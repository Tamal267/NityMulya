import 'package:nitymulya/network/network_helper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class CustomerApi {
  static final NetworkHelper _networkHelper = NetworkHelper();

  // Create a new customer order
  static Future<Map<String, dynamic>> createOrder({
    required String shopOwnerId,
    required String subcatId,
    required int quantityOrdered,
    required String deliveryAddress,
    required String deliveryPhone,
    String? notes,
  }) async {
    try {
      final data = {
        'shop_owner_id': shopOwnerId,
        'subcat_id': subcatId,
        'quantity_ordered': quantityOrdered,
        'delivery_address': deliveryAddress,
        'delivery_phone': deliveryPhone,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final response =
          await _networkHelper.postWithToken('/customer/orders', data);

      if (response['error'] != null) {
        return {
          'success': false,
          'error': response['error'],
        };
      }

      return {
        'success': response['success'] ?? true,
        'order': response['order'],
        'message': response['message'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to create order: $e',
      };
    }
  }

  // Submit a new complaint (authenticated)
  static Future<Map<String, dynamic>> submitComplaint({
    required String shopOwnerId,
    required String shopName,
    required String complaintType,
    required String description,
    required String priority,
    String? severity,
    String? productId,
    String? productName,
    File? attachmentFile,
    Uint8List? attachmentBytes,
    String? attachmentName,
  }) async {
    try {
      final data = {
        'shop_owner_id': shopOwnerId,
        'shop_name': shopName,
        'complaint_type': complaintType,
        'description': description,
        'priority': priority.toLowerCase(),
        if (severity != null) 'severity': severity.toLowerCase(),
        if (productId != null) 'product_id': productId,
        if (productName != null) 'product_name': productName,
      };

      Map<String, dynamic> response;

      if (attachmentFile != null ||
          (attachmentBytes != null && attachmentName != null)) {
        // Use multipart form for file upload
        if (kIsWeb && attachmentBytes != null && attachmentName != null) {
          // Web platform - use bytes
          response = await _networkHelper.postWithFileBytesAndToken(
              '/customer/complaints', data, attachmentBytes, attachmentName);
        } else if (attachmentFile != null) {
          // Mobile/Desktop - use file
          response = await _networkHelper.postWithFileAndToken(
              '/customer/complaints', data, attachmentFile);
        } else {
          // Fallback to regular JSON request
          response =
              await _networkHelper.postWithToken('/customer/complaints', data);
        }
      } else {
        // Regular JSON request
        response =
            await _networkHelper.postWithToken('/customer/complaints', data);
      }

      if (response['error'] != null) {
        return {
          'success': false,
          'error': response['error'],
        };
      }

      return {
        'success': response['success'] ?? true,
        'complaint': response['complaint'],
        'message': response['message'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to submit complaint: $e',
      };
    }
  }

  // Submit a new complaint (public - no auth required)
  static Future<Map<String, dynamic>> submitPublicComplaint({
    required String shopOwnerId,
    required String shopName,
    required String complaintType,
    required String description,
    required String priority,
    String? severity,
    String? productId,
    String? productName,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
  }) async {
    try {
      final data = {
        'customer_name': customerName ?? 'Anonymous Customer',
        'customer_email': customerEmail ?? 'unknown@email.com',
        'customer_phone': customerPhone ?? '',
        'shop_owner_id': shopOwnerId,
        'shop_name': shopName,
        'complaint_type': complaintType,
        'description': description,
        'priority': priority.toLowerCase(),
        if (severity != null) 'severity': severity.toLowerCase(),
        if (productId != null) 'product_id': productId,
        if (productName != null) 'product_name': productName,
      };

      final response =
          await _networkHelper.post('/api/complaints/public', data);

      if (response['error'] != null) {
        return {
          'success': false,
          'error': response['error'],
        };
      }

      return {
        'success': response['success'] ?? true,
        'complaint': response['complaint'],
        'message': response['message'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to submit complaint: $e',
      };
    }
  }

  // Get customer orders with optional status filter
  static Future<Map<String, dynamic>> getOrders({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String url = '/customer/orders?page=$page&limit=$limit';
      if (status != null && status.isNotEmpty) {
        url += '&status=$status';
      }

      final response = await _networkHelper.getWithToken(url);

      if (response['error'] != null) {
        return {
          'success': false,
          'error': response['error'],
          'orders': <Map<String, dynamic>>[],
        };
      }

      return {
        'success': response['success'] ?? true,
        'orders': List<Map<String, dynamic>>.from(response['orders'] ?? []),
        'pagination': response['pagination'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to fetch orders: $e',
        'orders': <Map<String, dynamic>>[],
      };
    }
  }

  // Get a specific customer order by ID
  static Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      final response =
          await _networkHelper.getWithToken('/customer/orders/$orderId');

      if (response['error'] != null) {
        return {
          'success': false,
          'error': response['error'],
        };
      }

      return {
        'success': response['success'] ?? true,
        'order': response['order'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to fetch order: $e',
      };
    }
  }

  // Get cancelled orders for customer
  static Future<Map<String, dynamic>> getCancelledOrders() async {
    try {
      final response =
          await _networkHelper.getWithToken('/customer/cancelled-orders');

      if (response['error'] != null) {
        return {
          'success': false,
          'error': response['error'],
          'cancelled_orders': <Map<String, dynamic>>[],
        };
      }

      return {
        'success': response['success'] ?? true,
        'cancelled_orders':
            List<Map<String, dynamic>>.from(response['cancelled_orders'] ?? []),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to fetch cancelled orders: $e',
        'cancelled_orders': <Map<String, dynamic>>[],
      };
    }
  }

  // Cancel a customer order
  static Future<Map<String, dynamic>> cancelOrder({
    required String orderId,
    String? cancellationReason,
  }) async {
    try {
      final data = {
        'order_id': orderId,
        if (cancellationReason != null && cancellationReason.isNotEmpty)
          'cancellation_reason': cancellationReason,
      };

      final response =
          await _networkHelper.postWithToken('/customer/orders/cancel', data);

      if (response['error'] != null) {
        return {
          'success': false,
          'error': response['error'],
        };
      }

      return {
        'success': response['success'] ?? true,
        'order': response['order'],
        'message': response['message'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to cancel order: $e',
      };
    }
  }

  // Helper method to check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final token = await _networkHelper.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get order statistics for customer profile
  static Future<Map<String, dynamic>> getOrderStats() async {
    try {
      final response =
          await _networkHelper.getWithToken('/customer/orders/stats');

      if (response['error'] != null) {
        return {
          'success': false,
          'error': response['error'],
          'totalOrders': 0,
          'pendingOrders': 0,
        };
      }

      return {
        'success': response['success'] ?? true,
        'totalOrders': response['totalOrders'] ?? 0,
        'pendingOrders': response['pendingOrders'] ?? 0,
        'confirmedOrders': response['confirmedOrders'] ?? 0,
        'deliveredOrders': response['deliveredOrders'] ?? 0,
        'cancelledOrders': response['cancelledOrders'] ?? 0,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to fetch order stats: $e',
        'totalOrders': 0,
        'pendingOrders': 0,
      };
    }
  }

  // Helper method to get user token
  static Future<String?> getAuthToken() async {
    try {
      return await _networkHelper.getToken();
    } catch (e) {
      return null;
    }
  }

  // Get all complaints for DNCRP admin
  static Future<Map<String, dynamic>> getAllComplaints() async {
    try {
      final response = await _networkHelper.get('/complaints/all');

      if (response['error'] != null) {
        return {
          'success': false,
          'error': response['error'],
        };
      }

      return {
        'success': true,
        'complaints': response['complaints'] ?? [],
        'message': response['message'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to get complaints: $e',
      };
    }
  }

  // Get all attachments for a specific complaint number
  static Future<Map<String, dynamic>> getComplaintAttachments(
      String complaintNumber) async {
    try {
      final response =
          await _networkHelper.get('/complaints/attachments/$complaintNumber');

      if (response['error'] != null) {
        return {
          'success': false,
          'error': response['error'],
        };
      }

      return {
        'success': true,
        'attachments': response['attachments'] ?? [],
        'message': response['message'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to get attachments: $e',
      };
    }
  }
}
