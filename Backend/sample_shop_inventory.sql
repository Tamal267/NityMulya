-- Sample shop inventory data for testing

-- First, let's make sure we have some shop owners
INSERT INTO shop_owners (name, email, password, contact, shop_address, shop_description, latitude, longitude) VALUES 
('রহমান গ্রোসারি', 'rahman.grocery@example.com', 'password123', '01711123456', 'ধানমন্ডি-৩২, ঢাকা', 'পাড়ার সুবিধাজনক গ্রোসারি দোকান', 23.7465, 90.3763),
('করিম স্টোর', 'karim.store@example.com', 'password123', '01812345678', 'গুলশান-১, ঢাকা', 'প্রিমিয়াম খাদ্যপণ্যের দোকান', 23.7925, 90.4078),
('নিউ মার্কেট শপ', 'newmarket.shop@example.com', 'password123', '01913456789', 'নিউমার্কেট, ঢাকা', 'ঐতিহ্যবাহী বাজারের দোকান', 23.7275, 90.3854),
('ফ্রেশ মার্ট', 'fresh.mart@example.com', 'password123', '01615678901', 'উত্তরা-৭, ঢাকা', 'তাজা খাদ্যপণ্যের বিশেষজ্ঞ দোকান', 23.8759, 90.3795),
('আলম ট্রেডার্স', 'alam.traders@example.com', 'password123', '01913456789', 'মিরপুর-১০, ঢাকা', 'পাইকারি ও খুচরা খাদ্যপণ্য', 23.8103, 90.4125)
ON CONFLICT (email) DO NOTHING;

-- Add shop inventory for different products
-- চাল সরু (নাজির/মিনিকেট)
INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
SELECT so.id, sc.id, 150, 78.00, 20, true
FROM shop_owners so, subcategories sc 
WHERE so.email = 'rahman.grocery@example.com' AND sc.subcat_name = 'চাল সরু (নাজির/মিনিকেট)'
ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
    stock_quantity = EXCLUDED.stock_quantity,
    unit_price = EXCLUDED.unit_price,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
SELECT so.id, sc.id, 200, 80.00, 25, true
FROM shop_owners so, subcategories sc 
WHERE so.email = 'karim.store@example.com' AND sc.subcat_name = 'চাল সরু (নাজির/মিনিকেট)'
ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
    stock_quantity = EXCLUDED.stock_quantity,
    unit_price = EXCLUDED.unit_price,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
SELECT so.id, sc.id, 80, 82.00, 15, true
FROM shop_owners so, subcategories sc 
WHERE so.email = 'newmarket.shop@example.com' AND sc.subcat_name = 'চাল সরু (নাজির/মিনিকেট)'
ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
    stock_quantity = EXCLUDED.stock_quantity,
    unit_price = EXCLUDED.unit_price,
    updated_at = CURRENT_TIMESTAMP;

-- চাল (মাঝারী)পাইজাম/আটাশ
INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
SELECT so.id, sc.id, 120, 65.00, 20, true
FROM shop_owners so, subcategories sc 
WHERE so.email = 'fresh.mart@example.com' AND sc.subcat_name = 'চাল (মাঝারী)পাইজাম/আটাশ'
ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
    stock_quantity = EXCLUDED.stock_quantity,
    unit_price = EXCLUDED.unit_price,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
SELECT so.id, sc.id, 90, 68.00, 15, true
FROM shop_owners so, subcategories sc 
WHERE so.email = 'alam.traders@example.com' AND sc.subcat_name = 'চাল (মাঝারী)পাইজাম/আটাশ'
ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
    stock_quantity = EXCLUDED.stock_quantity,
    unit_price = EXCLUDED.unit_price,
    updated_at = CURRENT_TIMESTAMP;

-- আটা সাদা (খোলা)
INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
SELECT so.id, sc.id, 75, 42.00, 10, true
FROM shop_owners so, subcategories sc 
WHERE so.email = 'rahman.grocery@example.com' AND sc.subcat_name = 'আটা সাদা (খোলা)'
ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
    stock_quantity = EXCLUDED.stock_quantity,
    unit_price = EXCLUDED.unit_price,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
