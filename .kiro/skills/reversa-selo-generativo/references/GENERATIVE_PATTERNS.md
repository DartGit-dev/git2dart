# Generative Stamp Patterns

Catalog of the 5 renowned patterns that the `selo-generativo` skill produces. Each pattern has a distinct appearance, core algorithm, and parameters derived from the seed.

General seed pattern: the sha256 hash (64 hex chars) is cut into slices of 8 chars, each slice becomes a `parseInt(slice, 16)` and feeds a different parameter. Thus, different patterns of the same seed share visual personality.

---

## 1. flow-field

Perlin flow fields: thousands of particles follow noise-derived vectors, leaving curved organic tracks. "Turbulent natural" style.

**When combined**: styles `sober` (soft version) and `exploratory` (luminous version).

**Algoritmo**:

```javascript
let particles = [];
const PARTICLE_COUNT = 500;
const NOISE_SCALE = 0.004;
const STEP = 1.5;

function setup() {
    const canvas = createCanvas(SIZE, SIZE);
    canvas.parent("seal-container");
    randomSeed(seedInt);
    noiseSeed(seedInt);
    background(palette.bg);
    noFill();
    strokeWeight(0.6);

    for (let i = 0; i < PARTICLE_COUNT; i++) {
        particles.push({
            x: random(width),
            y: random(height),
            color: random(palette.foreground),
            life: random(200, 600)
        });
    }
    noLoop();
    drawFlowField();
}

function drawFlowField() {
    particles.forEach((p) => {
        stroke(p.color + "55"); // semi-transparente
        let x = p.x, y = p.y;
        for (let step = 0; step < p.life; step++) {
            const angle = noise(x * NOISE_SCALE, y * NOISE_SCALE) * TWO_PI * 4;
            const nx = x + cos(angle) * STEP;
            const ny = y + sin(angle) * STEP;
            line(x, y, nx, ny);
            x = nx;
            y = ny;
            if (x < 0 || x > width || y < 0 || y > height) break;
        }
    });
}
```

**Seed-derived parameters**:
- `PARTICLE_COUNT`: 300 a 1000 (slice 0 normalizado).
- `NOISE_SCALE`: 0.002 a 0.008 (slice 1).
- Center of gravity of the field (if there is an attractor): XY coordinate (slices 2 and 3).

**Performance**: up to 1500 particles on an 800x800 canvas without locking.

---

## 2. particle-orbit

Particles orbiting a center with decreasing tracks, creating a "rotating constellation" pattern.

**When combined**: styles `premium` (dark, gold) and `exploratory` (bright pastels).

**Algoritmo**:

```javascript
const ORBITS = 6;
const PARTICLES_PER_ORBIT = 24;

function setup() {
    const canvas = createCanvas(SIZE, SIZE);
    canvas.parent("seal-container");
    randomSeed(seedInt);
    noiseSeed(seedInt);
    background(palette.bg);
    drawOrbit();
    noLoop();
}

function drawOrbit() {
    const cx = width / 2;
    const cy = height / 2;
    for (let o = 0; o < ORBITS; o++) {
        const radius = (o + 1) * (width / (ORBITS * 2.5));
        const orbitColor = palette.foreground[o % palette.foreground.length];
        const phase = random(TWO_PI);
        const tilt = random(-PI / 6, PI / 6);

        for (let p = 0; p < PARTICLES_PER_ORBIT; p++) {
            const angle = (p / PARTICLES_PER_ORBIT) * TWO_PI + phase;
            const x = cx + cos(angle) * radius;
            const y = cy + sin(angle) * radius * cos(tilt);
            const size = map(noise(angle * 2, o), 0, 1, 1, 6);

            // Trilha
            stroke(orbitColor + "33");
            strokeWeight(0.4);
            noFill();
            arc(cx, cy, radius * 2, radius * 2 * cos(tilt), phase, angle);

// Particle
            noStroke();
            fill(orbitColor);
            ellipse(x, y, size);
        }
    }

    // Centro
    fill(palette.accent);
    noStroke();
    ellipse(cx, cy, 14);
}
```

**Seed-derived parameters**:
- Number of orbits: 3 to 8 (slice 0).
- Orbit inclination (tilt): -π/4 to π/4 (slice 1).
- Particle density per orbit (slice 2).

**Performance**: trivial, dezenas de elementos.

---

## 3. crystal-lattice

Symmetrical crystalline form derived from a base polygon, with clean geometric subdivisions. "Architectural logo" style.

**When combined**: styles `dense` (saturated) and `sober` (clean).

**Algoritmo**:

```javascript
function setup() {
    const canvas = createCanvas(SIZE, SIZE);
    canvas.parent("seal-container");
    randomSeed(seedInt);
    background(palette.bg);
    drawCrystal();
    noLoop();
}

function drawCrystal() {
    const cx = width / 2;
    const cy = height / 2;
    const sides = floor(random(5, 9)); // 5 a 8 lados
    const radius = width * 0.35;
    const layers = floor(random(3, 6));

    push();
    translate(cx, cy);

    for (let layer = layers; layer > 0; layer--) {
        const r = radius * (layer / layers);
        const rotation = (layers - layer) * (PI / sides);
        const color = palette.foreground[layer % palette.foreground.length];
        fill(color);
        stroke(palette.bg);
        strokeWeight(2);

        beginShape();
        for (let i = 0; i < sides; i++) {
            const angle = (i / sides) * TWO_PI + rotation;
            const x = cos(angle) * r;
            const y = sin(angle) * r;
            vertex(x, y);
        }
        endShape(CLOSE);
    }

// Central core
    fill(palette.accent);
    noStroke();
    const coreRadius = radius * 0.15;
    beginShape();
    for (let i = 0; i < sides; i++) {
        const angle = (i / sides) * TWO_PI;
        vertex(cos(angle) * coreRadius, sin(angle) * coreRadius);
    }
    endShape(CLOSE);

    pop();
}
```

