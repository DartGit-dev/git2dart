# Trust Rating Rules

Use this scale for **every** statement in the specs. No exceptions.

## Settings

| Symbol | Name | Meaning |
|---------|------|-------------|
| 🟢 | CONFIRMED | Extracted directly from the code — can be cited with file and line |
| 🟡 | INFERRED | Deduced from patterns, names, conventions, or context — may be wrong |
| 🔴 | GAP | Unable to determine from code — requires human validation |

## When to use each level

### 🟢 CONFIRMADO
- The behavior is explicit in the code (if/else, return, throw)
- The value is a constant or enum defined in the code
- The rule is in a descriptive comment next to the relevant code
- There is an automated test that covers exactly this behavior
- DDL/migration defines the constraint directly

### 🟡 INFERIDO
- The function/variable name suggests the behavior, but there is no explicit logic
- The behavior is consistent with framework conventions (e.g. soft delete in Eloquent)
- There are clues in the code but the complete logic is not visible in the analyzed scope
- The rule was inferred from multiple similar examples, not a single definition
- Old comment or TODO that may not reflect the current state

### 🔴 LACUNA
- Functionality is referenced but not implemented in visible code
- The logic depends on external configuration that is not accessible (environment variable, bank, API)
- The expected behavior contradicts what is in the code (possible bug or hidden logic)
- Code generated or compiled without access to the original source
- Business rule that only exists in the minds of stakeholders

---

## Reclassification during review

### Upgrade: 🟡 → 🟢
Conditions: find direct evidence in the code that confirms the statement.
Action: Note the evidence (file + line) in the spec.

### Upgrade: 🔴 → 🟡
Conditions: find sufficient evidence for a reasonable inference.
Action: Reframe the statement as inference, not certainty.

### Upgrade: 🔴 → 🟢
Conditions: the user confirms with concrete evidence (e.g. "yes, that's the rule").
Action: Update the spec and record the commit.

### Downgrade: 🟢 → 🟡
Conditions: find contradiction between the spec and the real code.
Action: flag the contradiction and reclassify.

### Downgrade: 🟡 → 🔴
Conditions: find evidence that the inference was wrong.
Action: Reclassify and create question for the user if necessary.

---

## Rule of thumb

**When in doubt, use the lowest level.**
An honest 🔴 is more useful than a deceitful 🟡.
