import sql from "./src/db.js";

// Test and apply the shop details migration
async function runShopDetailsMigration() {
  console.log("🔧 Running Shop Details Migration");
  console.log("=" * 50);

  try {
    // Check if columns already exist
    console.log("\n1. Checking current table structure...");
    
    const columnCheck = await sql`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'customer_orders' 
        AND column_name IN ('shop_name', 'shop_phone', 'shop_address')
    `;
    
    console.log(`   Found ${columnCheck.length} shop detail columns`);
    
    if (columnCheck.length < 3) {
      console.log("\n2. Adding shop detail columns...");
      
      // Add columns if they don't exist
      await sql`
        ALTER TABLE customer_orders 
        ADD COLUMN IF NOT EXISTS shop_name VARCHAR(255),
        ADD COLUMN IF NOT EXISTS shop_phone VARCHAR(20),
        ADD COLUMN IF NOT EXISTS shop_address TEXT
      `;
      
      console.log("   ✅ Shop detail columns added");
    } else {
      console.log("   ✅ Shop detail columns already exist");
    }

    // Update existing records
    console.log("\n3. Updating existing orders with shop details...");
    
    const updateResult = await sql`
      UPDATE customer_orders 
      SET 
          shop_name = so.name,
          shop_phone = so.contact,
          shop_address = so.address
      FROM shop_owners so 
      WHERE customer_orders.shop_owner_id = so.id
        AND (customer_orders.shop_name IS NULL OR customer_orders.shop_name = '')
    `;
    
    console.log(`   ✅ Updated ${updateResult.count || 0} orders with shop details`);

    // Create index
    console.log("\n4. Creating index...");
    
    await sql`
      CREATE INDEX IF NOT EXISTS idx_customer_orders_shop_name 
      ON customer_orders(shop_name)
    `;
    
    console.log("   ✅ Index created");

    // Test the updated query
    console.log("\n5. Testing updated query...");
    
    const testQuery = await sql`
      SELECT 
          co.order_number,
          co.shop_name as direct_shop_name,
          so.name as joined_shop_name,
          COALESCE(co.shop_name, so.name, 'Unknown Shop') as final_shop_name
      FROM customer_orders co
      LEFT JOIN shop_owners so ON co.shop_owner_id = so.id
      LIMIT 5
    `;
    
    console.log("   Sample results:");
    testQuery.forEach((order, index) => {
      console.log(`   ${index + 1}. Order: ${order.order_number}`);
      console.log(`      Direct: ${order.direct_shop_name || 'NULL'}`);
      console.log(`      Joined: ${order.joined_shop_name || 'NULL'}`);
      console.log(`      Final: ${order.final_shop_name}`);
    });

    console.log("\n✅ Migration completed successfully!");

  } catch (error) {
    console.error("\n❌ Migration failed:", error);
    throw error;
  }
}

// Run the migration
runShopDetailsMigration()
  .then(() => {
    console.log("\n🎉 All done! Shop names should now display correctly.");
    process.exit(0);
  })
  .catch((error) => {
    console.error("\n💥 Error:", error);
    process.exit(1);
  });
