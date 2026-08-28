# Ownership trace

## Allocation and ownership facts

1. `bindings.getByIndex` documents the returned `git_index_entry` as non-modifiable
   and not caller-freed.
2. `Index.operator []`, conflict projections, and `_IndexIterator` all construct
   `IndexEntry` directly from native pointers returned by index APIs. No constructor
   creates an owned copy.
3. `IndexEntry.path` assigns `path.toCharAlloc()` to the native `path` field.
   `toCharAlloc` uses a standalone FFI allocation and attaches neither a finalizer
   nor an explicit disposer to the `IndexEntry`.
4. Reassignment loses the original libgit2-owned path pointer. Repeated assignments
   also lose each earlier Dart allocation. `Index.free` frees the index, not Dart
   allocations introduced by the setter.
5. `IndexEntry.oid` and `IndexEntry.mode` setters write the same borrowed native
   structure. They do not allocate, but mean a path-only guard would not establish
   the required immutable-borrowed invariant.

## Safe proof boundary

The existing value test proves only that mutation appears to work. It does not
observe allocation ownership. The available test runtime has no native allocation
instrumentation, and a destructive lifetime probe could dereference or free
borrowed libgit2 storage. No such probe was run.

## Required repair decision

The repair must choose one coherent contract:

- make all borrowed `IndexEntry` views immutable, which is a public behavioral
  change; or
- introduce an owned mutable copy with explicit, exactly-once disposal for its
  structure and every replaced path allocation, then define how `Index.add` uses
  that copy.

Either choice affects the public mutation contract and needs an independent
ownership review plus allocation instrumentation before implementation.
