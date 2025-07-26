import 'package:flutter/material.dart';

class WholesalerAddProductScreen extends StatefulWidget {
  const WholesalerAddProductScreen({super.key});

  @override
  State<WholesalerAddProductScreen> createState() => _WholesalerAddProductScreenState();
}

class _WholesalerAddProductScreenState extends State<WholesalerAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _minimumOrderController = TextEditingController();
  
  String selectedProduct = "চাল সরু (প্রিমিয়াম)";
  String selectedCategory = "Rice (চাল)";
  
  // Government Fixed Product List
  final Map<String, List<String>> governmentProducts = {
    "Rice (চাল)": [
      "চাল সরু (প্রিমিয়াম)",
      "চাল মোটা (স্ট্যান্ডার্ড)",
      "চাল বাসমতি",
      "চাল মিনিকেট",
      "চাল পায়জাম",
      "চাল কাটারিভোগ",
      "চাল বোরো",
      "চাল আমন",
    ],
    "Oil (তেল)": [
      "সয়াবিন তেল (রিফাইন্ড)",
      "সরিষার তেল (খাঁটি)",
      "পাম তেল",
      "সূর্যমুখী তেল",
      "ভুট্টার তেল",
      "নারিকেল তেল",
      "তিলের তেল",
    ],
    "Lentils (ডাল)": [
      "মসুর ডাল (দেশি)",
      "মসুর ডাল (আমদানি)",
      "ছোলা ডাল",
      "মুগ ডাল",
      "অড়হর ডাল",
      "ফেলন ডাল",
      "খেসারি ডাল",
      "মাসকলাই ডাল",
    ],
    "Sugar (চিনি)": [
      "চিনি সাদা (রিফাইন্ড)",
      "চিনি দেশি",
      "চিনি পাউডার",
      "চিনি কিউব",
      "গুড় (খেজুর)",
      "গুড় (আখ)",
      "মিছরি",
    ],
    "Onion (পেঁয়াজ)": [
      "পেঁয়াজ দেশি",
      "পেঁয়াজ আমদানি",
      "পেঁয়াজ লাল",
      "পেঁয়াজ সাদা",
      "পেঁয়াজ ছোট",
      "শালগম",
    ],
    "Flour (আটা)": [
      "গমের আটা (প্রিমিয়াম)",
      "গমের আটা (স্ট্যান্ডার্ড)",
      "ময়দা",
      "সুজি",
      "চালের গুঁড়া",
      "বার্লি আটা",
      "ভুট্টার আটা",
    ],
    "Spices (মসলা)": [
      "হলুদ গুঁড়া",
      "মরিচ গুঁড়া",
      "ধনিয়া গুঁড়া",
      "জিরা গুঁড়া",
      "গরম মসলা",
      "বিরিয়ানি মসলা",
      "মাছের মসলা",
      "মাংসের মসলা",
    ],
    "Vegetables (সবজি)": [
      "আলু দেশি",
      "আলু আমদানি",
      "টমেটো",
      "বেগুন",
      "কাঁচা মরিচ",
      "আদা",
      "রসুন",
      "গাজর",
    ],
    "Fish (মাছ)": [
      "ইলিশ মাছ",
      "রুই মাছ",
      "কাতলা মাছ",
      "পাঙ্গাস মাছ",
      "তেলাপিয়া মাছ",
      "চিংড়ি মাছ",
      "হিলসা শুটকি",
      "বোয়াল মাছ",
    ],
    "Meat (মাংস)": [
      "গরুর মাংস",
      "খাসির মাংস",
      "মুরগির মাংস",
      "হাঁসের মাংস",
      "কবুতরের মাংস",
      "ছাগলের মাংস",
    ],
    "Dairy (দুগ্ধজাত)": [
      "দুধ তরল (পাস্তুরাইজড)",
      "দুধ পাউডার",
      "দই",
      "মাখন",
      "পনির",
      "ছানা",
      "ক্রিম",
    ],
    "Snacks (খাবার)": [
      "চানাচুর",
      "বিস্কুট",
      "কেক",
      "চকলেট",
      "আইসক্রিম",
      "নুডলস",
      "চিপস",
    ],
  };

  @override
  void dispose() {
    _priceController.dispose();
    _stockController.dispose();
    _minimumOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Add Product",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simple header
              const Text(
                "Add New Product",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Fill in the basic product details",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Category Selection
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: "Product Category",
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                isExpanded: true,
                items: governmentProducts.keys.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(
                    category,
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                    selectedProduct = governmentProducts[selectedCategory]!.first;
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),

              // Government Product Selection
              DropdownButtonFormField<String>(
                value: selectedProduct,
                decoration: InputDecoration(
                  labelText: "Government Approved Product",
                  prefixIcon: const Icon(Icons.verified),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                isExpanded: true,
                menuMaxHeight: 300,
                items: governmentProducts[selectedCategory]!.map((product) => DropdownMenuItem(
                  value: product,
                  child: Text(
                    product,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProduct = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select a product' : null,
              ),
              const SizedBox(height: 16),

              // Price and Stock Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Price (৳)",
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter price';
                        }
                        final price = double.tryParse(value.trim());
                        if (price == null || price <= 0) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Stock",
                        prefixIcon: const Icon(Icons.inventory),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter stock';
                        }
                        final stock = int.tryParse(value.trim());
                        if (stock == null || stock < 0) {
                          return 'Invalid stock';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Minimum Order
              TextFormField(
                controller: _minimumOrderController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Minimum Order Quantity",
                  prefixIcon: const Icon(Icons.local_shipping),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter minimum order';
                  }
                  final minOrder = int.tryParse(value.trim());
                  if (minOrder == null || minOrder <= 0) {
                    return 'Invalid minimum order';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Add Product",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      // Prepare simplified product data
      final productData = {
        'name': selectedProduct,
        'category': selectedCategory,
        'price': double.parse(_priceController.text.trim()),
        'stock': int.parse(_stockController.text.trim()),
        'minimumOrder': int.parse(_minimumOrderController.text.trim()),
        'dateAdded': DateTime.now(),
      };

      // Show simple success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text("Product Added!"),
            ],
          ),
          content: Text(
            "Product '${productData['name']}' has been added successfully.\n\nPrice: ৳${productData['price']}\nStock: ${productData['stock']} units",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Return to dashboard
              },
              child: const Text("Done"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _resetForm(); // Reset for another product
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
              ),
              child: const Text(
                "Add Another",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _priceController.clear();
    _stockController.clear();
    _minimumOrderController.clear();
    
    setState(() {
      selectedCategory = "Rice (চাল)";
      selectedProduct = governmentProducts[selectedCategory]!.first;
    });
  }
}
