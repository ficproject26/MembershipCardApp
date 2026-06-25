import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/config_model.dart';
import '../models/user_model.dart';

class PricingService {
  final Dio _dio = ApiClient.instance;

  Future<List<MembershipPricing>> getAllPricing() async {
    try {
      final response = await _dio.get('/pricing');
      return (response.data as List)
          .map((e) => MembershipPricing.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to load pricing: ${e.message}');
    }
  }

  Future<MembershipPricing> updatePricing(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/pricing/$id', data: data);
      return MembershipPricing.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update pricing: ${e.message}');
    }
  }

  Future<MembershipPricing> createPricing(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/pricing', data: data);
      return MembershipPricing.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create pricing: ${e.message}');
    }
  }
}
