import 'package:git2dart/git2dart.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart' show LibGit2Error;
import 'package:test/test.dart';

void main() {
  group('Libgit2 global option errors', () {
    test('exposes native failures and remains usable afterwards', () {
      expect(Libgit2.version, isNotEmpty);

      expect(
        () => Libgit2.setCacheObjectLimit(type: GitObject.invalid, value: 1),
        throwsA(isA<LibGit2Error>()),
      );
      expect(
        () => Libgit2.setCacheObjectLimit(type: GitObject.blob, value: 0),
        returnsNormally,
      );
    });
  });
}
