# Code Quality Record (Reversa Refactor)

> GENERATED / MANAGED by the Reversa Code Quality team. This README stores the registry policies.
> Context folders and transformation artifacts are born on demand.

## Policies

- `control_mode`: gated
- `gated` (default): reading, analysis, measurement and proof of behavior flow without approval. EVERY step that touches the project code goes through a gate with approved diff.
- `supervised`: the agent can apply proven low-risk transformations, warning; high risk continues with gate.
- `autonomous`: automatically applies whatever is 🟢 and proven. Even here they have mandatory gate: remove code, change effective spec, send material to external harness, destructive operation.
- `safety_net_policy`: require-characterization
- `require-characterization` (default): transformation that changes structure or logic requires a green safety net (existing tests + characterization) before and after.
- `allow-unproven`: allows transformation without network, always demoted to 🔴 and marked as without mechanical proof in the registry.

## Invariante do registro

No transformation changes observable behavior. What does not prove preservation stops at the gate. Every applied transformation is reversible by the saved diff.

## Estrutura

```
_reversa_refactor/
README.md (this file)
<context>/ (feature, module or use case)
opportunities/ (opportunities detected, one per file)
    transformations/
      OPP-<data>-<sufixo>-<slug>/
plan.html (visual report of the plan, before touching the file)
safety-net/ (characterization tests + green/red result)
before-after/ (evidence: measurement, proof of equivalence, proof of death)
CHG-NNN.diff (diffs applied, revert source)
        transformation.md            (registro conforme opportunity-schema.md)
generated/ (index and catalog regenerable, never edited by hand)
```
