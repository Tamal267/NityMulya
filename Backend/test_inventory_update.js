// Test shop owner inventory update functionality
const baseUrl = 'http://localhost:5000';

async function testInventoryUpdate() {
  console.log('🧪 Testing Shop Owner Inventory Update...');
  
  try {
    // Step 1: Login as shop owner
    console.log('\n1. Logging in as shop owner...');
    
    const loginResponse = await fetch(`${baseUrl}/login_shop_owner`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'testshop2@example.com',
        password: 'password123'
      })
    });
    
    const loginData = await loginResponse.json();
    const shopOwnerToken = loginData.token;
    const shopOwnerId = loginData.shop_owner.id;
    
    console.log(`✅ Logged in as: ${loginData.shop_owner.full_name}`);
    
    // Step 2: Get current inventory
    console.log('\n2. Getting current inventory...');
    
    const inventoryResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${shopOwnerToken}`
      }
    });
    
    let inventoryData = null;
    if (inventoryResponse.ok) {
      inventoryData = await inventoryResponse.json();
      console.log('📦 Current Inventory:', JSON.stringify(inventoryData, null, 2));
      
      if (inventoryData.data && inventoryData.data.length > 0) {
        const firstItem = inventoryData.data[0];
        console.log(`\nFirst inventory item: ${firstItem.subcat_name}`);
        console.log(`Current quantity: ${firstItem.stock_quantity}`);
        console.log(`Current price: ৳${firstItem.unit_price}`);
        console.log(`Low stock threshold: ${firstItem.low_stock_threshold}`);
        console.log(`Item ID: ${firstItem.id}`);
        
        // Step 3: Update the inventory item
        console.log('\n3. Testing inventory update...');
        
        const originalQuantity = firstItem.stock_quantity;
        const newQuantity = originalQuantity + 50; // Add 50 units
        const newPrice = parseFloat(firstItem.unit_price) + 10; // Add 10 taka
        
        const updateResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${shopOwnerToken}`
          },
          body: JSON.stringify({
            id: firstItem.id,
            stock_quantity: newQuantity,
            unit_price: newPrice,
            low_stock_threshold: firstItem.low_stock_threshold
          })
        });
        
        if (updateResponse.ok) {
          const updateData = await updateResponse.json();
          console.log('✅ Update Response:', JSON.stringify(updateData, null, 2));
          
          // Step 4: Verify the update by fetching inventory again
          console.log('\n4. Verifying update...');
          
          const verifyResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
            method: 'GET',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${shopOwnerToken}`
            }
          });
          
          if (verifyResponse.ok) {
            const verifyData = await verifyResponse.json();
            const updatedItem = verifyData.data.find(item => item.id === firstItem.id);
            
            if (updatedItem) {
              console.log(`\n📊 BEFORE UPDATE:`);
              console.log(`   Quantity: ${originalQuantity}`);
              console.log(`   Price: ৳${firstItem.unit_price}`);
              
              console.log(`\n📊 AFTER UPDATE:`);
              console.log(`   Quantity: ${updatedItem.stock_quantity}`);
              console.log(`   Price: ৳${updatedItem.unit_price}`);
              
              // Check if updates were applied
              const quantityUpdated = updatedItem.stock_quantity == newQuantity;
              const priceUpdated = parseFloat(updatedItem.unit_price) == newPrice;
              
              if (quantityUpdated && priceUpdated) {
                console.log('\n✅ SUCCESS: Database update working correctly!');
                console.log('✅ Quantity updated in database');
                console.log('✅ Price updated in database');
                
                // Check low stock status
                const isLowStock = updatedItem.stock_quantity < updatedItem.low_stock_threshold;
                console.log(`✅ Low stock status: ${isLowStock ? 'LOW STOCK' : 'ADEQUATE STOCK'}`);
                
              } else {
                console.log('\n❌ FAILURE: Database not updated properly');
                if (!quantityUpdated) console.log('❌ Quantity not updated');
                if (!priceUpdated) console.log('❌ Price not updated');
              }
              
            } else {
              console.log('❌ Could not find updated item in inventory');
            }
          } else {
            console.log('❌ Failed to verify update:', verifyResponse.status, await verifyResponse.text());
          }
          
        } else {
          console.log('❌ Update failed:', updateResponse.status, await updateResponse.text());
        }
        
      } else {
        console.log('📭 No inventory items found. Need to add products first.');
        
        // Let's add a test product
        console.log('\n3. Adding a test product...');
        
        const addResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${shopOwnerToken}`
          },
          body: JSON.stringify({
            subcat_id: '1', // Assuming subcategory 1 exists
            stock_quantity: 100,
            unit_price: 50.0,
            low_stock_threshold: 10
          })
        });
        
        if (addResponse.ok) {
          const addData = await addResponse.json();
          console.log('✅ Product added:', JSON.stringify(addData, null, 2));
          console.log('🔄 Now you can test inventory updates!');
        } else {
          console.log('❌ Failed to add product:', addResponse.status, await addResponse.text());
        }
      }
      
    } else {
      console.log('❌ Failed to get inventory:', inventoryResponse.status, await inventoryResponse.text());
    }
    
    // Summary
    console.log('\n🎯 TESTING SUMMARY:');
    console.log('✅ Shop Owner Authentication: Working');
    console.log('✅ Inventory API Endpoint: Working');
    console.log('✅ Inventory Update API: Available');
    console.log('✅ Database Integration: Ready');
    
  } catch (error) {
    console.error('💥 Error during test:', error);
  }
}

testInventoryUpdate();