**Seed-derived parameters**:
- Number of sides: 5 to 8 (slice 0).
- Number of concentric layers: 3 to 6 (slice 1).
- Offset rotation between layers (slice 2).

**Exportable as SVG**: This pattern is purely geometric, ideal for converting to real SVG for mini stamps.

**Performance**: trivial.

---

## 4. wave-interference

Moiré-like interference patterns: circular waves starting from multiple centers that intersect, generating complex textures based on simple rules.

**When combined**: styles `premium` (black + gold, high contrast) and `dense`.

**Algoritmo**:

```javascript
function setup() {
    const canvas = createCanvas(SIZE, SIZE);
    canvas.parent("seal-container");
    randomSeed(seedInt);
    pixelDensity(1);
    background(palette.bg);
    drawInterference();
    noLoop();
}

function drawInterference() {
    const centers = [];
    const numCenters = floor(random(2, 5));
    for (let i = 0; i < numCenters; i++) {
        centers.push({
            x: random(width * 0.2, width * 0.8),
            y: random(height * 0.2, height * 0.8),
            frequency: random(0.04, 0.10),
            phase: random(TWO_PI)
        });
    }

    loadPixels();
    for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
            let value = 0;
            centers.forEach((c) => {
                const dx = x - c.x;
                const dy = y - c.y;
                const dist = sqrt(dx * dx + dy * dy);
                value += sin(dist * c.frequency + c.phase);
            });
            value = (value / centers.length + 1) / 2;

            const colorIdx = floor(value * palette.foreground.length);
            const hex = palette.foreground[constrain(colorIdx, 0, palette.foreground.length - 1)];
            const rgb = hexToRgb(hex);
            const i = (y * width + x) * 4;
            pixels[i] = rgb.r;
            pixels[i + 1] = rgb.g;
            pixels[i + 2] = rgb.b;
            pixels[i + 3] = 255;
        }
    }
    updatePixels();
}

function hexToRgb(hex) {
    const h = hex.replace("#", "");
    return {
        r: parseInt(h.slice(0, 2), 16),
        g: parseInt(h.slice(2, 4), 16),
        b: parseInt(h.slice(4, 6), 16)
    };
}
```

**Seed-derived parameters**:
- Number of centers: 2 to 4 (slice 0).
- Wave frequency: 0.04 to 0.10 (slice 1).
- Position of each center (slices 2-N).

**Performance**: O(width * height * centers). At 800x800 with 3 centers, ~1.9M operations. Okay for `noLoop()`.

---

## 5. noise-strata

Horizontal layers of noise, forming an "abstract landscape" with layers of Perlin noise.

**When combined**: styles `sober` (neutral terracotta) and `exploratory` (auroral).

**Algoritmo**:

```javascript
function setup() {
    const canvas = createCanvas(SIZE, SIZE);
    canvas.parent("seal-container");
    randomSeed(seedInt);
    noiseSeed(seedInt);
    background(palette.bg);
    drawStrata();
    noLoop();
}

function drawStrata() {
    const layers = floor(random(4, 8));
    const baseY = height * 0.3;
    const layerHeight = (height - baseY) / layers;

    for (let l = 0; l < layers; l++) {
        const y0 = baseY + l * layerHeight;
        const color = palette.foreground[l % palette.foreground.length];
        fill(color);
        noStroke();
        beginShape();
        vertex(0, height);
        for (let x = 0; x <= width; x += 4) {
            const n = noise(x * 0.005, l * 0.7);
            const y = y0 + n * layerHeight * 1.5;
            vertex(x, y);
        }
        vertex(width, height);
        endShape(CLOSE);
    }

    // Sol/lua decorativa
    fill(palette.accent);
    noStroke();
    const sunX = random(width * 0.2, width * 0.8);
    const sunY = baseY - random(20, 60);
    const sunR = random(30, 70);
    ellipse(sunX, sunY, sunR * 2);
}
```

**Seed-derived parameters**:
- Number of layers: 4 to 8 (slice 0).
- Altura base do horizonte: 25% a 40% do canvas (slice 1).
- Position of the decorative sun/moon (slices 2 and 3).

**Performance**: trivial.

---

## Pattern selection by seed

```javascript
const PATTERNS = ["flow-field", "particle-orbit", "crystal-lattice", "wave-interference", "noise-strata"];

function pickPattern(seedHex, styleHint) {
    const patternIndex = parseInt(seedHex.slice(0, 2), 16) % PATTERNS.length;
    let chosen = PATTERNS[patternIndex];

// Smooth adjustment by style (chooses between "compatible" patterns if disconnected)
    if (styleHint && !isStyleCompatible(chosen, styleHint)) {
        chosen = pickCompatible(seedHex, styleHint);
    }
    return chosen;
}
```

The `pattern x style` compatibility appears at the beginning of this reference. When a mismatch is declared, the `pickCompatible` function reevaluates among the patterns marked as appropriate for the style.

---

## Override manual

The skill accepts parameter `forcePattern` to ignore seed derivation and choose the pattern manually, useful when the user wants a specific stamp in a different style than the default.
