import 'dart:io';
import 'dart:isolate';

import 'package:git2dart/git2dart.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart' as binaries;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'helpers/util.dart';

void main() {
  group('Libgit2 managed lifecycle consumer', () {
    test(
      'reproduction: repeated public calls reuse one native lease',
      () async {
        final result = await Isolate.run(_exerciseStableCount);
        final countWithLease = result['countWithLease']! as int;

        expect(result['version'], isNotEmpty);
        expect(result['featuresPresent'], isTrue);
        expect(result['afterVersion'], countWithLease);
        expect(result['afterFeatures'], countWithLease);
        expect(result['afterGlobalOption'], countWithLease);
        expect(result['countAfterShutdown'], countWithLease - 1);
        expect(result['countAfterRepeatedShutdown'], countWithLease - 1);
        expect(result['repeatedShutdownResult'], result['shutdownResult']);
        expect(result['postShutdownRejected'], isTrue);
      },
    );

    test('negative: a live root owner rejects shutdown unchanged', () async {
      final result = await Isolate.run(_exerciseLiveRootOwner);

      expect(result['shutdownError'], 'StateError');
      expect(result['countAfterRejected'], result['countBeforeRejected']);
      expect(result['repositoryStillUsable'], isTrue);
      expect(
        result['countAfterShutdown'],
        (result['countWithLease']! as int) - 1,
      );
    });

    test('regression: an owned child outlives its released parent', () async {
      final result = await Isolate.run(_exerciseDerivedChildOwner);

      expect(result['commitStillUsable'], isTrue);
      expect(result['shutdownError'], 'StateError');
      expect(result['countAfterRejected'], result['countBeforeRejected']);
      expect(
        result['countAfterShutdown'],
        (result['countWithLease']! as int) - 1,
      );
    });

    test('constructor failure rolls back its provisional owner', () async {
      final result = await Isolate.run(_exerciseConstructorRollback);

      expect(result['constructorError'], 'LibGit2Error');
      expect(result['liveOwnersAfterFailure'], 0);
      expect(
        result['countAfterShutdown'],
        (result['countWithLease']! as int) - 1,
      );
    });

    test('stream transfer completes its owner without destruction', () async {
      final result = await Isolate.run(_exerciseStreamTransfer);

      expect(result['oidLength'], greaterThanOrEqualTo(40));
      expect(result['liveOwnersBeforeShutdown'], 0);
      expect(result['shutdownSucceededWithTransferredStreamAlive'], isTrue);
      expect(
        result['countAfterShutdown'],
        (result['countWithLease']! as int) - 1,
      );
    });

    test('two isolates own and release independent native leases', () async {
      final result = await Isolate.run(_exerciseTwoIsolates);
      final countWithCoordinatorLease =
          result['countWithCoordinatorLease']! as int;

      expect(result['afterFirst'], countWithCoordinatorLease + 1);
      expect(result['afterSecond'], countWithCoordinatorLease + 2);
      expect(result['afterFirstShutdown'], countWithCoordinatorLease + 1);
      expect(result['secondStillUsable'], isTrue);
      expect(result['afterSecondShutdown'], countWithCoordinatorLease);
      expect(result['afterCoordinatorShutdown'], countWithCoordinatorLease - 1);
    });
  });
}

int _probeInitializationCount(binaries.Libgit2 rawBindings) {
  final count = rawBindings.git_libgit2_init();
  final restored = rawBindings.git_libgit2_shutdown();
  if (restored != count - 1) {
    throw StateError(
      'Lifecycle probe failed to restore the native count: $count -> $restored',
    );
  }
  return count;
}

Map<String, Object?> _exerciseStableCount() {
  final rawBindings = binaries.libgit2Runtime.bindings;
  final countWithLease = _probeInitializationCount(rawBindings);
  final version = Libgit2.version;
  final afterVersion = _probeInitializationCount(rawBindings);
  final featuresPresent = Libgit2.features.isNotEmpty;
  final afterFeatures = _probeInitializationCount(rawBindings);
  final ownerValidation = Libgit2.ownerValidation;
  final afterGlobalOption = _probeInitializationCount(rawBindings);

  final shutdownResult = Libgit2.shutdown();
  final countAfterShutdown = _probeInitializationCount(rawBindings);
  final repeatedShutdownResult = Libgit2.shutdown();
  final countAfterRepeatedShutdown = _probeInitializationCount(rawBindings);

  var postShutdownRejected = false;
  try {
    Libgit2.version;
  } on StateError {
    postShutdownRejected = true;
  }

  return {
    'countWithLease': countWithLease,
    'version': version,
    'featuresPresent': featuresPresent,
    'ownerValidation': ownerValidation,
    'afterVersion': afterVersion,
    'afterFeatures': afterFeatures,
    'afterGlobalOption': afterGlobalOption,
    'shutdownResult': shutdownResult,
    'countAfterShutdown': countAfterShutdown,
    'repeatedShutdownResult': repeatedShutdownResult,
    'countAfterRepeatedShutdown': countAfterRepeatedShutdown,
    'postShutdownRejected': postShutdownRejected,
  };
}

