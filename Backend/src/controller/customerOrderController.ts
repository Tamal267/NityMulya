import sql from "../db";

// Create a new order
export const createCustomerOrder = async (c: any) => {
  try {
    const body = await c.req.json();
    const user = c.get("user");
    const customerId = user.userId;

    const {
      shop_owner_id,
      subcat_id,
      quantity_ordered,
      delivery_address,
      delivery_phone,
      notes,
    } = body;

    // Validate required fields
    if (
      !shop_owner_id ||
      !subcat_id ||
      !quantity_ordered ||
      !delivery_address ||
      !delivery_phone
    ) {
      return c.json(
        {
          success: false,
          message: "Missing required fields",
        },
        400
      );
    }

    // Get product details and shop inventory
    const inventoryResult = await sql`
            SELECT 
                si.unit_price,
                si.stock_quantity,
                sc.subcat_name,
                sc.unit,
                sc.subcat_img,
                so.name as shop_name,
                so.contact as shop_phone,
                so.address as shop_address
            FROM shop_inventory si
            JOIN subcategories sc ON si.subcat_id = sc.id
            JOIN shop_owners so ON si.shop_owner_id = so.id
            WHERE si.shop_owner_id = ${shop_owner_id} 
            AND si.subcat_id = ${subcat_id}
            AND si.stock_quantity > 0
        `;

    if (inventoryResult.length === 0) {
      return c.json(
        {
          success: false,
          message: "Product not available in this shop",
        },
        404
      );
    }

    const inventory = inventoryResult[0];

    // Check stock availability
    if (inventory.stock_quantity < quantity_ordered) {
      return c.json(
        {
          success: false,
          message: `Insufficient stock. Available: ${inventory.stock_quantity}, Requested: ${quantity_ordered}`,
        },
        400
      );
    }

    // Calculate total amount
    const totalAmount = parseFloat(inventory.unit_price) * quantity_ordered;
    const estimatedDelivery = new Date();
    estimatedDelivery.setDate(estimatedDelivery.getDate() + 3); // 3 days from now

    // Generate order number
    const orderNumberResult =
      await sql`SELECT generate_order_number() as order_number`;
    const orderNumber = orderNumberResult[0].order_number;

    // Create the order (triggers will handle inventory updates)
    const orderResult = await sql`
            INSERT INTO customer_orders (
                order_number,
                customer_id,
                shop_owner_id,
                subcat_id,
                quantity_ordered,
                unit_price,
                total_amount,
                delivery_address,
                delivery_phone,
                notes,
                estimated_delivery
            ) VALUES (
                ${orderNumber},
                ${customerId},
                ${shop_owner_id},
                ${subcat_id},
                ${quantity_ordered},
                ${inventory.unit_price},
                ${totalAmount},
                ${delivery_address},
                ${delivery_phone},
                ${notes || null},
                ${estimatedDelivery}
            )
            RETURNING *
        `;

    const order = orderResult[0];

    return c.json(
      {
        success: true,
        message: "Order created successfully",
        order: {
          ...order,
          product_name: inventory.subcat_name,
          product_image: inventory.subcat_img,
          unit: inventory.unit,
          shop_name: inventory.shop_name,
          shop_phone: inventory.shop_phone,
          shop_address: inventory.shop_address,
        },
      },
      201
    );
  } catch (error: any) {
    console.error("Error creating order:", error);
    return c.json(
      {
        success: false,
        message: error.message || "Internal server error",
      },
      500
    );
  }
};

// Get all orders for a customer
export const getCustomerOrders = async (c: any) => {
  try {
    const user = c.get("user");
    const customerId = user.userId;
    const status = c.req.query("status");

    let query = sql`
            SELECT 
                co.*,
                sc.subcat_name as product_name,
                sc.unit,
                sc.subcat_img as product_image,
                so.name as shop_name,
                so.contact as shop_phone,
                so.address as shop_address,
                c.full_name as customer_name,
                c.contact as customer_phone
            FROM customer_orders co
            JOIN subcategories sc ON co.subcat_id = sc.id
            JOIN shop_owners so ON co.shop_owner_id = so.id
            JOIN customers c ON co.customer_id = c.id
            WHERE co.customer_id = ${customerId}
        `;

    if (status) {
      query = sql`
                SELECT 
                    co.*,
                    sc.subcat_name as product_name,
                    sc.unit,
                    sc.subcat_img as product_image,
                    so.name as shop_name,
                    so.contact as shop_phone,
                    so.address as shop_address,
                    c.full_name as customer_name,
                    c.contact as customer_phone
                FROM customer_orders co
                JOIN subcategories sc ON co.subcat_id = sc.id
                JOIN shop_owners so ON co.shop_owner_id = so.id
                JOIN customers c ON co.customer_id = c.id
                WHERE co.customer_id = ${customerId}
                AND co.status = ${status}
            `;
    }

    query = sql`${query} ORDER BY co.created_at DESC`;

    const orders = await query;

    return c.json({
      success: true,
      orders: orders,
    });
  } catch (error: any) {
    console.error("Error fetching orders:", error);
    return c.json(
      {
        success: false,
        message: "Internal server error",
      },
      500
    );
  }
};

