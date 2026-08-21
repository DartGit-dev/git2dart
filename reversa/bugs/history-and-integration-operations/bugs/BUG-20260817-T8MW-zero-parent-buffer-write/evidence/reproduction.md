# Reproduction Capsule

## Baseline

- Commit: `a725bac1b8641156819c2f08a007fcc1a74f80bf`
- Branch: `0.5.4`
- OS: Windows x64
- Dart: 3.10.0 stable
- Flutter: 3.38.2 stable
- Native package: `git2dart_binaries 1.12.1`
- Date: 2026-08-20

## Environment Preparation

The repository package configuration initially referenced dependencies that were
not present in the local Pub cache. Dependencies were restored from the existing
lockfile into a temporary Pub cache:

```powershell
flutter pub get
```

Exit code: `0`. No dependency version or lockfile change was requested.

## Runtime Reachability

Command:

```powershell
flutter test -j 1 test\commit_test.dart --plain-name 'without parents'
```

Exit code: `0`.

Observed result:

```text
Commit writes commit without parents into the buffer
Commit creates commit without parents
All tests passed!
```

The two public root-commit paths are reachable. Passing tests do not disprove the
defect because the current Windows allocator/runtime is not instrumented to
detect a write through a zero-count FFI allocation.

## Deterministic Static Reproduction

Command:

```powershell
Select-String -Path lib\src\bindings\commit.dart -Pattern 'parentsC\[0\] = nullptr'
```

Exit code: `0`.

The unsafe sentinel write occurs in all three serializers:

- `create`: line 78
- `createBuffer`: line 127
- `createFromIds`: line 175

For each path, an empty parent list produces `parentCount == 0`, allocates zero
pointer elements, and then writes element zero. The defect therefore reproduces
in 3/3 static FFI paths. The first two paths are dynamically reachable through
the public API; `createFromIds` currently has no high-level caller.

## Classification

- Classification: deterministic
- Static reproduction rate: 3/3 affected FFI paths
- Public runtime reachability: 2/2 available root-commit APIs
- Runtime memory-fault observation: unavailable without allocator
  instrumentation
