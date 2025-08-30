import 'dart:convert';

import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Testing Customer Order Authentication Flow...\n');

  // Test 1: Try placing order without authentication
  print('📋 Test 1: Order without authentication');
  await testOrderWithoutAuth();

  print('\n${'=' * 50}\n');

  // Test 2: Try placing order with authentication
  print('📋 Test 2: Order with authentication');
  await testOrderWithAuth();
}

Future<void> testOrderWithoutAuth() async {
  try {
    final orderData = {
      'shop_owner_id': '12345678-1234-1234-1234-123456789012',
      'subcat_id': 1,
      'quantity_ordered': 2,
      'delivery_address': 'Test Address, Dhaka',
      'delivery_phone': '01700000000',
      'notes': 'Test order without authentication',
    };

    print('🔄 Sending order request without auth token...');
    final response = await http.post(
      Uri.parse('http://localhost:5001/customer/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(orderData),
    );

    print('📊 Response Status: ${response.statusCode}');
    print('📝 Response Body: ${response.body}');

    if (response.statusCode == 401) {
      print('✅ EXPECTED: Authentication required (Unauthorized)');
    } else {
      print('❌ UNEXPECTED: Should require authentication');
    }
  } catch (e) {
    print('❌ Connection Error: $e');
    print('💡 Make sure backend server is running on port 5001');
  }
}

Future<void> testOrderWithAuth() async {
  try {
    // First, login as a customer
    print('🔑 Step 1: Logging in as customer...');
    final loginData = {
      'email': 'test.customer@example.com',
      'password': 'password123',
    };

    final loginResponse = await http.post(
      Uri.parse('http://localhost:5001/login_customer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginData),
    );

    print('📊 Login Status: ${loginResponse.statusCode}');

    if (loginResponse.statusCode == 200) {
      final loginResult = jsonDecode(loginResponse.body);
      final token = loginResult['token'];
      print('✅ Login successful, got token: ${token?.substring(0, 20)}...');

      // Now try placing order with token
      print('\n🛒 Step 2: Placing order with authentication...');
      final orderData = {
        'shop_owner_id': '12345678-1234-1234-1234-123456789012',
        'subcat_id': 1,
        'quantity_ordered': 2,
        'delivery_address': 'Test Address, Dhaka',
        'delivery_phone': '01700000000',
        'notes': 'Test order with authentication',
      };

      final orderResponse = await http.post(
        Uri.parse('http://localhost:5001/customer/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderData),
      );

      print('📊 Order Status: ${orderResponse.statusCode}');
      print('📝 Order Response: ${orderResponse.body}');

      if (orderResponse.statusCode == 201) {
        print('✅ SUCCESS: Order created and stored in database!');
      } else {
        print('❌ FAILED: Order not created');
      }
    } else {
      print('❌ Login failed: ${loginResponse.body}');
      print('💡 You may need to create a customer account first');
    }
  } catch (e) {
    print('❌ Connection Error: $e');
    print('💡 Make sure backend server is running on port 5001');
  }
}
