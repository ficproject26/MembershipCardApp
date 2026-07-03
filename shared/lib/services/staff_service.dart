import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/staff_model.dart';
import '../models/hr_dashboard_model.dart';

class StaffService {
  final Dio _dio = ApiClient.instance;

  Future<List<StaffModel>> getAllStaff() async {
    try {
      final response = await _dio.get('/staff');
      return (response.data as List)
          .map((e) => StaffModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to load staff: ${e.message}');
    }
  }

  Future<StaffModel> createStaff(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/staff', data: data);
      return StaffModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create staff: ${e.message}');
    }
  }

  Future<StaffModel> loginStaff(String email, String password) async {
    try {
      final response = await _dio.post('/staff/login', data: {
        'email': email,
        'password': password,
      });
      return StaffModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('No staff account found with this email');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Invalid password');
      }
      throw Exception('Login failed: ${e.message}');
    }
  }

  Future<StaffModel> getStaff(String id) async {
    try {
      final response = await _dio.get('/staff/$id');
      return StaffModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load staff member: ${e.message}');
    }
  }

  Future<HrDashboardStats> getHrDashboardStats() async {
    try {
      final response = await _dio.get('/staff/hr-dashboard/stats');
      return HrDashboardStats.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load HR dashboard stats: ${e.message}');
    }
  }
}

