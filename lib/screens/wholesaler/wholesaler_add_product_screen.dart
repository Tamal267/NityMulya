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
  final TextEditingController _descriptionController = TextEditingController();
  
  String selectedProduct = "চাল সরু (প্রিমিয়াম)";
  String selectedCategory = "Rice (চাল)";
  String selectedUnit = "কেজি";
  bool isPriorityProduct = false;
  bool isDiscountAvailable = false;
  double discountPercentage = 0.0;
  
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
  
  final List<String> categories = [
    "Rice (চাল)",
    "Oil (তেল)",
    "Lentils (ডাল)",
    "Sugar (চিনি)",
    "Onion (পেঁয়াজ)",
    "Flour (আটা)",
    "Spices (মসলা)",
    "Vegetables (সবজি)",
    "Fish (মাছ)",
    "Meat (মাংস)",
    "Dairy (দুগ্ধজাত)",
    "Snacks (খাবার)",
  ];
  
  final List<String> units = [
    "কেজি",
    "লিটার",
    "গ্রাম",
    "পিস",
    "প্যাকেট",
    "বস্তা",
    "কার্টন",
  ];

  @override
  void dispose() {
    _priceController.dispose();
    _stockController.dispose();
    _minimumOrderController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Add New Product",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
              // Header Card
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
                child: Row(
                  children: [
                    Icon(Icons.add_box, color: Colors.green[800], size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add New Wholesale Product",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Fill in the details for your new wholesale product",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Product Details Section
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
                    const Text(
                      "📦 Product Information",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Selection
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: "Product Category",
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        helperText: "Select category first, then choose specific product",
                      ),
                      items: governmentProducts.keys.map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                          // Reset product selection when category changes
                          selectedProduct = governmentProducts[selectedCategory]!.first;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Government Fixed Product Selection
                    DropdownButtonFormField<String>(
                      value: selectedProduct,
                      decoration: InputDecoration(
                        labelText: "Government Approved Product",
                        hintText: "Select from approved product list",
                        prefixIcon: const Icon(Icons.verified),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        helperText: "Only government-approved products can be sold",
                      ),
                      items: governmentProducts[selectedCategory]!.map((product) => DropdownMenuItem(
                        value: product,
                        child: Text(product, style: const TextStyle(fontSize: 14)),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedProduct = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a product';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Unit Selection
                    DropdownButtonFormField<String>(
                      value: selectedUnit,
                      decoration: InputDecoration(
                        labelText: "Unit",
                        prefixIcon: const Icon(Icons.straighten),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: units.map((unit) => DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedUnit = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a unit';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Product Description (Optional)",
                        hintText: "Describe quality, origin, or special features",
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pricing & Stock Section
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
                    const Text(
                      "💰 Pricing & Stock",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Wholesale Price and Stock Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Wholesale Price (৳)",
                              hintText: "Per unit price",
                              prefixIcon: const Icon(Icons.attach_money),
                              suffixText: "৳",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter price';
                              }
                              final price = double.tryParse(value.trim());
                              if (price == null || price <= 0) {
                                return 'Please enter a valid price';
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
                              labelText: "Available Stock",
                              hintText: "Total quantity",
                              prefixIcon: const Icon(Icons.inventory),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter stock';
                              }
                              final stock = int.tryParse(value.trim());
                              if (stock == null || stock < 0) {
                                return 'Please enter valid stock';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Minimum Order Quantity
                    TextFormField(
                      controller: _minimumOrderController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Minimum Order Quantity",
                        hintText: "Minimum order required from shops",
                        prefixIcon: const Icon(Icons.local_shipping),
                        helperText: "Set minimum order quantity for bulk discount",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter minimum order quantity';
                        }
                        final minOrder = int.tryParse(value.trim());
                        if (minOrder == null || minOrder <= 0) {
                          return 'Please enter valid minimum order';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Discount & Priority Section
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
                    const Text(
                      "🎯 Special Options",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Priority Product Switch
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.yellow[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.yellow[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow[700]),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Priority Product",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Mark as priority for faster processing",
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isPriorityProduct,
                            onChanged: (value) {
                              setState(() {
                                isPriorityProduct = value;
                              });
                            },
                            activeColor: Colors.yellow[700],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bulk Discount Switch
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_offer, color: Colors.green[700]),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Bulk Discount Available",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Offer discount for large orders",
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: isDiscountAvailable,
                                onChanged: (value) {
                                  setState(() {
                                    isDiscountAvailable = value;
                                    if (!value) {
                                      discountPercentage = 0.0;
                                    }
                                  });
                                },
                                activeColor: Colors.green[700],
                              ),
                            ],
                          ),
                          if (isDiscountAvailable) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text("Discount Percentage:"),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Slider(
                                    value: discountPercentage,
                                    min: 0,
                                    max: 50,
                                    divisions: 10,
                                    label: "${discountPercentage.round()}%",
                                    onChanged: (value) {
                                      setState(() {
                                        discountPercentage = value;
                                      });
                                    },
                                    activeColor: Colors.green[700],
                                  ),
                                ),
                                Text(
                                  "${discountPercentage.round()}%",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
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
                        side: BorderSide(color: Colors.grey[400]!),
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
      // Prepare product data
      final productData = {
        'name': selectedProduct,
        'category': selectedCategory,
        'unit': selectedUnit,
        'price': double.parse(_priceController.text.trim()),
        'stock': int.parse(_stockController.text.trim()),
        'minimumOrder': int.parse(_minimumOrderController.text.trim()),
        'description': _descriptionController.text.trim(),
        'isPriority': isPriorityProduct,
        'discountAvailable': isDiscountAvailable,
        'discountPercentage': discountPercentage,
        'dateAdded': DateTime.now(),
      };

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600]),
              const SizedBox(width: 8),
              const Text("Success!"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Product has been added successfully!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Product: ${productData['name']}"),
                    Text("Category: ${productData['category']}"),
                    Text("Price: ৳${productData['price']}/${productData['unit']}"),
                    Text("Stock: ${productData['stock']} ${productData['unit']}"),
                    if (productData['isPriority'] as bool)
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.yellow[700]),
                          const SizedBox(width: 4),
                          const Text("Priority Product"),
                        ],
                      ),
                    if (productData['discountAvailable'] as bool)
                      Text("Bulk Discount: ${(productData['discountPercentage'] as double).round()}%"),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Return to dashboard with success
              },
              child: const Text("Continue"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _resetForm(); // Reset form for another product
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
    _descriptionController.clear();
    
    setState(() {
      selectedCategory = "Rice (চাল)";
      selectedProduct = governmentProducts[selectedCategory]!.first;
      selectedUnit = "কেজি";
      isPriorityProduct = false;
      isDiscountAvailable = false;
      discountPercentage = 0.0;
    });
  }
}
