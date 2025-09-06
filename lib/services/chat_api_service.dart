import 'package:nitymulya/network/network_helper.dart';

class ChatApiService {
  static final NetworkHelper _networkHelper = NetworkHelper();

  // Send a chat message
  static Future<Map<String, dynamic>> sendMessage({
    required String receiverId,
    required String receiverType, // 'wholesaler' or 'shop_owner'
    required String messageText,
  }) async {
    try {
      final requestData = {
        'receiver_id': receiverId,
        'receiver_type': receiverType,
        'message_text': messageText,
      };

      final response =
          await _networkHelper.postWithToken('/chat/send', requestData);

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'message': response['message'],
          };
        } else if (response.containsKey('message') &&
            response['message'].toString().contains('Unauthorized')) {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to send message',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending message: $e',
      };
    }
  }

  // Get chat messages between current user and a contact
  static Future<Map<String, dynamic>> getMessages({
    required String contactId,
    required String contactType, // 'wholesaler' or 'shop_owner'
  }) async {
    try {
      final response = await _networkHelper.getWithToken(
          '/chat/messages?contact_id=$contactId&contact_type=$contactType');

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'messages': response['messages'] ?? [],
          };
        } else if (response.containsKey('message') &&
            response['message'].toString().contains('Unauthorized')) {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to get messages',
        'messages': [],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting messages: $e',
        'messages': [],
      };
    }
  }

  // Get all chat conversations for current user
  static Future<Map<String, dynamic>> getConversations() async {
    try {
      final response = await _networkHelper.getWithToken('/chat/conversations');

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'conversations': response['conversations'] ?? [],
          };
        } else if (response.containsKey('message') &&
            response['message'].toString().contains('Unauthorized')) {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to get conversations',
        'conversations': [],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting conversations: $e',
        'conversations': [],
      };
    }
  }

  // Mark messages as read
  static Future<Map<String, dynamic>> markMessagesAsRead({
    required String senderId,
    required String senderType, // 'wholesaler' or 'shop_owner'
  }) async {
    try {
      final requestData = {
        'sender_id': senderId,
        'sender_type': senderType,
      };

      final response =
          await _networkHelper.postWithToken('/chat/mark-read', requestData);

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'marked_count': response['marked_count'] ?? 0,
          };
        } else if (response.containsKey('message') &&
            response['message'].toString().contains('Unauthorized')) {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to mark messages as read',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error marking messages as read: $e',
      };
    }
  }
}
