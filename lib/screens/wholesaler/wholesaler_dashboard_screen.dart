import 'package:flutter/material.dart';
import 'package:nitymulya/screens/wholesaler/wholesaler_add_product_screen.dart';
import 'package:nitymulya/screens/wholesaler/wholesaler_chat_screen.dart';
import 'package:nitymulya/screens/wholesaler/wholesaler_edit_product_screen.dart';

class WholesalerDashboardScreen extends StatefulWidget {
  const WholesalerDashboardScreen({super.key});

  @override
  State<WholesalerDashboardScreen> createState() => _WholesalerDashboardScreenState();
}

class _WholesalerDashboardScreenState extends State<WholesalerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int totalShops = 45;
  int newRequests = 12;
  int lowStockProducts = 8;
  int unreadMessages = 15;
  
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
      appBar: AppBar(
        title: const Text(
          "Wholesaler Panel",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => _showNotifications(),
              ),
              if (newRequests > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.yellow[600],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$newRequests',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.message),
                onPressed: () => _openMessageCenter(),
              ),
              if (unreadMessages > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.yellow[600],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$unreadMessages',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        "Total Shops\nSupplied",
                        "$totalShops",
                        Icons.store,
                        Colors.green[700]!,
                        Colors.green[50]!,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        "New Stock\nRequests",
                        "$newRequests",
                        Icons.shopping_cart,
                        Colors.yellow[700]!,
                        Colors.yellow[50]!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        "Products Low\nin Shops",
                        "$lowStockProducts",
                        Icons.warning,
                        Colors.red[700]!,
                        Colors.red[50]!,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        "Messages from\nShops",
                        "$unreadMessages",
                        Icons.chat,
                        Colors.blue[700]!,
                        Colors.blue[50]!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.green[800],
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green[800],
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(icon: Icon(Icons.monitor, size: 20), text: "Monitor"),
                Tab(icon: Icon(Icons.inventory, size: 20), text: "Inventory"),
                Tab(icon: Icon(Icons.chat, size: 20), text: "Chat"),
                Tab(icon: Icon(Icons.history, size: 20), text: "History"),
                Tab(icon: Icon(Icons.campaign, size: 20), text: "Offers"),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLowStockMonitorTab(),
                _buildInventoryTab(),
                _buildChatTab(),
                _buildHistoryTab(),
                _buildOffersTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActions(),
        backgroundColor: Colors.green[800],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Quick Action",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
              Icon(icon, color: color, size: 28),
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
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockMonitorTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Section
          Container(
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
                    Icon(Icons.monitor, color: Colors.green[800]),
                    const SizedBox(width: 8),
                    const Text(
                      "🛒 Low Stock Monitor",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Product Filter
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Product:", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            value: selectedProduct,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              isDense: true,
                            ),
                            items: products.map((product) => DropdownMenuItem(
                              value: product,
                              child: Text(product, style: const TextStyle(fontSize: 14)),
                            )).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedProduct = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Location:", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            value: selectedLocation,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              isDense: true,
                            ),
                            items: locations.map((location) => DropdownMenuItem(
                              value: location,
                              child: Text(location, style: const TextStyle(fontSize: 14)),
                            )).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedLocation = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Quantity Threshold
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Quantity Threshold:", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          TextFormField(
                            initialValue: quantityThreshold.toString(),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              isDense: true,
                              suffixText: "units",
                              prefixText: "< ",
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              quantityThreshold = int.tryParse(value) ?? 10;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          ElevatedButton.icon(
                            onPressed: () => _applyFilters(),
                            icon: const Icon(Icons.search, color: Colors.white),
                            label: const Text("Apply Filter", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[800],
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
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
                Text(shop["location"] as String),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  "${shop["product"]} - ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Current: $quantity units",
                  style: TextStyle(
                    color: quantity < 5 ? Colors.red[700] : Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.chat, color: Colors.white, size: 20),
                onPressed: () => _contactShop(shop["name"] as String),
                tooltip: "Contact Shop",
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.yellow[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.local_offer, color: Colors.white, size: 20),
                onPressed: () => _bulkOffer(shop["name"] as String),
                tooltip: "Bulk Offer",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addProduct(),
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
      {"name": "চাল সরু (প্রিমিয়াম)", "unit": "কেজি", "price": 85, "stock": 500, "priority": true},
      {"name": "সয়াবিন তেল (পিউর)", "unit": "লিটার", "price": 170, "stock": 200, "priority": false},
      {"name": "মসুর ডাল", "unit": "কেজি", "price": 125, "stock": 150, "priority": false},
      {"name": "পেঁয়াজ (দেশি)", "unit": "কেজি", "price": 55, "stock": 80, "priority": true},
      {"name": "চিনি (সাদা)", "unit": "কেজি", "price": 65, "stock": 300, "priority": false},
      {"name": "গমের আটা", "unit": "কেজি", "price": 50, "stock": 250, "priority": false},
      {"name": "ছোলা ডাল", "unit": "কেজি", "price": 95, "stock": 120, "priority": true},
      {"name": "সরিষার তেল", "unit": "লিটার", "price": 180, "stock": 90, "priority": false},
    ];

    final product = products[index];
    final isPriority = product["priority"] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPriority ? Colors.yellow[100] : Colors.green[100],
          child: Icon(
            Icons.inventory_2,
            color: isPriority ? Colors.yellow[700] : Colors.green[700],
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                product["name"] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (isPriority)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.yellow[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "⭐",
                  style: TextStyle(fontSize: 12),
                ),
              ),
          ],
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
            const PopupMenuItem(value: "priority", child: Text("Toggle Priority")),
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
        children: [
          // Chat Filter Tabs
          Container(
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
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Recent",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Text(
                      "Unread",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Text(
                      "By Product",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
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
      {"shop": "আহমেদ স্টোর", "message": "চাল সরুর দাম কত?", "time": "২ মিনিট আগে", "unread": 2, "product": "চাল"},
      {"shop": "করিম ট্রেডার্স", "message": "তেলের স্টক আছে?", "time": "১৫ মিনিট আগে", "unread": 0, "product": "তেল"},
      {"shop": "রহিম মার্ট", "message": "অর্ডার কনফার্ম", "time": "৩০ মিনিট আগে", "unread": 1, "product": "ডাল"},
      {"shop": "ফাতিমা স্টোর", "message": "ডেলিভারি কবে?", "time": "১ ঘণ্টা আগে", "unread": 3, "product": "পেঁয়াজ"},
      {"shop": "নাসির এন্টারপ্রাইজ", "message": "নতুন দামের তালিকা চাই", "time": "২ ঘণ্টা আগে", "unread": 0, "product": "চিনি"},
      {"shop": "সালমা ট্রেডিং", "message": "বাল্ক অর্ডার দিতে চাই", "time": "৩ ঘণ্টা আগে", "unread": 1, "product": "আটা"},
    ];

    final chat = chats[index];
    final unreadCount = chat["unread"] as int;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            (chat["shop"] as String)[0],
            style: TextStyle(
              color: Colors.blue[700],
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.yellow[600],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$unreadCount",
                  style: const TextStyle(
                    color: Colors.black,
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
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  chat["time"] as String,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    chat["product"] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.grey),
              onPressed: () => _attachFile(chat["shop"] as String),
              tooltip: "Attach Catalog",
            ),
            IconButton(
              icon: Icon(Icons.chat, color: Colors.green[800]),
              onPressed: () => _openChat(chat["shop"] as String),
              tooltip: "Open Chat",
            ),
          ],
        ),
      ),
    );
  }

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
                  label: const Text("Export PDF", style: TextStyle(color: Colors.white)),
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
                  label: const Text("Export CSV", style: TextStyle(color: Colors.white)),
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
      {"shop": "আহমেদ স্টোর", "product": "চাল সরু", "quantity": "50 কেজি", "date": "২৫/০৭/২৫", "status": "Delivered"},
      {"shop": "করিম ট্রেডার্স", "product": "সয়াবিন তেল", "quantity": "20 লিটার", "date": "২৪/০৭/২৫", "status": "Pending"},
      {"shop": "রহিম মার্ট", "product": "মসুর ডাল", "quantity": "30 কেজি", "date": "২৩/০৭/২৫", "status": "Delivered"},
      {"shop": "ফাতিমা স্টোর", "product": "পেঁয়াজ", "quantity": "100 কেজি", "date": "২২/০৭/২৫", "status": "Processing"},
      {"shop": "নাসির এন্টারপ্রাইজ", "product": "চিনি", "quantity": "40 কেজি", "date": "২১/০৭/২৫", "status": "Delivered"},
      {"shop": "সালমা ট্রেডিং", "product": "গমের আটা", "quantity": "60 কেজি", "date": "২০/০৭/২৫", "status": "Delivered"},
      {"shop": "আব্দুল মার্ট", "product": "ছোলা ডাল", "quantity": "25 কেজি", "date": "১৯/০৭/২৫", "status": "Delivered"},
      {"shop": "রশিদ স্টোর", "product": "সরিষার তেল", "quantity": "15 লিটার", "date": "১৮/০৭/২৫", "status": "Cancelled"},
      {"shop": "হাসান ট্রেডার্স", "product": "চাল মোটা", "quantity": "80 কেজি", "date": "১৭/০৭/২৫", "status": "Delivered"},
      {"shop": "কবির স্টোর", "product": "তুলসী ডাল", "quantity": "35 কেজি", "date": "১৬/০৭/২৫", "status": "Delivered"},
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
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  transaction["date"] as String,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
                  label: const Text("Create Offer", style: TextStyle(color: Colors.white)),
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
                  label: const Text("Broadcast All", style: TextStyle(color: Colors.white)),
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
        "target": "সব দোকান",
        "validUntil": "৩১ জুলাই পর্যন্ত",
        "active": true
      },
      {
        "title": "তেল ও ডাল কম্বো অফার",
        "description": "একসাথে কিনলে ১৫% ছাড়",
        "target": "নির্বাচিত দোকান",
        "validUntil": "২৮ জুলাই পর্যন্ত",
        "active": true
      },
      {
        "title": "নতুন গ্রাহক বোনাস",
        "description": "প্রথম অর্ডারে ২০% ছাড়",
        "target": "নতুন দোকান",
        "validUntil": "৩০ জুলাই পর্যন্ত",
        "active": true
      },
      {
        "title": "দ্রুত ডেলিভারি অফার",
        "description": "২৪ ঘণ্টায় ডেলিভারি",
        "target": "ঢাকার দোকান",
        "validUntil": "মেয়াদ শেষ",
        "active": false
      },
      {
        "title": "ঈদ স্পেশাল ডিল",
        "description": "সব পণ্যে ২৫% ছাড়",
        "target": "সব দোকান",
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
              style: TextStyle(color: isActive ? Colors.black87 : Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  "Target: ${offer["target"]}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
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

  // Action Methods
  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Notifications"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.shopping_cart, color: Colors.yellow[700]),
              title: const Text("New Stock Request"),
              subtitle: const Text("আহমেদ স্টোর থেকে চাল সরুর অর্ডার"),
            ),
            ListTile(
              leading: Icon(Icons.warning, color: Colors.red[700]),
              title: const Text("Urgent Stock Alert"),
              subtitle: const Text("৩টি দোকানে পণ্য শেষ হয়ে যাচ্ছে"),
            ),
            ListTile(
              leading: Icon(Icons.message, color: Colors.blue[700]),
              title: const Text("New Messages"),
              subtitle: const Text("৫টি নতুন বার্তা এসেছে"),
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

  void _openMessageCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Opening Message Center...")),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Settings"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile Settings"),
              onTap: () {
                Navigator.pop(context);
                _profileSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text("Business Info"),
              onTap: () {
                Navigator.pop(context);
                _businessInfo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Notification Settings"),
              onTap: () {
                Navigator.pop(context);
                _notificationSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation();
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

  void _profileSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Settings - Coming Soon!")),
    );
  }

  void _businessInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Business Info - Coming Soon!")),
    );
  }

  void _notificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notification Settings - Coming Soon!")),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout from your wholesaler account?"),
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

  void _showQuickActions() {
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
            ListTile(
              leading: Icon(Icons.campaign, color: Colors.yellow[700]),
              title: const Text("Broadcast Offer"),
              onTap: () {
                Navigator.pop(context);
                _createOffer();
              },
            ),
            ListTile(
              leading: Icon(Icons.add_box, color: Colors.green[800]),
              title: const Text("Add Product"),
              onTap: () {
                Navigator.pop(context);
                _addProduct();
              },
            ),
            ListTile(
              leading: Icon(Icons.message, color: Colors.blue[700]),
              title: const Text("Send Message to All"),
              onTap: () {
                Navigator.pop(context);
                _broadcastToAll();
              },
            ),
          ],
        ),
      ),
    );
  }

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

  void _contactShop(String shopName) {
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

  void _bulkOffer(String shopName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Creating bulk offer for $shopName")),
    );
  }

  void _addProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WholesalerAddProductScreen(),
      ),
    );
    
    if (result == true) {
      // Refresh the dashboard data
      setState(() {
        // In a real app, you would reload data from your database
        // For now, we'll just show a success message
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text("Product added successfully!"),
            ],
          ),
          backgroundColor: Colors.green[800],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _uploadCatalog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Upload Catalog - Coming Soon!")),
    );
  }

  void _handleInventoryAction(String action, String productName) async {
    // Get the product data based on product name
    final products = [
      {"name": "চাল সরু (প্রিমিয়াম)", "unit": "কেজি", "price": 85, "stock": 500, "priority": true},
      {"name": "সয়াবিন তেল (পিউর)", "unit": "লিটার", "price": 170, "stock": 200, "priority": false},
      {"name": "মসুর ডাল", "unit": "কেজি", "price": 125, "stock": 150, "priority": false},
      {"name": "পেঁয়াজ (দেশি)", "unit": "কেজি", "price": 55, "stock": 80, "priority": true},
      {"name": "চিনি (সাদা)", "unit": "কেজি", "price": 65, "stock": 300, "priority": false},
      {"name": "গমের আটা", "unit": "কেজি", "price": 50, "stock": 250, "priority": false},
      {"name": "ছোলা ডাল", "unit": "কেজি", "price": 95, "stock": 120, "priority": true},
      {"name": "সরিষার তেল", "unit": "লিটার", "price": 180, "stock": 90, "priority": false},
    ];

    final product = products.firstWhere(
      (p) => p['name'] == productName,
      orElse: () => {"name": productName, "unit": "কেজি", "price": 0, "stock": 0, "priority": false},
    );

    if (action == "edit") {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WholesalerEditProductScreen(product: product),
        ),
      );
      
      if (result != null) {
        if (result == 'deleted') {
          setState(() {
            // In a real app, you would remove the product from your database
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.delete, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Product deleted successfully"),
                ],
              ),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // Product was updated
          setState(() {
            // In a real app, you would update the product in your database
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Product updated successfully!"),
                ],
              ),
              backgroundColor: Colors.green[800],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else if (action == "history") {
      _showSupplyHistory(productName);
    } else if (action == "priority") {
      _togglePriority(productName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$action $productName - Coming Soon!")),
      );
    }
  }

  void _attachFile(String shopName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Attaching file for $shopName")),
    );
  }

  void _openChat(String shopName) {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Viewing receipt for ${transaction["shop"]}")),
    );
  }

  void _createOffer() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Create Offer - Coming Soon!")),
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

  void _showSupplyHistory(String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Supply History: $productName"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.history),
              title: Text("Last 30 days"),
              subtitle: Text("145 units supplied to 8 shops"),
            ),
            ListTile(
              leading: Icon(Icons.trending_up),
              title: Text("Average demand"),
              subtitle: Text("4.8 units per day"),
            ),
            ListTile(
              leading: Icon(Icons.store),
              title: Text("Top customer"),
              subtitle: Text("আহমেদ স্টোর (35 units)"),
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

  void _togglePriority(String productName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Priority status toggled for $productName"),
        backgroundColor: Colors.yellow[700],
      ),
    );
  }
}
