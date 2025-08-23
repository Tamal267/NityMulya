import 'package:flutter/material.dart';
import 'package:nitymulya/network/auth.dart';
import 'package:nitymulya/network/pricelist_api.dart';
import 'package:nitymulya/network/wholesaler_api.dart';
import 'package:nitymulya/screens/welcome_screen.dart';
import 'package:nitymulya/screens/wholesaler/add_order_screen.dart';
import 'package:nitymulya/screens/wholesaler/order_status_update_screen.dart';
import 'package:nitymulya/screens/wholesaler/shop_owner_search_screen.dart';
import 'package:nitymulya/screens/wholesaler/shop_reviews_screen.dart';
import 'package:nitymulya/screens/wholesaler/wholesaler_add_product_screen.dart';
import 'package:nitymulya/screens/wholesaler/wholesaler_chat_screen.dart';
import 'package:nitymulya/widgets/custom_drawer.dart';

class WholesalerDashboardScreen extends StatefulWidget {
  const WholesalerDashboardScreen({super.key});

  @override
  State<WholesalerDashboardScreen> createState() =>
      _WholesalerDashboardScreenState();
}

class _WholesalerDashboardScreenState extends State<WholesalerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int unreadNotifications = 8;
  int totalShops = 45;
  int newRequests = 12;
  int lowStockProducts = 8;
  int outOfStockProducts = 3;
  String supplyStatus = "Active";

  // Inventory state
  List<Map<String, dynamic>> inventoryItems = [];
  bool isLoadingInventory = false;
  String? inventoryError;

  // Categories and subcategories data
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> priceList = [];
  List<String> products = ["All Products"];
  bool isLoadingProducts = false;

  // Offers state
  List<Map<String, dynamic>> offers = [];
  bool isLoadingOffers = false;
  String? offersError;

  // Chat related state variables
  List<Map<String, dynamic>> shopOwners = [];
  List<Map<String, dynamic>> filteredShopOwners = [];
  final TextEditingController _chatSearchController = TextEditingController();
  bool isLoadingShopOwners = false;
  String? shopOwnersError;
  bool showSearchDropdown = false;

  // Stock Monitor state (additional variables)
  List<Map<String, dynamic>> lowStockProductsList = [];
  bool isLoadingLowStock = false;
  String? categoriesError;
  String? lowStockError;

  // Order History state
  List<Map<String, dynamic>> orderHistory = [];
  bool isLoadingHistory = false;
  String? historyError;
  List<Map<String, dynamic>> categoryList = [];

  // TODO: Remove this hardcoded ID - now using token-based authentication
  // final String currentWholesalerId = 'cdb69b0f-27bc-41b5-9ce3-525f54e1f316';

  String selectedProduct = "All Products";
  String selectedLocation = "All Areas";
  int quantityThreshold = 10;

  final List<String> locations = [
    "All Areas",
    "Dhaka (ঢাকা)",
    "Chittagong (চট্টগ্রাম)",
    "Sylhet (সিলেট)",
    "Rajshahi (রাজশাহী)",
    "Khulna (খুলনা)",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadInventory(); // Load inventory on startup
    _loadOffers(); // Load offers on startup
    _loadCategories(); // Load categories for filters
    _loadLowStockProducts(); // Load low stock products on startup
    _loadProductsFromDatabase(); // Load products for the filter
    _loadOrderHistory(); // Load order history on startup
    _loadShopOwners(); // Load shop owners for chat search
  }

  Future<void> _loadProductsFromDatabase() async {
    setState(() {
      isLoadingProducts = true;
    });

    try {
      final fetchedCategories = await fetchCategories();
      final fetchedPriceList = await fetchPriceList();

      setState(() {
        categories = fetchedCategories;
        priceList = fetchedPriceList;

        // Extract unique product names (subcategory names) from price list
        final productNames = priceList
            .map((item) => item['subcat_name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList();

        products = ["All Products", ...productNames];
        isLoadingProducts = false;
      });
    } catch (e) {
      debugPrint('Error loading products: $e');
      setState(() {
        isLoadingProducts = false;
      });
    }
  }

  Future<void> _loadInventory() async {
    setState(() {
      isLoadingInventory = true;
      inventoryError = null;
    });

    try {
      final result = await WholesalerApiService.getInventory();

      if (result['success']) {
        setState(() {
          inventoryItems =
              List<Map<String, dynamic>>.from(result['data'] ?? []);
          isLoadingInventory = false;
        });
      } else {
        setState(() {
          inventoryError = result['message'] ?? 'Failed to load inventory';
          isLoadingInventory = false;
        });

        // Handle token expiration or authentication errors
        if (result['requiresLogin'] == true) {
          _handleAuthError();
        }
      }
    } catch (e) {
      setState(() {
        inventoryError = 'Error loading inventory: $e';
        isLoadingInventory = false;
      });
    }
  }

  Future<void> _loadOffers() async {
    setState(() {
      isLoadingOffers = true;
      offersError = null;
    });

    try {
      final result = await WholesalerApiService.getOffers();

      if (result['success']) {
        setState(() {
          offers = List<Map<String, dynamic>>.from(result['data'] ?? []);
          isLoadingOffers = false;
        });
      } else {
        setState(() {
          offersError = result['message'] ?? 'Failed to load offers';
          isLoadingOffers = false;
        });

        // Handle token expiration or authentication errors
        if (result['requiresLogin'] == true) {
          _handleAuthError();
        }
      }
    } catch (e) {
      setState(() {
        offersError = 'Error loading offers: $e';
        isLoadingOffers = false;
      });
    }
  }

  Future<void> _loadOrderHistory() async {
    print('🔄 Loading order history...');
    setState(() {
      isLoadingHistory = true;
      historyError = null;
    });

    try {
      final result = await WholesalerApiService.getShopOrders();
      print('📦 Order history API result: $result');

      if (result['success']) {
        final orders = List<Map<String, dynamic>>.from(result['data'] ?? []);
        print('✅ Successfully loaded ${orders.length} orders');
        setState(() {
          orderHistory = orders;
          isLoadingHistory = false;
        });
      } else {
        print('❌ Failed to load orders: ${result['message']}');
        setState(() {
          historyError = result['message'] ?? 'Failed to load order history';
          isLoadingHistory = false;
        });

        // Handle token expiration or authentication errors
        if (result['requiresLogin'] == true) {
          _handleAuthError();
        }
      }
    } catch (e) {
      print('💥 Exception loading order history: $e');
      setState(() {
        historyError = 'Error loading order history: $e';
        isLoadingHistory = false;
      });
    }
  }

  Future<void> _navigateToAddOrder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddOrderScreen()),
    );

    // If order was created successfully, reload the order history
    if (result == true) {
      await _loadOrderHistory();
    }
  }

  Future<void> _loadLowStockProducts() async {
    setState(() {
      isLoadingLowStock = true;
      lowStockError = null;
    });

    try {
      final result = await WholesalerApiService.getLowStockProducts(
        productFilter:
            selectedProduct != "All Products" ? selectedProduct : null,
        locationFilter:
            selectedLocation != "All Areas" ? selectedLocation : null,
      );

      if (result['success']) {
        setState(() {
          lowStockProductsList =
              List<Map<String, dynamic>>.from(result['data'] ?? []);
          isLoadingLowStock = false;
        });
      } else {
        setState(() {
          lowStockError =
              result['message'] ?? 'Failed to load low stock products';
          isLoadingLowStock = false;
        });

        // Handle token expiration or authentication errors
        if (result['requiresLogin'] == true) {
          _handleAuthError();
        }
      }
    } catch (e) {
      setState(() {
        lowStockError = 'Error loading low stock products: $e';
        isLoadingLowStock = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      // Fetch categories from the API
      final categories = await fetchCategories();
      setState(() {
        categoryList = categories;
      });
    } catch (error) {
      setState(() {
        categoriesError = 'Failed to load categories: $error';
      });
      print('Error loading categories: $error');
    }
  }

  Future<void> _loadShopOwners() async {
    setState(() {
      isLoadingShopOwners = true;
      shopOwnersError = null;
    });

    try {
      final result = await WholesalerApiService.getShopOwners();
      if (result['success'] == true) {
        setState(() {
          shopOwners = List<Map<String, dynamic>>.from(result['data'] ?? []);
          filteredShopOwners = shopOwners;
          isLoadingShopOwners = false;
        });
      } else {
        setState(() {
          shopOwnersError = result['message'] ?? 'Failed to load shop owners';
          isLoadingShopOwners = false;
        });
      }
    } catch (e) {
      setState(() {
        shopOwnersError = 'Error loading shop owners: $e';
        isLoadingShopOwners = false;
      });
      print('Error loading shop owners: $e');
    }
  }

  void _filterShopOwners(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredShopOwners = shopOwners;
        showSearchDropdown = false;
      } else {
        filteredShopOwners = shopOwners.where((shopOwner) {
          final name = shopOwner['shop_name']?.toString().toLowerCase() ?? '';
          final fullName = shopOwner['full_name']?.toString().toLowerCase() ?? '';
          final phone = shopOwner['phone']?.toString().toLowerCase() ?? '';
          final location = shopOwner['location']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          
          return name.contains(searchQuery) ||
                 fullName.contains(searchQuery) ||
                 phone.contains(searchQuery) ||
                 location.contains(searchQuery);
        }).toList();
        showSearchDropdown = filteredShopOwners.isNotEmpty && query.isNotEmpty;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const CustomDrawer(
        userName: "Wholesaler Name",
        userEmail: "wholesaler@example.com",
        userRole: "Wholesaler",
      ),
      appBar: AppBar(
        title: const Text(
          "Wholesaler Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  _showNotifications(context);
                },
              ),
              if (unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$unreadNotifications',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              _showProfileSettings(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmation(context);
            },
            tooltip: "Logout",
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Cards in One Row
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    debugPrint("Tapped Total Shops");
                  },
                  child: _buildSummaryCard(
                    "Total Shops",
                    "$totalShops",
                    Icons.store,
                    Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    debugPrint("Tapped New Requests");
                  },
                  child: _buildSummaryCard(
                    "New Requests",
                    "$newRequests",
                    Icons.shopping_cart,
                    Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    debugPrint("Tapped Low Stock");
                  },
                  child: _buildSummaryCard(
                    "Shops Low Stock",
                    "$lowStockProducts",
                    Icons.warning,
                    Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    debugPrint("Tapped Supply Status");
                  },
                  child: _buildSummaryCard(
                    "Supply Status",
                    supplyStatus,
                    Icons.local_shipping,
                    Colors.green,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Reviews Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Shop Reviews & Ratings",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Manage customer feedback and ratings",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShopReviewsScreen(
                            shopId:
                                'wholesaler_shop_id', // Replace with actual shop ID
                            shopName:
                                'Your Wholesale Shop', // Replace with actual shop name
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.rate_review, size: 18),
                    label: const Text("View Reviews"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Tab Content
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMonitorTab(),
                _buildInventoryTab(),
                _buildChatTab(),
                _buildHistoryTab(),
                _buildOffersTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Material(
        color: Colors.white,
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 5,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            labelColor: Colors.green[600],
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green[600],
            tabs: const [
              Tab(icon: Icon(Icons.monitor), text: "Monitor"),
              Tab(icon: Icon(Icons.inventory), text: "Inventory"),
              Tab(icon: Icon(Icons.chat), text: "Chat"),
              Tab(icon: Icon(Icons.history), text: "History"),
              Tab(icon: Icon(Icons.campaign), text: "Offers"),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showQuickActions(context);
        },
        backgroundColor: Colors.green[600],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Quick Add",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Summary Card Builder - Matches Shop Owner Dashboard Style
  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      height: 90, // Fixed height for equal sizing
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              if (title.contains("Low") || title.contains("Requests"))
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "!",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Monitor Tab - Low Stock Monitor with Filters
  Widget _buildMonitorTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Section - Accordion Style
          Card(
            elevation: 2,
            child: ExpansionTile(
              initiallyExpanded: false,
              leading:
                  Icon(Icons.filter_list, color: Colors.green[800], size: 20),
              title: const Text(
                "🏪 Shop Stock Monitor - Track Low Stock Shops",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Product Dropdown (Full Width)
                      DropdownButtonFormField<String>(
                        value: selectedProduct,
                        decoration: InputDecoration(
                          labelText: "Product",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        items: products
                            .map((product) => DropdownMenuItem(
                                  value: product,
                                  child: Text(
                                    product,
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProduct = value!;
                          });
                          // Reload low stock products with new filter
                          _loadLowStockProducts();
                        },
                      ),
                      const SizedBox(height: 12),

                      // Location Dropdown (Full Width)
                      DropdownButtonFormField<String>(
                        value: selectedLocation,
                        decoration: InputDecoration(
                          labelText: "Location",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        items: locations
                            .map((location) => DropdownMenuItem(
                                  value: location,
                                  child: Text(
                                    location,
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedLocation = value!;
                          });
                          // Reload low stock products with new filter
                          _loadLowStockProducts();
                        },
                      ),
                      const SizedBox(height: 12),

                      // Threshold Input and Filter Button
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: quantityThreshold.toString(),
                              decoration: InputDecoration(
                                labelText: "Threshold (units)",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              style: const TextStyle(fontSize: 14),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  quantityThreshold = int.tryParse(value) ?? 10;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 48,
                            width: 48,
                            child: IconButton(
                              onPressed: () => _applyFilters(),
                              icon: const Icon(Icons.search,
                                  color: Colors.white, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.green[800],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
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
          const SizedBox(height: 12),

          // Results List
          Expanded(
            child: isLoadingLowStock
                ? const Center(child: CircularProgressIndicator())
                : lowStockError != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red[400]),
                            const SizedBox(height: 16),
                            Text(lowStockError!,
                                style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadLowStockProducts,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : lowStockProductsList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text('No shops with low stock found',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 16)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: lowStockProductsList.length,
                            itemBuilder: (context, index) {
                              return _buildLowStockItem(index);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockItem(int index) {
    // Use real product data from the API
    final productData = lowStockProductsList[index];

    // Extract data from the API response
    final shopName = productData['shop_name'] ?? 'Unknown Shop';
    final shopLocation = productData['shop_location'] ?? 'Unknown Location';
    final productName = productData['product_name'] ?? 'Unknown Product';
    final quantity = productData['stock_quantity'] ?? 0;
    final minThreshold = productData['min_stock_threshold'] ?? 0;

    // Consider it urgent if stock is below half the minimum threshold
    final isUrgent = quantity <= (minThreshold / 2);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isUrgent ? Colors.red[50] : Colors.white,
      elevation: isUrgent ? 3 : 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isUrgent ? Colors.red[100] : Colors.green[100],
          child: Icon(
            Icons.store,
            color: isUrgent ? Colors.red[700] : Colors.green[700],
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                shopName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (isUrgent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "URGENT",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    shopLocation,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.inventory,
                  size: 14,
                  color: isUrgent ? Colors.red[700] : Colors.orange[700],
                ),
                const SizedBox(width: 4),
                Text(
                  "$quantity units",
                  style: TextStyle(
                    color: isUrgent ? Colors.red[700] : Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.blue[600],
            borderRadius: BorderRadius.circular(6),
          ),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WholesalerChatScreen(
                  contactId: shopName.toLowerCase().replaceAll(' ', '_'),
                  contactType: 'shop_owner',
                  contactName: shopName,
                ),
              ),
            ),
            onLongPress: () => _contactShop(shopName),
            child: Container(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              child: const Icon(Icons.chat, color: Colors.white, size: 16),
            ),
          ),
        ),
      ),
    );
  }

  // Inventory Tab
  Widget _buildInventoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const WholesalerAddProductScreen(),
                      ),
                    ).then((_) {
                      // Refresh inventory when returning from add product screen
                      _loadInventory();
                    });
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Add Product",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoadingInventory ? null : _loadInventory,
                  icon: isLoadingInventory
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.refresh, color: Colors.white),
                  label: Text(
                    isLoadingInventory ? "Loading..." : "Refresh",
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _uploadCatalog(),
                  icon: const Icon(Icons.upload, color: Colors.white),
                  label: const Text("Upload",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildInventoryContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryContent() {
    if (isLoadingInventory) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading inventory..."),
          ],
        ),
      );
    }

    if (inventoryError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              inventoryError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInventory,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (inventoryItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No products in inventory",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add your first product to get started",
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WholesalerAddProductScreen(),
                  ),
                ).then((_) {
                  _loadInventory();
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Product"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: inventoryItems.length,
      itemBuilder: (context, index) {
        return _buildInventoryItemFromApi(inventoryItems[index]);
      },
    );
  }

  Widget _buildInventoryItemFromApi(Map<String, dynamic> item) {
    final productName = item['subcat_name']?.toString() ?? 'Unknown Product';
    final categoryName = item['cat_name']?.toString() ?? '';
    final stockQuantity = item['stock_quantity'] ?? 0;
    final unitPrice = item['unit_price'] ?? 0.0;
    final lowStockThreshold = item['low_stock_threshold'] ?? 10;
    final updatedAt = item['updated_at']?.toString() ?? '';

    final isLowStock = stockQuantity < lowStockThreshold;
    final displayPrice = unitPrice is String
        ? double.tryParse(unitPrice) ?? 0.0
        : unitPrice.toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLowStock ? Colors.red[100] : Colors.green[100],
          child: Icon(
            isLowStock ? Icons.warning : Icons.inventory_2,
            color: isLowStock ? Colors.red[700] : Colors.green[700],
          ),
        ),
        title: Text(
          productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (categoryName.isNotEmpty)
              Text(
                "Category: $categoryName",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            Text("Price: ৳${displayPrice.toStringAsFixed(2)}/unit"),
            Text(
              "Stock: $stockQuantity units",
              style: TextStyle(
                color: isLowStock ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isLowStock)
              Text(
                "⚠️ Low stock! (Threshold: $lowStockThreshold)",
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (updatedAt.isNotEmpty)
              Text(
                "Updated: ${_formatDate(updatedAt)}",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: "edit", child: Text("Edit")),
            const PopupMenuItem(
                value: "history", child: Text("Supply History")),
            const PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
          onSelected: (value) {
            _handleInventoryAction(value, productName, item);
          },
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildChatTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Shop Owners Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.search, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Search & Chat with Shop Owners",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Search Box with Dropdown
                Stack(
                  children: [
                    TextField(
                      controller: _chatSearchController,
                      decoration: InputDecoration(
                        hintText: "Search shop owners by name, phone, or location...",
                        prefixIcon: Icon(Icons.search, color: Colors.green[600]),
                        suffixIcon: _chatSearchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _chatSearchController.clear();
                                  _filterShopOwners('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.green[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: _filterShopOwners,
                    ),
                    
                    // Dropdown suggestions
                    if (showSearchDropdown)
                      Positioned(
                        top: 60,
                        left: 0,
                        right: 0,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredShopOwners.length,
                              itemBuilder: (context, index) {
                                final shopOwner = filteredShopOwners[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green[100],
                                    child: Text(
                                      (shopOwner['shop_name']?.toString() ?? 'S')[0].toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.green[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    shopOwner['shop_name']?.toString() ?? 'Unknown Shop',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (shopOwner['phone'] != null)
                                        Text('📞 ${shopOwner['phone']}'),
                                      if (shopOwner['location'] != null)
                                        Text('📍 ${shopOwner['location']}'),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.chat,
                                    color: Colors.green[600],
                                  ),
                                  onTap: () {
                                    _chatSearchController.clear();
                                    setState(() {
                                      showSearchDropdown = false;
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WholesalerChatScreen(
                                          contactId: shopOwner['id']?.toString() ?? '',
                                          contactType: 'shop_owner',
                                          contactName: shopOwner['shop_name']?.toString() ?? 'Unknown Shop',
                                          contactPhone: shopOwner['phone']?.toString(),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShopOwnerSearchScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text("Advanced Search"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          Text(
            "Recent Conversations",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) {
                return _buildChatItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(int index) {
    final chats = [
      {
        "shop": "আহমেদ স্টোর",
        "message": "চাল সরু (নাজির/মিনিকেট) এর দাম কত?",
        "time": "২ মিনিট আগে",
        "unread": 2,
      },
      {
        "shop": "করিম ট্রেডার্স",
        "message": "সয়াবিন তেল (বোতল) এর স্টক আছে?",
        "time": "১৫ মিনিট আগে",
        "unread": 0,
      },
      {
        "shop": "রহিম মার্ট",
        "message": "অর্ডার কনফার্ম",
        "time": "৩০ মিনিট আগে",
        "unread": 1,
      },
      {
        "shop": "ফাতিমা স্টোর",
        "message": "ডেলিভারি কবে?",
        "time": "১ ঘণ্টা আগে",
        "unread": 3,
      },
      {
        "shop": "নাসির এন্টারপ্রাইজ",
        "message": "নতুন দামের তালিকা চাই",
        "time": "২ ঘণ্টা আগে",
        "unread": 0,
      },
      {
        "shop": "সালমা ট্রেডিং",
        "message": "বাল্ক অর্ডার দিতে চাই",
        "time": "৩ ঘণ্টা আগে",
        "unread": 1,
      },
    ];

    final chat = chats[index];
    final unreadCount = chat["unread"] as int;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Text(
            (chat["shop"] as String)[0],
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                chat["shop"] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$unreadCount",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chat["message"] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              chat["time"] as String,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.chat, color: Colors.green[800]),
          onPressed: () => _openChatWithShop(chat["shop"] as String),
          tooltip: "Open Chat",
        ),
      ),
    );
  }

  // History Tab (previously Supply Tab)
  Widget _buildHistoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportPDF(),
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: const Text("Export PDF",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToAddOrder(),
                  icon:
                      const Icon(Icons.add_shopping_cart, color: Colors.white),
                  label: const Text("Add Order",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : historyError != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red[400]),
                            const SizedBox(height: 16),
                            Text(historyError!,
                                style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadOrderHistory,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : orderHistory.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text('No order history found',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 16)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: orderHistory.length,
                            itemBuilder: (context, index) {
                              return _buildHistoryItem(index);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(int index) {
    final order = orderHistory[index];
    final status = order["status"] as String? ?? "unknown";

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case "delivered":
      case "completed":
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case "pending":
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case "processing":
      case "in_progress":
        statusColor = Colors.blue;
        statusIcon = Icons.sync;
        break;
      case "cancelled":
      case "canceled":
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    // Format date
    String formattedDate = order["created_at"] as String? ??
        order["order_date"] as String? ??
        order["date"] as String? ??
        "N/A";

    // Try to format the date if it's in ISO format
    try {
      if (formattedDate.contains('T')) {
        final dateTime = DateTime.parse(formattedDate);
        formattedDate = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
      }
    } catch (e) {
      // Keep original format if parsing fails
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(
            statusIcon,
            color: statusColor,
          ),
        ),
        title: Text(
          order["shop_name"] as String? ??
              order["full_name"] as String? ??
              "Unknown Shop",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "${order["subcat_name"] as String? ?? "Unknown Product"} - ${order["quantity_requested"] ?? order["quantity"] ?? 0} ${order["unit"] ?? ""}"),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (order["total_amount"] != null) ...[
                  Row(
                    children: [
                      Icon(Icons.monetization_on,
                          size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        "৳${order["total_amount"]}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                GestureDetector(
                  onTap: () => _changeTransactionStatus(order, index),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: statusColor.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 9,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.receipt),
          onPressed: () => _viewReceipt(order),
          tooltip: "View Receipt",
        ),
      ),
    );
  }

  Widget _buildOffersTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _createOffer(),
                  icon: const Icon(Icons.campaign, color: Colors.white),
                  label: const Text("Create Offer",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _broadcastToAll(),
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text("Broadcast All",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildOffersContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersContent() {
    if (isLoadingOffers) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (offersError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading offers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              offersError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOffers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No offers yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first offer to attract more customers',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _createOffer(),
              icon: const Icon(Icons.add),
              label: const Text('Create Offer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOffers,
      child: ListView.builder(
        itemCount: offers.length,
        itemBuilder: (context, index) {
          return _buildOfferItem(offers[index]);
        },
      ),
    );
  }

  Widget _buildOfferItem(Map<String, dynamic> offer) {
    final isActive = offer['is_active'] ?? false;
    final title = offer['title'] ?? '';
    final description = offer['description'] ?? '';
    final validUntil = offer['valid_until'] != null
        ? DateTime.parse(offer['valid_until']).isAfter(DateTime.now())
            ? 'Valid until ${DateTime.parse(offer['valid_until']).day}/${DateTime.parse(offer['valid_until']).month}'
            : 'Expired'
        : 'No expiry';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isActive ? Colors.white : Colors.grey[100],
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.yellow[100] : Colors.grey[200],
          child: Icon(
            Icons.local_offer,
            color: isActive ? Colors.yellow[700] : Colors.grey,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black : Colors.grey[600],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(
                color: isActive ? Colors.black87 : Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.cancel,
                  size: 14,
                  color: isActive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  validUntil,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(value: "edit", child: Text("Edit")),
            const PopupMenuItem(value: "duplicate", child: Text("Duplicate")),
            if (isActive)
              const PopupMenuItem(
                  value: "deactivate", child: Text("Deactivate"))
            else
              const PopupMenuItem(value: "activate", child: Text("Activate")),
            const PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
          onSelected: (value) {
            _handleOfferAction(value, offer);
          },
        ),
      ),
    );
  }

  // Notification Methods
  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Notifications"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title: const Text("New Order Request"),
                subtitle: const Text("Rahman Store needs 50kg rice"),
                trailing: const Text("2 min"),
              ),
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: const Text("Low Stock Alert"),
                subtitle: const Text("Oil running low in 3 shops"),
                trailing: const Text("5 min"),
              ),
              ListTile(
                leading: const Icon(Icons.message, color: Colors.green),
                title: const Text("New Message"),
                subtitle: const Text("Ahmed Store: Thanks for delivery"),
                trailing: const Text("10 min"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showProfileSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Profile Settings"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Edit Profile"),
              onTap: () {
                Navigator.pop(context);
                // Navigate to profile edit screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("App Settings"),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Help & Support"),
              onTap: () {
                Navigator.pop(context);
                // Navigate to help screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Handle authentication errors (token expired, invalid, etc.)
  void _handleAuthError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Session Expired"),
        content: const Text("Your session has expired. Please login again."),
        actions: [
          TextButton(
            onPressed: () async {
              // Clear any stored token
              await logout();

              // Navigate to welcome screen
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const WelcomeScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("Login Again"),
          ),
        ],
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const WholesalerAddProductScreen(),
                        ),
                      ).then((_) {
                        // Refresh inventory after adding product
                        _loadInventory();
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Product"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _createOffer();
                    },
                    icon: const Icon(Icons.local_offer),
                    label: const Text("Create Offer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showBulkActions();
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Bulk Update"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _tabController.animateTo(0); // Go to Monitor tab
                    },
                    icon: const Icon(Icons.monitor_heart),
                    label: const Text("Monitor"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Inventory Management Methods
  void _uploadCatalog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Upload Product Catalog"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                "Upload an Excel or CSV file with your product catalog."),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                  Text("Click to select file or drag and drop"),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Supported formats: .xlsx, .xls, .csv",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Catalog upload started!")),
              );
            },
            child: const Text("Upload"),
          ),
        ],
      ),
    );
  }

  void _handleInventoryAction(String action, String productName,
      [Map<String, dynamic>? item]) {
    switch (action) {
      case "edit":
        _editProduct(productName, item);
        break;
      case "history":
        _viewSupplyHistory(productName);
        break;
      case "delete":
        _deleteProduct(productName);
        break;
    }
  }

  void _editProduct(String productName, [Map<String, dynamic>? item]) {
    // Create controllers and initialize with current values if item is provided
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final thresholdController = TextEditingController();

    if (item != null) {
      final currentPrice = item['unit_price'] ?? 0.0;
      final displayPrice = currentPrice is String
          ? double.tryParse(currentPrice) ?? 0.0
          : currentPrice.toDouble();
      priceController.text = displayPrice.toStringAsFixed(2);
      stockController.text = (item['stock_quantity'] ?? 0).toString();
      thresholdController.text = (item['low_stock_threshold'] ?? 10).toString();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $productName"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: "Price per Unit",
                  prefixText: "৳",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: stockController,
                decoration: const InputDecoration(
                  labelText: "Current Stock",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: thresholdController,
                decoration: const InputDecoration(
                  labelText: "Low Stock Threshold",
                  border: OutlineInputBorder(),
                  helperText: "Alert when stock falls below this number",
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              priceController.dispose();
              stockController.dispose();
              thresholdController.dispose();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              // Validate inputs
              if (priceController.text.trim().isEmpty ||
                  stockController.text.trim().isEmpty ||
                  thresholdController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields")),
                );
                return;
              }

              final newPrice = double.tryParse(priceController.text.trim());
              final newStock = int.tryParse(stockController.text.trim());
              final newThreshold =
                  int.tryParse(thresholdController.text.trim());

              if (newPrice == null || newPrice <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid price")),
                );
                return;
              }

              if (newStock == null || newStock < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Please enter a valid stock quantity")),
                );
                return;
              }

              if (newThreshold == null || newThreshold < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Please enter a valid threshold")),
                );
                return;
              }

              if (item == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Error: Product data not available")),
                );
                return;
              }

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text("Updating product..."),
                    ],
                  ),
                ),
              );

              try {
                final result = await WholesalerApiService.updateInventoryItem(
                  inventoryId: item['id'].toString(),
                  stockQuantity: newStock,
                  unitPrice: newPrice,
                  lowStockThreshold: newThreshold,
                );

                // Close loading dialog
                if (mounted) {
                  Navigator.pop(context);
                }

                if (result['success'] == true) {
                  // Close edit dialog
                  priceController.dispose();
                  stockController.dispose();
                  thresholdController.dispose();
                  if (mounted) {
                    Navigator.pop(context);
                  }

                  // Refresh inventory to show updated data
                  await _loadInventory();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("$productName updated successfully!")),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            result['message'] ?? 'Failed to update product'),
                        backgroundColor: Colors.red,
                      ),
                    );

                    // Handle authentication errors
                    if (result['requiresLogin'] == true) {
                      _handleAuthError();
                    }
                  }
                }
              } catch (e) {
                // Close loading dialog
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating product: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _viewSupplyHistory(String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Supply History - $productName"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              final dates = [
                "2024-01-15",
                "2024-01-10",
                "2024-01-05",
                "2023-12-28",
                "2023-12-20"
              ];
              final quantities = [100, 150, 200, 80, 120];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text("${quantities[index]} kg supplied"),
                subtitle: Text("Date: ${dates[index]}"),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete $productName"),
        content: Text(
            "Are you sure you want to delete $productName from your inventory?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$productName deleted from inventory")),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _exportPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Exporting to PDF...")),
    );
  }

  void _viewReceipt(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: _buildReceiptWidget(transaction),
      ),
    );
  }

  void _changeTransactionStatus(
      Map<String, dynamic> transaction, int index) async {
    // Navigate to the status update screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderStatusUpdateScreen(transaction: transaction),
      ),
    );

    // If status was updated successfully, reload the order history
    if (result == true) {
      await _loadOrderHistory();
    }
  }

  Widget _buildReceiptWidget(Map<String, dynamic> transaction) {
    final receiptNumber =
        "R${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    final currentDate = DateTime.now();
    final formattedDate =
        "${currentDate.day}/${currentDate.month}/${currentDate.year}";
    final formattedTime =
        "${currentDate.hour}:${currentDate.minute.toString().padLeft(2, '0')}";

    // Get values with fallbacks
    final shopName = transaction["shop_name"] as String? ??
        transaction["full_name"] as String? ??
        "Unknown Shop";
    final productName =
        transaction["subcat_name"] as String? ?? "Unknown Product";
    final status = transaction["status"] as String? ?? "pending";

    // Sample pricing calculation
    final unitPrice = _getUnitPrice(productName);
    final quantity = transaction["quantity"] as num? ?? 0;
    final subtotal = unitPrice * quantity;
    final tax = subtotal * 0.05; // 5% tax
    final total = subtotal + tax;

    return Container(
      width: 350,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[800],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.receipt, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  "TRANSACTION RECEIPT",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Receipt Body
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Receipt Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Receipt #: $receiptNumber",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("Date: $formattedDate"),
                        Text("Time: $formattedTime"),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),

                // Shop Details
                _buildReceiptRow("Shop Name:", shopName, isTitle: true),
                _buildReceiptRow("Location:", _getShopLocation(shopName)),
                _buildReceiptRow("Contact:",
                    transaction["phone"] as String? ?? "+880 1712-345678"),

                const SizedBox(height: 12),
                const Divider(),

                // Product Details
                const Text(
                  "Product Details:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildReceiptRow("Product:", productName),
                _buildReceiptRow("Quantity:",
                    "${transaction["quantity"] ?? 0} ${transaction["unit"] ?? ""}"),
                _buildReceiptRow(
                    "Unit Price:", "৳${unitPrice.toStringAsFixed(2)}"),

                const SizedBox(height: 12),
                const Divider(),

                // Pricing
                _buildReceiptRow(
                    "Subtotal:", "৳${subtotal.toStringAsFixed(2)}"),
                _buildReceiptRow("Tax (5%):", "৳${tax.toStringAsFixed(2)}"),
                const Divider(thickness: 2),
                _buildReceiptRow(
                    "Total Amount:", "৳${total.toStringAsFixed(2)}",
                    isTotal: true),

                const SizedBox(height: 16),

                // Footer
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        "Thank you for your business!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "NityMulya Wholesale Platform",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text("Close"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _printReceipt(transaction, receiptNumber),
                  icon: const Icon(Icons.print, color: Colors.white),
                  label: const Text("Print",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value,
      {bool isTitle = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight:
                  isTitle || isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight:
                  isTitle || isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.green[800] : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  double _getUnitPrice(String product) {
    // Get price from the actual database data if available
    if (priceList.isNotEmpty) {
      for (final item in priceList) {
        if (item['subcat_name'] == product) {
          final minPrice =
              double.tryParse(item['min_price']?.toString() ?? '0') ?? 0.0;
          final maxPrice =
              double.tryParse(item['max_price']?.toString() ?? '0') ?? 0.0;
          // Return average price between min and max
          return (minPrice + maxPrice) / 2;
        }
      }
    }

    // Fallback prices based on actual database product names
    final prices = {
      "চাল সরু (নাজির/মিনিকেট)": 80.0,
      "সয়াবিন তেল (বোতল)": 187.5,
      "সয়াবিন তেল (লুজ)": 167.0,
      "মশুর ডাল (বড় দানা)": 102.5,
      "মশুর ডাল (মাঝারী দানা)": 122.5,
      "পিঁয়াজ (দেশী)": 80.0,
      "চিনি": 110.0,
      "আটা সাদা (খোলা)": 42.5,
      "ছোলা (মানভেদে)": 100.0,
      "চাল (মোটা)/স্বর্ণা/চায়না ইরি": 57.5,
    };
    return prices[product] ?? 100.0;
  }

  String _getShopLocation(String shopName) {
    final locations = {
      "আহমেদ স্টোর": "ধানমন্ডি, ঢাকা",
      "করিম ট্রেডার্স": "চট্টগ্রাম",
      "রহিম মার্ট": "সিলেট",
      "ফাতিমা স্টোর": "রাজশাহী",
      "নাসির এন্টারপ্রাইজ": "খুলনা",
      "সালমা ট্রেডিং": "বরিশাল",
      "আব্দুল মার্ট": "ঢাকা",
      "রশিদ স্টোর": "চট্টগ্রাম",
      "হাসান ট্রেডার্স": "সিলেট",
      "কবির স্টোর": "রাজশাহী",
    };
    return locations[shopName] ?? "ঢাকা, বাংলাদেশ";
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "delivered":
      case "completed":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "processing":
      case "in_progress":
        return Colors.blue;
      case "cancelled":
      case "canceled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _printReceipt(Map<String, dynamic> transaction, String receiptNumber) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Receipt $receiptNumber sent to printer"),
        backgroundColor: Colors.green[800],
      ),
    );
  }

  void _broadcastToAll() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Broadcasting to all shops...")),
    );
  }

  void _handleOfferAction(String action, Map<String, dynamic> offer) {
    switch (action) {
      case 'edit':
        _editOffer(offer);
        break;
      case 'duplicate':
        _duplicateOffer(offer);
        break;
      case 'activate':
        _toggleOfferStatus(offer, true);
        break;
      case 'deactivate':
        _toggleOfferStatus(offer, false);
        break;
      case 'delete':
        _deleteOffer(offer);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$action: ${offer['title']} - Coming Soon!")),
        );
    }
  }

  void _editOffer(Map<String, dynamic> offer) {
    _showOfferDialog(offer: offer);
  }

  void _duplicateOffer(Map<String, dynamic> offer) {
    final duplicatedOffer = Map<String, dynamic>.from(offer);
    duplicatedOffer['title'] = '${offer['title']} (Copy)';
    duplicatedOffer.remove('id'); // Remove ID so it creates a new offer
    _showOfferDialog(offer: duplicatedOffer);
  }

  void _toggleOfferStatus(Map<String, dynamic> offer, bool isActive) async {
    try {
      final result = await WholesalerApiService.updateOffer(
        offerId: offer['id'].toString(),
        title: offer['title'],
        description: offer['description'],
        discountPercentage: offer['discount_percentage']?.toDouble(),
        minimumQuantity: offer['minimum_quantity'],
        validUntil: offer['valid_until'],
        isActive: isActive,
      );

      if (result['success']) {
        await _loadOffers(); // Reload offers
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Offer ${isActive ? 'activated' : 'deactivated'} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update offer: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating offer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteOffer(Map<String, dynamic> offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Offer'),
        content: Text(
            'Are you sure you want to delete "${offer['title']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performDeleteOffer(offer['id'].toString());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteOffer(String offerId) async {
    try {
      final result = await WholesalerApiService.deleteOffer(offerId: offerId);

      if (result['success']) {
        await _loadOffers(); // Reload offers
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offer deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete offer: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting offer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openChatWithShop(String shopName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WholesalerChatScreen(
          contactId: shopName.toLowerCase().replaceAll(' ', '_'),
          contactType: 'shop_owner',
          contactName: shopName,
        ),
      ),
    );
  }

  // Communication Methods
  void _contactShop(String shopName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Contact $shopName"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text("Call Shop"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Calling $shopName...")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text("Send Message"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WholesalerChatScreen(
                      contactId: shopName.toLowerCase().replaceAll(' ', '_'),
                      contactType: 'shop_owner',
                      contactName: shopName,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // Offer Management Methods
  void _createOffer() {
    _showOfferDialog();
  }

  void _showOfferDialog({Map<String, dynamic>? offer}) {
    final isEditing = offer != null;
    final titleController = TextEditingController(text: offer?['title'] ?? '');
    final descriptionController =
        TextEditingController(text: offer?['description'] ?? '');
    final discountController = TextEditingController(
        text: offer?['discount_percentage']?.toString() ?? '');
    final minimumQuantityController = TextEditingController(
        text: offer?['minimum_quantity']?.toString() ?? '');
    final termsController =
        TextEditingController(text: offer?['terms_conditions'] ?? '');

    DateTime? validUntil = offer?['valid_until'] != null
        ? DateTime.tryParse(offer!['valid_until'])
        : null;

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Offer' : 'Create New Offer'),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Offer Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter offer title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter offer description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: discountController,
                            decoration: const InputDecoration(
                              labelText: 'Discount %',
                              suffixText: '%',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.percent),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              final percent = double.tryParse(value);
                              if (percent == null ||
                                  percent < 0 ||
                                  percent > 100) {
                                return 'Enter 0-100';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: minimumQuantityController,
                            decoration: const InputDecoration(
                              labelText: 'Min Quantity',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.shopping_cart),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.trim().isNotEmpty) {
                                final qty = int.tryParse(value);
                                if (qty == null || qty < 1) {
                                  return 'Enter valid quantity';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: validUntil ??
                              DateTime.now().add(const Duration(days: 7)),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            validUntil = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                validUntil != null
                                    ? 'Valid until: ${validUntil!.day}/${validUntil!.month}/${validUntil!.year}'
                                    : 'Select valid until date',
                                style: TextStyle(
                                  color: validUntil != null
                                      ? Colors.black
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: termsController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Terms & Conditions (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.rule),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();

                  final offerData = {
                    'title': titleController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'discount_percentage':
                        double.tryParse(discountController.text) ?? 0,
                    'minimum_quantity':
                        minimumQuantityController.text.trim().isNotEmpty
                            ? int.tryParse(minimumQuantityController.text)
                            : null,
                    'valid_until': validUntil?.toIso8601String(),
                    'terms_conditions': termsController.text.trim().isNotEmpty
                        ? termsController.text.trim()
                        : null,
                  };

                  if (isEditing) {
                    await _updateOffer(offer['id'].toString(), offerData);
                  } else {
                    await _createNewOffer(offerData);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createNewOffer(Map<String, dynamic> offerData) async {
    try {
      final result = await WholesalerApiService.createOffer(
        title: offerData['title'],
        description: offerData['description'],
        discountPercentage: offerData['discount_percentage'],
        minimumQuantity: offerData['minimum_quantity'],
        validUntil: offerData['valid_until'],
      );

      if (result['success']) {
        await _loadOffers(); // Reload offers
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offer created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create offer: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating offer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateOffer(
      String offerId, Map<String, dynamic> offerData) async {
    try {
      final result = await WholesalerApiService.updateOffer(
        offerId: offerId,
        title: offerData['title'],
        description: offerData['description'],
        discountPercentage: offerData['discount_percentage'],
        minimumQuantity: offerData['minimum_quantity'],
        validUntil: offerData['valid_until'],
      );

      if (result['success']) {
        await _loadOffers(); // Reload offers
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offer updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update offer: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating offer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBulkActions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Bulk Actions"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Bulk Price Update"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text("Bulk Discount"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // Filter and Offer Methods
  void _applyFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Filtering: $selectedProduct in $selectedLocation with < $quantityThreshold units",
        ),
        backgroundColor: Colors.green[800],
      ),
    );
  }
}
