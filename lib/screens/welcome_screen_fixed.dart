import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nitymulya/network/pricelist_api.dart';
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
  bool isLoading = true;
  bool isCategoriesLoading = true;
  String? errorMessage;

  late AnimationController _controller;

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
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
        products = [];
      });
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please login to continue"),
                  ),
                );
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please login to continue"),
                          ),
                        );
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
                  onPressed: () => setState(() => isDarkMode = !isDarkMode),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
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
                                      subtitle: Text(
                                          '${p["cat_name"] ?? "Unknown Category"} • ৳${p["min_price"] ?? 0} - ৳${p["max_price"] ?? 0}'),
                                      onTap: () {
                                        setState(() {
                                          searchQuery = "";
                                        });
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ProductDetailScreen(
                                              title: p["subcat_name"]
                                                      ?.toString() ??
                                                  'Unknown Product',
                                              unit: p["unit"]?.toString() ??
                                                  'Unknown Unit',
                                              low: (p["min_price"] as num?)
                                                      ?.toInt() ??
                                                  0,
                                              high: (p["max_price"] as num?)
                                                      ?.toInt() ??
                                                  0,
                                              subcatId: p["id"]?.toString(),
                                              userName: widget.userName,
                                              userEmail: widget.userEmail,
                                              userRole: widget.userRole,
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text("See all products feature - coming soon!"),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                height: MediaQuery.of(context).size.height * 0.5,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
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
                                    style: const TextStyle(color: Colors.grey)),
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
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailScreen(
                                            title: product["subcat_name"]
                                                    ?.toString() ??
                                                'Unknown Product',
                                            unit: product["unit"]?.toString() ??
                                                'Unknown Unit',
                                            low: (product["min_price"] as num?)
                                                    ?.toInt() ??
                                                0,
                                            high: (product["max_price"] as num?)
                                                    ?.toInt() ??
                                                0,
                                            subcatId: product["id"]?.toString(),
                                            userName: widget.userName,
                                            userEmail: widget.userEmail,
                                            userRole: widget.userRole,
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: Colors.grey[100],
                                                ),
                                                child:
                                                    _buildProductImage(product),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    product["subcat_name"]
                                                            ?.toString() ??
                                                        'Unknown Product',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    product["unit"]
                                                            ?.toString() ??
                                                        'Unknown Unit',
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Text(
                                                    '৳${product["min_price"] ?? 0} - ৳${product["max_price"] ?? 0}',
                                                    style: const TextStyle(
                                                      color: Color(0xFF079b11),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF079b11),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shops'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
        ],
        onTap: (index) {
          if (index == 1) {
            _handleRestrictedAction('orders'); // Orders - require login
          } else if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Map - Coming Soon!")),
            ); // Map - show message
          } else if (index == 3) {
            _handleRestrictedAction('shops'); // Shops - require login
          } else if (index == 4) {
            _handleRestrictedAction('favorites'); // Favorites - require login
          }
        },
      ),
    );
  }
}
