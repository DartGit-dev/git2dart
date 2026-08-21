---
name: reversa-image-prompt-json
description: Creates structured JSON prompts for generating images with luxurious and cinematic aesthetics (product photo, food, cosmetic, jewelry, fashion).
disable-model-invocation: true
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  team: shared-skills
  role: image-prompt-builder
---

# Image Prompt Builder

Skill to build structured JSON prompts for generating product images with
luxurious, cinematic aesthetic — optimized for **Nano Banana 2 (Gemini 3.1 Flash Image)**
via **Google Antigravity**, with support for all native model parameters.

---

## Mandatory flow

When activated, this skill must **ALWAYS** follow these steps in order:

1. **Guided interview** — Collect user information in blocks
2. **Confirmation** — Show summary and request approval
3. **JSON Generation** — Assemble the final structured prompt

---

## STAGE 1 — Interview guided by blocks

Collect information in **3 rounds of questions**, never all at once.

---

### Round 1 — Product and Scene

Ask the user:

> "Let's put together your image prompt! I need to understand the product first. Tell me:"

1. **Type of product**: What is the product? (e.g. chocolate cake, perfume bottle, sneakers, shake, jewelry...)
2. **Brand name**: Is there a visible brand? If so, what is the name?
3. **Product appearance**: Describe the color, texture, finish, shape. The more detail, the better.
4. **Elementos extras**: Tem acompanhamentos? (frutas, gelo, flores, folhas, reflexos...)
5. **Type of scene**: What is the general mood of the image?
- Suggested options: luxurious and cinematic / clean and minimalist / dramatic and contrasting / warm and cozy / futuristic and technological

---

### Round 2 — Composition and Action

> "Great! Now tell me about the dynamic look of the image:"

6. **Main action**: Is the product static or moving? (ex: liquid exploding, suspended particles, smoke, splash, cut revealing interior...)
7. **Elements suspended in the air**: Which elements fly around the product? (e.g. drops, dust, fragments, leaves, crystals, bubbles...)
8. **Support surface**: Where is the product? (ex: polished white marble, matte black stone, rustic wood, transparent glass, abstract surface...)
9. **Camera angle**: How does the camera film the product?
- Options: low angle (dominance) / eye level / slightly above / extreme macro / 3/4 angle

---

### Round 3 — Lighting, Colors and Technical Specifications

> "Almost there! Now the visual and technical part:"

10. **Lighting style**: How do you want the light?
- Options: clean and bright studio / dramatic with shadows / soft natural light / luxury product light with rim light / colorful neon light

11. **Background color palette**: Which color/gradient dominates the background? (ex: charcoal black with amber bokeh, pink gradient for champagne, dark blue for white...)

12. **Accent colors**: What colors appear in the surrounding elements? (e.g. gold, silver, bright red, pastel tones...)

13. **Resolution**: What level of quality do you need?
- `512px` — fast iteration / testing
    - `1K` — redes sociais e uso digital
- `2K` — professional content
- `4K` — maximum production / printing

14. **Aspect Ratio**: What is the aspect ratio of the image? (default: `16:9`)
- `16:9` — widescreen (default) ✅
    - `1:1` — quadrado (Instagram feed)
    - `9:16` — vertical (Stories, Reels, TikTok)
- `4:3` — classic
    - `3:4` — retrato
    - `4:1` / `1:4` — banner horizontal / vertical
    - `8:1` / `1:8` — super banner

15. **Rendering style**: Ultra-detailed photorealistic / illustration / 3D render / analog photo / other?

16. **Anything else?**: Any special details you want to ensure in the image?

---

## STEP 2 — Confirmation

After collecting all the responses, show a **summary in topics** for the user to confirm:

```
📋 RESUMO DO PROMPT:
- Produto: [type] — [brand]
- Appearance: [description]
- Cena: [tipo]
- Action: [description]
- Elementos suspensos: [lista]
- Surface: [description]
- Angle: [angle]
- Lighting: [style]
- Fundo: [cores]
- Accents: [cores]
- Resolution: [ex: 2K]
- Aspect Ratio: [ex: 1:1]
- Rendering: [ex: ultra-photorealistic]

Is it correct? Can I mount the JSON prompt now?
```

Only proceed to Step 3 after user confirmation.

---

## STEP 3 — JSON Generation

With the answers confirmed, set up the prompt following **exactly** this schema:

```json
{
  "master_prompt": {
    "scene_type": "[velocidade/estilo] [nicho] photography",
    "product": {
      "type": "[rich, adjective-heavy product description]",
      "brand_name": "[nome da marca ou 'no visible branding']",
      "appearance": "[detailed color, texture, shape, and finish]",
      "accompaniments": [
"[element 1 with sensory description]",
"[element 2 with sensory description]"
      ]
    },
    "composition": {
      "action": "[central dramatic action captured in motion]",
      "surrounding_elements": [
"[dropdown element 1 with motion detail]",
"[suspended element 2 with motion detail]",
"[suspended element 3 with motion detail]"
      ],
      "placement": "[hero positioning centered on specified surface]"
    },
    "lighting": {
      "style": "[full lighting style]",
      "effects": [
        "[efeito de rim light]",
        "[efeito de key light]",
        "[efeito de backlight ou top light]",
"[extra effect if needed]"
      ]
    },
    "color_palette": {
      "background": "[background gradient/bokeh with transition description]",
      "accents": "[comma separated list of accent colors]"
    },
    "technical_specs": {
      "camera": "[lens type], [chosen angle]",
      "shutter": "[tipo de captura — freeze-motion, long exposure, etc.]",
      "depth_of_field": "[key focus], [blur description]",
      "rendering_style": "[photorealistic / illustration / 3D render / analog photo / etc.]"
    },
    "output_specs": {
      "resolution": "[512px | 1K | 2K | 4K]",
      "aspect_ratio": "16:9",
      "model": "nano-banana-2",
      "synthid_watermark": true
    }
  }
}
```

---

## JSON quality rules

- **Luxury and premium adjectives** are mandatory in every descriptive field
- **Frozen motion** must always be present in `action` and `surrounding_elements`
- **Reflective surfaces** must be mentioned in `placement`
- The product is always the **centralized hero** of the scene
- `surrounding_elements` must have **minimum 3, maximum 6 items**
- `lighting.effects` must have **always 3 or 4 effects** (rim, key, back/top + optional extra)
- `scene_type` must follow the pattern: `"[adjetivo de velocidade/estilo] [nicho] photography"`
- `output_specs.resolution` must use the native Nano Banana 2 values: `512px`, `1K`, `2K` or `4K`
- `output_specs.aspect_ratio` must use the native values ​​supported by the model
- `output_specs.model` must always be `"nano-banana-2"`
- `output_specs.synthid_watermark` must always be `true` (Google's mandatory default)

---

## After generating the JSON

Present the JSON formatted in code block and add:

> 💡 **Antigravity usage tip:** Paste this JSON directly into the Nano Banana 2 prompt field in Google Antigravity. `output_specs` fields are interpreted natively by the model — no additional prefix is ​​required.

Ask if the user wants to adjust any field, change the aspect ratio or generate variations.

---

## Reference examples

For language pattern inspiration, see `/mnt/skills/user/image-prompt-builder/references/examples.md` if available.
