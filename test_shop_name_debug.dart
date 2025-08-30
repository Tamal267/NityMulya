import 'dart:io';

// Test script to debug shop name issue in customer orders

void main() async {
  print("🔍 Testing Customer Orders Shop Name Issue");
  print("=" * 50);

  // Test 1: Check if backend is running
  print("\n1. Testing Backend Connection...");
  try {
    final client = HttpClient();
    final request = await client.get('localhost', 5000, '/api/health');
    request.headers.set('content-type', 'application/json');

    final response = await request.close();
    if (response.statusCode == 200) {
      print("✅ Backend is running on localhost:5000");
    } else {
      print("❌ Backend returned status: ${response.statusCode}");
    }
    client.close();
  } catch (e) {
    print("❌ Backend connection failed: $e");
  }

  // Test 2: Test customer orders API (need authentication token)
  print("\n2. Testing Customer Orders API...");
  print("ℹ️  Note: This requires a valid authentication token");
  print("   Manual test needed: Check /api/customer/orders endpoint");

  // Test 3: Check database schema expectations
  print("\n3. Expected Database Structure:");
  print("   customer_orders table should have:");
  print("   - shop_owner_id (UUID) -> references shop_owners(id)");
  print("   ");
  print("   shop_owners table should have:");
  print("   - id (UUID, PRIMARY KEY)");
  print("   - name (VARCHAR) -> This should appear as shop_name in API");
  print("   ");
  print("   API query should JOIN:");
  print("   JOIN shop_owners so ON co.shop_owner_id = so.id");
  print("   SELECT so.name as shop_name");

  // Test 4: Sample data check
  print("\n4. Debugging Steps:");
  print("   a) Check if shop_owners table has data");
  print(
      "   b) Check if customer_orders.shop_owner_id matches existing shop_owners.id");
  print("   c) Verify JOIN query in getCustomerOrders function");
  print("   d) Check API response format");

  print("\n🔧 Next Steps:");
  print("   1. Run backend in development mode");
  print("   2. Check database directly for shop_owners data");
  print("   3. Test API endpoint with authentication");
  print("   4. Verify frontend data conversion");
}
