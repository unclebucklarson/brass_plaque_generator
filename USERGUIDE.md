# Bronze Plaque Generator -- User Guide

This guide walks you through everything you need to create your own custom
bronze-style plaques, even if you have never used 3D modelling software before.

---

## What is OpenSCAD?

OpenSCAD is a free, open-source program that creates 3D models by reading a
text file (a "script") that describes the shape.  Unlike traditional 3D
modelling tools where you drag and click to sculpt, OpenSCAD builds models from
written instructions -- think of it like a recipe for a 3D object.

You do not need to write any code yourself.  This project provides a ready-made
script (`bronze_plaque.scad`).  All you do is change a few values at the top of
the file -- things like the width, text, and border size -- and OpenSCAD turns
those values into a 3D plaque you can 3D-print, send to a foundry, or use for
CNC machining.

---

## Installing OpenSCAD

### Windows

1. Go to <https://openscad.org/downloads.html>
2. Click the **Windows Installer** link.
3. Run the downloaded `.exe` file and follow the prompts.
4. When finished, you can open OpenSCAD from the Start menu.

### macOS

1. Go to <https://openscad.org/downloads.html>
2. Click the **macOS** link to download the `.dmg` file.
3. Open the `.dmg` and drag the OpenSCAD icon into your Applications folder.
4. Open it from Applications (you may need to right-click and choose "Open"
   the first time due to macOS security).

### Linux

Most distributions include OpenSCAD in their package manager:

- **Ubuntu / Debian:**  `sudo apt install openscad`
- **Fedora:**  `sudo dnf install openscad`
- **Arch:**  `sudo pacman -S openscad`

Or download from <https://openscad.org/downloads.html>.

---

## Getting Started

### Step 1 -- Open the script

1. Start OpenSCAD.
2. Go to **File > Open** and select `bronze_plaque.scad`.

You will see a text editor on the left and a 3D preview area on the right.

### Step 2 -- Preview your plaque

Press **F5** (or click the **Preview** button) to see a quick preview of the
plaque in the 3D view.  You can:

- **Rotate** the view by clicking and dragging.
- **Zoom** with the scroll wheel.
- **Pan** by holding Shift and dragging.

### Step 3 -- Customise your plaque

All the settings you need to change are at the very top of the file, in the
section labelled `USER PARAMETERS`.  Each setting has a comment explaining what
it does.  Here are the most important ones:

#### Changing the text

Find this section near the top:

```
text_lines = [
    "In Loving Memory",
    "John Doe",
    "1940 - 2020",
];
```

Replace the words inside the quotation marks with your own text.  You can have
as many lines as you like -- just follow the pattern:

```
text_lines = [
    "First Line",
    "Second Line",
    "Third Line",
    "Fourth Line",
];
```

Each line must be wrapped in quotes `"..."` and followed by a comma.

#### Changing the plaque size

```
plaque_width  = 200;    // width in millimetres
plaque_height = 150;    // height in millimetres
```

Change the numbers to whatever size you need.  The text will automatically
shrink if it is too large for the plaque.

#### Changing the font

```
text_font = "Liberation Sans:style=Bold";
```

You can use any font installed on your computer.  Some examples:

- `"Arial:style=Bold"`
- `"Times New Roman:style=Regular"`
- `"Georgia:style=Italic"`

The format is `"Font Name:style=Style"`.

#### Turning features on or off

Several features can be toggled with `true` or `false`:

```
border_enabled         = true;   // raised border around the edge
medallion_enabled      = false;  // raised oval/circle in the centre
mounting_holes_enabled = true;   // screw holes in the corners
```

Change `true` to `false` (or vice versa) to enable or disable a feature.

### Step 4 -- Render and export

Once you are happy with the preview:

1. Press **F6** (or click **Render**).  This performs a full-quality render and
   may take 10-30 seconds depending on the complexity.
2. Go to **File > Export > Export as STL** and save the file.

The `.stl` file is a standard 3D model format that can be used with:

- **3D printing** slicers (Cura, PrusaSlicer, BambuStudio, etc.)
- **CNC machining** software
- **Foundry / casting** services

---

## Examples

### Simple Memorial Plaque

A small, clean plaque with three lines of centred text.

```
plaque_width  = 150;
plaque_height = 100;
text_lines = [
    "In Memory Of",
    "Jane Smith",
    "1952 - 2023",
];
text_size = 10;
```

### Ship's Plaque

A larger plaque with many lines and no mounting holes.

