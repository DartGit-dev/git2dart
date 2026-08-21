# Schema do bug.md (schema_version: 1)

Contract shared by all commands on the Reversa Bugs Team. `bug.md` is the source of truth;
everything in `generated/` is projection. References between documents always use the canonical ID, never path.

## Front matter

```yaml
---
schema_version: 1
id: BUG-20260715-A7K3 # BUG-<YYYYMMDD>-<4 base32 chars>, immutable, merge-safe
display_number: 7            # apelido humano; comandos aceitam ID ou display_number
title: Desconto aplicado duas vezes no fechamento do pedido
status: open                 # open | active | resolved (the folder NEVER carries status)
phase: triaging              # triaging | mitigating | reproducing | diagnosing | planning |
                             # testing | patching | delivering | observing | awaiting-human
severity: high               # critical | high | medium | low  (impact size)
priority: P1                 # P0 | P1 | P2 | P3               (fix urgency)
created: 2026-07-15
updated: 2026-07-15

origin:
  type: manual-report        # manual-report | github-issue | gitlab-issue | ci-failure |
                             # telemetry | alert | support | customer | security-advisory |
                             # inspection | other
  external_ref: null # {provider, id} when there is

area: vendas                 # valores de taxonomy.yaml ou unclassified
module: checkout
feature: desconto
labels: []                   # ex.: spec-gap, financeiro

visibility: normal           # normal | internal | restricted (security: excluded from public views)
security_suspected: false

reproduction:
  classification: deterministic   # deterministic | intermittent | environment-dependent |
                                  # not-reproduced | unknown
  rate: "10/10" # failed attempts/attempts
  suspected_triggers: [] # for intermittent

blocking: [] # conditions that stop the bug; is_blocked is DERIVADO, never status
# - kind: bug
#   target: BUG-20260701-Q2R8
# - kind: external
#   reason: "Aguardando credenciais do fornecedor"
#   since: 2026-07-15

relationships: [] # canonical edges, written UMA time; inverses derived in views
# - bug: BUG-20260701-Q2R8
#   type: caused-by          # direcionais: caused-by, blocked-by, duplicate-of, regression-of
#   state: proposed          # proposed | supported | confirmed | rejected
# evidence: [] # required for state >= supported
# symmetric types: related-to, conflicts-with
# prohibited: self-relation, ID non-existent, duplicate-of cycle

traceability:
  specs: [] # locators "path#anchor" in spec EFETIVA (original + current addenda)
  affected_code: [] # where the bug APARECE
  root_cause: null # where the bug NASCEU, with epistemological state (filled by the fix):
  # root_cause:
  #   state: hypothesized    # hypothesized | supported | confirmed | rejected
  #   hypothesis: "..."
  #   causal_path: []
  #   evidence: [{ref, observation}]
  #   code_refs: [{file, symbol, commit}]
  reproduction_tests: []     # provam que o defeito relatado aparece
  regression_tests: [] # protect what cannot be broken again (concepts DISTINTOS)

spec_verdict: null           # spec-correta | spec-desatualizada | spec-gap (recorded HUMAN decision)

change_set: [] # corrective changes typed (populated by fix)
# - id: CHG-001
#   kind: test | code | configuration | migration | data-repair | dependency | infrastructure |
#         feature-flag | api-contract | cache | observability | specification | documentation | other
# artifact: path
#   purpose: frase curta
#   diff: fix/CHG-001.diff

closure:
  policy: local-software     # local-software | package | production-service (do README do registro)
  satisfied: false
resolution_kind: null        # fixed | duplicate | invalid | cannot-reproduce | spec-only |
                             # instrumentation-required
---
```

Optional blocks (only when the context exists): `mitigation` (kind, applied_at, temporary),
`data_impact` / `data_repair` (cured code is not system cured), `regression_analysis`
(last_known_good, first_known_bad, bisect, culprit_commit), `versions` / `backports`,
`ownership` (inferred from CODEOWNERS, never invented; no evidence use unclassified),
`delivery` (branch, PR, CI, merge), `post_fix_observation`, `change_risk`
(low|medium|high rating + reasons).

## Body (sections in order)

1. `# <title>`
2. `## Summary`
3. `## Expected Behavior` (citando a spec efetiva; se spec-gap, dizer explicitamente)
4. `## Actual Behavior`
5. `## Steps to Reproduce`
6. `## Evidence` (paths relative to the bug folder, e.g.: `evidence/fechamento.log`)
7. `## Suspected Area`
8. `## Acceptance Criteria`
9. `## Traceability` (Readable mirror of YAML block)
10. `## Resolution` (populated by fix: root cause, spec verdict passed, resolution_kind,
change set table, code and spec diffs TOGETHER, reproduction and regression tests)
11. `## Agent Notes` (restrictions for those correcting; taxonomy proposals)

## Completion lock (DONE.md)

When the closure policy is satisfied, the fix writes `DONE.md` to the bug folder (data, `resolution_kind`
and the read-only warning). Folder with `DONE.md` is UNTOUCHABLE by any agent: reopening requires the
user remove the lock, or a new bug with `regression-of`.

## Invariants (/reversa-debugger-graph validates and STOPs on error, never fixes silently)

- `status: resolved` exige `resolution_kind` preenchido e `closure.satisfied: true`
- `DONE.md` without `status: resolved`, or `resolved` + `closure.satisfied` without `DONE.md`, is inconsistency
- `resolution_kind: fixed` requires `root_cause.state: confirmed`, non-empty `regression_tests` and populated `spec_verdict`
- Duplicate ID, reference to non-existent ID, self-relationship and `duplicate-of` cycle are errors
- `proposed` relationship never enters automatic prioritization or impact score
