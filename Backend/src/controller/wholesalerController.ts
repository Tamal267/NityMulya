import sql from "../db";

// Get wholesaler dashboard summary
export const getWholesalerDashboard = async (c: any) => {
  try {
    // Get wholesaler ID from authenticated user
    const user = c.get("user");
    const wholesaler_id = user.userId;

    if (!wholesaler_id) {
      return c.json({ success: false, message: "Unauthorized" }, 401);
    }

    // Get total shops (unique shop owners who have made orders)
    const totalShops = await sql`
            SELECT COUNT(DISTINCT shop_owner_id) as count 
            FROM shop_orders 
            WHERE wholesaler_id = ${wholesaler_id}
        `;

    // Get new requests (pending orders)
    const newRequests = await sql`
            SELECT COUNT(*) as count 
            FROM shop_orders 
            WHERE wholesaler_id = ${wholesaler_id} AND status = 'pending'
        `;

    // Get low stock products from shop owners (not wholesaler inventory)
    const lowStockProducts = await sql`
            SELECT COUNT(*) as count 
            FROM shop_inventory si
            JOIN shop_owners so ON si.shop_owner_id = so.id
            WHERE si.stock_quantity <= si.low_stock_threshold
            AND si.is_active = true
        `;

    // Get unread messages count
    const unreadMessages = await sql`
            SELECT COUNT(*) as count 
            FROM chat_messages 
            WHERE receiver_id = ${wholesaler_id} 
            AND receiver_type = 'wholesaler' 
            AND is_read = false
        `;

    return c.json({
      success: true,
      data: {
        totalShops: totalShops[0]?.count || 0,
        newRequests: newRequests[0]?.count || 0,
        lowStockProducts: lowStockProducts[0]?.count || 0,
        unreadMessages: unreadMessages[0]?.count || 0,
      },
    });
  } catch (error) {
    console.error("Error fetching wholesaler dashboard:", error);
    return c.json(
      { success: false, message: "Failed to fetch dashboard data" },
      500
    );
  }
};

// Get wholesaler inventory
export const getWholesalerInventory = async (c: any) => {
  try {
    // Get wholesaler ID from authenticated user
    const user = c.get("user");
    const wholesaler_id = user.userId;

    if (!wholesaler_id) {
      return c.json({ success: false, message: "Unauthorized" }, 401);
    }

    const inventory = await sql`
            SELECT 
                wi.id,
                wi.subcat_id,
                wi.stock_quantity,
                wi.unit_price,
                wi.low_stock_threshold,
                wi.is_active,
                wi.created_at,
                wi.updated_at,
                sc.subcat_name,
                sc.unit,
                c.cat_name
            FROM wholesaler_inventory wi
            JOIN subcategories sc ON wi.subcat_id = sc.id
            JOIN categories c ON sc.cat_id = c.id
            WHERE wi.wholesaler_id = ${wholesaler_id}
            AND wi.is_active = true
            ORDER BY sc.subcat_name
        `;

    return c.json({
      success: true,
      data: inventory,
    });
  } catch (error) {
    console.error("Error fetching wholesaler inventory:", error);
    return c.json(
      { success: false, message: "Failed to fetch inventory" },
      500
    );
  }
};

