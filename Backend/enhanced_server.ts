import { Hono } from "hono";
import { cors } from "hono/cors";
import { db } from "./src/db";

const app = new Hono();

// Enable CORS for all origins and methods
app.use(
  "/*",
  cors({
    origin: "*",
    allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowHeaders: ["Content-Type", "Authorization"],
  })
);

app.get("/", (c) => {
  return c.json({
    message: "Enhanced Features API Server",
    timestamp: new Date().toISOString(),
    database: "PostgreSQL (Supabase)",
    status: "OK",
  });
});

// Handle preflight OPTIONS requests
app.options("/*", (c) => {
  return c.text("", 200);
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
      dbStatus: "Connected",
    });
  } catch (error) {
    return c.json(
      {
        success: false,
        message: "Database connection failed",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
});

// 💬 MESSAGE ENDPOINTS - Real-time messaging between shop owners and customers

// Send a message
app.post("/api/messages/send", async (c) => {
  try {
    const body = await c.req.json();
    const {
      order_id,
      sender_type, // 'shop_owner' or 'customer'
      sender_id,
      receiver_type, // 'shop_owner' or 'customer'
      receiver_id,
      message_text,
    } = body;

    // Validate required fields
    if (
      !order_id ||
      !sender_type ||
      !sender_id ||
      !receiver_type ||
      !receiver_id ||
      !message_text
    ) {
      return c.json(
        {
          success: false,
          message: "All fields are required",
        },
        400
      );
    }

    // Insert message into database
    const result = await db`
      INSERT INTO order_messages (order_id, sender_type, sender_id, receiver_type, receiver_id, message_text)
      VALUES (${order_id}, ${sender_type}, ${sender_id}, ${receiver_type}, ${receiver_id}, ${message_text})
      RETURNING *
    `;

    return c.json({
      success: true,
      message: "Message sent successfully",
      data: result[0],
    });
  } catch (error) {
    console.error("❌ Error sending message:", error);
    return c.json(
      {
        success: false,
        message: "Failed to send message",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
});

// Get messages for a specific order
app.get("/api/messages/order/:order_id", async (c) => {
  try {
    const order_id = c.req.param("order_id");
    const { user_id, user_type } = c.req.query();

    const messages = await db`
      SELECT om.*, 
             CASE 
               WHEN om.sender_type = 'shop_owner' THEN so.shop_name
               WHEN om.sender_type = 'customer' THEN c.full_name
             END as sender_name
      FROM order_messages om
      LEFT JOIN shop_owners so ON om.sender_type = 'shop_owner' AND om.sender_id = so.id::varchar
      LEFT JOIN customers c ON om.sender_type = 'customer' AND om.sender_id = c.id::varchar
      WHERE om.order_id = ${order_id}
      AND (om.sender_id = ${user_id} OR om.receiver_id = ${user_id})
      ORDER BY om.created_at ASC
    `;

    // Mark messages as read for the current user
    if (user_id && user_type) {
      await db`
        UPDATE order_messages 
        SET is_read = TRUE, updated_at = CURRENT_TIMESTAMP
        WHERE order_id = ${order_id} AND receiver_id = ${user_id} AND receiver_type = ${user_type}
      `;
    }

    return c.json({
      success: true,
      data: messages,
    });
  } catch (error) {
    console.error("❌ Error fetching messages:", error);
    return c.json(
      {
        success: false,
        message: "Failed to fetch messages",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
});

// Get all message conversations for a customer
app.get("/api/messages/customer/:customer_id", async (c) => {
  try {
    const customer_id = c.req.param("customer_id");
    console.log("📧 Fetching messages for customer:", customer_id);

    // Use the working query from test server
    const conversations = await db`
      SELECT * FROM order_messages 
      WHERE receiver_id::text = ${customer_id} OR sender_id::text = ${customer_id}
      ORDER BY created_at DESC
    `;

    console.log("✅ Messages found:", conversations.length);

    return c.json({
      success: true,
      data: conversations,
      count: conversations.length,
    });
  } catch (error) {
    console.error("❌ Error fetching customer messages:", error);
    return c.json(
      {
        success: false,
        message: "Failed to fetch customer messages",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
});

// Get all message conversations for a shop owner
app.get("/api/messages/shop/:shop_id", async (c) => {
  try {
    const shop_id = c.req.param("shop_id");

    const conversations = await db`
      WITH latest_messages AS (
        SELECT DISTINCT ON (order_id) 
               order_id,
               sender_type,
               sender_id,
               receiver_type,
               receiver_id,
               message_text,
               is_read,
               created_at
        FROM order_messages 
        WHERE sender_id::varchar = ${shop_id} OR receiver_id::varchar = ${shop_id}
        ORDER BY order_id, created_at DESC
      )
      SELECT lm.*,
             co.status as order_status,
             c.full_name as customer_name,
             c.phone as customer_phone,
             (SELECT COUNT(*) FROM order_messages om_unread 
              WHERE om_unread.order_id = lm.order_id 
              AND om_unread.receiver_id::varchar = ${shop_id} 
              AND om_unread.is_read = FALSE) as unread_count
      FROM latest_messages lm
      LEFT JOIN customer_orders co ON lm.order_id = co.order_number
      LEFT JOIN customers c ON (
        CASE 
          WHEN lm.sender_type = 'customer' THEN lm.sender_id::varchar = c.id::varchar
          WHEN lm.receiver_type = 'customer' THEN lm.receiver_id::varchar = c.id::varchar
        END
      )
      ORDER BY lm.created_at DESC
    `;

    return c.json({
      success: true,
      data: conversations,
    });
  } catch (error) {
    console.error("❌ Error fetching shop messages:", error);
    return c.json(
      {
        success: false,
        message: "Failed to fetch shop messages",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
});

// Get unread message count
app.get("/api/messages/unread-count/:user_id/:user_type", async (c) => {
  try {
    const user_id = c.req.param("user_id");
    const user_type = c.req.param("user_type");

    const result = await db`
      SELECT COUNT(*) as unread_count
      FROM order_messages 
      WHERE receiver_id = ${user_id} AND receiver_type = ${user_type} AND is_read = FALSE
    `;

    return c.json({
      success: true,
      unread_count: parseInt(result[0].unread_count),
    });
  } catch (error) {
    console.error("❌ Error getting unread count:", error);
    return c.json(
      {
        success: false,
        message: "Failed to get unread count",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
});

// Mark messages as read
app.put("/api/messages/mark-read", async (c) => {
  try {
    const body = await c.req.json();
    const { order_id, user_id, user_type } = body;

    const result = await db`
      UPDATE order_messages 
      SET is_read = TRUE, updated_at = CURRENT_TIMESTAMP
      WHERE order_id = ${order_id} AND receiver_id = ${user_id} AND receiver_type = ${user_type}
      RETURNING *
    `;

    return c.json({
      success: true,
      message: "Messages marked as read",
      data: result,
    });
  } catch (error) {
    console.error("❌ Error marking messages as read:", error);
    return c.json(
      {
        success: false,
        message: "Failed to mark messages as read",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
});

// Favourites endpoints
app.get("/api/enhanced/favourites/:customerId", async (c) => {
  try {
    const customerId = c.req.param("customerId");

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
      message: "Favourites retrieved successfully",
    });
  } catch (error) {
    console.error("Error fetching favourites:", error);
    return c.json(
      {
        success: false,
        message: "Failed to fetch favourites",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
});

// Reviews endpoints
app.get("/api/enhanced/reviews/:shopId", async (c) => {
  try {
    const shopId = c.req.param("shopId");
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
      message: "Reviews retrieved successfully",
    });
  } catch (error) {
    console.error("Error fetching reviews:", error);
    return c.json(
      {
        success: false,
        message: "Failed to fetch reviews",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
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
      review_comment,
    } = body;

    // Validate required fields
    if (
      !customer_id ||
      !customer_name ||
      !customer_email ||
      !shop_id ||
      !overall_rating ||
      !review_comment
    ) {
      return c.json(
        {
          success: false,
          message: "Missing required fields",
        },
        400
      );
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
      message: "Review added successfully",
    });
  } catch (error) {
    console.error("Error adding review:", error);
    return c.json(
      {
        success: false,
        message: "Failed to add review",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
});

// Complaints endpoints
app.get("/api/enhanced/complaints/:customerId", async (c) => {
  try {
    const customerId = c.req.param("customerId");

    const complaints = await db`
      SELECT * FROM complaints 
      WHERE customer_id = ${customerId}
      ORDER BY created_at DESC
      LIMIT 20
    `;

    return c.json({
      success: true,
      data: complaints,
      message: "Complaints retrieved successfully",
    });
  } catch (error) {
    console.error("Error fetching complaints:", error);
    return c.json(
      {
        success: false,
        message: "Failed to fetch complaints",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
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
      priority = "medium",
    } = body;

    // Validate required fields
    if (
      !customer_id ||
      !customer_name ||
      !customer_email ||
      !shop_owner_id ||
      !complaint_type ||
      !subject ||
      !description
    ) {
      return c.json(
        {
          success: false,
          message: "Missing required fields",
        },
        400
      );
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
      message: "Complaint submitted successfully",
    });
  } catch (error) {
    console.error("Error submitting complaint:", error);
    return c.json(
      {
        success: false,
        message: "Failed to submit complaint",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
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
      tables: tables,
    });
  } catch (error) {
    return c.json(
      {
        success: false,
        message: "Failed to check tables",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
});

console.log("Starting Enhanced Features API server on port 3005...");

export default {
  port: 3005,
  fetch: app.fetch,
};
