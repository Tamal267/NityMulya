// Check the actual structure of customer_orders table
import postgres from "postgres";

const sql = postgres(process.env.DATABASE_URL!);

async function checkTableStructure() {
  try {
    console.log("🔍 Checking customer_orders table structure...\n");

    const columns = await sql`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns 
      WHERE table_name = 'customer_orders'
      ORDER BY ordinal_position;
    `;

    console.log("📋 customer_orders columns:");
    columns.forEach((col: any) => {
      console.log(
        `  - ${col.column_name}: ${col.data_type} (${
          col.is_nullable === "YES" ? "nullable" : "not null"
        })`
      );
    });

    console.log("\n🔍 Checking order_messages table structure...\n");

    const msgColumns = await sql`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns 
      WHERE table_name = 'order_messages'
      ORDER BY ordinal_position;
    `;

    console.log("📋 order_messages columns:");
    msgColumns.forEach((col: any) => {
      console.log(
        `  - ${col.column_name}: ${col.data_type} (${
          col.is_nullable === "YES" ? "nullable" : "not null"
        })`
      );
    });

    // Check some sample data
    console.log("\n📊 Sample customer_orders data:");
    const orders = await sql`SELECT * FROM customer_orders LIMIT 2;`;
    console.log(orders);
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    await sql.end();
  }
}

checkTableStructure();
