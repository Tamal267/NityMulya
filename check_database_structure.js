const { sql } = require('./Backend/src/db.ts');

async function checkDatabaseStructure() {
  try {
    console.log('=== Checking Database Structure ===\n');

    // Check if subcategories table exists and has data
    console.log('1. Checking subcategories table:');
    const subcats = await sql`SELECT id, subcat_name FROM subcategories LIMIT 5`;
    console.log(`   Found ${subcats.length} subcategories:`);
    subcats.forEach(sub => console.log(`   - ${sub.id}: ${sub.subcat_name}`));
    console.log('');

    // Check shop owners
    console.log('2. Checking shop_owners table:');
    const shopOwners = await sql`SELECT id, email, full_name FROM shop_owners LIMIT 3`;
    console.log(`   Found ${shopOwners.length} shop owners:`);
    shopOwners.forEach(owner => console.log(`   - ${owner.id}: ${owner.email} (${owner.full_name})`));
    console.log('');

    // Check existing inventory
    console.log('3. Checking shop_inventory table:');
    const inventory = await sql`
      SELECT si.id, si.stock_quantity, si.unit_price, 
             so.email as shop_email, sc.subcat_name
      FROM shop_inventory si
      JOIN shop_owners so ON si.shop_owner_id = so.id
      JOIN subcategories sc ON si.subcat_id = sc.id
      LIMIT 5
    `;
    console.log(`   Found ${inventory.length} inventory items:`);
    inventory.forEach(item => console.log(`   - ${item.shop_email}: ${item.subcat_name} (${item.stock_quantity} units @ ${item.unit_price})`));
    console.log('');

    // Check if we can add a product with valid UUIDs
    if (subcats.length > 0 && shopOwners.length > 0) {
      console.log('4. Testing product addition with valid UUIDs:');
      const testSubcatId = subcats[0].id;
      const testShopOwnerId = shopOwners[0].id;
      
      console.log(`   Using subcategory: ${testSubcatId} (${subcats[0].subcat_name})`);
      console.log(`   Using shop owner: ${testShopOwnerId} (${shopOwners[0].email})`);
      
      // Check if this combination already exists
      const existing = await sql`
        SELECT * FROM shop_inventory 
        WHERE shop_owner_id = ${testShopOwnerId} AND subcat_id = ${testSubcatId}
      `;
      
      if (existing.length > 0) {
        console.log('   This product already exists in inventory - perfect for testing updates!');
        console.log(`   Current quantity: ${existing[0].stock_quantity}, price: ${existing[0].unit_price}`);
      } else {
        console.log('   This combination does not exist - would need to add first');
      }
    }

  } catch (error) {
    console.error('Error checking database:', error.message);
  }
  
  process.exit();
}

checkDatabaseStructure();
