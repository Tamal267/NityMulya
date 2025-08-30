import sql from "../db";
import { verifyToken } from "../utils/jwt";

// Helper function to get user from token
const getUserFromToken = async (c: any) => {
  try {
    const authHeader = c.req.header("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return null;
    }

    const token = authHeader.substring(7);
    const payload = verifyToken(token);
    return payload;
  } catch (error) {
    return null;
  }
};

// Create a new customer order
export const createCustomerOrder = async (c: any) => {
  try {
    const user = await getUserFromToken(c);
    if (!user || user.role !== "customer") {
      return c.json(
        {
          success: false,
          error: "Unauthorized. Customer login required.",
        },
        401
      );
    }

    const {
      shop_owner_id,
      subcat_id,
      quantity_ordered,
      delivery_address,
      delivery_phone,
      notes,
    } = await c.req.json();

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
          error:
            "Missing required fields: shop_owner_id, subcat_id, quantity_ordered, delivery_address, delivery_phone",
        },
        400
      );
    }

    if (quantity_ordered <= 0) {
      return c.json(
        {
          success: false,
          error: "Quantity must be greater than 0",
        },
        400
      );
    }

    // Check if shop owner exists
    const shopOwner = await sql`
            SELECT id, full_name FROM shop_owners WHERE id = ${shop_owner_id}
        `;
    if (shopOwner.length === 0) {
      return c.json(
        {
          success: false,
          error: "Shop owner not found",
        },
        404
      );
    }

    // Check if product exists and get inventory details
    const inventory = await sql`
            SELECT si.*, s.subcat_name, s.unit, c.cat_name 
            FROM shop_inventory si
            JOIN subcategories s ON si.subcat_id = s.id
            JOIN categories c ON s.cat_id = c.id
            WHERE si.shop_owner_id = ${shop_owner_id} AND si.subcat_id = ${subcat_id}
        `;

    if (inventory.length === 0) {
      return c.json(
        {
          success: false,
          error: "Product not available in this shop",
        },
        404
      );
    }

    const product = inventory[0];

    // Check if sufficient quantity is available
    if (product.quantity < quantity_ordered) {
      return c.json(
        {
          success: false,
          error: `Insufficient stock. Available: ${product.quantity} ${product.unit}`,
        },
        400
      );
    }

    // Calculate total amount
    const unit_price = parseFloat(product.price);
    const total_amount = unit_price * quantity_ordered;

    // Set estimated delivery (3 days from now)
    const estimated_delivery = new Date();
    estimated_delivery.setDate(estimated_delivery.getDate() + 3);

    // Create the order (triggers will handle inventory update)
    const order = await sql`
            INSERT INTO customer_orders (
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
                ${user.userId},
                ${shop_owner_id},
                ${subcat_id},
                ${quantity_ordered},
                ${unit_price},
                ${total_amount},
                ${delivery_address},
                ${delivery_phone},
                ${notes || null},
                ${estimated_delivery.toISOString()}
            )
            RETURNING *
        `;

    // Get complete order details with product and shop info
    const orderDetails = await sql`
            SELECT 
                co.*,
                c.full_name as customer_name,
                c.contact as customer_phone,
                c.email as customer_email,
                so.full_name as shop_name,
                so.contact as shop_phone,
                so.address as shop_address,
                sc.subcat_name as product_name,
                sc.unit,
                cat.cat_name as category_name
            FROM customer_orders co
            JOIN customers c ON co.customer_id = c.id
            JOIN shop_owners so ON co.shop_owner_id = so.id
            JOIN subcategories sc ON co.subcat_id = sc.id
            JOIN categories cat ON sc.cat_id = cat.id
            WHERE co.id = ${order[0].id}
        `;

    return c.json(
      {
        success: true,
        message: "Order created successfully",
        order: orderDetails[0],
      },
      201
    );
  } catch (error: any) {
    console.error("Error creating customer order:", error);

    if (
      error.message.includes("Insufficient stock") ||
      error.message.includes("Product not found")
    ) {
      return c.json(
        {
          success: false,
          error: error.message,
        },
        400
      );
    }

    return c.json(
      {
        success: false,
        error: "Failed to create order. Please try again.",
      },
      500
    );
  }
};

