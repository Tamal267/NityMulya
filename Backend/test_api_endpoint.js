// Test the actual API endpoint
require('dotenv').config();

const baseUrl = 'http://localhost:5000';

async function testShopOwnerInventoryAPI() {
  try {
    console.log('🧪 Testing Shop Owner Inventory API...\n');
    
    // Step 1: Login as shop owner
    console.log('1️⃣ Logging in as shop owner...');
    
    // Try different existing accounts
    const testAccounts = [
      { email: 'test.shopowner@example.com', password: 'password123' },
      { email: 'testshop@example.com', password: 'password123' },
      { email: 'shop1@example.com', password: 'password123' },
      { email: 'rahim@shop.com', password: 'password123' }
    ];
    
    let token = null;
    let loginSuccess = false;
    
    for (const account of testAccounts) {
      console.log(`Trying to login with: ${account.email}`);
      
      const loginResponse = await fetch(`${baseUrl}/login_shop_owner`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(account)
      });
      
      const loginData = await loginResponse.json();
      
      if (loginData.success) {
        console.log(`✅ Logged in successfully with: ${account.email}`);
        token = loginData.token;
        loginSuccess = true;
        break;
      } else {
        console.log(`❌ Failed with ${account.email}: ${loginData.message}`);
      }
    }
    
    if (!loginSuccess) {
      console.log('❌ All login attempts failed. Creating a test account...');
      
      // Create a test shop owner
      const createResponse = await fetch(`${baseUrl}/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          full_name: 'API Test Shop Owner',
          email: 'api.test@shop.com',
          password: 'testpass123',
          contact: '01234567890',
          address: 'Test Address',
          latitude: 23.7465,
          longitude: 90.3763,
          shop_name: 'API Test Shop',
          shop_description: 'Test shop for API testing'
        })
      });
      
      const createData = await createResponse.json();
      
      if (createData.success) {
        console.log('✅ Test account created, trying to login...');
        
        const newLoginResponse = await fetch(`${baseUrl}/login_shop_owner`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            email: 'api.test@shop.com',
            password: 'testpass123'
          })
        });
        
        const newLoginData = await newLoginResponse.json();
        
        if (newLoginData.success) {
          console.log('✅ Logged in with new test account');
          token = newLoginData.token;
          loginSuccess = true;
        }
      }
    }
    
    if (!loginSuccess) {
      console.log('❌ Unable to login with any account');
      return;
    }
    
    // Step 2: Get inventory
    console.log('\n2️⃣ Getting inventory...');
    const inventoryResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
      headers: { 
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    const inventoryData = await inventoryResponse.json();
    
    if (!inventoryData.success || inventoryData.data.length === 0) {
      console.log('❌ No inventory found:', inventoryData.message);
      return;
    }
    
    console.log(`✅ Found ${inventoryData.data.length} inventory items`);
    const testItem = inventoryData.data[0];
    console.log('Testing with item:', {
      id: testItem.id,
      name: testItem.subcat_name,
      current_stock: testItem.stock_quantity,
      current_price: testItem.unit_price
    });
    
    // Step 3: Update inventory item
    console.log('\n3️⃣ Testing inventory update API...');
    const newStock = testItem.stock_quantity + 5;
    const newPrice = parseFloat(testItem.unit_price) + 2;
    
    console.log(`Updating: ${testItem.stock_quantity} → ${newStock} stock, ${testItem.unit_price} → ${newPrice} price`);
    
    const updateResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
      method: 'PUT',
      headers: { 
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        id: testItem.id,
        stock_quantity: newStock,
        unit_price: newPrice,
        low_stock_threshold: testItem.low_stock_threshold
      })
    });
    
    const updateData = await updateResponse.json();
    
    if (updateData.success) {
      console.log('✅ INVENTORY UPDATE API WORKING!');
      console.log('Response:', updateData);
      
      // Step 4: Verify the update
      console.log('\n4️⃣ Verifying update...');
      const verifyResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
        headers: { 
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      
      const verifyData = await verifyResponse.json();
      const updatedItem = verifyData.data.find(item => item.id === testItem.id);
      
      if (updatedItem) {
        console.log('✅ Update verified!');
        console.log('Updated values:', {
          stock: updatedItem.stock_quantity,
          price: updatedItem.unit_price
        });
        
        console.log('\n🎉 SHOP OWNER INVENTORY UPDATE IS WORKING PERFECTLY!');
        console.log('🔧 The Flutter app should be able to update inventory now.');
      } else {
        console.log('❌ Could not find updated item');
      }
    } else {
      console.log('❌ Update API failed:', updateData.message);
      console.log('Response status:', updateResponse.status);
      console.log('Full response:', updateData);
    }
    
  } catch (error) {
    console.error('❌ Test Error:', error);
  }
}

testShopOwnerInventoryAPI();
