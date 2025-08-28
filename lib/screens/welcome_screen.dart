import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nitymulya/network/pricelist_api.dart';
import 'package:nitymulya/screens/customers/nearby_shops_map_screen_enhanced.dart';
import 'package:nitymulya/screens/customers/product_detail_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String? userRole;

  const WelcomeScreen({
    super.key,
    this.userName,
    this.userEmail,
    this.userRole,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  String selectedCategory = "All";
  String searchQuery = "";
  bool isDarkMode = false;
  bool isBangla = true;
  bool showSplash = true;

  List<Map<String, dynamic>> products = [];
  List<String> categories = ["All"];
  Map<String, int> shopCounts = {}; // Store shop counts for each product
  bool isLoading = true;
  bool isCategoriesLoading = true;
  String? errorMessage;

  late AnimationController _controller;

  // Helper method to safely parse price values
  int _safeParseInt(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      try {
        return double.parse(value).toInt();
      } catch (e) {
        print('Error parsing price: $value, error: $e');
        return 0;
      }
    }

    return 0;
  }

  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> result = products;

    if (selectedCategory != "All") {
      result = result.where((p) => p["cat_name"] == selectedCategory).toList();
    }

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

  List<Map<String, dynamic>> get searchSuggestions {
    if (searchQuery.isEmpty) return [];
    List<Map<String, dynamic>> searchBase = products;

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
        .take(5)
        .toList();
  }

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
      });

      // Load shop counts after products are loaded
      _loadShopCounts();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
        products = [];
      });
    }
  }

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

  Future<void> loadCategories() async {
    try {
      setState(() {
        isCategoriesLoading = true;
      });

      final apiCategories = await fetchCategories();
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
      });
    } catch (e) {
      setState(() {
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

  @override
  void initState() {
    super.initState();
    loadCategories();
    loadProducts();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        showSplash = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleRestrictedAction([String? feature]) {
    if (widget.userName == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Login Required"),
          content: const Text("Please login or sign up to continue."),
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
    } else {
      // Handle navigation for logged-in users
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Accessing ${feature ?? 'feature'}..."),
      ));
    }
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 220,
            child: Container(
              decoration: const BoxDecoration(color: Color(0xFF079b11)),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/image/logo.jpeg',
                        height: 90,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (widget.userName == null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        minimumSize: const Size(150, 40),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        "Login / Sign Up",
                        style: TextStyle(fontSize: 14),
                      ),
                    )
                  else
                    Column(
                      children: [
                        Text(
                          widget.userName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.userEmail ?? '',
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
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text("Shop"),
            onTap: () => _handleRestrictedAction('shop'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text("My Orders"),
            onTap: () => _handleRestrictedAction('orders'),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text("Favorites"),
            onTap: () => _handleRestrictedAction('favorites'),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About Our App"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text("Help & Support"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text("Test Main Customer"),
            onTap: () {
              Navigator.pushNamed(context, '/main-customer');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(Map<String, dynamic> product) {
    final imageUrl = product["subcat_img"]?.toString();

    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return const Icon(Icons.inventory_2, size: 60, color: Colors.grey);
    }

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

  Widget _buildShopAvailability(Map<String, dynamic> product) {
    final subcatId = product["id"]?.toString();

    if (subcatId == null || subcatId.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!shopCounts.containsKey(subcatId)) {
      // Still loading
      return Row(
        children: [
          Icon(Icons.store_outlined, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            "Loading shops...",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    }

    final shopCount = shopCounts[subcatId] ?? 0;

    if (shopCount == 0) {
      return Row(
        children: [
          Icon(Icons.store_outlined, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            "No shops available",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        const Icon(Icons.store, size: 14, color: Color(0xFF079b11)),
        const SizedBox(width: 4),
        Text(
          "$shopCount ${shopCount == 1 ? 'shop' : 'shops'} available",
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF079b11),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showSplash) {
      return Scaffold(
        backgroundColor: Colors.green.shade100,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.green.shade800,
                    width: 3.0,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/image/logo.jpeg',
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome to NityMulya App!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : null,
      drawer: buildDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF079b11),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("NityMulya"),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.language),
                  onPressed: () => setState(() => isBangla = !isBangla),
                ),
                IconButton(
                  icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () {
                    setState(() => isDarkMode = !isDarkMode);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isDarkMode
                            ? 'Dark mode enabled'
                            : 'Light mode enabled'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          color: isDarkMode ? Colors.grey[900] : null,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                if (searchQuery.isNotEmpty)
                  Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3),
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
                                        title: Text(
                                            p["subcat_name"]?.toString() ??
                                                'Unknown Product'),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                '${p["cat_name"] ?? "Unknown Category"} • ৳${_safeParseInt(p["min_price"])} - ৳${_safeParseInt(p["max_price"])}'),
                                            const SizedBox(height: 2),
                                            _buildShopAvailability(p),
                                          ],
                                        ),
                                        onTap: () {
                                          setState(() {
                                            searchQuery = "";
                                          });
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ProductDetailScreen(
                                                title: p["subcat_name"]
                                                        ?.toString() ??
                                                    'Unknown Product',
                                                unit: p["unit"]?.toString() ??
                                                    'Unknown Unit',
                                                low: _safeParseInt(
                                                    p["min_price"]),
                                                high: _safeParseInt(
                                                    p["max_price"]),
                                                subcatId: p["id"]?.toString(),
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
                        isBangla ? "দৈনিক মূল্য আপডেট" : "Daily Price Update",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // Navigate to a simple product list view
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "See all products feature - coming soon!"),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Color(0xFF079b11),
                        ),
                        label: Text(
                          "See All",
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF079b11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text("Last Updated: 2 hours ago",
                      style: TextStyle(color: Colors.grey[600])),
                ),
                Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(vertical: 2),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: ChoiceChip(
                                label: Text(categories[index]),
                                selected: selectedCategory == categories[index],
                                onSelected: (_) => setState(() {
                                  selectedCategory = categories[index];
                                  searchQuery = "";
                                }),
                              ),
                            );
                          },
                        ),
                ),
                // Fixed height container for products to avoid overflow
                Container(
                  height: MediaQuery.of(context).size.height * 1,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline,
                                      size: 64, color: Colors.red),
                                  const SizedBox(height: 16),
                                  const Text('Error loading products'),
                                  const SizedBox(height: 8),
                                  Text(errorMessage!,
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: loadProducts,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : filteredProducts.isEmpty
                              ? const Center(
                                  child: Text('No products found'),
                                )
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 6,
                                    mainAxisSpacing: 6,
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
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ProductDetailScreen(
                                              title: product["subcat_name"]
                                                      ?.toString() ??
                                                  'Unknown Product',
                                              unit:
                                                  product["unit"]?.toString() ??
                                                      'Unknown Unit',
                                              low: _safeParseInt(
                                                  product["min_price"]),
                                              high: _safeParseInt(
                                                  product["max_price"]),
                                              subcatId:
                                                  product["id"]?.toString(),
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Center(
                                                    child: _buildProductImage(
                                                        product),
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
                                                  Text(
                                                    "৳${_safeParseInt(product["min_price"])} - ৳${_safeParseInt(product["max_price"])}",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  _buildShopAvailability(
                                                      product),
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
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF079b11),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Orders'),
          BottomNavigationBarItem(
              icon: Icon(Icons.store_mall_directory), label: 'Nearby Shops'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
        ],
        onTap: (index) {
          if (index == 1) {
            _handleRestrictedAction('orders'); // Orders - require login
          } else if (index == 2) {
            // Navigate to Map Screen showing nearby shops
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NearbyShopsMapScreenEnhanced(
                  userName: widget.userName,
                  userEmail: widget.userEmail,
                  userRole: widget.userRole,
                ),
              ),
            );
          } else if (index == 3) {
            _handleRestrictedAction('favorites'); // Favorites - require login
          }
        },
      ),
    );
  }
}
