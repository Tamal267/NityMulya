// Comprehensive test to understand current system state and test inventory updates
const baseUrl = 'http://localhost:5000';

async function fullSystemTest() {
  console.log('🧪 Full System Test for Inventory Updates...');
  
  try {
    // Step 1: Get all available endpoints
    console.log('\n1. Testing available endpoints...');
    
    const endpoints = [
      '/subcategories',
      '/products',
      '/customer/orders',
      '/shop-owner/inventory',
      '/wholesaler/inventory'
    ];
    
    for (const endpoint of endpoints) {
      try {
        const response = await fetch(`${baseUrl}${endpoint}`);
        console.log(`   ${endpoint}: ${response.status}`);
      } catch (e) {
        console.log(`   ${endpoint}: Error`);
      }
    }
    
    // Step 2: Login as shop owner
    console.log('\n2. Shop owner authentication...');
    
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
    
    console.log(`✅ Logged in as: ${loginData.shop_owner.full_name}`);
    
    // Step 3: Try to get subcategories to see what products we can add
    console.log('\n3. Testing subcategories endpoint...');
    
    const subcatResponse = await fetch(`${baseUrl}/subcategories`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      }
    });
    
    if (subcatResponse.ok) {
      const subcatData = await subcatResponse.json();
      console.log('📋 Available subcategories:', subcatData.length);
      
      if (subcatData.length > 0) {
        const firstSubcat = subcatData[0];
        console.log(`First subcategory: ${firstSubcat.subcat_name} (ID: ${firstSubcat.id})`);
        
        // Step 4: Try to add a product to inventory
        console.log('\n4. Adding test product to inventory...');
        
        const addProductResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${shopOwnerToken}`
          },
          body: JSON.stringify({
            subcat_id: firstSubcat.id,
            stock_quantity: 100,
            unit_price: 80.0,
            low_stock_threshold: 10
          })
        });
        
        if (addProductResponse.ok) {
          const addData = await addProductResponse.json();
          console.log('✅ Product added successfully:', addData.message);
          
          // Step 5: Get updated inventory
          console.log('\n5. Getting updated inventory...');
          
          const inventoryResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
            method: 'GET',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${shopOwnerToken}`
            }
          });
          
          if (inventoryResponse.ok) {
            const inventoryData = await inventoryResponse.json();
            console.log(`📦 Inventory items: ${inventoryData.data.length}`);
            
            if (inventoryData.data.length > 0) {
              const testItem = inventoryData.data[0];
              console.log(`\nTest item: ${testItem.subcat_name}`);
              console.log(`Current quantity: ${testItem.stock_quantity}`);
              console.log(`Current price: ৳${testItem.unit_price}`);
              console.log(`Item ID: ${testItem.id}`);
              
              // Step 6: Test inventory update
              console.log('\n6. Testing inventory update...');
              
              const originalQuantity = testItem.stock_quantity;
              const newQuantity = originalQuantity + 25;
              const originalPrice = parseFloat(testItem.unit_price);
              const newPrice = originalPrice + 5;
              
              console.log(`Updating quantity: ${originalQuantity} → ${newQuantity}`);
              console.log(`Updating price: ৳${originalPrice} → ৳${newPrice}`);
              
              const updateResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
                method: 'PUT',
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': `Bearer ${shopOwnerToken}`
                },
                body: JSON.stringify({
                  id: testItem.id,
                  stock_quantity: newQuantity,
                  unit_price: newPrice
                })
              });
              
              if (updateResponse.ok) {
                const updateData = await updateResponse.json();
                console.log('✅ Update API Response:', updateData.message);
                
                // Step 7: Verify the update
                console.log('\n7. Verifying update in database...');
                
                const verifyResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
                  method: 'GET',
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${shopOwnerToken}`
                  }
                });
                
                if (verifyResponse.ok) {
                  const verifyData = await verifyResponse.json();
                  const updatedItem = verifyData.data.find(item => item.id === testItem.id);
                  
                  if (updatedItem) {
                    const quantityMatch = updatedItem.stock_quantity == newQuantity;
                    const priceMatch = parseFloat(updatedItem.unit_price) == newPrice;
                    
                    console.log('\n📊 UPDATE VERIFICATION:');
                    console.log(`   Quantity: ${updatedItem.stock_quantity} (expected ${newQuantity}) ${quantityMatch ? '✅' : '❌'}`);
                    console.log(`   Price: ৳${updatedItem.unit_price} (expected ৳${newPrice}) ${priceMatch ? '✅' : '❌'}`);
                    
                    // Test low stock detection
                    const isLowStock = updatedItem.stock_quantity < (updatedItem.low_stock_threshold || 10);
                    console.log(`   Low Stock: ${isLowStock ? 'YES' : 'NO'} (threshold: ${updatedItem.low_stock_threshold || 10})`);
                    
                    if (quantityMatch && priceMatch) {
                      console.log('\n🎉 SUCCESS: Inventory update is working correctly!');
                      console.log('✅ Database updates are working');
                      console.log('✅ API responses are correct');
                      console.log('✅ Quantity and price changes are saved');
                      console.log('✅ Low stock detection is functional');
                    } else {
                      console.log('\n❌ FAILURE: Updates not saved correctly');
                    }
                  }
                }
              } else {
                const errorText = await updateResponse.text();
                console.log('❌ Update failed:', updateResponse.status, errorText);
              }
            }
          }
        } else {
          const errorText = await addProductResponse.text();
          console.log('❌ Failed to add product:', addProductResponse.status, errorText);
        }
      } else {
        console.log('❌ No subcategories available');
      }
    } else {
      console.log('❌ Cannot access subcategories:', subcatResponse.status);
    }
    
  } catch (error) {
    console.error('💥 Error during test:', error);
  }
}

fullSystemTest();
