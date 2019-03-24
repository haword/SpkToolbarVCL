﻿unit spkt_Tools;

{$Define EnhancedRecordSupport}

(*******************************************************************************
*                                                                              *
*  Plik: spkt_Tools.pas                                                        *
*  Opis: Klasy narzêdziowe u³atwiaj¹ce renderowanie toolbara.                  *
*  Copyright: (c) 2009 by Spook. Jakiekolwiek u¿ycie komponentu bez            *
*             uprzedniego uzyskania licencji od autora stanowi z³amanie        *
*             prawa autorskiego!                                               *
*                                                                              *
*******************************************************************************)

interface

uses
  Graphics, SysUtils, SpkMath, SpkGUITools;

type TButtonTools = class (TObject)
     private
     protected
     public
       class procedure DrawButton(Bitmap : TBitmap;
                                  Rect : T2DIntRect;
                                  FrameColor,
                                  InnerLightColor,
                                  InnerDarkColor,
                                  GradientFrom,
                                  GradientTo : TColor;
                                  GradientKind : TBackgroundKind;
                                  LeftEdgeOpen,
                                  RightEdgeOpen,
                                  TopEdgeOpen,
                                  BottomEdgeOpen : boolean;
                                  Radius : integer;
                                  ClipRect : T2DIntRect);
     end;

implementation

{ TButtonTools }

class procedure TButtonTools.DrawButton(Bitmap: TBitmap;
  Rect: T2DIntRect; FrameColor, InnerLightColor, InnerDarkColor, GradientFrom,
  GradientTo: TColor; GradientKind: TBackgroundKind; LeftEdgeOpen,
  RightEdgeOpen, TopEdgeOpen, BottomEdgeOpen: boolean; Radius: integer;
  ClipRect : T2DIntRect);

var x1, x2, y1, y2 : integer;
    LeftClosed, TopClosed, RightClosed, BottomClosed : byte;

begin
if (Rect.Width<6) or (Rect.Height<6) or
   (Rect.Width < 2*radius) or (Rect.Height < 2*Radius) then
   exit;

if LeftEdgeOpen then LeftClosed:=0 else LeftClosed:=1;
if RightEdgeOpen then RightClosed:=0 else RightClosed:=1;
if TopEdgeOpen then TopClosed:=0 else TopClosed:=1;
if BottomEdgeOpen then BottomClosed:=0 else BottomClosed:=1;

TGuiTools.DrawRoundRect(Bitmap.Canvas,
                        Rect,
                        Radius,
                        GradientFrom,
                        GradientTo,
                        GradientKind,
                        ClipRect,
                        not(LeftEdgeOpen or TopEdgeOpen),
                        not(RightEdgeOpen or TopEdgeOpen),
                        not(LeftEdgeOpen or BottomEdgeOpen),
                        not(RightEdgeOpen or BottomEdgeOpen));

// Wewnêtrzna krawêdŸ
// *** Góra ***
x1:=Rect.Left + radius * TopClosed * LeftClosed + LeftClosed;
x2:=Rect.Right - radius * TopClosed * RightClosed - RightClosed;
y1:=Rect.Top + TopClosed;
TGuiTools.DrawHLine(Bitmap, x1, x2, y1, InnerLightColor, ClipRect);

// *** Dó³ ***
x1:=Rect.Left + radius * BottomClosed * LeftClosed + LeftClosed;
x2:=Rect.Right - radius * BottomClosed * RightClosed - RightClosed;
y1:=Rect.Bottom - BottomClosed;
if BottomEdgeOpen then
   TGuiTools.DrawHLine(Bitmap, x1, x2, y1, InnerDarkColor, ClipRect) else
   TGuiTools.DrawHLine(Bitmap, x1, x2, y1, InnerLightColor, ClipRect);

// *** Lewo ***
y1:=Rect.Top + Radius * LeftClosed * TopClosed + TopClosed;
y2:=Rect.Bottom - Radius * LeftClosed * BottomClosed - BottomClosed;
x1:=Rect.Left + LeftClosed;
TGuiTools.DrawVLine(Bitmap, x1, y1, y2, InnerLightColor, ClipRect);

// *** Prawo ***
y1:=Rect.Top + Radius * RightClosed * TopClosed + TopClosed;
y2:=Rect.Bottom - Radius * RightClosed * BottomClosed - BottomClosed;
x1:=Rect.Right - RightClosed;
if RightEdgeOpen then
   TGuiTools.DrawVLine(Bitmap, x1, y1, y2, InnerDarkColor, ClipRect) else
   TGuiTools.DrawVLine(Bitmap, x1, y1, y2, InnerLightColor, ClipRect);

// Zaokr¹glone naro¿niki
if not(LeftEdgeOpen or TopEdgeOpen) then
   TGuiTools.DrawAARoundCorner(Bitmap,
                               {$IFDEF EnhancedRecordSupport}
                               T2DIntPoint.create(Rect.left + 1, Rect.Top + 1),
                               {$ELSE}
                               Create2DIntPoint(Rect.left + 1, Rect.Top + 1),
                               {$ENDIF}
                               Radius,
                               cpLeftTop,
                               InnerLightColor,
                               ClipRect);
