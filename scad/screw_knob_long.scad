// ============================================================
// screw_knob_long.scad — Tile-clamp screw knob (M20, long)
// ============================================================
// Identical ergonomic star-knob design as screw_knob_short.scad
// but with a longer thread shaft to accommodate tile thickness
// variation and the larger travel required by the 45 degree tile clamp.
//
// Print orientation: knob-face DOWN (flat bottom on print bed).
// No supports needed — all features are self-supporting.
// ============================================================

use <libs/threads.scad>
use <libs/star_knob.scad>

/* [Knob] */
// Outer diameter of the 5-point star knob
knob_diameter = 48;
// Height / thickness of the knob body
knob_height   = 18;
// Number of star points
knob_points   = 5;
// Depth of the star-point indentation (concave between points)
star_depth     = 7;
// Fillet radius on star-point tips (ergonomics)
star_tip_r     = 5;

/* [Thread] */
// M20 nominal thread diameter
thread_diam  = 20;
// Thread pitch (M20 standard = 2.5 mm)
thread_pitch = 2.5;
// Thread length (longer knob, for tile clamp — more travel needed)
thread_length = 70;

/* [Pressure Pad] */
// Add a flat pad at the screw tip to avoid cracking the tile
add_pad = true;
pad_diameter = 22;   // smaller than table-pad to contact tile edge area
pad_height   = 4;

/* [Resolution] */
$fn = 64;

// ----------------------------------------------------------------
// Render
// ----------------------------------------------------------------
screw_knob_long();

module screw_knob_long() {
    union() {
        // Star knob (flat bottom, comfortable grip)
        star_knob(knob_diameter, knob_height, knob_points,
                  star_depth, star_tip_r);

        // Threaded shaft — uses external_thread() from libs/threads.scad
        translate([0, 0, knob_height])
        external_thread(thread_diam, thread_pitch, thread_length);

        // Optional pressure pad at screw tip to avoid cracking the tile
        if (add_pad) {
            translate([0, 0, knob_height + thread_length])
            cylinder(d = pad_diameter, h = pad_height);
        }
    }
}
