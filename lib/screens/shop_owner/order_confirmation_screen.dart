import 'package:flutter/material.dart';
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
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
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
      print('🔍 Debug - Full order object: ${widget.order}');
      print('🔍 Debug - Available keys: ${widget.order.keys.toList()}');
      
      // Extract order details - need to handle both data structures
      String? subcatId = widget.order['subcat_id']?.toString();
      int quantity = 0;
      double unitPrice = 0.0;
      
      // Handle different order data structures
      if (subcatId == null) {
        // If no subcat_id, try to find it in a different way or fetch from API
        print('⚠️ No subcat_id found in order object. Need to fetch order details from API.');
        
        // Get order details from API to get subcat_id
        final orderDetails = await ShopOwnerApiService.getShopOrders();
        if (orderDetails['success'] == true) {
          final orders = orderDetails['data'] as List;
          final matchingOrder = orders.firstWhere(
            (order) => order['id'] == widget.order['id'],
            orElse: () => null,
          );
          
          if (matchingOrder != null) {
            subcatId = matchingOrder['subcat_id']?.toString();
            quantity = matchingOrder['quantity_requested'] ?? 0;
            unitPrice = double.tryParse(matchingOrder['unit_price']?.toString() ?? '0') ?? 0.0;
          }
        }
      } else {
        quantity = widget.order['quantity_requested'] ?? 0;
        unitPrice = double.tryParse(widget.order['unit_price']?.toString() ?? '0') ?? 0.0;
      }
      
      print('🔍 Final values: subcatId=$subcatId, quantity=$quantity, price=$unitPrice');
      
      if (subcatId == null || quantity <= 0 || unitPrice <= 0) {
        print('❌ Invalid order data for inventory addition: subcatId=$subcatId, quantity=$quantity, price=$unitPrice');
        throw Exception('Invalid order data: Missing required fields (subcat_id, quantity, unit_price)');
      }

      // Add/Update product inventory using the existing API method
      final result = await ShopOwnerApiService.addProductToInventory(
        subcatId: subcatId,
        stockQuantity: quantity,
        unitPrice: unitPrice,
        lowStockThreshold: 10, // Default threshold
      );

      if (result['success'] == true) {
        print('✅ Product added to inventory successfully');
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.inventory, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Product added to your inventory: ${widget.order['product_name'] ?? 'Product'} ($quantity units)'),
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
        print('❌ Failed to add product to inventory: ${result['message']}');
        // Throw error to prevent order acceptance
        throw Exception('Failed to add product to inventory: ${result['message']}');
      }
    } catch (e) {
      print('❌ Error adding product to inventory: $e');
      // Re-throw error to prevent order acceptance
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.order);
    final wholesalerName = widget.order['wholesaler_name']?.toString() ?? 'Unknown Wholesaler';
    final productName = widget.order['product_name']?.toString() ?? 'Unknown Product';
    final quantity = widget.order['quantity'] ?? 0;
    final unitPrice = double.tryParse(widget.order['unit_price']?.toString() ?? '0') ?? 0.0;
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
      body: SingleChildScrollView(
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
                    'Please confirm that you have received this order',
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
                            productName,
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
                            '$quantity units',
                            Icons.scale,
                            Colors.orange,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            'Unit Price',
                            '৳${unitPrice.toStringAsFixed(2)}',
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

            // Notes Section
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
                          Icons.note_add,
                          color: Colors.blue[600],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Additional Notes (Optional)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Add any notes about the order receipt, quality, or delivery...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
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
                      'Please confirm only if you have actually received the order in good condition.',
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
