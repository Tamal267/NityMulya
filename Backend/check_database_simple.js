// Simple script to check database state
const postgres = require('postgres');

// Load environment variables
require('dotenv').config();
const sql = postgres(process.env.DATABASE_URL);

async function checkDatabase() {
  try {
    console.log('🔍 Checking database state...\n');
    
    // Check categories
    console.log('1️⃣ Categories:');
    const categories = await sql`SELECT * FROM categories LIMIT 10`;
    console.log(`Found ${categories.length} categories`);
    categories.forEach(cat => {
      console.log(`  - ID: ${cat.id}, Name: ${cat.name}`);
    });
    
    // Check subcategories
    console.log('\n2️⃣ Subcategories:');
    const subcategories = await sql`SELECT * FROM subcategories LIMIT 10`;
    console.log(`Found ${subcategories.length} subcategories`);
    subcategories.forEach(sub => {
      console.log(`  - ID: ${sub.id}, Name: ${sub.name}, Category ID: ${sub.category_id}`);
    });
    
    // Check shop owners
    console.log('\n3️⃣ Shop Owners:');
    const shopOwners = await sql`SELECT id, email, full_name FROM shop_owners LIMIT 5`;
    console.log(`Found ${shopOwners.length} shop owners`);
    shopOwners.forEach(owner => {
      console.log(`  - ID: ${owner.id}, Name: ${owner.full_name}, Email: ${owner.email}`);
    });
    
    // Check shop inventory
    console.log('\n4️⃣ Shop Inventory:');
    const inventory = await sql`SELECT * FROM shop_inventory LIMIT 10`;
    console.log(`Found ${inventory.length} inventory items`);
    inventory.forEach(item => {
      console.log(`  - ID: ${item.id}, Shop Owner ID: ${item.shop_owner_id}, Subcat ID: ${item.subcat_id}, Stock: ${item.stock_quantity}`);
    });
    
    // If no subcategories, create some
    if (subcategories.length === 0) {
      console.log('\n🔧 No subcategories found. Creating sample data...');
      
      // First ensure we have categories
      if (categories.length === 0) {
        await sql`
          INSERT INTO categories (name, description) VALUES 
          ('Rice & Grains', 'Rice and other grains'),
          ('Oil & Ghee', 'Cooking oils and ghee'),
          ('Lentils', 'Various types of lentils')
        `;
        console.log('✅ Created sample categories');
      }
      
      // Create subcategories
      await sql`
        INSERT INTO subcategories (name, category_id, description) VALUES 
        ('Fine Rice', 1, 'High quality fine rice'),
        ('Soybean Oil', 2, 'Pure soybean cooking oil'),
        ('Red Lentils', 3, 'Red masoor dal')
      `;
      console.log('✅ Created sample subcategories');
    }
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Database Error:', error);
    process.exit(1);
  }
}

checkDatabase();
