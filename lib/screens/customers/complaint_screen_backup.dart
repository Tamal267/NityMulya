import 'package:flutter/material.dart';
import '../../models/shop.dart';
import '../../services/enhanced_features_service.dart';

class ComplaintScreen extends StatefulWidget {
  final Shop shop;
  final int customerId;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;

  const ComplaintScreen({
    super.key,
    required this.shop,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
  });

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  final String _selectedComplaintType = 'পণ্যের গুণগত মান';
  final String _selectedProduct = 'সাধারণ';
  final String _selectedPriority = 'medium';
  bool _isSubmitting = false;

  final List<String> complaintTypes = [
    'পণ্যের গুণগত মান',
    'দাম সংক্রান্ত সমস্যা', 
    'ডেলিভারি সমস্যা',
    'আচরণগত সমস্যা',
    'অন্যান্য'
  ];

  final List<String> priorities = [
    'low',
    'medium', 
    'high',
    'urgent'
  ];

  final Map<String, String> priorityLabels = {
    'low': 'কম গুরুত্বপূর্ণ',
    'medium': 'মাঝারি',
    'high': 'গুরুত্বপূর্ণ',
    'urgent': 'জরুরি',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে অভিযোগের শিরোনাম লিখুন'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_complaintController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে আপনার অভিযোগ লিখুন'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await EnhancedFeaturesService.submitComplaint(
        customerId: widget.customerId,
        customerName: widget.customerName,
        customerEmail: widget.customerEmail,
        customerPhone: widget.customerPhone,
        shopId: widget.shop.id,
        shopName: widget.shop.name,
        productId: _selectedProduct != 'সাধারণ' ? _selectedProduct : null,
        productName: _selectedProduct != 'সাধারণ' ? _selectedProduct : null,
        complaintType: _selectedComplaintType,
        complaintTitle: _titleController.text.trim(),
        complaintDescription: _complaintController.text.trim(),
        priority: _selectedPriority,
      );

      if (response['success'] == true) {
        final complaintNumber = response['data']['complaint_number'];
        
        if (!mounted) return;
        
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 50,
            ),
            title: const Text(
              'অভিযোগ সফলভাবে জমা দেওয়া হয়েছে',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'আপনার অভিযোগ নম্বর: $complaintNumber',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'আমরা শীঘ্রই আপনার অভিযোগের সমাধান করব। অভিযোগ নম্বরটি সংরক্ষণ করুন।',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                child: const Text(
                  'ঠিক আছে',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'অভিযোগ জমা দিতে ব্যর্থ হয়েছে');
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ত্রুটি: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
      }
    } void finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        title: const Text('অভিযোগ করুন'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Shop Info Header
            Container(
              color: Colors.red.shade600,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.asset(
                            widget.shop.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.store,
                                size: 25,
                                color: Colors.red,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.shop.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.shop.address,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Complaint Form
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Complaint Type Selection
                  const Text(
                    'অভিযোগের ধরন',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedComplaintType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    items: complaintTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedComplaintType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Product Selection
                  const Text(
                    'সংশ্লিষ্ট পণ্য',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedProduct,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'সাধারণ',
                        child: Text('সাধারণ'),
                      ),
                      ...widget.shop.availableProducts.map((product) {
                        return DropdownMenuItem(
                          value: product,
                          child: Text(product),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedProduct = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Complaint Details
                  const Text(
                    'অভিযোগের বিস্তারিত',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _complaintController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'আপনার অভিযোগের বিস্তারিত বিবরণ লিখুন...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Warning Message
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'মিথ্যা অভিযোগ করা আইনত দণ্ডনীয় অপরাধ। সত্য তথ্য দিয়ে অভিযোগ করুন।',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitComplaint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSubmitting
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
                                SizedBox(width: 8),
                                Text('জমা দেওয়া হচ্ছে...'),
                              ],
                            )
                          : const Text(
                              'অভিযোগ জমা দিন',
                              style: TextStyle(fontSize: 16),
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
}
