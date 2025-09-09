// DNCRP API Routes for Backend
// Enhanced server implementation for complaint management

import { Hono } from "hono";
import { cors } from "hono/cors";
import jwt from "jsonwebtoken";
import bcrypt from "bcrypt";

const app = new Hono();

// Database connection with fallback
let sql: any = null;
let dbAvailable = false;

try {
  const postgres = require("postgres");
  sql = postgres(
    process.env.DATABASE_URL || "postgresql://localhost:5432/nitymulya"
  );
  dbAvailable = true;
  console.log("✅ Database connection established");
} catch (error) {
  console.log("⚠️ Database unavailable, using mock mode:", error.message);
  dbAvailable = false;
}

// Middleware
app.use("*", cors());

// JWT secret
const JWT_SECRET = process.env.JWT_SECRET || "your-secret-key";

// Authentication middleware
const authenticateToken = async (c, next) => {
  const authHeader = c.req.header("authorization");
  const token = authHeader && authHeader.split(" ")[1];

  if (!token) {
    return c.json({ success: false, message: "Access token required" }, 401);
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    c.user = decoded;
    await next();
  } catch (error) {
    return c.json({ success: false, message: "Invalid token" }, 401);
  }
};

// DNCRP admin authentication
app.post("/api/auth/login", async (c) => {
  try {
    const { email, password, role } = await c.req.json();

    // For DNCRP demo, check specific credentials
    if (role === "dncrp_admin") {
      if (email === "DNCRP_Demo@govt.com" && password === "DNCRP_Demo") {
        const token = jwt.sign(
          { id: 1, email, role: "dncrp_admin" },
          JWT_SECRET,
          { expiresIn: "24h" }
        );

        return c.json({
          success: true,
          message: "Login successful",
          data: {
            token,
            user: { id: 1, email, role: "dncrp_admin" },
          },
        });
      } else {
        return c.json(
          {
            success: false,
            message: "Invalid credentials",
          },
          401
        );
      }
    }

    // Regular user authentication (existing logic)
    const users = await sql`
      SELECT * FROM users 
      WHERE email = ${email} AND role = ${role}
    `;

    if (users.length === 0) {
      return c.json(
        {
          success: false,
          message: "User not found",
        },
        404
      );
    }

    const user = users[0];
    const isValidPassword = await bcrypt.compare(password, user.password_hash);

    if (!isValidPassword) {
      return c.json(
        {
          success: false,
          message: "Invalid password",
        },
        401
      );
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      JWT_SECRET,
      { expiresIn: "24h" }
    );

    return c.json({
      success: true,
      message: "Login successful",
      data: {
        token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
        },
      },
    });
  } catch (error) {
    console.error("Login error:", error);
    return c.json(
      {
        success: false,
        message: "Server error",
      },
      500
    );
  }
});

// Get all complaints for DNCRP dashboard
app.get("/api/dncrp/complaints", authenticateToken, async (c) => {
  try {
    // Check if user is DNCRP admin
    if (c.user.role !== "dncrp_admin") {
      return c.json(
        {
          success: false,
          message: "Access denied",
        },
        403
      );
    }

    const complaints = await sql`
      SELECT 
        c.*,
        cf.id as file_id,
        cf.file_name,
        cf.file_url,
        cf.file_type,
        cf.file_size,
        cf.uploaded_at as file_uploaded_at
      FROM complaints c
      LEFT JOIN complaint_files cf ON c.id = cf.complaint_id
      ORDER BY c.submitted_at DESC
    `;

    // Group files by complaint
    const complaintsMap = new Map();

    complaints.forEach((row) => {
      if (!complaintsMap.has(row.id)) {
        complaintsMap.set(row.id, {
          id: row.id,
          complaint_number: row.complaint_number,
          customer_id: row.customer_id,
          customer_name: row.customer_name,
          customer_email: row.customer_email,
          customer_phone: row.customer_phone,
          shop_id: row.shop_id,
          shop_name: row.shop_name,
          product_id: row.product_id,
          product_name: row.product_name,
          category: row.category,
          priority: row.priority,
          severity: row.severity,
          description: row.description,
          status: row.status,
          forwarded_to: row.forwarded_to,
          forwarded_at: row.forwarded_at,
          solved_at: row.solved_at,
          submitted_at: row.submitted_at,
          updated_at: row.updated_at,
          resolution_comment: row.resolution_comment,
          dncrp_officer_id: row.dncrp_officer_id,
          files: [],
        });
      }

      if (row.file_id) {
        complaintsMap.get(row.id).files.push({
          id: row.file_id,
          complaint_id: row.id,
          file_name: row.file_name,
          file_url: row.file_url,
          file_type: row.file_type,
          file_size: row.file_size,
          uploaded_at: row.file_uploaded_at,
        });
      }
    });

    const result = Array.from(complaintsMap.values());

    return c.json({
      success: true,
      data: result,
    });
  } catch (error) {
    console.error("Get complaints error:", error);
    return c.json(
      {
        success: false,
        message: "Server error",
      },
      500
    );
  }
});

