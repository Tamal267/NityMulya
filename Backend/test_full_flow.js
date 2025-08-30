// Test to initialize proper subcategories and test inventory update
const baseUrl = 'http://localhost:5000';

async function initializeAndTest() {
  console.log('🔧 INITIALIZING SAMPLE DATA AND TESTING INVENTORY UPDATE...\n');
  
  try {
    // Step 1: Initialize sample data
    console.log('1️⃣ Initializing sample data...');
    
    const initResponse = await fetch(`${baseUrl}/initialize_sample_data`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    });
    
    if (initResponse.ok) {
      const initData = await initResponse.json();
      console.log('✅ Sample data initialized:', initData.message);
    } else {
      console.log('⚠️ Sample data initialization response:', await initResponse.text());
    }
    
    // Step 2: Create a wholesaler to access subcategories
    console.log('\n2️⃣ Setting up wholesaler access...');
    
    const wholesalerSignup = await fetch(`${baseUrl}/signup_wholesaler`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        full_name: 'Test Wholesaler',
        email: 'testwholesaler@example.com',
        password: 'password123',
        contact: '01900000000',
        address: 'Wholesaler Address',
        business_name: 'Test Wholesale',
        license_number: 'LIC123',
        latitude: 23.8103,
        longitude: 90.4125
      })
    });
    
    // Login as wholesaler
    const wholesalerLogin = await fetch(`${baseUrl}/login_wholesaler`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'testwholesaler@example.com',
        password: 'password123'
      })
    });
    
    let wholesalerToken = null;
    if (wholesalerLogin.ok) {
      const wholesalerData = await wholesalerLogin.json();
      wholesalerToken = wholesalerData.token;
      console.log('✅ Wholesaler access established');
    }
    
    // Step 3: Get available subcategories
    console.log('\n3️⃣ Getting available subcategories...');
    
    if (wholesalerToken) {
      const subcatResponse = await fetch(`${baseUrl}/wholesaler/subcategories?category_id=1`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${wholesalerToken}`
        }
      });
      
      if (subcatResponse.ok) {
        const subcatData = await subcatResponse.json();
        console.log(`✅ Found ${subcatData.length} subcategories`);
        
        if (subcatData.length > 0) {
          const firstSubcat = subcatData[0];
          console.log(`   First subcategory: ${firstSubcat.subcat_name} (ID: ${firstSubcat.id})`);
          console.log(`   Price range: ৳${firstSubcat.min_price} - ৳${firstSubcat.max_price}`);
          
          // Step 4: Test with shop owner
          console.log('\n4️⃣ Testing with shop owner...');
          
          const shopLogin = await fetch(`${baseUrl}/login_shop_owner`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              email: 'testshop2@example.com',
              password: 'password123'
            })
          });
          
          if (shopLogin.ok) {
            const shopData = await shopLogin.json();
            const shopToken = shopData.token;
            console.log(`✅ Shop owner logged in: ${shopData.shop_owner.full_name}`);
            
            // Calculate a valid price
            const minPrice = parseFloat(firstSubcat.min_price) || 50;
            const maxPrice = parseFloat(firstSubcat.max_price) || 100;
            const testPrice = minPrice + ((maxPrice - minPrice) / 2);
            
            console.log(`   Using valid price: ৳${testPrice} (range: ৳${minPrice}-৳${maxPrice})`);
            
            // Step 5: Add a test product
            console.log('\n5️⃣ Adding test product...');
            
            const addResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${shopToken}`
              },
              body: JSON.stringify({
                subcat_id: firstSubcat.id,
                stock_quantity: 100,
                unit_price: testPrice,
                low_stock_threshold: 10
              })
            });
            
            if (addResponse.ok) {
              const addData = await addResponse.json();
              console.log('✅ Product added successfully:', addData.message);
              
              // Step 6: Test inventory update
              console.log('\n6️⃣ Testing inventory update...');
              
              const inventoryResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
                method: 'GET',
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': `Bearer ${shopToken}`
                }
              });
              
              if (inventoryResponse.ok) {
                const inventoryData = await inventoryResponse.json();
                
                if (inventoryData.data.length > 0) {
                  const item = inventoryData.data[0];
                  const newQuantity = 150;
                  const newPrice = testPrice + 5;
                  
                  console.log(`   Original: ${item.stock_quantity} units at ৳${item.unit_price}`);
                  console.log(`   Updating to: ${newQuantity} units at ৳${newPrice}`);
                  
                  const updateResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
                    method: 'PUT',
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': `Bearer ${shopToken}`
                    },
                    body: JSON.stringify({
                      id: item.id,
                      stock_quantity: newQuantity,
                      unit_price: newPrice
                    })
                  });
                  
                  if (updateResponse.ok) {
                    const updateData = await updateResponse.json();
                    console.log('✅ UPDATE SUCCESS:', updateData.message);
                    
                    // Verify update
                    const verifyResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
                      method: 'GET',
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${shopToken}`
                      }
                    });
                    
                    if (verifyResponse.ok) {
                      const verifyData = await verifyResponse.json();
                      const updatedItem = verifyData.data.find(i => i.id === item.id);
                      
                      if (updatedItem) {
                        console.log('\n📊 VERIFICATION RESULTS:');
                        console.log(`   Quantity: ${updatedItem.stock_quantity} (expected ${newQuantity}) ${updatedItem.stock_quantity == newQuantity ? '✅' : '❌'}`);
                        console.log(`   Price: ৳${updatedItem.unit_price} (expected ৳${newPrice}) ${parseFloat(updatedItem.unit_price) == newPrice ? '✅' : '❌'}`);
                        
                        if (updatedItem.stock_quantity == newQuantity && parseFloat(updatedItem.unit_price) == newPrice) {
                          console.log('\n🎉 INVENTORY UPDATE WORKING PERFECTLY!');
                          console.log('✅ Database update: SUCCESS');
                          console.log('✅ API integration: SUCCESS');
                          console.log('✅ Data persistence: SUCCESS');
                          
                          console.log('\n🚀 FRONTEND INTEGRATION READY:');
                          console.log('✅ Backend API working correctly');
                          console.log('✅ UpdateProductScreen should work now');
                          console.log('✅ Shop owner can update quantities successfully');
                        } else {
                          console.log('\n❌ Update verification failed');
                        }
                      }
                    }
                  } else {
                    const errorText = await updateResponse.text();
                    console.log('❌ Update failed:', errorText);
                  }
                }
              }
            } else {
              const errorText = await addResponse.text();
              console.log('❌ Failed to add product:', errorText);
            }
          }
        } else {
          console.log('❌ No subcategories found');
        }
      } else {
        console.log('❌ Failed to get subcategories:', await subcatResponse.text());
      }
    }
    
  } catch (error) {
    console.error('💥 Error:', error);
  }
}

initializeAndTest();
