
i import { Context } from "hono";
import { memoryDb } from "../memoryDb";

export class ReviewController {
  constructor() {
    // No database connection needed for memory storage
  }

  // Create a new product review
  async createProductReview(c: Context) {
    try {
      const body = await c.req.json();
      console.log("Creating product review with data:", body);

      const {
        customer_id,
        customer_name,
        customer_email,
        subcat_id,
        product_name,
        shop_owner_id,
        shop_name,
        rating,
        comment,
        order_id,
        is_verified_purchase = false,
      } = body;

      // Validate required fields
      if (
        !customer_id ||
        !customer_name ||
        !customer_email ||
        !subcat_id ||
        !product_name ||
        !shop_owner_id ||
        !shop_name ||
        !rating ||
        rating < 1 ||
        rating > 5
      ) {
        return c.json(
          {
            success: false,
            error: "Missing or invalid required fields for product review",
          },
          400
        );
      }

      // Create product review using memory database
      const review = await memoryDb.createProductReview({
        id: `product_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        customer_id,
        customer_name,
        customer_email,
        subcat_id,
        product_name,
        shop_owner_id,
        shop_name,
        rating,
        comment: comment || "",
        order_id: order_id || null,
        is_verified_purchase,
        helpful_count: 0,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      });

      console.log("Product review created successfully:", review.id);
      return c.json({
        success: true,
        message: "Product review created successfully",
        review,
      });
    } catch (error) {
      console.error("Error creating product review:", error);
      return c.json(
        {
          success: false,
          error: "Failed to create product review",
        },
        500
      );
    }
  }

  // Create a new shop review
  async createShopReview(c: Context) {
    try {
      const body = await c.req.json();
      console.log("Creating shop review with data:", body);

      const {
        customer_id,
        customer_name,
        customer_email,
        shop_owner_id,
        shop_name,
        overall_rating,
        service_rating,
        delivery_rating,
        comment,
        order_id,
        is_verified_purchase = false,
      } = body;

      // Validate required fields
      if (
        !customer_id ||
        !customer_name ||
        !customer_email ||
        !shop_owner_id ||
        !shop_name ||
        !overall_rating ||
        overall_rating < 1 ||
        overall_rating > 5
      ) {
        return c.json(
          {
            success: false,
            error: "Missing or invalid required fields for shop review",
          },
          400
        );
      }

      // Create shop review using memory database
      const review = await memoryDb.createShopReview({
        id: `shop_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        customer_id,
        customer_name,
        customer_email,
        shop_owner_id,
        shop_name,
        overall_rating,
        service_rating: service_rating || overall_rating,
        delivery_rating: delivery_rating || overall_rating,
        comment: comment || "",
        order_id: order_id || null,
        is_verified_purchase,
        helpful_count: 0,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      });

      console.log("Shop review created successfully:", review.id);
      return c.json({
        success: true,
        message: "Shop review created successfully",
        review,
      });
    } catch (error) {
      console.error("Error creating shop review:", error);
      return c.json(
        {
          success: false,
          error: "Failed to create shop review",
        },
        500
      );
    }
  }

  // Get all product reviews for a specific product (subcat_id)
  async getProductReviews(c: Context) {
    try {
      const subcatId = c.req.param("subcatId");
      const shopOwnerId = c.req.query("shopOwnerId"); // Optional filter by shop

      if (!subcatId) {
        return c.json(
          {
            success: false,
            error: "Product ID (subcatId) is required",
          },
          400
        );
      }

      console.log(
        `Getting product reviews for product: ${subcatId}, shop: ${shopOwnerId}`
      );

      const reviews = await memoryDb.getProductReviews(subcatId, shopOwnerId);

      return c.json({
        success: true,
        reviews: reviews || [],
      });
    } catch (error) {
      console.error("Error getting product reviews:", error);
      return c.json(
        {
          success: false,
          error: "Failed to get product reviews",
        },
        500
      );
    }
  }

  // Get all shop reviews for a specific shop
  async getShopReviews(c: Context) {
    try {
      const shopOwnerId = c.req.param("shopOwnerId");

      if (!shopOwnerId) {
        return c.json(
          {
            success: false,
            error: "Shop Owner ID is required",
          },
          400
        );
      }

      console.log(`Getting shop reviews for shop: ${shopOwnerId}`);

      const reviews = await memoryDb.getShopReviews(shopOwnerId);

      return c.json({
        success: true,
        reviews: reviews || [],
      });
    } catch (error) {
      console.error("Error getting shop reviews:", error);
      return c.json(
        {
          success: false,
          error: "Failed to get shop reviews",
        },
        500
      );
    }
  }

