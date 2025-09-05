const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'nitymulya',
  password: 'shanto321',
  port: 5432,
});

async function testMessagesTable() {
  try {
    console.log('🔍 Checking if order_messages table exists...');
    
    // Check if table exists
    const checkTableQuery = `
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'order_messages'
      );
    `;
    
    const tableExists = await pool.query(checkTableQuery);
    console.log('Table exists:', tableExists.rows[0].exists);
    
    if (!tableExists.rows[0].exists) {
      console.log('📝 Creating order_messages table...');
      
      const createTableQuery = `
        CREATE TABLE order_messages (
          id SERIAL PRIMARY KEY,
          order_id VARCHAR(255) NOT NULL,
          customer_id VARCHAR(255) NOT NULL,
          shop_owner_id VARCHAR(255) NOT NULL,
          sender_type VARCHAR(20) NOT NULL CHECK (sender_type IN ('customer', 'shop_owner')),
          message TEXT NOT NULL,
          timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          is_read BOOLEAN DEFAULT FALSE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      `;
      
      await pool.query(createTableQuery);
      console.log('✅ order_messages table created successfully');
    }
    
    // Test inserting a sample message
    console.log('📝 Testing message insertion...');
    const insertQuery = `
      INSERT INTO order_messages (order_id, customer_id, shop_owner_id, sender_type, message)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *;
    `;
    
    const result = await pool.query(insertQuery, [
      'test_order_123',
      'test_customer',
      'test_shop_owner', 
      'shop_owner',
      'Test message from shop owner'
    ]);
    
    console.log('✅ Message inserted:', result.rows[0]);
    
    // Test fetching messages
    console.log('📖 Testing message retrieval...');
    const fetchQuery = `
      SELECT * FROM order_messages 
      WHERE customer_id = $1 
      ORDER BY timestamp DESC;
    `;
    
    const messages = await pool.query(fetchQuery, ['test_customer']);
    console.log('✅ Messages found:', messages.rows.length);
    console.log('Messages:', messages.rows);
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await pool.end();
  }
}

testMessagesTable();
