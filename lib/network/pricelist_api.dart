import 'package:nitymulya/network/network_helper.dart';

final _apiClient = NetworkHelper();

// Fetch the price list from the server and return it as a List
Future<List<Map<String, dynamic>>> fetchPriceList() async {
  try {
    // Call the API to get the price list
    final response = await _apiClient.get('/get_pricelist');
    // print('API Response: $response');

    // Handle List response (which is what the API actually returns)
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    
    // Handle Map response with error
    if (response is Map && response.containsKey('error')) {
      throw Exception(response['error']);
    }
    
    // Handle Map response with data
    if (response is Map && response.containsKey('data')) {
      final data = response['data'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
    }
    
    throw Exception('Unexpected response format: ${response.runtimeType}');
  } catch (e) {
    throw Exception('Failed to fetch price list: $e');
  }
}

Future<List<Map<String, dynamic>>> fetchCategories() async {
  try {
    // Call the API to get the categories
    final response = await _apiClient.get('/get_categories');

    // Handle List response (which is what the API actually returns)
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }

    // Handle Map response with error
    if (response is Map && response.containsKey('error')) {
      throw Exception(response['error']);
    }

    // Handle List response (which is what the API actually returns)
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    
    // Handle Map response with error
    if (response is Map && response.containsKey('error')) {
      throw Exception(response['error']);
    }
    
    // Handle Map response with data
    if (response is Map && response.containsKey('data')) {
      final data = response['data'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
    }
    
    throw Exception('Unexpected response format: ${response.runtimeType}');
  } catch (e) {
    throw Exception('Failed to fetch categories: $e');
  }
}