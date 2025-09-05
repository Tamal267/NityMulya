// Test messaging with real shop owner and customer IDs
import postgres from "postgres";

const sql = postgres(process.env.DATABASE_URL!);

async function testRealMessaging() {
  try {
    console.log("🔍 Getting real shop owner and customer IDs...\n");

    // Get a real customer_order with customer and shop owner IDs
    const orders = await sql`
      SELECT 
        order_number,
        customer_id,
        shop_owner_id,
        shop_name
      FROM customer_orders 
      WHERE status = 'pending'
      LIMIT 3;
    `;

    console.log("📋 Available orders for testing:");
    orders.forEach((order: any, index: any) => {
      console.log(`${index + 1}. Order: ${order.order_number}`);
      console.log(`   Customer ID: ${order.customer_id}`);
      console.log(`   Shop Owner ID: ${order.shop_owner_id}`);
      console.log(`   Shop Name: ${order.shop_name}`);
      console.log("");
    });

    if (orders.length > 0) {
      const testOrder = orders[0];
      console.log("📝 Testing message insertion with real IDs...");

      const result = await sql`
        INSERT INTO order_messages (
          order_id, 
          sender_type, 
          sender_id, 
          receiver_type, 
          receiver_id, 
          message_text
        ) VALUES (
          ${testOrder.order_number},
          'shop_owner',
          ${testOrder.shop_owner_id},
          'customer', 
          ${testOrder.customer_id},
          'Hello! Your order is being prepared and will be ready soon.'
        )
        RETURNING *;
      `;

      console.log("✅ Test message inserted:", {
        id: result[0].id,
        order_id: result[0].order_id,
        sender_type: result[0].sender_type,
        message_text: result[0].message_text,
        created_at: result[0].created_at,
      });

      // Test fetching messages for this customer
      console.log("\n📖 Testing message retrieval for customer...");
      const customerMessages = await sql`
        SELECT * FROM order_messages 
        WHERE receiver_id = ${testOrder.customer_id}
        ORDER BY created_at DESC;
      `;

      console.log(`✅ Messages found for customer: ${customerMessages.length}`);
      customerMessages.forEach((msg: any, index: any) => {
        console.log(`${index + 1}. [${msg.sender_type}] ${msg.message_text}`);
      });
    } else {
      console.log("❌ No pending orders found for testing");
    }
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    await sql.end();
  }
}

testRealMessaging();
