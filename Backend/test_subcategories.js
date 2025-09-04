// Check what subcategories exist in the database
const baseUrl = 'http://localhost:5000';

async function checkSubcategories() {
  console.log('🔍 Checking available subcategories...');
  
  try {
    // Login as wholesaler to access subcategories endpoint
    const loginResponse = await fetch(`${baseUrl}/login_wholesaler`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'wholesaler@test.com', // Try common test email
        password: 'password123'
      })
    });
    
    let token = null;
    
    if (loginResponse.ok) {
      const loginData = await loginResponse.json();
      token = loginData.token;
      console.log('✅ Logged in as wholesaler');
    } else {
      console.log('❌ Wholesaler login failed, trying to create one...');
      
      // Try to create a wholesaler
      const signupResponse = await fetch(`${baseUrl}/signup_wholesaler`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          full_name: 'Test Wholesaler',
          email: 'testwholesaler@example.com',
          password: 'password123',
          contact: '01900000000',
          address: 'Wholesaler Address, Dhaka',
          business_name: 'Test Wholesale Business',
          license_number: 'LICENSE123',
          latitude: 23.8103,
          longitude: 90.4125
        })
      });
      
      if (signupResponse.ok) {
        const signupData = await signupResponse.json();
        console.log('✅ Wholesaler created');
        
        // Login again
        const login2Response = await fetch(`${baseUrl}/login_wholesaler`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            email: 'testwholesaler@example.com',
            password: 'password123'
          })
        });
        
        if (login2Response.ok) {
          const login2Data = await login2Response.json();
          token = login2Data.token;
          console.log('✅ Logged in as new wholesaler');
        }
      }
    }
    
    if (token) {
      // Get subcategories
      const subcatResponse = await fetch(`${baseUrl}/wholesaler/subcategories`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        }
      });
      
      if (subcatResponse.ok) {
        const subcatData = await subcatResponse.json();
        console.log(`\n📋 Found ${subcatData.length} subcategories:`);
        
        subcatData.slice(0, 10).forEach((subcat, index) => {
          console.log(`   ${index + 1}. ID: ${subcat.id}, Name: ${subcat.subcat_name}, Min: ৳${subcat.min_price}, Max: ৳${subcat.max_price}`);
        });
        
        if (subcatData.length > 0) {
          // Test adding product with valid subcategory
          console.log('\n🧪 Testing product addition with valid subcategory...');
          
          const shopLoginResponse = await fetch(`${baseUrl}/login_shop_owner`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              email: 'testshop2@example.com',
              password: 'password123'
            })
          });
          
          if (shopLoginResponse.ok) {
            const shopLoginData = await shopLoginResponse.json();
            const shopToken = shopLoginData.token;
            
            const firstSubcat = subcatData[0];
            const testPrice = (parseFloat(firstSubcat.min_price) + parseFloat(firstSubcat.max_price)) / 2;
            
            console.log(`Using subcategory: ${firstSubcat.subcat_name} (ID: ${firstSubcat.id})`);
            console.log(`Price range: ৳${firstSubcat.min_price} - ৳${firstSubcat.max_price}`);
            console.log(`Testing with price: ৳${testPrice}`);
            
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
              console.log('✅ Product addition successful:', addData.message);
              
              // Now test the update functionality
              console.log('\n🔄 Testing inventory update...');
              
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
                  const newPrice = testPrice + 10;
                  
                  console.log(`Updating item: ${item.subcat_name}`);
                  console.log(`Current: ${item.stock_quantity} units at ৳${item.unit_price}`);
                  console.log(`New: ${newQuantity} units at ৳${newPrice}`);
                  
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
                    
                    // Verify the update
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
                      
                      console.log('\n📊 VERIFICATION:');
                      console.log(`   Quantity: ${updatedItem.stock_quantity} (expected ${newQuantity}) ${updatedItem.stock_quantity == newQuantity ? '✅' : '❌'}`);
                      console.log(`   Price: ৳${updatedItem.unit_price} (expected ৳${newPrice}) ${parseFloat(updatedItem.unit_price) == newPrice ? '✅' : '❌'}`);
                      
                      if (updatedItem.stock_quantity == newQuantity && parseFloat(updatedItem.unit_price) == newPrice) {
                        console.log('\n🎉 INVENTORY UPDATE FULLY WORKING!');
                      } else {
                        console.log('\n❌ Update verification failed');
                      }
                    }
                  } else {
                    const errorText = await updateResponse.text();
                    console.log('❌ UPDATE FAILED:', errorText);
                  }
                }
              }
            } else {
              const errorText = await addResponse.text();
              console.log('❌ Product addition failed:', errorText);
            }
          }
        }
      } else {
        console.log('❌ Cannot get subcategories:', subcatResponse.status, await subcatResponse.text());
      }
    } else {
      console.log('❌ Could not get authentication token');
    }
    
  } catch (error) {
    console.error('💥 Error:', error);
  }
}

checkSubcategories();
