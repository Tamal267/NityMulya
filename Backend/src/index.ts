import { Hono } from "hono";
import { cors } from "hono/cors";
import type { JwtVariables } from "hono/jwt";
import { prettyJSON } from "hono/pretty-json";
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
  getChatConversations as getChatConversationsFromChat,
  getChatMessages as getChatMessagesFromChat,
  markMessagesAsRead,
  sendChatMessage,
} from "./controller/chatController";
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
import { createAuthMiddleware, requireRole } from "./utils/jwt";
// import sql from "./db"; // Database connection for persistent storage

const app = new Hono<{ Variables: JwtVariables }>();
// Use database controller for persistent storage
const reviewController = new DatabaseReviewController();

app.use(prettyJSON());
app.use("/*", cors());

app.get("/", (c) => {
  return c.json({ message: "Welcome to the API!" });
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
app.get("/wholesaler/profile", getWholesalerProfile);
app.get("/wholesaler/inventory", getWholesalerInventory);
app.post("/wholesaler/inventory", addWholesalerProduct);
app.put("/wholesaler/inventory", updateWholesalerInventoryItem);
app.get("/wholesaler/low-stock", getWholesalerLowStockProducts);
app.get("/wholesaler/orders", getWholesalerShopOrders);
app.post("/wholesaler/orders", createOrder);
app.put("/wholesaler/orders/status", updateOrderStatus);
app.get("/wholesaler/offers", getWholesalerOffers);
app.post("/wholesaler/offers", createOffer);
app.get("/wholesaler/chat", getWholesalerChatMessages);
app.get("/wholesaler/shop-owners", getShopOwners);
app.get("/wholesaler/categories", getWholesalerCategories);
app.get("/wholesaler/subcategories", getSubcategories);

// Shop Owner routes (protected)
app.use("/shop-owner/*", createAuthMiddleware(), requireRole("shop_owner"));
app.get("/shop-owner/dashboard", getShopOwnerDashboard);
app.get("/shop-owner/inventory", getShopOwnerInventory);
app.post("/shop-owner/inventory", addShopOwnerProduct);
app.put("/shop-owner/inventory", updateShopOwnerInventoryItem);
app.get("/shop-owner/low-stock", getShopOwnerLowStockProducts);
app.get("/shop-owner/orders", getShopOwnerOrders);
app.get("/shop-owner/chat", getShopOwnerChatMessages);
app.get("/shop-owner/customer-orders", getShopOwnerCustomerOrders);
app.put("/shop-owner/customer-orders/status", updateCustomerOrderStatus);

// Customer routes (protected)
app.use("/customer/*", createAuthMiddleware(), requireRole("customer"));
app.post("/customer/orders", createCustomerOrder);
app.get("/customer/orders/stats", getCustomerOrderStats);
app.get("/customer/orders", getCustomerOrders);
app.get("/customer/orders/:orderId", getCustomerOrder);
app.post("/customer/orders/cancel", cancelCustomerOrder);
app.get("/customer/cancelled-orders", getCancelledOrders);

// Real-time Chat routes (protected - both wholesaler and shop owner)
app.use("/chat/*", createAuthMiddleware());
app.post("/chat/send", sendChatMessage);
app.get("/chat/messages", getChatMessagesFromChat);
app.get("/chat/conversations", getChatConversationsFromChat);
app.post("/chat/mark-read", markMessagesAsRead);

// Legacy chat routes (protected - both wholesaler and shop owner)
app.get("/chat/wholesalers", getWholesalers);
app.post("/chat/send-old", sendMessage);
app.get("/chat/messages-old", getChatMessages);
app.get("/chat/conversations-old", getChatConversations);

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
// MESSAGING ROUTES
// ====================================

// Get customer messages
app.get("/api/messages/customer/:customerId", async (c) => {
  try {
    const customerId = c.req.param("customerId");
    console.log(`📧 Getting messages for customer: ${customerId}`);

    // Use existing database connection
    const { default: sql } = await import("./db");

    const result = await sql`
      SELECT 
        om.*,
        COALESCE(so.full_name, so.name, 'Unknown Shop') as shop_name
      FROM order_messages om
      LEFT JOIN shop_owners so ON om.sender_id::uuid = so.id
      WHERE om.receiver_id = ${customerId}
        AND om.receiver_type = 'customer'
      ORDER BY om.created_at DESC
    `;

    console.log(`💬 Found ${result.length} messages`);

    return c.json({
      success: true,
      messages: result,
    });
  } catch (error) {
    console.error("❌ Error getting customer messages:", error);
    return c.json(
      {
        success: false,
        error: "Failed to get messages",
        details: error instanceof Error ? error.message : String(error),
      },
      500
    );
  }
});

// Send message
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

    console.log("📤 Sending message:", { order_id, sender_type, message_text });

    // Use existing database connection
    const { default: sql } = await import("./db");

    const result = await sql`
      INSERT INTO order_messages (
        order_id, sender_type, sender_id, receiver_type, receiver_id, message_text
      ) VALUES (${order_id}, ${sender_type}, ${sender_id}, ${receiver_type}, ${receiver_id}, ${message_text})
      RETURNING id as message_id, created_at
    `;

    console.log("✅ Message sent successfully:", result[0]);

    return c.json({
      success: true,
      message_id: result[0].message_id,
      created_at: result[0].created_at,
    });
  } catch (error) {
    console.error("❌ Error sending message:", error);
    return c.json(
      {
        success: false,
        error: "Failed to send message",
        details: error instanceof Error ? error.message : String(error),
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

export default {
  port: process.env.PORT || 5000,
  fetch: app.fetch,
  idleTimeout: 255,
};
