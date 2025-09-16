import sql from "./src/db";

async function addFileColumn() {
  try {
    console.log("Ì¥ß Adding file_url column to complaints table...");
    
    await sql`
      ALTER TABLE complaints 
      ADD COLUMN IF NOT EXISTS file_url TEXT
    `;
    
    console.log("‚úÖ file_url column added successfully!");
  } catch (error) {
    console.error("‚ùå Error:", error);
  } finally {
    process.exit(0);
  }
}

addFileColumn();