SELECT so.id, sc.id, 60, 44.00, 8, true
FROM shop_owners so, subcategories sc 
WHERE so.email = 'karim.store@example.com' AND sc.subcat_name = 'আটা সাদা (খোলা)'
ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
    stock_quantity = EXCLUDED.stock_quantity,
    unit_price = EXCLUDED.unit_price,
    updated_at = CURRENT_TIMESTAMP;

-- সয়াবিন তেল (লুজ)
INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
SELECT so.id, sc.id, 40, 165.00, 5, true
FROM shop_owners so, subcategories sc 
WHERE so.email = 'fresh.mart@example.com' AND sc.subcat_name = 'সয়াবিন তেল (লুজ)'
ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
    stock_quantity = EXCLUDED.stock_quantity,
    unit_price = EXCLUDED.unit_price,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
SELECT so.id, sc.id, 30, 168.00, 5, true
FROM shop_owners so, subcategories sc 
WHERE so.email = 'newmarket.shop@example.com' AND sc.subcat_name = 'সয়াবিন তেল (লুজ)'
ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
    stock_quantity = EXCLUDED.stock_quantity,
    unit_price = EXCLUDED.unit_price,
    updated_at = CURRENT_TIMESTAMP;

-- মশুর ডাল (বড় দানা)
INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
SELECT so.id, sc.id, 85, 98.00, 10, true
FROM shop_owners so, subcategories sc 
WHERE so.email = 'alam.traders@example.com' AND sc.subcat_name = 'মশুর ডাল (বড় দানা)'
ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
    stock_quantity = EXCLUDED.stock_quantity,
    unit_price = EXCLUDED.unit_price,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
SELECT so.id, sc.id, 70, 102.00, 12, true
FROM shop_owners so, subcategories sc 
WHERE so.email = 'rahman.grocery@example.com' AND sc.subcat_name = 'মশুর ডাল (বড় দানা)'
ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
    stock_quantity = EXCLUDED.stock_quantity,
    unit_price = EXCLUDED.unit_price,
    updated_at = CURRENT_TIMESTAMP;

-- পিঁয়াজ (দেশী)
INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
SELECT so.id, sc.id, 95, 78.00, 15, true
FROM shop_owners so, subcategories sc 
WHERE so.email = 'fresh.mart@example.com' AND sc.subcat_name = 'পিঁয়াজ (দেশী)'
ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
    stock_quantity = EXCLUDED.stock_quantity,
    unit_price = EXCLUDED.unit_price,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
SELECT so.id, sc.id, 110, 81.00, 20, true
FROM shop_owners so, subcategories sc 
WHERE so.email = 'karim.store@example.com' AND sc.subcat_name = 'পিঁয়াজ (দেশী)'
ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
    stock_quantity = EXCLUDED.stock_quantity,
    unit_price = EXCLUDED.unit_price,
    updated_at = CURRENT_TIMESTAMP;

-- Add some products to multiple shops for better testing
INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
SELECT so.id, sc.id, 55, 79.00, 10, true
FROM shop_owners so, subcategories sc 
WHERE so.email = 'fresh.mart@example.com' AND sc.subcat_name = 'চাল সরু (নাজির/মিনিকেট)'
ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
    stock_quantity = EXCLUDED.stock_quantity,
    unit_price = EXCLUDED.unit_price,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO shop_inventory (shop_owner_id, subcat_id, stock_quantity, unit_price, low_stock_threshold, is_active)
SELECT so.id, sc.id, 45, 43.00, 8, true
FROM shop_owners so, subcategories sc 
WHERE so.email = 'newmarket.shop@example.com' AND sc.subcat_name = 'আটা সাদা (খোলা)'
ON CONFLICT (shop_owner_id, subcat_id) DO UPDATE SET
    stock_quantity = EXCLUDED.stock_quantity,
    unit_price = EXCLUDED.unit_price,
    updated_at = CURRENT_TIMESTAMP;
