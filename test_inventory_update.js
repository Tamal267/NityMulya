// Test inventory update functionality
const fetch = require('node-fetch');

const BASE_URL = 'http://localhost:5000';

async function testInventoryUpdate() {
  try {
    console.log('=== Testing Inventory Update Functionality ===\n');

    // Step 1: Login as shop owner
    console.log('1. Logging in as shop owner...');
    const loginResponse = await fetch(`${BASE_URL}/shop-owner/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'rahman.grocery@example.com',
        password: 'password123'
      })
    });

    const loginData = await loginResponse.json();
    if (!loginResponse.ok) {
      console.error('Login failed:', loginData);
      return;
    }

    console.log('   ✓ Login successful');
    const authToken = loginData.token;
    const shopOwnerId = loginData.shop_owner.id;

    // Step 2: Get current inventory
    console.log('\n2. Getting current inventory...');
    const inventoryResponse = await fetch(`${BASE_URL}/shop-owner/inventory`, {
      headers: { 'Authorization': `Bearer ${authToken}` }
    });

    const inventoryData = await inventoryResponse.json();
    if (!inventoryResponse.ok) {
      console.error('Failed to get inventory:', inventoryData);
      return;
    }

    console.log(`   ✓ Found ${inventoryData.inventory.length} inventory items:`);
    inventoryData.inventory.forEach(item => {
      console.log(`   - ${item.subcat_name}: ${item.stock_quantity} units @ ৳${item.unit_price}`);
    });

    if (inventoryData.inventory.length === 0) {
      console.log('   No inventory items found. Cannot test update.');
      return;
    }

    // Step 3: Test updating the first item
    const firstItem = inventoryData.inventory[0];
    console.log(`\n3. Testing update for: ${firstItem.subcat_name}`);
    console.log(`   Current: ${firstItem.stock_quantity} units @ ৳${firstItem.unit_price}`);

    const newQuantity = firstItem.stock_quantity + 50;
    const newPrice = parseFloat(firstItem.unit_price) + 5.00;

    console.log(`   New values: ${newQuantity} units @ ৳${newPrice.toFixed(2)}`);

    const updateResponse = await fetch(`${BASE_URL}/shop-owner/inventory`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${authToken}`
      },
      body: JSON.stringify({
        subcat_id: firstItem.subcat_id,
        stock_quantity: newQuantity,
        unit_price: newPrice
      })
    });

    const updateData = await updateResponse.json();
    if (!updateResponse.ok) {
      console.error('   ✗ Update failed:', updateData);
      return;
    }

    console.log('   ✓ Update successful:', updateData.message);

    // Step 4: Verify the update
    console.log('\n4. Verifying the update...');
    const verifyResponse = await fetch(`${BASE_URL}/shop-owner/inventory`, {
      headers: { 'Authorization': `Bearer ${authToken}` }
    });

    const verifyData = await verifyResponse.json();
    const updatedItem = verifyData.inventory.find(item => item.subcat_id === firstItem.subcat_id);

    if (updatedItem) {
      console.log(`   Updated item: ${updatedItem.subcat_name}`);
      console.log(`   Quantity: ${firstItem.stock_quantity} → ${updatedItem.stock_quantity} ${updatedItem.stock_quantity == newQuantity ? '✓' : '✗'}`);
      console.log(`   Price: ৳${firstItem.unit_price} → ৳${updatedItem.unit_price} ${parseFloat(updatedItem.unit_price) == newPrice ? '✓' : '✗'}`);
      
      if (updatedItem.stock_quantity == newQuantity && parseFloat(updatedItem.unit_price) == newPrice) {
        console.log('\n🎉 INVENTORY UPDATE TEST PASSED! 🎉');
        console.log('The shop owner inventory update functionality is working correctly.');
      } else {
        console.log('\n❌ INVENTORY UPDATE TEST FAILED!');
        console.log('Values were not updated correctly in the database.');
      }
    } else {
      console.log('   ✗ Could not find updated item');
    }

  } catch (error) {
    console.error('Error during test:', error.message);
  }
}

testInventoryUpdate();
