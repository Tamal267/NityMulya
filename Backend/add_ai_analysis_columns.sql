-- Add AI Analysis columns to complaints table
-- For AI-Enhanced Complaint Management System

-- Add validity detection fields
ALTER TABLE complaints
ADD COLUMN IF NOT EXISTS validity_score DECIMAL(3,2) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS is_valid BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS validity_reasons TEXT[] DEFAULT '{}';

-- Add priority classification fields
ALTER TABLE complaints
ADD COLUMN IF NOT EXISTS ai_priority_score DECIMAL(3,2) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS ai_priority_level TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS priority_reasons TEXT[] DEFAULT '{}';

-- Add sentiment analysis fields
ALTER TABLE complaints
ADD COLUMN IF NOT EXISTS sentiment_score DECIMAL(3, 2) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS sentiment TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS emotion_intensity TEXT DEFAULT NULL;

-- Add category detection fields
ALTER TABLE complaints
ADD COLUMN IF NOT EXISTS ai_category TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS ai_category_confidence TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS matched_keywords INTEGER DEFAULT 0;

-- Add summary and metadata
ALTER TABLE complaints
ADD COLUMN IF NOT EXISTS ai_summary TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS detected_language TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS ai_analysis_date TIMESTAMP DEFAULT NULL,
ADD COLUMN IF NOT EXISTS ai_processing_time_ms DECIMAL(10, 2) DEFAULT NULL;

-- Add full analysis JSON (for debugging and research)
ALTER TABLE complaints
ADD COLUMN IF NOT EXISTS ai_full_analysis JSONB DEFAULT NULL;

-- Create index for filtering by AI predictions
CREATE INDEX IF NOT EXISTS idx_complaints_ai_priority ON complaints (ai_priority_level);

CREATE INDEX IF NOT EXISTS idx_complaints_validity ON complaints (is_valid);

CREATE INDEX IF NOT EXISTS idx_complaints_sentiment ON complaints (sentiment);

CREATE INDEX IF NOT EXISTS idx_complaints_ai_category ON complaints (ai_category);

-- Create view for admin dashboard with AI insights
CREATE OR REPLACE VIEW complaints_with_ai AS
SELECT
    c.*,
    -- Combine manual priority with AI priority for better decision making
    CASE
        WHEN c.ai_priority_level = 'Urgent' THEN 1
        WHEN c.ai_priority_level = 'High' THEN 2
        WHEN c.priority = 'high'
        OR c.priority = 'High' THEN 2
        WHEN c.ai_priority_level = 'Medium' THEN 3
        WHEN c.priority = 'Medium' THEN 3
        ELSE 4
    END as combined_priority_rank,
    -- AI confidence indicator
    CASE
        WHEN c.validity_score IS NOT NULL
        AND c.ai_priority_score IS NOT NULL
        AND c.sentiment_score IS NOT NULL THEN 'complete'
        WHEN c.validity_score IS NOT NULL THEN 'partial'
        ELSE 'none'
    END as ai_analysis_status
FROM complaints c;

-- Add comment for documentation
COMMENT ON COLUMN complaints.validity_score IS 'AI-generated validity score (0-1), higher means more likely to be valid';

COMMENT ON COLUMN complaints.ai_priority_score IS 'AI-generated priority score (0-1), higher means more urgent';

COMMENT ON COLUMN complaints.sentiment_score IS 'AI-generated sentiment score (-1 to 1), negative for complaints';

COMMENT ON COLUMN complaints.ai_full_analysis IS 'Complete AI analysis result in JSON format for research purposes';