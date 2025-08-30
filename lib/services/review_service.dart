import 'api_service.dart';

class ReviewService {
  static const String baseUrl = 'http://localhost:3001';

  // Singleton pattern
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  // Create a new product review
  static Map<String, dynamic> createProductReview({
    required String productName,
    required String shopName,
    required String shopId,
    required String customerId,
    required String customerName,
    required int rating,
    required String comment,
    String? orderId,
  }) {
    final reviewId = 'REV-${DateTime.now().millisecondsSinceEpoch}';

    return {
      'id': reviewId,
      'productName': productName,
      'shopName': shopName,
      'shopId': shopId,
      'customerId': customerId,
      'customerName': customerName,
      'rating': rating,
      'comment': comment,
      'orderId': orderId,
      'reviewDate': DateTime.now().toIso8601String(),
      'helpful': 0,
      'isVerifiedPurchase': orderId != null,
    };
  }

  // Create a new shop review
  static Map<String, dynamic> createShopReview({
    required String shopName,
    required String shopId,
    required String customerId,
    required String customerName,
    required int rating,
    required String comment,
    required int deliveryRating,
    required int serviceRating,
    String? orderId,
  }) {
    final reviewId = 'SHOP-REV-${DateTime.now().millisecondsSinceEpoch}';

    return {
      'id': reviewId,
      'shopName': shopName,
      'shopId': shopId,
      'customerId': customerId,
      'customerName': customerName,
      'rating': rating,
      'deliveryRating': deliveryRating,
      'serviceRating': serviceRating,
      'comment': comment,
      'orderId': orderId,
      'reviewDate': DateTime.now().toIso8601String(),
      'helpful': 0,
      'isVerifiedPurchase': orderId != null,
    };
  }

  // Save product review to database
  Future<void> saveProductReview(Map<String, dynamic> review) async {
    try {
      await ApiService.post('/reviews/create', review);
    } catch (e) {
      throw Exception('Failed to save product review: $e');
    }
  }

  // Save shop review to database
  Future<void> saveShopReview(Map<String, dynamic> review) async {
    try {
      await ApiService.post('/reviews/create', review);
    } catch (e) {
      throw Exception('Failed to save shop review: $e');
    }
  }

