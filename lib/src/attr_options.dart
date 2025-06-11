import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// Wrapper around libgit2's [git_attr_options] structure.
///
/// This class allocates and manages memory for the underlying options
/// structure. Call [free] when done to release the memory.
@immutable
class AttrOptions {
  /// Create attribute options with optional [flags] and [commit].
  AttrOptions({
    Set<GitAttributeCheck> flags = const {GitAttributeCheck.fileThenIndex},
    Oid? commit,
  }) {
    _pointer = calloc<git_attr_options>();
    _pointer.ref
      ..version = GIT_ATTR_OPTIONS_VERSION
      ..flags = flags.fold(0, (acc, e) => acc | e.value);
    if (commit != null) {
      _pointer.ref.commit_id = commit.pointer;
      _pointer.ref.attr_commit_id = commit.pointer.ref;
    } else {
      _pointer.ref.commit_id = nullptr;
    }
    _finalizer.attach(this, _pointer, detach: this);
  }

  late final Pointer<git_attr_options> _pointer;

  /// Pointer to the underlying C structure.
  @internal
  Pointer<git_attr_options> get pointer => _pointer;

  /// Free memory allocated for these options.
  void free() {
    _finalizer.detach(this);
    calloc.free(_pointer);
  }
}

// coverage:ignore-start
final _finalizer = Finalizer<Pointer<git_attr_options>>(
  (pointer) => calloc.free(pointer),
);
// coverage:ignore-end
