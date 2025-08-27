import 'dart:convert';

import 'package:http/http.dart' as http;

// Test API connectivity and order creation
void main() async {
  // Test basic connectivity
  print('Testing API connectivity...');

  try {
    final response = await http.get(Uri.parse('http://localhost:5000/'));
    print('Backend Status: ${response.statusCode}');
    print('Response: ${response.body}');
  } catch (e) {
    print('Backend connection failed: $e');
  }

  // Test order creation (would need a valid token in real scenario)
  print('\nTesting order creation endpoint...');

  final orderData = {
    'shop_owner_id': '1',
    'subcat_id': '1',
    'quantity_ordered': 2,
    'delivery_address': 'Test Address',
    'delivery_phone': '01700000000',
    'notes': 'Test order',
  };

  try {
    final response = await http.post(
      Uri.parse('http://localhost:5000/customer/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer test-token', // This would fail but shows structure
      },
      body: json.encode(orderData),
    );

    print('Order API Status: ${response.statusCode}');
    print('Order Response: ${response.body}');
  } catch (e) {
    print('Order API failed: $e');
  }
}
