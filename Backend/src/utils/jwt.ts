import * as jwt from 'jsonwebtoken';

// Secret key for JWT (in production, this should be in environment variables)
const JWT_SECRET = process.env.JWT_SECRET || 'your-super-secret-key-that-should-be-in-env';

export interface TokenPayload {
    userId: number;
    email: string;
    role: 'customer' | 'wholesaler' | 'shop_owner';
}

export const generateToken = (payload: TokenPayload): string => {
    return jwt.sign(payload, JWT_SECRET, { 
        expiresIn: '7d' // Token expires in 7 days
    });
};

export const verifyToken = (token: string): TokenPayload | null => {
    try {
        const decoded = jwt.verify(token, JWT_SECRET) as TokenPayload;
        return decoded;
    } catch (error) {
        console.error('Token verification failed:', error);
        return null;
    }
};

export const createAuthMiddleware = () => {
    return async (c: any, next: any) => {
        const authHeader = c.req.header('Authorization');
        
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return c.json({ 
                success: false, 
                error: 'Unauthorized - No token provided' 
            }, 401);
        }

        const token = authHeader.substring(7); // Remove 'Bearer ' prefix
        const decoded = verifyToken(token);

        if (!decoded) {
            return c.json({ 
                success: false, 
                error: 'Unauthorized - Invalid token' 
            }, 401);
        }

        // Add user info to context for use in route handlers
        c.set('user', decoded);
        await next();
    };
};

// Middleware to check if user has specific role
export const requireRole = (role: string) => {
    return async (c: any, next: any) => {
        const user = c.get('user');
        
        if (!user || user.role !== role) {
            return c.json({ 
                success: false, 
                error: 'Forbidden - Insufficient permissions' 
            }, 403);
        }

        await next();
    };
};
