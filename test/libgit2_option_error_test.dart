import 'dart:io';

import 'package:git2dart/git2dart.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart' show LibGit2Error;
import 'package:test/test.dart';

void main() {
  group('Libgit2 global option error contract', () {
    test('reproduction: native option failures are exposed', () {
      expect(Libgit2.version, isNotEmpty);

      expect(
        () => Libgit2.setCacheObjectLimit(type: GitObject.invalid, value: 1),
        throwsA(isA<LibGit2Error>()),
      );
    });

    test('uses the delivered error and StateError fallback contract', () {
      final helper =
          File('lib/src/helpers/error_helper.dart').readAsStringSync();
      expect(helper, contains('bindings.getLastError()'));
      expect(
        helper,
        contains("StateError('libgit2 failed without providing an error.')"),
      );

      for (final path in [
        'lib/src/helpers/error_helper.dart',
        'lib/src/bindings/commit.dart',
        'lib/src/bindings/diff.dart',
        'lib/src/bindings/remote_callbacks.dart',
      ]) {
        final source = File(path).readAsStringSync();
        expect(source, isNot(contains('LibGit2Error(')), reason: path);
      }

      final remoteCallbacks =
          File('lib/src/bindings/remote_callbacks.dart').readAsStringSync();
      expect(
        RegExp(r'throwLastError\(\)').allMatches(remoteCallbacks),
        hasLength(2),
      );
    });

    test('regression: every global option call checks its status', () {
      final source = File('lib/src/libgit2.dart').readAsStringSync();
      final calls =
          RegExp('git_libgit2_opts_[a-z0-9_]+').allMatches(source).toList();
      final unchecked = <String>[];

      for (var index = 0; index < calls.length; index++) {
        final call = calls[index];
        final semicolon = source.indexOf(';', call.end);
        final nextCall =
            index + 1 < calls.length ? calls[index + 1].start : source.length;
        final following = source.substring(semicolon + 1, nextCall);

        if (!RegExp(r'^\s*checkErrorAndThrow\(').hasMatch(following)) {
          final line = '${source.substring(0, call.start).split('\n').length}';
          unchecked.add('line $line: ${call.group(0)}');
        }
      }

      expect(calls, hasLength(42));
      expect(
        unchecked,
        isEmpty,
        reason:
            'Every fallible global option call must immediately check its '
            'native status:\n${unchecked.join('\n')}',
      );
    });
  });
}
