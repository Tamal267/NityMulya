/**
 * Enhanced Complaint Controller with AI Analysis
 * Integrates NLP service for automatic complaint processing
 */

import { Context } from "hono";
import sql from "../db";
import { nlpService, ComplaintAnalysisResult } from "../services/nlp_service";

/**
 * Submit complaint with AI analysis
 */
export const submitComplaintWithAI = async (c: Context) => {
  try {
    const body = await c.req.json();
    console.log("📝 Complaint submission received:", body);

    const {
      customer_id,
      customer_name,
      customer_email,
      customer_phone,
      shop_name,
      product_id,
      product_name,
      category,
      description,
      priority,
      severity,
    } = body;

    // Validate required fields
    if (!customer_name || !customer_email || !shop_name || !description) {
      return c.json(
        {
          success: false,
          message:
            "Missing required fields: customer_name, customer_email, shop_name, description",
        },
        400
      );
    }

    // Generate complaint number
    const complaintNumber = `DNCRP-${Date.now()}-${Math.random()
      .toString(36)
      .substr(2, 6)
      .toUpperCase()}`;

    // Step 1: Run AI Analysis (async, non-blocking)
    console.log("🤖 Running AI analysis...");
    let aiAnalysis: ComplaintAnalysisResult | null = null;

    try {
      aiAnalysis = await nlpService.analyzeComplaint({
        complaint_text: description,
        customer_name,
        shop_name,
        product_name,
      });
    } catch (error) {
      console.warn("⚠️ AI analysis failed, proceeding without it:", error);
    }

    // Step 2: Prepare database insert
    const now = new Date();

    // Use AI-detected priority if available, otherwise use manual
    const finalPriority =
      aiAnalysis?.priority?.priority_level || priority || "Medium";
    const finalCategory =
      aiAnalysis?.category?.category || category || "অন্যান্য";

    // Step 3: Insert complaint with AI analysis
    const result = await sql`
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
        updated_at,
        -- AI Analysis fields
        validity_score,
        is_valid,
        validity_reasons,
        ai_priority_score,
        ai_priority_level,
        priority_reasons,
        sentiment_score,
        sentiment,
        emotion_intensity,
        ai_category,
        ai_category_confidence,
        matched_keywords,
        ai_summary,
        detected_language,
        ai_analysis_date,
        ai_processing_time_ms,
        ai_full_analysis
      ) VALUES (
        ${complaintNumber},
        ${customer_id || null},
        ${customer_name},
        ${customer_email},
        ${customer_phone || null},
        ${shop_name},
        ${product_id || null},
        ${product_name || null},
        ${finalCategory},
        ${finalPriority},
        ${severity || "Minor"},
        ${description},
        'Received',
        ${now},
        ${now},
        -- AI Analysis values
        ${aiAnalysis?.validity?.validity_score || null},
        ${aiAnalysis?.validity?.is_valid ?? true},
        ${aiAnalysis?.validity?.reasons || []},
        ${aiAnalysis?.priority?.priority_score || null},
        ${aiAnalysis?.priority?.priority_level || null},
        ${aiAnalysis?.priority?.reasons || []},
        ${aiAnalysis?.sentiment?.sentiment_score || null},
        ${aiAnalysis?.sentiment?.sentiment || null},
        ${aiAnalysis?.sentiment?.emotion_intensity || null},
        ${aiAnalysis?.category?.category || null},
        ${aiAnalysis?.category?.confidence || null},
        ${aiAnalysis?.category?.matched_keywords || 0},
        ${aiAnalysis?.summary || null},
        ${aiAnalysis?.language || null},
        ${aiAnalysis ? now : null},
        ${null}, -- Will be updated after processing
        ${aiAnalysis ? JSON.stringify(aiAnalysis) : null}
      )
      RETURNING *
    `;

    const complaint = result[0];
    console.log(
      "✅ Complaint saved with AI analysis:",
      complaint.complaint_number
    );

    // Step 4: Prepare response
    const response: any = {
      success: true,
      data: {
        id: complaint.id,
        complaint_number: complaint.complaint_number,
        status: complaint.status,
        priority: complaint.priority,
        category: complaint.category,
      },
      message: "Complaint submitted successfully",
    };

    // Add AI insights if available
    if (aiAnalysis) {
      response.ai_insights = {
        validity: aiAnalysis.validity.is_valid ? "Valid" : "Needs Review",
        priority: aiAnalysis.priority.priority_level,
        sentiment: aiAnalysis.sentiment.sentiment,
        category: aiAnalysis.category.category,
        summary: aiAnalysis.summary,
        language: aiAnalysis.language,
      };

      // Warning if complaint is flagged as invalid
      if (!aiAnalysis.validity.is_valid) {
        response.warning =
          "This complaint has been flagged for review by our AI system.";
      }
    }

    return c.json(response, 201);
  } catch (error) {
    console.error("❌ Error submitting complaint:", error);
    return c.json(
      {
        success: false,
        message: "Failed to submit complaint",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
};

/**
 * Get all complaints with AI insights for admin
 */
export const getComplaintsWithAI = async (c: Context) => {
  try {
    const filter = c.req.query("filter") || "all"; // all, valid, invalid, urgent, high
    const sortBy = c.req.query("sortBy") || "date"; // date, priority, validity
    const limit = parseInt(c.req.query("limit") || "50");
    const offset = parseInt(c.req.query("offset") || "0");

    let query = sql`
      SELECT 
        c.*,
        CASE 
          WHEN c.ai_priority_level = 'Urgent' THEN 1
          WHEN c.ai_priority_level = 'High' THEN 2
          WHEN c.priority = 'High' OR c.priority = 'high' THEN 2
          WHEN c.ai_priority_level = 'Medium' THEN 3
          ELSE 4
        END as priority_rank
      FROM complaints c
      WHERE 1=1
    `;

    // Apply filters
    if (filter === "valid") {
      query = sql`${query} AND c.is_valid = true`;
    } else if (filter === "invalid") {
      query = sql`${query} AND c.is_valid = false`;
    } else if (filter === "urgent") {
      query = sql`${query} AND c.ai_priority_level = 'Urgent'`;
    } else if (filter === "high") {
      query = sql`${query} AND (c.ai_priority_level IN ('Urgent', 'High') OR c.priority = 'High')`;
    }

    // Apply sorting
    if (sortBy === "priority") {
      query = sql`${query} ORDER BY priority_rank ASC, c.submitted_at DESC`;
    } else if (sortBy === "validity") {
      query = sql`${query} ORDER BY c.validity_score DESC NULLS LAST, c.submitted_at DESC`;
    } else {
      query = sql`${query} ORDER BY c.submitted_at DESC`;
    }

    // Apply pagination
    query = sql`${query} LIMIT ${limit} OFFSET ${offset}`;

    const complaints = await query;

    // Get total count
    const countResult = await sql`SELECT COUNT(*) as total FROM complaints`;
    const total = parseInt(countResult[0].total);

    return c.json({
      success: true,
      data: complaints,
      pagination: {
        total,
        limit,
        offset,
        hasMore: offset + limit < total,
      },
    });
  } catch (error) {
    console.error("❌ Error fetching complaints:", error);
    return c.json(
      {
        success: false,
        message: "Failed to fetch complaints",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
};

/**
 * Reanalyze existing complaint
 */
export const reanalyzeComplaint = async (c: Context) => {
  try {
    const complaintId = c.req.param("id");

    // Get existing complaint
    const complaints = await sql`
      SELECT * FROM complaints WHERE id = ${complaintId}
    `;

    if (complaints.length === 0) {
      return c.json(
        {
          success: false,
          message: "Complaint not found",
        },
        404
      );
    }

    const complaint = complaints[0];

    // Run AI analysis
    const aiAnalysis = await nlpService.analyzeComplaint({
      complaint_text: complaint.description,
      customer_name: complaint.customer_name,
      shop_name: complaint.shop_name,
      product_name: complaint.product_name,
    });

    if (!aiAnalysis) {
      return c.json(
        {
          success: false,
          message: "AI analysis service unavailable",
        },
        503
      );
    }

    // Update complaint with new analysis
    await sql`
      UPDATE complaints
      SET
        validity_score = ${aiAnalysis.validity.validity_score},
        is_valid = ${aiAnalysis.validity.is_valid},
        validity_reasons = ${aiAnalysis.validity.reasons},
        ai_priority_score = ${aiAnalysis.priority.priority_score},
        ai_priority_level = ${aiAnalysis.priority.priority_level},
        priority_reasons = ${aiAnalysis.priority.reasons},
        sentiment_score = ${aiAnalysis.sentiment.sentiment_score},
        sentiment = ${aiAnalysis.sentiment.sentiment},
        emotion_intensity = ${aiAnalysis.sentiment.emotion_intensity},
        ai_category = ${aiAnalysis.category.category},
        ai_category_confidence = ${aiAnalysis.category.confidence},
        matched_keywords = ${aiAnalysis.category.matched_keywords},
        ai_summary = ${aiAnalysis.summary},
        detected_language = ${aiAnalysis.language},
        ai_analysis_date = NOW(),
        ai_full_analysis = ${JSON.stringify(aiAnalysis)},
        updated_at = NOW()
      WHERE id = ${complaintId}
    `;

    return c.json({
      success: true,
      message: "Complaint reanalyzed successfully",
      analysis: aiAnalysis,
    });
  } catch (error) {
    console.error("❌ Error reanalyzing complaint:", error);
    return c.json(
      {
        success: false,
        message: "Failed to reanalyze complaint",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
};

/**
 * Get AI analytics dashboard data
 */
export const getAIAnalytics = async (c: Context) => {
  try {
    // Get various statistics
    const stats = await sql`
      SELECT 
        COUNT(*) as total_complaints,
        COUNT(*) FILTER (WHERE is_valid = true) as valid_complaints,
        COUNT(*) FILTER (WHERE is_valid = false) as invalid_complaints,
        COUNT(*) FILTER (WHERE ai_priority_level = 'Urgent') as urgent_complaints,
        COUNT(*) FILTER (WHERE ai_priority_level = 'High') as high_priority_complaints,
        COUNT(*) FILTER (WHERE sentiment = 'Negative') as negative_sentiment,
        AVG(validity_score) as avg_validity_score,
        AVG(ai_priority_score) as avg_priority_score,
        COUNT(DISTINCT ai_category) as unique_categories
      FROM complaints
      WHERE ai_analysis_date IS NOT NULL
    `;

    // Get category distribution
    const categoryDist = await sql`
      SELECT 
        ai_category as category,
        COUNT(*) as count,
        AVG(ai_priority_score) as avg_priority
      FROM complaints
      WHERE ai_category IS NOT NULL
      GROUP BY ai_category
      ORDER BY count DESC
      LIMIT 10
    `;

    // Get language distribution
    const languageDist = await sql`
      SELECT 
        detected_language as language,
        COUNT(*) as count
      FROM complaints
      WHERE detected_language IS NOT NULL
      GROUP BY detected_language
    `;

    return c.json({
      success: true,
      analytics: {
        overview: stats[0],
        category_distribution: categoryDist,
        language_distribution: languageDist,
      },
    });
  } catch (error) {
    console.error("❌ Error fetching AI analytics:", error);
    return c.json(
      {
        success: false,
        message: "Failed to fetch analytics",
        error: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
};
