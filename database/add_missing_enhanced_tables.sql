-- Enhanced Features: Missing Tables for PostgreSQL
-- Add these tables to complement existing customer_favorites, customer_product_reviews, customer_shop_reviews

-- 1. Customer Complaints Management Table
CREATE TABLE IF NOT EXISTS complaints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    complaint_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20),
    shop_owner_id UUID REFERENCES shop_owners(id) ON DELETE CASCADE,
    shop_name VARCHAR(255) NOT NULL,
    subcat_id UUID REFERENCES subcategories(id) ON DELETE SET NULL,
    product_name VARCHAR(255),
    complaint_type VARCHAR(100) NOT NULL,
    complaint_title VARCHAR(255) NOT NULL,
    complaint_description TEXT NOT NULL,
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'resolved', 'closed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolution_comment TEXT
);

-- 2. Product Price History Table
CREATE TABLE IF NOT EXISTS product_price_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subcat_id UUID REFERENCES subcategories(id) ON DELETE CASCADE,
    product_name VARCHAR(255) NOT NULL,
    shop_owner_id UUID REFERENCES shop_owners(id) ON DELETE CASCADE,
    shop_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    unit VARCHAR(50),
    price_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    recorded_by VARCHAR(100), -- system, user, api, etc.
    source VARCHAR(50) DEFAULT 'manual' -- manual, scraper, api, etc.
);

-- Indexes for Performance
CREATE INDEX IF NOT EXISTS idx_complaints_customer_id ON complaints(customer_id);
CREATE INDEX IF NOT EXISTS idx_complaints_shop_owner_id ON complaints(shop_owner_id);
CREATE INDEX IF NOT EXISTS idx_complaints_status ON complaints(status);
CREATE INDEX IF NOT EXISTS idx_complaints_created_at ON complaints(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_complaints_priority ON complaints(priority);

CREATE INDEX IF NOT EXISTS idx_price_history_subcat_id ON product_price_history(subcat_id);
CREATE INDEX IF NOT EXISTS idx_price_history_shop_owner_id ON product_price_history(shop_owner_id);
CREATE INDEX IF NOT EXISTS idx_price_history_price_date ON product_price_history(price_date DESC);
CREATE INDEX IF NOT EXISTS idx_price_history_product_shop ON product_price_history(subcat_id, shop_owner_id);

-- Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_complaints_updated_at BEFORE UPDATE ON complaints
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Sample Data for Testing
INSERT INTO complaints (
    complaint_number, customer_id, customer_name, customer_email, customer_phone,
    shop_owner_id, shop_name, complaint_type, complaint_title, complaint_description, priority
) VALUES 
(
    'COMP-' || extract(epoch from now()) || '-SAMPLE',
    (SELECT id FROM customers LIMIT 1),
    'Sample Customer',
    'sample@example.com',
    '01712345678',
    (SELECT id FROM shop_owners LIMIT 1),
    'Sample Shop',
    'পণ্যের গুণগত মান',
    'Sample Complaint Title',
    'This is a sample complaint for testing purposes.',
    'medium'
);

INSERT INTO product_price_history (
    subcat_id, product_name, shop_owner_id, shop_name, price, unit, recorded_by
) VALUES 
(
    (SELECT id FROM subcategories LIMIT 1),
    'Sample Product',
    (SELECT id FROM shop_owners LIMIT 1),
    'Sample Shop',
    150.00,
    'kg',
    'system'
);

-- Comments
COMMENT ON TABLE complaints IS 'Customer complaints management system';
COMMENT ON TABLE product_price_history IS 'Historical price tracking for products across shops';

COMMENT ON COLUMN complaints.complaint_number IS 'Unique complaint tracking number';
COMMENT ON COLUMN complaints.priority IS 'Complaint priority: low, medium, high, urgent';
COMMENT ON COLUMN complaints.status IS 'Complaint status: pending, in_progress, resolved, closed';

COMMENT ON COLUMN product_price_history.recorded_by IS 'Who/what recorded this price entry';
COMMENT ON COLUMN product_price_history.source IS 'Source of price data: manual, scraper, api, etc';
