import postgres from 'postgres';
import { config } from 'dotenv';
import fs from 'fs';

config({ path: 'Backend/.env.local' });
const sql = postgres(process.env.DATABASE_URL);

async function exportAll() {
  try {
    const records = await sql`
      SELECT 
        c.customer_id, c.customer_name, c.shop_name, 
        s.subcat_name, c.complaint_description, 
        c.validity, c.priority, c.complaint_score, c.complaint_classification
      FROM complaints c
      LEFT JOIN subcategories s ON c.subcategory_id = s.id
    `;
    
    // Add escaping for description properly
    const csvHeader = 'customer_id,customer_name,shop_name,subcategory_name,complaint_description,validity,priority,complaint_score,complaint_classification\n';
    const csvRows = records.map(r => {
      const desc = r.complaint_description ? r.complaint_description.replace(/"/g, '""').replace(/\n/g, ' ') : '';
      return `"${r.customer_id}","${r.customer_name}","${r.shop_name}","${r.subcat_name}","${desc}",${r.validity},${r.priority},${r.complaint_score},"${r.complaint_classification}"`;
    }).join('\n');
    
    fs.writeFileSync('ML_Model_Training/data/complaints_full.csv', csvHeader + csvRows);
    console.log('✅ Exported all ' + records.length + ' records to ML_Model_Training/data/complaints_full.csv');
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await sql.end();
  }
}
exportAll();
