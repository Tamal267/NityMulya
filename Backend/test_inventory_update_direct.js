// Test inventory update with existing data
require('dotenv').config();
const postgres = require('postgres');

const sql = postgres(process.env.DATABASE_URL);

async function testInventoryUpdate() {
  try {
    console.log('🧪 Testing Shop Owner Inventory Update...\n');
    
    // First, let's check the actual table structure
    console.log('1️⃣ Checking table structures...');
    
    // Check categories table structure
    const catCols = await sql`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'categories'
      ORDER BY ordinal_position
    `;
    console.log('Categories columns:', catCols);
    
    // Check subcategories table structure
    const subCatCols = await sql`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'subcategories'
      ORDER BY ordinal_position
    `;
    console.log('Subcategories columns:', subCatCols);
    
    // Get a sample category with all columns
    const sampleCat = await sql`SELECT * FROM categories LIMIT 1`;
    console.log('Sample category:', sampleCat[0]);
    
    // Get a sample subcategory with all columns
    const sampleSubCat = await sql`SELECT * FROM subcategories LIMIT 1`;
    console.log('Sample subcategory:', sampleSubCat[0]);
    
    // Now test the inventory update
    console.log('\n2️⃣ Testing inventory update...');
    
    // Get an existing inventory item
    const inventory = await sql`
      SELECT si.*, sc.subcat_name as subcat_name, c.cat_name as cat_name 
      FROM shop_inventory si
      LEFT JOIN subcategories sc ON si.subcat_id = sc.id
      LEFT JOIN categories c ON sc.cat_id = c.id
      LIMIT 1
    `;
    
    if (inventory.length === 0) {
      console.log('❌ No inventory items found');
      return;
    }
    
    const item = inventory[0];
    console.log('Testing with item:', {
      id: item.id,
      shop_owner_id: item.shop_owner_id,
      current_stock: item.stock_quantity,
      current_price: item.unit_price
    });
    
    // Try to update the inventory
    const newQuantity = item.stock_quantity + 10;
    const newPrice = (item.unit_price || 100) + 5;
    
    console.log(`Updating stock from ${item.stock_quantity} to ${newQuantity}`);
    console.log(`Updating price from ${item.unit_price} to ${newPrice}`);
    
    const updateResult = await sql`
      UPDATE shop_inventory 
      SET 
        stock_quantity = ${newQuantity},
        unit_price = ${newPrice},
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ${item.id}
      RETURNING *
    `;
    
    if (updateResult.length > 0) {
      console.log('✅ INVENTORY UPDATE SUCCESSFUL!');
      console.log('Updated item:', {
        id: updateResult[0].id,
        new_stock: updateResult[0].stock_quantity,
        new_price: updateResult[0].unit_price
      });
      
      // Test the API endpoint simulation
      console.log('\n3️⃣ Testing API format...');
      console.log('This is what the shop owner update API should receive:');
      console.log(JSON.stringify({
        id: item.id,
        stock_quantity: newQuantity,
        unit_price: newPrice,
        low_stock_threshold: item.low_stock_threshold
      }, null, 2));
    } else {
      console.log('❌ Update failed - no rows returned');
    }
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

testInventoryUpdate();
