import 'package:nitymulya/api/http_client.dart';

class PriceListService {
  /// Fetch price list using the structured HttpClient
  static Future<ApiResponse> fetchPriceList() async {
    try {
      final response = await HttpClient.get('/get_pricelist');
      
      if (!response.success) {
        return ApiResponse.error(response.error ?? 'Unknown error');
      }

      // Handle both List and Map responses
      if (response.data is List) {
        // If API returns a list, wrap it for consistency
        return ApiResponse.success({'data': response.data});
      } else if (response.data is Map) {
        // If API returns a map, use it directly
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error('Unexpected response format');
      }
    } catch (e) {
      return ApiResponse.error('Failed to fetch price list: $e');
    }
  }

  /// Get price list as a List for UI consumption
  static Future<List<Map<String, dynamic>>> fetchPriceListAsArray() async {
    try {
      final response = await fetchPriceList();
      
      if (!response.success) {
        throw Exception(response.error);
      }

      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        // Extract the list from wrapped response
        final listData = data['data'];
        if (listData is List) {
          return listData.cast<Map<String, dynamic>>();
        }
      }
      
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      
      if (data is Map) {
        return [data.cast<String, dynamic>()];
      }
      
      throw Exception('Invalid data format');
    } catch (e) {
      throw Exception('Failed to fetch price list: $e');
    }
  }
}