  // Get product reviews from database
  Future<List<Map<String, dynamic>>> getProductReviews(String productName) async {
    try {
      print('Fetching reviews for product: $productName');
      final response = await ApiService.get('/reviews/product/$productName');
      print('API response: $response');
      
      if (response['success'] == true) {
        final reviews = List<Map<String, dynamic>>.from(response['reviews'] ?? [])
            .map((review) {
          if (review['reviewDate'] is String) {
            review['reviewDate'] = DateTime.parse(review['reviewDate']);
          }
          return review;
        }).toList();
        print('Fetched ${reviews.length} reviews from database');
        return reviews; // Return database results even if empty
      } else {
        print('API call failed, returning empty list');
        return []; // Return empty list instead of sample data
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      return []; // Return empty list instead of sample data
    }
  }

  // Get shop reviews from database
  Future<List<Map<String, dynamic>>> getShopReviews(String shopId) async {
    try {
      final response = await ApiService.get('/reviews/shop/$shopId');
      if (response['success'] == true) {
        return List<Map<String, dynamic>>.from(response['reviews'] ?? [])
            .map((review) {
          if (review['reviewDate'] is String) {
            review['reviewDate'] = DateTime.parse(review['reviewDate']);
          }
          return review;
        }).toList();
      } else {
        // Fallback to sample data if API fails
        return getSampleShopReviews(shopId);
      }
    } catch (e) {
      // Fallback to sample data
      return getSampleShopReviews(shopId);
    }
  }

  // Get all reviews for a customer from database
  Future<List<Map<String, dynamic>>> getCustomerReviews(String customerId) async {
    try {
      final response = await ApiService.get('/reviews/customer/$customerId');
      if (response['success'] == true) {
        return List<Map<String, dynamic>>.from(response['reviews'] ?? [])
            .map((review) {
          if (review['reviewDate'] is String) {
            review['reviewDate'] = DateTime.parse(review['reviewDate']);
          }
          return review;
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Calculate average rating for a product from database
  Future<double> getProductAverageRating(String productName) async {
    try {
      print('Fetching average rating for product: $productName');
      final response = await ApiService.get('/reviews/product/$productName/average');
      print('Average rating API response: $response');
      
      if (response['success'] == true) {
        final avgRating = (response['averageRating'] ?? 0.0).toDouble();
        print('Database average rating: $avgRating');
        return avgRating; // Return database result even if 0
      } else {
        print('Average rating API failed, returning 0');
        return 0.0; // Return 0 instead of sample data
      }
    } catch (e) {
      print('Error fetching average rating: $e');
      return 0.0; // Return 0 instead of sample data
    }
  }

  // Calculate average rating for a shop from database
  Future<Map<String, double>> getShopAverageRatings(String shopId) async {
    try {
      final response = await ApiService.get('/reviews/shop/$shopId/average');
      if (response['success'] == true && response['ratings'] != null) {
        final ratings = response['ratings'];
        return {
          'overall': (ratings['overall'] ?? 0.0).toDouble(),
          'delivery': (ratings['delivery'] ?? 0.0).toDouble(),
          'service': (ratings['service'] ?? 0.0).toDouble(),
        };
      } else {
        // Fallback to sample data
        return {'overall': 4.5, 'delivery': 4.3, 'service': 4.7};
      }
    } catch (e) {
      // Fallback to sample data
      return {'overall': 4.5, 'delivery': 4.3, 'service': 4.7};
    }
  }

  // Mark review as helpful in database
  Future<void> markReviewHelpful(String reviewId, String productName) async {
    try {
      await ApiService.put('/reviews/helpful/$reviewId');
    } catch (e) {
      throw Exception('Failed to mark review as helpful: $e');
    }
  }

  // Get sample reviews for demonstration
  List<Map<String, dynamic>> getSampleProductReviews(String productName) {
    return [
      {
        'id': 'REV-001',
        'productName': productName,
        'shopName': 'রহমান গ্রোসারি',
        'shopId': 'shop_001',
        'customerId': 'customer_001',
        'customerName': 'আহমেদ হাসান',
        'rating': 5,
        'comment': 'অসাধারণ মানের চাল। দাম অনুযায়ী খুবই ভালো। আবার কিনব।',
        'reviewDate': DateTime.now().subtract(const Duration(days: 5)),
        'helpful': 12,
        'isVerifiedPurchase': true,
        'orderId': 'ORD-001',
      },
      {
        'id': 'REV-002',
        'productName': productName,
        'shopName': 'করিম স্টোর',
        'shopId': 'shop_002',
        'customerId': 'customer_002',
        'customerName': 'ফাতেমা খাতুন',
        'rating': 4,
        'comment':
            'ভালো কোয়ালিটির পণ্য। ডেলিভারি একটু দেরি হয়েছিল তবে সার্ভিস ভালো।',
        'reviewDate': DateTime.now().subtract(const Duration(days: 10)),
        'helpful': 8,
        'isVerifiedPurchase': true,
        'orderId': 'ORD-002',
      },
      {
        'id': 'REV-003',
        'productName': productName,
        'shopName': 'নিউ মার্কেট শপ',
        'shopId': 'shop_003',
        'customerId': 'customer_003',
        'customerName': 'মোহাম্মদ করিম',
        'rating': 3,
        'comment': 'মোটামুটি ভালো। দাম একটু বেশি মনে হয়েছে।',
        'reviewDate': DateTime.now().subtract(const Duration(days: 15)),
        'helpful': 3,
        'isVerifiedPurchase': false,
      },
    ];
  }

  List<Map<String, dynamic>> getSampleShopReviews(String shopId) {
    return [
      {
        'id': 'SHOP-REV-001',
        'shopName': 'রহমান গ্রোসারি',
        'shopId': shopId,
        'customerId': 'customer_001',
        'customerName': 'সাকিব আহমেদ',
        'rating': 5,
        'deliveryRating': 4,
        'serviceRating': 5,
        'comment':
            'চমৎকার সার্ভিস! দোকানদার খুবই ভদ্র এবং সহায়ক। পণ্যের মান অসাধারণ।',
        'reviewDate': DateTime.now().subtract(const Duration(days: 3)),
        'helpful': 15,
        'isVerifiedPurchase': true,
        'orderId': 'ORD-001',
      },
      {
        'id': 'SHOP-REV-002',
        'shopName': 'রহমান গ্রোসারি',
        'shopId': shopId,
        'customerId': 'customer_002',
        'customerName': 'রাশিদা বেগম',
        'rating': 4,
        'deliveryRating': 5,
        'serviceRating': 4,
        'comment': 'দ্রুত ডেলিভারি এবং ভালো সার্ভিস। দাম একটু কমানো যেতে পারে।',
        'reviewDate': DateTime.now().subtract(const Duration(days: 8)),
        'helpful': 9,
        'isVerifiedPurchase': true,
        'orderId': 'ORD-002',
      },
    ];
  }

  // Clear all reviews (for testing) - removed since using database
  Future<void> clearAllReviews() async {
    // This method is no longer needed as we're using a database
    // Reviews can be managed through database administration tools
    print('Clear reviews functionality moved to database administration');
  }
}
