import * as fs from 'fs';
import * as path from 'path';
import sql from './db';

export const initializeDatabase = async () => {
    try {
        console.log('Initializing database tables...');
        
        // Read the schema SQL file
        const schemaPath = path.join(__dirname, 'schema.sql');
        const schemaSql = fs.readFileSync(schemaPath, 'utf8');
        
        // Execute the entire SQL as a single statement
        // This handles complex blocks like DO $$ ... $$ properly
        await sql.unsafe(schemaSql);
        
        console.log('Database tables initialized successfully!');
    } catch (error) {
        console.error('Error initializing database:', error);
        throw error;
    }
};

export const checkDatabaseConnection = async () => {
    try {
        await sql`SELECT 1`;
        console.log('Database connection successful!');
        return true;
    } catch (error) {
        console.error('Database connection failed:', error);
        return false;
    }
};
