import 'package:flutter/material.dart';

class ShopOwnerRefillHistoryScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;

  const ShopOwnerRefillHistoryScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  State<ShopOwnerRefillHistoryScreen> createState() =>
      _ShopOwnerRefillHistoryScreenState();
}

class _ShopOwnerRefillHistoryScreenState
    extends State<ShopOwnerRefillHistoryScreen> {
  List<Map<String, dynamic>> refillHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRefillHistory();
  }

  Future<void> _loadRefillHistory() async {
    setState(() {
      isLoading = true;
    });

    // Sample data - replace with actual API call
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      refillHistory = [
        {
          'id': 'ref001',
          'product_name': 'চাল (সরু)',
          'wholesaler_name': 'রহমান ট্রেডার্স',
          'quantity': 50,
          'unit': 'কেজি',
          'refill_date': '2025-01-15',
          'taken_date': '2025-01-16',
          'status': 'taken',
          'total_amount': 2500.0,
        },
        {
          'id': 'ref002',
          'product_name': 'সয়াবিন তেল',
          'wholesaler_name': 'করিম এন্টারপ্রাইজ',
          'quantity': 20,
          'unit': 'লিটার',
          'refill_date': '2025-01-12',
          'taken_date': '2025-01-13',
          'status': 'taken',
          'total_amount': 3200.0,
        },
        {
          'id': 'ref003',
          'product_name': 'মসুর ডাল',
          'wholesaler_name': 'আলম ইমপোর্ট',
          'quantity': 30,
          'unit': 'কেজি',
          'refill_date': '2025-01-10',
          'taken_date': '2025-01-11',
          'status': 'taken',
          'total_amount': 3600.0,
        },
        {
          'id': 'ref004',
          'product_name': 'পেঁয়াজ (দেশি)',
          'wholesaler_name': 'নিউ সুন্দরবন',
          'quantity': 25,
          'unit': 'কেজি',
          'refill_date': '2025-01-08',
          'taken_date': '2025-01-09',
          'status': 'taken',
          'total_amount': 1250.0,
        },
        {
          'id': 'ref005',
          'product_name': 'গমের আটা',
          'wholesaler_name': 'রহমান ট্রেডার্স',
          'quantity': 40,
          'unit': 'কেজি',
          'refill_date': '2025-01-05',
          'taken_date': '2025-01-06',
          'status': 'taken',
          'total_amount': 1800.0,
        },
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Refill History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRefillHistory,
            tooltip: "Refresh History",
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Info Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[600]!, Colors.purple[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Refill History",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "All refills you have taken from wholesalers",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatChip("Total Taken", "${refillHistory.length}"),
                    const SizedBox(width: 12),
                    _buildStatChip("Total Amount",
                        "৳${_calculateTotalAmount().toStringAsFixed(0)}"),
                  ],
                ),
              ],
            ),
          ),

          // Refill History List
          Expanded(
            child: isLoading ? _buildLoadingView() : _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.purple),
          SizedBox(height: 16),
          Text(
            "Loading refill history...",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (refillHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: refillHistory.length,
      itemBuilder: (context, index) {
        return _buildRefillHistoryCard(refillHistory[index]);
      },
    );
  }

  Widget _buildRefillHistoryCard(Map<String, dynamic> refill) {
    final productName = refill['product_name']?.toString() ?? 'Unknown Product';
    final wholesalerName =
        refill['wholesaler_name']?.toString() ?? 'Unknown Wholesaler';
    final quantity = refill['quantity'] ?? 0;
    final unit = refill['unit']?.toString() ?? 'units';
    final refillDate = refill['refill_date']?.toString() ?? '';
    final takenDate = refill['taken_date']?.toString() ?? '';
    final totalAmount = (refill['total_amount'] ?? 0.0).toDouble();

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
                    Icons.inventory_2,
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
                        child: _buildDetailItem(
                          "Quantity",
                          "$quantity $unit",
                          Icons.scale,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
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
                        child: _buildDetailItem(
                          "Refill Date",
                          _formatDate(refillDate),
                          Icons.calendar_today,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
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
                    onPressed: () => _viewRefillDetails(refill),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text("View Details"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple[600],
                      side: BorderSide(color: Colors.purple[300]!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _reorderProduct(refill),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text("Reorder"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[600],
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

  Widget _buildDetailItem(String label, String value, IconData icon) {
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  double _calculateTotalAmount() {
    return refillHistory.fold(
      0.0,
      (sum, item) => sum + ((item['total_amount'] ?? 0.0) as double),
    );
  }

  void _viewRefillDetails(Map<String, dynamic> refill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.purple[600]),
            const SizedBox(width: 8),
            const Text("Refill Details"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                  "Product", refill['product_name']?.toString() ?? ''),
              _buildDetailRow(
                  "Wholesaler", refill['wholesaler_name']?.toString() ?? ''),
              _buildDetailRow(
                  "Quantity", "${refill['quantity']} ${refill['unit']}"),
              _buildDetailRow("Refill Date",
                  _formatDate(refill['refill_date']?.toString() ?? '')),
              _buildDetailRow("Taken Date",
                  _formatDate(refill['taken_date']?.toString() ?? '')),
              _buildDetailRow("Amount",
                  "৳${(refill['total_amount'] ?? 0.0).toStringAsFixed(2)}"),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
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

  void _reorderProduct(Map<String, dynamic> refill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reorder Product"),
        content: Text(
          "Do you want to reorder '${refill['product_name']}' from '${refill['wholesaler_name']}'?",
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
              backgroundColor: Colors.purple[600],
              foregroundColor: Colors.white,
            ),
            child: const Text("Reorder"),
          ),
        ],
      ),
    );
  }
}
