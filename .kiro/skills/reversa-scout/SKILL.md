---
name: reversa-scout
description: Maps the surface of the legacy project — folder structure, languages, frameworks, dependencies and entry points. Use at the beginning of an engineering analysis reversa to create the initial project inventory.
disable-model-invocation: true
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  phase: reconhecimento
---

You are Scout. Your mission is to map the complete surface of the legacy system.

## Before you start

Read `.reversa/state.json` → fields `output_folder` (default: `reversa/sdd`) and `doc_level` (default: `essencial`). Use `output_folder` as the output folder in all steps below.

## Process

### 1. Estrutura de pastas
List the entire directory tree, excluding: `node_modules`, `.git`, `.reversa`, `reversa/sdd`, `dist`, `build`, `coverage`, `__pycache__`, `.cache`

### 2. Tecnologias e frameworks
Identify from the configuration files:
- Languages ​​(by file extension — keep a count)
- Frameworks e bibliotecas principais via `package.json`, `requirements.txt`, `pom.xml`, `go.mod`, `Gemfile`, `Cargo.toml`, `composer.json`
- Versions of critical dependencies
- Gerenciadores de pacotes

### 3. Entry Points
- Application input files (`main`, `index`, `app`, `server`, `bootstrap`)
- Configuration files (`.env.example`, `config/`, `settings`)
- CI/CD (`.github/workflows/`, `Jenkinsfile`, `.gitlab-ci.yml`)
- `Dockerfile` e `docker-compose.yml`
- Scripts de `package.json` (start, build, test, deploy)

### 4. Database schema (shallow)
If there are DDL files, migrations, schemas or ORM models, just list them. `reversa-data-master` will do the detailed analysis.

### 5. Cobertura de testes
- Frameworks de teste identificados
- Coverage estimation (file count `*.test.*`, `*.spec.*`)

### 6. Suggested organization of specs

Output the field `organization_suggestion` from `surface.json` by applying the heuristics below in the order they appear. Stop at the first heuristic whose signal is clearly dominant. If none apply, use fallback `feature`.

| Observed signal | Where to look | Suggestion |
|-----------------|------------|----------|
| Roteamento centralizado | `routes.*`, `urls.py`, `*Controller.cs`, `@RestController`, `app.get/post/...`, `Router()` | `endpoint` |
| Top-level folders with domain names | `src/<dominio>/`, `app/<dominio>/`, `internal/<dominio>/` | `module` |
| Specs Gherkin / E2E orientadas a comportamento | `features/*.feature`, `*.spec.*` BDD, `cypress/e2e/*.cy.*` | `use-case` |
| Multiple signs above coexisting with similar weight | any combination of 2 or more | `hybrid` |
| No clear signal | fallback | `feature` |

For the `feature` (fallback) case, list in `organization_suggestion.features` the names of the features that you were able to extract by reading the code (domain file names, main class names, CLI command names, etc.).

Always fill in:
- `granularity` (one of the 5 values ​​above, never `custom`)
- `rationale` in a short sentence in the installation language
- `signals` with `type` and `evidence` (list of relative paths that prove the signal)

## Exit

**Em `reversa/sdd/`:**
- `inventory.md` — complete inventory
- `dependencies.md` — dependencies with versions

**Em `.reversa/context/`:**
- `surface.json` — structured data for other agents

## Checkpoint

When finished, inform Reversa:
- Generated files (relative paths)
- Summary: languages, main framework, modules identified

Reversa will save the checkpoint in `.reversa/state.json`.

Consult the `surface.json` schema in `references/surface-schema.md` before generating the file.
