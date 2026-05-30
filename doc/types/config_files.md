# Config Files

`Config` reads and writes Git configuration files and repository configuration.

## Opening Configs

```dart
final config = Config.open('path/to/config');
final repoConfig = repo.config;
final snapshot = repoConfig.snapshot;

Config.system();
Config.global();
Config.xdg();
Config.programData();
```

## Reading Values

```dart
config['user.name'].value;
config.getBool('core.bare');
config.getInt32('core.repositoryformatversion');
config.getInt64('core.bigfilethreshold');
config.getString('remote.origin.url');
config.getPath('core.excludesfile');
```

## Writing Values

```dart
config['user.name'] = 'A User';
config['core.bare'] = false;
config['core.repositoryformatversion'] = 0;
config.delete('user.name');
```

## Helpers

```dart
Config.parseBool('true');
Config.parseInt32('42');
Config.parseInt64('42');
Config.parsePath('~/file');

config.multivar(variable: 'remote.origin.fetch');
config.setMultivar(
  variable: 'remote.origin.fetch',
  regexp: 'main',
  value: '+refs/heads/main:refs/remotes/origin/main',
);
```

Call `free()` when a long-running process no longer needs a config handle.

See [test/config_test.dart](../../test/config_test.dart).
