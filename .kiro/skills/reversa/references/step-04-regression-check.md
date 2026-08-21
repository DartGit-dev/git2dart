# Step 4, semantic regression check

> This step only runs in **re-extractions**, that is, when a reversa pipeline is executed in a project that has already gone through at least one `/reversa-coding` cycle. In projects without `reversa/forward/` or without `regression-watch.md`, the regression check is silently skipped (the "Addendum Reconciliation" at the end is still checked).

## Por que existe

Reversa is not just one-shot extraction. Each `/reversa-coding` leaves in `reversa/forward/<feature>/regression-watch.md` a list of rules that must remain true in the next extraction. The reversa pipeline, when re-run, has the duty to check these rules against the current code and report regressions. This is the competitive advantage of Reversa compared to pure forward frameworks.

## When to run

After the **last agent in the plan** completes, before the final "extraction complete" message. The trigger is position (last item of `.reversa/plan.md`), not agent name, because the last agent varies depending on the options selected in the install (Reviewer may be absent, for example). Carry out the checks in order:

1. Verify that `reversa/forward/` exists in the project root. If it doesn't exist, skip straight to the "Addendum Reconciliation" section.
2. List all subfolders of `reversa/forward/` that contain `regression-watch.md`.
3. If the list is empty, skip straight to the "Addendum Reconciliation" section.
4. Otherwise, proceed with the procedure below, one feature at a time.

## Procedimento por feature

For each `reversa/forward/<feature>/regression-watch.md`:

1. Load the file. Identify the main watch-item table (columns `ID | Source | Expected rule after change | Verification type | Violation signal`; also accept the legacy Portuguese headers).
2. For each watch item in the main table (not archived ones):
2.1. Identify `Verification type`; possible values are `presence`, `absence`, `wording`, and `confidence`. Accept legacy Portuguese values when reading existing artifacts.
2.2. Apply the corresponding check against the newly generated artifacts in `reversa/sdd/`:
- `presence`: the rule must be present in `reversa/sdd/domain.md` (or in the file pointed to by the Source column) with the same semantic essence.
- `absence`: the original rule must NO longer appear in the SDD.
- `wording`: the text was deliberately changed; check whether the new version meets expectations.
- `confidence`: the rule is still present, but its confidence (🟢, 🟡, 🔴) must be equal to or greater than expected.
   2.3. Atribua um veredito:
        - 🟢 **verde**, a expectativa bateu integralmente.
- 🟡 **yellow**, there is semantic equivalence but the text differs, or the evidence is partial. Default verdict when there is ambiguity. Awaits human judgment.
- 🔴 **red**, expectations did NOT meet. The previously confirmed rule became an injured rule.
3. After evaluating all watch items, update the `## Re-extraction history` section of the same `regression-watch.md` by adding a dated block (also recognize the legacy Portuguese heading when reading):

```
### Re-extraction YYYY-MM-DD HH:MM

| ID | Verdict | Note |
|----|----------|------------|
| W001 | 🟢 green | rule preserved in reversa/sdd/domain.md#rule-X |
| W005 | 🔴 red | rule removed from current code; unintended change |
| W010 | 🟡 yellow | semantically equivalent text differs literally; awaiting judgment |
```

4. DO NOT change the main watch items table. DO NOT recycle IDs. DO NOT move watch items to "Archived" automatically.

5. For each watch item with three consecutive green verdicts in history, and as long as `setup.json#watch.archive-after` allows it, move the item from the main table to the `## Arquivadas` section at the end of the file. Keep the original ID.

## Writing policy

- Atomic writing (tempfile plus rename) in `regression-watch.md`.
- Never rewrite or delete entries from the re-extraction history.
- The new re-extraction block always goes at the top of the `## Re-extraction history` section (descending order).

## User report

After going through all the features, present:

1. Total de features verificadas
2. Total de watch items verificados
3. Quebra por veredito: verdes, amarelos, vermelhos
4. Detailed list of reds (ID, feature, rule, reason for divergence)
5. Detailed list of yellows who asked for human judgment

If there is at least one red, display a prominent warning:

> 🔴 **Attention**, **N semantic regressions** were detected in previously coded features. Review before proceeding.

If `setup.json#watch.block-on-red` is `true`, suggest the user **not** proceed with new `/reversa-requirements` until each red is sorted. Reversa only alerts, it never automatically blocks the user's flow.

## Addendum reconciliation

After scrolling through the features (or even if none have `regression-watch.md`), check if there is `reversa/sdd/addenda/` with files `.md` created by `/reversa-sync`. If it exists:

1. For each addendum whose `## Validity` section (or legacy `## Vigência`) does NOT contain `Superseded by the re-extraction of ...` or its legacy Portuguese equivalent, add this line at the end of the section:

   ```
Superseded by the re-extraction of YYYY-MM-DD.
   ```

2. Never delete the addendum, never rewrite the previous lines of the Validity section, never touch the other sections. Append-only, atomic writing.
3. Addenda already exceeded in previous re-extractions remain as they are (they are historical).
4. Include in the report to the user how many addenda were marked as obsolete in this re-extraction.

The reason: addenda are bridges between a forward delivery and re-extraction. With the extract regenerated from the current code, the deltas described in the addenda are already absorbed into the main artifacts, and consumers (for example `/reversa-requirements` and `/reversa-plan`) should only consider current addenda.

## Special case, without `reversa/sdd/`

If during the procedure `reversa/sdd/` does not have the expected files (because the re-extraction was partial or the documentation level was reduced), record a 🟡 yellow verdict with the note `missing evidence; reversa/sdd/<file> was not generated in this extraction` and move on.

## Lacuna conhecida

Semantic equivalence between expected rule and extracted rule is subjective evaluation. When in doubt, choose a yellow verdict. Red verdict should be reserved for cases where the rule simply disappeared or was explicitly contradicted.
