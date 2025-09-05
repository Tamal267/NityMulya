// Test the messaging query directly
import postgres from "postgres";

const sql = postgres(process.env.DATABASE_URL!);

async function testMessageQuery() {
  try {
    console.log("🔍 Testing message query directly...\n");

    const customer_id = "a4e43c54-30b7-4e5a-8d84-276071423e30";

    console.log("📋 Testing simple query...");
    const messages = await sql`
      SELECT 
        order_id,
        sender_type,
        sender_id,
        receiver_type,
        receiver_id,
        message_text,
        is_read,
        created_at
      FROM order_messages 
      WHERE sender_id::varchar = ${customer_id} OR receiver_id::varchar = ${customer_id}
      ORDER BY created_at DESC
    `;

    console.log("✅ Query executed successfully!");
    console.log("📊 Messages found:", messages.length);
    console.log("Messages:", messages);

    // Test sending a message
    console.log("\n📝 Testing message insertion...");
    const newMessage = await sql`
      INSERT INTO order_messages (
        order_id, 
        sender_type, 
        sender_id, 
        receiver_type, 
        receiver_id, 
        message_text
      ) VALUES (
        'ORD-2025-000032',
        'customer',
        ${customer_id}::uuid,
        'shop_owner', 
        '175ebb5a-3de5-457a-a21d-39873e8ac334'::uuid,
        'When will my order be ready?'
      )
      RETURNING *;
    `;

    console.log("✅ Message sent:", newMessage[0]);

    // Test the query again
    console.log("\n📖 Testing query again after insertion...");
    const updatedMessages = await sql`
      SELECT * FROM order_messages 
      WHERE sender_id::varchar = ${customer_id} OR receiver_id::varchar = ${customer_id}
      ORDER BY created_at DESC
    `;

    console.log("✅ Updated messages count:", updatedMessages.length);
    updatedMessages.forEach((msg, index) => {
      console.log(
        `${index + 1}. [${msg.sender_type}] ${msg.message_text} (${
          msg.created_at
        })`
      );
    });
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    await sql.end();
  }
}

testMessageQuery();
