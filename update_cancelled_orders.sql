-- Update existing cancelled orders to have default cancellation reason
UPDATE customer_orders 
SET cancellation_reason = 'change my mind'
WHERE status = 'cancelled' 
AND (cancellation_reason IS NULL OR cancellation_reason = '');

-- Check updated records
SELECT id, order_number, status, cancellation_reason, created_at
FROM customer_orders 
WHERE status = 'cancelled'
ORDER BY created_at DESC;
