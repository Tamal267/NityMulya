# 2. Heuristic Evaluation

Evaluator Count: 4  
Method: Independent review → consolidation workshop → severity assignment (highest credible severity kept).  
Severity Scale: 0 None, 1 Cosmetic, 2 Minor, 3 Major, 4 Critical.

## 2.1 Issue Table

| ID    | Screen/Context             | Heuristic (H#) | Description                                                                        | Severity | Rationale                    | Recommendation                                      |
| ----- | -------------------------- | -------------- | ---------------------------------------------------------------------------------- | -------- | ---------------------------- | --------------------------------------------------- |
| H1-1  | Complaint Submission       | H1 Visibility  | No progress indicator during media attachment upload (frontend attempts multipart) | 3        | Users may double-submit      | Add upload progress + disable submit until complete |
| H1-2  | Inventory Save             | H1 Visibility  | Silent delay on product update; only final state change                            | 2        | Perceived unresponsiveness   | Show inline saving spinner + toast                  |
| H1-3  | Login                      | H1 Visibility  | Slow network shows no inline loader for >500ms                                     | 2        | Uncertainty leads to retries | Add minimal skeleton/loader                         |
| H2-1  | Multi-role Labels          | H2 Match       | Mixed Bengali/English in same element                                              | 2        | Cognitive switching cost     | Introduce localization layer                        |
| H2-2  | Complaint Categories       | H2 Match       | Terms (severity/priority) not explained in user language                           | 2        | Misclassification risk       | Add helper tooltips                                 |
| H3-1  | Complaint Form Exit        | H3 Control     | Back navigation discards data silently                                             | 3        | Data loss frustration        | Prompt: “Discard draft?” + auto-save                |
| H3-2  | Inventory Edit             | H3 Control     | No undo for accidental quantity change                                             | 2        | Error propagation            | Maintain last value + “Undo” snackbar               |
| H3-3  | Order Cancellation         | H3 Control     | No confirmation step before irreversible cancel                                    | 2        | Accidental action risk       | Add confirm dialog                                  |
| H4-1  | Role Strings               | H4 Consistency | ‘Shop Owner’ vs ‘shop_owner’ vs ‘shop owner’                                       | 3        | Inconsistent mental model    | Centralize constants enum                           |
| H4-2  | Date Formats               | H4 Consistency | Mixed ISO + localized date                                                         | 2        | Parsing confusion            | Standardize formatting util                         |
| H4-3  | Button Styling             | H4 Consistency | Primary/secondary colors inconsistent across screens                               | 2        | Visual hierarchy diluted     | Apply theme tokens                                  |
| H4-4  | Complaint Routes           | H4 Consistency | Duplicate route definitions `/api/complaints/public`                               | 3        | Maintenance/security risk    | Deduplicate & test routing                          |
| H5-1  | Password Storage           | H5 Prevention  | Plaintext password logic in auth controller                                        | 4        | Critical security flaw       | Implement bcrypt + migration                        |
| H5-2  | Duplicate Offer Submission | H5 Prevention  | Rapid double taps create duplicates (no throttle)                                  | 2        | Data noise                   | Disable button after first tap until response       |
| H5-3  | File Type Validation       | H5 Prevention  | No client/server validation on attachments                                         | 3        | Potential malicious upload   | Enforce whitelist + size check                      |
| H6-1  | Location Capture           | H6 Recognition | Re-enter address if permission denied once                                         | 2        | Redundant recall             | Cache last known location                           |
| H6-2  | Government Price Reference | H6 Recognition | User must recall last official price                                               | 2        | Increases cognitive load     | Show readonly official field                        |
| H7-1  | Inventory Bulk Ops         | H7 Flexibility | No bulk update for multiple SKUs                                                   | 2        | Slow for large catalogs      | Multi-select batch editor                           |
| H7-2  | Saved Filters              | H7 Flexibility | Filters reset on tab change                                                        | 2        | Repetitive steps             | Persist filter state per tab                        |
| H8-1  | Dashboard Density          | H8 Aesthetic   | Overloaded cards & stats on single tab                                             | 2        | Scanning difficulty          | Segment into subviews                               |
| H8-2  | Mixed Typography           | H8 Aesthetic   | Font sizes inconsistent without hierarchy                                          | 2        | Visual noise                 | Apply scale ramp (e.g. 12/14/16/20)                 |
| H9-1  | Network Errors             | H9 Recovery    | Generic “Network error” without action                                             | 2        | No recovery guidance         | Provide actionable retry CTA                        |
| H9-2  | Price Fetch Fail           | H9 Recovery    | No fallback cached data on fail                                                    | 3        | Empty state reduces trust    | Cache last successful payload                       |
| H9-3  | Complaint Fail             | H9 Recovery    | Failure loses filled fields                                                        | 3        | Re-entry burden              | Retain form in memory/storage                       |
| H10-1 | Complaint Evidence         | H10 Help       | No guidance on acceptable file size/types                                          | 2        | Trial-and-error              | Inline microcopy + doc link                         |
| H10-2 | Review Ratings             | H10 Help       | No explanation of multi-dimension rating (if added later)                          | 1        | Minor clarity issue          | Tooltip / info icon                                 |

## 2.2 Severity Rationale Framework

- 4 Critical: Security or data integrity (P1 immediate fix).
- 3 Major: Blocks task or significant frustration.
- 2 Minor: Noticeable friction but workaround exists.
- 1 Cosmetic: Low impact aesthetics.

## 2.3 Consolidation Notes

Duplicates merged where wording varied (e.g. loading feedback across multiple evaluators). Individual evaluator raw sheets: see evaluator CSV files.

## 2.4 Prioritized Fix Batch (Sprint 1 Suggestion)

1. H5-1 (bcrypt)
2. H1-1 + H5-3 (upload robustness)
3. H3-1 (draft persistence)
4. H4-1 (role taxonomy)
5. H9-2 (pricing cache)
