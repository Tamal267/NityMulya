// Quick script to test database connection and create customer_reviews table
import sql from './src/db';

async function testDatabase() {
  try {
    console.log('Testing database connection...');
    
    // Test basic connection
    const result = await sql`SELECT NOW() as current_time`;
    console.log('Database connected successfully:', result[0]);
    
    // Check if customer_reviews table exists
    const tableExists = await sql`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'customer_reviews'
      );
    `;
    
    console.log('customer_reviews table exists:', tableExists[0].exists);
    
    if (!tableExists[0].exists) {
      console.log('Creating customer_reviews table...');
      
      // Create the customer_reviews table
      await sql`
        CREATE TABLE IF NOT EXISTS customer_reviews (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
          shop_owner_id UUID REFERENCES shop_owners(id) ON DELETE CASCADE,
          order_id UUID,
          subcat_id UUID REFERENCES subcategories(id) ON DELETE SET NULL,
          rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
          comment TEXT,
          product_name VARCHAR(255),
          shop_name VARCHAR(255),
          delivery_rating INTEGER CHECK (delivery_rating >= 1 AND delivery_rating <= 5),
          service_rating INTEGER CHECK (service_rating >= 1 AND service_rating <= 5),
          helpful_count INTEGER DEFAULT 0,
          is_verified_purchase BOOLEAN DEFAULT FALSE
        )
      `;
      
      // Create indexes
      await sql`CREATE INDEX IF NOT EXISTS idx_customer_reviews_customer ON customer_reviews (customer_id)`;
      await sql`CREATE INDEX IF NOT EXISTS idx_customer_reviews_shop ON customer_reviews (shop_owner_id)`;
      await sql`CREATE INDEX IF NOT EXISTS idx_customer_reviews_subcat ON customer_reviews (subcat_id)`;
      await sql`CREATE INDEX IF NOT EXISTS idx_customer_reviews_rating ON customer_reviews (rating)`;
      
      console.log('customer_reviews table created successfully!');
    }
    
    // Test inserting a sample review
    console.log('Inserting sample review...');
    
    // First check if we have customers and shop_owners
    const customers = await sql`SELECT id FROM customers LIMIT 1`;
    const shopOwners = await sql`SELECT id FROM shop_owners LIMIT 1`;
    
    if (customers.length > 0 && shopOwners.length > 0) {
      await sql`
        INSERT INTO customer_reviews (
          customer_id, shop_owner_id, rating, comment, product_name, shop_name, is_verified_purchase
        ) VALUES (
          ${customers[0].id}, ${shopOwners[0].id}, 5, 'অসাধারণ মানের চাল! দাম অনুযায়ী খুবই ভালো।', 'চাল', 'রহমান গ্রোসারি', true
        )
        ON CONFLICT DO NOTHING
      `;
      console.log('Sample review inserted!');
    } else {
      console.log('No customers or shop_owners found, skipping sample review');
    }
    
    // Query reviews
    const reviews = await sql`
      SELECT * FROM customer_reviews 
      WHERE product_name = 'চাল'
      LIMIT 5
    `;
    
    console.log('Found reviews:', reviews);
    
  } catch (error) {
    console.error('Database error:', error);
  } finally {
    process.exit(0);
  }
}

testDatabase();
