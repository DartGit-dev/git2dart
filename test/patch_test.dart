import 'dart:ffi';
import 'dart:io';
import 'dart:convert';

import 'package:git2dart/git2dart.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'helpers/util.dart';

void main() {
  late Repository repo;
  late Directory tmpDir;
  const oldBuffer = '';
  const newBuffer = 'Feature edit\n';
  late Oid oldBlobOid;
  late Oid newBlobOid;
  const path = 'feature_file';
  const blobPatch = """
diff --git a/feature_file b/feature_file
index e69de29..9c78c21 100644
--- a/feature_file
+++ b/feature_file
@@ -0,0 +1 @@
+Feature edit
""";

  const blobPatchAdd = """
diff --git a/feature_file b/feature_file
new file mode 100644
index 0000000..9c78c21
--- /dev/null
+++ b/feature_file
@@ -0,0 +1 @@
+Feature edit
""";

  const blobPatchDelete = """
diff --git a/feature_file b/feature_file
deleted file mode 100644
index e69de29..0000000
--- a/feature_file
+++ /dev/null
""";

  setUp(() {
    tmpDir = setupRepo(Directory(p.join('test', 'assets', 'test_repo')));
    repo = Repository.open(tmpDir.path);
    oldBlobOid = repo['e69de29bb2d1d6434b8b29ae775ad8c2e48c5391'];
    newBlobOid = repo['9c78c21d6680a7ffebc76f7ac68cacc11d8f48bc'];
  });

  tearDown(() {
    tmpDir.deleteSync(recursive: true);
  });

  group('Patch', () {
    test('creates from buffers', () {
      final patch = Patch.fromBuffers(
        oldBuffer: oldBuffer,
        newBuffer: newBuffer,
        oldBufferPath: path,
        newBufferPath: path,
      );

      expect(patch.size(), 14);
      expect(patch.text, blobPatch);
      expect(patch.textBytes, utf8.encode(blobPatch));
    });

    test('creates from one buffer (add)', () {
      final patch = Patch.fromBuffers(
        oldBuffer: null,
        newBuffer: newBuffer,
        oldBufferPath: path,
        newBufferPath: path,
      );

      expect(patch.text, blobPatchAdd);
    });

    test('creates from one buffer (delete)', () {
      final patch = Patch.fromBuffers(
        oldBuffer: oldBuffer,
        newBuffer: null,
        oldBufferPath: path,
        newBufferPath: path,
      );

      expect(patch.text, blobPatchDelete);
    });

    test('creates from blobs', () {
      final patch = Patch.fromBlobs(
        oldBlob: Blob.lookup(repo: repo, oid: oldBlobOid),
        newBlob: Blob.lookup(repo: repo, oid: newBlobOid),
        oldBlobPath: path,
        newBlobPath: path,
      );

      expect(patch.text, blobPatch);
    });

    test('creates from one blob (add)', () {
      final patch = Patch.fromBlobs(
        oldBlob: null,
        newBlob: Blob.lookup(repo: repo, oid: newBlobOid),
        oldBlobPath: path,
        newBlobPath: path,
      );

      expect(patch.text, blobPatchAdd);
    });

    test('creates from one blob (delete)', () {
      final patch = Patch.fromBlobs(
        oldBlob: Blob.lookup(repo: repo, oid: oldBlobOid),
        newBlob: null,
        oldBlobPath: path,
        newBlobPath: path,
      );

      expect(patch.text, blobPatchDelete);
    });

    test('creates from blob and buffer', () {
      final patch = Patch.fromBlobAndBuffer(
        blob: Blob.lookup(repo: repo, oid: oldBlobOid),
        buffer: newBuffer,
        blobPath: path,
        bufferPath: path,
      );

      expect(patch.text, blobPatch);
    });

    test('creates from empty blob and buffer', () {
      final patch = Patch.fromBlobAndBuffer(
        blob: null,
        buffer: newBuffer,
        blobPath: path,
        bufferPath: path,
      );

      expect(patch.text, blobPatchAdd);
    });

    test('throws when trying to create from diff and error occurs', () {
      expect(
        () => Patch.fromDiff(diff: Diff(nullptr), index: 0),
        throwsA(isA<LibGit2Error>()),
      );
    });

    test('throws when trying to get text of patch and error occurs', () {
      expect(() => Patch(nullptr).text, throwsA(isA<LibGit2Error>()));
    });

    test('returns hunks in a patch', () {
      final patch = Patch.fromBuffers(
        oldBuffer: oldBuffer,
        newBuffer: newBuffer,
        oldBufferPath: path,
        newBufferPath: path,
      );
      final hunk = patch.hunks[0];

      expect(patch.hunks.length, 1);
      expect(hunk.linesCount, 1);
      expect(hunk.oldStart, 0);
      expect(hunk.oldLines, 0);
      expect(hunk.newStart, 1);
      expect(hunk.newLines, 1);
      expect(hunk.header, '@@ -0,0 +1 @@\n');
    });

    test('returns lines in a hunk', () {
      final patch = Patch.fromBuffers(
        oldBuffer: oldBuffer,
        newBuffer: newBuffer,
        oldBufferPath: path,
        newBufferPath: path,
      );
      final hunk = patch.hunks[0];
      final line = hunk.lines[0];

      expect(hunk.lines.length, 1);
      expect(line.origin, GitDiffLine.addition);
      expect(line.oldLineNumber, -1);
      expect(line.newLineNumber, 1);
      expect(line.numLines, 1);
      expect(line.contentOffset, 0);
      expect(line.content, 'Feature edit\n');
    });

    test('returns line counts of each type in a patch', () {
      final patch = Patch.fromBuffers(
        oldBuffer: oldBuffer,
        newBuffer: newBuffer,
        oldBufferPath: path,
        newBufferPath: path,
      );

      final stats = patch.stats;
      expect(stats.context, equals(0));
      expect(stats.insertions, equals(1));
      expect(stats.deletions, equals(0));
      expect(stats.toString(), contains('PatchStats{'));
    });

    test('manually releases allocated memory', () {
      final patch = Patch.fromBuffers(
        oldBuffer: oldBuffer,
        newBuffer: newBuffer,
        oldBufferPath: path,
        newBufferPath: path,
      );
      expect(() => patch.free(), returnsNormally);
    });

    test(
      'returns string representation of Patch, DiffHunk and DiffLine objects',
      () {
        final patch = Patch.fromBuffers(
          oldBuffer: oldBuffer,
          newBuffer: newBuffer,
          oldBufferPath: path,
          newBufferPath: path,
        );

        expect(patch.toString(), contains('Patch{'));
        expect(patch.hunks[0].toString(), contains('DiffHunk{'));
        expect(patch.hunks[0].lines[0].toString(), contains('DiffLine{'));
      },
    );

    test('supports value comparison', () {
      final patch = Patch.fromBuffers(
        oldBuffer: oldBuffer,
        newBuffer: newBuffer,
        oldBufferPath: path,
        newBufferPath: path,
      );
      final anotherPatch = Patch.fromBuffers(
        oldBuffer: oldBuffer,
        newBuffer: newBuffer,
        oldBufferPath: path,
        newBufferPath: path,
      );
      expect(patch, equals(anotherPatch));
      expect(patch.hunks[0], equals(patch.hunks[0]));

      final hunk = patch.hunks[0];
      expect(hunk.lines[0], equals(hunk.lines[0]));
    });

    test('creates patch from binary blobs', () {
      final bytes1 = [0x00, 0x01, 0x02, 0x03];
      final bytes2 = [0x00, 0x01, 0x02, 0x04];
      final oldFile = File(p.join(repo.workdir, 'old.bin'))..writeAsBytesSync(bytes1);
      final newFile = File(p.join(repo.workdir, 'new.bin'))..writeAsBytesSync(bytes2);
      final oldBlob = Blob.lookup(
        repo: repo,
        oid: Blob.createFromDisk(repo: repo, path: oldFile.path),
      );
      final newBlob = Blob.lookup(
        repo: repo,
        oid: Blob.createFromDisk(repo: repo, path: newFile.path),
      );
      final patch = Patch.fromBlobs(
        oldBlob: oldBlob,
        newBlob: newBlob,
        oldBlobPath: 'old.bin',
        newBlobPath: 'new.bin',
      );

      expect(patch.text, contains('Binary files'));
      expect(patch.textBytes, utf8.encode(patch.text));
    });
  });
}
