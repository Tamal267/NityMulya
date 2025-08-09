import sql from '../db';

// Simple password hashing function (in production, use bcrypt)
const hashPassword = async (password: string): Promise<string> => {
    // For now, we'll store plain text passwords
    // In production, you should use bcrypt or similar
    return password;
};

// Simple password verification function (in production, use bcrypt)
const verifyPassword = async (plainPassword: string, hashedPassword: string): Promise<boolean> => {
    // For now, we're storing plain text passwords, so direct comparison
    // In production, you should use bcrypt.compare()
    return plainPassword === hashedPassword;
};

export const signupCustomer = async (c: any) => {
    try {
        const {full_name, email, password, contact, address, longitude, latitude} = await c.req.json();

        // Validate required fields
        if (!full_name || !email || !password || !contact) {
            return c.json({ 
                success: false, 
                error: 'Missing required fields: full_name, email, password, contact' 
            }, 400);
        }

        // Hash password
        const hashedPassword = await hashPassword(password);

        const customer = await sql`
            INSERT INTO customers (full_name, email, password, contact, address, longitude, latitude)
            VALUES (${full_name}, ${email}, ${hashedPassword}, ${contact}, ${address || ''}, ${longitude || 0}, ${latitude || 0})
            RETURNING id, full_name, email, contact, address, longitude, latitude, created_at;
        `;

        return c.json({ 
            success: true, 
            message: 'Customer registered successfully',
            customer: customer[0] 
        });
    } catch (error: any) {
        console.error('Error signing up customer:', error);
        
        // Handle unique constraint violation (duplicate email)
        if (error.code === '23505') {
            return c.json({ 
                success: false, 
                error: 'Email already exists. Please use a different email address.' 
            }, 409);
        }
        
        return c.json({ 
            success: false, 
            error: 'Failed to register customer. Please try again.' 
        }, 500);
    }
}

export const signupWholesaler = async (c: any) => {
    try {
        const {full_name, email, password, contact, address, longitude, latitude} = await c.req.json();

        // Validate required fields
        if (!full_name || !email || !password || !contact) {
            return c.json({ 
                success: false, 
                error: 'Missing required fields: full_name, email, password, contact' 
            }, 400);
        }

        // Hash password
        const hashedPassword = await hashPassword(password);

        const wholesaler = await sql`
            INSERT INTO wholesalers (full_name, email, password, contact, address, longitude, latitude)
            VALUES (${full_name}, ${email}, ${hashedPassword}, ${contact}, ${address || ''}, ${longitude || 0}, ${latitude || 0})
            RETURNING id, full_name, email, contact, address, longitude, latitude, created_at;
        `;

        return c.json({ 
            success: true, 
            message: 'Wholesaler registered successfully',
            wholesaler: wholesaler[0] 
        });
    } catch (error: any) {
        console.error('Error signing up wholesaler:', error);
        
        // Handle unique constraint violation (duplicate email)
        if (error.code === '23505') {
            return c.json({ 
                success: false, 
                error: 'Email already exists. Please use a different email address.' 
            }, 409);
        }
        
        return c.json({ 
            success: false, 
            error: 'Failed to register wholesaler. Please try again.' 
        }, 500);
    }
}

export const signupShopOwner = async (c: any) => {
    try {
        const {full_name, email, password, contact, address, longitude, latitude, shop_description} = await c.req.json();

        // Validate required fields
        if (!full_name || !email || !password || !contact) {
            return c.json({ 
                success: false, 
                error: 'Missing required fields: full_name, email, password, contact' 
            }, 400);
        }

        // Hash password
        const hashedPassword = await hashPassword(password);

        const shopOwner = await sql`
            INSERT INTO shop_owners (full_name, email, password, contact, address, longitude, latitude, shop_description)
            VALUES (${full_name}, ${email}, ${hashedPassword}, ${contact}, ${address || ''}, ${longitude || 0}, ${latitude || 0}, ${shop_description || ''})
            RETURNING id, full_name, email, contact, address, longitude, latitude, shop_description, created_at;
        `;

        return c.json({ 
            success: true, 
            message: 'Shop owner registered successfully',
            shop_owner: shopOwner[0] 
        });
    } catch (error: any) {
        console.error('Error signing up shop owner:', error);
        
        // Handle unique constraint violation (duplicate email)
        if (error.code === '23505') {
            return c.json({ 
                success: false, 
                error: 'Email already exists. Please use a different email address.' 
            }, 409);
        }
        
        return c.json({ 
            success: false, 
            error: 'Failed to register shop owner. Please try again.' 
        }, 500);
    }
};

// Customer login function
export const loginCustomer = async (c: any) => {
    try {
        const { email, password } = await c.req.json();

        // Validate required fields
        if (!email || !password) {
            return c.json({ 
                success: false, 
                error: 'Missing required fields: email, password' 
            }, 400);
        }

        // Find customer by email
        const customer = await sql`
            SELECT id, full_name, email, contact, address, longitude, latitude, password, created_at
            FROM customers 
            WHERE email = ${email}
        `;

        if (customer.length === 0) {
            return c.json({ 
                success: false, 
                error: 'Invalid email or password' 
            }, 401);
        }

        // Verify password
        const isValidPassword = await verifyPassword(password, customer[0].password);
        if (!isValidPassword) {
            return c.json({ 
                success: false, 
                error: 'Invalid email or password' 
            }, 401);
        }

        // Remove password from response
        const { password: _, ...customerData } = customer[0];

        return c.json({ 
            success: true, 
            message: 'Login successful',
            customer: customerData,
            role: 'customer'
        });
    } catch (error: any) {
        console.error('Error logging in customer:', error);
        
        return c.json({ 
            success: false, 
            error: 'Login failed. Please try again.' 
        }, 500);
    }
};

