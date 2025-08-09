import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nitymulya/network/pricelist_api.dart';
import 'package:nitymulya/screens/auth/login_screen.dart';
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
  List<String> categories = ["All"]; // Start with "All", will load from API
  bool isLoading = true;
  bool isCategoriesLoading = true;
  String? errorMessage;

  late AnimationController _controller;
  late Animation<double> _fadeIn;

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
      setState(() {
        // Keep fallback categories if API fails
        categories = ["All", "চাল", "আটা ও ময়দা", "তেল", "ডাল", "সবজি ও মসলা", "মাছ ও গোশত", "দুধ"];
        isCategoriesLoading = false;
      });
    }
  }

//-----------------------------------Mithila --------------------//
  @override
  void initState() {
    super.initState();
    loadCategories(); // Load categories from API
    loadProducts(); // Load products from API
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
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

  void _handleRestrictedAction() {
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
      // TODO: Add actual action if logged in
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Accessing feature..."),
      ));
    }
  }

//---------Mithila----------

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // Remove default padding
        children: [
          SizedBox(
            height: 220, // Fixed height instead of DrawerHeader
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
                        minimumSize:
                            const Size(150, 40), // Constrained button size
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/login'),
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
                            fontSize: 16, // Slightly smaller
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.userEmail ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12, // Smaller email text
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
            onTap: _handleRestrictedAction,
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text("Favorites"),
            onTap: _handleRestrictedAction,
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

  @override
  Widget build(BuildContext context) {
    if (showSplash) {
      return Scaffold(
        backgroundColor: Colors.green.shade100,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular image with border
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.green.shade800, // Border color
                    width: 3.0, // Border width
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/image/logo.jpeg',
                    height: 150, // Adjust size as needed
                    width: 150,
                    fit: BoxFit.cover, // Ensures the image fills the circle
                  ),
                ),
              ),
              SizedBox(height: 20),
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: const Color(0xFF079b11),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
      home: Scaffold(
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: _fadeIn,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Text(
                  isBangla ? "Welcome to NityMulya!" : "Welcome to NityMulya!",
                  style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
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
                isBangla ? "দৈনিক মূল্য আপডেট" : "Daily Price Update",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text("Last Updated: 2 hours ago",
                  style: TextStyle(color: Colors.grey[600])),
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
                            onSelected: (_) => setState(() {
                              selectedCategory = categories[index];
                              searchQuery = ""; // Clear search when changing category
                            }),
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
                                      borderRadius: BorderRadius.circular(10)),
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
                                                fontSize: 12, color: Colors.grey),
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
                                              child: const Center(
                                                child: Icon(Icons.inventory_2,
                                                    size: 40, color: Colors.grey),
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

        //  bottomNavigationBar: const GlobalBottomNav(currentIndex: 0),
        //----------Mithila---------//
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0, // Current selected index
          selectedItemColor:
              const Color(0xFF079b11), // Green color for selected tab
          unselectedItemColor: Colors.grey, // Grey for unselected tabs
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shops'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: 'Favorites'),
          ],
          onTap: (index) {
            if (index == 1 || index == 2) {
              // Both Shops and Favorites tabs
              _handleRestrictedAction();
            }
            // Home tab (index 0) does nothing since we're already there
          },
        ),
      ),
    );
  }
}
