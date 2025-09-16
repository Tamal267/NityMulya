import dotenv from "dotenv";
import { Hono } from "hono";
import { cors } from "hono/cors";
import type { JwtVariables } from "hono/jwt";
import { prettyJSON } from "hono/pretty-json";
import path from "path";
import {
  getCategories,
  getChatConversations,
  getChatMessages,
  getPrice,
  getPricesfromDB,
  getProductPriceHistory,
  getSheetUrl,
  getShops,
  getShopsByProduct,
  getShopsBySubcategoryId,
  getWholesalers,
  initializeSampleData,
  sendMessage,
} from "./controller/apiController";
import {
  login,
  loginCustomer,
  loginShopOwner,
  loginWholesaler,
  signupCustomer,
  signupShopOwner,
  signupWholesaler,
} from "./controller/authController";
import {
  createCustomerComplaint,
  createPublicComplaint,
  getCustomerComplaints,
} from "./controller/customerComplaintController";
import {
  cancelCustomerOrder,
  createCustomerOrder,
  getCancelledOrders,
  getCustomerOrder,
  getCustomerOrders,
  getCustomerOrderStats,
  getShopOwnerCustomerOrders,
  updateCustomerOrderStatus,
} from "./controller/customerOrderController";
import { DatabaseReviewController } from "./controller/databaseReviewController";
import {
  addProductToInventory as addShopOwnerProduct,
  getChatMessages as getShopOwnerChatMessages,
  getShopOwnerDashboard,
  getShopOwnerInventory,
  getLowStockProducts as getShopOwnerLowStockProducts,
  getShopOrders as getShopOwnerOrders,
  updateShopOrderStatus,
  updateInventoryItem as updateShopOwnerInventoryItem,
} from "./controller/shopOwnerController";
import {
  addProductToInventory as addWholesalerProduct,
  createOffer,
  createOrder,
  getShopOwners,
  getSubcategories,
  getCategories as getWholesalerCategories,
  getChatMessages as getWholesalerChatMessages,
  getWholesalerDashboard,
  getWholesalerInventory,
  getLowStockProducts as getWholesalerLowStockProducts,
  getWholesalerOffers,
  getWholesalerProfile,
  getShopOrders as getWholesalerShopOrders,
  updateOrderStatus,
  updateInventoryItem as updateWholesalerInventoryItem,
} from "./controller/wholesalerController";
import sql, { db } from "./db"; // Database connection for persistent storage
import { createAuthMiddleware, requireRole } from "./utils/jwt";

// Load environment variables
dotenv.config({ path: ".env.local" });

const app = new Hono<{ Variables: JwtVariables }>();
// Use database controller for persistent storage
const reviewController = new DatabaseReviewController();

app.use(prettyJSON());
app.use("/*", cors());

