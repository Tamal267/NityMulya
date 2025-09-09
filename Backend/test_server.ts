import { Hono } from "hono";
import { cors } from "hono/cors";

const app = new Hono();

app.use("/*", cors());

app.get("/", (c) => {
  return c.json({
    message: "Test server is running!",
    timestamp: new Date().toISOString(),
    status: "OK",
  });
});

app.get("/api/test", (c) => {
  return c.json({
    message: "Test endpoint working!",
    database: "PostgreSQL (Supabase)",
    port: 3005,
  });
});

console.log("Starting test server on port 3005...");

export default {
  port: 3006,
  fetch: app.fetch,
};
