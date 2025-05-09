import 'dart:ffi';

import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/object.dart' as object_bindings;
import 'package:git2dart/src/bindings/revparse.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// A class for parsing Git revision specifications and finding corresponding objects.
///
/// This class provides methods to parse Git revision strings (specs) and find the
/// corresponding Git objects. It supports various revision string formats as
/// described in the Git documentation.
///
/// For more information about the accepted syntax, see:
/// * [git-rev-parse documentation](https://git-scm.com/docs/git-rev-parse.html#_specifying_revisions)
/// * `man gitrevisions`
///
/// Example:
/// ```dart
/// // Find a commit by its hash
/// final commit = RevParse.single(repo: repo, spec: 'a1b2c3d4') as Commit;
///
/// // Find a tree object
/// final tree = RevParse.single(repo: repo, spec: 'HEAD^{tree}') as Tree;
///
/// // Find a file in a specific commit
/// final blob = RevParse.single(repo: repo, spec: 'HEAD:path/to/file.txt') as Blob;
///
/// // Find a tag
/// final tag = RevParse.single(repo: repo, spec: 'v1.0') as Tag;
///
/// // Find a commit and its reference
/// final revParse = RevParse.ext(repo: repo, spec: 'master@{upstream}');
/// final commit = revParse.object;
/// final reference = revParse.reference;
///
/// // Parse a revision range
/// final range = RevParse.range(repo: repo, spec: 'master..develop');
/// final from = range.from;
/// final to = range.to;
/// final flags = range.flags;
/// ```
class RevParse {
  /// Finds a single object and intermediate reference (if there is one) by a
  /// [spec] revision string.
  ///
  /// This method is particularly useful for expressions that may involve intermediate
  /// references, such as:
  /// * `@{<-n>}` - Previous reflog entry
  /// * `<branchname>@{upstream}` - Upstream branch
  /// * `<branchname>@{push}` - Push destination
  ///
  /// The [object] property will contain the found Git object, and [reference] will
  /// contain any intermediate reference if one was found.
  ///
  /// Throws a [LibGit2Error] if an error occurs during parsing.
  ///
  /// Example:
  /// ```dart
  /// final revParse = RevParse.ext(
  ///   repo: repo,
  ///   spec: 'master@{upstream}',
  /// );
  /// print('Object: ${revParse.object}');
  /// print('Reference: ${revParse.reference}');
  /// ```
  RevParse.ext({required Repository repo, required String spec}) {
    final pointers = bindings.revParseExt(
      repoPointer: repo.pointer,
      spec: spec,
    );
    object = Commit(pointers[0].cast<git_commit>());
    reference =
        pointers.length == 2
            ? Reference(pointers[1].cast<git_reference>())
            : null;
  }

  /// The Git object found by the revision string.
  late final Commit object;

  /// The intermediate reference found by the revision string, if any.
  late final Reference? reference;

  /// Finds a single object as specified by a [spec] revision string.
  ///
  /// This method parses a revision string and returns the corresponding Git object.
  /// The returned object should be explicitly cast to one of the four Git object types:
  /// * [Commit]
  /// * [Tree]
  /// * [Blob]
  /// * [Tag]
  ///
  /// Throws a [LibGit2Error] if an error occurs during parsing.
  ///
  /// Example:
  /// ```dart
  /// // Find a commit
  /// final commit = RevParse.single(repo: repo, spec: 'HEAD') as Commit;
  ///
  /// // Find a tree
  /// final tree = RevParse.single(repo: repo, spec: 'HEAD^{tree}') as Tree;
  ///
  /// // Find a file
  /// final blob = RevParse.single(repo: repo, spec: 'HEAD:file.txt') as Blob;
  ///
  /// // Find a tag
  /// final tag = RevParse.single(repo: repo, spec: 'v1.0') as Tag;
  /// ```
  static Object single({required Repository repo, required String spec}) {
    final object = bindings.revParseSingle(
      repoPointer: repo.pointer,
      spec: spec,
    );
    final objectType = object_bindings.type(object);

    if (objectType == GitObject.commit.value) {
      return Commit(object.cast());
    } else if (objectType == GitObject.tree.value) {
      return Tree(object.cast());
    } else if (objectType == GitObject.blob.value) {
      return Blob(object.cast());
    } else {
      return Tag(object.cast());
    }
  }

  /// Parses a revision string for from, to, and intent.
  ///
  /// This method parses a revision string that specifies a range of commits,
  /// such as `master..develop` or `HEAD~3..HEAD`.
  ///
  /// The returned [RevSpec] contains:
  /// * [from] - The starting commit
  /// * [to] - The ending commit (if specified)
  /// * [flags] - The intent flags for the range
  ///
  /// Throws a [LibGit2Error] if an error occurs during parsing.
  ///
  /// Example:
  /// ```dart
  /// final range = RevParse.range(repo: repo, spec: 'master..develop');
  /// print('From: ${range.from}');
  /// print('To: ${range.to}');
  /// print('Flags: ${range.flags}');
  /// ```
  static RevSpec range({required Repository repo, required String spec}) {
    return RevSpec._(bindings.revParse(repoPointer: repo.pointer, spec: spec));
  }

  @override
  String toString() {
    return 'RevParse{object: $object, reference: $reference}';
  }
}

/// A class representing a Git revision specification range.
///
/// This class contains information about a range of commits specified by a
/// revision string, including the starting and ending commits and any special
/// flags that modify the range's behavior.
class RevSpec {
  /// Creates a new [RevSpec] instance from a pointer to a Git revspec object.
  const RevSpec._(this._revSpecPointer);

  /// The pointer to the Git revspec object in memory.
  final Pointer<git_revspec> _revSpecPointer;

  /// The starting commit of the range.
  Commit get from => Commit(_revSpecPointer.ref.from.cast());

  /// The ending commit of the range, if specified.
  Commit? get to {
    return _revSpecPointer.ref.to == nullptr
        ? null
        : Commit(_revSpecPointer.ref.to.cast());
  }

  /// The intent flags for the range.
  ///
  /// These flags modify how the range should be interpreted. For example,
  /// they might indicate whether the range is inclusive or exclusive.
  Set<GitRevSpec> get flags {
    return GitRevSpec.values
        .where((e) => _revSpecPointer.ref.flags & e.value == e.value)
        .toSet();
  }

  @override
  String toString() {
    return 'RevSpec{from: $from, to: $to, flags: $flags}';
  }
}
