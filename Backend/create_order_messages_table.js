const postgres = require('postgres');

const sql = postgres(process.env.DATABASE_URL || {
  host: 'localhost',
  port: 5432,
  database: 'nitymulya_db',
  username: 'postgres',
  password: 'shanto321'
});

async function createOrderMessagesTable() {
  try {
    console.log('🔍 Checking if order_messages table exists...');
    
    // Check if table exists
    const tableExists = await sql`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'order_messages'
      );
    `;
    
    console.log('Table exists:', tableExists[0].exists);
    
    if (!tableExists[0].exists) {
      console.log('📝 Creating order_messages table...');
      
      await sql`
        CREATE TABLE order_messages (
          id SERIAL PRIMARY KEY,
          order_id VARCHAR(255) NOT NULL,
          sender_type VARCHAR(20) NOT NULL CHECK (sender_type IN ('customer', 'shop_owner')),
          sender_id VARCHAR(255) NOT NULL,
          receiver_type VARCHAR(20) NOT NULL CHECK (receiver_type IN ('customer', 'shop_owner')),
          receiver_id VARCHAR(255) NOT NULL,
          message_text TEXT NOT NULL,
          is_read BOOLEAN DEFAULT FALSE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      `;
      
      console.log('✅ order_messages table created successfully');
      
      // Create indexes for better performance
      await sql`CREATE INDEX idx_order_messages_order_id ON order_messages(order_id);`;
      await sql`CREATE INDEX idx_order_messages_sender ON order_messages(sender_id, sender_type);`;
      await sql`CREATE INDEX idx_order_messages_receiver ON order_messages(receiver_id, receiver_type);`;
      await sql`CREATE INDEX idx_order_messages_created_at ON order_messages(created_at);`;
      
      console.log('✅ Indexes created successfully');
    } else {
      console.log('✅ order_messages table already exists');
    }
    
    // Test inserting a sample message
    console.log('📝 Testing message insertion...');
    const result = await sql`
      INSERT INTO order_messages (
        order_id, 
        sender_type, 
        sender_id, 
        receiver_type, 
        receiver_id, 
        message_text
      ) VALUES (
        'ORD-2025-000031',
        'shop_owner',
        'shop_1',
        'customer', 
        'test_customer',
        'Your order is being prepared. It will be ready in 30 minutes!'
      )
      RETURNING *;
    `;
    
    console.log('✅ Message inserted:', result[0]);
    
    // Test fetching messages
    console.log('📖 Testing message retrieval...');
    const messages = await sql`
      SELECT * FROM order_messages 
      WHERE receiver_id = 'test_customer'
      ORDER BY created_at DESC;
    `;
    
    console.log('✅ Messages found:', messages.length);
    console.log('Messages:', messages);
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await sql.end();
  }
}

createOrderMessagesTable();
