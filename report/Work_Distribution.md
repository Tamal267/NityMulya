# Work Distribution Report - NityMulya Project

## Project Timeline

- **Start Date**: July 12, 2025
- **End Date**: September 12, 2025
- **Duration**: 62 days
- **Total Commits**: 105

## Team Members & Contribution Summary

| Member Name                | Email                                 | Total Commits | Percentage | Primary Focus Areas                                       |
| -------------------------- | ------------------------------------- | ------------- | ---------- | --------------------------------------------------------- |
| **Tamal (Syed Tamal)**     | syedtamal@gmail.com                   | 32            | 30.5%      | Backend Architecture, Authentication, Cross-Role Features |
| **sakifshahrear**          | sakifshahrear@gmail.com               | 32            | 30.5%      | Order System, Inventory Management, Messaging             |
| **NAHIDURZAMAN**           | NAHIDURZAMAN@users.noreply.github.com | 31            | 29.5%      | Complaint System UI, Reviews, Shop Features               |
| **Khadiza Khanum Mithila** | khadizakhanom8833@gmail.com           | 10            | 9.5%       | Complaint Data Models, Admin Tools, Testing               |

## Detailed Work Distribution by Module

### Backend Development

| Component                | Primary Contributor | Secondary Contributor | Key Files                                           |
| ------------------------ | ------------------- | --------------------- | --------------------------------------------------- |
| Core Server & API Routes | Tamal               | sakifshahrear         | `Backend/src/index.ts`, API controllers             |
| Database Schema          | sakifshahrear       | Khadiza               | `customer_order_schema.sql`, complaint tables       |
| Authentication System    | Tamal               | -                     | Auth controllers, JWT middleware                    |
| Controller Logic         | Tamal               | sakifshahrear         | `shopOwnerController.ts`, `wholesalerController.ts` |

### Frontend Development (Flutter)

#### Authentication & Core Navigation

| Feature               | Primary Contributor | Files                                                           |
| --------------------- | ------------------- | --------------------------------------------------------------- |
| Login System          | Tamal               | `lib/screens/auth/login_screen.dart`                            |
| Custom Drawer         | Tamal               | `lib/widgets/custom_drawer.dart`                                |
| Auth Provider         | Tamal               | `lib/providers/auth_provider.dart`                              |
| Network Configuration | Tamal               | `lib/config/api_config.dart`, `lib/network/network_helper.dart` |

#### Customer Features

| Feature                     | Primary Contributor | Secondary Contributor | Key Components                              |
| --------------------------- | ------------------- | --------------------- | ------------------------------------------- |
| Order Placement & Tracking  | Tamal               | sakifshahrear         | `my_orders_screen.dart`, order confirmation |
| Order Status Management     | sakifshahrear       | Tamal                 | Pending, ongoing, cancelled order screens   |
| Complaint Submission        | NAHIDURZAMAN        | Khadiza               | `complaint_screen*.dart` variations         |
| Complaint Form & Validation | Khadiza             | NAHIDURZAMAN          | `complaint_submission_screen.dart`          |

#### Shop Owner Features

| Feature                   | Primary Contributor | Secondary Contributor | Key Components                     |
| ------------------------- | ------------------- | --------------------- | ---------------------------------- |
| Dashboard                 | Tamal               | sakifshahrear         | `dashboard_screen.dart`            |
| Order Management          | sakifshahrear       | Tamal                 | Order confirmation, status updates |
| Inventory Integration     | Tamal               | sakifshahrear         | Inventory API integration          |
| Customer Order Processing | sakifshahrear       | Tamal                 | Customer order handling screens    |

#### Wholesaler Features

| Feature              | Primary Contributor | Secondary Contributor | Key Components                     |
| -------------------- | ------------------- | --------------------- | ---------------------------------- |
| Wholesaler Dashboard | Tamal               | sakifshahrear         | `wholesaler_dashboard_screen.dart` |
| Order Creation       | Tamal               | sakifshahrear         | `add_order_screen.dart`            |
| Chat System          | Tamal               | sakifshahrear         | Wholesaler chat screens            |
| Shop Reviews         | NAHIDURZAMAN        | -                     | `shop_reviews_screen.dart`         |

#### Admin/DNCRP Features

| Feature               | Primary Contributor | Secondary Contributor | Key Components                   |
| --------------------- | ------------------- | --------------------- | -------------------------------- |
| DNCRP Dashboard       | Tamal               | Khadiza               | `dncrp_dashboard_screen.dart`    |
| Complaint Management  | Khadiza             | NAHIDURZAMAN          | Admin complaint list and details |
| Complaint Data Models | Khadiza             | -                     | `lib/models/complaint.dart`      |

