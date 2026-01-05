import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:nitymulya/models/shop.dart';
import 'package:nitymulya/network/customer_api.dart';
import 'package:nitymulya/utils/user_session.dart';
import 'package:nitymulya/screens/auth/login_screen.dart';

class ComplaintSubmissionScreen extends StatefulWidget {
  final Shop shop;
  final int? productId;
  final String? productName;

  const ComplaintSubmissionScreen({
    super.key,
    required this.shop,
    this.productId,
    this.productName,
  });

  @override
  State<ComplaintSubmissionScreen> createState() =>
      _ComplaintSubmissionScreenState();
}

class _ComplaintSubmissionScreenState extends State<ComplaintSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoadingProducts = false;
  List<Map<String, dynamic>> _shopProducts = [];

  // File upload variables (for multiple files)
  final List<File> _selectedFiles = [];
  final List<String> _selectedFileNames = [];
  final List<Uint8List> _selectedFileBytes = []; // For web platform
  final List<String> _selectedFileTypes = []; // To know if it's image or video
  bool _isFileUploading = false;

  // DNCRP Form Fields
  String? _selectedCategory;
  String? _selectedProductId;
  String? _selectedProductName;

  // Bengali Categories (6 predefined types)
  final List<String> _categories = [
    'পণ্যের গুণগত মান সমস্যা', // Product Quality Issue
    'ভুল দাম বা অতিরিক্ত চার্জ', // Wrong Price or Extra Charge
    'পণ্যের ওজন কম', // Product Weight Less
    'খারাপ আচরণ', // Bad Behavior
    'মেয়াদোত্তীর্ণ পণ্য', // Expired Product
    'অন্যান্য', // Others
  ];

  @override
  void initState() {
    super.initState();
    _loadShopProducts();
  }

  // Load products for the specific shop
  void _loadShopProducts() async {
    setState(() => _isLoadingProducts = true);

    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _shopProducts = [
          {'id': 'general', 'name': 'সব পণ্য (সাধারণ অভিযোগ)'},
          {'id': 'na', 'name': 'প্রযোজ্য নয়'},
          {'id': '1', 'name': 'চাল'},
          {'id': '2', 'name': 'ডাল'},
          {'id': '3', 'name': 'তেল'},
          {'id': '4', 'name': 'চিনি'},
          {'id': '5', 'name': 'নুন'},
          {'id': '6', 'name': 'আলু'},
          {'id': '7', 'name': 'পেঁয়াজ'},
        ];
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() => _isLoadingProducts = false);
      print('Error loading products: $e');
    }
  }

  // File picker function (multiple files)
  Future<void> _pickFile() async {
    try {
      setState(() => _isFileUploading = true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media, // This allows images and videos
        allowMultiple: true, // Allow multiple file selection
      );

      if (result != null) {
        for (var platformFile in result.files) {
          final fileName = platformFile.name;

          // Check file size (max 10MB per file)
          final fileSize = platformFile.size;
          if (fileSize > 10 * 1024 * 1024) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '$fileName ফাইলের আকার ১০ MB এর বেশি, এটি যোগ করা হয়নি'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            continue; // Skip this file
          }

          // Handle both web and mobile platforms
          if (kIsWeb) {
            // Web platform - use bytes
            if (platformFile.bytes != null) {
              setState(() {
                _selectedFiles.add(File('')); // Placeholder for web
                _selectedFileBytes.add(platformFile.bytes!);
                _selectedFileNames.add(fileName);
                _selectedFileTypes.add(_getFileType(fileName));
              });
            }
          } else {
            // Mobile/Desktop - use path
            if (platformFile.path != null) {
              final file = File(platformFile.path!);
              setState(() {
                _selectedFiles.add(file);
                _selectedFileBytes.add(Uint8List(0)); // Placeholder for mobile
                _selectedFileNames.add(fileName);
                _selectedFileTypes.add(_getFileType(fileName));
              });
            }
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.files.length} টি ফাইল নির্বাচিত হয়েছে'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Error picking files: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ফাইল নির্বাচনে সমস্যা: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isFileUploading = false);
    }
  }

  // Helper method to detect file type
  String _getFileType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return 'image';
    } else if (['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', '3gp']
        .contains(extension)) {
      return 'video';
    }
    return 'file';
  }

  // Remove selected file
  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _selectedFileBytes.removeAt(index);
      _selectedFileNames.removeAt(index);
      _selectedFileTypes.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ফাইল সরানো হয়েছে'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  // Clear all selected files
  void _clearAllFiles() {
    setState(() {
      _selectedFiles.clear();
      _selectedFileBytes.clear();
      _selectedFileNames.clear();
      _selectedFileTypes.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('সব ফাইল সরানো হয়েছে'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  // Build image preview widget for specific file
  Widget _buildImagePreview(int index) {
    if (kIsWeb &&
        _selectedFileBytes.length > index &&
        _selectedFileBytes[index].isNotEmpty) {
      // Web platform - use bytes
      return Image.memory(
        _selectedFileBytes[index],
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 48, color: Colors.grey.shade500),
                const SizedBox(height: 8),
                Text(
                  'ছবি প্রদর্শন করতে সমস্যা',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        },
      );
    } else if (_selectedFiles.length > index &&
        _selectedFiles[index].path.isNotEmpty) {
      // Mobile/Desktop - use file
      return Image.file(
        _selectedFiles[index],
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 48, color: Colors.grey.shade500),
                const SizedBox(height: 8),
                Text(
                  'ছবি প্রদর্শন করতে সমস্যা',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Fallback
      return Container(
        color: Colors.grey.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 48, color: Colors.grey.shade500),
            const SizedBox(height: 8),
            Text(
              'ছবি প্রিভিউ',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
  }

  // Build individual file preview item
  Widget _buildFilePreviewItem(int index, double height) {
    final isVideo = _selectedFileNames[index].toLowerCase().endsWith('.mp4') ||
        _selectedFileNames[index].toLowerCase().endsWith('.mov') ||
        _selectedFileNames[index].toLowerCase().endsWith('.avi');

    return SizedBox(
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: isVideo
                    ? Container(
                        color: Colors.grey.shade200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.videocam,
                                size: 32, color: Colors.grey.shade500),
                            const SizedBox(height: 4),
                            Text(
                              'ভিডিও ফাইল',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 10),
                            ),
                          ],
                        ),
                      )
                    : _buildImagePreview(index),
              ),
            ),
            // Remove button
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeFile(index),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
            // File name overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                ),
                child: Text(
                  _selectedFileNames[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if category is selected
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('দয়া করে অভিযোগের ধরন নির্বাচন করুন')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Check if user is logged in
      final isLoggedIn = await UserSession.isLoggedIn();
      if (!isLoggedIn) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('অভিযোগ জমা দিতে অনুগ্রহ করে লগইন করুন'),
            backgroundColor: Colors.orange,
          ),
        );

        // Navigate to login screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }

      // Get current user info
      final currentUser = await UserSession.getCurrentUser();
      if (currentUser == null) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('ব্যবহারকারীর তথ্য পাওয়া যায়নি। পুনরায় লগইন করুন।'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('🚀 Submitting complaint for user: ${currentUser.fullName}');

      // Map Bengali categories to English for database
      final categoryMapping = {
        'পণ্যের গুণগত মান সমস্যা': 'Low Quality Product',
        'ভুল দাম বা অতিরিক্ত চার্জ': 'Overpricing',
        'পণ্যের ওজন কম': 'Short Measurement',
        'খারাপ আচরণ': 'Unfair Behavior',
        'মেয়াদোত্তীর্ণ পণ্য': 'Low Quality Product',
        'অন্যান্য': 'Other',
      };

      final englishCategory = categoryMapping[_selectedCategory] ?? 'Other';

      // Determine product info
      String? productId;
      String? productName;

      if (_selectedProductId != null &&
          _selectedProductId != 'general' &&
          _selectedProductId != 'na') {
        productId = _selectedProductId;
        productName = _selectedProductName;
      }

      print('📦 Product Info: ID=$productId, Name=$productName');

      // Submit complaint with multiple files (one by one)
      Map<String, dynamic>? firstResult;
      List<String> uploadedFiles = [];

      // If no files selected, submit complaint without files
      if (_selectedFiles.isEmpty) {
        final result = await CustomerApi.submitComplaint(
          shopOwnerId: widget.shop.id,
          shopName: widget.shop.name,
          complaintType: englishCategory,
          description: _descriptionController.text.trim(),
          productId: productId,
          productName: productName,
          attachmentFile: null,
          attachmentBytes: null,
          attachmentName: null,
        );
        firstResult = result;
      } else {
        // Upload each file separately
        for (int i = 0; i < _selectedFiles.length; i++) {
          print(
              '📎 Uploading file ${i + 1}/${_selectedFiles.length}: ${_selectedFileNames[i]}');

          final result = await CustomerApi.submitComplaint(
            shopOwnerId: widget.shop.id,
            shopName: widget.shop.name,
            complaintType: englishCategory,
            description: i == 0
                ? _descriptionController.text.trim()
                : 'Additional file attachment',
            productId: productId,
            productName: productName,
            attachmentFile:
                _selectedFiles.length > i ? _selectedFiles[i] : null,
            attachmentBytes:
                _selectedFileBytes.length > i ? _selectedFileBytes[i] : null,
            attachmentName:
                _selectedFileNames.length > i ? _selectedFileNames[i] : null,
          );

          if (result['success'] == true) {
            uploadedFiles.add(_selectedFileNames[i]);
            if (i == 0) {
              firstResult = result; // Keep first result for main complaint
            }
            print(
                '✅ File ${i + 1} uploaded successfully: ${_selectedFileNames[i]}');
          } else {
            print('❌ Failed to upload file ${i + 1}: ${_selectedFileNames[i]}');
            // Continue with other files even if one fails
          }
        }
      }

      final result = firstResult ??
          {'success': false, 'error': 'No files uploaded successfully'};

      print('📡 API Response: $result');

      if (result['success'] == true) {
        final complaint = result['complaint'];
        final complaintNumber = complaint?['complaint_number'] ??
            'DNCRP${DateTime.now().millisecondsSinceEpoch}';

        print('✅ Complaint submitted successfully!');
        print('🆔 Complaint ID: ${complaint?['id']}');
        print('🔢 Complaint Number: $complaintNumber');
        print(
            '📎 Files uploaded: ${uploadedFiles.length}/${_selectedFiles.length}');

        if (mounted) {
          setState(() => _isSubmitting = false);

          // Success dialog with complaint number
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              icon:
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
              title:
                  const Text('✅ সফল!', style: TextStyle(color: Colors.green)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('আপনার অভিযোগ সফলভাবে জমা হয়েছে।'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text('আপনার অভিযোগ নম্বর:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        SelectableText(
                          complaintNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (uploadedFiles.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'আপলোড হয়েছে ${uploadedFiles.length}টি ফাইল:',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          const SizedBox(height: 8),
                          ...uploadedFiles
                              .map((fileName) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle,
                                            color: Colors.green, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            fileName,
                                            style:
                                                const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              ,
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Text(
                    'এই নম্বরটি সংরক্ষণ করুন। DNCRP কর্তৃপক্ষ শীঘ্রই আপনার সাথে যোগাযোগ করবে।',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to previous screen
                  },
                  child: const Text('ঠিক আছে'),
                ),
              ],
            ),
          );
        }
      } else {
        // Handle API error
        final error = result['error'] ?? 'Unknown error occurred';
        print('❌ API Error: $error');

        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ সমস্যা হয়েছে: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      print('💥 Error: $e');
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ সমস্যা হয়েছে: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DNCRP অভিযোগ জমা'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance,
                              color: Colors.blue.shade700, size: 28),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'জাতীয় ভোক্তা অধিকার সংরক্ষণ অধিদপ্তর',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'আপনার ভোক্তা অধিকার রক্ষায় আমরা প্রতিশ্রুতিবদ্ধ',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Shop Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.store, color: Colors.orange),
                          const SizedBox(width: 8),
                          const Text(
                            'দোকানের তথ্য',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildInfoRow('দোকানের নাম:', widget.shop.name),
                      _buildInfoRow('অবস্থান:', widget.shop.location),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Product Selection (Optional)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.inventory, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'পণ্য নির্বাচন (ঐচ্ছিক)',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _isLoadingProducts
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : DropdownButtonFormField<String>(
                              value: _selectedProductId,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'পণ্য নির্বাচন করুন (ঐচ্ছিক)',
                              ),
                              items: _shopProducts.map((product) {
                                return DropdownMenuItem<String>(
                                  value: product['id'] as String,
                                  child: Text(product['name'] as String),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedProductId = value;
                                  _selectedProductName =
                                      _shopProducts.firstWhere(
                                          (p) => p['id'] == value)['name'];
                                });
                              },
                            ),
                      const SizedBox(height: 8),
                      const Text(
                        'নির্দিষ্ট পণ্যের অভিযোগ থাকলে নির্বাচন করুন। সাধারণ অভিযোগের জন্য "সব পণ্য" নির্বাচন করুন।',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Complaint Category
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.category, color: Colors.purple),
                          const SizedBox(width: 8),
                          const Text(
                            'অভিযোগের ধরন *',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'অভিযোগের ধরন নির্বাচন করুন',
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'অভিযোগের ধরন নির্বাচন করুন';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Complaint Description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.description, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'অভিযোগের বিস্তারিত বিবরণ *',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText:
                              'আপনার অভিযোগের বিস্তারিত বিবরণ লিখুন...\n\n• কী ঘটেছে?\n• কখন ঘটেছে?\n• কোনো ক্ষতি হয়েছে কি?',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'অভিযোগের বিবরণ লিখুন';
                          }
                          if (value.trim().length < 10) {
                            return 'কমপক্ষে ১০ অক্ষরের বিবরণ লিখুন';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // File Upload Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.attach_file, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'ফাইল সংযুক্ত করুন (ঐচ্ছিক)',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ছবি বা ভিডিও সংযুক্ত করুন (ঐচ্ছিক)',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      if (_selectedFileNames.isEmpty) ...[
                        // File picker button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isFileUploading ? null : _pickFile,
                            icon: _isFileUploading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.photo_camera),
                            label: Text(_isFileUploading
                                ? 'আপলোড হচ্ছে...'
                                : 'ছবি বা ভিডিও নির্বাচন করুন'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.blue.shade300),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Selected files display with previews
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Files count header
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'নির্বাচিত ফাইল${_selectedFileNames.length > 1 ? 'সমূহ' : ''}: ${_selectedFileNames.length}টি',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Add more files button
                                TextButton.icon(
                                  onPressed:
                                      _isFileUploading ? null : _pickFile,
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('আরো যোগ করুন'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue.shade600,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // File previews with proper constraint handling
                            LayoutBuilder(
                              builder: (context, constraints) {
                                // Fixed height for all items
                                final itemHeight = 140.0;

                                return Column(
                                  children: [
                                    for (int i = 0;
                                        i < _selectedFileNames.length;
                                        i += 2)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            // First item
                                            Expanded(
                                              child: _buildFilePreviewItem(
                                                  i, itemHeight),
                                            ),
                                            // Second item (if exists)
                                            if (i + 1 <
                                                _selectedFileNames.length) ...[
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: _buildFilePreviewItem(
                                                    i + 1, itemHeight),
                                              ),
                                            ] else
                                              const Expanded(
                                                  child:
                                                      SizedBox()), // Empty space for last odd item
                                          ],
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'অভিযোগ জমা দিন',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Footer Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'আপনার অভিযোগ জমা দেওয়ার পর DNCRP কর্তৃপক্ষ ৭২ ঘন্টার মধ্যে প্রাথমিক তদন্ত শুরু করবে।',
                        style: TextStyle(fontSize: 11, color: Colors.amber),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey),
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

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
