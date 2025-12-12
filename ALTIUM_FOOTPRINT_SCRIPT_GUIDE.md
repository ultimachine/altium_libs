# Altium PCB Footprint Script Generation Guide

This guide provides requirements and best practices for generating Altium Designer PCB footprint scripts (.pas files) from component datasheets.

## Project Structure

```
/pcb/Intellispin_Sensor/
  ComponentName_Footprint_Definition.txt  # Pad coordinates and specs
  ComponentName_CreateFootprint.pas       # DelphiScript file
  ComponentName_Footprint.PrjScr          # Script project file
  ComponentName.PcbLib                    # Generated output (after running script)
```

## Script Project File (.PrjScr)

```ini
[Design]
Version=1.0
HierarchyMode=0

[Document1]
DocumentPath=ComponentName_CreateFootprint.pas
AnnotationEnabled=1

[Generic]
ProjectType=Script
```

## CRITICAL: Altium Designer 21+ Origin Offset

**Altium Designer 21.x has a PCB Library origin offset issue.** Objects placed at (0,0) appear at approximately (-50000, -50000) mils or (-1270, -1270) mm.

### Solution: Add 1270mm Offset to All Coordinates

```pascal
Const
    // REQUIRED for AD21+ - compensates for library origin offset
    Offset = 1270.0;  // mm (equivalent to 50000 mils)
```

All coordinates must include this offset:
```pascal
Pad.X := MMsToCoord(Offset + PadX);  // NOT just MMsToCoord(PadX)
Pad.Y := MMsToCoord(Offset + PadY);
```

### Post-Script Steps (REQUIRED)

After running the script:
1. **View > Fit Document** (or press V, D)
2. **Select All** (Ctrl+A)
3. **Edit > Set Reference > Center** - centers the component origin

## DelphiScript Requirements

### Correct API Identifiers

**IMPORTANT:** Use `*Object` suffix for PCB objects (NOT the names without suffix):

| Object Type | Correct Identifier | WRONG |
|-------------|-------------------|-------|
| Pad | `ePadObject` | ~~ePad~~ |
| Track/Line | `eTrackObject` | ~~eTrack~~ |
| Arc | `eArcObject` | ~~eArc~~ |
| Region | `eRegionObject` | ~~eRegion~~ |
| Fill | `eFillObject` | ~~eFill~~ |
| Text | `eTextObject` | ~~eText~~ |
| Via | `eViaObject` | ~~eVia~~ |

### Coordinate Functions

| Function | Use Case |
|----------|----------|
| `MMsToCoord(value)` | Convert mm to internal coords (RECOMMENDED) |
| `MilsToCoord(value)` | Convert mils to internal coords |

**Always use mm for exact dimensions from datasheets.**

### Pad Shape Constants

| Shape | Identifier |
|-------|------------|
| Circular | `eRounded` |
| Rectangular | `eRectangular` |
| Octagonal | `eOctagonal` |
| Rounded Rectangle | `eRoundedRectangle` |

### Layer Definitions

| Layer | Identifier |
|-------|------------|
| Top Layer | `eTopLayer` |
| Bottom Layer | `eBottomLayer` |
| Multi Layer (through-hole) | `eMultiLayer` |
| Top Overlay (silkscreen) | `eTopOverlay` |
| Top Solder Mask | `eTopSolder` |
| Top Paste Mask | `eTopPaste` |
| Mechanical 1 (assembly) | `eMechanical1` |
| Mechanical 13 (courtyard) | `eMechanical13` |
| Mechanical 15 (3D body) | `eMechanical15` |

## Working Script Template (AD21 Compatible)

