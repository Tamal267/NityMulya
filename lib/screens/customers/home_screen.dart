import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nitymulya/network/pricelist_api.dart';
import 'package:nitymulya/widgets/custom_drawer.dart';

import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String? userRole;

  const HomeScreen({
    super.key,
    this.userName,
    this.userEmail,
    this.userRole,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "All";
  String searchQuery = "";
  bool isDarkMode = false;
  bool isBangla = true;

  List<Map<String, dynamic>> products = [];
  List<String> categories = ["All"]; // Start with "All", will load from API
  Map<String, int> shopCounts = {}; // Store shop counts for each product
  bool isLoading = true;
  bool isCategoriesLoading = true;
  String? errorMessage;
  DateTime? lastUpdated; // Track when data was last updated
  Timer? _timer; // Timer for updating time display

  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> result = products;

    // First filter by category
    if (selectedCategory != "All") {
      result = result.where((p) => p["cat_name"] == selectedCategory).toList();
    }

    // Then filter by search query if present
    if (searchQuery.isNotEmpty) {
      result = result
          .where((p) =>
              p["subcat_name"]
                  ?.toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ??
              false)
          .toList();
    }

    return result;
  }

  // Get search suggestions that respect current category filter
  List<Map<String, dynamic>> get searchSuggestions {
    if (searchQuery.isEmpty) return [];

    List<Map<String, dynamic>> searchBase = products;

    // Respect category filter for search suggestions
    if (selectedCategory != "All") {
      searchBase =
          searchBase.where((p) => p["cat_name"] == selectedCategory).toList();
    }

    return searchBase
        .where((p) =>
            p["subcat_name"]
                ?.toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ??
            false)
        .take(5) // Limit suggestions to 5
        .toList();
  }

  // Get formatted time since last update
  String getTimeSinceLastUpdate() {
    if (lastUpdated == null) {
      return isBangla ? "কখনো আপডেট হয়নি" : "Never updated";
    }

    final now = DateTime.now();
    final difference = now.difference(lastUpdated!);

    if (difference.inMinutes < 1) {
      return isBangla ? "এখনই" : "Just now";
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      if (isBangla) {
        return "$minutes মিনিট আগে";
      } else {
        return "$minutes minute${minutes == 1 ? '' : 's'} ago";
      }
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      if (isBangla) {
        return "$hours ঘন্টা আগে";
      } else {
        return "$hours hour${hours == 1 ? '' : 's'} ago";
      }
    } else {
      final days = difference.inDays;
      if (isBangla) {
        return "$days দিন আগে";
      } else {
        return "$days day${days == 1 ? '' : 's'} ago";
      }
    }
  }

  // Load products from API
  Future<void> loadProducts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final apiProducts = await fetchPriceList();

      setState(() {
        products = apiProducts;
        isLoading = false;
        lastUpdated = DateTime.now(); // Set current time as last updated
      });
      
      // Load shop counts after products are loaded
      _loadShopCounts();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
        // Use empty list as fallback
        products = [];
      });
    }
  }

  // Load shop counts for each product
  Future<void> _loadShopCounts() async {
    // Load shop counts for each product in the background
    for (final product in products) {
      final subcatId = product["id"]?.toString();
      if (subcatId != null && subcatId.isNotEmpty) {
        try {
          final shops = await fetchShopsBySubcategoryId(subcatId);
          if (mounted) {
            setState(() {
              shopCounts[subcatId] = shops.length;
            });
          }
        } catch (e) {
          // Silently handle error, just don't show shop count for this product
          if (mounted) {
            setState(() {
              shopCounts[subcatId] = 0;
            });
          }
        }
      }
    }
  }

  // Load categories from API
  Future<void> loadCategories() async {
    try {
      setState(() {
        isCategoriesLoading = true;
      });

      final apiCategories = await fetchCategories();

      // Extract cat_name from API response and create list with "All" first
      final categoryNames = ["All"];
      for (final category in apiCategories) {
        final catName = category["cat_name"]?.toString();
        if (catName != null && catName.isNotEmpty) {
          categoryNames.add(catName);
        }
      }

      setState(() {
        categories = categoryNames;
        isCategoriesLoading = false;
        lastUpdated = DateTime.now(); // Set current time as last updated
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        // Keep fallback categories if API fails
        categories = [
          "All",
          "চাল",
          "আটা ও ময়দা",
          "তেল",
          "ডাল",
          "সবজি ও মসলা",
          "মাছ ও গোশত",
          "দুধ"
        ];
        isCategoriesLoading = false;
      });
    }
  }

  // Helper method to safely parse price values from API response
  int _parsePrice(dynamic price) {
    if (price == null) return 0;

    if (price is num) {
      return price.toInt();
    }

    if (price is String) {
      try {
        return double.parse(price).toInt();
      } catch (e) {
        print('Error parsing price: $price, error: $e');
        return 0;
      }
    }

    return 0;
  }

  // Build shop availability widget
  Widget _buildShopAvailability(Map<String, dynamic> product) {
    final subcatId = product["id"]?.toString();

    if (subcatId == null || subcatId.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!shopCounts.containsKey(subcatId)) {
      // Still loading
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "Loading...",
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final shopCount = shopCounts[subcatId] ?? 0;

    if (shopCount == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_outlined, size: 12, color: Colors.red.shade600),
            const SizedBox(width: 4),
            Text(
              "No shops",
              style: TextStyle(
                fontSize: 10,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.store, size: 12, color: Colors.green.shade700),
          const SizedBox(width: 4),
          Text(
            "$shopCount ${shopCount == 1 ? 'Shop' : 'Shops'}",
            style: TextStyle(
              fontSize: 10,
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadCategories(); // Load categories from API
    loadProducts(); // Load products from API
    
    // Start periodic timer to update time display every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {}); // Just trigger rebuild to update time display
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }

  Widget _buildProductImage(Map<String, dynamic> product) {
    final imageUrl = product["subcat_img"]?.toString();

    // If image URL is null or empty, show the inventory icon
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return const Icon(Icons.inventory_2, size: 60, color: Colors.grey);
    }

    // Try to load the image, with fallback to inventory icon on error
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.inventory_2, size: 60, color: Colors.grey);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        userName: widget.userName ?? 'Guest User',
        userEmail: widget.userEmail ?? 'guest@example.com',
        userRole: widget.userRole ?? 'Customer',
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF079b11),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("NitiMulya"),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.language),
                  onPressed: () {
                    setState(() {
                      isBangla = !isBangla;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () {
                    setState(() {
                      isDarkMode = !isDarkMode;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        color: isDarkMode ? Colors.grey[900] : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: selectedCategory == "All"
                      ? "Search all products"
                      : "Search in $selectedCategory",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => searchQuery = ""),
                        )
                      : null,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            if (searchQuery.isNotEmpty)
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  child: searchSuggestions.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            selectedCategory == "All"
                                ? 'No products found matching "$searchQuery"'
                                : 'No products found in "$selectedCategory" matching "$searchQuery"',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView(
                          shrinkWrap: true,
                          children: searchSuggestions
                              .map((p) => ListTile(
                                    title: Text(p["subcat_name"]?.toString() ??
                                        'Unknown Product'),
                                    subtitle: Text(
                                        '${p["cat_name"] ?? "Unknown Category"} • ৳${_parsePrice(p["min_price"])} - ৳${_parsePrice(p["max_price"])}'),
                                    onTap: () {
                                      // Clear search and navigate to product
                                      setState(() {
                                        searchQuery = "";
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailScreen(
                                            title:
                                                p["subcat_name"]?.toString() ??
                                                    'Unknown Product',
                                            unit: p["unit"]?.toString() ??
                                                'Unknown Unit',
                                            low: _parsePrice(p["min_price"]),
                                            high: _parsePrice(p["max_price"]),
                                            subcatId: p["id"]
                                                ?.toString(), // Pass the subcategory ID
                                            userEmail: widget.userEmail,
                                            userName: widget.userName,
                                          ),
                                        ),
                                      );
                                    },
                                  ))
                              .toList(),
                        ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBangla ? "Daily Price Update" : "দৈনিক মূল্য আপডেট",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      loadProducts();
                      loadCategories();
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    tooltip: isBangla ? "রিফ্রেশ করুন" : "Refresh",
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                isBangla 
                  ? "সর্বশেষ আপডেট: ${getTimeSinceLastUpdate()}"
                  : "Last Updated: ${getTimeSinceLastUpdate()}",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: isCategoriesLoading
                  ? const Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ChoiceChip(
                            label: Text(categories[index]),
                            selected: selectedCategory == categories[index],
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = categories[index];
                                searchQuery =
                                    ""; // Clear search when changing category
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 64, color: Colors.red),
                              SizedBox(height: 16),
                              Text('Error loading products'),
                              SizedBox(height: 8),
                              Text(errorMessage!,
                                  style: TextStyle(color: Colors.grey)),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: loadProducts,
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : filteredProducts.isEmpty
                          ? const Center(
                              child: Text('No products found'),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(12),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailScreen(
                                            title: product["subcat_name"]
                                                    ?.toString() ??
                                                'Unknown Product',
                                            unit: product["unit"]?.toString() ??
                                                'Unknown Unit',
                                            low: _parsePrice(
                                                product["min_price"]),
                                            high: _parsePrice(
                                                product["max_price"]),
                                            subcatId: product["id"]
                                                ?.toString(), // Pass the subcategory ID
                                            userEmail: widget.userEmail,
                                            userName: widget.userName,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            product["subcat_name"]
                                                    ?.toString() ??
                                                'Unknown Product',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            product["unit"]?.toString() ??
                                                'Unknown Unit',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child:
                                                    _buildProductImage(product),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8, left: 8, right: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Price
                                              Text(
                                                "৳${_parsePrice(product["min_price"])} - ৳${_parsePrice(product["max_price"])}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              
                                              // Shop Availability - Centered at bottom
                                              Center(
                                                child: _buildShopAvailability(product),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
