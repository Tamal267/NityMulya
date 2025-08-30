// Comprehensive test to diagnose inventory update issues
const baseUrl = 'http://localhost:5000';

async function diagnoseInventoryUpdate() {
  console.log('🔍 COMPREHENSIVE INVENTORY UPDATE DIAGNOSIS...\n');
  
  try {
    // Step 1: Test shop owner authentication
    console.log('1️⃣ Testing Shop Owner Authentication...');
    
    const loginResponse = await fetch(`${baseUrl}/login_shop_owner`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'testshop2@example.com',
        password: 'password123'
      })
    });
    
    if (!loginResponse.ok) {
      console.log('❌ Login failed:', loginResponse.status, await loginResponse.text());
      return;
    }
    
    const loginData = await loginResponse.json();
    const token = loginData.token;
    const shopOwnerId = loginData.shop_owner.id;
    
    console.log(`✅ Authentication successful: ${loginData.shop_owner.full_name}`);
    console.log(`   Shop Owner ID: ${shopOwnerId}`);
    console.log(`   Token: ${token.substring(0, 20)}...`);
    
    // Step 2: Test inventory retrieval
    console.log('\n2️⃣ Testing Inventory Retrieval...');
    
    const inventoryResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    });
    
    if (!inventoryResponse.ok) {
      console.log('❌ Inventory retrieval failed:', inventoryResponse.status, await inventoryResponse.text());
      return;
    }
    
    const inventoryData = await inventoryResponse.json();
    console.log(`✅ Inventory retrieved: ${inventoryData.data.length} items`);
    
    if (inventoryData.data.length === 0) {
      console.log('📋 No inventory items found. Adding a test product first...');
      
      // Step 3: Add a test product first
      console.log('\n3️⃣ Adding Test Product...');
      
      // First, get available subcategories
      const subcatResponse = await fetch(`${baseUrl}/wholesaler/subcategories?category_id=1`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      
      let subcatId = 1; // Default fallback
      
      if (subcatResponse.ok) {
        const subcatData = await subcatResponse.json();
        if (subcatData.length > 0) {
          subcatId = subcatData[0].id;
          console.log(`   Using subcategory: ${subcatData[0].subcat_name} (ID: ${subcatId})`);
        }
      } else {
        console.log('   Using default subcategory ID: 1');
      }
      
      const addProductResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          subcat_id: subcatId,
          stock_quantity: 100,
          unit_price: 80.0,
          low_stock_threshold: 10
        })
      });
      
      if (addProductResponse.ok) {
        const addData = await addProductResponse.json();
        console.log('✅ Test product added successfully');
        
        // Refresh inventory
        const refreshResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          }
        });
        
        if (refreshResponse.ok) {
          const refreshData = await refreshResponse.json();
          inventoryData.data = refreshData.data;
          console.log(`✅ Inventory refreshed: ${refreshData.data.length} items`);
        }
      } else {
        const errorText = await addProductResponse.text();
        console.log('❌ Failed to add test product:', errorText);
        console.log('📋 Will test with existing shop owners that have inventory...');
        return;
      }
    }
    
    if (inventoryData.data.length > 0) {
      const testItem = inventoryData.data[0];
      console.log(`\n📦 Test Item Details:`);
      console.log(`   ID: ${testItem.id}`);
      console.log(`   Name: ${testItem.subcat_name || 'Unknown Product'}`);
      console.log(`   Current Quantity: ${testItem.stock_quantity}`);
      console.log(`   Current Price: ৳${testItem.unit_price}`);
      console.log(`   Low Stock Threshold: ${testItem.low_stock_threshold}`);
      
      // Step 4: Test inventory update API
      console.log('\n4️⃣ Testing Inventory Update API...');
      
      const originalQuantity = testItem.stock_quantity;
      const originalPrice = parseFloat(testItem.unit_price);
      const newQuantity = originalQuantity + 25;
      const newPrice = originalPrice + 10;
      
      console.log(`   Updating: ${originalQuantity} → ${newQuantity} units`);
      console.log(`   Updating: ৳${originalPrice} → ৳${newPrice}`);
      
      const updatePayload = {
        id: testItem.id,
        stock_quantity: newQuantity,
        unit_price: newPrice,
        low_stock_threshold: testItem.low_stock_threshold
      };
      
      console.log(`   Update Payload:`, JSON.stringify(updatePayload, null, 2));
      
      const updateResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(updatePayload)
      });
      
      console.log(`   Update Response Status: ${updateResponse.status}`);
      
      if (updateResponse.ok) {
        const updateData = await updateResponse.json();
        console.log('✅ Update API Response:', JSON.stringify(updateData, null, 2));
        
        // Step 5: Verify the update in database
        console.log('\n5️⃣ Verifying Database Update...');
        
        const verifyResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          }
        });
        
        if (verifyResponse.ok) {
          const verifyData = await verifyResponse.json();
          const updatedItem = verifyData.data.find(item => item.id === testItem.id);
          
          if (updatedItem) {
            console.log('📊 DATABASE VERIFICATION:');
            console.log(`   Original Quantity: ${originalQuantity}`);
            console.log(`   Updated Quantity: ${updatedItem.stock_quantity}`);
            console.log(`   Expected Quantity: ${newQuantity}`);
            console.log(`   Quantity Match: ${updatedItem.stock_quantity == newQuantity ? '✅ YES' : '❌ NO'}`);
            
            console.log(`   Original Price: ৳${originalPrice}`);
            console.log(`   Updated Price: ৳${updatedItem.unit_price}`);
            console.log(`   Expected Price: ৳${newPrice}`);
            console.log(`   Price Match: ${parseFloat(updatedItem.unit_price) == newPrice ? '✅ YES' : '❌ NO'}`);
            
            const quantityCorrect = updatedItem.stock_quantity == newQuantity;
            const priceCorrect = parseFloat(updatedItem.unit_price) == newPrice;
            
            if (quantityCorrect && priceCorrect) {
              console.log('\n🎉 SUCCESS: DATABASE UPDATE WORKING CORRECTLY!');
              console.log('✅ API endpoint functional');
              console.log('✅ Database updates working');
              console.log('✅ Data persistence verified');
              
              // Test low stock detection
              const isLowStock = updatedItem.stock_quantity < (updatedItem.low_stock_threshold || 10);
              console.log(`✅ Low stock detection: ${isLowStock ? 'LOW STOCK' : 'ADEQUATE STOCK'}`);
              
            } else {
              console.log('\n❌ FAILURE: DATABASE UPDATE NOT WORKING');
              if (!quantityCorrect) console.log('❌ Quantity not updated in database');
              if (!priceCorrect) console.log('❌ Price not updated in database');
            }
          } else {
            console.log('❌ Could not find updated item in inventory');
          }
        } else {
          console.log('❌ Failed to verify update:', verifyResponse.status, await verifyResponse.text());
        }
        
      } else {
        const errorText = await updateResponse.text();
        console.log('❌ UPDATE API FAILED:', errorText);
        
        try {
          const errorData = JSON.parse(errorText);
          console.log('📋 Error Details:', JSON.stringify(errorData, null, 2));
        } catch (e) {
          console.log('📋 Raw Error:', errorText);
        }
      }
    }
    
    // Step 6: Test API endpoint structure
    console.log('\n6️⃣ Testing API Endpoint Structure...');
    
    const endpointsToTest = [
      { method: 'GET', path: '/shop-owner/inventory', description: 'Get Inventory' },
      { method: 'PUT', path: '/shop-owner/inventory', description: 'Update Inventory' },
      { method: 'POST', path: '/shop-owner/inventory', description: 'Add Product' }
    ];
    
    for (const endpoint of endpointsToTest) {
      const testResponse = await fetch(`${baseUrl}${endpoint.path}`, {
        method: endpoint.method,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: endpoint.method !== 'GET' ? JSON.stringify({}) : undefined
      });
      
      console.log(`   ${endpoint.method} ${endpoint.path}: ${testResponse.status} (${endpoint.description})`);
    }
    
    console.log('\n📋 DIAGNOSIS COMPLETE');
    
  } catch (error) {
    console.error('\n💥 ERROR DURING DIAGNOSIS:', error);
  }
}

diagnoseInventoryUpdate();
