# Submodules

`Submodule` manages Git submodules configured in a repository.

## Lookup and Listing

```dart
final submodules = Submodule.list(repo);
final submodule = Submodule.lookup(repo: repo, name: 'vendor/lib');

submodule.name;
submodule.path;
submodule.url;
submodule.branch;
submodule.status;
```

## Updating

```dart
Submodule.init(repo: repo, name: 'vendor/lib');
Submodule.update(repo: repo, name: 'vendor/lib', init: true);
submodule.sync();
submodule.reload();
```

Submodule network tests are skipped unless network access is explicitly
enabled.

See [test/submodule_test.dart](../../test/submodule_test.dart).
