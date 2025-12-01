/**
 * AI-Enhanced Complaint Routes
 */

import { Hono } from "hono";
import {
  submitComplaintWithAI,
  getComplaintsWithAI,
  reanalyzeComplaint,
  getAIAnalytics,
} from "../controller/ai_complaint_controller";

const aiComplaintRoutes = new Hono();

// Submit new complaint with AI analysis
aiComplaintRoutes.post("/submit", submitComplaintWithAI);

// Get all complaints with AI insights (for admin)
aiComplaintRoutes.get("/", getComplaintsWithAI);

// Reanalyze existing complaint
aiComplaintRoutes.post("/:id/reanalyze", reanalyzeComplaint);

// Get AI analytics dashboard
aiComplaintRoutes.get("/analytics", getAIAnalytics);

export default aiComplaintRoutes;
