# Regression watch: 003-binaries-1-13-migration

| ID | Origin (file, section) | Expected rule after change | Verification type | Violation signal |
|---|---|---|---|---|
| W001 | `legacy-impact.md`, Modified | Global-option output pointers remain arena-scoped so native failures do not leak temporary allocations. | presença | A `calloc` output pointer can bypass release after `checkErrorAndThrow`. |
| W002 | `legacy-impact.md`, Modified | The public global-option API stays `int`, with `Size` for the four size outputs and `IntPtr` for both cached-memory outputs. | redação | A getter changes public type or swaps the documented ABI pointer group. |

## Historical re-extractions


## Archived


## Observations

- CI proof across Linux, macOS, Windows, Android, and iOS is still pending;
  local Windows execution is not equivalent evidence.
