# Onboarding: Validate Analyzer Evidence Closure

## Preconditions

1. Work from `F:\git2dart`.
2. Confirm feature 001 is paused and do not edit it.
3. Record the current bytes or hash of `pubspec_overrides.yaml` and the
   resolved runtime/package configuration before any temporary validation setup.
4. Treat `lib/`, `test/`, dependencies, binaries, OpenSSL, and secrets as
   read-only for this feature.

## Baseline

Run:

```powershell
flutter analyze
```

Record the expected baseline separately:

- 21 total errors;
- four E3LU evidence import/symbol errors;
- four ZC7X undefined-`libgit2` errors;
- 13 excluded `lib/` errors.

Do not describe this baseline as a package-quality failure caused by the evidence
feature alone.

## Evidence verification

1. Confirm each E3LU evidence file imports
   `../../../../../../test/helpers/util.dart`.
2. Confirm ZC7X uses `libgit2Runtime.bindings.git_libgit2_init()` and
   `libgit2Runtime.bindings.git_libgit2_shutdown()` for all four formerly
   legacy-global references.
3. Run targeted analysis against the three listed evidence files. It must report
   no diagnostic for them.
4. If runtime reproduction is executed, retain the original test semantics:
   E3LU remains an ownership-failure capsule; ZC7X still proves count growth
   with restoration probes and two final shutdowns.

## Temporary runtime and restoration

1. Reuse the proven Windows compatibility arrangement only transiently:
   ea87cf companion Dart runtime plus the recorded staged hosted-1.12.1 DLL
   payload; set `GIT2DART_BINARIES_PACKAGE_ROOT` only for commands that need
   native execution.
2. Run the final full `flutter analyze` in that arrangement.
3. Classify rather than overstate its result: zero diagnostics in the three
   covered evidence files; the known excluded `lib/` diagnostics are reported
   separately.
4. In a guaranteed cleanup path, restore the original override/runtime files
   and remove only temporary staged artifacts created by the procedure.
5. Verify restoration by comparing the pre-run hash/content and resolving the
   package root again. If restoration cannot be verified, stop and report the
   environment as dirty; do not proceed to later forward stages.

No full-suite, cross-platform, CI, publication, dependency upgrade, or native
ABI claim is produced by this onboarding.

