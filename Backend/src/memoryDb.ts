// Temporary in-memory database for testing reviews with new table structure
let productReviews: any[] = [];
let shopReviews: any[] = [];

interface ProductReview {
  id: string;
  customer_id: string;
  customer_name: string;
  customer_email: string;
  subcat_id: string;
  product_name: string;
  shop_owner_id: string;
  shop_name: string;
  rating: number;
  comment: string;
  order_id?: string;
  is_verified_purchase: boolean;
  helpful_count: number;
  created_at: string;
  updated_at: string;
}

interface ShopReview {
  id: string;
  customer_id: string;
  customer_name: string;
  customer_email: string;
  shop_owner_id: string;
  shop_name: string;
  overall_rating: number;
  service_rating?: number;
  delivery_rating?: number;
  comment: string;
  order_id?: string;
  is_verified_purchase: boolean;
  helpful_count: number;
  created_at: string;
  updated_at: string;
}

export const memoryDb = {
  // ====================================
  // PRODUCT REVIEWS
  // ====================================

  // Create a product review
  async createProductReview(reviewData: ProductReview) {
    const review = {
      ...reviewData,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      helpful_count: 0,
    };

    productReviews.push(review);
    console.log("Product review saved to memory:", review.id);
    return review;
  },

  // Get product reviews by subcat_id (and optionally shop_owner_id)
  async getProductReviews(subcatId: string, shopOwnerId?: string) {
    let filteredReviews = productReviews.filter(
      (review) => review.subcat_id === subcatId
    );

    if (shopOwnerId) {
      filteredReviews = filteredReviews.filter(
        (review) => review.shop_owner_id === shopOwnerId
      );
    }

    console.log(
      `Found ${filteredReviews.length} product reviews for subcat: ${subcatId}, shop: ${shopOwnerId}`
    );
    return filteredReviews;
  },

  // Get all product reviews by a specific customer
  async getCustomerProductReviews(customerId: string) {
    const customerReviews = productReviews.filter(
      (review) => review.customer_id === customerId
    );
    console.log(
      `Found ${customerReviews.length} product reviews by customer: ${customerId}`
    );
    return customerReviews;
  },

  // Update a product review
  async updateProductReview(
    reviewId: string,
    updateData: Partial<ProductReview>
  ) {
    const reviewIndex = productReviews.findIndex(
      (review) => review.id === reviewId
    );

    if (reviewIndex === -1) {
      console.log(`Product review not found: ${reviewId}`);
      return null;
    }

    productReviews[reviewIndex] = {
      ...productReviews[reviewIndex],
      ...updateData,
      updated_at: new Date().toISOString(),
    };

    console.log("Product review updated:", reviewId);
    return productReviews[reviewIndex];
  },

  // Delete a product review
  async deleteProductReview(reviewId: string) {
    const reviewIndex = productReviews.findIndex(
      (review) => review.id === reviewId
    );

    if (reviewIndex === -1) {
      console.log(`Product review not found: ${reviewId}`);
      return false;
    }

    productReviews.splice(reviewIndex, 1);
    console.log("Product review deleted:", reviewId);
    return true;
  },

  // Get average rating for a product
  async getProductAverageRating(subcatId: string, shopOwnerId?: string) {
    const reviews = await this.getProductReviews(subcatId, shopOwnerId);

    if (reviews.length === 0) {
      return { average: 0, count: 0 };
    }

    const average =
      reviews.reduce((sum, review) => sum + review.rating, 0) / reviews.length;
    return { average: Math.round(average * 10) / 10, count: reviews.length };
  },

  // ====================================
  // SHOP REVIEWS
  // ====================================

  // Create a shop review
  async createShopReview(reviewData: ShopReview) {
    const review = {
      ...reviewData,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      helpful_count: 0,
    };

    shopReviews.push(review);
    console.log("Shop review saved to memory:", review.id);
    return review;
  },

  // Get shop reviews by shop_owner_id
  async getShopReviews(shopOwnerId: string) {
    const filteredReviews = shopReviews.filter(
      (review) => review.shop_owner_id === shopOwnerId
    );

    console.log(
      `Found ${filteredReviews.length} shop reviews for shop: ${shopOwnerId}`
    );
    return filteredReviews;
  },

  // Get all shop reviews by a specific customer
  async getCustomerShopReviews(customerId: string) {
    const customerReviews = shopReviews.filter(
      (review) => review.customer_id === customerId
    );
    console.log(
      `Found ${customerReviews.length} shop reviews by customer: ${customerId}`
    );
    return customerReviews;
  },

  // Update a shop review
  async updateShopReview(reviewId: string, updateData: Partial<ShopReview>) {
    const reviewIndex = shopReviews.findIndex(
      (review) => review.id === reviewId
    );

    if (reviewIndex === -1) {
      console.log(`Shop review not found: ${reviewId}`);
      return null;
    }

    shopReviews[reviewIndex] = {
      ...shopReviews[reviewIndex],
      ...updateData,
      updated_at: new Date().toISOString(),
    };

    console.log("Shop review updated:", reviewId);
    return shopReviews[reviewIndex];
  },

  // Delete a shop review
  async deleteShopReview(reviewId: string) {
    const reviewIndex = shopReviews.findIndex(
      (review) => review.id === reviewId
    );

    if (reviewIndex === -1) {
      console.log(`Shop review not found: ${reviewId}`);
      return false;
    }

    shopReviews.splice(reviewIndex, 1);
    console.log("Shop review deleted:", reviewId);
    return true;
  },

  // Get average ratings for a shop
  async getShopAverageRatings(shopOwnerId: string) {
    const reviews = await this.getShopReviews(shopOwnerId);

    if (reviews.length === 0) {
      return {
        overall: 0,
        service: 0,
        delivery: 0,
        count: 0,
      };
    }

    const overallAvg =
      reviews.reduce((sum, review) => sum + review.overall_rating, 0) /
      reviews.length;
    const serviceAvg =
      reviews.reduce(
        (sum, review) => sum + (review.service_rating || review.overall_rating),
        0
      ) / reviews.length;
    const deliveryAvg =
      reviews.reduce(
        (sum, review) =>
          sum + (review.delivery_rating || review.overall_rating),
        0
      ) / reviews.length;

    return {
      overall: Math.round(overallAvg * 10) / 10,
      service: Math.round(serviceAvg * 10) / 10,
      delivery: Math.round(deliveryAvg * 10) / 10,
      count: reviews.length,
    };
  },

  // ====================================
  // UTILITY METHODS
  // ====================================

  // Get all reviews (for debugging)
  async getAllReviews() {
    return {
      productReviews: productReviews,
      shopReviews: shopReviews,
      productCount: productReviews.length,
      shopCount: shopReviews.length,
    };
  },

  // Clear all reviews (for testing)
  async clearAllReviews() {
    productReviews = [];
    shopReviews = [];
    console.log("All reviews cleared from memory");
    return true;
  },

  // ====================================
  // LEGACY METHODS (for backward compatibility)
  // ====================================

  // Legacy method - redirects to product reviews
  async createReview(reviewData: any) {
    console.log(
      "Using legacy createReview method, redirecting to createProductReview"
    );
    return this.createProductReview({
      id:
        reviewData.id ||
        `product_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      customer_id: reviewData.customerId,
      customer_name: reviewData.customerName || "Anonymous",
      customer_email: reviewData.customerEmail || "anonymous@example.com",
      subcat_id: reviewData.subcatId || "unknown",
      product_name: reviewData.productName,
      shop_owner_id: reviewData.shopOwnerId || "unknown",
      shop_name: reviewData.shopName,
      rating: reviewData.rating,
      comment: reviewData.comment || "",
      order_id: reviewData.orderId,
      is_verified_purchase: reviewData.isVerifiedPurchase || false,
      helpful_count: 0,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });
  },

  // Legacy method - redirects to product reviews
  async getReviewsByProduct(productName: string) {
    console.log("Using legacy getReviewsByProduct method");
    return productReviews.filter(
      (review) => review.product_name === productName
    );
  },

  // Legacy method - redirects to customer reviews
  async getReviewsByUser(customerEmail: string) {
    console.log("Using legacy getReviewsByUser method");
    return productReviews.filter(
      (review) => review.customer_email === customerEmail
    );
  },

  // Legacy method - redirects to shop reviews
  async getShopReviewsByUser(customerEmail: string) {
    console.log("Using legacy getShopReviewsByUser method");
    return shopReviews.filter(
      (review) => review.customer_email === customerEmail
    );
  },
};