// Get customer orders
export const getCustomerOrders = async (c: any) => {
  try {
    const user = await getUserFromToken(c);
    if (!user || user.role !== "customer") {
      return c.json(
        {
          success: false,
          error: "Unauthorized. Customer login required.",
        },
        401
      );
    }

    // Get query parameters
    const status = c.req.query("status");
    const page = parseInt(c.req.query("page")) || 1;
    const limit = parseInt(c.req.query("limit")) || 10;
    const offset = (page - 1) * limit;

    // Build query with optional status filter
    let query = sql`
            SELECT 
                co.*,
                so.full_name as shop_name,
                so.contact as shop_phone,
                so.address as shop_address,
                sc.subcat_name as product_name,
                sc.unit,
                cat.cat_name as category_name
            FROM customer_orders co
            JOIN shop_owners so ON co.shop_owner_id = so.id
            JOIN subcategories sc ON co.subcat_id = sc.id
            JOIN categories cat ON sc.cat_id = cat.id
            WHERE co.customer_id = ${user.userId}
        `;

    if (status) {
      query = sql`
                SELECT 
                    co.*,
                    so.full_name as shop_name,
                    so.contact as shop_phone,
                    so.address as shop_address,
                    sc.subcat_name as product_name,
                    sc.unit,
                    cat.cat_name as category_name
                FROM customer_orders co
                JOIN shop_owners so ON co.shop_owner_id = so.id
                JOIN subcategories sc ON co.subcat_id = sc.id
                JOIN categories cat ON sc.cat_id = cat.id
                WHERE co.customer_id = ${user.userId} AND co.status = ${status}
            `;
    }

    // Add ordering and pagination
    const orders = await sql`
            ${query}
            ORDER BY co.created_at DESC
            LIMIT ${limit} OFFSET ${offset}
        `;

    // Get total count for pagination
    const countResult = status
      ? await sql`SELECT COUNT(*) FROM customer_orders WHERE customer_id = ${user.userId} AND status = ${status}`
      : await sql`SELECT COUNT(*) FROM customer_orders WHERE customer_id = ${user.userId}`;

    const totalOrders = parseInt(countResult[0].count);
    const totalPages = Math.ceil(totalOrders / limit);

    return c.json({
      success: true,
      orders,
      pagination: {
        page,
        limit,
        totalOrders,
        totalPages,
        hasNextPage: page < totalPages,
        hasPrevPage: page > 1,
      },
    });
  } catch (error: any) {
    console.error("Error fetching customer orders:", error);
    return c.json(
      {
        success: false,
        error: "Failed to fetch orders. Please try again.",
      },
      500
    );
  }
};

