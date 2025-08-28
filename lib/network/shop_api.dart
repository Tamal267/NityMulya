import 'dart:convert';
import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ShopApi {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000';

  // Fetch all shops with their location data
  static Future<List<Map<String, dynamic>>> fetchShops() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_shops'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 404) {
        // No shops found
        return [];
      } else {
        throw Exception('Failed to load shops: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching shops: $e');
      throw Exception('Failed to load shops: $e');
    }
  }

  // Fetch shops by product subcategory
  static Future<List<Map<String, dynamic>>> fetchShopsBySubcategory(
      String subcatId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_shops_by_subcat/$subcatId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 404) {
        // No shops found for this product
        return [];
      } else {
        throw Exception(
            'Failed to load shops for product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching shops by subcategory: $e');
      throw Exception('Failed to load shops by subcategory: $e');
    }
  }

  // Calculate distance between two points (in kilometers)
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Filter shops by distance from user location
  static List<Map<String, dynamic>> filterShopsByDistance(
    List<Map<String, dynamic>> shops,
    double userLat,
    double userLon,
    double radiusKm,
  ) {
    return shops.where((shop) {
      final shopLat = parseDouble(shop['latitude']);
      final shopLon = parseDouble(shop['longitude']);

      if (shopLat == null || shopLon == null) return false;

      final distance = calculateDistance(userLat, userLon, shopLat, shopLon);
      return distance <= radiusKm;
    }).toList();
  }

  // Get nearby shops within radius from user location
  static Future<List<Map<String, dynamic>>> getNearbyShops(
    double userLat,
    double userLon,
    double radiusKm,
  ) async {
    try {
      final allShops = await fetchShops();
      return filterShopsByDistance(allShops, userLat, userLon, radiusKm);
    } catch (e) {
      print('Error fetching nearby shops: $e');
      throw Exception('Failed to load nearby shops: $e');
    }
  }

  // Helper method to safely parse double values
  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
