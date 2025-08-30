import sql from "../db";

async function runCustomerOrderMigration() {
  try {
    console.log("Starting customer order database migration...");

    // Drop existing tables if they exist
    await sql`DROP TABLE IF EXISTS order_status_history CASCADE`;
    await sql`DROP TABLE IF EXISTS customer_orders CASCADE`;

    // Create enum type
    await sql`
            DO $$ BEGIN
                CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled');
            EXCEPTION
                WHEN duplicate_object THEN null;
            END $$
        `;

    // Create customer_orders table
    await sql`
            CREATE TABLE customer_orders (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                order_number VARCHAR(50) UNIQUE NOT NULL,
                customer_id UUID NOT NULL,
                shop_owner_id UUID NOT NULL,
                subcat_id UUID NOT NULL,
                quantity_ordered INTEGER NOT NULL CHECK (quantity_ordered > 0),
                unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
                total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
                delivery_address TEXT NOT NULL,
                delivery_phone VARCHAR(20) NOT NULL,
                status order_status DEFAULT 'pending',
                notes TEXT,
                cancellation_reason TEXT,
                estimated_delivery TIMESTAMP,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `;

    // Add foreign key constraints separately
    try {
      await sql`
                ALTER TABLE customer_orders 
                ADD CONSTRAINT fk_customer_orders_customer 
                FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
            `;
    } catch (e) {
      console.log(
        "Customer FK constraint may already exist or customers table not found"
      );
    }

    try {
      await sql`
                ALTER TABLE customer_orders 
                ADD CONSTRAINT fk_customer_orders_shop_owner 
                FOREIGN KEY (shop_owner_id) REFERENCES shop_owners(id) ON DELETE CASCADE
            `;
    } catch (e) {
      console.log(
        "Shop owner FK constraint may already exist or shop_owners table not found"
      );
    }

    try {
      await sql`
                ALTER TABLE customer_orders 
                ADD CONSTRAINT fk_customer_orders_subcategory 
                FOREIGN KEY (subcat_id) REFERENCES subcategories(id) ON DELETE CASCADE
            `;
    } catch (e) {
      console.log(
        "Subcategory FK constraint may already exist or subcategories table not found"
      );
    }

    // Create order_status_history table
    await sql`
            CREATE TABLE order_status_history (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                order_id UUID NOT NULL,
                old_status order_status,
                new_status order_status NOT NULL,
                changed_by VARCHAR(50),
                notes TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `;

    // Add foreign key for order_status_history
    await sql`
            ALTER TABLE order_status_history 
            ADD CONSTRAINT fk_order_status_history_order 
            FOREIGN KEY (order_id) REFERENCES customer_orders(id) ON DELETE CASCADE
        `;

    // Create indexes
    await sql`CREATE INDEX idx_customer_orders_customer_id ON customer_orders(customer_id)`;
    await sql`CREATE INDEX idx_customer_orders_shop_owner_id ON customer_orders(shop_owner_id)`;
    await sql`CREATE INDEX idx_customer_orders_status ON customer_orders(status)`;
    await sql`CREATE INDEX idx_customer_orders_created_at ON customer_orders(created_at)`;
    await sql`CREATE INDEX idx_customer_orders_order_number ON customer_orders(order_number)`;
    await sql`CREATE INDEX idx_order_status_history_order_id ON order_status_history(order_id)`;

    console.log("Tables and indexes created successfully");

    // Create functions
    await sql`
            CREATE OR REPLACE FUNCTION generate_order_number() 
            RETURNS VARCHAR(50) AS $$
            DECLARE
                new_order_number VARCHAR(50);
                counter INTEGER := 1;
            BEGIN
                LOOP
                    new_order_number := 'ORD-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD(counter::TEXT, 6, '0');
                    
                    IF NOT EXISTS (SELECT 1 FROM customer_orders WHERE order_number = new_order_number) THEN
                        RETURN new_order_number;
                    END IF;
                    
                    counter := counter + 1;
                    
                    IF counter > 999999 THEN
                        RAISE EXCEPTION 'Unable to generate unique order number';
                    END IF;
                END LOOP;
            END;
            $$ LANGUAGE plpgsql
        `;

    await sql`
            CREATE OR REPLACE FUNCTION set_order_number() 
            RETURNS TRIGGER AS $$
            BEGIN
                IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
                    NEW.order_number := generate_order_number();
                END IF;
                RETURN NEW;
            END;
            $$ LANGUAGE plpgsql
        `;

    await sql`
            CREATE OR REPLACE FUNCTION update_updated_at_column() 
            RETURNS TRIGGER AS $$
            BEGIN
                NEW.updated_at = CURRENT_TIMESTAMP;
                RETURN NEW;
            END;
            $$ LANGUAGE plpgsql
        `;

    // Create inventory management functions (optional - may not work if shop_inventory doesn't exist)
    try {
      await sql`
                CREATE OR REPLACE FUNCTION update_inventory_on_order() 
                RETURNS TRIGGER AS $$
                BEGIN
                    UPDATE shop_inventory 
                    SET quantity = quantity - NEW.quantity_ordered,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE shop_owner_id = NEW.shop_owner_id 
                      AND subcat_id = NEW.subcat_id;
                    
                    IF NOT FOUND THEN
                        RAISE EXCEPTION 'Product not found in shop inventory or insufficient stock';
                    END IF;
                    
                    IF (SELECT quantity FROM shop_inventory 
                        WHERE shop_owner_id = NEW.shop_owner_id AND subcat_id = NEW.subcat_id) < 0 THEN
                        RAISE EXCEPTION 'Insufficient stock available';
                    END IF;
                    
                    RETURN NEW;
                END;
                $$ LANGUAGE plpgsql
            `;

      await sql`
                CREATE OR REPLACE FUNCTION restore_inventory_on_cancel() 
                RETURNS TRIGGER AS $$
                BEGIN
                    IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
                        UPDATE shop_inventory 
                        SET quantity = quantity + NEW.quantity_ordered,
                            updated_at = CURRENT_TIMESTAMP
                        WHERE shop_owner_id = NEW.shop_owner_id 
                          AND subcat_id = NEW.subcat_id;
                    END IF;
                    
                    RETURN NEW;
                END;
                $$ LANGUAGE plpgsql
            `;
    } catch (e) {
      console.log(
        "Inventory functions skipped - shop_inventory table may not exist"
      );
    }

    await sql`
            CREATE OR REPLACE FUNCTION log_status_change() 
            RETURNS TRIGGER AS $$
            BEGIN
                IF NEW.status IS DISTINCT FROM OLD.status THEN
                    INSERT INTO order_status_history (order_id, old_status, new_status, changed_by, notes)
                    VALUES (NEW.id, OLD.status, NEW.status, 'system', 'Status changed automatically');
                END IF;
                
                RETURN NEW;
            END;
            $$ LANGUAGE plpgsql
        `;

    console.log("Functions created successfully");

    // Create triggers
    await sql`
            CREATE TRIGGER trigger_set_order_number
                BEFORE INSERT ON customer_orders
                FOR EACH ROW
                EXECUTE FUNCTION set_order_number()
        `;

    await sql`
            CREATE TRIGGER trigger_update_updated_at
                BEFORE UPDATE ON customer_orders
                FOR EACH ROW
                EXECUTE FUNCTION update_updated_at_column()
        `;

    await sql`
            CREATE TRIGGER trigger_log_status_change
                AFTER UPDATE ON customer_orders
                FOR EACH ROW
                EXECUTE FUNCTION log_status_change()
        `;

    // Create inventory triggers if functions exist
    try {
      await sql`
                CREATE TRIGGER trigger_update_inventory_on_order
                    AFTER INSERT ON customer_orders
                    FOR EACH ROW
                    EXECUTE FUNCTION update_inventory_on_order()
            `;

      await sql`
                CREATE TRIGGER trigger_restore_inventory_on_cancel
                    AFTER UPDATE ON customer_orders
                    FOR EACH ROW
                    EXECUTE FUNCTION restore_inventory_on_cancel()
            `;
      console.log("Inventory triggers created successfully");
    } catch (e) {
      console.log("Inventory triggers skipped - functions may not exist");
    }

    console.log("Customer order database migration completed successfully!");

    // Verify tables were created
    const tables = await sql`
            SELECT table_name FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name IN ('customer_orders', 'order_status_history')
        `;

    console.log(
      "Created tables:",
      tables.map((t) => t.table_name)
    );
  } catch (error) {
    console.error("Migration failed:", error);
    throw error;
  }
}

// Run the migration
runCustomerOrderMigration()
  .then(() => {
    console.log("Migration completed successfully");
  })
  .catch((error) => {
    console.error("Migration failed:", error);
  });
