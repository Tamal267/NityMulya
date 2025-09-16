# Section 1: System Overview

## 1.1 Project Name

NityMulya – Multi-role Consumer Protection & Commerce Platform.

## 1.2 Purpose & Vision

A unified platform connecting customers, shop owners, wholesalers, and regulatory authority (DNCRP) to promote transparent pricing, ethical trade, and streamlined dispute resolution.

## 1.3 Primary User Roles

| Role        | Goals                                             | Key Capabilities                                                        |
| ----------- | ------------------------------------------------- | ----------------------------------------------------------------------- |
| Customer    | Find fair prices, submit complaints, review shops | Browse prices, favorites, map-based shop discovery, complaints, reviews |
| Shop Owner  | Manage inventory & orders                         | Inventory CRUD, order processing, chat wholesalers                      |
| Wholesaler  | Supply to shops efficiently                       | Inventory, offers, restock negotiation, order fulfillment               |
| DNCRP Admin | Monitor consumer rights                           | View complaints, status oversight (demo)                                |

## 1.4 Core Functional Modules

- Price Discovery & Market Data
- Inventory & Order Lifecycle
- Complaint Management (customer + DNCRP)
- Review & Reputation System
- Chat & Collaboration
- Location & Proximity Intelligence

## 1.5 Current Implementation Snapshot

| Feature Domain | Status                   | Notes                                     |
| -------------- | ------------------------ | ----------------------------------------- |
| Authentication | Partially secure         | Plaintext storage in some flows (risk)    |
| Complaints     | Functional + DNCRP demo  | Media upload incomplete server-side       |
| Reviews        | Product & shop ratings   | No media attachments yet                  |
| Pricing        | Live retrieval endpoints | Lacks official vs market price separation |
| Notifications  | Partial                  | Model exists; backend trigger incomplete  |
| Rewards        | Not implemented          | Planned VAT incentive mechanism           |
| Mapping        | Functional               | Nearby & basic distance logic             |
| Chat           | Functional (text)        | No presence / real-time push              |

## 1.6 Target Devices & Constraints

- Mobile-first (Android emphasis), Web compatibility via Flutter Web.
- Network variability: must degrade gracefully (caching planned).

## 1.7 Usability Goals

| Goal                                  | Metric Target                   |
| ------------------------------------- | ------------------------------- |
| Task success (core flows)             | >90% without external help      |
| First-time complaint submission       | <2.5 min                        |
| Navigation clarity (role dashboards)  | SUS equivalent >70              |
| Error recovery (failed network calls) | Clear action prompts in <1 step |

## 1.8 Known Constraints

- Large monolithic screens hurt learnability.
- Inconsistent role naming increases cognitive overhead.
- Environment config duplication (base URLs) may confuse evaluators.

## 1.9 Evaluation Scope

Included: Customer pricing journey, complaint submission, review creation, shop owner inventory update, wholesaler restock coordination.
Excluded: Advanced reward logic (not yet built), media persistence for reviews (future).
