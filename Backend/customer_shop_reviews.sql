-- ====================================
-- CUSTOMER SHOP REVIEWS TABLE
-- ====================================
-- This table stores reviews for shops/wholesalers

CREATE TABLE customer_shop_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Customer information
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(150) NOT NULL,
    
    -- Shop information
    shop_owner_id UUID REFERENCES shop_owners(id) ON DELETE CASCADE,
    shop_name VARCHAR(255) NOT NULL,
    
    -- Review ratings (multiple aspects)
    overall_rating INTEGER NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
    service_rating INTEGER CHECK (service_rating >= 1 AND service_rating <= 5),
    delivery_rating INTEGER CHECK (delivery_rating >= 1 AND delivery_rating <= 5),
    
    -- Review details
    comment TEXT,
    
    -- Additional metadata
    order_id UUID,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_count INTEGER DEFAULT 0,
    
    -- Ensure one review per customer per shop
    UNIQUE(customer_id, shop_owner_id)
);

-- Create indexes for performance
CREATE INDEX idx_customer_shop_reviews_customer ON customer_shop_reviews (customer_id);
CREATE INDEX idx_customer_shop_reviews_shop ON customer_shop_reviews (shop_owner_id);
CREATE INDEX idx_customer_shop_reviews_overall ON customer_shop_reviews (overall_rating);
CREATE INDEX idx_customer_shop_reviews_created ON customer_shop_reviews (created_at DESC);

-- Trigger function for updated_at (create only if it doesn't exist)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to update updated_at timestamp
CREATE TRIGGER update_customer_shop_reviews_updated_at 
    BEFORE UPDATE ON customer_shop_reviews 
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
