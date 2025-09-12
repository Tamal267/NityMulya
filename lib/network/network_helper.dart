import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

// Get server URL from ApiConfig
String get serverUrl => ApiConfig.baseUrl;

// A simple utility class to handle all API requests.
class NetworkHelper {
  // Use a final instance of FlutterSecureStorage
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Function to save the token after a successful login/auth
  Future<void> setToken(String token) async {
    try {
      if (token.isEmpty) {
        // If empty token, clear it
        await _secureStorage.delete(key: 'token');
      } else {
        await _secureStorage.write(key: 'token', value: token);
      }
      print('🔑 Token updated in secure storage: ${token.isEmpty ? "cleared" : "set"}');
    } catch (e) {
      print('🔑 Error setting token: $e');
    }
  }

  // Function to get the stored token from secure storage
  Future<String?> getToken() async {
    try {
      // First try to get from secure storage
      String? token = await _secureStorage.read(key: 'token');
      
      // If not found in secure storage, try to sync from UserSession
      if (token == null || token.isEmpty) {
        await syncTokenFromUserSession();
        token = await _secureStorage.read(key: 'token');
      }
      
      return token;
    } catch (e) {
      print('🔑 Error getting token: $e');
      return null;
    }
  }

  // Clear token completely
  Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: 'token');
      print('🔑 Token cleared from secure storage');
    } catch (e) {
      print('🔑 Error clearing token: $e');
    }
  }

  // Sync token from SharedPreferences (UserSession) to SecureStorage
  Future<void> syncTokenFromUserSession() async {
    try {
      // Import UserSession dynamically to avoid circular dependency
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        await setToken(token);
      }
    } catch (e) {
      print('Error syncing token: $e');
    }
  }

  // A generic POST request function
  Future<dynamic> post(String url, Map<String, dynamic> data) async {
    final fullUrl = Uri.parse('$serverUrl$url');

    try {
      final response = await http.post(
        fullUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // A generic GET request function
  Future<dynamic> get(String url) async {
    final fullUrl = Uri.parse('$serverUrl$url');

    try {
      final response = await http.get(
        fullUrl,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // A GET request with a token in the header
  Future<dynamic> getWithToken(String url) async {
    // First try to sync token from UserSession
    await syncTokenFromUserSession();
    
    final token = await getToken();
    if (token == null) {
      return {'error': 'Unauthorized'};
    }

    final fullUrl = Uri.parse('$serverUrl$url');
    try {
      final response = await http.get(
        fullUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // A POST request with a token in the header
  Future<dynamic> postWithToken(String url, Map<String, dynamic> data) async {
    // First try to sync token from UserSession
    await syncTokenFromUserSession();
    
    final token = await getToken();
    if (token == null) {
      return {'error': 'Unauthorized'};
    }

    final fullUrl = Uri.parse('$serverUrl$url');
    try {
      // Use longer timeout for inventory operations
      final timeoutDuration = url.contains('/inventory') 
          ? const Duration(seconds: 10) 
          : const Duration(seconds: 3);
          
      final response = await http
          .post(
            fullUrl,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(data),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // A generic PUT request function
  Future<dynamic> put(String url, Map<String, dynamic> data) async {
    final fullUrl = Uri.parse('$serverUrl$url');

    try {
      final response = await http.put(
        fullUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // A generic DELETE request function
  Future<dynamic> delete(String url) async {
    final fullUrl = Uri.parse('$serverUrl$url');

    try {
      final response = await http.delete(
        fullUrl,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // A PUT request with a token in the header
  Future<dynamic> putWithToken(String url, Map<String, dynamic> data) async {
    final token = await getToken();
    if (token == null) {
      return {'error': 'Unauthorized'};
    }

    final fullUrl = Uri.parse('$serverUrl$url');
    try {
      final response = await http.put(
        fullUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // A DELETE request with a token in the header
  Future<dynamic> deleteWithToken(String url) async {
    final token = await getToken();
    if (token == null) {
      return {'error': 'Unauthorized'};
    }

    final fullUrl = Uri.parse('$serverUrl$url');
    try {
      final response = await http.delete(
        fullUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // A private helper to handle common response logic
  dynamic _handleResponse(http.Response response) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        return {'error': 'Server error: ${response.statusCode}'};
      }
    } on FormatException catch (e) {
      return {'error': 'JSON parsing error: $e'};
    }
  }
}
