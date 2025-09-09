import sql from "./src/db";

async function recreateComplaintsTable() {
  try {
    console.log("🗑️ Dropping existing complaints table...");

    // Drop existing complaints table
    await sql`DROP TABLE IF EXISTS complaint_history CASCADE`;
    await sql`DROP TABLE IF EXISTS complaint_files CASCADE`;
    await sql`DROP TABLE IF EXISTS complaints CASCADE`;

    console.log("✅ Old tables dropped successfully");

    console.log("🏗️ Creating new complaints table...");

    // Create new complaints table with proper structure
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
        
        -- Enhanced complaint categorization
        category TEXT NOT NULL,
        priority TEXT NOT NULL DEFAULT 'Medium',
        severity TEXT NOT NULL DEFAULT 'Minor',
        
        description TEXT NOT NULL,
        
        -- DNCRP Status tracking
        status TEXT NOT NULL DEFAULT 'Received',
        forwarded_to TEXT,
        forwarded_at TIMESTAMP,
        solved_at TIMESTAMP,
        
        -- Timestamps
        submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        
        -- Additional fields
        resolution_comment TEXT
      )
    `;

    console.log("✅ New complaints table created successfully");

    console.log("🏗️ Creating complaint_files table...");

    await sql`
      CREATE TABLE complaint_files (
        id SERIAL PRIMARY KEY,
        complaint_id INTEGER NOT NULL REFERENCES complaints(id) ON DELETE CASCADE,
        file_name TEXT NOT NULL,
        file_url TEXT NOT NULL,
        file_type TEXT NOT NULL,
        file_size INTEGER,
        uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `;

    console.log("✅ complaint_files table created");

    console.log("🏗️ Creating complaint_history table...");

    await sql`
      CREATE TABLE complaint_history (
        id SERIAL PRIMARY KEY,
        complaint_id INTEGER NOT NULL REFERENCES complaints(id) ON DELETE CASCADE,
        old_status TEXT,
        new_status TEXT NOT NULL,
        comment TEXT,
        changed_by_name TEXT,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `;

    console.log("✅ complaint_history table created");
    console.log("🎉 All tables created successfully!");
  } catch (error) {
    console.error("❌ Error recreating tables:", error);
  } finally {
    process.exit(0);
  }
}

recreateComplaintsTable();
