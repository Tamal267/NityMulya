import { Hono } from "hono";
import { cors } from "hono/cors";
import { db } from "./src/db";

const app = new Hono();

app.use("/*", cors());

app.get("/", (c) => {
  return c.json({ 
    message: "Enhanced Features API Server",
    timestamp: new Date().toISOString(),
    database: "PostgreSQL (Supabase)",
    status: "OK" 
  });
});

// Health check endpoint
app.get("/health", async (c) => {
  try {
    // Test database connection
    const result = await db`SELECT 1 as test`;
    return c.json({
      success: true,
      message: "Enhanced Features API is healthy",
      timestamp: new Date().toISOString(),
      database: "PostgreSQL (Supabase)",
      dbStatus: "Connected"
    });
  } catch (error) {
    return c.json({
      success: false,
      message: "Database connection failed",
      error: error instanceof Error ? error.message : "Unknown error"
    }, 500);
  }
});

// Favourites endpoints
app.get("/api/enhanced/favourites/:customerId", async (c) => {
  try {
    const customerId = c.req.param('customerId');
    
    const favourites = await db`
      SELECT 
        cf.*,
        sc.subcat_name as product_name,
        so.name as shop_name
      FROM customer_favorites cf
      LEFT JOIN subcategories sc ON cf.subcat_id = sc.id
      LEFT JOIN shop_owners so ON cf.shop_owner_id = so.id  
      WHERE cf.customer_id = ${customerId}
      ORDER BY cf.created_at DESC
      LIMIT 20
    `;

    return c.json({
      success: true,
      data: favourites,
      message: 'Favourites retrieved successfully'
    });
  } catch (error) {
    console.error('Error fetching favourites:', error);
    return c.json({
      success: false,
      message: 'Failed to fetch favourites',
      error: error instanceof Error ? error.message : 'Unknown error'
    }, 500);
  }
});

// Reviews endpoints
app.get("/api/enhanced/reviews/:shopId", async (c) => {
  try {
    const shopId = c.req.param('shopId');
    const { limit = 10, offset = 0 } = c.req.query();
    
    const reviews = await db`
      SELECT 
        r.*,
        c.name as customer_name,
        c.email as customer_email
      FROM customer_shop_reviews r
      LEFT JOIN customers c ON r.customer_id = c.id::text
      WHERE r.shop_id = ${shopId}
      ORDER BY r.created_at DESC
      LIMIT ${limit} OFFSET ${offset}
    `;

    return c.json({
      success: true,
      data: reviews,
      message: 'Reviews retrieved successfully'
    });
  } catch (error) {
    console.error('Error fetching reviews:', error);
    return c.json({
      success: false,
      message: 'Failed to fetch reviews',
      error: error instanceof Error ? error.message : 'Unknown error'
    }, 500);
  }
});

app.post("/api/enhanced/reviews", async (c) => {
  try {
    const body = await c.req.json();
    const {
      customer_id,
      customer_name,
      customer_email,
      shop_id,
      shop_name,
      product_id,
      product_name,
      overall_rating,
      product_quality_rating,
      service_rating,
      delivery_rating,
      review_title,
      review_comment
    } = body;

    // Validate required fields
    if (!customer_id || !customer_name || !customer_email || !shop_id || !overall_rating || !review_comment) {
      return c.json({
        success: false,
        message: 'Missing required fields'
      }, 400);
    }

    // Insert review
    const result = await db`
      INSERT INTO customer_shop_reviews (
        customer_id, customer_name, customer_email,
        shop_id, shop_name, product_id, product_name,
        overall_rating, product_quality_rating, service_rating, delivery_rating,
        review_title, review_comment, created_at
      ) VALUES (
        ${customer_id}, ${customer_name}, ${customer_email},
        ${shop_id}, ${shop_name}, ${product_id}, ${product_name},
        ${overall_rating}, ${product_quality_rating}, ${service_rating}, ${delivery_rating},
        ${review_title}, ${review_comment}, NOW()
      ) RETURNING *
    `;

    return c.json({
      success: true,
      data: result[0],
      message: 'Review added successfully'
    });
  } catch (error) {
    console.error('Error adding review:', error);
    return c.json({
      success: false,
      message: 'Failed to add review',
      error: error instanceof Error ? error.message : 'Unknown error'
    }, 500);
  }
});

// Complaints endpoints
app.get("/api/enhanced/complaints/:customerId", async (c) => {
  try {
    const customerId = c.req.param('customerId');
    
    const complaints = await db`
      SELECT * FROM complaints 
      WHERE customer_id = ${customerId}
      ORDER BY created_at DESC
      LIMIT 20
    `;

    return c.json({
      success: true,
      data: complaints,
      message: 'Complaints retrieved successfully'
    });
  } catch (error) {
    console.error('Error fetching complaints:', error);
    return c.json({
      success: false,
      message: 'Failed to fetch complaints',
      error: error instanceof Error ? error.message : 'Unknown error'
    }, 500);
  }
});

app.post("/api/enhanced/complaints", async (c) => {
  try {
    const body = await c.req.json();
    const {
      customer_id,
      customer_name,
      customer_email,
      customer_phone,
      shop_owner_id,
      shop_name,
      product_id,
      product_name,
      complaint_type,
      subject,
      description,
      priority = 'medium'
    } = body;

    // Validate required fields
    if (!customer_id || !customer_name || !customer_email || !shop_owner_id || !complaint_type || !subject || !description) {
      return c.json({
        success: false,
        message: 'Missing required fields'
      }, 400);
    }

    // Generate complaint number
    const timestamp = Date.now().toString().slice(-6);
    const complaint_number = `COMP-${timestamp}`;

    // Insert complaint
    const result = await db`
      INSERT INTO complaints (
        customer_id, customer_name, customer_email, customer_phone,
        shop_owner_id, shop_name, product_id, product_name,
        complaint_type, subject, description, priority,
        complaint_number, status, created_at
      ) VALUES (
        ${customer_id}, ${customer_name}, ${customer_email}, ${customer_phone},
        ${shop_owner_id}, ${shop_name}, ${product_id}, ${product_name},
        ${complaint_type}, ${subject}, ${description}, ${priority},
        ${complaint_number}, 'pending', NOW()
      ) RETURNING *
    `;

    return c.json({
      success: true,
      data: result[0],
      message: 'Complaint submitted successfully'
    });
  } catch (error) {
    console.error('Error submitting complaint:', error);
    return c.json({
      success: false,
      message: 'Failed to submit complaint',
      error: error instanceof Error ? error.message : 'Unknown error'
    }, 500);
  }
});

// Test database tables
app.get("/test/tables", async (c) => {
  try {
    const tables = await db`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name IN ('customer_favorites', 'complaints', 'product_price_history', 'customer_shop_reviews', 'subcategories', 'shop_owners')
      ORDER BY table_name;
    `;

    return c.json({
      success: true,
      message: "Database tables check",
      tables: tables
    });
  } catch (error) {
    return c.json({
      success: false,
      message: 'Failed to check tables',
      error: error instanceof Error ? error.message : 'Unknown error'
    }, 500);
  }
});

console.log("Starting Enhanced Features API server on port 3005...");

export default {
  port: 3005,
  fetch: app.fetch,
};
