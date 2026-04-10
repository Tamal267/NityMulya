import postgres from 'postgres';
import { config } from 'dotenv';

config({ path: '.env.local' });

const sql = postgres(process.env.DATABASE_URL);

async function checkStructure() {
  try {
    // Get subcategories schema
    const schema = await sql`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'subcategories'
      ORDER BY ordinal_position
    `;
    console.log('Subcategories columns:', JSON.stringify(schema, null, 2));
    
    // Get some subcategories data
    const subcats = await sql`
      SELECT * 
      FROM subcategories 
      LIMIT 5
    `;
    console.log('\nSubcategories sample:', JSON.stringify(subcats, null, 2));
    
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await sql.end();
  }
}

checkStructure();
