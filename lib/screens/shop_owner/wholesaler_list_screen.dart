import 'package:flutter/material.dart';
import 'package:nitymulya/screens/shop_owner/wholesaler_chat_screen.dart';

class WholesalerListScreen extends StatefulWidget {
  const WholesalerListScreen({super.key});

  @override
  State<WholesalerListScreen> createState() => _WholesalerListScreenState();
}

class _WholesalerListScreenState extends State<WholesalerListScreen> {
  final List<Map<String, dynamic>> wholesalers = [
    {
      "name": "রহমান ট্রেডার্স",
      "unread": 2,
      "lastMessage": "নতুন দামের তালিকা আপডেট",
      "lastTime": "২ ঘণ্টা আগে",
      "online": true,
      "category": "চাল ও ডাল",
      "phone": "+880 1712-345678",
      "location": "চট্টগ্রাম"
    },
    {
      "name": "করিম এন্টারপ্রাইজ",
      "unread": 0,
      "lastMessage": "অর্ডার কনফার্ম করেছি",
      "lastTime": "৩ ঘণ্টা আগে",
      "online": false,
      "category": "তেল ও মসলা",
      "phone": "+880 1812-345679",
      "location": "ঢাকা"
    },
    {
      "name": "আলম ইমপোর্ট",
      "unread": 1,
      "lastMessage": "স্টক আভেইলেবল আছে",
      "lastTime": "৪৫ মিনিট আগে",
      "online": true,
      "category": "সবজি ও ফল",
      "phone": "+880 1912-345680",
      "location": "সিলেট"
    },
    {
      "name": "নিউ সুন্দরবন",
      "unread": 3,
      "lastMessage": "আগামীকাল ডেলিভারি দেব",
      "lastTime": "১ ঘণ্টা আগে",
      "online": true,
      "category": "মাছ ও মাংস",
      "phone": "+880 1612-345681",
      "location": "খুলনা"
    },
    {
      "name": "বরকত ট্রেডিং",
      "unread": 0,
      "lastMessage": "পেমেন্ট রিসিভ করেছি",
      "lastTime": "১ দিন আগে",
      "online": false,
      "category": "আটা ও বেকারি",
      "phone": "+880 1512-345682",
      "location": "রাজশাহী"
    },
    {
      "name": "শাহ ওয়্যারহাউস",
      "unread": 0,
      "lastMessage": "নতুন পণ্য এসেছে",
      "lastTime": "২ দিন আগে",
      "online": true,
      "category": "দুগ্ধজাত পণ্য",
      "phone": "+880 1412-345683",
      "location": "বরিশাল"
    },
  ];

  String searchQuery = "";
  String selectedCategory = "All";
  final List<String> categories = [
    "All",
    "চাল ও ডাল",
    "তেল ও মসলা",
    "সবজি ও ফল",
    "মাছ ও মাংস",
    "আটা ও বেকারি",
    "দুগ্ধজাত পণ্য"
  ];

  List<Map<String, dynamic>> get filteredWholesalers {
    return wholesalers.where((wholesaler) {
      final matchesSearch = wholesaler["name"]
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == "All" ||
          wholesaler["category"] == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Wholesaler Chat",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: WholesalerSearchDelegate(wholesalers),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search wholesalers...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategory == category;
                      
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          backgroundColor: Colors.grey[100],
                          selectedColor: Colors.purple[100],
                          checkmarkColor: Colors.purple[600],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Quick Stats
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Total Wholesalers",
                    "${wholesalers.length}",
                    Icons.business,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    "Online Now",
                    "${wholesalers.where((w) => w['online']).length}",
                    Icons.online_prediction,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    "Unread Messages",
                    "${wholesalers.map((w) => w['unread'] as int).reduce((a, b) => a + b)}",
                    Icons.message,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          
          // Wholesaler List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredWholesalers.length,
              itemBuilder: (context, index) {
                final wholesaler = filteredWholesalers[index];
                return _buildWholesalerCard(wholesaler);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddWholesalerDialog();
        },
        backgroundColor: Colors.purple[600],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Wholesaler",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWholesalerCard(Map<String, dynamic> wholesaler) {
    final unreadCount = wholesaler["unread"] as int;
    final isOnline = wholesaler["online"] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple[100],
              child: Text(
                (wholesaler["name"] as String)[0],
                style: TextStyle(
                  color: Colors.purple[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
          ],
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              wholesaler["lastMessage"] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 2),
                Text(
                  wholesaler["location"] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    wholesaler["category"] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.purple[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              wholesaler["lastTime"] as String,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.phone, size: 18),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Calling ${wholesaler["name"]}..."),
                        backgroundColor: Colors.green[600],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          final initial = (wholesaler["name"] as String)[0];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WholesalerChatScreen(
                wholesalerName: wholesaler["name"] as String,
                wholesalerInitial: initial,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddWholesalerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Wholesaler"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Wholesaler Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
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
                  content: Text("Wholesaler added successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
            ),
            child: const Text(
              "Add",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class WholesalerSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> wholesalers;

  WholesalerSearchDelegate(this.wholesalers);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = wholesalers
        .where((wholesaler) =>
            (wholesaler["name"] as String)
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final wholesaler = results[index];
        final initial = (wholesaler["name"] as String)[0];
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purple[100],
            child: Text(
              initial,
              style: TextStyle(
                color: Colors.purple[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(wholesaler["name"] as String),
          subtitle: Text(wholesaler["category"] as String),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WholesalerChatScreen(
                  wholesalerName: wholesaler["name"] as String,
                  wholesalerInitial: initial,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
