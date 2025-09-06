import 'package:flutter/material.dart';

import '../../models/shop.dart';
import '../../services/review_service.dart';
import '../../utils/user_session.dart';
import 'complaint_submission_screen.dart';
import 'product_detail_screen.dart';
import 'reviews_screen.dart';

class ShopItemsScreen extends StatefulWidget {
  final Shop shop;

  const ShopItemsScreen({
    super.key,
    required this.shop,
  });

  @override
  State<ShopItemsScreen> createState() => _ShopItemsScreenState();
}

class _ShopItemsScreenState extends State<ShopItemsScreen> {
  String searchQuery = "";

  // Mock product data for the shop - in a real app, this would come from an API
  late List<Map<String, dynamic>> shopProducts;

  @override
  void initState() {
    super.initState();
    _initializeShopProducts();
  }

  void _showShopReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => _ShopReviewDialog(shop: widget.shop),
    );
  }

  void _initializeShopProducts() {
    // Create mock product data based on shop's available products
    shopProducts = widget.shop.availableProducts.map((productName) {
      return _getProductDetails(productName);
    }).toList();
  }

  Map<String, dynamic> _getProductDetails(String productName) {
    // Mock product details - in a real app, this would come from a database
    final productData = {
      "চাল সরু (নাজির/মিনিকেট)": {
        "title": "চাল সরু (নাজির/মিনিকেট)",
        "unit": "প্রতি কেজি",
        "low": 75,
        "high": 85,
        "category": "চাল",
        "image": "assets/image/1.jpg",
        "description": "উন্নত মানের সরু চাল। রান্নার পর ঝরঝরে এবং স্বাদযুক্ত।",
        "availability": "In Stock",
      },
      "চাল মোটা (পাইলস)": {
        "title": "চাল মোটা (পাইলস)",
        "unit": "প্রতি কেজি",
        "low": 55,
        "high": 65,
        "category": "চাল",
        "image": "assets/image/2.jpg",
        "description": "মোটা ধানের চাল। পুষ্টিকর এবং সাশ্রয়ী।",
        "availability": "In Stock",
      },
      "গমের আটা (প্রিমিয়াম)": {
        "title": "গমের আটা (প্রিমিয়াম)",
        "unit": "প্রতি কেজি",
        "low": 45,
        "high": 50,
        "category": "আটা ও ময়দা",
        "image": "assets/image/6.jpg",
        "description":
            "প্রিমিয়াম মানের গমের আটা। রুটি এবং পরোটার জন্য উপযুক্ত।",
        "availability": "In Stock",
      },
      "সয়াবিন তেল (পিউর)": {
        "title": "সয়াবিন তেল (পিউর)",
        "unit": "প্রতি লিটার",
        "low": 160,
        "high": 175,
        "category": "তেল",
        "image": "assets/image/10.jpg",
        "description": "বিশুদ্ধ সয়াবিন তেল। রান্নার জন্য স্বাস্থ্যকর।",
        "availability": "In Stock",
      },
      "মসুর ডাল": {
        "title": "মসুর ডাল",
        "unit": "প্রতি কেজি",
        "low": 115,
        "high": 125,
        "category": "ডাল",
        "image": "assets/image/4.jpg",
        "description": "উন্নত মানের মসুর ডাল। প্রোটিনের ভালো উৎস।",
        "availability": "In Stock",
      },
      "পেঁয়াজ (দেশি)": {
        "title": "পেঁয়াজ (দেশি)",
        "unit": "প্রতি কেজি",
        "low": 50,
        "high": 60,
        "category": "সবজি ও মসলা",
        "image": "assets/image/5.jpg",
        "description": "তাজা দেশি পেঁয়াজ। রান্নার জন্য অপরিহার্য।",
        "availability": "In Stock",
      },
      "রুই মাছ": {
        "title": "রুই মাছ",
        "unit": "প্রতি কেজি",
        "low": 350,
        "high": 400,
        "category": "মাছ ও গোশত",
        "image": "assets/image/10.jpg",
        "description": "তাজা রুই মাছ। প্রোটিনের চমৎকার উৎস।",
        "availability": "In Stock",
      },
      "গরুর দুধ": {
        "title": "গরুর দুধ",
        "unit": "প্রতি লিটার",
        "low": 60,
        "high": 70,
        "category": "দুধ",
        "image": "assets/image/11.jpg",
        "description": "বিশুদ্ধ গরুর দুধ। ক্যালসিয়াম এবং প্রোটিনে ভরপুর।",
        "availability": "In Stock",
      },
    };

    return productData[productName] ??
        {
          "title": productName,
          "unit": "প্রতি কেজি",
          "low": 50,
          "high": 60,
          "category": "অন্যান্য",
          "image": "assets/image/6.jpg",
          "description": "পণ্যের বিবরণ উপলব্ধ নেই।",
          "availability": "In Stock",
        };
  }

  List<Map<String, dynamic>> get filteredProducts {
    if (searchQuery.isEmpty) {
      return shopProducts;
    }
    return shopProducts
        .where((product) =>
            product["title"].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF079b11),
        title: Text(widget.shop.name),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              // Add shop to favorites
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.shop.name} added to favorites!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            tooltip: 'Add to Favorites',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop Info Header
          Container(
            color: const Color(0xFF079b11),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          widget.shop.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.store,
                              size: 30,
                              color: Color(0xFF079b11),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.shop.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (widget.shop.isVerified)
                                const Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 20,
                                ),
                            ],
                          ),
                          Text(
                            widget.shop.address,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.shop.rating.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.access_time,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.shop.openingHours,
                                style: const TextStyle(
                                  color: Colors.white70,
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
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "এই দোকানে পণ্য খুঁজুন...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Products Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "উপলব্ধ পণ্যসমূহ (${filteredProducts.length}টি)",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Products Grid
          SizedBox(
            height: 400, // Fixed height
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty
                              ? "কোনো পণ্য উপলব্ধ নেই"
                              : "খোঁজার ফলাফল পাওয়া যায়নি",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(
                                  title: product["title"],
                                  unit: product["unit"],
                                  low: product["low"],
                                  high: product["high"],
                                  subcatId: product[
                                      "subcat_id"], // Pass subcategory ID if available
                                  userEmail: null, // TODO: Pass actual user email
                                  userName: null, // TODO: Pass actual user name
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      product["image"],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product["title"],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product["unit"],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "৳${product["low"]} - ৳${product["high"]}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF079b11),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Reviews Section
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "দোকানের রিভিউ",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showShopReviewDialog(),
                            icon: const Icon(Icons.star, size: 16),
                            label: const Text('রিভিউ দিন'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[600], size: 20),
                          const SizedBox(width: 4),
                          Text(
                            "${widget.shop.rating} (0 reviews)",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "এখনো কোন রিভিউ নেই। প্রথম রিভিউ দিন!",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Complaints Section
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.report_problem, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            "অভিযোগ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "দোকান বা পণ্য সংক্রান্ত কোনো সমস্যা থাকলে অভিযোগ করুন",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            print('🔥🔥🔥 BUTTON PRESSED DIRECTLY!');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Button clicked successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _navigateToComplaintPage();
                          },
                          icon: const Icon(Icons.report, size: 16),
                          label: const Text('অভিযোগ করুন'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
        ),
      ),
    );
  }

  // Navigate to complaint page
  void _navigateToComplaintPage() async {
    print('🔥 COMPLAINT BUTTON CLICKED!'); // Debug
    print('🔥 Shop: ${widget.shop.name}'); // Debug
    
    // Get user info from session
    final userInfo = await UserSession.getCurrentUser();
    print('🔥 User info: $userInfo'); // Debug
    
    if (userInfo == null) {
      print('User info is null'); // Debug
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('লগইন করতে হবে অভিযোগ করার জন্য'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    print('🔥 Navigating to complaint screen...'); // Debug
    if (mounted) {
      try {
        print('🔥 About to navigate...'); // Debug
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComplaintSubmissionScreen(
              shop: widget.shop,
            ),
          ),
        );
        print('🔥 Navigation successful!'); // Debug
      } catch (e) {
        print('🔥 Navigation error: $e'); // Debug
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Shop Review Dialog Widget
class _ShopReviewDialog extends StatefulWidget {
  final Shop shop;

  const _ShopReviewDialog({required this.shop});

  @override
  State<_ShopReviewDialog> createState() => _ShopReviewDialogState();
}

class _ShopReviewDialogState extends State<_ShopReviewDialog> {
  final TextEditingController _commentController = TextEditingController();
  int _overallRating = 5;
  int _deliveryRating = 5;
  int _serviceRating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a comment for your review'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      ReviewService.createShopReview(
        shopId: widget.shop.name.toLowerCase().replaceAll(' ', '_'),
        shopOwnerId: 'shop_owner_${widget.shop.name.toLowerCase().replaceAll(' ', '_')}',  // Added required shopOwnerId
        shopName: widget.shop.name,
        customerId: 'customer_current', // Replace with actual customer ID
        customerName: 'Current Customer', // Replace with actual customer name
        customerEmail: 'customer@example.com',  // Added required customerEmail
        overallRating: _overallRating,  // Changed from 'rating' to 'overallRating'
        deliveryRating: _deliveryRating,
        serviceRating: _serviceRating,
        comment: _commentController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review submitted for ${widget.shop.name}!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View Reviews',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReviewsScreen(),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildRatingSelector(
      String label, int rating, Function(int) onChanged, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => onChanged(index + 1),
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.store, color: Colors.indigo, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Review ${widget.shop.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Shop Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.indigo.withOpacity(0.2),
                      child: Text(
                        widget.shop.name[0],
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.shop.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.shop.address,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Rating Sections
              _buildRatingSelector('Overall Rating', _overallRating, (rating) {
                setState(() => _overallRating = rating);
              }, Colors.indigo),
              const SizedBox(height: 16),

              _buildRatingSelector('Delivery Experience', _deliveryRating,
                  (rating) {
                setState(() => _deliveryRating = rating);
              }, Colors.orange),
              const SizedBox(height: 16),

              _buildRatingSelector('Customer Service', _serviceRating,
                  (rating) {
                setState(() => _serviceRating = rating);
              }, Colors.green),
              const SizedBox(height: 20),

              // Comment Section
              Text(
                'Share your experience',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Tell others about your experience with ${widget.shop.name}...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.indigo),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Submit Review'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
