import 'package:flutter/material.dart';
import 'package:nitymulya/network/shop_owner_api.dart';
import 'package:nitymulya/screens/shop_owner/order_confirmation_screen.dart';

class ShopOwnerRefillScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;

  const ShopOwnerRefillScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  State<ShopOwnerRefillScreen> createState() => _ShopOwnerRefillScreenState();
}

class _ShopOwnerRefillScreenState extends State<ShopOwnerRefillScreen> {
  List<Map<String, dynamic>> refillItems = [];
  List<Map<String, dynamic>> historyItems = [];
  bool isLoadingRefills = false;
  String? refillError;
  bool showHistory = false; // Track whether to show history or requests

  @override
  void initState() {
    super.initState();
    _loadRefillHistory();
    _loadHistoryData();
  }

  Future<void> _loadRefillHistory() async {
    setState(() {
      isLoadingRefills = true;
      refillError = null;
    });

    try {
      // Load real data from API
      final result = await ShopOwnerApiService.getShopOrders();

      if (result['success'] == true) {
        final orders = result['data'] as List<dynamic>;
        
        setState(() {
          refillItems = orders.map((order) => {
            'id': order['id'],
            'wholesaler_name': order['wholesaler_name'],
            'product_name': order['subcat_name'],
            'quantity': order['quantity_requested'],
            'refill_date': order['created_at'],
            'updated_date': order['updated_at'],
            'status': order['status'],
            'unit_price': double.tryParse(order['unit_price']?.toString() ?? '0') ?? 0.0,
            'total_amount': double.tryParse(order['total_amount']?.toString() ?? '0') ?? 0.0,
            'wholesaler_contact': order['wholesaler_contact'],
            'notes': order['notes'],
            'unit': order['unit'] ?? 'units',
          }).toList();
          isLoadingRefills = false;
        });
      } else {
        setState(() {
          refillError = result['message'] ?? 'Failed to load refill data';
          isLoadingRefills = false;
        });
      }
    } catch (e) {
      setState(() {
        refillError = 'Error loading refill history: $e';
        isLoadingRefills = false;
      });
    }
  }

