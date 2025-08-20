import 'package:flutter/material.dart';

import '../../services/review_service.dart';

class ShopReviewsScreen extends StatefulWidget {
  final String shopId;
  final String shopName;

  const ShopReviewsScreen({
    super.key,
    required this.shopId,
    required this.shopName,
  });

  @override
  State<ShopReviewsScreen> createState() => _ShopReviewsScreenState();
}

class _ShopReviewsScreenState extends State<ShopReviewsScreen> {
  List<Map<String, dynamic>> shopReviews = [];
  List<Map<String, dynamic>> productReviews = [];
  bool isLoading = true;
  Map<String, double> shopRatings = {};

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => isLoading = true);

    try {
      final sReviews = await ReviewService().getShopReviews(widget.shopId);
      final ratings =
          await ReviewService().getShopAverageRatings(widget.shopId);

      // Get all product reviews for this shop
      final allCustomerReviews =
          await ReviewService().getCustomerReviews('customer_current');
      final pReviews = allCustomerReviews
          .where((review) =>
              review['shopId'] == widget.shopId ||
              review['shopName'] == widget.shopName)
          .toList();

      setState(() {
        shopReviews = sReviews.isEmpty
            ? ReviewService().getSampleShopReviews(widget.shopId)
            : sReviews;
        productReviews = pReviews;
        shopRatings = ratings['overall']! > 0
            ? ratings
            : {'overall': 4.5, 'delivery': 4.3, 'service': 4.7};
      });
    } catch (e) {
      // Fallback to sample data
      setState(() {
        shopReviews = ReviewService().getSampleShopReviews(widget.shopId);
        productReviews = [];
        shopRatings = {'overall': 4.5, 'delivery': 4.3, 'service': 4.7};
      });
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.shopName} Reviews'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop Rating Summary
                  _buildShopRatingSummary(),
                  const SizedBox(height: 20),

                  // Quick Stats
                  _buildQuickStats(),
                  const SizedBox(height: 20),

                  // Shop Reviews
                  _buildShopReviewsSection(),
                  const SizedBox(height: 20),

                  // Product Reviews
                  if (productReviews.isNotEmpty) ...[
                    _buildProductReviewsSection(),
                    const SizedBox(height: 20),
                  ],

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildShopRatingSummary() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              widget.shopName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRatingItem(
                    'Overall', shopRatings['overall'] ?? 0.0, Colors.indigo),
                _buildRatingItem(
                    'Delivery', shopRatings['delivery'] ?? 0.0, Colors.orange),
                _buildRatingItem(
                    'Service', shopRatings['service'] ?? 0.0, Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Based on ${shopReviews.length} shop reviews',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingItem(String label, double rating, Color color) {
    return Column(
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        _buildStarRating(rating, 16),
        const SizedBox(height: 4),
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

  Widget _buildQuickStats() {
    final totalReviews = shopReviews.length + productReviews.length;
    final recentReviews = [...shopReviews, ...productReviews]
        .where((review) =>
            DateTime.now().difference(review['reviewDate']).inDays <= 7)
        .length;
    final verifiedReviews = [...shopReviews, ...productReviews]
        .where((review) => review['isVerifiedPurchase'] == true)
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Reviews',
            totalReviews.toString(),
            Icons.rate_review,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'This Week',
            recentReviews.toString(),
            Icons.schedule,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Verified',
            verifiedReviews.toString(),
            Icons.verified,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.store, color: Colors.indigo),
            const SizedBox(width: 8),
            const Text(
              'Shop Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const Spacer(),
            Text(
              '${shopReviews.length} reviews',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (shopReviews.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No shop reviews yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shopReviews.length,
            itemBuilder: (context, index) {
              final review = shopReviews[index];
              return _buildShopReviewCard(review);
            },
          ),
      ],
    );
  }

  Widget _buildProductReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.shopping_bag, color: Colors.green),
            const SizedBox(width: 8),
            const Text(
              'Product Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Spacer(),
            Text(
              '${productReviews.length} reviews',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: productReviews.length,
          itemBuilder: (context, index) {
            final review = productReviews[index];
            return _buildProductReviewCard(review);
          },
        ),
      ],
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
                      Text(
                        review['customerName'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                if (review['isVerifiedPurchase'] == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                Icon(
                  Icons.thumb_up,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Helpful (${review['helpful']})',
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
                  backgroundColor: Colors.green,
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
                      Text(
                        review['customerName'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        review['productName'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
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
                if (review['isVerifiedPurchase'] == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            ),
            const SizedBox(height: 12),
            _buildStarRating(review['rating'].toDouble(), 16),
            const SizedBox(height: 8),
            Text(review['comment']),
            const SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
                Icon(
                  Icons.thumb_up,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Helpful (${review['helpful']})',
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

  Widget _buildActionButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Review analytics feature coming soon!'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                    icon: const Icon(Icons.analytics),
                    label: const Text('Analytics'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Export reviews feature coming soon!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
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
}
