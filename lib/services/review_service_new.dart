import 'dart:convert';
import 'package:http/http.dart' as http;

class ReviewService {
  static const String baseUrl = 'http://localhost:5002';

  // ====================================
  // PRODUCT REVIEW METHODS
  // ====================================

  // Create a new product review
  static Future<Map<String, dynamic>> createProductReview({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String subcatId,
    required String productName,
    required String shopOwnerId,
    required String shopName,
    required int rating,
    String? comment,
    String? orderId,
    bool isVerifiedPurchase = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews/product/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'customer_id': customerId,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'subcat_id': subcatId,
          'product_name': productName,
          'shop_owner_id': shopOwnerId,
          'shop_name': shopName,
          'rating': rating,
          'comment': comment ?? '',
          'order_id': orderId,
          'is_verified_purchase': isVerifiedPurchase,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return {
            'success': true,
            'message': 'Product review created successfully',
            'review': data['review'],
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Failed to create product review',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error creating product review: $e');
      return {
        'success': false,
        'error': 'Network error: Unable to create product review',
      };
    }
  }

  // Get product reviews for a specific product
  static Future<List<Map<String, dynamic>>> getProductReviews(
    String subcatId, {
    String? shopOwnerId,
  }) async {
    try {
      String url = '$baseUrl/reviews/product/$subcatId';
      if (shopOwnerId != null) {
        url += '?shopOwnerId=$shopOwnerId';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['reviews'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('Error getting product reviews: $e');
      return [];
    }
  }

  // Get average rating for a product
  static Future<Map<String, dynamic>> getProductAverageRating(
    String subcatId, {
    String? shopOwnerId,
  }) async {
    try {
      String url = '$baseUrl/reviews/product/$subcatId/average';
      if (shopOwnerId != null) {
        url += '?shopOwnerId=$shopOwnerId';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return {
            'average': data['average'] ?? 0.0,
            'count': data['count'] ?? 0,
          };
        }
      }
      return {'average': 0.0, 'count': 0};
    } catch (e) {
      print('Error getting product average rating: $e');
      return {'average': 0.0, 'count': 0};
    }
  }

  // Update a product review
  static Future<Map<String, dynamic>> updateProductReview({
    required String reviewId,
    int? rating,
    String? comment,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reviews/product/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (rating != null) 'rating': rating,
          if (comment != null) 'comment': comment,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'],
          'review': data['review'],
        };
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error updating product review: $e');
      return {
        'success': false,
        'error': 'Network error: Unable to update product review',
      };
    }
  }

