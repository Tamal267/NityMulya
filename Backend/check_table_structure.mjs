import sql from './src/db.js';

console.log('📋 Checking chat_messages table structure...');

try {
  const result = await sql`
    SELECT column_name, data_type, is_nullable
    FROM information_schema.columns 
    WHERE table_name = 'chat_messages'
    ORDER BY ordinal_position
  `;
  
  console.log('Table structure:');
  result.forEach(col => {
    console.log(`- ${col.column_name}: ${col.data_type} ${col.is_nullable === 'YES' ? '(nullable)' : '(not null)'}`);
  });
  
  // Also check if table exists and get sample data
  const count = await sql`SELECT COUNT(*) as count FROM chat_messages`;
  console.log(`\nTotal records: ${count[0].count}`);
  
  if (count[0].count > 0) {
    const sample = await sql`SELECT * FROM chat_messages LIMIT 2`;
    console.log('\nSample data:');
    console.log(sample);
  }
  
} catch (error) {
  console.error('❌ Error:', error.message);
}

process.exit(0);
