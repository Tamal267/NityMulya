// Script to fix the customer_reviews table structure
import sql from "./src/db";

async function fixDatabase() {
  try {
    console.log("Fixing customer_reviews table structure...");

    // Check existing columns
    const columns = await sql`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'customer_reviews' 
      AND table_schema = 'public'
      ORDER BY ordinal_position
    `;

    console.log("Existing columns:", columns);

    // Add missing columns if they don't exist
    const columnNames = columns.map((col) => col.column_name);

    if (!columnNames.includes("comment")) {
      console.log("Adding comment column...");
      await sql`ALTER TABLE customer_reviews ADD COLUMN comment TEXT`;
    }

    if (!columnNames.includes("product_name")) {
      console.log("Adding product_name column...");
      await sql`ALTER TABLE customer_reviews ADD COLUMN product_name VARCHAR(255)`;
    }

    if (!columnNames.includes("shop_name")) {
      console.log("Adding shop_name column...");
      await sql`ALTER TABLE customer_reviews ADD COLUMN shop_name VARCHAR(255)`;
    }

    if (!columnNames.includes("delivery_rating")) {
      console.log("Adding delivery_rating column...");
      await sql`ALTER TABLE customer_reviews ADD COLUMN delivery_rating INTEGER CHECK (delivery_rating >= 1 AND delivery_rating <= 5)`;
    }

    if (!columnNames.includes("service_rating")) {
      console.log("Adding service_rating column...");
      await sql`ALTER TABLE customer_reviews ADD COLUMN service_rating INTEGER CHECK (service_rating >= 1 AND service_rating <= 5)`;
    }

    if (!columnNames.includes("helpful_count")) {
      console.log("Adding helpful_count column...");
      await sql`ALTER TABLE customer_reviews ADD COLUMN helpful_count INTEGER DEFAULT 0`;
    }

    if (!columnNames.includes("is_verified_purchase")) {
      console.log("Adding is_verified_purchase column...");
      await sql`ALTER TABLE customer_reviews ADD COLUMN is_verified_purchase BOOLEAN DEFAULT FALSE`;
    }

    // Now try to insert sample data
    console.log("Inserting sample review...");

    const customers = await sql`SELECT id, full_name FROM customers LIMIT 1`;
    const shopOwners = await sql`SELECT id, name FROM shop_owners LIMIT 1`;

    if (customers.length > 0 && shopOwners.length > 0) {
      const reviewId = crypto.randomUUID();
      await sql`
        INSERT INTO customer_reviews (
          id, customer_id, shop_owner_id, rating, comment, product_name, shop_name, is_verified_purchase, helpful_count
        ) VALUES (
          ${reviewId}, ${customers[0].id}, ${shopOwners[0].id}, 5, 'অসাধারণ মানের চাল! দাম অনুযায়ী খুবই ভালো।', 'চাল', 'রহমান গ্রোসারি', true, 12
        )
      `;
      console.log("Sample review inserted!");

      // Insert a few more reviews
      const reviewId2 = crypto.randomUUID();
      await sql`
        INSERT INTO customer_reviews (
          id, customer_id, shop_owner_id, rating, comment, product_name, shop_name, is_verified_purchase, helpful_count
        ) VALUES (
          ${reviewId2}, ${customers[0].id}, ${shopOwners[0].id}, 4, 'ভালো কোয়ালিটি। ডেলিভারি একটু দেরি হয়েছিল কিন্তু পণ্য ভালো।', 'চাল', 'করিম স্টোর', true, 8
        )
      `;

      const reviewId3 = crypto.randomUUID();
      await sql`
        INSERT INTO customer_reviews (
          id, customer_id, shop_owner_id, rating, comment, product_name, shop_name, is_verified_purchase, helpful_count
        ) VALUES (
          ${reviewId3}, ${customers[0].id}, ${shopOwners[0].id}, 5, 'খুবই ভালো চাল। দামটাও যুক্তিসংগত। আবার কিনব।', 'চাল', 'নিউ মার্কেট শপ', true, 15
        )
      `;

      console.log("Multiple sample reviews inserted!");
    } else {
      console.log("No customers or shop_owners found");
    }

    // Query reviews to verify
    const reviews = await sql`
      SELECT r.*, c.full_name as customer_name
      FROM customer_reviews r
      JOIN customers c ON r.customer_id = c.id
      WHERE r.product_name = 'চাল'
      ORDER BY r.created_at DESC
    `;

    console.log("Found reviews for চাল:", reviews.length);
    reviews.forEach((review) => {
      console.log(
        `- ${review.customer_name}: ${review.rating} stars - ${review.comment}`
      );
    });
  } catch (error) {
    console.error("Database error:", error);
  } finally {
    process.exit(0);
  }
}

fixDatabase();
