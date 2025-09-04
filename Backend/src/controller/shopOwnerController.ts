import sql from "../db";

// Get shop owner dashboard summary
export const getShopOwnerDashboard = async (c: any) => {
  try {
    // Get shop owner ID from authenticated user
    const user = c.get("user");
    const shop_owner_id = user.userId;

    if (!shop_owner_id) {
      return c.json({ success: false, message: "Unauthorized" }, 401);
    }

    // Get total products in inventory
    const totalProducts = await sql`
            SELECT COUNT(*) as count 
            FROM shop_inventory 
            WHERE shop_owner_id = ${shop_owner_id} AND is_active = true
        `;

    // Get pending orders count
    const pendingOrders = await sql`
            SELECT COUNT(*) as count 
            FROM shop_orders 
            WHERE shop_owner_id = ${shop_owner_id} AND status = 'pending'
        `;

    // Get low stock products
    const lowStockProducts = await sql`
            SELECT COUNT(*) as count 
            FROM shop_inventory si
            WHERE si.shop_owner_id = ${shop_owner_id} 
            AND si.stock_quantity <= si.low_stock_threshold
            AND si.is_active = true
        `;

    // Get unread messages count
    const unreadMessages = await sql`
            SELECT COUNT(*) as count 
            FROM chat_messages 
            WHERE receiver_id = ${shop_owner_id} 
            AND receiver_type = 'shop_owner' 
            AND is_read = false
        `;

    return c.json({
      success: true,
      data: {
        totalProducts: totalProducts[0]?.count || 0,
        pendingOrders: pendingOrders[0]?.count || 0,
        lowStockProducts: lowStockProducts[0]?.count || 0,
        unreadMessages: unreadMessages[0]?.count || 0,
      },
    });
  } catch (error) {
    console.error("Error fetching shop owner dashboard:", error);
    return c.json(
      { success: false, message: "Failed to fetch dashboard data" },
      500
    );
  }
};

// Get shop owner inventory with product details
export const getShopOwnerInventory = async (c: any) => {
  try {
    // Get shop owner ID from authenticated user
    const user = c.get("user");
    const shop_owner_id = user.userId;

    if (!shop_owner_id) {
      return c.json({ success: false, message: "Unauthorized" }, 401);
    }

    const inventory = await sql`
            SELECT 
                si.*,
                s.subcat_name,
                s.unit,
                c.cat_name,
                s.subcat_img
            FROM shop_inventory si
            JOIN subcategories s ON si.subcat_id = s.id
            JOIN categories c ON s.cat_id = c.id
            WHERE si.shop_owner_id = ${shop_owner_id}
            ORDER BY si.created_at DESC
        `;

    return c.json({
      success: true,
      data: inventory,
    });
  } catch (error) {
    console.error("Error fetching shop owner inventory:", error);
    return c.json(
      { success: false, message: "Failed to fetch inventory" },
      500
    );
  }
};

// Add product to shop owner inventory
export const addProductToInventory = async (c: any) => {
  try {
    // Get shop owner ID from authenticated user
    const user = c.get("user");
    const shop_owner_id = user.userId;

    const { subcat_id, stock_quantity, unit_price, low_stock_threshold } =
      await c.req.json();

    if (!shop_owner_id || !subcat_id || !stock_quantity || !unit_price) {
      return c.json(
        {
          success: false,
          message: "subcat_id, stock_quantity, and unit_price are required",
        },
        400
      );
    }

    // Validate price range against government regulations
    const priceValidation = await sql`
            SELECT min_price, max_price, subcat_name
            FROM subcategories
            WHERE id = ${subcat_id}
        `;

    if (priceValidation.length === 0) {
      return c.json(
        {
          success: false,
          message: "Invalid product selected",
        },
        400
      );
    }

    const { min_price, max_price, subcat_name } = priceValidation[0];
    const minPrice = parseFloat(min_price) || 0;
    const maxPrice = parseFloat(max_price) || Infinity;

    if (minPrice > 0 && unit_price < minPrice) {
      return c.json(
        {
          success: false,
          message: `Price must be at least ৳${minPrice.toFixed(
            2
          )} for ${subcat_name}`,
        },
        400
      );
    }

    if (maxPrice < Infinity && unit_price > maxPrice) {
      return c.json(
        {
          success: false,
          message: `Price cannot exceed ৳${maxPrice.toFixed(
            2
          )} for ${subcat_name}`,
        },
        400
      );
    }

    const result = await sql`
            INSERT INTO shop_inventory 
            (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold)
            VALUES (${shop_owner_id}, ${subcat_id}, ${stock_quantity}, ${unit_price}, ${
      low_stock_threshold || 10
    })
            ON CONFLICT (shop_owner_id, subcat_id)
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

// Update existing product in shop owner inventory
export const updateInventoryItem = async (c: any) => {
  try {
    // Get shop owner ID from authenticated user
    const user = c.get("user");
    const shop_owner_id = user.userId;

    const { id, stock_quantity, unit_price, low_stock_threshold } =
      await c.req.json();

    if (!shop_owner_id || !id) {
      return c.json(
        {
          success: false,
          message: "id is required",
        },
        400
      );
    }

    // Verify the inventory item belongs to the authenticated shop owner
    const existingItem = await sql`
            SELECT * FROM shop_inventory 
            WHERE id = ${id} AND shop_owner_id = ${shop_owner_id}
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

    const result = await sql`
            UPDATE shop_inventory 
            SET 
                stock_quantity = COALESCE(${stock_quantity}, stock_quantity),
                unit_price = COALESCE(${unit_price}, unit_price),
                low_stock_threshold = COALESCE(${low_stock_threshold}, low_stock_threshold),
                updated_at = CURRENT_TIMESTAMP
            WHERE id = ${id} AND shop_owner_id = ${shop_owner_id}
            RETURNING *
        `;

    return c.json({
      success: true,
      message: "Inventory updated successfully",
      data: result[0],
    });
  } catch (error) {
    console.error("Error updating inventory:", error);
    return c.json(
      { success: false, message: "Failed to update inventory" },
      500
    );
  }
};

