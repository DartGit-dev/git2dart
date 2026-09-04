# Investigation: Companion Binaries 1.14 Upgrade and 0.5.6 Release Preparation

## Scope and evidence boundary

The current package declares `git2dart_binaries >=1.13.0 <1.14.0` and locks
1.13.0. Addendum 003 records that the earlier 1.13.0 migration completed, but
its platform evidence is historical and not evidence for the 1.14.0 package.
The supplied 1.13.0-to-1.14.0 comparison found no public Dart declaration
changes. That result supports public declaration compatibility only; it does
not establish native ABI compatibility, binary contents/provenance, memory
ownership behavior, platform packaging, runtime initialization, or live remote
transport behavior.

## Legacy findings relevant to this change

| Finding | Source | Planning consequence |
|---------|--------|----------------------|
| Generated declarations and native binaries are delivered by the companion package. | `reversa/sdd/architecture.md#companion-native-package`; principle II | Do not regenerate, copy, or vendor generated artifacts. |
| Raw calls, ownership, and platform loading sit below the public facade. | `reversa/sdd/architecture.md#native-binding-adapters`; `code-analysis.md#feature-6-native-runtime-and-platform-boundary` | A stable public declaration surface cannot replace compile/runtime validation. |
| Android initializes certificate support; iOS eagerly resolves native symbols. | `reversa/sdd/code-analysis.md#feature-6-native-runtime-and-platform-boundary` | Exercise or explicitly gap both startup paths. |
| Default tests skip `remote_fetch` tests. | `reversa/sdd/architecture.md#quality-and-delivery-architecture` | Do not use the normal suite as live HTTPS/SSH proof. |
| Build CI defines Quality, Linux, macOS, Windows, Android, and iOS jobs. | `.github/workflows/build.yml` | Report every current release run separately. |

## Alternatives considered

| Alternative | Decision | Reason |
|-------------|----------|--------|
| Upgrade only the dependency range and version metadata | Rejected as sufficient evidence | It would not establish lock resolution, compilation, package readiness, or platform startup. |
| Copy 1.14.0 generated declarations into `lib/src/bindings` | Rejected | Violates the companion-boundary ownership model. |
| Preemptively rewrite adapters after the declaration diff | Rejected | No public declaration change was reported; changes must be driven by observed incompatibility. |
| Treat the 1.13.0 CI matrix as 1.14.0 evidence | Rejected | Inputs and artifacts differ by release. |
| Require live remote tests before any release work | Deferred / evidence-dependent | Valuable but not presently established as a standard mandatory gate; report their absence rather than overclaim. |

## Verification research and applicable standards

- Dart package dependency constraints and lock-file resolution: <https://dart.dev/tools/pub/dependencies>
- Dart package publishing and `dart pub publish --dry-run`: <https://dart.dev/tools/pub/publishing>
- Hosted companion release page to inspect during implementation: <https://pub.dev/packages/git2dart_binaries/versions/1.14.0>
- Project-local declaration comparison surface: `tool/api_diff/` and the completed 1.13.0-to-1.14.0 comparison supplied with this feature.

## Planned evidence matrix

| Evidence | Proves | Does not prove |
|----------|--------|----------------|
| Resolved `pubspec.lock` | Selected hosted package version | Native ABI or artifact behavior |
| Public declaration comparison | Public Dart declaration delta | Runtime or behavioral compatibility |
| Format/analyze/tests on one host | Observed source/static/test result on that host | Other platforms, publication, live transports |
| Android/iOS targeted validation | Observed initialization/runtime behavior on that target | Other device architectures or live transports |
| GitHub Actions matrix | Observed configured runner coverage | pub.dev publication unless publish evidence exists |
| `dart pub publish --dry-run` | Package assembly and pub validation at that run | Actual publication |
| Controlled live HTTPS/SSH test | Observed protocol path under tested conditions | General remote-service compatibility |

## Conditional adapter investigation procedure

1. Resolve 1.14.0 and run analyzer/compiler checks before editing bindings.
2. If an import, type, ABI-width, ownership, or platform helper mismatch appears, map it to the exact hand-written adapter and generated declaration.
3. Add focused positive and negative regression coverage for that mismatch.
4. Preserve shared native error translation and arena/finalizer ownership; do not expose raw pointers.
5. Treat a clean analyzer/test run as release evidence only at its observed scope.

## Open validation gaps

- The repository extraction has no universal ABI audit or cross-platform 1.14.0 runtime proof.
- Historical 1.13.0 hosted success must not be re-labeled as 1.14.0 proof.
- Live HTTPS/SSH interoperability remains unproven unless deliberately run and recorded.
