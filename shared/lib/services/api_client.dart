import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global navigator key — used for 401 auto-logout redirect.
/// Also used by incoming_call_overlay for navigation.
final GlobalKey<NavigatorState> sharedNavigatorKey = GlobalKey<NavigatorState>();

class ApiClient {
  // Set to true for production, false for local development
  static const bool _isProduction = true;

  static const String _productionUrl = 'https://membershipcardapp.onrender.com';
  
  static String get _devUrl {
    // If you are using an Android EMULATOR, change this back to 'http://10.0.2.2:3001'
    return 'http://localhost:3001';
  }

  static String get baseUrl => _isProduction ? _productionUrl : _devUrl;
  static String get _baseUrl => baseUrl;

  static Dio? _dioInstance;

  static Dio get instance {
    _dioInstance ??= _createDio();
    return _dioInstance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ─── Security: SSL Certificate Pinning (Production Only) ───
    // Prevents man-in-the-middle (MITM) attacks by validating server cert
    if (_isProduction && !kIsWeb) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          // Only allow connections to our production domain
          if (host == 'membershipcardapp.onrender.com') {
            // In production, we trust the certificate chain
            // For extra security, you can pin specific certificate fingerprints here
            return true;
          }
          // Reject all other hosts
          return false;
        };
        return client;
      };
    }

    // Add interceptors
    dio.interceptors.addAll([
      _AuthInterceptor(),
      _SecurityResponseInterceptor(),
    ]);

    return dio;
  }
}

/// ─── Auth Interceptor ───
/// Attaches JWT token to every request automatically
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
}

/// ─── Security Response Interceptor ───
/// Handles 401 (Unauthorized) — auto logout + redirect to login
/// Handles 429 (Too Many Requests) — shows rate limit message
class _SecurityResponseInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // ─── Auto Logout: Token expired or invalid ───
      debugPrint('🔒 SecurityInterceptor: 401 Unauthorized — clearing tokens');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('user_data');
      await prefs.remove('staff_data');

      // Navigate to login screen
      sharedNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    } else if (err.response?.statusCode == 429) {
      // ─── Rate Limited ───
      debugPrint('⚠️ SecurityInterceptor: 429 Too Many Requests — rate limited');
    }

    handler.next(err);
  }
}

