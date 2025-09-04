-- Fix NULL shop_name in customer_orders table
-- This script will update all orders to have proper shop names

-- First, add the shop detail columns if they don't exist
ALTER TABLE customer_orders 
ADD COLUMN IF NOT EXISTS shop_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS shop_phone VARCHAR(20),
ADD COLUMN IF NOT EXISTS shop_address TEXT;

-- Update all existing orders with shop details from shop_owners table
UPDATE customer_orders 
SET 
    shop_name = so.name,
    shop_phone = so.contact,
    shop_address = so.address
FROM shop_owners so 
WHERE customer_orders.shop_owner_id = so.id;

-- Verify the update by showing sample results
SELECT 
    co.order_number,
    co.shop_owner_id,
    co.shop_name,
    so.name as original_shop_name
FROM customer_orders co
LEFT JOIN shop_owners so ON co.shop_owner_id = so.id
LIMIT 10;
