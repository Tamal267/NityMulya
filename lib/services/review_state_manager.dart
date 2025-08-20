import 'package:flutter/material.dart';

// State management utility for review system
class ReviewStateManager extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _reviews = [];
  Map<String, double> _averageRatings = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get reviews => _reviews;
  Map<String, double> get averageRatings => _averageRatings;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setReviews(List<Map<String, dynamic>> reviews) {
    _reviews = reviews;
    notifyListeners();
  }

  void addReview(Map<String, dynamic> review) {
    _reviews.insert(0, review); // Add to beginning (newest first)
    notifyListeners();
  }

  void setAverageRatings(Map<String, double> ratings) {
    _averageRatings = ratings;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearData() {
    _reviews.clear();
    _averageRatings.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Utility methods
  double getAverageRatingForProduct(String productName) {
    final productReviews = _reviews
        .where((review) => review['productName'] == productName)
        .toList();

    if (productReviews.isEmpty) return 0.0;

    final totalRating = productReviews.fold(
        0, (sum, review) => sum + (review['rating'] as int));

    return totalRating / productReviews.length;
  }

  int getReviewCountForProduct(String productName) {
    return _reviews
        .where((review) => review['productName'] == productName)
        .length;
  }

  List<Map<String, dynamic>> getReviewsForShop(String shopId) {
    return _reviews
        .where((review) =>
            review['shopId'] == shopId || review['shopName'] == shopId)
        .toList();
  }
}
