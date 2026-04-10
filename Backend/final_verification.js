import postgres from 'postgres';
import { config } from 'dotenv';

config({ path: '.env.local' });

const sql = postgres(process.env.DATABASE_URL);

async function finalVerification() {
  try {
    console.log('╔════════════════════════════════════════════════════════════════════════╗');
    console.log('║     COMPLAINTS DATASET - FINAL VERIFICATION & SUMMARY                 ║');
    console.log('╚════════════════════════════════════════════════════════════════════════╝\n');
    
    // Overall summary
    const summary = await sql`
      SELECT 
        COUNT(*) as total_records,
        COUNT(DISTINCT customer_id) as unique_customers,
        COUNT(DISTINCT shop_id) as unique_shops,
        COUNT(DISTINCT subcategory_id) as unique_subcategories,
        MIN(created_at) as first_record,
        MAX(created_at) as last_record
      FROM complaints
    `;
    
    console.log('📊 DATASET SUMMARY');
    console.log('═'.repeat(75));
    console.log(`Total Records:          ${summary[0].total_records}`);
    console.log(`Unique Customers:       ${summary[0].unique_customers}`);
    console.log(`Unique Shops:           ${summary[0].unique_shops}`);
    console.log(`Subcategories Covered:  ${summary[0].unique_subcategories}`);
    console.log(`Created:                ${summary[0].first_record.toISOString().split('T')[0]}\n`);
    
    // Language examples
    console.log('🌐 LANGUAGE DIVERSITY SAMPLES');
    console.log('═'.repeat(75));
    
    // Pure Bangla
    const bangla = await sql`
      SELECT complaint_description, complaint_score, complaint_classification
      FROM complaints
      WHERE complaint_description ~ '^[আ-ৰ ]+[।]'
      LIMIT 3
    `;
    console.log('\n1️⃣  BANGLA (বাংলা):');
    bangla.forEach((c, i) => {
      console.log(`   [${i+1}] ${c.complaint_description.substring(0, 70)}...`);
      console.log(`       Score: ${c.complaint_score} | Class: ${c.complaint_classification.toUpperCase()}\n`);
    });
    
    // Pure English
    const english = await sql`
      SELECT complaint_description, complaint_score, complaint_classification
      FROM complaints
      WHERE complaint_description ~ '^[A-Z][a-z]+ '
        AND complaint_description !~ '[আ-ৰ]'
      LIMIT 3
    `;
    console.log('2️⃣  ENGLISH:');
    english.forEach((c, i) => {
      console.log(`   [${i+1}] ${c.complaint_description.substring(0, 70)}...`);
      console.log(`       Score: ${c.complaint_score} | Class: ${c.complaint_classification.toUpperCase()}\n`);
    });
    
    // Banglish
    const banglish = await sql`
      SELECT complaint_description, complaint_score, complaint_classification
      FROM complaints
      WHERE complaint_description ~ '[আ-ৰ]'
        AND complaint_description ~ ' [a-z]+ '
      LIMIT 3
    `;
    console.log('3️⃣  BANGLISH (মিশ্র):');
    banglish.forEach((c, i) => {
      console.log(`   [${i+1}] ${c.complaint_description.substring(0, 70)}...`);
      console.log(`       Score: ${c.complaint_score} | Class: ${c.complaint_classification.toUpperCase()}\n`);
    });
    
    // Classification breakdown
    console.log('📈 CLASSIFICATION BREAKDOWN');
    console.log('═'.repeat(75));
    const breakdown = await sql`
      SELECT 
        complaint_classification,
        COUNT(*) as count,
        ROUND((COUNT(*) * 100.0 / 500)::numeric, 1) as percentage,
        ROUND(MIN(complaint_score)::numeric, 2) as min,
        ROUND(MAX(complaint_score)::numeric, 2) as max,
        ROUND(AVG(complaint_score)::numeric, 2) as avg
      FROM complaints
      GROUP BY complaint_classification
      ORDER BY 
        CASE complaint_classification
          WHEN 'high' THEN 1
          WHEN 'medium' THEN 2
          WHEN 'weak' THEN 3
        END
    `;
    breakdown.forEach(b => {
      const bar = '█'.repeat(Math.round(parseFloat(b.percentage) / 2));
      console.log(`\n${b.complaint_classification.toUpperCase().padEnd(10)} │ ${bar} ${b.percentage}%`);
      console.log(`           │ Count: ${b.count} | Score: ${b.min}-${b.max} (avg: ${b.avg})`);
    });
    
    // Feature statistics
    console.log('\n\n🎯 FEATURE STATISTICS');
    console.log('═'.repeat(75));
    const features = await sql`
      SELECT 
        ROUND(AVG(validity)::numeric, 3) as avg_validity,
        ROUND(STDDEV(validity)::numeric, 3) as std_validity,
        ROUND(AVG(priority)::numeric, 3) as avg_priority,
        ROUND(STDDEV(priority)::numeric, 3) as std_priority,
        ROUND(AVG(complaint_score)::numeric, 3) as avg_score,
        ROUND(STDDEV(complaint_score)::numeric, 3) as std_score
      FROM complaints
    `;
    const f = features[0];
    console.log(`Validity:  Mean=${f.avg_validity}, StdDev=${f.std_validity}`);
    console.log(`Priority:  Mean=${f.avg_priority}, StdDev=${f.std_priority}`);
    console.log(`Score:     Mean=${f.avg_score}, StdDev=${f.std_score}`);
    
    // Sample high-priority cases
    console.log('\n\n⚠️  HIGH-PRIORITY CASES (Top 5)');
    console.log('═'.repeat(75));
    const highPriority = await sql`
      SELECT 
        customer_name,
        shop_name,
        complaint_description,
        validity,
        priority,
        complaint_score
      FROM complaints
      WHERE complaint_classification = 'high'
      ORDER BY complaint_score DESC
      LIMIT 5
    `;
    highPriority.forEach((c, i) => {
      console.log(`\n[${i+1}] Customer: ${c.customer_name} → Shop: ${c.shop_name}`);
      console.log(`    ${c.complaint_description.substring(0, 65)}...`);
      console.log(`    Validity: ${c.validity} | Priority: ${c.priority} | Score: ${c.complaint_score}`);
    });
    
    console.log('\n\n✅ DATASET QUALITY CHECKS');
    console.log('═'.repeat(75));
    
    // Check for nulls
    const nullCheck = await sql`
      SELECT 
        SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) as null_customer_id,
        SUM(CASE WHEN subcategory_id IS NULL THEN 1 ELSE 0 END) as null_subcat,
        SUM(CASE WHEN validity IS NULL THEN 1 ELSE 0 END) as null_validity,
        SUM(CASE WHEN priority IS NULL THEN 1 ELSE 0 END) as null_priority,
        SUM(CASE WHEN complaint_score IS NULL THEN 1 ELSE 0 END) as null_score
      FROM complaints
    `;
    console.log(`✓ NULL values check:    ${Object.values(nullCheck[0]).every(v => v === 0 || v === '0') ? 'PASSED' : 'FAILED'}`);
    
    // Check score validity
    const scoreCheck = await sql`
      SELECT COUNT(*) as invalid_scores
      FROM complaints
      WHERE validity < 0 OR validity > 1
        OR priority < 0 OR priority > 1
        OR complaint_score < 0 OR complaint_score > 1
    `;
    console.log(`✓ Score range (0-1):    ${scoreCheck[0].invalid_scores === 0 || scoreCheck[0].invalid_scores === '0' ? 'PASSED' : 'FAILED'}`);
    
    // Check foreign keys
    const fkCheck = await sql`
      SELECT COUNT(*) as orphan_records
      FROM complaints c
      LEFT JOIN subcategories s ON c.subcategory_id = s.id
      WHERE s.id IS NULL
    `;
    console.log(`✓ Foreign key integrity: ${fkCheck[0].orphan_records === 0 || fkCheck[0].orphan_records === '0' ? 'PASSED' : 'FAILED'}`);
    
    // Check classification logic
    const classCheck = await sql`
      SELECT COUNT(*) as misclassified
      FROM complaints
      WHERE (complaint_score >= 0.7 AND complaint_classification != 'high')
         OR (complaint_score >= 0.4 AND complaint_score < 0.7 AND complaint_classification != 'medium')
         OR (complaint_score < 0.4 AND complaint_classification != 'weak')
    `;
    console.log(`✓ Classification logic:  ${classCheck[0].misclassified === 0 || classCheck[0].misclassified === '0' ? 'PASSED' : 'FAILED'}`);
    
    console.log('\n' + '═'.repeat(75));
    console.log('🎉 DATASET CREATION COMPLETE!');
    console.log('═'.repeat(75));
    console.log('\n📁 Files created:');
    console.log('   • Database table: complaints (500 records)');
    console.log('   • Documentation: COMPLAINTS_DATASET_README.md');
    console.log('   • Sample CSV: complaints_sample.csv');
    console.log('\n📊 Ready for thesis research and analysis!\n');
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await sql.end();
  }
}

finalVerification();
