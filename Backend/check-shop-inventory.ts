import sql from "./db";

async function checkShopInventorySchema() {
  try {
    console.log("Checking shop_inventory table schema...");

    // Get table schema
    const schemaResult = await sql`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns 
      WHERE table_name = 'shop_inventory'
      ORDER BY ordinal_position;
    `;

    console.log("📋 shop_inventory table columns:");
    schemaResult.forEach((col) => {
      console.log(
        `  - ${col.column_name}: ${col.data_type} (nullable: ${col.is_nullable})`
      );
    });

    // Get sample data
    console.log("\n📊 Sample shop_inventory data:");
    const sampleData = await sql`
      SELECT * FROM shop_inventory LIMIT 3;
    `;

    if (sampleData.length > 0) {
      console.log("Columns:", Object.keys(sampleData[0]));
      sampleData.forEach((row, i) => {
        console.log(`Row ${i + 1}:`, row);
      });
    } else {
      console.log("No data found in shop_inventory table");
    }
  } catch (error) {
    console.error("Error:", error);
  }

  process.exit(0);
}

checkShopInventorySchema();
