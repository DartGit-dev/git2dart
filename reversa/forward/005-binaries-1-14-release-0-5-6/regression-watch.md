# Regression Watch: 005-binaries-1-14-release-0-5-6

> Context anchor: legacy
> Execution status: partial; no confirmed green legacy domain rule was modified.

| ID | Origin (file, section) | Expected rule after change | Verification type | Violation signal |
|---|---|---|---|---|
| W001 | `test/libgit2_test.dart`, `Libgit2 returns up to date version of libgit2` | Resolved companion 1.14.0 reports bundled libgit2 1.9.7 on the validated Windows x64 host. | presence | The version assertion diverges from the runtime value or the focused/full test fails. |

## Re-extraction history

None.

## Archived

None.

## Observations

- The initial 1.9.6 expectation was corrected to 1.9.7 from directly observed resolved-runtime evidence. This remains host-scoped and is not cross-platform runtime proof.
