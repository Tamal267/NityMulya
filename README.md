# NityMulya (নিত্য মূল্য) - Wholesale-Retail Market Transparency Platform

<div align="center">
  <img src="assets/image/logo.jpeg" alt="NityMulya Logo" width="120" height="120">
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.32.6-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.8.1-0175C2?logo=dart&logoColor=white)](https://dart.dev)
  [![Node.js](https://img.shields.io/badge/Node.js-Bun-339933?logo=node.js&logoColor=white)](https://nodejs.org)
  [![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-336791?logo=postgresql&logoColor=white)](https://postgresql.org)
  [![Hono](https://img.shields.io/badge/Hono-API_Framework-E36002?logo=hono&logoColor=white)](https://hono.dev)
</div>

## 📖 Overview

**NityMulya** is a comprehensive market transparency and commerce platform designed to bridge the gap between wholesalers, retailers, and customers in Bangladesh. The platform ensures fair pricing, transparent supply chains, and effective market oversight through a multi-stakeholder approach.

### 🎯 Mission
To create a transparent, efficient, and fair marketplace that connects wholesale suppliers with retail shops and end customers, while providing regulatory oversight through DNCRP (Directorate of National Consumer Rights Protection) integration.

## ✨ Key Features

### 🔐 Multi-Role Authentication System
- **Customers**: Browse products, place orders, track status, submit complaints
- **Shop Owners**: Manage inventory, process orders, communicate with customers
- **Wholesalers**: Supply products, manage offers, track downstream orders
- **DNCRP Admin**: Monitor complaints, ensure market compliance, generate reports

### 🛒 Customer Experience
- **Product Browsing**: Comprehensive product catalog with price comparison
- **Order Management**: Place orders, track status, view history
- **Shop Discovery**: Find nearby shops using geolocation and mapping
- **Review System**: Rate and review products and shops
- **Price Alerts**: Get notified about price changes
- **Messaging**: Direct communication with shop owners for order inquiries

### 🏪 Shop Owner Dashboard
- **Inventory Management**: Add, update, and track product stock levels
- **Order Processing**: View customer orders, confirm/reject, update status
- **Low Stock Alerts**: Automated notifications for inventory replenishment
- **Customer Communication**: Chat system for order-related queries
- **Analytics**: Sales performance and order statistics

### 🏭 Wholesaler Platform
- **Product Supply**: Manage wholesale inventory and pricing
- **Shop Network**: Connect with multiple retail shops
- **Offer Management**: Create special deals and bulk pricing
- **Order Tracking**: Monitor downstream order flow
- **Business Analytics**: Track supply chain performance

### 📋 Complaint & Oversight System
- **Public Complaints**: Citizens can submit market-related complaints
- **DNCRP Dashboard**: Administrative oversight of market activities
- **Status Tracking**: Real-time complaint resolution progress
- **Regulatory Tools**: Market monitoring and compliance enforcement

## 🏗️ Technical Architecture

### Frontend (Flutter)
```
lib/
├── main.dart                 # App entry point with routing
├── config/
│   ├── api_config.dart      # API configuration management
│   └── web_config.dart      # Web-specific configurations
├── providers/
│   └── auth_provider.dart   # Authentication state management
├── screens/
│   ├── auth/                # Login, signup, authentication
│   ├── customers/           # Customer-specific screens
│   ├── shop_owner/          # Shop owner dashboard and tools
│   ├── wholesaler/          # Wholesaler management interface
│   └── dncrp/              # DNCRP admin dashboard
├── services/
│   ├── customer_api.dart    # Customer API integration
│   ├── shop_owner_api.dart  # Shop owner API services
│   ├── wholesaler_api.dart  # Wholesaler API services
│   └── message_api_service.dart # Messaging system
└── network/
    └── network_helper.dart  # HTTP client with authentication
```

### Backend (Node.js + Hono)
```
Backend/
├── src/
│   ├── index.ts             # Server entry point and routing
│   ├── controller/
│   │   ├── authController.ts     # Authentication logic
│   │   ├── apiController.ts      # Core API endpoints
│   │   ├── customerController.ts # Customer operations
│   │   ├── shopOwnerController.ts # Shop owner operations
│   │   └── wholesalerController.ts # Wholesaler operations
│   ├── utils/
│   │   ├── jwt.ts           # JWT authentication middleware
│   │   └── database.ts      # PostgreSQL connection
│   └── types/
│       └── auth.ts          # TypeScript type definitions
├── package.json
└── .env                     # Environment configuration
```

### Database Schema (PostgreSQL)
- **users**: Multi-role user authentication
- **customers**: Customer profile information
- **shop_owners**: Shop owner details and shop information
- **wholesalers**: Wholesaler company information
- **products**: Product catalog with categories
- **customer_orders**: Order management and tracking
- **order_messages**: Order-specific communication
- **complaints**: Public and customer complaint system
- **inventory**: Stock management for shops and wholesalers

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: 3.32.6 or higher
- **Dart SDK**: 3.8.1 or higher
- **Bun Runtime**: Latest version
- **PostgreSQL**: 12 or higher
- **Android Studio/VS Code**: For development

### 📱 Frontend Setup (Flutter)

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd NityMulya
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   Create `.env.local` file in the root directory:
   ```env
   API_BASE_URL=http://localhost:5000
   ENABLE_LOGGING=true
   ```

4. **Run the application**
   ```bash
   # For Android
   flutter run
   
   # For iOS
   flutter run -d ios
   
   # For Web
   flutter run -d web-server --web-port 3000
   ```

### 🖥️ Backend Setup (Node.js)

1. **Navigate to backend directory**
   ```bash
   cd Backend
   ```

2. **Install dependencies**
   ```bash
   bun install
   ```

3. **Configure environment variables**
   Create `.env` file:
   ```env
   # Database Configuration
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=nitymulya_db
   DB_USER=your_username
   DB_PASSWORD=your_password
   
   # JWT Configuration
   JWT_SECRET=your-super-secret-jwt-key-here
   JWT_EXPIRES_IN=7d
   
   # Server Configuration
   PORT=5000
   NODE_ENV=development
   
   # CORS Configuration
   ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
   ```

4. **Set up PostgreSQL database**
   ```sql
   CREATE DATABASE nitymulya_db;
   -- Run migration scripts to create tables
   ```

5. **Start the development server**
   ```bash
   bun run dev
   ```

   The server will start on `http://localhost:5000`

### 🗄️ Database Setup

1. **Create PostgreSQL database**
   ```sql
   CREATE DATABASE nitymulya_db;
   \c nitymulya_db;
   ```

2. **Run table creation scripts**
   Execute the SQL schema files in order:
   - Create users and role-specific tables
   - Create product and category tables
   - Create order and messaging tables
   - Create complaint management tables

3. **Seed initial data** (optional)
   ```bash
   # Run API endpoint to initialize sample data
   curl -X POST http://localhost:5000/initialize_sample_data
   ```

## 📚 API Documentation

### Authentication Endpoints
```http
POST /login_customer          # Customer login
POST /login_shop_owner        # Shop owner login
POST /login_wholesaler        # Wholesaler login
POST /signup_customer         # Customer registration
POST /signup_shop_owner       # Shop owner registration
POST /signup_wholesaler       # Wholesaler registration
```

### Customer Endpoints (Protected)
```http
GET  /customer/orders         # Get customer orders
POST /customer/orders         # Create new order
GET  /customer/orders/:id     # Get specific order
POST /customer/orders/cancel  # Cancel order
POST /customer/complaints     # Submit complaint
```

### Shop Owner Endpoints (Protected)
```http
GET  /shop-owner/dashboard         # Dashboard data
GET  /shop-owner/inventory         # Inventory management
GET  /shop-owner/customer-orders   # Customer orders
PUT  /shop-owner/customer-orders/status # Update order status
GET  /shop-owner/low-stock         # Low stock alerts
```

### Wholesaler Endpoints (Protected)
```http
GET  /wholesaler/dashboard    # Wholesaler dashboard
GET  /wholesaler/inventory    # Manage wholesale inventory
GET  /wholesaler/orders       # Downstream orders
POST /wholesaler/offers       # Create offers
```

### Public Endpoints
```http
GET  /get_shops              # Get all shops
GET  /get_categories         # Product categories
GET  /get_price_history/:product # Price history
POST /api/complaints/public  # Public complaint submission
```

## 🔧 Configuration

### Flutter Configuration
- **API Base URL**: Configure in `.env.local`
- **Platform-specific settings**: Handle web vs mobile differences
- **Secure storage**: JWT tokens stored securely per platform

### Backend Configuration
- **Database connection**: PostgreSQL with connection pooling
- **JWT authentication**: Configurable expiration and secret
- **CORS**: Multi-origin support for web and mobile
- **Logging**: Comprehensive request/response logging

## 🧪 Testing

### Flutter Tests
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

### Backend Tests
```bash
# Run API tests
bun test

# Test specific endpoints
curl -X POST http://localhost:5000/test
```

### Manual Testing Scripts
- `test_customer_order_flow_complete.dart`: End-to-end order testing
- `test_auth_debug.dart`: Authentication flow validation
- `test_order_auth.dart`: Order authentication testing

## 📱 Supported Platforms

- **Android**: Full feature support with adaptive icons
- **iOS**: Complete iOS compatibility
- **Web**: Responsive web application
- **Windows/macOS/Linux**: Desktop support available

## 🔒 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Role-based Access Control**: Granular permission system
- **Secure Storage**: Platform-specific secure token storage
- **Input Validation**: Comprehensive input sanitization
- **CORS Protection**: Configured cross-origin security

## 🌐 Localization

- **Bengali (bn)**: Primary language support
- **English (en)**: Secondary language
- **RTL Support**: Right-to-left text rendering
- **Cultural Adaptation**: Bangladesh-specific features

## 📈 Performance & Monitoring

- **Caching**: Strategic caching for improved performance
- **Error Tracking**: Comprehensive error logging
- **Analytics**: User behavior and system performance tracking
- **Monitoring**: Real-time system health monitoring

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart style guidelines
- Write comprehensive tests for new features
- Update documentation for API changes
- Ensure cross-platform compatibility

## 🙏 Acknowledgments

- **Flutter Team**: For the excellent cross-platform framework
- **Hono**: For the lightweight and fast API framework
- **PostgreSQL**: For robust database capabilities
- **Open Source Community**: For various packages and libraries used

---

<div align="center">
  <p><strong>Built with ❤️ for transparent and fair markets in Bangladesh</strong></p>
</div>
