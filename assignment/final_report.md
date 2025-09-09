<!-- Final HCI Evaluation Report for NityMulya -->

# NityMulya Usability Evaluation (Heuristic Evaluation + Cognitive Walkthrough)

Version: 1.0  
Date: 2025-09-09

## 1. System Overview

NityMulya is a multi-role commerce and consumer protection platform supporting Customers, Shop Owners, Wholesalers, and a DNCRP (regulatory) Admin. Core functions include: real‑time commodity pricing, inventory publication, order management, complaints with evidence to government channels, reviews & ratings, shop discovery with geolocation, chat between supply chain actors, and future reward (VAT honesty) incentives.

See `01_system_overview.md` for the concise description and scope boundaries.

## 2. Heuristic Evaluation Summary

Four evaluators independently applied Nielsen's 10 Usability Heuristics. 26 distinct issues were consolidated (duplicates merged). Severity scale: 0=None, 1=Cosmetic, 2=Minor, 3=Major, 4=Critical. Distribution:

| Heuristic                         | Issues | Highest Severity | Notes                                                                      |
| --------------------------------- | ------ | ---------------- | -------------------------------------------------------------------------- |
| H1 Visibility of System Status    | 3      | 3                | Missing loading/submit feedback in complaint upload & inventory save       |
| H2 Match to Real World            | 2      | 2                | Mixed language (English/Bengali) without consistent labeling               |
| H3 User Control & Freedom         | 3      | 3                | No cancel/undo for inventory edits; exiting complaint form loses data      |
| H4 Consistency & Standards        | 4      | 3                | Role naming inconsistent (Shop Owner vs shop_owner); multiple date formats |
| H5 Error Prevention               | 3      | 4                | Plaintext password logic; accidental duplicate offers possible             |
| H6 Recognition vs Recall          | 2      | 2                | Re‑entry of location on signup if permission denied once                   |
| H7 Flexibility & Efficiency       | 2      | 2                | Power users lack bulk inventory update; no saved filters                   |
| H8 Aesthetic & Minimalist Design  | 2      | 2                | Overloaded dashboard tabs, dense card layouts                              |
| H9 Help Users Recover from Errors | 3      | 3                | Generic network error messages; no retry on price fetch                    |
| H10 Help & Docs                   | 2      | 2                | No inline guidance for complaint evidence standards                        |

Detailed issue list with recommendations: `02_heuristic_evaluation.md` and consolidated CSV `all_findings.csv`.

## 3. Cognitive Walkthrough Summary

Three representative tasks were analyzed (first‑time user perspective):

1. Customer locates a nearby verified shop and submits a complaint with photo evidence.
2. Shop Owner updates product quantity referencing government price baseline.
3. Wholesaler responds to a low‑stock restock need and sends an offer.

Across 41 action steps, 11 potential breakdowns identified (27% of steps). Most breakdown categories: Missing feedback, terminology mismatch, insufficient affordance for attachment progress, and lack of structured confirmation.
Full step matrix: `03_cognitive_walkthrough.md` and CSVs `cw_tasks.csv`, `cw_steps_analysis.csv`.

## 4. Comparative Analysis (HE vs CW)

Overlap: 8 issues surfaced by both methods (loading feedback, inconsistent role labels, missing cancel states, vague errors).
Unique to HE: Structural/security issues (plaintext password, inconsistent naming, duplication of complaint route) not encountered in guided tasks.
Unique to CW: Step-level learnability friction (attachment state ambiguity, expectation of auto-populated government price field, absence of review submission confirmation screen).
CW surfaced more sequence-dependent confusion; HE surfaced broader systemic risk.

## 5. Design Recommendations

Priority (P1 critical, P2 important, P3 enhancement):
| ID | Priority | Recommendation | Source Issues | Expected Impact |
|----|----------|---------------|--------------|-----------------|
| R1 | P1 | Implement bcrypt hashing + uniform auth error copy | H5-S4 | Security & trust |
| R2 | P1 | Add unified loading + success toasts (complaints, inventory, offers) | H1, CW-T1-S6 | Reduce uncertainty & resubmissions |
| R3 | P1 | Preserve unsent form state (complaint draft cache) | H3, CW-T1-S4 | Prevent data loss |
| R4 | P2 | Standardize role & label taxonomy (Customer, Shop Owner, Wholesaler, Admin) | H4 | Cognitive clarity |
| R5 | P2 | Introduce attachment upload progress + size/type validation | CW-T1-S7, H5 | Reduce failed evidence submissions |
| R6 | P2 | Split dashboards into focused sub-screens, add filter memory | H8, H7 | Efficiency & readability |
| R7 | P2 | Bulk inventory adjust (multi-select + delta apply) | H7 | Expert efficiency |
| R8 | P2 | Guided tooltip / help panel for complaint severity & priority | H10 | Better classification accuracy |
| R9 | P3 | Save frequently used location & auto-fill on signup | H6 | Faster onboarding |
| R10 | P3 | Add order & supply event timeline (dispatched/in_transit) | CW-T3-S8 | Operational transparency |

Implementation roadmap: See `05_design_recommendations.md`.

## 6. Method Comparison Reflection

HE breadth > CW depth. HE faster for systemic issues (security, consistency); CW indispensable for first‑time task friction. Combining both gave a fuller defect set (intersection only 30%).

## 7. Team Contribution Summary

Breakdown of individual inputs: `team_contributions.csv` and narrative in `05_design_recommendations.md`.

## 8. Appendix

Artifacts: evaluator CSVs, CW task matrix, consolidated findings.

---

Prepared for academic submission (Human–Computer Interaction Assignment). All data synthesized from current codebase state (branch: Khadiza-Mithila) as of 2025-09-09.
