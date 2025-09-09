# 3. Cognitive Walkthrough (CW)

## 3.1 Tasks Selected

| Task ID | User Role  | Goal                                                                        | Success Criteria                            |
| ------- | ---------- | --------------------------------------------------------------------------- | ------------------------------------------- |
| T1      | Customer   | Submit a complaint with photo evidence for a product issue at a nearby shop | Complaint ID returned + visible in list     |
| T2      | Shop Owner | Update product stock using government price as reference                    | Quantity saved, inventory reflects change   |
| T3      | Wholesaler | Identify low-stock shop and send restock offer                              | Offer acknowledged / appears in offers list |

## 3.2 Step Analysis (Representative Extract)

| Task | Step # | User Action (Intended)    | Expected System Response           | Observed/Issue?                | Breakdown? | Recommendation                   |
| ---- | ------ | ------------------------- | ---------------------------------- | ------------------------------ | ---------- | -------------------------------- |
| T1   | 1      | Open app & login          | Dashboard loads                    | Works                          | No         | Preload session if token valid   |
| T1   | 4      | Open nearby shops map     | Show verified shops with distances | Works                          | No         | Add filter toggle persisted      |
| T1   | 6      | Select “Submit Complaint” | Show complaint form                | Minor delay                    | Minor      | Skeleton placeholder             |
| T1   | 7      | Attach photo evidence     | Show upload progress               | No progress shown              | Yes        | Progress bar + size limit        |
| T1   | 9      | Submit complaint          | Spinner + success ref              | Delay, no spinner              | Yes        | Unified async overlay            |
| T1   | 10     | Return to list            | New complaint visible              | Sometimes needs manual refresh | Yes        | Auto refresh / optimistic add    |
| T2   | 2      | Navigate to Inventory tab | Inventory list shows               | Works                          | No         | Remember last sort               |
| T2   | 5      | Edit quantity             | Editable field focused             | OK                             | No         | Add undo after save              |
| T2   | 6      | Save changes              | Confirmation                       | Silent                         | Yes        | Toast “Saved”                    |
| T2   | 7      | Cross-check gov price     | Readonly field present             | Not present                    | Yes        | Surface official price field     |
| T3   | 3      | Open Low Stock view       | List of shops w/ thresholds        | Works                          | No         | Add distance column              |
| T3   | 5      | Select a shop             | Shop detail + request context      | Works                          | No         | Show last order date             |
| T3   | 7      | Compose offer             | Offer form loaded                  | Works                          | No         | Prefill previous price           |
| T3   | 8      | Send offer                | Confirmation + appears in list     | Appears after manual refresh   | Yes        | Event-based or optimistic insert |

Full granular step table in `cw_steps_analysis.csv`.

## 3.3 Breakdown Themes

- Feedback absence (save, upload, submit).
- Missing persistent filters and optimistic UI patterns.
- Lack of government reference pricing display.
- Manual refresh expectations.

## 3.4 Learnability Observations

- Navigation labels mostly self-evident.
- Mixed language decreases first-time clarity for severity/priority fields.
- Chat entry points buried within tab clusters for new wholesalers.

## 3.5 Improvements (Top CW-Derived)

1. Attachment progress & validation.
2. Optimistic list insertion (complaints, offers).
3. Readonly “Official Price” field in inventory edit modal.
4. Auto-refresh using stream/poll after create actions.
5. Draft retention for multi-field forms.
