import 'package:flutter/material.dart';
import 'package:nitymulya/models/complaint.dart';
import 'package:nitymulya/services/dncrp_service.dart';

class DNCRPComplaintDetailDialog extends StatefulWidget {
  final Complaint complaint;
  final Function(String) onStatusUpdate;

  const DNCRPComplaintDetailDialog({
    super.key,
    required this.complaint,
    required this.onStatusUpdate,
  });

  @override
  State<DNCRPComplaintDetailDialog> createState() =>
      _DNCRPComplaintDetailDialogState();
}

class _DNCRPComplaintDetailDialogState
    extends State<DNCRPComplaintDetailDialog> {
  final DNCRPService _dncrpService = DNCRPService();
  final TextEditingController _commentController = TextEditingController();

  Map<String, dynamic>? complaintDetails;
  List<ComplaintHistory> history = [];
  Map<String, dynamic>? shopDetails;
  Map<String, dynamic>? customerDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComplaintDetails();
  }

  Future<void> _loadComplaintDetails() async {
    setState(() => isLoading = true);

    try {
      final details = await _dncrpService
          .getComplaintDetails(widget.complaint.id.toString());
      final shop = await _dncrpService.getShopDetails(widget.complaint.shopId);
      final customer =
          await _dncrpService.getCustomerDetails(widget.complaint.customerId);

      setState(() {
        complaintDetails = details;
        history = (details['history'] as List?)
                ?.map((h) => ComplaintHistory.fromJson(h))
                .toList() ??
            [];
        shopDetails = shop;
        customerDetails = customer;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildComplaintInfo(),
                          const SizedBox(height: 20),
                          _buildCustomerInfo(),
                          const SizedBox(height: 20),
                          _buildShopInfo(),
                          const SizedBox(height: 20),
                          _buildProofFiles(),
                          const SizedBox(height: 20),
                          _buildStatusHistory(),
                          const SizedBox(height: 20),
                          _buildStatusUpdateSection(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complaint Details',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.complaint.complaintNumber,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildComplaintInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complaint Information',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Category', widget.complaint.category),
            _buildInfoRow('Priority', widget.complaint.priority),
            _buildInfoRow('Severity', widget.complaint.severity),
            _buildInfoRow('Status', widget.complaint.status),
            _buildInfoRow('Product', widget.complaint.productName ?? 'N/A'),
            const SizedBox(height: 8),
            const Text(
              'Description:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                widget.complaint.description,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    if (customerDetails == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', customerDetails!['name'] ?? 'N/A'),
            _buildInfoRow('Email', customerDetails!['email'] ?? 'N/A'),
            _buildInfoRow('Phone', customerDetails!['phone'] ?? 'N/A'),
            _buildInfoRow('Location', customerDetails!['location'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildShopInfo() {
    if (shopDetails == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shop Information',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Shop Name', shopDetails!['name'] ?? 'N/A'),
            _buildInfoRow('Location', shopDetails!['location'] ?? 'N/A'),
            _buildInfoRow('Address', shopDetails!['address'] ?? 'N/A'),
            _buildInfoRow('Phone', shopDetails!['phone'] ?? 'N/A'),
            _buildInfoRow(
                'Status', shopDetails!['verification_status'] ?? 'N/A'),
            if (shopDetails!['description'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(shopDetails!['description']),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProofFiles() {
    if (widget.complaint.files == null || widget.complaint.files!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Proof Files',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...widget.complaint.files!.map((file) => _buildFileItem(file)),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(ComplaintFile file) {
    IconData icon;
    Color color;

    switch (file.fileType) {
      case 'image':
        icon = Icons.image;
        color = Colors.green;
        break;
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'video':
        icon = Icons.video_file;
        color = Colors.purple;
        break;
      default:
        icon = Icons.attach_file;
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              file.fileName,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement file preview/download
            },
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHistory() {
    if (history.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status History',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...history.map((h) => _buildHistoryItem(h)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(ComplaintHistory historyItem) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Status changed to: ${historyItem.newStatus}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text(
                      _formatDateTime(historyItem.timestamp),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                if (historyItem.changedByName != null)
                  Text(
                    'By: ${historyItem.changedByName}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                if (historyItem.comment != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      historyItem.comment!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateSection() {
    if (widget.complaint.status == 'Solved') return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Status',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Add comment (optional)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (widget.complaint.status == 'Received')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus('Forwarded'),
                      icon: const Icon(Icons.send),
                      label: const Text('Forward'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (widget.complaint.status == 'Forwarded')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus('Solved'),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark as Solved'),
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

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _downloadComplaintAsPDF,
          icon: const Icon(Icons.download),
          label: const Text('Download PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _updateStatus(String newStatus) async {
    try {
      await _dncrpService.updateComplaintStatus(
        widget.complaint.id.toString(),
        newStatus,
        comment: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
      );

      widget.onStatusUpdate(newStatus);
      _commentController.clear();
      await _loadComplaintDetails(); // Refresh data

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _downloadComplaintAsPDF() async {
    try {
      await _dncrpService.downloadComplaintsAsPDF([widget.complaint]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
