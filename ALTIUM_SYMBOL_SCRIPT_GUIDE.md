# Altium Schematic Symbol Script Generation Guide

This guide provides requirements and best practices for generating Altium Designer schematic symbol scripts (.pas files) from component datasheets.

## Project Structure

```
/pcb/Intellispin_Sensor/
  ComponentName_Symbol_Definition.txt  # Pin table and specs documentation
  ComponentName_CreateSymbol.pas       # DelphiScript file
  ComponentName_Symbol.PrjScr          # Script project file
  ComponentName.SchLib                 # Generated output (after running script)
```

## Script Project File (.PrjScr)

```ini
[Design]
Version=1.0
HierarchyMode=0

[Document1]
DocumentPath=ComponentName_CreateSymbol.pas
AnnotationEnabled=1

[Generic]
ProjectType=Script
```

## DelphiScript Requirements

### Correct API Identifiers

Use these identifiers (NOT the `eSch` prefixed versions):

| Object Type | Factory Identifier |
|-------------|-------------------|
| Component | `eSchComponent` |
| Pin | `ePin` |
| Rectangle | `eRectangle` |
| Parameter | `eParameter` |
| Line | `eLine` |
| Arc | `eArc` |
| Label | `eLabel` |

### Pin Electrical Types

| Type | Identifier |
|------|------------|
| Passive | `eElectricPassive` |
| Input | `eElectricInput` |
| Output | `eElectricOutput` |
| I/O | `eElectricIO` |
| Power | `eElectricPower` |
| Open Collector | `eElectricOpenCollector` |
| Open Emitter | `eElectricOpenEmitter` |
| Hi-Z | `eElectricHiZ` |

### Pin Orientation

| Direction | Identifier | Use Case |
|-----------|------------|----------|
| Right (pointing right) | `eRotate0` | Right side pins (connect from right) |
| Up | `eRotate90` | Bottom pins |
| Left (pointing left) | `eRotate180` | Left side pins (connect from left) |
| Down | `eRotate270` | Top pins |

### Required Properties

Every graphical object needs `OwnerPartId := 1` to display correctly:

```pascal
SchPin.OwnerPartId := 1;
SchRect.OwnerPartId := 1;
```

Component-level parameters need `OwnerPartId := -1`:

```pascal
SchParam.OwnerPartId := -1;
```

### Component Identification

Always set these for proper library management:

```pascal
SchComponent.LibReference := 'PartNumber';
SchComponent.DesignItemId := 'PartNumber';
SchComponent.ComponentDescription := 'Description';
SchComponent.Designator.Text := 'U?';
SchComponent.Comment.Text := 'PartNumber';
```

## User Parameters

Include these standard parameters:

| Parameter | Description |
|-----------|-------------|
| MANUFACTURER | Component manufacturer name |
| MANUFACTURER # | Manufacturer's part number |
| PART | Part number (same as DesignItemId) |
| PART DESCRIPTION | Full text description |
| VALUE | Display value |
| TOLERANCE | Tolerance spec (if applicable) |
| EE_SPEC | Key electrical specifications |

### Parameter Helper Procedure

```pascal
Procedure AddParameter(SchComponent : ISch_Component; ParamName : String; ParamValue : String);
Var
    SchParam : ISch_Parameter;
Begin
    SchParam := SchServer.SchObjectFactory(eParameter, eCreate_Default);
    If SchParam <> Nil Then
    Begin
        SchParam.Name := ParamName;
        SchParam.Text := ParamValue;
        SchParam.IsHidden := True;
        SchParam.ShowName := False;
        SchParam.OwnerPartId := -1;
        SchComponent.AddSchObject(SchParam);
    End;
End;
```

## Symbol Rectangle

### Standard Colors (BGR Format)

| Color | RGB | BGR Hex |
|-------|-----|---------|
| Light Yellow | #FFFFB0 | `$B0FFFF` |
| Light Blue | 204, 232, 255 | `$FFE8CC` |
| Light Green | 204, 255, 204 | `$CCFFCC` |
| White | 255, 255, 255 | `$FFFFFF` |

### Rectangle Properties

```pascal
SchRect := SchServer.SchObjectFactory(eRectangle, eCreate_Default);
SchRect.Location := Point(MilsToCoord(X1), MilsToCoord(Y1));
SchRect.Corner := Point(MilsToCoord(X2), MilsToCoord(Y2));
SchRect.LineWidth := 0;
SchRect.Color := $000080;           // Border color (#800000 dark red, BGR format)
SchRect.AreaColor := $B0FFFF;       // Fill color (#FFFFB0 light yellow, BGR format)
SchRect.IsSolid := True;            // Filled
SchRect.Transparent := True;        // Allow see-through
SchRect.OwnerPartId := 1;
```

