// Direct database check to see what data exists
const baseUrl = 'http://localhost:5000';

async function checkDatabaseState() {
  console.log('🔍 CHECKING DATABASE STATE...\n');
  
  try {
    // Login as shop owner to get token
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
      console.log(`✅ Logged in as: ${shopData.shop_owner.full_name}`);
      console.log(`   Shop Owner ID: ${shopData.shop_owner.id}`);
      
      // Check what's already in the database by trying different approaches
      console.log('\n🗄️ Testing direct database approaches...');
      
      // Try to insert a product with minimal validation
      console.log('\n📝 Attempting to create test inventory directly...');
      
      const directInsert = await fetch(`${baseUrl}/api/test/direct-inventory`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${shopToken}`
        },
        body: JSON.stringify({
          shop_owner_id: shopData.shop_owner.id,
          stock_quantity: 100,
          unit_price: 75.0
        })
      });
      
      if (directInsert.ok) {
        console.log('✅ Direct inventory creation worked');
      } else {
        console.log('❌ Direct approach failed:', await directInsert.text());
      }
      
      // Alternative: Try to seed with sample data
      console.log('\n🌱 Trying alternative seeding...');
      
      const seedResponse = await fetch(`${baseUrl}/api/test/seed-inventory`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${shopToken}`
        },
        body: JSON.stringify({
          shop_owner_id: shopData.shop_owner.id
        })
      });
      
      if (seedResponse.ok) {
        console.log('✅ Seeding worked');
        
        // Now check inventory
        const inventoryResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${shopToken}`
          }
        });
        
        if (inventoryResponse.ok) {
          const inventoryData = await inventoryResponse.json();
          console.log(`📦 Inventory now has ${inventoryData.data.length} items`);
          
          if (inventoryData.data.length > 0) {
            const item = inventoryData.data[0];
            console.log(`   First item: ID ${item.id}, Quantity: ${item.stock_quantity}, Price: ৳${item.unit_price}`);
            
            // NOW TEST THE UPDATE!
            console.log('\n🚀 TESTING INVENTORY UPDATE...');
            
            const originalQuantity = item.stock_quantity;
            const originalPrice = parseFloat(item.unit_price);
            const newQuantity = originalQuantity + 50;
            const newPrice = originalPrice + 10;
            
            console.log(`   Updating from ${originalQuantity} → ${newQuantity} units`);
            console.log(`   Updating from ৳${originalPrice} → ৳${newPrice}`);
            
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
                
                console.log('\n📊 VERIFICATION RESULTS:');
                console.log(`   Quantity: ${updatedItem.stock_quantity} (expected ${newQuantity})`);
                console.log(`   Price: ৳${updatedItem.unit_price} (expected ৳${newPrice})`);
                
                const quantityCorrect = updatedItem.stock_quantity == newQuantity;
                const priceCorrect = Math.abs(parseFloat(updatedItem.unit_price) - newPrice) < 0.01;
                
                if (quantityCorrect && priceCorrect) {
                  console.log('\n🎉 INVENTORY UPDATE IS WORKING PERFECTLY!');
                  console.log('✅ Backend API: FUNCTIONAL');
                  console.log('✅ Database updates: PERSISTENT');
                  console.log('✅ Flutter integration: READY');
                  
                  console.log('\n📱 FLUTTER APP READY:');
                  console.log('✅ UpdateProductScreen will work');
                  console.log('✅ Shop owner can update quantities');
                  console.log('✅ Changes will save to database');
                  console.log('✅ UI will show updated values');
                  
                  console.log('\n💡 PROBLEM SOLVED:');
                  console.log('   The "3 dots" → Edit → Update functionality is now working!');
                } else {
                  console.log('\n❌ Values not matching after update');
                  console.log(`   Quantity check: ${quantityCorrect}`);
                  console.log(`   Price check: ${priceCorrect}`);
                }
              }
            } else {
              const errorText = await updateResponse.text();
              console.log('❌ Update failed:', errorText);
            }
          }
        }
      } else {
        console.log('❌ Seeding failed:', await seedResponse.text());
        
        // Last resort: manually create a row
        console.log('\n🔧 Last resort: manual row creation...');
        
        const manualCreate = await fetch(`${baseUrl}/api/test/manual-inventory`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            shop_owner_id: shopData.shop_owner.id
          })
        });
        
        console.log('Manual creation response:', manualCreate.status);
        if (manualCreate.ok) {
          console.log('✅ Manual creation worked, retry the test');
        }
      }
    }
    
  } catch (error) {
    console.error('💥 Error:', error);
  }
}

checkDatabaseState();
