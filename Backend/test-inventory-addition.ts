// Test script to verify quantity addition in shop inventory
const BASE_URL = 'http://localhost:5000'\;

async function testInventoryAddition() {
  try {
    // Test data
    const testData = {
      subcat_id: '1', // Assuming subcategory 1 exists
      stock_quantity: 10,
      unit_price: 300.00,
      low_stock_threshold: 5
    };

    console.log('🧪 Testing inventory addition with data:', testData);

    // You'll need to replace this with actual auth token
    const response = await fetch(`${BASE_URL}/shop-owner/inventory`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_TOKEN_HERE'
      },
      body: JSON.stringify(testData)
    });

    const result = await response.json();
    console.log('📡 Response:', result);

    // Test adding more quantity to the same product
    if (result.success) {
      console.log('\n�� Testing quantity addition (adding 5 more units)...');
      const addMoreData = {
        ...testData,
        stock_quantity: 5 // This should be ADDED to existing quantity
      };

      const response2 = await fetch(`${BASE_URL}/shop-owner/inventory`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN_HERE'
        },
        body: JSON.stringify(addMoreData)
      });

      const result2 = await response2.json();
      console.log('📡 Second Response:', result2);
    }

  } catch (error) {
    console.error('❌ Error:', error);
  }
}

console.log('Note: You need to replace YOUR_TOKEN_HERE with an actual auth token');
console.log('This script demonstrates the expected behavior of quantity addition');
