import 'package:nitymulya/network/network_helper.dart';

class ShopOwnerApiService {
  static final NetworkHelper _networkHelper = NetworkHelper();

  // Get shop owner dashboard summary
  static Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final response = await _networkHelper.getWithToken('/shop-owner/dashboard');
      
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

  // Get shop owner inventory
  static Future<Map<String, dynamic>> getInventory() async {
    try {
      final response = await _networkHelper.getWithToken('/shop-owner/inventory');
      
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

      final response = await _networkHelper.postWithToken('/shop-owner/inventory', requestData);
      
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
        'id': inventoryId,
      };

      if (stockQuantity != null) requestData['stock_quantity'] = stockQuantity;
      if (unitPrice != null) requestData['unit_price'] = unitPrice;
      if (lowStockThreshold != null) requestData['low_stock_threshold'] = lowStockThreshold;

      final response = await _networkHelper.putWithToken('/shop-owner/inventory', requestData);
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Product updated successfully',
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
      final response = await _networkHelper.getWithToken('/shop-owner/low-stock');
      
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
  static Future<Map<String, dynamic>> getOrders() async {
    try {
      final response = await _networkHelper.getWithToken('/shop-owner/orders');
      
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
        'message': response['message'] ?? 'Failed to fetch chat messages',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching chat messages: $e',
      };
    }
  }
}
