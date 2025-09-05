import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class MessageApiService {
  // Send a message
  static Future<Map<String, dynamic>> sendMessage({
    required String orderId,
    required String senderType, // 'shop_owner' or 'customer'
    required String senderId,
    required String receiverType, // 'shop_owner' or 'customer'
    required String receiverId,
    required String messageText,
  }) async {
    try {
      final sendUrl = ApiConfig.sendMessageUrl;

      print('📤 Attempting to send message to: $sendUrl');
      print('📤 Web platform: $kIsWeb');

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      // Add CORS headers for web
      if (kIsWeb) {
        headers.addAll({
          'Accept': 'application/json',
        });
      }

      final response = await http.post(
        Uri.parse(sendUrl),
        headers: headers,
        body: jsonEncode({
          'order_id': orderId,
          'sender_type': senderType,
          'sender_id': senderId,
          'receiver_type': receiverType,
          'receiver_id': receiverId,
          'message_text': messageText,
        }),
      );

      print('💬 Send message response: ${response.statusCode}');
      print('💬 Send message body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Message sent successfully',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to send message',
        };
      }
    } catch (e) {
      print('❌ Error in sendMessage: $e');

      // For web, provide more specific error information
      if (kIsWeb && e.toString().contains('Failed to fetch')) {
        return {
          'success': false,
          'message':
              'Network connection failed. Please check if backend server is running on port 3005.',
        };
      }

      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get messages for a specific order
  static Future<Map<String, dynamic>> getOrderMessages({
    required String orderId,
    required String userId,
    required String userType,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getOrderMessagesUrl(orderId) +
            '?user_id=$userId&user_type=$userType'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('💬 Get order messages response: ${response.statusCode}');
      print('💬 Get order messages body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? [],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to load messages',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Error in getOrderMessages: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': [],
      };
    }
  }

  // Get all message conversations for a customer
  static Future<Map<String, dynamic>> getCustomerMessages({
    required String customerId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getCustomerMessagesUrl(customerId)),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('💬 Get customer messages response: ${response.statusCode}');
      print('💬 Get customer messages body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? [],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to load customer messages',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Error in getCustomerMessages: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': [],
      };
    }
  }

  // Get all message conversations for a shop owner
  static Future<Map<String, dynamic>> getShopMessages({
    required String shopId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getShopMessagesUrl(shopId)),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('💬 Get shop messages response: ${response.statusCode}');
      print('💬 Get shop messages body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? [],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to load shop messages',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Error in getShopMessages: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': [],
      };
    }
  }

  // Get unread message count
  static Future<Map<String, dynamic>> getUnreadCount({
    required String userId,
    required String userType,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUnreadCountUrl(userId, userType)),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('💬 Get unread count response: ${response.statusCode}');
      print('💬 Get unread count body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'unread_count': data['unread_count'] ?? 0,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to get unread count',
          'unread_count': 0,
        };
      }
    } catch (e) {
      print('❌ Error in getUnreadCount: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'unread_count': 0,
      };
    }
  }

  // Mark messages as read
  static Future<Map<String, dynamic>> markAsRead({
    required String orderId,
    required String userId,
    required String userType,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.markAsReadUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'order_id': orderId,
          'user_id': userId,
          'user_type': userType,
        }),
      );

      print('💬 Mark as read response: ${response.statusCode}');
      print('💬 Mark as read body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Messages marked as read',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to mark messages as read',
        };
      }
    } catch (e) {
      print('❌ Error in markAsRead: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}
