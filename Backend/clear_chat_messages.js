const { Client } = require('pg');

async function clearChatMessages() {
  const client = new Client(process.env.DATABASE_URL || 'postgresql://postgres.xogshdgdgygihvfpezez:@5P8aO4o@Q8GDKAq@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres');
  
  try {
    await client.connect();
    console.log('Connected to database');
    
    // Check current structure
    const result = await client.query('SELECT COUNT(*) FROM chat_messages');
    console.log(`Current messages count: ${result.rows[0].count}`);
    
    // Clear all messages
    const deleteResult = await client.query('DELETE FROM chat_messages');
    console.log(`Deleted ${deleteResult.rowCount} messages`);
    
    console.log('✅ Chat messages table cleared successfully');
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await client.end();
  }
}

clearChatMessages();
