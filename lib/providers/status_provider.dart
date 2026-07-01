import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_client.dart';

class StatusUpdate {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final String type;
  final String? mediaUrl;
  final DateTime createdAt;

  StatusUpdate({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.type,
    this.mediaUrl,
    required this.createdAt,
  });

  factory StatusUpdate.fromJson(Map<String, dynamic> json) {
    return StatusUpdate(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'TEXT',
      mediaUrl: json['mediaUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class StatusProvider extends ChangeNotifier {
  List<StatusUpdate> _statuses = [];
  bool _isLoading = false;

  List<StatusUpdate> get statuses => _statuses;
  bool get isLoading => _isLoading;

  StatusUpdate? getStatusForUser(String userId) {
    try {
      return _statuses.firstWhere((s) => s.userId == userId);
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchStatuses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get('/status');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _statuses = data.map((json) => StatusUpdate.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching statuses: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> postStatus(String userId, String userName, String content) async {
    try {
      final response = await ApiClient.instance.post('/status', data: {
        'userId': userId,
        'userName': userName,
        'content': content,
      });
      if (response.statusCode == 201) {
        await fetchStatuses();
        return true;
      }
    } catch (e) {
      print('Error posting status: $e');
    }
    return false;
  }

  Future<bool> postMediaStatus(String userId, String userName, String type, File file, {String? content}) async {
    try {
      String fileName = file.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        'userId': userId,
        'userName': userName,
        'type': type,
        if (content != null && content.isNotEmpty) 'content': content,
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await ApiClient.instance.post('/status/media', data: formData);
      if (response.statusCode == 201) {
        await fetchStatuses();
        return true;
      }
    } catch (e) {
      print('Error posting media status: $e');
    }
    return false;
  }

  Future<bool> deleteStatus(String statusId) async {
    try {
      final response = await ApiClient.instance.delete('/status/$statusId');
      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchStatuses();
        return true;
      }
    } catch (e) {
      print('Error deleting status: $e');
    }
    return false;
  }
}
