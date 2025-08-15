-- Create shop_inventory table if it doesn't exist
CREATE TABLE IF NOT EXISTS shop_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    shop_owner_id UUID REFERENCES shop_owners(id) ON DELETE CASCADE,
    subcat_id UUID REFERENCES subcategories(id) ON DELETE CASCADE,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    unit_price DECIMAL(10, 2) NOT NULL,
    low_stock_threshold INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(shop_owner_id, subcat_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_shop_inventory_shop_owner ON shop_inventory (shop_owner_id);
CREATE INDEX IF NOT EXISTS idx_shop_inventory_subcat ON shop_inventory (subcat_id);
CREATE INDEX IF NOT EXISTS idx_shop_inventory_active ON shop_inventory (is_active);
CREATE INDEX IF NOT EXISTS idx_shop_inventory_stock ON shop_inventory (stock_quantity);
