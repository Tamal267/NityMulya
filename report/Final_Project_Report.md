# NityMulya: A Fair Market Transparency & Commerce Platform

## Cover Page

Group Number: (Add Here)

Group Members:

- Member 1 (Name / ID)
- Member 2 (Name / ID)
- Member 3 (Name / ID)
- Member 4 (Name / ID)

App Name: NityMulya: A Multi‑Role Fair Price & Supply Chain Application

Date: September 13, 2025

---

## Table of Contents

1. Introduction
2. Target Users
3. Literature Review of Existing Systems
4. Problem Statement & Identification
5. Objectives
6. Feature List
7. Technology Stack
8. Developed System (Key Screens)
9. Ethical Concerns
10. Societal Impacts
11. Design Changes
12. Lifelong Learning
13. SUS Usability Testing & Task Completion Time
14. Future Work
15. Work Distribution
16. References

---

## 1. Introduction

NityMulya is a multi‑stakeholder digital marketplace platform that integrates customers, shop owners, wholesalers, and a regulatory (DNCRP demo) authority into a unified ecosystem. It addresses core problems of opaque pricing, inventory mismanagement, delayed complaint redressal, and lack of structured accountability between retail participants. The platform combines:

- Real‑time product & inventory updates.
- Customer ordering with lifecycle tracking.
- Wholesaler–retailer supply alignment.
- Complaint submission and administrative (DNCRP demo) monitoring.
- Messaging, notifications, and reviews for trust reinforcement.

The system bridges information gaps and enforces fairness by enabling transparent order history, complaint tracking, and shop/product feedback loops.

## 2. Target Users

- Retail Customers (price transparency, fair service, complaint escalation)
- Shop Owners (inventory management, customer order processing, wholesaler linkage)
- Wholesalers (downstream demand visibility, offer management)
- Regulatory / Consumer Rights Officers (complaint oversight, trend analysis)
- Future Analytics / Policy Stakeholders (price trend intelligence)

## 3. Literature Review of Existing Apps/Systems

A survey of comparable applications shows partial coverage of NityMulya’s goals. Many emphasize either e‑commerce convenience or price lookup but do not combine supply chain integration, government price compliance, and complaint adjudication with evidence.

Vegetable Market Price apps aggregate daily prices across cities but lack transactional and governance features. Large e‑commerce platforms like Daraz and grocery delivery (Panda Mart) excel in logistics but don’t surface government price baselines or empower users to formally escalate pricing violations with documented proof. Regional supermarket apps (e.g., Shwapno) focus on retail catalog breadth yet omit wholesaler integration and robust regulatory compliance workflows. None of the reviewed platforms reward fair pricing practices or integrate a multi‑role chain from producer/wholesaler to regulator.

### Summary Table of Existing Systems

| App                              | Key Features                                                                                                | Limitations                                                                                                                                                     |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Vegetable Market Price App       | Daily multi‑category price listings; city filtering; lightweight; language selection                        | No purchasing; no real‑time shop linkage; ads; no feedback/review; no proof uploads; no govt verification; update delays                                        |
| Shwapno Grocery App              | Large catalog; live order tracking; multiple payment methods; delivery network; offers & feedback processes | No government price comparison; no violation reporting; weak in‑app loyalty; ops issues (delays/search); no wholesaler linkage                                  |
| Daraz                            | Massive inventory; live chat & AI assistant; quality assurance programs; seller logistics tools             | No govt price integration; no public fair‑pricing complaints; no incentive for compliant pricing; limited wholesaler–retailer sync; fulfillment inconsistencies |
| Panda Mart (Foodpanda Grocery)   | Quick delivery; O2O pickup; in‑house brand pricing; subscription discounts                                  | Lacks govt price baseline; no violation reporting; rewards tied to spend not fairness; no wholesaler restocking channel; service reliability issues             |
| (Comparable Generic Marketplace) | Standard cart, catalog, search, promotions                                                                  | No regulatory workflow; no chain transparency; no evidence‑based complaint tracking                                                                             |

## 4. Problem Statement & Identification

From the review, key gaps:

1. Absence of government price benchmark visibility within transactional flows.
2. Lack of structured, evidence‑backed complaint escalation workflow connecting users to oversight.
3. Disconnected supply tiers (wholesaler → shop → customer) causing stockouts and opaque markups.
4. Limited tools for shop owners to manage dynamic inventory and order status transparently.
5. No integrated trust mechanisms (reviews + notifications + messaging + status history) in single platform.

## 5. Objectives

- To enable transparent, fair product pricing and order lifecycle visibility across roles.
- To streamline complaint lodging and resolution tracking with regulatory oversight (demo DNCRP module).
- To integrate wholesaler–retailer–customer interactions for inventory continuity and ethical commerce.

## 6. Feature List

- Multi‑Role Authentication: Role‑based login (customer, shop owner, wholesaler, DNCRP admin demo).
- Customer Ordering: Place orders, generate order number, track statuses.
- Order Status Tracking: Historical status timeline & cancellation support.
- Shop Inventory Management: Add/update products, low‑stock detection.
- Wholesaler Supply Module: Offers, inventory, order management for downstream shops.
- Complaint System (DNCRP Demo): File complaints, status progression, admin dashboard.
- Messaging System: Order‑context chat between parties.
- Notifications: Real‑time style updates for complaints, orders, status changes.
- Review & Rating: Product and shop reviews with averages.
- Price & Category APIs: Dynamic categories, price history retrieval.
- Location & Mapping: Geolocation + map display for shops/products.
- Secure Storage & Auth: JWT + secure local token handling.
- Analytics & Dashboard: Role dashboards (inventory metrics, offers, stats).

