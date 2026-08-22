# Companion eager initialization boundary

## Observation

The locked dependency `git2dart_binaries 1.12.1` initializes its exported
`libgit2` binding eagerly on first access in each Dart isolate. Its
`lib/src/util.dart` constructs the binding through `_initializeLibgit2`,
which calls `git_libgit2_init()` before returning the instance.

## Gate 2 impact

Reusing that exported binding would add an implicit, untracked native increment
before the new explicit isolate lease. A fresh worker isolate then contributed
two increments: one from the companion binding and one from the proposed
runtime manager.

The Gate 2 proposal therefore loads the already-resolved native library through
`libgit2Opts`, creates a private raw `Libgit2` binding without evaluating the
companion's eager global binding, and performs the only explicit initialization
through `Libgit2Runtime`.

## Proof

- Before the boundary correction, the two-isolate lifecycle test expected one
  increment but observed two for the first worker.
- After routing internal calls through the private raw binding, all 12 lifecycle
  tests passed, including independent startup and shutdown of two isolates.

This finding does not modify `git2dart_binaries`, its generated bindings, or
the dependency version.
