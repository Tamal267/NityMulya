import 'package:flutter/material.dart';
import '../../services/review_service.dart';

class ReviewsScreen extends StatefulWidget {
  final String customerEmail;
  final String customerName;

  const ReviewsScreen({
    super.key,
    required this.customerEmail,
    required this.customerName,
  });

  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> customerProductReviews = [];
  List<Map<String, dynamic>> customerShopReviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCustomerReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomerReviews() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load customer's product reviews
      final productReviews = await ReviewService.getReviewsByUser(widget.customerEmail);
      
      // Load customer's shop reviews
      final shopReviews = await ReviewService.getShopReviewsByUser(widget.customerEmail);

      setState(() {
        customerProductReviews = productReviews;
        customerShopReviews = shopReviews;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading customer reviews: $e');
      setState(() {
        isLoading = false;
      });
    }
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
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.shopping_bag),
              text: 'Product Reviews',
            ),
            Tab(
              icon: Icon(Icons.store),
              text: 'Shop Reviews',
            ),
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

  // Build customer's product reviews tab
  Widget _buildCustomerProductReviewsTab() {
    return customerProductReviews.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'You haven\'t reviewed any products yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Visit product details to write your first review!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: customerProductReviews.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final review = customerProductReviews[index];
              return _buildCustomerProductReviewCard(review);
            },
          );
  }

  // Build customer's shop reviews tab
  Widget _buildCustomerShopReviewsTab() {
    return customerShopReviews.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'You haven\'t reviewed any shops yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Shop with us and share your experience!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: customerShopReviews.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final review = customerShopReviews[index];
              return _buildCustomerShopReviewCard(review);
            },
          );
  }

  Widget _buildCustomerProductReviewCard(Map<String, dynamic> review) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product info
            Row(
              children: [
                const Icon(Icons.shopping_bag, color: Colors.indigo, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    review['productName'] ?? 'Product',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  review['createdAt'] != null
                      ? _formatDate(review['createdAt'])
                      : 'Today',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (review['shopName'] != null) ...[
              const SizedBox(height: 4),
              Text(
                'from ${review['shopName']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 8),
            // Rating
            Row(
              children: [
                _buildStarRating(review['rating']?.toDouble() ?? 0.0, 16),
                const SizedBox(width: 8),
                Text(
                  '${review['rating'] ?? 0}/5',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (review['comment'] != null && review['comment'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                review['comment'],
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerShopReviewCard(Map<String, dynamic> review) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop info
            Row(
              children: [
                const Icon(Icons.store, color: Colors.indigo, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    review['shopName'] ?? 'Shop',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  review['createdAt'] != null
                      ? _formatDate(review['createdAt'])
                      : 'Today',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Overall Rating
            Row(
              children: [
                const Text(
                  'Overall: ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                _buildStarRating(review['overallRating']?.toDouble() ?? 0.0, 16),
                const SizedBox(width: 8),
                Text(
                  '${review['overallRating'] ?? 0}/5',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            // Service Rating
            if (review['serviceRating'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'Service: ',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  _buildStarRating(review['serviceRating']?.toDouble() ?? 0.0, 16),
                  const SizedBox(width: 8),
                  Text(
                    '${review['serviceRating'] ?? 0}/5',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
            // Delivery Rating
            if (review['deliveryRating'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'Delivery: ',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  _buildStarRating(review['deliveryRating']?.toDouble() ?? 0.0, 16),
                  const SizedBox(width: 8),
                  Text(
                    '${review['deliveryRating'] ?? 0}/5',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
            if (review['comment'] != null && review['comment'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                review['comment'],
                style: const TextStyle(fontSize: 14),
              ),
            ],
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;
      
      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return '$difference days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}
