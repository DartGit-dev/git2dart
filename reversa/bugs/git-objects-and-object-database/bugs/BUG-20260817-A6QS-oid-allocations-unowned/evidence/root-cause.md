# Root Cause

State: `confirmed`.

Binding adapters return both caller-owned `calloc<git_oid>()` outputs and
parent-owned borrowed `git_oid` pointers. At baseline commit `3b71986`, both
routes enter the same `Oid(Pointer<git_oid>)` constructor, which only stores the
pointer. The wrapper has no ownership marker, finalizer, or manual release
operation.

That type erasure prevents safe cleanup: releasing every pointer would invalidly
free borrowed native storage, while releasing none leaks every owned output.
The candidate commit resolves the ambiguity by copying borrowed values into
owned storage and attaching a finalizer to every high-level `Oid` instance.

The causal path is statically complete and the isolated baseline playback
confirms the missing release contract. Candidate commit `aba8aa7` passes the
focused suite, but still requires Reversa gate review and project-policy negative
coverage before it can be accepted as the final correction.
