import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nitymulya/screens/auth/login_screen.dart';
import 'package:nitymulya/screens/customers/product_detail_screen.dart';

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

//----------Sakif-------------------------------------------------///

  final List<Map<String, dynamic>> products = [
    // চাল (Rice)
    {
      "title": "চাল সরু (নাজির/মিনিকেট)",
      "unit": "প্রতি কেজি",
      "low": 75,
      "high": 85,
      "image": "assets/image/1.jpg",
      "category": "চাল সরু (নাজির/মিনিকেট)",
      "mainCategory": "চাল"
    },
    {
      "title": "চাল (মাঝারী)পাইজাম/আটাশ)",
      "unit": "প্রতি কেজি",
      "low": 60,
      "high": 70,
      "image": "assets/image/1.jpg",
      "category": "চাল (মাঝারী)পাইজাম/আটাশ)",
      "mainCategory": "চাল"
    },
    {
      "title": "চাল (মোটা)/স্বর্ণা/চায়না ইরি",
      "unit": "প্রতি কেজি",
      "low": 55,
      "high": 60,
      "image": "assets/image/1.jpg",
      "category": "চাল (মোটা)/স্বর্ণা/চায়না ইরি",
      "mainCategory": "চাল"
    },

    // আটা ও ময়দা (Flour)
    {
      "title": "আটা সাদা (খোলা)",
      "unit": "প্রতি কেজি",
      "low": 40,
      "high": 45,
      "image": "assets/image/2.jpg",
      "category": "আটা সাদা (খোলা)",
      "mainCategory": "আটা ও ময়দা"
    },
    {
      "title": "আটা (প্যাকেট)",
      "unit": "প্রতি কেজি প্যাঃ",
      "low": 50,
      "high": 55,
      "image": "assets/image/2.jpg",
      "category": "আটা (প্যাকেট)",
      "mainCategory": "আটা ও ময়দা"
    },
    {
      "title": "ময়দা (খোলা)",
      "unit": "প্রতি কেজি",
      "low": 50,
      "high": 60,
      "image": "assets/image/2.jpg",
      "category": "ময়দা (খোলা)",
      "mainCategory": "আটা ও ময়দา"
    },
    {
      "title": "ময়দা (প্যাকেট)",
      "unit": "প্রতি কেজি প্যাঃ",
      "low": 50,
      "high": 60,
      "image": "assets/image/2.jpg",
      "category": "ময়দা (প্যাকেট)",
      "mainCategory": "আটা ও ময়দা"
    },

    // তেল (Oil)
    {
      "title": "সয়াবিন তেল (লুজ)",
      "unit": "১ লিটার",
      "low": 162,
      "high": 170,
      "image": "assets/image/14.jpg",
      "category": "সয়াবিন তেল (লুজ)",
      "mainCategory": "তেল"
    },
    {
      "title": "সয়াবিন তেল (বোতল)",
      "unit": "5 লিটার",
      "low": 890,
      "high": 920,
      "image": "assets/image/14.jpg",
      "category": "সয়াবিন তেল (বোতল)",
      "mainCategory": "তেল"
    },
    {
      "title": "সয়াবিন তেল (বোতল)",
      "unit": "2 লিটার)",
      "low": 370,
      "high": 378,
      "image": "assets/image/14.jpg",
      "category": "সয়াবিন তেল (বোতল)",
      "mainCategory": "তেল"
    },
    {
      "title": "সয়াবিন তেল (বোতল)",
      "unit": "১ লিটার",
      "low": 185,
      "high": 190,
      "image": "assets/image/14.jpg",
      "category": "সয়াবিন তেল (বোতল)",
      "mainCategory": "তেল"
    },
    {
      "title": "পাম অয়েল (লুজ)",
      "unit": "প্রতি লিটার",
      "low": 150,
      "high": 155,
      "image": "assets/image/14.jpg",
      "category": "পাম অয়েল (লুজ)",
      "mainCategory": "তেল"
    },
    {
      "title": "সুপার পাম অয়েল (লুজ)",
      "unit": "প্রতি লিটার",
      "low": 152,
      "high": 155,
      "image": "assets/image/14.jpg",
      "category": "সুপার পাম অয়েল (লুজ)",
      "mainCategory": "তেল"
    },
    {
      "title": "রাইস ব্রান তেল (বোতল)",
      "unit": "৫ লিটার",
      "low": 1030,
      "high": 1080,
      "image": "assets/image/14.jpg",
      "category": "রাইস ব্রান তেল (বোতল)",
      "mainCategory": "তেল"
    },

    // ডাল (Lentils)
    {
      "title": "মশুর ডাল (বড় দানা)",
      "unit": "প্রতি কেজি",
      "low": 95,
      "high": 110,
      "image": "assets/image/3.jpg",
      "category": "মশুর ডাল (বড় দানা)",
      "mainCategory": "ডাল"
    },
    {
      "title": "মশুর ডাল (মাঝারী দানা)",
      "unit": "প্রতি কেজি",
      "low": 105,
      "high": 120,
      "image": "assets/image/3.jpg",
      "category": "মশুর ডাল (মাঝারী দানা)",
      "mainCategory": "ডাল"
    },
    {
      "title": "মশুর ডাল (ছোট দানা)",
      "unit": "প্রতি কেজি",
      "low": 130,
      "high": 140,
      "image": "assets/image/3.jpg",
      "category": "মশুর ডাল (ছোট দানা)",
      "mainCategory": "ডাল"
    },
    {
      "title": "মুগ ডাল (মানভেদে)",
      "unit": "প্রতি কেজি",
      "low": 110,
      "high": 180,
      "image": "assets/image/3.jpg",
      "category": "মুগ ডাল (মানভেদে)",
      "mainCategory": "ডাল"
    },
    {
      "title": "এ্যাংকর ডাল",
      "unit": "প্রতি কেজি",
      "low": 55,
      "high": 80,
      "image": "assets/image/3.jpg",
      "category": "এ্যাংকর ডাল",
      "mainCategory": "ডাল"
    },
    {
      "title": "ছোলা (মানভেদে)",
      "unit": "প্রতি কেজি",
      "low": 90,
      "high": 110,
      "image": "assets/image/3.jpg",
      "category": "ছোলা (মানভেদে)",
      "mainCategory": "ডাল"
    },

    // সবজি ও মসলা (Vegetables & Spices)
    {
      "title": "আলু (মানভেদে)",
      "unit": "প্রতি কেজি",
      "low": 25,
      "high": 30,
      "image": "assets/image/4.jpg",
      "category": "আলু (মানভেদে)",
      "mainCategory": "সবজি ও মসলা"
    },
    {
      "title": "পিঁয়াজ (দেশী)",
      "unit": "প্রতি কেজি",
      "low": 55,
      "high": 65,
      "image": "assets/image/4.jpg",
      "category": "পিঁয়াজ (দেশী)",
      "mainCategory": "সবজি ও মসলা"
    },
    {
      "title": "পিঁয়াজ (আমদানি)",
      "unit": "প্রতি কেজি",
      "low": "",
      "high": "",
      "image": "assets/image/4.jpg",
      "category": "পিঁয়াজ (আমদানি)",
      "mainCategory": "সবজি ও মসলা"
    },
    {
      "title": "রসুন (দেশী)",
      "unit": "প্রতি কেজি",
      "low": 100,
      "high": 150,
      "image": "assets/image/4.jpg",
      "category": "রসুন (দেশী)",
      "mainCategory": "সবজি ও মসলা"
    },
    {
      "title": "রসুন (আমদানি)",
      "unit": "প্রতি কেজি",
      "low": 160,
      "high": 200,
      "image": "assets/image/4.jpg",
      "category": "রসুন (আমদানি)",
      "mainCategory": "সবজি ও মসলা"
    },
    {
      "title": "শুকনা মরিচ (দেশী)",
      "unit": "প্রতি কেজি",
      "low": 240,
      "high": 350,
      "image": "assets/image/4.jpg",
      "category": "শুকনা মরিচ (দেশী)",
      "mainCategory": "সবজি ও মসলা"
    },
    {
      "title": "শুকনা মরিচ (আমদানি)",
      "unit": "প্রতি কেজি",
      "low": 300,
      "high": 450,
      "image": "assets/image/4.jpg",
      "category": "শুকনা মরিচ (আমদানি)",
      "mainCategory": "সবজি ও মসলা"
    },
    {
      "title": "হলুদ (দেশী)",
      "unit": "প্রতি কেজি",
      "low": 300,
      "high": 400,
      "image": "assets/image/4.jpg",
      "category": "হলুদ (দেশী)",
      "mainCategory": "সবজি ও মসলা"
    },
    {
      "title": "হলুদ (আমদানি)",
      "unit": "প্রতি কেজি",
      "low": 300,
      "high": 420,
      "image": "assets/image/4.jpg",
      "category": "হলুদ (আমদানি)",
      "mainCategory": "সবজি ও মসলা"
    },
    {
      "title": "আদা (দেশী)",
      "unit": "প্রতি কেজি",
      "low": "",
      "high": "",
      "image": "assets/image/4.jpg",
      "category": "আদা (দেশী)",
      "mainCategory": "সবজি ও মসলা"
    },
    {
      "title": "আদা (আমদানি)",
      "unit": "প্রতি কেজি",
      "low": 120,
      "high": 180,
      "image": "assets/image/4.jpg",
      "category": "আদা (আমদানি)",
      "mainCategory": "সবজি ও মসলা"
    },
    {
      "title": "জিরা",
      "unit": "প্রতি কেজি",
      "low": 600,
      "high": 750,
      "image": "assets/image/4.jpg",
      "category": "জিরা",
      "mainCategory": "সবজি ও মসলা"
    },
    {
      "title": "দারুচিনি",
      "unit": "প্রতি কেজি",
      "low": 500,
      "high": 600,
      "image": "assets/image/4.jpg",
      "category": "দারুচিনি",
      "mainCategory": "সবজি ও মসলা"
    },
    {
      "title": "লবঙ্গ",
      "unit": "প্রতি কেজি",
      "low": 1400,
      "high": 1600,
      "image": "assets/image/4.jpg",
      "category": "লবঙ্গ",
      "mainCategory": "সবজি ও মসলা"
    },
    {
      "title": "এলাচ(ছোট)",
      "unit": "প্রতি কেজি",
      "low": 4400,
      "high": 5200,
      "image": "assets/image/4.jpg",
      "category": "এলাচ(ছোট)",
      "mainCategory": "সবজি ও মসলা"
    },
    {
      "title": "ধনে পাতা",
      "unit": "প্রতি কেজি",
      "low": 180,
      "high": 280,
      "image": "assets/image/4.jpg",
      "category": "ধনে পাতা",
      "mainCategory": "সবজি ও মসলা"
    },
    {
      "title": "তেজপাতা",
      "unit": "প্রতি কেজি",
      "low": 180,
      "high": 220,
      "image": "assets/image/4.jpg",
      "category": "তেজপাতা",
      "mainCategory": "সবজি ও মসলা"
    },

    // মাছ ও গোশত (Fish & Meat)
    {
      "title": "রুই মাছ",
      "unit": "প্রতি কেজি",
      "low": 300,
      "high": 450,
      "image": "assets/image/5.jpg",
      "category": "রুই মাছ",
      "mainCategory": "মাছ ও গোশত"
    },
    {
      "title": "ইলিশ মাছ",
      "unit": "প্রতি কেজি",
      "low": 1000,
      "high": 2000,
      "image": "assets/image/5.jpg",
      "category": "ইলিশ মাছ",
      "mainCategory": "মাছ ও গোশত"
    },
    {
      "title": "গরু গোশত",
      "unit": "প্রতি কেজি",
      "low": 750,
      "high": 800,
      "image": "assets/image/5.jpg",
      "category": "গরু গোশত",
      "mainCategory": "মাছ ও গোশত"
    },
    {
      "title": "খাসী গোশত",
      "unit": "প্রতি কেজি",
      "low": 1100,
      "high": 1250,
      "image": "assets/image/5.jpg",
      "category": "খাসী গোশত",
      "mainCategory": "মাছ ও গোশت"
    },
    {
      "title": "মুরগী(ব্রয়লার)",
      "unit": "প্রতি কেজি",
      "low": 150,
      "high": 170,
      "image": "assets/image/5.jpg",
      "category": "মুরগী(ব্রয়লার)",
      "mainCategory": "মাছ ও গোশত"
    },
    {
      "title": "মুরগী (দেশী)",
      "unit": "প্রতি কেজি",
      "low": 580,
      "high": 700,
      "image": "assets/image/5.jpg",
      "category": "মুরগী (দেশী)",
      "mainCategory": "মাছ ও গোশত"
    },

    // দুধ (Milk)
    {
      "title": "ডানো",
      "unit": "প্রতি কেজি",
      "low": 720,
      "high": 860,
      "image": "assets/image/5.jpg",
      "category": "ডানো",
      "mainCategory": "দুধ"
    },
    {
      "title": "ডিপ্লোমা (নিউজিল্যান্ড)",
      "unit": "প্রতি কেজি",
      "low": 840,
      "high": 910,
      "image": "assets/image/5.jpg",
      "category": "ডিপ্লোমা (নিউজিল্যান্ড)",
      "mainCategory": "দুধ"
    },
    {
      "title": "ফ্রেশ",
      "unit": "প্রতি কেজি",
      "low": 830,
      "high": 890,
      "image": "assets/image/5.jpg",
      "category": "ফ্রেশ",
      "mainCategory": "দুধ"
    },
    {
      "title": "মার্কস",
      "unit": "প্রতি কেজি",
      "low": 830,
      "high": 900,
      "image": "assets/image/5.jpg",
      "category": "মার্কস",
      "mainCategory": "দুধ"
    },

    // Other items
    {
      "title": "চিনি",
      "unit": "প্রতি কেজি",
      "low": 105,
      "high": 115,
      "image": "assets/image/5.jpg",
      "category": "চিনি",
      "mainCategory": "All" // Or create new category
    },
    {
      "title": "খেজুর(সাধারণ মানের)",
      "unit": "প্রতি কেজি",
      "low": 250,
      "high": 550,
      "image": "assets/image/5.jpg",
      "category": "খেজুর(সাধারণ মানের)",
      "mainCategory": "All" // Or create new category
    },
    {
      "title": "লবণ(প্যাঃ)আয়োডিনযুক্ত",
      "unit": "প্রতি কেজি",
      "low": 38,
      "high": 42,
      "image": "assets/image/5.jpg",
      "category": "লবণ(প্যাঃ)আয়োডিনযুক্ত",
      "mainCategory": "All" // Or create new category
    },
    {
      "title": "ডিম (ফার্ম)",
      "unit": "প্রতি হালি",
      "low": 38,
      "high": 46,
      "image": "assets/image/5.jpg",
      "category": "ডিম (ফার্ম)",
      "mainCategory": "All" // Or create new category
    },
    {
      "title": "লেখার কাগজ(সাদা)",
      "unit": "প্রতি দিস্তা",
      "low": 30,
      "high": 40,
      "image": "assets/image/5.jpg",
      "category": "লেখার কাগজ(সাদা)",
      "mainCategory": "All" // Or create new category
    }
  ];
