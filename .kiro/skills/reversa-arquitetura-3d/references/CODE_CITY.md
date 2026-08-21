# Code City

Established standard for 3D software visualization: each project file is a **building**, grouped into **districts** that correspond to folders. It allows you to capture the size, complexity and distribution of the code in a single glance.

## Mapeamento de atributos

| Code attribute | Visual attribute of the building |
|---|---|
| Lines of code (LOC) | Height |
| Cyclomatic complexity | Base area (width x depth) |
| File Folder | District (position in the plan) |
| File type (code, test, config) | Base color |
| Hot path (change frequency or dependent) | Highlight Color (vermelho/amarelo) |

## When to use

- Initial overview of an unknown project.
- Identify very large files (tall buildings) or complex files (wide buildings).
- Detect grouping by folder (cohesive vs scattered districts).
- Executive presentation: visually impactful and intuitive.

**When to avoid**: small projects (< 30 files), where the urban metaphor is overkill. Use Dependency Graph 3D or D3 2D modules.

## Algoritmo de layout

### 1. Group by folder

```javascript
const districts = {};
modules.forEach((m) => {
    if (!districts[m.folder]) districts[m.folder] = [];
    districts[m.folder].push(m);
});
```

### 2. Calculate size of each district

The area of ​​the district is proportional to the number of files. Use simple packing (line by line) or squarified treemap.

```javascript
function packDistrict(modules, padding = 1) {
    const count = modules.length;
    const cols = Math.ceil(Math.sqrt(count));
    const rows = Math.ceil(count / cols);
    return { cols, rows };
}
```

### 3. Posicionar distritos no plano

The districts make up the city. For up to ~20 folders, pack in a simple grid. For more, use treemap.

```javascript
const districtSize = (count) => Math.sqrt(count) * cellSize * 2;
let offsetX = 0;
let offsetZ = 0;
const districtPositions = {};
Object.entries(districts).forEach(([folder, mods], i) => {
    const size = districtSize(mods.length);
    districtPositions[folder] = { x: offsetX, z: offsetZ, size };
    offsetX += size + districtGap;
    if ((i + 1) % gridCols === 0) {
        offsetX = 0;
        offsetZ += size + districtGap;
    }
});
```

### 4. Position buildings within the district

```javascript
modules.forEach((m) => {
    const district = districtPositions[m.folder];
    const local = packDistrict(districts[m.folder]);
    const indexInDistrict = districts[m.folder].indexOf(m);
    const col = indexInDistrict % local.cols;
    const row = Math.floor(indexInDistrict / local.cols);
    m.x = district.x + col * cellSize;
    m.z = district.z + row * cellSize;
});
```

### 5. Size each building

```javascript
const LOC_TO_HEIGHT = 0.4;      // 1000 LOC = 400 unidades de altura
const COMPLEXITY_TO_WIDTH = 0.8;
const MIN_W = 2;
const MIN_H = 1;

modules.forEach((m) => {
    m.height = Math.max(MIN_H, m.loc * LOC_TO_HEIGHT);
    const baseW = Math.max(MIN_W, Math.sqrt(m.complexity) * COMPLEXITY_TO_WIDTH);
    m.w = baseW;
    m.d = baseW;
});
```

### 6. Render with InstancedMesh

See `THREE_PATTERNS.md` for the InstancedMesh pattern. Each building is an instance of the same BoxGeometry, with a different matrix and color.

```javascript
const boxGeo = new THREE.BoxGeometry(1, 1, 1);
boxGeo.translate(0, 0.5, 0); // base on the floor
const mat = new THREE.MeshStandardMaterial({ roughness: 0.6 });
const buildings = new THREE.InstancedMesh(boxGeo, mat, modules.length);
buildings.castShadow = true;
buildings.receiveShadow = true;

const dummy = new THREE.Object3D();
const color = new THREE.Color();

modules.forEach((m, i) => {
    dummy.position.set(m.x, 0, m.z);
    dummy.scale.set(m.w, m.height, m.d);
    dummy.updateMatrix();
    buildings.setMatrixAt(i, dummy.matrix);
    color.set(colorForModule(m));
    buildings.setColorAt(i, color);
});
buildings.instanceMatrix.needsUpdate = true;
buildings.instanceColor.needsUpdate = true;
scene.add(buildings);
```

### 7. Floor and districts

Add a large plane as the floor and colored squares demarcating each district.

```javascript
const ground = new THREE.Mesh(
    new THREE.PlaneGeometry(2000, 2000),
    new THREE.MeshStandardMaterial({ color: 0x14141a, roughness: 1 })
);
ground.rotation.x = -Math.PI / 2;
ground.receiveShadow = true;
scene.add(ground);

Object.entries(districtPositions).forEach(([folder, d]) => {
    const districtPlane = new THREE.Mesh(
        new THREE.PlaneGeometry(d.size, d.size),
        new THREE.MeshStandardMaterial({ color: districtColor(folder), transparent: true, opacity: 0.15 })
    );
    districtPlane.rotation.x = -Math.PI / 2;
    districtPlane.position.set(d.x + d.size / 2, 0.01, d.z + d.size / 2);
    scene.add(districtPlane);
});
```

## Colors by file type

```javascript
const TYPE_COLORS = {
    code:    0x4a9eff,  // azul
    test:    0x6cc46c,  // verde
    config:  0xffc857,  // amarelo
    doc:     0xb39ddb,  // lilac
    style:   0xff9aa2,  // rosa
    asset:   0x999999   // cinza
};

function colorForModule(m) {
    if (m.isHotPath) return 0xff5a4f;
    return TYPE_COLORS[m.type] || 0xcccccc;
}
```

## Sidebar de controles (Code City)

```html
<aside id="sidebar">
    <h3>Code City</h3>

    <label>Altura (LOC)
        <input type="range" min="0.1" max="2.0" step="0.1" value="0.4" data-param="locScale">
    </label>

    <label>Base (complexidade)
        <input type="range" min="0.2" max="2.0" step="0.1" value="0.8" data-param="complexityScale">
    </label>

    <label>Threshold de hot path
        <input type="range" min="0" max="100" step="5" value="50" data-param="hotPathThreshold">
    </label>

    <label>
<input type="checkbox" data-param="showLabels" checked> Visible labels
    </label>

    <label>
        <input type="checkbox" data-param="showDistricts" checked> Mostrar distritos
    </label>

<label>Filter folder
        <select data-param="folderFilter">
<option value="all">All</option>
            <!-- POPULATED_FROM_DATA -->
        </select>
    </label>

    <button id="reset">Reset</button>
    <button id="export-png">Exportar PNG</button>
</aside>
```

When a slider changes, recalculate `m.height`, `m.w`, `m.d` and update `InstancedMesh` with new matrices.

## Interaction

- **Hover in building**: tooltip shows file name, LOC, complexity, folder.
- **Click on building**: focuses the camera on the building (animates `controls.target` to the position of the building).
- **Drag in district**: rotates camera with OrbitControls.
- **Scroll**: zoom in/out.

## Performance

- Up to **5,000 buildings** are secure with InstancedMesh.
- Above that, group files by folder (one building = one folder with aggregate height of LOC, area by number of files).
- Disable shadows if framerate drops below 30fps (detect via `requestAnimationFrame` timer).

## Variantes opcionais

- **Temporal Code City**: animate growth throughout the project's history (each commit makes buildings grow).
- **Code City colored by author**: colors indicate who is the main maintainer of each file.
- **Code City with rain**: hot paths receive the effect of falling red particles, indicating "instability".

These variants are for future versions of the skill.
