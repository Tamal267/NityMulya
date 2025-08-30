import 'package:flutter/material.dart';
import 'package:nitymulya/network/pricelist_api.dart';

import '../../services/order_service.dart';
import '../../services/review_service.dart';
import 'reviews_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String title;
  final String unit;
  final int low;
  final int high;
  final String? subcatId; // Add subcategory ID
  final String? userName; // Add user information
  final String? userEmail; // Add user email
  final String? userRole; // Add user role

  const ProductDetailScreen({
    super.key,
    required this.title,
    required this.unit,
    required this.low,
    required this.high,
    this.subcatId, // Optional for backward compatibility
    this.userName, // Optional user information
    this.userEmail, // Optional user email
    this.userRole, // Optional user role
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<Map<String, dynamic>> availableShops = [];
  Map<String, dynamic>? priceHistory;
  bool isLoadingShops = true;
  bool isLoadingHistory = true;
  String? errorMessage;

  // Review-related variables
  List<Map<String, dynamic>> productReviews = [];
  double averageRating = 0.0;
  bool isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadAvailableShops(),
      _loadPriceHistory(),
      _loadProductReviews(),
    ]);
  }

  Future<void> _loadAvailableShops() async {
    try {
      setState(() {
        isLoadingShops = true;
        errorMessage = null;
      });

      print('Loading shops for: ${widget.title} (ID: ${widget.subcatId})');

      List<Map<String, dynamic>> shops;

      // Use subcategory ID if available, otherwise fall back to product name
      if (widget.subcatId != null && widget.subcatId!.isNotEmpty) {
        shops = await fetchShopsBySubcategoryId(widget.subcatId!);
      } else {
        shops = await fetchShopsByProduct(widget.title);
      }

      print('Fetched ${shops.length} shops');

      setState(() {
        availableShops = shops;
        isLoadingShops = false;
      });
    } catch (e) {
      print('Error loading shops: $e');
      setState(() {
        // Don't show error message for shops, just show empty state
        errorMessage = null;
        isLoadingShops = false;
        availableShops = [];
      });
    }
  }

  Future<void> _loadPriceHistory() async {
    try {
      setState(() {
        isLoadingHistory = true;
      });

      final history = await fetchProductPriceHistory(widget.title);

      setState(() {
        priceHistory = history;
        isLoadingHistory = false;
      });
    } catch (e) {
      print('Error loading price history: $e');
      setState(() {
        isLoadingHistory = false;
        priceHistory = null;
      });
    }
  }

  Future<void> _loadProductReviews() async {
    try {
      setState(() {
        isLoadingReviews = true;
      });

      final reviews = await ReviewService().getProductReviews(widget.title);
      final avgRating =
          await ReviewService().getProductAverageRating(widget.title);

      setState(() {
        // Only use reviews from database, don't fall back to sample data
        productReviews = reviews;
        // Only use database average rating, or 0 if no reviews
        averageRating = avgRating;
        isLoadingReviews = false;
      });

      // Debug: Print API responses
      print('Loaded ${productReviews.length} reviews for ${widget.title}');
      print('Average rating: $averageRating');
      
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() {
        // On error, show empty reviews instead of sample data
        productReviews = [];
        averageRating = 0.0;
        isLoadingReviews = false;
      });
    }
  }

  // Check if user is logged in and show login dialog if not
  bool _checkLoginAndShowDialog() {
    if (widget.userName == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Login Required"),
          content: const Text("Please login or sign up to place an order."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
              child: const Text("Login / Sign Up"),
            ),
          ],
        ),
      );
      return false; // Not logged in
    }
    return true; // Logged in
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info Card
            Card(
              elevation: 4,
              child: Padding(
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
                            color: Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            color: Colors.indigo,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Unit: ${widget.unit}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Current Price Range:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Low: ৳${widget.low}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "High: ৳${widget.high}",
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Available Shops Section
            Row(
              children: [
                const Icon(Icons.store, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  "Available Shops (${availableShops.length})",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                if (isLoadingShops)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (isLoadingShops)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (availableShops.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.store_mall_directory_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "No shops currently have this product in stock",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: availableShops.length,
                itemBuilder: (context, index) {
                  final shop = availableShops[index];
                  final price = shop['unit_price']?.toString() ?? '0';
                  final shopName = shop['name']?.toString() ?? 'Unknown Shop';
                  final shopAddress =
                      shop['address']?.toString() ?? 'Unknown Address';
                  final stockQuantity =
                      shop['stock_quantity']?.toString() ?? '0';
                  final lowStockThreshold =
                      shop['low_stock_threshold']?.toString() ?? '10';

                  // Determine stock status
                  final stock = int.tryParse(stockQuantity) ?? 0;
                  final threshold = int.tryParse(lowStockThreshold) ?? 10;
                  final stockStatus = stock > 50
                      ? 'High Stock'
                      : stock > threshold
                          ? 'Medium Stock'
                          : 'Low Stock';
                  final stockColor = stock > 50
                      ? Colors.green
                      : stock > threshold
                          ? Colors.orange
                          : Colors.red;

                  return InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(shopName),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Address: $shopAddress"),
                              Text("Stock: $stockQuantity ${widget.unit}"),
                              Text("Stock Status: $stockStatus"),
                              Text("Price: ৳$price per ${widget.unit}"),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Close"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Calling $shopName..."),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Contact"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Shop header row
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      Colors.indigo.withOpacity(0.1),
                                  child: Text(
                                    shopName.isNotEmpty ? shopName[0] : 'S',
                                    style: const TextStyle(
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        shopName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              shopAddress,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Stock status chip
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: stockColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: stockColor, width: 1),
                                  ),
                                  child: Text(
                                    stockStatus,
                                    style: TextStyle(
                                      color: stockColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Bottom row with stock, price, and buy button
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.inventory,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          "Stock: $stockQuantity",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: stockColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Price
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "৳$price",
                                    style: const TextStyle(
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Buy button
                                SizedBox(
                                  width: 60,
                                  height: 32,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (!_checkLoginAndShowDialog()) {
                                        return;
                                      }
                                      _showPurchaseDialog(context, shop,
                                          widget.title, widget.unit);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: const Text(
                                      'Buy',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),

            // Price History Section
            Row(
              children: [
                const Icon(Icons.history, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  "Price History",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                if (isLoadingHistory)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (isLoadingHistory)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (priceHistory == null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Price history not available",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Card(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      (priceHistory!['price_history'] as List?)?.length ?? 0,
                  itemBuilder: (context, index) {
                    final history = priceHistory!['price_history'] as List;
                    final dayHistory = history[index];
                    final date = dayHistory['date']?.toString() ?? '';
                    final minPrice = dayHistory['min_price']?.toString() ?? '0';
                    final maxPrice = dayHistory['max_price']?.toString() ?? '0';

                    String subtitle = '';
                    if (index == 0) {
                      subtitle = 'Today';
                    } else if (index == 1) {
                      subtitle = 'Yesterday';
                    } else {
                      subtitle = '$index days ago';
                    }

                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.calendar_today,
                              color: index == 0 ? Colors.indigo : Colors.grey),
                          title: Text(date),
                          subtitle: Text(subtitle),
                          trailing: Text(
                            "৳$minPrice - ৳$maxPrice",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: index == 0 ? Colors.indigo : Colors.black,
                            ),
                          ),
                        ),
                        if (index < (history.length - 1))
                          const Divider(height: 1),
                      ],
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // Reviews Section
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  "Reviews (${productReviews.length})",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(width: 8),
                if (!isLoadingReviews && averageRating > 0) ...[
                  _buildStarRating(averageRating, 16),
                  const SizedBox(width: 8),
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
                const Spacer(),
                if (isLoadingReviews)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (isLoadingReviews)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (productReviews.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "No reviews yet",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Be the first to review this product!",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                child: Column(
                  children: [
                    // Review Summary
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                averageRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 32,
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
                    const Divider(height: 1),
                    // Recent Reviews Preview
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          productReviews.length > 3 ? 3 : productReviews.length,
                      itemBuilder: (context, index) {
                        final review = productReviews[index];
                        return _buildReviewPreview(review);
                      },
                    ),
                    if (productReviews.length > 3)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewsScreen(
                                  productName: widget.title,
                                  shopId: availableShops.isNotEmpty ? availableShops.first['id']?.toString() : null,
                                  shopName: availableShops.isNotEmpty ? availableShops.first['name']?.toString() : null,
                                  customerId: widget.userEmail,
                                  customerName: widget.userName,
                                ),
                              ),
                            );
                            
                            if (result == true) {
                              // Reload reviews after successful submission
                              _loadProductReviews();
                            }
                          },
                          child:
                              Text('View all ${productReviews.length} reviews'),
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Added to favorites!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.favorite_border),
                    label: const Text("Add to Favorites"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: availableShops.isNotEmpty
                        ? () {
                            // Check if user is logged in first
                            if (!_checkLoginAndShowDialog()) {
                              return; // User not logged in, dialog shown
                            }

                            // Show shop selection dialog if multiple shops
                            if (availableShops.length > 1) {
                              _showShopSelectionDialog(context);
                            } else {
                              // Direct purchase from the only available shop
                              _showPurchaseDialog(context, availableShops.first,
                                  widget.title, widget.unit);
                            }
                          }
                        : null,
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text("Order Now"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: availableShops.isNotEmpty
                          ? Colors.green
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Price Alert Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Price alert set!"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                icon: const Icon(Icons.notifications),
                label: const Text("Set Price Alert"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewsScreen(
                productName: widget.title,
                shopId: availableShops.isNotEmpty ? availableShops.first['id']?.toString() : null,
                shopName: availableShops.isNotEmpty ? availableShops.first['name']?.toString() : null,
                customerId: widget.userEmail,
                customerName: widget.userName,
              ),
            ),
          );
          
          if (result == true) {
            // Reload reviews after successful submission
            _loadProductReviews();
          }
        },
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.star),
        label: const Text('Reviews'),
      ),
    );
  }

  void _showShopSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Shop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose a shop to purchase from:'),
            const SizedBox(height: 16),
            ...availableShops.map((shop) {
              final shopName = shop['name']?.toString() ?? 'Unknown Shop';
              final price = shop['unit_price']?.toString() ?? '0';
              final stockQuantity = shop['stock_quantity']?.toString() ?? '0';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    child: Text(
                      shopName.isNotEmpty ? shopName[0] : 'S',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(shopName),
                  subtitle: Text('Stock: $stockQuantity ${widget.unit}'),
                  trailing: Text(
                    '৳$price',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  onTap: () {
                    // Check if user is logged in first
                    if (!_checkLoginAndShowDialog()) {
                      Navigator.pop(context); // Close shop selection dialog
                      return; // User not logged in, login dialog shown
                    }

                    Navigator.pop(context);
                    _showPurchaseDialog(
                        context, shop, widget.title, widget.unit);
                  },
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, Map<String, dynamic> shop,
      String productTitle, String unit) {
    final TextEditingController quantityController =
        TextEditingController(text: '1');
    double unitPrice =
        double.tryParse(shop['unit_price']?.toString() ?? '0') ?? 0.0;
    int availableStock =
        int.tryParse(shop['stock_quantity']?.toString() ?? '0') ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          int quantity = int.tryParse(quantityController.text) ?? 1;
          double totalPrice = unitPrice * quantity;

          return AlertDialog(
            title: Text('Purchase $productTitle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shop: ${shop['name'] ?? 'Unknown Shop'}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('Address: ${shop['address'] ?? 'Unknown Address'}'),
                  Text('Phone: ${shop['phone'] ?? 'No Phone'}'),
                  const SizedBox(height: 16),
                  Text('Price per $unit: ৳${unitPrice.toStringAsFixed(2)}'),
                  Text('Available Stock: $availableStock $unit'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Quantity: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            suffixText: unit,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // Update the dialog state when quantity changes
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Price:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '৳${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (quantity > availableStock)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning,
                              color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Requested quantity exceeds available stock!',
                              style: TextStyle(
                                  color: Colors.red[700], fontSize: 12),
                            ),
                          ),
                        ],
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
                onPressed: quantity > 0 && quantity <= availableStock
                    ? () {
                        Navigator.pop(context);
                        _processPurchase(
                            shop, productTitle, quantity, totalPrice, unit);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm Purchase'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _processPurchase(Map<String, dynamic> shop, String productTitle,
      int quantity, double totalPrice, String unit) async {
    // Create and save the order
    final order = OrderService.createOrder(
      productName: productTitle,
      shopName: shop['name'] ?? 'Unknown Shop',
      shopPhone: shop['phone'] ?? 'No Phone',
      shopAddress: shop['address'] ?? 'No Address',
      quantity: quantity,
      unit: unit,
      unitPrice: totalPrice / quantity,
      totalPrice: totalPrice,
    );

    try {
      await OrderService().saveOrder(order);
    } catch (e) {
      // If saving fails, show error but continue with confirmation
      print('Error saving order: $e');
    }

    // Show order confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Order Placed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your order has been successfully placed.',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Order Details:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Product: $productTitle'),
            Text('Quantity: $quantity $unit'),
            Text('Shop: ${shop['name'] ?? 'Unknown Shop'}'),
            Text('Total: ৳${totalPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Next Steps:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                      '• Contact shop at ${shop['phone'] ?? 'No Phone'} for delivery'),
                  const Text('• Payment can be made on delivery'),
                  const Text('• You will receive a call confirmation soon'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/my-orders');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('View Orders'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Simulate calling the shop
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling ${shop['name']}...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Call Shop'),
          ),
        ],
      ),
    );
  }

  // Helper methods for review UI components
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

  Widget _buildReviewPreview(Map<String, dynamic> review) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.indigo,
                child: Text(
                  review['customerName'].toString().substring(0, 1),
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
            review['comment'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
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
              Icon(
                Icons.thumb_up,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${review['helpful']}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatReviewDate(DateTime date) {
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
