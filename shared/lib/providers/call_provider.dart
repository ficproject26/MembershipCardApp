import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

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

  bool _isSpeakerOn = true;
  bool get isSpeakerOn => _isSpeakerOn;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Timer? _callTimer;
  int _duration = 0;
  int get duration => _duration;

  String get formattedDuration {
    final hours = (_duration ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_duration % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_duration % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _startCallTimer() {
    if (_callTimer != null) return; // Already running
    _duration = 0;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration++;
      notifyListeners();
    });
  }

  void _stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
    _duration = 0;
  }

  CallProvider() {
    // No-op constructor
  }

  void init({
    required IO.Socket socket,
    required String currentUserId,
    required String currentUserName,
    required String currentUserType,
  }) {
    // Update user info always
    _currentUserId = currentUserId;
    _currentUserName = currentUserName;
    _currentUserType = currentUserType;

    // If same socket, just ensure join is emitted (don't re-register listeners)
    if (_socket == socket) {
      _ensureJoined();
      return;
    }

    // New socket — register listeners
    _socket = socket;
    _listenToSignaling();
  }

  void _ensureJoined() {
    if (_socket == null || _currentUserId == null) return;
    if (_socket!.connected) {
      debugPrint("CallProvider: _ensureJoined - socket already connected, emitting join for $_currentUserId");
      _socket!.emit('join', {'userId': _currentUserId});
    }
    // If not connected yet, the onConnect handler in _listenToSignaling will emit join
  }

  @override
  void dispose() {
    _engine?.release();
    super.dispose();
  }

  void _listenToSignaling() {
    debugPrint("CallProvider: _listenToSignaling started. Socket connected: ${_socket?.connected}");
    
    _socket!.onConnect((_) {
      debugPrint("CallProvider Socket connected - emitting join for $_currentUserId");
      // Re-emit join so backend registers us for call routing
      _socket!.emit('join', {'userId': _currentUserId});
    });
    
    // If socket is already connected when we init, emit join immediately
    if (_socket!.connected) {
      debugPrint("CallProvider: Socket already connected, emitting join immediately");
      _socket!.emit('join', {'userId': _currentUserId});
    }
    
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
            // Immediately update state so UI shows Connected
            _callState = CallState.inCall;
            _startCallTimer();
            notifyListeners();
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
    _startCallTimer();
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

  int _getUidFromString(String? id) {
    if (id == null) return 0;
    return id.hashCode & 0x7FFFFFFF; // Stable 31-bit positive integer
  }

  Future<String?> _fetchToken(String channelName, int uid) async {
    try {
      final response = await http.get(Uri.parse('$_tokenServerUrl/agora/rtcToken?channelName=$channelName&uid=$uid'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['token'];
      }
    } catch (e) {
      debugPrint("Token fetch error: $e");
    }
    return null;
  }

  Future<void> _startAgora() async {
    // Agora RTC Engine does NOT support web/Chrome
    if (kIsWeb) {
      debugPrint("CallProvider: Agora not supported on Web. Skipping RTC join.");
      return;
    }

    try {
      // 1. Request Microphone and Camera permissions at runtime
      final List<Permission> permissions = [Permission.microphone];
      if (_isVideo) {
        permissions.add(Permission.camera);
      }

      // Request Bluetooth Connect permission on Android 12+ (API 31+) to prevent SecurityException during audio routing
      if (defaultTargetPlatform == TargetPlatform.android) {
        permissions.add(Permission.bluetoothConnect);
      }
      
      final statuses = await permissions.request();
      final micGranted = statuses[Permission.microphone] == PermissionStatus.granted;
      final camGranted = !_isVideo || statuses[Permission.camera] == PermissionStatus.granted;
      final btGranted = defaultTargetPlatform != TargetPlatform.android || 
                         statuses[Permission.bluetoothConnect] == PermissionStatus.granted;
      
      if (!micGranted || !camGranted || !btGranted) {
        debugPrint("CallProvider: Permissions not fully granted. Mic: $micGranted, Cam: $camGranted, BT: $btGranted");
      }

      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: _agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
            debugPrint("local user ${connection.localUid} joined Agora channel");
            _localUid = connection.localUid;
            _errorMessage = null; // Clear error on join success
            _startCallTimer(); // Ensure timer starts when we successfully join
            
            try {
              // Safely configure volumes and audio routing now that the engine is ready
              await _engine?.adjustRecordingSignalVolume(100);
              await _engine?.adjustPlaybackSignalVolume(100);
              if (!_isVideo) {
                await _engine?.setEnableSpeakerphone(_isSpeakerOn);
              }
            } catch (e) {
              debugPrint("Agora post-join setup error: $e");
            }
            
            notifyListeners();
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("remote user $remoteUid joined Agora channel");
            _remoteUid = remoteUid;
            _callState = CallState.inCall;
            _startCallTimer(); // Ensure timer starts when remote user joins
            notifyListeners();
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint("remote user $remoteUid left Agora channel");
            _remoteUid = null;
            _resetCall();
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            debugPrint("left Agora channel");
            _localUid = null;
            _remoteUid = null;
          },
          onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
            debugPrint("Agora Connection state changed: $state, reason: $reason");
            if (state == ConnectionStateType.connectionStateFailed) {
              _errorMessage = "Connection failed: $reason";
              notifyListeners();
            }
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint("Agora error: $err - $msg");
            _errorMessage = "Agora Error: $err - $msg";
            notifyListeners();
          },
        ),
      );

      // Enable required media modules before joining
      await _engine!.enableAudio();

      if (_isVideo) {
        await _engine!.enableVideo();
        await _engine!.startPreview();
      }

      final myUid = _getUidFromString(_currentUserId);
      final token = await _fetchToken(_channelName!, myUid);
      debugPrint("CallProvider: Joining Agora channel: $_channelName with uid: $myUid and token: ${token != null ? 'OK' : 'NULL'}");

      await _engine!.joinChannel(
        token: token ?? '',
        channelId: _channelName ?? 'default_channel',
        uid: myUid,
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          publishCameraTrack: _isVideo,
          autoSubscribeAudio: true,
          autoSubscribeVideo: _isVideo,
        ),
      );

      // Explicitly unmute local and remote audio streams to ensure sound flows
      await _engine!.muteLocalAudioStream(false);
      await _engine!.muteAllRemoteAudioStreams(false);
    } catch (e) {
      debugPrint("Agora initialize/join error: $e");
      _errorMessage = "Agora Init Error: $e";
      notifyListeners();
    }
  }

  Future<void> _resetCall() async {
    _callState = CallState.idle;
    _stopCallTimer();
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
    _isSpeakerOn = true;
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

  void toggleSpeaker() {
    if (_engine != null) {
      _isSpeakerOn = !_isSpeakerOn;
      _engine!.setEnableSpeakerphone(_isSpeakerOn);
      notifyListeners();
    }
  }

  void switchCamera() {
    if (_engine != null && _isVideo) {
      _engine!.switchCamera();
    }
  }
}
