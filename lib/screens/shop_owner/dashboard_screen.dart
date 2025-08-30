import 'package:flutter/material.dart';
import 'package:nitymulya/models/location_models.dart';
import 'package:nitymulya/network/shop_owner_api.dart';
import 'package:nitymulya/screens/shop_owner/add_product_screen.dart';
import 'package:nitymulya/screens/shop_owner/update_product_screen.dart';
import 'package:nitymulya/screens/shop_owner/wholesaler_chat_screen.dart';
import 'package:nitymulya/screens/shop_owner/wholesaler_list_screen.dart';
import 'package:nitymulya/screens/shop_owner/wholesaler_search_screen.dart';
import 'package:nitymulya/utils/user_session.dart';
import 'package:nitymulya/widgets/custom_drawer.dart';

class ShopOwnerDashboard extends StatefulWidget {
  const ShopOwnerDashboard({super.key});

  @override
  State<ShopOwnerDashboard> createState() => _ShopOwnerDashboardState();
}

class _ShopOwnerDashboardState extends State<ShopOwnerDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int unreadNotifications = 3;
  int pendingOrders = 5;
  int totalProducts = 25;
  int stockAlerts = 3;
  String vatRewardStatus = "Eligible";

  // Shop owner data state
  ShopOwner? currentShopOwner;
  String shopOwnerName = "Shop Owner";
  String shopOwnerEmail = "owner@example.com";
  bool isLoadingShopOwner = false;

  // Inventory state
  List<Map<String, dynamic>> inventoryItems = [];
  bool isLoadingInventory = false;
  String? inventoryError;

  // Orders state
  List<Map<String, dynamic>> orderItems = [];
  bool isLoadingOrders = false;
  String? ordersError;

  // Notification state

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadShopOwnerData(); // Load shop owner data first
    _loadInventory(); // Load inventory on startup
    _loadOrders(); // Load orders on startup
    _loadNotifications(); // Load notifications on startup
  }

  Future<void> _loadShopOwnerData() async {
    setState(() {
      isLoadingShopOwner = true;
    });

    try {
      debugPrint('🔍 Loading shop owner data...');

      // Check if user is logged in
      final isLoggedIn = await UserSession.isLoggedIn();
      debugPrint('✅ Is logged in: $isLoggedIn');

      // Get user type
      final userType = await UserSession.getCurrentUserType();
      debugPrint('✅ User type: $userType');

      // Get user data
      final userData = await UserSession.getCurrentUserData();
      debugPrint('✅ User data: $userData');

      if (userData != null) {
        debugPrint('🏪 Converting to ShopOwner model...');

        // Try direct field access first (fallback)
        String name = userData['full_name'] ??
            userData['name'] ??
            userData['fullName'] ??
            "Shop Owner";
        String email = userData['email'] ?? "owner@example.com";

        debugPrint('📋 Direct field access - Name: $name, Email: $email');

        // Try ShopOwner model conversion
        try {
          currentShopOwner = ShopOwner.fromMap(userData);
          debugPrint(
              '✅ Shop Owner model: ${currentShopOwner?.fullName} - ${currentShopOwner?.email}');

          // Use model data if available, otherwise use direct access
          name = currentShopOwner?.fullName ?? name;
          email = currentShopOwner?.email ?? email;
        } catch (modelError) {
          debugPrint('⚠️ ShopOwner model conversion failed: $modelError');
          debugPrint('📝 Using direct field access instead');
        }

        setState(() {
          shopOwnerName = name;
          shopOwnerEmail = email;
          isLoadingShopOwner = false;
        });

        debugPrint('🎉 Shop owner data loaded successfully!');
        debugPrint('📝 Final Name: $shopOwnerName');
        debugPrint('📧 Final Email: $shopOwnerEmail');
      } else {
        debugPrint('❌ No user data found');
        setState(() {
          isLoadingShopOwner = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading shop owner data: $e');
      setState(() {
        isLoadingShopOwner = false;
      });
    }
  }

  // 🔧 Debug method to test user session
  Future<void> _debugUserSession() async {
    try {
      debugPrint('🔧 === DEBUG USER SESSION ===');

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Debugging user session...'),
            ],
          ),
        ),
      );

      // Test current session
      final isLoggedIn = await UserSession.isLoggedIn();
      final userType = await UserSession.getCurrentUserType();
      final userData = await UserSession.getCurrentUserData();
      final authToken = await UserSession.getAuthToken();

      // Close loading dialog
      Navigator.pop(context);

      // Create test data if no data exists
      if (userData == null) {
        debugPrint('❌ No user data found. Creating test data...');

        final testUserData = {
          'id': 'test-shop-owner-123',
          'full_name': 'রহমান গ্রোসারি (Test)',
          'email': 'test.shop@example.com',
          'contact': '01711123456',
          'address': 'ধানমন্ডি-৩২, ঢাকা',
          'latitude': 23.7465,
          'longitude': 90.3763,
          'shop_name': 'রহমান গ্রোসারি',
          'shop_description': 'Quality grocery items',
          'is_verified': true,
        };

        await UserSession.saveUserSession(
          userId: 'test-shop-owner-123',
          userType: 'shop_owner',
          userData: testUserData,
          token: 'test-token-123',
        );

        // Reload shop owner data
        await _loadShopOwnerData();
      }

      // Show debug info
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🔧 Debug Info'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Is Logged In: $isLoggedIn'),
                Text('User Type: $userType'),
                Text('Auth Token: ${authToken?.substring(0, 20) ?? 'null'}...'),
                const SizedBox(height: 8),
                const Text('User Data:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('$userData'),
                const SizedBox(height: 8),
                const Text('Current Values:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Name: $shopOwnerName'),
                Text('Email: $shopOwnerEmail'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loadShopOwnerData(); // Reload data
              },
              child: const Text('Reload Data'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog if open

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('❌ Debug Error'),
          content: Text('Error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _loadInventory() async {
    setState(() {
      isLoadingInventory = true;
      inventoryError = null;
    });

    try {
      final result = await ShopOwnerApiService.getInventory();

      if (result['success'] == true) {
        setState(() {
          inventoryItems =
              List<Map<String, dynamic>>.from(result['data'] ?? []);
          totalProducts = inventoryItems.length;
          stockAlerts = inventoryItems.where((item) {
            final stockQuantity = item['stock_quantity'] ?? 0;
            final lowStockThreshold = item['low_stock_threshold'] ?? 10;
            return stockQuantity < lowStockThreshold;
          }).length;
          isLoadingInventory = false;
        });
      } else {
        setState(() {
          inventoryError = result['message'] ?? 'Failed to load inventory';
          isLoadingInventory = false;
        });

        // If authentication error, show message
        if (result['requiresLogin'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Please login again'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        inventoryError = 'Error loading inventory: $e';
        isLoadingInventory = false;
      });
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoadingOrders = true;
      ordersError = null;
    });

    try {
      final result = await ShopOwnerApiService.getOrders();

      if (result['success'] == true) {
        setState(() {
          orderItems = List<Map<String, dynamic>>.from(result['data'] ?? []);
          // Update pending orders count from real data
          pendingOrders = orderItems
              .where((order) =>
                  order['status']?.toString().toLowerCase() == 'pending')
              .length;
          isLoadingOrders = false;
        });
      } else {
        setState(() {
          ordersError = result['message'] ?? 'Failed to load orders';
          isLoadingOrders = false;
        });

        // If authentication error, show message
        if (result['requiresLogin'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Please login again'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        ordersError = 'Error loading orders: $e';
        isLoadingOrders = false;
      });
    }
  }

  Future<void> _loadNotifications() async {
    // For now, just calculate notifications based on pending orders
    // In a real app, this could be a separate API call
    setState(() {
      unreadNotifications = pendingOrders;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

//-----------------------------------------------------tush
  @override
  /*
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[50],
    appBar: AppBar(
      title: const Text(
        "Shop Dashboard",
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
        // Summary Cards
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    "Total Products",
                    "$totalProducts",
                    Icons.inventory,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    "Pending Orders",
                    "$pendingOrders",
                    Icons.shopping_cart,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    "Stock Alerts",
                    "$stockAlerts",
                    Icons.warning,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    "VAT Reward",
                    vatRewardStatus,
                    Icons.card_giftcard,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Tab Content
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInventoryTab(),
              _buildOrdersTab(),
              _buildChatTab(),
              _buildPricesTab(),
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
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.green[600],
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green[600],
          tabs: const [
            Tab(icon: Icon(Icons.inventory), text: "Inventory"),
            Tab(icon: Icon(Icons.shopping_cart), text: "Orders"),
            Tab(icon: Icon(Icons.chat), text: "Chat"),
            Tab(icon: Icon(Icons.price_check), text: "Prices"),
            Tab(icon: Icon(Icons.local_offer), text: "Offers"),
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
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: isLoadingShopOwner
          ? const Drawer(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : CustomDrawer(
              userName: shopOwnerName,
              userEmail: shopOwnerEmail,
              userRole: "Shop Owner",
            ),
      appBar: AppBar(
        title: const Text(
          "Shop Dashboard",
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
          // 🔧 Debug button to test user data
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              _debugUserSession();
            },
            tooltip: "Debug User Session",
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
          // ✅ UPDATED: Summary Cards in One Row
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    debugPrint("Tapped Total Products");
                  },
                  child: _buildSummaryCard(
                    "Total Products",
                    "$totalProducts",
                    Icons.inventory,
                    Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    debugPrint("Tapped Pending Orders");
                  },
                  child: _buildSummaryCard(
                    "Pending Orders",
                    "$pendingOrders",
                    Icons.shopping_cart,
                    Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    debugPrint("Tapped Stock Alerts");
                  },
                  child: _buildSummaryCard(
                    "Stock Alerts",
                    "$stockAlerts",
                    Icons.warning,
                    Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    debugPrint("Tapped VAT Reward");
                  },
                  child: _buildSummaryCard(
                    "VAT Reward",
                    vatRewardStatus,
                    Icons.card_giftcard,
                    Colors.green,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tab Content
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInventoryTab(),
                _buildOrdersTab(),
                _buildChatTab(),
                _buildPricesTab(),
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
                // ignore: deprecated_member_use
                color: Colors.grey.withOpacity(0.2),
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
              Tab(icon: Icon(Icons.inventory), text: "Inventory"),
              Tab(icon: Icon(Icons.shopping_cart), text: "Orders"),
              Tab(icon: Icon(Icons.chat), text: "Chat"),
              Tab(icon: Icon(Icons.price_check), text: "Prices"),
              Tab(icon: Icon(Icons.local_offer), text: "Offers"),
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

//--------------------------tush---------------
/*
  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              if (title == "Stock Alerts" && stockAlerts > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "!",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

*/

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12), // reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // slightly smaller corners
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20), // smaller icon
              const Spacer(),
              if (title == "Stock Alerts" && stockAlerts > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "!",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 1), // reduced spacing
          Text(
            value,
            style: TextStyle(
              fontSize: 15, // slightly smaller
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11, // slightly smaller
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

//-----------------------------------------------

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
                    _addNewProduct();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add New Product"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
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
                      : const Icon(Icons.refresh),
                  label: Text(
                    isLoadingInventory ? "Loading..." : "Refresh",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
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
                _addNewProduct();
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
        return _buildProductCard(inventoryItems[index]);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    final productName = item['subcat_name']?.toString() ?? 'Unknown Product';
    final categoryName = item['cat_name']?.toString() ?? '';
    final stockQuantity = item['stock_quantity'] ?? 0;
    final unitPrice = item['unit_price'] ?? 0.0;
    final lowStockThreshold = item['low_stock_threshold'] ?? 10;
    final inventoryId = item['id']?.toString() ?? '';

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
            isLowStock ? Icons.warning : Icons.inventory,
            color: isLowStock ? Colors.red : Colors.green,
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
            Text("Quantity: $stockQuantity units"),
            Text("Price: ৳${displayPrice.toStringAsFixed(2)} per unit"),
            if (isLowStock)
              Text(
                "⚠️ Low Stock (Threshold: $lowStockThreshold)",
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: "edit", child: Text("Edit")),
            const PopupMenuItem(
                value: "toggle", child: Text("Toggle Visibility")),
            const PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
          onSelected: (value) {
            _handleProductActionWithData(value, productName, inventoryId, item);
          },
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Order Status Summary
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Text(
                    isLoadingOrders
                        ? "Loading orders..."
                        : "Total Orders: ${orderItems.length}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (pendingOrders > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "$pendingOrders Pending",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _loadOrders,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Refresh Orders"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showOrderStats,
                  icon: const Icon(Icons.analytics),
                  label: const Text("Order Stats"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: _buildOrdersContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(int index) {
    final orders = [
      {
        "customer": "আহমেদ সাহেব",
        "item": "চাল সরু",
        "quantity": 5,
        "time": "10:30 AM",
        "status": "Pending"
      },
      {
        "customer": "ফাতিমা বেগম",
        "item": "সয়াবিন তেল",
        "quantity": 2,
        "time": "11:15 AM",
        "status": "Confirmed"
      },
      {
        "customer": "করিম উদ্দিন",
        "item": "মসুর ডাল",
        "quantity": 3,
        "time": "12:00 PM",
        "status": "Pending"
      },
      {
        "customer": "রহিমা খাতুন",
        "item": "পেঁয়াজ",
        "quantity": 10,
        "time": "01:30 PM",
        "status": "Delivered"
      },
      {
        "customer": "নাসির সাহেব",
        "item": "গমের আটা",
        "quantity": 2,
        "time": "02:15 PM",
        "status": "Rejected"
      },
    ];

    final order = orders[index];
    final status = order["status"] as String;

    // Define colors and background for different statuses
    Color statusColor;
    Color backgroundColor;
    IconData statusIcon;

    switch (status) {
      case "Pending":
        statusColor = Colors.orange[700]!;
        backgroundColor = Colors.orange[50]!;
        statusIcon = Icons.access_time;
        break;
      case "Confirmed":
        statusColor = Colors.blue[700]!;
        backgroundColor = Colors.blue[50]!;
        statusIcon = Icons.check_circle;
        break;
      case "Delivered":
        statusColor = Colors.green[700]!;
        backgroundColor = Colors.green[50]!;
        statusIcon = Icons.delivery_dining;
        break;
      case "Rejected":
        statusColor = Colors.red[700]!;
        backgroundColor = Colors.red[50]!;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey[700]!;
        backgroundColor = Colors.grey[50]!;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: backgroundColor,
      elevation: status == "Pending" ? 3 : 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(
            Icons.person,
            color: statusColor,
          ),
        ),
        title: Text(
          order["customer"] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${order["item"]} × ${order["quantity"]} units"),
            Text("Time: ${order["time"]}"),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    statusIcon,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: status == "Pending"
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.check, color: Colors.white),
                      onPressed: () {
                        _showConfirmOrderDialog(
                            order["customer"] as String, order);
                      },
                      tooltip: "Confirm Order",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        _showRejectOrderDialog(
                            order["customer"] as String, order);
                      },
                      tooltip: "Reject Order",
                    ),
                  ),
                ],
              )
            : status == "Confirmed"
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[300]!),
                    ),
                    child: const Text(
                      "Processing",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
      ),
    );
  }

  Widget _buildChatTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Wholesalers Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.search, color: Colors.purple[600]),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Search & Chat with Wholesalers",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "Find wholesalers by name, location, or contact details and start chatting instantly.",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WholesalerSearchScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text("Search Wholesalers"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WholesalerListScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text("View All Chats"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Recent Chats Preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.purple[600]),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Click on any wholesaler to start chatting",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildWholesalerCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWholesalerCard(int index) {
    final wholesalers = [
      {
        "name": "রহমান ট্রেডার্স",
        "unread": 2,
        "lastMessage": "নতুন দামের তালিকা আপডেট"
      },
      {
        "name": "করিম এন্টারপ্রাইজ",
        "unread": 0,
        "lastMessage": "অর্ডার কনফার্ম করেছি"
      },
      {"name": "আলম ইমপোর্ট", "unread": 1, "lastMessage": "স্টক আভেইলেবল আছে"},
      {
        "name": "নিউ সুন্দরবন",
        "unread": 3,
        "lastMessage": "আগামীকাল ডেলিভারি দেব"
      },
    ];

    final wholesaler = wholesalers[index];
    final unreadCount = wholesaler["unread"] as int;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple[100],
          child: Text(
            (wholesaler["name"] as String)[0],
            style: TextStyle(
              color: Colors.purple[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                wholesaler["name"] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$unreadCount",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          wholesaler["lastMessage"] as String,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          _openChatWithWholesaler(wholesaler["name"] as String);
        },
      ),
    );
  }

  Widget _buildPricesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🏛️ Government Fixed Prices",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Last updated: Today, 9:00 AM",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) {
                return _buildPriceCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(int index) {
    final prices = [
      {
        "product": "চাল সরু (নাজির/মিনিকেট)",
        "price": "৳78-82/কেজি",
        "category": "চাল"
      },
      {
        "product": "সয়াবিন তেল (পিউর)",
        "price": "৳165-175/লিটার",
        "category": "তেল"
      },
      {"product": "মসুর ডাল", "price": "৳115-125/কেজি", "category": "ডাল"},
      {"product": "পেঁয়াজ (দেশি)", "price": "৳50-60/কেজি", "category": "সবজি"},
      {
        "product": "গমের আটা (প্রিমিয়াম)",
        "price": "৳45-50/কেজি",
        "category": "আটা"
      },
      {"product": "গরুর দুধ", "price": "৳60-70/লিটার", "category": "দুগ্ধজাত"},
    ];

    final price = prices[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: const Icon(
            Icons.price_check,
            color: Colors.green,
          ),
        ),
        title: Text(
          price["product"] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Category: ${price["category"]}",
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green),
          ),
          child: Text(
            price["price"] as String,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
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
                  onPressed: () {
                    _createOffer();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Create Offer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildOfferCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(int index) {
    final offers = [
      {
        "title": "চাল সরু ২০% ছাড়",
        "description": "৫ কেজির উপর অর্ডারে ২০% ছাড়",
        "validUntil": "৩০ জানুয়ারি পর্যন্ত",
        "active": true
      },
      {
        "title": "তেল ও ডাল কম্বো অফার",
        "description": "একসাথে তেল ও ডাল কিনলে ১৫% ছাড়",
        "validUntil": "২৮ জানুয়ারি পর্যন্ত",
        "active": true
      },
      {
        "title": "নতুন গ্রাহক অফার",
        "description": "নতুন গ্রাহকদের জন্য ১০% ছাড়",
        "validUntil": "মেয়াদ শেষ",
        "active": false
      },
    ];

    final offer = offers[index];
    final isActive = offer["active"] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.orange[100] : Colors.grey[100],
          child: Icon(
            Icons.local_offer,
            color: isActive ? Colors.orange : Colors.grey,
          ),
        ),
        title: Text(
          offer["title"] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(offer["description"] as String),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: isActive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  isActive ? "Active" : "Expired",
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  offer["validUntil"] as String,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: "edit", child: Text("Edit")),
            const PopupMenuItem(value: "broadcast", child: Text("Broadcast")),
            const PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
          onSelected: (value) {
            _handleOfferAction(value, offer["title"] as String);
          },
        ),
      ),
    );
  }

  // Action Methods
  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Notifications"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.orange),
              title: const Text("New Order"),
              subtitle: const Text("আহমেদ সাহেব ordered চাল সরু"),
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: const Text("Low Stock Alert"),
              subtitle: const Text("সয়াবিন তেল stock is running low"),
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.purple),
              title: const Text("New Message"),
              subtitle: const Text("Message from রহমান ট্রেডার্স"),
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
                _editProfile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Shop Settings"),
              onTap: () {
                Navigator.pop(context);
                _shopSettings();
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

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Edit Profile - Coming Soon!")),
    );
  }

  void _shopSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Shop Settings - Coming Soon!")),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _logout() {
    // Clear any stored user data/tokens here
    // For now, just navigate back to login screen
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (Route<dynamic> route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Logged out successfully"),
        backgroundColor: Colors.green,
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add_box, color: Colors.blue),
              title: const Text("Add Product"),
              onTap: () {
                Navigator.pop(context);
                _addNewProduct();
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer, color: Colors.orange),
              title: const Text("Create Offer"),
              onTap: () {
                Navigator.pop(context);
                _createOffer();
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.purple),
              title: const Text("Message Wholesalers"),
              onTap: () {
                Navigator.pop(context);
                _openWholesalerChat();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addNewProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );

    if (result == true) {
      // Refresh the inventory data
      _loadInventory();
    }
  }

  void _handleProductActionWithData(String action, String productName,
      String inventoryId, Map<String, dynamic> item) async {
    if (action == "edit") {
      // Convert the item data to the format expected by UpdateProductScreen
      final productForUpdate = {
        "name": productName,
        "quantity": item['stock_quantity'] ?? 0,
        "price": item['unit_price'] ?? 0.0,
        "lowStock":
            (item['stock_quantity'] ?? 0) < (item['low_stock_threshold'] ?? 10),
        "id": inventoryId,
        "subcat_id": item['subcat_id'],
        "low_stock_threshold": item['low_stock_threshold'],
      };

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateProductScreen(product: productForUpdate),
        ),
      );

      if (result != null) {
        // Refresh the inventory data after successful update
        _loadInventory();

        // Show success message if the update was successful
        if (result is Map<String, dynamic> && result.containsKey('success')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Product updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } else if (action == "delete") {
      // Show confirmation dialog for delete
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Delete $productName"),
          content: Text(
              "Are you sure you want to delete $productName from your inventory?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Delete $productName - API integration needed")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$action $productName - Coming Soon!")),
      );
    }
  }

  void _showConfirmOrderDialog(String customer, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text("Confirm Order"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to confirm this order?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Customer: $customer",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("Item: ${order["item"]} × ${order["quantity"]} units"),
                  Text("Order Time: ${order["time"]}"),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This action will notify the customer that their order has been confirmed.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _confirmOrder(customer, order);
            },
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              "Confirm Order",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectOrderDialog(String customer, Map<String, dynamic> order) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text("Reject Order"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to reject this order?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Customer: $customer",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("Item: ${order["item"]} × ${order["quantity"]} units"),
                  Text("Order Time: ${order["time"]}"),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Reason for rejection (optional):",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: "e.g., Out of stock, Store closed, etc.",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Text(
              "The customer will be notified about the rejection.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _rejectOrder(customer, order, reasonController.text);
            },
            icon: const Icon(Icons.cancel, color: Colors.white),
            label: const Text(
              "Reject Order",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmOrder(String customer, Map<String, dynamic> order) {
    setState(() {
      pendingOrders = (pendingOrders - 1).clamp(0, double.infinity).toInt();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text("Order confirmed for $customer"),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "View Details",
          textColor: Colors.white,
          onPressed: () {
            // TODO: Navigate to order details
          },
        ),
      ),
    );
  }

  void _rejectOrder(
      String customer, Map<String, dynamic> order, String reason) {
    setState(() {
      pendingOrders = (pendingOrders - 1).clamp(0, double.infinity).toInt();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.cancel, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order rejected for $customer"),
                  if (reason.isNotEmpty)
                    Text(
                      "Reason: $reason",
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _openWholesalerChat() {
    // Navigate to a general wholesaler list or the first wholesaler
    const defaultWholesaler = "রহমান ট্রেডার্স";
    _openChatWithWholesaler(defaultWholesaler);
  }

  void _openChatWithWholesaler(String wholesaler) {
    // Extract the first character for the avatar
    final initial = wholesaler.isNotEmpty ? wholesaler[0] : 'W';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WholesalerChatScreen(
          wholesalerName: wholesaler,
          wholesalerInitial: initial,
        ),
      ),
    );
  }

  void _createOffer() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Create Offer - Coming Soon!")),
    );
  }

  void _handleOfferAction(String action, String offerTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$action: $offerTitle - Coming Soon!")),
    );
  }

  void _showOrderStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.analytics, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text("Order Statistics"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow(
                "Pending Orders", "3", Colors.orange, Icons.access_time),
            _buildStatRow(
                "Confirmed Orders", "1", Colors.blue, Icons.check_circle),
            _buildStatRow(
                "Delivered Orders", "1", Colors.green, Icons.delivery_dining),
            _buildStatRow("Rejected Orders", "1", Colors.red, Icons.cancel),
            const Divider(),
            _buildStatRow("Total Today", "6", Colors.purple, Icons.today),
            _buildStatRow(
                "Success Rate", "83%", Colors.green, Icons.trending_up),
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
              // TODO: Navigate to detailed analytics
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Detailed analytics - Coming Soon!")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
            ),
            child: const Text(
              "View Details",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Real order handling methods
  Widget _buildOrdersContent() {
    if (isLoadingOrders) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading orders..."),
          ],
        ),
      );
    }

    if (ordersError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              ordersError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrders,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (orderItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No orders yet",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Orders will appear here when customers place them",
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: orderItems.length,
      itemBuilder: (context, index) {
        return _buildRealOrderCard(orderItems[index]);
      },
    );
  }

  Widget _buildRealOrderCard(Map<String, dynamic> order) {
    final customerName =
        order['customer_name']?.toString() ?? 'Unknown Customer';
    final productName = order['product_name']?.toString() ?? 'Unknown Product';
    final quantity = order['quantity_ordered'] ?? 0;
    final status = order['status']?.toString() ?? 'pending';
    final orderNumber = order['order_number']?.toString() ?? '';
    final createdAt = order['created_at']?.toString() ?? '';
    final totalAmount = order['total_amount'] ?? order['total_price'] ?? 0.0;
    final orderDate = DateTime.tryParse(createdAt);

    // Format time
    final timeString = orderDate != null
        ? "${orderDate.hour.toString().padLeft(2, '0')}:${orderDate.minute.toString().padLeft(2, '0')}"
        : 'Unknown time';

    // Format date
    final dateString = orderDate != null
        ? "${orderDate.day.toString().padLeft(2, '0')}/${orderDate.month.toString().padLeft(2, '0')}/${orderDate.year}"
        : 'Unknown date';

    // Parse total amount properly
    final displayTotalAmount = totalAmount is String
        ? double.tryParse(totalAmount) ?? 0.0
        : totalAmount.toDouble();

    // Define colors and background for different statuses
    Color statusColor;
    Color backgroundColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange[700]!;
        backgroundColor = Colors.orange[50]!;
        statusIcon = Icons.access_time;
        break;
      case 'confirmed':
      case 'on going':
        statusColor = Colors.blue[700]!;
        backgroundColor = Colors.blue[50]!;
        statusIcon = Icons.check_circle;
        break;
      case 'delivered':
        statusColor = Colors.green[700]!;
        backgroundColor = Colors.green[50]!;
        statusIcon = Icons.delivery_dining;
        break;
      case 'rejected':
      case 'cancelled':
        statusColor = Colors.red[700]!;
        backgroundColor = Colors.red[50]!;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey[700]!;
        backgroundColor = Colors.grey[50]!;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: backgroundColor,
      elevation: status.toLowerCase() == "pending" ? 3 : 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            Icons.person,
            color: statusColor,
          ),
        ),
        title: Text(
          customerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$productName × $quantity units"),
            Text("Order ID: $orderNumber"),
            Text("Date: $dateString"),
            Text("Time: $timeString"),
            Text("Total: ৳${displayTotalAmount.toStringAsFixed(2)}"),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: status.toLowerCase() == "pending"
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.check, color: Colors.green[700]),
                      tooltip: "Confirm Order",
                      onPressed: () => _confirmRealOrder(order),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.red[700]),
                      tooltip: "Reject Order",
                      onPressed: () => _rejectRealOrder(order),
                    ),
                  ),
                ],
              )
            : (status.toLowerCase() == "confirmed" ||
                    status.toLowerCase() == "on going")
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[300]!),
                    ),
                    child: const Text(
                      "On Going",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
      ),
    );
  }

  void _confirmRealOrder(Map<String, dynamic> order) async {
    final orderId = order['id']?.toString();
    if (orderId == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text("Confirm Order"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Are you sure you want to confirm this order?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Customer: ${order['customer_name'] ?? 'Unknown'}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("Product: ${order['product_name'] ?? 'Unknown'}"),
                  Text("Quantity: ${order['quantity_ordered'] ?? 0} units"),
                  Text("Order: ${order['order_number'] ?? 'Unknown'}"),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.inventory, color: Colors.orange, size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "This will decrease your product inventory and change status to 'On Going'",
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              "Confirm Order",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Use the new confirm order API method
      final result = await ShopOwnerApiService.confirmOrder(
        orderId: orderId,
        notes: 'Confirmed by shop owner',
      );

      if (result['success'] == true) {
        // Success message with remaining stock info
        final message = result['message'] ?? 'Order confirmed successfully!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(message),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );

        // Update notification count
        setState(() {
          unreadNotifications++;
        });

        // Refresh orders and inventory to get updated data
        _loadOrders();
        _loadInventory(); // Refresh inventory to show updated quantities
      } else {
        // Check if it's a low stock error
        if (result.containsKey('lowStock') && result['lowStock'] == true) {
          final availableStock = result['availableStock'] ?? 0;
          final requiredStock = result['requiredStock'] ?? 0;
          final productName = result['productName'] ?? 'Product';

          // Show limited stock dialog with restore message
          showDialog(
            context: context,
            barrierDismissible: false, // Prevent dismissing by tapping outside
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red[600]),
                  const SizedBox(width: 8),
                  const Text("Limited Stock",
                      style: TextStyle(color: Colors.red)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Limited stock please restore',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$productName',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('Available Stock: $availableStock units'),
                        Text('Required: $requiredStock units'),
                        Text(
                          'Need to restore: ${requiredStock - availableStock} units',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Please restore your stock first, then you can confirm this order.',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to inventory tab to restore stock
                    _tabController.animateTo(0);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Please restore the stock first, then try to confirm the order again.'),
                        backgroundColor: Colors.orange[600],
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Restore Stock'),
                ),
              ],
            ),
          );
        } else {
          // Regular error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to confirm order'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error confirming order: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _rejectRealOrder(Map<String, dynamic> order) async {
    final orderId = order['id']?.toString();
    if (orderId == null) return;

    try {
      final result = await ShopOwnerApiService.updateOrderStatus(
        orderId: orderId,
        status: 'rejected',
        rejectionReason: 'Rejected by shop owner',
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.cancel, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text("Order ${order['order_number']} rejected"),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Refresh orders to get updated status
        _loadOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to reject order'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
