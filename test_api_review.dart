import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print('Testing Review API...');
  
  // Test 1: Basic server response
  try {
    print('\n1. Testing basic server connection...');
    final response1 = await http.get(Uri.parse('http://localhost:5002/'));
    print('Status: ${response1.statusCode}');
    print('Response: ${response1.body}');
  } catch (e) {
    print('Error connecting to server: $e');
  }
  
  // Test 2: Get all reviews
  try {
    print('\n2. Testing get all reviews...');
    final response2 = await http.get(Uri.parse('http://localhost:5002/reviews/all'));
    print('Status: ${response2.statusCode}');
    print('Response: ${response2.body}');
  } catch (e) {
    print('Error getting reviews: $e');
  }
  
  // Test 3: Create product review
  try {
    print('\n3. Testing create product review...');
    final testReview = {
      'customer_id': 'test_customer',
      'customer_name': 'Test User',
      'customer_email': 'test@example.com',
      'subcat_id': 'test_product',
      'product_name': 'Test Product',
      'shop_owner_id': 'test_shop',
      'shop_name': 'Test Shop',
      'rating': 5,
      'comment': 'Great product!',
    };
    
    final response3 = await http.post(
      Uri.parse('http://localhost:5002/reviews/product/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(testReview),
    );
    print('Status: ${response3.statusCode}');
    print('Response: ${response3.body}');
  } catch (e) {
    print('Error creating review: $e');
  }
  
  print('\nAPI test completed!');
}
