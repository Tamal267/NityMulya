import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Testing Review API...');
  
  try {
    // Test basic server connection
    print('\n1️⃣ Testing basic server connection...');
    final response1 = await http.get(Uri.parse('http://localhost:5002/'))
        .timeout(Duration(seconds: 5));
    print('✅ Server Status: ${response1.statusCode}');
    print('📝 Response: ${response1.body}');
    
    // Test get all reviews
    print('\n2️⃣ Testing get all reviews...');
    final response2 = await http.get(Uri.parse('http://localhost:5002/reviews/all'))
        .timeout(Duration(seconds: 5));
    print('✅ Reviews Status: ${response2.statusCode}');
    print('📝 Response: ${response2.body}');
    
    // Test create product review
    print('\n3️⃣ Testing create product review...');
    final testReview = {
      'customer_id': 'test_customer_123',
      'customer_name': 'Test User',
      'customer_email': 'test@example.com',
      'subcat_id': 'test_product_123',
      'product_name': 'Rice Premium 25kg',
      'shop_owner_id': 'test_shop_123',
      'shop_name': 'Fresh Mart',
      'rating': 5,
      'comment': 'Excellent product! Great quality rice.',
      'is_verified_purchase': false,
    };
    
    final response3 = await http.post(
      Uri.parse('http://localhost:5002/reviews/product/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(testReview),
    ).timeout(Duration(seconds: 10));
    
    print('✅ Create Review Status: ${response3.statusCode}');
    print('📝 Response: ${response3.body}');
    
    if (response3.statusCode == 200) {
      // Test getting reviews after creating one
      print('\n4️⃣ Testing get reviews after creation...');
      final response4 = await http.get(Uri.parse('http://localhost:5002/reviews/all'))
          .timeout(Duration(seconds: 5));
      print('✅ Updated Reviews Status: ${response4.statusCode}');
      print('📝 Response: ${response4.body}');
    }
    
  } catch (e) {
    print('❌ Error: $e');
  }
  
  print('\n🎉 API test completed!');
}
