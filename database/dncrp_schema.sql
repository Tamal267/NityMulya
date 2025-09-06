-- DNCRP Demo System Database Schema
-- Enhanced complaint system for জাতীয় ভোক্তা অধিকার সংরক্ষণ অধিদপ্তর

-- Drop existing complaint table to recreate with enhanced structure
DROP TABLE IF EXISTS complaints CASCADE;
DROP TABLE IF EXISTS complaint_files CASCADE;
DROP TABLE IF EXISTS complaint_history CASCADE;

-- Enhanced Users table with DNCRP admin role
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('customer', 'shop_owner', 'wholesaler', 'dncrp_admin')),
    phone TEXT,
    location TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Enhanced Shops table
CREATE TABLE IF NOT EXISTS shops (
    id SERIAL PRIMARY KEY,
    owner_id INTEGER REFERENCES users(id),
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    address TEXT,
    description TEXT,
    phone TEXT,
    verification_status TEXT DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Enhanced Products table
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    shop_id INTEGER REFERENCES shops(id),
    name TEXT NOT NULL,
    category TEXT,
    price DECIMAL(10, 2) NOT NULL,
    unit TEXT DEFAULT 'kg',
    quantity INTEGER DEFAULT 0,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Enhanced Complaints table for DNCRP system
CREATE TABLE IF NOT EXISTS complaints (
    id SERIAL PRIMARY KEY,
    complaint_number TEXT UNIQUE NOT NULL,
    customer_id INTEGER NOT NULL REFERENCES users(id),
    customer_name TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    customer_phone TEXT,
    shop_id INTEGER NOT NULL REFERENCES shops(id),
    shop_name TEXT NOT NULL,
    product_id INTEGER REFERENCES products(id),
    product_name TEXT,
    
    -- Enhanced complaint categorization
    category TEXT NOT NULL CHECK (category IN (
        'Overpricing', 'No Price List', 'Short Measurement', 
        'Low Quality Product', 'Unfair Behavior', 'Other'
    )),
    priority TEXT NOT NULL DEFAULT 'Medium' CHECK (priority IN ('Low', 'Medium', 'High', 'Urgent')),
    severity TEXT NOT NULL DEFAULT 'Minor' CHECK (severity IN ('Minor', 'Moderate', 'Major', 'Critical')),
    
    description TEXT NOT NULL,
    
    -- DNCRP Status tracking
    status TEXT NOT NULL DEFAULT 'Received' CHECK (status IN ('Received', 'Forwarded', 'Solved')),
    forwarded_to TEXT,
    forwarded_at TIMESTAMP,
    solved_at TIMESTAMP,
    
    -- Timestamps
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Additional fields
    resolution_comment TEXT,
    dncrp_officer_id INTEGER REFERENCES users(id)
);

-- Complaint Files table (for proof uploads)
CREATE TABLE IF NOT EXISTS complaint_files (
    id SERIAL PRIMARY KEY,
    complaint_id INTEGER NOT NULL REFERENCES complaints(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_type TEXT NOT NULL CHECK (file_type IN ('image', 'pdf', 'video', 'document')),
    file_size INTEGER,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Complaint History table (status changes and comments)
CREATE TABLE IF NOT EXISTS complaint_history (
    id SERIAL PRIMARY KEY,
    complaint_id INTEGER NOT NULL REFERENCES complaints(id) ON DELETE CASCADE,
    old_status TEXT,
    new_status TEXT NOT NULL,
    comment TEXT,
    changed_by INTEGER REFERENCES users(id),
    changed_by_name TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    type TEXT NOT NULL CHECK (type IN ('complaint_received', 'complaint_forwarded', 'complaint_solved', 'general')),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    complaint_id INTEGER REFERENCES complaints(id),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_shops_owner ON shops(owner_id);
CREATE INDEX IF NOT EXISTS idx_products_shop ON products(shop_id);
CREATE INDEX IF NOT EXISTS idx_complaints_customer ON complaints(customer_id);
CREATE INDEX IF NOT EXISTS idx_complaints_shop ON complaints(shop_id);
CREATE INDEX IF NOT EXISTS idx_complaints_status ON complaints(status);
CREATE INDEX IF NOT EXISTS idx_complaints_number ON complaints(complaint_number);
CREATE INDEX IF NOT EXISTS idx_complaint_files_complaint ON complaint_files(complaint_id);
CREATE INDEX IF NOT EXISTS idx_complaint_history_complaint ON complaint_history(complaint_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(is_read);

-- Insert DNCRP admin user
INSERT INTO users (name, email, password_hash, role, phone)
VALUES (
    'DNCRP Demo Admin',
    'DNCRP_Demo@govt.com',
    '$2b$10$xYzKL8QmHGF6N.8yJ2x.6eHHvqO.7Vp9Dw2Xc1hF5M3jT8pR4vE6w',  -- hashed 'DNCRP_Demo'
    'dncrp_admin',
    '+880-1700-000000'
) ON CONFLICT (email) DO NOTHING;

-- Insert sample data for testing
INSERT INTO users (name, email, password_hash, role, phone) VALUES
('Test Customer', 'customer@test.com', '$2b$10$hashedpassword', 'customer', '+880-1700-111111'),
('Shop Owner 1', 'shop1@test.com', '$2b$10$hashedpassword', 'shop_owner', '+880-1700-222222'),
('Wholesaler 1', 'wholesaler1@test.com', '$2b$10$hashedpassword', 'wholesaler', '+880-1700-333333')
ON CONFLICT (email) DO NOTHING;

-- Insert sample shops
INSERT INTO shops (owner_id, name, location, address, description, phone) VALUES
((SELECT id FROM users WHERE email = 'shop1@test.com'), 'Sunrise Store', 'Dhaka', 'Dhanmondi, Dhaka', 'Quality grocery store', '+880-1700-444444'),
((SELECT id FROM users WHERE email = 'shop1@test.com'), 'Fresh Market', 'Chittagong', 'Agrabad, Chittagong', 'Fresh products daily', '+880-1700-555555')
ON CONFLICT DO NOTHING;

-- Insert sample products
INSERT INTO products (shop_id, name, category, price, unit, quantity, description) VALUES
((SELECT id FROM shops WHERE name = 'Sunrise Store'), 'Basmati Rice', 'Rice', 85.50, 'kg', 100, 'Premium quality basmati rice'),
((SELECT id FROM shops WHERE name = 'Sunrise Store'), 'Soybean Oil', 'Oil', 165.00, 'liter', 50, 'Pure soybean oil'),
((SELECT id FROM shops WHERE name = 'Fresh Market'), 'White Sugar', 'Sugar', 65.00, 'kg', 200, 'Refined white sugar')
ON CONFLICT DO NOTHING;

-- Verification queries
SELECT 'users' as table_name, COUNT(*) as row_count FROM users
UNION ALL
SELECT 'shops', COUNT(*) FROM shops
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'complaints', COUNT(*) FROM complaints
UNION ALL
SELECT 'complaint_files', COUNT(*) FROM complaint_files
UNION ALL
SELECT 'complaint_history', COUNT(*) FROM complaint_history
UNION ALL
SELECT 'notifications', COUNT(*) FROM notifications;
