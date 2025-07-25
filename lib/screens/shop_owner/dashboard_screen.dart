import 'package:flutter/material.dart';
import 'package:nitymulya/screens/shop_owner/add_product_screen.dart';
import 'package:nitymulya/screens/shop_owner/update_product_screen.dart';
import 'package:nitymulya/screens/shop_owner/wholesaler_chat_screen.dart';
import 'package:nitymulya/screens/shop_owner/wholesaler_list_screen.dart';
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
    drawer: CustomDrawer( // ✅ This is newly added
    userName: "Shop Owner",
    userEmail: "owner@example.com",
    userRole: "Shop",
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
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
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
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) {
                return _buildProductCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(int index) {
    final products = [
      {
        "name": "চাল সরু (নাজির/মিনিকেট)",
        "quantity": 50,
        "price": 80,
        "lowStock": false
      },
      {
        "name": "সয়াবিন তেল (পিউর)",
        "quantity": 5,
        "price": 170,
        "lowStock": true
      },
      {"name": "মসুর ডাল", "quantity": 25, "price": 120, "lowStock": false},
      {"name": "পেঁয়াজ (দেশি)", "quantity": 3, "price": 55, "lowStock": true},
      {
        "name": "গমের আটা (প্রিমিয়াম)",
        "quantity": 30,
        "price": 48,
        "lowStock": false
      },
      {"name": "রুই মাছ", "quantity": 15, "price": 375, "lowStock": false},
      {"name": "গরুর দুধ", "quantity": 2, "price": 65, "lowStock": true},
      {
        "name": "চাল মোটা (পাইলস)",
        "quantity": 40,
        "price": 60,
        "lowStock": false
      },
    ];

    final product = products[index];
    final isLowStock = product["lowStock"] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLowStock ? Colors.red[100] : Colors.green[100],
          child: Icon(
            Icons.inventory,
            color: isLowStock ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          product["name"] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Quantity: ${product["quantity"]} units"),
            Text("Price: ৳${product["price"]} per unit"),
            if (isLowStock)
              const Text(
                "⚠️ Low Stock",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
            _handleProductAction(value, product["name"] as String);
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
                  Icon(Icons.info, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Click on Pending orders to confirm or reject",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
                  onPressed: () {
                    _viewAllOrders();
                  },
                  icon: const Icon(Icons.list),
                  label: const Text("View All Orders"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showOrderStats();
                  },
                  icon: const Icon(Icons.analytics),
                  label: const Text("Statistics"),
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
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildOrderCard(index);
              },
            ),
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
      // Refresh the dashboard data
      setState(() {
        // In a real app, you would reload data from your database
        // For now, we'll just update the total products count
        totalProducts++;
      });
    }
  }

  void _handleProductAction(String action, String productName) async {
    final products = [
      {
        "name": "চাল সরু (নাজির/মিনিকেট)",
        "quantity": 50,
        "price": 80,
        "lowStock": false
      },
      {
        "name": "সয়াবিন তেল (পিউর)",
        "quantity": 5,
        "price": 170,
        "lowStock": true
      },
      {"name": "মসুর ডাল", "quantity": 25, "price": 120, "lowStock": false},
      {"name": "পেঁয়াজ (দেশি)", "quantity": 3, "price": 55, "lowStock": true},
      {
        "name": "গমের আটা (প্রিমিয়াম)",
        "quantity": 30,
        "price": 48,
        "lowStock": false
      },
      {"name": "রুই মাছ", "quantity": 15, "price": 375, "lowStock": false},
      {"name": "গরুর দুধ", "quantity": 2, "price": 65, "lowStock": true},
      {
        "name": "চাল মোটা (পাইলস)",
        "quantity": 40,
        "price": 60,
        "lowStock": false
      },
    ];

    final product = products.firstWhere(
      (p) => p['name'] == productName,
      orElse: () =>
          {"name": productName, "quantity": 0, "price": 0, "lowStock": false},
    );

    if (action == "edit") {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateProductScreen(product: product),
        ),
      );

      if (result != null) {
        if (result == 'deleted') {
          setState(() {
            totalProducts =
                (totalProducts - 1).clamp(0, double.infinity).toInt();
          });
        } else {
          // Product was updated
          setState(() {
            // In a real app, you would update the product in your database
            // and refresh the list
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$action $productName - Coming Soon!")),
      );
    }
  }

  void _viewAllOrders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("View All Orders - Coming Soon!")),
    );
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
}
