import { Context } from "hono";
import { db } from "../db";

// ================================
// FAVOURITES CONTROLLER (using existing customer_favorites table)
// ================================

export const getFavourites = async (c: Context) => {
  try {
    const customerId = c.req.param('customerId');
    
    const favourites = await db`
      SELECT 
        cf.*,
        sc.subcat_name as product_name,
        sc.unit,
        so.name as shop_name,
        si.unit_price as current_price,
        ph.price as last_price,
        ph.price_date as last_updated
      FROM customer_favorites cf
      LEFT JOIN subcategories sc ON cf.subcat_id = sc.id
      LEFT JOIN shop_owners so ON cf.shop_owner_id = so.id  
      LEFT JOIN shop_inventory si ON cf.shop_owner_id = si.shop_owner_id AND cf.subcat_id = si.subcat_id
      LEFT JOIN (
        SELECT subcat_id, shop_owner_id, price, price_date,
               ROW_NUMBER() OVER (PARTITION BY subcat_id, shop_owner_id ORDER BY price_date DESC) as rn
        FROM product_price_history
      ) ph ON cf.subcat_id = ph.subcat_id AND cf.shop_owner_id = ph.shop_owner_id AND ph.rn = 1
      WHERE cf.customer_id = ${customerId}
      ORDER BY cf.created_at DESC
    `;

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
      error: error instanceof Error ? error.message : 'Unknown error'
    }, 500);
  }
};

export const addToFavourites = async (c: Context) => {
  try {
    const body = await c.req.json();
    const { customer_id, shop_id, product_id, product_name, shop_name } = body;

    if (!customer_id || !shop_id || !product_id) {
      return c.json({
        success: false,
        message: 'Missing required fields: customer_id, shop_id, product_id'
      }, 400);
    }

    // Insert or ignore if already exists
    const result = await db`
      INSERT INTO customer_favorites (customer_id, shop_owner_id, subcat_id)
      VALUES (${customer_id}, ${shop_id}, ${product_id})
      ON CONFLICT (customer_id, shop_owner_id, subcat_id) DO NOTHING
      RETURNING id
    `;

    return c.json({
      success: true,
      data: result[0] || { message: 'Already in favourites' },
      message: 'Added to favourites successfully'
    });
  } catch (error) {
    console.error('Error adding to favourites:', error);
    return c.json({
      success: false,
      message: 'Failed to add to favourites',
      error: error instanceof Error ? error.message : 'Unknown error'
    }, 500);
  }
};

export const removeFromFavourites = async (c: Context) => {
  try {
    const customerId = c.req.param('customerId');
    const shopId = c.req.param('shopId');  
    const productId = c.req.param('productId');

    const result = await db`
      DELETE FROM customer_favorites 
      WHERE customer_id = ${customerId} 
      AND shop_owner_id = ${shopId} 
      AND subcat_id = ${productId}
      RETURNING id
    `;

    return c.json({
      success: true,
      message: 'Removed from favourites successfully',
      rowsAffected: result.length
    });
  } catch (error) {
    console.error('Error removing from favourites:', error);
    return c.json({
      success: false,
      message: 'Failed to remove from favourites',
      error: error instanceof Error ? error.message : 'Unknown error'
    }, 500);
  }
};

// ================================
// PRICE HISTORY CONTROLLER (using new product_price_history table)
// ================================

export const getPriceHistory = async (c: Context) => {
  try {
    const productId = c.req.param('productId');
    const shopId = c.req.param('shopId');

    const priceHistory = await db`
      SELECT 
        ph.*,
        sc.subcat_name as product_name,
        so.name as shop_name
      FROM product_price_history ph
      LEFT JOIN subcategories sc ON ph.subcat_id = sc.id
      LEFT JOIN shop_owners so ON ph.shop_owner_id = so.id
      WHERE ph.subcat_id = ${productId} 
      AND ph.shop_owner_id = ${shopId}
      ORDER BY ph.price_date DESC
      LIMIT 50
    `;

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
      error: error instanceof Error ? error.message : 'Unknown error'
    }, 500);
  }
};

export const addPriceHistory = async (c: Context) => {
  try {
    const body = await c.req.json();
    const { product_id, product_name, shop_id, shop_name, price, unit, recorded_by } = body;

    if (!product_id || !shop_id || !price) {
      return c.json({
        success: false,
        message: 'Missing required fields: product_id, shop_id, price'
      }, 400);
    }

    const result = await db`
      INSERT INTO product_price_history (
        subcat_id, product_name, shop_owner_id, shop_name, price, unit, recorded_by
      ) VALUES (
        ${product_id}, ${product_name}, ${shop_id}, ${shop_name}, 
        ${price}, ${unit}, ${recorded_by || 'api'}
      )
      RETURNING id
    `;

    return c.json({
      success: true,
      data: result[0],
      message: 'Price history added successfully'
    });
  } catch (error) {
    console.error('Error adding price history:', error);
    return c.json({
      success: false,
      message: 'Failed to add price history',
      error: error instanceof Error ? error.message : 'Unknown error'
    }, 500);
  }
};

