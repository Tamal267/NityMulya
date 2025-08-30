// Simple test to add a product and test inventory update
const baseUrl = 'http://localhost:5000';

async function testInventoryUpdateSimple() {
  console.log('🧪 Simple Inventory Update Test...');
  
  try {
    // Step 1: Login as shop owner
    const loginResponse = await fetch(`${baseUrl}/login_shop_owner`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'testshop2@example.com',
        password: 'password123'
      })
    });
    
    const loginData = await loginResponse.json();
    const token = loginData.token;
    console.log(`✅ Logged in as: ${loginData.shop_owner.full_name}`);
    
    // Step 2: Try to add a product with a simple subcat_id
    console.log('\n📦 Adding test product...');
    
    const addResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        subcat_id: 1, // Try with simple ID
        stock_quantity: 50,
        unit_price: 100.0,
        low_stock_threshold: 10
      })
    });
    
    if (addResponse.ok) {
      const addData = await addResponse.json();
      console.log('✅ Product added:', addData.message);
      
      // Step 3: Get inventory to find the item
      const inventoryResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        }
      });
      
      if (inventoryResponse.ok) {
        const inventoryData = await inventoryResponse.json();
        console.log(`📊 Current inventory: ${inventoryData.data.length} items`);
        
        if (inventoryData.data.length > 0) {
          const item = inventoryData.data[0];
          console.log(`\nTesting with item: ${item.subcat_name || 'Unknown Product'}`);
          console.log(`Current: ${item.stock_quantity} units at ৳${item.unit_price}`);
          
          // Step 4: Update the item
          console.log('\n🔄 Testing update...');
          
          const newQuantity = 75;
          const newPrice = 120.0;
          
          const updateResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
            method: 'PUT',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({
              id: item.id,
              stock_quantity: newQuantity,
              unit_price: newPrice
            })
          });
          
          if (updateResponse.ok) {
            const updateData = await updateResponse.json();
            console.log('✅ Update response:', updateData.message);
            
            // Step 5: Verify update
            const verifyResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
              method: 'GET',
              headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
              }
            });
            
            if (verifyResponse.ok) {
              const verifyData = await verifyResponse.json();
              const updatedItem = verifyData.data.find(i => i.id === item.id);
              
              if (updatedItem) {
                console.log('\n📊 VERIFICATION RESULTS:');
                console.log(`   Original quantity: ${item.stock_quantity}`);
                console.log(`   Updated quantity: ${updatedItem.stock_quantity}`);
                console.log(`   Original price: ৳${item.unit_price}`);
                console.log(`   Updated price: ৳${updatedItem.unit_price}`);
                
                const quantityCorrect = updatedItem.stock_quantity == newQuantity;
                const priceCorrect = parseFloat(updatedItem.unit_price) == newPrice;
                
                if (quantityCorrect && priceCorrect) {
                  console.log('\n🎉 SUCCESS: Inventory update working correctly!');
                  console.log('✅ Quantity updated in database');
                  console.log('✅ Price updated in database');
                  console.log('✅ Frontend integration should work properly');
                } else {
                  console.log('\n❌ FAILURE: Update not working');
                  if (!quantityCorrect) console.log('❌ Quantity not updated');
                  if (!priceCorrect) console.log('❌ Price not updated');
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
      console.log('❌ Add product failed:', errorText);
      
      // Maybe there are existing products, let's check
      console.log('\n📦 Checking existing inventory...');
      
      const inventoryResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        }
      });
      
      if (inventoryResponse.ok) {
        const inventoryData = await inventoryResponse.json();
        console.log(`📊 Existing inventory: ${inventoryData.data.length} items`);
        
        if (inventoryData.data.length > 0) {
          console.log('Found existing items - you can test updates with the frontend!');
          inventoryData.data.forEach((item, index) => {
            console.log(`   ${index + 1}. ${item.subcat_name || 'Unknown'}: ${item.stock_quantity} units at ৳${item.unit_price}`);
          });
        }
      }
    }
    
  } catch (error) {
    console.error('💥 Error:', error);
  }
}

testInventoryUpdateSimple();
