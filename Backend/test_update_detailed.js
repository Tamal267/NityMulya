// Test inventory update with detailed error logging
require('dotenv').config();

const baseUrl = 'http://localhost:5000';

async function testInventoryUpdateDetailed() {
  try {
    console.log('🔍 DETAILED INVENTORY UPDATE TEST...\n');
    
    // Login first
    console.log('1️⃣ Login...');
    const loginResponse = await fetch(`${baseUrl}/login_shop_owner`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'test.shopowner@example.com',
        password: 'password123'
      })
    });
    
    const loginData = await loginResponse.json();
    const token = loginData.token;
    console.log('✅ Login successful');
    
    // Get inventory
    console.log('\n2️⃣ Get inventory...');
    const inventoryResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
      headers: { 
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    const inventoryData = await inventoryResponse.json();
    const testItem = inventoryData.data[0];
    
    console.log('Item to update:', {
      id: testItem.id,
      name: testItem.subcat_name,
      current_stock: testItem.stock_quantity,
      current_price: testItem.unit_price,
      low_stock_threshold: testItem.low_stock_threshold
    });
    
    // Test update with exact data structure
    console.log('\n3️⃣ Testing update API...');
    
    const updatePayload = {
      id: testItem.id,
      stock_quantity: testItem.stock_quantity + 5,
      unit_price: parseFloat(testItem.unit_price) + 2,
      low_stock_threshold: testItem.low_stock_threshold || 10
    };
    
    console.log('Update payload:', JSON.stringify(updatePayload, null, 2));
    
    const updateResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
      method: 'PUT',
      headers: { 
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(updatePayload)
    });
    
    console.log('Response status:', updateResponse.status);
    console.log('Response headers:', Object.fromEntries(updateResponse.headers.entries()));
    
    const responseText = await updateResponse.text();
    console.log('Raw response:', responseText);
    
    try {
      const updateData = JSON.parse(responseText);
      console.log('Parsed response:', updateData);
    } catch (parseError) {
      console.log('Could not parse response as JSON');
    }
    
  } catch (error) {
    console.error('Test Error:', error);
  }
}

testInventoryUpdateDetailed();
