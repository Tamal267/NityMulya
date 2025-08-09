import sql from '../db';

export const signupCustomer = async (c: any) => {
    try {
        const {full_name, email, password, contact, address, longitude, latitude} = await c.req.json();

        const customer = await sql`
            INSERT INTO customers (full_name, email, password, contact, address, longitude, latitude)
            VALUES (${full_name}, ${email}, ${password}, ${contact}, ${address}, ${longitude}, ${latitude})
            RETURNING *;
        `;

        return c.json({ success: true, customer });
    } catch (error) {
        console.error('Error signing up customer:', error);
        return c.json({ success: false, message: 'Failed to sign up customer' }, 400);
    }
}