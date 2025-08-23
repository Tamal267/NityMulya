import 'package:nitymulya/network/network_helper.dart';

class WholesalerApiService {
  static final NetworkHelper _networkHelper = NetworkHelper();

  // Get wholesaler dashboard summary
  static Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final response = await _networkHelper.getWithToken('/wholesaler/dashboard');
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
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

  // Get wholesaler inventory
  static Future<Map<String, dynamic>> getInventory() async {
    try {
      final response = await _networkHelper.getWithToken('/wholesaler/inventory');
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to fetch inventory',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching inventory: $e',
      };
    }
  }

  // Add product to inventory
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

      final response = await _networkHelper.postWithToken('/wholesaler/inventory', requestData);
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Product added successfully',
            'data': response['data'],
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
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
        'inventory_id': inventoryId,
      };
      
      if (stockQuantity != null) {
        requestData['stock_quantity'] = stockQuantity;
      }
      if (unitPrice != null) {
        requestData['unit_price'] = unitPrice;
      }
      if (lowStockThreshold != null) {
        requestData['low_stock_threshold'] = lowStockThreshold;
      }

      final response = await _networkHelper.putWithToken('/wholesaler/inventory', requestData);
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Inventory updated successfully',
            'data': response['data'],
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to update inventory',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating inventory: $e',
      };
    }
  }

  // Get low stock products
  static Future<Map<String, dynamic>> getLowStockProducts({
    String? productFilter,
    String? locationFilter,
  }) async {
    try {
      String url = '/wholesaler/low-stock';
      List<String> params = [];
      if (productFilter != null) params.add('product=$productFilter');
      if (locationFilter != null) params.add('location=$locationFilter');
      if (params.isNotEmpty) url += '?${params.join('&')}';
      
      final response = await _networkHelper.getWithToken(url);
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
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
  static Future<Map<String, dynamic>> getShopOrders({
    String? statusFilter,
  }) async {
    try {
      String url = '/wholesaler/orders';
      if (statusFilter != null) url += '?status=$statusFilter';
      
      final response = await _networkHelper.getWithToken(url);
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
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

  // Create a new order
  static Future<Map<String, dynamic>> createOrder({
    required String shopOwnerId,
    required String subcategoryId,
    required int quantity,
    required double unitPrice,
    String? notes,
  }) async {
    try {
      final requestData = {
        'shop_owner_id': shopOwnerId,
        'subcat_id': subcategoryId,
        'quantity': quantity,
        'unit_price': unitPrice,
        'notes': notes,
      };

      final response = await _networkHelper.postWithToken('/wholesaler/orders', requestData);
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Order created successfully',
            'data': response['data'],
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to create order',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating order: $e',
      };
    }
  }

  // Update order status
  static Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final requestData = {
        'order_id': orderId,
        'status': status,
      };

      final response = await _networkHelper.putWithToken('/wholesaler/orders/status', requestData);
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Order status updated successfully',
            'data': response['data'],
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
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

  // Get wholesaler offers
  static Future<Map<String, dynamic>> getOffers() async {
    try {
      final response = await _networkHelper.getWithToken('/wholesaler/offers');
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to fetch offers',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching offers: $e',
      };
    }
  }

  // Create new offer
  static Future<Map<String, dynamic>> createOffer({
    required String title,
    String? description,
    double? discountPercentage,
    int? minimumQuantity,
    String? validUntil,
  }) async {
    try {
      final requestData = {
        'title': title,
        'description': description,
        'discount_percentage': discountPercentage,
        'minimum_quantity': minimumQuantity,
        'valid_until': validUntil,
      };

      final response = await _networkHelper.postWithToken('/wholesaler/offers', requestData);
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Offer created successfully',
            'data': response['data'],
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to create offer',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating offer: $e',
      };
    }
  }

  // Update existing offer
  static Future<Map<String, dynamic>> updateOffer({
    required String offerId,
    required String title,
    String? description,
    double? discountPercentage,
    int? minimumQuantity,
    String? validUntil,
    bool? isActive,
  }) async {
    try {
      final requestData = {
        'offer_id': offerId,
        'title': title,
        'description': description,
        'discount_percentage': discountPercentage,
        'minimum_quantity': minimumQuantity,
        'valid_until': validUntil,
        'is_active': isActive,
      };

      final response = await _networkHelper.putWithToken('/wholesaler/offers', requestData);
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Offer updated successfully',
            'data': response['data'],
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to update offer',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating offer: $e',
      };
    }
  }

  // Delete offer
  static Future<Map<String, dynamic>> deleteOffer({
    required String offerId,
  }) async {
    try {
      final response = await _networkHelper.deleteWithToken('/wholesaler/offers/$offerId');
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Offer deleted successfully',
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to delete offer',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting offer: $e',
      };
    }
  }

  // Get chat messages
  static Future<Map<String, dynamic>> getChatMessages({
    String? shopOwnerId,
  }) async {
    try {
      String url = '/wholesaler/chat';
      if (shopOwnerId != null) url += '?shop_owner_id=$shopOwnerId';
      
      final response = await _networkHelper.getWithToken(url);
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to fetch messages',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching messages: $e',
      };
    }
  }

  // Get all shop owners for selection
  static Future<Map<String, dynamic>> getShopOwners() async {
    try {
      final response = await _networkHelper.getWithToken('/wholesaler/shop-owners');
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to fetch shop owners',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching shop owners: $e',
      };
    }
  }

  // Get all categories
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await _networkHelper.getWithToken('/wholesaler/categories');
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to fetch categories',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching categories: $e',
      };
    }
  }

  // Get subcategories by category ID
  static Future<Map<String, dynamic>> getSubcategories(String categoryId) async {
    try {
      final response = await _networkHelper.getWithToken('/wholesaler/subcategories?category_id=$categoryId');
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to fetch subcategories',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching subcategories: $e',
      };
    }
  }

  // Send message to shop owner
  static Future<Map<String, dynamic>> sendMessage({
    required String senderId,
    required String senderType,
    required String receiverId,
    required String receiverType,
    required String message,
  }) async {
    try {
      final response = await _networkHelper.postWithToken('/chat/send', {
        'sender_id': senderId,
        'sender_type': senderType,
        'receiver_id': receiverId,
        'receiver_type': receiverType,
        'message': message,
      });
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
            'message': response['message'] ?? 'Message sent successfully',
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
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

  // Get conversation messages between wholesaler and shop owner
  static Future<Map<String, dynamic>> getConversationMessages({
    required String user1Id,
    required String user1Type,
    required String user2Id,
    required String user2Type,
  }) async {
    try {
      final response = await _networkHelper.getWithToken(
        '/chat/messages?user1_id=$user1Id&user1_type=$user1Type&user2_id=$user2Id&user2_type=$user2Type'
      );
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'data': response['data'],
          };
        } else if (response.containsKey('error') && response['error'] == 'Unauthorized') {
          return {
            'success': false,
            'message': 'Please login again',
            'requiresLogin': true,
          };
        }
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to fetch messages',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching messages: $e',
      };
    }
  }
}
