import 'package:flutter/material.dart';
import 'package:nitymulya/screens/customers/ShopListScreen.dart';
import 'ProductDetailScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "All";
  String searchQuery = "";
  bool isDarkMode = false;
  bool isBangla = true;

  final List<String> categories = [
    "All", "চাল", "আটা ও ময়দা", "তেল", "ডাল", "সবজি ও মসলা", "মাছ ও গোশত", "দুধ"
  ];



  final List<Map<String, dynamic>> products = [
    // চাল
    {"title": "চাল সরু (নাজির/মিনিকেট)", "unit": "প্রতি কেজি", "low": 75, "high": 85, "category": "চাল", "image": "https://via.placeholder.com/150"},
    {"title": "চাল (মাঝারী) পাইজাম/আটাশ", "unit": "প্রতি কেজি", "low": 60, "high": 70, "category": "চাল", "image": "https://via.placeholder.com/150"},
    {"title": "চাল (মোটা)/স্বর্ণা/চায়না ইরি", "unit": "প্রতি কেজি", "low": 55, "high": 60, "category": "চাল", "image": "https://via.placeholder.com/150"},

    // আটা ও ময়দা
    {"title": "আটা সাদা (খোলা)", "unit": "প্রতি কেজি", "low": 40, "high": 45, "category": "আটা ও ময়দা", "image": "https://via.placeholder.com/150"},
    {"title": "আটা (প্যাকেট)", "unit": "প্রতি কেজি প্যাঃ", "low": 50, "high": 55, "category": "আটা ও ময়দা", "image": "https://via.placeholder.com/150"},
    {"title": "ময়দা (খোলা)", "unit": "প্রতি কেজি", "low": 50, "high": 60, "category": "আটা ও ময়দা", "image": "https://via.placeholder.com/150"},
    {"title": "ময়দা (প্যাকেট)", "unit": "প্রতি কেজি প্যাঃ", "low": 65, "high": 70, "category": "আটা ও ময়দা", "image": "https://via.placeholder.com/150"},

    // তেল
    {"title": "সয়াবিন তেল (লুজ)", "unit": "প্রতি লিটার", "low": 160, "high": 170, "category": "তেল", "image": "https://via.placeholder.com/150"},
    {"title": "সয়াবিন তেল (বোতল) ৫ লিটার", "unit": "৫ লিটার", "low": 880, "high": 920, "category": "তেল", "image": "https://via.placeholder.com/150"},
    {"title": "সয়াবিন তেল (বোতল) ২ লিটার", "unit": "২ লিটার", "low": 370, "high": 378, "category": "তেল", "image": "https://via.placeholder.com/150"},
    {"title": "সয়াবিন তেল (বোতল) ১ লিটার", "unit": "১ লিটার", "low": 185, "high": 190, "category": "তেল", "image": "https://via.placeholder.com/150"},
    {"title": "পাম অয়েল (লুজ)", "unit": "প্রতি লিটার", "low": 147, "high": 155, "category": "তেল", "image": "https://via.placeholder.com/150"},
    {"title": "সুপার পাম অয়েল (লুজ)", "unit": "প্রতি লিটার", "low": 152, "high": 160, "category": "তেল", "image": "https://via.placeholder.com/150"},
    {"title": "রাইস ব্রান তেল (বোতল) ৫ লিটার", "unit": "৫ লিটার", "low": 1030, "high": 1080, "category": "তেল", "image": "https://via.placeholder.com/150"},

    // ডাল
    {"title": "মশুর ডাল (বড় দানা)", "unit": "প্রতি কেজি", "low": 100, "high": 110, "category": "ডাল", "image": "https://via.placeholder.com/150"},
    {"title": "মশুর ডাল (মাঝারী দানা)", "unit": "প্রতি কেজি", "low": 105, "high": 120, "category": "ডাল", "image": "https://via.placeholder.com/150"},
    {"title": "মশুর ডাল (ছোট দানা)", "unit": "প্রতি কেজি", "low": 125, "high": 135, "category": "ডাল", "image": "https://via.placeholder.com/150"},
    {"title": "মুগ ডাল (মানভেদে)", "unit": "প্রতি কেজি", "low": 125, "high": 180, "category": "ডাল", "image": "https://via.placeholder.com/150"},
    {"title": "এ্যাংকর ডাল", "unit": "প্রতি কেজি", "low": 50, "high": 80, "category": "ডাল", "image": "https://via.placeholder.com/150"},
    {"title": "ছোলা (মানভেদে)", "unit": "প্রতি কেজি", "low": 90, "high": 110, "category": "ডাল", "image": "https://via.placeholder.com/150"},

    // মাছ ও গোশত
    {"title": "রুই", "unit": "প্রতি কেজি", "low": 300, "high": 450, "category": "মাছ ও গোশত", "image": "https://via.placeholder.com/150"},
    {"title": "ইলিশ", "unit": "প্রতি কেজি", "low": 900, "high": 2000, "category": "মাছ ও গোশত", "image": "https://via.placeholder.com/150"},
    {"title": "গরু", "unit": "প্রতি কেজি", "low": 750, "high": 800, "category": "মাছ ও গোশত", "image": "https://via.placeholder.com/150"},
    {"title": "খাসী", "unit": "প্রতি কেজি", "low": 1100, "high": 1250, "category": "মাছ ও গোশত", "image": "https://via.placeholder.com/150"},
    {"title": "মুরগী (ব্রয়লার)", "unit": "প্রতি কেজি", "low": 150, "high": 170, "category": "মাছ ও গোশত", "image": "https://via.placeholder.com/150"},
    {"title": "মুরগী (দেশী)", "unit": "প্রতি কেজি", "low": 580, "high": 700, "category": "মাছ ও গোশত", "image": "https://via.placeholder.com/150"},

    // দুধ
    {"title": "ডানো গুঁড়া দুধ", "unit": "১ কেজি", "low": 720, "high": 860, "category": "দুধ", "image": "https://via.placeholder.com/150"},
    {"title": "ডিপ্লোমা (নিউজিল্যান্ড) গুঁড়া দুধ", "unit": "১ কেজি", "low": 840, "high": 910, "category": "দুধ", "image": "https://via.placeholder.com/150"},
    {"title": "ফ্রেশ গুঁড়া দুধ", "unit": "১ কেজি", "low": 830, "high": 890, "category": "দুধ", "image": "https://via.placeholder.com/150"},
    {"title": "মার্কস গুঁড়া দুধ", "unit": "১ কেজি", "low": 830, "high": 900, "category": "দুধ", "image": "https://via.placeholder.com/150"},
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
      debugShowCheckedModeBanner: false,  // disable debug banner
      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: const Color(0xFF079b11),
      ),
      home: Scaffold(
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
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF079b11)),
                child: Column(
                  children: [
                    Image.asset("assets/image/logo.jpeg", height: 60),
                    const SizedBox(height: 10),
                    const Text("NitiMulya", style: TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: () {},
                      child: const Text("Login / Sign up", style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
              const ListTile(leading: Icon(Icons.info), title: Text("Information")),
              ListTile(leading: const Icon(Icons.report_problem), title: const Text("Complain"),
                  onTap: () => Navigator.pushNamed(context, '/complaints')),
              const ListTile(leading: Icon(Icons.help), title: Text("Help")),
              const ListTile(leading: Icon(Icons.support), title: Text("Customer Support")),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            // typeahead suggestion box
            if (searchQuery.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  child: ListView(
                    shrinkWrap: true,
                    children: products
                        .where((p) => p["title"].contains(searchQuery))
                        .map((p) => ListTile(
                      title: Text(p["title"]),
                      onTap: () {
                        setState(() {
                          searchQuery = p["title"];
                        });
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  if (searchQuery.isNotEmpty && !product["title"].contains(searchQuery)) {
                    return const SizedBox.shrink();
                  }
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              title: product["title"],
                              unit: product["unit"],
                              low: product["low"],
                              high: product["high"],
                            )));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 4)
                          )],
                          color: isDarkMode ? Colors.grey[800] : Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(product["title"],
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(product["unit"],
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(product["image"], fit: BoxFit.cover),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text("৳${product["low"]} - ৳${product["high"]}",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopListScreen()));
            } else if (index == 2) {
              Navigator.pushNamed(context, '/favorites');
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.shop), label: "Shop"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
          ],
        ),
      ),
    );
  }
}
