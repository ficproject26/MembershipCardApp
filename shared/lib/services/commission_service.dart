import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/config_model.dart';

class CommissionService {
  final Dio _dio = ApiClient.instance;

  Future<List<CommissionConfig>> getAllCommissions() async {
    try {
      final response = await _dio.get('/commission');
      return (response.data as List)
          .map((e) => CommissionConfig.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to load commissions: ${e.message}');
    }
  }

  Future<CommissionConfig> updateCommission(String serviceType, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/commission/$serviceType', data: data);
      return CommissionConfig.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update commission: ${e.message}');
    }
  }
}
