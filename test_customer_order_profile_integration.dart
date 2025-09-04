/*
* Customer Order-to-Profile Integration Test
* This test verifies the complete order creation and profile display flow
*/

import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print("🔍 Testing Customer Order-to-Profile Integration");
  print("=" * 60);

  await testOrderCreation();
  await testOrderProfileIntegration();

  print("\n✅ Customer Order-to-Profile Integration Test Complete");
}

// Test order creation API
Future<void> testOrderCreation() async {
  print("\n📝 Testing Order Creation API...");

  try {
    // Test data for order creation
    final orderData = {
      'shop_owner_id': 'test-shop-owner-id',
      'subcat_id': 'test-subcat-id',
      'quantity_ordered': 5,
      'delivery_address': 'House #12, Road #5, Dhanmondi, Dhaka',
      'delivery_phone': '01900000000',
      'notes': 'Please deliver fresh products'
    };

    // Simulate API call to create order
    final client = HttpClient();
    final request = await client
        .postUrl(Uri.parse('http://localhost:5001/customer/orders'));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Authorization', 'Bearer test-customer-token');
    request.write(json.encode(orderData));

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    print("📊 Order Creation Response Status: ${response.statusCode}");
    print("📋 Response Body: $responseBody");

    if (response.statusCode == 201) {
      print("✅ Order created successfully in database");

      final responseData = json.decode(responseBody);
      if (responseData['success'] == true && responseData['order'] != null) {
        print("✅ Order data structure is correct");
        print("🆔 Order ID: ${responseData['order']['id']}");
        print("📦 Product: ${responseData['order']['product_name']}");
        print("🏪 Shop: ${responseData['order']['shop_name']}");
        print("💰 Total: ৳${responseData['order']['total_amount']}");
      } else {
        print("❌ Order data structure is incorrect");
      }
    } else {
      print("❌ Order creation failed");
    }

    client.close();
  } catch (e) {
    print("❌ Order creation test failed: $e");
  }
}

// Test order retrieval and profile integration
Future<void> testOrderProfileIntegration() async {
  print("\n👤 Testing Order Profile Integration...");

  try {
    // Test fetching customer orders for profile display
    final client = HttpClient();
    final request =
        await client.getUrl(Uri.parse('http://localhost:5001/customer/orders'));
    request.headers.set('Authorization', 'Bearer test-customer-token');

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    print("📊 Get Orders Response Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      print("✅ Customer orders retrieved successfully");

      final responseData = json.decode(responseBody);
      if (responseData['success'] == true) {
        final orders = responseData['orders'] as List;
        print("✅ Found ${orders.length} orders for customer");

        if (orders.isNotEmpty) {
          print("\n📋 Sample Order Details:");
          final sampleOrder = orders.first;
          print("  🆔 ID: ${sampleOrder['id']}");
          print("  📦 Product: ${sampleOrder['product_name']}");
          print("  🏪 Shop: ${sampleOrder['shop_name']}");
          print("  📞 Shop Phone: ${sampleOrder['shop_phone']}");
          print("  🏠 Shop Address: ${sampleOrder['shop_address']}");
          print(
              "  📊 Quantity: ${sampleOrder['quantity_ordered']} ${sampleOrder['unit']}");
          print("  💰 Unit Price: ৳${sampleOrder['unit_price']}");
          print("  💵 Total: ৳${sampleOrder['total_amount']}");
          print("  📅 Order Date: ${sampleOrder['created_at']}");
          print("  📦 Status: ${sampleOrder['status']}");
          print("  🚚 Delivery Address: ${sampleOrder['delivery_address']}");
          print("  📱 Delivery Phone: ${sampleOrder['delivery_phone']}");

          // Test profile integration fields
          if (sampleOrder.containsKey('product_name') &&
              sampleOrder.containsKey('shop_name') &&
              sampleOrder.containsKey('total_amount') &&
              sampleOrder.containsKey('status')) {
            print("✅ All required fields for profile display are present");
          } else {
            print("❌ Missing required fields for profile display");
          }
        } else {
          print("ℹ️ No orders found for customer");
        }
      } else {
        print("❌ Failed to retrieve orders");
      }
    } else {
      print("❌ Orders retrieval failed");
    }

    client.close();
  } catch (e) {
    print("❌ Profile integration test failed: $e");
  }
}