// Add product to wholesaler inventory
export const addProductToInventory = async (c: any) => {
  try {
    // Get wholesaler ID from authenticated user
    const user = c.get("user");
    const wholesaler_id = user.userId;

    const { subcat_id, stock_quantity, unit_price, low_stock_threshold } =
      await c.req.json();

    if (!wholesaler_id || !subcat_id || !stock_quantity || !unit_price) {
      return c.json(
        {
          success: false,
          message: "subcat_id, stock_quantity, and unit_price are required",
        },
        400
      );
    }

    const result = await sql`
            INSERT INTO wholesaler_inventory 
            (wholesaler_id, subcat_id, stock_quantity, unit_price, low_stock_threshold)
            VALUES (${wholesaler_id}, ${subcat_id}, ${stock_quantity}, ${unit_price}, ${
      low_stock_threshold || 10
    })
            ON CONFLICT (wholesaler_id, subcat_id)
            DO UPDATE SET 
                stock_quantity = EXCLUDED.stock_quantity,
                unit_price = EXCLUDED.unit_price,
                low_stock_threshold = EXCLUDED.low_stock_threshold,
                updated_at = CURRENT_TIMESTAMP
            RETURNING *
        `;

    return c.json({
      success: true,
      message: "Product added to inventory successfully",
      data: result[0],
    });
  } catch (error) {
    console.error("Error adding product to inventory:", error);
    return c.json(
      { success: false, message: "Failed to add product to inventory" },
      500
    );
  }
};

// Update existing product in wholesaler inventory
export const updateInventoryItem = async (c: any) => {
  try {
    // Get wholesaler ID from authenticated user
    const user = c.get("user");
    const wholesaler_id = user.userId;

    const { inventory_id, stock_quantity, unit_price, low_stock_threshold } =
      await c.req.json();

    if (!wholesaler_id || !inventory_id) {
      return c.json(
        {
          success: false,
          message: "inventory_id is required",
        },
        400
      );
    }

    // First, verify that this inventory item belongs to the authenticated wholesaler
    const existingItem = await sql`
            SELECT * FROM wholesaler_inventory 
            WHERE id = ${inventory_id} AND wholesaler_id = ${wholesaler_id}
        `;

    if (existingItem.length === 0) {
      return c.json(
        {
          success: false,
          message: "Inventory item not found or access denied",
        },
        404
      );
    }

    // Update only the fields that are provided
    const updates = [];
    const values = [];
    let valueIndex = 1;

    if (stock_quantity !== undefined) {
      updates.push(`stock_quantity = $${valueIndex++}`);
      values.push(stock_quantity);
    }
    if (unit_price !== undefined) {
      updates.push(`unit_price = $${valueIndex++}`);
      values.push(unit_price);
    }
    if (low_stock_threshold !== undefined) {
      updates.push(`low_stock_threshold = $${valueIndex++}`);
      values.push(low_stock_threshold);
    }

    if (updates.length === 0) {
      return c.json(
        {
          success: false,
          message: "No fields to update",
        },
        400
      );
    }

    // Add updated_at timestamp
    updates.push(`updated_at = CURRENT_TIMESTAMP`);

    // Add WHERE clause parameters
    values.push(inventory_id, wholesaler_id);

    const updateQuery = `
            UPDATE wholesaler_inventory 
            SET ${updates.join(", ")}
            WHERE id = $${valueIndex++} AND wholesaler_id = $${valueIndex++}
            RETURNING *
        `;

    const result = await sql.unsafe(updateQuery, values);

    if (result.length === 0) {
      return c.json(
        {
          success: false,
          message: "Failed to update inventory item",
        },
        500
      );
    }

    return c.json({
      success: true,
      message: "Inventory updated successfully",
      data: result[0],
    });
  } catch (error) {
    console.error("Error updating inventory item:", error);
    return c.json(
      { success: false, message: "Failed to update inventory item" },
      500
    );
  }
};

