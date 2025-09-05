// Test the GET messages endpoint directly
import postgres from "postgres";

const sql = postgres(process.env.DATABASE_URL!);

async function testGetMessages() {
  try {
    const customer_id = "a4e43c54-30b7-4e5a-8d84-276071423e30";

    console.log("🔍 Testing GET messages for customer:", customer_id);
    console.log("");

    // Test the exact query from the server
    console.log("📋 Running the same query as the server...");
    const conversations = await sql`
      SELECT * FROM order_messages 
      WHERE receiver_id::text = ${customer_id} OR sender_id::text = ${customer_id}
      ORDER BY created_at DESC
    `;

    console.log("✅ Query executed successfully!");
    console.log("📊 Messages found:", conversations.length);

    if (conversations.length > 0) {
      console.log("\n📋 Messages:");
      conversations.forEach((msg: any, index: any) => {
        console.log(`${index + 1}. ID: ${msg.id}`);
        console.log(`   Order: ${msg.order_id}`);
        console.log(`   From: ${msg.sender_type} (${msg.sender_id})`);
        console.log(`   To: ${msg.receiver_type} (${msg.receiver_id})`);
        console.log(`   Message: ${msg.message_text}`);
        console.log(`   Created: ${msg.created_at}`);
        console.log("");
      });
    }

    // Test with different casting approaches
    console.log("🔧 Testing with UUID casting...");
    const conversations2 = await sql`
      SELECT * FROM order_messages 
      WHERE receiver_id = ${customer_id}::uuid OR sender_id = ${customer_id}::uuid
      ORDER BY created_at DESC
    `;

    console.log("✅ UUID casting query result:", conversations2.length);
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    await sql.end();
  }
}

testGetMessages();