// ================================
// REVIEWS CONTROLLER (using existing customer_shop_reviews table)
// ================================

export const getReviews = async (c: Context) => {
  try {
    const shopId = c.req.param('shopId');
    const limit = parseInt(c.req.query('limit') || '20');
    const offset = parseInt(c.req.query('offset') || '0');

    // For now, we'll try to match the shop_id as UUID directly
    // Later we can add a mapping between shop numeric IDs and UUID
    const reviews = await db`
      SELECT 
        csr.*,
        so.name as shop_name
      FROM customer_shop_reviews csr
      LEFT JOIN shop_owners so ON csr.shop_owner_id = so.id
      WHERE csr.shop_owner_id::text = ${shopId} OR so.id::text = ${shopId}
      ORDER BY csr.created_at DESC
      LIMIT ${limit} OFFSET ${offset}
    `;

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
      error: error instanceof Error ? error.message : 'Unknown error'
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

    if (!customer_id || !customer_name || !customer_email || !shop_id || !overall_rating || !review_comment) {
      return c.json({
        success: false,
        message: 'Missing required fields'
      }, 400);
    }

    const result = await db`
      INSERT INTO customer_shop_reviews (
        customer_id, customer_name, customer_email, shop_owner_id, shop_name,
        overall_rating, service_rating, delivery_rating, comment
      ) VALUES (
        ${customer_id}, ${customer_name}, ${customer_email}, ${shop_id}, ${shop_name},
        ${overall_rating}, ${service_rating}, ${delivery_rating}, ${review_comment}
      )
      RETURNING id
    `;

    return c.json({
      success: true,
      data: result[0],
      message: 'Review added successfully'
    });
  } catch (error) {
    console.error('Error adding review:', error);
    return c.json({
      success: false,
      message: 'Failed to add review',
      error: error instanceof Error ? error.message : 'Unknown error'
    }, 500);
  }
};

// ================================
// COMPLAINTS CONTROLLER (using new complaints table)
// ================================

export const getComplaints = async (c: Context) => {
  try {
    const customerId = c.req.param('customerId');
    const limit = parseInt(c.req.query('limit') || '20');
    const offset = parseInt(c.req.query('offset') || '0');

    const complaints = await db`
      SELECT 
        co.*,
        so.name as shop_name,
        sc.subcat_name as product_name
      FROM complaints co
      LEFT JOIN shop_owners so ON co.shop_owner_id = so.id
      LEFT JOIN subcategories sc ON co.subcat_id = sc.id
      WHERE co.customer_id = ${customerId}
      ORDER BY co.created_at DESC
      LIMIT ${limit} OFFSET ${offset}
    `;

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
      error: error instanceof Error ? error.message : 'Unknown error'
    }, 500);
  }
};

export const submitComplaint = async (c: Context) => {
  try {
    const body = await c.req.json();
    const { 
      customer_id, customer_name, customer_email, customer_phone,
      shop_id, shop_name, product_id, product_name,
      complaint_type, complaint_title, complaint_description 
    } = body;

    if (!customer_id || !customer_name || !customer_email || !shop_id || 
        !complaint_type || !complaint_title || !complaint_description) {
      return c.json({
        success: false,
        message: 'Missing required fields'
      }, 400);
    }

    // Generate complaint number
    const complaintNumber = `COMP-${Date.now()}-${Math.random().toString(36).substr(2, 6).toUpperCase()}`;

    const result = await db`
      INSERT INTO complaints (
        complaint_number, customer_id, customer_name, customer_email, customer_phone,
        shop_owner_id, shop_name, subcat_id, product_name,
        complaint_type, complaint_title, complaint_description
      ) VALUES (
        ${complaintNumber}, ${customer_id}, ${customer_name}, ${customer_email}, ${customer_phone},
        ${shop_id}, ${shop_name}, ${product_id}, ${product_name},
        ${complaint_type}, ${complaint_title}, ${complaint_description}
      )
      RETURNING id, complaint_number
    `;

    return c.json({
      success: true,
      data: result[0],
      message: 'Complaint submitted successfully'
    });
  } catch (error) {
    console.error('Error submitting complaint:', error);
    return c.json({
      success: false,
      message: 'Failed to submit complaint',
      error: error instanceof Error ? error.message : 'Unknown error'
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

    const result = await db`
      UPDATE complaints 
      SET 
        status = ${status}, 
        resolution_comment = ${resolution_comment},
        resolved_at = CASE WHEN ${status} = 'resolved' THEN CURRENT_TIMESTAMP ELSE resolved_at END,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ${complaintId}
      RETURNING id
    `;

    return c.json({
      success: true,
      message: 'Complaint status updated successfully',
      rowsAffected: result.length
    });
  } catch (error) {
    console.error('Error updating complaint status:', error);
    return c.json({
      success: false,
      message: 'Failed to update complaint status',
      error: error instanceof Error ? error.message : 'Unknown error'
    }, 500);
  }
};
