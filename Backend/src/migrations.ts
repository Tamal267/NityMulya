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
        
        console.log('Database migrations completed successfully!');
    } catch (error) {
        console.error('Error running migrations:', error);
        throw error;
    }
};
