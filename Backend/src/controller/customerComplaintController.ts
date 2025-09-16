import sql from "../db";
import { writeFile, mkdir } from "fs/promises";
import { existsSync } from "fs";
import path from "path";

// Create a public complaint (no authentication required)
export const createPublicComplaint = async (c: any) => {
  try {
    let body: any;
    let fileData: any = null;

    // Check if this is a multipart form (file upload)
    const contentType = c.req.header("content-type") || "";

    if (contentType.includes("multipart/form-data")) {
      console.log("📎 Processing multipart form with file upload...");

      const formData = await c.req.formData();

      // Extract form fields
      body = {};
      const fields = [
        "customer_name",
        "customer_email",
        "customer_phone",
        "shop_owner_id",
        "shop_name",
        "complaint_type",
        "description",
        "priority",
        "severity",
        "product_id",
        "product_name",
      ];

      for (const field of fields) {
        const value = formData.get(field);
        if (value) {
          body[field] = value.toString();
        }
      }

      // Extract file
      const file = formData.get("attachment");
      if (file && file instanceof File) {
        console.log("📁 File found:", {
          name: file.name,
          size: file.size,
          type: file.type,
        });

        fileData = {
          name: file.name,
          size: file.size,
          type: file.type,
          buffer: Buffer.from(await file.arrayBuffer()),
        };
      }
    } else {
      console.log("📝 Processing regular JSON request...");
      body = await c.req.json();
    }

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

    let fileUrl = null;

    // Handle file upload first if file exists
    if (fileData) {
      console.log("📁 Processing file upload...");

      try {
        // Create uploads directory if it doesn't exist
        const uploadsDir = path.join(process.cwd(), "uploads", "complaints");
        if (!existsSync(uploadsDir)) {
          await mkdir(uploadsDir, { recursive: true });
          console.log("📁 Created uploads directory:", uploadsDir);
        }

        // Generate unique filename
        const timestamp = Date.now();
        const fileExtension = path.extname(fileData.name);
        const sanitizedFileName = fileData.name.replace(/[^a-zA-Z0-9.-]/g, "_");
        const fileName = `${timestamp}_${sanitizedFileName}`;
        const filePath = path.join(uploadsDir, fileName);

        console.log("💾 Saving file to:", filePath);

        // Save file to disk
        await writeFile(filePath, fileData.buffer);

        // Create file URL (relative path for API access)
        fileUrl = `/uploads/complaints/${fileName}`;

        console.log("✅ File saved successfully:", fileUrl);
      } catch (fileError: any) {
        console.error("❌ Error handling file upload:", fileError);
        // Continue without file if upload fails
      }
    }

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
        submitted_at,
        file_url
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
        ${severity || "Minor"},
        ${description},
        'Received',
        NOW(),
        ${fileUrl}
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

    const user = c.get("user");
    console.log("👤 User from context:", user);

    const customerId = user.userId;
    console.log("🆔 Customer ID:", customerId);

    let body: any;
    let fileData: any = null;

    // Check if this is a multipart form (file upload)
    const contentType = c.req.header("content-type") || "";

    if (contentType.includes("multipart/form-data")) {
      console.log("Processing multipart form with file upload...");

      const formData = await c.req.formData();

      // Extract form fields
      body = {};
      const fields = [
        "shop_owner_id",
        "shop_name",
        "complaint_type",
        "description",
        "priority",
        "severity",
        "product_id",
        "product_name",
      ];

      for (const field of fields) {
        const value = formData.get(field);
        if (value) {
          body[field] = value.toString();
        }
      }

      // Extract file
      const file = formData.get("attachment");
      if (file && file instanceof File) {
        console.log("� File found:", {
          name: file.name,
          size: file.size,
          type: file.type,
        });

        fileData = {
          name: file.name,
          size: file.size,
          type: file.type,
          buffer: Buffer.from(await file.arrayBuffer()),
        };
      }
    } else {
      console.log("📝 Processing regular JSON request...");
      body = await c.req.json();
    }

    console.log("📝 Processed request body:", JSON.stringify(body, null, 2));

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
        priority: !!priority,
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
      product_id: product_id || "N/A",
      product_name: product_name || "N/A",
      customerId,
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
      email: customer.email,
    });

    // Create the complaint
    console.log("💾 Inserting complaint into database...");

    let fileUrl = null;

    // Handle file upload first if file exists
    if (fileData) {
      console.log("📁 Processing file upload...");

      try {
        // Create uploads directory if it doesn't exist
        const uploadsDir = path.join(process.cwd(), "uploads", "complaints");
        if (!existsSync(uploadsDir)) {
          await mkdir(uploadsDir, { recursive: true });
          console.log("📁 Created uploads directory:", uploadsDir);
        }

        // Generate unique filename
        const timestamp = Date.now();
        const fileExtension = path.extname(fileData.name);
        const sanitizedFileName = fileData.name.replace(/[^a-zA-Z0-9.-]/g, "_");
        const fileName = `${timestamp}_${sanitizedFileName}`;
        const filePath = path.join(uploadsDir, fileName);

        console.log("💾 Saving file to:", filePath);

        // Save file to disk
        await writeFile(filePath, fileData.buffer);

        // Create file URL (relative path for API access)
        fileUrl = `/uploads/complaints/${fileName}`;

        console.log("✅ File saved successfully:", fileUrl);
      } catch (fileError: any) {
        console.error("❌ Error handling file upload:", fileError);
        // Continue without file if upload fails
      }
    }

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
        submitted_at,
        file_url
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
        ${severity || "Minor"},
        ${description},
        'Received',
        NOW(),
        ${fileUrl}
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

    if (status && status !== "all") {
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
