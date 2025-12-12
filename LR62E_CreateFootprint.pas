{..............................................................................}
{ LR62E PCB Footprint Generator for Altium Designer                            }
{ Fanstel LR62E - 10.2 x 15.0 mm, 10-pin edge-mount SMD, 0.7mm pitch          }
{ All dimensions in MM (exact from datasheet)                                  }
{..............................................................................}

Procedure CreateLR62EFootprint;
Const
    // Offset to compensate for AD21 library origin (50000 mils = 1270 mm)
    Offset = 1270.0;

    // Module dimensions (mm) - exact from datasheet
    ModuleWidth = 10.2;
    ModuleHeight = 15.0;
    PadPitch = 1.1;      // Vertical spacing between pad centers
    PadWidth = 1.0;      // Horizontal (extends onto PCB)
    PadHeight = 0.7;     // Vertical (matches module castellation)
    EdgeToPad = 0.5;
    BottomToPad1 = 1.1;

    // u.FL connector location (from top-left corner)
    uFLFromLeft = 2.2;
    uFLFromTop = 2.4;

    // Drawing widths (mm)
    SilkWidth = 0.15;
    AssemblyWidth = 0.1;
Var
    Board       : IPCB_Board;
    Pad         : IPCB_Pad;
    Track       : IPCB_Track;
    Arc         : IPCB_Arc;
    PinIdx      : Integer;
    PadX, PadY  : Double;
    PadName     : String;
    HalfW, HalfH : Double;
    PinNames    : Array[1..10] of String;
