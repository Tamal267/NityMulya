const express = require('express');
const router = express.Router();
const { Pool } = require('pg');

// Database connection
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'nitymulya_db',
  password: 'nitymulya321',
  port: 5432,
});

// Send a message
router.post('/send', async (req, res) => {
  try {
    const {
      order_id,
      sender_type, // 'shop_owner' or 'customer'
      sender_id,
      receiver_type, // 'shop_owner' or 'customer'
      receiver_id,
      message_text
    } = req.body;

    // Validate required fields
    if (!order_id || !sender_type || !sender_id || !receiver_type || !receiver_id || !message_text) {
      return res.status(400).json({
        success: false,
        message: 'All fields are required'
      });
    }

    // Insert message into database
    const query = `
      INSERT INTO order_messages (order_id, sender_type, sender_id, receiver_type, receiver_id, message_text)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
    `;

    const result = await pool.query(query, [
      order_id,
      sender_type,
      sender_id,
      receiver_type,
      receiver_id,
      message_text
    ]);

    res.json({
      success: true,
      message: 'Message sent successfully',
      data: result.rows[0]
    });

  } catch (error) {
    console.error('❌ Error sending message:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send message',
      error: error.message
    });
  }
});

// Get messages for a specific order
router.get('/order/:order_id', async (req, res) => {
  try {
    const { order_id } = req.params;
    const { user_id, user_type } = req.query;

    const query = `
      SELECT om.*, 
             CASE 
               WHEN om.sender_type = 'shop_owner' THEN so.shop_name
               WHEN om.sender_type = 'customer' THEN c.full_name
             END as sender_name
      FROM order_messages om
      LEFT JOIN shop_owners so ON om.sender_type = 'shop_owner' AND om.sender_id = so.id
      LEFT JOIN customers c ON om.sender_type = 'customer' AND om.sender_id = c.id
      WHERE om.order_id = $1
      AND (om.sender_id = $2 OR om.receiver_id = $2)
      ORDER BY om.created_at ASC
    `;

    const result = await pool.query(query, [order_id, user_id]);

    // Mark messages as read for the current user
    if (user_id && user_type) {
      await pool.query(`
        UPDATE order_messages 
        SET is_read = TRUE, updated_at = CURRENT_TIMESTAMP
        WHERE order_id = $1 AND receiver_id = $2 AND receiver_type = $3
      `, [order_id, user_id, user_type]);
    }

    res.json({
      success: true,
      data: result.rows
    });

  } catch (error) {
    console.error('❌ Error fetching messages:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch messages',
      error: error.message
    });
  }
});

// Get all message conversations for a customer
router.get('/customer/:customer_id', async (req, res) => {
  try {
    const { customer_id } = req.params;

    const query = `
      WITH latest_messages AS (
        SELECT DISTINCT ON (order_id) 
               order_id,
               sender_type,
               sender_id,
               receiver_type,
               receiver_id,
               message_text,
               is_read,
               created_at
        FROM order_messages 
        WHERE sender_id = $1 OR receiver_id = $1
        ORDER BY order_id, created_at DESC
      )
      SELECT lm.*,
             o.status as order_status,
             so.shop_name,
             so.shop_address,
             COUNT(om_unread.id) as unread_count
      FROM latest_messages lm
      LEFT JOIN orders o ON lm.order_id = o.order_id
      LEFT JOIN shop_owners so ON (
        CASE 
          WHEN lm.sender_type = 'shop_owner' THEN lm.sender_id = so.id
          WHEN lm.receiver_type = 'shop_owner' THEN lm.receiver_id = so.id
        END
      )
      LEFT JOIN order_messages om_unread ON lm.order_id = om_unread.order_id 
        AND om_unread.receiver_id = $1 
        AND om_unread.is_read = FALSE
      GROUP BY lm.order_id, lm.sender_type, lm.sender_id, lm.receiver_type, 
               lm.receiver_id, lm.message_text, lm.is_read, lm.created_at,
               o.status, so.shop_name, so.shop_address
      ORDER BY lm.created_at DESC
    `;

    const result = await pool.query(query, [customer_id]);

    res.json({
      success: true,
      data: result.rows
    });

  } catch (error) {
    console.error('❌ Error fetching customer messages:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch customer messages',
      error: error.message
    });
  }
});

// Get all message conversations for a shop owner
router.get('/shop/:shop_id', async (req, res) => {
  try {
    const { shop_id } = req.params;

    const query = `
      WITH latest_messages AS (
        SELECT DISTINCT ON (order_id) 
               order_id,
               sender_type,
               sender_id,
               receiver_type,
               receiver_id,
               message_text,
               is_read,
               created_at
        FROM order_messages 
        WHERE sender_id = $1 OR receiver_id = $1
        ORDER BY order_id, created_at DESC
      )
      SELECT lm.*,
             o.status as order_status,
             c.full_name as customer_name,
             c.phone as customer_phone,
             COUNT(om_unread.id) as unread_count
      FROM latest_messages lm
      LEFT JOIN orders o ON lm.order_id = o.order_id
      LEFT JOIN customers c ON (
        CASE 
          WHEN lm.sender_type = 'customer' THEN lm.sender_id = c.id
          WHEN lm.receiver_type = 'customer' THEN lm.receiver_id = c.id
        END
      )
      LEFT JOIN order_messages om_unread ON lm.order_id = om_unread.order_id 
        AND om_unread.receiver_id = $1 
        AND om_unread.is_read = FALSE
      GROUP BY lm.order_id, lm.sender_type, lm.sender_id, lm.receiver_type, 
               lm.receiver_id, lm.message_text, lm.is_read, lm.created_at,
               o.status, c.full_name, c.phone
      ORDER BY lm.created_at DESC
    `;

    const result = await pool.query(query, [shop_id]);

    res.json({
      success: true,
      data: result.rows
    });

  } catch (error) {
    console.error('❌ Error fetching shop messages:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch shop messages',
      error: error.message
    });
  }
});

// Mark messages as read
router.put('/mark-read', async (req, res) => {
  try {
    const { order_id, user_id, user_type } = req.body;

    const query = `
      UPDATE order_messages 
      SET is_read = TRUE, updated_at = CURRENT_TIMESTAMP
      WHERE order_id = $1 AND receiver_id = $2 AND receiver_type = $3
      RETURNING *
    `;

    const result = await pool.query(query, [order_id, user_id, user_type]);

    res.json({
      success: true,
      message: 'Messages marked as read',
      data: result.rows
    });

  } catch (error) {
    console.error('❌ Error marking messages as read:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to mark messages as read',
      error: error.message
    });
  }
});

// Get unread message count
router.get('/unread-count/:user_id/:user_type', async (req, res) => {
  try {
    const { user_id, user_type } = req.params;

    const query = `
      SELECT COUNT(*) as unread_count
      FROM order_messages 
      WHERE receiver_id = $1 AND receiver_type = $2 AND is_read = FALSE
    `;

    const result = await pool.query(query, [user_id, user_type]);

    res.json({
      success: true,
      unread_count: parseInt(result.rows[0].unread_count)
    });

  } catch (error) {
    console.error('❌ Error getting unread count:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get unread count',
      error: error.message
    });
  }
});

module.exports = router;
