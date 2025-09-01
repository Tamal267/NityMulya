import { Context } from "hono";
import sql from "../db";

export class DatabaseReviewController {
  constructor() {
    // Database connection is handled by the sql import
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

      // Insert product review into database
      const [review] = await sql`
        INSERT INTO customer_product_reviews (
          customer_id, customer_name, customer_email,
          subcat_id, product_name,
          shop_owner_id, shop_name,
          rating, comment, order_id, is_verified_purchase
        ) VALUES (
          ${customer_id}, ${customer_name}, ${customer_email},
          ${subcat_id}, ${product_name},
          ${shop_owner_id}, ${shop_name},
          ${rating}, ${comment || ""}, ${
        order_id || null
      }, ${is_verified_purchase}
        ) RETURNING *
      `;

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
          error: "Failed to create product review: " + error.message,
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

      // Insert shop review into database
      const [review] = await sql`
        INSERT INTO customer_shop_reviews (
          customer_id, customer_name, customer_email,
          shop_owner_id, shop_name,
          overall_rating, service_rating, delivery_rating,
          comment, order_id, is_verified_purchase
        ) VALUES (
          ${customer_id}, ${customer_name}, ${customer_email},
          ${shop_owner_id}, ${shop_name},
          ${overall_rating}, ${service_rating || overall_rating}, ${
        delivery_rating || overall_rating
      },
          ${comment || ""}, ${order_id || null}, ${is_verified_purchase}
        ) RETURNING *
      `;

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
          error: "Failed to create shop review: " + error.message,
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

      let reviews;
      if (shopOwnerId) {
        reviews = await sql`
          SELECT * FROM customer_product_reviews 
          WHERE subcat_id = ${subcatId} AND shop_owner_id = ${shopOwnerId}
          ORDER BY created_at DESC
        `;
      } else {
        reviews = await sql`
          SELECT * FROM customer_product_reviews 
          WHERE subcat_id = ${subcatId}
          ORDER BY created_at DESC
        `;
      }

      return c.json({
        success: true,
        reviews: reviews || [],
      });
    } catch (error) {
      console.error("Error getting product reviews:", error);
      return c.json(
        {
          success: false,
          error: "Failed to get product reviews: " + error.message,
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

      const reviews = await sql`
        SELECT * FROM customer_shop_reviews 
        WHERE shop_owner_id = ${shopOwnerId}
        ORDER BY created_at DESC
      `;

      return c.json({
        success: true,
        reviews: reviews || [],
      });
    } catch (error) {
      console.error("Error getting shop reviews:", error);
      return c.json(
        {
          success: false,
          error: "Failed to get shop reviews: " + error.message,
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

      const reviews = await sql`
        SELECT * FROM customer_product_reviews 
        WHERE customer_id = ${customerId}
        ORDER BY created_at DESC
      `;

      return c.json({
        success: true,
        reviews: reviews || [],
      });
    } catch (error) {
      console.error("Error getting customer product reviews:", error);
      return c.json(
        {
          success: false,
          error: "Failed to get customer product reviews: " + error.message,
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

      const reviews = await sql`
        SELECT * FROM customer_shop_reviews 
        WHERE customer_id = ${customerId}
        ORDER BY created_at DESC
      `;

      return c.json({
        success: true,
        reviews: reviews || [],
      });
    } catch (error) {
      console.error("Error getting customer shop reviews:", error);
      return c.json(
        {
          success: false,
          error: "Failed to get customer shop reviews: " + error.message,
        },
        500
      );
    }
  }

  // Get average rating for a product
  async getProductAverageRating(c: Context) {
    try {
      const subcatId = c.req.param("subcatId");
      const shopOwnerId = c.req.query("shopOwnerId");

      if (!subcatId) {
        return c.json(
          {
            success: false,
            error: "Product ID (subcatId) is required",
          },
          400
        );
      }

      let result;
      if (shopOwnerId) {
        result = await sql`
          SELECT AVG(rating)::numeric(3,2) as average, COUNT(*) as count
          FROM customer_product_reviews 
          WHERE subcat_id = ${subcatId} AND shop_owner_id = ${shopOwnerId}
        `;
      } else {
        result = await sql`
          SELECT AVG(rating)::numeric(3,2) as average, COUNT(*) as count
          FROM customer_product_reviews 
          WHERE subcat_id = ${subcatId}
        `;
      }

      const average = parseFloat(result[0]?.average || "0");
      const count = parseInt(result[0]?.count || "0");

      return c.json({
        success: true,
        average,
        count,
      });
    } catch (error) {
      console.error("Error getting product average rating:", error);
      return c.json(
        {
          success: false,
          error: "Failed to get product average rating: " + error.message,
        },
        500
      );
    }
  }

  // Get average ratings for a shop
  async getShopAverageRatings(c: Context) {
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

      const result = await sql`
        SELECT 
          AVG(overall_rating)::numeric(3,2) as overall,
          AVG(service_rating)::numeric(3,2) as service,
          AVG(delivery_rating)::numeric(3,2) as delivery,
          COUNT(*) as count
        FROM customer_shop_reviews 
        WHERE shop_owner_id = ${shopOwnerId}
      `;

      const overall = parseFloat(result[0]?.overall || "0");
      const service = parseFloat(result[0]?.service || "0");
      const delivery = parseFloat(result[0]?.delivery || "0");
      const count = parseInt(result[0]?.count || "0");

      return c.json({
        success: true,
        overall,
        service,
        delivery,
        count,
      });
    } catch (error) {
      console.error("Error getting shop average ratings:", error);
      return c.json(
        {
          success: false,
          error: "Failed to get shop average ratings: " + error.message,
        },
        500
      );
    }
  }

  // Get all reviews (for debugging)
  async getAllReviews(c: Context) {
    try {
      const productReviews =
        await sql`SELECT * FROM customer_product_reviews ORDER BY created_at DESC`;
      const shopReviews =
        await sql`SELECT * FROM customer_shop_reviews ORDER BY created_at DESC`;

      return c.json({
        success: true,
        productReviews,
        shopReviews,
        productCount: productReviews.length,
        shopCount: shopReviews.length,
      });
    } catch (error) {
      console.error("Error getting all reviews:", error);
      return c.json(
        {
          success: false,
          error: "Failed to get all reviews: " + error.message,
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

      const updateFields = [];
      const values = [];

      if (body.rating) {
        updateFields.push("rating = $" + (values.length + 1));
        values.push(body.rating);
      }
      if (body.comment !== undefined) {
        updateFields.push("comment = $" + (values.length + 1));
        values.push(body.comment);
      }

      if (updateFields.length === 0) {
        return c.json(
          {
            success: false,
            error: "No fields to update",
          },
          400
        );
      }

      updateFields.push("updated_at = CURRENT_TIMESTAMP");
      values.push(reviewId);

      const [updatedReview] = await sql`
        UPDATE customer_product_reviews 
        SET rating = ${body.rating || sql`rating`}, 
            comment = ${
              body.comment !== undefined ? body.comment : sql`comment`
            },
            updated_at = CURRENT_TIMESTAMP
        WHERE id = ${reviewId}
        RETURNING *
      `;

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
          error: "Failed to update product review: " + error.message,
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

      const [updatedReview] = await sql`
        UPDATE customer_shop_reviews 
        SET overall_rating = ${body.overall_rating || sql`overall_rating`}, 
            service_rating = ${body.service_rating || sql`service_rating`},
            delivery_rating = ${body.delivery_rating || sql`delivery_rating`},
            comment = ${
              body.comment !== undefined ? body.comment : sql`comment`
            },
            updated_at = CURRENT_TIMESTAMP
        WHERE id = ${reviewId}
        RETURNING *
      `;

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
          error: "Failed to update shop review: " + error.message,
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

      const [deletedReview] = await sql`
        DELETE FROM customer_product_reviews 
        WHERE id = ${reviewId}
        RETURNING id
      `;

      if (!deletedReview) {
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
          error: "Failed to delete product review: " + error.message,
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

      const [deletedReview] = await sql`
        DELETE FROM customer_shop_reviews 
        WHERE id = ${reviewId}
        RETURNING id
      `;

      if (!deletedReview) {
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
          error: "Failed to delete shop review: " + error.message,
        },
        500
      );
    }
  }
}
