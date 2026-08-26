# Regression Watch: Strict Git Validation

Feature: `001-strict-git-validation`

| ID | Origin (file, section) | Expected rule after change | Verification type | Violation signal |
| --- | --- | --- | --- | --- |
| W001 | `reversa/sdd/domain.md`, Object and repository integrity, rule 4 | Only commit, tree, blob, and tag pass ODB write/hash validation; all other `GitObject` values throw `ArgumentError` before native execution. | presence | A pseudo or delta type reaches a native ODB operation or a concrete type is rejected locally. |
| W002 | `reversa/sdd/domain.md`, References and history, rule 8 | Every covered public reference-name position rejects the approved invalid Git syntax locally and accepts valid `HEAD`-style or `refs/` names. | presence | Invalid syntax produces a native error or a valid representative is rejected before native execution. |

## Re-extraction history

None.

## Arquivadas

None.