// Get low stock products for monitoring
export const getLowStockProducts = async (c: any) => {
  try {
    // Get wholesaler ID from authenticated user
    const user = c.get("user");
    const wholesaler_id = user.userId;

    const product_filter = c.req.query("product");
    const location_filter = c.req.query("location");

    if (!wholesaler_id) {
      return c.json(
        { success: false, message: "Wholesaler ID is required" },
        400
      );
    }

    let query = sql`
            SELECT 
    si.stock_quantity,
    si.low_stock_threshold as min_stock_threshold,
    si.unit_price,
    si.updated_at,
    sc.subcat_name as product_name,
    sc.unit,
    c.cat_name,
    sc.subcat_img,
    COALESCE(NULLIF(so.full_name, ''), 'Unknown Owner') as shop_name,
    COALESCE(so.address, 'Address not provided') as shop_location,
    so.contact as shop_contact,
    so.id as shop_owner_id
FROM shop_inventory si
JOIN subcategories sc ON si.subcat_id = sc.id
JOIN categories c ON sc.cat_id = c.id
JOIN shop_owners so ON si.shop_owner_id = so.id
WHERE si.stock_quantity <= si.low_stock_threshold
AND si.is_active = true
        `;

    // Add filters if provided
    if (product_filter && product_filter !== "All Products") {
      query = sql`${query} AND sc.subcat_name = ${product_filter}`;
    }

    if (location_filter && location_filter !== "All Areas") {
      query = sql`${query} AND so.address ILIKE ${`%${location_filter}%`}`;
    }

    query = sql`${query} 
            ORDER BY si.stock_quantity ASC, so.full_name, sc.subcat_name
        `;

    const lowStockProducts = await query;

    return c.json({
      success: true,
      data: lowStockProducts,
    });
  } catch (error) {
    console.error("Error fetching low stock products:", error);
    return c.json(
      { success: false, message: "Failed to fetch low stock products" },
      500
    );
  }
};

// Get shop orders/requests
export const getShopOrders = async (c: any) => {
  try {
    // Get wholesaler ID from authenticated user
    const user = c.get("user");
    const wholesaler_id = user.userId;
    const status_filter = c.req.query("status");

    if (!wholesaler_id) {
      return c.json(
        { success: false, message: "Wholesaler ID is required" },
        400
      );
    }

    let query = sql`
            SELECT 
                orders.*,
                sc.subcat_name,
                sc.unit,
                c.cat_name,
                COALESCE(so.full_name, so.name) as shop_name,
                so.full_name,
                so.address as shop_address,
                so.contact as shop_contact
            FROM shop_orders orders
            JOIN subcategories sc ON orders.subcat_id = sc.id
            JOIN categories c ON sc.cat_id = c.id
            JOIN shop_owners so ON orders.shop_owner_id = so.id
            WHERE orders.wholesaler_id = ${wholesaler_id}
        `;

    if (status_filter && status_filter !== "all") {
      query = sql`${query} AND orders.status = ${status_filter}`;
    }

    query = sql`${query} ORDER BY orders.created_at DESC`;

    const orders = await query;

    return c.json({
      success: true,
      data: orders,
    });
  } catch (error) {
    console.error("Error fetching shop orders:", error);
    return c.json(
      { success: false, message: "Failed to fetch shop orders" },
      500
    );
  }
};

// Update order status
export const updateOrderStatus = async (c: any) => {
  try {
    const { order_id, status } = await c.req.json();

    if (!order_id || !status) {
      return c.json(
        {
          success: false,
          message: "order_id and status are required",
        },
        400
      );
    }

    const validStatuses = ["pending", "processing", "delivered", "cancelled"];
    if (!validStatuses.includes(status)) {
      return c.json(
        {
          success: false,
          message:
            "Invalid status. Must be one of: " + validStatuses.join(", "),
        },
        400
      );
    }

    const result = await sql`
            UPDATE shop_orders 
            SET status = ${status}, updated_at = CURRENT_TIMESTAMP
            WHERE id = ${order_id}
            RETURNING *
        `;

    if (result.length === 0) {
      return c.json({ success: false, message: "Order not found" }, 404);
    }

    return c.json({
      success: true,
      message: "Order status updated successfully",
      data: result[0],
    });
  } catch (error) {
    console.error("Error updating order status:", error);
    return c.json(
      { success: false, message: "Failed to update order status" },
      500
    );
  }
};

