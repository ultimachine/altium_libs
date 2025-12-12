{..............................................................................}
{ MCP47FVB01 Schematic Symbol Generator for Altium Designer                    }
{ Microchip - Single-channel 8-bit Voltage Output DAC with I2C Interface       }
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

Procedure CreateMCP47FVB01Symbol;
Var
    SchLib      : ISch_Lib;
    SchComponent : ISch_Component;
    SchPin      : ISch_Pin;
    SchRect     : ISch_Rectangle;
    LeftY, RightY : Integer;

Begin
    // Check if SchLib document is focused
    If SchServer = Nil Then Exit;

    SchLib := SchServer.GetCurrentSchDocument;
    If SchLib = Nil Then
    Begin
        ShowMessage('Please open or create a Schematic Library first.');
        Exit;
    End;

    // Create new component
    SchComponent := SchServer.SchObjectFactory(eSchComponent, eCreate_Default);
    If SchComponent = Nil Then Exit;

    SchComponent.LibReference := 'MCP47FVB01A0-E/ST';
    SchComponent.ComponentDescription := 'Single-channel 8-bit DAC, I2C, 8-TSSOP';
    SchComponent.Designator.Text := 'U?';
    SchComponent.Comment.Text := 'MCP47FVB01';
    SchComponent.DesignItemId := 'MCP47FVB01A0-E/ST';

    // Add User Parameters
    AddParameter(SchComponent, 'MANUFACTURER', 'Microchip');
    AddParameter(SchComponent, 'MANUFACTURER #', 'MCP47FVB01A0-E/ST');
    AddParameter(SchComponent, 'PART', 'MCP47FVB01A0-E/ST');
    AddParameter(SchComponent, 'PART DESCRIPTION', 'Single-channel 8-bit Voltage Output DAC with I2C Interface, 8-TSSOP');
    AddParameter(SchComponent, 'VALUE', 'MCP47FVB01');
    AddParameter(SchComponent, 'TOLERANCE', '');
    AddParameter(SchComponent, 'EE_SPEC', 'VDD=2.7-5.5V, 8-bit, I2C, Unbuffered VREF');

    // Create rectangle body
    // Left: 4 pins + 2 gaps = 600 mil + 100 mil bottom margin = 700 mil
    // Right: 5 pins + 1 gap = 600 mil + 100 mil bottom margin = 700 mil
    // Use: 700 mil
    SchRect := SchServer.SchObjectFactory(eRectangle, eCreate_Default);
    SchRect.Location := Point(MilsToCoord(-200), MilsToCoord(0));
    SchRect.Corner := Point(MilsToCoord(800), MilsToCoord(-700));
    SchRect.LineWidth := 0;
    SchRect.Color := $000080;  // #800000 dark red (BGR format)
    SchRect.AreaColor := $B0FFFF;  // #FFFFB0 light yellow (BGR format)
    SchRect.IsSolid := True;
    SchRect.Transparent := True;
    SchRect.OwnerPartId := 1;
    SchComponent.AddSchObject(SchRect);

    // ============ LEFT SIDE PINS ============
    // Power, Ground, Reference, Config
    LeftY := -100;

    // --- POWER ---
    // Pin 1 - VDD
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := '1';
    SchPin.Name := 'VDD';
    SchPin.Electrical := eElectricPower;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 200;  // Extra space after VDD

    // Pin 5 - VSS
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := '5';
    SchPin.Name := 'VSS';
    SchPin.Electrical := eElectricPower;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 200;  // Group spacing

    // --- REFERENCE & CONFIG ---
    // Pin 2 - VREF
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := '2';
    SchPin.Name := 'VREF';
    SchPin.Electrical := eElectricInput;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 100;

    // Pin 6 - ALT/HVC
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := '6';
    SchPin.Name := 'ALT/HVC';
    SchPin.Electrical := eElectricInput;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);

    // ============ RIGHT SIDE PINS ============
    // I2C Interface, Output
    RightY := -100;

    // --- I2C INTERFACE ---
    // Pin 7 - SCL
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := '7';
    SchPin.Name := 'SCL';
    SchPin.Electrical := eElectricInput;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // Pin 8 - SDA
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := '8';
    SchPin.Name := 'SDA';
    SchPin.Electrical := eElectricIO;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 200;  // Group spacing

    // --- OUTPUT ---
    // Pin 3 - VOUT
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := '3';
    SchPin.Name := 'VOUT';
    SchPin.Electrical := eElectricOutput;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // Pin 4 - NC
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := '4';
    SchPin.Name := 'NC';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);

    // Add component to library
    SchLib.AddSchComponent(SchComponent);
    SchLib.CurrentSchComponent := SchComponent;

    // Refresh
    SchLib.GraphicallyInvalidate;

    ShowMessage('MCP47FVB01 symbol created successfully!');
End;

End.
