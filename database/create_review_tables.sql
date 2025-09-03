-- Create customer_shop_reviews table for Enhanced Features
-- Run this in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS customer_shop_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id TEXT NOT NULL,
    customer_name TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    shop_id TEXT NOT NULL,
    shop_name TEXT,
    product_id TEXT,
    product_name TEXT,
    overall_rating INTEGER NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
    product_quality_rating INTEGER CHECK (product_quality_rating >= 1 AND product_quality_rating <= 5),
    service_rating INTEGER CHECK (service_rating >= 1 AND service_rating <= 5),
    delivery_rating INTEGER CHECK (delivery_rating >= 1 AND delivery_rating <= 5),
    review_title TEXT,
    review_comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create complaints table for Enhanced Features
CREATE TABLE IF NOT EXISTS complaints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id TEXT NOT NULL,
    customer_name TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    customer_phone TEXT,
    shop_owner_id TEXT NOT NULL,
    shop_name TEXT,
    product_id TEXT,
    product_name TEXT,
    complaint_type TEXT NOT NULL,
    subject TEXT NOT NULL,
    description TEXT NOT NULL,
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'resolved', 'rejected')),
    complaint_number TEXT UNIQUE,
    admin_notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_customer_shop_reviews_shop_id ON customer_shop_reviews(shop_id);
CREATE INDEX IF NOT EXISTS idx_customer_shop_reviews_customer_id ON customer_shop_reviews(customer_id);
CREATE INDEX IF NOT EXISTS idx_customer_shop_reviews_created_at ON customer_shop_reviews(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_complaints_customer_id ON complaints(customer_id);
CREATE INDEX IF NOT EXISTS idx_complaints_shop_owner_id ON complaints(shop_owner_id);
CREATE INDEX IF NOT EXISTS idx_complaints_status ON complaints(status);
CREATE INDEX IF NOT EXISTS idx_complaints_created_at ON complaints(created_at DESC);

-- Insert sample data for testing
INSERT INTO customer_shop_reviews (
    customer_id, customer_name, customer_email,
    shop_id, shop_name,
    overall_rating, review_comment, review_title
) VALUES 
(
    '1', 'John Doe', 'john@example.com',
    '1', 'Test Shop',
    5, 'Excellent service and quality products!', 'Great Experience'
),
(
    '2', 'Jane Smith', 'jane@example.com', 
    '1', 'Test Shop',
    4, 'Good shop with reasonable prices.', 'Satisfied Customer'
);

-- Success message
SELECT 'Enhanced Features tables created successfully!' as message;
