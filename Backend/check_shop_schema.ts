import sql from "./src/db";

async function checkShopOwnersSchema() {
  console.log("🔍 Checking shop_owners table schema and data...");

  try {
    // Check all columns in shop_owners table
    console.log("\n1. Shop owners table schema:");
    const schema = await sql`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns 
      WHERE table_name = 'shop_owners'
      ORDER BY ordinal_position
    `;

    schema.forEach((col) => {
      console.log(
        `   ${col.column_name}: ${col.data_type} (nullable: ${col.is_nullable})`
      );
    });

    // Check actual data in shop_owners
    console.log("\n2. Sample shop owners data:");
    const shopData = await sql`
      SELECT *
      FROM shop_owners
      LIMIT 5
    `;

    shopData.forEach((shop, index) => {
      console.log(`   Shop ${index + 1}:`);
      Object.keys(shop).forEach((key) => {
        console.log(`     ${key}: ${shop[key] || "NULL"}`);
      });
      console.log("");
    });

    // Check users table to see if shop names are there
    console.log("\n3. Checking users table for shop owners:");
    const userData = await sql`
      SELECT 
        u.id as user_id,
        u.name as user_name,
        u.role,
        so.id as shop_owner_id,
        so.contact as shop_contact
      FROM users u
      LEFT JOIN shop_owners so ON u.id = so.id
      WHERE u.role = 'shop_owner'
      LIMIT 5
    `;

    userData.forEach((user, index) => {
      console.log(`   User ${index + 1}:`);
      console.log(`     User ID: ${user.user_id}`);
      console.log(`     User Name: ${user.user_name || "NULL"}`);
      console.log(`     Role: ${user.role}`);
      console.log(`     Shop Owner ID: ${user.shop_owner_id || "NULL"}`);
      console.log(`     Shop Contact: ${user.shop_contact || "NULL"}`);
      console.log("");
    });
  } catch (error) {
    console.error("❌ Error checking schema:", error);
  }
}

checkShopOwnersSchema();
