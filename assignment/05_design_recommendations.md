# 5. Design Recommendations & Strategy

## 5.1 Prioritized Backlog (Mapped to Issues)

| Ref | Linked Issues            | Sprint | Effort (Est) | Impact | Description                                                   |
| --- | ------------------------ | ------ | ------------ | ------ | ------------------------------------------------------------- |
| R1  | H5-1                     | S1     | 2d           | High   | Implement bcrypt + migration script + rehash existing records |
| R2  | H1-1,H1-3,H2-2,H3-1,H9-3 | S1     | 3d           | High   | Unified async UX kit (LoadingOverlay, Toaster, DraftCache)    |
| R3  | H4-1,H4-2,H4-3           | S1     | 2d           | Med    | Taxonomy + design token standardization                       |
| R4  | H9-2                     | S2     | 1.5d         | Med    | Local price cache & stale indicator                           |
| R5  | H1-2,H7-2,H8-1           | S2     | 3d           | Med    | Dashboard decomposition + persistent filters                  |
| R6  | H3-2,H7-1                | S2     | 2d           | Med    | Undo & bulk inventory operations                              |
| R7  | CW T2 S7                 | S3     | 1d           | Med    | Official price reference field integration                    |
| R8  | H5-3,CW T1 S7            | S3     | 2d           | High   | Robust media pipeline (validation + progress)                 |
| R9  | H6-1                     | S3     | 1d           | Low    | Last-known location reuse logic                               |
| R10 | CW T3 S8                 | S4     | 2d           | Med    | Order / supply event timeline model                           |

## 5.2 Architectural Enhancements

- Introduce Provider/Riverpod for state partitioning.
- Central API client (interceptors: auth renewal, logging, exponential backoff).
- Event bus or WebSocket for real‑time updates (complaints, offers, inventory).
- Modularization: split monolith dashboards (`/features/inventory`, `/features/complaints`, etc.).

## 5.3 Security Hardening Plan

1. Bcrypt hashing & minimum password policy.
2. Token expiry (short) + refresh mechanism.
3. Standard error envelope (no stack traces).
4. Upload sanitization & MIME validation.

## 5.4 Metrics to Track Post-Changes

- Complaint submission completion rate.
- Average task time: inventory update & complaint filing.
- Duplicate submission rate (should decline after R2).
- Offer response latency.
- Crash/error frequency per 1K sessions.

## 5.5 Team Contribution Narrative

See `team_contributions.csv` for quantitative breakdown. Qualitative highlights:

- Evaluator A: Security emphasis (found plaintext password risk).
- Evaluator B: Interaction flow & form resilience.
- Evaluator C: Visual consistency & taxonomy.
- Evaluator D: Performance & feedback timing.

## 5.6 Limitations

- No real user analytics available for triangulation.
- Media pipeline not live → simulated assumptions for upload friction.

## 5.7 Future Work

- Accessibility (contrast ratios, semantic roles) audit.
- Internationalization framework extraction.
- Automated regression tests for critical flows.

---

Prepared collaboratively; final editing pass integrated all evaluator inputs.