if not(RightEdgeOpen or TopEdgeOpen) then
   TGuiTools.DrawAARoundCorner(Bitmap,
                               {$IFDEF EnhancedRecordSupport}
                               T2DIntPoint.create(Rect.right - radius, Rect.Top + 1),
                               {$ELSE}
                               Create2DIntPoint(Rect.right - radius, Rect.Top + 1),
                               {$ENDIF}
                               Radius,
                               cpRightTop,
                               InnerLightColor,
                               ClipRect);
if not(LeftEdgeOpen or BottomEdgeOpen) then
   TGuiTools.DrawAARoundCorner(Bitmap,
                               {$IFDEF EnhancedRecordSupport}
                               T2DIntPoint.create(Rect.left + 1, Rect.bottom - radius),
                               {$ELSE}
                               Create2DIntPoint(Rect.left + 1, Rect.bottom - radius),
                               {$ENDIF}
                               Radius,
                               cpLeftBottom,
                               InnerLightColor,
                               ClipRect);
if not(RightEdgeOpen or BottomEdgeOpen) then
   TGuiTools.DrawAARoundCorner(Bitmap,
                               {$IFDEF EnhancedRecordSupport}
                               T2DIntPoint.create(Rect.right - radius, Rect.bottom - radius),
                               {$ELSE}
                               Create2DIntPoint(Rect.right - radius, Rect.bottom - radius),
                               {$ENDIF}
                               Radius,
                               cpRightBottom,
                               InnerLightColor,
                               ClipRect);

// Zewnêtrzna krawêdŸ
// Zaokr¹glone naro¿niki
if not(TopEdgeOpen) then
   begin
   x1:=Rect.Left + Radius * LeftClosed;
   x2:=Rect.Right - Radius * RightClosed;
   y1:=Rect.Top;
   TGuiTools.DrawHLine(Bitmap, x1, x2, y1, FrameColor, ClipRect);
   end;

if not(BottomEdgeOpen) then
   begin
   x1:=Rect.Left + Radius * LeftClosed;
   x2:=Rect.Right - Radius * RightClosed;
   y1:=Rect.Bottom;
   TGuiTools.DrawHLine(Bitmap, x1, x2, y1, FrameColor, ClipRect);
   end;

if not(LeftEdgeOpen) then
   begin
   y1:=Rect.Top + Radius * TopClosed;
   y2:=Rect.Bottom - Radius * BottomClosed;
   x1:=Rect.Left;
   TGuiTools.DrawVLine(Bitmap, x1, y1, y2, FrameColor, ClipRect);
   end;

if not(RightEdgeOpen) then
   begin
   y1:=Rect.Top + Radius * TopClosed;
   y2:=Rect.Bottom - Radius * BottomClosed;
   x1:=Rect.Right;
   TGuiTools.DrawVLine(Bitmap, x1, y1, y2, FrameColor, ClipRect);
   end;

if not(LeftEdgeOpen or TopEdgeOpen) then
   TGuiTools.DrawAARoundCorner(Bitmap,
                               {$IFDEF EnhancedRecordSupport}
                               T2DIntPoint.create(Rect.left, Rect.Top),
                               {$ELSE}
                               Create2DIntPoint(Rect.left, Rect.Top),
                               {$ENDIF}
                               Radius,
                               cpLeftTop,
                               FrameColor,
                               ClipRect);
if not(RightEdgeOpen or TopEdgeOpen) then
   TGuiTools.DrawAARoundCorner(Bitmap,
                               {$IFDEF EnhancedRecordSupport}
                               T2DIntPoint.create(Rect.right - radius + 1, Rect.Top),
                               {$ELSE}
                               Create2DIntPoint(Rect.right - radius + 1, Rect.Top),
                               {$ENDIF}
                               Radius,
                               cpRightTop,
                               FrameColor,
                               ClipRect);
if not(LeftEdgeOpen or BottomEdgeOpen) then
   TGuiTools.DrawAARoundCorner(Bitmap,
                               {$IFDEF EnhancedRecordSupport}
                               T2DIntPoint.create(Rect.left, Rect.bottom - radius + 1),
                               {$ELSE}
                               Create2DIntPoint(Rect.left, Rect.bottom - radius + 1),
                               {$ENDIF}
                               Radius,
                               cpLeftBottom,
                               FrameColor,
                               ClipRect);
if not(RightEdgeOpen or BottomEdgeOpen) then
   TGuiTools.DrawAARoundCorner(Bitmap,
                               {$IFDEF EnhancedRecordSupport}
                               T2DIntPoint.create(Rect.right - radius + 1, Rect.bottom - radius + 1),
                               {$ELSE}
                               Create2DIntPoint(Rect.right - radius + 1, Rect.bottom - radius + 1),
                               {$ENDIF}
                               Radius,
                               cpRightBottom,
                               FrameColor,
                               ClipRect);
end;

end.
