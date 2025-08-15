import 'package:flutter/material.dart';

import '../../network/wholesaler_api.dart';

class OrderStatusUpdateScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const OrderStatusUpdateScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  State<OrderStatusUpdateScreen> createState() => _OrderStatusUpdateScreenState();
}

class _OrderStatusUpdateScreenState extends State<OrderStatusUpdateScreen> {
  String selectedStatus = "";
  bool isUpdating = false;
  final List<String> statuses = ["pending", "processing", "delivered", "cancelled"];

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.transaction["status"] as String? ?? "pending";
  }

  @override
  Widget build(BuildContext context) {
    final shopName = widget.transaction["shop_name"] ?? 
                    widget.transaction["full_name"] ?? 
                    "Unknown Shop";
    final productName = widget.transaction["subcat_name"] ?? "Unknown Product";
    final quantity = widget.transaction["quantity_requested"] ?? 
                    widget.transaction["quantity"] ?? 0;
    final unit = widget.transaction["unit"] ?? "";
    final currentStatus = widget.transaction["status"] as String? ?? "pending";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Update Order Status",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Details Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow("Shop Name:", shopName),
                    _buildDetailRow("Product:", productName),
                    _buildDetailRow("Quantity:", "$quantity $unit"),
                    _buildDetailRow("Current Status:", currentStatus.toUpperCase()),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Status Selection
            Text(
              "Select New Status:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status Options
            Expanded(
              child: ListView.builder(
                itemCount: statuses.length,
                itemBuilder: (context, index) {
                  final status = statuses[index];
                  final isSelected = selectedStatus == status;
                  final isCurrentStatus = currentStatus == status;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isSelected ? Colors.green[50] : Colors.white,
                    child: ListTile(
                      leading: Radio<String>(
                        value: status,
                        groupValue: selectedStatus,
                        onChanged: isUpdating ? null : (value) {
                          setState(() {
                            selectedStatus = value!;
                          });
                        },
                        activeColor: Colors.green[800],
                      ),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isCurrentStatus)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "CURRENT",
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(_getStatusDescription(status)),
                      onTap: isUpdating ? null : () {
                        setState(() {
                          selectedStatus = status;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            
            // Action Buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isUpdating ? null : () {
                        Navigator.pop(context, false); // Return false to indicate no update
                      },
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: (isUpdating || selectedStatus == currentStatus) 
                          ? null 
                          : _updateStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isUpdating
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text("Updating..."),
                              ],
                            )
                          : Text(
                              selectedStatus == currentStatus 
                                  ? "No Change Selected" 
                                  : "Update Status",
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "delivered":
      case "completed":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "processing":
      case "in_progress":
        return Colors.blue;
      case "cancelled":
      case "canceled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return "Order received, awaiting processing";
      case "processing":
        return "Order is being prepared for delivery";
      case "delivered":
        return "Order has been delivered to the shop";
      case "cancelled":
        return "Order has been cancelled";
      default:
        return "";
    }
  }

  Future<void> _updateStatus() async {
    setState(() {
      isUpdating = true;
    });

    try {
      final result = await WholesalerApiService.updateOrderStatus(
        orderId: widget.transaction["id"],
        status: selectedStatus,
      );

      if (result['success']) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "✅ Status updated to '${selectedStatus.toUpperCase()}'",
              ),
              backgroundColor: Colors.green[800],
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Wait a moment for the success message to show, then navigate back
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.pop(context, true); // Return true to indicate successful update
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "❌ Failed to update status: ${result['message'] ?? 'Unknown error'}",
              ),
              backgroundColor: Colors.red[800],
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("💥 Error updating status: $e"),
            backgroundColor: Colors.red[800],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }
}
