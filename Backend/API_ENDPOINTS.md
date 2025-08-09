# NityMulya Backend API Endpoints

## Authentication Endpoints

### Customer Signup
- **URL**: `POST /signup_customer`
- **Content-Type**: `application/json`
- **Body**:
  ```json
  {
    "full_name": "string (required)",
    "email": "string (required)",
    "password": "string (required)",
    "contact": "string (required)"
  }
  ```
- **Success Response**: 
  ```json
  {
    "success": true,
    "message": "Customer registered successfully",
    "customer": {
      "id": "uuid",
      "full_name": "string",
      "email": "string",
      "contact": "string",
      "address": "string",
      "longitude": "string",
      "latitude": "string",
      "created_at": "timestamp"
    }
  }
  ```

### Wholesaler Signup
- **URL**: `POST /signup_wholesaler`
- **Content-Type**: `application/json`
- **Body**:
  ```json
  {
    "full_name": "string (required)",
    "email": "string (required)",
    "password": "string (required)",
    "address": "string (required)",
    "contact": "string (required)"
  }
  ```
- **Success Response**:
  ```json
  {
    "success": true,
    "message": "Wholesaler registered successfully",
    "wholesaler": {
      "id": "uuid",
      "full_name": "string",
      "email": "string",
      "contact": "string",
      "address": "string",
      "longitude": "string",
      "latitude": "string",
      "created_at": "timestamp"
    }
  }
  ```

### Shop Owner Signup
- **URL**: `POST /signup_shop_owner`
- **Content-Type**: `application/json`
- **Body**:
  ```json
  {
    "full_name": "string (required)",
    "email": "string (required)",
    "password": "string (required)",
    "address": "string (required)",
    "contact": "string (required)"
  }
  ```
- **Success Response**:
  ```json
  {
    "success": true,
    "message": "Shop owner registered successfully",
    "shop_owner": {
      "id": "uuid",
      "full_name": "string",
      "email": "string",
      "contact": "string",
      "address": "string",
      "longitude": "string",
      "latitude": "string",
      "shop_description": "string",
      "created_at": "timestamp"
    }
  }
  ```

### Customer Login
- **URL**: `POST /login_customer`
- **Content-Type**: `application/json`
- **Body**:
  ```json
  {
    "email": "string (required)",
    "password": "string (required)"
  }
  ```
- **Success Response**:
  ```json
  {
    "success": true,
    "message": "Login successful",
    "customer": {
      "id": "uuid",
      "full_name": "string",
      "email": "string",
      "contact": "string",
      "address": "string",
      "longitude": "string",
      "latitude": "string",
      "created_at": "timestamp"
    },
    "role": "customer"
  }
  ```

### Wholesaler Login
- **URL**: `POST /login_wholesaler`
- **Content-Type**: `application/json`
- **Body**:
  ```json
  {
    "email": "string (required)",
    "password": "string (required)"
  }
  ```
- **Success Response**:
  ```json
  {
    "success": true,
    "message": "Login successful",
    "wholesaler": {
      "id": "uuid",
      "full_name": "string",
      "email": "string",
      "contact": "string",
      "address": "string",
      "longitude": "string",
      "latitude": "string",
      "created_at": "timestamp"
    },
    "role": "wholesaler"
  }
  ```

### Shop Owner Login
- **URL**: `POST /login_shop_owner`
- **Content-Type**: `application/json`
- **Body**:
  ```json
  {
    "email": "string (required)",
    "password": "string (required)"
  }
  ```
- **Success Response**:
  ```json
  {
    "success": true,
    "message": "Login successful",
    "shop_owner": {
      "id": "uuid",
      "full_name": "string",
      "email": "string",
      "contact": "string",
      "address": "string",
      "longitude": "string",
      "latitude": "string",
      "shop_description": "string",
      "created_at": "timestamp"
    },
    "role": "shop_owner"
  }
  ```

### Generic Login
- **URL**: `POST /login`
- **Content-Type**: `application/json`
- **Body**:
  ```json
  {
    "email": "string (required)",
    "password": "string (required)",
    "role": "string (optional: customer|wholesaler|shop_owner)"
  }
  ```
- **Success Response**: Returns the same as the specific login endpoints based on the user's role

## Other Endpoints

### Get Categories
- **URL**: `GET /get_categories`

### Get Price
- **URL**: `GET /get_price`

### Get Sheet URL
- **URL**: `GET /get_url`

### Get Price List
- **URL**: `GET /get_pricelist`

## Error Responses

All endpoints can return error responses in the following format:
```json
{
  "success": false,
  "error": "Error message description"
}
```

Common errors:
- Missing required fields
- Email already exists
- Invalid email format
- Database connection errors

## Server Information

- **Host**: `localhost`
- **Port**: `5000`
- **Base URL**: `http://localhost:5000`

## Example Usage

```bash
# Customer Signup
curl -X POST http://localhost:5000/signup_customer \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "contact": "1234567890"
  }'

# Wholesaler Signup
curl -X POST http://localhost:5000/signup_wholesaler \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "ABC Wholesale Corp",
    "email": "contact@abcwholesale.com",
    "password": "securepass",
    "address": "123 Business St, City, State",
    "contact": "9876543210"
  }'

# Shop Owner Signup
curl -X POST http://localhost:5000/signup_shop_owner \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Jane Shop Owner",
    "email": "jane@myshop.com",
    "password": "shoppass123",
    "address": "456 Shop Ave, City, State",
    "contact": "5555555555"
  }'

# Customer Login
curl -X POST http://localhost:5000/login_customer \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'

# Wholesaler Login
curl -X POST http://localhost:5000/login_wholesaler \
  -H "Content-Type: application/json" \
  -d '{
    "email": "contact@abcwholesale.com",
    "password": "securepass"
  }'

# Shop Owner Login
curl -X POST http://localhost:5000/login_shop_owner \
  -H "Content-Type: application/json" \
  -d '{
    "email": "jane@myshop.com",
    "password": "shoppass123"
  }'

# Generic Login with Role
curl -X POST http://localhost:5000/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123",
    "role": "customer"
  }'
```
