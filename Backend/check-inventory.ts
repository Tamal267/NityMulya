import sql from './src/db';

async function checkInventory() {
    try {
        console.log('=== Shop Inventory ===');
        const inventory = await sql`SELECT * FROM shop_inventory`;
        console.log(JSON.stringify(inventory, null, 2));
        
        console.log('\n=== Subcategories (first 3) ===');
        const subcats = await sql`SELECT * FROM subcategories LIMIT 3`;
        console.log(JSON.stringify(subcats, null, 2));
    } catch (error) {
        console.error('Error:', error);
    }
    process.exit(0);
}

checkInventory();
