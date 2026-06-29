import 'dart:ffi';
import 'dart:io';

import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/config.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final filePath = p.join(Directory.systemTemp.path, 'test_config');
  const contents = '''
[core]
\trepositoryformatversion = 0
\tbare = false
\tgitproxy = proxy-command for kernel.org
\tgitproxy = default-proxy
[remote "origin"]
\turl = someurl
''';

  const expectedEntries = [
    'core.repositoryformatversion',
    'core.bare',
    'core.gitproxy',
    'core.gitproxy',
    'remote.origin.url',
  ];

  late Config config;

  setUp(() {
    File(filePath).writeAsStringSync(contents);
    config = Config.open(filePath);
  });

  tearDown(() {
    File(filePath).deleteSync();
  });

  group('Config', () {
    test('opens file with provided path', () {
      expect(config, isA<Config>());
    });

    test('creates empty config', () {
      final config = Config.empty();
      expect(config, isA<Config>());
      expect(config.toList(), isEmpty);
    });

    test('opens the global, XDG and system configuration files '
        '(if they are present) if no path provided', () {
      try {
        expect(Config.open(), isA<Config>());
      } catch (e) {
        expect(() => Config.open(), throwsA(isA<LibGit2Error>()));
      }
    });

    test('throws when trying to open non existing file', () {
      expect(() => Config.open('not.there'), throwsA(isA<Exception>()));
    });

    test('opens system file or throws is there is none', () {
      try {
        expect(Config.system(), isA<Config>());
      } catch (e) {
        expect(() => Config.system(), throwsA(isA<LibGit2Error>()));
      }
    });

    test('opens global file or throws is there is none', () {
      try {
        expect(Config.global(), isA<Config>());
      } catch (e) {
        expect(() => Config.global(), throwsA(isA<LibGit2Error>()));
      }
    });

    test('opens xdg file or throws is there is none', () {
      try {
        expect(Config.xdg(), isA<Config>());
      } catch (e) {
        expect(() => Config.xdg(), throwsA(isA<LibGit2Error>()));
      }
    });

    test('returns config snapshot', () {
      expect(config.snapshot, isA<Config>());
    });

    test('returns config entries and their values', () {
      var i = 0;
      for (final entry in config) {
        expect(entry.name, expectedEntries[i]);
        expect(entry.includeDepth, 0);
        expect(entry.level, GitConfigLevel.local);
        i++;
      }
    });

    group('binding iteration helpers', () {
      late Pointer<git_config> configPointer;

      setUp(() {
        configPointer = bindings.open(filePath);
      });

      tearDown(() {
        bindings.free(configPointer);
      });

      test('returns config entries using foreach callback', () {
        final entries = bindings.foreachEntries(configPointer);

        expect(entries.map((entry) => entry['name']), expectedEntries);
        expect(entries.first['value'], '0');
        expect(entries.first['level'], GitConfigLevel.local.value);
      });

      test('returns config entries using foreach match callback', () {
        final entries = bindings.foreachMatchEntries(
          configPointer: configPointer,
          regexp: r'^remote\.',
        );

        expect(entries.single['name'], 'remote.origin.url');
        expect(entries.single['value'], 'someurl');
      });

      test('returns config entries using glob iterator', () {
        final entries = bindings.globEntries(
          configPointer: configPointer,
          regexp: r'^core\.',
        );

        expect(entries.map((entry) => entry['name']), [
          'core.repositoryformatversion',
          'core.bare',
          'core.gitproxy',
          'core.gitproxy',
        ]);
      });

      test('returns multivar values using foreach callback', () {
        expect(
          bindings.multivarValuesForeach(
            configPointer: configPointer,
            variable: 'core.gitproxy',
          ),
          ['proxy-command for kernel.org', 'default-proxy'],
        );
        expect(
          bindings.multivarValuesForeach(
            configPointer: configPointer,
            variable: 'not.there',
          ),
          <String>[],
        );
      });

      test('maps config values to integer constants', () {
        const maps = [
          bindings.ConfigMapSpec(
            type: git_configmap_t.GIT_CONFIGMAP_FALSE,
            value: 0,
          ),
          bindings.ConfigMapSpec(
            type: git_configmap_t.GIT_CONFIGMAP_TRUE,
            value: 1,
          ),
          bindings.ConfigMapSpec(
            type: git_configmap_t.GIT_CONFIGMAP_STRING,
            match: 'input',
            value: 2,
          ),
        ];

        bindings.setString(
          configPointer: configPointer,
          variable: 'core.autocrlf',
          value: 'input',
        );

        expect(
          bindings.getMapped(
            configPointer: configPointer,
            name: 'core.autocrlf',
            maps: maps,
          ),
          2,
        );
        expect(bindings.lookupMapValue(maps: maps, value: 'true'), 1);
      });

      test('locks and unlocks config backend', () {
        expect(() => bindings.lock(configPointer), returnsNormally);
      });
    });

    group('get value', () {
      test('returns value of variable', () {
        expect(config['core.bare'].value, 'false');
      });

      test("throws when variable isn't found", () {
        expect(() => config['not.there'], throwsA(isA<LibGit2Error>()));
      });

      test('returns typed values', () {
        expect(config.getBool('core.bare'), false);
        expect(config.getInt32('core.repositoryformatversion'), 0);
        expect(config.getInt64('core.repositoryformatversion'), 0);
        expect(config.getString('remote.origin.url'), 'someurl');
      });

      test('throws when typed variable is missing', () {
        expect(() => config.getBool('not.there'), throwsA(isA<LibGit2Error>()));
      });
    });

    group('parse helpers', () {
      test('parse typed config values', () {
        expect(Config.parseBool('true'), true);
        expect(Config.parseInt32('42'), 42);
        expect(Config.parseInt64('42'), 42);
        expect(Config.parsePath('/tmp'), '/tmp');
      });

      test('throw when typed config values are invalid', () {
        expect(() => Config.parseBool('maybe'), throwsA(isA<LibGit2Error>()));
        expect(() => Config.parseInt32('nope'), throwsA(isA<LibGit2Error>()));
      });
    });

    group('set value', () {
      test('sets boolean value for provided variable', () {
        config['core.bare'] = true;
        expect(config['core.bare'].value, 'true');
      });

      test('sets integer value for provided variable', () {
        config['core.repositoryformatversion'] = 1;
        expect(config['core.repositoryformatversion'].value, '1');
      });

      test('sets 32-bit integer value for provided variable', () {
        config.setInt32('core.repositoryformatversion', 1);
        expect(config.getInt32('core.repositoryformatversion'), 1);
      });

      test('sets string value for provided variable', () {
        config['remote.origin.url'] = 'updated';
        expect(config['remote.origin.url'].value, 'updated');
      });

      test('throws when trying to set invalid value', () {
        expect(
          () => config['remote.origin.url'] = 0.1,
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('delete', () {
      test('deletes entry', () {
        expect(config['core.bare'].value, 'false');
        config.delete('core.bare');
        expect(() => config['core.bare'], throwsA(isA<LibGit2Error>()));
      });

      test('throws on deleting non existing variable', () {
        expect(() => config.delete('not.there'), throwsA(isA<LibGit2Error>()));
      });
    });

    group('get multivar values', () {
      test('returns list of values', () {
        expect(config.multivar(variable: 'core.gitproxy'), [
          'proxy-command for kernel.org',
          'default-proxy',
        ]);
      });

      test('returns list of values for provided regexp', () {
        expect(
          config.multivar(
            variable: 'core.gitproxy',
            regexp: r'for kernel.org$',
          ),
          ['proxy-command for kernel.org'],
        );
      });

      test('returns empty list if multivar not found', () {
        expect(config.multivar(variable: 'not.there'), <String>[]);
      });
    });

    group('setMultivarValue()', () {
      test('sets value of multivar', () {
        config.setMultivar(
          variable: 'core.gitproxy',
          regexp: 'default',
          value: 'updated',
        );
        final multivarValues = config.multivar(variable: 'core.gitproxy');
        expect(multivarValues, isNot(contains('default-proxy')));
        expect(multivarValues, contains('updated'));
      });
    });

    group('deleteMultivar()', () {
      test('deletes value of a multivar', () {
        expect(
          config.multivar(
            variable: 'core.gitproxy',
            regexp: r'for kernel.org$',
          ),
          ['proxy-command for kernel.org'],
        );

        config.deleteMultivar(
          variable: 'core.gitproxy',
          regexp: r'for kernel.org$',
        );

        expect(
          config.multivar(
            variable: 'core.gitproxy',
            regexp: r'for kernel.org$',
          ),
          <String>[],
        );
      });
    });

    test('manually releases allocated memory', () {
      final config = Config.open(filePath);
      expect(() => config.free(), returnsNormally);
    });

    test('returns string representation of ConfigEntry object', () {
      final entry = config.first;
      expect(entry.toString(), contains('ConfigEntry{'));
    });

    test('supports value comparison', () {
      expect(Config.open(filePath), equals(Config.open(filePath)));
    });
  });
}