//----------Sakif-------------------------------------------------///

  List<Map<String, dynamic>> get filteredProducts {
    if (selectedCategory == "All") return products;
    return products
        .where((p) => p["mainCategory"] == selectedCategory)
        .toList();
  }

//-----------------------------------Mithila --------------------//
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

//---------Mithila----------

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // Remove default padding
        children: [
          SizedBox(
            height: 220, // Fixed height instead of DrawerHeader
            child: Container(
              decoration: const BoxDecoration(color: Color(0xFF079b11)),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/image/logo.jpeg',
                        height: 90,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (widget.userName == null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        minimumSize:
                            const Size(150, 40), // Constrained button size
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text(
                        "Login / Sign Up",
                        style: TextStyle(fontSize: 14),
                      ),
                    )
                  else
                    Column(
                      children: [
                        Text(
                          widget.userName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16, // Slightly smaller
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.userEmail ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12, // Smaller email text
                          ),
                        ),
                      ],
                    ),
                ],
              ),
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
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text("Help & Support"),
            onTap: () {},
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular image with border
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.green.shade800, // Border color
                    width: 3.0, // Border width
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/image/logo.jpeg',
                    height: 150, // Adjust size as needed
                    width: 150,
                    fit: BoxFit.cover, // Ensures the image fills the circle
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Welcome to NityMulya App!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
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

        //  bottomNavigationBar: const GlobalBottomNav(currentIndex: 0),
        //----------Mithila---------//
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0, // Current selected index
          selectedItemColor:
              const Color(0xFF079b11), // Green color for selected tab
          unselectedItemColor: Colors.grey, // Grey for unselected tabs
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shops'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: 'Favorites'),
          ],
          onTap: (index) {
            if (index == 1 || index == 2) {
              // Both Shops and Favorites tabs
              _handleRestrictedAction();
            }
            // Home tab (index 0) does nothing since we're already there
          },
        ),
      ),
    );
  }
}
