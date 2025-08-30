// Comprehensive test to debug the inventory update issue
const baseUrl = 'http://localhost:5000';

async function debugInventoryUpdate() {
  console.log('🔍 Debugging Inventory Update Issue...');
  
  try {
    // Step 1: Login as shop owner
    console.log('\n1. Testing shop owner login...');
    
    const loginResponse = await fetch(`${baseUrl}/login_shop_owner`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'john.doe@example.com', // Try with sample data shop owner
        password: 'password123'
      })
    });
    
    if (!loginResponse.ok) {
      console.log('❌ Login failed, trying different credentials...');
      
      // Try with test shop owner
      const loginResponse2 = await fetch(`${baseUrl}/login_shop_owner`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: 'testshop2@example.com',
          password: 'password123'
        })
      });
      
      if (!loginResponse2.ok) {
        console.log('❌ Both logins failed');
        return;
      }
      
      const loginData2 = await loginResponse2.json();
      var token = loginData2.token;
      var shopOwnerId = loginData2.shop_owner.id;
      console.log(`✅ Logged in as: ${loginData2.shop_owner.full_name}`);
    } else {
      const loginData = await loginResponse.json();
      var token = loginData.token;
      var shopOwnerId = loginData.shop_owner.id;
      console.log(`✅ Logged in as: ${loginData.shop_owner.full_name}`);
    }
    
    // Step 2: Get current inventory
    console.log('\n2. Checking current inventory...');
    
    const inventoryResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    });
    
    if (!inventoryResponse.ok) {
      console.log('❌ Failed to get inventory:', await inventoryResponse.text());
      return;
    }
    
    const inventoryData = await inventoryResponse.json();
    console.log(`📦 Found ${inventoryData.data.length} inventory items`);
    
    if (inventoryData.data.length === 0) {
      console.log('\n📝 No inventory found. Adding a test product...');
      
      // Try to add a product first
      const addResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          subcat_id: 1, // Try with ID 1
          stock_quantity: 100,
          unit_price: 80.0,
          low_stock_threshold: 10
        })
      });
      
      if (addResponse.ok) {
        const addData = await addResponse.json();
        console.log('✅ Product added successfully');
        
        // Get updated inventory
        const updatedInventoryResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          }
        });
        
        if (updatedInventoryResponse.ok) {
          const updatedInventoryData = await updatedInventoryResponse.json();
          inventoryData.data = updatedInventoryData.data;
        }
      } else {
        const addError = await addResponse.text();
        console.log('❌ Failed to add product:', addError);
        
        // Let's try with different subcategory IDs
        console.log('\n🔄 Trying different subcategory IDs...');
        
        for (let subcatId = 2; subcatId <= 10; subcatId++) {
          const tryAddResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({
              subcat_id: subcatId,
              stock_quantity: 50,
              unit_price: 60.0,
              low_stock_threshold: 5
            })
          });
          
          if (tryAddResponse.ok) {
            console.log(`✅ Successfully added product with subcategory ID: ${subcatId}`);
            
            // Get the new inventory
            const newInventoryResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
              method: 'GET',
              headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
              }
            });
            
            if (newInventoryResponse.ok) {
              const newInventoryData = await newInventoryResponse.json();
              inventoryData.data = newInventoryData.data;
            }
            break;
          } else {
            console.log(`❌ Subcategory ID ${subcatId} failed:`, await tryAddResponse.text());
          }
        }
      }
    }
    
    // Step 3: Test inventory update
    if (inventoryData.data.length > 0) {
      const testItem = inventoryData.data[0];
      console.log(`\n3. Testing update on item: ${testItem.subcat_name || 'Unknown Product'}`);
      console.log(`   Current: ${testItem.stock_quantity} units at ৳${testItem.unit_price}`);
      console.log(`   Item ID: ${testItem.id} (Type: ${typeof testItem.id})`);
      console.log(`   Shop Owner ID: ${shopOwnerId}`);
      
      const originalQuantity = parseInt(testItem.stock_quantity);
      const newQuantity = originalQuantity + 25;
      const originalPrice = parseFloat(testItem.unit_price);
      const newPrice = originalPrice + 10;
      
      console.log(`\n🔄 Attempting update: ${originalQuantity} → ${newQuantity} units, ৳${originalPrice} → ৳${newPrice}`);
      
      const updatePayload = {
        id: testItem.id,
        stock_quantity: newQuantity,
        unit_price: newPrice,
        low_stock_threshold: testItem.low_stock_threshold
      };
      
      console.log('📝 Update payload:', JSON.stringify(updatePayload, null, 2));
      
      const updateResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(updatePayload)
      });
      
      console.log(`📡 Update response status: ${updateResponse.status}`);
      
      if (updateResponse.ok) {
        const updateData = await updateResponse.json();
        console.log('✅ UPDATE SUCCESS:', JSON.stringify(updateData, null, 2));
        
        // Step 4: Verify the update
        console.log('\n4. Verifying update...');
        
        const verifyResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          }
        });
        
        if (verifyResponse.ok) {
          const verifyData = await verifyResponse.json();
          const updatedItem = verifyData.data.find(item => item.id == testItem.id);
          
          if (updatedItem) {
            console.log('\n📊 VERIFICATION RESULTS:');
            console.log(`   Original Quantity: ${originalQuantity}`);
            console.log(`   Updated Quantity: ${updatedItem.stock_quantity}`);
            console.log(`   Quantity Match: ${updatedItem.stock_quantity == newQuantity ? '✅' : '❌'}`);
            
            console.log(`   Original Price: ৳${originalPrice}`);
            console.log(`   Updated Price: ৳${updatedItem.unit_price}`);
            console.log(`   Price Match: ${parseFloat(updatedItem.unit_price) == newPrice ? '✅' : '❌'}`);
            
            if (updatedItem.stock_quantity == newQuantity && parseFloat(updatedItem.unit_price) == newPrice) {
              console.log('\n🎉 SUCCESS: Inventory update is working correctly!');
              console.log('✅ Database update: Working');
              console.log('✅ API integration: Working');
              console.log('✅ The frontend should work properly now');
            } else {
              console.log('\n❌ FAILURE: Update not reflected in database');
            }
          } else {
            console.log('❌ Could not find updated item');
          }
        }
        
      } else {
        const errorText = await updateResponse.text();
        console.log('❌ UPDATE FAILED:');
        console.log(`   Status: ${updateResponse.status}`);
        console.log(`   Error: ${errorText}`);
        
        // Let's try to debug the specific error
        try {
          const errorData = JSON.parse(errorText);
          console.log('   Parsed Error:', JSON.stringify(errorData, null, 2));
        } catch (e) {
          console.log('   Raw Error:', errorText);
        }
      }
      
    } else {
      console.log('\n❌ No inventory items available to test update');
    }
    
  } catch (error) {
    console.error('💥 Error during debugging:', error);
  }
}

debugInventoryUpdate();
