# Working Tree and Index Occurrence

- `lib/src/bindings/diff.dart:422-646` stores callback output in process-global lists used by print, foreach, and direct-diff operations.
- `lib/src/bindings/checkout.dart:12-29` stores checkout progress and performance callbacks in process-global variables.
- `lib/src/bindings/stash.dart:176-230` uses a process-global list for stash iteration.

Overlapping operations can overwrite or interleave operation-specific state. This extends the same cross-operation mechanism tracked by BUG-20260817-CIKD.
