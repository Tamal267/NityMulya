import 'package:flutter/material.dart';
import 'package:nitymulya/models/wholesaler_models.dart';
import 'package:nitymulya/network/wholesaler_api.dart';
import 'package:nitymulya/screens/wholesaler/shop_owner_search_screen.dart';
import 'package:nitymulya/screens/wholesaler/wholesaler_add_product_screen.dart';
import 'package:nitymulya/screens/wholesaler/wholesaler_chat_screen.dart';
import 'package:nitymulya/widgets/custom_drawer.dart';

class WholesalerDashboardScreen extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String? userId;
  
  const WholesalerDashboardScreen({
    super.key,
    this.userName,
    this.userEmail,
    this.userId,
  });

  @override
  State<WholesalerDashboardScreen> createState() => _WholesalerDashboardScreenState();
}

class _WholesalerDashboardScreenState extends State<WholesalerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Loading states
  bool isLoadingDashboard = true;
  bool isLoadingInventory = true;
  bool isLoadingLowStock = true;
  bool isLoadingOrders = true;
  bool isLoadingOffers = true;
  bool isLoadingChat = true;
  
  // Dashboard data
  WholesalerDashboardSummary? dashboardSummary;
  List<WholesalerInventoryItem> inventoryItems = [];
  List<LowStockItem> lowStockItems = [];
  List<ShopOrder> orders = [];
  List<WholesalerOffer> offers = [];
  List<ChatMessage> chatMessages = [];
  List<Category> categories = [];
  List<Subcategory> subcategories = [];
  
  // Filters
  String selectedProduct = "All Products";
  String selectedLocation = "All Areas";
  int quantityThreshold = 10;
  
  // User info
  String get userName => widget.userName ?? "Wholesaler";
  String get userEmail => widget.userEmail ?? "wholesaler@example.com";
  String get userId => widget.userId ?? "cdb69b0f-27bc-41b5-9ce3-525f54e1f316"; // Fallback for testing with actual UUID
  
  // Dynamic lists from backend
  List<String> get products {
    List<String> productList = ["All Products"];
    for (var category in categories) {
      productList.add(category.catName);
    }
    return productList;
  }
  
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
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadDashboardSummary(),
      _loadCategories(),
      _loadInventory(),
      _loadLowStockProducts(),
      _loadOrders(),
      _loadOffers(),
      _loadChatMessages(),
    ]);
  }

  Future<void> _loadDashboardSummary() async {
    setState(() => isLoadingDashboard = true);
    try {
      final result = await WholesalerApiService.getDashboardSummary(userId);
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          dashboardSummary = WholesalerDashboardSummary.fromJson(result['data']);
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard summary: $e');
    } finally {
      setState(() => isLoadingDashboard = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final result = await WholesalerApiService.getCategories();
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          categories = (result['data'] as List)
              .map((item) => Category.fromJson(item))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _loadInventory() async {
    setState(() => isLoadingInventory = true);
    try {
      final result = await WholesalerApiService.getInventory(userId);
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          inventoryItems = (result['data'] as List)
              .map((item) => WholesalerInventoryItem.fromJson(item))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading inventory: $e');
    } finally {
      setState(() => isLoadingInventory = false);
    }
  }

  Future<void> _loadLowStockProducts() async {
    setState(() => isLoadingLowStock = true);
    try {
      final result = await WholesalerApiService.getLowStockProducts(
        wholesalerId: userId,
        productFilter: selectedProduct != "All Products" ? selectedProduct : null,
        locationFilter: selectedLocation != "All Areas" ? selectedLocation : null,
      );
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          lowStockItems = (result['data'] as List)
              .map((item) => LowStockItem.fromJson(item))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading low stock products: $e');
    } finally {
      setState(() => isLoadingLowStock = false);
    }
  }

  Future<void> _loadOrders() async {
    setState(() => isLoadingOrders = true);
    try {
      final result = await WholesalerApiService.getShopOrders(wholesalerId: userId);
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          orders = (result['data'] as List)
              .map((item) => ShopOrder.fromJson(item))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
    } finally {
      setState(() => isLoadingOrders = false);
    }
  }

  Future<void> _loadOffers() async {
    setState(() => isLoadingOffers = true);
    try {
      final result = await WholesalerApiService.getOffers(userId);
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          offers = (result['data'] as List)
              .map((item) => WholesalerOffer.fromJson(item))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading offers: $e');
    } finally {
      setState(() => isLoadingOffers = false);
    }
  }

  Future<void> _loadChatMessages() async {
    setState(() => isLoadingChat = true);
    try {
      final result = await WholesalerApiService.getChatMessages(wholesalerId: userId);
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          chatMessages = (result['data'] as List)
              .map((item) => ChatMessage.fromJson(item))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading chat messages: $e');
    } finally {
      setState(() => isLoadingChat = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: CustomDrawer(
        userName: userName,
        userEmail: userEmail,
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
              if ((dashboardSummary?.unreadMessages ?? 0) > 0)
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
                      '${dashboardSummary?.unreadMessages ?? 0}',
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
                    "${dashboardSummary?.totalShops ?? 0}",
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
                    "${dashboardSummary?.newRequests ?? 0}",
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
                    "Low Stock",
                    "${dashboardSummary?.lowStockProducts ?? 0}",
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
                    dashboardSummary?.supplyStatus ?? "Active",
                    Icons.local_shipping,
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
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "!",
                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
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
              leading: Icon(Icons.filter_list, color: Colors.green[800], size: 20),
              title: const Text(
                "🛒 Low Stock Monitor Filters",
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: products.map((product) => DropdownMenuItem(
                          value: product,
                          child: Text(
                            product,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProduct = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Location Dropdown (Full Width)
                      DropdownButtonFormField<String>(
                        value: selectedLocation,
                        decoration: InputDecoration(
                          labelText: "Location",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: locations.map((location) => DropdownMenuItem(
                          value: location,
                          child: Text(
                            location,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedLocation = value!;
                          });
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
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              icon: const Icon(Icons.search, color: Colors.white, size: 20),
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
              : lowStockItems.isEmpty
                ? const Center(
                    child: Text(
                      "No low stock items found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: lowStockItems.length,
                    itemBuilder: (context, index) {
                      return _buildLowStockItem(lowStockItems[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockItem(LowStockItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: item.isUrgent ? Colors.red[50] : Colors.white,
      elevation: item.isUrgent ? 3 : 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.isUrgent ? Colors.red[100] : Colors.green[100],
          child: item.subcatImg != null && item.subcatImg!.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  item.subcatImg!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.inventory_2,
                    color: item.isUrgent ? Colors.red[700] : Colors.green[700],
                  ),
                ),
              )
            : Icon(
                Icons.inventory_2,
                color: item.isUrgent ? Colors.red[700] : Colors.green[700],
              ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.shopName ?? item.subcatName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (item.isUrgent)
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
            if (item.shopAddress != null) ...[
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      item.shopAddress!,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${item.subcatName} (${item.catName})",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.inventory,
                  size: 14,
                  color: item.stockQuantity < 5 ? Colors.red[700] : Colors.orange[700],
                ),
                const SizedBox(width: 4),
                Text(
                  "${item.stockQuantity} ${item.unit}",
                  style: TextStyle(
                    color: item.stockQuantity < 5 ? Colors.red[700] : Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (item.pendingOrders > 0) ...[
              const SizedBox(height: 4),
              Text(
                "Pending orders: ${item.pendingOrders}",
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
                  contactId: (item.shopName ?? "unknown").toLowerCase().replaceAll(' ', '_'),
                  contactType: 'shop_owner',
                  contactName: item.shopName ?? "Unknown Shop",
                ),
              ),
            ),
            onLongPress: () => _contactShop(item.shopName ?? "Unknown Shop"),
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
                        builder: (context) => WholesalerAddProductScreen(
                          userId: widget.userId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Add Product", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _uploadCatalog(),
                  icon: const Icon(Icons.upload, color: Colors.white),
                  label: const Text("Upload Catalog", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoadingInventory
              ? const Center(child: CircularProgressIndicator())
              : inventoryItems.isEmpty
                ? const Center(
                    child: Text(
                      "No inventory items found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: inventoryItems.length,
                    itemBuilder: (context, index) {
                      return _buildInventoryItem(inventoryItems[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItem(WholesalerInventoryItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: item.subcatImg != null && item.subcatImg!.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  item.subcatImg!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.inventory_2,
                    color: Colors.green[700],
                  ),
                ),
              )
            : Icon(
                Icons.inventory_2,
                color: Colors.green[700],
              ),
        ),
        title: Text(
          item.subcatName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Category: ${item.catName}"),
            Text("Price: ৳${item.unitPrice.toStringAsFixed(2)}/${item.unit}"),
            Text(
              "Stock: ${item.stockQuantity} ${item.unit}",
              style: TextStyle(
                color: item.isLowStock ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (item.isLowStock)
              Text(
                "⚠️ Low Stock Alert",
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: "edit", child: Text("Edit")),
            const PopupMenuItem(value: "history", child: Text("Supply History")),
            const PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
          onSelected: (value) {
            _handleInventoryAction(value, item);
          },
        ),
      ),
    );
  }

  Widget _buildChatTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Shop Communications",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShopOwnerSearchScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.search, color: Colors.white),
                label: const Text(
                  "Search Shop",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: isLoadingChat
              ? const Center(child: CircularProgressIndicator())
              : chatMessages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No conversations yet",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Search for shop owners to start chatting",
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ShopOwnerSearchScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            "Find Shop Owners",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: chatMessages.length,
                    itemBuilder: (context, index) {
                      return _buildChatItem(chatMessages[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatMessage chatMessage) {
    final timeAgo = _getTimeAgo(chatMessage.createdAt);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Text(
            (chatMessage.shopName ?? chatMessage.senderName ?? "U")[0].toUpperCase(),
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
                chatMessage.shopName ?? chatMessage.senderName ?? "Unknown",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (!chatMessage.isRead)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "New",
                  style: TextStyle(
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
              chatMessage.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              timeAgo,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.chat, color: Colors.green[800]),
          onPressed: () => _openChatWithShop(chatMessage.shopName ?? "Unknown"),
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
                  onPressed: () => _exportCSV(),
                  icon: const Icon(Icons.table_chart, color: Colors.white),
                  label: const Text("Export CSV",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoadingOrders
              ? const Center(child: CircularProgressIndicator())
              : orders.isEmpty
                ? const Center(
                    child: Text(
                      "No orders found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return _buildHistoryItem(orders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(ShopOrder order) {
    Color statusColor;
    IconData statusIcon;

    switch (order.status.toLowerCase()) {
      case "delivered":
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case "pending":
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case "processing":
        statusColor = Colors.blue;
        statusIcon = Icons.sync;
        break;
      case "cancelled":
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    final formattedDate = "${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year.toString().substring(2)}";

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
          order.shopName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${order.subcatName} - ${order.quantityRequested} ${order.unit}"),
            Text("Amount: ৳${order.totalAmount.toStringAsFixed(2)}"),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _changeTransactionStatus(order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order.status.toUpperCase(),
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

  void _changeTransactionStatus(ShopOrder order) {
    String selectedStatus = order.status;
    
    final statuses = ["pending", "processing", "delivered", "cancelled"];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Change Status - ${order.shopName}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Product: ${order.subcatName} - ${order.quantityRequested} ${order.unit}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Total: ৳${order.totalAmount.toStringAsFixed(2)}"),
              const SizedBox(height: 16),
              const Text("Select new status:"),
              const SizedBox(height: 8),
              ...statuses.map((status) => RadioListTile<String>(
                title: Text(status.toUpperCase()),
                value: status,
                groupValue: selectedStatus,
                onChanged: (value) {
                  setDialogState(() {
                    selectedStatus = value!;
                  });
                },
                dense: true,
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: selectedStatus == order.status ? null : () async {
                Navigator.pop(context);
                
                // Update order status via API
                final result = await WholesalerApiService.updateOrderStatus(
                  orderId: order.id,
                  status: selectedStatus,
                );
                
                if (result['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Order status updated to ${selectedStatus.toUpperCase()}")),
                  );
                  _loadOrders(); // Reload orders
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to update: ${result['message']}")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
              ),
              child: const Text("Confirm", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _viewReceipt(ShopOrder order) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: _buildReceiptWidget(order),
      ),
    );
  }

  Widget _buildReceiptWidget(ShopOrder order) {
    final receiptNumber = "R${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    final currentDate = DateTime.now();
    final formattedDate = "${currentDate.day}/${currentDate.month}/${currentDate.year}";
    final formattedTime = "${currentDate.hour}:${currentDate.minute.toString().padLeft(2, '0')}";
    
    // Sample pricing calculation
    final unitPrice = _getUnitPrice(order.subcatName);
    final quantity = order.quantityRequested;
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.status,
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
                _buildReceiptRow("Shop Name:", order.shopName, isTitle: true),
                _buildReceiptRow("Location:", _getShopLocation(order.shopName)),
                _buildReceiptRow("Contact:", "+880 1712-345678"),
                
                const SizedBox(height: 12),
                const Divider(),
                
                // Product Details
                const Text(
                  "Product Details:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildReceiptRow("Product:", order.subcatName),
                _buildReceiptRow("Quantity:", "${order.quantityRequested} ${order.unit}"),
                _buildReceiptRow("Unit Price:", "৳${unitPrice.toStringAsFixed(2)}"),
                
                const SizedBox(height: 12),
                const Divider(),
                
                // Pricing
                _buildReceiptRow("Subtotal:", "৳${subtotal.toStringAsFixed(2)}"),
                _buildReceiptRow("Tax (5%):", "৳${tax.toStringAsFixed(2)}"),
                const Divider(thickness: 2),
                _buildReceiptRow("Total Amount:", "৳${total.toStringAsFixed(2)}", isTotal: true),
                
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
                  onPressed: () => _printReceipt(order, receiptNumber),
                  icon: const Icon(Icons.print, color: Colors.white),
                  label: const Text("Print", style: TextStyle(color: Colors.white)),
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

  Widget _buildReceiptRow(String label, String value, {bool isTitle = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTitle || isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTitle || isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.green[800] : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  double _getUnitPrice(String product) {
    // Sample pricing based on product
    final prices = {
      "চাল সরু": 85.0,
      "সয়াবিন তেল": 170.0,
      "মসুর ডাল": 125.0,
      "পেঁয়াজ": 55.0,
      "চিনি": 65.0,
      "গমের আটা": 50.0,
      "ছোলা ডাল": 95.0,
      "সরিষার তেল": 180.0,
      "চাল মোটা": 75.0,
      "তুলসী ডাল": 115.0,
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
    switch (status) {
      case "Delivered":
        return Colors.green;
      case "Pending":
        return Colors.orange;
      case "Processing":
        return Colors.blue;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _printReceipt(ShopOrder order, String receiptNumber) {
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

  void _handleOfferAction(String action, String offerTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$action: $offerTitle - Coming Soon!")),
    );
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create New Offer"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Product",
                border: OutlineInputBorder(),
              ),
              items: products.map((product) {
                return DropdownMenuItem(value: product, child: Text(product));
              }).toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Discount Percentage",
                suffixText: "%",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Valid Days",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Create"),
          ),
        ],
      ),
    );
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
  void _applyFilters() async {
    await _loadLowStockProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Applied filters: $selectedProduct in $selectedLocation with < $quantityThreshold units",
        ),
        backgroundColor: Colors.green[800],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else {
      return "${difference.inDays} days ago";
    }
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildNotificationItem(
                      "New Order Received",
                      "Order #12345 from Shop ABC",
                      DateTime.now().subtract(const Duration(minutes: 5)),
                      Icons.shopping_cart,
                      Colors.green,
                    ),
                    _buildNotificationItem(
                      "Low Stock Alert",
                      "Rice stock is running low (8 bags left)",
                      DateTime.now().subtract(const Duration(hours: 2)),
                      Icons.warning,
                      Colors.orange,
                    ),
                    _buildNotificationItem(
                      "Payment Received",
                      "₹15,000 received from Shop XYZ",
                      DateTime.now().subtract(const Duration(hours: 4)),
                      Icons.payment,
                      Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String subtitle,
    DateTime time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTimeAgo(time),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Settings'),
        content: const Text('Profile settings coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout'),
          ),
        ],
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Create new offer functionality coming soon')),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Create Offer", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Broadcast offers functionality coming soon')),
                    );
                  },
                  icon: const Icon(Icons.broadcast_on_personal, color: Colors.white),
                  label: const Text("Broadcast", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Expanded(
            child: Center(
              child: Text(
                "No offers found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
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
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add_business),
              title: const Text('Add Product'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add product functionality coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh Data'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data refreshed')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('View Messages'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat functionality coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _uploadCatalog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catalog upload functionality coming soon')),
    );
  }

  void _handleInventoryAction(String action, dynamic item) {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit item functionality coming soon')),
        );
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Item'),
            content: const Text('Are you sure you want to delete this item?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item deleted')),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        break;
      case 'restock':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restock functionality coming soon')),
        );
        break;
    }
  }

  void _exportPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF export functionality coming soon')),
    );
  }

  void _exportCSV() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV export functionality coming soon')),
    );
  }
}