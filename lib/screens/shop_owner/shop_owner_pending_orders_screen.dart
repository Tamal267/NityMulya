import 'package:flutter/material.dart';
import 'package:nitymulya/network/shop_owner_api.dart';
import 'package:nitymulya/utils/user_session.dart';

import '../../services/message_api_service.dart';

class PendingOrdersScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;

  const PendingOrdersScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  State<PendingOrdersScreen> createState() => _PendingOrdersScreenState();
}

class _PendingOrdersScreenState extends State<PendingOrdersScreen> {
  List<Map<String, dynamic>> pendingOrders = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadPendingOrders();
  }

  Future<void> _loadPendingOrders() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await ShopOwnerApiService.getOrders();

      if (result['success'] == true) {
        final allOrders = List<Map<String, dynamic>>.from(result['data'] ?? []);
        setState(() {
          // Filter for pending orders
          pendingOrders = allOrders
              .where((order) =>
                  order['status']?.toString().toLowerCase() == 'pending')
              .toList();
          isLoading = false;
        });

        debugPrint('📋 Pending Orders Loaded: ${pendingOrders.length}');
      } else {
        setState(() {
          error = result['message'] ?? 'Failed to load pending orders';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error loading pending orders: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _acceptOrder(Map<String, dynamic> order) async {
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
              Text('Accepting order...'),
            ],
          ),
        ),
      );

      final result = await ShopOwnerApiService.updateOrderStatus(
        orderId: order['id'].toString(),
        status: 'on going',
      );

      Navigator.pop(context); // Close loading dialog

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Order accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPendingOrders(); // Reload to update the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('💬 ${result['message'] ?? 'Failed to accept order'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('💬 Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendMessageToCustomer(Map<String, dynamic> order) async {
    final TextEditingController messageController = TextEditingController();
    final customerName =
        order['customer_name']?.toString() ?? 'Unknown Customer';
    final productName = order['product_name']?.toString() ??
        order['subcat_name']?.toString() ??
        'Unknown Product';
    final quantity = order['quantity_ordered']?.toString() ??
        order['quantity']?.toString() ??
        '0';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.message, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('💬 Send Message'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Order Context
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Details:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Customer: $customerName'),
                    Text('Product: $productName × $quantity'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Message Input
              Text(
                'Your Message:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Type your message to the customer...\nExample: "Product is available, but delivery will be delayed by 1 day. Is that okay?"',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (messageController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('💬 Please enter a message'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Send Message'),
          ),
        ],
      ),
    );

    if (result == true && messageController.text.trim().isNotEmpty) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Sending message...'),
            ],
          ),
        ),
      );

      try {
        // Get shop owner ID from user session
        final userData = await UserSession.getCurrentUserData();
        final shopOwnerId = userData?['id']?.toString() ?? 'unknown_shop';

        debugPrint('📧 Sending message from shop owner: $shopOwnerId');
        debugPrint('📧 To customer: ${order['customer_id']}');
        debugPrint('📧 Order: ${order['order_id'] ?? order['order_number']}');

        // Send message using real API
        final result = await MessageApiService.sendMessage(
          orderId: order['order_id']?.toString() ??
              order['order_number']?.toString() ??
              'unknown',
          senderType: 'shop_owner',
          senderId: shopOwnerId,
          receiverType: 'customer',
          receiverId: order['customer_id']?.toString() ?? 'unknown_customer',
          messageText: messageController.text.trim(),
        );

        Navigator.pop(context); // Close loading dialog

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('💬 Message sent to $customerName successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Log the message for debugging
          debugPrint(
              '💬 Message sent to $customerName: ${messageController.text}');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('💬 Failed to send message: ${result['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('💬 Error sending message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Pending Orders (${pendingOrders.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingOrders,
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
            Text('Loading pending orders...'),
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
              onPressed: _loadPendingOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (pendingOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: Colors.green[300]),
            const SizedBox(height: 16),
            Text(
              '🎉 No Pending Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All orders have been processed!',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPendingOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingOrders.length,
        itemBuilder: (context, index) {
          return _buildPendingOrderCard(pendingOrders[index]);
        },
      ),
    );
  }

  Widget _buildPendingOrderCard(Map<String, dynamic> order) {
    // Debug print to see actual field names
    debugPrint('🔍 Order Data: ${order.keys.toList()}');

    final customerName =
        order['customer_name']?.toString() ?? 'Unknown Customer';
    // Use product_name from backend (not subcat_name)
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
    final orderDate = order['created_at']?.toString() ?? '';
    final address =
        order['delivery_address']?.toString() ?? 'No address provided';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange[200]!),
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
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'PENDING',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  orderDate.isNotEmpty
                      ? orderDate.substring(0, 10)
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
                Icon(Icons.person, color: Colors.orange[600], size: 18),
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
                Icon(Icons.shopping_bag, color: Colors.orange[600], size: 18),
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
                Icon(Icons.location_on, color: Colors.orange[600], size: 18),
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
                  child: ElevatedButton.icon(
                    onPressed: () => _sendMessageToCustomer(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue[600],
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.message, size: 18),
                    label: const Text('Message'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptOrder(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
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
