// Simple test server for GET messages endpoint
import { Hono } from "hono";
import { cors } from "hono/cors";
import { db } from "./src/db";

const app = new Hono();
app.use("/*", cors());

app.get("/", (c) => {
  return c.json({ message: "Test Messages API Server", status: "OK" });
});

app.get("/health", (c) => {
  return c.json({ success: true, message: "Test server is healthy" });
});

// Test GET messages endpoint
app.get("/api/messages/customer/:customer_id", async (c) => {
  try {
    const customer_id = c.req.param("customer_id");
    console.log("📧 Testing - Fetching messages for customer:", customer_id);

    // Simple direct query
    const conversations = await db`
      SELECT * FROM order_messages 
      WHERE receiver_id::text = ${customer_id} OR sender_id::text = ${customer_id}
      ORDER BY created_at DESC
    `;

    console.log("✅ Testing - Messages found:", conversations.length);

    return c.json({
      success: true,
      data: conversations,
      count: conversations.length,
    });
  } catch (error) {
    console.error("❌ Testing - Error fetching customer messages:", error);
    return c.json(
      {
        success: false,
        message: "Failed to fetch customer messages",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
});

console.log("Starting Test Messages API server on port 3006...");

export default {
  port: 3006,
  fetch: app.fetch,
};
