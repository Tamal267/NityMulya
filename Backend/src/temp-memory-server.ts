import { Hono } from "hono";
import { cors } from "hono/cors";

const app = new Hono();

// Enable CORS
app.use("/*", cors());

// In-memory storage for reviews (temporary solution)
let reviews: any[] = [];

// Basic route
app.get("/", (c) => {
  return c.json({
    message: "NityMulya Review API Server",
    status: "running",
    timestamp: new Date().toISOString(),
  });
});

// Create a review
app.post("/reviews/create", async (c) => {
  try {
    const body = await c.req.json();
    const {
      customerId,
      shopOwnerId,
      orderId,
      subcatId,
      rating,
      comment,
      productName,
      shopName,
      deliveryRating,
      serviceRating,
      isVerifiedPurchase,
    } = body;

    // Validate required fields
    if (!customerId || !shopOwnerId || !rating || rating < 1 || rating > 5) {
      return c.json({ error: "Missing or invalid required fields" }, 400);
    }

    const reviewId = crypto.randomUUID();
    const now = new Date();

    const review = {
      id: reviewId,
      customer_id: customerId,
      shop_owner_id: shopOwnerId,
      order_id: orderId || null,
      subcat_id: subcatId || null,
      rating: rating,
      comment: comment || "",
      product_name: productName || null,
      shop_name: shopName || null,
      delivery_rating: deliveryRating || null,
      service_rating: serviceRating || null,
      is_verified_purchase: isVerifiedPurchase || false,
      helpful_count: 0,
      created_at: now.toISOString(),
      // Add formatted fields for compatibility
      customer_name: `Customer ${customerId.slice(-3)}`,
      reviewDate: now.toISOString(),
      customerName: `Customer ${customerId.slice(-3)}`,
      customerId: customerId,
      helpful: 0,
      isVerifiedPurchase: isVerifiedPurchase || false,
    };

    reviews.push(review);

    console.log(`Review created for product: ${productName}`);
    console.log(`Total reviews in memory: ${reviews.length}`);

    return c.json({
      success: true,
      message: "Review created successfully",
      reviewId: reviewId,
    });
  } catch (error) {
    console.error("Error creating review:", error);
    return c.json(
      {
        success: false,
        error: "Failed to create review",
        details: error.message,
      },
      500
    );
  }
});

// Get reviews for a product
app.get("/reviews/product/:productName", async (c) => {
  try {
    const productName = decodeURIComponent(c.req.param("productName"));
    console.log(`Fetching reviews for product: "${productName}"`);

    const productReviews = reviews.filter(
      (review) => review.product_name === productName
    );

    console.log(`Found ${productReviews.length} reviews for "${productName}"`);

    return c.json({
      success: true,
      reviews: productReviews,
    });
  } catch (error) {
    console.error("Error fetching product reviews:", error);
    return c.json({
      success: false,
      error: "Failed to fetch reviews",
      reviews: [],
    });
  }
});

// Get average rating for a product
app.get("/reviews/product/:productName/average", async (c) => {
  try {
    const productName = decodeURIComponent(c.req.param("productName"));

    const productReviews = reviews.filter(
      (review) => review.product_name === productName
    );

    if (productReviews.length === 0) {
      return c.json({
        success: true,
        averageRating: 0,
        totalReviews: 0,
      });
    }

    const totalRating = productReviews.reduce(
      (sum, review) => sum + review.rating,
      0
    );
    const averageRating = totalRating / productReviews.length;

    return c.json({
      success: true,
      averageRating: averageRating.toFixed(2),
      totalReviews: productReviews.length,
    });
  } catch (error) {
    console.error("Error fetching average rating:", error);
    return c.json({
      success: false,
      averageRating: 0,
      totalReviews: 0,
    });
  }
});

// Get reviews for a shop
app.get("/reviews/shop/:shopId", async (c) => {
  try {
    const shopId = c.req.param("shopId");
    const shopReviews = reviews.filter(
      (review) => review.shop_owner_id === shopId
    );

    return c.json({
      success: true,
      reviews: shopReviews,
    });
  } catch (error) {
    console.error("Error fetching shop reviews:", error);
    return c.json({
      success: false,
      error: "Failed to fetch reviews",
      reviews: [],
    });
  }
});

// Get reviews for a customer
app.get("/reviews/customer/:customerId", async (c) => {
  try {
    const customerId = c.req.param("customerId");
    const customerReviews = reviews.filter(
      (review) => review.customer_id === customerId
    );

    return c.json({
      success: true,
      reviews: customerReviews,
    });
  } catch (error) {
    console.error("Error fetching customer reviews:", error);
    return c.json({
      success: false,
      error: "Failed to fetch reviews",
      reviews: [],
    });
  }
});

// Add some initial test data
const initTestData = () => {
  const testReviews = [
    {
      id: crypto.randomUUID(),
      customer_id: "customer1",
      shop_owner_id: "shop1",
      rating: 5,
      comment: "অসাধারণ মানের চাল! দাম অনুযায়ী খুবই ভালো।",
      product_name: "চাল",
      shop_name: "রহমান গ্রোসারি",
      is_verified_purchase: true,
      helpful_count: 12,
      created_at: new Date().toISOString(),
      customer_name: "আহমেদ হাসান",
      reviewDate: new Date().toISOString(),
      customerName: "আহমেদ হাসান",
      customerId: "customer1",
      helpful: 12,
      isVerifiedPurchase: true,
    },
    {
      id: crypto.randomUUID(),
      customer_id: "customer2",
      shop_owner_id: "shop2",
      rating: 4,
      comment: "ভালো কোয়ালিটি। ডেলিভারি একটু দেরি হয়েছিল।",
      product_name: "চাল",
      shop_name: "করিম স্টোর",
      is_verified_purchase: true,
      helpful_count: 8,
      created_at: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
      customer_name: "ফাতেমা খাতুন",
      reviewDate: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
      customerName: "ফাতেমা খাতুন",
      customerId: "customer2",
      helpful: 8,
      isVerifiedPurchase: true,
    },
  ];

  reviews.push(...testReviews);
  console.log(`Initialized with ${testReviews.length} test reviews`);
};

// Initialize test data
initTestData();

const port = 3001;
export default {
  port,
  fetch: app.fetch,
};
