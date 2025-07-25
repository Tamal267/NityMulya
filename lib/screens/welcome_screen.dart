import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nitymulya/Screens/customers/product_detail_screen.dart';
import 'package:nitymulya/screens/auth/login_screen.dart';
import 'package:nitymulya/widgets/global_bottom_nav.dart';

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

  late AnimationController _controller;
  late Animation<double> _fadeIn;

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
      "title": "চাল",
      "unit": "কেজি",
      "low": 50,
      "high": 55,
      "image": "assets/image/1.jpg",
      "category": "চাল"
    },
    {
      "title": "আটা ও ময়দা",
      "unit": "কেজি",
      "low": 30,
      "high": 35,
      "image": "assets/image/2.jpg",
      "category": "আটা ও ময়দা"
    },
    {
      "title": "তেল",
      "unit": "লিটার",
      "low": 120,
      "high": 130,
      "image": "assets/image/14.jpg",
      "category": "তেল"
    },
    {
      "title": "ডাল",
      "unit": "কেজি",
      "low": 70,
      "high": 75,
      "image": "assets/image/3.jpg",
      "category": "ডাল"
    },
    {
      "title": "সবজি ও মসলা",
      "unit": "",
      "low": 20,
      "high": 25,
      "image": "assets/image/4.jpg",
      "category": "সবজি ও মসলা"
    },
    {
      "title": "মাছ ও গোশত",
      "unit": "",
      "low": 200,
      "high": 250,
      "image": "assets/image/5.jpg",
      "category": "মাছ ও গোশত"
    },
  ];

  List<Map<String, dynamic>> get filteredProducts {
    if (selectedCategory == "All") return products;
    return products.where((p) => p["category"] == selectedCategory).toList();
  }

  @override
  void initState() {
    super.initState();
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

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF079b11)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/image/logo.jpeg', height: 50),
                const SizedBox(height: 10),
                widget.userName == null
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text("Login / Sign Up"),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.userName!,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)),
                          Text(widget.userEmail ?? '',
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
              ],
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
            onTap: () {}, // optional: implement About screen
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text("Help & Support"),
            onTap: () {}, // optional: implement Help screen
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
          child: Text(
            "Welcome to NityMulya App!",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
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
                  hintText: "Search products",
                  prefixIcon: const Icon(Icons.search),
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
              child: ListView.builder(
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
                      }),
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
                        borderRadius: BorderRadius.circular(10)),
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
                                  fontSize: 12, color: Colors.grey),
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
                                        child: Icon(Icons.image_not_supported,
                                            size: 40, color: Colors.grey),
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
        bottomNavigationBar: const GlobalBottomNav(currentIndex: 0),
      ),
    );
  }
}
