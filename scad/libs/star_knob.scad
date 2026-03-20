// ============================================================
// star_knob.scad — Reusable ergonomic star-knob library
// ============================================================
// Provides a large 5-point (configurable) star-shaped knob that
// is comfortable to grip and turn by hand.
// All geometry is flat-bottomed and prints without supports.
//
// Usage:
//   use <star_knob.scad>
//   star_knob(diameter, height, points, depth, tip_r);
// ============================================================

// ----------------------------------------------------------------
// star_knob — main module
//   diameter  : tip-to-tip outer diameter (mm)
//   height    : knob thickness / depth (Z, mm)
//   points    : number of star points (default 5)
//   depth     : concave indent depth between points (mm)
//   tip_r     : fillet radius at each point tip for comfort (mm)
// ----------------------------------------------------------------
module star_knob(diameter, height, points = 5, depth = 7, tip_r = 5) {
    r_outer    = diameter / 2;
    r_inner    = r_outer - depth;
    angle_step = 360 / points;

    linear_extrude(height = height, convexity = 4)
    star_profile_2d(r_outer, r_inner, points, tip_r, angle_step);
}

// ----------------------------------------------------------------
// star_profile_2d — 2-D cross-section (for use with other extrudes)
// ----------------------------------------------------------------
module star_profile_2d(r_outer, r_inner, points = 5, tip_r = 5,
                       angle_step = 72) {
    offset(r = tip_r, $fn = 32)
    offset(r = -tip_r)
    polygon(_star_pts(r_outer, r_inner, points, angle_step));
}

// ----------------------------------------------------------------
// Internal helper — returns flat list of 2-D star vertices
// ----------------------------------------------------------------
function _star_pts(r_outer, r_inner, points, angle_step) =
    [for (i = [0 : points - 1])
        each [
            [r_outer * cos(i * angle_step),
             r_outer * sin(i * angle_step)],
            [r_inner * cos(i * angle_step + angle_step / 2),
             r_inner * sin(i * angle_step + angle_step / 2)]
        ]
    ];
