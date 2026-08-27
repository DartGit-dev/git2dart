import 'dart:io';

import 'package:test/test.dart';

void main() {
  group('Native cleanup contracts', () {
    test('disposes extensions after copying the native string array', () {
      final source = File('lib/src/libgit2.dart').readAsStringSync();

      expect(source, contains('git_strarray_dispose(array)'));
      expect(source, contains('calloc.free(array)'));
    });

    test('releases temporary worktree handles after listing names', () {
      final source = File('lib/src/worktree.dart').readAsStringSync();

      expect(source, contains('for (final worktree in worktrees)'));
      expect(source, contains('bindings.free(worktree)'));
    });

    test('disposes worktree lock reasons on every return path', () {
      final source = File('lib/src/bindings/worktree.dart').readAsStringSync();

      expect(source, contains('git_worktree_is_locked(reason, wt)'));
      expect(source, contains('git_buf_dispose(reason)'));
    });

    test('releases patch-id options when their initializer fails', () {
      final source = File('lib/src/bindings/diff.dart').readAsStringSync();

      expect(
        source,
        contains('Pointer<git_diff_patchid_options> initPatchIdOptions()'),
      );
      expect(source, contains('calloc.free(opts)'));
    });
  });
}
