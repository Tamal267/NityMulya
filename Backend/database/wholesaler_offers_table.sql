-- Table for storing wholesaler offers
CREATE TABLE IF NOT EXISTS wholesaler_offers (
    id SERIAL PRIMARY KEY,
    wholesaler_id UUID NOT NULL REFERENCES wholesalers(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    discount_percentage DECIMAL(5,2), -- e.g., 15.50 for 15.5%
    minimum_quantity INTEGER DEFAULT 1,
    valid_until TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_wholesaler_offers_wholesaler_id ON wholesaler_offers(wholesaler_id);
CREATE INDEX IF NOT EXISTS idx_wholesaler_offers_is_active ON wholesaler_offers(is_active);
CREATE INDEX IF NOT EXISTS idx_wholesaler_offers_valid_until ON wholesaler_offers(valid_until);

-- Add some sample data for testing (optional)
-- INSERT INTO wholesaler_offers (wholesaler_id, title, description, discount_percentage, minimum_quantity, valid_until) 
-- VALUES 
-- ('your-wholesaler-uuid-here', 'Bulk Rice Discount', 'Get 10% off on orders above 100 kg', 10.00, 100, '2025-12-31 23:59:59'),
-- ('your-wholesaler-uuid-here', 'Festival Special', 'Special offer for Eid - 15% off on all lentils', 15.00, 50, '2025-09-15 23:59:59');
