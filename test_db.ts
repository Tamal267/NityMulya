import sql from "./Backend/src/db.ts";

async function test() {
  try {
    const result = await sql`SELECT NOW() as current_time`;
    console.log("Database connected:", result[0]);

    // Check if complaints table exists
    const tables =
      await sql`SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'complaints'`;
    console.log("Complaints table exists:", tables.length > 0);

    if (tables.length === 0) {
      console.log("Creating complaints table...");
      // Create basic complaints table for testing
      await sql`
        CREATE TABLE IF NOT EXISTS complaints (
          id SERIAL PRIMARY KEY,
          complaint_number TEXT UNIQUE NOT NULL,
          customer_id INTEGER NOT NULL,
          customer_name TEXT NOT NULL,
          customer_email TEXT NOT NULL,
          customer_phone TEXT,
          shop_id INTEGER NOT NULL,
          shop_name TEXT NOT NULL,
          product_id INTEGER,
          product_name TEXT,
          category TEXT NOT NULL DEFAULT 'Other',
          priority TEXT NOT NULL DEFAULT 'Medium',
          severity TEXT NOT NULL DEFAULT 'Minor',
          description TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'Received',
          submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      `;
      console.log("Complaints table created!");
    }

    process.exit(0);
  } catch (error) {
    console.error("Database error:", error);
    process.exit(1);
  }
}

test();
