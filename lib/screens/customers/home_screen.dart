import 'package:flutter/material.dart';
import 'package:nitymulya/widgets/custom_drawer.dart';
import 'package:nitymulya/widgets/global_bottom_nav.dart';

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

  final List<String> categories = [
    "All",
    "চাল",
    "আটা ও ময়দা",
    "তেল",
    "ডাল",
    "সবজি ও মসলা",
    "মাছ ও গোশত",
    "দুধ"
  ];

  final List<Map<String, dynamic>> products = [
    {
      "title": "চাল সরু (নাজির/মিনিকেট)",
      "unit": "প্রতি কেজি",
      "low": 75,
      "high": 85,
      "category": "চাল",
      "image": "assets/image/1.jpg"
    },
    {
      "title": "চাল মোটা (পাইলস)",
      "unit": "প্রতি কেজি",
      "low": 55,
      "high": 65,
      "category": "চাল",
      "image": "assets/image/2.jpg"
    },
    {
      "title": "গমের আটা (প্রিমিয়াম)",
      "unit": "প্রতি কেজি",
      "low": 45,
      "high": 50,
      "category": "আটা ও ময়দা",
      "image": "assets/image/3.jpg"
    },
    {
      "title": "সয়াবিন তেল (পিউর)",
      "unit": "প্রতি লিটার",
      "low": 160,
      "high": 175,
      "category": "তেল",
      "image": "assets/image/4.jpg"
    },
    {
      "title": "মসুর ডাল",
      "unit": "প্রতি কেজি",
      "low": 115,
      "high": 125,
      "category": "ডাল",
      "image": "assets/image/5.jpg"
    },
    {
      "title": "পেঁয়াজ (দেশি)",
      "unit": "প্রতি কেজি",
      "low": 50,
      "high": 60,
      "category": "সবজি ও মসলা",
      "image": "assets/image/6.jpg"
    },
    {
      "title": "রুই মাছ",
      "unit": "প্রতি কেজি",
      "low": 350,
      "high": 400,
      "category": "মাছ ও গোশত",
      "image": "assets/images/7.jpg"
    },
    {
      "title": "গরুর দুধ",
      "unit": "প্রতি লিটার",
      "low": 60,
      "high": 70,
      "category": "দুধ",
      "image": "assets/image/8.jpg"
    },
  ];

  List<Map<String, dynamic>> get filteredProducts {
    if (selectedCategory == "All") {
      return products;
    }
    return products.where((p) => p["category"] == selectedCategory).toList();
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
                  hintText: "Search products",
                  prefixIcon: const Icon(Icons.search),
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
                  child: ListView(
                    shrinkWrap: true,
                    children: products
                        .where((p) => p["title"]
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                        .map((p) => ListTile(
                              title: Text(p["title"]),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(
                                      title: p["title"],
                                      unit: p["unit"],
                                      low: p["low"],
                                      high: p["high"],
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
              child: ListView.builder(
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
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: GridView.builder(
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
                  if (searchQuery.isNotEmpty &&
                      !product["title"]
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase())) {
                    return const SizedBox.shrink();
                  }
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
                              title: product["title"],
                              unit: product["unit"],
                              low: product["low"],
                              high: product["high"],
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
                              product["title"],
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
                              product["unit"],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  product["image"],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 8, left: 8, right: 8),
                            child: Text(
                              "৳${product["low"]} - ৳${product["high"]}",
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
        bottomNavigationBar: const GlobalBottomNav(
          currentIndex: 0,
        ),
      ),
    );
  }
}