  // Delete a product review
  static Future<Map<String, dynamic>> deleteProductReview(String reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reviews/product/$reviewId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error deleting product review: $e');
      return {
        'success': false,
        'error': 'Network error: Unable to delete product review',
      };
    }
  }

  // ====================================
  // SHOP REVIEW METHODS
  // ====================================

  // Create a new shop review
  static Future<Map<String, dynamic>> createShopReview({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String shopOwnerId,
    required String shopName,
    required int overallRating,
    int? serviceRating,
    int? deliveryRating,
    String? comment,
    String? orderId,
    bool isVerifiedPurchase = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews/shop/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'customer_id': customerId,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'shop_owner_id': shopOwnerId,
          'shop_name': shopName,
          'overall_rating': overallRating,
          'service_rating': serviceRating,
          'delivery_rating': deliveryRating,
          'comment': comment ?? '',
          'order_id': orderId,
          'is_verified_purchase': isVerifiedPurchase,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return {
            'success': true,
            'message': 'Shop review created successfully',
            'review': data['review'],
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Failed to create shop review',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error creating shop review: $e');
      return {
        'success': false,
        'error': 'Network error: Unable to create shop review',
      };
    }
  }

  // Get shop reviews for a specific shop
  static Future<List<Map<String, dynamic>>> getShopReviews(String shopOwnerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/shop/$shopOwnerId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['reviews'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('Error getting shop reviews: $e');
      return [];
    }
  }

  // Get average ratings for a shop
  static Future<Map<String, dynamic>> getShopAverageRatings(String shopOwnerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/shop/$shopOwnerId/average'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return {
            'overall': data['overall'] ?? 0.0,
            'service': data['service'] ?? 0.0,
            'delivery': data['delivery'] ?? 0.0,
            'count': data['count'] ?? 0,
          };
        }
      }
      return {
        'overall': 0.0,
        'service': 0.0,
        'delivery': 0.0,
        'count': 0,
      };
    } catch (e) {
      print('Error getting shop average ratings: $e');
      return {
        'overall': 0.0,
        'service': 0.0,
        'delivery': 0.0,
        'count': 0,
      };
    }
  }

  // Update a shop review
  static Future<Map<String, dynamic>> updateShopReview({
    required String reviewId,
    int? overallRating,
    int? serviceRating,
    int? deliveryRating,
    String? comment,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reviews/shop/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (overallRating != null) 'overall_rating': overallRating,
          if (serviceRating != null) 'service_rating': serviceRating,
          if (deliveryRating != null) 'delivery_rating': deliveryRating,
          if (comment != null) 'comment': comment,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'],
          'review': data['review'],
        };
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error updating shop review: $e');
      return {
        'success': false,
        'error': 'Network error: Unable to update shop review',
      };
    }
  }

  // Delete a shop review
  static Future<Map<String, dynamic>> deleteShopReview(String reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reviews/shop/$reviewId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error deleting shop review: $e');
      return {
        'success': false,
        'error': 'Network error: Unable to delete shop review',
      };
    }
  }

  // ====================================
  // CUSTOMER REVIEW METHODS
  // ====================================

  // Get all product reviews by a specific customer
  static Future<List<Map<String, dynamic>>> getCustomerProductReviews(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/customer/$customerId/products'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['reviews'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('Error getting customer product reviews: $e');
      return [];
    }
  }

  // Get all shop reviews by a specific customer
  static Future<List<Map<String, dynamic>>> getCustomerShopReviews(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/customer/$customerId/shops'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['reviews'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('Error getting customer shop reviews: $e');
      return [];
    }
  }

  // ====================================
  // LEGACY METHODS (for backward compatibility)
  // ====================================

  // Legacy method - redirects to getCustomerProductReviews
  static Future<List<Map<String, dynamic>>> getReviewsByUser(String customerEmail) async {
    // Note: This method now uses customer email but the API expects customer ID
    // You may need to map email to ID or update the API to accept email
    return getCustomerProductReviews(customerEmail);
  }

  // Legacy method - redirects to getCustomerShopReviews
  static Future<List<Map<String, dynamic>>> getShopReviewsByUser(String customerEmail) async {
    // Note: This method now uses customer email but the API expects customer ID
    // You may need to map email to ID or update the API to accept email
    return getCustomerShopReviews(customerEmail);
  }

  // Legacy method - redirects to getProductReviews
  static Future<List<Map<String, dynamic>>> getReviewsByProduct(String productName) async {
    // Note: This method now uses product name but the API expects subcat_id
    // You may need to map product name to subcat_id or update the API to accept product name
    print('Warning: Legacy method getReviewsByProduct used with product name: $productName');
    return [];
  }

  // ====================================
  // UTILITY METHODS
  // ====================================

  // Get all reviews (for debugging)
  static Future<Map<String, dynamic>> getAllReviews() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/all'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return {
            'productReviews': data['productReviews'] ?? [],
            'shopReviews': data['shopReviews'] ?? [],
            'productCount': data['productCount'] ?? 0,
            'shopCount': data['shopCount'] ?? 0,
          };
        }
      }
      return {
        'productReviews': [],
        'shopReviews': [],
        'productCount': 0,
        'shopCount': 0,
      };
    } catch (e) {
      print('Error getting all reviews: $e');
      return {
        'productReviews': [],
        'shopReviews': [],
        'productCount': 0,
        'shopCount': 0,
      };
    }
  }

  // Clear all reviews (for testing)
  static Future<Map<String, dynamic>> clearAllReviews() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reviews/all'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error clearing all reviews: $e');
      return {
        'success': false,
        'error': 'Network error: Unable to clear reviews',
      };
    }
  }
}
