import 'package:flutter/material.dart';
import 'package:nitymulya/network/shop_owner_api.dart';

class DeliveredOrdersScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;

  const DeliveredOrdersScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  State<DeliveredOrdersScreen> createState() => _DeliveredOrdersScreenState();
}

class _DeliveredOrdersScreenState extends State<DeliveredOrdersScreen> {
  List<Map<String, dynamic>> deliveredOrders = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDeliveredOrders();
  }

  Future<void> _loadDeliveredOrders() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await ShopOwnerApiService.getOrders();

      if (result['success'] == true) {
        final allOrders = List<Map<String, dynamic>>.from(result['data'] ?? []);
        setState(() {
          // Filter for delivered orders
          deliveredOrders = allOrders
              .where((order) =>
                  order['status']?.toString().toLowerCase() == 'delivered')
              .toList();
          isLoading = false;
        });

        debugPrint('✅ Delivered Orders Loaded: ${deliveredOrders.length}');
      } else {
        setState(() {
          error = result['message'] ?? 'Failed to load delivered orders';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error loading delivered orders: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _markAsReturned(Map<String, dynamic> order) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('↩️ Mark as Returned'),
        content: Text(
            'Mark this order from ${order['customer_name'] ?? 'Unknown Customer'} as returned?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Mark Returned'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Updating order status...'),
            ],
          ),
        ),
      );

      final result = await ShopOwnerApiService.updateOrderStatus(
        orderId: order['id'].toString(),
        status: 'returned',
      );

      Navigator.pop(context); // Close loading dialog

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('↩️ Order marked as returned!'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadDeliveredOrders(); // Reload to update the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('❌ ${result['message'] ?? 'Failed to mark as returned'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📋 Order Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Order ID', order['id']?.toString() ?? 'N/A'),
              _buildDetailRow(
                  'Customer', order['customer_name']?.toString() ?? 'Unknown'),
              _buildDetailRow(
                  'Product', order['subcat_name']?.toString() ?? 'Unknown'),
              _buildDetailRow(
                  'Category', order['cat_name']?.toString() ?? 'Unknown'),
              _buildDetailRow('Quantity', order['quantity']?.toString() ?? '0'),
              _buildDetailRow(
                  'Unit Price', '৳${order['unit_price']?.toString() ?? '0'}'),
              _buildDetailRow(
                  'Total Price', '৳${order['total_price']?.toString() ?? '0'}'),
              _buildDetailRow(
                  'Status', order['status']?.toString() ?? 'Unknown'),
              _buildDetailRow(
                  'Order Date',
                  order['created_at']?.toString().substring(0, 16) ??
                      'Unknown'),
              _buildDetailRow(
                  'Delivery Date',
                  order['updated_at']?.toString().substring(0, 16) ??
                      'Unknown'),
              const SizedBox(height: 8),
              Text(
                'Delivery Address:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order['delivery_address']?.toString() ?? 'No address provided',
                style: TextStyle(color: Colors.grey[600]),
              ),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Delivered Orders (${deliveredOrders.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeliveredOrders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading delivered orders...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDeliveredOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (deliveredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '📦 No Delivered Orders Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Delivered orders will appear here',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDeliveredOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: deliveredOrders.length,
        itemBuilder: (context, index) {
          return _buildDeliveredOrderCard(deliveredOrders[index]);
        },
      ),
    );
  }

  Widget _buildDeliveredOrderCard(Map<String, dynamic> order) {
    final customerName =
        order['customer_name']?.toString() ?? 'Unknown Customer';
    // Use product_name from backend
    final productName = order['product_name']?.toString() ??
        order['subcat_name']?.toString() ??
        'Unknown Product';
    // Use quantity_ordered from backend
    final quantity = order['quantity_ordered']?.toString() ??
        order['quantity']?.toString() ??
        '0';
    // Calculate total price if not available
    final unitPrice = order['unit_price']?.toString() ?? '0';
    final totalPrice = order['total_price']?.toString() ??
        (double.tryParse(unitPrice) != null && double.tryParse(quantity) != null
            ? (double.parse(unitPrice) * double.parse(quantity)).toString()
            : '0');
    final deliveryDate = order['updated_at']?.toString() ?? '';
    final address =
        order['delivery_address']?.toString() ?? 'No address provided';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'DELIVERED',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  deliveryDate.isNotEmpty
                      ? deliveryDate.substring(0, 10)
                      : 'Unknown Date',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Customer Info
            Row(
              children: [
                Icon(Icons.person, color: Colors.green[600], size: 18),
                const SizedBox(width: 8),
                Text(
                  customerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Product Info
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$productName × $quantity',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  '৳$totalPrice',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: Colors.green[600], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewOrderDetails(order),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[600],
                      side: BorderSide(color: Colors.green[300]!),
                    ),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _markAsReturned(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[50],
                      foregroundColor: Colors.orange[600],
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.undo, size: 18),
                    label: const Text('Mark Returned'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
