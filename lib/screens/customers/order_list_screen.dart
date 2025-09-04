import 'package:flutter/material.dart';

import '../../network/customer_api.dart';
import '../../services/order_service.dart';

class OrderListScreen extends StatefulWidget {
  final String orderType; // 'pending', 'ongoing', 'delivered', 'cancelled'
  final String title;
  final String? customerId;
  final String? userName;
  final String? userEmail;
  final String? userRole;

  const OrderListScreen({
    super.key,
    required this.orderType,
    required this.title,
    this.customerId,
    this.userName,
    this.userEmail,
    this.userRole,
  });

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print(
        '🔍 OrderListScreen initialized with orderType: ${widget.orderType}, title: ${widget.title}');
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    print('🔍 _loadOrders called for orderType: ${widget.orderType}');
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> allOrders = [];

      if (widget.orderType == 'cancelled') {
        print('📋 Loading cancelled orders...');
        final apiResult = await CustomerApi.getCancelledOrders();
        print('📡 getCancelledOrders result: $apiResult');
        if (apiResult['success'] == true) {
          final dbOrders = List<Map<String, dynamic>>.from(
              apiResult['cancelled_orders'] ?? []);
          print('✅ Found ${dbOrders.length} cancelled orders from API');
          for (final dbOrder in dbOrders) {
            final convertedOrder = _convertDatabaseOrderToLocal(dbOrder);
            allOrders.add(convertedOrder);
          }
        } else {
          print('❌ Failed to load cancelled orders: ${apiResult['error']}');
        }
      } else {
        print('📋 Loading orders with filter: ${widget.orderType}');
        String? statusFilter;
        if (widget.orderType == 'pending') {
          statusFilter = 'pending';
        } else if (widget.orderType == 'ongoing') {
          statusFilter =
              'preparing'; // Include preparing and ready orders for "ongoing"
        } else if (widget.orderType == 'delivered') {
          statusFilter = 'delivered';
        }

        print('📡 Calling getOrders with status: $statusFilter');
        final apiResult = await CustomerApi.getOrders(status: statusFilter);
        print('📡 getOrders result: $apiResult');
        if (apiResult['success'] == true) {
          final dbOrders =
              List<Map<String, dynamic>>.from(apiResult['orders'] ?? []);
          print('✅ Found ${dbOrders.length} orders from API');
          for (final dbOrder in dbOrders) {
            final convertedOrder = _convertDatabaseOrderToLocal(dbOrder);
            allOrders.add(convertedOrder);
          }
        } else {
          print('❌ Failed to load orders: ${apiResult['error']}');
        }

        // For ongoing orders, also get 'ready' status orders
        if (widget.orderType == 'ongoing') {
          final readyApiResult = await CustomerApi.getOrders(status: 'ready');
          if (readyApiResult['success'] == true) {
            final readyDbOrders =
                List<Map<String, dynamic>>.from(readyApiResult['orders'] ?? []);
            for (final dbOrder in readyDbOrders) {
              final convertedOrder = _convertDatabaseOrderToLocal(dbOrder);
              allOrders.add(convertedOrder);
            }
          }
        }
      }

      // Also check local orders for fallback
      if (widget.orderType != 'cancelled') {
        final localOrders = await OrderService().getOrders();
        for (final localOrder in localOrders) {
          bool shouldInclude = false;

          if (widget.orderType == 'pending') {
            shouldInclude = localOrder['status'] == 'pending' ||
                localOrder['status'] == 'confirmed';
          } else if (widget.orderType == 'ongoing') {
            shouldInclude = localOrder['status'] == 'preparing' ||
                localOrder['status'] == 'ready';
          } else if (widget.orderType == 'delivered') {
            shouldInclude = localOrder['status'] == 'delivered';
          }

          if (shouldInclude &&
              !allOrders.any((order) => order['id'] == localOrder['id'])) {
            allOrders.add(localOrder);
          }
        }
      }

      // Sort by order date (newest first)
      allOrders.sort((a, b) {
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

      print(
          '🎯 Final result for ${widget.orderType}: ${allOrders.length} orders');
      setState(() {
        orders = allOrders;
        isLoading = false;
      });
    } catch (e) {
      print('🚨 Error loading orders: $e');
      setState(() {
        orders = [];
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> _convertDatabaseOrderToLocal(
      Map<String, dynamic> dbOrder) {
    return {
      'id': dbOrder['id']?.toString() ?? 'Unknown',
      'order_number': dbOrder['order_number'] ?? 'Unknown',
      'productName': dbOrder['product_name'] ?? 'Unknown Product',
      'productImage': dbOrder['product_image'],
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
      'cancellationReason': dbOrder['cancellation_reason'],
      'cancelledDate': _parseDateTime(dbOrder['updated_at']),
    };
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _mapDatabaseStatus(dynamic dbStatus) {
    final status = dbStatus?.toString().toLowerCase() ?? 'pending';
    switch (status) {
      case 'pending':
      case 'confirmed':
      case 'preparing':
      case 'ready':
      case 'delivered':
      case 'cancelled':
        return status;
      default:
        return 'pending';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'preparing':
        return Icons.kitchen;
      case 'ready':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF079b11),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No ${widget.orderType} orders found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your ${widget.orderType} orders will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
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
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          title: Text(
                              'Order ${order['order_number'] ?? order['id']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order['productName'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    _getStatusIcon(order['status']),
                                    size: 16,
                                    color: _getStatusColor(order['status']),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    order['status'].toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(order['status']),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Text(
                            '৳${order['totalPrice']?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF079b11),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('Shop', order['shopName']),
                                  _buildDetailRow('Quantity',
                                      '${order['quantity']} ${order['unit']}'),
                                  _buildDetailRow('Unit Price',
                                      '৳${order['unitPrice']?.toStringAsFixed(2) ?? '0.00'}'),
                                  _buildDetailRow('Order Date',
                                      _formatDate(order['orderDate'])),
                                  if (order['status'] == 'cancelled' &&
                                      order['cancellationReason'] != null)
                                    _buildDetailRow('Cancellation Reason',
                                        order['cancellationReason']),
                                  _buildDetailRow('Delivery Address',
                                      order['deliveryAddress']),
                                  _buildDetailRow(
                                      'Delivery Phone', order['deliveryPhone']),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }
}
