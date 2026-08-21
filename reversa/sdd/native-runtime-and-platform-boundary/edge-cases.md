# Native Runtime and Platform Boundary — Edge Cases

> 🟢 **CONFIRMED** — Native boundary edge cases are fail-fast where locally decidable and explicit gaps where dynamic proof is absent.

| ID | Edge case | Expected behavior | Confidence |
| --- | --- | --- | --- |
| EC-NP-01 | Native library is missing or wrong architecture | Load/call fails; no Dart fallback implementation is implied. | 🟢 CONFIRMED |
| EC-NP-02 | Generated struct/function declaration mismatches binary ABI | Unsafe/incompatible; upgrade must be blocked by comparison/testing. | 🟢 CONFIRMED |
| EC-NP-03 | Dart string contains Unicode | Marshal UTF-8 plus terminating null. | 🟢 CONFIRMED |
| EC-NP-04 | Nullable string is absent | Pass null only where native contract permits it. | 🟢 CONFIRMED |
| EC-NP-05 | Flag set is empty | Pass native zero/default mask. | 🟢 CONFIRMED |
| EC-NP-06 | Native result is negative | Read current error immediately and throw. | 🟢 CONFIRMED |
| EC-NP-07 | Native result is non-negative status, not simple success | Operation adapter interprets it; generic checker must not erase it. | 🟢 CONFIRMED |
| EC-NP-08 | `git_error_last()` is null/unexpected | Fallback diagnostic behavior must avoid dereferencing null; exact contract needs proof. | 🔴 GAP |
| EC-NP-09 | Arena call throws midway | Arena allocations unwind. | 🟢 CONFIRMED |
| EC-NP-10 | Manual temporary acquired before later failure | Matching disposer must run; exhaustive proof is absent. | 🔴 GAP |
| EC-NP-11 | Owned pointer finalizes after explicit free | Finalizer must have been detached to prevent double free. | 🟢 CONFIRMED |
| EC-NP-12 | Borrowed pointer is wrapped as owned | Forbidden; would risk invalid free/use-after-free. | 🟢 CONFIRMED |
| EC-NP-13 | Ownership is transferred | Previous finalizer/destructor path must be detached. | 🟢 CONFIRMED |
| EC-NP-14 | Callback data retained after callback | Unsupported unless copied. | 🟢 CONFIRMED |
| EC-NP-15 | Callback throws | Native result/cleanup behavior needs characterization. | 🔴 GAP |
| EC-NP-16 | Two callback-bearing calls overlap | Static bridge isolation is not proven. | 🔴 GAP |
| EC-NP-17 | Android bootstrap omitted before TLS | Remote TLS may fail. | 🟢 CONFIRMED requirement / 🔴 GAP exact error |
| EC-NP-18 | Android CA helper fails | Initialization fails and TLS readiness must not be claimed. | 🟡 INFERRED |
| EC-NP-19 | iOS static symbols unavailable | Version access/init fails; no successful runtime claim. | 🟡 INFERRED |
| EC-NP-20 | Desktop calls platform initializer | Mobile-specific branches no-op. | 🟢 CONFIRMED |
| EC-NP-21 | SSL file and path are both null | Reject configuration. | 🟢 CONFIRMED |
| EC-NP-22 | Pack maximum object size is negative | Reject locally. | 🟢 CONFIRMED |
| EC-NP-23 | Global option changes during another operation | Cross-operation effects are possible; serialize until proven safe. | 🔴 GAP |
| EC-NP-24 | Cached memory values exceed Dart small-int assumptions | Dart int/native conversion must preserve supported native width. | 🟡 INFERRED |
| EC-NP-25 | Wrapper is freed twice or used afterward | Universal safe behavior is not established. | 🔴 GAP |
| EC-NP-26 | Finalizer timing is relied on for scarce resources | Unsupported deterministic timing; use explicit free. | 🟢 CONFIRMED |

## Required Characterization

- 🔴 **GAP** — Sanitizer/leak instrumentation on every platform and injected native error path.
- 🔴 **GAP** — Callback exception/overlap and global-option race tests.
- 🔴 **GAP** — Missing/wrong ABI/load failure diagnostics.
- 🔴 **GAP** — Repeated/post-free wrapper safety.