```pascal
{..............................................................................}
{ ComponentName PCB Footprint Generator for Altium Designer                    }
{ Manufacturer - Description                                                   }
{ Dimensions in MM (exact from datasheet)                                      }
{..............................................................................}

Procedure CreateComponentFootprint;
Const
    // AD21 origin offset (REQUIRED)
    Offset = 1270.0;

    // Component dimensions (mm) - from datasheet
    ModuleWidth = 6.0;
    ModuleHeight = 12.4;
    PadPitch = 0.9;
    PadDiameter = 0.5;
    EdgeToPad = 0.75;

    // Drawing widths (mm)
    SilkWidth = 0.15;
    AssemblyWidth = 0.1;
Var
    Board       : IPCB_Board;
    Pad         : IPCB_Pad;
    Track       : IPCB_Track;
    Arc         : IPCB_Arc;
    Col, Row    : Integer;
    PadX, PadY  : Double;
    PadName     : String;
    HalfW, HalfH : Double;
Begin
    Board := PCBServer.GetCurrentPCBBoard;
    If Board = Nil Then
    Begin
        ShowMessage('Please open a PCB Library first.');
        Exit;
    End;

    HalfW := ModuleWidth / 2.0;
    HalfH := ModuleHeight / 2.0;

    PCBServer.PreProcess;

    // Create pads
    For Row := 1 To 6 Do
    Begin
        For Col := 1 To 6 Do
        Begin
            // Calculate position WITH OFFSET
            PadX := Offset + (-HalfW + EdgeToPad + (Col - 1) * PadPitch);
            PadY := Offset + (-HalfH + EdgeToPad + (Row - 1) * PadPitch);

            Case Row Of
                1: PadName := 'A';
                2: PadName := 'B';
                3: PadName := 'C';
                4: PadName := 'D';
                5: PadName := 'E';
                6: PadName := 'F';
            End;
            PadName := PadName + IntToStr(Col);

            Pad := PcbServer.PCBObjectFactory(ePadObject, eNoDimension, eCreate_Default);
            If Pad <> Nil Then
            Begin
                Pad.X := MMsToCoord(PadX);
                Pad.Y := MMsToCoord(PadY);
                Pad.TopXSize := MMsToCoord(PadDiameter);
                Pad.TopYSize := MMsToCoord(PadDiameter);
                Pad.TopShape := eRounded;
                Pad.HoleSize := MMsToCoord(0);
                Pad.Layer := eTopLayer;
                Pad.Name := PadName;
                Board.AddPCBObject(Pad);
            End;
        End;
    End;

    // Silkscreen (with offset)
    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset - HalfW);
        Track.Y1 := MMsToCoord(Offset + HalfH);
        Track.X2 := MMsToCoord(Offset + HalfW);
        Track.Y2 := MMsToCoord(Offset + HalfH);
        Track.Width := MMsToCoord(SilkWidth);
        Track.Layer := eTopOverlay;
        Board.AddPCBObject(Track);
    End;

    // Assembly outline (with offset)
    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset - HalfW);
        Track.Y1 := MMsToCoord(Offset - HalfH);
        Track.X2 := MMsToCoord(Offset + HalfW);
        Track.Y2 := MMsToCoord(Offset - HalfH);
        Track.Width := MMsToCoord(AssemblyWidth);
        Track.Layer := eMechanical1;
        Board.AddPCBObject(Track);
    End;
    // ... repeat for other sides

    PCBServer.PostProcess;
    Board.GraphicallyInvalidate;

    ShowMessage('Footprint created!' + #13#10 +
                '1. View > Fit (V, D)' + #13#10 +
                '2. Ctrl+A select all' + #13#10 +
                '3. Edit > Set Reference > Center');
End;

End.
```

## LGA/BGA Footprint Guidelines

### Pad Sizing for LGA

| Pad Pitch | Recommended Pad Size | Notes |
|-----------|---------------------|-------|
| 1.0 mm | 0.50 - 0.55 mm | Standard LGA |
| 0.9 mm | 0.45 - 0.50 mm | BC15C |
| 0.8 mm | 0.40 - 0.45 mm | Fine pitch |
| 0.65 mm | 0.30 - 0.35 mm | Very fine pitch |
| 0.5 mm | 0.25 - 0.30 mm | Ultra fine pitch |

General rule: Pad diameter = 50-60% of pitch

### Solder Mask and Paste

