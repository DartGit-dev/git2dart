# Root Cause

State: `confirmed`.

`lib/src/libgit2.dart` contains 42 typed `git_libgit2_opts_*` calls. The
`packMaxObjectSize` getter and setter capture the returned integer and call
`checkErrorAndThrow`; the other 40 calls discard the returned status.

The isolated reproduction closes the causal path: libgit2 returns a negative
status for an invalid cache object type, but the public wrapper ignores that
status and returns normally. This directly violates BR-NP-03, FR-NP-04,
FL-NP-05, and ADR-004.

The minimal coherent repair is to capture and immediately check each fallible
global-option result before interpreting output or returning to the caller.
No new error abstraction is required.
