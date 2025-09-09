// Simplified DNCRP routes for complaint submission with database fallback
import { Hono } from "hono";
import { cors } from "hono/cors";

const app = new Hono();

app.use("*", cors());

// Database connection with fallback
let db: any = null;
let dbAvailable = false;

try {
  const { db: dbConnection } = require("./db.js");
  db = dbConnection;
  dbAvailable = true;
  console.log("✅ Database connection available");
} catch (error) {
  console.log(
    "⚠️ Database unavailable, using mock mode:",
    error instanceof Error ? error.message : "Unknown error"
  );
  dbAvailable = false;
}

// Mock storage for when database is unavailable
const mockComplaints: any[] = [];
let complaintIdCounter = 1;

// Database helper functions
async function ensureTablesExist() {
  if (!dbAvailable) {
    console.log("📋 Database not available, using mock storage");
    return;
  }

  try {
    console.log("📋 Database available, checking tables...");
    // Tables should already exist, just confirm connection works
    const testResult = await db`SELECT 1 as test`;
    console.log(
      "✅ Database connection working:",
      testResult.length > 0 ? "OK" : "Failed"
    );
  } catch (error) {
    console.error(
      "⚠️ Database test failed, falling back to mock mode:",
      error instanceof Error ? error.message : "Unknown error"
    );
    dbAvailable = false;
  }
}

// Initialize database check on startup (non-blocking)
if (dbAvailable) {
  setTimeout(() => {
    ensureTablesExist().catch((err) => {
      console.log("⚠️ Async database check failed:", err.message);
    });
  }, 100);
}

// Submit complaint (for customers) - ULTRA SIMPLE VERSION
app.post("/complaints/submit", async (c) => {
  console.log("� COMPLAINT RECEIVED!");

  try {
    const formData = await c.req.formData();
    console.log("� Form parsed!");

    // Extract ONLY essential data
    const customer_name =
      formData.get("customer_name")?.toString() || "Anonymous";
    const shop_name = formData.get("shop_name")?.toString() || "Unknown Shop";
    const description =
      formData.get("description")?.toString() || "No description";

    // Simple complaint number
    const complaintNumber = `DNCRP-${Date.now()}`;

    console.log("� Saving:", complaintNumber);

    // Quick database save (no complex logic)
    if (dbAvailable) {
      try {
        await db`
          INSERT INTO complaints (complaint_number, customer_name, shop_name, complaint_description, status, created_at) 
          VALUES (${complaintNumber}, ${customer_name}, ${shop_name}, ${description}, 'pending', CURRENT_TIMESTAMP)
        `;
        console.log("✅ DATABASE SAVED!");
      } catch (err) {
        console.log("⚠️ DB failed, using mock");
        mockComplaints.push({
          id: complaintIdCounter++,
          complaint_number: complaintNumber,
          customer_name,
          shop_name,
          complaint_description: description,
          status: "pending",
          created_at: new Date().toISOString(),
        });
      }
    } else {
      console.log("📋 Using mock storage");
      mockComplaints.push({
        id: complaintIdCounter++,
        complaint_number: complaintNumber,
        customer_name,
        shop_name,
        complaint_description: description,
        status: "pending",
        created_at: new Date().toISOString(),
      });
    }

    console.log("🎉 DONE!");

    // Quick response
    return c.json(
      {
        success: true,
        message: "Complaint submitted!",
        data: { complaint_number: complaintNumber },
      },
      201
    );
  } catch (error) {
    console.error("❌ ERROR:", error);
    return c.json({ success: false, message: "Failed" }, 500);
  }
});

// Get all complaints (from database or mock storage)
app.get("/complaints", async (c) => {
  try {
    let complaints = [];

    if (dbAvailable) {
      try {
        complaints = await db`
          SELECT c.*, 
                 array_agg(
                   json_build_object(
                     'id', cf.id,
                     'file_name', cf.file_name,
                     'file_type', cf.file_type,
                     'file_size', cf.file_size,
                     'uploaded_at', cf.uploaded_at
                   )
                 ) FILTER (WHERE cf.id IS NOT NULL) as files
          FROM complaints c
          LEFT JOIN complaint_files cf ON c.id = cf.complaint_id
          GROUP BY c.id
          ORDER BY c.created_at DESC
        `;
        console.log(
          "📋 Retrieved complaints from database, total:",
          complaints.length
        );
      } catch (dbError) {
        console.log("⚠️ Database query failed, using mock storage");
        complaints = mockComplaints;
      }
    } else {
      complaints = mockComplaints;
      console.log(
        "📋 Retrieved complaints from mock storage, total:",
        complaints.length
      );
    }

    return c.json({
      success: true,
      data: complaints,
      total: complaints.length,
      storage_type: dbAvailable ? "database" : "mock",
    });
  } catch (error) {
    console.error("❌ Get complaints error:", error);
    return c.json(
      {
        success: false,
        message: "Error retrieving complaints",
      },
      500
    );
  }
});

// Health check endpoint (simple version without database)
app.get("/health", async (c) => {
  try {
    console.log("🏥 Health check requested");

    return c.json({
      success: true,
      message: "DNCRP API is working",
      timestamp: new Date().toISOString(),
      complaints_count: mockComplaints.length,
      storage_type: dbAvailable ? "database_available" : "mock_only",
      database_status: dbAvailable ? "connected" : "unavailable",
    });
  } catch (error) {
    console.error("❌ Health check error:", error);
    return c.json(
      {
        success: false,
        message: "Health check failed",
        timestamp: new Date().toISOString(),
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
});

// Catchall for debugging unmatched /api routes
app.all("/*", (c) => {
  console.log(`❓ Unmatched API route: ${c.req.method} ${c.req.url}`);
  return c.json(
    {
      success: false,
      message: `Route not found: ${c.req.method} ${c.req.url}`,
      available_routes: [
        "POST /api/complaints/submit",
        "GET /api/complaints",
        "GET /api/health",
      ],
    },
    404
  );
});

export default app;
