import sql from './src/db';

async function testInventoryQuery() {
    try {
        const shop_owner_id = '183ce7a8-c810-48dc-b52c-1176d5cefe0b';
        
        console.log('=== Testing Inventory Query ===');
        const inventory = await sql`
            SELECT 
                si.*,
                s.subcat_name,
                s.unit,
                c.cat_name,
                s.hindi_name,
                s.image_url
            FROM shop_inventory si
            JOIN subcategories s ON si.subcat_id = s.id
            JOIN categories c ON s.cat_id = c.id
            WHERE si.shop_owner_id = ${shop_owner_id}
            ORDER BY si.created_at DESC
        `;
        
        console.log('Query result:');
        console.log(JSON.stringify(inventory, null, 2));
    } catch (error) {
        console.error('Query Error:', error);
    }
    process.exit(0);
}

testInventoryQuery();
