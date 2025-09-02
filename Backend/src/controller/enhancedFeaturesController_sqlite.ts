import { Context } from "hono";
import { sqliteDb } from "../sqlite-db";

// ================================
// FAVOURITES CONTROLLER
// ================================

export const getFavourites = async (c: Context) => {
  try {
    const customerId = c.req.param('customerId');
    
    const query = sqliteDb.query(`
      SELECT 
        f.*,
        ph.price as current_price,
        ph.unit,
        ph.price_date as last_updated
      FROM favourites f
      LEFT JOIN (
        SELECT product_id, shop_id, price, unit, price_date,
               ROW_NUMBER() OVER (PARTITION BY product_id, shop_id ORDER BY price_date DESC) as rn
        FROM product_price_history
      ) ph ON f.product_id = ph.product_id AND f.shop_id = ph.shop_id AND ph.rn = 1
      WHERE f.customer_id = ?
      ORDER BY f.created_at DESC
    `);
    
    const favourites = query.all(customerId);

    return c.json({
      success: true,
      data: favourites,
      message: 'Favourites retrieved successfully'
    });
  } catch (error) {
    console.error('Error fetching favourites:', error);
    return c.json({
      success: false,
      message: 'Failed to fetch favourites',
      error: error
    }, 500);
  }
};

export const addToFavourites = async (c: Context) => {
  try {
    const body = await c.req.json();
    const { customer_id, shop_id, product_id, product_name, shop_name } = body;

    if (!customer_id || !shop_id || !product_id || !product_name || !shop_name) {
      return c.json({
        success: false,
        message: 'Missing required fields'
      }, 400);
    }

    const insertQuery = sqliteDb.query(`
      INSERT INTO favourites (customer_id, shop_id, product_id, product_name, shop_name)
      VALUES (?, ?, ?, ?, ?)
      ON CONFLICT(customer_id, shop_id, product_id) DO NOTHING
    `);

    const result = insertQuery.run(customer_id, shop_id, product_id, product_name, shop_name);

    return c.json({
      success: true,
      data: { id: result.lastInsertRowid },
      message: 'Added to favourites successfully'
    });
  } catch (error) {
    console.error('Error adding to favourites:', error);
    return c.json({
      success: false,
      message: 'Failed to add to favourites',
      error: error
    }, 500);
  }
};

export const removeFromFavourites = async (c: Context) => {
  try {
    const customerId = c.req.param('customerId');
    const shopId = c.req.param('shopId');
    const productId = c.req.param('productId');

    const deleteQuery = sqliteDb.query(`
      DELETE FROM favourites 
      WHERE customer_id = ? AND shop_id = ? AND product_id = ?
    `);

    const result = deleteQuery.run(customerId, shopId, productId);

    return c.json({
      success: true,
      message: 'Removed from favourites successfully',
      rowsAffected: result.changes
    });
  } catch (error) {
    console.error('Error removing from favourites:', error);
    return c.json({
      success: false,
      message: 'Failed to remove from favourites',
      error: error
    }, 500);
  }
};

// ================================
// PRICE HISTORY CONTROLLER
// ================================

export const getPriceHistory = async (c: Context) => {
  try {
    const productId = c.req.param('productId');
    const shopId = c.req.param('shopId');

    const query = sqliteDb.query(`
      SELECT * FROM product_price_history 
      WHERE product_id = ? AND shop_id = ?
      ORDER BY price_date DESC
      LIMIT 50
    `);

    const priceHistory = query.all(productId, shopId);

    return c.json({
      success: true,
      data: priceHistory,
      message: 'Price history retrieved successfully'
    });
  } catch (error) {
    console.error('Error fetching price history:', error);
    return c.json({
      success: false,
      message: 'Failed to fetch price history',
      error: error
    }, 500);
  }
};

export const addPriceHistory = async (c: Context) => {
  try {
    const body = await c.req.json();
    const { product_id, product_name, shop_id, shop_name, price, unit, recorded_by } = body;

    if (!product_id || !product_name || !shop_id || !shop_name || !price) {
      return c.json({
        success: false,
        message: 'Missing required fields'
      }, 400);
    }

    const insertQuery = sqliteDb.query(`
      INSERT INTO product_price_history (product_id, product_name, shop_id, shop_name, price, unit, recorded_by)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `);

    const result = insertQuery.run(product_id, product_name, shop_id, shop_name, price, unit, recorded_by);

    return c.json({
      success: true,
      data: { id: result.lastInsertRowid },
      message: 'Price history added successfully'
    });
  } catch (error) {
    console.error('Error adding price history:', error);
    return c.json({
      success: false,
      message: 'Failed to add price history',
      error: error
    }, 500);
  }
};

// ================================
// REVIEWS CONTROLLER
// ================================

