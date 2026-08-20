# Permissions and Trust Boundaries

## RBAC/ACL Finding

🟢 **No application-level RBAC or ACL system exists in this repository.** `git2dart` is an in-process library. It executes with the filesystem, network, credential, and platform permissions of the embedding Dart/Flutter process.

## Capability Matrix

| Capability | Caller supplies | Enforcement boundary | Main risk |
| --- | --- | --- | --- |
| Read repository and objects | Repository path | OS filesystem permissions and libgit2 validation | Reading unintended local repositories |
| Mutate references/index/workdir | Repository handle, paths, strategies | libgit2 rules plus OS write permissions | Data loss from force/reset/checkout options |
| Clone/fetch/push | URL, refspecs, callbacks | Network stack, credentials, certificate policy, remote server authorization | Credential leakage or trusting wrong host |
| Configure global libgit2 | Static option setters | In-process caller authority | Cross-operation/global behavior changes |
| Load native runtime | Companion package/platform initialization | OS loader, mobile packaging, ABI compatibility | Missing/incompatible native library |
| Open submodule | Parent repository metadata | Filesystem and remote credentials | Traversal into nested repository/network access |
| Publish package | CI secrets and branch conditions | GitHub Actions and pub.dev tokens | Unauthorized publication |

## Credential and Certificate Rules

- Plaintext username/password should be used only with a protected transport; the binding documentation explicitly notes plaintext transmission risk.
- SSH key files and in-memory keys are caller-provided secrets; the library does not persist a credential vault.
- The certificate callback is security-sensitive: returning `true` overrides rejection for the presented host/certificate.
- Certificate objects are borrowed and should not be retained after callback completion.
- 🔴 The repository does not define secret-redaction guarantees for callback logging by consumers.

## Destructive Operation Boundaries

| Operation | Guard present | Caller responsibility |
| --- | --- | --- |
| Force checkout/reset | Typed strategy flags | Choose non-destructive strategy and preserve uncommitted work |
| Reference overwrite | `force` defaults false; matching update available | Prefer compare-and-set where stale writes matter |
| Branch/tag/reference delete | Native existence/name checks | Confirm intended target before call |
| Stash drop/pop | Index-based native validation | Verify stash index and desired persistence |
| Submodule update | Explicit `init`, callbacks | Validate URL, credentials, and nested worktree impact |
| Disable strict validation/safety | Explicit global methods | Serialize global policy changes and restore expected defaults |

## CI/Release Permissions

- Pull requests and configured branches run the test matrix.
- Publishing runs after tests on `main` or release branches; non-main publication is configured as dry-run.
- pub.dev access/refresh tokens are GitHub secrets.
- 🔴 Branch protection and secret-environment approval rules are external to the repository and were not inspected.

