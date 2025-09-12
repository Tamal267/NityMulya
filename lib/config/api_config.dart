import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String? _baseUrl;
  static bool _initialized = false;

  static String get baseUrl {
    if (_baseUrl == null) {
      throw Exception('ApiConfig not initialized. Call ApiConfig.initialize() first.');
    }
    return _baseUrl!;
  }

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    print('🚀 Starting ApiConfig initialization...');
    
    try {
      // First load the .env.local file
      await dotenv.load(fileName: ".env.local");
      print('✅ Loaded .env.local file');
      
      // Get URL from .env.local file
      final envUrl = dotenv.env['API_BASE_URL'] ?? dotenv.env['SERVER_URL'];
      print("envUrl: $envUrl");
      if (envUrl != null && envUrl.isNotEmpty) {
        _baseUrl = envUrl;
        print('✅ Using URL from .env.local: $_baseUrl');
      } else {
        _baseUrl = 'http://localhost:5000';
        print('⚠️ No URL found in .env.local, using fallback: $_baseUrl');
      }
      
      _initialized = true;
    } catch (e) {
      print('❌ Error during ApiConfig initialization: $e');
      _baseUrl = 'http://localhost:5000';
      _initialized = true;
    }
  }

  // Complaint submission endpoint
  static String complaintsSubmitEndpoint(String baseUrl) => '$baseUrl/api/complaints/submit';
  
  // Message API endpoints
  static String get sendMessageUrl => '$baseUrl/chat/send';
  static String get markAsReadUrl => '$baseUrl/chat/mark-read';
  
  // Dynamic URL methods for messages
  static String getOrderMessagesUrl(String orderId) => '$baseUrl/chat/messages/order/$orderId';
  static String getCustomerMessagesUrl(String customerId) => '$baseUrl/chat/messages/customer/$customerId';
  static String getShopMessagesUrl(String shopId) => '$baseUrl/chat/messages/shop/$shopId';
  static String getUnreadCountUrl(String userId, String userType) => '$baseUrl/chat/unread-count?user_id=$userId&user_type=$userType';
}
