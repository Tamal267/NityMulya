import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedProduct;
  String? _selectedCategory;

  // Government fixed products by category
  final Map<String, List<Map<String, dynamic>>> _governmentProducts = {
    'চাল': [
      {'name': 'চাল সরু (নাজির/মিনিকেট)', 'fixedPrice': '৳78-82/কেজি'},
      {'name': 'চাল মোটা (পাইলস)', 'fixedPrice': '৳58-62/কেজি'},
      {'name': 'চাল বাসমতি', 'fixedPrice': '৳95-105/কেজি'},
    ],
    'তেল': [
      {'name': 'সয়াবিন তেল (পিউর)', 'fixedPrice': '৳165-175/লিটার'},
      {'name': 'সরিষার তেল', 'fixedPrice': '৳180-190/লিটার'},
      {'name': 'পাম তেল', 'fixedPrice': '৳155-165/লিটার'},
    ],
    'ডাল': [
      {'name': 'মসুর ডাল', 'fixedPrice': '৳115-125/কেজি'},
      {'name': 'মুগ ডাল', 'fixedPrice': '৳135-145/কেজি'},
      {'name': 'ছোলার ডাল', 'fixedPrice': '৳125-135/কেজি'},
      {'name': 'অড়হর ডাল', 'fixedPrice': '৳145-155/কেজি'},
    ],
    'সবজি': [
      {'name': 'পেঁয়াজ (দেশি)', 'fixedPrice': '৳50-60/কেজি'},
      {'name': 'আলু', 'fixedPrice': '৳25-30/কেজি'},
      {'name': 'রসুন', 'fixedPrice': '৳180-200/কেজি'},
      {'name': 'আদা', 'fixedPrice': '৳120-140/কেজি'},
    ],
    'আটা': [
      {'name': 'গমের আটা (প্রিমিয়াম)', 'fixedPrice': '৳45-50/কেজি'},
      {'name': 'গমের আটা (স্ট্যান্ডার্ড)', 'fixedPrice': '৳38-42/কেজি'},
      {'name': 'ময়দা', 'fixedPrice': '৳48-52/কেজি'},
    ],
    'দুগ্ধজাত': [
      {'name': 'গরুর দুধ', 'fixedPrice': '৳60-70/লিটার'},
      {'name': 'ছাগলের দুধ', 'fixedPrice': '৳90-100/লিটার'},
    ],
    'মাছ': [
      {'name': 'রুই মাছ', 'fixedPrice': '৳350-400/কেজি'},
      {'name': 'কাতলা মাছ', 'fixedPrice': '৳320-370/কেজি'},
      {'name': 'ইলিশ মাছ', 'fixedPrice': '৳1200-1500/কেজি'},
    ],
    'মসলা': [
      {'name': 'হলুদ গুঁড়া', 'fixedPrice': '৳250-280/কেজি'},
      {'name': 'লাল মরিচ গুঁড়া', 'fixedPrice': '৳300-350/কেজি'},
      {'name': 'ধনিয়া গুঁড়া', 'fixedPrice': '৳200-230/কেজি'},
    ],
  };

  List<Map<String, dynamic>> get _currentProducts {
    if (_selectedCategory == null) return [];
    return _governmentProducts[_selectedCategory!] ?? [];
  }

  String? get _selectedProductFixedPrice {
    if (_selectedProduct == null) return null;
    final product = _currentProducts.firstWhere(
      (p) => p['name'] == _selectedProduct,
      orElse: () => {},
    );
    return product['fixedPrice'];
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addProduct() {
    if (_formKey.currentState!.validate() && _selectedProduct != null) {
      // TODO: Add product to database/storage
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product "$_selectedProduct" added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Add New Product",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[600]),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Select from government approved products only. Prices are regulated by the government.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Product Category",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        hintText: "Select a category",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      items: _governmentProducts.keys.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                          _selectedProduct = null; // Reset product selection
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Product Name",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedProduct,
                      decoration: InputDecoration(
                        hintText: _selectedCategory == null 
                            ? "Select category first" 
                            : "Select a product",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.inventory),
                      ),
                      items: _currentProducts.map((product) {
                        return DropdownMenuItem<String>(
                          value: product['name'] as String,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Gov. Price: ${product['fixedPrice']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: _selectedCategory == null ? null : (value) {
                        setState(() {
                          _selectedProduct = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a product';
                        }
                        return null;
                      },
                    ),
                    if (_selectedProductFixedPrice != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.price_check, 
                                 color: Colors.green[600], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Government Fixed Price: $_selectedProductFixedPrice',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quantity Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Initial Stock Quantity",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        hintText: "Enter quantity",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.numbers),
                        suffixText: "units",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Please enter a valid positive number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Your Selling Price
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Selling Price",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Must be within government price range",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        hintText: "Enter your price per unit",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                        prefixText: "৳",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter selling price';
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Add Product Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _addProduct,
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                label: const Text(
                  "Add Product to Inventory",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
