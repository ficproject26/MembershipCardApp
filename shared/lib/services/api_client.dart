import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiClient {
  // Set to true for production, false for local development
  static const bool _isProduction = false;

  static const String _productionUrl = 'https://membershipcardapp.onrender.com';
  
  static String get _devUrl {
    // If you are using an Android EMULATOR, change this back to 'http://10.0.2.2:3001'
    return 'http://localhost:3001';
  }

  static String get baseUrl => _isProduction ? _productionUrl : _devUrl;
  static String get _baseUrl => baseUrl;

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(_AuthInterceptor());

  static Dio get instance => _dio;
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Could handle 401 token refresh here in the future
    handler.next(err);
  }
}
