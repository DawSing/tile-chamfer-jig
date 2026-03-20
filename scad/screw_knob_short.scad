// ============================================================
// screw_knob_short.scad — Table-clamp screw knob (M20, short)
// ============================================================
// A fully-threaded M20 bolt with a large 5-point star ergonomic
// knob and an optional flat pressure pad at the tip.
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
// Thread length (shorter knob, for table clamp ~40 mm travel)
thread_length = 42;

/* [Pressure Pad] */
// Add a flat pad at the screw tip to protect the workbench surface
add_pad = true;
pad_diameter = 28;
pad_height   = 4;

/* [Resolution] */
$fn = 64;

// ----------------------------------------------------------------
// Render
// ----------------------------------------------------------------
screw_knob_short();

module screw_knob_short() {
    union() {
        // Star knob (flat bottom, comfortable grip)
        star_knob(knob_diameter, knob_height, knob_points,
                  star_depth, star_tip_r);

        // Threaded shaft — uses external_thread() from libs/threads.scad
        translate([0, 0, knob_height])
        external_thread(thread_diam, thread_pitch, thread_length);

        // Optional pressure pad at screw tip to protect workbench
        if (add_pad) {
            translate([0, 0, knob_height + thread_length])
            cylinder(d = pad_diameter, h = pad_height);
        }
    }
}