// Get wholesaler offers
export const getWholesalerOffers = async (c: any) => {
  try {
    // Get wholesaler ID from authenticated user
    const user = c.get("user");
    const wholesaler_id = user.userId;

    if (!wholesaler_id) {
      return c.json({ success: false, message: "Unauthorized" }, 401);
    }

    const offers = await sql`
            SELECT * FROM wholesaler_offers
            WHERE wholesaler_id = ${wholesaler_id}
            AND is_active = true
            ORDER BY created_at DESC
        `;

    return c.json({
      success: true,
      data: offers,
    });
  } catch (error) {
    console.error("Error fetching wholesaler offers:", error);
    return c.json({ success: false, message: "Failed to fetch offers" }, 500);
  }
};

// Create new offer
export const createOffer = async (c: any) => {
  try {
    // Get wholesaler ID from authenticated user
    const user = c.get("user");
    const wholesaler_id = user.userId;

    if (!wholesaler_id) {
      return c.json({ success: false, message: "Unauthorized" }, 401);
    }

    const {
      title,
      description,
      discount_percentage,
      minimum_quantity,
      valid_until,
    } = await c.req.json();

    if (!title) {
      return c.json(
        {
          success: false,
          message: "title is required",
        },
        400
      );
    }

    const result = await sql`
            INSERT INTO wholesaler_offers 
            (wholesaler_id, title, description, discount_percentage, minimum_quantity, valid_until, is_active)
            VALUES (${wholesaler_id}, ${title}, ${description}, ${discount_percentage}, ${minimum_quantity}, ${valid_until}, true)
            RETURNING *
        `;

    return c.json({
      success: true,
      message: "Offer created successfully",
      data: result[0],
    });
  } catch (error) {
    console.error("Error creating offer:", error);
    return c.json({ success: false, message: "Failed to create offer" }, 500);
  }
};

// Update existing offer
export const updateOffer = async (c: any) => {
  try {
    // Get wholesaler ID from authenticated user
    const user = c.get("user");
    const wholesaler_id = user.userId;

    if (!wholesaler_id) {
      return c.json({ success: false, message: "Unauthorized" }, 401);
    }

    const {
      offer_id,
      title,
      description,
      discount_percentage,
      minimum_quantity,
      valid_until,
      is_active,
    } = await c.req.json();

    if (!offer_id || !title) {
      return c.json(
        {
          success: false,
          message: "offer_id and title are required",
        },
        400
      );
    }

    // First verify the offer belongs to this wholesaler
    const existingOffer = await sql`
            SELECT * FROM wholesaler_offers 
            WHERE id = ${offer_id} AND wholesaler_id = ${wholesaler_id}
        `;

    if (existingOffer.length === 0) {
      return c.json(
        {
          success: false,
          message: "Offer not found or access denied",
        },
        404
      );
    }

    const result = await sql`
            UPDATE wholesaler_offers 
            SET 
                title = ${title},
                description = ${description},
                discount_percentage = ${discount_percentage},
                minimum_quantity = ${minimum_quantity},
                valid_until = ${valid_until},
                is_active = ${
                  is_active !== undefined
                    ? is_active
                    : existingOffer[0].is_active
                },
                updated_at = CURRENT_TIMESTAMP
            WHERE id = ${offer_id} AND wholesaler_id = ${wholesaler_id}
            RETURNING *
        `;

    return c.json({
      success: true,
      message: "Offer updated successfully",
      data: result[0],
    });
  } catch (error) {
    console.error("Error updating offer:", error);
    return c.json({ success: false, message: "Failed to update offer" }, 500);
  }
};

