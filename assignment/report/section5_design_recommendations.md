# Section 5: Design Recommendations & Comparative Insight

## 5.1 Which Method Identified More Issues?

Heuristic Evaluation (HE) surfaced more total issues (13 vs 6) due to its breadth, especially systemic and non-task-layer concerns (security, consistency, accessibility).

## 5.2 Unique Contributions

- HE: Architectural + policy gaps (password hashing, API uniformity, naming conventions, error taxonomy, accessibility contrast).
- CW: First-time user stumbling blocks (shop selection search, evidence upload clarity, contextual chat initiation, silent saves).

## 5.3 Practicality in This Context

| Criterion                    | HE       | CW     | Notes                                    |
| ---------------------------- | -------- | ------ | ---------------------------------------- |
| Speed of Setup               | Faster   | Slower | CW required task path modeling           |
| Depth of Interaction Insight | Moderate | High   | CW reveals step-level confusion          |
| Architectural Coverage       | High     | Low    | CW does not expose backend risks         |
| Reusability for Regression   | High     | Medium | HE checklist reusable release to release |

## 5.4 Recommended Design Improvements (Actionable)

| Area              | Change                                                     | Rationale                              | Effort | Priority |
| ----------------- | ---------------------------------------------------------- | -------------------------------------- | ------ | -------- |
| Security          | Implement bcrypt hashing + migrate users                   | Eliminates catastrophic HE-05 risk     | Medium | P0       |
| Dashboard UX      | Split monolith into modular tabs/cards + searchable panels | Reduces overload & improves scan paths | High   | P1       |
| Complaint UX      | Add searchable shop selector + evidence panel w/ preview   | Resolves CW-01, CW-02                  | Medium | P1       |
| Error Handling    | Standard error envelope: code, message, action_hint        | Fixes HE-09; supports localization     | Medium | P1       |
| Inventory Flow    | Inline edit + success toast + highlight                    | Fixes CW-03                            | Low    | P2       |
| Chat Context      | Add "Message Supplier" button on low-stock items           | Fixes CW-04                            | Low    | P2       |
| Terminology       | Centralized role & label dictionary + i18n keys            | Resolves HE-02 & part of CW-05         | Medium | P2       |
| Progress Feedback | Add progress bar + staged form for long submissions        | Fixes CW-06                            | Medium | P2       |
| Accessibility     | Audit colors + scalable text + semantic labels             | Improves HE-13                         | Medium | P2       |
| Reviews           | Add media attachments + moderation queue                   | Enhances trust & completeness          | High   | P3       |
| Notifications     | Implement server push or polling + categorized types       | Improves visibility/status             | Medium | P3       |

## 5.5 Roadmap Alignment

Phase 0 (Immediate Gate): Security hardening.  
Phase 1: High-friction interaction fixes (complaints, dashboard decomposition).  
Phase 2: Consistency, i18n, structured errors, accessibility.  
Phase 3: Engagement & trust layers (media reviews, notifications).  
Phase 4: Performance & real-time enhancements.

## 5.6 Measuring Success Post-Fixes

| Metric                                                 | Baseline  | Target             |
| ------------------------------------------------------ | --------- | ------------------ |
| Complaint form abandonment                             | ~Est. 25% | <10%               |
| Inventory update confirmation errors (support tickets) | Unknown   | Track → Reduce 50% |
| Avg. time to submit first complaint                    | ~>150s    | <100s              |
| Strong password adoption                               | <20%      | >85%               |
| Dashboard interaction time (finding inventory)         | >10s      | <5s                |

## 5.7 Risks if Deferred

- Security breach potential (data compromise) blocks adoption.
- User frustration leading to low retention (discoverability issues).
- Scalability pain as features pile onto monolithic screens.

## 5.8 Summary Statement

Combining HE and CW surfaced a dual-lens insight: structural debt and first-use friction. Addressing security, structural dashboard refactor, and complaint/review interaction clarity will yield the largest immediate usability and trust gains. A disciplined roadmap prevents piecemeal regressions.
