# Step 2 — Session Resume

## 0. Migration check in progress

First of all, read `.reversa/state.json` just to resolve `output_folder` (default `reversa/sdd`).

Verify that `<output_folder>/migration/.state.json` exists. If it does not exist, skip this section and go to section 1.

If it exists, read the file and rate the migration status:

| Condition | Status |
|----------|--------|
| `pendingAgents.length > 0` ou `currentAgent.agent` diferente de `null` | em andamento |
| `currentAgent.status == "awaiting_user_approval"` | pending intra-agent pause |
| `pendingAgents.length == 0`, `currentAgent.agent == null` and `<output_folder>/migration/handoff.md` exists | completed |

If the status is **complete**, skip this section (the migration is already finished, nothing to ask) and go to section 1.

If the status is **in progress** or **intra-agent pause pending**, present the question to the user before anything else:

> "[Name], I found a **migration in progress** on `<output_folder>/migration/`.
>
> - Completed: <N> of 6 agents (<list of completedAgents>)
> - Pending: <list of pendingAgents>
> - Current state: <currentAgent.agent or \"awaiting human approval\">
>
> How do you prefer to continue:
>
> 1. **Resume migration**: return to the Migration Team where you left off
> 2. **Resume the flow of Reversa**: follow descoberta/forward, ignore migration for now
> 3. **Cancel**: close this session without changing anything
> 4. **Outro**: descreva o que prefere fazer
>
> Use the engine's interactive menu mechanism (in Claude Code, `AskUserQuestion`); in engines without menu support, ask the user to enter the number 1–4 or free text."

Wait for the response. DO NOT choose on your own.

- If **1**: terminate `/reversa` here with the final instruction:
> "To resume the migration, enter `/reversa-migrate`. It detects the saved state and offers resume options."

DO NOT activate `reversa-migrate` automatically, let the user enter (Reversa explicit handoff pattern).
- If **2**: proceed with section 1 of this step normally.
- If **3**: close without doing anything.
- If **4** (free text): interpret the user's intention and offer the best possible route, without inventing new flows. If the intent is ambiguous, rephrase the question once before deciding.

## 1. Leitura do estado

Read `.reversa/state.json` and `.reversa/plan.md`.

## 2. Version Check

Compare `.reversa/version` with the npm registry. If there is a newer version, discreetly inform:
> "💡 New version available. Run `npx reversa update` when you want to update."

## 3. Greeting

Say: "[Name], welcome back to Reversa! 🎼"

## 4. Progress Summary

Mostre:
- ✅ Phases completed (field `completed` from state.json)
- 🔄 Current phase (field `phase`) with the last task registered in `checkpoints`
- ⏳ Next phases (field `pending`)

Example:
> "Progresso atual:
> ✅ Recognition completed
> 🔄 Excavation in progress — modules `auth` and `orders` analyzed, `payments` and `users` pending
> ⏳ Interpretation, Generation, Review"

## 5. Gap Response Mode

Se `answer_mode` for `"file"`:
> "Remember: your answers to the questions must be completed in `reversa/sdd/questions.md`. Let me know when you're done."

If `answer_mode` is `"chat"` (default):
> Continue as normal — I will ask the questions here in the chat.

## 6. Confirmation

Just ask: "Do we pick up where we left off? (CONTINUE to follow)"

After confirmation, resume the next pending task in the plan (`.reversa/plan.md`).

**🚫 Do not offer `/clear` + `/reversa` at this time.** The user has just resumed the session; asking to clean and reopen is now redundant. The pause prompt between steps (described in `SKILL.md`, section "Preventive checkpoint between steps") is only valid **after** an agent completes work within this session, never in the resume greeting itself.

See `references/checkpoint-guide.md` for the rules for writing to state.json.