// Delete offer (soft delete)
export const deleteOffer = async (c: any) => {
  try {
    // Get wholesaler ID from authenticated user
    const user = c.get("user");
    const wholesaler_id = user.userId;

    if (!wholesaler_id) {
      return c.json({ success: false, message: "Unauthorized" }, 401);
    }

    const offer_id = c.req.param("id");

    if (!offer_id) {
      return c.json(
        {
          success: false,
          message: "offer_id is required",
        },
        400
      );
    }

    // First verify the offer belongs to this wholesaler
    const existingOffer = await sql`
            SELECT * FROM wholesaler_offers 
            WHERE id = ${offer_id} AND wholesaler_id = ${wholesaler_id}
        `;

    if (existingOffer.length === 0) {
      return c.json(
        {
          success: false,
          message: "Offer not found or access denied",
        },
        404
      );
    }

    // Soft delete by setting is_active to false
    const result = await sql`
            UPDATE wholesaler_offers 
            SET is_active = false, updated_at = CURRENT_TIMESTAMP
            WHERE id = ${offer_id} AND wholesaler_id = ${wholesaler_id}
            RETURNING *
        `;

    return c.json({
      success: true,
      message: "Offer deleted successfully",
      data: result[0],
    });
  } catch (error) {
    console.error("Error deleting offer:", error);
    return c.json({ success: false, message: "Failed to delete offer" }, 500);
  }
};

// Get chat messages
export const getChatMessages = async (c: any) => {
  try {
    const wholesaler_id = c.req.query("wholesaler_id");
    const shop_owner_id = c.req.query("shop_owner_id");

    if (!wholesaler_id) {
      return c.json(
        { success: false, message: "Wholesaler ID is required" },
        400
      );
    }

    let query;
    if (shop_owner_id) {
      // Get messages between specific wholesaler and shop owner
      query = sql`
                SELECT 
                    cm.*,
                    CASE 
                        WHEN cm.sender_type = 'wholesaler' THEN w.name
                        ELSE so.name
                    END as sender_name
                FROM chat_messages cm
                LEFT JOIN wholesalers w ON cm.sender_id::uuid = w.id AND cm.sender_type = 'wholesaler'
                LEFT JOIN shop_owners so ON cm.sender_id::uuid = so.id AND cm.sender_type = 'shop_owner'
                WHERE ((cm.sender_id = ${wholesaler_id} AND cm.receiver_id = ${shop_owner_id})
                    OR (cm.sender_id = ${shop_owner_id} AND cm.receiver_id = ${wholesaler_id}))
                ORDER BY cm.created_at ASC
            `;
    } else {
      // Get all chat conversations for this wholesaler
      query = sql`
                SELECT DISTINCT
                    CASE 
                        WHEN cm.sender_type = 'shop_owner' THEN cm.sender_id
                        ELSE cm.receiver_id
                    END as shop_owner_id,
                    so.name as shop_name,
                    so.shop_address,
                    (SELECT message_text FROM chat_messages 
                     WHERE ((sender_id = ${wholesaler_id} AND receiver_id = so.id)
                        OR (sender_id = so.id AND receiver_id = ${wholesaler_id}))
                     ORDER BY created_at DESC LIMIT 1) as last_message,
                    (SELECT created_at FROM chat_messages 
                     WHERE ((sender_id = ${wholesaler_id} AND receiver_id = so.id)
                        OR (sender_id = so.id AND receiver_id = ${wholesaler_id}))
                     ORDER BY created_at DESC LIMIT 1) as last_message_time,
                    (SELECT COUNT(*) FROM chat_messages 
                     WHERE sender_id = so.id AND receiver_id = ${wholesaler_id}
                     AND receiver_type = 'wholesaler' AND is_read = false) as unread_count
                FROM chat_messages cm
                JOIN shop_owners so ON (
                    (cm.sender_type = 'shop_owner' AND cm.sender_id = so.id) OR
                    (cm.receiver_type = 'shop_owner' AND cm.receiver_id = so.id)
                )
                WHERE (cm.sender_id = ${wholesaler_id} OR cm.receiver_id = ${wholesaler_id})
                ORDER BY last_message_time DESC
            `;
    }

    const messages = await query;

    return c.json({
      success: true,
      data: messages,
    });
  } catch (error) {
    console.error("Error fetching chat messages:", error);
    return c.json({ success: false, message: "Failed to fetch messages" }, 500);
  }
};

