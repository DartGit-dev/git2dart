import 'package:git2dart/git2dart.dart' as git2dart;
import 'package:git2dart_binaries/git2dart_binaries.dart' as binaries;
import 'package:test/test.dart';

void main() {
  test('public cache option wrapper discards a native failure', () {
    git2dart.Libgit2.version;

    final rawResult = binaries.libgit2Runtime.options
        .git_libgit2_opts_set_cache_object_limit(
          git2dart.GitObject.invalid.value,
          1,
        );

    expect(rawResult, isNegative);
    expect(
      () => git2dart.Libgit2.setCacheObjectLimit(
        type: git2dart.GitObject.invalid,
        value: 1,
      ),
      returnsNormally,
    );

    git2dart.Libgit2.shutdown();
  });
}
