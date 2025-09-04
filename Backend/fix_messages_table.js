const { Client } = require('pg');

async function fixMessagesTable() {
  const client = new Client({
    user: 'postgres',
    host: 'localhost',
    database: 'nitymulya_db',
    password: 'nitymulya321',
    port: 5432,
  });

  try {
    await client.connect();
    
    console.log('🔄 Dropping existing order_messages table...');
    await client.query('DROP TABLE IF EXISTS order_messages CASCADE');
    
    console.log('🔄 Creating order_messages table with UUID support...');
    await client.query(`
      CREATE TABLE order_messages (
          id SERIAL PRIMARY KEY,
          order_id VARCHAR(255) NOT NULL,
          sender_type VARCHAR(20) NOT NULL CHECK (sender_type IN ('shop_owner', 'customer')),
          sender_id UUID NOT NULL,
          receiver_type VARCHAR(20) NOT NULL CHECK (receiver_type IN ('shop_owner', 'customer')),
          receiver_id UUID NOT NULL,
          message_text TEXT NOT NULL,
          is_read BOOLEAN DEFAULT FALSE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    console.log('🔄 Creating indexes...');
    await client.query('CREATE INDEX idx_order_messages_order_id ON order_messages(order_id)');
    await client.query('CREATE INDEX idx_order_messages_receiver ON order_messages(receiver_type, receiver_id)');
    await client.query('CREATE INDEX idx_order_messages_sender ON order_messages(sender_type, sender_id)');
    await client.query('CREATE INDEX idx_order_messages_created_at ON order_messages(created_at DESC)');
    
    console.log('✅ Table recreation completed successfully!');
    
    // Verify table structure
    const result = await client.query(`
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_name = 'order_messages'
      ORDER BY ordinal_position
    `);
    
    console.log('📋 New table structure:');
    result.rows.forEach(row => {
      console.log(`   ${row.column_name}: ${row.data_type}`);
    });
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
  }
}

fixMessagesTable();
