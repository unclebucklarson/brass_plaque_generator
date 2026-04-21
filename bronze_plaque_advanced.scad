// Bronze Plaque -- Advanced Per-Line Styling
// Version 1.0.0
//
// Same plaque geometry as bronze_plaque.scad, but each line of text
// can have its own font, size, and alignment.
//
// Lines are defined as parallel arrays:
//   text_lines[i]  -- the string
//   text_fonts[i]  -- the font for that line  (or "default")
//   text_sizes[i]  -- the font size in mm     (or 0 for auto)
//   text_aligns[i] -- alignment for that line  (or "default")
//
// If a line's font/size/align is "default" (or 0 for size), the
// global value is used instead.
//
// All dimensions in mm.

// ============================================================
// USER PARAMETERS
// ============================================================

// --- Overall plaque ---
plaque_width       = 200;
plaque_height      = 150;
plaque_base        = 3;
field_depth        = 1.5;

// --- Raised border ---
border_enabled     = true;
border_width       = 8;
border_height      = 2;

// --- Medallion ---
medallion_enabled  = false;
medallion_shape    = "oval";
medallion_width    = 120;
medallion_height   = 80;
medallion_raise    = 0.5;

// --- Text: parallel arrays ---
// Each array must have the same number of entries.

text_lines = [
    "In Loving Memory",
    "John Doe",
    "1940 - 2020",
    "Rest in Peace",
];

// Per-line font.  Use "default" to inherit the global text_font.
text_fonts = [
    "Liberation Serif:style=Italic",      // line 1 -- serif italic
    "Liberation Sans:style=Bold",         // line 2 -- sans bold (the name)
    "Liberation Sans:style=Regular",      // line 3 -- sans regular
    "Liberation Serif:style=Italic",      // line 4 -- serif italic
];

// Per-line size in mm.  Use 0 to inherit the global text_size.
text_sizes = [
    8,      // line 1 -- smaller header
    14,     // line 2 -- large name
    10,     // line 3 -- medium dates
    7,      // line 4 -- small footer
];

// Per-line alignment.  Use "default" to inherit the global text_halign.
text_aligns = [
    "default",   // line 1
    "default",   // line 2
    "default",   // line 3
    "default",   // line 4
];

// --- Global text defaults (used when a line says "default" or 0) ---
text_font          = "Liberation Sans:style=Bold";
text_size          = 10;
text_halign        = "center";
text_line_spacing  = 1.5;
text_raise         = 0.8;

// --- Mounting holes ---
mounting_holes_enabled  = true;
mounting_hole_diameter  = 5;
mounting_hole_inset     = 12;
mounting_hole_layout    = "corners";

// --- Material calculator ---
material_density = 8.7;

// --- Render quality ---
$fn = 64;

// ============================================================
// DERIVED VALUES
// ============================================================

total_z = plaque_base + field_depth + border_height;
field_z = plaque_base + field_depth;

field_x = border_enabled ? border_width : 0;
field_y = border_enabled ? border_width : 0;
field_w = plaque_width  - 2 * field_x;
field_h = plaque_height - 2 * field_y;

_medallion_raise = min(medallion_raise, border_height);
medallion_z      = field_z + _medallion_raise;

text_base_z      = medallion_enabled ? medallion_z : field_z;
_max_text_raise  = total_z - text_base_z;
_text_raise      = min(text_raise, _max_text_raise);

text_area_w = medallion_enabled ? medallion_width  - 10 : field_w - 10;
text_area_h = medallion_enabled ? medallion_height - 10 : field_h - 10;

// --- Resolve per-line values ---
// Returns the effective font for line i
function _eff_font(i) =
    (i < len(text_fonts) && text_fonts[i] != "default") ?
        text_fonts[i] : text_font;

// Returns the effective size for line i
function _eff_size(i) =
    (i < len(text_sizes) && text_sizes[i] > 0) ?
        text_sizes[i] : text_size;

// Returns the effective alignment for line i
function _eff_align(i) =
    (i < len(text_aligns) && text_aligns[i] != "default") ?
        text_aligns[i] : text_halign;

// ============================================================
// AUTO-SCALE
// ============================================================
//
// With mixed sizes per line, we compute a single global scale
// factor that shrinks ALL lines proportionally so the text
// block fits inside the available area.
//
// We estimate:
//   total height = sum of each line's effective size * line_spacing
//   max width    = widest line (chars * size * 0.55)
//
// Then scale = min(area_w / max_width, area_h / total_height, 1.0)