// Get a specific order
export const getCustomerOrder = async (c: any) => {
  try {
    const user = c.get("user");
    const customerId = user.userId;
    const orderId = c.req.param("orderId");

    const orderResult = await sql`
            SELECT 
                co.*,
                sc.subcat_name as product_name,
                sc.unit,
                sc.subcat_img as product_image,
                so.name as shop_name,
                so.contact as shop_phone,
                so.address as shop_address,
                c.full_name as customer_name,
                c.contact as customer_phone
            FROM customer_orders co
            JOIN subcategories sc ON co.subcat_id = sc.id
            JOIN shop_owners so ON co.shop_owner_id = so.id
            JOIN customers c ON co.customer_id = c.id
            WHERE co.id = ${orderId}
            AND co.customer_id = ${customerId}
        `;

    if (orderResult.length === 0) {
      return c.json(
        {
          success: false,
          message: "Order not found",
        },
        404
      );
    }

    // Get order status history
    const statusHistory = await sql`
            SELECT * FROM order_status_history
            WHERE order_id = ${orderId}
            ORDER BY created_at ASC
        `;

    return c.json({
      success: true,
      order: orderResult[0],
      status_history: statusHistory,
    });
  } catch (error: any) {
    console.error("Error fetching order:", error);
    return c.json(
      {
        success: false,
        message: "Internal server error",
      },
      500
    );
  }
};

// Cancel an order
export const cancelCustomerOrder = async (c: any) => {
  try {
    const user = c.get("user");
    const customerId = user.userId;
    const body = await c.req.json();
    const { order_id, cancellation_reason } = body;

    if (!order_id) {
      return c.json(
        {
          success: false,
          message: "Order ID is required",
        },
        400
      );
    }

    // Check if order exists and belongs to customer
    const orderResult = await sql`
            SELECT * FROM customer_orders
            WHERE id = ${order_id}
            AND customer_id = ${customerId}
        `;

    if (orderResult.length === 0) {
      return c.json(
        {
          success: false,
          message: "Order not found",
        },
        404
      );
    }

    const order = orderResult[0];

    // Check if order can be cancelled
    if (order.status === "cancelled") {
      return c.json(
        {
          success: false,
          message: "Order is already cancelled",
        },
        400
      );
    }

    if (order.status === "delivered") {
      return c.json(
        {
          success: false,
          message: "Cannot cancel delivered order",
        },
        400
      );
    }

    // Update order status to cancelled (trigger will handle inventory restoration)
    await sql`
            UPDATE customer_orders
            SET status = 'cancelled',
                cancellation_reason = ${
                  cancellation_reason || "Cancelled by customer"
                },
                updated_at = CURRENT_TIMESTAMP
            WHERE id = ${order_id}
        `;

    return c.json({
      success: true,
      message: "Order cancelled successfully",
    });
  } catch (error: any) {
    console.error("Error cancelling order:", error);
    return c.json(
      {
        success: false,
        message: "Internal server error",
      },
      500
    );
  }
};

// Get all customer orders for a shop owner
export const getShopOwnerCustomerOrders = async (c: any) => {
  try {
    const user = c.get("user");
    const shopOwnerId = user.userId;
    const status = c.req.query("status");

    let query = sql`
            SELECT 
                co.*,
                sc.subcat_name as product_name,
                sc.unit,
                sc.subcat_img as product_image,
                so.name as shop_name,
                so.contact as shop_phone,
                so.address as shop_address,
                c.full_name as customer_name,
                c.contact as customer_phone
            FROM customer_orders co
            JOIN subcategories sc ON co.subcat_id = sc.id
            JOIN shop_owners so ON co.shop_owner_id = so.id
            JOIN customers c ON co.customer_id = c.id
            WHERE co.shop_owner_id = ${shopOwnerId}
        `;

    if (status) {
      query = sql`
                SELECT 
                    co.*,
                    sc.subcat_name as product_name,
                    sc.unit,
                    sc.subcat_img as product_image,
                    so.name as shop_name,
                    so.contact as shop_phone,
                    so.address as shop_address,
                    c.full_name as customer_name,
                    c.contact as customer_phone
                FROM customer_orders co
                JOIN subcategories sc ON co.subcat_id = sc.id
                JOIN shop_owners so ON co.shop_owner_id = so.id
                JOIN customers c ON co.customer_id = c.id
                WHERE co.shop_owner_id = ${shopOwnerId}
                AND co.status = ${status}
            `;
    }

    query = sql`${query} ORDER BY co.created_at DESC`;

    const orders = await query;

    return c.json({
      success: true,
      orders: orders,
    });
  } catch (error: any) {
    console.error("Error fetching shop orders:", error);
    return c.json(
      {
        success: false,
        message: "Internal server error",
      },
      500
    );
  }
};

