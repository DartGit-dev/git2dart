import 'dart:io';
import 'package:git2dart/git2dart.dart';
import 'package:path/path.dart' as p;

/// Copies repository at provided [repoDir] into system's temp directory.
Directory setupRepo(Directory repoDir) {
  Libgit2.ownerValidation = false;
  final tmpDir = Directory.systemTemp.createTempSync('testrepo');
  copyRepo(from: repoDir, to: tmpDir);

  return tmpDir;
}

void copyRepo({required Directory from, required Directory to}) {
  for (final entity in from.listSync()) {
    if (entity is Directory) {
      Directory newDir;
      if (p.basename(entity.path) == '.gitdir') {
        newDir = Directory(p.join(to.absolute.path, '.git'))..createSync();
      } else {
        newDir = Directory(p.join(to.absolute.path, p.basename(entity.path)))
          ..createSync();
      }
      copyRepo(from: entity.absolute, to: newDir);
    } else if (entity is File) {
      if (p.basename(entity.path) == 'gitignore') {
        _copyFixtureFile(entity, File(p.join(to.path, '.gitignore')));
      } else if (p.basename(entity.path) == 'gitattributes') {
        _copyFixtureFile(entity, File(p.join(to.path, '.gitattributes')));
      } else {
        _copyFixtureFile(
          entity,
          File(p.join(to.path, p.basename(entity.path))),
        );
      }
    }
  }
}

void _copyFixtureFile(File source, File destination) {
  final bytes = source.readAsBytesSync();
  if (bytes.contains(0)) {
    destination.writeAsBytesSync(bytes);
    return;
  }

  final normalized = <int>[];
  for (var i = 0; i < bytes.length; i++) {
    if (bytes[i] == 13 && i + 1 < bytes.length && bytes[i + 1] == 10) {
      normalized.add(10);
      i++;
    } else {
      normalized.add(bytes[i]);
    }
  }
  destination.writeAsBytesSync(normalized);
}
