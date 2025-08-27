import 'package:nitymulya/network/network_helper.dart';

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

  // Helper method to get user token
  static Future<String?> getAuthToken() async {
    try {
      return await _networkHelper.getToken();
    } catch (e) {
      return null;
    }
  }
}
