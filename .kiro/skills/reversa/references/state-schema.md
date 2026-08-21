# Schema — .reversa/state.json

This file persists the complete analysis state between sessions. Reversa reads and writes to this file.

## Estrutura completa

```json
{
  "version": "1.0.0",
  "project": "project-name",
  "user_name": "User Name",
  "chat_language": "pt-br",
  "doc_language": "Portuguese",
  "answer_mode": "chat",
  "doc_level": null,
  "output_folder": "reversa/sdd",
  "forward_folder": "reversa/forward",
  "docs_folder": "reversa/docs",
  "bugs_folder": "reversa/bugs",
  "phase": "reconhecimento",
  "completed": ["reconhecimento"],
  "pending": ["escavacao", "interpretacao", "geracao", "revisao"],
  "engines": ["claude-code"],
  "agents": ["reversa", "reversa-scout", "reversa-archaeologist"],
  "checkpoints": {
    "scout": {
      "completed_at": "2026-04-26T10:00:00Z",
      "files": [
        "reversa/sdd/inventory.md",
        "reversa/sdd/dependencies.md",
        ".reversa/context/surface.json"
      ]
    },
    "archaeologist": {
      "completed_at": "2026-04-26T11:00:00Z",
      "modules_analyzed": ["auth", "orders", "payments"],
      "files": [
        "reversa/sdd/code-analysis.md",
        "reversa/sdd/data-dictionary.md",
        ".reversa/context/modules.json"
      ]
    }
  },
  "created_files": [
    "CLAUDE.md",
    ".agents/skills/reversa/SKILL.md",
    ".reversa/state.json",
    ".reversa/plan.md"
  ]
}
```

## Campos

| Field | Type | Description |
|-------|------|-----------|
| `version` | string | Reversa version installed |
| `project` | string | Legacy project name |
| `user_name` | string | Username (for interactions) |
| `chat_language` | string | Language of interactions (e.g. pt-br, en-us) |
| `doc_language` | string | Language of the generated specs (ex: Portuguese, English) |
| `answer_mode` | string | How the user responds to the gaps: `chat` or `file` |
| `doc_level` | string \| null | Volume of documentation generated: `essencial`, `completo` or `detalhado`. Starts `null` — mandatory to fill in via user choice after Scout. |
| `output_folder` | string | Specs output folder (default: `reversa/sdd`) |
| `forward_folder` | string | Compatibility alias for `setup.json#paths.forward-dir` |
| `docs_folder` | string | Compatibility alias for `setup.json#paths.docs-dir` |
| `bugs_folder` | string | Compatibility alias for `setup.json#paths.bugs-dir` |
| `phase` | string \| null | Current phase. `null` = not started |
| `completed` | string[] | Phases completed |
| `pending` | string[] | Fases pendentes |
| `checkpoints` | object | Completion record for each agent |
| `engines` | string[] | Engines configuradas (ex: `["claude-code", "codex"]`) |
| `agents` | string[] | Installed agents |
| `created_files` | string[] | All files created by Reversa (for safe uninstall) |

## Valid phases

`reconhecimento` → `escavacao` → `interpretacao` → `geracao` → `revisao`

## Rule when writing

Never remove existing fields. Just add or update.

## Where NOT to write

The decision to organize the specs (granularity, custom folders, Scout's original suggestion, timestamp of the choice) **doesn't** go into `state.json`. It is persisted in `.reversa/config.toml`, section `[specs]`, as per `references/step-03-specs-organization.md`. `state.json` is runtime state, `config.toml` is long-term decision.
