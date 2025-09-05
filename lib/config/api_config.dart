import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Get the base API URL from environment variables
  static String get baseUrl {
    final serverUrl = dotenv.env['API_BASE_URL'] ?? dotenv.env['SERVER_URL'];
    if (serverUrl == null || serverUrl.isEmpty) {
      throw Exception(
          'API_BASE_URL or SERVER_URL not found in environment variables');
    }
    return serverUrl.endsWith('/')
        ? serverUrl.substring(0, serverUrl.length - 1)
        : serverUrl;
  }

  /// Get the messages API base URL
  static String get messagesApiUrl => '$baseUrl/api/messages';

  /// Get the full URL for sending messages
  static String get sendMessageUrl => '$messagesApiUrl/send';

  /// Get the full URL for getting customer messages
  static String getCustomerMessagesUrl(String customerId) =>
      '$messagesApiUrl/customer/$customerId';

  /// Get the full URL for getting order messages
  static String getOrderMessagesUrl(String orderId) =>
      '$messagesApiUrl/order/$orderId';

  /// Get the full URL for getting shop messages
  static String getShopMessagesUrl(String shopId) =>
      '$messagesApiUrl/shop/$shopId';

  /// Get the full URL for marking messages as read
  static String get markAsReadUrl => '$messagesApiUrl/mark-read';

  /// Get the full URL for getting unread count
  static String getUnreadCountUrl(String userId, String userType) =>
      '$messagesApiUrl/unread-count/$userId/$userType';

  /// Check if the configuration is properly loaded
  static bool get isConfigured {
    try {
      baseUrl; // This will throw if not configured
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Print current configuration for debugging
  static void printConfig() {
    try {
      print('🔧 API Configuration:');
      print('   Base URL: $baseUrl');
      print('   Messages API URL: $messagesApiUrl');
      print('   Send Message URL: $sendMessageUrl');
      print('   Configuration Status: ✅ Loaded');
    } catch (e) {
      print('❌ API Configuration Error: $e');
    }
  }
}
