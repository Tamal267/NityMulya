import 'dart:convert';
import 'package:http/http.dart' as http;

class EnhancedFeaturesService {
  static const String _baseUrl = 'http://localhost:3005/api/enhanced';
  
  // ================================
  // FAVOURITES SERVICE
  // ================================
  
  static Future<Map<String, dynamic>> getFavourites({
    required String customerId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/favourites/$customerId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch favourites: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching favourites: $e');
    }
  }

  static Future<Map<String, dynamic>> addToFavourites({
    required String customerId,
    required String shopId,
    required String productId,
    String? productName,
    String? shopName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/favourites'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer_id': customerId,
          'shop_owner_id': shopId,
          'subcat_id': productId,
          'product_name': productName,
          'shop_name': shopName,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to add to favourites: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding to favourites: $e');
    }
  }

  static Future<Map<String, dynamic>> removeFromFavourites({
    required String customerId,
    required String shopId,
    required String productId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/favourites/$customerId/$shopId/$productId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to remove from favourites: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing from favourites: $e');
    }
  }

  // ================================
  // PRICE HISTORY SERVICE
  // ================================
  
  static Future<Map<String, dynamic>> getPriceHistory({
    required String productId,
    required String shopId,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      String url = '$_baseUrl/price-history/$productId/$shopId?limit=$limit&offset=$offset';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch price history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching price history: $e');
    }
  }

  static Future<Map<String, dynamic>> addPriceHistory({
    required String shopOwnerId,
    required String subcatId,
    required double price,
    String? priceType,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/price-history'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'shop_owner_id': shopOwnerId,
          'subcat_id': subcatId,
          'price': price,
          'price_type': priceType ?? 'retail',
          'notes': notes,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to add price history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding price history: $e');
    }
  }

  // ================================
  // REVIEWS SERVICE
  // ================================
  
  static Future<Map<String, dynamic>> getReviews({
    required dynamic shopId, // Accept both String and int
    String? productId,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      String url = '$_baseUrl/reviews/$shopId?limit=$limit&offset=$offset';
      if (productId != null) {
        url += '&productId=$productId';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  static Future<Map<String, dynamic>> addReview({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String shopId,
    String? shopName,
    String? productId,
    String? productName,
    required int overallRating,
    int? productQualityRating,
    int? serviceRating,
    int? deliveryRating,
    String? reviewTitle,
    required String reviewComment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer_id': customerId,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'shop_id': shopId,
          'shop_name': shopName,
          'product_id': productId,
          'product_name': productName,
          'overall_rating': overallRating,
          'product_quality_rating': productQualityRating,
          'service_rating': serviceRating,
          'delivery_rating': deliveryRating,
          'review_title': reviewTitle,
          'review_comment': reviewComment,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to add review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding review: $e');
    }
  }

  // ================================
  // COMPLAINTS SERVICE
  // ================================
  
  static Future<Map<String, dynamic>> getComplaints({
    required String customerId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/complaints/$customerId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch complaints: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching complaints: $e');
    }
  }

  static Future<Map<String, dynamic>> submitComplaint({
    required String customerId,
    required String customerName,
    required String customerEmail,
    String? customerPhone,
    required String shopId,
    String? shopName,
    String? productId,
    String? productName,
    required String complaintType,
    required String subject,
    required String description,
    String? priority,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/complaints'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer_id': customerId,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'customer_phone': customerPhone,
          'shop_owner_id': shopId,
          'shop_name': shopName,
          'product_id': productId,
          'product_name': productName,
          'complaint_type': complaintType,
          'subject': subject,
          'description': description,
          'priority': priority ?? 'medium',
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to submit complaint: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting complaint: $e');
    }
  }

  static Future<Map<String, dynamic>> updateComplaintStatus({
    required String complaintId,
    required String status,
    String? adminNotes,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/complaints/$complaintId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': status,
          'admin_notes': adminNotes,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update complaint status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating complaint status: $e');
    }
  }

  // ================================
  // HEALTH CHECK
  // ================================
  
  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking health: $e');
    }
  }
}