```
plaque_width  = 300;
plaque_height = 200;
text_lines = [
    "HMS Illustrious",
    "R06",
    "Royal Navy",
    "Portsmouth, England",
    "Commissioned 1982",
    "Decommissioned 2014",
    "Per Mare Per Terram",
];
text_size = 14;
mounting_holes_enabled = false;
```

### Company / Dedication Plaque with Medallion

A square plaque with a raised oval medallion behind the text.

```
plaque_width  = 200;
plaque_height = 200;
text_lines = [
    "Acme Corporation",
    "World Headquarters",
    "Established 1955",
];
text_size = 12;
medallion_enabled = true;
medallion_shape   = "oval";
medallion_width   = 160;
medallion_height  = 120;
```

### Park Bench Plaque

A small, wide plaque with two mounting holes at the top and bottom.

```
plaque_width  = 200;
plaque_height = 60;
text_lines = [
    "For Margaret, who loved this view",
];
text_size = 8;
border_width = 5;
mounting_hole_layout = "top-bottom";
```

---

## Frequently Asked Questions

### The text is too small / too big

The script automatically shrinks text that is too wide or tall for the plaque.
If the text looks too small, try:

- Making the plaque larger (`plaque_width`, `plaque_height`).
- Using fewer or shorter lines.
- Increasing `text_size` (the script will scale it down only if it has to).

If you want bigger text, you can also reduce the `border_width` to give the
text more room.

### I want to change the font but it does not work

OpenSCAD can only use fonts that are installed on your computer.  To see which
fonts are available, go to **Help > Font List** inside OpenSCAD.

### How thick is the plaque?

The total thickness is `plaque_base + field_depth + border_height`.  With the
defaults (3 + 1.5 + 2) that is **6.5 mm**.  Increase `plaque_base` for a
thicker backing.

### Can I remove the mounting holes?

Yes.  Set:

```
mounting_holes_enabled = false;
```

### Can I have four corner holes instead of two?

The default is already four corner holes.  If you see only two, make sure you
have:

```
mounting_hole_layout = "corners";
```

Use `"top-bottom"` for two holes centred at the top and bottom edges.

### The render takes a long time

Complex text (many characters, fancy fonts) increases render time.  Some tips:

- Use **F5** (preview) while experimenting -- it is much faster.
- Only press **F6** (full render) when you are ready to export.
- Reducing `$fn` (near the top of the file) from 64 to 32 speeds things up
  at the cost of slightly less smooth curves.

### How do I 3D-print this?

1. Export the plaque as an STL file (see Step 4 above).
2. Open the STL in your slicer (Cura, PrusaSlicer, BambuStudio, etc.).
3. The plaque should sit flat on the print bed with the text facing up.
4. Print with a small layer height (0.1-0.15 mm) for the sharpest lettering.
5. For a bronze look, use bronze or gold PLA filament, or paint after printing.

### What is the estimated weight shown in the console?

When you render, the console at the bottom shows a line like:

```
=== Material estimate: ~1696 g  (195 cm³) ===
```

This assumes the plaque is solid bronze (8.7 g/cm³).  For a 3D-printed plastic
version the weight will be much less.  You can change `material_density` to
match your material (e.g. 1.24 for PLA plastic).

---

## Quick Reference -- All Parameters

| Parameter | What it does | Default |
|-----------|-------------|---------|
| `plaque_width` | Width of the plaque (mm) | 200 |
| `plaque_height` | Height of the plaque (mm) | 150 |
| `plaque_base` | Thickness of the back plate (mm) | 3 |
| `field_depth` | How far the centre is recessed (mm) | 1.5 |
| `border_enabled` | Show the raised border | true |
| `border_width` | Width of the border rim (mm) | 8 |
| `border_height` | Height of the border above the field (mm) | 2 |
| `medallion_enabled` | Show a raised medallion | false |
| `medallion_shape` | Shape: "circle", "oval", or "rect" | "oval" |
| `medallion_width` | Medallion width (mm) | 120 |
| `medallion_height` | Medallion height (mm) | 80 |
| `medallion_raise` | How far the medallion rises (mm) | 0.5 |
| `text_lines` | The lines of text (see examples) | [...] |
| `text_font` | Font name and style | "Liberation Sans:style=Bold" |
| `text_size` | Desired font size in mm | 12 |
| `text_halign` | Text alignment: "left", "center", "right" | "center" |
| `text_line_spacing` | Space between lines (multiplier) | 1.4 |
| `text_raise` | How far the text sticks up (mm) | 0.8 |
| `mounting_holes_enabled` | Show mounting holes | true |
| `mounting_hole_diameter` | Hole size (mm) | 5 |
| `mounting_hole_inset` | Distance from edge to hole (mm) | 12 |
| `mounting_hole_layout` | "corners" (4 holes) or "top-bottom" (2 holes) | "corners" |
| `material_density` | For weight estimate (g/cm³) | 8.7 |

