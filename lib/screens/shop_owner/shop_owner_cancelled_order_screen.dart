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

    // Check multiple possible field names for cancellation reason
    final rejectionReason = order['rejection_reason']?.toString() ??
        order['cancellation_reason']?.toString() ??
        order['cancel_reason']?.toString() ??
        order['reason']?.toString();

    // Debug print to see what fields we have
    print('Order fields: ${order.keys.toList()}');
    print('Rejection reason: $rejectionReason');

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
            if (rejectionReason != null && rejectionReason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.cancel, color: Colors.red[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cancellation Reason:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rejectionReason,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Show default message if no reason is provided
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No cancellation reason provided',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
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
    );
  }
}
