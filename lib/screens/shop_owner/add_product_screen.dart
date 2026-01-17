import 'package:flutter/material.dart';
import 'package:nitymulya/network/pricelist_api.dart';
import 'package:nitymulya/network/shop_owner_api.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

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
          selectedCategory = categories.first['cat_name'];
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
      String categoryName = item['cat_name'] ?? 'Unknown';

      if (!categorizedProducts.containsKey(categoryName)) {
        categorizedProducts[categoryName] = [];
      }
      categorizedProducts[categoryName]!.add(item);
    }

    // Set initial selected product if category is already selected
    if (selectedCategory != null &&
        categorizedProducts.containsKey(selectedCategory)) {
      if (categorizedProducts[selectedCategory]!.isNotEmpty &&
          selectedProduct == null) {
        selectedProduct =
            categorizedProducts[selectedCategory]!.first['subcat_name'];
      }
    }
  }

  String? get _selectedProductFixedPrice {
    if (selectedProduct == null || selectedCategory == null) return null;

    if (categorizedProducts.containsKey(selectedCategory)) {
      final product = categorizedProducts[selectedCategory]!.firstWhere(
        (p) => p['subcat_name'] == selectedProduct,
        orElse: () => <String, dynamic>{},
      );

      if (product.isNotEmpty) {
        String minPrice = product['min_price']?.toString() ?? '';
        String maxPrice = product['max_price']?.toString() ?? '';
        String unit = product['unit']?.toString() ?? '';

        if (minPrice.isNotEmpty && maxPrice.isNotEmpty) {
          return '৳$minPrice-$maxPrice${unit.isNotEmpty ? '/$unit' : ''}';
        } else if (minPrice.isNotEmpty) {
          return '৳$minPrice+${unit.isNotEmpty ? '/$unit' : ''}';
        } else if (maxPrice.isNotEmpty) {
          return 'up to ৳$maxPrice${unit.isNotEmpty ? '/$unit' : ''}';
        }
      }
    }
    return null;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addProduct() async {
    if (_formKey.currentState!.validate() && selectedProduct != null) {
      // Get selected product data
      Map<String, dynamic>? selectedProductData;
      if (selectedProduct != null &&
          selectedCategory != null &&
          categorizedProducts.containsKey(selectedCategory)) {
        selectedProductData = categorizedProducts[selectedCategory]!.firstWhere(
          (product) => product['subcat_name'] == selectedProduct,
          orElse: () => <String, dynamic>{},
        );
      }

      if (selectedProductData == null || selectedProductData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a valid product'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                SizedBox(width: 16),
                Text('Adding product to inventory...'),
              ],
            ),
            duration: Duration(seconds: 30), // Long duration for loading
          ),
        );
      }

      try {
        final subcatId = selectedProductData['id'].toString();
        final stockQuantity = int.parse(_quantityController.text);
        final unitPrice = double.parse(_priceController.text);

        final result = await ShopOwnerApiService.addProductToInventory(
          subcatId: subcatId,
          stockQuantity: stockQuantity,
          unitPrice: unitPrice,
          lowStockThreshold: 10, // Default low stock threshold
        );

        // Hide loading snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          if (result['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ??
                    'Product "$selectedProduct" added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Failed to add product'),
                backgroundColor: Colors.red,
              ),
            );

            // Check if login is required
            if (result['requiresLogin'] == true) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding product: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _autofillProductData() {
    if (selectedProduct != null &&
        selectedCategory != null &&
        categorizedProducts.containsKey(selectedCategory)) {
      var productData = categorizedProducts[selectedCategory]!.firstWhere(
        (product) => product['subcat_name'] == selectedProduct,
        orElse: () => <String, dynamic>{},
      );

      if (productData.isNotEmpty) {
        // Auto-fill with minimum price as suggestion if available
        String? minPrice = productData['min_price']?.toString();
        if (minPrice != null &&
            minPrice.isNotEmpty &&
            _priceController.text.isEmpty) {
          _priceController.text = minPrice;
        }
      }
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
          : Form(
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
                            initialValue: selectedCategory,
                            decoration: InputDecoration(
                              hintText: "Select a category",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.category),
                            ),
                            isExpanded: true,
                            items: categories.map((category) {
                              String categoryName =
                                  category['cat_name'] ?? 'Unknown';
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
                                if (categorizedProducts
                                        .containsKey(selectedCategory) &&
                                    categorizedProducts[selectedCategory]!
                                        .isNotEmpty) {
                                  selectedProduct =
                                      categorizedProducts[selectedCategory]!
                                          .first['subcat_name'];
                                } else {
                                  selectedProduct = null;
                                }
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

                          // ✅ Fixed DropdownButtonFormField
                          DropdownButtonFormField<String>(
                            initialValue: selectedProduct,
                            decoration: InputDecoration(
                              hintText: selectedCategory == null
                                  ? "Select category first"
                                  : "Select a product",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.inventory),
                            ),
                            isExpanded: true,
                            menuMaxHeight: 300,
                            items: selectedCategory != null &&
                                    categorizedProducts
                                        .containsKey(selectedCategory)
                                ? categorizedProducts[selectedCategory]!
                                    .map((product) {
                                    String productName =
                                        product['subcat_name'] ?? 'Unknown';
                                    String unit = product['unit'] ?? '';

                                    // Build display name with unit
                                    String displayName = productName;
                                    if (unit.isNotEmpty) {
                                      displayName += ' ($unit)';
                                    }

                                    return DropdownMenuItem<String>(
                                      value: productName,
                                      child: Text(
                                        displayName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList()
                                : [],
                            onChanged: selectedCategory == null
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedProduct = value;
                                      _autofillProductData(); // Auto-fill price if available
                                    });
                                  },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a product';
                              }
                              return null;
                            },
                          ),

                          // Price Info
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
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Government Fixed Price:',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.green[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '$_selectedProductFixedPrice',
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
                              if (int.tryParse(value) == null ||
                                  int.parse(value) <= 0) {
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

                              final enteredPrice = double.tryParse(value);
                              if (enteredPrice == null || enteredPrice <= 0) {
                                return 'Please enter a valid price';
                              }

                              // Validate against government price range
                              if (selectedProduct != null &&
                                  selectedCategory != null &&
                                  categorizedProducts
                                      .containsKey(selectedCategory)) {
                                final productData =
                                    categorizedProducts[selectedCategory]!
                                        .firstWhere(
                                  (product) =>
                                      product['subcat_name'] == selectedProduct,
                                  orElse: () => <String, dynamic>{},
                                );

                                if (productData.isNotEmpty) {
                                  final minPrice = double.tryParse(
                                          productData['min_price']
                                                  ?.toString() ??
                                              '0') ??
                                      0;
                                  final maxPrice = double.tryParse(
                                          productData['max_price']
                                                  ?.toString() ??
                                              '0') ??
                                      double.infinity;

                                  if (minPrice > 0 && enteredPrice < minPrice) {
                                    return 'Price must be at least ৳${minPrice.toStringAsFixed(2)}';
                                  }

                                  if (maxPrice < double.infinity &&
                                      enteredPrice > maxPrice) {
                                    return 'Price cannot exceed ৳${maxPrice.toStringAsFixed(2)}';
                                  }
                                }
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
                      icon: const Icon(Icons.add_shopping_cart,
                          color: Colors.white),
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
