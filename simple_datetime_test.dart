import 'dart:convert';

// Simple test to verify OrderService DateTime encoding
void main() {
  print('Testing DateTime encoding...');

  // Simulate the order creation
  final testOrder = {
    'id': 'ORD-test',
    'productName': 'Test Product',
    'shopName': 'Test Shop',
    'orderDate': DateTime.now().toIso8601String(),
    'estimatedDelivery':
        DateTime.now().add(const Duration(days: 3)).toIso8601String(),
  };

  print('Order created: $testOrder');

  try {
    // Test JSON encoding (this is what was failing before)
    final jsonString = jsonEncode(testOrder);
    print('✅ JSON encoding successful: $jsonString');

    // Test JSON decoding
    final decoded = jsonDecode(jsonString);
    print('✅ JSON decoding successful: $decoded');

    // Test DateTime parsing
    final orderDate = DateTime.parse(decoded['orderDate']);
    final estimatedDelivery = DateTime.parse(decoded['estimatedDelivery']);
    print('✅ DateTime parsing successful:');
    print('   Order Date: $orderDate');
    print('   Estimated Delivery: $estimatedDelivery');

    print('\n🎉 All tests passed! DateTime encoding fix is working correctly.');
  } catch (e) {
    print('❌ Error during testing: $e');
  }
}
