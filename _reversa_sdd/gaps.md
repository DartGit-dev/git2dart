# Remaining Gaps — git2dart

> 🟢 **CONFIRMED** — Reviewer consolidated repeated red statements into the following unique evidence/decision gaps. Severity reflects potential impact on faithful reimplementation, safety, or release confidence.

## Critical

| ID | Gap | Impact | Resolution evidence | Question |
| --- | --- | --- | --- | --- |
| GAP-C01 | No exhaustive native allocation/free/transfer/borrow audit | Leak, double free, use-after-free, process crash | Sanitizer/fault-injection matrix | Q4 |
| GAP-C02 | Callback/global/repository concurrency contract absent | Cross-operation credentials/trust/state corruption | Overlap tests or explicit serialization policy | Q1 |
| GAP-C03 | Repeated/post-free and parent/borrowed lifetime contract absent | Undefined native lifetime behavior | Guard design and lifetime tests | Q2/Q3 |
| GAP-C04 | Live HTTPS/SSH/platform matrix not current | Offline success may hide production transport failures | Controlled live suite | Q6 |
| GAP-C05 | Multi-step mutation/interruption recovery not specified | Partial index/workdir/ref/submodule/pack state | Fault injection, reopen/retry policy | Q7 |
| GAP-C06 | Callback exception/cancellation cleanup not characterized | Partial operation, leaked resources, unclear error | Callback fault tests and mapping | Q8 |
| GAP-C07 | ABI/load proof threshold for native upgrades undefined | Silent struct/function mismatch across platforms | API diff plus five-platform load/test gate | Q11 |

## Moderate

| ID | Gap | Impact | Resolution evidence | Question |
| --- | --- | --- | --- | --- |
| GAP-M01 | Full SHA-256 support matrix absent | Unsupported object format may appear partially functional | SHA-1/SHA-256 operation matrix | Q5 |
| GAP-M02 | Secret-redaction and certificate override guidance incomplete | Consumer logging or trust policy may be unsafe | Security guidance/tests | Q9 |
| GAP-M03 | Cross-platform path/mode/symlink normalization contract absent | Behavioral/test differences by OS | Platform fixture matrix | Q10 |
| GAP-M04 | Mobile initialization repeat/concurrency behavior absent | Duplicate setup or startup race | Device characterization/guard | Q12 |
| GAP-M05 | Dedicated `createCommitOnHead` rollback/negative tests absent | Partial index mutation on failure | Focused tests and documented recovery | Q7 |
| GAP-M06 | Pack partial-output cleanup is not characterized | Stale/corrupt output file after failure | Output fault tests | Q7 |

## Cosmetic / Documentation

| ID | Gap | Impact | Resolution |
| --- | --- | --- | --- |
| GAP-D01 | Some supporting files belong to more than one semantic unit but matrix assigns one primary unit | Readers may overlook cross-unit responsibility | Preserve primary mapping plus spec-impact matrix | 🟢 Addressed structurally |
| GAP-D02 | User-story personas are derived from package mission rather than observed product research | Stories are technical rather than market/persona evidence | Keep confidence provenance explicit | 🟢 Addressed |
| GAP-D03 | Historical test log exists without fresh Writer/Reviewer execution | Readers may mistake prior success for current proof | Confidence report explicitly separates it | 🟢 Addressed |

## No Gap Found in Structural Coverage

- 🟢 **CONFIRMED** — All six Scout features have the seven planned unit files.
- 🟢 **CONFIRMED** — All 95 Dart files under `lib/` appear exactly once in the primary code/spec mapping.
- 🟢 **CONFIRMED** — No missing or extra `lib/*.dart` path was found in the matrix validation.
- 🟢 **CONFIRMED** — No HTTP/RPC/queue API exists, so OpenAPI/contracts omission is appropriate.
- 🟢 **CONFIRMED** — No Docker/Compose/cloud configuration exists, so deployment omission is appropriate.

