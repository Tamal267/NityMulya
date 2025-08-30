// Temporary in-memory database for testing reviews
let reviews: any[] = [];

interface Review {
  id: string;
  customerId: string;
  shopOwnerId?: string;
  rating: number;
  comment: string;
  productName: string;
  shopName: string;
  deliveryRating?: number;
  serviceRating?: number;
  helpfulCount: number;
  isVerifiedPurchase: boolean;
  createdAt: Date;
  customerName?: string;
}

export const memoryDb = {
  // Create a review
  async createReview(reviewData: Review) {
    const review = {
      ...reviewData,
      id: `review_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      createdAt: new Date(),
      helpfulCount: 0
    };
    
    reviews.push(review);
    console.log('Review saved to memory:', review.id);
    return review;
  },

  // Get reviews by product name
  async getReviewsByProduct(productName: string) {
    const productReviews = reviews.filter(review => 
      review.productName === productName
    );
    console.log(`Found ${productReviews.length} reviews for product: ${productName}`);
    return productReviews;
  },

  // Get average rating for a product
  async getProductAverageRating(productName: string) {
    const productReviews = reviews.filter(review => 
      review.productName === productName
    );
    
    if (productReviews.length === 0) {
      return { averageRating: 0, totalReviews: 0 };
    }
    
    const totalRating = productReviews.reduce((sum, review) => sum + review.rating, 0);
    const averageRating = totalRating / productReviews.length;
    
    return { 
      averageRating: Math.round(averageRating * 100) / 100, 
      totalReviews: productReviews.length 
    };
  },

  // Get reviews by shop
  async getReviewsByShop(shopId: string) {
    const shopReviews = reviews.filter(review => 
      review.shopOwnerId === shopId
    );
    return shopReviews;
  },

  // Get reviews by customer
  async getReviewsByCustomer(customerId: string) {
    const customerReviews = reviews.filter(review => 
      review.customerId === customerId
    );
    return customerReviews;
  },

  // Get all reviews (for debugging)
  async getAllReviews() {
    console.log(`Total reviews in memory: ${reviews.length}`);
    return reviews;
  }
};

export { reviews };
