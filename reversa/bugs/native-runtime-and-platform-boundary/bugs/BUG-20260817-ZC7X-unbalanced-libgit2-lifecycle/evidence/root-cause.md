# Root Cause

State: `confirmed`.

The package invokes `git_libgit2_init()` at 66 public entry points and never
invokes `git_libgit2_shutdown()`. Libgit2 defines these calls as a paired,
reference-counted global lifecycle: each initialization increments the count
and each shutdown decrements it.

Fresh runtime proof shows the count increasing once per repeated
`Libgit2.version` call. The causal path is therefore complete: the public entry
point performs an increment, no package path owns the matching decrement, and
the process-global count grows.

Official lifecycle contracts:

- https://libgit2.org/docs/reference/main/global/git_libgit2_init.html
- https://libgit2.org/docs/reference/main/global/git_libgit2_shutdown.html

The defect is present in the initial repository commit `d34661a`; there is no
known-good project commit, so regression bisection is not applicable.
