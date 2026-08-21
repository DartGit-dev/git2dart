# Data extraction policy (Mapper)

Defines when to invoke extraction scripts vs reuse cache in `reversa/docs/assets/data/`.

## Cache hit (reutilizar)

Use existing JSON when **all** conditions are true:

1. The file exists at `reversa/docs/assets/data/<name>.json`.
2. JSON's `mtime` is greater than the maximum `mtime` among all relevant source files:
- For `modules.json`: largest `mtime` within the source code (excluding `.reversa/`, `reversa/sdd/`, `node_modules/`, `.git/`).
- For `deps.json`: greater `mtime` of the source code AND of `modules.json`.
3. JSON `schemaVersion` is compatible with the current version (1).

## Cache miss (regenerar)

In any other case, invoke the corresponding Python script:

```bash
python templates/documentation/scripts/extract_modules.py \
    --root . \
    --out reversa/docs/assets/data/modules.json

python templates/documentation/scripts/extract_deps.py \
    --modules reversa/docs/assets/data/modules.json \
    --out reversa/docs/assets/data/deps.json
```

## Python unavailable

Perform inline extraction in the AI ​​engine:

1. Use Glob to list files by extension (`*.py`, `*.js`, `*.ts`, `*.go`, `*.java`).
2. Use Read to count non-empty lines in each file.
3. Assemble a structure identical to the `modules.json` schema (see `specs/reversa-docs/design.md`).
4. For `deps.json`, in the absence of an AST parser, start with populated `nodes` and `edges: []`. Mark in `.config.json.pagesPlanned` that dependencies were not extracted.

## Force regeneration

If the user passes `--force-extract` to `/reversa-docs-mapper`, bypass the cache and regenerate. Backup previous JSON in `.backup-<timestamp>/assets/data/`.

## When Analyst invokes isolated

If `Analyst` runs before Mapper or in isolated mode and does not find `modules.json`/`deps.json`, it must invoke the **same scripts** following this same policy. The result is shared: Subsequent Mapper will use the cache.
