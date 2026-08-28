# Investigation: Strict Git Validation

## Evidence baseline

`lib/src/odb.dart` currently rejects only `any`, `invalid`, `offsetDelta`, and
`refDelta`. `GitObject` also explicitly defines the four intended concrete
values, so the present predicate is a partial deny-list rather than the finite
contract in `requirements.md`. 🟢

`lib/src/reference.dart` documents two accepted name families but forwards most
input strings to bindings. Existing tests demonstrate invalid symbolic target
and rename input currently reaches libgit2 and becomes `LibGit2Error`. 🟢

## Applicable reference rules

The approved feature rules correspond to Git's documented refname restrictions:
components cannot begin with `.` or end with `.lock`; refnames reject `..`,
ASCII controls, space, `~`, `^`, `:`, `?`, `*`, `[`, leading/trailing or
doubled slashes, a trailing `.`, and `@{`. Git's general rule also rejects a
backslash. The feature additionally makes the allowed one-level set explicit:
uppercase letters/underscores, beginning and ending with a letter.

- [Git `check-ref-format` documentation](https://git-scm.com/docs/git-check-ref-format.html)
- [Existing public `Reference.create` documentation](../../../lib/src/reference.dart)

## Alternatives considered

| Alternative | Decision | Reason |
|-------------|----------|--------|
| Delegate all invalid values to libgit2 | Rejected | Violates deterministic local `ArgumentError` and no-native-call acceptance criteria. |
| Use a partial deny-list for ODB types | Rejected | It encodes what is currently known to be bad, not the explicitly finite accepted set. |
| Invoke a Git executable for validation | Rejected | Adds process/repository dependence and differs from the package's in-process boundary. |
| Call a libgit2 validation API through new bindings | Rejected | Expands ABI/binary scope without need; the approved rules are fully local and deterministic. |
| Add a public validation utility | Rejected | Unnecessary new API surface; validation is an internal precondition of existing APIs. |
| Normalize slash forms before validation | Rejected | Requirements demand rejection, not mutation, of invalid caller input. |

## Test design notes

Use table-driven invalid categories: empty, control/space/prohibited character,
`..`, `@{`, leading/trailing/doubled slash, trailing dot, leading-dot component,
`.lock` component suffix, invalid one-level form, and non-`refs/` hierarchy.
Use valid examples `HEAD`, `ORIG_HEAD`, `refs/heads/main`, `refs/tags/v1.0`,
and `refs/remotes/origin/main`.

For no-native-call evidence, invoke an invalid value before an otherwise invalid
native receiver/path and expect `ArgumentError`; retain a separate valid-input
test showing the call remains eligible to reach the existing native behavior.
This is boundary-order evidence, not a mock-based assertion of generated FFI.

## Scope boundary

`Reference.list*` glob parameters are patterns, not ref names. Branch, remote,
worktree, and other string-named APIs are outside the approved `Reference` and
ODB scope. No network, OpenSSL, generated declarations, or companion-binaries
work is needed.