Map<String, Object?> _exerciseLiveRootOwner() {
  final rawBindings = binaries.libgit2Runtime.bindings;
  final countWithLease = _probeInitializationCount(rawBindings);
  final tmpDir = setupRepo(
    Directory(p.join('test', 'assets', 'attributes_repo')),
  );
  final repo = Repository.open(tmpDir.path);
  var repoFreed = false;
  var runtimeShutdown = false;

  try {
    final countBeforeRejected = _probeInitializationCount(rawBindings);
    String? shutdownError;
    try {
      Libgit2.shutdown();
    } catch (error) {
      shutdownError = error.runtimeType.toString();
    }
    final countAfterRejected = _probeInitializationCount(rawBindings);
    final repositoryStillUsable = repo.path.isNotEmpty;

    repo.free();
    repoFreed = true;
    Libgit2.shutdown();
    runtimeShutdown = true;

    return {
      'countWithLease': countWithLease,
      'shutdownError': shutdownError,
      'countBeforeRejected': countBeforeRejected,
      'countAfterRejected': countAfterRejected,
      'repositoryStillUsable': repositoryStillUsable,
      'countAfterShutdown': _probeInitializationCount(rawBindings),
    };
  } finally {
    if (!repoFreed) repo.free();
    if (!runtimeShutdown) Libgit2.shutdown();
    tmpDir.deleteSync(recursive: true);
  }
}

Map<String, Object?> _exerciseDerivedChildOwner() {
  final rawBindings = binaries.libgit2Runtime.bindings;
  final countWithLease = _probeInitializationCount(rawBindings);
  final tmpDir = setupRepo(
    Directory(p.join('test', 'assets', 'attributes_repo')),
  );
  final repo = Repository.open(tmpDir.path);
  final oid = repo['d2f3abc9324a22a9f80fec2c131ec43c93430618'];
  final commit = Commit.lookup(repo: repo, oid: oid);
  var repoFreed = false;
  var oidFreed = false;
  var commitFreed = false;
  var runtimeShutdown = false;

  try {
    oid.free();
    oidFreed = true;
    repo.free();
    repoFreed = true;

    final commitStillUsable = commit.message.isNotEmpty;
    final countBeforeRejected = _probeInitializationCount(rawBindings);
    String? shutdownError;
    try {
      Libgit2.shutdown();
    } catch (error) {
      shutdownError = error.runtimeType.toString();
    }
    final countAfterRejected = _probeInitializationCount(rawBindings);

    commit.free();
    commitFreed = true;
    Libgit2.shutdown();
    runtimeShutdown = true;

    return {
      'countWithLease': countWithLease,
      'commitStillUsable': commitStillUsable,
      'shutdownError': shutdownError,
      'countBeforeRejected': countBeforeRejected,
      'countAfterRejected': countAfterRejected,
      'countAfterShutdown': _probeInitializationCount(rawBindings),
    };
  } finally {
    if (!commitFreed) commit.free();
    if (!oidFreed) oid.free();
    if (!repoFreed) repo.free();
    if (!runtimeShutdown) Libgit2.shutdown();
    tmpDir.deleteSync(recursive: true);
  }
}

Map<String, Object?> _exerciseConstructorRollback() {
  final rawBindings = binaries.libgit2Runtime.bindings;
  final countWithLease = _probeInitializationCount(rawBindings);
  final tmpDir = Directory.systemTemp.createTempSync('git2dart-runtime-');
  var runtimeShutdown = false;

  try {
    String? constructorError;
    try {
      Repository.open(p.join(tmpDir.path, 'missing'));
    } catch (error) {
      constructorError = error.runtimeType.toString();
    }

    final liveOwnersAfterFailure = binaries.libgit2Runtime.liveOwnerCount;
    Libgit2.shutdown();
    runtimeShutdown = true;

    return {
      'countWithLease': countWithLease,
      'constructorError': constructorError,
      'liveOwnersAfterFailure': liveOwnersAfterFailure,
      'countAfterShutdown': _probeInitializationCount(rawBindings),
    };
  } finally {
    if (!runtimeShutdown) Libgit2.shutdown();
    tmpDir.deleteSync(recursive: true);
  }
}

