import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/lead_model.dart';
import '../models/kyc_document_model.dart';

class LeadService {
  final Dio _dio = ApiClient.instance;

  Future<List<LeadModel>> getAllLeads() async {
    try {
      final response = await _dio.get('/lead');
      return (response.data as List)
          .map((e) => LeadModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to load leads: ${e.message}');
    }
  }

  Future<List<LeadModel>> getLeadsByStatusAndServiceType(String status, String serviceType) async {
    try {
      final response = await _dio.get('/lead?status=$status&serviceType=$serviceType');
      return (response.data as List)
          .map((e) => LeadModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to load leads: ${e.message}');
    }
  }

  Future<List<LeadModel>> getLeadsByAgent(String agentId) async {
    try {
      final response = await _dio.get('/lead/agent/$agentId');
      return (response.data as List)
          .map((e) => LeadModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to load agent leads: ${e.message}');
    }
  }

  Future<LeadModel> getLeadById(String id) async {
    try {
      final response = await _dio.get('/lead/$id');
      return LeadModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load lead details: ${e.message}');
    }
  }

  Future<LeadModel> createLead(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/lead', data: data);
      return LeadModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create lead: ${e.message}');
    }
  }

  Future<LeadModel> updateLead(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/lead/$id', data: data);
      return LeadModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update lead: ${e.message}');
    }
  }

  Future<String> generateKycLink(String leadId) async {
    try {
      final response = await _dio.post('/kyc-upload/generate-link/$leadId');
      return response.data['url'] as String;
    } on DioException catch (e) {
      throw Exception('Failed to generate KYC link: ${e.message}');
    }
  }

  Future<List<KycDocument>> getKycDocuments(String leadId) async {
    try {
      final response = await _dio.get('/kyc-upload/documents/$leadId');
      return (response.data as List)
          .map((e) => KycDocument.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to get KYC documents: ${e.message}');
    }
  }
}
