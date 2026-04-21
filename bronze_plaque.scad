// Bronze Plaque OpenSCAD Script
// Version 1.1.0
//
// Generates a 3D bronze-style plaque with:
//   - Solid base slab
//   - Raised border frame around the perimeter
//   - Recessed field inside the border
//   - Optional raised medallion in the field
//   - Raised / extruded text on the field or medallion surface
//   - All raised features (text, medallion) stay within border height
//   - Optional through-hole mounting holes
//   - Variable number of text lines with auto-scaling
//
// All dimensions in mm.

// ============================================================
// USER PARAMETERS — edit these or override with -D on the CLI
// ============================================================

// --- Overall plaque ---
plaque_width       = 150;   // X dimension
plaque_height      = 75
 ;   // Y dimension
plaque_base        = 3;     // thickness of the back plate
field_depth        = 1.5;   // how far the field is recessed below the border top

// --- Raised border ---
border_enabled     = true;
border_width       = 8;     // width of the raised rim
border_height      = 2;     // height of the rim above the field surface

// --- Medallion (raised area inside the field) ---
medallion_enabled  = false;
medallion_shape    = "oval"; // "circle", "oval", or "rect"
medallion_width    = 120;
medallion_height   = 80;
medallion_raise    = 0.5;   // how far medallion rises above field (clamped to border_height)

// --- Text ---
// Supply lines as an OpenSCAD vector of strings — any length.
text_lines = [
    "A Man For The Times",
    "The Dude",
    "1969 - 2026",
];
text_font          = "Liberation Sans:style=Bold";
text_size          = 8;    // desired font size (will be scaled down if needed)
text_halign        = "center";  // "left", "center", or "right"
text_line_spacing  = 1.4;   // multiplier on font size
text_raise         = 0.8;   // height of raised text above the surface it sits on

// --- Mounting holes ---
mounting_holes_enabled  = true;
mounting_hole_diameter  = 5;
mounting_hole_inset     = 12;  // distance from plaque edge to hole centre
mounting_hole_layout    = "corners"; // "top-bottom" or "corners"

// --- Material calculator ---
material_density = 8.7;     // g/cm³  (bronze ≈ 8.7)

// --- Render quality ---
$fn = 64;

// ============================================================
// DERIVED VALUES (do not edit)
// ============================================================

// The total Z height of the plaque at the border top
total_z = plaque_base + field_depth + border_height;

// Field surface Z (the flat recessed area)
field_z = plaque_base + field_depth;

// Inner field rectangle
field_x = border_enabled ? border_width : 0;
field_y = border_enabled ? border_width : 0;
field_w = plaque_width  - 2 * field_x;
field_h = plaque_height - 2 * field_y;

// Clamp medallion raise so it never exceeds border height
_medallion_raise = min(medallion_raise, border_height);

// Medallion surface Z
medallion_z = field_z + _medallion_raise;

// The surface Z that text sits on
text_base_z = medallion_enabled ? medallion_z : field_z;

// Clamp text raise so the top of the text never exceeds border top
_max_text_raise = total_z - text_base_z;
_text_raise = min(text_raise, _max_text_raise);

// Text area available for layout
text_area_w = medallion_enabled ? medallion_width  - 10 : field_w - 10;
text_area_h = medallion_enabled ? medallion_height - 10 : field_h - 10;

// Mounting hole positions
function _hole_positions() =
    let(
        mx = mounting_hole_inset,
        my = mounting_hole_inset,
        w  = plaque_width,
        h  = plaque_height
    )
    (mounting_hole_layout == "corners") ?
        [ [mx, my], [w-mx, my], [mx, h-my], [w-mx, h-my] ] :
        [ [w/2, my], [w/2, h-my] ];

hole_positions = _hole_positions();

// ============================================================
// AUTO-SCALE: compute the font size that fits the text area
// ============================================================

function _auto_scaled_size() =
    let(
        n         = len(text_lines),
        longest   = max([for (l = text_lines) len(l)]),
        est_w     = longest * text_size * 0.55,
        est_h     = n * text_size * text_line_spacing,
        sx        = (est_w > 0) ? text_area_w / est_w : 1,
        sy        = (est_h > 0) ? text_area_h / est_h : 1
    )
    text_size * min(sx, sy, 1.0);

scaled_text_size = _auto_scaled_size();

// ============================================================
// MODULES
// ============================================================

// --- Solid plaque body at border-top height -----------------
module plaque_body() {
    cube([plaque_width, plaque_height, total_z]);
}

// --- Material to subtract to form the recessed field --------
module field_recess() {
    if (border_enabled && field_w > 0 && field_h > 0) {
        translate([field_x, field_y, field_z])
            cube([field_w, field_h, border_height + 1]);
    }
}

// --- Raised medallion on the field surface ------------------
module medallion() {
    if (medallion_enabled) {
        cx = plaque_width  / 2;
        cy = plaque_height / 2;

        translate([cx, cy, field_z]) {
            if (medallion_shape == "circle") {
                cylinder(r = medallion_width / 2, h = _medallion_raise);
            } else if (medallion_shape == "oval") {
                scale([medallion_width / medallion_height, 1, 1])
                    cylinder(r = medallion_height / 2, h = _medallion_raise);
            } else { // "rect"
                translate([-medallion_width/2, -medallion_height/2, 0])
                    cube([medallion_width, medallion_height, _medallion_raise]);
            }
        }
    }
}

// --- Through-hole mounting holes ----------------------------
module mounting_holes() {
    if (mounting_holes_enabled) {
        for (p = hole_positions) {
            translate([p[0], p[1], -1])
                cylinder(d = mounting_hole_diameter, h = total_z + 2);
        }
    }
}

// --- 3-D raised text geometry (added to the plaque) ---------
module text_geometry() {
    n = len(text_lines);
    if (n > 0) {
        block_h = n * scaled_text_size * text_line_spacing;

        cx = plaque_width  / 2;
        cy = plaque_height / 2;

        // First baseline: top of text block, offset down by ascender
        first_y = cy + block_h / 2 - scaled_text_size * 0.85;

        for (i = [0 : n - 1]) {
            line_y = first_y - i * scaled_text_size * text_line_spacing;

            line_x = (text_halign == "left")   ? field_x + 5 :
                     (text_halign == "right")  ? plaque_width - field_x - 5 :
                     cx;

            // Text rises upward from the surface
            translate([line_x, line_y, text_base_z])
                linear_extrude(height = _text_raise)
                    text(text_lines[i],
                         size    = scaled_text_size,
                         font    = text_font,
                         halign  = text_halign,
                         valign  = "baseline");
        }
    }
}

// ============================================================
// ASSEMBLY
// ============================================================

module bronze_plaque() {
    difference() {
        union() {
            // Start with full slab, cut the recess, add medallion back
            difference() {
                plaque_body();
                field_recess();
            }
            medallion();
            // Raised text is part of the solid body
            text_geometry();
        }
        // Subtract only the mounting holes from everything
        mounting_holes();
    }
}

// ============================================================
// MAIN
// ============================================================

bronze_plaque();

// --- Material calculator (echo) ---
plaque_vol_cm3 = (plaque_width * plaque_height * total_z) / 1000;
est_weight_g   = plaque_vol_cm3 * material_density;
echo(str("=== Material estimate: ~",
         round(est_weight_g), " g  (",
         round(plaque_vol_cm3 * 10) / 10, " cm³) ==="));
