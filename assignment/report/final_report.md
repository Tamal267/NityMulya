# HCI Usability Evaluation – NityMulya

## Section 1. System Overview (Summary)

NityMulya is a multi-role commerce and consumer rights platform connecting Customers, Shop Owners, Wholesalers, and DNCRP Admins. Core modules: Pricing, Inventory, Orders, Complaints, Reviews, Chat, Location Intelligence. Evaluation scope emphasized early journey flows: pricing browse, complaint submission, inventory update, restock coordination, and rating.

## Section 2. Heuristic Evaluation (Condensed)

13 issues mapped to Nielsen + extended heuristics. Highest severity: plaintext password storage (HE-05), API inconsistency (HE-04), poor feedback (HE-09), dashboard overload (HE-06). Mean severity: 2.15. Themes: consistency, structural overload, feedback latency, security, accessibility.

## Section 3. Cognitive Walkthrough (Condensed)

Tasks: (1) Submit pricing complaint, (2) Update inventory, (3) Respond to low stock & negotiate supply, (4 optional) Add favorite. Key breakdowns: discoverability (shop search, evidence upload), silent success (inventory save), contextual action absence (chat). 6 distinct CW issues—three High risk (shop search, evidence upload affordance, chat context linkage).

## Section 4. Comparative Analysis

Overlap in structural complexity and feedback deficits. HE surfaced systemic + backend constraints; CW revealed interaction-level friction. Combined approach provided both breadth (architecture) and depth (first-run mental model gaps). Priority convergence: dashboard decomposition, secure auth, improved complaint workflow clarity.

## Section 5. Design Recommendations

Immediate P0: Implement bcrypt hashing + uniform auth (security gate). P1: Complaint UX (searchable shop + evidence panel), dashboard modularization, error taxonomy. P2: Inline inventory feedback, contextual chat triggers, localization & terminology harmonization, accessibility audit. P3: Review media + notifications enrichment. Success metrics defined for post-change validation (e.g., complaint completion time, strong password adoption).

## Key Tables (Abbreviated)

### Critical HE Issues

| ID    | Issue                        | Severity | Fix Priority |
| ----- | ---------------------------- | -------- | ------------ |
| HE-05 | Plaintext password storage   | 4        | P0           |
| HE-06 | Dashboard cognitive overload | 3        | P1           |
| HE-09 | Generic error feedback       | 3        | P1           |
| HE-04 | Inconsistent API prefix      | 3        | P1           |

### Top CW Breakdowns

| ID    | Breakdown                          | Impact | Fix                     |
| ----- | ---------------------------------- | ------ | ----------------------- |
| CW-01 | No shop search in complaints       | High   | Searchable picker       |
| CW-02 | Weak evidence upload affordance    | High   | Media panel w/ previews |
| CW-04 | Chat not contextual from low stock | High   | Inline chat CTA         |

## Roadmap Snapshot

Phase 0: Security hardening
Phase 1: High-friction UX fixes
Phase 2: Consistency + Accessibility
Phase 3: Engagement features
Phase 4: Real-time & performance optimization

## Conclusion

The evaluation exposed a synergy of architectural debt and UI friction. Applying the outlined phased plan will significantly enhance trust, learnability, and operational resilience, positioning NityMulya for sustainable expansion.

---

Refer to individual section files and CSV datasets for full detail.
