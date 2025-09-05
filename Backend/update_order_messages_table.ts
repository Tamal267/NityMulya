// Update order_messages table to use UUIDs
import postgres from "postgres";

const sql = postgres(process.env.DATABASE_URL!);

async function updateOrderMessagesTable() {
  try {
    console.log("🔧 Updating order_messages table to use UUIDs...\n");

    // First, drop the table if it exists and recreate with correct data types
    await sql`DROP TABLE IF EXISTS order_messages;`;
    console.log("🗑️ Dropped existing order_messages table");

    // Create table with UUID data types for sender_id and receiver_id
    await sql`
      CREATE TABLE order_messages (
        id SERIAL PRIMARY KEY,
        order_id VARCHAR(255) NOT NULL,
        sender_type VARCHAR(20) NOT NULL CHECK (sender_type IN ('customer', 'shop_owner')),
        sender_id UUID NOT NULL,
        receiver_type VARCHAR(20) NOT NULL CHECK (receiver_type IN ('customer', 'shop_owner')),
        receiver_id UUID NOT NULL,
        message_text TEXT NOT NULL,
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `;

    console.log("✅ order_messages table created with UUID support");

    // Create indexes for better performance
    await sql`CREATE INDEX idx_order_messages_order_id ON order_messages(order_id);`;
    await sql`CREATE INDEX idx_order_messages_sender ON order_messages(sender_id, sender_type);`;
    await sql`CREATE INDEX idx_order_messages_receiver ON order_messages(receiver_id, receiver_type);`;
    await sql`CREATE INDEX idx_order_messages_created_at ON order_messages(created_at);`;

    console.log("✅ Indexes created successfully");

    // Insert a test message using actual UUIDs from customer_orders
    console.log("📝 Inserting test message with real UUIDs...");

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
        '175ebb5a-3de5-457a-a21d-39873e8ac334'::uuid,
        'customer', 
        'a4e43c54-30b7-4e5a-8d84-276071423e30'::uuid,
        'Your order is being prepared. It will be ready in 30 minutes!'
      )
      RETURNING *;
    `;

    console.log("✅ Test message inserted:", result[0]);

    console.log("🎉 order_messages table setup complete with UUID support!");
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    await sql.end();
  }
}

updateOrderMessagesTable();
