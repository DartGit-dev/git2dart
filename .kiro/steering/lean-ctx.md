---
inclusion: always
---

# Context Engineering Layer

<!-- lean-ctx-rules -->
<!-- version: 8 -->

The workspace has the `lean-ctx` MCP server installed. You MUST prefer lean-ctx tools over native equivalents for token efficiency and caching.

MANDATORY MAPPING:
• Read/cat -> ctx_read(path, mode)
• Grep -> ctx_search(pattern, path)
• Shell/bash -> ctx_shell(command)
• Glob/find -> ctx_glob(pattern)
• ls/find -> ctx_tree(path, depth)

NEVER use native Read/Grep/Shell/Glob when a ctx_* equivalent exists. SELF-CORRECT: the moment you reach for one, stop and call the ctx_* tool instead.

## When to use native Kiro tools instead

- `fsWrite` / `fsAppend` — always use native (lean-ctx doesn't write files)
- `strReplace` — always use native (precise string replacement)
- `semanticRename` / `smartRelocate` — always use native (IDE integration)
- `getDiagnostics` — always use native (language server diagnostics)
- `deleteFile` — always use native
- Glob — always use native glob

<!-- /lean-ctx-rules -->