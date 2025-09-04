import sql from "./src/db";

async function checkShopOwnersSchema() {
  try {
    console.log("Checking shop_owners table schema...");

    // Check table structure
    const columns = await sql`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'shop_owners' 
      AND table_schema = 'public'
      ORDER BY ordinal_position;
    `;

    console.log("📋 shop_owners table columns:");
    columns.forEach((col) => {
      console.log(`  - ${col.column_name}: ${col.data_type}`);
    });

    // Check if we have any shop_owners data
    const shopOwners = await sql`
      SELECT id, name, contact
      FROM shop_owners 
      LIMIT 3;
    `;

    console.log("📊 Sample shop_owners data:");
    shopOwners.forEach((shop) => {
      console.log(`  - ${shop.name}: ${shop.contact}`);
    });
  } catch (error) {
    console.error("❌ Error:", error.message);
  } finally {
    process.exit(0);
  }
}

checkShopOwnersSchema();
