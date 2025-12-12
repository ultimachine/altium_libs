{..............................................................................}
{ LR62E Schematic Symbol Generator for Altium Designer                         }
{ Fanstel LR62E - LoRa Module with Semtech SX1262 Transceiver                  }
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

Procedure CreateLR62ESymbol;
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

    SchComponent.LibReference := 'LR62E';
    SchComponent.ComponentDescription := 'Fanstel LR62E LoRa Module (SX1262)';
    SchComponent.Designator.Text := 'U?';
    SchComponent.Comment.Text := 'LR62E';
    SchComponent.DesignItemId := 'LR62E';

    // Add User Parameters
    AddParameter(SchComponent, 'MANUFACTURER', 'Fanstel');
    AddParameter(SchComponent, 'MANUFACTURER #', 'LR62E');
    AddParameter(SchComponent, 'PART', 'LR62E');
    AddParameter(SchComponent, 'PART DESCRIPTION', 'LoRa Module with Semtech SX1262, u.FL Antenna, 10.2x15mm');
    AddParameter(SchComponent, 'VALUE', 'LR62E');
    AddParameter(SchComponent, 'TOLERANCE', '');
    AddParameter(SchComponent, 'EE_SPEC', 'VDD=1.8-3.7V, 902-928MHz, +20dBm TX, SPI Interface, LoRa/FSK');

    // Create rectangle body
    // Left: 5 pins + 2 group gaps = 700 mil + 100 mil bottom margin = 800 mil
    // Right: 5 pins + 1 group gap = 600 mil + 100 mil bottom margin = 700 mil
    // Use larger value: 800 mil
    SchRect := SchServer.SchObjectFactory(eRectangle, eCreate_Default);
    SchRect.Location := Point(MilsToCoord(-200), MilsToCoord(0));
    SchRect.Corner := Point(MilsToCoord(800), MilsToCoord(-800));
    SchRect.LineWidth := 0;
    SchRect.Color := $000080;  // #800000 dark red (BGR format)
    SchRect.AreaColor := $B0FFFF;  // #FFFFB0 light yellow (BGR format)
    SchRect.IsSolid := True;
    SchRect.Transparent := True;
    SchRect.OwnerPartId := 1;
    SchComponent.AddSchObject(SchRect);

    // ============ LEFT SIDE PINS ============
    // Power, Reset, Control
    LeftY := -100;

    // --- POWER ---
    // Pin 5 - VDD
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := '5';
    SchPin.Name := 'VDD';
    SchPin.Electrical := eElectricPower;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 200;  // Extra space after VDD

    // Pin 10 - GND
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := '10';
    SchPin.Name := 'GND';
    SchPin.Electrical := eElectricPower;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 200;  // Group spacing

    // --- CONTROL ---
    // Pin 2 - SX-NRESET (active low)
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := '2';
    SchPin.Name := '~SX-NRESET';
    SchPin.Electrical := eElectricInput;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 100;

    // Pin 3 - BUSY
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := '3';
    SchPin.Name := 'BUSY';
    SchPin.Electrical := eElectricOutput;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 100;

    // Pin 4 - DIO1
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := '4';
    SchPin.Name := 'DIO1';
    SchPin.Electrical := eElectricIO;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);

    // ============ RIGHT SIDE PINS ============
    // SPI Interface, Antenna
    RightY := -100;

    // --- SPI INTERFACE ---
    // Pin 6 - SCK
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := '6';
    SchPin.Name := 'SCK';
    SchPin.Electrical := eElectricInput;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // Pin 7 - MOSI
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := '7';
    SchPin.Name := 'MOSI';
    SchPin.Electrical := eElectricInput;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // Pin 8 - MISO
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := '8';
    SchPin.Name := 'MISO';
    SchPin.Electrical := eElectricOutput;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // Pin 9 - NSS
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := '9';
    SchPin.Name := '~NSS';
    SchPin.Electrical := eElectricInput;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 200;  // Group spacing

    // --- ANTENNA ---
    // Pin 1 - ANT-SW
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := '1';
    SchPin.Name := 'ANT-SW';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);

    // Add component to library
    SchLib.AddSchComponent(SchComponent);
    SchLib.CurrentSchComponent := SchComponent;

    // Refresh
    SchLib.GraphicallyInvalidate;

    ShowMessage('LR62E symbol created successfully!');
End;

End.
