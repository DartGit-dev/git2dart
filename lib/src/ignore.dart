import 'package:git2dart/src/bindings/ignore.dart' as bindings;
import 'package:git2dart/src/repository.dart';

/// Utilities for working with repository ignore rules.
class Ignore {
  Ignore._(); // coverage:ignore-line

  /// Adds in-memory ignore [rules] to [repo].
  ///
  /// Multiple rules may be separated by newlines. These rules are not persisted
  /// to disk and are cleared with [clearInternalRules].
  static void addRule({required Repository repo, required String rules}) {
    bindings.addRule(repoPointer: repo.pointer, rules: rules);
  }

  /// Clears in-memory ignore rules added with [addRule].
  static void clearInternalRules(Repository repo) {
    bindings.clearInternalRules(repo.pointer);
  }

  /// Returns whether [path] is ignored in [repo].
  ///
  /// The [path] must be relative to the repository workdir.
  static bool pathIsIgnored({required Repository repo, required String path}) {
    return bindings.pathIsIgnored(repoPointer: repo.pointer, path: path);
  }
}
