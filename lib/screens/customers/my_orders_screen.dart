import 'package:flutter/material.dart';

import '../../network/customer_api.dart';
import '../../services/order_service.dart';
import 'cancel_order_screen.dart';
import 'main_customer_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  final String? customerId;
  final String? userName;
  final String? userEmail;
  final String? userRole;
  final bool isInBottomNav;
  final VoidCallback? onNavigateToHome;

  const MyOrdersScreen({
    super.key,
    this.customerId,
    this.userName,
    this.userEmail,
    this.userRole,
    this.isInBottomNav = false,
    this.onNavigateToHome,
  });

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // Load orders from both database and local storage
  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> allOrders = [];

      // First, try to load from database via API
      final apiResult = await CustomerApi.getOrders();
      if (apiResult['success'] == true) {
        final dbOrders =
            List<Map<String, dynamic>>.from(apiResult['orders'] ?? []);

        // Convert database orders to local format
        for (final dbOrder in dbOrders) {
          final convertedOrder = _convertDatabaseOrderToLocal(dbOrder);
          allOrders.add(convertedOrder);
        }
      }

      // Also load local orders (for offline orders)
      final localOrders = await OrderService().getOrders();

      // Merge orders, avoiding duplicates based on order ID
      final Map<String, Map<String, dynamic>> orderMap = {};

      // Add database orders first (they take priority)
      for (final order in allOrders) {
        orderMap[order['id']] = order;
      }

      // Add local orders that aren't already in database
      for (final localOrder in localOrders) {
        if (!orderMap.containsKey(localOrder['id'])) {
          orderMap[localOrder['id']] = localOrder;
        }
      }

      final mergedOrders = orderMap.values.toList();

      // Sort by order date (newest first)
      mergedOrders.sort((a, b) {
        final dateA = a['orderDate'] is DateTime
            ? a['orderDate'] as DateTime
            : DateTime.tryParse(a['orderDate']?.toString() ?? '') ??
                DateTime.now();
        final dateB = b['orderDate'] is DateTime
            ? b['orderDate'] as DateTime
            : DateTime.tryParse(b['orderDate']?.toString() ?? '') ??
                DateTime.now();
        return dateB.compareTo(dateA);
      });

      setState(() {
        orders = mergedOrders; // Remove fallback to sample orders
        isLoading = false;
      });
    } catch (e) {
      print('Error loading orders: $e');

      // Fallback to local orders if API fails
      try {
        final localOrders = await OrderService().getOrders();
        setState(() {
          orders = localOrders; // Remove fallback to sample orders
          isLoading = false;
        });
      } catch (localError) {
        // Show empty list instead of sample orders
        setState(() {
          orders = []; // Empty list instead of sample orders
          isLoading = false;
        });
      }
    }
  }

  // Convert database order format to local order format
  Map<String, dynamic> _convertDatabaseOrderToLocal(
      Map<String, dynamic> dbOrder) {
    return {
      'id': dbOrder['order_number'] ?? dbOrder['id']?.toString() ?? 'Unknown',
      'productName': dbOrder['product_name'] ?? 'Unknown Product',
      'productImage': dbOrder['product_image'], // Add product image
      'shopName': dbOrder['shop_name'] ?? 'Unknown Shop',
      'shopPhone': dbOrder['shop_phone'] ?? 'No Phone',
      'shopAddress': dbOrder['shop_address'] ?? 'No Address',
      'quantity': dbOrder['quantity_ordered'] ?? 1,
      'unit': dbOrder['unit'] ?? 'units',
      'unitPrice': _parseDouble(dbOrder['unit_price']) ?? 0.0,
      'totalPrice': _parseDouble(dbOrder['total_amount']) ?? 0.0,
      'orderDate': _parseDateTime(dbOrder['created_at']) ?? DateTime.now(),
      'status': _mapDatabaseStatus(dbOrder['status']),
      'deliveryAddress': dbOrder['delivery_address'] ?? 'No Address',
      'deliveryPhone': dbOrder['delivery_phone'] ?? 'No Phone',
      'estimatedDelivery': _parseDateTime(dbOrder['estimated_delivery']) ??
          DateTime.now().add(const Duration(days: 3)),
      'cancellationReason': dbOrder['cancellation_reason'], // Add cancellation reason
    };
  }

  // Helper method to parse double values
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // Helper method to parse DateTime values
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // Map database status to local status
  String _mapDatabaseStatus(dynamic dbStatus) {
    final status = dbStatus?.toString().toLowerCase() ?? 'pending';
    switch (status) {
      case 'pending':
      case 'confirmed':
      case 'on going':
      case 'delivered':
      case 'cancelled':
        return status;
      default:
        return 'pending';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
      case 'on going':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'confirmed':
        return Icons.check_circle;
      case 'on going':
        return Icons.work;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order ${order['id']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Section
              if (order['productImage'] != null &&
                  order['productImage'].toString().isNotEmpty)
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        order['productImage'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.indigo.withOpacity(0.1),
                            child: const Icon(
                              Icons.shopping_bag,
                              color: Colors.indigo,
                              size: 48,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              _buildInfoRow('Product', order['productName']),
              _buildInfoRow('Shop', order['shopName']),
              _buildInfoRow('Shop Phone', order['shopPhone']),
              _buildInfoRow('Shop Address', order['shopAddress']),
              _buildInfoRow(
                  'Quantity', '${order['quantity']} ${order['unit']}'),
              _buildInfoRow(
                  'Unit Price', '৳${order['unitPrice'].toStringAsFixed(2)}'),
              _buildInfoRow(
                  'Total Price', '৳${order['totalPrice'].toStringAsFixed(2)}'),
              _buildInfoRow('Order Date', _formatDate(order['orderDate'])),
              _buildInfoRow('Estimated Delivery',
                  _formatDate(order['estimatedDelivery'])),
              _buildInfoRow('Status', order['status'].toString().toUpperCase()),
              // Show cancellation reason if order is cancelled
              if (order['status'] == 'cancelled')
                _buildInfoRow(
                    'Cancellation Reason', 
                    order['cancellationReason'] ?? 'change my mind'
                ),
              const SizedBox(height: 16),
              const Text('Delivery Details:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildInfoRow('Address', order['deliveryAddress']),
              _buildInfoRow('Phone', order['deliveryPhone']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (order['status'] != 'delivered' && order['status'] != 'cancelled')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditDeliveryDialog(order);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Edit Delivery'),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showEditDeliveryDialog(Map<String, dynamic> order) {
    final TextEditingController addressController =
        TextEditingController(text: order['deliveryAddress']);
    final TextEditingController phoneController =
        TextEditingController(text: order['deliveryPhone']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Delivery Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Delivery Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Update in OrderService
                await OrderService().updateDeliveryDetails(
                  order['id'],
                  addressController.text,
                  phoneController.text,
                );

                // Update local state
                setState(() {
                  order['deliveryAddress'] = addressController.text;
                  order['deliveryPhone'] = phoneController.text;
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Delivery details updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update delivery details: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _cancelOrder(Map<String, dynamic> order) async {
    // Navigate to cancel order screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CancelOrderScreen(order: order),
      ),
    );

    // If cancellation was successful, refresh the orders list
    if (result == true) {
      _loadOrders(); // Refresh the orders list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.isInBottomNav && widget.onNavigateToHome != null) {
              // If we're in bottom navigation context, call the callback to switch to home tab
              widget.onNavigateToHome!();
            } else {
              // Otherwise, navigate to MainCustomerScreen (for cases like profile navigation)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainCustomerScreen(
                    userName: widget.userName,
                    userEmail: widget.userEmail,
                    userRole: widget.userRole,
                  ),
                ),
              );
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await _loadOrders();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Orders refreshed'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Orders',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 100,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No orders found',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your order history will appear here after you place your first order',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final statusColor = _getStatusColor(order['status']);
                      final statusIcon = _getStatusIcon(order['status']);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order ${order['id']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: statusColor),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(statusIcon,
                                            size: 14, color: statusColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          order['status']
                                              .toString()
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: order['productImage'] != null &&
                                              order['productImage']
                                                  .toString()
                                                  .isNotEmpty
                                          ? Image.network(
                                              order['productImage'],
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.indigo
                                                      .withOpacity(0.1),
                                                  child: const Icon(
                                                    Icons.shopping_bag,
                                                    color: Colors.indigo,
                                                    size: 24,
                                                  ),
                                                );
                                              },
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Container(
                                                  color: Colors.grey.shade200,
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              color: Colors.indigo
                                                  .withOpacity(0.1),
                                              child: const Icon(
                                                Icons.shopping_bag,
                                                color: Colors.indigo,
                                                size: 24,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order['productName'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Shop: ${order['shopName']}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          'Quantity: ${order['quantity']} ${order['unit']}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '৳${order['totalPrice'].toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(order['orderDate']),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _showOrderDetails(order),
                                      child: const Text('View Details'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (order['status'] != 'delivered' &&
                                      order['status'] != 'cancelled' &&
                                      order['status'] != 'on going')
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _showEditDeliveryDialog(order),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Edit Delivery'),
                                      ),
                                    ),
                                  if (order['status'] == 'on going')
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.blue[300]!),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.work,
                                                size: 16,
                                                color: Colors.blue[700]),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Order Being Prepared',
                                              style: TextStyle(
                                                color: Colors.blue[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (order['status'] == 'pending')
                                    const SizedBox(width: 8),
                                  if (order['status'] == 'pending')
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _cancelOrder(order),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
