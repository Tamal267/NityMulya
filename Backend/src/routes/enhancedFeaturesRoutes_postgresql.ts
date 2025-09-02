import { Hono } from "hono";
import { 
  // Favourites
  getFavourites, 
  addToFavourites, 
  removeFromFavourites,
  
  // Price History
  getPriceHistory, 
  addPriceHistory,
  
  // Reviews
  getReviews, 
  addReview,
  
  // Complaints
  getComplaints, 
  submitComplaint, 
  updateComplaintStatus
} from "../controller/enhancedFeaturesController_postgresql";

const app = new Hono();

// ================================
// FAVOURITES ROUTES
// ================================

// GET /api/enhanced/favourites/:customerId
app.get("/favourites/:customerId", getFavourites);

// POST /api/enhanced/favourites
app.post("/favourites", addToFavourites);

// DELETE /api/enhanced/favourites/:customerId/:shopId/:productId
app.delete("/favourites/:customerId/:shopId/:productId", removeFromFavourites);

// ================================
// PRICE HISTORY ROUTES
// ================================

// GET /api/enhanced/price-history/:productId/:shopId
app.get("/price-history/:productId/:shopId", getPriceHistory);

// POST /api/enhanced/price-history
app.post("/price-history", addPriceHistory);

// ================================
// REVIEWS ROUTES
// ================================

// GET /api/enhanced/reviews/:shopId
app.get("/reviews/:shopId", getReviews);

// POST /api/enhanced/reviews
app.post("/reviews", addReview);

// ================================
// COMPLAINTS ROUTES
// ================================

// GET /api/enhanced/complaints/:customerId
app.get("/complaints/:customerId", getComplaints);

// POST /api/enhanced/complaints
app.post("/complaints", submitComplaint);

// PUT /api/enhanced/complaints/:complaintId/status
app.put("/complaints/:complaintId/status", updateComplaintStatus);

// ================================
// HEALTH CHECK
// ================================

// GET /api/enhanced/health
app.get("/health", (c) => {
  return c.json({
    success: true,
    message: "Enhanced Features API is running with PostgreSQL",
    timestamp: new Date().toISOString(),
    database: "PostgreSQL"
  });
});

export default app;
