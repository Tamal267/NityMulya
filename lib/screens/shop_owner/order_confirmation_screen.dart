import 'package:flutter/material.dart';
import 'package:nitymulya/network/pricelist_api.dart';
import 'package:nitymulya/network/shop_owner_api.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderConfirmationScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  bool _isConfirming = false;
  final TextEditingController _shopUnitPriceController = TextEditingController();
  
  // Price validation data from government
  List<Map<String, dynamic>> priceList = [];
  Map<String, dynamic>? productPriceValidation;
  
  // Loading states
  bool isLoadingPriceList = true;
  
  // Error states
  String? _priceError;
  
  // Order data
  String? productName;
  String? subcategoryId;
  int orderQuantity = 0;
  double wholesalerPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _extractOrderData();
    _loadPriceValidation();
  }

  @override
  void dispose() {
    _shopUnitPriceController.dispose();
    super.dispose();
  }

  void _extractOrderData() {
    // Debug: Print the entire order object to understand its structure
    print('📦 Full order data: ${widget.order}');
    
    // Extract order information
    productName = widget.order['product_name']?.toString() ?? 
                 widget.order['subcat_name']?.toString() ?? 
                 widget.order['name']?.toString() ??
                 'Unknown Product';
    
    // Try multiple possible field names for subcategory ID
    subcategoryId = widget.order['subcat_id']?.toString() ??
                   widget.order['subcategory_id']?.toString() ??
                   widget.order['product_id']?.toString() ??
                   widget.order['subcatId']?.toString() ??
                   widget.order['subCatId']?.toString();
    
    // Get order quantity
    var rawQuantity = widget.order['quantity_requested'] ?? 
                     widget.order['quantity'] ?? 
                     widget.order['order_quantity'] ?? 
                     widget.order['qty'] ?? 
                     widget.order['amount'] ??
                     0;
    
    if (rawQuantity is String) {
      orderQuantity = int.tryParse(rawQuantity) ?? 0;
    } else if (rawQuantity is num) {
      orderQuantity = rawQuantity.toInt();
    }
    
    // Get wholesaler price
    var rawPrice = widget.order['unit_price'] ?? 
                  widget.order['price'] ?? 
                  widget.order['wholesale_price'] ??
                  0;
    if (rawPrice is String) {
      wholesalerPrice = double.tryParse(rawPrice) ?? 0.0;
    } else if (rawPrice is num) {
      wholesalerPrice = rawPrice.toDouble();
    }
    
    // Set default shop price to wholesaler price
    _shopUnitPriceController.text = wholesalerPrice.toStringAsFixed(2);
    
    print('🔍 Extracted order data: productName=$productName, subcategoryId=$subcategoryId, quantity=$orderQuantity, wholesalerPrice=$wholesalerPrice');
    print('🔍 Available order keys: ${widget.order.keys.toList()}');
    
    // If subcategoryId is still null, let's try to find it by examining all fields
    if (subcategoryId == null) {
      print('⚠️ subcategoryId is null, examining all order fields:');
      widget.order.forEach((key, value) {
        print('  $key: $value (${value.runtimeType})');
      });
    }
  }

  Future<void> _loadPriceValidation() async {
    try {
      setState(() {
        isLoadingPriceList = true;
      });
      
      // Fetch price list to get government validation
      final fetchedPriceList = await fetchPriceList();
      
      setState(() {
        priceList = fetchedPriceList;
        isLoadingPriceList = false;
        _findProductPriceValidation();
      });
    } catch (e) {
      print('Error loading price validation: $e');
      setState(() {
        isLoadingPriceList = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load price validation: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _findProductPriceValidation() {
    // Find the product in price list by subcategory ID or name
    for (var item in priceList) {
      bool isMatch = false;
      
      // First try to match by subcategory ID
      if (subcategoryId != null && item['id']?.toString() == subcategoryId) {
        isMatch = true;
        print('🎯 Found product by subcategory ID match: ${item['id']} == $subcategoryId');
      }
      // If no ID match, try by product name
      else if (item['subcat_name']?.toString().toLowerCase() == productName?.toLowerCase()) {
        isMatch = true;
        // If we found by name but didn't have subcategoryId, extract it
        if (subcategoryId == null) {
          subcategoryId = item['id']?.toString();
          print('🎯 Found subcategory ID from name match: $subcategoryId');
        }
        print('🎯 Found product by name match: ${item['subcat_name']} == $productName');
      }
      
      if (isMatch) {
        productPriceValidation = {
          'min_price': double.tryParse(item['min_price']?.toString() ?? '0') ?? 0.0,
          'max_price': double.tryParse(item['max_price']?.toString() ?? '0') ?? 999999.0,
          'unit': item['unit']?.toString() ?? '',
          'subcat_name': item['subcat_name']?.toString() ?? productName,
          'id': item['id']?.toString(),
        };
        
        print('🔍 Found price validation: $productPriceValidation');
        break;
      }
    }
    
    if (productPriceValidation == null) {
      print('⚠️ No price validation found for product: $productName (ID: $subcategoryId)');
      print('📋 Available products in price list:');
      for (var item in priceList.take(5)) {
        print('  ID: ${item['id']}, Name: ${item['subcat_name']}');
      }
    } else {
      // Ensure subcategoryId is set from the validation data if we found it
      if (subcategoryId == null && productPriceValidation!['id'] != null) {
        subcategoryId = productPriceValidation!['id'] as String?;
        print('🔄 Updated subcategoryId from price validation: $subcategoryId');
      }
    }
  }

  String? get _governmentPriceRange {
    if (productPriceValidation == null) return null;
    
    final minPrice = productPriceValidation!['min_price'] as double;
    final maxPrice = productPriceValidation!['max_price'] as double;
    final unit = productPriceValidation!['unit'] as String;
    
    if (minPrice > 0 && maxPrice < 999999) {
      return '৳${minPrice.toStringAsFixed(2)} - ৳${maxPrice.toStringAsFixed(2)}${unit.isNotEmpty ? '/$unit' : ''}';
    } else if (minPrice > 0) {
      return '৳${minPrice.toStringAsFixed(2)}+${unit.isNotEmpty ? '/$unit' : ''}';
    } else if (maxPrice < 999999) {
      return 'up to ৳${maxPrice.toStringAsFixed(2)}${unit.isNotEmpty ? '/$unit' : ''}';
    }
    return null;
  }

  Future<void> _confirmOrder() async {
    if (_isConfirming) return;

    setState(() {
      _isConfirming = true;
    });

    try {
      final result = await ShopOwnerApiService.updateShopOrderStatus(
        orderId: widget.order['id'].toString(),
        status: 'completed',
        notes: 'Order confirmed and added to inventory',
      );

      if (result['success'] == true) {
        // After successful order confirmation, add product to inventory
        try {
          await _addOrderToInventory();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order confirmed and product added to inventory successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          }
        } catch (e) {
          // If inventory addition fails, rollback the order status
          print('Inventory addition failed, rolling back order status: $e');
          
          // Attempt to revert order status
          await ShopOwnerApiService.updateShopOrderStatus(
            orderId: widget.order['id'].toString(),
            status: 'delivered', // Revert to previous status
            notes: 'Reverted due to inventory addition failure',
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order acceptance failed: Unable to add product to inventory. ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to confirm order'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error confirming order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }

  Future<void> _addOrderToInventory() async {
    try {
      // Validate the shop unit price
      final shopUnitPriceText = _shopUnitPriceController.text.trim();
      if (shopUnitPriceText.isEmpty) {
        setState(() {
          _priceError = 'Please enter a unit price for your shop inventory';
        });
        throw Exception('Please enter a unit price for your shop inventory');
      }

      final shopUnitPrice = double.tryParse(shopUnitPriceText);
      if (shopUnitPrice == null || shopUnitPrice <= 0) {
        setState(() {
          _priceError = 'Please enter a valid price greater than 0';
        });
        throw Exception('Please enter a valid price greater than 0');
      }

      // Validate price range if we have validation data
      if (productPriceValidation != null) {
        final minPrice = productPriceValidation!['min_price'] as double?;
        final maxPrice = productPriceValidation!['max_price'] as double?;
        
        if (minPrice != null && shopUnitPrice < minPrice) {
          setState(() {
            _priceError = 'Price must be at least ৳${minPrice.toStringAsFixed(2)} (Government minimum)';
          });
          throw Exception('Price must be at least ৳${minPrice.toStringAsFixed(2)} (Government minimum)');
        }
        
        if (maxPrice != null && maxPrice < 999999 && shopUnitPrice > maxPrice) {
          setState(() {
            _priceError = 'Price cannot exceed ৳${maxPrice.toStringAsFixed(2)} (Government maximum)';
          });
          throw Exception('Price cannot exceed ৳${maxPrice.toStringAsFixed(2)} (Government maximum)');
        }
      }

      // Clear any previous errors
      setState(() {
        _priceError = null;
      });

      // Ensure we have subcategory ID
      if (subcategoryId == null || subcategoryId!.isEmpty) {
        print('❌ Missing subcategory ID details:');
        print('   - subcategoryId: $subcategoryId');
        print('   - productName: $productName');
        print('   - productPriceValidation: $productPriceValidation');
        print('   - Available order keys: ${widget.order.keys.toList()}');
        
        // Try one more time to get subcategory ID from price validation
        if (productPriceValidation != null && productPriceValidation!['id'] != null) {
          subcategoryId = productPriceValidation!['id'].toString();
          print('🔄 Last attempt: Using subcategoryId from price validation: $subcategoryId');
        }
        
        if (subcategoryId == null || subcategoryId!.isEmpty) {
          throw Exception('Cannot add product to inventory: Missing subcategory ID. Please ensure the product is properly configured in the system.');
        }
      }

      // Add/Update product inventory
      print('🚀 Making API call to add product to inventory...');
      print('🔍 API Parameters: subcatId=$subcategoryId, stockQuantity=$orderQuantity, shopUnitPrice=$shopUnitPrice');
      
      final result = await ShopOwnerApiService.addProductToInventory(
        subcatId: subcategoryId!,
        stockQuantity: orderQuantity,
        unitPrice: shopUnitPrice,
        lowStockThreshold: 10,
      );

      print('📡 API Response: $result');

      if (result['success'] == true) {
        print('✅ Product added to inventory successfully');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.inventory, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Product added to inventory: $productName ($orderQuantity units at ৳${shopUnitPrice.toStringAsFixed(2)})'),
                  ),
                ],
              ),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        final errorMessage = result['message'] ?? 'Unknown error';
        print('❌ Failed to add product to inventory: $errorMessage');
        throw Exception('Failed to add product to inventory: $errorMessage');
      }
    } catch (e) {
      print('❌ Error adding product to inventory: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final wholesalerName = widget.order['wholesaler_name']?.toString() ?? 'Unknown Wholesaler';
    final totalAmount = double.tryParse(widget.order['total_amount']?.toString() ?? '0') ?? 0.0;
    final deliveryDate = widget.order['updated_date']?.toString() ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Confirm Order Receipt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoadingPriceList
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading price validation...'),
                ],
              ),
            )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[600]!, Colors.green[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Confirm Order Receipt',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Order will be added to your inventory',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Order Details Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          color: Colors.green[600],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Order Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Product Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Product',
                            productName ?? 'Unknown Product',
                            Icons.inventory_2,
                            Colors.blue,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            'Wholesaler',
                            wholesalerName,
                            Icons.store,
                            Colors.purple,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            'Quantity',
                            '$orderQuantity units',
                            Icons.scale,
                            Colors.orange,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            'Wholesaler Price',
                            '৳${wholesalerPrice.toStringAsFixed(2)}',
                            Icons.attach_money,
                            Colors.green,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            'Total Amount',
                            '৳${totalAmount.toStringAsFixed(2)}',
                            Icons.account_balance_wallet,
                            Colors.red,
                          ),
                          if (deliveryDate.isNotEmpty) ...[
                            const Divider(height: 20),
                            _buildDetailRow(
                              'Delivered',
                              _formatDate(deliveryDate),
                              Icons.local_shipping,
                              Colors.teal,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Shop Unit Price Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.price_change,
                          color: Colors.orange[600],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Set Your Shop Unit Price',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Set the unit price for your shop inventory. Must comply with government regulations.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Price validation info
                    if (productPriceValidation != null && _governmentPriceRange != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Government price range: $_governmentPriceRange',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Shop unit price input field
                    TextField(
                      controller: _shopUnitPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Shop Unit Price (৳)',
                        hintText: 'Enter unit price for your shop',
                        prefixIcon: Icon(
                          Icons.attach_money,
                          color: Colors.orange[600],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.orange[600]!, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _priceError = null;
                        });
                      },
                    ),

                    // Price error display
                    if (_priceError != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _priceError!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
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

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isConfirming ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[400]!, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isConfirming ? null : _confirmOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: _isConfirming
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Confirming...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Confirm Receipt',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Warning Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Colors.amber[700],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Confirming will add $orderQuantity units of $productName to your inventory.',
                      style: TextStyle(
                        color: Colors.amber[800],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return "${date.day} ${months[date.month - 1]} ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateStr;
    }
  }
}
