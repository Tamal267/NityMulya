-- Sample data for testing the app with database integration

-- Insert sample categories
INSERT INTO categories (cat_name) VALUES 
('চাল') ON CONFLICT (cat_name) DO NOTHING;
INSERT INTO categories (cat_name) VALUES 
('আটা/ময়দা') ON CONFLICT (cat_name) DO NOTHING;
INSERT INTO categories (cat_name) VALUES 
('ভোজ্য তেল') ON CONFLICT (cat_name) DO NOTHING;
INSERT INTO categories (cat_name) VALUES 
('ডাল') ON CONFLICT (cat_name) DO NOTHING;
INSERT INTO categories (cat_name) VALUES 
('মসলা') ON CONFLICT (cat_name) DO NOTHING;

-- Insert sample subcategories (products)
INSERT INTO subcategories (subcat_name, unit, min_price, max_price, cat_id) 
SELECT 'চাল সরু (নাজির/মিনিকেট)', 'প্রতি কেজি', 75.00, 85.00, c.id 
FROM categories c WHERE c.cat_name = 'চাল'
ON CONFLICT (subcat_name, cat_id) DO NOTHING;

INSERT INTO subcategories (subcat_name, unit, min_price, max_price, cat_id) 
SELECT 'চাল (মাঝারী)পাইজাম/আটাশ', 'প্রতি কেজি', 60.00, 75.00, c.id 
FROM categories c WHERE c.cat_name = 'চাল'
ON CONFLICT (subcat_name, cat_id) DO NOTHING;

INSERT INTO subcategories (subcat_name, unit, min_price, max_price, cat_id) 
SELECT 'আটা সাদা (খোলা)', 'প্রতি কেজি', 40.00, 45.00, c.id 
FROM categories c WHERE c.cat_name = 'আটা/ময়দা'
ON CONFLICT (subcat_name, cat_id) DO NOTHING;

INSERT INTO subcategories (subcat_name, unit, min_price, max_price, cat_id) 
SELECT 'সয়াবিন তেল (লুজ)', 'প্রতি লিটার', 162.00, 172.00, c.id 
FROM categories c WHERE c.cat_name = 'ভোজ্য তেল'
ON CONFLICT (subcat_name, cat_id) DO NOTHING;

INSERT INTO subcategories (subcat_name, unit, min_price, max_price, cat_id) 
SELECT 'মশুর ডাল (বড় দানা)', 'প্রতি কেজি', 95.00, 110.00, c.id 
FROM categories c WHERE c.cat_name = 'ডাল'
ON CONFLICT (subcat_name, cat_id) DO NOTHING;

INSERT INTO subcategories (subcat_name, unit, min_price, max_price, cat_id) 
SELECT 'পিঁয়াজ (দেশী)', 'প্রতি কেজি', 75.00, 85.00, c.id 
FROM categories c WHERE c.cat_name = 'মসলা'
ON CONFLICT (subcat_name, cat_id) DO NOTHING;

-- Insert sample wholesalers
INSERT INTO wholesalers (name, email, password, contact, organization_address, latitude, longitude) VALUES 
('রহমান ট্রেডার্স', 'rahman.traders@example.com', 'password123', '01711123456', 'ধানমন্ডি, ঢাকা-১২০৫', 23.7465, 90.3763),
('করিম এন্টারপ্রাইজ', 'karim.enterprise@example.com', 'password123', '01812345678', 'গুলশান-২, ঢাকা-১২১২', 23.7925, 90.4078),
('আলম ইমপোর্ট', 'alam.import@example.com', 'password123', '01913456789', 'মিরপুর-১০, ঢাকা-১২১৬', 23.8103, 90.4125)
ON CONFLICT (email) DO NOTHING;

-- Insert sample wholesaler inventory
INSERT INTO wholesaler_inventory (wholesaler_id, subcat_id, stock_quantity, unit_price, is_active)
SELECT w.id, sc.id, 1000, 80.00, true
FROM wholesalers w, subcategories sc 
WHERE w.email = 'rahman.traders@example.com' AND sc.subcat_name = 'চাল সরু (নাজির/মিনিকেট)'
ON CONFLICT (wholesaler_id, subcat_id) DO NOTHING;

INSERT INTO wholesaler_inventory (wholesaler_id, subcat_id, stock_quantity, unit_price, is_active)
SELECT w.id, sc.id, 800, 42.00, true
FROM wholesalers w, subcategories sc 
WHERE w.email = 'rahman.traders@example.com' AND sc.subcat_name = 'আটা সাদা (খোলা)'
ON CONFLICT (wholesaler_id, subcat_id) DO NOTHING;

INSERT INTO wholesaler_inventory (wholesaler_id, subcat_id, stock_quantity, unit_price, is_active)
SELECT w.id, sc.id, 500, 167.00, true
FROM wholesalers w, subcategories sc 
WHERE w.email = 'korimalm.enterprise@example.com' AND sc.subcat_name = 'সয়াবিন তেল (লুজ)'
ON CONFLICT (wholesaler_id, subcat_id) DO NOTHING;

INSERT INTO wholesaler_inventory (wholesaler_id, subcat_id, stock_quantity, unit_price, is_active)
SELECT w.id, sc.id, 600, 105.00, true
FROM wholesalers w, subcategories sc 
WHERE w.email = 'karim.enterprise@example.com' AND sc.subcat_name = 'মশুর ডাল (বড় দানা)'
ON CONFLICT (wholesaler_id, subcat_id) DO NOTHING;

INSERT INTO wholesaler_inventory (wholesaler_id, subcat_id, stock_quantity, unit_price, is_active)
SELECT w.id, sc.id, 300, 80.00, true
FROM wholesalers w, subcategories sc 
WHERE w.email = 'alam.import@example.com' AND sc.subcat_name = 'পিঁয়াজ (দেশী)'
ON CONFLICT (wholesaler_id, subcat_id) DO NOTHING;

-- Insert sample shop owners
INSERT INTO shop_owners (name, email, password, contact, shop_address, shop_description, latitude, longitude) VALUES 
('রহমান গ্রোসারি', 'rahman.grocery@example.com', 'password123', '01711123456', 'ধানমন্ডি-৩২, ঢাকা', 'পাড়ার সুবিধাজনক গ্রোসারি দোকান', 23.7465, 90.3763),
('করিম স্টোর', 'karim.store@example.com', 'password123', '01812345678', 'গুলশান-১, ঢাকা', 'প্রিমিয়াম খাদ্যপণ্যের দোকান', 23.7925, 90.4078),
('নিউ মার্কেট শপ', 'newmarket.shop@example.com', 'password123', '01913456789', 'নিউমার্কেট, ঢাকা', 'ঐতিহ্যবাহী বাজারের দোকান', 23.7275, 90.3854)
ON CONFLICT (email) DO NOTHING;
