import sql from "./src/db";

async function addFileColumn() {
  try {
    console.log("� Adding file_url column to complaints table...");
    
    await sql`
      ALTER TABLE complaints 
      ADD COLUMN IF NOT EXISTS file_url TEXT
    `;
    
    console.log("✅ file_url column added successfully!");
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    process.exit(0);
  }
}

addFileColumn();
