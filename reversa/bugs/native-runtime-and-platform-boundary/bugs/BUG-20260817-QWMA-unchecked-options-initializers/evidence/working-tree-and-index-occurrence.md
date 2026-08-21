# Working Tree and Index Occurrence

- `lib/src/bindings/diff.dart:862` calls `git_diff_options_init` without checking its status before using the options.
- `lib/src/bindings/diff.dart:315` does the same for patch-ID options.
- `lib/src/bindings/checkout.dart:49`, `:81`, `:113`, `:149`, and `:185` ignore checkout-options initializer results.
- `lib/src/bindings/stash.dart:52`, `:97`, and `:156` ignore stash initializer results.

This is the same unchecked-initializer mechanism already tracked by BUG-20260817-QWMA, so no duplicate bug was created.
