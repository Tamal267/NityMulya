import 'package:flutter/material.dart';
import 'package:nitymulya/network/pricelist_api.dart';
import 'package:nitymulya/screens/customers/shop_list_screen.dart';
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
  bool isLoading = true;
  bool isCategoriesLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> result = products;
    
    // First filter by category
    if (selectedCategory != "All") {
      result = result
          .where((p) => p["cat_name"] == selectedCategory)
          .toList();
    }
    
    // Then filter by search query if present
    if (searchQuery.isNotEmpty) {
      result = result
          .where((p) => p["subcat_name"]
              ?.toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ?? false)
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
      searchBase = searchBase
          .where((p) => p["cat_name"] == selectedCategory)
          .toList();
    }
    
    return searchBase
        .where((p) => p["subcat_name"]
            ?.toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase()) ?? false)
        .take(5) // Limit suggestions to 5
        .toList();
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
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
        // Use empty list as fallback
        products = [];
      });
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
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        // Keep fallback categories if API fails
        categories = ["All", "চাল", "আটা ও ময়দা", "তেল", "ডাল", "সবজি ও মসলা", "মাছ ও গোশত", "দুধ"];
        isCategoriesLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadCategories(); // Load categories from API
    loadProducts(); // Load products from API
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: const Color(0xFF079b11),
      ),
      home: Scaffold(
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
        body: Column(
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
                                    title: Text(p["subcat_name"]?.toString() ?? 'Unknown Product'),
                                    subtitle: Text('${p["cat_name"] ?? "Unknown Category"} • ৳${p["min_price"] ?? 0} - ৳${p["max_price"] ?? 0}'),
                                    onTap: () {
                                      // Clear search and navigate to product
                                      setState(() {
                                        searchQuery = "";
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailScreen(
                                            title: p["subcat_name"]?.toString() ?? 'Unknown Product',
                                            unit: p["unit"]?.toString() ?? 'Unknown Unit',
                                            low: (p["min_price"] as num?)?.toInt() ?? 0,
                                            high: (p["max_price"] as num?)?.toInt() ?? 0,
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
              child: Text(
                isBangla ? "Daily Price Update" : "দৈনিক মূল্য আপডেট",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                "Last Updated: 2 hours ago",
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
                                searchQuery = ""; // Clear search when changing category
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
                              Icon(Icons.error_outline, size: 64, color: Colors.red),
                              SizedBox(height: 16),
                              Text('Error loading products'),
                              SizedBox(height: 8),
                              Text(errorMessage!, style: TextStyle(color: Colors.grey)),
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
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                            title: product["subcat_name"]?.toString() ?? 'Unknown Product',
                                            unit: product["unit"]?.toString() ?? 'Unknown Unit',
                                            low: (product["min_price"] as num?)?.toInt() ?? 0,
                                            high: (product["max_price"] as num?)?.toInt() ?? 0,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            product["subcat_name"]?.toString() ?? 'Unknown Product',
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
                                              const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            product["unit"]?.toString() ?? 'Unknown Unit',
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
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: _buildProductImage(product),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8, left: 8, right: 8),
                                          child: Text(
                                            "৳${product["min_price"] ?? 0} - ৳${product["max_price"] ?? 0}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
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
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          selectedItemColor: const Color(0xFF079b11),
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopListScreen()),
              );
            } else if (index == 2) {
              Navigator.pushNamed(context, '/favorites');
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.shop), label: "Shop"),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: "Favorites"),
          ],
        ),
      ),
    );
  }
}
