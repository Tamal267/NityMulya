import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../network/wholesaler_api.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();

  // Data lists
  List<Map<String, dynamic>> allShopOwners = [];
  List<Map<String, dynamic>> filteredShopOwners = [];
  List<Map<String, dynamic>> inventory = [];
  List<Map<String, dynamic>> availableCategories = [];
  List<Map<String, dynamic>> availableSubcategories = [];

  // Selected values
  Map<String, dynamic>? selectedShopOwner;
  Map<String, dynamic>? selectedCategory;
  Map<String, dynamic>? selectedSubcategory;
  Map<String, dynamic>? selectedInventoryItem;

  // Loading states
  bool isLoadingShopOwners = false;
  bool isLoadingInventory = false;
  bool isSubmitting = false;

  // Search focus
  bool isSearchFocused = false;
  final FocusNode _searchFocusNode = FocusNode();

  // Calculated values
  double unitPrice = 0.0;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupListeners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _setupListeners() {
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _quantityController.addListener(_calculateTotal);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    print('Search changed: "$query"');
    print('Search focused: $isSearchFocused');
    
    setState(() {
      if (query.isEmpty) {
        filteredShopOwners = [];
        selectedShopOwner = null;
      } else {
        _filterShopOwners(query);
      }
    });
  }

  void _onSearchFocusChanged() {
    setState(() {
      isSearchFocused = _searchFocusNode.hasFocus;
      if (isSearchFocused && _searchController.text.isNotEmpty) {
        // Re-filter when gaining focus with existing text
        _filterShopOwners(_searchController.text);
      } else if (!isSearchFocused && _searchController.text.isEmpty) {
        filteredShopOwners = [];
      }
    });
  }

  void _calculateTotal() {
    if (_quantityController.text.isNotEmpty) {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      setState(() {
        totalAmount = quantity * unitPrice;
      });
    } else {
      setState(() {
        totalAmount = 0.0;
      });
    }
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadShopOwners(),
      _loadInventory(),
    ]);
  }

  Future<void> _loadShopOwners() async {
    setState(() => isLoadingShopOwners = true);
    try {
      final response = await WholesalerApiService.getShopOwners();
      if (response['success'] == true) {
        setState(() {
          allShopOwners = List<Map<String, dynamic>>.from(response['data'] ?? []);
        });
        print('Loaded ${allShopOwners.length} shop owners successfully');
        if (allShopOwners.isNotEmpty) {
          print('Sample shop owner: ${allShopOwners[0]}');
        }
      } else {
        if (response['requiresLogin'] == true) {
          _showErrorSnackBar('Please login again to continue');
          // Navigate to login if needed
        } else {
          _showErrorSnackBar('Failed to load shop owners: ${response['message']}');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error loading shop owners: $e');
    } finally {
      setState(() => isLoadingShopOwners = false);
    }
  }

  Future<void> _loadInventory() async {
    setState(() => isLoadingInventory = true);
    try {
      final response = await WholesalerApiService.getInventory();
      if (response['success'] == true) {
        setState(() {
          inventory = List<Map<String, dynamic>>.from(response['data'] ?? []);
          _extractCategoriesFromInventory();
        });
      } else {
        _showErrorSnackBar('Failed to load inventory: ${response['message']}');
      }
    } catch (e) {
      _showErrorSnackBar('Error loading inventory: $e');
    } finally {
      setState(() => isLoadingInventory = false);
    }
  }

  void _extractCategoriesFromInventory() {
    // Extract unique categories from inventory
    final Map<String, Map<String, dynamic>> uniqueCategories = {};
    
    for (final item in inventory) {
      final catName = item['cat_name'];
      if (catName != null && !uniqueCategories.containsKey(catName)) {
        uniqueCategories[catName] = {
          'name': catName,
        };
      }
    }
    
    setState(() {
      availableCategories = uniqueCategories.values.toList();
    });
  }

  void _loadSubcategoriesForCategory(String categoryName) {
    // Filter inventory items by category and extract subcategories
    final subcats = inventory
        .where((item) => item['cat_name'] == categoryName)
        .map((item) => {
              'id': item['id'],
              'subcat_id': item['subcat_id'],
              'name': item['subcat_name'],
              'unit': item['unit'],
              'unit_price': item['unit_price'],
              'stock_quantity': item['stock_quantity'],
            })
        .toList();

    setState(() {
      availableSubcategories = subcats;
      selectedSubcategory = null;
      selectedInventoryItem = null;
      unitPrice = 0.0;
      _calculateTotal();
    });
  }

  void _filterShopOwners(String query) {
    print('Filtering with query: "$query"');
    print('Total shop owners: ${allShopOwners.length}');
    
    if (query.isEmpty) {
      setState(() {
        filteredShopOwners = [];
      });
      return;
    }

    final queryLower = query.toLowerCase().trim();
    final filtered = allShopOwners.where((owner) {
      final shopName = (owner['shop_name']?.toString() ?? '').toLowerCase();
      final fullName = (owner['full_name']?.toString() ?? '').toLowerCase();
      final phone = (owner['phone']?.toString() ?? '').toLowerCase();
      
      return shopName.contains(queryLower) || 
             fullName.contains(queryLower) ||
             phone.contains(queryLower);
    }).toList();

    print('Filtered results: ${filtered.length}');
    setState(() {
      filteredShopOwners = filtered.take(10).toList(); // Limit to 10 results for better performance
    });
    print('Updated filteredShopOwners: ${filteredShopOwners.length}');
  }

  void _selectShopOwner(Map<String, dynamic> owner) {
    setState(() {
      selectedShopOwner = owner;
      _searchController.text = owner['shop_name'] ?? owner['full_name'] ?? '';
      filteredShopOwners = [];
      isSearchFocused = false;
    });
    _searchFocusNode.unfocus();
  }

  void _selectSubcategory(Map<String, dynamic> subcategory) {
    setState(() {
      selectedSubcategory = subcategory;
      selectedInventoryItem = inventory.firstWhere(
        (item) => item['id'] == subcategory['id'],
        orElse: () => <String, dynamic>{},
      );
      
      if (selectedInventoryItem != null) {
        unitPrice = double.tryParse(selectedInventoryItem!['unit_price'].toString()) ?? 0.0;
      }
      _calculateTotal();
    });
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedShopOwner == null || selectedSubcategory == null) {
      _showErrorSnackBar('Please select shop owner and product');
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final quantity = int.parse(_quantityController.text);
      
      final response = await WholesalerApiService.createOrder(
        shopOwnerId: selectedShopOwner!['id'],
        subcategoryId: selectedSubcategory!['subcat_id'],
        quantity: quantity,
        unitPrice: unitPrice,
      );

      if (response['success'] == true) {
        _showSuccessSnackBar('Order created successfully!');
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        _showErrorSnackBar('Failed to create order: ${response['message']}');
      }
    } catch (e) {
      _showErrorSnackBar('Error creating order: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Order'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShopOwnerSection(),
                        const SizedBox(height: 20),
                        _buildProductSection(),
                        const SizedBox(height: 20),
                        _buildQuantitySection(),
                        const SizedBox(height: 20),
                        _buildSummarySection(),
                      ],
                    ),
                  ),
                ),
                _buildBottomSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShopOwnerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.store, color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Shop Owner',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search for shop owner...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: isLoadingShopOwners
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : (_searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    selectedShopOwner = null;
                                    filteredShopOwners = [];
                                  });
                                },
                              )
                            : null),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (selectedShopOwner == null) {
                      return 'Please select a shop owner';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        // Show suggestions dropdown outside the card
        if (filteredShopOwners.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16, top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade300),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: Builder(
              builder: (context) {
                print('🔥 DROPDOWN RENDERED: ${filteredShopOwners.length} items');
                return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: filteredShopOwners.length,
                  itemBuilder: (context, index) {
                    final owner = filteredShopOwners[index];
                    final shopName = owner['shop_name']?.toString() ?? owner['full_name']?.toString() ?? 'N/A';
                    final phone = owner['phone']?.toString() ?? 'No phone';
                    final location = owner['location']?.toString() ?? 'No location';
                    
                    print('🔥 DROPDOWN ITEM $index: $shopName');
                    
                    return InkWell(
                      onTap: () => _selectShopOwner(owner),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: index < filteredShopOwners.length - 1
                              ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                              : null,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green[100],
                              radius: 18,
                              child: Icon(Icons.store, color: Colors.green[600], size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shopName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$phone • $location',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildProductSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory, color: Colors.green[600], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Product Selection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Category Dropdown
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                ),
              ),
              initialValue: selectedCategory,
              hint: const Text('Select Category'),
              isExpanded: true,
              items: availableCategories.map((category) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: category,
                  child: Text(category['name'] ?? 'N/A'),
                );
              }).toList(),
              onChanged: isLoadingInventory ? null : (value) {
                setState(() {
                  selectedCategory = value;
                  selectedSubcategory = null;
                  availableSubcategories = [];
                  unitPrice = 0.0;
                  _calculateTotal();
                });
                if (value != null) {
                  _loadSubcategoriesForCategory(value['name']);
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Subcategory Dropdown
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: InputDecoration(
                labelText: 'Product',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                ),
              ),
              initialValue: selectedSubcategory,
              hint: const Text('Select Product'),
              isExpanded: true,
              isDense: false,
              menuMaxHeight: 300,
              items: availableSubcategories.map((subcategory) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: subcategory,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          subcategory['name'] ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '৳${subcategory['unit_price']} per ${subcategory['unit']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: selectedCategory == null ? null : (value) {
                if (value != null) {
                  _selectSubcategory(value);
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a product';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.numbers, color: Colors.green[600], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Quantity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter quantity',
                suffixText: selectedSubcategory?['unit'] ?? '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                final quantity = int.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'Please enter a valid quantity';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    if (selectedSubcategory == null || _quantityController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: Colors.green[600], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Product:', selectedSubcategory!['name']),
                  _buildSummaryRow('Unit Price:', '৳${unitPrice.toStringAsFixed(2)}'),
                  _buildSummaryRow('Quantity:', _quantityController.text),
                  const Divider(),
                  _buildSummaryRow(
                    'Total Amount:',
                    '৳${totalAmount.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.green[700] : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isSubmitting ? null : _submitOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: isSubmitting
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Creating Order...'),
                  ],
                )
              : const Text(
                  'Create Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
