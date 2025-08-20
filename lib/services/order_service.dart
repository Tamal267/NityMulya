import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  static const String _ordersKey = 'customer_orders';

  // Singleton pattern
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  // Sample order data structure
  static Map<String, dynamic> createOrder({
    required String productName,
    required String shopName,
    required String shopPhone,
    required String shopAddress,
    required int quantity,
    required String unit,
    required double unitPrice,
    required double totalPrice,
    String deliveryAddress = 'House #12, Road #5, Dhanmondi, Dhaka',
    String deliveryPhone = '01900000000',
  }) {
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    return {
      'id': orderId,
      'productName': productName,
      'shopName': shopName,
      'shopPhone': shopPhone,
      'shopAddress': shopAddress,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'orderDate': DateTime.now().toIso8601String(),
      'status': 'pending',
      'deliveryAddress': deliveryAddress,
      'deliveryPhone': deliveryPhone,
      'estimatedDelivery':
          DateTime.now().add(const Duration(days: 3)).toIso8601String(),
    };
  }

  // Save order to local storage
  Future<void> saveOrder(Map<String, dynamic> order) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing orders as raw JSON strings (without DateTime conversion)
      final existingOrdersJson = prefs.getStringList(_ordersKey) ?? [];

      // Convert DateTime objects to strings before saving
      final orderToSave = Map<String, dynamic>.from(order);
      if (orderToSave['orderDate'] is DateTime) {
        orderToSave['orderDate'] =
            (orderToSave['orderDate'] as DateTime).toIso8601String();
      }
      if (orderToSave['estimatedDelivery'] is DateTime) {
        orderToSave['estimatedDelivery'] =
            (orderToSave['estimatedDelivery'] as DateTime).toIso8601String();
      }

      // Add the new order as JSON string directly
      existingOrdersJson.add(jsonEncode(orderToSave));

      // Save all orders
      await prefs.setStringList(_ordersKey, existingOrdersJson);
    } catch (e) {
      print('Error in saveOrder: $e');
      rethrow;
    }
  }

  // Get all orders from local storage
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getStringList(_ordersKey) ?? [];

      return ordersJson.map((orderStr) {
        final orderMap = jsonDecode(orderStr) as Map<String, dynamic>;

        // Safely convert string dates back to DateTime objects for display
        if (orderMap['orderDate'] is String) {
          try {
            orderMap['orderDate'] = DateTime.parse(orderMap['orderDate']);
          } catch (e) {
            orderMap['orderDate'] = DateTime.now();
          }
        }

        if (orderMap['estimatedDelivery'] is String) {
          try {
            orderMap['estimatedDelivery'] =
                DateTime.parse(orderMap['estimatedDelivery']);
          } catch (e) {
            orderMap['estimatedDelivery'] =
                DateTime.now().add(const Duration(days: 3));
          }
        }

        return orderMap;
      }).toList();
    } catch (e) {
      print('Error in getOrders: $e');
      return [];
    }
  }

  // Update order
  Future<void> updateOrder(
      String orderId, Map<String, dynamic> updatedFields) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getStringList(_ordersKey) ?? [];

      // Find and update the order in the JSON list
      for (int i = 0; i < ordersJson.length; i++) {
        final orderMap = jsonDecode(ordersJson[i]) as Map<String, dynamic>;

        if (orderMap['id'] == orderId) {
          // Update the order
          orderMap.addAll(updatedFields);

          // Convert any DateTime objects to strings
          if (orderMap['orderDate'] is DateTime) {
            orderMap['orderDate'] =
                (orderMap['orderDate'] as DateTime).toIso8601String();
          }
          if (orderMap['estimatedDelivery'] is DateTime) {
            orderMap['estimatedDelivery'] =
                (orderMap['estimatedDelivery'] as DateTime).toIso8601String();
          }

          // Replace the order in the list
          ordersJson[i] = jsonEncode(orderMap);
          break;
        }
      }

      // Save updated orders
      await prefs.setStringList(_ordersKey, ordersJson);
    } catch (e) {
      print('Error in updateOrder: $e');
      rethrow;
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    await updateOrder(orderId, {'status': 'cancelled'});
  }

  // Update delivery details
  Future<void> updateDeliveryDetails(
      String orderId, String address, String phone) async {
    await updateOrder(orderId, {
      'deliveryAddress': address,
      'deliveryPhone': phone,
    });
  }

  // Clear all orders (for testing)
  Future<void> clearAllOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ordersKey);
  }

  // Get sample orders for demonstration
  List<Map<String, dynamic>> getSampleOrders() {
    return [
      {
        'id': 'ORD-001',
        'productName': 'চাল সরু (নাজির/মিনিকেট)',
        'shopName': 'রহমান গ্রোসারি',
        'shopPhone': '01711123456',
        'shopAddress': 'ধানমন্ডি-৩২, ঢাকা',
        'quantity': 5,
        'unit': 'কেজি',
        'unitPrice': 78.0,
        'totalPrice': 390.0,
        'orderDate': DateTime.now().subtract(const Duration(days: 2)),
        'status': 'confirmed',
        'deliveryAddress': 'House #12, Road #5, Dhanmondi, Dhaka',
        'deliveryPhone': '01900000000',
        'estimatedDelivery': DateTime.now().add(const Duration(days: 1)),
      },
      {
        'id': 'ORD-002',
        'productName': 'সয়াবিন তেল (বোতল)',
        'shopName': 'করিম স্টোর',
        'shopPhone': '01812345678',
        'shopAddress': 'গুলশান-১, ঢাকা',
        'quantity': 2,
        'unit': 'লিটার',
        'unitPrice': 188.0,
        'totalPrice': 376.0,
        'orderDate': DateTime.now().subtract(const Duration(days: 5)),
        'status': 'delivered',
        'deliveryAddress': 'House #12, Road #5, Dhanmondi, Dhaka',
        'deliveryPhone': '01900000000',
        'estimatedDelivery': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': 'ORD-003',
        'productName': 'আটা সাদা (খোলা)',
        'shopName': 'নিউ মার্কেট শপ',
        'shopPhone': '01913456789',
        'shopAddress': 'নিউমার্কেট, ঢাকা',
        'quantity': 3,
        'unit': 'কেজি',
        'unitPrice': 43.0,
        'totalPrice': 129.0,
        'orderDate': DateTime.now().subtract(const Duration(days: 7)),
        'status': 'pending',
        'deliveryAddress': 'House #12, Road #5, Dhanmondi, Dhaka',
        'deliveryPhone': '01900000000',
        'estimatedDelivery': DateTime.now().add(const Duration(days: 2)),
      },
    ];
  }
}
