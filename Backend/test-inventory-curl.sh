#!/bin/bash

echo "🧪 Testing Inventory API with cURL..."
echo

BASE_URL="http://localhost:5000"

# Test 1: Health check
echo "📝 Step 1: Health check..."
curl -s "$BASE_URL/get_categories" | head -c 200
echo
echo "✅ API connectivity tested"
echo

# Test 2: Test inventory endpoint without auth (should fail)
echo "📝 Step 2: Testing inventory endpoint without auth..."
response=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/shop-owner/inventory" \
  -H "Content-Type: application/json" \
  -d '{"subcat_id":"1","stock_quantity":10,"unit_price":280.00}')

echo "Response: $response"
echo

# Test 3: Try dummy login
echo "📝 Step 3: Testing with dummy login..."
login_response=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/login/shop-owner" \
  -H "Content-Type: application/json" \
  -d '{"email":"dummy@test.com","password":"dummy123"}')

echo "Login response: $login_response"
echo

echo "🎉 Basic API test completed!"
echo
echo "💡 To test with real credentials, use:"
echo "curl -X POST $BASE_URL/login/shop-owner -H 'Content-Type: application/json' -d '{\"email\":\"real@email.com\",\"password\":\"realpassword\"}'"

