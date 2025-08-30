import { Context } from 'hono';
import { memoryDb } from '../memoryDb';

export class ReviewController {
  constructor() {
    // No database connection needed for memory storage
  }

  // Create a new product/shop review
  async createReview(c: Context) {
    try {
      const body = await c.req.json();
      console.log('Creating review with data:', body);

      const {
        customerId,
        shopOwnerId,
        orderId,
        subcatId,
        rating,
        comment,
        productName,
        shopName,
        deliveryRating = 5,
        serviceRating = 5,
        isVerifiedPurchase = false,
        customerName = 'Anonymous Customer'
      } = body;

      // Validate required fields
      if (!customerId || !rating || rating < 1 || rating > 5) {
        return c.json({ 
          success: false,
          error: 'Missing or invalid required fields: customerId and rating (1-5) are required' 
        }, 400);
      }

      // Create review using memory database
      const review = await memoryDb.createReview({
        id: '', // Will be generated
        customerId,
        shopOwnerId: shopOwnerId || 'unknown',
        rating,
        comment: comment || '',
        productName: productName || 'Unknown Product',
        shopName: shopName || 'Unknown Shop',
        deliveryRating,
        serviceRating,
        isVerifiedPurchase,
        customerName,
        helpfulCount: 0,
        createdAt: new Date()
      });

      console.log('Review created successfully:', review.id);

      return c.json({
        success: true,
        message: 'Review created successfully',
        reviewId: review.id,
        review: review
      });
    } catch (error) {
      console.error('Error creating review:', error);
      return c.json({ 
        success: false,
        error: 'Failed to create review',
        details: error instanceof Error ? error.message : 'Unknown error'
      }, 500);
    }
  }

  // Get reviews for a specific product
  async getProductReviews(c: Context) {
    try {
      const productName = c.req.param('productName');
      if (!productName) {
        return c.json({ 
          success: false,
          error: 'Product name is required' 
        }, 400);
      }

      console.log('Getting reviews for product:', productName);
      
      const reviews = await memoryDb.getReviewsByProduct(decodeURIComponent(productName));
      
      // Format reviews for frontend
      const formattedReviews = reviews.map(review => ({
        ...review,
        customerName: review.customerName || 'Anonymous',
        reviewDate: review.createdAt,
        helpful: review.helpfulCount || 0,
        isVerifiedPurchase: review.isVerifiedPurchase || false
      }));

      return c.json({
        success: true,
        reviews: formattedReviews,
        count: formattedReviews.length
      });
    } catch (error) {
      console.error('Error getting product reviews:', error);
      return c.json({ 
        success: false,
        error: 'Failed to get reviews',
        details: error instanceof Error ? error.message : 'Unknown error'
      }, 500);
    }
  }

  // Get average rating for a product
  async getProductAverageRating(c: Context) {
    try {
      const productName = c.req.param('productName');
      if (!productName) {
        return c.json({ 
          success: false,
          error: 'Product name is required' 
        }, 400);
      }

      console.log('Getting average rating for product:', productName);
      
      const result = await memoryDb.getProductAverageRating(decodeURIComponent(productName));

      return c.json({
        success: true,
        averageRating: result.averageRating,
        totalReviews: result.totalReviews
      });
    } catch (error) {
      console.error('Error getting product average rating:', error);
      return c.json({ 
        success: false,
        error: 'Failed to get average rating',
        details: error instanceof Error ? error.message : 'Unknown error'
      }, 500);
    }
  }

  // Get all reviews by shop
  async getShopReviews(c: Context) {
    try {
      const shopId = c.req.param('shopId');
      if (!shopId) {
        return c.json({ 
          success: false,
          error: 'Shop ID is required' 
        }, 400);
      }

      const reviews = await memoryDb.getReviewsByShop(shopId);

      return c.json({
        success: true,
        reviews: reviews,
        count: reviews.length
      });
    } catch (error) {
      console.error('Error getting shop reviews:', error);
      return c.json({ 
        success: false,
        error: 'Failed to get shop reviews',
        details: error instanceof Error ? error.message : 'Unknown error'
      }, 500);
    }
  }

  // Get all reviews by customer  
  async getCustomerReviews(c: Context) {
    try {
      const customerId = c.req.param('customerId');
      if (!customerId) {
        return c.json({ 
          success: false,
          error: 'Customer ID is required' 
        }, 400);
      }

      const reviews = await memoryDb.getReviewsByCustomer(customerId);

      return c.json({
        success: true,
        reviews: reviews,
        count: reviews.length
      });
    } catch (error) {
      console.error('Error getting customer reviews:', error);
      return c.json({ 
        success: false,
        error: 'Failed to get customer reviews',
        details: error instanceof Error ? error.message : 'Unknown error'
      }, 500);
    }
  }

  // Debug endpoint to get all reviews
  async getAllReviews(c: Context) {
    try {
      const reviews = await memoryDb.getAllReviews();
      
      return c.json({
        success: true,
        reviews: reviews,
        count: reviews.length,
        message: `Found ${reviews.length} reviews in memory`
      });
    } catch (error) {
      console.error('Error getting all reviews:', error);
      return c.json({ 
        success: false,
        error: 'Failed to get reviews',
        details: error instanceof Error ? error.message : 'Unknown error'
      }, 500);
    }
  }
}
