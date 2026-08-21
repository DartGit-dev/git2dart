# History and Integration Occurrence

`lib/src/merge.dart` calls `git_libgit2_init` inside the public in-memory merge-file operation without a matching shutdown. This is the same refcount imbalance tracked by BUG-20260817-ZC7X.
