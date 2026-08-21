# Debate Convergence Audit

## Round 0

- Quorum: `3/3` valid local solver proposals.
- Strong convergence: all solvers propose one synchronous lexical helper that
  owns callback installation and guarantees `reset()` in `finally`.
- Strong convergence: all keep the native call and immediate
  `checkErrorAndThrow` inside the protected closure so cleanup cannot precede
  error capture.
- Strong convergence: all migrate the same six operation families and leave
  process-static callback concurrency out of scope.
- Main disagreement: solver 1 folds credential-payload arena ownership from
  related bug 47ZS into the lifecycle primitive; solvers 2 and 3 keep O3B3
  strictly limited to Dart callback-state cleanup to avoid cross-bug coupling.
- Secondary disagreement: breadth of per-call-site runtime tests versus a
  smaller helper-focused matrix plus representative native failures.
- Normalization note: tool-generated kernel-context footers after the required
  proposal sections are non-substantive execution metadata and are ignored.

## Round 1

- Quorum: `3/3` valid final solver proposals.
- Full convergence: use one internal synchronous generic helper whose `try`
  begins before callback installation and whose `finally` performs pure-Dart
  `reset()`.
- Full convergence: migrate remote connect/fetch/push, repository clone, and
  submodule update/clone; keep native call plus immediate error translation
  inside the protected operation.
- Full convergence: keep credential payload allocation under separate bug
  47ZS and keep process-static concurrency under separate bug CIKD.
- Remaining variation is limited to test breadth: exhaustive per-call-site
  native failures versus helper tests plus representative family coverage.
- Confidence reported by all solvers: high (`0.94` where quantified).
