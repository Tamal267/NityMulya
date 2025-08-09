import 'package:flutter/material.dart';
import 'package:nitymulya/network/pricelist_api.dart';

class WholesalerAddProductScreen extends StatefulWidget {
  final String? userId;
  
  const WholesalerAddProductScreen({super.key, this.userId});

  @override
  State<WholesalerAddProductScreen> createState() => _WholesalerAddProductScreenState();
}

class _WholesalerAddProductScreenState extends State<WholesalerAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _minimumOrderController = TextEditingController();
  
  String? selectedProduct;
  String? selectedCategory;
  
  // Dynamic data from backend
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> priceList = [];
  Map<String, List<Map<String, dynamic>>> categorizedProducts = {};
  
  // Loading states
  bool isLoadingCategories = true;
  bool isLoadingPriceList = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadCategories(),
      _loadPriceList(),
    ]);
  }

  Future<void> _loadCategories() async {
    try {
      final fetchedCategories = await fetchCategories();
      setState(() {
        categories = fetchedCategories;
        isLoadingCategories = false;
        if (categories.isNotEmpty && selectedCategory == null) {
          selectedCategory = categories.first['name'] ?? categories.first['category_name'];
        }
      });
    } catch (e) {
      setState(() {
        isLoadingCategories = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    }
  }

  Future<void> _loadPriceList() async {
    try {
      final fetchedPriceList = await fetchPriceList();
      setState(() {
        priceList = fetchedPriceList;
        isLoadingPriceList = false;
        _organizePriceListByCategory();
      });
    } catch (e) {
      setState(() {
        isLoadingPriceList = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load price list: $e')),
        );
      }
    }
  }

  void _organizePriceListByCategory() {
    categorizedProducts.clear();
    
    for (var item in priceList) {
      String categoryName = item['category_name'] ?? item['category'] ?? 'Unknown';
      
      if (!categorizedProducts.containsKey(categoryName)) {
        categorizedProducts[categoryName] = [];
      }
      categorizedProducts[categoryName]!.add(item);
    }
    
    // Set initial selected product if category is already selected
    if (selectedCategory != null && categorizedProducts.containsKey(selectedCategory)) {
      if (categorizedProducts[selectedCategory]!.isNotEmpty && selectedProduct == null) {
        selectedProduct = categorizedProducts[selectedCategory]!.first['subcat_name'] ?? 
                         categorizedProducts[selectedCategory]!.first['name'];
      }
    }
  }

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
        actions: [
          if (!isLoadingCategories && !isLoadingPriceList)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Data',
              onPressed: () {
                setState(() {
                  isLoadingCategories = true;
                  isLoadingPriceList = true;
                });
                _loadData();
              },
            ),
        ],
      ),
      body: isLoadingCategories || isLoadingPriceList
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading product data...'),
                ],
              ),
            )
          : SingleChildScrollView(
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
                items: categories.map((category) {
                  String categoryName = category['name'] ?? category['category_name'] ?? 'Unknown';
                  return DropdownMenuItem(
                    value: categoryName,
                    child: Text(
                      categoryName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                    // Reset selected product when category changes
                    if (categorizedProducts.containsKey(selectedCategory) &&
                        categorizedProducts[selectedCategory]!.isNotEmpty) {
                      selectedProduct = categorizedProducts[selectedCategory]!.first['subcat_name'] ??
                                     categorizedProducts[selectedCategory]!.first['name'];
                    } else {
                      selectedProduct = null;
                    }
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),

              // Available Products Selection
              DropdownButtonFormField<String>(
                value: selectedProduct,
                decoration: InputDecoration(
                  labelText: "Available Products",
                  prefixIcon: const Icon(Icons.verified),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  helperText: selectedCategory != null && 
                             (!categorizedProducts.containsKey(selectedCategory) || 
                              categorizedProducts[selectedCategory]!.isEmpty)
                      ? 'No products available for this category'
                      : null,
                ),
                isExpanded: true,
                menuMaxHeight: 300,
                items: selectedCategory != null && categorizedProducts.containsKey(selectedCategory)
                    ? categorizedProducts[selectedCategory]!.map((product) {
                        String productName = product['subcat_name'] ?? product['name'] ?? 'Unknown';
                        String unit = product['unit'] ?? '';
                        String price = product['price']?.toString() ?? '';
                        String displayName = unit.isNotEmpty ? '$productName ($unit)' : productName;
                        if (price.isNotEmpty) {
                          displayName += ' - ৳$price';
                        }
                        
                        return DropdownMenuItem(
                          value: productName,
                          child: Text(
                            displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList()
                    : [],
                onChanged: selectedCategory != null && 
                          categorizedProducts.containsKey(selectedCategory) &&
                          categorizedProducts[selectedCategory]!.isNotEmpty
                    ? (value) {
                        setState(() {
                          selectedProduct = value!;
                          // Auto-fill price if available
                          _autofillProductData();
                        });
                      }
                    : null,
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
      // Get selected product data
      Map<String, dynamic>? selectedProductData;
      if (selectedProduct != null && selectedCategory != null && 
          categorizedProducts.containsKey(selectedCategory)) {
        selectedProductData = categorizedProducts[selectedCategory]!.firstWhere(
          (product) => (product['subcat_name'] ?? product['name']) == selectedProduct,
          orElse: () => <String, dynamic>{},
        );
      }

      // Prepare product data with unit information
      final productData = {
        'name': selectedProduct,
        'category': selectedCategory,
        'unit': selectedProductData?['unit'] ?? '',
        'price': double.parse(_priceController.text.trim()),
        'stock': int.parse(_stockController.text.trim()),
        'minimumOrder': int.parse(_minimumOrderController.text.trim()),
        'userId': widget.userId,
        'dateAdded': DateTime.now(),
      };

      // Show success dialog
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
            "Product '${productData['name']}' has been added successfully.\n\n"
            "Unit: ${productData['unit']}\n"
            "Price: ৳${productData['price']}\n"
            "Stock: ${productData['stock']} units",
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

  void _autofillProductData() {
    if (selectedProduct != null && selectedCategory != null && 
        categorizedProducts.containsKey(selectedCategory)) {
      
      var productData = categorizedProducts[selectedCategory]!.firstWhere(
        (product) => (product['subcat_name'] ?? product['name']) == selectedProduct,
        orElse: () => <String, dynamic>{},
      );
      
      if (productData.isNotEmpty) {
        // Auto-fill price if available (you can show suggested price)
        String? suggestedPrice = productData['price']?.toString();
        if (suggestedPrice != null && _priceController.text.isEmpty) {
          _priceController.text = suggestedPrice;
        }
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _priceController.clear();
    _stockController.clear();
    _minimumOrderController.clear();
    
    setState(() {
      if (categories.isNotEmpty) {
        selectedCategory = categories.first['name'] ?? categories.first['category_name'];
        if (categorizedProducts.containsKey(selectedCategory) &&
            categorizedProducts[selectedCategory]!.isNotEmpty) {
          selectedProduct = categorizedProducts[selectedCategory]!.first['subcat_name'] ??
                           categorizedProducts[selectedCategory]!.first['name'];
        }
      }
    });
  }
}
