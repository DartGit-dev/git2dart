# Guia de Checkpoints — .reversa/state.json

Reversa is the only agent that **writes** to state.json. The other agents just read.

## Absolute rules

1. **Never remove existing fields.** Only add or update.
2. **Always read the file before writing** — another agent may have updated `checkpoints`.
3. **Save after each completed level**, not just at the end.
4. **In case of context overflow**, save immediately before pausing.

## What to save at each stage

### When starting a phase
```json
{
  "phase": "reconhecimento"
}
```

### When completing an agent
```json
{
  "checkpoints": {
    "scout": {
      "completed_at": "2026-04-26T10:30:00Z",
      "files": [
        "reversa/sdd/inventory.md",
        "reversa/sdd/dependencies.md",
        ".reversa/context/surface.json"
      ]
    }
  }
}
```

### When completing an entire level
```json
{
  "phase": "escavacao",
  "completed": ["reconhecimento"],
  "pending": ["escavacao", "interpretacao", "geracao", "revisao"]
}
```

### When marking an Archaeologist partial task
```json
{
  "checkpoints": {
    "archaeologist": {
      "modules_analyzed": ["auth", "orders"],
      "modules_pending": ["payments", "users"]
    }
  }
}
```

## Phase sequence

```
null → reconhecimento → escavacao → interpretacao → geracao → revisao
```

When moving phase:
- Remove the completed phase from `pending` and add to `completed`
- Update `phase` to the next phase

## Example of state.json with analysis in progress

```json
{
  "version": "1.0.0",
  "project": "my-system",
  "user_name": "Ana",
  "chat_language": "pt-br",
  "doc_language": "Portuguese",
  "answer_mode": "chat",
  "output_folder": "reversa/sdd",
  "phase": "escavacao",
  "completed": ["reconhecimento"],
  "pending": ["escavacao", "interpretacao", "geracao", "revisao"],
  "checkpoints": {
    "scout": {
      "completed_at": "2026-04-26T10:30:00Z",
      "files": [
        "reversa/sdd/inventory.md",
        "reversa/sdd/dependencies.md",
        ".reversa/context/surface.json"
      ]
    },
    "archaeologist": {
      "modules_analyzed": ["auth", "orders"],
      "modules_pending": ["payments", "users"]
    }
  },
  "engines": ["claude-code"],
  "agents": ["reversa", "reversa-scout", "reversa-archaeologist"],
  "created_files": []
}
```

## Pause message due to context overflow

If context is running out, save the current checkpoint and say:

> "[Name], I'm going to pause here to preserve context. Everything is saved in `.reversa/state.json`. Type `reversa` in a new session to pick up where we left off."
