import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static const String _reviewsKey = 'product_reviews';
  static const String _shopReviewsKey = 'shop_reviews';

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

  // Save product review
  Future<void> saveProductReview(Map<String, dynamic> review) async {
    final prefs = await SharedPreferences.getInstance();
    final existingReviews = await getProductReviews(review['productName']);
    existingReviews.add(review);

    final reviewsJson =
        existingReviews.map((review) => jsonEncode(review)).toList();
    await prefs.setStringList(
        '${_reviewsKey}_${review['productName']}', reviewsJson);
  }

  // Save shop review
  Future<void> saveShopReview(Map<String, dynamic> review) async {
    final prefs = await SharedPreferences.getInstance();
    final existingReviews = await getShopReviews(review['shopId']);
    existingReviews.add(review);

    final reviewsJson =
        existingReviews.map((review) => jsonEncode(review)).toList();
    await prefs.setStringList(
        '${_shopReviewsKey}_${review['shopId']}', reviewsJson);
  }

  // Get product reviews
  Future<List<Map<String, dynamic>>> getProductReviews(
      String productName) async {
    final prefs = await SharedPreferences.getInstance();
    final reviewsJson =
        prefs.getStringList('${_reviewsKey}_$productName') ?? [];

    return reviewsJson.map((reviewStr) {
      final reviewMap = jsonDecode(reviewStr) as Map<String, dynamic>;
      reviewMap['reviewDate'] = DateTime.parse(reviewMap['reviewDate']);
      return reviewMap;
    }).toList();
  }

  // Get shop reviews
  Future<List<Map<String, dynamic>>> getShopReviews(String shopId) async {
    final prefs = await SharedPreferences.getInstance();
    final reviewsJson = prefs.getStringList('${_shopReviewsKey}_$shopId') ?? [];

    return reviewsJson.map((reviewStr) {
      final reviewMap = jsonDecode(reviewStr) as Map<String, dynamic>;
      reviewMap['reviewDate'] = DateTime.parse(reviewMap['reviewDate']);
      return reviewMap;
    }).toList();
  }

  // Get all reviews for a customer
  Future<List<Map<String, dynamic>>> getCustomerReviews(
      String customerId) async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    List<Map<String, dynamic>> customerReviews = [];

    for (String key in allKeys) {
      if (key.startsWith(_reviewsKey) || key.startsWith(_shopReviewsKey)) {
        final reviewsJson = prefs.getStringList(key) ?? [];
        for (String reviewStr in reviewsJson) {
          final review = jsonDecode(reviewStr) as Map<String, dynamic>;
          if (review['customerId'] == customerId) {
            review['reviewDate'] = DateTime.parse(review['reviewDate']);
            customerReviews.add(review);
          }
        }
      }
    }

    // Sort by date (newest first)
    customerReviews.sort((a, b) => b['reviewDate'].compareTo(a['reviewDate']));
    return customerReviews;
  }

  // Calculate average rating for a product
  Future<double> getProductAverageRating(String productName) async {
    final reviews = await getProductReviews(productName);
    if (reviews.isEmpty) return 0.0;

    final totalRating =
        reviews.fold(0, (sum, review) => sum + (review['rating'] as int));
    return totalRating / reviews.length;
  }

  // Calculate average rating for a shop
  Future<Map<String, double>> getShopAverageRatings(String shopId) async {
    final reviews = await getShopReviews(shopId);
    if (reviews.isEmpty) {
      return {
        'overall': 0.0,
        'delivery': 0.0,
        'service': 0.0,
      };
    }

    final totalOverall =
        reviews.fold(0, (sum, review) => sum + (review['rating'] as int));
    final totalDelivery = reviews.fold(
        0, (sum, review) => sum + (review['deliveryRating'] as int));
    final totalService = reviews.fold(
        0, (sum, review) => sum + (review['serviceRating'] as int));

    return {
      'overall': totalOverall / reviews.length,
      'delivery': totalDelivery / reviews.length,
      'service': totalService / reviews.length,
    };
  }

  // Mark review as helpful
  Future<void> markReviewHelpful(String reviewId, String productName) async {
    final reviews = await getProductReviews(productName);
    final reviewIndex =
        reviews.indexWhere((review) => review['id'] == reviewId);

    if (reviewIndex != -1) {
      reviews[reviewIndex]['helpful'] =
          (reviews[reviewIndex]['helpful'] as int) + 1;

      // Save back to storage
      final prefs = await SharedPreferences.getInstance();
      final reviewsForStorage = reviews.map((review) {
        final reviewCopy = Map<String, dynamic>.from(review);
        reviewCopy['reviewDate'] = reviewCopy['reviewDate'].toIso8601String();
        return reviewCopy;
      }).toList();

      final reviewsJson =
          reviewsForStorage.map((review) => jsonEncode(review)).toList();
      await prefs.setStringList('${_reviewsKey}_$productName', reviewsJson);
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

  // Clear all reviews (for testing)
  Future<void> clearAllReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    for (String key in allKeys) {
      if (key.startsWith(_reviewsKey) || key.startsWith(_shopReviewsKey)) {
        await prefs.remove(key);
      }
    }
  }
}
