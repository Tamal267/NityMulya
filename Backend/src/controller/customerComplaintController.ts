import sql from "../db";

// Create a public complaint (no authentication required)
export const createPublicComplaint = async (c: any) => {
  try {
    const body = await c.req.json();

    const {
      customer_name,
      customer_email,
      customer_phone,
      shop_owner_id,
      shop_name,
      complaint_type,
      description,
      priority,
      severity,
      product_id,
      product_name,
    } = body;

    // Validate required fields
    if (
      !customer_name ||
      !customer_email ||
      !shop_owner_id ||
      !shop_name ||
      !complaint_type ||
      !description ||
      !priority
    ) {
      return c.json(
        {
          success: false,
          message: "Missing required fields",
        },
        400
      );
    }

    // Generate complaint number
    const complaintNumber = `DNCRP${Date.now()}`;

    // Create the complaint without customer_id (for public complaints)
    const complaintResult = await sql`
      INSERT INTO complaints (
        complaint_number,
        customer_id,
        customer_name,
        customer_email,
        customer_phone,
        shop_name,
        product_id,
        product_name,
        category,
        priority,
        severity,
        description,
        status,
        submitted_at
      ) VALUES (
        ${complaintNumber},
        0,
        ${customer_name},
        ${customer_email},
        ${customer_phone || null},
        ${shop_name},
        ${product_id || null},
        ${product_name || null},
        ${complaint_type},
        ${priority},
        ${severity || 'Minor'},
        ${description},
        'Received',
        NOW()
      )
      RETURNING *
    `;

    const complaint = complaintResult[0];

    return c.json(
      {
        success: true,
        message: "অভিযোগ সফলভাবে জমা হয়েছে!",
        complaint: {
          ...complaint,
          id: complaint.id,
          complaint_number: complaint.complaint_number,
        },
      },
      201
    );
  } catch (error: any) {
    console.error("Error creating public complaint:", error);
    return c.json(
      {
        success: false,
        message: error.message || "Internal server error",
      },
      500
    );
  }
};

// Create a new complaint
export const createCustomerComplaint = async (c: any) => {
  try {
    console.log("🚀 Starting complaint submission...");
    
    const body = await c.req.json();
    console.log("📝 Raw request body:", JSON.stringify(body, null, 2));
    
    const user = c.get("user");
    console.log("👤 User from context:", user);
    
    const customerId = user.userId;
    console.log("🆔 Customer ID:", customerId);

    const {
      shop_owner_id,
      shop_name,
      complaint_type,
      description,
      priority,
      severity,
      product_id,
      product_name,
    } = body;

    // Validate required fields
    if (
      !shop_owner_id ||
      !shop_name ||
      !complaint_type ||
      !description ||
      !priority
    ) {
      console.log("❌ Missing required fields:", {
        shop_owner_id: !!shop_owner_id,
        shop_name: !!shop_name,
        complaint_type: !!complaint_type,
        description: !!description,
        priority: !!priority
      });
      return c.json(
        {
          success: false,
          message: "Missing required fields",
        },
        400
      );
    }

    console.log("📥 Complaint submission data:", {
      shop_owner_id,
      shop_name,
      complaint_type,
      description,
      priority,
      severity,
      product_id: product_id || 'N/A',
      product_name: product_name || 'N/A',
      customerId
    });

    // Generate complaint number
    const complaintNumber = `DNCRP${Date.now()}`;
    
    console.log("🔢 Generated complaint number:", complaintNumber);

    // Get customer details
    const customerResult = await sql`
      SELECT full_name, email 
      FROM customers 
      WHERE id = ${customerId}
    `;
    
    console.log("👤 Customer lookup result:", customerResult);
    
    const customer = customerResult[0];
    if (!customer) {
      console.log("❌ Customer not found for ID:", customerId);
      return c.json(
        {
          success: false,
          message: "Customer not found",
        },
        404
      );
    }

    console.log("✅ Customer found:", {
      id: customerId,
      name: customer.full_name,
      email: customer.email
    });

    // Create the complaint
    console.log("💾 Inserting complaint into database...");
    const complaintResult = await sql`
      INSERT INTO complaints (
        complaint_number,
        customer_id,
        customer_name,
        customer_email,
        customer_phone,
        shop_name,
        product_id,
        product_name,
        category,
        priority,
        severity,
        description,
        status,
        submitted_at
      ) VALUES (
        ${complaintNumber},
        ${customerId},
        ${customer.full_name},
        ${customer.email},
        ${null},
        ${shop_name},
        ${product_id || null},
        ${product_name || null},
        ${complaint_type},
        ${priority},
        ${severity || 'Minor'},
        ${description},
        'Received',
        NOW()
      )
      RETURNING *
    `;

    console.log("🎉 Database insert successful:", complaintResult[0]);
    const complaint = complaintResult[0];

    return c.json(
      {
        success: true,
        message: "অভিযোগ সফলভাবে জমা হয়েছে!",
        complaint: {
          ...complaint,
          id: complaint.id,
          complaint_number: complaint.complaint_number,
        },
      },
      201
    );
  } catch (error: any) {
    console.error("❌ Error creating complaint:");
    console.error("Error message:", error.message);
    console.error("Error stack:", error.stack);
    console.error("Full error object:", error);
    return c.json(
      {
        success: false,
        message: error.message || "Internal server error",
      },
      500
    );
  }
};

// Get customer complaints
export const getCustomerComplaints = async (c: any) => {
  try {
    const user = c.get("user");
    const customerId = user.userId;

    const { status, page = 1, limit = 10 } = c.req.query();
    const offset = (parseInt(page) - 1) * parseInt(limit);

    let whereClause = sql`WHERE customer_id = ${customerId}`;
    
    if (status && status !== 'all') {
      whereClause = sql`WHERE customer_id = ${customerId} AND status = ${status}`;
    }

    // Get complaints with pagination
    const complaints = await sql`
      SELECT 
        id,
        complaint_number,
        shop_name,
        product_name,
        category,
        description,
        priority,
        severity,
        status,
        submitted_at,
        updated_at
      FROM complaints
      ${whereClause}
      ORDER BY submitted_at DESC
      LIMIT ${parseInt(limit)}
      OFFSET ${offset}
    `;

    // Get total count
    const countResult = await sql`
      SELECT COUNT(*) as total
      FROM complaints
      ${whereClause}
    `;

    const total = parseInt(countResult[0].total);
    const totalPages = Math.ceil(total / parseInt(limit));

    return c.json({
      success: true,
      complaints,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        totalPages,
        hasNext: parseInt(page) < totalPages,
        hasPrev: parseInt(page) > 1,
      },
    });
  } catch (error: any) {
    console.error("Error fetching complaints:", error);
    return c.json(
      {
        success: false,
        message: error.message || "Internal server error",
        complaints: [],
      },
      500
    );
  }
};
