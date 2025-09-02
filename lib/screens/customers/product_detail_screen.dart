import 'package:flutter/material.dart';
import 'package:nitymulya/network/pricelist_api.dart';
import 'package:geolocator/geolocator.dart';

import '../../network/customer_api.dart';
import '../../services/review_service.dart';
import '../../widgets/shop_card_with_distance.dart';
import 'favorite_products_screen.dart';
import 'order_confirmation_screen.dart';
import 'reviews_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String title;
  final String unit;
  final int low;
  final int high;
  final String? subcatId; // Add subcategory ID
  final String? userEmail; // Add user email for reviews
  final String? userName; // Add user name for reviews

  const ProductDetailScreen({
    super.key,
    required this.title,
    required this.unit,
    required this.low,
    required this.high,
    this.subcatId, // Optional for backward compatibility
    this.userEmail, // Optional for reviews
    this.userName, // Optional for reviews
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

  // Location-related variables
  Position? userLocation;
  bool isLoadingLocation = false;

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
    // Start location loading in parallel
    _getCurrentLocation();
    
    await Future.wait([
      _loadAvailableShops(),
      _loadPriceHistory(),
      _loadProductReviews(),
    ]);
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        isLoadingLocation = true;
      });

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        userLocation = position;
        isLoadingLocation = false;
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        isLoadingLocation = false;
      });
    }
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

      final reviews = await ReviewService.getProductReviewsByName(widget.title);
      final avgRatingData =
          await ReviewService.getProductAverageRatingByName(widget.title);

      setState(() {
        // Only use reviews from database, don't fall back to sample data
        productReviews = reviews;
        // Only use database average rating, or 0 if no reviews
        averageRating = avgRatingData['average']?.toDouble() ?? 0.0;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.favorite, color: Colors.white),
            tooltip: 'Favourite Options',
            onSelected: (String value) {
              if (value == 'add_to_favourites') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.title} added to favorites!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (value == 'view_favourites') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoriteProductsScreen(
                      userName: widget.userName,
                      userEmail: widget.userEmail,
                      userRole: 'Customer',
                    ),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'add_to_favourites',
                child: ListTile(
                  leading: Icon(Icons.favorite_border, color: Colors.red),
                  title: Text('Add to Favourites'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'view_favourites',
                child: ListTile(
                  leading: Icon(Icons.favorite, color: Colors.green),
                  title: Text('View My Favourites'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
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
                  
                  return ShopCardWithDistance(
                    shop: shop,
                    userLocation: userLocation,
                    productTitle: widget.title,
                    unit: widget.unit,
                    onTap: () {
                      final shopName = shop['name']?.toString() ?? 'Unknown Shop';
                      final shopAddress = shop['address']?.toString() ?? 'Unknown Address';
                      final shopPhone = shop['phone']?.toString() ?? 'No Phone';
                      final stockQuantity = shop['stock_quantity']?.toString() ?? '0';
                      final shopDescription = shop['shop_description']?.toString() ?? '';
                      final price = shop['unit_price']?.toString() ?? '0';
                      final stock = int.tryParse(stockQuantity) ?? 0;
                      final threshold = int.tryParse(shop['low_stock_threshold']?.toString() ?? '10') ?? 10;
                      final isLowStock = stock <= threshold;
                      final stockStatus = stock > 50 ? 'High Stock' : stock > threshold ? 'Medium Stock' : 'Low Stock';

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(shopName),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Address: $shopAddress"),
                              Text("Phone: $shopPhone"),
                              if (shopDescription.isNotEmpty)
                                Text("Description: $shopDescription"),
                              Text("Stock: $stockQuantity ${widget.unit}"),
                              Text("Stock Status: $stockStatus"),
                              Text("Price: ৳$price per ${widget.unit}"),
                              if (isLowStock)
                                const Text(
                                  "⚠️ Low stock - order soon!",
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showPurchaseDialog(
                                    context, shop, widget.title, widget.unit);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Purchase"),
                            ),
                          ],
                        ),
                      );
                    },
                    onBuyNow: () {
                      _showPurchaseDialog(
                          context, shop, widget.title, widget.unit);
                    },
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
                                  shopId: availableShops.isNotEmpty
                                      ? availableShops.first['id']?.toString()
                                      : null,
                                  shopName: availableShops.isNotEmpty
                                      ? availableShops.first['name']?.toString()
                                      : null,
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
        onPressed: () {
          // Show popup review dialog instead of navigating to full screen
          _showReviewPopupDialog();
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
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text('Placing order...'),
          ],
        ),
      ),
    );

    try {
      // Validate required data
      final shopOwnerId = shop['id']?.toString();
      final subcatId = widget.subcatId;

      if (shopOwnerId == null || shopOwnerId.isEmpty) {
        // Close loading dialog before throwing exception
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        throw Exception('Shop ID is missing');
      }

      if (subcatId == null || subcatId.isEmpty) {
        // Close loading dialog before throwing exception
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        throw Exception('Product ID is missing');
      }

      // Call the backend API to create order in database
      final result = await CustomerApi.createOrder(
        shopOwnerId: shopOwnerId,
        subcatId: subcatId,
        quantityOrdered: quantity,
        deliveryAddress: 'House #12, Road #5, Dhanmondi, Dhaka',
        deliveryPhone: '01900000000',
        notes: 'Order placed through mobile app',
      );

      // Close loading dialog safely
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Check if widget is still mounted before navigation
      if (!mounted) return;

      if (result['success'] == true) {
        // Small delay to ensure loading dialog is fully dismissed
        await Future.delayed(const Duration(milliseconds: 100));

        // Check if still mounted after delay
        if (!mounted) return;

        // Navigate to order confirmation screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmationScreen(
              orderData: result['order'] ?? {},
              shopData: shop,
              productTitle: productTitle,
              quantity: quantity,
              unit: unit,
              totalPrice: totalPrice,
            ),
          ),
        );

        // Refresh the available shops to update stock quantities
        _loadAvailableShops();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Order Failed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(result['error'] ??
                    result['message'] ??
                    'Unknown error occurred'),
                const Text('Please try again or contact support'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                // Retry the purchase
                _processPurchase(
                    shop, productTitle, quantity, totalPrice, unit);
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open safely
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error message for network or other errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Connection Error',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Error: $e'),
                const Text('Check your internet connection and try again'),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                // Retry the purchase
                _processPurchase(
                    shop, productTitle, quantity, totalPrice, unit);
              },
            ),
          ),
        );
      }
    }
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

  // Show popup review dialog
  void _showReviewPopupDialog() {
    showDialog(
      context: context,
      builder: (context) => ReviewPopupDialog(
        productName: widget.title,
        shopId: availableShops.isNotEmpty
            ? availableShops.first['id']?.toString()
            : null,
        shopName: availableShops.isNotEmpty
            ? availableShops.first['name']?.toString()
            : null,
        customerId: widget.userEmail,
        customerName: widget.userName,
        existingReviews: productReviews,
        averageRating: averageRating,
        onReviewAdded: () {
          _loadProductReviews(); // Reload reviews after adding
        },
      ),
    );
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
      return 'Just now';
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

// Review Popup Dialog for showing reviews and adding new reviews
class ReviewPopupDialog extends StatefulWidget {
  final String productName;
  final String? shopId;
  final String? shopName;
  final String? customerId;
  final String? customerName;
  final List<Map<String, dynamic>> existingReviews;
  final double averageRating;
  final VoidCallback onReviewAdded;

  const ReviewPopupDialog({
    super.key,
    required this.productName,
    this.shopId,
    this.shopName,
    this.customerId,
    this.customerName,
    required this.existingReviews,
    required this.averageRating,
    required this.onReviewAdded,
  });

  @override
  State<ReviewPopupDialog> createState() => _ReviewPopupDialogState();
}

class _ReviewPopupDialogState extends State<ReviewPopupDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header with product info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.shopName != null)
                          Text(
                            'from ${widget.shopName}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  icon: const Icon(Icons.list),
                  text: 'Reviews (${widget.existingReviews.length})',
                ),
                Tab(
                  icon: const Icon(Icons.edit),
                  text: widget.customerId != null
                      ? 'Write Review'
                      : 'Login Required',
                ),
              ],
              labelColor: Colors.indigo,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.indigo,
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildReviewsListTab(),
                  _buildWriteReviewTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsListTab() {
    if (widget.existingReviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No reviews yet',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Be the first to review this product!',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Average Rating Summary
        if (widget.averageRating > 0) ...[
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.amber.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    _buildStarRating(widget.averageRating, 20),
                    Text(
                      '${widget.existingReviews.length} reviews',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],

        // Reviews List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.existingReviews.length,
            itemBuilder: (context, index) {
              final review = widget.existingReviews[index];
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
                              review['customerName']
                                  .toString()
                                  .substring(0, 1)
                                  .toUpperCase(),
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    _buildStarRating(
                                        review['rating'].toDouble(), 16),
                                    const SizedBox(width: 8),
                                    if (review['isVerifiedPurchase'] == true)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'Verified',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10),
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
                      Text(
                        review['comment'],
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Shop: ${review['shopName']}',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                          ),
                          const Spacer(),
                          Text(
                            'Just now', // You can implement proper date formatting
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWriteReviewTab() {
    if (widget.customerId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Please login to write a review',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('You need to be logged in to share your experience',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate this product:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Star Rating Selector
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
                  size: 36,
                ),
              );
            }),
          ),

          const SizedBox(height: 24),
          const Text(
            'Write your review:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Comment Field
          TextField(
            controller: _commentController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Share your experience with this product...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(16),
            ),
          ),

          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Submit Review',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a review comment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reviewData = {
        'customerId': widget.customerId ?? 'anonymous_user',
        'customerName': widget.customerName ?? 'Anonymous User',
        'customerEmail': widget.customerId ??
            'anonymous@example.com', // Use customerId as fallback email
        'shopOwnerId': widget.shopId ?? 'unknown_shop',
        'shopName': widget.shopName ?? 'Unknown Shop',
        'productName': widget.productName,
        'subcatId': widget.productName, // Use productName as subcatId fallback
        'rating': _rating,
        'comment': _commentController.text.trim(),
        'isVerifiedPurchase': false,
      };

      await ReviewService.saveProductReview(reviewData);

      if (mounted) {
        Navigator.pop(context);
        widget.onReviewAdded();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Review submitted successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
