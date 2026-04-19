# Bronze Plaque OpenSCAD Project Roadmap

## Phase 1: Core Plaque Geometry
- [x] Solid base slab with configurable dimensions
- [x] Raised border frame around perimeter
- [x] Recessed inner field
- [x] Configurable border width and height
- [x] Configurable field depth

## Phase 2: Mounting Holes
- [x] Optional through-hole mounting holes
- [x] Configurable diameter and inset from edge
- [x] Two layouts: "corners" (4 holes) and "top-bottom" (2 holes)

## Phase 3: Text System
- [x] Variable number of text lines (OpenSCAD vector)
- [x] Configurable font, size, alignment
- [x] Configurable line spacing and engrave depth
- [x] Auto-scaling: font shrinks when text exceeds available area
- [x] Text properly engraved (boolean subtraction) into field surface

## Phase 4: Medallion
- [x] Optional raised medallion in centre of field
- [x] Three shapes: circle, oval, rect
- [x] Text engraves into medallion surface when enabled

## Phase 5: Quality and Output
- [x] Clean STL export (manifold mesh, Simple: yes)
- [x] $fn=64 for smooth curves
- [x] Material weight calculator (echo output)
- [x] Zero warnings on render

## Future Enhancements (not yet implemented)
- [ ] SVG/DXF graphic import
- [ ] Border pattern library (rope, Greek key, beveled)
- [ ] Background texture options (brushed, hammered)
- [ ] DXF 2D output mode for laser/waterjet
- [ ] Per-line font/size/alignment overrides
- [ ] Countersink option for mounting holes
