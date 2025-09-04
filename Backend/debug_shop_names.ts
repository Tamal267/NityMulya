import sql from "./src/db";

async function debugShopNames() {
  console.log("🔍 Debugging shop name issues...");

  try {
    // Check customer_orders table structure and data
    console.log("\n1. Customer orders with shop_owner_id:");
    const orders = await sql`
      SELECT 
        order_number,
        shop_owner_id,
        shop_name,
        created_at
      FROM customer_orders 
      ORDER BY created_at DESC
      LIMIT 10
    `;

    orders.forEach((order) => {
      console.log(
        `   Order: ${order.order_number}, Shop ID: ${
          order.shop_owner_id
        }, Shop Name: ${order.shop_name || "NULL"}`
      );
    });

    // Check shop_owners table
    console.log("\n2. Shop owners data:");
    const shopOwners = await sql`
      SELECT id, name, contact, address
      FROM shop_owners
      ORDER BY id
      LIMIT 10
    `;

    shopOwners.forEach((shop) => {
      console.log(
        `   Shop ID: ${shop.id}, Name: ${shop.name || "NULL"}, Contact: ${
          shop.contact || "NULL"
        }`
      );
    });

    // Check the join to see what's happening
    console.log("\n3. Join analysis:");
    const joinAnalysis = await sql`
      SELECT 
        co.order_number,
        co.shop_owner_id,
        co.shop_name as stored_shop_name,
        so.id as shop_id,
        so.name as shop_owner_name,
        so.contact as shop_contact
      FROM customer_orders co
      LEFT JOIN shop_owners so ON co.shop_owner_id = so.id
      WHERE co.shop_name IS NULL
      LIMIT 5
    `;

    joinAnalysis.forEach((result) => {
      console.log(`   Order: ${result.order_number}`);
      console.log(`     Customer Order Shop ID: ${result.shop_owner_id}`);
      console.log(`     Shop Owner ID Found: ${result.shop_id || "NULL"}`);
      console.log(`     Shop Owner Name: ${result.shop_owner_name || "NULL"}`);
      console.log(`     Shop Contact: ${result.shop_contact || "NULL"}`);
      console.log("");
    });

    // Check for data type mismatches
    console.log("\n4. Data type analysis:");
    const typeAnalysis = await sql`
      SELECT 
        column_name, 
        data_type, 
        is_nullable
      FROM information_schema.columns 
      WHERE table_name IN ('customer_orders', 'shop_owners') 
        AND column_name IN ('id', 'shop_owner_id')
      ORDER BY table_name, column_name
    `;

    typeAnalysis.forEach((col) => {
      console.log(
        `   ${col.column_name}: ${col.data_type} (nullable: ${col.is_nullable})`
      );
    });
  } catch (error) {
    console.error("❌ Error debugging:", error);
  }
}

debugShopNames();