## Pin Placement Guidelines

### Sizing

- Pin length: 200 mil standard
- Pin spacing: 100 mil vertical within groups
- **Group spacing: 200 mil (extra 100 mil) between logical groups** for wire fan-out
- **Power pin spacing: 200 mil between VDD and GND** for separate routing
- Rectangle should extend 200 mil beyond pin connection points on left/right
- Rectangle should extend 100 mil below the last pin to enclose pin names

### Spacing Implementation

```pascal
// Normal pin spacing (within a group)
LeftY := LeftY - 100;

// Group spacing (between groups) - adds extra 100 mil
LeftY := LeftY - 200;  // Group spacing

// Power pin spacing (between VDD and GND)
LeftY := LeftY - 200;  // Extra space after VDD
```

### Logical Grouping by Component Type

#### MCU/BLE Modules (e.g., BC15C)

**Left Side - Power & Control:**
1. **Power** - VDD at top, then 200 mil gap, then GND pins together
2. **Reset** - Active low reset (~RESET)
3. **Debug** - JTAG, SWD interfaces (SWDCLK, SWDIO)
4. **Port 0** - GPIO P0.xx in numerical order

**Right Side - GPIO Ports:**
1. **Port 1** - All P1.xx pins in numerical order (including NFC, analog)
2. **Port 2** - GPIO P2.xx in numerical order

#### RF/Radio Modules (e.g., LR62E LoRa)

**Left Side - Power & Control:**
1. **Power** - VDD at top, then 200 mil gap, then GND
2. **Control** - Reset (~NRESET), status outputs (BUSY), interrupt pins (DIO1)

**Right Side - Interface & RF:**
1. **SPI Interface** - SCK, MOSI, MISO, ~NSS (active low chip select)
2. **RF/Antenna** - ANT-SW, RF pins (with 200 mil gap from SPI group)

### Pin Naming Conventions

- Active low signals: Use tilde prefix `~RESET`, `~NSS`, `~CS` (renders with overbar)
- Multi-function pins: `P1.04/AIN0` (primary/alternate)
- Power pins: `VDD`, `GND`, `VDDIO`
- NFC pins: `P1.02/NFC1`, `P1.03/NFC2`
- Analog pins: `P1.04/AIN0` through `P1.14/AIN7`
- SPI pins: `SCK`, `MOSI`, `MISO`, `~NSS` or `~CS`
- Reset pins: `~RESET`, `~NRESET`, `~SX-NRESET` (include chip prefix if needed)

### Rectangle Sizing Calculation

Calculate the rectangle height based on the longer side:

```
Height = (num_pins * 100) + (num_group_gaps * 100) + 100 (bottom margin)
Width  = 600 mil (standard for most components)
```

**Example for BC15C (36-pin BLE module):**
- Left: 11 pins + 4 gaps = 1500 mil + 100 = 1600 mil
- Right: 25 pins + 1 gap = 2600 mil + 100 = 2700 mil
- Use the larger value: 2800 mil (with extra margin)
- Rectangle: 600 x 2800 mil

**Example for LR62E (10-pin LoRa module):**
- Left: 5 pins + 2 gaps = 700 mil + 100 = 800 mil
- Right: 5 pins + 1 gap = 600 mil + 100 = 700 mil
- Use the larger value: 800 mil
- Rectangle: 600 x 800 mil

## Script Template

