-- Migration to add shop details to customer_orders table
-- This ensures shop name is always available even if shop_owners data is missing

-- Add shop details columns to customer_orders table
ALTER TABLE customer_orders 
ADD COLUMN IF NOT EXISTS shop_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS shop_phone VARCHAR(20),
ADD COLUMN IF NOT EXISTS shop_address TEXT;

-- Update existing records to populate shop details from shop_owners table
UPDATE customer_orders 
SET 
    shop_name = so.name,
    shop_phone = so.contact,
    shop_address = so.address
FROM shop_owners so 
WHERE customer_orders.shop_owner_id = so.id
  AND customer_orders.shop_name IS NULL;

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_customer_orders_shop_name ON customer_orders(shop_name);

-- Update the function to generate order number (if needed)
-- This is just a safety check to ensure the function exists
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
