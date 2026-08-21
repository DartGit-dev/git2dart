# Call Graph 3D

Tree (or DAG) of **function calls** explorable in 3D. Each node is a function, each edge is a call. Allows you to navigate the depth of a chain of invocations starting from entry points (endpoints, handlers, main).

## Mapeamento

| Conceito | Visual |
|---|---|
| Function | 3D capsule or pill with label |
| Call Depth | Position in Z (depth axis) |
| Synchronous function | Solid capsule |
| Asynchronous function | Translucent capsule with particles |
| Recursive function | Glossy capsule (emissive) |
| Hot path (frequency) | Thicker line, saturated color |
| External function (lib) | Gray color |
| Project role | Color by folder/module |

## When to use

- Understand the execution flow of a specific endpoint.
- Diagnose excessive call depth (>15 levels, sign of overengineering).
- Detect indirect recursion.
- Present how the system responds to a typical request.

**When to avoid**: Static analysis without execution data is incomplete (does not capture polymorphism). For structural vision use Dependency Graph 3D.

## Expected data model

```json
{
  "entrypoints": ["POST /api/orders", "handleWebhookStripe"],
  "calls": [
    {
      "from": "POST /api/orders",
      "to": "OrderController.create",
      "type": "sync",
      "weight": 1000
    },
    {
      "from": "OrderController.create",
      "to": "OrderService.placeOrder",
      "type": "sync",
      "weight": 1000
    },
    {
      "from": "OrderService.placeOrder",
      "to": "PaymentClient.charge",
      "type": "async",
      "weight": 1000
    }
  ]
}
```

`weight` is relative frequency (number of invocations observed in a period). `type` is `sync`, `async`, `recursive`, or `external`.

## Layout algorithm: 3D radial tree

Each entrypoint becomes the root of the tree. Depth increases in the Z axis (away from the camera), functions at the same level are distributed in an XY plane.

```javascript
function layoutTree(entrypoint, calls) {
    const nodes = new Map();
    nodes.set(entrypoint, { id: entrypoint, depth: 0, x: 0, y: 0, z: 0, children: [] });

    function buildChildren(parentId, parentDepth) {
        const outgoing = calls.filter((c) => c.from === parentId);
        outgoing.forEach((c, i, arr) => {
            if (nodes.has(c.to)) {
// detected recursion
                nodes.get(c.to).recursive = true;
                return;
            }
            const angle = (i / arr.length) * Math.PI * 2;
            const radius = parentDepth * 15 + 30;
            const node = {
                id: c.to,
                depth: parentDepth + 1,
                x: nodes.get(parentId).x + Math.cos(angle) * radius,
                y: nodes.get(parentId).y + Math.sin(angle) * radius,
                z: -(parentDepth + 1) * 40,
                type: c.type,
                weight: c.weight,
                children: []
            };
            nodes.set(c.to, node);
            nodes.get(parentId).children.push(node);
            buildChildren(c.to, parentDepth + 1);
        });
    }

    buildChildren(entrypoint, 0);
    return Array.from(nodes.values());
}
```

For multiple entrypoints, each one occupies a region of the XY plane (center translation), creating parallel trees.

## Capsule rendering

```javascript
const capsuleGeo = new THREE.CapsuleGeometry(2, 6, 8, 12);
const capsuleMat = new THREE.MeshStandardMaterial({ roughness: 0.4 });
const capsules = new THREE.InstancedMesh(capsuleGeo, capsuleMat, nodes.length);

nodes.forEach((n, i) => {
    const dummy = new THREE.Object3D();
    dummy.position.set(n.x, n.y, n.z);
    dummy.rotation.z = Math.PI / 2; // horizontal
    const scale = 0.6 + Math.log(1 + (n.weight ?? 1)) * 0.2;
    dummy.scale.set(scale, scale, scale);
    dummy.updateMatrix();
    capsules.setMatrixAt(i, dummy.matrix);

    const color = new THREE.Color(colorForCall(n));
    capsules.setColorAt(i, color);
});
capsules.instanceMatrix.needsUpdate = true;
capsules.instanceColor.needsUpdate = true;
scene.add(capsules);
```

`colorForCall(n)` returns gray for external, folder color for internal, with emissive if `n.recursive`.

## Rendering of calls (edges)

Curved bezier lines connecting parent to child. Thicker for high `weight`.

```javascript
calls.forEach((c) => {
    const src = nodesById.get(c.from);
    const dst = nodesById.get(c.to);
    if (!src || !dst) return;

    const mid = new THREE.Vector3(
        (src.x + dst.x) / 2,
        (src.y + dst.y) / 2 + 10,
        (src.z + dst.z) / 2
    );
    const curve = new THREE.QuadraticBezierCurve3(
        new THREE.Vector3(src.x, src.y, src.z),
        mid,
        new THREE.Vector3(dst.x, dst.y, dst.z)
    );
    const tube = new THREE.TubeGeometry(curve, 20, 0.2 + Math.log(1 + c.weight) * 0.1, 6, false);
    const isAsync = c.type === "async";
    const mat = new THREE.MeshStandardMaterial({
        color: isAsync ? 0xb39ddb : 0x4a9eff,
        transparent: true,
        opacity: 0.6
    });
    scene.add(new THREE.Mesh(tube, mat));
});
```

## Flow animation (optional)

Particles traveling along the edges, indicating that the call is "alive". Useful for presentations.

```javascript
function animateFlow(time) {
    edgeParticles.forEach((p) => {
        const t = (time * 0.001 + p.offset) % 1;
        const pos = p.curve.getPoint(t);
        p.mesh.position.copy(pos);
    });
}
```

## Sidebar de controles

```html
<aside id="sidebar">
    <h3>Call Graph 3D</h3>

    <label>Entrypoint
        <select data-param="entrypoint">
            <!-- POPULATED -->
        </select>
    </label>

<label>Maximum depth
        <input type="range" min="1" max="20" value="10" data-param="maxDepth">
    </label>

    <label>
        <input type="checkbox" data-param="showAsync" checked> Destacar async
    </label>

    <label>
        <input type="checkbox" data-param="showExternal"> Mostrar libs externas
    </label>

    <label>
        <input type="checkbox" data-param="animateFlow"> Animar fluxo
    </label>

    <div id="depth-info"></div>
    <div id="recursive-warnings"></div>

    <button id="reset">Reset</button>
    <button id="export-png">Exportar PNG</button>
</aside>
```

## Interaction

- **Hover in capsule**: function name, source module, number of callers and callees, type.
- **Click on capsule**: focuses on the camera, highlights the chain from the entrypoint to this function.
- **Double click**: expande/colapsa subtree.
- **Toggle entrypoint**: changes the root of the view, recalculates layout.

## Performance

- Practical limit: ~500 functions per entrypoint.
- Above that, automatically collapse subtrees after depth 5 and display "+N functions" button.
- Flow animation: limit to 50 simultaneous particles to avoid dropping fps.
