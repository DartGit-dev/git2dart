# Error and Handling Scenarios

Catalog of common errors in the `arquitetura-3d` skill and how to handle them to preserve the user experience.

---

## ERR-01: Three.js unavailable (CDN unreachable)

**Cause**: user is offline on first run, or CDN blocked by corporate firewall.

**Detection**: Script `<script type="module">` fails to import, or `THREE` becomes `undefined` after loading.

**Tratamento**:

```javascript
try {
    const mod = await import("https://cdn.jsdelivr.net/npm/three@0.158.0/build/three.module.js");
    window.THREE = mod;
} catch (e) {
    document.getElementById("loader").innerHTML = `
        <div class="error-panel">
<h2>Unable to load 3D library</h2>
<p>This preview requires internet access to download Three.js once.
Connect to the internet and reload the page.</p>
<p>Technical detail: ${e.message}</p>
        </div>`;
    return;
}
```

Text always in PT-BR, without indents.

---

## ERR-02: WebGL not supported

**Cause**: browser without WebGL (very rare today, but possible on old VMs or restricted corporate environments).

**Detection**: `new THREE.WebGLRenderer()` throws exception or returns `null`.

**Tratamento**:

```javascript
let renderer;
try {
    renderer = new THREE.WebGLRenderer({ antialias: true });
} catch (e) {
showFallback("WebGL is not available in your browser. Use an updated Chrome, Firefox or Edge.");
    return;
}
```

Fallback displays a static version of the scene (pre-rendered screenshot if available, or symbolic ASCII art) with clear message.

---

## ERR-03: JSON malformado

**Cause**: `modules.json` or `deps.json` with invalid syntax, or expected fields missing.

**Detection**: `JSON.parse` fails, or schema validation indicates missing fields.

**Tratamento**:

```javascript
function loadData() {
    const raw = document.getElementById("data").textContent;
    let data;
    try {
        data = JSON.parse(raw);
    } catch (e) {
showError("Invalid input data: malformed file JSON. " + e.message);
        return null;
    }

    if (!Array.isArray(data.modules)) {
showError("Invalid input data: 'modules' must be a list.");
        return null;
    }

    data.modules = data.modules.filter((m) => {
        if (!m.name) {
console.warn("Module without 'name' discarded:", m);
            return false;
        }
        return true;
    });

    return data;
}
```

Non-fatal errors (bad individual module) discard the item with warning. Fatal errors (invalid root structure) show clear message.

---

## ERR-04: Empty project or no viewable data

**Cause**: `modules.json` has 0 items, or `deps.json` has 0 edges, or both.

**Detection**: after `loadData()`, item count.

**Tratamento**:

```javascript
if (data.modules.length === 0) {
    showEmptyState({
        title: "Nothing to view yet",
        message: "The project has no modules detected. Run `/reversa` to extract the structure first.",
        actions: [
{ label: "Back to documentation", href: "index.html" }
        ]
    });
    return;
}
```

Empty state friendly, never silent empty scene.

---

## ERR-05: Project too large (>5,000 modules without grouping)

**Cause**: User forces Code City mode without clustering on a huge project.

**Detection**: `data.modules.length > 5000` and no grouping strategy activated.

**Tratamento**: aplicar agrupamento automaticamente e avisar.

```javascript
if (data.modules.length > 5000) {
showToast("Large project detected (" + data.modules.length + " files). Grouping by folder to maintain performance.");
    data.modules = groupByFolder(data.modules);
    config.grouped = true;
}
```

Grouping and its impact appear in the page's permanent footer: "View grouped by folder. Each block represents N files."

---

## ERR-06: Performance degradada (fps < 30)

**Cause**: weak hardware, design at upper limit, heavy shadows.

**Detection**: measure `requestAnimationFrame` delta.

```javascript
let frameTimes = [];
function measureFps(time) {
    frameTimes.push(time);
    if (frameTimes.length > 60) frameTimes.shift();
    if (frameTimes.length === 60) {
        const fps = 1000 / ((frameTimes[59] - frameTimes[0]) / 59);
        if (fps < 30 && !config.degraded) {
            degradeQuality();
        }
    }
}
```

**Tratamento progressivo** (`degradeQuality`):

1. Desativar sombras.
2. Reduce pixelRatio to 1.
3. Reduce particle counts on tours.
4. Show "Performance mode activated" toast.

---

## ERR-07: InstancedMesh limit excedido

**Cause**: Attempt to create InstancedMesh with more instances than the hardware supports (~65k limit on older hardware via Uint16, but rare).

**Detection**: Three.js console error after `setMatrixAt` for high indexes.

**Tratamento**:

```javascript
const MAX_INSTANCES = 32768;
if (modules.length > MAX_INSTANCES) {
showWarning("Instance limit exceeded. Showing only the largest " + MAX_INSTANCES + ".");
    modules = modules.sort((a, b) => b.loc - a.loc).slice(0, MAX_INSTANCES);
}
```

---

## ERR-08: Infinite dependency cycle during layout

**Cause**: graph with closed loop and iterative layout without stopping criteria.

**Detection**: measure simulation iterations; if it passes `MAX_SIM_FRAMES` without converging, abort.

**Treatment**: stop simulation at the limit frame, show warning "Layout did not converge, positions may not reflect ideal stability", draw anyway.

---

## ERR-09: WebGL context lost

**Cause**: tab inactive for a long time, changing graphics driver, GPU overloaded.

**Detection**: `webglcontextlost` event on the canvas.

**Tratamento**:

```javascript
renderer.domElement.addEventListener("webglcontextlost", (e) => {
    e.preventDefault();
showToast("3D Context was lost. Trying to recover...");
});

renderer.domElement.addEventListener("webglcontextrestored", () => {
    rebuildScene();
showToast("Context retrieved.");
});
```

Instead of reloading the page, rebuild the scene on the same canvas. Important to call `rebuildScene()` which recreates textures and buffers.

---

## ERR-10: Sidebar localStorage corrompido

**Cause**: old localStorage data with incompatible format after skill update.

**Detection**: `JSON.parse` fails to restore state, or value is outside the expected range of a slider.

**Tratamento**: silencioso, descarta e usa default.

```javascript
function loadSliderState(slider) {
    try {
        const saved = localStorage.getItem(`arq3d.${slider.dataset.param}`);
        if (saved !== null) {
            const value = parseFloat(saved);
            if (value >= slider.min && value <= slider.max) {
                slider.value = value;
            }
        }
    } catch (e) {
// ignore and keep default value
    }
}
```

---

## Utility function: showError + showWarning + showToast

```javascript
function showError(message) {
    const panel = document.createElement("div");
    panel.className = "reversa-error-panel";
panel.innerHTML = `<h2>Erro</h2><p>${escapeHtml(message)}</p>`;
    document.body.appendChild(panel);
}

function showWarning(message) {
    const panel = document.createElement("div");
    panel.className = "reversa-warning-banner";
    panel.textContent = message;
    document.body.appendChild(panel);
    setTimeout(() => panel.remove(), 8000);
}

function showToast(message) {
    const t = document.createElement("div");
    t.className = "reversa-toast";
    t.textContent = message;
    document.body.appendChild(t);
    setTimeout(() => t.remove(), 4000);
}

function escapeHtml(s) {
    return s.replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
}
```

Estilos `reversa-error-panel`, `reversa-warning-banner`, `reversa-toast` ficam no CSS compartilhado do mini-site.

---

## General principle

No errors should result in a **silent white screen**. Always show clear message in pt-br with actionable instruction or clear indication of limitation. Short messages, no framework jargon, no dashes.