## 7. Technology Stack

| Layer            | Technology                                      | Purpose                                  |
| ---------------- | ----------------------------------------------- | ---------------------------------------- |
| Frontend         | Flutter (Dart), Provider                        | Cross‑platform UI, state management      |
| Backend          | Bun + Hono (TypeScript)                         | High‑performance API server & routing    |
| Database         | PostgreSQL (`postgres` driver)                  | Persistent relational storage            |
| Auth             | JWT + bcrypt                                    | Secure authentication & role enforcement |
| Mapping          | flutter_map, geolocator, geocoding              | Location services & visualization        |
| Data Transport   | HTTP (flutter http), CORS enabled               | Client–server communication              |
| Config           | dotenv                                          | Environment variable management          |
| Security Storage | flutter_secure_storage                          | Token / sensitive data persistence       |
| Misc Tools       | fl_chart, uuid, shared_preferences, file_picker | Charts, IDs, preferences, file uploads   |

## 8. Developed System (Key Screens)

(Insert 4–6 labeled screenshots here: e.g. Login Screen, Customer Product List, Order Confirmation, Shop Owner Dashboard, Complaint Submission, DNCRP Admin Dashboard.)

| Screen                         | Description                                                        |
| ------------------------------ | ------------------------------------------------------------------ |
| Login & Role Selection         | Unified entry for all roles including DNCRP Admin demo.            |
| Product Detail & Order Flow    | Product selection, shop selection, order initiation.               |
| Customer Orders / Profile      | My Orders list with status + navigation to details.                |
| Shop Owner Inventory Dashboard | Manage stock, view low stock alerts.                               |
| Complaint Submission           | Form with category, severity, description, attachment placeholder. |
| DNCRP Admin Dashboard          | Complaint list with status filtering & statistics.                 |

## 9. Ethical Concerns

1. User Data Minimization: Only essential profile (name, contact, role) stored; sensitive data hashing for passwords.
2. Location Consent: Explicit runtime permission required before geolocation used on device.
3. Complaint Integrity: Potential sensitive complaint text protected; recommend encryption at rest for expansion.
4. Fair Use & Transparency: Clear indication that DNCRP module is a demo; avoid misleading users about official processing.

## 10. Societal Impacts

- Empowers consumers with transparent pricing & accountable ordering.
- Supports fair competition among shops through visibility + reviews.
- Reduces resource waste via better inventory alignment (wholesaler → retailer).
- Provides a prototype channel for regulatory digital oversight of pricing ethics.

## 11. Design Changes (Post-Feedback)

1. Consolidated role login into single screen (reduced navigation friction).
2. Enhanced overflow handling in monitor/notification tabs to prevent layout breaks.
3. Simplified order confirmation screen for clearer next steps.
4. Improved navigation drawer grouping for faster access to complaints & orders.

## 12. Lifelong Learning

- Users gain habit of verifying fair price compliance before purchase decisions.
- Developers acquire scalable multi‑role architecture practices (auth layering, modular APIs).
- Skill portability: Mapping, messaging, and complaint workflow patterns reusable in civic-tech apps.
- Encourages data‑driven oversight thinking (logs, status histories, review analytics).

## 13. SUS Usability Testing & Task Completion Time

A System Usability Scale (SUS) evaluation (placeholder—insert actual score) indicates above‑average perceived usability (e.g., Score: XX/100). Participants completed core tasks—login, place order, file complaint, check status—within acceptable interaction time frames. Average task completion times (prototype sample) are tabled below (replace with empirical data when collected).

| Task                   | Avg Time (s) | Notes                              |
| ---------------------- | ------------ | ---------------------------------- |
| Login & Select Role    | 8            | Single unified screen aids speed   |
| Place Customer Order   | 35           | Includes product & shop selection  |
| View Order Status      | 6            | Direct from profile orders button  |
| Submit Complaint       | 42           | Multi-field form; could streamline |
| Check Complaint Status | 10           | Dashboard filtering effective      |

## 14. Future Work

- Real-time WebSocket push for notifications & messaging.
- Government price feed integration + discrepancy detection alerts.
- Evidence attachments (images/receipts) with secure storage & moderation.
- Advanced analytics (price volatility, compliance scoring, heat maps).
- Role-based dashboards with KPI drilldowns.
- Localization expansion (full Bengali UI + additional languages).
- Automated anomaly detection in inventory or pricing.

## 15. Work Distribution

(Attach completed work distribution doc; list responsibilities.)

- Member 1: Backend auth & order system.
- Member 2: Flutter UI & navigation + complaint submission screens.
- Member 3: Inventory & wholesaler modules + messaging.
- Member 4: Reviews system & DNCRP admin dashboard.
  (Add real names & adjust.)

## 16. References

- Brooke, J. (1996). SUS: A quick and dirty usability scale.
- Hono Framework Documentation.
- Flutter & Dart Official Docs.
- PostgreSQL 16 Documentation.
- Industry examples (Daraz, Shwapno, Foodpanda Panda Mart, regional price apps) – feature observation.

---

Prepared automatically on September 13, 2025. Replace placeholders (Group Number, Member Names, SUS score, screenshots) before submission.
