import sql from "./src/db";

async function addAIAnalysisColumns() {
  try {
    console.log("🤖 Adding AI Analysis columns to complaints table...");

    // Add validity detection fields
    await sql`
      ALTER TABLE complaints
      ADD COLUMN IF NOT EXISTS validity_score DECIMAL(3,2) DEFAULT NULL,
      ADD COLUMN IF NOT EXISTS is_valid BOOLEAN DEFAULT true,
      ADD COLUMN IF NOT EXISTS validity_reasons TEXT[] DEFAULT '{}'
    `;
    console.log("✅ Validity detection fields added");

    // Add priority classification fields
    await sql`
      ALTER TABLE complaints
      ADD COLUMN IF NOT EXISTS ai_priority_score DECIMAL(3,2) DEFAULT NULL,
      ADD COLUMN IF NOT EXISTS ai_priority_level TEXT DEFAULT NULL,
      ADD COLUMN IF NOT EXISTS priority_reasons TEXT[] DEFAULT '{}'
    `;
    console.log("✅ Priority classification fields added");

    // Add sentiment analysis fields
    await sql`
      ALTER TABLE complaints
      ADD COLUMN IF NOT EXISTS sentiment_score DECIMAL(3,2) DEFAULT NULL,
      ADD COLUMN IF NOT EXISTS sentiment TEXT DEFAULT NULL,
      ADD COLUMN IF NOT EXISTS emotion_intensity TEXT DEFAULT NULL
    `;
    console.log("✅ Sentiment analysis fields added");

    // Add category detection fields
    await sql`
      ALTER TABLE complaints
      ADD COLUMN IF NOT EXISTS ai_category TEXT DEFAULT NULL,
      ADD COLUMN IF NOT EXISTS ai_category_confidence TEXT DEFAULT NULL,
      ADD COLUMN IF NOT EXISTS matched_keywords INTEGER DEFAULT 0
    `;
    console.log("✅ Category detection fields added");

    // Add summary and metadata
    await sql`
      ALTER TABLE complaints
      ADD COLUMN IF NOT EXISTS ai_summary TEXT DEFAULT NULL,
      ADD COLUMN IF NOT EXISTS detected_language TEXT DEFAULT NULL,
      ADD COLUMN IF NOT EXISTS ai_analysis_date TIMESTAMP DEFAULT NULL,
      ADD COLUMN IF NOT EXISTS ai_processing_time_ms DECIMAL(10,2) DEFAULT NULL
    `;
    console.log("✅ Summary and metadata fields added");

    // Add full analysis JSON
    await sql`
      ALTER TABLE complaints
      ADD COLUMN IF NOT EXISTS ai_full_analysis JSONB DEFAULT NULL
    `;
    console.log("✅ Full analysis JSON field added");

    // Create indexes
    await sql`
      CREATE INDEX IF NOT EXISTS idx_complaints_ai_priority ON complaints(ai_priority_level)
    `;
    await sql`
      CREATE INDEX IF NOT EXISTS idx_complaints_validity ON complaints(is_valid)
    `;
    await sql`
      CREATE INDEX IF NOT EXISTS idx_complaints_sentiment ON complaints(sentiment)
    `;
    await sql`
      CREATE INDEX IF NOT EXISTS idx_complaints_ai_category ON complaints(ai_category)
    `;
    console.log("✅ Indexes created");

    // Create view
    await sql`
      CREATE OR REPLACE VIEW complaints_with_ai AS
      SELECT 
          c.*,
          CASE 
              WHEN c.ai_priority_level = 'Urgent' THEN 1
              WHEN c.ai_priority_level = 'High' THEN 2
              WHEN c.priority = 'high' OR c.priority = 'High' THEN 2
              WHEN c.ai_priority_level = 'Medium' THEN 3
              WHEN c.priority = 'Medium' THEN 3
              ELSE 4
          END as combined_priority_rank,
          CASE 
              WHEN c.validity_score IS NOT NULL 
               AND c.ai_priority_score IS NOT NULL 
               AND c.sentiment_score IS NOT NULL 
              THEN 'complete'
              WHEN c.validity_score IS NOT NULL THEN 'partial'
              ELSE 'none'
          END as ai_analysis_status
      FROM complaints c
    `;
    console.log("✅ View created");

    console.log("🎉 All AI analysis columns added successfully!");
  } catch (error) {
    console.error("❌ Error adding AI columns:", error);
  } finally {
    process.exit(0);
  }
}

addAIAnalysisColumns();