export const getReviews = async (c: Context) => {
  try {
    const shopId = c.req.param('shopId');
    const limit = c.req.query('limit') || '20';
    const offset = c.req.query('offset') || '0';

    const query = sqliteDb.query(`
      SELECT * FROM reviews 
      WHERE shop_id = ?
      ORDER BY created_at DESC
      LIMIT ? OFFSET ?
    `);

    const reviews = query.all(shopId, parseInt(limit), parseInt(offset));

    return c.json({
      success: true,
      data: reviews,
      message: 'Reviews retrieved successfully'
    });
  } catch (error) {
    console.error('Error fetching reviews:', error);
    return c.json({
      success: false,
      message: 'Failed to fetch reviews',
      error: error
    }, 500);
  }
};

export const addReview = async (c: Context) => {
  try {
    const body = await c.req.json();
    const { 
      customer_id, customer_name, customer_email, shop_id, shop_name,
      product_id, product_name, overall_rating, product_quality_rating,
      service_rating, delivery_rating, review_title, review_comment
    } = body;

    if (!customer_id || !customer_name || !customer_email || !shop_id || !shop_name || !overall_rating || !review_comment) {
      return c.json({
        success: false,
        message: 'Missing required fields'
      }, 400);
    }

    const insertQuery = sqliteDb.query(`
      INSERT INTO reviews (
        customer_id, customer_name, customer_email, shop_id, shop_name,
        product_id, product_name, overall_rating, product_quality_rating,
        service_rating, delivery_rating, review_title, review_comment
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);

    const result = insertQuery.run(
      customer_id, customer_name, customer_email, shop_id, shop_name,
      product_id, product_name, overall_rating, product_quality_rating,
      service_rating, delivery_rating, review_title, review_comment
    );

    return c.json({
      success: true,
      data: { id: result.lastInsertRowid },
      message: 'Review added successfully'
    });
  } catch (error) {
    console.error('Error adding review:', error);
    return c.json({
      success: false,
      message: 'Failed to add review',
      error: error
    }, 500);
  }
};

// ================================
// COMPLAINTS CONTROLLER
// ================================

export const getComplaints = async (c: Context) => {
  try {
    const customerId = c.req.param('customerId');
    const limit = c.req.query('limit') || '20';
    const offset = c.req.query('offset') || '0';

    const query = sqliteDb.query(`
      SELECT * FROM complaints 
      WHERE customer_id = ?
      ORDER BY created_at DESC
      LIMIT ? OFFSET ?
    `);

    const complaints = query.all(customerId, parseInt(limit), parseInt(offset));

    return c.json({
      success: true,
      data: complaints,
      message: 'Complaints retrieved successfully'
    });
  } catch (error) {
    console.error('Error fetching complaints:', error);
    return c.json({
      success: false,
      message: 'Failed to fetch complaints',
      error: error
    }, 500);
  }
};

export const submitComplaint = async (c: Context) => {
  try {
    const body = await c.req.json();
    const { 
      customer_id, customer_name, customer_email, customer_phone,
      shop_id, shop_name, product_id, product_name,
      complaint_type, complaint_title, complaint_description, priority 
    } = body;

    if (!customer_id || !customer_name || !customer_email || !shop_id || !shop_name || 
        !complaint_type || !complaint_title || !complaint_description) {
      return c.json({
        success: false,
        message: 'Missing required fields'
      }, 400);
    }

    // Generate complaint number
    const complaintNumber = `COMP-${Date.now()}-${Math.random().toString(36).substr(2, 6).toUpperCase()}`;

    const insertQuery = sqliteDb.query(`
      INSERT INTO complaints (
        complaint_number, customer_id, customer_name, customer_email, customer_phone,
        shop_id, shop_name, product_id, product_name,
        complaint_type, complaint_title, complaint_description, priority
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);

    const result = insertQuery.run(
      complaintNumber, customer_id, customer_name, customer_email, customer_phone,
      shop_id, shop_name, product_id, product_name,
      complaint_type, complaint_title, complaint_description, priority || 'medium'
    );

    return c.json({
      success: true,
      data: { 
        id: result.lastInsertRowid, 
        complaint_number: complaintNumber 
      },
      message: 'Complaint submitted successfully'
    });
  } catch (error) {
    console.error('Error submitting complaint:', error);
    return c.json({
      success: false,
      message: 'Failed to submit complaint',
      error: error
    }, 500);
  }
};

export const updateComplaintStatus = async (c: Context) => {
  try {
    const complaintId = c.req.param('complaintId');
    const body = await c.req.json();
    const { status, resolution_comment } = body;

    if (!status) {
      return c.json({
        success: false,
        message: 'Status is required'
      }, 400);
    }

    const updateQuery = sqliteDb.query(`
      UPDATE complaints 
      SET status = ?, resolution_comment = ?, 
          resolved_at = CASE WHEN ? = 'resolved' THEN CURRENT_TIMESTAMP ELSE resolved_at END,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `);

    const result = updateQuery.run(status, resolution_comment, status, complaintId);

    return c.json({
      success: true,
      message: 'Complaint status updated successfully',
      rowsAffected: result.changes
    });
  } catch (error) {
    console.error('Error updating complaint status:', error);
    return c.json({
      success: false,
      message: 'Failed to update complaint status',
      error: error
    }, 500);
  }
};
