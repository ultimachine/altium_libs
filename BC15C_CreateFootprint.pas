{..............................................................................}
{ BC15C PCB Footprint Generator for Altium Designer                            }
{ Fanstel BC15C - 6.0 x 12.4 mm, 36-pin LGA, 0.9mm pitch                       }
{ All dimensions in MM (exact from datasheet)                                  }
{..............................................................................}

Procedure CreateBC15CFootprint;
Const
    // Offset to compensate for AD21 library origin (50000 mils = 1270 mm)
    Offset = 1270.0;

    // Module dimensions (mm) - exact from datasheet
    ModuleWidth = 6.0;
    ModuleHeight = 12.4;
    PadPitch = 0.9;
    PadDiameter = 0.5;
    EdgeToPad = 0.75;
    PadAreaHeight = 6.0;

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
    PadAreaTop  : Double;
Begin
    Board := PCBServer.GetCurrentPCBBoard;
    If Board = Nil Then
    Begin
        ShowMessage('Please open a PCB Library first.');
        Exit;
    End;

    HalfW := ModuleWidth / 2.0;    // 3.0 mm
    HalfH := ModuleHeight / 2.0;   // 6.2 mm
    PadAreaTop := -HalfH + PadAreaHeight;  // -0.2 mm

    PCBServer.PreProcess;

    // ========================================================================
    // Create 36 SMD Pads (A1-F6)
    // Exact 0.9mm pitch, 0.5mm diameter
    // ========================================================================
    For Row := 1 To 6 Do
    Begin
        For Col := 1 To 6 Do
        Begin
            // X: Col 1 at -2.25mm, Col 6 at +2.25mm
            PadX := Offset + (-HalfW + EdgeToPad + (Col - 1) * PadPitch);

            // Y: Row A at -0.95mm, Row F at -5.45mm
            PadY := Offset + (PadAreaTop - EdgeToPad - (Row - 1) * PadPitch);

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

    // ========================================================================
    // Silkscreen (Top Overlay)
    // ========================================================================
    // Top line
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

    // Left side (antenna area only)
    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset - HalfW);
        Track.Y1 := MMsToCoord(Offset + HalfH);
        Track.X2 := MMsToCoord(Offset - HalfW);
        Track.Y2 := MMsToCoord(Offset + PadAreaTop + 0.3);
        Track.Width := MMsToCoord(SilkWidth);
        Track.Layer := eTopOverlay;
        Board.AddPCBObject(Track);
    End;

    // Right side (antenna area only)
    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset + HalfW);
        Track.Y1 := MMsToCoord(Offset + HalfH);
        Track.X2 := MMsToCoord(Offset + HalfW);
        Track.Y2 := MMsToCoord(Offset + PadAreaTop + 0.3);
        Track.Width := MMsToCoord(SilkWidth);
        Track.Layer := eTopOverlay;
        Board.AddPCBObject(Track);
    End;

    // Bottom left corner
    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset - HalfW);
        Track.Y1 := MMsToCoord(Offset - HalfH);
        Track.X2 := MMsToCoord(Offset - HalfW);
        Track.Y2 := MMsToCoord(Offset - HalfH + 0.5);
        Track.Width := MMsToCoord(SilkWidth);
        Track.Layer := eTopOverlay;
        Board.AddPCBObject(Track);
    End;

    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset - HalfW);
        Track.Y1 := MMsToCoord(Offset - HalfH);
        Track.X2 := MMsToCoord(Offset - HalfW + 0.5);
        Track.Y2 := MMsToCoord(Offset - HalfH);
        Track.Width := MMsToCoord(SilkWidth);
        Track.Layer := eTopOverlay;
        Board.AddPCBObject(Track);
    End;

    // Bottom right corner
    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset + HalfW);
        Track.Y1 := MMsToCoord(Offset - HalfH);
        Track.X2 := MMsToCoord(Offset + HalfW);
        Track.Y2 := MMsToCoord(Offset - HalfH + 0.5);
        Track.Width := MMsToCoord(SilkWidth);
        Track.Layer := eTopOverlay;
        Board.AddPCBObject(Track);
    End;

    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset + HalfW);
        Track.Y1 := MMsToCoord(Offset - HalfH);
        Track.X2 := MMsToCoord(Offset + HalfW - 0.5);
        Track.Y2 := MMsToCoord(Offset - HalfH);
        Track.Width := MMsToCoord(SilkWidth);
        Track.Layer := eTopOverlay;
        Board.AddPCBObject(Track);
    End;

    // Pin 1 indicator dot
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

    // Ground plane setback line (4.4mm from top for antenna clearance)
    // Top of module = +6.2mm, setback line at 6.2 - 4.4 = 1.8mm
    Track := PcbServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
    If Track <> Nil Then
    Begin
        Track.X1 := MMsToCoord(Offset - HalfW);
        Track.Y1 := MMsToCoord(Offset + HalfH - 4.4);
        Track.X2 := MMsToCoord(Offset + HalfW);
        Track.Y2 := MMsToCoord(Offset + HalfH - 4.4);
        Track.Width := MMsToCoord(SilkWidth);
        Track.Layer := eTopOverlay;
        Board.AddPCBObject(Track);
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

    // Pin 1 chamfer
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

    ShowMessage('BC15C footprint created!' + #13#10 +
                '36 pads, 0.9mm pitch (exact)' + #13#10 +
                '6.0 x 12.4 mm' + #13#10 +
                #13#10 +
                '1. View > Fit (V, D)' + #13#10 +
                '2. Ctrl+A to select all' + #13#10 +
                '3. Edit > Set Reference > Center');
End;

End.
