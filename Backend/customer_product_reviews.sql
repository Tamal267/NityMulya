-- ====================================
-- CUSTOMER PRODUCT REVIEWS TABLE
-- ====================================
-- This table stores reviews for specific products (subcategories)

CREATE TABLE customer_product_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Customer information
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(150) NOT NULL,
    
    -- Product information
    subcat_id UUID REFERENCES subcategories(id) ON DELETE CASCADE,
    product_name VARCHAR(255) NOT NULL,
    
    -- Shop information
    shop_owner_id UUID REFERENCES shop_owners(id) ON DELETE CASCADE,
    shop_name VARCHAR(255) NOT NULL,
    
    -- Review details
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    
    -- Additional metadata
    order_id UUID,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_count INTEGER DEFAULT 0,
    
    -- Ensure one review per customer per product
    UNIQUE(customer_id, subcat_id, shop_owner_id)
);

-- Create indexes for performance
CREATE INDEX idx_customer_product_reviews_customer ON customer_product_reviews (customer_id);
CREATE INDEX idx_customer_product_reviews_product ON customer_product_reviews (subcat_id);
CREATE INDEX idx_customer_product_reviews_shop ON customer_product_reviews (shop_owner_id);
CREATE INDEX idx_customer_product_reviews_rating ON customer_product_reviews (rating);
CREATE INDEX idx_customer_product_reviews_created ON customer_product_reviews (created_at DESC);

-- Trigger function for updated_at (create only if it doesn't exist)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to update updated_at timestamp
CREATE TRIGGER update_customer_product_reviews_updated_at 
    BEFORE UPDATE ON customer_product_reviews 
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
