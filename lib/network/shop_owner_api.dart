import 'package:nitymulya/network/network_helper.dart';

class ShopOwnerApiService {
  static final NetworkHelper _networkHelper = NetworkHelper();

  // Get shop owner dashboard summary
  static Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final response =
          await _networkHelper.getWithToken('/shop-owner/dashboard');

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') &&
            response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to fetch dashboard data',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching dashboard data: $e',
      };
    }
  }

  // Get shop owner inventory
  static Future<Map<String, dynamic>> getInventory() async {
    try {
      final response =
          await _networkHelper.getWithToken('/shop-owner/inventory');

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') &&
            response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to fetch inventory data',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching inventory data: $e',
      };
    }
  }

  // Add product to shop owner inventory with price range validation
  static Future<Map<String, dynamic>> addProductToInventory({
    required String subcatId,
    required int stockQuantity,
    required double unitPrice,
    int? lowStockThreshold,
  }) async {
    try {
      final requestData = {
        'subcat_id': subcatId,
        'stock_quantity': stockQuantity,
        'unit_price': unitPrice,
        'low_stock_threshold': lowStockThreshold ?? 10,
      };

      final response = await _networkHelper.postWithToken(
          '/shop-owner/inventory', requestData);

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Product added successfully',
            'data': response['data'],
          };
        } else if (response.containsKey('error') &&
            response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to add product',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error adding product: $e',
      };
    }
  }

  // Update existing inventory item
  static Future<Map<String, dynamic>> updateInventoryItem({
    required String inventoryId,
    int? stockQuantity,
    double? unitPrice,
    int? lowStockThreshold,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'id': inventoryId,
      };

      if (stockQuantity != null) requestData['stock_quantity'] = stockQuantity;
      if (unitPrice != null) requestData['unit_price'] = unitPrice;
      if (lowStockThreshold != null) {
        requestData['low_stock_threshold'] = lowStockThreshold;
      }

      final response = await _networkHelper.putWithToken(
          '/shop-owner/inventory', requestData);

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Product updated successfully',
            'data': response['data'],
          };
        } else if (response.containsKey('error') &&
            response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to update product',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating product: $e',
      };
    }
  }

  // Get low stock products
  static Future<Map<String, dynamic>> getLowStockProducts() async {
    try {
      final response =
          await _networkHelper.getWithToken('/shop-owner/low-stock');

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') &&
            response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to fetch low stock products',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching low stock products: $e',
      };
    }
  }

  // Get shop orders
  static Future<Map<String, dynamic>> getOrders() async {
    try {
      final response =
          await _networkHelper.getWithToken('/shop-owner/customer-orders');

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') &&
            response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to fetch orders',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching orders: $e',
      };
    }
  }

  // Get chat messages
  static Future<Map<String, dynamic>> getChatMessages() async {
    try {
      final response = await _networkHelper.getWithToken('/shop-owner/chat');

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') &&
            response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to fetch chat messages',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching chat messages: $e',
      };
    }
  }

  // Search wholesalers for chat
  static Future<Map<String, dynamic>> searchWholesalers(
      {String? search}) async {
    try {
      String endpoint = '/chat/wholesalers';
      if (search != null && search.isNotEmpty) {
        endpoint += '?search=${Uri.encodeComponent(search)}';
      }

      final response = await _networkHelper.getWithToken(endpoint);

      if (response is List) {
        return {
          'success': true,
          'data': response,
        };
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('error') &&
            response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to fetch wholesalers',
        };
      }

      return {
        'success': false,
        'message': 'Failed to fetch wholesalers',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching wholesalers: $e',
      };
    }
  }

  // Send chat message
  static Future<Map<String, dynamic>> sendMessage({
    required String senderId,
    required String senderType,
    required String receiverId,
    required String receiverType,
    required String message,
    String messageType = 'text',
  }) async {
    try {
      final requestData = {
        'sender_id': senderId,
        'sender_type': senderType,
        'receiver_id': receiverId,
        'receiver_type': receiverType,
        'message': message,
        'message_type': messageType,
      };

      final response =
          await _networkHelper.postWithToken('/chat/send', requestData);

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Message sent successfully',
            'data': response['data'],
          };
        } else if (response.containsKey('error') &&
            response['error'] == 'Unauthorized') {
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

  // Get chat messages between two users
  static Future<Map<String, dynamic>> getConversationMessages({
    required String user1Id,
    required String user1Type,
    required String user2Id,
    required String user2Type,
  }) async {
    try {
      final endpoint =
          '/chat/messages?user1_id=$user1Id&user1_type=$user1Type&user2_id=$user2Id&user2_type=$user2Type';

      final response = await _networkHelper.getWithToken(endpoint);

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') &&
            response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }

      return {
        'success': false,
        'message':
            response['message'] ?? 'Failed to fetch conversation messages',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching conversation messages: $e',
      };
    }
  }

  // Get chat conversations for current user
  static Future<Map<String, dynamic>> getChatConversations({
    required String userId,
    required String userType,
  }) async {
    try {
      final endpoint =
          '/chat/conversations?user_id=$userId&user_type=$userType';

      final response = await _networkHelper.getWithToken(endpoint);

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') &&
            response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to fetch conversations',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching conversations: $e',
      };
    }
  }

  // Update order status
  static Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final requestData = {
        'order_id': orderId,
        'status': status,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      };

      final response = await _networkHelper.putWithToken(
          '/shop-owner/customer-orders/status', requestData);

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'message':
                response['message'] ?? 'Order status updated successfully',
            'data': response['data'],
          };
        } else if (response.containsKey('error') &&
            response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to update order status',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating order status: $e',
      };
    }
  }

  // Get shop orders (orders from wholesalers)
  static Future<Map<String, dynamic>> getShopOrders() async {
    try {
      final response =
          await _networkHelper.getWithToken('/shop-owner/orders');

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') &&
            response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to fetch shop orders',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching shop orders: $e',
      };
    }
  }

  // Update shop order status (for orders from wholesalers)
  static Future<Map<String, dynamic>> updateShopOrderStatus({
    required String orderId,
    required String status,
    String? notes,
  }) async {
    try {
      final requestData = {
        'order_id': orderId,
        'status': status,
        if (notes != null) 'notes': notes,
      };

      final response = await _networkHelper.putWithToken(
          '/shop-owner/orders/status', requestData);

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'message':
                response['message'] ?? 'Shop order status updated successfully',
            'data': response['data'],
          };
        } else if (response.containsKey('error') &&
            response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to update shop order status',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating shop order status: $e',
      };
    }
  }

  // Confirm order (changes status from pending to on going and decreases inventory)
  static Future<Map<String, dynamic>> confirmOrder({
    required String orderId,
    String? notes,
  }) async {
    try {
      final requestData = {
        'order_id': orderId,
        'status': 'on going',
        if (notes != null) 'notes': notes,
      };

      final response = await _networkHelper.putWithToken(
          '/shop-owner/customer-orders/status', requestData);

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Order confirmed successfully',
            'data': response['data'],
          };
        } else if (response.containsKey('error') &&
            response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to confirm order',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error confirming order: $e',
      };
    }
  }
}
