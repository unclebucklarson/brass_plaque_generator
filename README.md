# Bronze Plaque OpenSCAD Script

Parametric OpenSCAD script for generating 3D bronze-style plaques (memorial, ships, company, etc.) with engraved text, raised borders, and optional medallions.

## Features

- **Solid plaque body** with raised border and recessed inner field
- **Variable-length text** -- pass any number of lines as an OpenSCAD vector
- **Auto-scaling** -- font size shrinks automatically when text is too large
- **Medallion** -- optional raised circle/oval/rect in the centre
- **Mounting holes** -- corner or top-bottom layout, configurable
- **Material calculator** -- estimated weight echoed during render
- **Raised lettering** -- text is extruded upward, clamped to never exceed border height
- **Clean STL output** -- manifold mesh, ready for slicing or casting

## Quick Start

```bash
# Default plaque (200x150 mm, 3 lines of text)
openscad -o plaque.stl bronze_plaque.scad

# Custom size
openscad -D 'plaque_width=300' -D 'plaque_height=200' -o plaque.stl bronze_plaque.scad

# Custom text (any number of lines)
openscad -D 'text_lines=["USS Enterprise","CVN-65","United States Navy"]' \
         -o plaque.stl bronze_plaque.scad

# Enable medallion
openscad -D 'medallion_enabled=true' -o plaque.stl bronze_plaque.scad

# Disable mounting holes
openscad -D 'mounting_holes_enabled=false' -o plaque.stl bronze_plaque.scad
```

## Parameters

Edit the top of `bronze_plaque.scad` or override with `-D` on the command line.

### Plaque Dimensions

| Parameter | Description | Default |
|-----------|-------------|---------|
| `plaque_width` | Width (mm) | 200 |
| `plaque_height` | Height (mm) | 150 |
| `plaque_base` | Back plate thickness (mm) | 3 |
| `field_depth` | Recess depth below border top (mm) | 1.5 |

### Border

| Parameter | Description | Default |
|-----------|-------------|---------|
| `border_enabled` | Enable raised border | true |
| `border_width` | Rim width (mm) | 8 |
| `border_height` | Rim height above field (mm) | 2 |

### Medallion

| Parameter | Description | Default |
|-----------|-------------|---------|
| `medallion_enabled` | Enable raised medallion | false |
| `medallion_shape` | "circle", "oval", or "rect" | "oval" |
| `medallion_width` | Width (mm) | 120 |
| `medallion_height` | Height (mm) | 80 |
| `medallion_raise` | Height above field (mm) | 1 |

### Text

| Parameter | Description | Default |
|-----------|-------------|---------|
| `text_lines` | Vector of strings | ["In Loving Memory", ...] |
| `text_font` | OpenSCAD font spec | "Liberation Sans:style=Bold" |
| `text_size` | Desired font size (mm) | 12 |
| `text_halign` | "left", "center", or "right" | "center" |
| `text_line_spacing` | Line spacing multiplier | 1.4 |
| `text_raise` | Height of raised text (mm) | 0.8 |

### Mounting Holes

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mounting_holes_enabled` | Enable holes | true |
| `mounting_hole_diameter` | Hole diameter (mm) | 5 |
| `mounting_hole_inset` | Distance from edge (mm) | 12 |
| `mounting_hole_layout` | "corners" or "top-bottom" | "corners" |

### Other

| Parameter | Description | Default |
|-----------|-------------|---------|
| `material_density` | g/cm3 for weight estimate | 8.7 (bronze) |

## Files

- `bronze_plaque.scad` -- main script
- `roadmap.md` -- development roadmap
- `project_rough_details.txt` -- original requirements

## Requirements

- OpenSCAD 2021.01 or later
