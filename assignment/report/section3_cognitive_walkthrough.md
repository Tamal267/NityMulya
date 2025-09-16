# Section 3: Cognitive Walkthrough (CW)

Focus: Learnability for first-time users performing key tasks.
Questions Applied Per Step:

1. Will the user try to achieve the right effect?
2. Will the user notice the correct action is available?
3. Will the user associate the action with the desired effect?
4. If the correct action is performed, will the user see progress toward the goal?

Severity Scale (CW Specific Breakdown Risk): Low / Medium / High

## Task 1: Submit a Pricing Complaint

Goal: Customer reports unfair price at a shop.
Preconditions: Logged in as Customer; knows target shop.

| Step | User Intention          | Expected Action                      | System Affordance                       | Breakdown Risk | Notes / Improvement                   |
| ---- | ----------------------- | ------------------------------------ | --------------------------------------- | -------------- | ------------------------------------- |
| 1    | Find complaint feature  | Open navigation / complaints         | Drawer icon present                     | Low            | Highlight in home shortcuts           |
| 2    | Start new complaint     | Tap "Submit Complaint"               | Button visible but text lengthy         | Medium         | Use concise CTA "New Complaint"       |
| 3    | Select shop             | Choose shop from list / manual entry | No auto-suggest binding yet             | High           | Add searchable shop picker            |
| 4    | Add evidence            | Attach photo/video                   | Media button (if added) unclear         | High           | Show icon + label "Add Evidence"      |
| 5    | Set category & priority | Dropdown selection                   | Present but jargon mix (Bangla/English) | Medium         | Provide inline helper text            |
| 6    | Submit complaint        | Tap submit                           | Loading feedback minimal                | Medium         | Add progress + success number earlier |

## Task 2: Shop Owner Updates Inventory Quantity

Goal: Modify stock after restock.
Preconditions: Authenticated as Shop Owner.

| Step | Intention              | Expected Action      | Affordance              | Risk   | Improvement                        |
| ---- | ---------------------- | -------------------- | ----------------------- | ------ | ---------------------------------- |
| 1    | Navigate to inventory  | Select Inventory tab | Tab label among 5       | Low    | Use icon + tooltip                 |
| 2    | Choose product to edit | Tap product row      | Crowded list            | Medium | Add filter/search field            |
| 3    | Edit quantity          | Open edit dialog     | Inline edit not obvious | Medium | Add pencil icon & inline edit mode |
| 4    | Save changes           | Tap Save/Update      | Confirmation silent     | High   | Toast + highlight changed row      |

## Task 3: Wholesaler Responds to Low Stock Demand

Goal: Identify shops needing supply and initiate chat.

| Step | Intention             | Expected Action         | Affordance                 | Risk   | Improvement                          |
| ---- | --------------------- | ----------------------- | -------------------------- | ------ | ------------------------------------ |
| 1    | View low stock alerts | Open Low Stock tab      | Tab available              | Low    | Badge count for urgency              |
| 2    | Inspect affected shop | Tap product / shop link | Link styling subtle        | Medium | Use card with clear CTA              |
| 3    | Initiate negotiation  | Open chat from context  | Chat requires separate tab | High   | Add contextual "Message Shop" button |
| 4    | Confirm shipment      | Update order status     | Status form multi-step     | Medium | Provide status quick actions         |

## Task 4 (Optional): Customer Adds Favorite Product

| Step | Intention       | Expected Action      | Affordance          | Risk   | Improvement                        |
| ---- | --------------- | -------------------- | ------------------- | ------ | ---------------------------------- |
| 1    | View product    | Open product listing | Visible             | Low    | OK                                 |
| 2    | Mark favorite   | Tap heart icon       | Icon small          | Medium | Larger touch target + filled state |
| 3    | Verify addition | Check favorites page | Delay not explained | Medium | Snackbar "Added to Favorites"      |

## Cross-Task Observations

- Discoverability Gaps: Shop selection, evidence upload, chat initiation from context.
- Feedback Gaps: Inventory update silent success, complaint progress non-linear.
- Vocabulary Consistency: Mix of Bangla + English without glossary.

## Aggregated CW Issues (Mapped to Improvements)

| ID    | Issue                                       | Impact | Recommendation                                      |
| ----- | ------------------------------------------- | ------ | --------------------------------------------------- |
| CW-01 | Shop selection lacks search                 | High   | Add searchable dropdown with recent shops           |
| CW-02 | Evidence upload affordance weak             | High   | Dedicated media card with preview thumbnails        |
| CW-03 | Inventory save lacks confirmation           | Medium | Add toast + highlight pulse                         |
| CW-04 | Chat initiation detached from stock context | High   | Inline "Contact Wholesaler" button on low-stock row |
| CW-05 | Mixed language taxonomy                     | Medium | Localization service + glossary overlay             |
| CW-06 | No progress indicators on long form submit  | Medium | Inline stepper + progress bar                       |
