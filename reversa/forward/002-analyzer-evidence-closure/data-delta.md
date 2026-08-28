# Data Delta: Analyzer Evidence Closure

## Conceptual diff

| Extracted model | Delta | Migration |
|-----------------|-------|-----------|
| E3LU ownership reproduction fixture dependency | The source import becomes repository-root correct. | None. |
| E3LU borrowed `TreeEntry` ownership scenario | None; borrow, invalid free, parent/repository cleanup, and fixture deletion remain unchanged. | None. |
| ZC7X native lifecycle probe | Probe identifiers move from removed global access to the companion's exported runtime bindings. | None. |
| Git repository, object, ref, index, and native binary data | None. | None. |

## Runtime configuration boundary

Temporary ea87cf runtime/DLL staging is validation infrastructure only. It is
not a persistent data-model, dependency, package-lock, binary, or deployment
change. The original override/runtime configuration must be restored after the
validation run regardless of its outcome.

