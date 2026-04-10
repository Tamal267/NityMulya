import postgres from 'postgres';
import { config } from 'dotenv';
import fs from 'fs';

config({ path: '.env.local' });

const sql = postgres(process.env.DATABASE_URL);

async function exportSample() {
  try {
    // Get 20 diverse samples
    const samples = await sql`
      WITH classified_samples AS (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY complaint_classification ORDER BY RANDOM()) as rn
        FROM complaints
      )
      SELECT 
        customer_id,
        customer_name,
        shop_id,
        shop_name,
        s.subcat_name,
        cs.complaint_description,
        cs.validity,
        cs.priority,
        cs.complaint_score,
        cs.complaint_classification,
        s.min_price,
        s.max_price
      FROM classified_samples cs
      JOIN subcategories s ON cs.subcategory_id = s.id
      WHERE rn <= 7
      ORDER BY complaint_classification, complaint_score DESC
    `;
    
    console.log('=== SAMPLE COMPLAINT RECORDS (21 entries) ===\n');
    console.log('Each record shows the complete structure:\n');
    
    samples.forEach((record, idx) => {
      console.log(`\n[${idx + 1}] Classification: ${record.complaint_classification.toUpperCase()}`);
      console.log('─'.repeat(80));
      console.log(`Customer: ${record.customer_name} (${record.customer_id})`);
      console.log(`Shop: ${record.shop_name} (${record.shop_id})`);
      console.log(`Subcategory: ${record.subcat_name}`);
      console.log(`Price Range: ${record.min_price} - ${record.max_price} Taka`);
      console.log(`\nComplaint: ${record.complaint_description}`);
      console.log(`\nMetrics:`);
      console.log(`  • Validity: ${record.validity} (Price/quality validation)`);
      console.log(`  • Priority: ${record.priority} (Urgency level)`);
      console.log(`  • Score: ${record.complaint_score} (Combined metric)`);
      console.log(`  • Classification: ${record.complaint_classification}`);
    });
    
    // Create CSV export
    const csvHeader = 'customer_id,customer_name,shop_id,shop_name,subcategory_name,complaint_description,validity,priority,complaint_score,complaint_classification\n';
    const csvRows = samples.map(r => 
      `"${r.customer_id}","${r.customer_name}","${r.shop_id}","${r.shop_name}","${r.subcat_name}","${r.complaint_description.replace(/"/g, '""')}",${r.validity},${r.priority},${r.complaint_score},${r.complaint_classification}`
    ).join('\n');
    
    fs.writeFileSync('complaints_sample.csv', csvHeader + csvRows);
    console.log('\n\n✅ Sample exported to complaints_sample.csv');
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await sql.end();
  }
}

exportSample();
