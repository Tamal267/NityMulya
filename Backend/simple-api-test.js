// Simple test to check API connectivity and auth
const BASE_URL = 'http://localhost:5000'\;

async function testBasicAPI() {
  console.log('🧪 Testing basic API connectivity...\n');

  try {
    // Test 1: Health check
    console.log('📝 Step 1: Health check...');
    const healthResponse = await fetch(`${BASE_URL}/get_categories`);
    const healthResult = await healthResponse.json();
    console.log('Categories response status:', healthResponse.status);
    console.log('Categories available:', Array.isArray(healthResult) ? healthResult.length : 'Error');
    
    if (healthResponse.ok) {
      console.log('✅ API is accessible\n');
    } else {
      console.log('❌ API not accessible\n');
      return;
    }

    // Test 2: Try to add inventory without auth (should fail)
    console.log('📝 Step 2: Testing inventory endpoint without auth...');
    const noAuthResponse = await fetch(`${BASE_URL}/shop-owner/inventory`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        subcat_id: '1',
        stock_quantity: 10,
        unit_price: 280.00
      })
    });

    const noAuthResult = await noAuthResponse.json();
    console.log('No auth response status:', noAuthResponse.status);
    console.log('No auth response:', noAuthResult);
    
    if (noAuthResponse.status === 401) {
      console.log('✅ Auth protection working correctly\n');
    } else {
      console.log('❌ Auth protection might not be working\n');
    }

    // Test 3: Try with dummy credentials
    console.log('📝 Step 3: Testing with dummy login...');
    const loginResponse = await fetch(`${BASE_URL}/login/shop-owner`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'dummy@test.com',
        password: 'dummy123'
      })
    });

    const loginResult = await loginResponse.json();
    console.log('Dummy login response status:', loginResponse.status);
    console.log('Dummy login response:', loginResult);

    console.log('\n🎉 Basic API test completed!');
    console.log('\n💡 Next steps:');
    console.log('1. Use a real shop owner email/password to test authenticated endpoints');
    console.log('2. Check backend logs for any errors');
    console.log('3. Verify subcategory IDs exist in database');

  } catch (error) {
    console.error('❌ Test failed with error:', error);
  }
}

testBasicAPI();
