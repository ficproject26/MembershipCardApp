import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

enum CallState { idle, incoming, outgoing, inCall }

class CallProvider extends ChangeNotifier {
  IO.Socket? _socket;
  String? _currentUserId;
  String? _currentUserName;
  String? _currentUserType; // 'agent' or 'staff'
  
  static const String _agoraAppId = "f89a31b7e1bf419682f062607b2d8850";
  static const String _tokenServerUrl = "https://membershipcardapp.onrender.com";

  CallState _callState = CallState.idle;
  CallState get callState => _callState;

  bool _isVideo = true;
  bool get isVideo => _isVideo;

  String? _remoteUserId;
  String? get remoteUserId => _remoteUserId;

  String? _remoteUserName;
  String? get remoteUserName => _remoteUserName;

  String? _channelName;
  String? get channelName => _channelName;

  RtcEngine? _engine;
  RtcEngine? get engine => _engine;

  int? _localUid;
  int? get localUid => _localUid;

  int? _remoteUid;
  int? get remoteUid => _remoteUid;

  bool _isMicMuted = false;
  bool get isMicMuted => _isMicMuted;

  bool _isCameraOff = false;
  bool get isCameraOff => _isCameraOff;

  CallProvider() {
    // No-op constructor
  }

  void init({
    required IO.Socket socket,
    required String currentUserId,
    required String currentUserName,
    required String currentUserType,
  }) {
    if (_socket != null) return; // Already initialized
    
    _socket = socket;
    _currentUserId = currentUserId;
    _currentUserName = currentUserName;
    _currentUserType = currentUserType;
    
    _listenToSignaling();
  }

  @override
  void dispose() {
    _engine?.release();
    super.dispose();
  }

  void _listenToSignaling() {
    debugPrint("CallProvider: _listenToSignaling started. Socket connected: ${_socket?.connected}");
    
    _socket!.onConnect((_) {
      debugPrint("CallProvider Socket connected successfully");
    });
    
    _socket!.onDisconnect((_) {
      debugPrint("CallProvider Socket disconnected");
    });

    _socket!.on('webrtc-signaling', (data) async {
      debugPrint("CallProvider: Received signaling event: ${data['type']} with data: $data");
      final type = data['type'];
      final payload = data['payload'];

      switch (type) {
        case 'call-initiate':
          debugPrint("CallProvider: Processing call-initiate. Current state: $_callState");
          if (_callState != CallState.idle) {
            debugPrint("CallProvider: Rejecting call because state is not idle (busy)");
            _emitSignaling('call-reject', {'reason': 'busy'}, data['callerId']);
            return;
          }
          _remoteUserId = data['callerId'];
          _remoteUserName = data['callerName'];
          _isVideo = data['isVideo'] ?? true;
          _channelName = payload != null ? payload['channelName'] : null;
          _callState = CallState.incoming;
          notifyListeners();
          debugPrint("CallProvider: Transitioned state to incoming. Remote user: $_remoteUserName");
          break;

        case 'call-accept':
          debugPrint("CallProvider: Processing call-accept. Current state: $_callState");
          if (_callState == CallState.outgoing) {
            await _startAgora();
          }
          break;

        case 'call-reject':
          debugPrint("CallProvider: Processing call-reject. Current state: $_callState");
          if (_callState == CallState.outgoing) {
            await _resetCall();
          }
          break;

        case 'call-hangup':
          debugPrint("CallProvider: Processing call-hangup. Current state: $_callState");
          await _resetCall();
          break;
      }
    });
  }

  void _emitSignaling(String type, Map<String, dynamic>? payload, String? toOverride) {
    final targetUser = toOverride ?? _remoteUserId;
    debugPrint("CallProvider: Emitting signaling event: $type to target: $targetUser");
    _socket!.emit('webrtc-signaling', {
      'to': targetUser,
      'type': type,
      'payload': payload,
      'callerId': _currentUserId,
      'callerName': _currentUserName,
      'callerType': _currentUserType,
      'isVideo': _isVideo,
    });
  }

  Future<void> initiateCall(String remoteUserId, String remoteUserName, bool isVideoCall) async {
    debugPrint("CallProvider: initiateCall called. targetId: $remoteUserId, targetName: $remoteUserName, isVideo: $isVideoCall");
    _remoteUserId = remoteUserId;
    _remoteUserName = remoteUserName;
    _isVideo = isVideoCall;
    _channelName = 'channel_${_currentUserId}_$remoteUserId';
    _callState = CallState.outgoing;
    notifyListeners();
    
    _emitSignaling('call-initiate', {'channelName': _channelName}, null);
  }

  Future<void> acceptCall() async {
    _callState = CallState.inCall;
    notifyListeners();
    _emitSignaling('call-accept', null, null);
    await _startAgora();
  }

  Future<void> rejectCall() async {
    _emitSignaling('call-reject', null, null);
    await _resetCall();
  }

  Future<void> endCall() async {
    _emitSignaling('call-hangup', null, null);
    await _resetCall();
  }

  Future<String?> _fetchToken(String channelName) async {
    try {
      final response = await http.get(Uri.parse('$_tokenServerUrl/agora/rtcToken?channelName=$channelName&uid=0'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['token'];
      }
    } catch (e) {
      debugPrint("Token fetch error: $e");
    }
    return null;
  }

  Future<void> _startAgora() async {
    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: _agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint("local user ${connection.localUid} joined");
            _localUid = connection.localUid;
            notifyListeners();
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("remote user $remoteUid joined");
            _remoteUid = remoteUid;
            _callState = CallState.inCall;
            notifyListeners();
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint("remote user $remoteUid left channel");
            _remoteUid = null;
            _resetCall();
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            debugPrint("left channel");
            _localUid = null;
            _remoteUid = null;
          },
        ),
      );

      if (_isVideo) {
        await _engine!.enableVideo();
        await _engine!.startPreview();
      } else {
        await _engine!.enableAudio();
      }

      final token = await _fetchToken(_channelName!);

      await _engine!.joinChannel(
        token: token ?? "",
        channelId: _channelName ?? 'default_channel',
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          publishCameraTrack: true,
        ),
      );
    } catch (e) {
      debugPrint("Agora initialize error: $e");
    }
  }

  Future<void> _resetCall() async {
    _callState = CallState.idle;
    _remoteUserId = null;
    _remoteUserName = null;
    _localUid = null;
    _remoteUid = null;

    if (_engine != null) {
      try {
        await _engine!.leaveChannel();
        await _engine!.release();
      } catch (e) {
        debugPrint("Agora leave/release error: $e");
      }
      _engine = null;
    }

    _isMicMuted = false;
    _isCameraOff = false;
    notifyListeners();
  }

  void toggleMic() {
    if (_engine != null) {
      _isMicMuted = !_isMicMuted;
      _engine!.muteLocalAudioStream(_isMicMuted);
      notifyListeners();
    }
  }

  void toggleCamera() {
    if (_engine != null && _isVideo) {
      _isCameraOff = !_isCameraOff;
      _engine!.muteLocalVideoStream(_isCameraOff);
      notifyListeners();
    }
  }
}