### Database & Data Management

| Component         | Primary Contributor | Secondary Contributor | Description                             |
| ----------------- | ------------------- | --------------------- | --------------------------------------- |
| Order Schema      | sakifshahrear       | -                     | Complete order lifecycle schema         |
| Message System    | sakifshahrear       | -                     | Order messaging table structure         |
| Complaint Tables  | Khadiza             | -                     | Complaint data structure and migrations |
| Inventory Testing | sakifshahrear       | Tamal                 | Inventory update and validation scripts |

### Testing & Debugging

| Area                    | Primary Contributor | Focus                                      |
| ----------------------- | ------------------- | ------------------------------------------ |
| Inventory Testing       | sakifshahrear       | 15+ inventory test scripts and diagnostics |
| Order System Testing    | sakifshahrear       | Order flow validation and edge cases       |
| Complaint Testing       | Khadiza             | Cancelled orders and complaint workflow    |
| API Integration Testing | Tamal               | Backend-frontend integration validation    |

## Technical Contribution Details

### Backend Architecture (Tamal - 30.5%)

- **Core Responsibilities**: Server setup, API routing, authentication middleware
- **Major Files**:
  - `Backend/src/index.ts` (main server configuration)
  - `Backend/src/controller/` (multiple controller files)
  - Authentication and role-based access control
- **Integration Work**: Connected frontend Flutter app with backend APIs
- **Cross-cutting Features**: Custom drawer, network helpers, auth provider

### Order & Inventory Systems (sakifshahrear - 30.5%)

- **Core Responsibilities**: Order lifecycle, inventory management, messaging system
- **Major Contributions**:
  - Database schema design for orders and messages
  - 20+ inventory testing and debugging scripts
  - Order status screen variations (pending, ongoing, cancelled)
  - Message system backend and frontend integration
- **Quality Assurance**: Extensive testing suite for inventory updates and order flows

### Complaint & Review Systems (NAHIDURZAMAN - 29.5%)

- **Core Responsibilities**: Customer complaint UI, shop review features
- **Major Contributions**:
  - Multiple iterations of complaint screen designs
  - Shop review functionality for wholesaler module
  - Customer-facing complaint submission flows
- **UI/UX Focus**: Frontend complaint experience and navigation

### Data Models & Admin Tools (Khadiza - 9.5%)

- **Core Responsibilities**: Data structure design, admin interfaces, testing scripts
- **Major Contributions**:
  - Complaint data models and database migrations
  - Admin complaint management screens
  - DNCRP complaint details and listing
  - Order cancellation testing and validation
- **Backend Support**: Database schema creation and migration scripts

## Code Quality & Collaboration Metrics

- **Average Commits per Day**: 1.7 commits/day
- **Peak Development Period**: September 2025 (final integration phase)
- **Code Review Collaboration**: Evidence of cross-member file modifications
- **Testing Coverage**: Comprehensive testing scripts across all major features

## Technical Skills Demonstrated

### Full-Stack Development

- **Tamal**: Backend architecture, Flutter development, API integration
- **sakifshahrear**: Database design, testing automation, order system complexity
- **NAHIDURZAMAN**: Frontend UI/UX, user interaction flows
- **Khadiza**: Data modeling, admin tooling, quality assurance

### Technology Proficiency

- **Backend**: Bun, Hono (TypeScript), PostgreSQL
- **Frontend**: Flutter (Dart), Provider state management
- **Testing**: Custom test scripts, API validation
- **DevOps**: Git collaboration, environment configuration

## Project Impact by Contributor

1. **Tamal**: Enabled multi-role architecture and secure authentication
2. **sakifshahrear**: Built robust order and inventory management foundation
3. **NAHIDURZAMAN**: Created intuitive customer-facing interfaces
4. **Khadiza**: Established data integrity and admin capabilities

## Summary

The NityMulya project demonstrates balanced team collaboration with each member contributing essential components. The work distribution shows complementary skills with backend architecture (Tamal), data systems (sakifshahrear), user interfaces (NAHIDURZAMAN), and data modeling (Khadiza) working together to create a comprehensive multi-stakeholder marketplace platform.

---

**Report Generated**: September 13, 2025  
**Data Source**: Git repository analysis (105 total commits)  
**Analysis Period**: July 12, 2025 - September 12, 2025
