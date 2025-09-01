import 'package:flutter/material.dart';

import '../../models/shop.dart';
import '../../services/review_service.dart';
import '../../services/shop_service.dart';
import 'nearby_shops_map_screen_enhanced.dart';
import 'reviews_screen.dart';
import 'shop_items_screen.dart';

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  String searchQuery = "";
  String selectedLocation = "All Areas";
  String selectedCategory = "All Categories";
  String sortBy = "Distance";
  bool isMapView = false;
  bool isSearchingByProduct = false;

  final TextEditingController _searchController = TextEditingController();

  final List<String> locations = [
    "All Areas",
    "ধানমন্ডি",
    "গুলশান",
    "মিরপুর",
    "নিউমার্কেট",
    "উত্তরা",
    "বাশুন্ধরা",
    "মতিঝিল"
  ];

  final List<String> categories = [
    "All Categories",
    "গ্রোসারি",
    "সুপার শপ",
    "পাইকারি",
    "খুচরা",
    "চাল",
    "তেল",
    "ডাল",
    "সবজি"
  ];

  final List<String> sortOptions = [
    "Distance",
    "Rating",
    "Name A-Z",
    "Price (Low to High)"
  ];

  // Get all available products for autocomplete
  List<String> getAllProducts() {
    final shops = ShopService.getMockShops();
    Set<String> products = {};
    for (var shop in shops) {
      products.addAll(shop.availableProducts);
    }
    return products.toList();
  }

  // Check if search query is a product name
  bool isProductSearch(String query) {
    if (query.isEmpty) return false;
    final products = getAllProducts();
    return products
        .any((product) => product.toLowerCase().contains(query.toLowerCase()));
  }

  // Get filtered shops
  List<Shop> getFilteredShops() {
    List<Shop> shops = ShopService.getMockShops();

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      isSearchingByProduct = isProductSearch(searchQuery);

      if (isSearchingByProduct) {
        // Search by product - show shops that have this product
        shops = shops
            .where((shop) => shop.availableProducts.any((product) =>
                product.toLowerCase().contains(searchQuery.toLowerCase())))
            .toList();
      } else {
        // Search by shop name
        shops = shops
            .where((shop) =>
                shop.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                shop.address.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }
    }

    // Filter by location
    if (selectedLocation != "All Areas") {
      shops = shops
          .where((shop) => shop.address.contains(selectedLocation))
          .toList();
    }

    // Filter by category
    if (selectedCategory != "All Categories") {
      shops = shops
          .where((shop) => shop.category.contains(selectedCategory))
          .toList();
    }

    // Sort shops
    switch (sortBy) {
      case "Rating":
        shops.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case "Name A-Z":
        shops.sort((a, b) => a.name.compareTo(b.name));
        break;
      case "Distance":
      case "Price (Low to High)":
      default:
        // Keep original order for now (mock distance/price sorting)
        break;
    }

    return shops;
  }

  // Get highlighted products for a shop (when searching by product)
  List<String> getHighlightedProducts(Shop shop) {
    if (!isSearchingByProduct || searchQuery.isEmpty) return [];

    return shop.availableProducts
        .where((product) =>
            product.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  // Show quick review dialog for a shop
  void _showQuickReviewDialog(Shop shop) {
    showDialog(
      context: context,
      builder: (context) => _QuickReviewDialog(shop: shop),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredShops = getFilteredShops();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF079b11),
        foregroundColor: Colors.white,
        title: const Text("Shops"),
        actions: [
          // Location Dropdown Button for Nearby Shops Map
          PopupMenuButton<String>(
            icon: const Icon(Icons.location_on, color: Colors.white),
            tooltip: "Nearby Shops on Map",
            onSelected: (String value) {
              if (value == "nearby_map") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NearbyShopsMapScreenEnhanced(),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: "nearby_map",
                child: ListTile(
                  leading: Icon(Icons.map, color: Color(0xFF079b11)),
                  title: Text("View Nearby Shops"),
                  subtitle: Text("See shops on map with distance"),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(isMapView ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                isMapView = !isMapView;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      isMapView ? "Map view coming soon!" : "List view active"),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search by product or shop name...",
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF079b11)),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                searchQuery = "";
                                _searchController.clear();
                                isSearchingByProduct = false;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Colors.indigo),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Filter Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip("Location", selectedLocation, locations),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          "Category", selectedCategory, categories),
                      const SizedBox(width: 8),
                      _buildFilterChip("Sort", sortBy, sortOptions),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Results Header
          if (searchQuery.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.indigo.withValues(alpha: 0.1),
              child: Text(
                isSearchingByProduct
                    ? "Shops with \"$searchQuery\" (${filteredShops.length} found)"
                    : "Shops matching \"$searchQuery\" (${filteredShops.length} found)",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),

          // Shop List
          Expanded(
            child: filteredShops.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredShops.length,
                    itemBuilder: (context, index) {
                      final shop = filteredShops[index];
                      final highlightedProducts = getHighlightedProducts(shop);
                      return _buildShopCard(shop, highlightedProducts);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String selected, List<String> options) {
    return GestureDetector(
      onTap: () => _showFilterDialog(label, selected, options),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(63, 81, 181, 1).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.indigo.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.indigo, size: 20),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(String title, String selected, List<String> options) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select $title"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: selected,
                onChanged: (value) {
                  setState(() {
                    switch (title) {
                      case "Location":
                        selectedLocation = value!;
                        break;
                      case "Category":
                        selectedCategory = value!;
                        break;
                      case "Sort":
                        sortBy = value!;
                        break;
                    }
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShopCard(Shop shop, List<String> highlightedProducts) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopItemsScreen(shop: shop),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                    radius: 25,
                    child: Text(
                      shop.name[0],
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
                                shop.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (shop.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Verified",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                shop.address,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
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

              const SizedBox(height: 12),

              // Shop Details Row
              Row(
                children: [
                  // Rating
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${shop.rating}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Distance (mock)
                  const Row(
                    children: [
                      Icon(
                        Icons.directions_walk,
                        size: 16,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "0.5 km",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Opening Hours
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            shop.openingHours,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Highlighted Products (when searching by product)
              if (highlightedProducts.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Available Products:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: highlightedProducts
                            .take(3)
                            .map(
                              (product) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  product,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      if (highlightedProducts.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "+${highlightedProducts.length - 3} more products",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              // Shop Category Tag and Action Buttons
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      shop.category,
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Quick Review Button
                  GestureDetector(
                    onTap: () => _showQuickReviewDialog(shop),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Review",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_mall_directory_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No matching shops found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isNotEmpty
                  ? "Try searching for a different product or shop name"
                  : "Try adjusting your filters or search criteria",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  searchQuery = "";
                  selectedLocation = "All Areas";
                  selectedCategory = "All Categories";
                  sortBy = "Distance";
                  _searchController.clear();
                  isSearchingByProduct = false;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Reset Filters"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Quick Review Dialog Widget for Shop List
class _QuickReviewDialog extends StatefulWidget {
  final Shop shop;

  const _QuickReviewDialog({required this.shop});

  @override
  State<_QuickReviewDialog> createState() => _QuickReviewDialogState();
}

class _QuickReviewDialogState extends State<_QuickReviewDialog> {
  final TextEditingController _commentController = TextEditingController();
  int _overallRating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitQuickReview() async {
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
        shopOwnerId:
            'shop_owner_${widget.shop.name.toLowerCase().replaceAll(' ', '_')}', // Added required shopOwnerId
        shopName: widget.shop.name,
        customerId: 'customer_current',
        customerName: 'Current Customer',
        customerEmail: 'customer@example.com', // Added required customerEmail
        overallRating:
            _overallRating, // Changed from 'rating' to 'overallRating'
        deliveryRating: _overallRating, // Use overall rating for quick review
        serviceRating: _overallRating, // Use overall rating for quick review
        comment: _commentController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quick review submitted for ${widget.shop.name}!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View All Reviews',
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Quick Review',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

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
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.shop.address,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
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
            const SizedBox(height: 16),

            // Quick Rating
            Text(
              'Rate your experience',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _overallRating = index + 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      index < _overallRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 28,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Comment Section
            Text(
              'Quick feedback (optional)',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Share your quick thoughts about ${widget.shop.name}...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
              ),
            ),
            const SizedBox(height: 20),

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
                    onPressed: _isSubmitting ? null : _submitQuickReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
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
                        : const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