// Get low stock products for shop owner
export const getLowStockProducts = async (c: any) => {
  try {
    // Get shop owner ID from authenticated user
    const user = c.get("user");
    const shop_owner_id = user.userId;

    if (!shop_owner_id) {
      return c.json({ success: false, message: "Unauthorized" }, 401);
    }

    const lowStockItems = await sql`
            SELECT 
                si.*,
                s.subcat_name,
                s.unit,
                c.cat_name,
                s.hindi_name,
                s.image_url
            FROM shop_inventory si
            JOIN subcategories s ON si.subcat_id = s.id
            JOIN categories c ON s.cat_id = c.id
            WHERE si.shop_owner_id = ${shop_owner_id}
            AND si.stock_quantity <= si.low_stock_threshold
            AND si.is_active = true
            ORDER BY (si.stock_quantity::float / si.low_stock_threshold::float) ASC
        `;

    return c.json({
      success: true,
      data: lowStockItems,
    });
  } catch (error) {
    console.error("Error fetching low stock products:", error);
    return c.json(
      { success: false, message: "Failed to fetch low stock products" },
      500
    );
  }
};

// Get shop owner orders
export const getShopOrders = async (c: any) => {
  try {
    // Get shop owner ID from authenticated user
    const user = c.get("user");
    const shop_owner_id = user.userId;

    if (!shop_owner_id) {
      return c.json({ success: false, message: "Unauthorized" }, 401);
    }

    const orders = await sql`
            SELECT 
                so.*,
                s.subcat_name,
                s.unit,
                c.cat_name,
                s.hindi_name,
                s.image_url,
                w.full_name as wholesaler_name,
                w.contact as wholesaler_contact
            FROM shop_orders so
            JOIN subcategories s ON so.subcat_id = s.id
            JOIN categories c ON s.cat_id = c.id
            JOIN wholesalers w ON so.wholesaler_id = w.id
            WHERE so.shop_owner_id = ${shop_owner_id}
            ORDER BY so.created_at DESC
        `;

    return c.json({
      success: true,
      data: orders,
    });
  } catch (error) {
    console.error("Error fetching shop orders:", error);
    return c.json({ success: false, message: "Failed to fetch orders" }, 500);
  }
};

// Get chat messages for shop owner
export const getChatMessages = async (c: any) => {
  try {
    // Get shop owner ID from authenticated user
    const user = c.get("user");
    const shop_owner_id = user.userId;

    if (!shop_owner_id) {
      return c.json({ success: false, message: "Unauthorized" }, 401);
    }

    // Get conversation partner ID from query parameters
    const partnerId = c.req.query("partner_id");

    let messages;
    if (partnerId) {
      // Get messages with specific partner
      messages = await sql`
                SELECT cm.*,
                       CASE 
                           WHEN sender_type = 'shop_owner' THEN so.full_name
                           ELSE w.full_name
                       END as sender_name
                FROM chat_messages cm
                LEFT JOIN shop_owners so ON cm.sender_id = so.id AND cm.sender_type = 'shop_owner'
                LEFT JOIN wholesalers w ON cm.sender_id = w.id AND cm.sender_type = 'wholesaler'
                WHERE (cm.sender_id = ${shop_owner_id} AND cm.receiver_id = ${partnerId})
                   OR (cm.sender_id = ${partnerId} AND cm.receiver_id = ${shop_owner_id})
                ORDER BY cm.created_at ASC
            `;
    } else {
      // Get all conversations for shop owner
      messages = await sql`
                SELECT cm.*,
                       CASE 
                           WHEN sender_type = 'shop_owner' THEN so.full_name
                           ELSE w.full_name
                       END as sender_name
                FROM chat_messages cm
                LEFT JOIN shop_owners so ON cm.sender_id = so.id AND cm.sender_type = 'shop_owner'
                LEFT JOIN wholesalers w ON cm.sender_id = w.id AND cm.sender_type = 'wholesaler'
                WHERE cm.receiver_id = ${shop_owner_id} AND cm.receiver_type = 'shop_owner'
                   OR cm.sender_id = ${shop_owner_id} AND cm.sender_type = 'shop_owner'
                ORDER BY cm.created_at DESC
            `;
    }

    return c.json({
      success: true,
      data: messages,
    });
  } catch (error) {
    console.error("Error fetching chat messages:", error);
    return c.json({ success: false, message: "Failed to fetch messages" }, 500);
  }
};
