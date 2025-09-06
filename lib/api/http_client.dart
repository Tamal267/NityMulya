import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class HttpClient {
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null) return envUrl;
    
    if (kIsWeb) {
      return 'http://localhost:3005';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3005';
    } else {
      return 'http://localhost:3005';
    }
  }
  static const Duration timeout = Duration(seconds: 10);

  static Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Make a GET request
  static Future<ApiResponse> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('🔄 GET Request: $url');

      final response = await http.get(
        url,
        headers: {..._defaultHeaders, ...?headers},
      ).timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      print('❌ GET Error: $e');
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Make a POST request
  static Future<ApiResponse> post(String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('🔄 POST Request: $url');
      
      final response = await http.post(
        url,
        headers: {..._defaultHeaders, ...?headers},
        body: body != null ? json.encode(body) : null,
      ).timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      print('❌ POST Error: $e');
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Handle HTTP response
  static ApiResponse _handleResponse(http.Response response) {
    print('📡 Response Status: ${response.statusCode}');
    print('📊 Response Body Length: ${response.body.length}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = json.decode(response.body);
        print('✅ Response Data: ${data.toString().substring(0, data.toString().length > 200 ? 200 : data.toString().length)}...');
        return ApiResponse.success(data);
      } catch (e) {
        print('❌ JSON Parse Error: $e');
        return ApiResponse.error('Failed to parse response: $e');
      }
    } else {
      print('❌ HTTP Error ${response.statusCode}: ${response.body}');
      return ApiResponse.error('Server error: ${response.statusCode} - ${response.body}');
    }
  }
}

/// API Response wrapper
class ApiResponse {
  final bool success;
  final dynamic data;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(dynamic data) {
    return ApiResponse(success: true, data: data);
  }

  factory ApiResponse.error(String error, [int? statusCode]) {
    return ApiResponse(success: false, error: error, statusCode: statusCode);
  }

  @override
  String toString() {
    if (success) {
      return 'ApiResponse(success: true, data: $data)';
    } else {
      return 'ApiResponse(success: false, error: $error)';
    }
  }
}
