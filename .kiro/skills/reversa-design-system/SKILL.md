---
name: reversa-design-system
description: Extracts and documents the legacy project's design system — color palette, typography, spacing, tokens, and components from CSS, theme files, and screenshots. Use when style files or interface screenshots are available.
disable-model-invocation: true
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills (screenshots require image support in the model).
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
phase: any
---

You are the Design System. Its mission is to extract and document the project's design tokens.

## Before you start

Read `.reversa/state.json` → field `output_folder` (default: `reversa/sdd`). Use it as the output folder.

## Analysis sources (use whatever is available)

1. CSS/SCSS/LESS — CSS variables (`--color-primary`), Sass variables (`$color-primary`)
2. Tailwind CSS — `tailwind.config.js` (tema customizado)
3. Temas de UI libraries — MUI (`createTheme`), Chakra UI (`extendTheme`), Mantine, Ant Design
4. styled-components / Emotion — objetos de tema (`ThemeProvider`)
5. Token files — Style Dictionary, `tokens.json`, `design-tokens.yaml`
6. Storybook — if it exists, analyze stories for component variants
7. Screenshots — as a visual complement to confirm tokens

## Process

### 1. Color palette
- Primary, secondary and accent colors
- Cores neutras (grays, blacks, whites)
- Feedback colors: success, error, alert, information
- Variations (50–900 or light/main/dark)
- Valores em hex/rgb/hsl

### 2. Tipografia
- Font families with fallbacks
- Size scale (values ​​in px/rem)
- Weights available
- Standard line-height and letter-spacing
- Hierarquia (h1–h6, body, caption, label, code)

### 3. Spacing and layout
- Base spacing scale
- Grid: columns, gutter, maximum width
- Breakpoints (sm, md, lg, xl, 2xl em px)

### 4. Outros tokens
- Border-radius (cards, buttons, inputs, circles)
- Shadows/elevations
- Z-index scale
- Transitions and easing functions
- Semantic opacities

### 5. Components
If there is your own component library: list components, variants and main props.

## Exit

**Em `reversa/sdd/design-system/`:**
- `color-palette.md` — complete palette with values
- `typography.md` — typographic system
- `spacing.md` — spacing, grid and breakpoints
- `tokens.md` — all tokens in table
- `design-system.md` — consolidated document

## Confidence scale
🟢 Extracted from configuration file | 🟡 Inferred from usage/screenshots | 🔴 Token referenced but not defined

## Output layout (cross)

This agent produces artifacts transversal to the organization chosen in `[specs]` of `config.toml`. The files are located in `<output_folder>/design-system/` in the root, outside the unit folders (feature folders). Do not apply the `<unit>/requirements.md|design.md|tasks.md` structure here, it belongs to Writer.

Report to Reversa: Documented tokens by category.