  Future<void> _loadHistoryData() async {
    // Load completed orders from the same API
    try {
      final result = await ShopOwnerApiService.getShopOrders();

      if (result['success'] == true) {
        final orders = result['data'] as List<dynamic>;
        
        // Filter only completed orders for history
        final completedOrders = orders.where((order) => 
          order['status']?.toString().toLowerCase() == 'completed'
        ).toList();
        
        setState(() {
          historyItems = completedOrders.map((order) => {
            'id': order['id'],
            'product_name': order['subcat_name'],
            'wholesaler_name': order['wholesaler_name'],
            'quantity': order['quantity_requested'],
            'unit': order['unit'] ?? 'units',
            'refill_date': order['created_at'],
            'taken_date': order['updated_at'],
            'status': 'taken',
            'total_amount': double.tryParse(order['total_amount']?.toString() ?? '0') ?? 0.0,
          }).toList();
        });
      }
    } catch (e) {
      // If error loading from API, keep empty list
      setState(() {
        historyItems = [];
      });
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (e) {
      return dateStr.split('T')[0]; // fallback to date part only
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          showHistory ? "Refill History" : "Refill Requests",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (showHistory)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  showHistory = false;
                });
              },
              tooltip: "Back to Requests",
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoadingRefills
                ? null
                : () {
                    if (showHistory) {
                      _loadHistoryData();
                    } else {
                      _loadRefillHistory();
                    }
                  },
            tooltip: "Refresh",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: showHistory
                      ? [Colors.green[600]!, Colors.green[400]!]
                      : [Colors.purple[600]!, Colors.purple[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (showHistory ? Colors.green : Colors.purple)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(showHistory ? Icons.history : Icons.inventory_2,
                          color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              showHistory
                                  ? "� Completed Refills"
                                  : "�📦 New Refill Requests",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              showHistory
                                  ? "All your completed stock refills"
                                  : "Incoming stock refills from wholesalers",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          showHistory ? "TAKEN" : "RECEIVING",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!showHistory) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            showHistory = true;
                          });
                        },
                        icon: const Icon(Icons.history, size: 18),
                        label: const Text("Find All History"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple[600],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            showHistory = false;
                          });
                        },
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text("Back to Requests"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child:
                  showHistory ? _buildHistoryContent() : _buildRefillContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefillContent() {
    if (isLoadingRefills) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading refill history..."),
          ],
        ),
      );
    }

    if (refillError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              refillError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRefillHistory,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (refillItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No refill history found",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Refills from wholesalers will appear here",
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: refillItems.length,
      itemBuilder: (context, index) {
        return _buildRefillCard(refillItems[index]);
      },
    );
  }

  Widget _buildHistoryContent() {
    if (historyItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No refill history found",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your completed refills will appear here",
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: historyItems.length,
      itemBuilder: (context, index) {
        return _buildHistoryCard(historyItems[index]);
      },
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> history) {
    final productName =
        history['product_name']?.toString() ?? 'Unknown Product';
    final wholesalerName =
        history['wholesaler_name']?.toString() ?? 'Unknown Wholesaler';
    final quantity = history['quantity'] ?? 0;
    final unit = history['unit']?.toString() ?? 'units';
    final refillDate = history['refill_date']?.toString() ?? '';
    final takenDate = history['taken_date']?.toString() ?? '';
    final totalAmount = (history['total_amount'] ?? 0.0).toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        wholesalerName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "TAKEN",
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Details Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildHistoryDetailItem(
                          "Quantity",
                          "$quantity $unit",
                          Icons.scale,
                        ),
                      ),
                      Expanded(
                        child: _buildHistoryDetailItem(
                          "Amount",
                          "৳${totalAmount.toStringAsFixed(0)}",
                          Icons.attach_money,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHistoryDetailItem(
                          "Refill Date",
                          _formatDate(refillDate),
                          Icons.calendar_today,
                        ),
                      ),
                      Expanded(
                        child: _buildHistoryDetailItem(
                          "Taken Date",
                          _formatDate(takenDate),
                          Icons.event_available,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewHistoryDetails(history),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text("View Details"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[600],
                      side: BorderSide(color: Colors.green[300]!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _reorderProduct(history),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text("Reorder"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
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

  Widget _buildHistoryDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _viewHistoryDetails(Map<String, dynamic> history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text("History Details"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                  "Product", history['product_name']?.toString() ?? ''),
              _buildDetailRow(
                  "Wholesaler", history['wholesaler_name']?.toString() ?? ''),
              _buildDetailRow(
                  "Quantity", "${history['quantity']} ${history['unit']}"),
              _buildDetailRow("Refill Date",
                  _formatDate(history['refill_date']?.toString() ?? '')),
              _buildDetailRow("Taken Date",
                  _formatDate(history['taken_date']?.toString() ?? '')),
              _buildDetailRow("Amount",
                  "৳${(history['total_amount'] ?? 0.0).toStringAsFixed(2)}"),
              _buildDetailRow("Status", "TAKEN"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _reorderProduct(Map<String, dynamic> history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reorder Product"),
        content: Text(
          "Do you want to reorder '${history['product_name']}' from '${history['wholesaler_name']}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Reorder request sent successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
            child: const Text("Reorder"),
          ),
        ],
      ),
    );
  }

  Widget _buildRefillCard(Map<String, dynamic> refill) {
    final wholesalerName =
        refill['wholesaler_name']?.toString() ?? 'Unknown Wholesaler';
    final productName = refill['product_name']?.toString() ?? 'Unknown Product';
    final quantity = refill['quantity'] ?? 0;
    final refillDate = refill['refill_date']?.toString() ?? '';
    final status = refill['status']?.toString() ?? 'unknown';
    final unitPrice = refill['unit_price'] ?? 0.0;
    final totalAmount = refill['total_amount'] ?? 0.0;
    final unit = refill['unit']?.toString() ?? 'units';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Pending';
        break;
      case 'processing':
        statusColor = Colors.blue;
        statusIcon = Icons.refresh;
        statusText = 'Processing';
        break;
      case 'delivered':
        statusColor = Colors.green;
        statusIcon = Icons.local_shipping;
        statusText = 'Delivered';
        break;
      case 'completed':
        statusColor = Colors.teal;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wholesalerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        productName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Details Row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Quantity
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Quantity",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "$quantity $unit",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Unit Price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Unit Price",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "৳${unitPrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Total Amount
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "৳${totalAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Date and Actions
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(refillDate),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                
                // Accept button for delivered orders
                if (status.toLowerCase() == 'delivered') ...[
                  ElevatedButton.icon(
                    onPressed: () => _navigateToConfirmation(refill),
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text("Accept"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: "details", child: Text("View Details")),
                    if (status.toLowerCase() == 'pending')
                      const PopupMenuItem(
                          value: "cancel", child: Text("Cancel Order")),
                    const PopupMenuItem(
                        value: "contact", child: Text("Contact Wholesaler")),
                  ],
                  onSelected: (value) {
                    _handleRefillAction(value, refill);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleRefillAction(String action, Map<String, dynamic> refill) {
    switch (action) {
      case 'details':
        _showRefillDetails(refill);
        break;
      case 'accept':
        _navigateToConfirmation(refill);
        break;
      case 'cancel':
        _cancelOrder(refill);
        break;
      case 'contact':
        _contactWholesaler(refill);
        break;
    }
  }

  Future<void> _navigateToConfirmation(Map<String, dynamic> refill) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(order: refill),
      ),
    );

    // If the order was confirmed, refresh the list
    if (result == true) {
      _loadRefillHistory();
    }
  }

  void _cancelOrder(Map<String, dynamic> refill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Order"),
        content: Text(
          "Are you sure you want to cancel this order for ${refill['product_name']}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Call API to cancel order
              final result = await ShopOwnerApiService.updateShopOrderStatus(
                orderId: refill['id'].toString(),
                status: 'cancelled',
                notes: 'Cancelled by shop owner',
              );

              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Order cancelled successfully!"),
                    backgroundColor: Colors.orange,
                  ),
                );
                _loadRefillHistory(); // Refresh the list
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? "Failed to cancel order"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );
  }

  void _showRefillDetails(Map<String, dynamic> refill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Refill Details"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                  "Product", refill['product_name']?.toString() ?? ''),
              _buildDetailRow(
                  "Wholesaler", refill['wholesaler_name']?.toString() ?? ''),
              _buildDetailRow("Quantity", "${refill['quantity']} units"),
              _buildDetailRow("Unit Price",
                  "৳${refill['unit_price']?.toStringAsFixed(2) ?? '0.00'}"),
              _buildDetailRow("Total Amount",
                  "৳${refill['total_amount']?.toStringAsFixed(2) ?? '0.00'}"),
              _buildDetailRow("Date", refill['refill_date']?.toString() ?? ''),
              _buildDetailRow("Status", refill['status']?.toString() ?? ''),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
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
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _contactWholesaler(Map<String, dynamic> refill) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Contacting ${refill['wholesaler_name']}..."),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