// Wholesaler login function
export const loginWholesaler = async (c: any) => {
    try {
        const { email, password } = await c.req.json();

        // Validate required fields
        if (!email || !password) {
            return c.json({ 
                success: false, 
                error: 'Missing required fields: email, password' 
            }, 400);
        }

        // Find wholesaler by email
        const wholesaler = await sql`
            SELECT id, full_name, email, contact, address, longitude, latitude, password, created_at
            FROM wholesalers 
            WHERE email = ${email}
        `;

        if (wholesaler.length === 0) {
            return c.json({ 
                success: false, 
                error: 'Invalid email or password' 
            }, 401);
        }

        // Verify password
        const isValidPassword = await verifyPassword(password, wholesaler[0].password);
        if (!isValidPassword) {
            return c.json({ 
                success: false, 
                error: 'Invalid email or password' 
            }, 401);
        }

        // Remove password from response
        const { password: _, ...wholesalerData } = wholesaler[0];

        return c.json({ 
            success: true, 
            message: 'Login successful',
            wholesaler: wholesalerData,
            role: 'wholesaler'
        });
    } catch (error: any) {
        console.error('Error logging in wholesaler:', error);
        
        return c.json({ 
            success: false, 
            error: 'Login failed. Please try again.' 
        }, 500);
    }
};

// Shop owner login function
export const loginShopOwner = async (c: any) => {
    try {
        const { email, password } = await c.req.json();

        // Validate required fields
        if (!email || !password) {
            return c.json({ 
                success: false, 
                error: 'Missing required fields: email, password' 
            }, 400);
        }

        // Find shop owner by email
        const shopOwner = await sql`
            SELECT id, full_name, email, contact, address, longitude, latitude, shop_description, password, created_at
            FROM shop_owners 
            WHERE email = ${email}
        `;

        if (shopOwner.length === 0) {
            return c.json({ 
                success: false, 
                error: 'Invalid email or password' 
            }, 401);
        }

        // Verify password
        const isValidPassword = await verifyPassword(password, shopOwner[0].password);
        if (!isValidPassword) {
            return c.json({ 
                success: false, 
                error: 'Invalid email or password' 
            }, 401);
        }

        // Remove password from response
        const { password: _, ...shopOwnerData } = shopOwner[0];

        return c.json({ 
            success: true, 
            message: 'Login successful',
            shop_owner: shopOwnerData,
            role: 'shop_owner'
        });
    } catch (error: any) {
        console.error('Error logging in shop owner:', error);
        
        return c.json({ 
            success: false, 
            error: 'Login failed. Please try again.' 
        }, 500);
    }
};

// Generic login function that determines user type and calls appropriate login
export const login = async (c: any) => {
    try {
        const { email, password, role } = await c.req.json();

        // Validate required fields
        if (!email || !password) {
            return c.json({ 
                success: false, 
                error: 'Missing required fields: email, password' 
            }, 400);
        }

        // If role is specified, use specific login function
        if (role) {
            switch (role.toLowerCase()) {
                case 'customer':
                    return await loginCustomer(c);
                case 'wholesaler':
                    return await loginWholesaler(c);
                case 'shop_owner':
                case 'shop owner':
                    return await loginShopOwner(c);
                default:
                    return c.json({ 
                        success: false, 
                        error: 'Invalid role specified' 
                    }, 400);
            }
        }

        // If no role specified, try to find user in all tables
        // Check customers first
        const customer = await sql`
            SELECT id, full_name, email, contact, address, longitude, latitude, password, created_at
            FROM customers 
            WHERE email = ${email}
        `;

        if (customer.length > 0) {
            const isValidPassword = await verifyPassword(password, customer[0].password);
            if (isValidPassword) {
                const { password: _, ...customerData } = customer[0];
                return c.json({ 
                    success: true, 
                    message: 'Login successful',
                    customer: customerData,
                    role: 'customer'
                });
            }
        }

        // Check wholesalers
        const wholesaler = await sql`
            SELECT id, full_name, email, contact, address, longitude, latitude, password, created_at
            FROM wholesalers 
            WHERE email = ${email}
        `;

        if (wholesaler.length > 0) {
            const isValidPassword = await verifyPassword(password, wholesaler[0].password);
            if (isValidPassword) {
                const { password: _, ...wholesalerData } = wholesaler[0];
                return c.json({ 
                    success: true, 
                    message: 'Login successful',
                    wholesaler: wholesalerData,
                    role: 'wholesaler'
                });
            }
        }

        // Check shop owners
        const shopOwner = await sql`
            SELECT id, full_name, email, contact, address, longitude, latitude, shop_description, password, created_at
            FROM shop_owners 
            WHERE email = ${email}
        `;

        if (shopOwner.length > 0) {
            const isValidPassword = await verifyPassword(password, shopOwner[0].password);
            if (isValidPassword) {
                const { password: _, ...shopOwnerData } = shopOwner[0];
                return c.json({ 
                    success: true, 
                    message: 'Login successful',
                    shop_owner: shopOwnerData,
                    role: 'shop_owner'
                });
            }
        }

        // No user found with valid credentials
        return c.json({ 
            success: false, 
            error: 'Invalid email or password' 
        }, 401);

    } catch (error: any) {
        console.error('Error during login:', error);
        
        return c.json({ 
            success: false, 
            error: 'Login failed. Please try again.' 
        }, 500);
    }
};