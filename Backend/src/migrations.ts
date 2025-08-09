import sql from './db';

export const runMigrations = async () => {
    try {
        console.log('Running database migrations...');
        
        // Add missing columns to wholesalers table
        await sql`
            ALTER TABLE wholesalers 
            ADD COLUMN IF NOT EXISTS full_name VARCHAR(255),
            ADD COLUMN IF NOT EXISTS address TEXT,
            ADD COLUMN IF NOT EXISTS contact VARCHAR(50),
            ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        `;
        
        // Add missing columns to shop_owners table
        await sql`
            ALTER TABLE shop_owners 
            ADD COLUMN IF NOT EXISTS full_name VARCHAR(255),
            ADD COLUMN IF NOT EXISTS address TEXT,
            ADD COLUMN IF NOT EXISTS contact VARCHAR(50),
            ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        `;
        
        // Add missing columns to customers table
        await sql`
            ALTER TABLE customers 
            ADD COLUMN IF NOT EXISTS full_name VARCHAR(255),
            ADD COLUMN IF NOT EXISTS contact VARCHAR(50),
            ADD COLUMN IF NOT EXISTS address TEXT,
            ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        `;
        
        // Drop the name column from all tables (we only use full_name)
        try {
            await sql`ALTER TABLE customers DROP COLUMN IF EXISTS name`;
            await sql`ALTER TABLE wholesalers DROP COLUMN IF EXISTS name`;
            await sql`ALTER TABLE shop_owners DROP COLUMN IF EXISTS name`;
            console.log('Dropped name columns from all tables');
        } catch (error) {
            console.log('Note: name columns may not exist or already dropped');
        }
        
        // Drop existing shop_inventory table if it has wrong schema
        try {
            await sql`DROP TABLE IF EXISTS shop_inventory CASCADE`;
            console.log('Dropped existing shop_inventory table');
        } catch (error) {
            console.log('Note: shop_inventory table may not exist');
        }
        
        // Create shop_inventory table if it doesn't exist
        await sql`
            CREATE TABLE IF NOT EXISTS shop_inventory (
                id SERIAL PRIMARY KEY,
                shop_owner_id UUID NOT NULL REFERENCES shop_owners(id) ON DELETE CASCADE,
                subcat_id UUID NOT NULL,
                stock_quantity INTEGER NOT NULL DEFAULT 0,
                unit_price DECIMAL(10,2) NOT NULL,
                low_stock_threshold INTEGER DEFAULT 10,
                is_active BOOLEAN DEFAULT true,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(shop_owner_id, subcat_id)
            )
        `;
        
        // Create indexes for shop_inventory
        await sql`
            CREATE INDEX IF NOT EXISTS idx_shop_inventory_shop_owner 
            ON shop_inventory(shop_owner_id)
        `;
        await sql`
            CREATE INDEX IF NOT EXISTS idx_shop_inventory_subcat 
            ON shop_inventory(subcat_id)
        `;
        await sql`
            CREATE INDEX IF NOT EXISTS idx_shop_inventory_active 
            ON shop_inventory(shop_owner_id, is_active)
        `;
        
        console.log('Shop inventory table created/verified successfully!');
        
        console.log('Database migrations completed successfully!');
    } catch (error) {
        console.error('Error running migrations:', error);
        throw error;
    }
};
