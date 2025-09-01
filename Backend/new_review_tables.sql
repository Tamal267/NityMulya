-- ====================================
-- DELETE OLD CUSTOMER_REVIEWS TABLE
-- ====================================
-- Run this first to delete the existing customer_reviews table and its indexes
DROP INDEX IF EXISTS idx_customer_reviews_customer;

DROP INDEX IF EXISTS idx_customer_reviews_shop;

DROP INDEX IF EXISTS idx_customer_reviews_subcat;

DROP INDEX IF EXISTS idx_customer_reviews_rating;

DROP TABLE IF EXISTS customer_reviews;

-- ====================================
-- CREATE NEW REVIEW TABLES
-- ====================================

-- 1. CUSTOMER PRODUCT REVIEWS TABLE
-- This table stores reviews for specific products (subcategories)
CREATE TABLE customer_product_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

-- Customer information
customer_id UUID REFERENCES customers (id) ON DELETE CASCADE,
customer_name VARCHAR(100) NOT NULL,
customer_email VARCHAR(150) NOT NULL,

-- Product information
subcat_id UUID REFERENCES subcategories (id) ON DELETE CASCADE,
product_name VARCHAR(255) NOT NULL,

-- Shop information
shop_owner_id UUID REFERENCES shop_owners (id) ON DELETE CASCADE,
shop_name VARCHAR(255) NOT NULL,

-- Review details
rating INTEGER NOT NULL CHECK (
    rating >= 1
    AND rating <= 5
),
comment TEXT,

-- Additional metadata
order_id UUID,
is_verified_purchase BOOLEAN DEFAULT FALSE,
helpful_count INTEGER DEFAULT 0,

-- Ensure one review per customer per product
UNIQUE(customer_id, subcat_id, shop_owner_id) );

-- 2. CUSTOMER SHOP REVIEWS TABLE
-- This table stores reviews for shops/wholesalers
CREATE TABLE customer_shop_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

-- Customer information
customer_id UUID REFERENCES customers (id) ON DELETE CASCADE,
customer_name VARCHAR(100) NOT NULL,
customer_email VARCHAR(150) NOT NULL,

-- Shop information
shop_owner_id UUID REFERENCES shop_owners (id) ON DELETE CASCADE,
shop_name VARCHAR(255) NOT NULL,

-- Review ratings (multiple aspects)
overall_rating INTEGER NOT NULL CHECK (
    overall_rating >= 1
    AND overall_rating <= 5
),
service_rating INTEGER CHECK (
    service_rating >= 1
    AND service_rating <= 5
),
delivery_rating INTEGER CHECK (
    delivery_rating >= 1
    AND delivery_rating <= 5
),

-- Review details
comment TEXT,

-- Additional metadata
order_id UUID,
is_verified_purchase BOOLEAN DEFAULT FALSE,
helpful_count INTEGER DEFAULT 0,

-- Ensure one review per customer per shop
UNIQUE(customer_id, shop_owner_id) );

-- ====================================
-- CREATE INDEXES FOR PERFORMANCE
-- ====================================

-- Indexes for customer_product_reviews
CREATE INDEX idx_customer_product_reviews_customer ON customer_product_reviews (customer_id);

CREATE INDEX idx_customer_product_reviews_product ON customer_product_reviews (subcat_id);

CREATE INDEX idx_customer_product_reviews_shop ON customer_product_reviews (shop_owner_id);

CREATE INDEX idx_customer_product_reviews_rating ON customer_product_reviews (rating);

CREATE INDEX idx_customer_product_reviews_created ON customer_product_reviews (created_at DESC);

-- Indexes for customer_shop_reviews
CREATE INDEX idx_customer_shop_reviews_customer ON customer_shop_reviews (customer_id);

CREATE INDEX idx_customer_shop_reviews_shop ON customer_shop_reviews (shop_owner_id);

CREATE INDEX idx_customer_shop_reviews_overall ON customer_shop_reviews (overall_rating);

CREATE INDEX idx_customer_shop_reviews_created ON customer_shop_reviews (created_at DESC);

-- ====================================
-- CREATE TRIGGERS FOR UPDATED_AT
-- ====================================

-- Trigger function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to both tables
CREATE TRIGGER update_customer_product_reviews_updated_at 
    BEFORE UPDATE ON customer_product_reviews 
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_customer_shop_reviews_updated_at 
    BEFORE UPDATE ON customer_shop_reviews 
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- ====================================
-- SAMPLE DATA (OPTIONAL - FOR TESTING)
-- ====================================

-- Sample product reviews
INSERT INTO
    customer_product_reviews (
        customer_id,
        customer_name,
        customer_email,
        subcat_id,
        product_name,
        shop_owner_id,
        shop_name,
        rating,
        comment,
        is_verified_purchase
    )
VALUES (
        (
            SELECT id
            FROM customers
            LIMIT 1
        ),
        'John Doe',
        'john@example.com',
        (
            SELECT id
            FROM subcategories
            LIMIT 1
        ),
        'Premium Rice 25kg',
        (
            SELECT id
            FROM shop_owners
            LIMIT 1
        ),
        'Fresh Mart',
        5,
        'Excellent quality rice, very fresh and well packaged!',
        true
    );

-- Sample shop reviews
INSERT INTO
    customer_shop_reviews (
        customer_id,
        customer_name,
        customer_email,
        shop_owner_id,
        shop_name,
        overall_rating,
        service_rating,
        delivery_rating,
        comment,
        is_verified_purchase
    )
VALUES (
        (
            SELECT id
            FROM customers
            LIMIT 1
        ),
        'Jane Smith',
        'jane@example.com',
        (
            SELECT id
            FROM shop_owners
            LIMIT 1
        ),
        'Fresh Mart',
        4,
        5,
        4,
        'Great service and friendly staff. Delivery was good but could be faster.',
        true
    );