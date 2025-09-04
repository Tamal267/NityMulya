// Simple server connectivity test
require('dotenv').config();

const baseUrl = 'http://localhost:5000';

async function testServerBasics() {
  try {
    console.log('🔍 Testing Server Connectivity...\n');
    
    // Test if server is responding
    console.log('1️⃣ Testing server connectivity...');
    
    try {
      const response = await fetch(baseUrl);
      console.log(`✅ Server responding with status: ${response.status}`);
      const text = await response.text();
      console.log('Response preview:', text.substring(0, 100));
    } catch (error) {
      console.log('❌ Server not responding:', error.message);
      return;
    }
    
    // Test a simple endpoint
    console.log('\n2️⃣ Testing API endpoints...');
    
    const testEndpoints = [
      '/shop-owner/login',
      '/shop-owner/register', 
      '/shop-owner/inventory'
    ];
    
    for (const endpoint of testEndpoints) {
      try {
        const response = await fetch(`${baseUrl}${endpoint}`, {
          method: endpoint === '/shop-owner/login' ? 'POST' : 'GET',
          headers: { 'Content-Type': 'application/json' },
          body: endpoint === '/shop-owner/login' ? JSON.stringify({}) : undefined
        });
        
        console.log(`${endpoint}: ${response.status} ${response.statusText}`);
        
        if (response.status !== 500) {
          const data = await response.json();
          console.log(`  Response:`, data);
        }
      } catch (error) {
        console.log(`${endpoint}: ERROR - ${error.message}`);
      }
    }
    
    // Test creating account directly via API
    console.log('\n3️⃣ Testing account creation...');
    try {
      const createResponse = await fetch(`${baseUrl}/shop-owner/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          full_name: 'Direct API Test',
          email: 'direct.api.test@example.com',
          password: 'testpass123',
          contact: '01987654321',
          address: 'API Test Address',
          latitude: 23.7465,
          longitude: 90.3763,
          shop_name: 'Direct API Test Shop',
          shop_description: 'Testing direct API access'
        })
      });
      
      const createData = await createResponse.json();
      console.log('Account creation response:', createData);
      
      if (createData.success) {
        console.log('✅ Account created successfully!');
        
        // Now try to login
        console.log('\n4️⃣ Testing login with new account...');
        const loginResponse = await fetch(`${baseUrl}/shop-owner/login`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            email: 'direct.api.test@example.com',
            password: 'testpass123'
          })
        });
        
        const loginData = await loginResponse.json();
        console.log('Login response:', loginData);
        
        if (loginData.success) {
          console.log('✅ LOGIN WORKING!');
          console.log('Token received:', loginData.data.token.substring(0, 20) + '...');
          
          // Test inventory access
          console.log('\n5️⃣ Testing inventory access...');
          const inventoryResponse = await fetch(`${baseUrl}/shop-owner/inventory`, {
            headers: { 
              'Authorization': `Bearer ${loginData.data.token}`,
              'Content-Type': 'application/json'
            }
          });
          
          const inventoryData = await inventoryResponse.json();
          console.log('Inventory response:', inventoryData);
          
          if (inventoryData.success) {
            console.log('✅ INVENTORY API WORKING!');
            console.log(`Found ${inventoryData.data.length} inventory items`);
            
            if (inventoryData.data.length > 0) {
              console.log('\n🎉 READY TO TEST INVENTORY UPDATE!');
              console.log('Use this account for testing:');
              console.log('Email: direct.api.test@example.com');
              console.log('Password: testpass123');
            } else {
              console.log('⚠️ No inventory items found for this account');
            }
          }
        }
      }
    } catch (error) {
      console.log('Account creation error:', error.message);
    }
    
  } catch (error) {
    console.error('❌ Test Error:', error);
  }
}

testServerBasics();
