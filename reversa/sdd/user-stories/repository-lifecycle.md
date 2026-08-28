# User Stories — Repository Lifecycle

> 🟢 **CONFIRMED** — Personas are package consumers/maintainers inferred from the public API and project mission.

## US-RL-01 — Acquire a Repository

🟢 **CONFIRMED** — As a Dart developer, I want to initialize, discover, open, or clone a repository through typed constructors so that I never manage `git_repository*` directly.

```gherkin
Dado a valid local path or remote URL and required process authority
Quando the selected acquisition operation succeeds
Então an owned Repository exposes typed metadata and cleanup
```

## US-RL-02 — Inspect and Reconcile State

🟢 **CONFIRMED** — As an application, I want HEAD, status, history, operation state, and child-resource access so that I can choose valid Git actions.

```gherkin
Dado an open repository
Quando metadata, HEAD, status, or active state is requested
Então typed values reflect libgit2 without zero-status or representation ambiguity
```

## US-RL-03 — Perform Explicitly Destructive Operations

🟢 **CONFIRMED** — As a caller, I want typed reset/workdir/state-cleanup options so that destructive intent is explicit and errors are not hidden.

## US-RL-04 — Manage Worktrees

🟢 **CONFIRMED** — As a multi-worktree application, I want to create, inspect, lock, validate, and prune linked worktrees while retaining independent native ownership.

## US-RL-05 — Operate Safely

🟢 **CONFIRMED** — As a maintainer, I want explicit release plus finalizer fallback and translated native errors so that resource and failure behavior remains consistent.

## Unresolved Persona Need

🔴 **GAP** — Concurrent shared-repository usage, post-free behavior, SHA-256 completeness, and live clone support need explicit product decisions/evidence.

