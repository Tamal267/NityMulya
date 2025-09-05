// Clear all sample data from order_messages table
import postgres from "postgres";

const sql = postgres(process.env.DATABASE_URL!);

async function clearSampleData() {
  try {
    console.log("🗑️ Clearing all sample data from order_messages table...\n");

    // Show current data before deletion
    const beforeCount = await sql`SELECT COUNT(*) FROM order_messages;`;
    console.log("📊 Messages before deletion:", beforeCount[0].count);

    const allMessages =
      await sql`SELECT * FROM order_messages ORDER BY created_at DESC;`;
    console.log("\n📋 Current messages:");
    allMessages.forEach((msg: any, index: any) => {
      console.log(
        `${index + 1}. [${msg.sender_type}] ${msg.message_text} (${
          msg.created_at
        })`
      );
    });

    // Delete all sample data
    await sql`DELETE FROM order_messages;`;
    console.log("\n🗑️ All sample data deleted");

    // Reset the ID sequence
    await sql`ALTER SEQUENCE order_messages_id_seq RESTART WITH 1;`;
    console.log("🔄 ID sequence reset to start from 1");

    // Verify deletion
    const afterCount = await sql`SELECT COUNT(*) FROM order_messages;`;
    console.log("✅ Messages after deletion:", afterCount[0].count);

    console.log("\n🎉 Sample data cleanup complete!");
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    await sql.end();
  }
}

clearSampleData();
