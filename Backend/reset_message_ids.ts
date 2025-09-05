// Reset order_messages table ID sequence to start from 1
import postgres from "postgres";

const sql = postgres(process.env.DATABASE_URL!);

async function resetMessageIds() {
  try {
    console.log("🔧 Resetting order_messages table ID sequence...\n");

    // Show current data
    const currentMessages =
      await sql`SELECT * FROM order_messages ORDER BY id;`;
    console.log("📊 Current messages before reset:");
    currentMessages.forEach((msg: any) => {
      console.log(
        `ID: ${msg.id} - [${msg.sender_type}] ${msg.message_text.substring(
          0,
          50
        )}...`
      );
    });

    // Delete all messages to reset cleanly
    await sql`DELETE FROM order_messages;`;
    console.log("\n🗑️ All messages deleted");

    // Reset the ID sequence to start from 1
    await sql`ALTER SEQUENCE order_messages_id_seq RESTART WITH 1;`;
    console.log("🔄 ID sequence reset to start from 1");

    // Verify the reset
    const afterReset = await sql`SELECT * FROM order_messages;`;
    console.log("✅ Messages after reset:", afterReset.length);

    console.log(
      "\n🎉 ID sequence reset complete! Next message will have ID = 1"
    );
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    await sql.end();
  }
}

resetMessageIds();
