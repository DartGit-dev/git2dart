# Requirements: Open Defects Remediation

> Identifier: `004-open-defects-remediation`
> Date: `2026-08-27`
> Origin: explicit user authorization to fix every currently open bug.

## Scope

Remediate the twelve `status: open` records in `reversa/bugs/` without changing
the public Dart API, generated FFI declarations, or supported platform-startup
contract.

## Outcomes

1. Native temporary allocations and libgit2-owned result buffers are released
   on success, failure, and partial-initialization paths.
2. Every fallible native options initializer translates failure before its
   structure is read or passed to libgit2.
3. Concurrent remote operations cannot dispatch callbacks to another
   operation's caller.
4. Repository identity failures are observable as translated native errors,
   while a legitimately absent identity remains distinguishable.
5. Each remediated defect has focused positive and negative regression tests.

## Included bugs

`BUG-20260817-CIKD`, `BUG-20260817-QWMA`, `BUG-20260817-K2RY`,
`BUG-20260817-P5DB`, `BUG-20260817-X4AE`, `BUG-20260817-3PON`,
`BUG-20260817-2TB4`, `BUG-20260817-L8WX`, `BUG-20260817-N4FC`,
`BUG-20260817-Q6JV`, `BUG-20260817-M2VF`, and `BUG-20260817-Y7GX`.

## Compatibility and validation boundary

Existing public signatures and documented explicit mobile initialization remain
unchanged. Local focused tests, formatting, analysis, and the full Windows
suite are necessary but do not prove the supported cross-platform or live
remote matrix; CI evidence is required. Package-level bug closure additionally
requires a specification verdict, merge, and publication of the fixed version.