// Get complaint statistics
app.get("/api/dncrp/complaints/stats", authenticateToken, async (c) => {
  try {
    if (c.user.role !== "dncrp_admin") {
      return c.json(
        {
          success: false,
          message: "Access denied",
        },
        403
      );
    }

    const stats = await sql`
      SELECT 
        COUNT(*) as total,
        COUNT(CASE WHEN status = 'Received' THEN 1 END) as received,
        COUNT(CASE WHEN status = 'Forwarded' THEN 1 END) as forwarded,
        COUNT(CASE WHEN status = 'Solved' THEN 1 END) as solved
      FROM complaints
    `;

    return c.json({
      success: true,
      data: {
        total: parseInt(stats[0].total),
        received: parseInt(stats[0].received),
        forwarded: parseInt(stats[0].forwarded),
        solved: parseInt(stats[0].solved),
      },
    });
  } catch (error) {
    console.error("Get stats error:", error);
    return c.json(
      {
        success: false,
        message: "Server error",
      },
      500
    );
  }
});

// Update complaint status
app.put("/api/dncrp/complaints/:id/status", authenticateToken, async (c) => {
  try {
    if (c.user.role !== "dncrp_admin") {
      return c.json(
        {
          success: false,
          message: "Access denied",
        },
        403
      );
    }

    const complaintId = c.req.param("id");
    const { status, comment } = await c.req.json();

    // Get current complaint
    const currentComplaint = await sql`
      SELECT * FROM complaints WHERE id = ${complaintId}
    `;

    if (currentComplaint.length === 0) {
      return c.json(
        {
          success: false,
          message: "Complaint not found",
        },
        404
      );
    }

    const oldStatus = currentComplaint[0].status;

    // Update complaint
    const updateData = {
      status,
      updated_at: new Date(),
      dncrp_officer_id: c.user.id,
    };

    if (status === "Forwarded") {
      updateData.forwarded_at = new Date();
      updateData.forwarded_to = "DNCRP Department";
    } else if (status === "Solved") {
      updateData.solved_at = new Date();
      if (comment) {
        updateData.resolution_comment = comment;
      }
    }

    await sql`
      UPDATE complaints 
      SET ${sql(updateData)}
      WHERE id = ${complaintId}
    `;

    // Add to history
    await sql`
      INSERT INTO complaint_history (
        complaint_id, old_status, new_status, comment, 
        changed_by, changed_by_name, timestamp
      ) VALUES (
        ${complaintId}, ${oldStatus}, ${status}, ${comment || null},
        ${c.user.id}, 'DNCRP Officer', ${new Date()}
      )
    `;

    // Create notification for customer
    await sql`
      INSERT INTO notifications (
        user_id, type, title, message, complaint_id, created_at
      ) VALUES (
        ${currentComplaint[0].customer_id},
        'complaint_${status.toLowerCase()}',
        'Complaint Status Updated',
        ${`Your complaint ${
          currentComplaint[0].complaint_number
        } has been ${status.toLowerCase()}`},
        ${complaintId},
        ${new Date()}
      )
    `;

    return c.json({
      success: true,
      message: "Status updated successfully",
    });
  } catch (error) {
    console.error("Update status error:", error);
    return c.json(
      {
        success: false,
        message: "Server error",
      },
      500
    );
  }
});