Map<String, Object?> _exerciseStreamTransfer() {
  final rawBindings = binaries.libgit2Runtime.bindings;
  final countWithLease = _probeInitializationCount(rawBindings);
  final tmpDir = setupRepo(
    Directory(p.join('test', 'assets', 'attributes_repo')),
  );
  final repo = Repository.open(tmpDir.path);
  final stream = Blob.createFromStream(repo: repo);
  Oid? oid;
  var repoFreed = false;
  var oidFreed = false;
  var runtimeShutdown = false;

  try {
    stream.writeString('lifecycle transfer');
    oid = Blob.createFromStreamCommit(stream);
    final oidLength = oid.sha.length;

    oid.free();
    oidFreed = true;
    repo.free();
    repoFreed = true;
    final liveOwnersBeforeShutdown = binaries.libgit2Runtime.liveOwnerCount;
    Libgit2.shutdown();
    runtimeShutdown = true;

    return {
      'countWithLease': countWithLease,
      'oidLength': oidLength,
      'liveOwnersBeforeShutdown': liveOwnersBeforeShutdown,
      'shutdownSucceededWithTransferredStreamAlive': true,
      'countAfterShutdown': _probeInitializationCount(rawBindings),
    };
  } finally {
    if (oid != null && !oidFreed) oid.free();
    if (!repoFreed) repo.free();
    if (!runtimeShutdown) Libgit2.shutdown();
    tmpDir.deleteSync(recursive: true);
  }
}

Future<Map<String, Object?>> _exerciseTwoIsolates() async {
  final rawBindings = binaries.libgit2Runtime.bindings;
  final countWithCoordinatorLease = _probeInitializationCount(rawBindings);
  final first = await _RuntimeWorker.start();
  _RuntimeWorker? second;
  var coordinatorShutdown = false;

  try {
    final afterFirst = _probeInitializationCount(rawBindings);
    second = await _RuntimeWorker.start();
    final afterSecond = _probeInitializationCount(rawBindings);

    await first.shutdown();
    final afterFirstShutdown = _probeInitializationCount(rawBindings);
    final secondVersion = await second.request('version');
    final secondStillUsable =
        secondVersion is String && secondVersion.isNotEmpty;

    await second.shutdown();
    final afterSecondShutdown = _probeInitializationCount(rawBindings);
    Libgit2.shutdown();
    coordinatorShutdown = true;
    final afterCoordinatorShutdown = _probeInitializationCount(rawBindings);

    return {
      'countWithCoordinatorLease': countWithCoordinatorLease,
      'afterFirst': afterFirst,
      'afterSecond': afterSecond,
      'afterFirstShutdown': afterFirstShutdown,
      'secondStillUsable': secondStillUsable,
      'afterSecondShutdown': afterSecondShutdown,
      'afterCoordinatorShutdown': afterCoordinatorShutdown,
    };
  } finally {
    await first.dispose();
    await second?.dispose();
    if (!coordinatorShutdown) Libgit2.shutdown();
  }
}

void _runtimeWorkerMain(SendPort ready) {
  final commands = ReceivePort();
  final version = Libgit2.version;
  ready.send([commands.sendPort, version]);

  commands.listen((message) {
    final values = message! as List<Object?>;
    final command = values[0]! as String;
    final reply = values[1]! as SendPort;

    try {
      if (command == 'version') {
        reply.send(['ok', Libgit2.version]);
      } else if (command == 'shutdown') {
        reply.send(['ok', Libgit2.shutdown()]);
        commands.close();
      } else {
        throw ArgumentError.value(command, 'command');
      }
    } catch (error) {
      reply.send(['error', error.toString()]);
    }
  });
}

final class _RuntimeWorker {
  _RuntimeWorker._(this.isolate, this.commands, this.exitPort, this.version);

  final Isolate isolate;
  final SendPort commands;
  final ReceivePort exitPort;
  final String version;
  bool _closed = false;

  static Future<_RuntimeWorker> start() async {
    final ready = ReceivePort();
    final exit = ReceivePort();
    final isolate = await Isolate.spawn(
      _runtimeWorkerMain,
      ready.sendPort,
      onExit: exit.sendPort,
    );
    final values = await ready.first as List<Object?>;
    ready.close();

    return _RuntimeWorker._(
      isolate,
      values[0]! as SendPort,
      exit,
      values[1]! as String,
    );
  }

  Future<Object?> request(String command) async {
    final reply = ReceivePort();
    commands.send([command, reply.sendPort]);
    final response = await reply.first as List<Object?>;
    reply.close();

    if (response[0] == 'error') {
      throw StateError(response[1]! as String);
    }
    return response[1];
  }

  Future<void> shutdown() async {
    if (_closed) return;
    await request('shutdown');
    await exitPort.first;
    exitPort.close();
    _closed = true;
  }

  Future<void> dispose() async {
    if (_closed) return;
    try {
      await shutdown();
    } finally {
      if (!_closed) {
        isolate.kill(priority: Isolate.immediate);
        exitPort.close();
        _closed = true;
      }
    }
  }
}