```pascal
{..............................................................................}
{ ComponentName Schematic Symbol Generator for Altium Designer                 }
{ Manufacturer - Full component description                                    }
{ Run this script in Altium Designer to create the schematic symbol            }
{..............................................................................}

Procedure AddParameter(SchComponent : ISch_Component; ParamName : String; ParamValue : String);
Var
    SchParam : ISch_Parameter;
Begin
    SchParam := SchServer.SchObjectFactory(eParameter, eCreate_Default);
    If SchParam <> Nil Then
    Begin
        SchParam.Name := ParamName;
        SchParam.Text := ParamValue;
        SchParam.IsHidden := True;
        SchParam.ShowName := False;
        SchParam.OwnerPartId := -1;
        SchComponent.AddSchObject(SchParam);
    End;
End;

Procedure CreateComponentSymbol;
Var
    SchLib       : ISch_Lib;
    SchComponent : ISch_Component;
    SchPin       : ISch_Pin;
    SchRect      : ISch_Rectangle;
    LeftY, RightY : Integer;
Begin
    If SchServer = Nil Then Exit;

    SchLib := SchServer.GetCurrentSchDocument;
    If SchLib = Nil Then
    Begin
        ShowMessage('Please open or create a Schematic Library first.');
        Exit;
    End;

    // Create component
    SchComponent := SchServer.SchObjectFactory(eSchComponent, eCreate_Default);
    If SchComponent = Nil Then Exit;

    SchComponent.LibReference := 'PARTNUM';
    SchComponent.ComponentDescription := 'Full Description';
    SchComponent.Designator.Text := 'U?';
    SchComponent.Comment.Text := 'PARTNUM';
    SchComponent.DesignItemId := 'PARTNUM';

    // Add parameters
    AddParameter(SchComponent, 'MANUFACTURER', 'Manufacturer Name');
    AddParameter(SchComponent, 'MANUFACTURER #', 'PARTNUM');
    AddParameter(SchComponent, 'PART', 'PARTNUM');
    AddParameter(SchComponent, 'PART DESCRIPTION', 'Full description');
    AddParameter(SchComponent, 'VALUE', 'PARTNUM');
    AddParameter(SchComponent, 'TOLERANCE', '');
    AddParameter(SchComponent, 'EE_SPEC', 'Key specs');

    // Create rectangle body
    SchRect := SchServer.SchObjectFactory(eRectangle, eCreate_Default);
    SchRect.Location := Point(MilsToCoord(-200), MilsToCoord(0));
    SchRect.Corner := Point(MilsToCoord(800), MilsToCoord(-2000));
    SchRect.LineWidth := 0;
    SchRect.Color := $000080;  // #800000 dark red (BGR format)
    SchRect.AreaColor := $B0FFFF;
    SchRect.IsSolid := True;
    SchRect.Transparent := True;
    SchRect.OwnerPartId := 1;
    SchComponent.AddSchObject(SchRect);

    // Left side pins
    LeftY := -100;

    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := 'PIN#';
    SchPin.Name := 'PINNAME';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 100;

    // Right side pins
    RightY := -100;

    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'PIN#';
    SchPin.Name := 'PINNAME';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // Add to library
    SchLib.AddSchComponent(SchComponent);
    SchLib.CurrentSchComponent := SchComponent;
    SchLib.GraphicallyInvalidate;

    ShowMessage('Symbol created successfully!');
End;

End.
```

## Checklist Before Delivery

- [ ] All pins from datasheet included
- [ ] Pin designators match datasheet exactly
- [ ] Pin names are descriptive with alternate functions
- [ ] Pins logically grouped by function
- [ ] Power pins have `eElectricPower` type
- [ ] Input-only pins have `eElectricInput` type
- [ ] Bidirectional pins have `eElectricIO` type
- [ ] Rectangle extends 200 mil beyond pins
- [ ] Rectangle has filled color with transparency
- [ ] All user parameters populated
- [ ] DesignItemId matches PART parameter
- [ ] LibReference set correctly
- [ ] Script project file (.PrjScr) created

## Common Issues

| Issue | Solution |
|-------|----------|
| Pins not visible | Add `OwnerPartId := 1` to each pin |
| Parameters not showing | Add `OwnerPartId := -1` to parameters |
| Undeclared identifier | Use correct API names (see tables above) |
| Pins pointing wrong way | Swap `eRotate0` and `eRotate180` |
| Rectangle not filled | Set `IsSolid := True` |

## Reference Examples

| Component | Type | Pins | File |
|-----------|------|------|------|
| BC15C | BLE Module (nRF54L15) | 36 | `Intellispin_Sensor/BC15C_CreateSymbol.pas` |
| LR62E | LoRa Module (SX1262) | 10 | `Intellispin_Sensor/LR62E_CreateSymbol.pas` |

- Datasheet location: `docs/` folder
- Symbol definitions: `*_Symbol_Definition.txt` files

## How to Run Scripts in Altium

1. Open Altium Designer
2. Create new Schematic Library: **File > New > Library > Schematic Library**
3. Open the script project: **File > Open > select `ComponentName_Symbol.PrjScr`**
4. Run the script: **DXP > Run Script > select the procedure (e.g., `CreateLR62ESymbol`)**
5. Save the library: **File > Save As > `ComponentName.SchLib`**