// Get order statistics for customer profile
export const getCustomerOrderStats = async (c: any) => {
  try {
    const user = c.get("user");
    const customerId = user.userId;

    // Get order counts by status
    const statsResult = await sql`
            SELECT 
                COUNT(*) as total_orders,
                COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_orders,
                COUNT(CASE WHEN status = 'confirmed' THEN 1 END) as confirmed_orders,
                COUNT(CASE WHEN status = 'preparing' THEN 1 END) as preparing_orders,
                COUNT(CASE WHEN status = 'ready' THEN 1 END) as ready_orders,
                COUNT(CASE WHEN status = 'delivered' THEN 1 END) as delivered_orders,
                COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled_orders,
                SUM(CASE WHEN status NOT IN ('cancelled') THEN total_amount ELSE 0 END) as total_spent,
                AVG(CASE WHEN status = 'delivered' THEN total_amount END) as avg_order_value
            FROM customer_orders
            WHERE customer_id = ${customerId}
        `;

    const stats = statsResult[0];

    // Get recent order activity (last 30 days)
    const recentActivityResult = await sql`
            SELECT 
                COUNT(*) as recent_orders,
                COUNT(CASE WHEN status = 'delivered' THEN 1 END) as recent_delivered
            FROM customer_orders
            WHERE customer_id = ${customerId}
            AND created_at >= CURRENT_DATE - INTERVAL '30 days'
        `;

    const recentActivity = recentActivityResult[0];

    return c.json({
      success: true,
      totalOrders: parseInt(stats.total_orders) || 0,
      pendingOrders: parseInt(stats.pending_orders) || 0,
      confirmedOrders: parseInt(stats.confirmed_orders) || 0,
      preparingOrders: parseInt(stats.preparing_orders) || 0,
      readyOrders: parseInt(stats.ready_orders) || 0,
      deliveredOrders: parseInt(stats.delivered_orders) || 0,
      cancelledOrders: parseInt(stats.cancelled_orders) || 0,
      totalSpent: parseFloat(stats.total_spent) || 0,
      averageOrderValue: parseFloat(stats.avg_order_value) || 0,
      recentOrders: parseInt(recentActivity.recent_orders) || 0,
      recentDelivered: parseInt(recentActivity.recent_delivered) || 0,
    });
  } catch (error: any) {
    console.error("Error fetching order stats:", error);
    return c.json(
      {
        success: false,
        message: "Internal server error",
      },
      500
    );
  }
};

// Update order status (shop owner only)
export const updateCustomerOrderStatus = async (c: any) => {
  try {
    const user = c.get("user");
    const shopOwnerId = user.userId;
    const body = await c.req.json();
    const { order_id, status, notes } = body;

    if (!order_id || !status) {
      return c.json(
        {
          success: false,
          message: "Order ID and status are required",
        },
        400
      );
    }

    // Validate status
    const validStatuses = [
      "pending",
      "confirmed",
      "preparing",
      "ready",
      "delivered",
      "cancelled",
    ];
    if (!validStatuses.includes(status)) {
      return c.json(
        {
          success: false,
          message: "Invalid status",
        },
        400
      );
    }

    // Check if order exists and belongs to shop owner
    const orderResult = await sql`
            SELECT * FROM customer_orders
            WHERE id = ${order_id}
            AND shop_owner_id = ${shopOwnerId}
        `;

    if (orderResult.length === 0) {
      return c.json(
        {
          success: false,
          message: "Order not found",
        },
        404
      );
    }

    // Update order status
    await sql`
            UPDATE customer_orders
            SET status = ${status},
                updated_at = CURRENT_TIMESTAMP
            WHERE id = ${order_id}
        `;

    // Log the status change with notes
    if (notes) {
      await sql`
                INSERT INTO order_status_history (order_id, old_status, new_status, changed_by, notes)
                VALUES (${order_id}, ${orderResult[0].status}, ${status}, 'shop_owner', ${notes})
            `;
    }

    return c.json({
      success: true,
      message: "Order status updated successfully",
    });
  } catch (error: any) {
    console.error("Error updating order status:", error);
    return c.json(
      {
        success: false,
        message: "Internal server error",
      },
      500
    );
  }
};