| Parameter | Typical Value | Notes |
|-----------|---------------|-------|
| Solder Mask Expansion | 0.05 mm | Per IPC-7351 |
| Paste Mask Expansion | 0 to -0.05 mm | Reduce for fine pitch |
| Paste Coverage | 70-100% | Adjust for reflow |

### Courtyard and Assembly

| Feature | Layer | Size |
|---------|-------|------|
| Component Outline | Mechanical 1 | Exact component size |
| Courtyard | Mechanical 13 | Component + 0.25mm all sides |
| 3D Body | Mechanical 15 | For 3D model placement |

## Castellated/Edge-Mount Pad Guidelines (IPC-7352)

For modules with castellated (half-via) terminations on the edges, follow IPC-7352 Table 3-6.

### Key Concepts

- **Castellation**: Half-via on module edge that the PCB pad solders to
- **Heel**: Portion of PCB pad extending beyond module edge (for solder fillet)
- **Pitch**: Center-to-center spacing between pads (NOT pad size)

### IPC-7352 Castellated Pad Extensions

| Parameter | Level A (Most) | Level B (Nominal) | Level C (Least) |
|-----------|----------------|-------------------|-----------------|
| Toe extension | 0.25 mm | 0.15 mm | 0.05 mm |
| Heel extension | 0.65 mm or 50% height | 0.45 mm or 25% height | 0.45 mm |
| Side extension | 0.05 mm | 0.00 mm | 0.00 mm |
| Courtyard | +0.50 mm | +0.25 mm | +0.10 mm |

### Pad Placement for Castellated Modules

**CRITICAL:** Pad center should be at module edge (not inside) so the land pattern extends onto the host PCB:

```pascal
// CORRECT: Pad center at module edge
PadX := Offset + (-HalfW);  // Left side pads
PadX := Offset + (HalfW);   // Right side pads

// WRONG: Pad center inside module (no heel extension)
PadX := Offset + (-HalfW + EdgeToPad);  // Don't do this for castellated
```

### Pad Sizing for Castellated

| Dimension | Calculation | Example (LR62E) |
|-----------|-------------|-----------------|
| Width (horizontal) | Castellation overlap + heel (0.45mm min) | 0.5 + 0.5 = 1.0 mm |
| Height (vertical) | Match castellation height | 0.7 mm |

**Important:** Pad height must be less than pitch to avoid overlap between pads.

### Reading Mechanical Drawings

When interpreting datasheet drawings for castellated modules:

| Dimension | Typically Shows |
|-----------|-----------------|
| Larger value between pads | Pitch (center-to-center) |
| Smaller value | Pad/castellation size |
| Edge dimension | Distance from module edge to pad center |

### Pin 1 Marker Placement

For edge-mount pads, ensure pin 1 marker clears the pad area:

```pascal
// Pin 1 marker must clear pad that extends beyond module edge
// Pad extends 0.5mm outside, so place marker at least 1.0mm outside
Arc.XCenter := MMsToCoord(Offset - HalfW - 1.0);  // 1.0mm outside module
Arc.YCenter := MMsToCoord(Offset - HalfH + BottomToPad1);
Arc.Radius := MMsToCoord(0.2);
```

### Example: Edge-Mount Module (LR62E)

```
Module: 10.2 x 15.0 mm
Pins: 10 (5 per side)
Pitch: 1.1 mm
Castellation: 0.7 mm height

PCB Land Pattern:
- Pad width: 1.0 mm (extends 0.5mm onto PCB)
- Pad height: 0.7 mm (matches castellation)
- Pad X: ±5.1 mm (at module edge)
```

## Silkscreen Guidelines

### Antenna Keepout Marking

For RF modules with antennas, add a silkscreen line marking the ground plane setback:

```pascal
// Ground plane setback line (e.g., 4.4mm from top for antenna)
Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
If Track <> Nil Then
Begin
    Track.X1 := MMsToCoord(Offset - HalfW);
    Track.Y1 := MMsToCoord(Offset + HalfH - 4.4);  // 4.4mm from top
    Track.X2 := MMsToCoord(Offset + HalfW);
    Track.Y2 := MMsToCoord(Offset + HalfH - 4.4);
    Track.Width := MMsToCoord(SilkWidth);
    Track.Layer := eTopOverlay;
    Board.AddPCBObject(Track);
End;
```