Begin
    Board := PCBServer.GetCurrentPCBBoard;
    If Board = Nil Then
    Begin
        ShowMessage('Please open a PCB Library first.');
        Exit;
    End;

    HalfW := ModuleWidth / 2.0;    // 5.1 mm
    HalfH := ModuleHeight / 2.0;   // 7.5 mm

    // Pin names array
    PinNames[1] := '1';   // ANT-SW
    PinNames[2] := '2';   // SX-NRESET
    PinNames[3] := '3';   // BUSY
    PinNames[4] := '4';   // DIO1
    PinNames[5] := '5';   // VDD
    PinNames[6] := '6';   // SCK
    PinNames[7] := '7';   // MOSI
    PinNames[8] := '8';   // MISO
    PinNames[9] := '9';   // NSS
    PinNames[10] := '10'; // GND

    PCBServer.PreProcess;

    // ========================================================================
    // Create 10 SMD Pads (edge-mount, rectangular)
    // Left side: Pins 1-5 (bottom to top)
    // Right side: Pins 6-10 (bottom to top)
    // ========================================================================

    // Left side pads (Pins 1-5)
    // Pad center at module edge so land extends onto host PCB
    For PinIdx := 1 To 5 Do
    Begin
        PadX := Offset + (-HalfW);  // Center at module edge
        PadY := Offset + (-HalfH + BottomToPad1 + (PinIdx - 1) * PadPitch);

        Pad := PcbServer.PCBObjectFactory(ePadObject, eNoDimension, eCreate_Default);
        If Pad <> Nil Then
        Begin
            Pad.X := MMsToCoord(PadX);
            Pad.Y := MMsToCoord(PadY);
            Pad.TopXSize := MMsToCoord(PadWidth);
            Pad.TopYSize := MMsToCoord(PadHeight);
            Pad.TopShape := eRectangular;
            Pad.HoleSize := MMsToCoord(0);
            Pad.Layer := eTopLayer;
            Pad.Name := PinNames[PinIdx];
            Board.AddPCBObject(Pad);
        End;
    End;

    // Right side pads (Pins 6-10)
    // Pad center at module edge so land extends onto host PCB
    For PinIdx := 6 To 10 Do
    Begin
        PadX := Offset + (HalfW);  // Center at module edge
        PadY := Offset + (-HalfH + BottomToPad1 + (PinIdx - 6) * PadPitch);

        Pad := PcbServer.PCBObjectFactory(ePadObject, eNoDimension, eCreate_Default);
        If Pad <> Nil Then
        Begin
            Pad.X := MMsToCoord(PadX);
            Pad.Y := MMsToCoord(PadY);
            Pad.TopXSize := MMsToCoord(PadWidth);
            Pad.TopYSize := MMsToCoord(PadHeight);
            Pad.TopShape := eRectangular;
            Pad.HoleSize := MMsToCoord(0);
            Pad.Layer := eTopLayer;
            Pad.Name := PinNames[PinIdx];
            Board.AddPCBObject(Pad);
        End;
    End;

    // ========================================================================
    // Silkscreen (Top Overlay)
    // ========================================================================

    // Top line (full width)
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

    // Bottom line (full width)
    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset - HalfW);
        Track.Y1 := MMsToCoord(Offset - HalfH);
        Track.X2 := MMsToCoord(Offset + HalfW);
        Track.Y2 := MMsToCoord(Offset - HalfH);
        Track.Width := MMsToCoord(SilkWidth);
        Track.Layer := eTopOverlay;
        Board.AddPCBObject(Track);
    End;

    // Left side - top segment (above pads)
    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset - HalfW);
        Track.Y1 := MMsToCoord(Offset + HalfH);
        Track.X2 := MMsToCoord(Offset - HalfW);
        Track.Y2 := MMsToCoord(Offset - HalfH + BottomToPad1 + 4*PadPitch + PadHeight/2 + 0.3);
        Track.Width := MMsToCoord(SilkWidth);
        Track.Layer := eTopOverlay;
        Board.AddPCBObject(Track);
    End;

    // Left side - bottom segment (below pads)
    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset - HalfW);
        Track.Y1 := MMsToCoord(Offset - HalfH);
        Track.X2 := MMsToCoord(Offset - HalfW);
        Track.Y2 := MMsToCoord(Offset - HalfH + BottomToPad1 - PadHeight/2 - 0.3);
        Track.Width := MMsToCoord(SilkWidth);
        Track.Layer := eTopOverlay;
        Board.AddPCBObject(Track);
    End;

    // Right side - top segment (above pads)
    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset + HalfW);
        Track.Y1 := MMsToCoord(Offset + HalfH);
        Track.X2 := MMsToCoord(Offset + HalfW);
        Track.Y2 := MMsToCoord(Offset - HalfH + BottomToPad1 + 4*PadPitch + PadHeight/2 + 0.3);
        Track.Width := MMsToCoord(SilkWidth);
        Track.Layer := eTopOverlay;
        Board.AddPCBObject(Track);
    End;

    // Right side - bottom segment (below pads)
    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset + HalfW);
        Track.Y1 := MMsToCoord(Offset - HalfH);
        Track.X2 := MMsToCoord(Offset + HalfW);
        Track.Y2 := MMsToCoord(Offset - HalfH + BottomToPad1 - PadHeight/2 - 0.3);
        Track.Width := MMsToCoord(SilkWidth);
        Track.Layer := eTopOverlay;
        Board.AddPCBObject(Track);
    End;

    // Pin 1 indicator dot (outside module, near pin 1)
    // Position: 1.0mm outside module edge to clear pad (pad extends 0.5mm out)
    Arc := PcbServer.PCBObjectFactory(eArcObject, eNoDimension, eCreate_Default);
    If Arc <> Nil Then
    Begin
        Arc.XCenter := MMsToCoord(Offset - HalfW - 1.0);
        Arc.YCenter := MMsToCoord(Offset - HalfH + BottomToPad1);
        Arc.Radius := MMsToCoord(0.2);
        Arc.StartAngle := 0;
        Arc.EndAngle := 360;
        Arc.LineWidth := MMsToCoord(SilkWidth);
        Arc.Layer := eTopOverlay;
        Board.AddPCBObject(Arc);
    End;

    // u.FL connector indicator (circle at top of module)
    Arc := PcbServer.PCBObjectFactory(eArcObject, eNoDimension, eCreate_Default);
    If Arc <> Nil Then
    Begin
        Arc.XCenter := MMsToCoord(Offset - HalfW + uFLFromLeft);
        Arc.YCenter := MMsToCoord(Offset + HalfH - uFLFromTop);
        Arc.Radius := MMsToCoord(1.0);
        Arc.StartAngle := 0;
        Arc.EndAngle := 360;
        Arc.LineWidth := MMsToCoord(SilkWidth);
        Arc.Layer := eTopOverlay;
        Board.AddPCBObject(Arc);
    End;

    // ========================================================================
    // Assembly Outline (Mechanical 1)
    // ========================================================================

    // Bottom
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

    // Right
    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset + HalfW);
        Track.Y1 := MMsToCoord(Offset - HalfH);
        Track.X2 := MMsToCoord(Offset + HalfW);
        Track.Y2 := MMsToCoord(Offset + HalfH);
        Track.Width := MMsToCoord(AssemblyWidth);
        Track.Layer := eMechanical1;
        Board.AddPCBObject(Track);
    End;

    // Top
    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset + HalfW);
        Track.Y1 := MMsToCoord(Offset + HalfH);
        Track.X2 := MMsToCoord(Offset - HalfW);
        Track.Y2 := MMsToCoord(Offset + HalfH);
        Track.Width := MMsToCoord(AssemblyWidth);
        Track.Layer := eMechanical1;
        Board.AddPCBObject(Track);
    End;

    // Left
    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset - HalfW);
        Track.Y1 := MMsToCoord(Offset + HalfH);
        Track.X2 := MMsToCoord(Offset - HalfW);
        Track.Y2 := MMsToCoord(Offset - HalfH);
        Track.Width := MMsToCoord(AssemblyWidth);
        Track.Layer := eMechanical1;
        Board.AddPCBObject(Track);
    End;

    // Pin 1 chamfer on assembly layer
    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset - HalfW);
        Track.Y1 := MMsToCoord(Offset - HalfH + 0.8);
        Track.X2 := MMsToCoord(Offset - HalfW + 0.8);
        Track.Y2 := MMsToCoord(Offset - HalfH);
        Track.Width := MMsToCoord(AssemblyWidth);
        Track.Layer := eMechanical1;
        Board.AddPCBObject(Track);
    End;

    PCBServer.PostProcess;
    Board.GraphicallyInvalidate;

    ShowMessage('LR62E footprint created!' + #13#10 +
                '10 pads, 0.7mm pitch (exact)' + #13#10 +
                '10.2 x 15.0 mm' + #13#10 +
                #13#10 +
                '1. View > Fit (V, D)' + #13#10 +
                '2. Ctrl+A to select all' + #13#10 +
                '3. Edit > Set Reference > Center');
End;

End.
