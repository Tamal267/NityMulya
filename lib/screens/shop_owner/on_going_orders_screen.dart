import 'package:flutter/material.dart';
import 'package:nitymulya/network/shop_owner_api.dart';

class OnGoingOrdersScreen extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String? userRole;

  const OnGoingOrdersScreen({
    super.key,
    this.userName,
    this.userEmail,
    this.userRole,
  });

  @override
  State<OnGoingOrdersScreen> createState() => _OnGoingOrdersScreenState();
}

class _OnGoingOrdersScreenState extends State<OnGoingOrdersScreen> {
  List<Map<String, dynamic>> onGoingOrders = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadOnGoingOrders();
  }

  Future<void> _loadOnGoingOrders() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await ShopOwnerApiService.getOrders();

      if (result['success'] == true) {
        final allOrders = List<Map<String, dynamic>>.from(result['data'] ?? []);

        // Filter only "on going" orders
        final filteredOrders = allOrders.where((order) {
          final status = order['status']?.toString().toLowerCase() ?? '';
          return status == 'on going' || status == 'confirmed';
        }).toList();

        setState(() {
          onGoingOrders = filteredOrders;
          isLoading = false;
        });
      } else {
        setState(() {
          error = result['message'] ?? 'Failed to load orders';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error loading orders: $e';
        isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on going':
      case 'confirmed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'on going':
      case 'confirmed':
        return Icons.work;
      default:
        return Icons.help;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return 'Unknown time';
    try {
      final date = DateTime.parse(dateString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown time';
    }
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final customerName =
        order['customer_name']?.toString() ?? 'Unknown Customer';
    final productName = order['product_name']?.toString() ?? 'Unknown Product';
    final quantity = order['quantity_ordered'] ?? 0;
    final status = order['status']?.toString() ?? 'on going';
    final orderNumber = order['order_number']?.toString() ?? '';
    final createdAt = order['created_at']?.toString() ?? '';
    final totalAmount = order['total_amount'] ?? 0.0;
    final deliveryAddress =
        order['delivery_address']?.toString() ?? 'No address';
    final deliveryPhone = order['delivery_phone']?.toString() ?? 'No phone';

    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final displayTotalAmount = totalAmount is String
        ? double.tryParse(totalAmount) ?? 0.0
        : totalAmount.toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with order number and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order $orderNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status.toUpperCase(),
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

            // Customer and product info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.2),
                  child: Icon(Icons.person, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '$productName × $quantity units',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Total: ৳${displayTotalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatTime(createdAt),
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

            // Delivery info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      const Text(
                        'Delivery Address:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deliveryAddress,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      const Text(
                        'Phone:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        deliveryPhone,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showOrderDetails(order),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _markAsDelivered(order),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Mark Delivered'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order ${order['order_number']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                  'Customer', order['customer_name']?.toString() ?? 'Unknown'),
              _buildDetailRow(
                  'Product', order['product_name']?.toString() ?? 'Unknown'),
              _buildDetailRow(
                  'Quantity', '${order['quantity_ordered'] ?? 0} units'),
              _buildDetailRow('Unit Price',
                  '৳${(order['unit_price'] ?? 0.0).toStringAsFixed(2)}'),
              _buildDetailRow('Total Amount',
                  '৳${(order['total_amount'] ?? 0.0).toStringAsFixed(2)}'),
              _buildDetailRow(
                  'Status', order['status']?.toString() ?? 'Unknown'),
              _buildDetailRow(
                  'Order Date', _formatDate(order['created_at']?.toString())),
              _buildDetailRow('Delivery Address',
                  order['delivery_address']?.toString() ?? 'No address'),
              _buildDetailRow('Delivery Phone',
                  order['delivery_phone']?.toString() ?? 'No phone'),
              if (order['notes'] != null &&
                  order['notes'].toString().isNotEmpty)
                _buildDetailRow('Notes', order['notes'].toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  void _markAsDelivered(Map<String, dynamic> order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Delivered'),
        content: Text(
            'Are you sure you want to mark order ${order['order_number']} as delivered?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark Delivered'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await ShopOwnerApiService.updateOrderStatus(
        orderId: order['id'].toString(),
        status: 'delivered',
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Order ${order['order_number']} marked as delivered!'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the orders list
        _loadOnGoingOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update order'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('On Going Orders'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadOnGoingOrders,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Orders',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOnGoingOrders,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : onGoingOrders.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_off_outlined,
                            size: 100,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No On Going Orders',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Orders that are confirmed and in progress will appear here',
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
                      onRefresh: _loadOnGoingOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: onGoingOrders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(onGoingOrders[index]);
                        },
                      ),
                    ),
    );
  }
}
