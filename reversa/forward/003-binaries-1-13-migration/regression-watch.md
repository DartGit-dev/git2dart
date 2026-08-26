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
- Superseded on 2026-08-26: Build run 32974619039 completed successfully for
  Quality and Linux, macOS, Windows, Android, and iOS at commit
  `9b47c0aaba67168ea74d671f9dee47418d10ad65`; Publish run 32974619046 also
  completed successfully. Its `publish` job was skipped, so this is workflow
  success evidence, not proof of a package publication.
