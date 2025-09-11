import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Your base server URL - Android emulator compatible
String get serverUrl {
  final envUrl = dotenv.env['SERVER_URL'];
  if (envUrl != null) return envUrl;
  
  if (kIsWeb) {
    return 'http://localhost:3005';
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:3005';
  } else {
    return 'http://localhost:3005';
  }
}

// A simple utility class to handle all API requests.
class NetworkHelper {
  // Use a final instance of FlutterSecureStorage
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Function to save the token after a successful login/auth
  Future<void> setToken(String token) async {
    await _secureStorage.write(key: 'token', value: token);
  }

  // Function to get the stored token from secure storage
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'token');
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