function _total_text_height() =
    let(n = len(text_lines))
    (n > 0) ?
        // Sum each line's contribution to total height
        _sum_line_heights(0, n) :
        0;

function _sum_line_heights(i, n) =
    (i >= n) ? 0 :
    _eff_size(i) * text_line_spacing + _sum_line_heights(i + 1, n);

function _max_text_width() =
    let(n = len(text_lines))
    (n > 0) ?
        max([for (i = [0 : n - 1]) len(text_lines[i]) * _eff_size(i) * 0.55]) :
        0;

function _auto_scale_factor() =
    let(
        th = _total_text_height(),
        tw = _max_text_width(),
        sx = (tw > 0) ? text_area_w / tw : 1,
        sy = (th > 0) ? text_area_h / th : 1
    )
    min(sx, sy, 1.0);

_scale_f = _auto_scale_factor();

// Effective scaled size for line i
function _scaled_size(i) = _eff_size(i) * _scale_f;

// ============================================================
// MOUNTING HOLE POSITIONS
// ============================================================

function _hole_positions() =
    let(
        mx = mounting_hole_inset, my = mounting_hole_inset,
        w = plaque_width, h = plaque_height
    )
    (mounting_hole_layout == "corners") ?
        [ [mx, my], [w-mx, my], [mx, h-my], [w-mx, h-my] ] :
        [ [w/2, my], [w/2, h-my] ];

hole_positions = _hole_positions();

// ============================================================
// MODULES
// ============================================================

module plaque_body() {
    cube([plaque_width, plaque_height, total_z]);
}

module field_recess() {
    if (border_enabled && field_w > 0 && field_h > 0) {
        translate([field_x, field_y, field_z])
            cube([field_w, field_h, border_height + 1]);
    }
}

module medallion() {
    if (medallion_enabled) {
        cx = plaque_width  / 2;
        cy = plaque_height / 2;
        translate([cx, cy, field_z]) {
            if (medallion_shape == "circle")
                cylinder(r = medallion_width / 2, h = _medallion_raise);
            else if (medallion_shape == "oval")
                scale([medallion_width / medallion_height, 1, 1])
                    cylinder(r = medallion_height / 2, h = _medallion_raise);
            else
                translate([-medallion_width/2, -medallion_height/2, 0])
                    cube([medallion_width, medallion_height, _medallion_raise]);
        }
    }
}

module mounting_holes() {
    if (mounting_holes_enabled) {
        for (p = hole_positions) {
            translate([p[0], p[1], -1])
                cylinder(d = mounting_hole_diameter, h = total_z + 2);
        }
    }
}

// --- Raised text with per-line styling ----------------------
module text_geometry() {
    n = len(text_lines);
    if (n > 0) {
        // Compute total scaled text block height
        block_h = _total_text_height() * _scale_f;

        cx = plaque_width  / 2;
        cy = plaque_height / 2;

        // Walk through lines, accumulating Y position from the top
        // We start at the top of the block and move down per line.
        top_y = cy + block_h / 2;

        for (i = [0 : n - 1]) {
            sz    = _scaled_size(i);
            fnt   = _eff_font(i);
            algn  = _eff_align(i);

            // Y offset: sum of all preceding lines' heights
            // (computed inline since OpenSCAD has no mutable state)
            preceding_h =
                (i == 0) ? 0 :
                _scale_f * _sum_line_heights(0, i);

            // Baseline sits one ascender below the top of this line's slot
            line_y = top_y - preceding_h - sz * 0.85;

            line_x = (algn == "left")  ? field_x + 5 :
                     (algn == "right") ? plaque_width - field_x - 5 :
                     cx;

            translate([line_x, line_y, text_base_z])
                linear_extrude(height = _text_raise)
                    text(text_lines[i],
                         size   = sz,
                         font   = fnt,
                         halign = algn,
                         valign = "baseline");
        }
    }
}

// ============================================================
// ASSEMBLY
// ============================================================

module bronze_plaque() {
    difference() {
        union() {
            difference() {
                plaque_body();
                field_recess();
            }
            medallion();
            text_geometry();
        }
        mounting_holes();
    }
}

// ============================================================
// MAIN
// ============================================================

bronze_plaque();

plaque_vol_cm3 = (plaque_width * plaque_height * total_z) / 1000;
est_weight_g   = plaque_vol_cm3 * material_density;
echo(str("=== Material estimate: ~",
         round(est_weight_g), " g  (",
         round(plaque_vol_cm3 * 10) / 10, " cm³) ==="));
