// ============================================================
// assembly.scad — Full assembly preview
// ============================================================
// Shows the main body, short table-clamp screw, and long
// tile-clamp screw in their assembled positions.
// Colour-coded for clarity.
//
// This file is for visualisation only — not for printing.
// ============================================================

use <main_body.scad>
use <screw_knob_short.scad>
use <screw_knob_long.scad>

/* [Show / Hide parts] */
show_body        = true;
show_short_screw = true;
show_long_screw  = true;

/* [Explode view offset] */
// Set > 0 to separate parts for inspection
explode = 0;   // mm

$fn = 64;

// ================================================================
// Assembly
// ================================================================

// ---- Shared dimension references (mirror main_body.scad params) ----
_body_depth  = 50;
_wall        = 10;
_lc_arm_len  = 85;
_lc_opening  = 45;
_lc_total_h  = 2 * _wall + _lc_opening;  // 65

_uc_arm_len  = 95;
_uc_opening  = 22;
_uc_total_h  = 2 * _wall + _uc_opening;  // 42

_thread_short = 42;
_thread_long  = 70;
_knob_h       = 18;
_pad_h        = 4;

// ---- Main body ----
if (show_body) {
    color("SteelBlue", 0.95)
    main_body();
}

// ---- Table-clamp short screw ----
// The screw sits in the lower top-arm thread hole.
// Thread hole centre: X = body_depth/2, Y = (wall + lc_arm_len)/2, Z = lc_total_h
// Screw is oriented Z-downward (tip points into the bench slot).
if (show_short_screw) {
    _x = _body_depth / 2;
    _y = (_wall + _lc_arm_len) / 2;
    _z = _lc_total_h + explode;   // knob sits just above top arm

    color("OrangeRed", 0.95)
    translate([_x, _y, _z])
    rotate([180, 0, 0])   // flip so knob is on top, tip points down
    screw_knob_short();
}

// ---- Tile-clamp long screw ----
// Sits in the upper arm's 45° thread hole.
// In the upper-C local frame (before rotation):
//   hole centre local: X = body_depth/2, Y = (wall + uc_arm_len)/2,
//                       Z ≈ uc_total_h (top of outer arm)
// After rotate([45,0,0]) and translate([0,0,lc_total_h]):
//   world position = rotate then translate.
if (show_long_screw) {
    _xl = _body_depth / 2;
    _yl = (_wall + _uc_arm_len) / 2;   // local Y
    _zl = _uc_total_h;                  // top of local upper arm

    // Same transform as the upper-C in main_body.scad
    color("ForestGreen", 0.95)
    translate([0, 0, _lc_total_h])
    rotate([45, 0, 0])
    translate([_xl, _yl, _zl + explode])
    rotate([180, 0, 0])   // tip points into the tile slot
    screw_knob_long();
}
