import { Hono } from "hono";
import { cors } from "hono/cors";

const app = new Hono();
app.use("*", cors());

// Health check endpoint for auto-discovery
app.get("/health", (c) => {
  console.log("🏥 Health check requested");
  return c.json({
    status: "ok",
    service: "NityMulya Backend",
    timestamp: new Date().toISOString(),
  });
});

// ULTRA SIMPLE - INSTANT RESPONSE
app.post("/complaints/submit", async (c) => {
  console.log("⚡ INSTANT COMPLAINT!");

  // NO PROCESSING - INSTANT RESPONSE
  return c.json(
    {
      success: true,
      message: "অভিযোগ জমা হয়েছে!",
      data: {
        complaint_number: `INSTANT-${Date.now()}`,
        status: "received",
      },
    },
    201
  );
});

// EVEN SIMPLER - GET route for testing
app.get("/complaints/submit", async (c) => {
  console.log("⚡ GET COMPLAINT TEST!");

  return c.json({
    success: true,
    message: "GET Test successful!",
    data: { test: true },
  });
});

// Health check
app.get("/health", async (c) => {
  return c.json({
    success: true,
    message: "Ultra simple API working!",
    timestamp: new Date().toISOString(),
  });
});

// Catch all
app.all("*", (c) => {
  return c.json(
    {
      success: false,
      message: "Route not found",
      available_routes: ["POST /api/complaints/submit", "GET /api/health"],
    },
    404
  );
});

export default app;
