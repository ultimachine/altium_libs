{..............................................................................}
{ BC15C Schematic Symbol Generator for Altium Designer                         }
{ Fanstel BC15C - Compact Bluetooth 6.0, 802.15.4 Module (nRF54L15)            }
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

Procedure CreateBC15CSymbol;
Var
    SchLib      : ISch_Lib;
    SchComponent : ISch_Component;
    SchPin      : ISch_Pin;
    SchRect     : ISch_Rectangle;
    SchLabel    : ISch_Label;
    PinNum      : Integer;
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

    SchComponent.LibReference := 'BC15C';
    SchComponent.ComponentDescription := 'Fanstel BC15C BLE Module (nRF54L15)';
    SchComponent.Designator.Text := 'U?';
    SchComponent.Comment.Text := 'BC15C';
    SchComponent.DesignItemId := 'BC15C';

    // Add User Parameters
    AddParameter(SchComponent, 'MANUFACTURER', 'Fanstel');
    AddParameter(SchComponent, 'MANUFACTURER #', 'BC15C');
    AddParameter(SchComponent, 'PART', 'BC15C');
    AddParameter(SchComponent, 'PART DESCRIPTION', 'Compact Bluetooth 6.0, 802.15.4 Module with nRF54L15 SoC, Chip Antenna, 6x12.4mm');
    AddParameter(SchComponent, 'VALUE', 'BC15C');
    AddParameter(SchComponent, 'TOLERANCE', '');
    AddParameter(SchComponent, 'EE_SPEC', 'VDD=1.8-3.6V, 31 GPIO, BLE 5.4, 802.15.4, ARM Cortex-M33 128MHz, 1524KB Flash, 256KB RAM');

    // Create rectangle body
    // Left: 11 pins + 4 group gaps (100 mil each) = 1500 mil + 100 mil bottom margin = 1600 mil
    // Right: 14 P1 + 1 gap + 11 P2 = 2600 mil + 100 mil bottom margin = 2700 mil
    SchRect := SchServer.SchObjectFactory(eRectangle, eCreate_Default);
    SchRect.Location := Point(MilsToCoord(-200), MilsToCoord(0));
    SchRect.Corner := Point(MilsToCoord(800), MilsToCoord(-2800));
    SchRect.LineWidth := 0;
    SchRect.Color := $000080;  // #800000 dark red (BGR format)
    SchRect.AreaColor := $B0FFFF;  // #FFFFB0 light yellow (BGR format)
    SchRect.IsSolid := True;
    SchRect.Transparent := True;
    SchRect.OwnerPartId := 1;
    SchComponent.AddSchObject(SchRect);

    // ============ LEFT SIDE PINS ============
    // Power, Reset, Debug, NFC, Analog
    LeftY := -100;

    // --- POWER ---
    // F6 - VDD
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := 'F6';
    SchPin.Name := 'VDD';
    SchPin.Electrical := eElectricPower;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 200;  // Extra space after VDD

    // E1 - GND
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := 'E1';
    SchPin.Name := 'GND';
    SchPin.Electrical := eElectricPower;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 100;

    // F1 - GND
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := 'F1';
    SchPin.Name := 'GND';
    SchPin.Electrical := eElectricPower;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 200;  // Group spacing

    // --- RESET ---
    // F3 - RESET
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := 'F3';
    SchPin.Name := '~RESET';
    SchPin.Electrical := eElectricInput;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 200;  // Group spacing

    // --- DEBUG (SWD) ---
    // A4 - SWDCLK
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := 'A4';
    SchPin.Name := 'SWDCLK';
    SchPin.Electrical := eElectricInput;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 100;

    // A3 - SWDIO
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := 'A3';
    SchPin.Name := 'SWDIO';
    SchPin.Electrical := eElectricIO;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 200;  // Group spacing

    // --- PORT 0 (P0.00-P0.04) ---
    // A2 - P0.00
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := 'A2';
    SchPin.Name := 'P0.00';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 100;

    // A1 - P0.01
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := 'A1';
    SchPin.Name := 'P0.01';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 100;

    // C2 - P0.02
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := 'C2';
    SchPin.Name := 'P0.02';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 100;

    // B2 - P0.03
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := 'B2';
    SchPin.Name := 'P0.03';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    LeftY := LeftY - 100;

    // E3 - P0.04
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(-200), MilsToCoord(LeftY));
    SchPin.Orientation := eRotate180;
    SchPin.Designator := 'E3';
    SchPin.Name := 'P0.04';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);

    // ============ RIGHT SIDE PINS ============
    // Port 1 (all), Port 2
    RightY := -100;

    // --- PORT 1 (P1.02-P1.15, all pins in order) - Top Right ---
    // E6 - P1.02/NFC1
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'E6';
    SchPin.Name := 'P1.02/NFC1';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // F4 - P1.03/NFC2
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'F4';
    SchPin.Name := 'P1.03/NFC2';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // C5 - P1.04/AIN0
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'C5';
    SchPin.Name := 'P1.04/AIN0';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // B5 - P1.05/AIN1
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'B5';
    SchPin.Name := 'P1.05/AIN1';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // B6 - P1.06/AIN2
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'B6';
    SchPin.Name := 'P1.06/AIN2';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // B4 - P1.07/AIN3
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'B4';
    SchPin.Name := 'P1.07/AIN3';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // B1 - P1.08
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'B1';
    SchPin.Name := 'P1.08';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // C3 - P1.09
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'C3';
    SchPin.Name := 'P1.09';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // D2 - P1.10
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'D2';
    SchPin.Name := 'P1.10';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // D5 - P1.11/AIN4
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'D5';
    SchPin.Name := 'P1.11/AIN4';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // D1 - P1.12/AIN5
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'D1';
    SchPin.Name := 'P1.12/AIN5';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // E2 - P1.13/AIN6
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'E2';
    SchPin.Name := 'P1.13/AIN6';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // D4 - P1.14/AIN7
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'D4';
    SchPin.Name := 'P1.14/AIN7';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // E5 - P1.15
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'E5';
    SchPin.Name := 'P1.15';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 200;  // Group spacing

    // --- PORT 2 (P2.00-P2.10) ---
    // C4 - P2.00
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'C4';
    SchPin.Name := 'P2.00';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // C6 - P2.01
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'C6';
    SchPin.Name := 'P2.01';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // D6 - P2.02
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'D6';
    SchPin.Name := 'P2.02';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // E4 - P2.03
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'E4';
    SchPin.Name := 'P2.03';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // F5 - P2.04
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'F5';
    SchPin.Name := 'P2.04';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // A6 - P2.05
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'A6';
    SchPin.Name := 'P2.05';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // F2 - P2.06
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'F2';
    SchPin.Name := 'P2.06';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // B3 - P2.07
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'B3';
    SchPin.Name := 'P2.07';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // D3 - P2.08
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'D3';
    SchPin.Name := 'P2.08';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // A5 - P2.09
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'A5';
    SchPin.Name := 'P2.09';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);
    RightY := RightY - 100;

    // C1 - P2.10
    SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
    SchPin.Location := Point(MilsToCoord(800), MilsToCoord(RightY));
    SchPin.Orientation := eRotate0;
    SchPin.Designator := 'C1';
    SchPin.Name := 'P2.10';
    SchPin.Electrical := eElectricPassive;
    SchPin.PinLength := MilsToCoord(200);
    SchPin.OwnerPartId := 1;
    SchComponent.AddSchObject(SchPin);

    // Add component to library
    SchLib.AddSchComponent(SchComponent);
    SchLib.CurrentSchComponent := SchComponent;

    // Refresh
    SchLib.GraphicallyInvalidate;

    ShowMessage('BC15C symbol created successfully!');
End;

End.
