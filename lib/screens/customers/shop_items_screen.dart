import 'package:flutter/material.dart';

import '../../models/shop.dart';
import 'product_detail_screen.dart';

class ShopItemsScreen extends StatefulWidget {
  final Shop shop;

  const ShopItemsScreen({
    super.key,
    required this.shop,
  });

  @override
  State<ShopItemsScreen> createState() => _ShopItemsScreenState();
}

class _ShopItemsScreenState extends State<ShopItemsScreen> {
  String searchQuery = "";

  // Mock product data for the shop - in a real app, this would come from an API
  late List<Map<String, dynamic>> shopProducts;

  @override
  void initState() {
    super.initState();
    _initializeShopProducts();
  }

  void _initializeShopProducts() {
    // Create mock product data based on shop's available products
    shopProducts = widget.shop.availableProducts.map((productName) {
      return _getProductDetails(productName);
    }).toList();
  }

  Map<String, dynamic> _getProductDetails(String productName) {
    // Mock product details - in a real app, this would come from a database
    final productData = {
      "চাল সরু (নাজির/মিনিকেট)": {
        "title": "চাল সরু (নাজির/মিনিকেট)",
        "unit": "প্রতি কেজি",
        "low": 75,
        "high": 85,
        "category": "চাল",
        "image": "assets/images/im_1.jpg",
        "description": "উন্নত মানের সরু চাল। রান্নার পর ঝরঝরে এবং স্বাদযুক্ত।",
        "availability": "In Stock",
      },
      "চাল মোটা (পাইলস)": {
        "title": "চাল মোটা (পাইলস)",
        "unit": "প্রতি কেজি",
        "low": 55,
        "high": 65,
        "category": "চাল",
        "image": "assets/images/im_2.jpg",
        "description": "মোটা ধানের চাল। পুষ্টিকর এবং সাশ্রয়ী।",
        "availability": "In Stock",
      },
      "গমের আটা (প্রিমিয়াম)": {
        "title": "গমের আটা (প্রিমিয়াম)",
        "unit": "প্রতি কেজি",
        "low": 45,
        "high": 50,
        "category": "আটা ও ময়দা",
        "image": "assets/images/im_3.jpg",
        "description": "প্রিমিয়াম মানের গমের আটা। রুটি এবং পরোটার জন্য উপযুক্ত।",
        "availability": "In Stock",
      },
      "সয়াবিন তেল (পিউর)": {
        "title": "সয়াবিন তেল (পিউর)",
        "unit": "প্রতি লিটার",
        "low": 160,
        "high": 175,
        "category": "তেল",
        "image": "assets/images/im_4.jpg",
        "description": "বিশুদ্ধ সয়াবিন তেল। রান্নার জন্য স্বাস্থ্যকর।",
        "availability": "In Stock",
      },
      "মসুর ডাল": {
        "title": "মসুর ডাল",
        "unit": "প্রতি কেজি",
        "low": 115,
        "high": 125,
        "category": "ডাল",
        "image": "assets/images/im_5.jpg",
        "description": "উন্নত মানের মসুর ডাল। প্রোটিনের ভালো উৎস।",
        "availability": "In Stock",
      },
      "পেঁয়াজ (দেশি)": {
        "title": "পেঁয়াজ (দেশি)",
        "unit": "প্রতি কেজি",
        "low": 50,
        "high": 60,
        "category": "সবজি ও মসলা",
        "image": "assets/images/im_6.jpg",
        "description": "তাজা দেশি পেঁয়াজ। রান্নার জন্য অপরিহার্য।",
        "availability": "In Stock",
      },
      "রুই মাছ": {
        "title": "রুই মাছ",
        "unit": "প্রতি কেজি",
        "low": 350,
        "high": 400,
        "category": "মাছ ও গোশত",
        "image": "assets/images/im_7.jpg",
        "description": "তাজা রুই মাছ। প্রোটিনের চমৎকার উৎস।",
        "availability": "In Stock",
      },
      "গরুর দুধ": {
        "title": "গরুর দুধ",
        "unit": "প্রতি লিটার",
        "low": 60,
        "high": 70,
        "category": "দুধ",
        "image": "assets/images/im_8.jpg",
        "description": "বিশুদ্ধ গরুর দুধ। ক্যালসিয়াম এবং প্রোটিনে ভরপুর।",
        "availability": "In Stock",
      },
    };

    return productData[productName] ?? {
      "title": productName,
      "unit": "প্রতি কেজি",
      "low": 50,
      "high": 60,
      "category": "অন্যান্য",
      "image": "assets/images/placeholder.jpg",
      "description": "পণ্যের বিবরণ উপলব্ধ নেই।",
      "availability": "In Stock",
    };
  }

  List<Map<String, dynamic>> get filteredProducts {
    if (searchQuery.isEmpty) {
      return shopProducts;
    }
    return shopProducts
        .where((product) => product["title"]
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF079b11),
        title: Text(widget.shop.name),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop Info Header
          Container(
            color: const Color(0xFF079b11),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          widget.shop.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.store,
                              size: 30,
                              color: Color(0xFF079b11),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.shop.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (widget.shop.isVerified)
                                const Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 20,
                                ),
                            ],
                          ),
                          Text(
                            widget.shop.address,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.shop.rating.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.access_time,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.shop.openingHours,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "এই দোকানে পণ্য খুঁজুন...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Products Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "উপলব্ধ পণ্যসমূহ (${filteredProducts.length}টি)",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Products Grid
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty
                              ? "কোনো পণ্য উপলব্ধ নেই"
                              : "খোঁজার ফলাফল পাওয়া যায়নি",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
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
                              Expanded(
                                flex: 3,
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
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product["title"],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product["unit"],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "৳${product["low"]} - ৳${product["high"]}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF079b11),
                                        ),
                                      ),
                                    ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Call shop functionality
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("${widget.shop.name} এ কল করুন"),
              content: Text("ফোন নম্বর: ${widget.shop.phone}"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("বাতিল"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // In a real app, this would initiate a phone call
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("কল করা হচ্ছে ${widget.shop.phone}"),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF079b11),
                  ),
                  child: const Text("কল করুন"),
                ),
              ],
            ),
          );
        },
        backgroundColor: const Color(0xFF079b11),
        child: const Icon(Icons.phone),
      ),
    );
  }
}
