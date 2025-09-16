import sql from './src/db.js';

async function checkComplaintsSchema() {
  try {
    console.log('🔍 Checking complaints table schema...');
    
    // Get table structure
    const columns = await sql`
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns 
      WHERE table_name = 'complaints' 
      AND table_schema = 'public'
      ORDER BY ordinal_position;
    `;
    
    console.log('\n📋 Complaints Table Structure:');
    console.table(columns);
    
    // Check if file_url column exists
    const fileUrlColumn = columns.find(col => col.column_name === 'file_url');
    if (fileUrlColumn) {
      console.log('\n✅ file_url column exists:', fileUrlColumn);
    } else {
      console.log('\n❌ file_url column does not exist');
    }
    
    // Check current complaints with files
    const complaintsWithFiles = await sql`
      SELECT id, complaint_number, file_url, submitted_at 
      FROM complaints 
      WHERE file_url IS NOT NULL 
      ORDER BY submitted_at DESC 
      LIMIT 5;
    `;
    
    console.log('\n📁 Recent complaints with files:');
    console.table(complaintsWithFiles);
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    process.exit(0);
  }
}

checkComplaintsSchema();