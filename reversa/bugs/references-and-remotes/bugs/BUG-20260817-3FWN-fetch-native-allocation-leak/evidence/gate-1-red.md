# Gate 1 RED evidence

Date: 2026-08-21

Command:

```text
flutter test -j 1 test/remote_test.dart --plain-name "owns fetch temporary allocations through the active arena"
```

Result: failed as expected. The extracted `fetch` implementation contains `calloc<git_strarray>()`, `calloc<Pointer<Char>>(refspecs.length)`, and `calloc<git_fetch_options>()` instead of arena-owned allocations.

## Proof boundary

This source-level regression test proves that the three known fetch temporaries do not satisfy the selected lexical ownership contract before the production change. It does not establish runtime heap measurements or platform-wide leak freedom.
