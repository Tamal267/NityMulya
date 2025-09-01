-- Database schema for NityMulya Backend

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cat_name VARCHAR(100) UNIQUE NOT NULL
);

-- Subcategories table
CREATE TABLE IF NOT EXISTS subcategories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subcat_name VARCHAR(100) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    min_price DECIMAL(10, 2),
    max_price DECIMAL(10, 2),
    subcat_img VARCHAR(255),
    cat_id UUID REFERENCES categories (id) ON DELETE CASCADE,
    UNIQUE (subcat_name, cat_id)
);

-- Customers table (already exists)
CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    contact VARCHAR(20) NOT NULL,
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8)
);

-- Wholesalers table
CREATE TABLE IF NOT EXISTS wholesalers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    contact VARCHAR(20) NOT NULL,
    organization_address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8)
);

-- Shop Owners table
CREATE TABLE IF NOT EXISTS shop_owners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    contact VARCHAR(20) NOT NULL,
    shop_address TEXT,
    shop_description TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8)
);

-- Wholesaler inventory table
CREATE TABLE IF NOT EXISTS wholesaler_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    wholesaler_id UUID REFERENCES wholesalers (id) ON DELETE CASCADE,
    subcat_id UUID REFERENCES subcategories (id) ON DELETE CASCADE,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    unit_price DECIMAL(10, 2) NOT NULL,
    low_stock_threshold INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE (wholesaler_id, subcat_id)
);

-- Orders/requests from shops to wholesalers
CREATE TABLE IF NOT EXISTS shop_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    shop_owner_id UUID REFERENCES shop_owners (id) ON DELETE CASCADE,
    wholesaler_id UUID REFERENCES wholesalers (id) ON DELETE CASCADE,
    subcat_id UUID REFERENCES subcategories (id) ON DELETE CASCADE,
    quantity_requested INTEGER NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (
        status IN (
            'pending',
            'processing',
            'delivered',
            'cancelled'
        )
    ),
    delivery_address TEXT,
    notes TEXT
);

-- Customer reviews table
CREATE TABLE IF NOT EXISTS customer_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    customer_id UUID REFERENCES customers (id) ON DELETE CASCADE,
    shop_owner_id UUID REFERENCES shop_owners (id) ON DELETE CASCADE,
    order_id UUID,
    subcat_id UUID REFERENCES subcategories (id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (
        rating >= 1
        AND rating <= 5
    ),
    comment TEXT,
    product_name VARCHAR(255),
    shop_name VARCHAR(255),
    delivery_rating INTEGER CHECK (
        delivery_rating >= 1
        AND delivery_rating <= 5
    ),
    service_rating INTEGER CHECK (
        service_rating >= 1
        AND service_rating <= 5
    ),
    helpful_count INTEGER DEFAULT 0,
    is_verified_purchase BOOLEAN DEFAULT FALSE
);

-- Chat/communication between wholesalers and shops
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sender_id UUID NOT NULL,
    receiver_id UUID NOT NULL,
    sender_type VARCHAR(20) NOT NULL CHECK (
        sender_type IN ('wholesaler', 'shop_owner')
    ),
    receiver_type VARCHAR(20) NOT NULL CHECK (
        receiver_type IN ('wholesaler', 'shop_owner')
    ),
    message_text TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE
);

-- Wholesaler offers/promotions
CREATE TABLE IF NOT EXISTS wholesaler_offers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    wholesaler_id UUID REFERENCES wholesalers (id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    discount_percentage DECIMAL(5, 2),
    minimum_quantity INTEGER,
    valid_until TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_categories_name ON categories (cat_name);

CREATE INDEX IF NOT EXISTS idx_subcategories_cat ON subcategories (cat_id);

CREATE INDEX IF NOT EXISTS idx_subcategories_name ON subcategories (subcat_name);

CREATE INDEX IF NOT EXISTS idx_customers_email ON customers (email);

CREATE INDEX IF NOT EXISTS idx_customers_location ON customers (latitude, longitude);

CREATE INDEX IF NOT EXISTS idx_wholesalers_email ON wholesalers (email);

CREATE INDEX IF NOT EXISTS idx_wholesalers_location ON wholesalers (latitude, longitude);

CREATE INDEX IF NOT EXISTS idx_shop_owners_email ON shop_owners (email);

CREATE INDEX IF NOT EXISTS idx_shop_owners_location ON shop_owners (latitude, longitude);

CREATE INDEX IF NOT EXISTS idx_wholesaler_inventory_wholesaler ON wholesaler_inventory (wholesaler_id);

CREATE INDEX IF NOT EXISTS idx_wholesaler_inventory_subcat ON wholesaler_inventory (subcat_id);

CREATE INDEX IF NOT EXISTS idx_shop_orders_shop ON shop_orders (shop_owner_id);

CREATE INDEX IF NOT EXISTS idx_shop_orders_wholesaler ON shop_orders (wholesaler_id);

CREATE INDEX IF NOT EXISTS idx_shop_orders_status ON shop_orders (status);

CREATE INDEX IF NOT EXISTS idx_chat_sender ON chat_messages (sender_id);

CREATE INDEX IF NOT EXISTS idx_chat_receiver ON chat_messages (receiver_id);

CREATE INDEX IF NOT EXISTS idx_wholesaler_offers_wholesaler ON wholesaler_offers (wholesaler_id);

CREATE INDEX IF NOT EXISTS idx_customer_reviews_customer ON customer_reviews (customer_id);

CREATE INDEX IF NOT EXISTS idx_customer_reviews_shop ON customer_reviews (shop_owner_id);

CREATE INDEX IF NOT EXISTS idx_customer_reviews_subcat ON customer_reviews (subcat_id);

CREATE INDEX IF NOT EXISTS idx_customer_reviews_rating ON customer_reviews (rating);