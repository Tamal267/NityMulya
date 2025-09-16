import 'package:flutter/material.dart';
import '../../config/api_config.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> complaint;

  const ComplaintDetailsScreen({super.key, required this.complaint});

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  List<String> attachments = [];
  bool isLoadingAttachments = true;

  @override
  void initState() {
    super.initState();
    _loadAttachments();
  }

  void _loadAttachments() async {
    // For now, just use the file_url from the current complaint
    // TODO: Implement backend endpoint to get all attachments for a complaint number
    final fileUrl = widget.complaint['file_url'];
    setState(() {
      if (fileUrl != null && fileUrl.toString().isNotEmpty) {
        attachments = [fileUrl.toString()];
      } else {
        attachments = [];
      }
      isLoadingAttachments = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final complaint = widget.complaint;
    final status = complaint['status'] ?? 'Received';
    final priority = complaint['priority'] ?? 'Medium';
    final severity = complaint['severity'] ?? 'Minor';

    Color statusColor = Colors.orange;
    if (status == 'Solved') statusColor = Colors.green;
    if (status == 'Forwarded') statusColor = Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          complaint['complaint_number'] ?? 'Complaint Details',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'forward') {
                _showForwardDialog(context);
              } else if (value == 'resolve') {
                _showResolveDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'forward',
                child: Row(
                  children: [
                    Icon(Icons.forward),
                    SizedBox(width: 8),
                    Text('Forward'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'resolve',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Mark as Resolved'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              elevation: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withOpacity(0.1),
                      statusColor.withOpacity(0.05)
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Complaint Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complaint Number: ${complaint['complaint_number'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Submitted: ${_formatDateTime(complaint['submitted_at'])}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Customer Information
            _buildSection(
              'Customer Information',
              Icons.person,
              [
                _buildDetailRow('Name', complaint['customer_name'] ?? 'N/A'),
                _buildDetailRow('Email', complaint['customer_email'] ?? 'N/A'),
                _buildDetailRow('Phone', complaint['customer_phone'] ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16),

            // Shop Information
            _buildSection(
              'Shop Information',
              Icons.store,
              [
                _buildDetailRow('Shop Name', complaint['shop_name'] ?? 'N/A'),
                if (complaint['product_name'] != null)
                  _buildDetailRow('Product', complaint['product_name']),
              ],
            ),
            const SizedBox(height: 16),

            // Complaint Details
            _buildSection(
              'Complaint Details',
              Icons.report_problem,
              [
                _buildDetailRow('Category', complaint['category'] ?? 'N/A'),
                _buildDetailRow('Priority', priority,
                    valueColor: _getPriorityColor(priority)),
                _buildDetailRow('Severity', severity,
                    valueColor: _getSeverityColor(severity)),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.description, color: Color(0xFF1976D2)),
                        SizedBox(width: 8),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        complaint['description'] ?? 'No description provided',
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // File Attachments Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.attach_file, color: Color(0xFF1976D2)),
                        SizedBox(width: 8),
                        Text(
                          'File Attachments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    isLoadingAttachments
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : attachments.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: Colors.grey),
                                    SizedBox(width: 8),
                                    Text(
                                      'No file attachments found',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: attachments.map((fileUrl) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child:
                                        _buildFileAttachment(context, fileUrl),
                                  );
                                }).toList(),
                              ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 8),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showForwardDialog(context),
                    icon: const Icon(Icons.forward),
                    label: const Text('Forward'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showResolveDialog(context),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Resolve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF1976D2)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: valueColor ?? Colors.black87,
                fontWeight: valueColor != null ? FontWeight.w500 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'major':
        return Colors.orange;
      case 'moderate':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  String _formatDateTime(dynamic dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateStr.toString());
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  void _showForwardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forward Complaint'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Forward this complaint to relevant department?'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Add comment (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Complaint forwarded successfully'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Forward'),
          ),
        ],
      ),
    );
  }

  void _showResolveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Complaint'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mark this complaint as resolved?'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Resolution comment',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Complaint resolved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  // Build file attachment widget with enhanced image display
  Widget _buildFileAttachment(BuildContext context, String? fileUrl) {
    if (fileUrl == null || fileUrl.isEmpty) {
      return const Text(
        'No attachments',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    final fileName = fileUrl.split('/').last;
    final isImage = fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png') ||
        fileName.toLowerCase().endsWith('.gif');
    final isVideo = fileName.toLowerCase().endsWith('.mp4') ||
        fileName.toLowerCase().endsWith('.mov') ||
        fileName.toLowerCase().endsWith('.avi');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced file preview
          InkWell(
            onTap: () =>
                _openFileFullScreen(context, fileUrl, fileName, isImage),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              height:
                  isImage ? 300 : 120, // Increased height for better image view
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: isImage
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Image.network(
                            '${ApiConfig.baseUrl}$fileUrl',
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image,
                                        size: 64, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 16),
                                    ),
                                    Text(
                                      'Click to retry',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Loading image...',
                                      style: TextStyle(
                                          color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          // Overlay for better UX
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.fullscreen,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'View Full',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isVideo
                                  ? Colors.red.shade50
                                  : Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isVideo ? Icons.videocam : Icons.attach_file,
                              size: 48,
                              color: isVideo
                                  ? Colors.red.shade600
                                  : Colors.blue.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isVideo ? 'Video File' : 'File Attachment',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Click to view',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          // Enhanced file info section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isImage
                        ? Colors.green.shade100
                        : (isVideo
                            ? Colors.red.shade100
                            : Colors.blue.shade100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isImage
                        ? Icons.image
                        : (isVideo ? Icons.videocam : Icons.attach_file),
                    size: 24,
                    color: isImage
                        ? Colors.green.shade700
                        : (isVideo
                            ? Colors.red.shade700
                            : Colors.blue.shade700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isImage
                            ? 'Image • Click to zoom'
                            : (isVideo
                                ? 'Video File • Click to view'
                                : 'File • Click to download'),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => _openFileFullScreen(
                        context, fileUrl, fileName, isImage),
                    icon: Icon(
                      Icons.open_in_new,
                      color: Colors.blue.shade700,
                    ),
                    tooltip: isImage ? 'View full screen' : 'Open file',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Open file in full screen
  void _openFileFullScreen(
      BuildContext context, String fileUrl, String fileName, bool isImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(fileName),
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: isImage
                ? InteractiveViewer(
                    child: Image.network(
                      '${ApiConfig.baseUrl}$fileUrl',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image,
                                size: 64, color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        fileName.toLowerCase().endsWith('.mp4') ||
                                fileName.toLowerCase().endsWith('.mov') ||
                                fileName.toLowerCase().endsWith('.avi')
                            ? Icons.videocam
                            : Icons.attach_file,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        fileName,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Implement file download or external viewer
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('File download not implemented yet'),
                            ),
                          );
                        },
                        child: const Text('Download File'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
