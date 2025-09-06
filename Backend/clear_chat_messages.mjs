import sql from './src/db.js';

async function clearChatMessages() {
  try {
    console.log('Clearing chat messages...');
    
    // Check current count
    const countResult = await sql`SELECT COUNT(*) as count FROM chat_messages`;
    console.log(`Current messages count: ${countResult[0].count}`);
    
    // Clear all messages
    const deleteResult = await sql`DELETE FROM chat_messages`;
    console.log(`✅ Cleared ${deleteResult.count} messages from chat_messages table`);
    
    console.log('Chat messages table is now empty');
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
  
  process.exit(0);
}

clearChatMessages();
