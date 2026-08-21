# Error and Handling Scenarios

Common scenarios in the `selo-generativo` skill and how to handle them.

---

## ERR-01: p5.js unavailable (CDN unreachable)

**Cause**: user offline on first run, or CDN blocked.

**Detection**: Global variable `p5` not defined after CDN `<script>`.

**Tratamento**:

```javascript
window.addEventListener("load", () => {
    if (typeof p5 === "undefined") {
        document.getElementById("seal-container").innerHTML = `
            <div class="seal-fallback" style="width: ${SIZE}px; height: ${SIZE}px;
                 background: ${palette.bg}; display: flex; align-items: center;
                 justify-content: center; border-radius: 50%; color: ${palette.fg};">
<span>Stamp unavailable</span>
            </div>`;
        return;
    }
    // setup normal aqui
});
```

Fallback: Minimal SVG (circle + palette background color) inline, no dependency on p5.

---

## ERR-02: Canvas not supported by the browser

**Cause**: very old browser without support for `<canvas>` (very rare today).

**Detection**: `canvas.getContext("2d")` returns `null`.

**Treatment**: Drop to inline SVG with `crystal-lattice` (which is the most compatible pattern with real SVG).

---

## ERR-03: Invalid or missing seed

**Cause**: agent called the skill without a seed, or passed an empty string.

**Detection**: validation at input.

**Tratamento**: fallback seguro.

```javascript
function resolveSeed(rawSeed) {
    if (!rawSeed || typeof rawSeed !== "string" || rawSeed.length === 0) {
        const timestamp = Date.now().toString();
console.warn("Missing seed, using timestamp as fallback. Stamp will not be reproducible.");
        return timestamp;
    }
    return rawSeed;
}
```

When timestamp is used, display a warning in the page footer (only if it is large hero): "Non-reproducible stamp (no seed)".

---

## ERR-04: Extreme size

**Cause**: screen request too large (>4096) or too small (<16).

**Detection**: validation of parameter `size`.

**Tratamento**:

```javascript
function clampSize(requested) {
    const MIN = 16;
    const MAX = 4096;
    if (requested < MIN) {
console.warn(`Size ${requested} is below the minimum (${MIN}). Adjusting.`);
        return MIN;
    }
    if (requested > MAX) {
console.warn(`Size ${requested} is above the maximum (${MAX}). Adjusting.`);
        return MAX;
    }
    return requested;
}
```

Above 1024, pixel-loop patterns like `wave-interference` become heavy. The skill must warn and offer mandatory `noLoop()` with canvas cache.

---

## ERR-05: Palette with invalid colors

**Cause**: Palette received with malformed hex or missing field.

**Detection**: validation regex on each color.

**Tratamento**:

```javascript
function validatePalette(palette) {
    const HEX_RX = /^#[0-9a-fA-F]{6}$/;
    const required = ["bg", "foreground", "accent", "fg"];
    for (const field of required) {
        if (!(field in palette)) {
throw new Error(`Invalid palette: missing field '${field}'.`);
        }
    }
    if (!Array.isArray(palette.foreground) || palette.foreground.length === 0) {
throw new Error("Invalid palette: 'foreground' must be non-empty list.");
    }
    [palette.bg, palette.accent, palette.fg].forEach((c) => {
if (!HEX_RX.test(c)) throw new Error(`Invalid color: ${c}`);
    });
    palette.foreground.forEach((c) => {
if (!HEX_RX.test(c)) throw new Error(`Invalid foreground color: ${c}`);
    });
}
```

If the palette is invalid, drop to `palettes.sober` (more conservative fallback palette) and log the crash.

---

## ERR-06: Contraste insuficiente

**Cause**: palette with `accent` and `bg` very close together, generating an invisible central element.

**Detection**: `contrastRatio(accent, bg) < 4.5` (see PALETTE_BY_STYLE.md).

**Tratamento**: derivar `accent` ajustado automaticamente.

```javascript
function ensureContrast(palette) {
    if (contrastRatio(palette.accent, palette.bg) < 4.5) {
        const bgIsLight = luminance(palette.bg) > 0.5;
        palette.accent = bgIsLight ? darken(palette.accent, 0.4) : lighten(palette.accent, 0.4);
    }
    return palette;
}
```

---

## ERR-07: Chosen pattern incompatible with style

**Cause**: derivation by seed resulted in a pattern visually incompatible with the chosen style (ex: `crystal-lattice` in style `exploratory`).

**Detection**: compatibility table declared in `GENERATIVE_PATTERNS.md`.

**Treatment**: re-roll within compatible patterns.

```javascript
const STYLE_COMPATIBLE = {
    sober: ["flow-field", "crystal-lattice", "noise-strata"],
    premium: ["particle-orbit", "wave-interference"],
    dense: ["crystal-lattice", "wave-interference"],
    exploratory: ["flow-field", "particle-orbit", "noise-strata"]
};

function pickCompatible(seedHex, styleHint) {
    const allowed = STYLE_COMPATIBLE[styleHint];
    if (!allowed) return PATTERNS[0];
    const idx = parseInt(seedHex.slice(2, 4), 16) % allowed.length;
    return allowed[idx];
}
```

---

## ERR-08: Performance muito ruim em mini-selo

**Cause**: Heavy pattern on small screen consuming disproportionate CPU.

**Detection**: measure time between `setup` and final `draw`.

**Treatment**: if the canvas is mini (<200px) and the chosen pattern is `wave-interference` (pixel loop), automatically change to `crystal-lattice` (simple geometry) with a message in the console.

---

## ERR-09: Multiple instances of the same badge on the same page

**Cause**: the mini-seal appears on all pages of the mini-site. Reloading p5.js and generating a screen in each one is wasteful.

**Treatment**: generate the stamp once as SVG (for `crystal-lattice`) or PNG dataURI (for other standards) and embed it inline on all pages. The skill accepts parameter `mode: "svg" | "dataURI" | "html"` to return appropriate format.

```javascript
function exportAs(mode) {
    if (mode === "svg") return canvasToSvg();
    if (mode === "dataURI") return canvas.elt.toDataURL("image/png");
    return wrapInStandaloneHtml(canvas);
}
```

---

## ERR-10: localStorage de seed corrompido

Not directly applicable, because the skill does not persist state between executions. The seed always comes from the invoker (orchestrating agent), and reproducibility depends solely on it.

If the summoner lost the seed, the agent must recalculate from soul.md (sha256). This skill is not responsible for this.

---

## General principle

The seal is a **decorative** element. Seal failure should never break the entire page. In all of the above scenarios, there is fallback that always renders something: a colored circle, a minimal SVG, a simplified version. No white screen.

Messages in pt-br, without indents.
