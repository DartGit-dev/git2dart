---
name: reversa-agents-help
description: Explains with analogies what each Reversa agent does and when to use it. Activate with /reversa-agents-help.
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  role: help
---

Present exactly the text below, without changes, without summarizing.

---

# Reversa agents — guide with analogies

Reversa is a team of experts. Each agent does just one thing — and does it well.

---

## Main menu

| What do you want to do? | Command | Team |
|---|---|---|
| Discover and Document a Legacy System | `/reversa` | Reversa Agents Core |
| Clarify the idea before any code | `/reversa-brainstorm` | Ideation Agents |
| Create a new project from an idea | `/reversa-new` | Code New Project Agents |
| Implement or evolve code from specs | `/reversa-forward` | Code Forward Agents |
| Plan a legacy migration | `/reversa-migrate` | Migration Agents |
| Generate a visual documentation mini-site | `/reversa-docs` | Documentation Agents |
| Understand which agent to use | `/reversa-agents-help` | Agent Guide |

The Pricing and Translators teams have specialized commands. Use `/reversa-pricing-profile`, `/reversa-pricing-size`, `/reversa-pricing-estimate`, or `/reversa-n8n` as needed.

---

## 💡 Reversa Brainstorm, the table before work
**Command:** `/reversa-brainstorm`

Before the bricklayer builds the wall, someone sits at the table and asks what they want with the house: who it is for, what it hurts to live as it is today, what are the possible paths, what could go wrong. Nobody draws blueprints on this table. You only decide what is worth building.

> Use Reversa Brainstorm when the idea is still raw, in a new or legacy project. It conducts `Framer → Explorer → Challenger → Arbiter → Pre-Spec` and delivers the result to `/reversa-new` (greenfield) or `/reversa-requirements` (legacy).

**Os cinco da mesa:**

| Agent | Analogy | Command |
|---|---|---|
| **Framer** | The doctor who doesn't accept "I want medicine X" and asks where it hurts | `/reversa-framer` |
| **Explorer** | The guide that shows all the trails, including the one not climbing the mountain | `/reversa-explorer` |
| **Challenger** | The devil's advocate who has seen this project fail before | `/reversa-challenger` |
| **Arbiter** | The judge who gives the verdict and assumes what is lost with it, but you are the one who decides | `/reversa-arbiter` |
| **Pre-Spec** | The clerk who delivers the minimum for the work to begin, and nothing more | `/reversa-pre-spec` |

---

## 🆕 Reversa New — the product founder
**Command:** `/reversa-new`

The founder starts with a raw idea, investigates the problem, understands who the product exists for, consolidates a PRD and transforms everything into specifications ready for implementation.

> Use Reversa New for greenfield projects. It conducts `Ideator → Researcher → Drafter → Spec SDD` and delivers the result to `/reversa-forward`.

---

## 🎼 Reversa — orquestrador central
**Command:** `/reversa`

An orchestra conductor does not play any instrument. He knows the entire score and tells you who comes in when, in what order, at what rhythm. Without it, each musician would play their part without connecting with the others.

> Use Reversa to start or resume the full analysis. It takes care of the sequence for you.

---

## 🗺️ Scout — the real estate agent
**Command:** `/reversa-scout`

The broker takes the first tour of the property. He doesn't open drawers, doesn't read documents, doesn't touch anything. It just maps: how many rooms, what neighborhood it is, what facilities there are, what the general condition is.

> Use Scout at the beginning. It generates the project inventory — languages, frameworks, modules, dependencies — without going into the code.

---

## 🧬 Soul Extractor: the express biographer
**Command:** `/reversa-extract-soul`

The express biographer visits the character, reads the scout's notes, quickly flips through some family albums and letter history (git log), and produces a one-page biography: who he is, what he does, and the founding decisions that shaped his entire life. It's not the complete story, it's the distilled soul.

> Use Soul Extractor right after Scout, when you want an executive synthesis of the system (purpose, central entities and founding decisions) in a single Spec, without waiting for the entire pipeline. Does not replace Archaeologist or Detective.

---

## ⛏️ Archaeologist — o escavador
**Command:** `/reversa-archaeologist`

The archaeologist patiently digs the ground, layer by layer. Catalogs each artifact found: size, material, location, shape. He does not interpret civilization, he only accurately describes what is there.

> Use Archaeologist to analyze code module by module. It extracts functions, algorithms, data structures, and control flows. **Run one module per session** to save tokens.

---

## 🔍 Detective — o Sherlock Holmes
**Command:** `/reversa-detective`

Sherlock Holmes arrives after the archaeologist. He looks at the cataloged artifacts and asks: *"But why is this here? Who put it in? What does this reveal about who lived here?"* He doesn't dig. He interprets.

> Use the Detective after the Archaeologist. It extracts implicit business rules, reads git history like a diary, and reconstructs decisions that no one has documented.

---

## 📐 Architect — the cartographer
**Command:** `/reversa-architect`

The cartographer visits a territory and produces formal maps: floor plan, elevation map, structural plan. Someone who has never set foot there can understand everything by looking at the maps.

> Use Architect after Detective. It summarizes everything in C4 diagrams, complete ERD and integration map.

---

## 📝 Writer — the notary
**Command:** `/reversa-writer`

The notary transforms what was discovered into formal, accurate and traceable contracts. Each clause has a declared degree of certainty. The document is valid as a contract: an AI agent can reimplement the system based on it.

> Use Writer after Architect. It generates SDD, OpenAPI and user stories specs with code traceability.

---

## ⚖️ Reviewer — o revisor de specs
**Command:** `/reversa-reviewer`

The Reviewer takes the Writer's contracts and tries to break them: *"This is a contradiction. This point has no proof. This rule disappears if the user does X."* He doesn't want to destroy, he wants to ensure that what remains is solid.

> Use Reviewer after Writer. It critically reviews specs, reclassifies confidence, and raises questions for human validation.

---

## 🖼️ Visor — o ilustrador forense
**Command:** `/reversa-visor`

The forensic illustrator works only with images. Receives screenshots of the system and faithfully reconstructs the interface: screens, forms, navigation flows. You don't need the system to be running — just the photos.

> Use the Viewfinder when you have screenshots available. It documents the UI without requiring system access.

---

## 🗄️ Data Master — the geologist
**Command:** `/reversa-data-master`

The geologist maps the subsoil — the layer that no one sees but that supports everything. Tables, relationships, constraints, triggers, procedures. The invisible foundation on which the application is built.

> Use Data Master when DDL, migrations or ORM models are available. It documents the bank completely.

---

## 🎨 Design System — o estilista
**Command:** `/reversa-design-system`

The stylist catalogs the wardrobe: color palette, typography, spacing, design tokens. The "fashion rules" that govern the appearance of the system — what can and cannot be combined.

> Use the Design System when there are CSS files, themes or interface screenshots. It extracts the project's visual tokens.

---

## Recommended sequence

```
Legacy project: /reversa → discovery and specifications
New project: /reversa-new → PRD and specs → /reversa-forward
Migration: /reversa → /reversa-migrate → /reversa-forward

Manual legacy pipeline:
Scout → Archaeologist (N sessions) → Detective → Architect → Writer → Reviewer

Options at any stage:
Soul Extractor · Visor · Data Master · Design System · Reversa Docs
```
