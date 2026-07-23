import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/user_model.dart';

class AgentService {
  final Dio _dio = ApiClient.instance;

  Future<List<AgentModel>> getAllAgents() async {
    try {
      final response = await _dio.get('/agent');
      return (response.data as List)
          .map((e) => AgentModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception('Failed to load agents: $errorMsg');
    }
  }

  Future<AgentModel?> getAgent(String id) async {
    try {
      final response = await _dio.get('/agent/$id');
      return AgentModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception('Failed to load agent: $errorMsg');
    }
  }

  Future<AgentModel> createAgent(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/agent', data: data);
      return AgentModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
  }

  Future<AgentModel> loginAgent(String emailOrPhone, String password) async {
    try {
      final response = await _dio.post('/agent/login', data: {
        'email': emailOrPhone,
        'emailOrPhone': emailOrPhone,
        'password': password,
      });
      return AgentModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
  }

  Future<AgentModel> updateAgent(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/agent/$id', data: data);
      return AgentModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception('Failed to update agent: $errorMsg');
    }
  }

  Future<void> deleteAgent(String id) async {
    try {
      await _dio.delete('/agent/$id');
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception('Failed to delete agent: $errorMsg');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post('/auth/forgot-password', data: {
        'email': email,
      });
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
  }
}
