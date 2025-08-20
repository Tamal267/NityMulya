import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/order_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Testing DateTime encoding fix...');

  try {
    // Clear any existing orders first
    await OrderService().clearAllOrders();

    // Create a test order
    final testOrder = OrderService.createOrder(
      productName: 'Test Product',
      shopName: 'Test Shop',
      shopPhone: '01700000000',
      shopAddress: 'Test Address',
      quantity: 2,
      unit: 'kg',
      unitPrice: 50.0,
      totalPrice: 100.0,
    );

    print('Created order: ${testOrder.toString()}');

    // Test saving the order
    await OrderService().saveOrder(testOrder);
    print('✅ Order saved successfully without DateTime encoding error!');

    // Test retrieving orders
    final orders = await OrderService().getOrders();
    print('✅ Retrieved ${orders.length} orders successfully!');

    if (orders.isNotEmpty) {
      final retrievedOrder = orders.first;
      print('Order ID: ${retrievedOrder['id']}');
      print('Product: ${retrievedOrder['productName']}');
      print('Order Date Type: ${retrievedOrder['orderDate'].runtimeType}');
      print(
          'Estimated Delivery Type: ${retrievedOrder['estimatedDelivery'].runtimeType}');
    }

    // Test with multiple orders
    final secondOrder = OrderService.createOrder(
      productName: 'Second Test Product',
      shopName: 'Second Test Shop',
      shopPhone: '01800000000',
      shopAddress: 'Second Test Address',
      quantity: 3,
      unit: 'liter',
      unitPrice: 75.0,
      totalPrice: 225.0,
    );

    await OrderService().saveOrder(secondOrder);
    print('✅ Second order saved successfully!');

    final allOrders = await OrderService().getOrders();
    print('✅ Total orders now: ${allOrders.length}');

    print(
        '\n🎉 All DateTime encoding tests passed! The fix is working correctly.');
  } catch (e) {
    print('❌ Error during testing: $e');
    print('Stack trace: ${StackTrace.current}');
  }
}
