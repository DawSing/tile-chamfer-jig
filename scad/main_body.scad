// ============================================================
// main_body.scad — Dual C-clamp tile chamfering jig
// ============================================================
// Print orientation: lay flat on the large XZ face (body_depth
// dimension becomes the print height, ~50 mm — no supports needed).
//
// Coordinate system used in this file:
//   X  — body depth (extrusion / print-height direction)
//   Y  — horizontal, pointing away from the bench edge (arm reach)
//   Z  — vertical (up)
// ============================================================

/* [Body] */
// Overall body depth (becomes print height when laid flat)
body_depth = 50;

/* [Wall Thickness] */
// Minimum wall / arm thickness for FDM structural strength
wall = 10;

/* [Lower Table C-Clamp] */
// Total arm reach (Y direction)
lc_arm_len = 85;
// Bench-slot opening height — bench thickness + clearance (~35 mm bench → 45 mm slot)
lc_opening = 45;

/* [Upper Tile C-Clamp] */
// Tile-bed arm length (projected along arm direction)
uc_arm_len = 95;
// Tile-slot opening (tile thickness + generous clearance)
uc_opening = 22;

/* [Relief Groove] */
// Radius of the dust / clearance groove at the tile-bed inner corner
groove_r = 4;

/* [Thread] */
// M20 nominal bore diameter (+ FDM clearance already added in threads.scad)
m20_bore = 20.4;   // 20 mm + 0.4 mm FDM clearance

/* [Resolution] */
$fn = 64;

// ---- Derived dimensions ----------------------------------------
lc_total_h = 2 * wall + lc_opening;  // 65 mm — lower C total height

// After rotate([45,0,0]) the upper-C box projects:
//   Y_max =  (uc_arm_len + uc_opening) / sqrt(2) ≈ 82 mm
//   Z_max =  (uc_arm_len + uc_opening) / sqrt(2) ≈ 82 mm
uc_total_h = 2 * wall + uc_opening;  // 42 mm — upper C box height (local)
SQRT2 = sqrt(2);

// Spine height — must cover the entire rotated upper-C back wall
spine_extra = (uc_total_h / SQRT2) + wall * 2;
spine_h = lc_total_h + spine_extra;  // ≈ 99 mm

// ================================================================
// TOP-LEVEL
// ================================================================
main_body();

module main_body() {
    difference() {
        body_solid();
        body_cutouts();
    }
}

// ================================================================
// SOLID UNION
// ================================================================
module body_solid() {
    union() {
        // 1. Lower C-clamp solid (box spanning full C geometry)
        lower_c_solid();

        // 2. Back-wall spine — structural backbone bridging both clamps
        spine_solid();

        // 3. Upper tile C-clamp solid (45° rotated C-box)
        upper_c_solid();

        // 4. Fillet/transition block between lower top and upper C base
        fillet_block();
    }
}

// ================================================================
// CUTOUTS (openings + thread holes + relief groove)
// ================================================================
module body_cutouts() {
    // Lower C bench slot
    lower_opening_cut();

    // Upper C tile slot
    upper_opening_cut();

    // Thread hole in the lower top arm (vertical, Z direction)
    lower_thread_hole();

    // Thread hole in the upper outer arm (45° in YZ, perpendicular to arm face)
    upper_thread_hole();

    // Relief groove at the inner corner of the tile bed
    relief_groove();
}

// ----------------------------------------------------------------
// Lower C-clamp solid
//   Box: X=0..BD, Y=0..lc_arm_len, Z=0..lc_total_h
// ----------------------------------------------------------------
module lower_c_solid() {
    cube([body_depth, lc_arm_len, lc_total_h]);
}

// ----------------------------------------------------------------
// Spine (back-wall backbone)
//   Runs from Z=0 up to spine_h covering the junction area.
//   Y range: 0..wall (the "back" wall strip)
// ----------------------------------------------------------------
module spine_solid() {
    cube([body_depth, wall, spine_h]);
}

// ----------------------------------------------------------------
// Upper C-clamp solid
//   A C-box (same profile as lower C) rotated 45° around X-axis,
//   pivoting at the top of the lower section (Z = lc_total_h).
//   The local Z direction after rotate([45,0,0]) becomes world
//   direction (-1/√2, 1/√2) in YZ, and local Y becomes (1/√2, 1/√2).
//   Net effect: the bed arm rises at 45° to horizontal. ✓
// ----------------------------------------------------------------
module upper_c_solid() {
    translate([0, 0, lc_total_h])
    rotate([45, 0, 0])
    cube([body_depth, uc_arm_len, uc_total_h]);
}

// ----------------------------------------------------------------
// Fillet / transition block
//   Fills the triangular gap that appears between the top surface
//   of the lower C and the underside of the rotated upper C.
//   Uses hull() between a thin slab at Z=lc_total_h and the
//   first slice of the upper C solid.
// ----------------------------------------------------------------
module fillet_block() {
    hull() {
        // Slab at top of lower C
        translate([0, 0, lc_total_h - 0.5])
        cube([body_depth, wall + 2, 0.5]);

        // Bottom strip of the rotated upper C (first 4 mm)
        translate([0, 0, lc_total_h])
        rotate([45, 0, 0])
        cube([body_depth, wall + 2, 4]);
    }
}

// ================================================================
// OPENING CUTOUTS
// ================================================================

// Lower C bench slot
//   Removes material from Y=wall to Y=lc_arm_len+1 (open end),
//   height=lc_opening, starting just above the bottom arm.
module lower_opening_cut() {
    translate([0, wall, wall])
    cube([body_depth, lc_arm_len - wall + 2, lc_opening]);
}

// Upper C tile slot
//   Same logic but in the rotated local space of the upper C.
module upper_opening_cut() {
    translate([0, 0, lc_total_h])
    rotate([45, 0, 0])
    translate([0, wall, wall])
    cube([body_depth, uc_arm_len - wall + 2, uc_opening]);
}

// ================================================================
// THREAD HOLES
// ================================================================

// Lower thread hole — vertical (Z axis), through the top arm.
//   Centre in Y at midpoint of top arm, centred in X.
module lower_thread_hole() {
    x_c = body_depth / 2;
    y_c = (wall + lc_arm_len) / 2;   // midpoint of arm in Y
    translate([x_c, y_c, lc_total_h - wall - 1])
    cylinder(d = m20_bore, h = wall + 2);
}

// Upper thread hole — perpendicular to the clamping arm face.
//   In local space the hole goes through the top arm in Z direction.
//   After rotate([45,0,0]) this becomes a 45° hole in world YZ.
module upper_thread_hole() {
    x_c = body_depth / 2;
    y_c = (wall + uc_arm_len) / 2;   // midpoint of arm in Y (local)
    z_top = uc_total_h;               // top of upper C box (local)

    translate([0, 0, lc_total_h])
    rotate([45, 0, 0])
    translate([x_c, y_c, z_top - wall - 1])
    cylinder(d = m20_bore, h = wall + 2);
}

// ================================================================
// RELIEF GROOVE
//   A cylindrical groove along the full X depth at the inner corner
//   of the tile bed (where the tile edge would otherwise be crushed).
//   Located at the back-inner corner of the tile slot in local space.
// ================================================================
module relief_groove() {
    // In local (rotated) space: the inner corner is at (Y=wall, Z=wall)
    translate([0, 0, lc_total_h])
    rotate([45, 0, 0])
    translate([-1, wall, wall])
    rotate([0, 90, 0])
    cylinder(r = groove_r, h = body_depth + 2, $fn = 32);
}