  // Get all reviews by a specific customer
  async getCustomerProductReviews(c: Context) {
    try {
      const customerId = c.req.param("customerId");

      if (!customerId) {
        return c.json(
          {
            success: false,
            error: "Customer ID is required",
          },
          400
        );
      }

      console.log(`Getting product reviews by customer: ${customerId}`);

      const reviews = await memoryDb.getCustomerProductReviews(customerId);

      return c.json({
        success: true,
        reviews: reviews || [],
      });
    } catch (error) {
      console.error("Error getting customer product reviews:", error);
      return c.json(
        {
          success: false,
          error: "Failed to get customer product reviews",
        },
        500
      );
    }
  }

  // Get all shop reviews by a specific customer
  async getCustomerShopReviews(c: Context) {
    try {
      const customerId = c.req.param("customerId");

      if (!customerId) {
        return c.json(
          {
            success: false,
            error: "Customer ID is required",
          },
          400
        );
      }

      console.log(`Getting shop reviews by customer: ${customerId}`);

      const reviews = await memoryDb.getCustomerShopReviews(customerId);

      return c.json({
        success: true,
        reviews: reviews || [],
      });
    } catch (error) {
      console.error("Error getting customer shop reviews:", error);
      return c.json(
        {
          success: false,
          error: "Failed to get customer shop reviews",
        },
        500
      );
    }
  }

  // Update a product review
  async updateProductReview(c: Context) {
    try {
      const reviewId = c.req.param("reviewId");
      const body = await c.req.json();

      if (!reviewId) {
        return c.json(
          {
            success: false,
            error: "Review ID is required",
          },
          400
        );
      }

      console.log(`Updating product review: ${reviewId}`);

      const updatedReview = await memoryDb.updateProductReview(reviewId, {
        ...body,
        updated_at: new Date().toISOString(),
      });

      if (!updatedReview) {
        return c.json(
          {
            success: false,
            error: "Product review not found",
          },
          404
        );
      }

      return c.json({
        success: true,
        message: "Product review updated successfully",
        review: updatedReview,
      });
    } catch (error) {
      console.error("Error updating product review:", error);
      return c.json(
        {
          success: false,
          error: "Failed to update product review",
        },
        500
      );
    }
  }

  // Update a shop review
  async updateShopReview(c: Context) {
    try {
      const reviewId = c.req.param("reviewId");
      const body = await c.req.json();

      if (!reviewId) {
        return c.json(
          {
            success: false,
            error: "Review ID is required",
          },
          400
        );
      }

      console.log(`Updating shop review: ${reviewId}`);

      const updatedReview = await memoryDb.updateShopReview(reviewId, {
        ...body,
        updated_at: new Date().toISOString(),
      });

      if (!updatedReview) {
        return c.json(
          {
            success: false,
            error: "Shop review not found",
          },
          404
        );
      }

      return c.json({
        success: true,
        message: "Shop review updated successfully",
        review: updatedReview,
      });
    } catch (error) {
      console.error("Error updating shop review:", error);
      return c.json(
        {
          success: false,
          error: "Failed to update shop review",
        },
        500
      );
    }
  }

  // Delete a product review
  async deleteProductReview(c: Context) {
    try {
      const reviewId = c.req.param("reviewId");

      if (!reviewId) {
        return c.json(
          {
            success: false,
            error: "Review ID is required",
          },
          400
        );
      }

      console.log(`Deleting product review: ${reviewId}`);

      const deleted = await memoryDb.deleteProductReview(reviewId);

      if (!deleted) {
        return c.json(
          {
            success: false,
            error: "Product review not found",
          },
          404
        );
      }

      return c.json({
        success: true,
        message: "Product review deleted successfully",
      });
    } catch (error) {
      console.error("Error deleting product review:", error);
      return c.json(
        {
          success: false,
          error: "Failed to delete product review",
        },
        500
      );
    }
  }

  // Delete a shop review
  async deleteShopReview(c: Context) {
    try {
      const reviewId = c.req.param("reviewId");

      if (!reviewId) {
        return c.json(
          {
            success: false,
            error: "Review ID is required",
          },
          400
        );
      }

      console.log(`Deleting shop review: ${reviewId}`);

      const deleted = await memoryDb.deleteShopReview(reviewId);

      if (!deleted) {
        return c.json(
          {
            success: false,
            error: "Shop review not found",
          },
          404
        );
      }

      return c.json({
        success: true,
        message: "Shop review deleted successfully",
      });
    } catch (error) {
      console.error("Error deleting shop review:", error);
      return c.json(
        {
          success: false,
          error: "Failed to delete shop review",
        },
        500
      );
    }
  }
}
