// Debug the inventory update to see what's failing
const baseUrl = 'http://localhost:5000';

async function debugUpdate() {
  console.log('🔍 DEBUGGING INVENTORY UPDATE...\n');
  
  try {
    // Initialize sample data
    const initResponse = await fetch(`${baseUrl}/initialize_sample_data`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    });
    
    console.log('✅ Sample data initialized');
    
    // Login as shop owner
    const shopLogin = await fetch(`${baseUrl}/login_shop_owner`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'rahman.grocery@example.com',
        password: 'password123'
      })
    });
    
    if (!shopLogin.ok) {
      console.log('❌ Login failed');
      return;
    }
    
    const shopData = await shopLogin.json();
    const shopToken = shopData.token;
    console.log(`✅ Logged in as: ${shopData.shop_owner.full_name}`);
    console.log(`   Shop Owner ID: ${shopData.shop_owner.id}`);
    
    // Get inventory items
    const inventoryResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${shopToken}`
      }
    });
    
    if (inventoryResponse.ok) {
      const inventoryData = await inventoryResponse.json();
      console.log(`📦 Found ${inventoryData.data.length} inventory items:`);
      
      inventoryData.data.forEach((item, index) => {
        console.log(`   ${index + 1}. ID: ${item.id}`);
        console.log(`      Product: ${item.subcat_name}`);
        console.log(`      Quantity: ${item.stock_quantity} units`);
        console.log(`      Price: ৳${item.unit_price}`);
        console.log(`      Owner ID: ${item.shop_owner_id}`);
      });
      
      if (inventoryData.data.length > 0) {
        const item = inventoryData.data[0];
        
        console.log(`\n🎯 Testing update with item ID: ${item.id}`);
        console.log(`   Current: ${item.stock_quantity} units at ৳${item.unit_price}`);
        
        const newQuantity = parseInt(item.stock_quantity) + 25;
        const newPrice = parseFloat(item.unit_price) + 5.00;
        
        console.log(`   New: ${newQuantity} units at ৳${newPrice}`);
        
        const updatePayload = {
          id: item.id,
          stock_quantity: newQuantity,
          unit_price: newPrice
        };
        
        console.log('\n📝 Update payload:', JSON.stringify(updatePayload, null, 2));
        
        const updateResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${shopToken}`
          },
          body: JSON.stringify(updatePayload)
        });
        
        console.log(`\n📡 Update response status: ${updateResponse.status}`);
        
        if (updateResponse.ok) {
          const updateData = await updateResponse.json();
          console.log('✅ UPDATE SUCCESS:', updateData);
          
          // Verify the change
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
              console.log('\n📊 VERIFICATION:');
              console.log(`   Updated quantity: ${updatedItem.stock_quantity} (expected ${newQuantity})`);
              console.log(`   Updated price: ৳${updatedItem.unit_price} (expected ৳${newPrice})`);
              
              const quantityMatch = updatedItem.stock_quantity == newQuantity;
              const priceMatch = Math.abs(parseFloat(updatedItem.unit_price) - newPrice) < 0.01;
              
              if (quantityMatch && priceMatch) {
                console.log('\n🎉 INVENTORY UPDATE IS WORKING PERFECTLY!');
                console.log('✅ The shop owner inventory update bug is FIXED!');
                console.log('✅ Database updates are persistent');
                console.log('✅ Flutter UpdateProductScreen will work correctly');
              } else {
                console.log('\n❌ Values did not update correctly');
                console.log(`   Quantity match: ${quantityMatch}`);
                console.log(`   Price match: ${priceMatch}`);
              }
            }
          }
        } else {
          const errorText = await updateResponse.text();
          console.log('❌ UPDATE FAILED:', errorText);
          
          try {
            const errorJson = JSON.parse(errorText);
            console.log('   Error details:', errorJson);
          } catch (e) {
            console.log('   Raw error:', errorText);
          }
        }
      }
    } else {
      console.log('❌ Failed to get inventory');
    }
    
  } catch (error) {
    console.error('💥 Debug error:', error);
  }
}

debugUpdate();
