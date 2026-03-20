// ============================================================
// threads.scad — Reusable metric thread library
// FDM-optimized trapezoidal thread profile
// ============================================================
// Usage:
//   metric_thread(diameter, pitch, length, internal, fn)
//   external_thread(d, pitch, length) — male screw thread
//   internal_thread(d, pitch, length) — female nut/hole thread
// ============================================================

// Thread tolerance compensation for FDM printing
// Add this to internal threads and subtract from external threads
FDM_CLEARANCE = 0.4; // mm — FDM tolerance gap (matches m20_bore in main_body.scad)

// M20 standard parameters
M20_DIAMETER = 20.0;
M20_PITCH    = 2.5;   // mm per revolution

// ============================================================
// Core thread module
// diameter  : nominal thread diameter (mm)
// pitch     : thread pitch (mm/rev) — positive float
// length    : total thread length along Z axis (mm)
// internal  : true = threaded hole (add clearance), false = bolt
// fn        : circle resolution (default 64)
// ============================================================
module metric_thread(diameter, pitch, length, internal = false, fn = 64) {
    // Actual radius with FDM compensation
    r_nom = diameter / 2;
    clearance = internal ? FDM_CLEARANCE : -FDM_CLEARANCE / 2;
    r = r_nom + clearance;

    // ISO metric thread geometry
    // Thread depth (radial) ≈ 0.6495 × pitch for 60° V-thread
    // We use a slightly shallower trapezoidal profile for printability
    depth = pitch * 0.55;  // slightly reduced for FDM

    // Number of full turns
    turns = length / pitch;

    // Steps per revolution
    steps = fn;
    total_steps = ceil(turns * steps);

    // Build helix using a series of rotated/translated trapezoid slices
    _metric_thread_solid(r, depth, pitch, length, internal, fn);
}

// Internal implementation using difference of cylinders with helical groove
module _metric_thread_solid(r, depth, pitch, length, internal, fn) {
    if (internal) {
        // For internal threads: start with cylinder, cut helical groove
        difference() {
            children();
            _helix_thread_cut(r + depth, depth, pitch, length, fn);
        }
    } else {
        // For external threads: cylinder with helical ridge
        union() {
            cylinder(r = r - depth, h = length, $fn = fn);
            _helix_thread_ridge(r, depth, pitch, length, fn);
        }
    }
}

// ============================================================
// Standalone external thread (male bolt thread)
// ============================================================
module external_thread(diameter, pitch, length, fn = 64) {
    r_nom = diameter / 2;
    r = r_nom - FDM_CLEARANCE / 2;
    depth = pitch * 0.55;
    r_root = r - depth;

    turns = length / pitch;
    steps_per_turn = fn;
    total_steps = ceil(turns * steps_per_turn);

    // Build helix polyhedron
    union() {
        cylinder(r = r_root, h = length, $fn = fn);
        _thread_helix(r_root, r, depth, pitch, length, fn, total_steps);
    }
}

// ============================================================
// Standalone internal thread (female hole — call inside difference())
// ============================================================
module internal_thread(diameter, pitch, length, fn = 64) {
    r_nom = diameter / 2;
    r = r_nom + FDM_CLEARANCE;
    depth = pitch * 0.55;
    r_crest = r + depth;

    turns = length / pitch;
    steps_per_turn = fn;
    total_steps = ceil(turns * steps_per_turn);

    _thread_helix(r, r_crest, depth, pitch, length, fn, total_steps);
    cylinder(r = r, h = length, $fn = fn);
}

// ============================================================
// Core helix builder — creates a helical ridge polyhedron
// r_root   : minor radius (root of thread)
// r_crest  : major radius (crest/peak of thread)
// depth    : radial thread depth = r_crest - r_root
// pitch    : axial pitch (mm/rev)
// length   : total axial length
// fn       : segments per revolution
// total    : total segment count
// ============================================================
module _thread_helix(r_root, r_crest, depth, pitch, length, fn, total) {
    // Build helix as polyhedron using 4-point quads per segment
    // Each segment: two points at start, two at end (root + crest)
    spr = fn; // steps per revolution
    dz = pitch / spr; // axial step per segment

    pts = [
        for (i = [0 : total]) let(
            a0 = i * 360 / spr,
            a1 = (i + 0.5) * 360 / spr,
            a2 = (i + 1) * 360 / spr,
            z0 = min(i * dz, length),
            zc = min((i + 0.5) * dz, length),
            z1 = min((i + 1) * dz, length)
        ) each [
            // [0] root at step start
            [r_root * cos(a0), r_root * sin(a0), z0],
            // [1] crest at step mid  
            [r_crest * cos(a1), r_crest * sin(a1), zc],
            // [2] root at step end
            [r_root * cos(a2), r_root * sin(a2), z1]
        ]
    ];

    // Faces: for each step i, connect pts[i*3+0..2] with pts[(i+1)*3+0..2]
    // This is complex; use a simpler sweep approach instead
    _simple_helix_thread(r_root, r_crest, pitch, length, fn);
}

// ============================================================
// Simple, robust helix thread using hull() of trapezoid slices
// ============================================================
module _simple_helix_thread(r_root, r_crest, pitch, length, fn) {
    steps_per_turn = fn;
    dangle = 360 / steps_per_turn;
    dz = pitch / steps_per_turn;
    total_steps = floor(length / dz);
    depth = r_crest - r_root;

    for (i = [0 : total_steps - 1]) {
        a0 = i * dangle;
        a1 = (i + 1) * dangle;
        z0 = i * dz;
        z1 = (i + 1) * dz;
        z_mid0 = z0 + dz / 4;
        z_mid1 = z0 + 3 * dz / 4;

        if (z1 <= length) {
            hull() {
                // Start trapezoid slice
                _thread_slice(r_root, r_crest, depth, a0, z0, dz / 2);
                // End trapezoid slice
                _thread_slice(r_root, r_crest, depth, a1, z0 + dz / 2, dz / 2);
            }
        }
    }
}

module _thread_slice(r_root, r_crest, depth, angle, z_base, dz) {
    // A thin trapezoid oriented at given angle and z position
    translate([0, 0, z_base])
    rotate([0, 0, angle])
    linear_extrude(height = 0.01, center = false)
    polygon([
        [r_root, -0.5],
        [r_crest, 0],
        [r_root, 0.5]
    ]);
}

// ============================================================
// Cut a helical groove (for internal threads)
// ============================================================
module _helix_thread_cut(r_crest, depth, pitch, length, fn) {
    r_root = r_crest - depth;
    // The cut is the groove shape swept helically
    // We use a slightly oversized version for clean internal threads
    _simple_helix_thread(r_root - 0.1, r_crest + 0.1, pitch, length + pitch, fn);
    // Also bore the minor cylinder
    cylinder(r = r_root, h = length + 0.2, center = false, $fn = fn);
}

// ============================================================
// Cut a helical groove (for internal threads) — standalone
// ============================================================
module _helix_thread_ridge(r, depth, pitch, length, fn) {
    r_root = r - depth;
    _simple_helix_thread(r_root, r, pitch, length, fn);
}
