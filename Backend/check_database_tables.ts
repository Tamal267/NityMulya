// Check what tables exist in the database
import postgres from "postgres";

const sql = postgres(process.env.DATABASE_URL!);

async function checkTables() {
  try {
    console.log("🔍 Checking what tables exist in the database...\n");

    const tables = await sql`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
      ORDER BY table_name;
    `;

    console.log("📋 Available tables:");
    tables.forEach((table, index) => {
      console.log(`${index + 1}. ${table.table_name}`);
    });

    // Check if we have customer and shop data
    console.log("\n📊 Checking data in key tables:");

    if (tables.some((t) => t.table_name === "customer_orders")) {
      const orderSample =
        await sql`SELECT order_id, customer_id, shop_id, shop_name FROM customer_orders LIMIT 3;`;
      console.log("\n🛒 Sample customer_orders:");
      orderSample.forEach((order) => {
        console.log(
          `  - Order: ${order.order_id}, Customer: ${order.customer_id}, Shop: ${order.shop_id} (${order.shop_name})`
        );
      });
    }

    if (tables.some((t) => t.table_name === "customers")) {
      const customerSample =
        await sql`SELECT id, full_name, email FROM customers LIMIT 3;`;
      console.log("\n👥 Sample customers:");
      customerSample.forEach((customer) => {
        console.log(
          `  - ID: ${customer.id}, Name: ${customer.full_name}, Email: ${customer.email}`
        );
      });
    }

    if (tables.some((t) => t.table_name === "shop_owners")) {
      const shopSample =
        await sql`SELECT id, shop_name, email FROM shop_owners LIMIT 3;`;
      console.log("\n🏪 Sample shop_owners:");
      shopSample.forEach((shop) => {
        console.log(
          `  - ID: ${shop.id}, Shop: ${shop.shop_name}, Email: ${shop.email}`
        );
      });
    }
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    await sql.end();
  }
}

checkTables();
