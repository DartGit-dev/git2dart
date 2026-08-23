# Reproduction Capsule

## Base

- Commit: `131f7c8f405fd818affd1bf4cc3fd60cd2b52f60`
- Branch: `0.5.5`
- OS: Microsoft Windows NT 10.0.26200.0, x64
- Flutter: 3.38.2 stable
- Dart: 3.10.0 stable
- Native binary root: hosted `git2dart_binaries-1.12.1`
- Dart API implementation: direct `F:/git2dart_binaries` path override

## Command

```powershell
$env:GIT2DART_BINARIES_PACKAGE_ROOT = 'C:/Users/Viktor/AppData/Local/Pub/Cache/hosted/pub.dev/git2dart_binaries-1.12.1'
flutter test -j 1 reversa/bugs/native-runtime-and-platform-boundary/bugs/BUG-20260817-DQPX-unchecked-global-option-results/evidence/reproduction_test.dart
```

## Result

- Exit code: 0
- Rate: 1/1
- Classification: deterministic
- Raw `git_libgit2_opts_set_cache_object_limit(GIT_OBJECT_INVALID, 1)` returned a negative status.
- Public `Libgit2.setCacheObjectLimit(type: GitObject.invalid, value: 1)` returned normally.

The comparison uses the same invalid option input and does not mutate valid
cache configuration. It proves that the public wrapper loses a real native
failure rather than translating it to `LibGit2Error`.
