import 'dart:convert';

import 'package:http/http.dart' as http;

void main() async {
  print('🚀 Testing Fast Customer Order Process...\n');

  try {
    // Test 1: Create customer account (if needed)
    print('1️⃣ Creating test customer account...');
    final signupResponse = await http.post(
      Uri.parse('http://localhost:5001/signup_customer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': 'Fast Order Customer',
        'email': 'fastorder@test.com',
        'password': 'password123',
        'contact': '01700000001',
      }),
    );

    if (signupResponse.statusCode == 201) {
      print('✅ Customer account created successfully!');
    } else if (signupResponse.body.contains('already exists')) {
      print('ℹ️  Customer account already exists, proceeding...');
    }

    // Test 2: Login customer
    print('\n2️⃣ Logging in customer...');
    final loginResponse = await http.post(
      Uri.parse('http://localhost:5001/login_customer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': 'fastorder@test.com',
        'password': 'password123',
      }),
    );

    if (loginResponse.statusCode != 200) {
      print('❌ Login failed: ${loginResponse.body}');
      return;
    }

    final loginData = jsonDecode(loginResponse.body);
    final token = loginData['token'];
    print('✅ Login successful!');

    // Test 3: Place order quickly
    print('\n3️⃣ Placing order (should be FAST now)...');
    final startTime = DateTime.now();

    final orderResponse = await http.post(
      Uri.parse('http://localhost:5001/customer/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'shop_owner_id':
            'sample-shop-id-123', // This might need to be a real shop ID
        'subcat_id': 1,
        'quantity_ordered': 2,
        'delivery_address': 'Fast Delivery Address, Dhaka',
        'delivery_phone': '01700000001',
        'notes': 'Fast order test',
      }),
    );

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    print('📊 Order Response Status: ${orderResponse.statusCode}');
    print('📝 Order Response: ${orderResponse.body}');
    print('⏱️  Order Process Time: ${duration.inMilliseconds}ms');

    if (orderResponse.statusCode == 201) {
      print('🎉 SUCCESS: Order placed and stored in database FAST!');

      // Test 4: Verify in database
      print('\n4️⃣ Verifying order in database...');
      // This would be checked by running the database test
      print('💡 Run: cd Backend && bun test-database.ts to see the order');
    } else {
      print('❌ Order failed: ${orderResponse.body}');
      if (orderResponse.body.contains('Product not found')) {
        print('💡 Need to use a valid shop_owner_id and subcat_id');
      }
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
