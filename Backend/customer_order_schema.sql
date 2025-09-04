-- Customer Order Management System Schema
-- This schema creates all necessary tables for customer order management

-- Drop existing tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS order_status_history CASCADE;
DROP TABLE IF EXISTS customer_orders CASCADE;

-- Enum for order status
DO $$ BEGIN
    CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Customer Orders Table
CREATE TABLE IF NOT EXISTS customer_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID NOT NULL,
    shop_owner_id UUID NOT NULL,
    subcat_id UUID NOT NULL,
    quantity_ordered INTEGER NOT NULL CHECK (quantity_ordered > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    delivery_address TEXT NOT NULL,
    delivery_phone VARCHAR(20) NOT NULL,
    status order_status DEFAULT 'pending',
    notes TEXT,
    cancellation_reason TEXT,
    estimated_delivery TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    CONSTRAINT fk_customer_orders_customer 
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    CONSTRAINT fk_customer_orders_shop_owner 
        FOREIGN KEY (shop_owner_id) REFERENCES shop_owners(id) ON DELETE CASCADE,
    CONSTRAINT fk_customer_orders_subcategory 
        FOREIGN KEY (subcat_id) REFERENCES subcategories(id) ON DELETE CASCADE
);

-- Order Status History Table (tracks status changes)
CREATE TABLE IF NOT EXISTS order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    old_status order_status,
    new_status order_status NOT NULL,
    changed_by VARCHAR(50), -- 'customer', 'shop_owner', 'system'
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_order_status_history_order 
        FOREIGN KEY (order_id) REFERENCES customer_orders(id) ON DELETE CASCADE
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_customer_orders_customer_id ON customer_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_customer_orders_shop_owner_id ON customer_orders(shop_owner_id);
CREATE INDEX IF NOT EXISTS idx_customer_orders_status ON customer_orders(status);
CREATE INDEX IF NOT EXISTS idx_customer_orders_created_at ON customer_orders(created_at);
CREATE INDEX IF NOT EXISTS idx_customer_orders_order_number ON customer_orders(order_number);
CREATE INDEX IF NOT EXISTS idx_order_status_history_order_id ON order_status_history(order_id);

-- Function to generate unique order number
CREATE OR REPLACE FUNCTION generate_order_number() 
RETURNS VARCHAR(50) AS $$
DECLARE
    new_order_number VARCHAR(50);
    counter INTEGER := 1;
BEGIN
    LOOP
        new_order_number := 'ORD-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD(counter::TEXT, 6, '0');
        
        -- Check if this order number already exists
        IF NOT EXISTS (SELECT 1 FROM customer_orders WHERE order_number = new_order_number) THEN
            RETURN new_order_number;
        END IF;
        
        counter := counter + 1;
        
        -- Prevent infinite loop (highly unlikely but safety measure)
        IF counter > 999999 THEN
            RAISE EXCEPTION 'Unable to generate unique order number';
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to update inventory when order is placed
CREATE OR REPLACE FUNCTION update_inventory_on_order() 
RETURNS TRIGGER AS $$
BEGIN
    -- Decrease inventory when order is placed
    UPDATE shop_inventory 
    SET quantity = quantity - NEW.quantity_ordered,
        updated_at = CURRENT_TIMESTAMP
    WHERE shop_owner_id = NEW.shop_owner_id 
      AND subcat_id = NEW.subcat_id;
    
    -- Check if update affected any rows
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Product not found in shop inventory or insufficient stock';
    END IF;
    
    -- Check if quantity went negative
    IF (SELECT quantity FROM shop_inventory 
        WHERE shop_owner_id = NEW.shop_owner_id AND subcat_id = NEW.subcat_id) < 0 THEN
        RAISE EXCEPTION 'Insufficient stock available';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to restore inventory when order is cancelled
CREATE OR REPLACE FUNCTION restore_inventory_on_cancel() 
RETURNS TRIGGER AS $$
BEGIN
    -- Only restore inventory if order is being cancelled
    IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
        UPDATE shop_inventory 
        SET quantity = quantity + NEW.quantity_ordered,
            updated_at = CURRENT_TIMESTAMP
        WHERE shop_owner_id = NEW.shop_owner_id 
          AND subcat_id = NEW.subcat_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to automatically set order number before insert
CREATE OR REPLACE FUNCTION set_order_number() 
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
        NEW.order_number := generate_order_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column() 
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to log status changes
CREATE OR REPLACE FUNCTION log_status_change() 
RETURNS TRIGGER AS $$
BEGIN
    -- Only log if status actually changed
    IF NEW.status IS DISTINCT FROM OLD.status THEN
        INSERT INTO order_status_history (order_id, old_status, new_status, changed_by, notes)
        VALUES (NEW.id, OLD.status, NEW.status, 'system', 'Status changed automatically');
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers
-- Trigger to set order number before insert
DROP TRIGGER IF EXISTS trigger_set_order_number ON customer_orders;
CREATE TRIGGER trigger_set_order_number
    BEFORE INSERT ON customer_orders
    FOR EACH ROW
    EXECUTE FUNCTION set_order_number();

-- Trigger to update inventory when order is placed
DROP TRIGGER IF EXISTS trigger_update_inventory_on_order ON customer_orders;
CREATE TRIGGER trigger_update_inventory_on_order
    AFTER INSERT ON customer_orders
    FOR EACH ROW
    EXECUTE FUNCTION update_inventory_on_order();

-- Trigger to restore inventory when order is cancelled
DROP TRIGGER IF EXISTS trigger_restore_inventory_on_cancel ON customer_orders;
CREATE TRIGGER trigger_restore_inventory_on_cancel
    AFTER UPDATE ON customer_orders
    FOR EACH ROW
    EXECUTE FUNCTION restore_inventory_on_cancel();

-- Trigger to update updated_at timestamp
DROP TRIGGER IF EXISTS trigger_update_updated_at ON customer_orders;
CREATE TRIGGER trigger_update_updated_at
    BEFORE UPDATE ON customer_orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger to log status changes
DROP TRIGGER IF EXISTS trigger_log_status_change ON customer_orders;
CREATE TRIGGER trigger_log_status_change
    AFTER UPDATE ON customer_orders
    FOR EACH ROW
    EXECUTE FUNCTION log_status_change();

-- Insert some sample data for testing (optional)
/*
INSERT INTO customer_orders (
    customer_id, 
    shop_owner_id, 
    subcat_id, 
    quantity_ordered, 
    unit_price, 
    total_amount,
    delivery_address,
    delivery_phone,
    notes,
    estimated_delivery
) VALUES (
    (SELECT id FROM customers LIMIT 1),
    (SELECT id FROM shop_owners LIMIT 1),
    (SELECT id FROM subcategories LIMIT 1),
    5,
    78.00,
    390.00,
    'House #12, Road #5, Dhanmondi, Dhaka',
    '01900000000',
    'Please deliver fresh products',
    CURRENT_TIMESTAMP + INTERVAL '3 days'
);
*/

-- Grant permissions (adjust as needed)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON customer_orders TO your_app_user;
-- GRANT SELECT, INSERT ON order_status_history TO your_app_user;
-- GRANT USAGE ON SCHEMA public TO your_app_user;
