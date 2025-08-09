-- Database initialization script for NityMulya
-- Create tables for customers, wholesalers, and shop_owners

-- Create customers table if it doesn't exist
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    contact VARCHAR(50) NOT NULL,
    address TEXT,
    longitude DECIMAL(10, 8),
    latitude DECIMAL(10, 8),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create wholesalers table if it doesn't exist
CREATE TABLE IF NOT EXISTS wholesalers (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    contact VARCHAR(50) NOT NULL,
    address TEXT,
    longitude DECIMAL(10, 8),
    latitude DECIMAL(10, 8),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create shop_owners table if it doesn't exist
CREATE TABLE IF NOT EXISTS shop_owners (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    contact VARCHAR(50) NOT NULL,
    address TEXT,
    longitude DECIMAL(10, 8),
    latitude DECIMAL(10, 8),
    shop_description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add missing columns to existing tables if they don't exist
DO $$
BEGIN
    -- Add full_name to customers if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'customers' AND column_name = 'full_name') THEN
        ALTER TABLE customers ADD COLUMN full_name VARCHAR(255) NOT NULL DEFAULT '';
    END IF;
    
    -- Add full_name to wholesalers if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'wholesalers' AND column_name = 'full_name') THEN
        ALTER TABLE wholesalers ADD COLUMN full_name VARCHAR(255) NOT NULL DEFAULT '';
    END IF;
    
    -- Add full_name to shop_owners if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'shop_owners' AND column_name = 'full_name') THEN
        ALTER TABLE shop_owners ADD COLUMN full_name VARCHAR(255) NOT NULL DEFAULT '';
    END IF;
    
    -- Add shop_description to shop_owners if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'shop_owners' AND column_name = 'shop_description') THEN
        ALTER TABLE shop_owners ADD COLUMN shop_description TEXT;
    END IF;
    
    -- Add contact to customers if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'customers' AND column_name = 'contact') THEN
        ALTER TABLE customers ADD COLUMN contact VARCHAR(50) NOT NULL DEFAULT '';
    END IF;
    
    -- Add contact to wholesalers if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'wholesalers' AND column_name = 'contact') THEN
        ALTER TABLE wholesalers ADD COLUMN contact VARCHAR(50) NOT NULL DEFAULT '';
    END IF;
    
    -- Add contact to shop_owners if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'shop_owners' AND column_name = 'contact') THEN
        ALTER TABLE shop_owners ADD COLUMN contact VARCHAR(50) NOT NULL DEFAULT '';
    END IF;
    
    -- Add timestamps if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'customers' AND column_name = 'created_at') THEN
        ALTER TABLE customers ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'customers' AND column_name = 'updated_at') THEN
        ALTER TABLE customers ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'wholesalers' AND column_name = 'created_at') THEN
        ALTER TABLE wholesalers ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'wholesalers' AND column_name = 'updated_at') THEN
        ALTER TABLE wholesalers ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'shop_owners' AND column_name = 'created_at') THEN
        ALTER TABLE shop_owners ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'shop_owners' AND column_name = 'updated_at') THEN
        ALTER TABLE shop_owners ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;
    END IF;
END $$;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_customers_email ON customers(email);
CREATE INDEX IF NOT EXISTS idx_wholesalers_email ON wholesalers(email);
CREATE INDEX IF NOT EXISTS idx_shop_owners_email ON shop_owners(email);

CREATE INDEX IF NOT EXISTS idx_customers_location ON customers(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_wholesalers_location ON wholesalers(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_shop_owners_location ON shop_owners(latitude, longitude);