// Create a new order
export const createOrder = async (c: any) => {
  try {
    // Get wholesaler ID from authenticated user
    const user = c.get("user");
    const wholesaler_id = user.userId;

    if (!wholesaler_id) {
      return c.json({ success: false, message: "Unauthorized" }, 401);
    }

    const { shop_owner_id, subcat_id, quantity, unit_price, notes } =
      await c.req.json();

    // Validate required fields
    if (!shop_owner_id || !subcat_id || !quantity || !unit_price) {
      return c.json(
        {
          success: false,
          message:
            "shop_owner_id, subcat_id, quantity, and unit_price are required",
        },
        400
      );
    }

    // Calculate total amount
    const total_amount = quantity * unit_price;

    // Insert the order
    const result = await sql`
            INSERT INTO shop_orders 
            (shop_owner_id, wholesaler_id, subcat_id, quantity_requested, unit_price, total_amount, notes, status)
            VALUES (${shop_owner_id}, ${wholesaler_id}, ${subcat_id}, ${quantity}, ${unit_price}, ${total_amount}, ${
      notes || null
    }, 'pending')
            RETURNING *
        `;

    return c.json({
      success: true,
      message: "Order created successfully",
      data: result[0],
    });
  } catch (error) {
    console.error("Error creating order:", error);
    return c.json({ success: false, message: "Failed to create order" }, 500);
  }
};

// Get all shop owners for dropdown selection
export const getShopOwners = async (c: any) => {
  try {
    const shopOwners = await sql`
            SELECT id, full_name as shop_name, full_name, email, contact as phone, address as location
            FROM shop_owners 
            ORDER BY full_name ASC
        `;

    return c.json({
      success: true,
      data: shopOwners,
    });
  } catch (error) {
    console.error("Error fetching shop owners:", error);
    return c.json(
      { success: false, message: "Failed to fetch shop owners" },
      500
    );
  }
};

// Get all categories for dropdown selection
export const getCategories = async (c: any) => {
  try {
    const categories = await sql`
            SELECT id, cat_name as name
            FROM categories 
            ORDER BY cat_name ASC
        `;

    return c.json({
      success: true,
      data: categories,
    });
  } catch (error) {
    console.error("Error fetching categories:", error);
    return c.json(
      { success: false, message: "Failed to fetch categories" },
      500
    );
  }
};

// Get subcategories by category ID
export const getSubcategories = async (c: any) => {
  try {
    const categoryId = c.req.query("category_id");

    if (!categoryId) {
      return c.json(
        { success: false, message: "Category ID is required" },
        400
      );
    }

    const subcategories = await sql`
            SELECT id, subcat_name as name, unit
            FROM subcategories 
            WHERE cat_id = ${categoryId} 
            ORDER BY subcat_name ASC
        `;

    return c.json({
      success: true,
      data: subcategories,
    });
  } catch (error) {
    console.error("Error fetching subcategories:", error);
    return c.json(
      { success: false, message: "Failed to fetch subcategories" },
      500
    );
  }
};

// Get wholesaler profile
export const getWholesalerProfile = async (c: any) => {
  try {
    // Get wholesaler ID from authenticated user
    const user = c.get("user");
    const wholesaler_id = user.userId;

    if (!wholesaler_id) {
      return c.json({ success: false, message: "Unauthorized" }, 401);
    }

    const profile = await sql`
            SELECT 
                id,
                full_name,
                email,
                contact,
                address,
                longitude,
                latitude,
                created_at
            FROM wholesalers 
            WHERE id = ${wholesaler_id}
        `;

    if (profile.length === 0) {
      return c.json(
        { success: false, message: "Wholesaler profile not found" },
        404
      );
    }

    return c.json({
      success: true,
      data: profile[0],
    });
  } catch (error) {
    console.error("Error fetching wholesaler profile:", error);
    return c.json({ success: false, message: "Failed to fetch profile" }, 500);
  }
};
