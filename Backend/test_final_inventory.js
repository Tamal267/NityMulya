// Check what data exists after initialization
const baseUrl = 'http://localhost:5000';

async function checkDataAndTest() {
  console.log('🔍 Checking available data after initialization...');
  
  try {
    // Login as shop owner first
    const shopLoginResponse = await fetch(`${baseUrl}/login_shop_owner`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'testshop2@example.com',
        password: 'password123'
      })
    });
    
    const shopLoginData = await shopLoginResponse.json();
    const shopToken = shopLoginData.token;
    console.log(`✅ Logged in as: ${shopLoginData.shop_owner.full_name}`);
    
    // Check if this shop owner already has inventory from sample data
    const inventoryResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${shopToken}`
      }
    });
    
    if (inventoryResponse.ok) {
      const inventoryData = await inventoryResponse.json();
      console.log(`📦 Current inventory: ${inventoryData.data.length} items`);
      
      if (inventoryData.data.length > 0) {
        console.log('\n🎉 Found existing inventory! Testing update functionality...');
        
        const item = inventoryData.data[0];
        console.log(`\nTesting with: ${item.subcat_name}`);
        console.log(`Current quantity: ${item.stock_quantity}`);
        console.log(`Current price: ৳${item.unit_price}`);
        console.log(`Low stock threshold: ${item.low_stock_threshold}`);
        
        // Test update
        const originalQuantity = item.stock_quantity;
        const originalPrice = parseFloat(item.unit_price);
        const newQuantity = originalQuantity + 25;
        const newPrice = originalPrice + 5;
        
        console.log(`\n🔄 Testing update: ${originalQuantity} → ${newQuantity} units, ৳${originalPrice} → ৳${newPrice}`);
        
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
          console.log('✅ Update Response:', updateData.message);
          
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
            
            console.log('\n📊 UPDATE VERIFICATION:');
            console.log(`   Original Quantity: ${originalQuantity}`);
            console.log(`   Updated Quantity: ${updatedItem.stock_quantity}`);
            console.log(`   Expected Quantity: ${newQuantity}`);
            console.log(`   Quantity Match: ${updatedItem.stock_quantity == newQuantity ? '✅ YES' : '❌ NO'}`);
            
            console.log(`   Original Price: ৳${originalPrice}`);
            console.log(`   Updated Price: ৳${updatedItem.unit_price}`);
            console.log(`   Expected Price: ৳${newPrice}`);
            console.log(`   Price Match: ${parseFloat(updatedItem.unit_price) == newPrice ? '✅ YES' : '❌ NO'}`);
            
            // Check low stock status
            const isLowStock = updatedItem.stock_quantity < (updatedItem.low_stock_threshold || 10);
            console.log(`   Low Stock Status: ${isLowStock ? 'LOW STOCK ⚠️' : 'ADEQUATE STOCK ✅'}`);
            
            if (updatedItem.stock_quantity == newQuantity && parseFloat(updatedItem.unit_price) == newPrice) {
              console.log('\n🎉 SUCCESS: INVENTORY UPDATE IS WORKING PERFECTLY!');
              console.log('✅ Database update: Working');
              console.log('✅ Quantity change: Working');
              console.log('✅ Price change: Working');
              console.log('✅ API integration: Working');
              console.log('\n👍 The frontend inventory update should work correctly now!');
            } else {
              console.log('\n❌ FAILURE: Update not working correctly');
            }
          }
        } else {
          const errorText = await updateResponse.text();
          console.log('❌ Update failed:', errorText);
        }
        
      } else {
        console.log('\n📋 No inventory found. The sample data may not have created inventory for this shop owner.');
        console.log('This is normal - shop owners start with empty inventory.');
        console.log('To test inventory updates, you would need to:');
        console.log('1. Add products through the frontend');
        console.log('2. Then test the update functionality');
      }
    }
    
  } catch (error) {
    console.error('💥 Error:', error);
  }
}

checkDataAndTest();
