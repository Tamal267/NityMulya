import dotenv from 'dotenv';
import postgres from 'postgres';

// Load environment variables
dotenv.config({ path: '.env.local' });

const sql = postgres({
  host: 'localhost',
  port: 5432,
  database: 'postgres',
  username: 'postgres',
  password: 'admin'
});

async function testWholesalerUsers() {
  try {
    console.log('🔍 Checking wholesaler users...');
    
    const wholesalers = await sql`
      SELECT id, username, full_name, email, role 
      FROM users 
      WHERE role = 'wholesaler' 
      LIMIT 5
    `;
    
    console.log('📊 Wholesaler users found:', wholesalers.length);
    wholesalers.forEach(user => {
      console.log(`  - ID: ${user.id}, Username: ${user.username}, Name: ${user.full_name}, Email: ${user.email}`);
    });
    
    if (wholesalers.length > 0) {
      console.log('\n🧪 Testing login for first wholesaler...');
      const firstWholesaler = wholesalers[0];
      console.log(`Testing login for: ${firstWholesaler.username}`);
      
      // Try to generate a token for testing
      const testData = {
        username: firstWholesaler.username,
        password: 'test123' // Common test password
      };
      
      console.log('Login data for testing:', testData);
    }
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await sql.end();
  }
}

testWholesalerUsers();
