// Bronze Plaque OpenSCAD Script
// Version 1.0.0
//
// Generates a 3D bronze-style plaque with:
//   - Solid base slab
//   - Raised border frame around the perimeter
//   - Recessed field inside the border
//   - Optional raised medallion in the field
//   - Text engraved into the field/medallion surface
//   - Optional through-hole mounting holes
//   - Variable number of text lines with auto-scaling
//
// All dimensions in mm.

// ============================================================
// USER PARAMETERS — edit these or override with -D on the CLI
// ============================================================

// --- Overall plaque ---
plaque_width       = 200;   // X dimension
plaque_height      = 150;   // Y dimension
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
medallion_raise    = 1;     // how far the medallion surface is above the field

// --- Text ---
// Supply lines as an OpenSCAD vector of strings — any length.
text_lines = [
    "In Loving Memory",
    "John Doe",
    "1940 - 2020",
];
text_font          = "Liberation Sans:style=Bold";
text_size           = 12;   // desired font size (will be scaled down if needed)
text_halign        = "center";  // "left", "center", or "right"
text_line_spacing   = 1.4;  // multiplier on font size
text_engrave_depth  = 0.8;  // depth of engraving into the surface

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

// Field surface Z (the flat area where text sits when no medallion)
field_z = plaque_base + field_depth;  // same as total_z - border_height

// Inner field rectangle
field_x = border_enabled ? border_width : 0;
field_y = border_enabled ? border_width : 0;
field_w = plaque_width  - 2 * field_x;
field_h = plaque_height - 2 * field_y;

// Medallion surface Z
medallion_z = field_z + medallion_raise;

// Text surface Z — the surface the text is engraved into
text_surface_z = medallion_enabled ? medallion_z : field_z;

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

// --- Solid plaque body (border + field + medallion) ---------
module plaque_body() {
    // 1. Full slab at border-top height
    cube([plaque_width, plaque_height, total_z]);
}

// --- Material to subtract from the body to form the recess --
module field_recess() {
    if (border_enabled && field_w > 0 && field_h > 0) {
        // Cut the field down from border-top to field_z
        translate([field_x, field_y, field_z])
            cube([field_w, field_h, border_height + 1]); // +1 ensures clean cut
    }
}

// --- Raised medallion added back on top of field ------------
module medallion() {
    if (medallion_enabled) {
        cx = plaque_width  / 2;
        cy = plaque_height / 2;

        translate([cx, cy, field_z]) {
            if (medallion_shape == "circle") {
                cylinder(r = medallion_width / 2, h = medallion_raise);
            } else if (medallion_shape == "oval") {
                scale([medallion_width / medallion_height, 1, 1])
                    cylinder(r = medallion_height / 2, h = medallion_raise);
            } else { // "rect"
                translate([-medallion_width/2, -medallion_height/2, 0])
                    cube([medallion_width, medallion_height, medallion_raise]);
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

// --- 3-D text geometry (used for subtraction) ---------------
module text_geometry() {
    n = len(text_lines);
    if (n > 0) {
        // Total text block height
        block_h = n * scaled_text_size * text_line_spacing;

        // Centre of the text area
        cx = plaque_width  / 2;
        cy = plaque_height / 2;

        // Y of the first baseline — top of block minus half ascender
        first_y = cy + block_h / 2 - scaled_text_size * 0.85;

        for (i = [0 : n - 1]) {
            line_y = first_y - i * scaled_text_size * text_line_spacing;

            // X anchor depends on alignment
            line_x = (text_halign == "left")   ? field_x + 5 :
                     (text_halign == "right")  ? plaque_width - field_x - 5 :
                     cx;

            translate([line_x, line_y, text_surface_z - text_engrave_depth])
                linear_extrude(height = text_engrave_depth + 0.1)
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
            plaque_body();
            // Medallion sits on top of field after recess is cut,
            // but since we do body-minus-recess we add medallion to union
            // so it sticks up from the field.
        }
        field_recess();
        mounting_holes();
        text_geometry();
    }
    // Add medallion *after* the difference so it isn't cut by the recess
    medallion();
    // Now subtract text from the medallion surface too
    difference() {
        // empty union — we only need the subtraction pass
        // OpenSCAD trick: wrap in a group
    }
}

// Simpler assembly that avoids the double-pass issue:
module bronze_plaque_v2() {
    difference() {
        union() {
            difference() {
                plaque_body();
                field_recess();
            }
            medallion();
        }
        mounting_holes();
        text_geometry();
    }
}

// ============================================================
// MAIN
// ============================================================

bronze_plaque_v2();

// --- Material calculator (echo) ---
plaque_vol_cm3 = (plaque_width * plaque_height * total_z) / 1000;
est_weight_g   = plaque_vol_cm3 * material_density;
echo(str("=== Material estimate: ~",
         round(est_weight_g), " g  (",
         round(plaque_vol_cm3 * 10) / 10, " cm³) ==="));
