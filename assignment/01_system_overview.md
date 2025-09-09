# 1. System Overview

## 1.1 Purpose

NityMulya enables transparent local commerce and consumer protection through multi-role interaction (Customer, Shop Owner, Wholesaler, DNCRP Admin).

## 1.2 Primary User Groups

- Customers: Price lookup, shop discovery, complaints, reviews, favorites.
- Shop Owners: Inventory + order management, communication with suppliers.
- Wholesalers: Supply management, offers, restock negotiation.
- DNCRP Admin: Oversight of complaints (regulatory demo).

## 1.3 Core Functional Domains

| Domain            | Key Functions                                           |
| ----------------- | ------------------------------------------------------- |
| Pricing           | Daily pricelist, (planned) government baseline tagging  |
| Inventory         | CRUD for products (shop & wholesale) + low stock alerts |
| Orders            | Customer orders; owner fulfillment lifecycle            |
| Complaints        | Submission with evidence (media pipeline pending)       |
| Reviews           | Product + shop ratings, aggregation (no media yet)      |
| Chat              | Real-time style supply chain messaging (polling-based)  |
| Geolocation       | Nearby verified shops display                           |
| Rewards (Planned) | VAT honesty incentive logic                             |

## 1.4 Technology Stack

- Frontend: Flutter (Dart), SharedPreferences, Geolocator, HTTP.
- Backend: Bun + TypeScript (Hono), Postgres, JWT.
- Data: Mix of role-specific tables + unified user schema variant in SQL assets.

## 1.5 Key Constraints

- Password hashing absent (risk).
- Large monolithic UI classes impede scalability.
- Media upload server parsing incomplete.
- Route duplication (complaints) & inconsistent naming conventions.

## 1.6 Assumptions for Evaluation

- Evaluated using current branch code (no production telemetry).
- Government price ingestion assumed not fully implemented (future feature).
- Review & complaint volumes moderate (no stress conditions modeled).
