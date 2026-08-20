# Static Evidence

- `lib/src/remote.dart:264-271` performs connect, advertisement read, and disconnect without a protected cleanup block.
- The binding can throw at `git_remote_ls` before line 271 runs.
- Existing negative tests cover connect failure, not post-connect advertisement failure and final connection state.
