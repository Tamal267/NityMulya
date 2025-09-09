// Minimal test to verify Bun server works
import { Hono } from "hono";

const app = new Hono();

app.get("/", (c) => {
  return c.json({ message: "Minimal server working!" });
});

app.get("/test", (c) => {
  return c.json({
    message: "Test endpoint working!",
    timestamp: new Date().toISOString(),
  });
});

export default {
  port: 3007,
  fetch: app.fetch,
};
