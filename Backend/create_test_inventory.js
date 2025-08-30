// Create a special test endpoint to insert inventory directly
const { Pool } = require('pg');

// Database connection
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'nity_mulya',
  password: 'password',
  port: 5432,
});

async function createTestInventory() {
  console.log('🔧 CREATING TEST INVENTORY DIRECTLY...\n');
  
  try {
    // Get the shop owner ID
    const shopOwnerQuery = `
      SELECT id, full_name 
      FROM shop_owners 
      WHERE email = 'testshop2@example.com'
    `;
    
    const shopOwnerResult = await pool.query(shopOwnerQuery);
    
    if (shopOwnerResult.rows.length === 0) {
      console.log('❌ Shop owner not found');
      return;
    }
    
    const shopOwner = shopOwnerResult.rows[0];
    console.log(`✅ Found shop owner: ${shopOwner.full_name} (ID: ${shopOwner.id})`);
    
    // Check if inventory already exists
    const existingQuery = `
      SELECT * FROM shop_inventory 
      WHERE shop_owner_id = $1
    `;
    
    const existingResult = await pool.query(existingQuery, [shopOwner.id]);
    console.log(`📦 Existing inventory items: ${existingResult.rows.length}`);
    
    if (existingResult.rows.length === 0) {
      // Create a test subcategory if needed
      console.log('\n🏗️ Creating test subcategory...');
      
      const categoryInsert = `
        INSERT INTO categories (category_name) 
        VALUES ('Test Food Category') 
        ON CONFLICT (category_name) DO NOTHING
        RETURNING id
      `;
      
      const categoryResult = await pool.query(categoryInsert);
      let categoryId = 1; // Default fallback
      
      if (categoryResult.rows.length > 0) {
        categoryId = categoryResult.rows[0].id;
      } else {
        // Get existing category
        const existingCat = await pool.query(`SELECT id FROM categories LIMIT 1`);
        if (existingCat.rows.length > 0) {
          categoryId = existingCat.rows[0].id;
        }
      }
      
      console.log(`✅ Using category ID: ${categoryId}`);
      
      // Create subcategory
      const subcatInsert = `
        INSERT INTO subcategories (subcat_name, category_id, min_price, max_price) 
        VALUES ('Test Rice', $1, 50.0, 100.0) 
        ON CONFLICT (subcat_name) DO NOTHING
        RETURNING id
      `;
      
      const subcatResult = await pool.query(subcatInsert, [categoryId]);
      let subcatId = 1; // Default fallback
      
      if (subcatResult.rows.length > 0) {
        subcatId = subcatResult.rows[0].id;
      } else {
        // Get existing subcategory
        const existingSubcat = await pool.query(`SELECT id FROM subcategories LIMIT 1`);
        if (existingSubcat.rows.length > 0) {
          subcatId = existingSubcat.rows[0].id;
        }
      }
      
      console.log(`✅ Using subcategory ID: ${subcatId}`);
      
      // Create inventory item
      console.log('\n📦 Creating test inventory item...');
      
      const inventoryInsert = `
        INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING id
      `;
      
      const inventoryResult = await pool.query(inventoryInsert, [
        shopOwner.id,
        subcatId,
        100,      // stock_quantity
        75.50,    // unit_price
        10        // low_stock_threshold
      ]);
      
      if (inventoryResult.rows.length > 0) {
        const itemId = inventoryResult.rows[0].id;
        console.log(`✅ Created inventory item with ID: ${itemId}`);
        
        // Verify the creation
        const verifyQuery = `
          SELECT si.*, s.subcat_name 
          FROM shop_inventory si
          JOIN subcategories s ON si.subcat_id = s.id
          WHERE si.id = $1
        `;
        
        const verifyResult = await pool.query(verifyQuery, [itemId]);
        
        if (verifyResult.rows.length > 0) {
          const item = verifyResult.rows[0];
          console.log('\n📊 CREATED ITEM DETAILS:');
          console.log(`   ID: ${item.id}`);
          console.log(`   Product: ${item.subcat_name}`);
          console.log(`   Quantity: ${item.stock_quantity} units`);
          console.log(`   Price: ৳${item.unit_price}`);
          console.log(`   Threshold: ${item.low_stock_threshold}`);
          
          console.log('\n🎉 TEST DATA READY!');
          console.log('✅ Shop owner has inventory to test with');
          console.log('✅ Flutter app can now load and update items');
          console.log('✅ "3 dots" → Edit functionality will work');
        }
      } else {
        console.log('❌ Failed to create inventory item');
      }
    } else {
      console.log('\n📦 EXISTING INVENTORY FOUND:');
      existingResult.rows.forEach((item, index) => {
        console.log(`   ${index + 1}. ID: ${item.id}, Quantity: ${item.stock_quantity}, Price: ৳${item.unit_price}`);
      });
      console.log('\n✅ Ready for testing with existing data');
    }
    
  } catch (error) {
    console.error('💥 Database error:', error);
  } finally {
    await pool.end();
  }
}

createTestInventory();
