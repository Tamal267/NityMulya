import 'dart:convert';

import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Complete Customer Order Flow Test...\n');

  // Step 1: Create a customer account
  print('📋 Step 1: Creating customer account');
  await createCustomerAccount();

  print('\n${'=' * 50}\n');

  // Step 2: Login and place order
  print('📋 Step 2: Login and place order');
  await loginAndPlaceOrder();

  print('\n${'=' * 50}\n');

  // Step 3: Check if order was stored in database
  print('📋 Step 3: Verify order in database');
  await checkOrderInDatabase();
}

Future<void> createCustomerAccount() async {
  try {
    final customerData = {
      'full_name': 'Test Customer',
      'email': 'test.customer@example.com',
      'password': 'password123',
      'contact': '01700000000',
    };

    print('🔄 Creating customer account...');
    final response = await http.post(
      Uri.parse('http://localhost:5001/signup_customer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(customerData),
    );

    print('📊 Signup Status: ${response.statusCode}');
    print('📝 Signup Response: ${response.body}');

    if (response.statusCode == 201) {
      print('✅ SUCCESS: Customer account created!');
    } else if (response.statusCode == 400 &&
        response.body.contains('already exists')) {
      print('ℹ️  INFO: Customer account already exists');
    } else {
      print('❌ FAILED: Could not create customer account');
    }
  } catch (e) {
    print('❌ Connection Error: $e');
  }
}

Future<void> loginAndPlaceOrder() async {
  try {
    // Login as customer
    print('🔑 Logging in as customer...');
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
      print('✅ Login successful!');

      // Place order with authentication
      print('\n🛒 Placing order with authentication...');
      final orderData = {
        'shop_owner_id': '12345678-1234-1234-1234-123456789012', // Sample UUID
        'subcat_id': 1,
        'quantity_ordered': 2,
        'delivery_address': 'Test Address, Dhaka, Bangladesh',
        'delivery_phone': '01700000000',
        'notes': 'Test order from authenticated customer',
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
        print('🎉 SUCCESS: Order created and stored in database!');
      } else {
        print('❌ FAILED: Order not created');
        print('💡 Possible reasons: Invalid shop_owner_id or subcategory_id');
      }
    } else {
      print('❌ Login failed: ${loginResponse.body}');
    }
  } catch (e) {
    print('❌ Connection Error: $e');
  }
}

Future<void> checkOrderInDatabase() async {
  try {
    print('🔍 Checking database for orders...');
    // This would run the database check script
    print('💡 Run: cd Backend && bun test-database.ts');
    print('💡 This will show if orders are now stored in the database');
  } catch (e) {
    print('❌ Error: $e');
  }
}
