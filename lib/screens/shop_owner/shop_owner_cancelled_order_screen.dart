import 'package:flutter/material.dart';
import 'package:nitymulya/network/shop_owner_api.dart';

class CancelledOrdersScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;

  const CancelledOrdersScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  State<CancelledOrdersScreen> createState() => _CancelledOrdersScreenState();
}

class _CancelledOrdersScreenState extends State<CancelledOrdersScreen> {
  List<Map<String, dynamic>> cancelledOrders = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCancelledOrders();
  }

  Future<void> _loadCancelledOrders() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await ShopOwnerApiService.getOrders();

      if (result['success'] == true) {
        final allOrders = List<Map<String, dynamic>>.from(result['data'] ?? []);
        setState(() {
          // Filter for cancelled orders
          cancelledOrders = allOrders.where((order) {
            final status = order['status']?.toString().toLowerCase() ?? '';
            return status == 'cancelled' ||
                status == 'canceled' ||
                status == 'rejected';
          }).toList();
          isLoading = false;
        });

        debugPrint('❌ Cancelled Orders Loaded: ${cancelledOrders.length}');
      } else {
        setState(() {
          error = result['message'] ?? 'Failed to load cancelled orders';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error loading cancelled orders: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _reactivateOrder(Map<String, dynamic> order) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔄 Reactivate Order'),
        content: Text(
            'Reactivate this order from ${order['customer_name'] ?? 'Unknown Customer'} and mark it as pending?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Reactivate'),
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
              Text('Reactivating order...'),
            ],
          ),
        ),
      );

      final result = await ShopOwnerApiService.updateOrderStatus(
        orderId: order['id'].toString(),
        status: 'pending',
      );

      Navigator.pop(context); // Close loading dialog

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔄 Order reactivated and marked as pending!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadCancelledOrders(); // Reload to update the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('❌ ${result['message'] ?? 'Failed to reactivate order'}'),
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
        title: const Text('📋 Cancelled Order Details'),
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
                  'Cancelled Date',
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
              if (order['rejection_reason'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Cancellation Reason:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order['rejection_reason'].toString(),
                  style: TextStyle(color: Colors.red[600]),
                ),
              ],
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
          'Cancelled Orders (${cancelledOrders.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCancelledOrders,
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
            Text('Loading cancelled orders...'),
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
              onPressed: _loadCancelledOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (cancelledOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: Colors.green[300]),
            const SizedBox(height: 16),
            Text(
              '✅ No Cancelled Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Great! No orders have been cancelled',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCancelledOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cancelledOrders.length,
        itemBuilder: (context, index) {
          return _buildCancelledOrderCard(cancelledOrders[index]);
        },
      ),
    );
  }

  Widget _buildCancelledOrderCard(Map<String, dynamic> order) {
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
    final cancelledDate = order['updated_at']?.toString() ?? '';
    final address =
        order['delivery_address']?.toString() ?? 'No address provided';
    final rejectionReason = order['rejection_reason']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red[200]!),
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
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'CANCELLED',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  cancelledDate.isNotEmpty
                      ? cancelledDate.substring(0, 10)
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
                Icon(Icons.person, color: Colors.red[600], size: 18),
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
                Icon(Icons.cancel, color: Colors.red[600], size: 18),
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
                    color: Colors.red[600],
                    fontSize: 16,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: Colors.red[600], size: 18),
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

            // Rejection Reason if available
            if (rejectionReason != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.red[600], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reason: $rejectionReason',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewOrderDetails(order),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[600],
                      side: BorderSide(color: Colors.red[300]!),
                    ),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _reactivateOrder(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[50],
                      foregroundColor: Colors.green[600],
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reactivate'),
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
