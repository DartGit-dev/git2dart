# [Nome da Unit]

> Template file `requirements.md`. Focus on WHAT the unit does, not how.

## Overview
[What is it, what problem does it solve, 2 to 3 lines]

## Responsabilidades
- [Responsabilidade 1]
- [Responsabilidade 2]

## Business Rules
- [Rule 1] 🟢
- [Rule 2] 🟡
- [Comportamento desconhecido] 🔴

## Functional Requirements

| ID | Requirement | Priority | Acceptance Criteria |
|----|-----------|-----------|-------------------|
| RF-01 | [Description] | Must | [How to validate] |
| RF-02 | [Description] | Should | [How to validate] |

## Non-Functional Requirements

| Type | Inferred requirement | Evidence in the code | Trust |
|------|--------------------|---------------------|-----------|
| Performance | [ex: 30s timeout on external calls] | `path/file.ext:line` | 🟢 |
| Security | [ex: mandatory authentication on the route] | `path/file.ext:line` | 🟡 |
| Scalability | [ex: Redis cache usage] | `path/file.ext:line` | 🟢 |
| Availability | [ex: automatic retry on failure] | `path/file.ext:line` | 🟡 |

> Inferred from the code. Validate with operations team.

## Acceptance Criteria

```gherkin
Given [precondition]
When [action]
So [expected result]

Given [error condition]
When [invalid action]
Then [expected failure behavior]
```

## Prioridade (MoSCoW)

| Requisito | MoSCoW | Justificativa |
|-----------|--------|---------------|
| [Main responsibility] | Must | Critical path, called in every flow |
| [Core business rule] | Must | Business rule without fallback |
| [Secondary functionality] | Should | Important but with an alternative |
| [Caso de borda] | Could | Raramente acionado |

> Priority inferred by call frequency and position in the dependency chain.

## Code Traceability

| Archive | Function / Class | Coverage |
|---------|-----------------|-----------|
| `path/file.ext` | `ClassName` | 🟢 |
