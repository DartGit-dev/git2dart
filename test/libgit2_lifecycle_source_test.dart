import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final productionFiles = _dartFilesUnder(Directory('lib'));

  group('libgit2 lifecycle source contract', () {
    test('reproduction: removes legacy generated binding globals', () {
      final occurrences = _findOccurrences(
        productionFiles,
        RegExp(r'(?<![\\/])\blibgit2(?:Opts)?\s*\.'),
      );

      expect(
        occurrences,
        isEmpty,
        reason:
            'Production must consume libgit2Runtime instead of the removed '
            'libgit2/libgit2Opts globals:\n${occurrences.join('\n')}',
      );
    });

    test('regression: raw lifecycle calls stay outside production', () {
      final occurrences = _findOccurrences(
        productionFiles,
        RegExp(r'\bgit_libgit2_(?:init|shutdown)\s*\('),
      );

      expect(
        occurrences,
        isEmpty,
        reason:
            'Only git2dart_binaries may own raw init/shutdown calls; '
            'git2dart production must use the managed runtime:\n'
            '${occurrences.join('\n')}',
      );
    });
  });
}

List<File> _dartFilesUnder(Directory root) {
  final files =
      root
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => p.extension(file.path) == '.dart')
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return files;
}

List<String> _findOccurrences(List<File> files, RegExp pattern) {
  final occurrences = <String>[];
  for (final file in files) {
    final relativePath = p.relative(file.path);
    final lines = file.readAsLinesSync();
    for (var index = 0; index < lines.length; index++) {
      final match = pattern.firstMatch(lines[index]);
      if (match == null) continue;
      occurrences.add('$relativePath:${index + 1}: ${match.group(0)!}');
    }
  }
  return occurrences;
}
