import sql from './src/db';

async function checkSchema() {
    try {
        console.log('=== Subcategories Schema ===');
        const schema = await sql`
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'subcategories'
        `;
        console.log(JSON.stringify(schema, null, 2));
        
        console.log('\n=== Sample Subcategory Record ===');
        const sample = await sql`SELECT * FROM subcategories LIMIT 1`;
        console.log(JSON.stringify(sample[0], null, 2));
    } catch (error) {
        console.error('Error:', error);
    }
    process.exit(0);
}

checkSchema();
