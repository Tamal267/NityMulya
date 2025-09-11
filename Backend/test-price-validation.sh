#!/bin/bash

echo "🧪 Testing Price Validation and Inventory Addition"
echo "=================================================="

BASE_URL="http://localhost:5000"

# Step 1: Login as shop owner
echo "📡 Step 1: Login as shop owner..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/login_shop_owner" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "shop@example.com", 
    "password": "123456"
  }')

echo "Login Response: $LOGIN_RESPONSE"

# Extract token
TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
if [ -z "$TOKEN" ]; then
  echo "❌ Failed to get token. Trying alternative email..."
  
  # Try alternative login
  LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/login_shop_owner" \
    -H "Content-Type: application/json" \
    -d '{
      "email": "test@shop.com", 
      "password": "password123"
    }')
  
  echo "Alternative Login Response: $LOGIN_RESPONSE"
  TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
fi

if [ -z "$TOKEN" ]; then
  echo "❌ Authentication failed! Cannot proceed with tests."
  exit 1
fi

echo "✅ Authentication successful. Token: ${TOKEN:0:20}..."
echo ""

# Step 2: Get current inventory to see existing products
echo "📡 Step 2: Get current inventory..."
INVENTORY_RESPONSE=$(curl -s -X GET "$BASE_URL/shop-owner/inventory" \
  -H "Authorization: Bearer $TOKEN")

echo "Current Inventory: $INVENTORY_RESPONSE"
echo ""

# Step 3: Test price validation with different scenarios
echo "📡 Step 3: Testing Price Validation Scenarios..."
echo ""

# Test 3a: Very low price (should fail government minimum)
echo "🧪 Test 3a: Adding product with very low price (৳1) - should fail..."
LOW_PRICE_RESPONSE=$(curl -s -X POST "$BASE_URL/shop-owner/inventory" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "subcat_id": "1",
    "stock_quantity": 10,
    "unit_price": 1.0,
    "low_stock_threshold": 5
  }')

echo "Low Price Response: $LOW_PRICE_RESPONSE"
echo ""

# Test 3b: Very high price (should fail government maximum)
echo "🧪 Test 3b: Adding product with very high price (৳10000) - should fail..."
HIGH_PRICE_RESPONSE=$(curl -s -X POST "$BASE_URL/shop-owner/inventory" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "subcat_id": "1",
    "stock_quantity": 10,
    "unit_price": 10000.0,
    "low_stock_threshold": 5
  }')

echo "High Price Response: $HIGH_PRICE_RESPONSE"
echo ""

# Test 3c: Reasonable price (should succeed)
echo "🧪 Test 3c: Adding product with reasonable price (৳75) - should succeed..."
VALID_PRICE_RESPONSE=$(curl -s -X POST "$BASE_URL/shop-owner/inventory" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "subcat_id": "1",
    "stock_quantity": 15,
    "unit_price": 75.0,
    "low_stock_threshold": 5
  }')

echo "Valid Price Response: $VALID_PRICE_RESPONSE"
echo ""

# Test 4: Test quantity addition (UPSERT behavior)
echo "📡 Step 4: Testing Quantity Addition (UPSERT)..."
echo ""

# Add same product again to test quantity addition
echo "🧪 Test 4a: Adding same product again to test quantity addition..."
UPSERT_RESPONSE=$(curl -s -X POST "$BASE_URL/shop-owner/inventory" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "subcat_id": "1",
    "stock_quantity": 20,
    "unit_price": 80.0,
    "low_stock_threshold": 5
  }')

echo "UPSERT Response: $UPSERT_RESPONSE"
echo ""

# Test 5: Check final inventory state
echo "📡 Step 5: Check final inventory state..."
FINAL_INVENTORY=$(curl -s -X GET "$BASE_URL/shop-owner/inventory" \
  -H "Authorization: Bearer $TOKEN")

echo "Final Inventory: $FINAL_INVENTORY"
echo ""

# Test 6: Test with different subcategory IDs to check price validation
echo "📡 Step 6: Testing different subcategory price validation..."
echo ""

for subcat_id in "2" "3" "4" "5"; do
  echo "🧪 Testing subcategory ID: $subcat_id with price ৳60..."
  SUBCAT_RESPONSE=$(curl -s -X POST "$BASE_URL/shop-owner/inventory" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
      \"subcat_id\": \"$subcat_id\",
      \"stock_quantity\": 10,
      \"unit_price\": 60.0,
      \"low_stock_threshold\": 5
    }")
  
  echo "Subcategory $subcat_id Response: $SUBCAT_RESPONSE"
  echo ""
done

echo "🏁 Price Validation and Inventory Tests Completed!"
echo "=================================================="
