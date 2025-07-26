import 'package:flutter/material.dart';
import 'package:nitymulya/screens/wholesaler/wholesaler_add_product_screen.dart';
import 'package:nitymulya/screens/wholesaler/wholesaler_chat_screen.dart';
import 'package:nitymulya/widgets/custom_drawer.dart';

class WholesalerDashboardScreen extends StatefulWidget {
  const WholesalerDashboardScreen({super.key});

  @override
  State<WholesalerDashboardScreen> createState() => _WholesalerDashboardScreenState();
}

class _WholesalerDashboardScreenState extends State<WholesalerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int unreadNotifications = 8;
  int totalShops = 45;
  int newRequests = 12;
  int lowStockProducts = 8;
  String supplyStatus = "Active";
  
  String selectedProduct = "All Products";
  String selectedLocation = "All Areas";
  int quantityThreshold = 10;
  
  final List<String> products = [
    "All Products",
    "Rice (চাল)",
    "Oil (তেল)",
    "Lentils (ডাল)",
    "Sugar (চিনি)",
    "Onion (পেঁয়াজ)",
    "Flour (আটা)",
  ];
  
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
                    "Low Stock",
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
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              if (title.contains("Low") || title.contains("Requests"))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "!",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
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
            child: ListView.builder(
              itemCount: 8,
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
    final shops = [
      {"name": "আহমেদ স্টোর", "location": "ধানমন্ডি, ঢাকা", "product": "চাল সরু", "quantity": 3, "urgent": true},
      {"name": "করিম ট্রেডার্স", "location": "চট্টগ্রাম", "product": "সয়াবিন তেল", "quantity": 5, "urgent": true},
      {"name": "রহিম মার্ট", "location": "সিলেট", "product": "মসুর ডাল", "quantity": 8, "urgent": false},
      {"name": "ফাতিমা স্টোর", "location": "রাজশাহী", "product": "পেঁয়াজ", "quantity": 2, "urgent": true},
      {"name": "নাসির এন্টারপ্রাইজ", "location": "খুলনা", "product": "চিনি", "quantity": 6, "urgent": false},
      {"name": "সালমা ট্রেডিং", "location": "বরিশাল", "product": "গমের আটা", "quantity": 4, "urgent": true},
      {"name": "আব্দুল মার্ট", "location": "ঢাকা", "product": "ছোলা ডাল", "quantity": 7, "urgent": false},
      {"name": "রশিদ স্টোর", "location": "চট্টগ্রাম", "product": "সরিষার তেল", "quantity": 1, "urgent": true},
    ];

    final shop = shops[index];
    final isUrgent = shop["urgent"] as bool;
    final quantity = shop["quantity"] as int;

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
                shop["name"] as String,
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
                    shop["location"] as String,
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
                    shop["product"] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.inventory,
                  size: 14,
                  color: quantity < 5 ? Colors.red[700] : Colors.orange[700],
                ),
                const SizedBox(width: 4),
                Text(
                  "$quantity units",
                  style: TextStyle(
                    color: quantity < 5 ? Colors.red[700] : Colors.orange[700],
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
                  shopName: shop["name"] as String,
                  shopId: (shop["name"] as String).toLowerCase().replaceAll(' ', '_'),
                ),
              ),
            ),
            onLongPress: () => _contactShop(shop["name"] as String),
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
                        builder: (context) => const WholesalerAddProductScreen(),
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
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) {
                return _buildInventoryItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItem(int index) {
    final products = [
      {
        "name": "চাল সরু (প্রিমিয়াম)",
        "unit": "কেজি",
        "price": 85,
        "stock": 500,
      },
      {
        "name": "সয়াবিন তেল (পিউর)",
        "unit": "লিটার",
        "price": 170,
        "stock": 200,
      },
      {
        "name": "মসুর ডাল",
        "unit": "কেজি",
        "price": 125,
        "stock": 150,
      },
      {
        "name": "পেঁয়াজ (দেশি)",
        "unit": "কেজি",
        "price": 55,
        "stock": 80,
      },
      {
        "name": "চিনি (সাদা)",
        "unit": "কেজি",
        "price": 65,
        "stock": 300,
      },
      {
        "name": "গমের আটা",
        "unit": "কেজি",
        "price": 50,
        "stock": 250,
      },
      {
        "name": "ছোলা ডাল",
        "unit": "কেজি",
        "price": 95,
        "stock": 120,
      },
      {
        "name": "সরিষার তেল",
        "unit": "লিটার",
        "price": 180,
        "stock": 90,
      },
    ];

    final product = products[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(
            Icons.inventory_2,
            color: Colors.green[700],
          ),
        ),
        title: Text(
          product["name"] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Price: ৳${product["price"]}/${product["unit"]}"),
            Text(
              "Stock: ${product["stock"]} ${product["unit"]}",
              style: TextStyle(
                color: (product["stock"] as int) < 100 ? Colors.red : Colors.green,
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
            _handleInventoryAction(value, product["name"] as String);
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
          Text(
            "Shop Communications",
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
        "message": "চাল সরুর দাম কত?",
        "time": "২ মিনিট আগে",
        "unread": 2,
      },
      {
        "shop": "করিম ট্রেডার্স",
        "message": "তেলের স্টক আছে?",
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
            child: ListView.builder(
              itemCount: 10,
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
    final transactions = [
      {
        "shop": "আহমেদ স্টোর",
        "product": "চাল সরু",
        "quantity": "50 কেজি",
        "date": "২৫/০৭/২৫",
        "status": "Delivered"
      },
      {
        "shop": "করিম ট্রেডার্স",
        "product": "সয়াবিন তেল",
        "quantity": "20 লিটার",
        "date": "২৪/০৭/২৫",
        "status": "Pending"
      },
      {
        "shop": "রহিম মার্ট",
        "product": "মসুর ডাল",
        "quantity": "30 কেজি",
        "date": "২৩/০৭/২৫",
        "status": "Delivered"
      },
      {
        "shop": "ফাতিমা স্টোর",
        "product": "পেঁয়াজ",
        "quantity": "100 কেজি",
        "date": "২২/০৭/২৫",
        "status": "Processing"
      },
      {
        "shop": "নাসির এন্টারপ্রাইজ",
        "product": "চিনি",
        "quantity": "40 কেজি",
        "date": "২১/০৭/২৫",
        "status": "Delivered"
      },
      {
        "shop": "সালমা ট্রেডিং",
        "product": "গমের আটা",
        "quantity": "60 কেজি",
        "date": "২০/০৭/২৫",
        "status": "Delivered"
      },
      {
        "shop": "আব্দুল মার্ট",
        "product": "ছোলা ডাল",
        "quantity": "25 কেজি",
        "date": "১৯/০৭/২৫",
        "status": "Delivered"
      },
      {
        "shop": "রশিদ স্টোর",
        "product": "সরিষার তেল",
        "quantity": "15 লিটার",
        "date": "১৮/০৭/২৫",
        "status": "Cancelled"
      },
      {
        "shop": "হাসান ট্রেডার্স",
        "product": "চাল মোটা",
        "quantity": "80 কেজি",
        "date": "১৭/০৭/২৫",
        "status": "Delivered"
      },
      {
        "shop": "কবির স্টোর",
        "product": "তুলসী ডাল",
        "quantity": "35 কেজি",
        "date": "১৬/০৭/২৫",
        "status": "Delivered"
      },
    ];

    final transaction = transactions[index];
    final status = transaction["status"] as String;

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case "Delivered":
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case "Pending":
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case "Processing":
        statusColor = Colors.blue;
        statusIcon = Icons.sync;
        break;
      case "Cancelled":
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
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
          transaction["shop"] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${transaction["product"]} - ${transaction["quantity"]}"),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      transaction["date"] as String,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _changeTransactionStatus(transaction, index),
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
                          status,
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
          onPressed: () => _viewReceipt(transaction),
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
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildOfferItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferItem(int index) {
    final offers = [
      {
        "title": "চাল সরু বাল্ক ডিসকাউন্ট",
        "description": "১০০ কেজির উপর ১০% ছাড়",
        "validUntil": "৩১ জুলাই পর্যন্ত",
        "active": true
      },
      {
        "title": "তেল ও ডাল কম্বো অফার",
        "description": "একসাথে কিনলে ১৫% ছাড়",
        "validUntil": "২৮ জুলাই পর্যন্ত",
        "active": true
      },
      {
        "title": "নতুন গ্রাহক বোনাস",
        "description": "প্রথম অর্ডারে ২০% ছাড়",
        "validUntil": "৩০ জুলাই পর্যন্ত",
        "active": true
      },
      {
        "title": "দ্রুত ডেলিভারি অফার",
        "description": "২৪ ঘণ্টায় ডেলিভারি",
        "validUntil": "মেয়াদ শেষ",
        "active": false
      },
      {
        "title": "ঈদ স্পেশাল ডিল",
        "description": "সব পণ্যে ২৫% ছাড়",
        "validUntil": "মেয়াদ শেষ",
        "active": false
      },
    ];

    final offer = offers[index];
    final isActive = offer["active"] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isActive ? Colors.white : Colors.grey[100],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.yellow[100] : Colors.grey[200],
          child: Icon(
            Icons.local_offer,
            color: isActive ? Colors.yellow[700] : Colors.grey,
          ),
        ),
        title: Text(
          offer["title"] as String,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black : Colors.grey[600],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              offer["description"] as String,
              style: TextStyle(
                  color: isActive ? Colors.black87 : Colors.grey[600]),
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
                  offer["validUntil"] as String,
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
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: "edit", child: Text("Edit")),
            const PopupMenuItem(value: "duplicate", child: Text("Duplicate")),
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
                          builder: (context) => const WholesalerAddProductScreen(),
                        ),
                      );
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
            const Text("Upload an Excel or CSV file with your product catalog."),
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

  void _handleInventoryAction(String action, String productName) {
    switch (action) {
      case "edit":
        _editProduct(productName);
        break;
      case "history":
        _viewSupplyHistory(productName);
        break;
      case "delete":
        _deleteProduct(productName);
        break;
    }
  }

  void _editProduct(String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $productName"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Price per Unit",
                  prefixText: "৳",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Current Stock",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
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
                SnackBar(content: Text("$productName updated successfully!")),
              );
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
              final dates = ["2024-01-15", "2024-01-10", "2024-01-05", "2023-12-28", "2023-12-20"];
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
        content: Text("Are you sure you want to delete $productName from your inventory?"),
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

  void _exportCSV() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Exporting to CSV...")),
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

  void _changeTransactionStatus(Map<String, dynamic> transaction, int index) {
    final currentStatus = transaction["status"] as String;
    String selectedStatus = currentStatus;
    
    final statuses = ["Pending", "Processing", "Delivered", "Cancelled"];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Change Status - ${transaction["shop"]}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Product: ${transaction["product"]} - ${transaction["quantity"]}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text("Select new status:"),
              const SizedBox(height: 8),
              ...statuses.map((status) => RadioListTile<String>(
                title: Text(status),
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
              onPressed: selectedStatus == currentStatus ? null : () {
                Navigator.pop(context);
                setState(() {
                  // In a real app, this would update the database
                  // For now, we'll just show a snackbar
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Status changed from '$currentStatus' to '$selectedStatus'"),
                    backgroundColor: Colors.green[800],
                  ),
                );
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

  Widget _buildReceiptWidget(Map<String, dynamic> transaction) {
    final receiptNumber = "R${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    final currentDate = DateTime.now();
    final formattedDate = "${currentDate.day}/${currentDate.month}/${currentDate.year}";
    final formattedTime = "${currentDate.hour}:${currentDate.minute.toString().padLeft(2, '0')}";
    
    // Sample pricing calculation
    final unitPrice = _getUnitPrice(transaction["product"] as String);
    final quantity = _extractQuantity(transaction["quantity"] as String);
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
                        color: _getStatusColor(transaction["status"] as String),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction["status"] as String,
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
                _buildReceiptRow("Shop Name:", transaction["shop"] as String, isTitle: true),
                _buildReceiptRow("Location:", _getShopLocation(transaction["shop"] as String)),
                _buildReceiptRow("Contact:", "+880 1712-345678"),
                
                const SizedBox(height: 12),
                const Divider(),
                
                // Product Details
                const Text(
                  "Product Details:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildReceiptRow("Product:", transaction["product"] as String),
                _buildReceiptRow("Quantity:", transaction["quantity"] as String),
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
                  onPressed: () => _printReceipt(transaction, receiptNumber),
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

  double _extractQuantity(String quantityString) {
    // Extract number from strings like "50 কেজি", "20 লিটার"
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(quantityString);
    return match != null ? double.parse(match.group(1)!) : 1.0;
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
          shopName: shopName,
          shopId: shopName.toLowerCase().replaceAll(' ', '_'),
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
                      shopName: shopName,
                      shopId: shopName.toLowerCase().replaceAll(' ', '_'),
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
