# User Stories — History and Integration Operations

> 🟢 **CONFIRMED** — Stories represent graph inspection and stateful integration workflows.

## US-HI-01 — Resolve and Walk History

🟢 **CONFIRMED** — As a history tool, I want revision expressions and configurable walks so that I can obtain typed ordered commits from selected roots and exclusions.

## US-HI-02 — Choose Merge Policy from Analysis

🟢 **CONFIRMED** — As a Git client, I want merge analysis before mutation so that up-to-date, fast-forward, unborn, and normal merge paths remain distinct.

## US-HI-03 — Rebase Sequentially

🟢 **CONFIRMED** — As an application, I want next/resolve/commit/finish/abort rebase operations so that conflicts block progress and recovery remains explicit.

```gherkin
Dado an in-progress rebase with a conflicting operation
Quando the caller resolves the index and commits the current operation
Então rebase may advance to the next operation and eventually finish
```

## US-HI-04 — Inspect Attribution and Metadata

🟢 **CONFIRMED** — As a review tool, I want blame, notes, mailmap, and message trailers so that history context is available as typed data.

## US-HI-05 — Package and Manage Nested Repositories

🟢 **CONFIRMED** — As a distribution tool, I want packbuilder and submodule lifecycle APIs so that object packaging and nested repository state are controlled.

## Unresolved Persona Need

🔴 **GAP** — Crash recovery, retry idempotency, partial submodule/pack state, and live nested transport require dynamic evidence.
