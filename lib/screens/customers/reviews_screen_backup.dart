import 'package:flutter/material.dart';

import '../../services/review_service.dart';

class ReviewsScreen extends StatefulWidget {
  final String? productName;
  final String? shopId;
  final String? shopName;
  final String? customerId; // Add customer ID to show customer's own reviews
  final String? customerName; // Add customer name

  const ReviewsScreen({
    super.key,
    this.productName,
    this.shopId,
    this.shopName,
    this.customerId, // For showing customer's own reviews
    this.customerName, // For showing customer's own reviews
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> productReviews = [];
  List<Map<String, dynamic>> shopReviews = [];
  List<Map<String, dynamic>> customerReviews = []; // Add customer reviews list
  bool isLoading = true;
  double averageRating = 0.0;
  Map<String, double> shopRatings = {};

  @override
  void initState() {
    super.initState();
    // Adjust tab count based on whether we're showing customer's own reviews
    int tabCount = 2;
    if (widget.customerId != null) {
      tabCount = 3; // Add "My Reviews" tab
    }
    
    _tabController = TabController(length: tabCount, vsync: this);
    _loadReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() => isLoading = true);

    try {
      if (widget.productName != null) {
        final reviews =
            await ReviewService().getProductReviews(widget.productName!);
        final avgRating =
            await ReviewService().getProductAverageRating(widget.productName!);

        setState(() {
          productReviews = reviews.isEmpty
              ? ReviewService().getSampleProductReviews(widget.productName!)
              : reviews;
          averageRating = avgRating > 0
              ? avgRating
              : 4.2; // Use sample average if no real reviews
        });
      }

      if (widget.shopId != null) {
        final reviews = await ReviewService().getShopReviews(widget.shopId!);
        final ratings =
            await ReviewService().getShopAverageRatings(widget.shopId!);

        setState(() {
          shopReviews = reviews.isEmpty
              ? ReviewService().getSampleShopReviews(widget.shopId!)
              : reviews;
          shopRatings = ratings['overall']! > 0
              ? ratings
              : {'overall': 4.5, 'delivery': 4.3, 'service': 4.7};
        });
      }

      // Load customer's own reviews if customer ID is provided
      if (widget.customerId != null) {
        final reviews = await ReviewService().getCustomerReviews(widget.customerId!);
        setState(() {
          customerReviews = reviews;
        });
      }
    } catch (e) {
      // Fallback to sample data
      if (widget.productName != null) {
        setState(() {
          productReviews =
              ReviewService().getSampleProductReviews(widget.productName!);
          averageRating = 4.2;
        });
      }
      if (widget.shopId != null) {
        setState(() {
          shopReviews = ReviewService().getSampleShopReviews(widget.shopId!);
          shopRatings = {'overall': 4.5, 'delivery': 4.3, 'service': 4.7};
        });
      }
      if (widget.customerId != null) {
        setState(() {
          customerReviews = []; // Empty list on error
        });
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Determine title based on what we're showing
    String title = 'Reviews';
    if (widget.customerId != null) {
      title = 'My Reviews';
    } else if (widget.productName != null) {
      title = 'Product Reviews';
    } else if (widget.shopName != null) {
      title = 'Shop Reviews';
    }

    // Build tabs based on context
    List<Tab> tabs = [];
    List<Widget> tabViews = [];

    if (widget.customerId != null) {
      // Customer's own reviews - show different tabs
      tabs = [
        const Tab(text: 'My Product Reviews'),
        const Tab(text: 'My Shop Reviews'),
      ];
      tabViews = [
        _buildCustomerProductReviewsTab(),
        _buildCustomerShopReviewsTab(),
      ];
    } else {
      // Regular product/shop reviews
      tabs = [
        const Tab(text: 'Product Reviews'),
        const Tab(text: 'Shop Reviews'),
      ];
      tabViews = [
        _buildProductReviewsTab(),
        _buildShopReviewsTab(),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: tabs,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: tabViews,
            ),
      floatingActionButton: widget.customerId == null 
          ? FloatingActionButton.extended(
              onPressed: () => _showAddReviewDialog(),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Review'),
            )
          : null, // Don't show add button for customer's own reviews
    );
  }

  Widget _buildProductReviewsTab() {
    return Column(
      children: [
        // Rating Summary
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  _buildStarRating(averageRating, 20),
                  Text(
                    '${productReviews.length} reviews',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, _getRatingCount(5)),
                    _buildRatingBar(4, _getRatingCount(4)),
                    _buildRatingBar(3, _getRatingCount(3)),
                    _buildRatingBar(2, _getRatingCount(2)),
                    _buildRatingBar(1, _getRatingCount(1)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Reviews List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: productReviews.length,
            itemBuilder: (context, index) {
              final review = productReviews[index];
              return _buildProductReviewCard(review);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShopReviewsTab() {
    return Column(
      children: [
        // Shop Rating Summary
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShopRatingItem(
                      'Overall', shopRatings['overall'] ?? 0.0, Colors.indigo),
                  _buildShopRatingItem('Delivery',
                      shopRatings['delivery'] ?? 0.0, Colors.orange),
                  _buildShopRatingItem(
                      'Service', shopRatings['service'] ?? 0.0, Colors.green),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${shopReviews.length} shop reviews',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // Shop Reviews List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shopReviews.length,
            itemBuilder: (context, index) {
              final review = shopReviews[index];
              return _buildShopReviewCard(review);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShopRatingItem(String label, double rating, Color color) {
    return Column(
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        _buildStarRating(rating, 16),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProductReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Text(
                    review['customerName'].toString().substring(0, 1),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review['customerName'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (review['isVerifiedPurchase'] == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          _buildStarRating(review['rating'].toDouble(), 14),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(review['reviewDate']),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(review['comment']),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Shop: ${review['shopName']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () =>
                      _markHelpful(review['id'], widget.productName!),
                  icon: const Icon(Icons.thumb_up, size: 16),
                  label: Text('Helpful (${review['helpful']})'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Text(
                    review['customerName'].toString().substring(0, 1),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review['customerName'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (review['isVerifiedPurchase'] == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _formatDate(review['reviewDate']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildRatingChip('Overall', review['rating'], Colors.indigo),
                const SizedBox(width: 8),
                _buildRatingChip(
                    'Delivery', review['deliveryRating'], Colors.orange),
                const SizedBox(width: 8),
                _buildRatingChip(
                    'Service', review['serviceRating'], Colors.green),
              ],
            ),
            const SizedBox(height: 12),
            Text(review['comment']),
            const SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.thumb_up, size: 16),
                  label: Text('Helpful (${review['helpful']})'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingChip(String label, int rating, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.star, size: 12, color: color),
          Text(
            rating.toString(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : index < rating
                  ? Icons.star_half
                  : Icons.star_border,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }

  Widget _buildRatingBar(int stars, int count) {
    final percentage =
        productReviews.isEmpty ? 0.0 : count / productReviews.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$stars', style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          const Icon(Icons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(width: 8),
          Text(count.toString(), style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  int _getRatingCount(int stars) {
    return productReviews.where((review) => review['rating'] == stars).length;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _markHelpful(String reviewId, String productName) async {
    try {
      await ReviewService().markReviewHelpful(reviewId, productName);
      _loadReviews(); // Reload to show updated helpful count

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        productName: widget.productName,
        shopId: widget.shopId,
        shopName: widget.shopName,
        onReviewAdded: () {
          _loadReviews();
        },
      ),
    );
  }
}

class AddReviewDialog extends StatefulWidget {
  final String? productName;
  final String? shopId;
  final String? shopName;
  final VoidCallback onReviewAdded;

  const AddReviewDialog({
    super.key,
    this.productName,
    this.shopId,
    this.shopName,
    required this.onReviewAdded,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final _commentController = TextEditingController();
  int _rating = 5;
  int _deliveryRating = 5;
  int _serviceRating = 5;
  bool _isProductReview = true;

  @override
  void initState() {
    super.initState();
    _isProductReview = widget.productName != null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isProductReview ? 'Add Product Review' : 'Add Shop Review'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isProductReview) ...[
              const Text('Rate this product:'),
              _buildRatingSelector(
                  _rating, (rating) => setState(() => _rating = rating)),
            ] else ...[
              const Text('Overall Rating:'),
              _buildRatingSelector(
                  _rating, (rating) => setState(() => _rating = rating)),
              const SizedBox(height: 16),
              const Text('Delivery Rating:'),
              _buildRatingSelector(_deliveryRating,
                  (rating) => setState(() => _deliveryRating = rating)),
              const SizedBox(height: 16),
              const Text('Service Rating:'),
              _buildRatingSelector(_serviceRating,
                  (rating) => setState(() => _serviceRating = rating)),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Write your review',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Widget _buildRatingSelector(
      int currentRating, Function(int) onRatingChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => onRatingChanged(index + 1),
          child: Icon(
            index < currentRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
        );
      }),
    );
  }

  void _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a review comment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (_isProductReview && widget.productName != null) {
        final review = ReviewService.createProductReview(
          productName: widget.productName!,
          shopName: widget.shopName ?? 'Unknown Shop',
          shopId: widget.shopId ?? 'unknown',
          customerId: 'customer_current', // In real app, get from auth
          customerName: 'Current User', // In real app, get from auth
          rating: _rating,
          comment: _commentController.text.trim(),
        );
        await ReviewService().saveProductReview(review);
      } else if (widget.shopId != null) {
        final review = ReviewService.createShopReview(
          shopName: widget.shopName ?? 'Unknown Shop',
          shopId: widget.shopId!,
          customerId: 'customer_current', // In real app, get from auth
          customerName: 'Current User', // In real app, get from auth
          rating: _rating,
          deliveryRating: _deliveryRating,
          serviceRating: _serviceRating,
          comment: _commentController.text.trim(),
        );
        await ReviewService().saveShopReview(review);
      }

      Navigator.pop(context);
      widget.onReviewAdded();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting review: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Build customer's own product reviews tab
  Widget _buildCustomerProductReviewsTab() {
    final productReviews = customerReviews
        .where((review) => review.containsKey('productName'))
        .toList();

    if (productReviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No product reviews yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start reviewing products you\'ve purchased!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: productReviews.length,
      itemBuilder: (context, index) {
        final review = productReviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review['productName'] ?? 'Unknown Product',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStarRating(review['rating'].toDouble(), 16),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Shop: ${review['shopName'] ?? 'Unknown Shop'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  review['comment'] ?? 'No comment',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      _formatReviewDate(review['reviewDate']),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    if (review['isVerifiedPurchase'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Verified Purchase',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build customer's own shop reviews tab
  Widget _buildCustomerShopReviewsTab() {
    final shopReviews = customerReviews
        .where((review) => review.containsKey('deliveryRating'))
        .toList();

    if (shopReviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No shop reviews yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Share your shopping experience!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: shopReviews.length,
      itemBuilder: (context, index) {
        final review = shopReviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review['shopName'] ?? 'Unknown Shop',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStarRating(review['rating'].toDouble(), 16),
                  ],
                ),
                const SizedBox(height: 12),
                // Rating breakdown
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Delivery',
                            style: TextStyle(fontSize: 12),
                          ),
                          _buildStarRating(review['deliveryRating'].toDouble(), 12),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Service',
                            style: TextStyle(fontSize: 12),
                          ),
                          _buildStarRating(review['serviceRating'].toDouble(), 12),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review['comment'] ?? 'No comment',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      _formatReviewDate(review['reviewDate']),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    if (review['isVerifiedPurchase'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Verified Purchase',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build customer's product reviews tab
  Widget _buildCustomerProductReviewsTab() {
    final productReviews = customerReviews
        .where((review) => review.containsKey('productName'))
        .toList();

    if (productReviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No product reviews yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start reviewing products you\'ve purchased',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: productReviews.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final review = productReviews[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review['productName'] ?? 'Product',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStarRating(review['rating'].toDouble(), 16),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review['comment'] ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Shop: ${review['shopName'] ?? 'Unknown'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatReviewDate(review['reviewDate']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build customer's shop reviews tab
  Widget _buildCustomerShopReviewsTab() {
    final shopReviews = customerReviews
        .where((review) => review.containsKey('shopName') && !review.containsKey('productName'))
        .toList();

    if (shopReviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No shop reviews yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start reviewing shops you\'ve bought from',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: shopReviews.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final review = shopReviews[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review['shopName'] ?? 'Shop',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStarRating(review['rating'].toDouble(), 16),
                  ],
                ),
                const SizedBox(height: 8),
                if (review.containsKey('deliveryRating') && review.containsKey('serviceRating')) ...[
                  Row(
                    children: [
                      const Text('Delivery: ', style: TextStyle(fontSize: 12)),
                      _buildStarRating(review['deliveryRating'].toDouble(), 12),
                      const SizedBox(width: 16),
                      const Text('Service: ', style: TextStyle(fontSize: 12)),
                      _buildStarRating(review['serviceRating'].toDouble(), 12),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  review['comment'] ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (review['isVerifiedPurchase'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Verified',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      _formatReviewDate(review['reviewDate']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatReviewDate(dynamic reviewDate) {
    DateTime date;
    if (reviewDate is DateTime) {
      date = reviewDate;
    } else if (reviewDate is String) {
      date = DateTime.parse(reviewDate);
    } else {
      return 'Unknown date';
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }
}
