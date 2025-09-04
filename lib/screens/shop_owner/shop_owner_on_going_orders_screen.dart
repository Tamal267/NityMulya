import 'package:flutter/material.dart';

import '../../network/shop_owner_api.dart';
import '../../widgets/global_bottom_nav.dart';

class OnGoingOrdersScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;

  const OnGoingOrdersScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  State<OnGoingOrdersScreen> createState() => _OnGoingOrdersScreenState();
}

class _OnGoingOrdersScreenState extends State<OnGoingOrdersScreen> {
  List<Map<String, dynamic>> ongoingOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOngoingOrders();
  }

  Future<void> _loadOngoingOrders() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await ShopOwnerApiService.getOrders();
      if (result['success'] == true) {
        // Filter for ongoing orders
        final allOrders = List<Map<String, dynamic>>.from(result['data'] ?? []);
        final ongoingOrdersList = allOrders.where((order) {
          final status = order['status']?.toString().toLowerCase();
          return status == 'ongoing' || status == 'on going';
        }).toList();

        setState(() {
          ongoingOrders = ongoingOrdersList;
        });
      } else {
        _showSnackBar('Failed to load ongoing orders: ${result['message']}');
      }
    } catch (e) {
      _showSnackBar('Error loading ongoing orders: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      final result = await ShopOwnerApiService.updateOrderStatus(
        orderId: orderId,
        status: newStatus,
      );
      if (result['success'] == true) {
        _showSnackBar('Order status updated successfully');
        _loadOngoingOrders(); // Refresh the list
      } else {
        _showSnackBar('Failed to update order status: ${result['message']}');
      }
    } catch (e) {
      _showSnackBar('Error updating order status: $e');
    }
  }

  Widget _buildOrderTotal(Map<String, dynamic> order) {
    // Get total amount from order (already calculated in backend)
    final totalAmount = order['total_amount'] ?? order['total_price'] ?? 0;
    final displayTotal = totalAmount is String
        ? double.tryParse(totalAmount) ?? 0.0
        : (totalAmount as num).toDouble();

    // Get individual order details
    final quantity = order['quantity_ordered'] ?? 0;
    final unitPrice = order['unit_price'] ?? 0;
    final productName = order['product_name'] ?? 'Unknown Product';
    final unit = order['unit'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total: ৳${displayTotal.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Details:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      productName,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '$quantity $unit',
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '৳$unitPrice/$unit',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Divider(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '৳${displayTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Orders'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ongoingOrders.isEmpty
              ? const Center(
                  child: Text(
                    'No ongoing orders found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOngoingOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ongoingOrders.length,
                    itemBuilder: (context, index) {
                      final order = ongoingOrders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Order #${order['id'] ?? 'N/A'}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            order['status']
                                                    ?.toString()
                                                    .toUpperCase() ??
                                                'ONGOING',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Customer: ${order['customer_name'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 4),
                              _buildOrderTotal(order),
                              const SizedBox(height: 4),
                              Text(
                                'Order Date: ${order['created_at'] ?? 'N/A'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _updateOrderStatus(
                                      order['id']?.toString() ?? '',
                                      'delivered',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    child: const Text(
                                      'Mark as Delivered',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: () => _updateOrderStatus(
                                      order['id']?.toString() ?? '',
                                      'cancelled',
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    child: const Text(
                                      'Cancel Order',
                                      style: TextStyle(fontSize: 14),
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
      bottomNavigationBar: GlobalBottomNav(
        currentIndex: 1,
      ),
    );
  }
}
