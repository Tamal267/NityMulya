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
  cancelCustomerOrder,
  createCustomerOrder,
  getCustomerOrder,
  getCustomerOrders,
  getCustomerOrderStats,
  getShopOwnerCustomerOrders,
  updateCustomerOrderStatus,
} from "./controller/customerOrderController";
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
  getShopOrders as getWholesalerShopOrders,
  updateOrderStatus,
  updateInventoryItem as updateWholesalerInventoryItem,
} from "./controller/wholesalerController";
import { ReviewController } from "./controller/reviewController";
import { createAuthMiddleware, requireRole } from "./utils/jwt";
// import sql from "./db"; // Commented out since using memory database

const app = new Hono<{ Variables: JwtVariables }>();
const reviewController = new ReviewController(); // No sql parameter needed

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

// Chat routes (protected - both wholesaler and shop owner)
app.use("/chat/*", createAuthMiddleware());
app.get("/chat/wholesalers", getWholesalers);
app.post("/chat/send", sendMessage);
app.get("/chat/messages", getChatMessages);
app.get("/chat/conversations", getChatConversations);

// Review routes - Public for viewing, protected for creating
app.get("/reviews/product/:productName", reviewController.getProductReviews.bind(reviewController));
app.get("/reviews/shop/:shopId", reviewController.getShopReviews.bind(reviewController));
app.get("/reviews/customer/:customerId", reviewController.getCustomerReviews.bind(reviewController));
app.get("/reviews/product/:productName/average", reviewController.getProductAverageRating.bind(reviewController));
app.get("/reviews/shop/:shopId/average", reviewController.getShopAverageRating.bind(reviewController));
app.get("/reviews/shop/:shopId/stats", reviewController.getReviewStats.bind(reviewController));

// Protected review routes - require customer authentication
app.use("/reviews/create", createAuthMiddleware(), requireRole("customer"));
app.post("/reviews/create", reviewController.createReview.bind(reviewController));

app.use("/reviews/helpful/*", createAuthMiddleware());
app.put("/reviews/helpful/:reviewId", reviewController.markReviewHelpful.bind(reviewController));

app.use("/reviews/delete/*", createAuthMiddleware(), requireRole("customer"));
app.delete("/reviews/delete/:reviewId", reviewController.deleteReview.bind(reviewController));

export default {
  port: process.env.PORT || 5001,
  fetch: app.fetch,
  idleTimeout: 255,
};