// Serve static files from uploads directory
app.get("/uploads/*", async (c) => {
  try {
    const filePath = c.req.path.replace("/uploads/", "");
    const fullPath = path.join(process.cwd(), "uploads", filePath);

    // Check if file exists
    const fs = await import("fs");
    if (!fs.existsSync(fullPath)) {
      return c.json({ error: "File not found" }, 404);
    }

    // Get file stats and content
    const stats = fs.statSync(fullPath);
    const fileBuffer = fs.readFileSync(fullPath);

    // Determine content type based on file extension
    const ext = path.extname(fullPath).toLowerCase();
    const contentTypes: { [key: string]: string } = {
      ".jpg": "image/jpeg",
      ".jpeg": "image/jpeg",
      ".png": "image/png",
      ".pdf": "application/pdf",
      ".doc": "application/msword",
      ".docx":
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    };

    const contentType = contentTypes[ext] || "application/octet-stream";

    return new Response(fileBuffer, {
      headers: {
        "Content-Type": contentType,
        "Content-Length": stats.size.toString(),
        "Cache-Control": "public, max-age=3600",
      },
    });
  } catch (error) {
    console.error("Error serving file:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
});

// Debug middleware to log all requests
app.use("*", async (c, next) => {
  console.log(`🌐 ${c.req.method} ${c.req.url} - ${new Date().toISOString()}`);
  try {
    await next();
  } catch (error) {
    console.error(`❌ Error handling ${c.req.method} ${c.req.url}:`, error);
    throw error;
  }
});

app.get("/", (c) => {
  return c.json({ message: "Welcome to the API!" });
});

// Test route
app.get("/test", (c) => {
  return c.json({
    message: "Server is working!",
    timestamp: new Date().toISOString(),
  });
});
// Existing API routes
app.use("/get_price", getPrice);
app.use("/get_url", getSheetUrl);
app.use("/get_pricelist", getPricesfromDB);
app.get("/get_categories", getCategories);

// Shop routes (public)
app.get("/get_shops", getShops);
app.get("/get_shops_by_product/:productName", getShopsByProduct);
app.get("/get_shops_by_subcat/:subcatId", getShopsBySubcategoryId);
app.get("/get_price_history/:productName", getProductPriceHistory);
app.post("/initialize_sample_data", initializeSampleData);

// Auth routes
app.post("/signup_customer", signupCustomer);
app.post("/signup_wholesaler", signupWholesaler);
app.post("/signup_shop_owner", signupShopOwner);
app.post("/login", login);
app.post("/login_customer", loginCustomer);
app.post("/login_wholesaler", loginWholesaler);
app.post("/login_shop_owner", loginShopOwner);

// Wholesaler routes - protected with authentication
app.use("/wholesaler/*", createAuthMiddleware(), requireRole("wholesaler"));
app.get("/wholesaler/dashboard", getWholesalerDashboard);
app.get("/wholesaler/inventory", getWholesalerInventory);
app.post("/wholesaler/inventory", addWholesalerProduct);
app.put("/wholesaler/inventory", updateWholesalerInventoryItem);
app.get("/wholesaler/low-stock", getWholesalerLowStockProducts);
app.get("/wholesaler/orders", getWholesalerShopOrders);
app.post("/wholesaler/orders", createOrder);
app.put("/wholesaler/orders/status", updateOrderStatus);
app.get("/wholesaler/offers", getWholesalerOffers);
app.post("/wholesaler/offers", createOffer);
app.get("/wholesaler/profile", getWholesalerProfile);
app.get("/wholesaler/chat", getWholesalerChatMessages);
app.get("/wholesaler/shop-owners", getShopOwners);
app.get("/wholesaler/categories", getWholesalerCategories);
app.get("/wholesaler/subcategories", getSubcategories);

// Shop Owner routes (protected)
app.use("/shop-owner/*", createAuthMiddleware(), requireRole("shop_owner"));

// Add logging middleware for shop-owner routes
app.use("/shop-owner/*", async (c, next) => {
  console.log(
    `🔍 [BACKEND] Shop-owner route called: ${c.req.method} ${c.req.path}`
  );
  // console.log(`🔍 [BACKEND] Headers:`, JSON.stringify(c.req.header(), null, 2));
  await next();
});

app.get("/shop-owner/dashboard", getShopOwnerDashboard);
app.get("/shop-owner/inventory", getShopOwnerInventory);
app.post("/shop-owner/inventory", addShopOwnerProduct);
app.put("/shop-owner/inventory", updateShopOwnerInventoryItem);
app.get("/shop-owner/low-stock", getShopOwnerLowStockProducts);
app.get("/shop-owner/orders", getShopOwnerOrders);
app.put("/shop-owner/orders/status", updateShopOrderStatus);
app.get("/shop-owner/chat", getShopOwnerChatMessages);
app.get("/shop-owner/customer-orders", getShopOwnerCustomerOrders);
app.put("/shop-owner/customer-orders/status", updateCustomerOrderStatus);

// Public complaint submission (no auth required)
app.post("/api/complaints/public", createPublicComplaint);

// Public complaint submission (no authentication required)
app.post("/api/complaints/public", createPublicComplaint);

// Customer routes (protected)
app.use("/customer/*", createAuthMiddleware(), requireRole("customer"));
app.post("/customer/orders", createCustomerOrder);
app.get("/customer/orders/stats", getCustomerOrderStats);
app.get("/customer/orders", getCustomerOrders);
app.get("/customer/orders/:orderId", getCustomerOrder);
app.post("/customer/orders/cancel", cancelCustomerOrder);
app.post("/customer/orders/cancel", cancelCustomerOrder);
app.get("/customer/cancelled-orders", getCancelledOrders);
app.post("/customer/complaints", createCustomerComplaint);
app.get("/customer/complaints", getCustomerComplaints);

// DNCRP Admin routes
app.get("/complaints/all", async (c) => {
  try {
    console.log("📋 Fetching all complaints for DNCRP admin");

    const complaints = await sql`
      SELECT 
        id,
        complaint_number,
        customer_name,
        customer_email,
        customer_phone,
        shop_name,
        product_name,
        category,
        priority,
        severity,
        description,
        status,
        submitted_at,
        updated_at
      FROM complaints
      ORDER BY submitted_at DESC
    `;

    console.log(`✅ Found ${complaints.length} complaints`);

    return c.json({
      success: true,
      complaints: complaints,
      message: "All complaints retrieved successfully",
    });
  } catch (error) {
    console.error("❌ Error fetching all complaints:", error);
    return c.json(
      {
        success: false,
        message: "Failed to fetch complaints",
        error: error,
      },
      500
    );
  }
});

// Chat routes (protected - both wholesaler and shop owner)
app.use("/chat/*", createAuthMiddleware());
app.get("/chat/wholesalers", getWholesalers);
app.post("/chat/send", sendMessage);
app.get("/chat/messages", getChatMessages);
app.get("/chat/conversations", getChatConversations);

// ====================================
// NEW PRODUCT REVIEW ROUTES
// ====================================

// Get all product reviews for a specific product (subcat_id)
app.get(
  "/reviews/product/:subcatId",
  reviewController.getProductReviews.bind(reviewController)
);

// Get average rating for a product
app.get(
  "/reviews/product/:subcatId/average",
  reviewController.getProductAverageRating.bind(reviewController)
);

// Create a new product review (protected route - temporarily removed for testing)
// app.use("/reviews/product/create", createAuthMiddleware(), requireRole("customer"));
app.post(
  "/reviews/product/create",
  reviewController.createProductReview.bind(reviewController)
);

// Update a product review (protected route)
app.use(
  "/reviews/product/:reviewId",
  createAuthMiddleware(),
  requireRole("customer")
);
app.put(
  "/reviews/product/:reviewId",
  reviewController.updateProductReview.bind(reviewController)
);

// Delete a product review (protected route)
app.delete(
  "/reviews/product/:reviewId",
  reviewController.deleteProductReview.bind(reviewController)
);

// ====================================
// NEW SHOP REVIEW ROUTES
// ====================================

// Get all shop reviews for a specific shop
app.get(
  "/reviews/shop/:shopOwnerId",
  reviewController.getShopReviews.bind(reviewController)
);

// Get average ratings for a shop
app.get(
  "/reviews/shop/:shopOwnerId/average",
  reviewController.getShopAverageRatings.bind(reviewController)
);

// Create a new shop review (protected route)
app.use(
  "/reviews/shop/create",
  createAuthMiddleware(),
  requireRole("customer")
);
app.post(
  "/reviews/shop/create",
  reviewController.createShopReview.bind(reviewController)
);

// Update a shop review (protected route)
app.put(
  "/reviews/shop/:reviewId",
  reviewController.updateShopReview.bind(reviewController)
);

// Delete a shop review (protected route)
app.delete(
  "/reviews/shop/:reviewId",
  reviewController.deleteShopReview.bind(reviewController)
);

// ====================================
// CUSTOMER REVIEW ROUTES
// ====================================

// Get all product reviews by a specific customer
app.get(
  "/reviews/customer/:customerId/products",
  reviewController.getCustomerProductReviews.bind(reviewController)
);

// Get all shop reviews by a specific customer
app.get(
  "/reviews/customer/:customerId/shops",
  reviewController.getCustomerShopReviews.bind(reviewController)
);

// ====================================
// API PREFIXED ROUTES (for Flutter app)
// ====================================

// Product reviews with /api prefix
app.get(
  "/api/reviews/product/:subcatId",
  reviewController.getProductReviews.bind(reviewController)
);
app.get(
  "/api/reviews/product/:subcatId/average",
  reviewController.getProductAverageRating.bind(reviewController)
);
app.post(
  "/api/reviews/product",
  reviewController.createProductReview.bind(reviewController)
);
app.put(
  "/api/reviews/product/:reviewId",
  reviewController.updateProductReview.bind(reviewController)
);
app.delete(
  "/api/reviews/product/:reviewId",
  reviewController.deleteProductReview.bind(reviewController)
);

// Shop reviews with /api prefix
app.get(
  "/api/reviews/shop/:shopOwnerId",
  reviewController.getShopReviews.bind(reviewController)
);
app.get(
  "/api/reviews/shop/:shopOwnerId/average",
  reviewController.getShopAverageRatings.bind(reviewController)
);
app.post(
  "/api/reviews/shop",
  reviewController.createShopReview.bind(reviewController)
);
app.put(
  "/api/reviews/shop/:reviewId",
  reviewController.updateShopReview.bind(reviewController)
);
app.delete(
  "/api/reviews/shop/:reviewId",
  reviewController.deleteShopReview.bind(reviewController)
);

// Customer reviews with /api prefix
app.get(
  "/api/reviews/customer/:customerId/products",
  reviewController.getCustomerProductReviews.bind(reviewController)
);
app.get(
  "/api/reviews/customer/:customerId/shops",
  reviewController.getCustomerShopReviews.bind(reviewController)
);

// ====================================
// COMPLAINTS ROUTES (DNCRP Integration)
// ====================================

// Submit new complaint
app.post("/api/complaints/submit", async (c) => {
  try {
    const body = await c.req.json();
    console.log("📝 Complaint submission received:", body);

    // Generate complaint number
    const complaintNumber = `DNCRP${Date.now()}`;

    // Save to database
    const result = await sql`
      INSERT INTO complaints (
        complaint_number, 
        customer_id, 
        customer_name, 
        customer_email, 
        customer_phone,
        shop_name, 
        category,
        priority,
        severity,
        subject, 
        description, 
        expected_resolution_date,
        status, 
        created_at
      ) VALUES (
        ${complaintNumber},
        ${body.customerId || 0},
        ${body.customerName || "Unknown"},
        ${body.customerEmail || "unknown@email.com"},
        ${body.customerPhone || ""},
        ${body.shopName || "DNCRP Online"},
        ${body.category || "সাধারণ"},
        ${body.priority || "মাঝারি"},
        ${body.severity || "মাঝারি"},
        ${body.subject || "DNCRP অভিযোগ"},
        ${body.description || ""},
        ${body.expectedDate || null},
        'pending',
        NOW()
      ) RETURNING *;
    `;

    const complaint = result[0];
    console.log("✅ Complaint saved to database:", complaint);

    return c.json({
      success: true,
      data: {
        complaint_number: complaint.complaint_number,
        id: complaint.id,
        status: complaint.status,
        created_at: complaint.created_at,
      },
      message: "অভিযোগ সফলভাবে জমা হয়েছে!",
    });
  } catch (error) {
    console.error("❌ Error submitting complaint:", error);
    return c.json(
      {
        success: false,
        message: "অভিযোগ জমা দিতে সমস্যা হয়েছে",
        error: error.message,
      },
      500
    );
  }
});

// Get complaints by customer
app.get("/api/complaints/customer/:customerId", async (c) => {
  try {
    const customerId = c.req.param("customerId");
    console.log("📋 Fetching complaints for customer:", customerId);

    // Mock data (replace with real DB query)
    const complaints = [
      {
        id: 1,
        complaint_number: "DNCRP123456",
        customer_id: parseInt(customerId),
        shop_name: "Sample Shop",
        complaint_type: "পণ্যের গুণগত মান সমস্যা",
        status: "pending",
        created_at: new Date().toISOString(),
      },
    ];

    return c.json({
      success: true,
      data: complaints,
      message: "Complaints retrieved successfully",
    });
  } catch (error) {
    console.error("❌ Error fetching complaints:", error);
    return c.json(
      {
        success: false,
        message: "Failed to fetch complaints",
        error: error.message,
      },
      500
    );
  }
});

// ====================================
// UTILITY ROUTES (for debugging)
// ====================================

// Get all reviews (for debugging) - both with and without /api prefix
app.get("/reviews/all", reviewController.getAllReviews.bind(reviewController));
app.get(
  "/api/reviews/all",
  reviewController.getAllReviews.bind(reviewController)
);

// ====================================
// MESSAGING SYSTEM ROUTES
// ====================================

// Protect messaging routes with authentication
app.use("/api/messages/*", createAuthMiddleware());

// Send a message
app.post("/api/messages/send", async (c) => {
  try {
    const body = await c.req.json();
    const {
      order_id,
      sender_type,
      sender_id,
      receiver_type,
      receiver_id,
      message_text,
    } = body;

    console.log("📧 Sending message:", {
      order_id,
      sender_type,
      sender_id,
      receiver_type,
      receiver_id,
    });

    // Insert message into database
    const result = await db`
      INSERT INTO order_messages (order_id, sender_type, sender_id, receiver_type, receiver_id, message_text, is_read, created_at, updated_at)
      VALUES (${order_id}, ${sender_type}, ${sender_id}, ${receiver_type}, ${receiver_id}, ${message_text}, false, NOW(), NOW())
      RETURNING *
    `;

    console.log("✅ Message saved successfully");

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

// Get messages for a customer
app.get("/api/messages/customer/:customer_id", async (c) => {
  try {
    const customer_id = c.req.param("customer_id");
    console.log("📧 Fetching messages for customer:", customer_id);

    const messages = await db`
      SELECT 
        om.*,
        so.full_name as shop_name
      FROM order_messages om
      LEFT JOIN shop_owners so ON om.sender_id::text = so.id::text
      WHERE om.receiver_id::text = ${customer_id} OR om.sender_id::text = ${customer_id}
      ORDER BY om.created_at DESC
    `;

    console.log("✅ Messages found:", messages.length);

    return c.json({
      success: true,
      data: messages,
      count: messages.length,
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

// Get messages for a shop owner
app.get("/api/messages/shop/:shop_id", async (c) => {
  try {
    const shop_id = c.req.param("shop_id");
    console.log("📧 Fetching messages for shop owner:", shop_id);

    const messages = await db`
      SELECT * FROM order_messages 
      WHERE receiver_id::text = ${shop_id} OR sender_id::text = ${shop_id}
      ORDER BY created_at DESC
    `;

    console.log("✅ Messages found:", messages.length);

    return c.json({
      success: true,
      data: messages,
      count: messages.length,
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

// Health check endpoint
app.get("/health", async (c) => {
  try {
    // Test database connection
    const result = await db`SELECT 1 as test`;

    return c.json({
      success: true,
      message: "API is healthy",
      timestamp: new Date().toISOString(),
      database: "Connected",
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

export default {
  port: process.env.PORT || 3005,
  hostname: "0.0.0.0", // Listen on all network interfaces
  fetch: app.fetch,
  idleTimeout: 255,
  error(error: Error) {
    console.error("🚨 Server error:", error);
  },
  async onstart(server: any) {
    console.log(`🚀 Server started successfully on port ${server.port}`);
    console.log(`📡 Health check: http://localhost:${server.port}/api/health`);
  },
};
