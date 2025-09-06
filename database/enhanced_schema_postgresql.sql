-- Enhanced Features PostgreSQL Schema
-- Run this in your Supabase SQL editor

-- Create favourites table
CREATE TABLE IF NOT EXISTS favourites (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    shop_id INTEGER NOT NULL,
    product_id TEXT NOT NULL,
    product_name TEXT NOT NULL,
    shop_name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (
        customer_id,
        shop_id,
        product_id
    )
);

-- Create product_price_history table
CREATE TABLE IF NOT EXISTS product_price_history (
    id SERIAL PRIMARY KEY,
    product_id TEXT NOT NULL,
    product_name TEXT NOT NULL,
    shop_id INTEGER NOT NULL,
    shop_name TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    unit TEXT,
    price_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    recorded_by TEXT
);

-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    customer_name TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    shop_id INTEGER NOT NULL,
    shop_name TEXT NOT NULL,
    product_id TEXT,
    product_name TEXT,
    overall_rating INTEGER NOT NULL CHECK (
        overall_rating >= 1
        AND overall_rating <= 5
    ),
    product_quality_rating INTEGER CHECK (
        product_quality_rating >= 1
        AND product_quality_rating <= 5
    ),
    service_rating INTEGER CHECK (
        service_rating >= 1
        AND service_rating <= 5
    ),
    delivery_rating INTEGER CHECK (
        delivery_rating >= 1
        AND delivery_rating <= 5
    ),
    review_title TEXT,
    review_comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create complaints table
CREATE TABLE IF NOT EXISTS complaints (
    id SERIAL PRIMARY KEY,
    complaint_number TEXT UNIQUE NOT NULL,
    customer_id INTEGER NOT NULL,
    customer_name TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    customer_phone TEXT,
    shop_id INTEGER NOT NULL,
    shop_name TEXT NOT NULL,
    product_id TEXT,
    product_name TEXT,
    complaint_type TEXT NOT NULL,
    complaint_title TEXT NOT NULL,
    complaint_description TEXT NOT NULL,
    priority TEXT NOT NULL DEFAULT 'medium',
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    resolution_comment TEXT
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_favourites_customer ON favourites (customer_id);

CREATE INDEX IF NOT EXISTS idx_favourites_shop ON favourites (shop_id);

CREATE INDEX IF NOT EXISTS idx_price_history_product_shop ON product_price_history (product_id, shop_id);

CREATE INDEX IF NOT EXISTS idx_price_history_date ON product_price_history (price_date);

CREATE INDEX IF NOT EXISTS idx_reviews_shop ON reviews (shop_id);

CREATE INDEX IF NOT EXISTS idx_reviews_customer ON reviews (customer_id);

CREATE INDEX IF NOT EXISTS idx_complaints_customer ON complaints (customer_id);

CREATE INDEX IF NOT EXISTS idx_complaints_status ON complaints (status);

-- Insert sample data for testing
INSERT INTO
    favourites (
        customer_id,
        shop_id,
        product_id,
        product_name,
        shop_name
    )
VALUES (
        12345,
        1,
        'rice_basmati',
        'Basmati Rice',
        'Sunrise Store'
    ),
    (
        12345,
        2,
        'oil_soybean',
        'Soybean Oil',
        'Fresh Market'
    ),
    (
        67890,
        1,
        'sugar_white',
        'White Sugar',
        'Sunrise Store'
    ) ON CONFLICT (
        customer_id,
        shop_id,
        product_id
    ) DO NOTHING;

INSERT INTO
    product_price_history (
        product_id,
        product_name,
        shop_id,
        shop_name,
        price,
        unit,
        recorded_by
    )
VALUES (
        'rice_basmati',
        'Basmati Rice',
        1,
        'Sunrise Store',
        85.50,
        'kg',
        'system'
    ),
    (
        'rice_basmati',
        'Basmati Rice',
        1,
        'Sunrise Store',
        87.00,
        'kg',
        'system'
    ),
    (
        'oil_soybean',
        'Soybean Oil',
        2,
        'Fresh Market',
        165.00,
        'liter',
        'customer_report'
    ),
    (
        'sugar_white',
        'White Sugar',
        1,
        'Sunrise Store',
        65.00,
        'kg',
        'system'
    );

INSERT INTO
    reviews (
        customer_id,
        customer_name,
        customer_email,
        shop_id,
        shop_name,
        overall_rating,
        review_comment
    )
VALUES (
        12345,
        'Test Customer',
        'test@example.com',
        1,
        'Sunrise Store',
        4,
        'Good quality products and reasonable prices'
    ),
    (
        67890,
        'Another Customer',
        'customer@test.com',
        2,
        'Fresh Market',
        5,
        'Excellent service and fresh products'
    );

INSERT INTO
    complaints (
        complaint_number,
        customer_id,
        customer_name,
        customer_email,
        shop_id,
        shop_name,
        complaint_type,
        complaint_title,
        complaint_description,
        priority
    )
VALUES (
        'COMP-TEST-001',
        12345,
        'Test Customer',
        'test@example.com',
        1,
        'Sunrise Store',
        'পণ্যের গুণগত মান',
        'Rice quality issue',
        'The basmati rice quality was not up to the mark',
        'medium'
    ),
    (
        'COMP-TEST-002',
        67890,
        'Another Customer',
        'customer@test.com',
        2,
        'Fresh Market',
        'দাম সংক্রান্ত সমস্যা',
        'Price discrepancy',
        'The displayed price was different from what was charged',
        'high'
    );

-- Enable Row Level Security (optional but recommended)
-- ALTER TABLE favourites ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE product_price_history ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE complaints ENABLE ROW LEVEL SECURITY;

-- Verification queries
SELECT 'favourites' as table_name, COUNT(*) as row_count
FROM favourites
UNION ALL
SELECT 'product_price_history', COUNT(*)
FROM product_price_history
UNION ALL
SELECT 'reviews', COUNT(*)
FROM reviews
UNION ALL
SELECT 'complaints', COUNT(*)
FROM complaints;