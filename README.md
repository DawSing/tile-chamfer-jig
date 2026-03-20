# Tile Chamfer Jig — 3D Printable Dual C-Clamp

A robust, FDM-optimized dual C-clamp jig for **45-degree tile chamfering and beveling**, designed
entirely in OpenSCAD. The jig clamps to any standard workbench edge and holds a ceramic tile at a
precise 45° angle so you can grind or polish a consistent miter/chamfer on the tile edge.

---

## Concept

```
          ╔══════╗  ← Star-knob long screw (tile clamp)
          ║      ║
    ╔═════╬══════╬═════╗   ← Upper 45° C-clamp (tile bed)
    ║     ║ tile ║     ║     Arms at exactly 45° to horizontal
    ║     ╚══════╝     ║     Relief groove at inner corner
    ╚═══════════════╗  ║
    ╔═══════════════╝  ║   ← Lower table C-clamp
    ║  [bench edge]    ║     Slides over workbench edge (~35 mm)
    ╚══════════════════╝
          ↑
    Star-knob short screw (table clamp)
```

---

## Repository Structure

```
tile-chamfer-jig/
├── README.md
├── LICENSE
└── scad/
    ├── main_body.scad          ← One-piece dual C-clamp body
    ├── screw_knob_short.scad   ← Table-clamp screw (M20, ~42 mm thread)
    ├── screw_knob_long.scad    ← Tile-clamp screw  (M20, ~70 mm thread)
    ├── assembly.scad           ← Colour-coded assembly preview
    └── libs/
        └── threads.scad        ← Reusable M20 thread library (FDM-tuned)
```

---

## Parts List (Bill of Materials)

| # | Part | File | Qty | Notes |
|---|------|------|-----|-------|
| 1 | Main body | `main_body.scad` | 1 | One solid print |
| 2 | Short screw knob | `screw_knob_short.scad` | 1 | Table clamp |
| 3 | Long screw knob | `screw_knob_long.scad` | 1 | Tile clamp |

No hardware required — all threads are printed.

---

## Key Design Features

| Feature | Value |
|---------|-------|
| Tile-bed angle | **45°** (exact) |
| Thread standard | **M20 × 2.5 mm pitch** |
| FDM thread clearance | +0.4 mm on internal bores |
| Minimum wall thickness | **10 mm** |
| Body depth (print height) | 50 mm |
| Bench slot opening | 45 mm (fits benches up to ~35 mm thick) |
| Tile slot opening | 22 mm (fits tiles up to ~12 mm thick) |
| Relief groove radius | 4 mm (dust escape + corner clearance) |
| Knob diameter | 48 mm (5-point star) |
| Table screw thread length | 42 mm |
| Tile screw thread length | 70 mm |

---

## Recommended Print Settings

| Parameter | Value |
|-----------|-------|
| **Layer height** | 0.2 – 0.3 mm |
| **Infill** | 50 – 80 % (rectilinear or gyroid) |
| **Material** | PETG or ABS *(heat + water resistant)* |
| **Nozzle diameter** | 0.4 – 0.6 mm |
| **Wall/perimeter count** | 4 – 5 minimum |
| **Top/bottom layers** | 5 minimum |
| **Supports** | **None required** |
| **Print speed** | 40 – 60 mm/s for outer walls |

### Print Orientation

| Part | Lay flat on… |
|------|-------------|
| `main_body.scad` | Large XZ face (body depth = print height ~50 mm) |
| `screw_knob_short.scad` | Knob face down (flat bottom) |
| `screw_knob_long.scad` | Knob face down (flat bottom) |

---

## Assembly & Usage

### Assembly
1. Print all three parts.
2. Thread the **short screw knob** into the lower (table) clamp hole.
3. Thread the **long screw knob** into the upper (tile) clamp hole.
4. Back both screws out fully before clamping.

### Mounting to Workbench
1. Slide the lower C-clamp over the edge of your workbench.
2. Hand-tighten the **short star knob** to lock the jig to the bench edge.
3. Give it a firm tug to confirm it does not move.

### Clamping the Tile
1. Loosen the **long star knob** so the tile slot is fully open.
2. Insert the tile edge-first into the 45° upper clamp slot.
   The tile rests on the angled bed; the chamfered edge should protrude
   approximately 5 – 10 mm past the open end of the clamp.
3. Hand-tighten the **long star knob** firmly until the tile is secure.
4. Grind or polish the exposed tile edge with an angle grinder fitted
   with a diamond cup wheel or a polishing pad.

### Tips
- Mark a consistent protrusion length on multiple tiles with a felt-tip pen
  before clamping — this gives you a uniform chamfer width.
- Apply light water spray during grinding to reduce ceramic dust and heat.
- The relief groove at the inner corner of the tile bed prevents the sharp
  tile corner from cracking under clamping pressure and allows grinding
  slurry to escape.

---

## Parametric Customisation

Open any `.scad` file in **OpenSCAD** and adjust the variables in the
`/* [Section] */` blocks at the top of the file:

- `lc_opening` — change bench slot to fit your workbench thickness
- `uc_opening` — change tile slot to fit thicker/thinner tiles
- `uc_arm_len` — lengthen the tile bed for larger tiles
- `body_depth` — increase for extra stiffness (wider extrusion)
- `thread_length` — adjust screw travel as needed

---

## License

MIT — see [`LICENSE`](LICENSE) file for full text.

