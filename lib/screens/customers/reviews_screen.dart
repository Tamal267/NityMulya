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
    _tabController = TabController(
        length: 2,
        vsync: this); // Always 2 tabs: Product Reviews + Shop Reviews
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
            await ReviewService.getProductReviewsByName(widget.productName!);
        final avgRatingData = await ReviewService.getProductAverageRatingByName(
            widget.productName!);

        setState(() {
          productReviews = reviews.isEmpty
              ? ReviewService.getSampleProductReviews(widget.productName!)
              : reviews;
          averageRating = avgRatingData['averageRating'] > 0
              ? avgRatingData['averageRating'].toDouble()
              : 4.2; // Use sample average if no real reviews
        });
      }

      if (widget.shopId != null) {
        final reviews = await ReviewService.getShopReviews(widget.shopId!);
        final ratings =
            await ReviewService.getShopAverageRatings(widget.shopId!);

        setState(() {
          shopReviews = reviews.isEmpty
              ? ReviewService.getSampleShopReviews(widget.shopId!)
              : reviews;
          shopRatings = ratings['overall']! > 0
              ? {
                  'overall': (ratings['overall'] as num).toDouble(),
                  'delivery': (ratings['delivery'] as num).toDouble(),
                  'service': (ratings['service'] as num).toDouble(),
                }
              : {'overall': 4.5, 'delivery': 4.3, 'service': 4.7};
        });
      }

      // Load customer's own reviews if customer ID is provided
      if (widget.customerId != null) {
        final reviews =
            await ReviewService.getCustomerReviews(widget.customerId!);
        setState(() {
          customerReviews = reviews;
        });
      }
    } catch (e) {
      // Fallback to sample data
      if (widget.productName != null) {
        setState(() {
          productReviews =
              ReviewService.getSampleProductReviews(widget.productName!);
          averageRating = 4.2;
        });
      }
      if (widget.shopId != null) {
        setState(() {
          shopReviews = ReviewService.getSampleShopReviews(widget.shopId!);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reviews'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Product Reviews', icon: Icon(Icons.star)),
            Tab(text: 'Shop Reviews', icon: Icon(Icons.store)),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCustomerProductReviewsTab(),
                _buildCustomerShopReviewsTab(),
              ],
            ),
    );
  }

  // Build "Add Review" tab for easy access
  Widget _buildAddReviewTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product info card
          if (widget.productName != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag,
                        color: Colors.indigo, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.productName!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.shopName != null)
                            Text(
                              'from ${widget.shopName}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Quick add review button
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showAddReviewDialog(),
              icon: const Icon(Icons.star),
              label: const Text('Write a Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Instructions
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'How to write a helpful review:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('• Rate the product quality (1-5 stars)'),
                  const Text('• Share your honest experience'),
                  const Text('• Mention specific features you liked/disliked'),
                  const Text('• Help other customers make informed decisions'),
                ],
              ),
            ),
          ),
        ],
      ),
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
          child: productReviews.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rate_review_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No reviews yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: productReviews.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final review = productReviews[index];
                    return _buildReviewCard(review);
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
                  _buildRatingColumn('Overall', shopRatings['overall'] ?? 4.5),
                  _buildRatingColumn(
                      'Delivery', shopRatings['delivery'] ?? 4.3),
                  _buildRatingColumn('Service', shopRatings['service'] ?? 4.7),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${shopReviews.length} shop reviews',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        // Shop Reviews List
        Expanded(
          child: shopReviews.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No shop reviews yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: shopReviews.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final review = shopReviews[index];
                    return _buildShopReviewCard(review);
                  },
                ),
        ),
      ],
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
        return _buildReviewCard(review);
      },
    );
  }

  // Build customer's shop reviews tab
  Widget _buildCustomerShopReviewsTab() {
    final shopReviews = customerReviews
        .where((review) =>
            review.containsKey('shopName') &&
            !review.containsKey('productName'))
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
        return _buildShopReviewCard(review);
      },
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.indigo,
                  child: Text(
                    (review['customerName'] ?? 'U')
                        .toString()
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
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
                            review['customerName'] ?? 'Unknown User',
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
                          _buildStarRating(
                              (review['rating'] ?? 0).toDouble(), 14),
                          const SizedBox(width: 8),
                          Text(
                            _formatReviewDate(review['reviewDate']),
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
            const SizedBox(height: 8),
            Text(
              review['comment'] ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (review['shopName'] != null)
                  Text(
                    'Shop: ${review['shopName']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                const Spacer(),
                Icon(
                  Icons.thumb_up,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${review['helpful'] ?? 0}',
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
    );
  }

  Widget _buildShopReviewCard(Map<String, dynamic> review) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.indigo,
                  child: Text(
                    (review['customerName'] ?? 'U')
                        .toString()
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['customerName'] ?? 'Unknown User',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          _buildStarRating(
                              (review['rating'] ?? 0).toDouble(), 14),
                          const SizedBox(width: 8),
                          Text(
                            _formatReviewDate(review['reviewDate']),
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
            const SizedBox(height: 8),
            // Show delivery and service ratings if available
            if (review.containsKey('deliveryRating') ||
                review.containsKey('serviceRating')) ...[
              Row(
                children: [
                  if (review.containsKey('deliveryRating')) ...[
                    const Text('Delivery: ', style: TextStyle(fontSize: 12)),
                    _buildStarRating(
                        (review['deliveryRating'] ?? 0).toDouble(), 12),
                    const SizedBox(width: 16),
                  ],
                  if (review.containsKey('serviceRating')) ...[
                    const Text('Service: ', style: TextStyle(fontSize: 12)),
                    _buildStarRating(
                        (review['serviceRating'] ?? 0).toDouble(), 12),
                  ],
                ],
              ),
              const SizedBox(height: 8),
            ],
            Text(
              review['comment'] ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (review['isVerifiedPurchase'] == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Verified Purchase',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                const Spacer(),
                Icon(
                  Icons.thumb_up,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${review['helpful'] ?? 0}',
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
    );
  }

  Widget _buildStarRating(double rating, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, size: size, color: Colors.amber);
        } else if (index < rating) {
          return Icon(Icons.star_half, size: size, color: Colors.amber);
        } else {
          return Icon(Icons.star_border, size: size, color: Colors.grey);
        }
      }),
    );
  }

  Widget _buildRatingColumn(String label, double rating) {
    return Column(
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        _buildStarRating(rating, 16),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRatingBar(int stars, int count) {
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
              value: productReviews.isEmpty ? 0 : count / productReviews.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  int _getRatingCount(int stars) {
    return productReviews.where((review) => review['rating'] == stars).length;
  }

  String _formatReviewDate(dynamic reviewDate) {
    DateTime date;
    if (reviewDate is DateTime) {
      date = reviewDate;
    } else if (reviewDate is String) {
      try {
        date = DateTime.parse(reviewDate);
      } catch (e) {
        return 'Unknown date';
      }
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

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        productName: widget.productName,
        shopId: widget.shopId,
        shopName: widget.shopName,
        customerId: widget.customerId,
        customerName: widget.customerName,
        onReviewAdded: () {
          _loadReviews(); // Reload reviews after adding

          // Switch back to reviews tab after adding review
          if (_tabController.length > 1) {
            _tabController.animateTo(0);
          }

          // Return success to parent screen (ProductDetailScreen)
          Navigator.of(context).pop(true);
        },
      ),
    );
  }
}

// Simplified Add Review Dialog
class AddReviewDialog extends StatefulWidget {
  final String? productName;
  final String? shopId;
  final String? shopName;
  final String? customerId;
  final String? customerName;
  final VoidCallback onReviewAdded;

  const AddReviewDialog({
    super.key,
    this.productName,
    this.shopId,
    this.shopName,
    this.customerId,
    this.customerName,
    required this.onReviewAdded,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final _commentController = TextEditingController();
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.productName != null
          ? 'Review ${widget.productName}'
          : 'Add Review'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.productName != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag, color: Colors.indigo),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.productName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (widget.shopName != null) ...[
              Text(
                'Shop: ${widget.shopName}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Rate your experience:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text(
              'Write your review:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Share your experience with this product...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
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
          onPressed: () async {
            // Validate input
            if (_commentController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please write a review comment'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // Prepare review data
            final reviewData = {
              'customerId': widget.customerId ?? 'anonymous',
              'customerName': widget.customerName ?? 'Anonymous User',
              'shopOwnerId': widget.shopId ?? 'unknown',
              'shopName': widget.shopName ?? 'Unknown Shop',
              'productName': widget.productName ?? 'Unknown Product',
              'subcatId': 'unknown', // TODO: Pass actual subcategory ID
              'rating': _rating,
              'comment': _commentController.text.trim(),
              'isVerifiedPurchase': false, // TODO: Check if user purchased
            };

            try {
              // Save the review using the API
              await ReviewService.saveProductReview(reviewData);

              // Close dialog
              Navigator.pop(context);

              // Trigger review reload
              widget.onReviewAdded();

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      const Text('Review added successfully!'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            } catch (e) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to add review: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
