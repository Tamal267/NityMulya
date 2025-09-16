# Section 4: Comparative Analysis (HE vs CW)

## 4.1 Overlap Matrix

| Theme                  | HE Findings                             | CW Findings                                               | Overlap Commentary                                                  |
| ---------------------- | --------------------------------------- | --------------------------------------------------------- | ------------------------------------------------------------------- |
| Navigation Complexity  | HE-06 (dashboard overload)              | CW multiple tasks: inventory/product selection effort     | Both methods converge on cognitive load; restructuring prioritized  |
| Feedback / Status      | HE-01, HE-09 (loading & generic errors) | CW-03 (silent inventory update), CW long submit ambiguity | Missing feedback is systemic across tasks (high ROI fix)            |
| Consistency & Language | HE-02, HE-08                            | CW-05 mixed taxonomy                                      | Reinforces need for unified terminology & style guide               |
| Security / Trust       | HE-05 (password risk)                   | Not surfaced in CW (not task-facing)                      | HE uniquely surfaces backend / architectural flaws                  |
| Discoverability        | HE-06 (dense UI)                        | CW-01, CW-02, CW-04 (missing affordances)                 | CW exposes granular early-usage friction; HE broad structural cause |
| Error Prevention       | HE-05, HE-09                            | CW-06 (no progress guidance)                              | Combined view: prevention + recovery both weak                      |
| Accessibility          | HE-13 contrast                          | Not explicitly evaluated in CW flows                      | HE provides coverage for non-task heuristics                        |

## 4.2 Which Method Found More Issues?

- HE: 13 documented issues (4 high severity or above)
- CW: 6 core breakdowns (3 high)  
  HE surfaces more breadth (infrastructure, consistency, security); CW surfaces depth (contextual task stumbling points).

## 4.3 Unique Issues per Method

| Method | Unique Issue Examples                                                           | Reason                                        |
| ------ | ------------------------------------------------------------------------------- | --------------------------------------------- |
| HE     | Plaintext passwords, API prefix inconsistency, contrast issues                  | Architectural / systemic not tied to one task |
| CW     | Shop selection discoverability, evidence upload affordance, chat context action | Emergent only when simulating real tasks      |

## 4.4 Complementary Value

- HE establishes macro-level structural + compliance baseline.
- CW exposes micro-level interaction friction that reduces first-time success.
- Combined: Prevents over-optimizing UI polish while ignoring backend risk, and vice versa.

## 4.5 Prioritization Framework (ICE Example)

| Issue                              | Impact | Confidence | Effort | ICE Score |
| ---------------------------------- | ------ | ---------- | ------ | --------- |
| Plaintext password (HE-05)         | 10     | 9          | 3      | 30        |
| Dashboard overload (HE-06)         | 8      | 8          | 6      | 21        |
| Shop selection search (CW-01)      | 7      | 8          | 4      | 19        |
| Missing error specificity (HE-09)  | 7      | 7          | 5      | 17        |
| Evidence upload affordance (CW-02) | 6      | 7          | 4      | 17        |
| Inconsistent roles (HE-02)         | 6      | 8          | 3      | 17        |

## 4.6 Synthesis

- High-impact fixes blend structural refactors (dashboard segmentation) with pointed interaction boosts (searchable pickers, progress cues).
- Security fix (password hashing) is non-negotiable gate before public expansion.
