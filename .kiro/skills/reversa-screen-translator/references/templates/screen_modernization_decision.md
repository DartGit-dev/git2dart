---
schemaVersion: 1
generatedAt: <ISO-8601>
reversa:
  version: "x.y.z"
kind: screen_modernization_decision
producedBy: screen-translator
decidedBy: <human-id or null when mode=skipped>
decidedAt: <ISO-8601 or null when mode=skipped>
mode: literal | modernized | hybrid | skipped
sourcePlatform: <slug or null when mode=skipped>
targetPlatform: <slug or null when mode=skipped>
hash: "sha256:<body hash below front-matter>"
---

> When `mode: skipped`, this decision **was not passed by human**: it was issued automatically by Screen Translator because the legacy has no UI. Only the "Context" and "Decision" sections are filled in, with the reason for omission; the rest are as N/A. Inspector reads `mode: skipped` in front-matter and skips visual parity without asking.


# Screen Modernization Decision

> Conscious decision on how to translate the legacy system screens: observable byte-to-byte parity, idiomatic redesign for the target platform, or screen-to-screen matching.
> This artifact is mandatory reading for the Screen Translator itself (to generate `target_screens.md`), the Inspector (to build parity tests appropriate to the mode) and the encoding agent.

## Context

- **Detected source platform**: <slug> (for example: `cobol-ansi-tui`, `delphi-vcl`, `asp-classic`, `android-xml`)
- **Confidence**: 🟢 CONFIRMED | 🟡 INFERRED | 🔴 GAP | ⚠️ AMBIGUOUS
- **Plataforma alvo**: <slug> (ex: `go-cli`, `web-spa`, `flutter`, `tauri`)
- **Telas inventariadas**: <N>
- **Inventory origin**: `reversa/sdd/screens/inventory.json` + `reversa/sdd/ui/inventory.md`
- **Adapter aplicado**: `<adapters/origem__alvo>` (ver `references/adapter-pairs.md`)

## Modos avaliados

### Mode: literal
- **Definition**: observable byte-for-byte or pixel-equivalent parity between legacy and new.
- **Trade-offs**:
- Implementation cost: <high ​​| medium | low>
- Visual fidelity: <high ​​| average | download>
- Feasibility of constructive parity tests: <yes | partial | no>
- Expected end user acceptance: <high ​​| average | download>
- Future technical debt: <high ​​| medium | low>
- **Recommended**: <yes | no>
- **Justification**: <short text>

### Mode: modernized
- **Definition**: idiomatic redesign for the target platform, preserving information and flow, but re-expressing hierarchy and interaction.
- **Trade-offs**:
- Implementation cost: <high ​​| medium | low>
- Visual fidelity: <high ​​| average | download>
- Feasibility of constructive parity tests: <yes | partial | no>
- Expected end user acceptance: <high ​​| average | download>
- Future technical debt: <high ​​| medium | low>
- **Recommended**: <yes | no>
- **Justification**: <short text>

### Mode: hybrid
- **Definition**: some of the screens are literal, some are modernized, with explicit lists.
- **Trade-offs**:
- Implementation cost: <high ​​| medium | low>
- Mixed visual fidelity: <description>
- Feasibility of parity tests: <description by subset>
- Separation maintenance cost: <high ​​| medium | low>
- **Recommended**: <yes | no>
- **Justification**: <short text>

## Decision

- **Chosen mode**: <literal | modernized | hybrid>
- **Human rationale**: <text>
- **Alternatives discarded**: <brief list with reason>
- **Decidido em**: <ISO-8601>
- **Decidido por**: <name or identifier>

### In hybrid mode, explicit lists (required)

**Screens in literal mode**:
- <screen 1>
- <screen 2>

**Screens in modernized mode**:
- <screen 3>
- <screen 4>

> Empty lists block Phase 2. Agent refuses to proceed.

## Pending implications for Phase 2

| Step | Implication | How to honor |
|---|---|---|
| Generation of `target_screens.md` | <implication> | <expected action> |
| Golden files capture | <implication> | <expected action> |
| Design-system tokens | <implication> | <expected action> |
| Textual content | Preserve literal unless explicit approval of linguistic revision | <expected action> |

## Implications for the Inspector

- **Parity strategy**:
- Literal mode → observable byte-by-byte/pixel-equivalent parity, validated by golden files when the oracle runs.
- Modernized mode → semantic contract (events, transitions, textual content, states), without byte-by-byte visual comparison.
- Hybrid mode → mixed strategy, declared per screen in `parity_specs.md`.
- **Deviations conhecidas a propagar**: ver `screen_deviation_log.md`.

## Notas

<Additional points that the coder, Inspector and agent need to know to honor the decision. It includes, for example, explicit approval of linguistic revision, tolerance of approximate rendering, or marking of screens that do not allow modernization due to regulatory requirements.>
