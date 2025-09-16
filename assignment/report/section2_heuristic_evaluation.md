# Section 2: Heuristic Evaluation (Nielsen’s 10)

Severity Scale: 0 = Not a problem, 1 = Cosmetic, 2 = Minor, 3 = Major, 4 = Usability Catastrophe

| ID      | Heuristic                               | Issue                                                 | Context / Screen                         | Severity | Rationale                                           | Recommendation                                 |
| ------- | --------------------------------------- | ----------------------------------------------------- | ---------------------------------------- | -------- | --------------------------------------------------- | ---------------------------------------------- |
| HE-01   | Visibility of System Status             | No loading state on some inventory fetches            | Shop Owner Dashboard (initial inventory) | 2        | Users unsure if data is coming or frozen            | Add skeleton loaders + retry toast             |
| HE-02   | Match Between System & Real World       | Mixed role naming (Shop Owner vs shop_owner)          | Login + dashboard logic                  | 2        | Increases cognitive friction & error risk           | Standardize display labels, map internal enums |
| HE-03   | User Control & Freedom                  | No cancel option mid complaint submission (multipart) | Complaint Submission Screen              | 2        | Long form; user forced to back-navigate losing data | Add draft auto-save + explicit Cancel          |
| HE-04   | Consistency & Standards                 | Routes & base URLs inconsistent (`/api/` vs none)     | Network + code audit                     | 3        | Hard to predict endpoints, debugging harder         | Normalize `/api/v1/` prefix, deprecate legacy  |
| HE-05   | Error Prevention                        | Password plaintext logic server-side                  | Sign Up & Auth backend                   | 4        | Critical security & trust risk                      | Implement bcrypt hashing + migration           |
| HE-06   | Recognition over Recall                 | Large 2–3K line dashboards without section grouping   | Shop/Wholesaler Dashboard                | 3        | Users hunt for functions; scanning overhead high    | Card-based modular layout + collapsible panels |
| HE-07   | Flexibility & Efficiency                | No power-user shortcuts (bulk inventory edits)        | Inventory management                     | 1        | Adds time for large catalogs                        | Add multi-select & batch update dialog         |
| HE-08   | Aesthetic & Minimalist Design           | Overcrowded metrics (mixed Bangla + English)          | Wholesaler Dashboard header              | 2        | Visual noise, divided attention                     | Group metrics + progressive disclosure         |
| HE-09   | Help Users Recognize, Diagnose, Recover | Generic 'Server error' without next step              | Network helper responses                 | 3        | Blocks self-recovery                                | Add structured error codes + retry CTA         |
| HE-10   | Help & Documentation                    | No inline guidance for complaint evidence quality     | Complaint Form                           | 1        | Users may upload irrelevant media                   | Tooltip with example acceptable proofs         |
| HE-11\* | (Extended) Security Feedback            | No password strength meter                            | Signup Screen                            | 1        | Weak passwords slip through                         | Add strength meter + policy hints              |
| HE-12\* | (Extended) Feedback Latency             | Chat send no optimistic UI                            | Chat Screen                              | 2        | User unsure if message sent                         | Show pending state + failure resend            |
| HE-13\* | (Extended) Accessibility                | Insufficient contrast on some green buttons           | Theming audit                            | 2        | Low visibility for low-vision users                 | Contrast ratio >4.5:1 & scalable text          |

Top Critical Issues: HE-05 (Security), HE-04 (Inconsistent API), HE-09 (Error feedback), HE-06 (Dashboard complexity)

## Aggregate Stats

- Total Issues: 13
- Severity Mean: 2.15
- High (>=3): 4
- Catastrophic (4): 1

## Improvement Themes

1. Structural Refactor (dashboards, navigation clarity)
2. Security Hardening (password hashing, token flows)
3. Feedback & Status (loading, error specificity)
4. Consistency (naming, endpoint prefix)
5. Accessibility & Localization strategy
