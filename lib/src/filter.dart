import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/filter.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// Wrapper around libgit2's [git_filter_options] structure.
///
/// Allocates and manages memory for filter options. Call [free] when done to
/// release the memory.
@immutable
class FilterOptions {
  /// Create filter options with optional [flags] and [commit].
  FilterOptions({
    Set<GitFilterFlag> flags = const {GitFilterFlag.defaults},
    Oid? commit,
  }) {
    _pointer = calloc<git_filter_options>();
    _pointer.ref
      ..version = GIT_FILTER_OPTIONS_VERSION
      ..flags = flags.fold(0, (acc, e) => acc | e.value)
      ..commit_id = commit?.pointer ?? nullptr;
    _optionsFinalizer.attach(this, _pointer, detach: this);
  }

  late final Pointer<git_filter_options> _pointer;

  /// Pointer to the underlying C structure.
  @internal
  Pointer<git_filter_options> get pointer => _pointer;

  /// Free memory allocated for these options.
  void free() {
    _optionsFinalizer.detach(this);
    calloc.free(_pointer);
  }
}

// coverage:ignore-start
final _optionsFinalizer = Finalizer<Pointer<git_filter_options>>(
  (pointer) => calloc.free(pointer),
);
// coverage:ignore-end

/// High level wrapper around libgit2's [git_filter_list].
///
/// Instances of this class hold a list of filters that can be applied to
/// arbitrary data, files on disk or blobs.
@immutable
class Filter {
  /// Loads filter list for a given [path] in [repo].
  ///
  /// [blob] can be provided to apply filters as if the content of the blob was
  /// in the file at [path].
  ///
  /// Throws a [LibGit2Error] if error occurred.
  factory Filter.load({
    required Repository repo,
    Blob? blob,
    required String path,
    required GitFilterMode mode,
    Set<GitFilterFlag> flags = const {GitFilterFlag.defaults},
  }) {
    final pointer = bindings.load(
      repoPointer: repo.pointer,
      blobPointer: blob?.pointer,
      path: path,
      mode: git_filter_mode_t.fromValue(mode.value),
      flags: flags.fold<int>(0, (acc, e) => acc | e.value),
    );
    return Filter._(pointer);
  }

  /// Loads filter list with extended options for a given [path] in [repo].
  ///
  /// Throws a [LibGit2Error] if error occurred.
  factory Filter.loadExt({
    required Repository repo,
    Blob? blob,
    required String path,
    required GitFilterMode mode,
    required FilterOptions options,
  }) {
    final pointer = bindings.loadExt(
      repoPointer: repo.pointer,
      blobPointer: blob?.pointer,
      path: path,
      mode: git_filter_mode_t.fromValue(mode.value),
      options: options.pointer,
    );
    return Filter._(pointer);
  }

  Filter._(this._filterListPointer) {
    _finalizer.attach(this, _filterListPointer, detach: this);
  }

  /// Pointer to memory address for allocated filter list object.
  final Pointer<git_filter_list> _filterListPointer;

  /// Apply filter list to arbitrary [data].
  ///
  /// Returns filtered data as string.
  String applyToData(String data) =>
      bindings.applyToData(filterListPointer: _filterListPointer, buffer: data);

  /// Apply filter list to a file on disk located at [path] in [repo].
  String applyToFile({required Repository repo, required String path}) =>
      bindings.applyToFile(
        repoPointer: repo.pointer,
        filterListPointer: _filterListPointer,
        path: path,
      );

  /// Apply filter list to a [blob].
  String applyToBlob(Blob blob) => bindings.applyToBlob(
    filterListPointer: _filterListPointer,
    blobPointer: blob.pointer,
  );

  /// Query whether a filter named [name] will run.
  bool contains(String name) =>
      bindings.contains(filterListPointer: _filterListPointer, name: name);

  /// Releases memory allocated for filter list object.
  void free() {
    bindings.free(_filterListPointer);
    _finalizer.detach(this);
  }

  @override
  String toString() => 'Filter{pointer: $_filterListPointer}';
}

// coverage:ignore-start
final _finalizer = Finalizer<Pointer<git_filter_list>>(
  (pointer) => bindings.free(pointer),
);
// coverage:ignore-end
