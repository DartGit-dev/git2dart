# ADR-006: Expose Caller-Controlled Certificate Validation

## Status

Accepted (retrospective).

## Context

Some platforms, especially Android SSH environments, cannot rely on normal `known_hosts` lookup. Remote operations need a way to inspect host keys/certificates without silently disabling trust checks.

## Decision

Expose a typed `certificateCheck` callback receiving certificate details, host, and libgit2's native validity result. Preserve libgit2 defaults when the callback is absent.

Evidence: `b422c95`, 0.5.1 changelog, certificate wrappers, and callback tests. 🟢 CONFIRMED.

## Alternatives considered

- Always trust certificates on affected platforms.
- Require consumers to patch native known-hosts behavior.
- Support HTTPS only.

## Consequences

- Consumers can implement pinning, TOFU, or platform-specific trust policy.
- A callback that returns true incorrectly can create a man-in-the-middle vulnerability.
- Borrowed certificate data must not escape callback lifetime.

