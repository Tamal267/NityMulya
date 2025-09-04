import sql from "./src/db";

async function testDatabase() {
  try {
    console.log("Testing database connection...");

    // Test basic connection
    const result = await sql`SELECT NOW() as current_time`;
    console.log("✅ Database connected successfully");
    console.log("Current time:", result[0].current_time);

    // Check if customer_orders table exists
    const tableCheck = await sql`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'customer_orders'
      );
    `;

    if (tableCheck[0].exists) {
      console.log("✅ customer_orders table exists");

      // Count existing orders
      const orderCount =
        await sql`SELECT COUNT(*) as count FROM customer_orders`;
      console.log(`📊 Current orders in database: ${orderCount[0].count}`);

      // Show recent orders if any
      const recentOrders = await sql`
        SELECT order_number, status, created_at 
        FROM customer_orders 
        ORDER BY created_at DESC 
        LIMIT 5
      `;

      if (recentOrders.length > 0) {
        console.log("🔍 Recent orders:");
        recentOrders.forEach((order) => {
          console.log(
            `  - ${order.order_number}: ${order.status} (${order.created_at})`
          );
        });
      } else {
        console.log("📭 No orders found in database");
      }
    } else {
      console.log("❌ customer_orders table does not exist");
      console.log("Need to run schema setup");
    }
  } catch (error) {
    console.error("❌ Database error:", error);
  } finally {
    process.exit(0);
  }
}

testDatabase();
