import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nitymulya/utils/user_session.dart';

import '../../network/customer_api.dart';
import '../../services/message_api_service.dart';
import '../../services/order_service.dart';
import 'cancel_order_screen.dart';
import 'customer_chat_screen.dart';
import 'main_customer_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  final String? customerId;
  final String? userName;
  final String? userEmail;
  final String? userRole;
  final bool isInBottomNav;
  final VoidCallback? onNavigateToHome;
  final int initialTabIndex;

  const MyOrdersScreen({
    super.key,
    this.customerId,
    this.userName,
    this.userEmail,
    this.userRole,
    this.isInBottomNav = false,
    this.onNavigateToHome,
    this.initialTabIndex = 0,
  });

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  late TabController _tabController;

  // Messages state
  List<Map<String, dynamic>> messages = [];
  bool isLoadingMessages = false;
  Timer? _messageTimer; // Timer for real-time updates

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 6,
        vsync: this,
        initialIndex: widget
            .initialTabIndex); // All, Pending, Ongoing, Delivered, Cancelled, Messages
    _loadOrders();
    _loadMessages(); // Load messages when screen initializes
    _startMessageTimer(); // Start real-time message updates
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageTimer?.cancel(); // Cancel timer
    super.dispose();
  }

  // Start timer for real-time message updates
  void _startMessageTimer() {
    _messageTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _loadMessages(); // Refresh messages every 10 seconds
      }
    });
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
      'cancellationReason':
          dbOrder['cancellation_reason'], // Add cancellation reason
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
                _buildInfoRow('Cancellation Reason',
                    order['cancellationReason'] ?? 'change my mind'),
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

  // Helper method to filter orders by status
  List<Map<String, dynamic>> _getOrdersByStatus(List<String> statuses) {
    return orders.where((order) => statuses.contains(order['status'])).toList();
  }

  // Build regular orders list
  Widget _buildOrdersList(List<Map<String, dynamic>> ordersList) {
    if (ordersList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your orders will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ordersList.length,
        itemBuilder: (context, index) {
          final order = ordersList[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  // Build cancelled orders list with special UI
  Widget _buildCancelledOrdersList(List<Map<String, dynamic>> cancelledOrders) {
    if (cancelledOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cancel_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No cancelled orders',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your cancelled orders will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cancelledOrders.length,
        itemBuilder: (context, index) {
          final order = cancelledOrders[index];
          return _buildCancelledOrderCard(order);
        },
      ),
    );
  }

  // Build individual order card
  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order['id']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(order['status']),
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order['status']?.toString().toUpperCase() ??
                              'UNKNOWN',
                          style: const TextStyle(
                            color: Colors.white,
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
                  // Product Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: order['productImage'] != null &&
                            order['productImage'].toString().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              order['productImage'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.shopping_bag,
                                  color: Colors.grey,
                                  size: 30,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.shopping_bag,
                            color: Colors.grey,
                            size: 30,
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['productName'] ?? 'Unknown Product',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Shop: ${order['shopName'] ?? 'Unknown Shop'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Qty: ${order['quantity']} ${order['unit'] ?? 'units'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ৳${order['totalPrice']?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _showOrderDetails(order),
                        child: const Text('Details'),
                      ),
                      if (order['status'] == 'pending' ||
                          order['status'] == 'confirmed')
                        ElevatedButton(
                          onPressed: () => _cancelOrder(order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: const Text('Cancel'),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build cancelled order card with special styling
  Widget _buildCancelledOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order['id']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cancel,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'CANCELLED',
                            style: TextStyle(
                              color: Colors.white,
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
                    // Product Image with overlay
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: Stack(
                        children: [
                          order['productImage'] != null &&
                                  order['productImage'].toString().isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                      Colors.grey.withOpacity(0.5),
                                      BlendMode.saturation,
                                    ),
                                    child: Image.network(
                                      order['productImage'],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.shopping_bag,
                                          color: Colors.grey,
                                          size: 30,
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.shopping_bag,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                          // Cancelled overlay
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.red.withOpacity(0.2),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['productName'] ?? 'Unknown Product',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Shop: ${order['shopName'] ?? 'Unknown Shop'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Qty: ${order['quantity']} ${order['unit'] ?? 'units'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          // Show cancellation reason if available
                          if (order['cancellationReason'] != null &&
                              order['cancellationReason'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Reason: ${order['cancellationReason']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[700],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ৳${order['totalPrice']?.toStringAsFixed(2) ?? '0.00'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _showOrderDetails(order),
                          child: const Text('Details'),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: const Text(
                            'Order Cancelled',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build messages tab
  Widget _buildMessagesTab() {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Icon(Icons.message, color: Colors.indigo, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chat with Shop Owners',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[700],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _loadMessages,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh Messages',
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoadingMessages
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? _buildEmptyMessagesState()
                    : _buildMessagesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _composeNewMessage,
        backgroundColor: Colors.indigo,
        tooltip: 'New Message',
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyMessagesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with shop owners',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _composeNewMessage,
            icon: const Icon(Icons.message),
            label: const Text('Start Messaging'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageCard(message);
      },
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> message) {
    final bool isFromCustomer = message['sender_type'] == 'customer';
    final bool isUnread = message['is_read'] != true;

    // Map the correct fields from API response
    final shopName = message['shop_name'] ?? 'Unknown Shop';
    final messageText = message['message_text'] ?? 'No message content';
    final messageTime = message['updated_at'] ?? message['created_at'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUnread ? 4 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isUnread
              ? Border.all(color: Colors.indigo, width: 2)
              : Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: isFromCustomer ? Colors.indigo : Colors.green,
            child: Icon(
              isFromCustomer ? Icons.person : Icons.store,
              color: Colors.white,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  shopName,
                  style: TextStyle(
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                messageText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isUnread ? Colors.black87 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatMessageTime(messageTime),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => {},
        ),
      ),
    );
  }

  String _formatMessageTime(dynamic timestamp) {
    if (timestamp == null) return 'Unknown time';

    DateTime time;
    if (timestamp is DateTime) {
      time = timestamp;
    } else if (timestamp is String) {
      time = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      return 'Unknown time';
    }

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      isLoadingMessages = true;
    });

    try {
      // Get customer ID from user session
      final userData = await UserSession.getCurrentUserData();
      final customerId = userData?['id']?.toString() ??
          widget.customerId ??
          'unknown_customer';

      debugPrint('📧 Loading messages for customer: $customerId');

      // Load messages using real API
      final result = await MessageApiService.getCustomerMessages(
        customerId: customerId,
      );

      debugPrint('📧 Messages API result: ${result['success']}');
      debugPrint('📧 Messages count: ${result['data']?.length ?? 0}');

      if (result['success'] == true) {
        setState(() {
          messages = List<Map<String, dynamic>>.from(result['data'] ?? []);
          isLoadingMessages = false;
        });

        debugPrint('📧 Messages loaded successfully: ${messages.length}');
      } else {
        setState(() {
          messages = [];
          isLoadingMessages = false;
        });

        debugPrint('❌ Failed to load messages: ${result['message']}');

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to load messages'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading messages: $e');
      setState(() {
        messages = [];
        isLoadingMessages = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load messages: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _composeNewMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Message'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select a shop from your recent orders to start messaging.'),
            SizedBox(height: 16),
            Text(
              'You can also message shops directly from your order details.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openChatScreen(Map<String, dynamic> message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerChatScreen(
          shopName: message['shop_name'] ?? 'Unknown Shop',
          shopId: message['sender_id'] ?? message['receiver_id'] ?? '',
          orderId: message['order_id'],
          customerId: widget.customerId,
          customerName: widget.userName ?? 'Customer',
        ),
      ),
    );
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              icon: Icon(Icons.all_inclusive),
              text: 'All (${orders.length})',
            ),
            Tab(
              icon: Icon(Icons.pending_actions),
              text: 'Pending (${_getOrdersByStatus([
                    'pending',
                    'confirmed'
                  ]).length})',
            ),
            Tab(
              icon: Icon(Icons.sync),
              text: 'Ongoing (${_getOrdersByStatus([
                    'preparing',
                    'ready',
                    'on going'
                  ]).length})',
            ),
            Tab(
              icon: Icon(Icons.check_circle),
              text: 'Delivered (${_getOrdersByStatus(['delivered']).length})',
            ),
            Tab(
              icon: Icon(Icons.cancel),
              text: 'Cancelled (${_getOrdersByStatus(['cancelled']).length})',
            ),
            Tab(
              icon: Icon(Icons.message),
              text: 'Messages',
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // All Orders Tab
                _buildOrdersList(orders),
                // Pending Orders Tab
                _buildOrdersList(_getOrdersByStatus(['pending', 'confirmed'])),
                // Ongoing Orders Tab
                _buildOrdersList(
                    _getOrdersByStatus(['preparing', 'ready', 'on going'])),
                // Delivered Orders Tab
                _buildOrdersList(_getOrdersByStatus(['delivered'])),
                // Cancelled Orders Tab (with special UI)
                _buildCancelledOrdersList(_getOrdersByStatus(['cancelled'])),
                // Messages Tab
                _buildMessagesTab(),
              ],
            ),
    );
  }
}