---

## Advanced Script -- Per-Line Font and Size

If you need each line of text to have its own font, size, or alignment, use
`bronze_plaque_advanced.scad` instead of the basic script.

Everything works the same way (border, medallion, mounting holes, etc.), but
text is defined using **four matching lists** instead of a single list.

### How it works

Open `bronze_plaque_advanced.scad` and find the text section near the top.
You will see four arrays that work together:

```
text_lines = [
    "In Loving Memory",          // line 1
    "John Doe",                  // line 2
    "1940 - 2020",               // line 3
    "Rest in Peace",             // line 4
];

text_fonts = [
    "Liberation Serif:style=Italic",   // line 1 font
    "Liberation Sans:style=Bold",      // line 2 font
    "Liberation Sans:style=Regular",   // line 3 font
    "Liberation Serif:style=Italic",   // line 4 font
];

text_sizes = [
    8,       // line 1 size (mm)
    14,      // line 2 size -- larger for the name
    10,      // line 3 size
    7,       // line 4 size -- smaller footer
];

text_aligns = [
    "default",    // line 1 alignment (uses global)
    "default",    // line 2
    "default",    // line 3
    "default",    // line 4
];
```

**Important:** all four lists must have the **same number of entries**.
Each entry at position 1 describes line 1, position 2 describes line 2, etc.

### Special values

- In `text_fonts`: use `"default"` to use the global `text_font` setting.
- In `text_sizes`: use `0` to use the global `text_size` setting.
- In `text_aligns`: use `"default"` to use the global `text_halign` setting.

This means you can style only the lines you care about and leave the rest
as `"default"` or `0`.

### Example: Memorial plaque with styled lines

```
text_lines = [
    "In Loving Memory Of",
    "Margaret Thompson",
    "12 March 1938 - 7 November 2024",
    "Forever In Our Hearts",
];

text_fonts = [
    "Liberation Serif:style=Italic",
    "Liberation Sans:style=Bold",
    "Liberation Sans:style=Regular",
    "Liberation Serif:style=Italic",
];

text_sizes = [
    8,
    16,
    9,
    7,
];

text_aligns = [
    "default",
    "default",
    "default",
    "default",
];
```

This produces: a small italic header, a large bold name, medium-sized dates,
and a small italic footer -- all on the same plaque.

### Example: Ship's plaque with mixed styles

```
text_lines = [
    "SHIPS PLAQUE",
    "HMS Victory",
    "Royal Navy",
    "Portsmouth",
    "1765",
];

text_fonts = [
    "Liberation Sans:style=Bold",
    "Liberation Serif:style=Bold",
    "Liberation Sans:style=Regular",
    "Liberation Sans:style=Regular",
    "Liberation Sans:style=Regular",
];

text_sizes = [
    16,
    12,
    9,
    8,
    8,
];

text_aligns = [
    "default",
    "default",
    "default",
    "default",
    "default",
];
```

### Example: Left-aligned plaque with one centred title

```
text_lines = [
    "Acme Corporation",
    "Founded by J. Smith",
    "Springfield, IL",
    "Established 1962",
];

text_fonts = [
    "Liberation Sans:style=Bold",
    "default",
    "default",
    "default",
];

text_sizes = [
    14,
    0,
    0,
    0,
];

text_aligns = [
    "center",
    "left",
    "left",
    "left",
];

text_halign = "left";   // global default for lines that say "default"
```

Here the title is centred and bold at 14 mm, while all other lines inherit the
global left alignment and global font size.

### Auto-scaling with mixed sizes

The script automatically scales all text down proportionally if the text block
is too large for the plaque.  The size ratios between lines are preserved --
if line 2 is twice as big as line 1, it will stay twice as big after scaling.

### Exporting

The export process is the same as the basic script:

1. Press **F5** to preview.
2. Press **F6** to do a full render.
3. **File > Export > Export as STL**.

Or from the command line:

```bash
openscad -o plaque.stl bronze_plaque_advanced.scad
```
