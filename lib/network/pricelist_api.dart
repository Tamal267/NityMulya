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

// Fetch shops from the server
Future<List<Map<String, dynamic>>> fetchShops() async {
  try {
    final response = await _apiClient.get('/get_shops');

    // Handle List response
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
    throw Exception('Failed to fetch shops: $e');
  }
}

// Fetch shops that have a specific product (by subcategory ID)
Future<List<Map<String, dynamic>>> fetchShopsBySubcategoryId(
    String subcatId) async {
  try {
    final response = await _apiClient.get('/get_shops_by_subcat/$subcatId');

    // Handle List response
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
    throw Exception('Failed to fetch shops by subcategory: $e');
  }
}

// Fetch shops that have a specific product (legacy endpoint using product name)
Future<List<Map<String, dynamic>>> fetchShopsByProduct(
    String productName) async {
  try {
    final response = await _apiClient.get('/get_shops_by_product/$productName');

    // Handle List response
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
    throw Exception('Failed to fetch shops by product: $e');
  }
}

// Fetch price history for a product
Future<Map<String, dynamic>> fetchProductPriceHistory(
    String productName) async {
  try {
    final response = await _apiClient.get('/get_price_history/$productName');

    // Handle Map response
    if (response is Map<String, dynamic>) {
      return response;
    }

    // Handle Map response with error
    if (response is Map && response.containsKey('error')) {
      throw Exception(response['error']);
    }

    throw Exception('Unexpected response format: ${response.runtimeType}');
  } catch (e) {
    throw Exception('Failed to fetch price history: $e');
  }
}
