import 'package:nitymulya/network/customer_api.dart';

void main() async {
  print('🔍 Testing API Authentication and Order Creation...\n');

  // Test 1: Check if user is authenticated
  print('1. Checking authentication status...');
  final isAuth = await CustomerApi.isAuthenticated();
  print('   Authenticated: $isAuth');

  if (!isAuth) {
    print(
        '   ❌ User not authenticated - this explains why orders aren\'t reaching database!');
    print('   💡 User needs to login first');
    return;
  }

  // Test 2: Get auth token
  print('\n2. Getting auth token...');
  final token = await CustomerApi.getAuthToken();
  print('   Token exists: ${token != null}');
  print('   Token preview: ${token?.substring(0, 20)}...');

  // Test 3: Test API connectivity
  print('\n3. Testing API endpoint...');
  try {
    final result = await CustomerApi.getOrders();
    print('   API Response: ${result['success']}');
    print('   Orders count: ${(result['orders'] as List).length}');

    if (result['success'] == true) {
      print('   ✅ API is working - authentication successful');
    } else {
      print('   ❌ API failed: ${result['error']}');
    }
  } catch (e) {
    print('   ❌ API connection failed: $e');
  }

  // Test 4: Test order creation
  print('\n4. Testing order creation...');
  try {
    final orderResult = await CustomerApi.createOrder(
      shopOwnerId: 'test-shop-id',
      subcatId: 'test-subcat-id',
      quantityOrdered: 1,
      deliveryAddress: 'Test Address',
      deliveryPhone: '01700000000',
      notes: 'Test order from debug script',
    );

    print('   Order creation success: ${orderResult['success']}');
    if (orderResult['success'] != true) {
      print('   Error: ${orderResult['error']}');
    } else {
      print('   ✅ Order created successfully!');
    }
  } catch (e) {
    print('   ❌ Order creation failed: $e');
  }
}
