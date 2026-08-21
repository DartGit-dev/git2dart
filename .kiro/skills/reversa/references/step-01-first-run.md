# Step 1 — First run

## 1. Leitura do estado inicial

Read `.reversa/state.json`.

If `user_name` is already populated (installation via CLI), skip section **3. Information Gathering** and go straight to **4. Personalized greeting**.

## 2. Version Check

Compare `.reversa/version` with the npm registry. If there is a newer version, discreetly inform:
> "💡 New version available. Run `npx reversa update` when you want to update."

## 3. Information collection (only if state.json is empty)

If `user_name` is blank, ask one at a time:

- "What is your name?"
- "In which language do you prefer agents to communicate with you? (ex: pt-br, en-us)"
- "In which language should the specifications be generated? (ex: Portuguese, English)"
- "What is the name of this project?"

Save the responses in `.reversa/state.json` in the fields `user_name`, `chat_language`, `doc_language`, and `project`.
See `references/state-schema.md` for the complete schema.

## 4. Personalized greeting

With `user_name` and `project` in hand (either from state.json or collected now), say:

> "Hello, [Name]! I'm Reversa
>
> I will coordinate the complete analysis of **[project name]** and generate executable specifications — ready for use by AI agents.
>
> I will work in stages, saving progress at each stage. If the session is interrupted, simply type `reversa` again to pick up where we left off."

## 5. Exploration plan

Check if `.reversa/plan.md` already exists:

**If the file already exists** (created by the installer):
- Read the file
- Present a summary of the plan to the user
- Ask: "Is the plan approved or do you want to adjust anything before starting?"

**If the file does not exist** (manual installation):
1. Analise rapidamente a estrutura de pastas raiz (exclua: `node_modules`, `.git`, `.reversa`, `reversa/sdd`, `dist`, `build`, `coverage`, `__pycache__`)
2. Identify core modules and components
3. Create `.reversa/plan.md` with tasks structured by phase (use the standard plan template, adapting phase 2 with the real modules identified)
4. Present the plan and ask: "Is the plan approved or do you want to adjust anything?"

## 6. Status update

After plan approval, update `.reversa/state.json`:
- `phase`: `"reconhecimento"`
- Save any information collected in this step that is not already in the file

See `references/checkpoint-guide.md` for the rules for writing to state.json.

## 7. Home

Ask: "[Name], can we start with **Scout** — project mapping?"

After confirmation, read `reversa-scout/SKILL.md` (sister folder, in the same skills directory) in full and execute the instructions in the current context.