// Get a specific customer order
export const getCustomerOrder = async (c: any) => {
  try {
    const user = await getUserFromToken(c);
    if (!user || user.role !== "customer") {
      return c.json(
        {
          success: false,
          error: "Unauthorized. Customer login required.",
        },
        401
      );
    }

    const orderId = c.req.param("orderId");
    if (!orderId) {
      return c.json(
        {
          success: false,
          error: "Order ID is required",
        },
        400
      );
    }

    const order = await sql`
            SELECT 
                co.*,
                so.full_name as shop_name,
                so.contact as shop_phone,
                so.address as shop_address,
                sc.subcat_name as product_name,
                sc.unit,
                cat.cat_name as category_name
            FROM customer_orders co
            JOIN shop_owners so ON co.shop_owner_id = so.id
            JOIN subcategories sc ON co.subcat_id = sc.id
            JOIN categories cat ON sc.cat_id = cat.id
            WHERE co.id = ${orderId} AND co.customer_id = ${user.userId}
        `;

    if (order.length === 0) {
      return c.json(
        {
          success: false,
          error: "Order not found",
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
      order: {
        ...order[0],
        status_history: statusHistory,
      },
    });
  } catch (error: any) {
    console.error("Error fetching customer order:", error);
    return c.json(
      {
        success: false,
        error: "Failed to fetch order. Please try again.",
      },
      500
    );
  }
};

// Cancel customer order
export const cancelCustomerOrder = async (c: any) => {
  try {
    const user = await getUserFromToken(c);
    if (!user || user.role !== "customer") {
      return c.json(
        {
          success: false,
          error: "Unauthorized. Customer login required.",
        },
        401
      );
    }

    const { order_id, cancellation_reason } = await c.req.json();

    if (!order_id) {
      return c.json(
        {
          success: false,
          error: "Order ID is required",
        },
        400
      );
    }

    // Check if order exists and belongs to the customer
    const order = await sql`
            SELECT * FROM customer_orders 
            WHERE id = ${order_id} AND customer_id = ${user.userId}
        `;

    if (order.length === 0) {
      return c.json(
        {
          success: false,
          error: "Order not found",
        },
        404
      );
    }

    const currentOrder = order[0];

    // Check if order can be cancelled
    if (currentOrder.status === "cancelled") {
      return c.json(
        {
          success: false,
          error: "Order is already cancelled",
        },
        400
      );
    }

    if (currentOrder.status === "delivered") {
      return c.json(
        {
          success: false,
          error: "Cannot cancel a delivered order",
        },
        400
      );
    }

    // Update order status to cancelled (trigger will restore inventory)
    const updatedOrder = await sql`
            UPDATE customer_orders 
            SET status = 'cancelled', 
                cancellation_reason = ${
                  cancellation_reason || "Cancelled by customer"
                }
            WHERE id = ${order_id}
            RETURNING *
        `;

    // Log the cancellation in status history
    await sql`
            INSERT INTO order_status_history (order_id, old_status, new_status, changed_by, notes)
            VALUES (${order_id}, ${
      currentOrder.status
    }, 'cancelled', 'customer', ${
      cancellation_reason || "Cancelled by customer"
    })
        `;

    return c.json({
      success: true,
      message: "Order cancelled successfully",
      order: updatedOrder[0],
    });
  } catch (error: any) {
    console.error("Error cancelling customer order:", error);
    return c.json(
      {
        success: false,
        error: "Failed to cancel order. Please try again.",
      },
      500
    );
  }
};

// Get orders for shop owner (to manage customer orders)
export const getShopOwnerCustomerOrders = async (c: any) => {
  try {
    const user = await getUserFromToken(c);
    if (!user || user.role !== "shop_owner") {
      return c.json(
        {
          success: false,
          error: "Unauthorized. Shop owner login required.",
        },
        401
      );
    }

    // Get query parameters
    const status = c.req.query("status");
    const page = parseInt(c.req.query("page")) || 1;
    const limit = parseInt(c.req.query("limit")) || 20;
    const offset = (page - 1) * limit;

    // Build query with optional status filter
    let query = sql`
            SELECT 
                co.*,
                c.full_name as customer_name,
                c.contact as customer_phone,
                c.email as customer_email,
                sc.subcat_name as product_name,
                sc.unit,
                cat.cat_name as category_name
            FROM customer_orders co
            JOIN customers c ON co.customer_id = c.id
            JOIN subcategories sc ON co.subcat_id = sc.id
            JOIN categories cat ON sc.cat_id = cat.id
            WHERE co.shop_owner_id = ${user.userId}
        `;

    if (status) {
      query = sql`
                SELECT 
                    co.*,
                    c.full_name as customer_name,
                    c.contact as customer_phone,
                    c.email as customer_email,
                    sc.subcat_name as product_name,
                    sc.unit,
                    cat.cat_name as category_name
                FROM customer_orders co
                JOIN customers c ON co.customer_id = c.id
                JOIN subcategories sc ON co.subcat_id = sc.id
                JOIN categories cat ON sc.cat_id = cat.id
                WHERE co.shop_owner_id = ${user.userId} AND co.status = ${status}
            `;
    }

    // Add ordering and pagination
    const orders = await sql`
            ${query}
            ORDER BY co.created_at DESC
            LIMIT ${limit} OFFSET ${offset}
        `;

    // Get total count for pagination
    const countResult = status
      ? await sql`SELECT COUNT(*) FROM customer_orders WHERE shop_owner_id = ${user.userId} AND status = ${status}`
      : await sql`SELECT COUNT(*) FROM customer_orders WHERE shop_owner_id = ${user.userId}`;

    const totalOrders = parseInt(countResult[0].count);
    const totalPages = Math.ceil(totalOrders / limit);

    return c.json({
      success: true,
      orders,
      pagination: {
        page,
        limit,
        totalOrders,
        totalPages,
        hasNextPage: page < totalPages,
        hasPrevPage: page > 1,
      },
    });
  } catch (error: any) {
    console.error("Error fetching shop owner customer orders:", error);
    return c.json(
      {
        success: false,
        error: "Failed to fetch orders. Please try again.",
      },
      500
    );
  }
};

// Update order status (shop owner only)
export const updateCustomerOrderStatus = async (c: any) => {
  try {
    const user = await getUserFromToken(c);
    if (!user || user.role !== "shop_owner") {
      return c.json(
        {
          success: false,
          error: "Unauthorized. Shop owner login required.",
        },
        401
      );
    }

    const { order_id, status, notes } = await c.req.json();

    if (!order_id || !status) {
      return c.json(
        {
          success: false,
          error: "Order ID and status are required",
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
          error: "Invalid status. Valid statuses: " + validStatuses.join(", "),
        },
        400
      );
    }

    // Check if order exists and belongs to the shop owner
    const order = await sql`
            SELECT * FROM customer_orders 
            WHERE id = ${order_id} AND shop_owner_id = ${user.userId}
        `;

    if (order.length === 0) {
      return c.json(
        {
          success: false,
          error: "Order not found",
        },
        404
      );
    }

    const currentOrder = order[0];

    // Don't allow updating already delivered or cancelled orders
    if (currentOrder.status === "delivered" && status !== "delivered") {
      return c.json(
        {
          success: false,
          error: "Cannot change status of delivered order",
        },
        400
      );
    }

    if (currentOrder.status === "cancelled" && status !== "cancelled") {
      return c.json(
        {
          success: false,
          error: "Cannot change status of cancelled order",
        },
        400
      );
    }

    // Update order status
    const updatedOrder = await sql`
            UPDATE customer_orders 
            SET status = ${status}
            WHERE id = ${order_id}
            RETURNING *
        `;

    // Log the status change
    await sql`
            INSERT INTO order_status_history (order_id, old_status, new_status, changed_by, notes)
            VALUES (${order_id}, ${
      currentOrder.status
    }, ${status}, 'shop_owner', ${notes || "Status updated by shop owner"})
        `;

    return c.json({
      success: true,
      message: "Order status updated successfully",
      order: updatedOrder[0],
    });
  } catch (error: any) {
    console.error("Error updating customer order status:", error);
    return c.json(
      {
        success: false,
        error: "Failed to update order status. Please try again.",
      },
      500
    );
  }
};