// Get complaint details
app.get("/api/dncrp/complaints/:id", authenticateToken, async (c) => {
  try {
    if (c.user.role !== "dncrp_admin") {
      return c.json(
        {
          success: false,
          message: "Access denied",
        },
        403
      );
    }

    const complaintId = c.req.param("id");

    // Get complaint with files
    const complaint = await sql`
      SELECT c.*, cf.id as file_id, cf.file_name, cf.file_url, cf.file_type
      FROM complaints c
      LEFT JOIN complaint_files cf ON c.id = cf.complaint_id
      WHERE c.id = ${complaintId}
    `;

    if (complaint.length === 0) {
      return c.json(
        {
          success: false,
          message: "Complaint not found",
        },
        404
      );
    }

    // Get history
    const history = await sql`
      SELECT * FROM complaint_history 
      WHERE complaint_id = ${complaintId}
      ORDER BY timestamp DESC
    `;

    // Group files
    const files = complaint
      .filter((row) => row.file_id)
      .map((row) => ({
        id: row.file_id,
        complaint_id: row.id,
        file_name: row.file_name,
        file_url: row.file_url,
        file_type: row.file_type,
      }));

    const result = {
      ...complaint[0],
      files,
      history,
    };

    return c.json({
      success: true,
      data: result,
    });
  } catch (error) {
    console.error("Get complaint details error:", error);
    return c.json(
      {
        success: false,
        message: "Server error",
      },
      500
    );
  }
});

// Submit complaint (for customers)
app.post("/api/complaints/submit", async (c) => {
  try {
    console.log("🔥 DNCRP complaint route hit!");
    const formData = await c.req.formData();
    console.log(
      "📋 Form data received:",
      Object.fromEntries(formData.entries())
    );

    // Extract form data
    const customer_id = formData.get("customer_id");
    const customer_name = formData.get("customer_name");
    const customer_email = formData.get("customer_email");
    const shop_id = formData.get("shop_id");
    const shop_name = formData.get("shop_name");
    const category = formData.get("category");
    const priority = formData.get("priority") || "Medium";
    const severity = formData.get("severity") || "Minor";
    const description = formData.get("description");

    // Generate complaint number
    const complaintNumber = `DNCRP-${Date.now()}-${Math.random()
      .toString(36)
      .substr(2, 5)
      .toUpperCase()}`;

    console.log("📝 Processing complaint:", {
      complaintNumber,
      customer_name,
      shop_name,
      category,
      priority,
      severity,
    });

    // For now, return success without database insertion to test connectivity
    // We'll add database insertion once we confirm the route is working
    return c.json(
      {
        success: true,
        message: "Complaint received successfully - testing mode",
        data: {
          complaint_number: complaintNumber,
          complaint_id: Math.floor(Math.random() * 10000),
          test_mode: true,
        },
      },
      201
    );
  } catch (error) {
    console.error("Submit complaint error:", error);
    return c.json(
      {
        success: false,
        message:
          "Server error: " +
          (error instanceof Error ? error.message : "Unknown error"),
      },
      500
    );
  }
});

// Get shop details
app.get("/api/shops/:id", authenticateToken, async (c) => {
  try {
    const shopId = c.req.param("id");

    const shops = await sql`
      SELECT * FROM shops WHERE id = ${shopId}
    `;

    if (shops.length === 0) {
      return c.json(
        {
          success: false,
          message: "Shop not found",
        },
        404
      );
    }

    return c.json({
      success: true,
      data: shops[0],
    });
  } catch (error) {
    console.error("Get shop error:", error);
    return c.json(
      {
        success: false,
        message: "Server error",
      },
      500
    );
  }
});

// Get customer details
app.get("/api/customers/:id", authenticateToken, async (c) => {
  try {
    const customerId = c.req.param("id");

    const customers = await sql`
      SELECT * FROM users WHERE id = ${customerId} AND role = 'customer'
    `;

    if (customers.length === 0) {
      return c.json(
        {
          success: false,
          message: "Customer not found",
        },
        404
      );
    }

    return c.json({
      success: true,
      data: customers[0],
    });
  } catch (error) {
    console.error("Get customer error:", error);
    return c.json(
      {
        success: false,
        message: "Server error",
      },
      500
    );
  }
});

// Download complaints as PDF (placeholder)
app.post("/api/dncrp/complaints/download-pdf", authenticateToken, async (c) => {
  try {
    if (c.user.role !== "dncrp_admin") {
      return c.json(
        {
          success: false,
          message: "Access denied",
        },
        403
      );
    }

    // For now, return a simple PDF placeholder
    const pdfContent = Buffer.from("PDF content placeholder");

    return new Response(pdfContent, {
      headers: {
        "Content-Type": "application/pdf",
        "Content-Disposition": "attachment; filename=complaints.pdf",
      },
    });
  } catch (error) {
    console.error("Download PDF error:", error);
    return c.json(
      {
        success: false,
        message: "Server error",
      },
      500
    );
  }
});

export default app;
