import { Database } from "bun:sqlite";
import * as path from "path";

// Create or connect to SQLite database
const dbPath = path.join(process.cwd(), '../enhanced_features.db');
const db = new Database(dbPath);

// Initialize database schema if not exists
const initializeDatabase = () => {
  try {
    // Create favourites table
    db.exec(`
      CREATE TABLE IF NOT EXISTS favourites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        shop_id INTEGER NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        shop_name TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(customer_id, shop_id, product_id)
      )
    `);

    // Create product_price_history table
    db.exec(`
      CREATE TABLE IF NOT EXISTS product_price_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        shop_id INTEGER NOT NULL,
        shop_name TEXT NOT NULL,
        price REAL NOT NULL,
        unit TEXT,
        price_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        recorded_by TEXT
      )
    `);

    // Create reviews table
    db.exec(`
      CREATE TABLE IF NOT EXISTS reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        customer_name TEXT NOT NULL,
        customer_email TEXT NOT NULL,
        shop_id INTEGER NOT NULL,
        shop_name TEXT NOT NULL,
        product_id TEXT,
        product_name TEXT,
        overall_rating INTEGER NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
        product_quality_rating INTEGER CHECK (product_quality_rating >= 1 AND product_quality_rating <= 5),
        service_rating INTEGER CHECK (service_rating >= 1 AND service_rating <= 5),
        delivery_rating INTEGER CHECK (delivery_rating >= 1 AND delivery_rating <= 5),
        review_title TEXT,
        review_comment TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create complaints table
    db.exec(`
      CREATE TABLE IF NOT EXISTS complaints (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        complaint_number TEXT UNIQUE NOT NULL,
        customer_id INTEGER NOT NULL,
        customer_name TEXT NOT NULL,
        customer_email TEXT NOT NULL,
        customer_phone TEXT,
        shop_id INTEGER NOT NULL,
        shop_name TEXT NOT NULL,
        product_id TEXT,
        product_name TEXT,
        complaint_type TEXT NOT NULL,
        complaint_title TEXT NOT NULL,
        complaint_description TEXT NOT NULL,
        priority TEXT NOT NULL DEFAULT 'medium',
        status TEXT NOT NULL DEFAULT 'pending',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        resolved_at DATETIME,
        resolution_comment TEXT
      )
    `);

    console.log('✅ SQLite database initialized successfully');
  } catch (error) {
    console.error('❌ Error initializing database:', error);
  }
};

// Initialize on import
initializeDatabase();

export { db as sqliteDb };
