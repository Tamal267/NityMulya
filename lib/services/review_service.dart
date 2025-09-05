import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ReviewService {
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
        Uri.parse('${ApiConfig.baseUrl}/api/reviews/product'),
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
      String url = '${ApiConfig.baseUrl}/reviews/product/$subcatId';
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
      String url = '${ApiConfig.baseUrl}/reviews/product/$subcatId/average';
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
        Uri.parse('${ApiConfig.baseUrl}/reviews/product/$reviewId'),
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
  static Future<Map<String, dynamic>> deleteProductReview(
      String reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/reviews/product/$reviewId'),
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
    String? shopId, // Added optional shopId parameter
    required int overallRating,
    int? serviceRating,
    int? deliveryRating,
    String? comment,
    String? orderId,
    bool isVerifiedPurchase = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/reviews/shop'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'customer_id': customerId,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'shop_owner_id': shopOwnerId,
          'shop_name': shopName,
          'shop_id': shopId, // Added shop_id to the request body
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
  static Future<List<Map<String, dynamic>>> getShopReviews(
      String shopOwnerId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reviews/shop/$shopOwnerId'),
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
  static Future<Map<String, dynamic>> getShopAverageRatings(
      String shopOwnerId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reviews/shop/$shopOwnerId/average'),
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
        Uri.parse('${ApiConfig.baseUrl}/reviews/shop/$reviewId'),
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
        Uri.parse('${ApiConfig.baseUrl}/reviews/shop/$reviewId'),
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
  static Future<List<Map<String, dynamic>>> getCustomerProductReviews(
      String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reviews/customer/$customerId/products'),
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
  static Future<List<Map<String, dynamic>>> getCustomerShopReviews(
      String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reviews/customer/$customerId/shops'),
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
  static Future<List<Map<String, dynamic>>> getReviewsByUser(
      String customerEmail) async {
    // Note: This method now uses customer email but the API expects customer ID
    // For now, return empty list - you may need to implement email-to-ID mapping
    print(
        'Warning: Legacy method getReviewsByUser used with email: $customerEmail');
    return [];
  }

  // Legacy method - redirects to getCustomerShopReviews
  static Future<List<Map<String, dynamic>>> getShopReviewsByUser(
      String customerEmail) async {
    // Note: This method now uses customer email but the API expects customer ID
    // For now, return empty list - you may need to implement email-to-ID mapping
    print(
        'Warning: Legacy method getShopReviewsByUser used with email: $customerEmail');
    return [];
  }

  // Legacy method - get product reviews by product name (backward compatibility)
  static Future<List<Map<String, dynamic>>> getProductReviewsByName(
      String productName) async {
    try {
      // For backward compatibility, we'll search through all reviews
      final allReviews = await getAllReviews();
      final productReviews =
          allReviews['productReviews'] as List<dynamic>? ?? [];

      return productReviews
          .cast<Map<String, dynamic>>()
          .where((review) => review['product_name'] == productName)
          .toList();
    } catch (e) {
      print('Error getting product reviews by name: $e');
      return [];
    }
  }

  // Legacy method - get average rating by product name (backward compatibility)
  static Future<Map<String, dynamic>> getProductAverageRatingByName(
      String productName) async {
    try {
      final reviews = await getProductReviewsByName(productName);
      if (reviews.isEmpty) {
        return {'average': 0.0, 'count': 0};
      }

      final total = reviews.fold<double>(
          0, (sum, review) => sum + (review['rating'] ?? 0).toDouble());
      final average = total / reviews.length;

      return {
        'average': double.parse(average.toStringAsFixed(1)),
        'count': reviews.length,
      };
    } catch (e) {
      print('Error getting product average rating by name: $e');
      return {'average': 0.0, 'count': 0};
    }
  }

  // Legacy method - redirects to getProductReviews
  static Future<List<Map<String, dynamic>>> getReviewsByProduct(
      String productName) async {
    // Note: This method now uses product name but the API expects subcat_id
    // You may need to map product name to subcat_id or update the API to accept product name
    print(
        'Warning: Legacy method getReviewsByProduct used with product name: $productName');
    return [];
  }

  // Legacy method - saves a product review (backward compatibility)
  static Future<Map<String, dynamic>> saveProductReview(
      Map<String, dynamic> reviewData) async {
    try {
      // Map old review data format to new format
      return await createProductReview(
        customerId: reviewData['customerId'] ?? 'anonymous',
        customerName: reviewData['customerName'] ?? 'Anonymous User',
        customerEmail: reviewData['customerEmail'] ?? 'anonymous@example.com',
        subcatId: reviewData['subcatId'] ?? 'unknown_product',
        productName: reviewData['productName'] ?? 'Unknown Product',
        shopOwnerId: reviewData['shopId'] ?? 'unknown_shop',
        shopName: reviewData['shopName'] ?? 'Unknown Shop',
        rating: reviewData['rating'] ?? 1,
        comment: reviewData['comment'] ?? '',
        orderId: reviewData['orderId'],
        isVerifiedPurchase: reviewData['isVerifiedPurchase'] ?? false,
      );
    } catch (e) {
      print('Error in saveProductReview: $e');
      return {
        'success': false,
        'error': 'Failed to save product review: $e',
      };
    }
  }

  // ====================================
  // UTILITY METHODS
  // ====================================

  // Get all reviews (for debugging)
  static Future<Map<String, dynamic>> getAllReviews() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/reviews/all'),
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
        Uri.parse('${ApiConfig.baseUrl}/reviews/all'),
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

  // Sample product reviews for demonstration
  static List<Map<String, dynamic>> getSampleProductReviews(
      String productName) {
    return [
      {
        'id': 'sample1',
        'customer_name': 'John Doe',
        'rating': 5,
        'comment': 'Excellent product! Very satisfied with the quality.',
        'created_at':
            DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
        'is_verified_purchase': true,
      },
      {
        'id': 'sample2',
        'customer_name': 'Sarah Khan',
        'rating': 4,
        'comment': 'Good product, fast delivery. Recommended!',
        'created_at':
            DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
        'is_verified_purchase': true,
      },
      {
        'id': 'sample3',
        'customer_name': 'Ahmed Ali',
        'rating': 4,
        'comment': 'Quality is good for the price. Will buy again.',
        'created_at':
            DateTime.now().subtract(Duration(days: 8)).toIso8601String(),
        'is_verified_purchase': false,
      },
    ];
  }

  // Sample shop reviews for demonstration
  static List<Map<String, dynamic>> getSampleShopReviews(String shopId) {
    return [
      {
        'id': 'shop_sample1',
        'customer_name': 'Fatima Rahman',
        'overall_rating': 5,
        'service_rating': 5,
        'delivery_rating': 4,
        'comment':
            'Excellent shop with great customer service and fast delivery!',
        'created_at':
            DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 'shop_sample2',
        'customer_name': 'Mohammad Hassan',
        'overall_rating': 4,
        'service_rating': 4,
        'delivery_rating': 5,
        'comment':
            'Good quality products and very quick delivery. Highly recommended!',
        'created_at':
            DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
      },
      {
        'id': 'shop_sample3',
        'customer_name': 'Ayesha Begum',
        'overall_rating': 5,
        'service_rating': 5,
        'delivery_rating': 4,
        'comment':
            'Amazing shop owner! Very helpful and products are as described.',
        'created_at':
            DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
      },
    ];
  }

  // Get customer's own reviews (both product and shop reviews)
  static Future<List<Map<String, dynamic>>> getCustomerReviews(
      String customerId) async {
    try {
      // Get both product and shop reviews for the customer
      final productReviewsResponse = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/api/reviews/customer/$customerId/products'),
        headers: {'Content-Type': 'application/json'},
      );

      final shopReviewsResponse = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/api/reviews/customer/$customerId/shops'),
        headers: {'Content-Type': 'application/json'},
      );

      List<Map<String, dynamic>> allReviews = [];

      // Add product reviews
      if (productReviewsResponse.statusCode == 200) {
        final productData = jsonDecode(productReviewsResponse.body);
        if (productData['success'] && productData['reviews'] != null) {
          final productReviews =
              List<Map<String, dynamic>>.from(productData['reviews']);
          // Mark as product reviews
          for (var review in productReviews) {
            review['review_type'] = 'product';
          }
          allReviews.addAll(productReviews);
        }
      }

      // Add shop reviews
      if (shopReviewsResponse.statusCode == 200) {
        final shopData = jsonDecode(shopReviewsResponse.body);
        if (shopData['success'] && shopData['reviews'] != null) {
          final shopReviews =
              List<Map<String, dynamic>>.from(shopData['reviews']);
          // Mark as shop reviews
          for (var review in shopReviews) {
            review['review_type'] = 'shop';
          }
          allReviews.addAll(shopReviews);
        }
      }

      // Sort by date (most recent first)
      allReviews.sort((a, b) {
        final aDate = DateTime.parse(a['created_at']);
        final bDate = DateTime.parse(b['created_at']);
        return bDate.compareTo(aDate);
      });

      return allReviews;
    } catch (e) {
      print('Error fetching customer reviews: $e');
      return [];
    }
  }
}
