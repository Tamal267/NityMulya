import sql from "./src/db";

async function fixShopNames() {
  console.log("🔧 Fixing NULL shop names in customer_orders table...");

  try {
    // Step 1: Add columns if they don't exist
    console.log("1. Adding shop detail columns...");
    await sql`
      ALTER TABLE customer_orders 
      ADD COLUMN IF NOT EXISTS shop_name VARCHAR(255),
      ADD COLUMN IF NOT EXISTS shop_phone VARCHAR(20),
      ADD COLUMN IF NOT EXISTS shop_address TEXT
    `;
    console.log("   ✅ Columns added/verified");

    // Step 2: Check current state
    console.log("2. Checking current orders with NULL shop names...");
    const nullShopNames = await sql`
      SELECT COUNT(*) as count 
      FROM customer_orders 
      WHERE shop_name IS NULL OR shop_name = ''
    `;
    console.log(
      `   Found ${nullShopNames[0].count} orders with NULL/empty shop names`
    );

    // Step 3: Update orders with shop details
    console.log("3. Updating orders with shop details from shop_owners...");
    const updateResult = await sql`
      UPDATE customer_orders 
      SET 
          shop_name = so.full_name,
          shop_phone = so.contact,
          shop_address = so.address
      FROM shop_owners so 
      WHERE customer_orders.shop_owner_id = so.id
    `;
    console.log(
      `   ✅ Updated ${updateResult.count || "unknown number of"} orders`
    );

    // Step 4: Verify the fix
    console.log("4. Verifying the fix...");
    const afterUpdate = await sql`
      SELECT COUNT(*) as count 
      FROM customer_orders 
      WHERE shop_name IS NULL OR shop_name = ''
    `;
    console.log(`   Remaining NULL shop names: ${afterUpdate[0].count}`);

    // Step 5: Show sample results
    console.log("5. Sample updated orders:");
    const sampleOrders = await sql`
      SELECT 
          co.order_number,
          co.shop_name,
          co.shop_phone,
          so.full_name as original_name
      FROM customer_orders co
      LEFT JOIN shop_owners so ON co.shop_owner_id = so.id
      LIMIT 5
    `;

    sampleOrders.forEach((order, index) => {
      console.log(`   ${index + 1}. Order: ${order.order_number}`);
      console.log(`      Shop Name: ${order.shop_name || "NULL"}`);
      console.log(`      Shop Phone: ${order.shop_phone || "NULL"}`);
      console.log(`      Original: ${order.original_name || "NULL"}`);
      console.log("");
    });

    console.log("✅ Shop names migration completed successfully!");
  } catch (error) {
    console.error("❌ Error fixing shop names:", error);
    throw error;
  }
}

// Run the fix
fixShopNames()
  .then(() => {
    console.log(
      "\n🎉 Migration completed! Shop names should now display properly in My Orders."
    );
    process.exit(0);
  })
  .catch((error) => {
    console.error("\n💥 Migration failed:", error);
    process.exit(1);
  });