### Pin 1 Indicator

```pascal
// Pin 1 dot (arc with 360 degrees = circle)
Arc := PcbServer.PCBObjectFactory(eArcObject, eNoDimension, eCreate_Default);
If Arc <> Nil Then
Begin
    Arc.XCenter := MMsToCoord(Offset - HalfW - 0.5);
    Arc.YCenter := MMsToCoord(Offset - HalfH + EdgeToPad);
    Arc.Radius := MMsToCoord(0.15);
    Arc.StartAngle := 0;
    Arc.EndAngle := 360;
    Arc.LineWidth := MMsToCoord(SilkWidth);
    Arc.Layer := eTopOverlay;
    Board.AddPCBObject(Arc);
End;
```

## IPC-7351 Naming Convention

Format: `PACKAGETYPE` + `PINCOUNT` + `_` + `SIZE` + `_P` + `PITCH`

Examples:
- `LGA36_6X12.4_P0.9` - 36-pin LGA, 6x12.4mm, 0.9mm pitch
- `BGA64_8X8_P0.8` - 64-pin BGA, 8x8mm, 0.8mm pitch
- `QFN48_7X7_P0.5` - 48-pin QFN, 7x7mm, 0.5mm pitch

## Checklist Before Delivery

- [ ] All pads from datasheet included
- [ ] Pad designators match datasheet pin numbering
- [ ] Pad size appropriate for pitch (50-60% of pitch for LGA/BGA)
- [ ] Pads correctly positioned per mechanical drawing
- [ ] **AD21 offset (1270mm) applied to all coordinates**
- [ ] Silkscreen doesn't overlap pads
- [ ] Assembly outline matches component size
- [ ] Pin 1 indicator present and clears pad area
- [ ] Antenna keepout line (if applicable)
- [ ] Footprint name follows IPC-7351 convention

### Additional for Castellated/Edge-Mount:
- [ ] Pad center at module edge (not inside)
- [ ] Heel extension meets IPC-7352 (≥0.45mm for Level B)
- [ ] Pad height < pitch (to avoid overlap)
- [ ] Pin 1 marker outside pad extension area

## Common Issues

| Issue | Solution |
|-------|----------|
| Undeclared identifier `ePad` | Use `ePadObject`, `eTrackObject`, etc. |
| Footprint at -50000 mils | Add `Offset = 1270.0` to all coordinates |
| Access violation error | Check `PCBServer.GetCurrentPCBBoard` is not nil |
| Pads not visible | Check Layer property (use `eTopLayer` for SMD) |
| Wrong pad positions | Verify coordinate calculations include offset |
| Silkscreen over pads | Adjust silkscreen lines to clear pad area |
| Castellated pads don't extend onto PCB | Place pad center at module edge, not inside |
| Pads overlap each other | Pad height must be less than pitch |
| Pin 1 marker on pad | Move marker outside pad extension (≥1.0mm from edge) |
| Mixed up pitch and pad size | Pitch = larger spacing value, pad = smaller dimension |

## How to Run Scripts in Altium

1. Open Altium Designer
2. **File > New > Library > PCB Library** (create fresh library)
3. **File > Open** > select `ComponentName_Footprint.PrjScr`
4. **DXP > Run Script** > select the procedure
5. After script completes:
   - Press **V, D** (View > Fit Document)
   - Press **Ctrl+A** (Select All)
   - **Edit > Set Reference > Center**
6. **File > Save As** > `ComponentName.PcbLib`

## Reference Examples

| Component | Package | Pins | File |
|-----------|---------|------|------|
| BC15C | LGA-36 (6x12.4mm) | 36 | `Intellispin_Sensor/BC15C_CreateFootprint.pas` |
| LR62E | Castellated edge-mount (10.2x15mm) | 10 | `Intellispin_Sensor/LR62E_CreateFootprint.pas` |

- Datasheet location: `docs/` folder
- Footprint definitions: `*_Footprint_Definition.txt` files
