import { Context } from 'hono';
import { Sql } from 'postgres';

export class ReviewController {
  constructor(private sql: Sql) {}

  // Create a new product/shop review
  async createReview(c: Context) {
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
        isVerifiedPurchase
      } = body;

      // Validate required fields
      if (!customerId || !shopOwnerId || !rating || rating < 1 || rating > 5) {
        return c.json({ error: 'Missing or invalid required fields' }, 400);
      }

      const reviewId = crypto.randomUUID();
      
      await this.sql`
        INSERT INTO customer_reviews (
          id, customer_id, shop_owner_id, order_id, subcat_id,
          rating, comment, product_name, shop_name, delivery_rating,
          service_rating, is_verified_purchase
        ) VALUES (
          ${reviewId}, ${customerId}, ${shopOwnerId}, ${orderId || null}, ${subcatId || null},
          ${rating}, ${comment || ''}, ${productName || null}, ${shopName || null}, 
          ${deliveryRating || null}, ${serviceRating || null}, ${isVerifiedPurchase || false}
        )
      `;

      return c.json({
        success: true,
        message: 'Review created successfully',
        reviewId: reviewId
      });
    } catch (error) {
      console.error('Error creating review:', error);
      return c.json({ error: 'Failed to create review' }, 500);
    }
  }

  // Get all reviews for a specific product (by subcategory)
  async getProductReviews(c: Context) {
    try {
      const productName = c.req.param('productName');
      const subcatId = c.req.query('subcatId');
      
      if (!productName && !subcatId) {
        return c.json({ error: 'Product name or subcategory ID required' }, 400);
      }

      let reviews: any[] = [];
      
      if (productName && subcatId) {
        reviews = await this.sql`
          SELECT 
            r.id,
            r.rating,
            r.comment,
            r.product_name,
            r.shop_name,
            r.helpful_count,
            r.is_verified_purchase,
            r.created_at,
            c.full_name as customer_name,
            c.id as customer_id
          FROM customer_reviews r
          JOIN customers c ON r.customer_id = c.id
          WHERE r.product_name IS NOT NULL
            AND r.product_name = ${productName}
            AND r.subcat_id = ${subcatId}
          ORDER BY r.created_at DESC
        `;
      } else if (productName) {
        reviews = await this.sql`
          SELECT 
            r.id,
            r.rating,
            r.comment,
            r.product_name,
            r.shop_name,
            r.helpful_count,
            r.is_verified_purchase,
            r.created_at,
            c.full_name as customer_name,
            c.id as customer_id
          FROM customer_reviews r
          JOIN customers c ON r.customer_id = c.id
          WHERE r.product_name IS NOT NULL
            AND r.product_name = ${productName}
          ORDER BY r.created_at DESC
        `;
      } else if (subcatId) {
        reviews = await this.sql`
          SELECT 
            r.id,
            r.rating,
            r.comment,
            r.product_name,
            r.shop_name,
            r.helpful_count,
            r.is_verified_purchase,
            r.created_at,
            c.full_name as customer_name,
            c.id as customer_id
          FROM customer_reviews r
          JOIN customers c ON r.customer_id = c.id
          WHERE r.product_name IS NOT NULL
            AND r.subcat_id = ${subcatId}
          ORDER BY r.created_at DESC
        `;
      }

      return c.json({
        success: true,
        reviews: reviews.map((review: any) => ({
          ...review,
          reviewDate: review.created_at,
          customerName: review.customer_name,
          customerId: review.customer_id,
          helpful: review.helpful_count,
          isVerifiedPurchase: Boolean(review.is_verified_purchase)
        }))
      });
    } catch (error) {
      console.error('Error fetching product reviews:', error);
      return c.json({ error: 'Failed to fetch product reviews' }, 500);
    }
  }

  // Get all reviews for a specific shop
  async getShopReviews(c: Context) {
    try {
      const shopId = c.req.param('shopId');
      
      if (!shopId) {
        return c.json({ error: 'Shop ID required' }, 400);
      }

      const reviews = await this.sql`
        SELECT 
          r.id,
          r.rating,
          r.delivery_rating,
          r.service_rating,
          r.comment,
          r.shop_name,
          r.helpful_count,
          r.is_verified_purchase,
          r.created_at,
          c.full_name as customer_name,
          c.id as customer_id
        FROM customer_reviews r
        JOIN customers c ON r.customer_id = c.id
        WHERE r.shop_owner_id = ${shopId}
        ORDER BY r.created_at DESC
      `;

      return c.json({
        success: true,
        reviews: reviews.map((review: any) => ({
          ...review,
          reviewDate: review.created_at,
          customerName: review.customer_name,
          customerId: review.customer_id,
          helpful: review.helpful_count,
          isVerifiedPurchase: Boolean(review.is_verified_purchase),
          deliveryRating: review.delivery_rating,
          serviceRating: review.service_rating
        }))
      });
    } catch (error) {
      console.error('Error fetching shop reviews:', error);
      return c.json({ error: 'Failed to fetch shop reviews' }, 500);
    }
  }

  // Get all reviews by a specific customer
  async getCustomerReviews(c: Context) {
    try {
      const customerId = c.req.param('customerId');
      
      if (!customerId) {
        return c.json({ error: 'Customer ID required' }, 400);
      }

      const reviews = await this.sql`
        SELECT 
          r.id,
          r.rating,
          r.delivery_rating,
          r.service_rating,
          r.comment,
          r.product_name,
          r.shop_name,
          r.helpful_count,
          r.is_verified_purchase,
          r.created_at,
          c.full_name as customer_name
        FROM customer_reviews r
        JOIN customers c ON r.customer_id = c.id
        WHERE r.customer_id = ${customerId}
        ORDER BY r.created_at DESC
      `;

      return c.json({
        success: true,
        reviews: reviews.map((review: any) => ({
          ...review,
          reviewDate: review.created_at,
          customerName: review.customer_name,
          helpful: review.helpful_count,
          isVerifiedPurchase: Boolean(review.is_verified_purchase),
          deliveryRating: review.delivery_rating,
          serviceRating: review.service_rating
        }))
      });
    } catch (error) {
      console.error('Error fetching customer reviews:', error);
      return c.json({ error: 'Failed to fetch customer reviews' }, 500);
    }
  }

  // Get average rating for a product
  async getProductAverageRating(c: Context) {
    try {
      const productName = c.req.param('productName');
      const subcatId = c.req.query('subcatId');
      
      if (!productName && !subcatId) {
        return c.json({ error: 'Product name or subcategory ID required' }, 400);
      }

      let result: any[] = [];
      
      if (productName && subcatId) {
        result = await this.sql`
          SELECT 
            AVG(rating) as average_rating,
            COUNT(*) as total_reviews
          FROM customer_reviews
          WHERE product_name IS NOT NULL
            AND product_name = ${productName}
            AND subcat_id = ${subcatId}
        `;
      } else if (productName) {
        result = await this.sql`
          SELECT 
            AVG(rating) as average_rating,
            COUNT(*) as total_reviews
          FROM customer_reviews
          WHERE product_name IS NOT NULL
            AND product_name = ${productName}
        `;
      } else if (subcatId) {
        result = await this.sql`
          SELECT 
            AVG(rating) as average_rating,
            COUNT(*) as total_reviews
          FROM customer_reviews
          WHERE product_name IS NOT NULL
            AND subcat_id = ${subcatId}
        `;
      }

      return c.json({
        success: true,
        averageRating: result[0]?.average_rating || 0,
        totalReviews: result[0]?.total_reviews || 0
      });
    } catch (error) {
      console.error('Error calculating product average rating:', error);
      return c.json({ error: 'Failed to calculate average rating' }, 500);
    }
  }

  // Get average ratings for a shop
  async getShopAverageRating(c: Context) {
    try {
      const shopId = c.req.param('shopId');
      
      if (!shopId) {
        return c.json({ error: 'Shop ID required' }, 400);
      }

      const result = await this.sql`
        SELECT 
          AVG(rating) as overall_rating,
          AVG(delivery_rating) as delivery_rating,
          AVG(service_rating) as service_rating,
          COUNT(*) as total_reviews
        FROM customer_reviews
        WHERE shop_owner_id = ${shopId}
      `;

      return c.json({
        success: true,
        ratings: {
          overall: result[0]?.overall_rating || 0,
          delivery: result[0]?.delivery_rating || 0,
          service: result[0]?.service_rating || 0
        },
        totalReviews: result[0]?.total_reviews || 0
      });
    } catch (error) {
      console.error('Error calculating shop average rating:', error);
      return c.json({ error: 'Failed to calculate shop average rating' }, 500);
    }
  }

  // Mark a review as helpful
  async markReviewHelpful(c: Context) {
    try {
      const reviewId = c.req.param('reviewId');
      
      if (!reviewId) {
        return c.json({ error: 'Review ID required' }, 400);
      }

      await this.sql`
        UPDATE customer_reviews 
        SET helpful_count = helpful_count + 1,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = ${reviewId}
      `;

      return c.json({
        success: true,
        message: 'Review marked as helpful'
      });
    } catch (error) {
      console.error('Error marking review as helpful:', error);
      return c.json({ error: 'Failed to mark review as helpful' }, 500);
    }
  }

  // Delete a review (only by the customer who wrote it)
  async deleteReview(c: Context) {
    try {
      const reviewId = c.req.param('reviewId');
      const customerId = c.req.query('customerId');
      
      if (!reviewId || !customerId) {
        return c.json({ error: 'Review ID and customer ID required' }, 400);
      }

      await this.sql`
        DELETE FROM customer_reviews 
        WHERE id = ${reviewId} AND customer_id = ${customerId}
      `;

      return c.json({
        success: true,
        message: 'Review deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting review:', error);
      return c.json({ error: 'Failed to delete review' }, 500);
    }
  }

  // Get review statistics for a shop owner dashboard
  async getReviewStats(c: Context) {
    try {
      const shopId = c.req.param('shopId');
      
      if (!shopId) {
        return c.json({ error: 'Shop ID required' }, 400);
      }

      const stats = await this.sql`
        SELECT 
          COUNT(*) as total_reviews,
          AVG(rating) as average_rating,
          COUNT(CASE WHEN rating = 5 THEN 1 END) as five_star,
          COUNT(CASE WHEN rating = 4 THEN 1 END) as four_star,
          COUNT(CASE WHEN rating = 3 THEN 1 END) as three_star,
          COUNT(CASE WHEN rating = 2 THEN 1 END) as two_star,
          COUNT(CASE WHEN rating = 1 THEN 1 END) as one_star
        FROM customer_reviews
        WHERE shop_owner_id = ${shopId}
      `;

      return c.json({
        success: true,
        stats: {
          totalReviews: stats[0]?.total_reviews || 0,
          averageRating: stats[0]?.average_rating || 0,
          ratingDistribution: {
            5: stats[0]?.five_star || 0,
            4: stats[0]?.four_star || 0,
            3: stats[0]?.three_star || 0,
            2: stats[0]?.two_star || 0,
            1: stats[0]?.one_star || 0
          }
        }
      });
    } catch (error) {
      console.error('Error fetching review stats:', error);
      return c.json({ error: 'Failed to fetch review statistics' }, 500);
    }
  }
}
