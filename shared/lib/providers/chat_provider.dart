import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io';
import '../models/message_model.dart';
import '../services/api_client.dart';
import 'package:dio/dio.dart';

class ChatProvider with ChangeNotifier {
  IO.Socket? _socket;
  IO.Socket? get socket => _socket;
  String get _serverUrl => ApiClient.instance.options.baseUrl;
  
  String? _currentUserId;
  String? _currentUserRole;

  // Map of ChatPartnerId -> List of Messages
  final Map<String, List<MessageModel>> _messages = {};
  
  // Track last message per contact for the UI
  final Map<String, MessageModel> _lastMessages = {};

  Map<String, List<MessageModel>> get messages => _messages;

  void init(String userId, String userRole) {
    if (_currentUserId == userId) return; // Already initialized

    _currentUserId = userId;
    _currentUserRole = userRole;

    _socket = IO.io(_serverUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build()
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Connected to Socket Server');
      _socket!.emit('join', {'userId': userId});
    });

    _socket!.on('newMessage', (data) {
      final msg = MessageModel.fromJson(data);
      final partnerId = (msg.senderId == _currentUserId) ? msg.receiverId : msg.senderId;
      
      if (!_messages.containsKey(partnerId)) {
        _messages[partnerId] = [];
      }
      _messages[partnerId]!.add(msg);
      _lastMessages[partnerId] = msg;
      notifyListeners();
    });

    _socket!.onDisconnect((_) => print('Disconnected from Socket Server'));

    // Fetch recent chats immediately on init
    fetchRecentChats();
  }

  Future<void> fetchRecentChats() async {
    if (_currentUserId == null) return;
    try {
      final response = await ApiClient.instance.get('/chat/recent/$_currentUserId');
      final List<dynamic> data = response.data;
      
      for (var json in data) {
        final msg = MessageModel.fromJson(json);
        final partnerId = (msg.senderId == _currentUserId) ? msg.receiverId : msg.senderId;
        
        _lastMessages[partnerId] = msg;
        
        // Also populate messages list with at least the last message if empty
        if (!_messages.containsKey(partnerId)) {
          _messages[partnerId] = [msg];
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching recent chats: $e');
    }
  }

  Future<void> fetchHistory(String partnerId) async {
    if (_currentUserId == null) return;
    try {
      final response = await ApiClient.instance.get('/chat/$_currentUserId/$partnerId');
      final List<dynamic> data = response.data;
      _messages[partnerId] = data.map((e) => MessageModel.fromJson(e)).toList();
      
      if (_messages[partnerId]!.isNotEmpty) {
        _lastMessages[partnerId] = _messages[partnerId]!.last;
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching history: $e');
    }
  }

  List<MessageModel> getMessagesFor(String partnerId) {
    return _messages[partnerId] ?? [];
  }

  MessageModel? getLastMessageFor(String partnerId) {
    return _lastMessages[partnerId];
  }

  void sendMessage(String receiverId, String receiverRole, String content, {String type = 'TEXT'}) {
    if (_socket == null || _currentUserId == null) return;
    
    if (!_socket!.connected) {
      _socket!.connect();
    }

    _socket!.emit('sendMessage', {
      'senderId': _currentUserId,
      'senderType': _currentUserRole,
      'receiverId': receiverId,
      'receiverType': receiverRole,
      'content': content,
      'type': type,
    });
  }

  Future<void> sendMediaMessage(String receiverId, String receiverRole, File file, String type, String content) async {
    if (_socket == null || _currentUserId == null) return;

    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await ApiClient.instance.post('/chat/media', data: formData);
      final mediaUrl = response.data['mediaUrl'];

      _socket!.emit('sendMessage', {
        'senderId': _currentUserId,
        'senderType': _currentUserRole,
        'receiverId': receiverId,
        'receiverType': receiverRole,
        'content': content,
        'type': type,
        'mediaUrl': mediaUrl,
      });
    } catch (e) {
      print('Error sending media: $e');
    }
  }

  @override
  void dispose() {
    _socket?.disconnect();
    super.dispose();
  }
}
