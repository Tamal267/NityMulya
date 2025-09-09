# 4. Comparative Analysis (HE vs CW)

## 4.1 Issue Overlap Matrix

| Category            | HE Only                   | CW Only                                         | Both                               |
| ------------------- | ------------------------- | ----------------------------------------------- | ---------------------------------- |
| Feedback/Visibility | 1 (route duplication)     | 3 (optimistic refresh, upload progress context) | 3                                  |
| Security            | 1 (plaintext password)    | 0                                               | 0                                  |
| Consistency         | 3 (naming, date, buttons) | 0                                               | 1 (role labeling surfaced in task) |
| Error Recovery      | 2 (cache, generic errors) | 2 (lost form state, manual refresh)             | 1                                  |
| Efficiency          | 2 (bulk ops, filters)     | 1 (distance context)                            | 1                                  |

## 4.2 Method Strengths

- HE: Broad, systematic; surfaced structural and latent risks (security, naming, duplication).
- CW: Contextual; revealed sequence and state continuity issues (refresh expectations, absent progress indicators in context).

## 4.3 Complementarity

Combined methods produced 26 (HE) + 11 (CW-only) with 8 overlaps: broadened defect coverage; overlap rate (~30%) indicates each method added unique value.

## 4.4 Risk Reduction Impact

Security + feedback + data loss constitute >60% of user friction risk; addressing shared issues yields maximum ROI.
