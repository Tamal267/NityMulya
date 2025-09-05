import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiService {
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      // URL encode the endpoint to handle Bengali characters
      final encodedEndpoint = Uri.encodeFull(endpoint);
      final response = await http.get(
        Uri.parse('$baseUrl$encodedEndpoint'),
        headers: {'Content-Type': 'application/json'},
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  static Future<Map<String, dynamic>> put(String endpoint,
      [Map<String, dynamic>? data]) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: data != null ? json.encode(data) : null,
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to update data: $e');
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }
}
