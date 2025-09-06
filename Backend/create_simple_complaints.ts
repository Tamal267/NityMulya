import sql from "./src/db";

async function createSimpleComplaintsTable() {
  try {
    console.log("🗑️ Dropping all complaint related tables...");
    
    // Drop all complaint tables
    await sql`DROP TABLE IF EXISTS complaint_history CASCADE`;
    await sql`DROP TABLE IF EXISTS complaint_files CASCADE`;
    await sql`DROP TABLE IF EXISTS complaints CASCADE`;
    
    console.log("✅ Old tables dropped successfully");

    console.log("🏗️ Creating simple complaints table...");
    
    // Create only the basic complaints table
    await sql`
      CREATE TABLE complaints (
        id SERIAL PRIMARY KEY,
        complaint_number TEXT UNIQUE NOT NULL,
        customer_id TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        customer_email TEXT NOT NULL,
        customer_phone TEXT,
        shop_name TEXT NOT NULL,
        product_id TEXT,
        product_name TEXT,
        category TEXT NOT NULL,
        priority TEXT NOT NULL DEFAULT 'Medium',
        severity TEXT NOT NULL DEFAULT 'Minor',
        description TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Received',
        submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `;

    console.log("✅ Simple complaints table created successfully");
    console.log("🎉 Database setup complete!");

  } catch (error) {
    console.error("❌ Error creating table:", error);
  } finally {
    process.exit(0);
  }
}

createSimpleComplaintsTable();
