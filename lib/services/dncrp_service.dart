import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:nitymulya/models/complaint.dart';
import 'package:flutter/foundation.dart';

class DNCRPService {
  // Use 10.0.2.2 for Android emulator, localhost for web/desktop
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3005';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3005';
    } else {
      return 'http://localhost:3005';
    }
  }

  // Authentication
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Login for DNCRP admin
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': 'dncrp_admin',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _authToken = data['data']['token'];
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get all complaints for DNCRP dashboard
  Future<List<Complaint>> getAllComplaints() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dncrp/complaints'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((json) => Complaint.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch complaints');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get complaint statistics
  Future<Map<String, int>> getComplaintStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dncrp/complaints/stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Map<String, int>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch stats');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update complaint status
  Future<void> updateComplaintStatus(String complaintId, String newStatus,
      {String? comment}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/dncrp/complaints/$complaintId/status'),
        headers: _headers,
        body: jsonEncode({
          'status': newStatus,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to update status');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get complaint details with history
  Future<Map<String, dynamic>> getComplaintDetails(String complaintId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dncrp/complaints/$complaintId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(
              data['message'] ?? 'Failed to fetch complaint details');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Submit complaint (for customers)
  static Future<Map<String, dynamic>> submitComplaint({
    required String customerId,
    required String customerName,
    required String customerEmail,
    String? customerPhone,
    required String shopId,
    required String shopName,
    int? productId,
    String? productName,
    required String category,
    required String priority,
    required String severity,
    required String description,
    List<File>? proofFiles,
  }) async {
    try {
      print(
          '🌐 Attempting to submit complaint to: $baseUrl/api/complaints/submit');
      print(
          '📊 Connection details: Platform: ${Platform.operatingSystem}, BaseURL: $baseUrl');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/complaints/submit'),
      );

      // Add headers
      request.headers.addAll(_headers);

      // Add form data
      request.fields['customer_id'] = customerId;
      request.fields['customer_name'] = customerName;
      request.fields['customer_email'] = customerEmail;
      if (customerPhone != null) {
        request.fields['customer_phone'] = customerPhone;
      }
      request.fields['shop_id'] = shopId;
      request.fields['shop_name'] = shopName;
      if (productId != null) {
        request.fields['product_id'] = productId.toString();
      }
      if (productName != null) request.fields['product_name'] = productName;
      request.fields['category'] = category;
      request.fields['priority'] = priority;
      request.fields['severity'] = severity;
      request.fields['description'] = description;

      print('📝 Form data prepared with ${request.fields.length} fields');

      // Add files
      if (proofFiles != null && proofFiles.isNotEmpty) {
        print('📁 Adding ${proofFiles.length} proof files...');
        for (int i = 0; i < proofFiles.length; i++) {
          final file = proofFiles[i];
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();
          final multipartFile = http.MultipartFile(
            'proof_files',
            stream,
            length,
            filename: file.path.split('/').last,
          );
          request.files.add(multipartFile);
          print(
              '📄 File added: ${file.path.split('/').last}, Size: $length bytes');
        }
      }

      print('🚀 Sending request...');
      final streamedResponse = await request.send().timeout(
        const Duration(
            seconds: 60), // Increased timeout temporarily for debugging
        onTimeout: () {
          throw Exception(
              'Request timed out after 60 seconds. Please check your internet connection.');
        },
      );

      print('📡 Response received with status: ${streamedResponse.statusCode}');
      final response = await http.Response.fromStream(streamedResponse);

      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ Complaint submitted successfully!');
          return data;
        } else {
          throw Exception(data['message'] ?? 'Server returned success=false');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ??
            'HTTP ${response.statusCode}: Failed to submit complaint');
      }
    } on TimeoutException catch (e) {
      print('⏰ Timeout error: $e');
      throw Exception(
          'সংযোগ টাইমআউট: অনুরোধটি ৩০ সেকেন্ডের মধ্যে সম্পন্ন হয়নি।');
    } on SocketException catch (e) {
      print('🌐 Network error: $e');
      throw Exception(
          'নেটওয়ার্ক সমস্যা: ইন্টারনেট সংযোগ চেক করুন। Backend server চালু আছে কিনা নিশ্চিত করুন।');
    } catch (e) {
      print('💥 Unexpected error: $e');
      throw Exception('সিস্টেম ত্রুটি: $e');
    }
  }

  // Download complaints as PDF
  Future<void> downloadComplaintsAsPDF(List<Complaint> complaints) async {
    try {
      final complaintIds = complaints.map((c) => c.id.toString()).toList();

      final response = await http.post(
        Uri.parse('$baseUrl/api/dncrp/complaints/download-pdf'),
        headers: _headers,
        body: jsonEncode({
          'complaint_ids': complaintIds,
        }),
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        if (kIsWeb) {
          // For web platform
          throw UnimplementedError('PDF download not implemented for web');
        } else {
          // For mobile platforms - simplified for now
          if (kDebugMode) {
            print('PDF download would save ${bytes.length} bytes');
          }
        }
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('PDF download error: $e');
    }
  }

  // Get notifications for DNCRP admin
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dncrp/notifications'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch notifications');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/dncrp/notifications/$notificationId/read'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(
              data['message'] ?? 'Failed to mark notification as read');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get shop details
  Future<Map<String, dynamic>> getShopDetails(int shopId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/shops/$shopId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch shop details');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get customer details
  Future<Map<String, dynamic>> getCustomerDetails(int customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/customers/$customerId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(
              data['message'] ?? 'Failed to fetch customer details');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
