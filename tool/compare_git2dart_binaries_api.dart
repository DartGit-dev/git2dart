import 'dart:io';

const _packageName = 'git2dart_binaries';

Future<void> main(List<String> arguments) async {
  try {
    final options = _Options.parse(arguments);
    if (options.showHelp) {
      stdout.write(_usage);
      return;
    }

    final repositoryRoot = File.fromUri(Platform.script).parent.parent;
    final oldInput = options.oldReference ?? _readBaseline(repositoryRoot);
    final newInput = options.newReference ?? _readLockedVersion(repositoryRoot);
    final oldReference = _asPackageReference(oldInput);
    final newReference = _asPackageReference(newInput);
    final output =
        options.outputPath == null
            ? null
            : _absoluteFile(repositoryRoot, options.outputPath!);
    output?.parent.createSync(recursive: true);

    final toolDirectory = Directory.fromUri(
      repositoryRoot.uri.resolve('tool/api_diff/'),
    );
    await _run(
      Platform.resolvedExecutable,
      const ['pub', 'get'],
      workingDirectory: toolDirectory.path,
      description: 'Preparing the API comparison tool',
    );

    stdout.writeln('Comparing $oldReference with $newReference...');
    final reportArguments =
        output == null
            ? const ['--report-format', 'cli']
            : [
              '--report-format',
              'markdown',
              '--report-file-path',
              output.path,
            ];
    await _run(
      Platform.resolvedExecutable,
      [
        'run',
        'dart_apitool:main',
        'diff',
        '--old',
        oldReference,
        '--new',
        newReference,
        '--version-check-mode',
        'none',
        ...reportArguments,
      ],
      workingDirectory: toolDirectory.path,
      description: 'Comparing package APIs',
    );

    if (output != null) {
      stdout.writeln('API change report: ${output.path}');
    }
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln();
    stderr.write(_usage);
    exitCode = 64;
  } on _CommandException catch (error) {
    stderr.writeln(error.message);
    exitCode = error.exitCode;
  } on FileSystemException catch (error) {
    stderr.writeln(error.message);
    exitCode = 66;
  }
}

String _readBaseline(Directory repositoryRoot) {
  final file = File.fromUri(
    repositoryRoot.uri.resolve('tool/api_diff/git2dart_binaries.baseline'),
  );
  if (!file.existsSync()) {
    throw const FileSystemException(
      'The git2dart_binaries API baseline file is missing.',
    );
  }

  final version = file.readAsStringSync().trim();
  if (version.isEmpty) {
    throw const FormatException('The git2dart_binaries API baseline is empty.');
  }
  return version;
}

String _readLockedVersion(Directory repositoryRoot) {
  final lockFile = File.fromUri(repositoryRoot.uri.resolve('pubspec.lock'));
  if (!lockFile.existsSync()) {
    throw const FileSystemException(
      'pubspec.lock is missing. Run "flutter pub get" or pass --new.',
    );
  }

  final lines = lockFile.readAsLinesSync();
  var insidePackage = false;
  for (final line in lines) {
    if (line == '  $_packageName:') {
      insidePackage = true;
      continue;
    }
    if (insidePackage && line.startsWith('  ') && !line.startsWith('    ')) {
      break;
    }
    if (insidePackage) {
      final match = RegExp(
        r'''^    version: ["']?([^"']+)["']?$''',
      ).firstMatch(line);
      if (match != null) {
        return match.group(1)!;
      }
    }
  }

  throw const FormatException(
    'pubspec.lock does not contain a git2dart_binaries version. '
    'Run "flutter pub get" or pass --new.',
  );
}

String _asPackageReference(String input) {
  final version = RegExp(
    r'^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$',
  );
  return version.hasMatch(input) ? 'pub://$_packageName/$input' : input;
}

File _absoluteFile(Directory repositoryRoot, String path) {
  final file = File(path);
  return file.isAbsolute
      ? file
      : File.fromUri(repositoryRoot.uri.resolve(path));
}

Future<void> _run(
  String executable,
  List<String> arguments, {
  required String workingDirectory,
  required String description,
}) async {
  stdout.writeln('$description...');
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    mode: ProcessStartMode.inheritStdio,
  );
  final result = await process.exitCode;
  if (result != 0) {
    throw _CommandException('$description failed.', result);
  }
}

final class _Options {
  const _Options({
    this.oldReference,
    this.newReference,
    this.outputPath,
    this.showHelp = false,
  });

  factory _Options.parse(List<String> arguments) {
    String? oldReference;
    String? newReference;
    String? outputPath;
    var showHelp = false;

    for (var index = 0; index < arguments.length; index++) {
      final argument = arguments[index];
      switch (argument) {
        case '--old':
          oldReference = _valueAfter(arguments, ++index, argument);
        case '--new':
          newReference = _valueAfter(arguments, ++index, argument);
        case '--output':
          outputPath = _valueAfter(arguments, ++index, argument);
        case '--help' || '-h':
          showHelp = true;
        default:
          throw FormatException('Unknown argument: $argument');
      }
    }

    return _Options(
      oldReference: oldReference,
      newReference: newReference,
      outputPath: outputPath,
      showHelp: showHelp,
    );
  }

  final String? oldReference;
  final String? newReference;
  final String? outputPath;
  final bool showHelp;
}

String _valueAfter(List<String> arguments, int index, String option) {
  if (index >= arguments.length || arguments[index].startsWith('-')) {
    throw FormatException('Missing value for $option.');
  }
  return arguments[index];
}

final class _CommandException implements Exception {
  const _CommandException(this.message, this.exitCode);

  final String message;
  final int exitCode;
}

const _usage = '''
Compare git2dart_binaries public APIs.

Usage:
  dart run tool/compare_git2dart_binaries_api.dart [options]

Options:
  --old <version-or-ref>  Old API. Defaults to the checked-in baseline.
  --new <version-or-ref>  New API. Defaults to the version in pubspec.lock.
  --output <path>         Write a Markdown report instead of printing the diff.
  -h, --help              Show this help.

A plain version is converted to pub://git2dart_binaries/<version>. Paths and
complete pub:// or git:// package references are passed to dart_apitool as-is.
Without --output, API changes are printed directly to standard output.
''';
