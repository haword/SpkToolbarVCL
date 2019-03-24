unit SpkGuiTools;

{$DEFINE SPKGUITOOLS}

interface

{$MESSAGE HINT 'W tym module konsekwentnie ka¿dy rect opisuje dok³adny prostok¹t (a nie, jak w przypadku WINAPI - bez dolnej i prawej krawêdzi)'}

uses
  Windows, Graphics, SysUtils, Math, Classes, Controls, ImgList, SpkGraphTools,
  SpkMath;

type
  TCornerPos = (cpLeftTop, cpRightTop, cpLeftBottom, cpRightBottom);

  TCornerKind = (cpRound, cpNormal);

  TBackgroundKind = (bkSolid, bkVerticalGradient, bkHorizontalGradient, bkConcave);

type
  TGUITools = class(TObject)
  private
  protected
    class procedure FillGradientRectangle(ACanvas: TCanvas; Rect: T2DIntRect; ColorFrom: TColor; ColorTo: TColor; GradientKind: TBackgroundKind);
    class procedure SaveClipRgn(DC: HDC; var OrgRgnExists: boolean; var OrgRgn: HRGN);
    class procedure RestoreClipRgn(DC: HDC; OrgRgnExists: boolean; var OrgRgn: HRGN);
  public
       // *** Lines ***

       // Performance:
       // w/ClipRect:  Bitmap is faster (2x)
       // wo/ClipRect: Canvas is faster (a little)
    class procedure DrawHLine(ABitmap: TBitmap; x1, x2: integer; y: integer; Color: TColor); overload; inline;
    class procedure DrawHLine(ABitmap: TBitmap; x1, x2: integer; y: integer; Color: TColor; ClipRect: T2DIntRect); overload; inline;
    class procedure DrawHLine(ACanvas: TCanvas; x1, x2: integer; y: integer; Color: TColor); overload; inline;
    class procedure DrawHLine(ACanvas: TCanvas; x1, x2: integer; y: integer; Color: TColor; ClipRect: T2DIntRect); overload; inline;


       // Performance:
       // w/ClipRect:  Bitmap is faster (2x)
       // wo/ClipRect: Canvas is faster (a little)
    class procedure DrawVLine(ABitmap: TBitmap; x: integer; y1, y2: integer; Color: TColor); overload; inline;
    class procedure DrawVLine(ABitmap: TBitmap; x: integer; y1, y2: integer; Color: TColor; ClipRect: T2DIntRect); overload; inline;
    class procedure DrawVLine(ACanvas: TCanvas; x: integer; y1, y2: integer; Color: TColor); overload; inline;
    class procedure DrawVLine(ACanvas: TCanvas; x: integer; y1, y2: integer; Color: TColor; ClipRect: T2DIntRect); overload; inline;

       // *** Background and frame tools ***

       // Performance:
       // w/ClipRect:  Bitmap is faster (extremely)
       // wo/ClipRect: Bitmap is faster (extremely)
    class procedure DrawAARoundCorner(ABitmap: TBitmap; Point: T2DIntVector; Radius: integer; CornerPos: TCornerPos; Color: TColor); overload; inline;
    class procedure DrawAARoundCorner(ABitmap: TBitmap; Point: T2DIntVector; Radius: integer; CornerPos: TCornerPos; Color: TColor; ClipRect: T2DIntRect); overload; inline;
    class procedure DrawAARoundCorner(ACanvas: TCanvas; Point: T2DIntVector; Radius: integer; CornerPos: TCornerPos; Color: TColor); overload; inline;
    class procedure DrawAARoundCorner(ACanvas: TCanvas; Point: T2DIntVector; Radius: integer; CornerPos: TCornerPos; Color: TColor; ClipRect: T2DIntRect); overload; inline;

       // Performance:
       // w/ClipRect:  Bitmap is faster (extremely)
       // wo/ClipRect: Bitmap is faster (extremely)
    class procedure DrawAARoundFrame(ABitmap: TBitmap; Rect: T2DIntRect; Radius: integer; Color: TColor); overload; inline;
    class procedure DrawAARoundFrame(ABitmap: TBitmap; Rect: T2DIntRect; Radius: integer; Color: TColor; ClipRect: T2DIntRect); overload; inline;
    class procedure DrawAARoundFrame(ACanvas: TCanvas; Rect: T2DIntRect; Radius: integer; Color: TColor); overload; inline;
    class procedure DrawAARoundFrame(ACanvas: TCanvas; Rect: T2DIntRect; Radius: integer; Color: TColor; ClipRect: T2DIntRect); overload; inline;
    class procedure RenderBackground(ABuffer: TBitmap; Rect: T2DIntRect; Color1, Color2: TColor; BackgroundKind: TBackgroundKind); inline;
    class procedure CopyRoundCorner(ABuffer: TBitmap; ABitmap: TBitmap; SrcPoint: T2DIntVector; DstPoint: T2DIntVector; Radius: integer; CornerPos: TCornerPos; Convex: boolean = true); overload; inline;
    class procedure CopyRoundCorner(ABuffer: TBitmap; ABitmap: TBitmap; SrcPoint: T2DIntVector; DstPoint: T2DIntVector; Radius: integer; CornerPos: TCornerPos; ClipRect: T2DIntRect; Convex: boolean = true); overload; inline;
    class procedure CopyCorner(ABuffer: TBitmap; ABitmap: TBitmap; SrcPoint: T2DIntVector; DstPoint: T2DIntVector; Radius: integer); overload; inline;
    class procedure CopyCorner(ABuffer: TBitmap; ABitmap: TBitmap; SrcPoint: T2DIntVector; DstPoint: T2DIntVector; Radius: integer; ClipRect: T2DIntRect); overload; inline;
    class procedure CopyRectangle(ABuffer: TBitmap; ABitmap: TBitmap; SrcPoint: T2DIntVector; DstPoint: T2DIntVector; Width: integer; Height: integer); overload; inline;
    class procedure CopyRectangle(ABuffer: TBitmap; ABitmap: TBitmap; SrcPoint: T2DIntVector; DstPoint: T2DIntVector; Width: integer; Height: integer; ClipRect: T2DIntRect); overload; inline;
    class procedure CopyMaskRectangle(ABuffer: TBitmap; AMask: TBitmap; ABitmap: TBitmap; SrcPoint: T2DIntVector; DstPoint: T2DIntVector; Width: integer; Height: integer); overload; inline;
    class procedure CopyMaskRectangle(ABuffer: TBitmap; AMask: TBitmap; ABitmap: TBitmap; SrcPoint: T2DIntVector; DstPoint: T2DIntVector; Width: integer; Height: integer; ClipRect: T2DIntRect); overload; inline;

       // Performance (RenderBackground + CopyRoundRect vs DrawRoundRect):
       // w/ClipRect  : Bitmap faster for smaller radiuses, Canvas faster for larger
       // wo/ClipRect : Bitmap faster for smaller radiuses, Canvas faster for larger
    class procedure CopyRoundRect(ABuffer: TBitmap; ABitmap: TBitmap; SrcPoint: T2DIntVector; DstPoint: T2DIntVector; Width, Height: integer; Radius: integer; LeftTopRound: boolean = true; RightTopRound: boolean = true; LeftBottomRound: boolean = true; RightBottomRound: boolean = true); overload; inline;
    class procedure CopyRoundRect(ABuffer: TBitmap; ABitmap: TBitmap; SrcPoint: T2DIntVector; DstPoint: T2DIntVector; Width, Height: integer; Radius: integer; ClipRect: T2DIntRect; LeftTopRound: boolean = true; RightTopRound: boolean = true; LeftBottomRound: boolean = true; RightBottomRound: boolean = true); overload; inline;
    class procedure DrawRoundRect(ACanvas: TCanvas; Rect: T2DIntRect; Radius: integer; ColorFrom: TColor; ColorTo: TColor; GradientKind: TBackgroundKind; LeftTopRound: boolean = true; RightTopRound: boolean = true; LeftBottomRound: boolean = true; RightBottomRound: boolean = true); overload; inline;
    class procedure DrawRoundRect(ACanvas: TCanvas; Rect: T2DIntRect; Radius: integer; ColorFrom: TColor; ColorTo: TColor; GradientKind: TBackgroundKind; ClipRect: T2DIntRect; LeftTopRound: boolean = true; RightTopRound: boolean = true; LeftBottomRound: boolean = true; RightBottomRound: boolean = true); overload; inline;
    class procedure DrawRegion(ACanvas: TCanvas; Region: HRGN; Rect: T2DIntRect; ColorFrom: TColor; ColorTo: TColor; GradientKind: TBackgroundKind); overload; inline;
    class procedure DrawRegion(ACanvas: TCanvas; Region: HRGN; Rect: T2DIntRect; ColorFrom: TColor; ColorTo: TColor; GradientKind: TBackgroundKind; ClipRect: T2DIntRect); overload; inline;

       // Imagelist tools
    class procedure DrawImage(ABitmap: TBitmap; Imagelist: TImageList; ImageIndex: integer; Point: T2DIntVector); overload; inline;
    class procedure DrawImage(ABitmap: TBitmap; Imagelist: TImageList; ImageIndex: integer; Point: T2DIntVector; ClipRect: T2DIntRect); overload; inline;
    class procedure DrawImage(ACanvas: TCanvas; Imagelist: TImageList; ImageIndex: integer; Point: T2DIntVector); overload; inline;
    class procedure DrawImage(ACanvas: TCanvas; Imagelist: TImageList; ImageIndex: integer; Point: T2DIntVector; ClipRect: T2DIntRect); overload; inline;
    class procedure DrawDisabledImage(ABitmap: TBitmap; Imagelist: TImageList; ImageIndex: integer; Point: T2DIntVector); overload; inline;
    class procedure DrawDisabledImage(ABitmap: TBitmap; Imagelist: TImageList; ImageIndex: integer; Point: T2DIntVector; ClipRect: T2DIntRect); overload; inline;
    class procedure DrawDisabledImage(ACanvas: TCanvas; Imagelist: TImageList; ImageIndex: integer; Point: T2DIntVector); overload; inline;
    class procedure DrawDisabledImage(ACanvas: TCanvas; Imagelist: TImageList; ImageIndex: integer; Point: T2DIntVector; ClipRect: T2DIntRect); overload; inline;

       // Text tools
    class procedure DrawText(ABitmap: TBitmap; x, y: integer; AText: string; TextColor: TColor); overload; inline;
    class procedure DrawText(ABitmap: TBitmap; x, y: integer; AText: string; TextColor: TColor; ClipRect: T2DIntRect); overload; inline;
    class procedure DrawMarkedText(ACanvas: TCanvas; x, y: integer; AText: string; AMarkPhrase: string; TextColor: TColor; CaseSensitive: boolean = false); overload; inline;
    class procedure DrawMarkedText(ACanvas: TCanvas; x, y: integer; AText: string; AMarkPhrase: string; TextColor: TColor; ClipRect: T2DIntRect; CaseSensitive: boolean = false); overload; inline;
    class procedure DrawText(ACanvas: TCanvas; x, y: integer; AText: string; TextColor: TColor); overload; inline;
    class procedure DrawText(ACanvas: TCanvas; x, y: integer; AText: string; TextColor: TColor; ClipRect: T2DIntRect); overload; inline;
    class procedure DrawFitWText(ABitmap: TBitmap; x1, x2: integer; y: integer; AText: string; TextColor: TColor; Align: TAlignment); overload; inline;
    class procedure DrawFitWText(ACanvas: TCanvas; x1, x2: integer; y: integer; AText: string; TextColor: TColor; Align: TAlignment); overload; inline;
    class procedure DrawOutlinedText(ABitmap: TBitmap; x, y: integer; AText: string; TextColor: TColor; OutlineColor: TColor); overload; inline;
    class procedure DrawOutlinedText(ABitmap: TBitmap; x, y: integer; AText: string; TextColor: TColor; OutlineColor: TColor; ClipRect: T2DIntRect); overload; inline;
    class procedure DrawOutlinedText(ACanvas: TCanvas; x, y: integer; AText: string; TextColor: TColor; OutlineColor: TColor); overload; inline;
    class procedure DrawOutlinedText(ACanvas: TCanvas; x, y: integer; AText: string; TextColor: TColor; OutlineColor: TColor; ClipRect: T2DIntRect); overload; inline;
    class procedure DrawFitWOutlinedText(ABitmap: TBitmap; x1, x2: integer; y: integer; AText: string; TextColor, OutlineColor: TColor; Align: TAlignment); overload; inline;
    class procedure DrawFitWOutlinedText(ACanvas: TCanvas; x1, x2: integer; y: integer; AText: string; TextColor, OutlineColor: TColor; Align: TAlignment); overload; inline;
  end;

implementation

{ TSpkGUITools }

class procedure TGUITools.CopyRoundCorner(ABuffer, ABitmap: TBitmap; SrcPoint, DstPoint: T2DIntVector; Radius: integer; CornerPos: TCornerPos; ClipRect: T2DIntRect; Convex: boolean);
var
  BufferRect, BitmapRect: T2DIntRect;
  OrgSrcRect, UnClippedDstRect, OrgDstRect: T2DIntRect;
  SrcRect: T2DIntRect;
  Offset: T2DIntVector;
  Center: T2DIntVector;
  y: Integer;
  SrcLine: Pointer;
  DstLine: Pointer;
  SrcPtr, DstPtr: PByte;
  x: Integer;
  Dist: double;
begin
  if (ABuffer.PixelFormat <> pf24bit) or (ABitmap.PixelFormat <> pf24bit) then
    raise exception.create('TSpkGUITools.CopyRoundCorner: Tylko 24-bitowe bitmapy s¹ akceptowane!');

// Sprawdzanie poprawnoœci
  if Radius < 1 then
    exit;

  if (ABuffer.width = 0) or (ABuffer.height = 0) or (ABitmap.width = 0) or (ABitmap.height = 0) then
    exit;

  BufferRect := T2DIntRect.create(0, 0, ABuffer.width - 1, ABuffer.height - 1);
  if not (BufferRect.IntersectsWith(T2DIntRect.create(SrcPoint.x, SrcPoint.y, SrcPoint.x + Radius - 1, SrcPoint.y + Radius - 1), OrgSrcRect)) then
    exit;

  BitmapRect := T2DIntRect.create(0, 0, ABitmap.width - 1, ABitmap.height - 1);
  if not (BitmapRect.IntersectsWith(T2DIntRect.create(DstPoint.x, DstPoint.y, DstPoint.x + Radius - 1, DstPoint.y + Radius - 1), UnClippedDstRect)) then
    exit;

  if not (ClipRect.IntersectsWith(UnClippedDstRect, OrgDstRect)) then
    exit;

  Offset := DstPoint - SrcPoint;

  if not (OrgSrcRect.IntersectsWith(OrgDstRect - Offset, SrcRect)) then
    exit;

// Ustalamy pozycjê œrodka ³uku
  case CornerPos of
    cpLeftTop:
      Center := T2DIntVector.create(SrcPoint.x + Radius - 1, SrcPoint.y + Radius - 1);
    cpRightTop:
      Center := T2DIntVector.create(SrcPoint.x, SrcPoint.y + Radius - 1);
    cpLeftBottom:
      Center := T2DIntVector.Create(SrcPoint.x + Radius - 1, SrcPoint.y);
    cpRightBottom:
      Center := T2DIntVector.Create(SrcPoint.x, SrcPoint.y);
  end;

// Czy jest cokolwiek do przetworzenia?
  if Convex then
  begin
    if (SrcRect.left <= SrcRect.right) and (SrcRect.top <= SrcRect.bottom) then
      for y := SrcRect.top to SrcRect.bottom do
      begin
        SrcLine := ABuffer.ScanLine[y];
        DstLine := ABitmap.ScanLine[y + Offset.y];

        SrcPtr := pointer(integer(SrcLine) + 3 * SrcRect.left);
        DstPtr := pointer(integer(DstLine) + 3 * (SrcRect.left + Offset.x));
        for x := SrcRect.left to SrcRect.right do
        begin
          Dist := Center.DistanceTo(T2DIntVector.create(x, y));
          if Dist <= (Radius - 1) then
            Move(SrcPtr^, DstPtr^, 3);

          inc(SrcPtr, 3);
          inc(DstPtr, 3);
        end;
      end;
  end
  else
  begin
    if (SrcRect.left <= SrcRect.right) and (SrcRect.top <= SrcRect.bottom) then
      for y := SrcRect.top to SrcRect.bottom do
      begin
        SrcLine := ABuffer.ScanLine[y];
        DstLine := ABitmap.ScanLine[y + Offset.y];

        SrcPtr := pointer(integer(SrcLine) + 3 * SrcRect.left);
        DstPtr := pointer(integer(DstLine) + 3 * (SrcRect.left + Offset.x));
        for x := SrcRect.left to SrcRect.right do
        begin
          Dist := Center.DistanceTo(T2DIntVector.create(x, y));
          if Dist >= (Radius - 1) then
            Move(SrcPtr^, DstPtr^, 3);

          inc(SrcPtr, 3);
          inc(DstPtr, 3);
        end;
      end;
  end;
end;

class procedure TGUITools.CopyRoundRect(ABuffer, ABitmap: TBitmap; SrcPoint, DstPoint: T2DIntVector; Width, Height, Radius: integer; ClipRect: T2DIntRect; LeftTopRound, RightTopRound, LeftBottomRound, RightBottomRound: boolean);
begin
  if (ABuffer.PixelFormat <> pf24bit) or (ABitmap.PixelFormat <> pf24bit) then
    raise exception.create('TSpkGUITools.CopyBackground: Tylko 24-bitowe bitmapy s¹ akceptowane!');

// Sprawdzamy poprawnoœæ
  if Radius < 0 then
    exit;

  if (Radius > Width div 2) or (Radius > Height div 2) then
    exit;

  if (ABuffer.width = 0) or (ABuffer.height = 0) or (ABitmap.width = 0) or (ABitmap.height = 0) then
    exit;

{$REGION 'Wype³niamy prostok¹ty'}
// Góra
  CopyRectangle(ABuffer, ABitmap, T2DIntPoint.create(SrcPoint.x + Radius, SrcPoint.y), T2DIntPoint.create(DstPoint.x + Radius, DstPoint.y), Width - 2 * Radius, Radius, ClipRect);
// Dó³
  CopyRectangle(ABuffer, ABitmap, T2DIntPoint.create(SrcPoint.x + Radius, SrcPoint.y + Height - Radius), T2DIntPoint.create(DstPoint.x + Radius, DstPoint.y + Height - Radius), Width - 2 * Radius, Radius, ClipRect);
// Œrodek
  CopyRectangle(ABuffer, ABitmap, T2DIntPoint.create(SrcPoint.x, SrcPoint.y + Radius), T2DIntPoint.create(DstPoint.x, DstPoint.y + Radius), Width, Height - 2 * Radius, ClipRect);
{$ENDREGION}

// Wype³niamy naro¿niki

{$REGION 'Lewy górny'}
  if LeftTopRound then
    TGUITools.CopyRoundCorner(ABuffer, ABitmap, T2DIntPoint.Create(SrcPoint.x, SrcPoint.y), T2DIntPoint.Create(DstPoint.x, DstPoint.y), Radius, cpLeftTop, ClipRect, true)
  else
    TGUITools.CopyCorner(ABuffer, ABitmap, T2DIntPoint.Create(SrcPoint.x, SrcPoint.y), T2DIntPoint.Create(DstPoint.x, DstPoint.y), Radius, ClipRect);
{$ENDREGION}

{$REGION 'Prawy górny'}
  if RightTopRound then
    TGUITools.CopyRoundCorner(ABuffer, ABitmap, T2DIntPoint.Create(SrcPoint.x + Width - Radius, SrcPoint.y), T2DIntPoint.Create(DstPoint.x + Width - Radius, DstPoint.y), Radius, cpRightTop, ClipRect, true)
  else
    TGUITools.CopyCorner(ABuffer, ABitmap, T2DIntPoint.Create(SrcPoint.x + Width - Radius, SrcPoint.y), T2DIntPoint.Create(DstPoint.x + Width - Radius, DstPoint.y), Radius, ClipRect);
{$ENDREGION}

{$REGION 'Lewy dolny'}
  if LeftBottomRound then
    TGUITools.CopyRoundCorner(ABuffer, ABitmap, T2DIntPoint.Create(SrcPoint.x, SrcPoint.y + Height - Radius), T2DIntPoint.Create(DstPoint.x, DstPoint.y + Height - Radius), Radius, cpLeftBottom, ClipRect, true)
  else
    TGUITools.CopyCorner(ABuffer, ABitmap, T2DIntPoint.Create(SrcPoint.x, SrcPoint.y + Height - Radius), T2DIntPoint.Create(DstPoint.x, DstPoint.y + Height - Radius), Radius, ClipRect);
{$ENDREGION}

{$REGION 'Prawy dolny'}
  if RightBottomRound then
    TGUITools.CopyRoundCorner(ABuffer, ABitmap, T2DIntPoint.Create(SrcPoint.x + Width - Radius, SrcPoint.y + Height - Radius), T2DIntPoint.Create(DstPoint.x + Width - Radius, DstPoint.y + Height - Radius), Radius, cpRightBottom, ClipRect, true)
  else
    TGUITools.CopyCorner(ABuffer, ABitmap, T2DIntPoint.Create(SrcPoint.x + Width - Radius, SrcPoint.y + Height - Radius), T2DIntPoint.Create(DstPoint.x + Width - Radius, DstPoint.y + Height - Radius), Radius, ClipRect);
{$ENDREGION'}
end;

class procedure TGUITools.CopyRoundRect(ABuffer: TBitmap; ABitmap: TBitmap; SrcPoint, DstPoint: T2DIntVector; Width, Height, Radius: integer; LeftTopRound, RightTopRound, LeftBottomRound, RightBottomRound: boolean);
begin
  if (ABuffer.PixelFormat <> pf24bit) or (ABitmap.PixelFormat <> pf24bit) then
    raise exception.create('TSpkGUITools.CopyBackground: Tylko 24-bitowe bitmapy s¹ akceptowane!');

// Sprawdzamy poprawnoœæ
  if Radius < 0 then
    exit;

  if (Radius > Width div 2) or (Radius > Height div 2) then
    exit;

  if (ABuffer.width = 0) or (ABuffer.height = 0) or (ABitmap.width = 0) or (ABitmap.height = 0) then
    exit;

{$REGION 'Wype³niamy prostok¹ty'}
// Góra
  CopyRectangle(ABuffer, ABitmap, T2DIntPoint.create(SrcPoint.x + Radius, SrcPoint.y), T2DIntPoint.create(DstPoint.x + Radius, DstPoint.y), Width - 2 * Radius, Radius);
// Dó³
  CopyRectangle(ABuffer, ABitmap, T2DIntPoint.create(SrcPoint.x + Radius, SrcPoint.y + Height - Radius), T2DIntPoint.create(DstPoint.x + Radius, DstPoint.y + Height - Radius), Width - 2 * Radius, Radius);
// Œrodek
  CopyRectangle(ABuffer, ABitmap, T2DIntPoint.create(SrcPoint.x, SrcPoint.y + Radius), T2DIntPoint.create(DstPoint.x, DstPoint.y + Radius), Width, Height - 2 * Radius);
{$ENDREGION}

// Wype³niamy naro¿niki
{$REGION 'Lewy górny'}
  if LeftTopRound then
    TGUITools.CopyRoundCorner(ABuffer, ABitmap, T2DIntPoint.Create(SrcPoint.x, SrcPoint.y), T2DIntPoint.Create(DstPoint.x, DstPoint.y), Radius, cpLeftTop, true)
  else
    TGUITools.CopyCorner(ABuffer, ABitmap, T2DIntPoint.Create(SrcPoint.x, SrcPoint.y), T2DIntPoint.Create(DstPoint.x, DstPoint.y), Radius);
{$ENDREGION}

{$REGION 'Prawy górny'}
  if RightTopRound then
    TGUITools.CopyRoundCorner(ABuffer, ABitmap, T2DIntPoint.Create(SrcPoint.x + Width - Radius, SrcPoint.y), T2DIntPoint.Create(DstPoint.x + Width - Radius, DstPoint.y), Radius, cpRightTop, true)
  else
    TGUITools.CopyCorner(ABuffer, ABitmap, T2DIntPoint.Create(SrcPoint.x + Width - Radius, SrcPoint.y), T2DIntPoint.Create(DstPoint.x + Width - Radius, DstPoint.y), Radius);
{$ENDREGION}

{$REGION 'Lewy dolny'}
  if LeftBottomRound then
    TGUITools.CopyRoundCorner(ABuffer, ABitmap, T2DIntPoint.Create(SrcPoint.x, SrcPoint.y + Height - Radius), T2DIntPoint.Create(DstPoint.x, DstPoint.y + Height - Radius), Radius, cpLeftBottom, true)
  else
    TGUITools.CopyCorner(ABuffer, ABitmap, T2DIntPoint.Create(SrcPoint.x, SrcPoint.y + Height - Radius), T2DIntPoint.Create(DstPoint.x, DstPoint.y + Height - Radius), Radius);
{$ENDREGION}

{$REGION 'Prawy dolny'}
  if RightBottomRound then
    TGUITools.CopyRoundCorner(ABuffer, ABitmap, T2DIntPoint.Create(SrcPoint.x + Width - Radius, SrcPoint.y + Height - Radius), T2DIntPoint.Create(DstPoint.x + Width - Radius, DstPoint.y + Height - Radius), Radius, cpRightBottom, true)
  else
    TGUITools.CopyCorner(ABuffer, ABitmap, T2DIntPoint.Create(SrcPoint.x + Width - Radius, SrcPoint.y + Height - Radius), T2DIntPoint.Create(DstPoint.x + Width - Radius, DstPoint.y + Height - Radius), Radius);
{$ENDREGION'}
end;

class procedure TGUITools.CopyRectangle(ABuffer, ABitmap: TBitmap; SrcPoint, DstPoint: T2DIntVector; Width, Height: integer);
var
  BufferRect, BitmapRect: T2DIntRect;
  SrcRect, DstRect: T2DIntRect;
  ClippedSrcRect: T2DIntRect;
  Offset: T2DIntVector;
  y: Integer;
  SrcLine: Pointer;
  DstLine: Pointer;
begin
  if (ABuffer.PixelFormat <> pf24bit) or (ABitmap.PixelFormat <> pf24bit) then
    raise exception.create('TSpkGUITools.CopyRoundCorner: Tylko 24-bitowe bitmapy s¹ akceptowane!');

// Sprawdzanie poprawnoœci
  if (Width < 1) or (Height < 1) then
    exit;

  if (ABuffer.width = 0) or (ABuffer.height = 0) or (ABitmap.width = 0) or (ABitmap.height = 0) then
    exit;

// Przycinamy Ÿród³owy rect do obszaru Ÿród³owej bitmapy
  BufferRect := T2DIntRect.create(0, 0, ABuffer.width - 1, ABuffer.height - 1);

  if not (BufferRect.IntersectsWith(T2DIntRect.create(SrcPoint.x, SrcPoint.y, SrcPoint.x + Width - 1, SrcPoint.y + Height - 1), SrcRect)) then
    exit;

// Przycinamy docelowy rect do obszaru docelowej bitmapy
  BitmapRect := T2DIntRect.create(0, 0, ABitmap.width - 1, ABitmap.height - 1);
  if not (BitmapRect.IntersectsWith(T2DIntRect.create(DstPoint.x, DstPoint.y, DstPoint.x + Width - 1, DstPoint.y + Height - 1), DstRect)) then
    exit;

// Liczymy offset Ÿród³owego do docelowego recta
  Offset := DstPoint - SrcPoint;

// Sprawdzamy, czy na³o¿one na siebie recty: Ÿród³owy i docelowy przesuniêty o
// offset maj¹ jak¹œ czêœæ wspóln¹
  if not (SrcRect.IntersectsWith(DstRect - Offset, ClippedSrcRect)) then
    exit;

// Jeœli jest cokolwiek do przetworzenia, wykonaj operacjê
  if (ClippedSrcRect.left <= ClippedSrcRect.right) and (ClippedSrcRect.top <= ClippedSrcRect.bottom) then
    for y := ClippedSrcRect.top to ClippedSrcRect.bottom do
    begin
      SrcLine := ABuffer.ScanLine[y];
      DstLine := ABitmap.ScanLine[y + Offset.y];

      Move(pointer(integer(SrcLine) + 3 * ClippedSrcRect.left)^, pointer(integer(DstLine) + 3 * (ClippedSrcRect.left + Offset.x))^, 3 * ClippedSrcRect.Width);
    end;
end;

class procedure TGUITools.CopyCorner(ABuffer: TBitmap; ABitmap: TBitmap; SrcPoint, DstPoint: T2DIntVector; Radius: integer);
begin
  CopyRectangle(ABuffer, ABitmap, SrcPoint, DstPoint, Radius, Radius);
end;

class procedure TGUITools.CopyCorner(ABuffer, ABitmap: TBitmap; SrcPoint, DstPoint: T2DIntVector; Radius: integer; ClipRect: T2DIntRect);
begin
  CopyRectangle(ABuffer, ABitmap, SrcPoint, DstPoint, Radius, Radius, ClipRect);
end;

class procedure TGUITools.CopyMaskRectangle(ABuffer, AMask, ABitmap: TBitmap; SrcPoint, DstPoint: T2DIntVector; Width, Height: integer);
var
  BufferRect, BitmapRect: T2DIntRect;
  SrcRect, DstRect: T2DIntRect;
  ClippedSrcRect: T2DIntRect;
  Offset: T2DIntVector;
  y: Integer;
  SrcLine: Pointer;
  MaskLine: Pointer;
  DstLine: Pointer;
  i: Integer;
begin
  if (ABuffer.PixelFormat <> pf24bit) or (ABitmap.PixelFormat <> pf24bit) then
    raise exception.create('TSpkGUITools.CopyRoundCorner: Tylko 24-bitowe bitmapy s¹ akceptowane!');

  if (AMask.PixelFormat <> pf8bit) then
    raise exception.create('TSpkGUITools.CopyRoundCorner: Tylko 8-bitowe maski s¹ akceptowane!');

// Sprawdzanie poprawnoœci
  if (Width < 1) or (Height < 1) then
    exit;

  if (ABuffer.width = 0) or (ABuffer.height = 0) or (ABitmap.width = 0) or (ABitmap.height = 0) then
    exit;

  if (ABuffer.Width <> AMask.Width) or (ABuffer.Height <> AMask.Height) then
    exit;

// Przycinamy Ÿród³owy rect do obszaru Ÿród³owej bitmapy
  BufferRect := T2DIntRect.create(0, 0, ABuffer.width - 1, ABuffer.height - 1);

  if not (BufferRect.IntersectsWith(T2DIntRect.create(SrcPoint.x, SrcPoint.y, SrcPoint.x + Width - 1, SrcPoint.y + Height - 1), SrcRect)) then
    exit;

// Przycinamy docelowy rect do obszaru docelowej bitmapy
  BitmapRect := T2DIntRect.create(0, 0, ABitmap.width - 1, ABitmap.height - 1);
  if not (BitmapRect.IntersectsWith(T2DIntRect.create(DstPoint.x, DstPoint.y, DstPoint.x + Width - 1, DstPoint.y + Height - 1), DstRect)) then
    exit;

// Liczymy offset Ÿród³owego do docelowego recta
  Offset := DstPoint - SrcPoint;

// Sprawdzamy, czy na³o¿one na siebie recty: Ÿród³owy i docelowy przesuniêty o
// offset maj¹ jak¹œ czêœæ wspóln¹
  if not (SrcRect.IntersectsWith(DstRect - Offset, ClippedSrcRect)) then
    exit;

// Jeœli jest cokolwiek do przetworzenia, wykonaj operacjê
  if (ClippedSrcRect.left <= ClippedSrcRect.right) and (ClippedSrcRect.top <= ClippedSrcRect.bottom) then
    for y := ClippedSrcRect.top to ClippedSrcRect.bottom do
    begin
      SrcLine := ABuffer.ScanLine[y];
      SrcLine := pointer(integer(SrcLine) + 3 * ClippedSrcRect.left);

      MaskLine := AMask.ScanLine[y];
      MaskLine := pointer(integer(MaskLine) + ClippedSrcRect.left);

      DstLine := ABitmap.ScanLine[y + Offset.y];
      DstLine := pointer(integer(DstLine) + 3 * (ClippedSrcRect.left + Offset.x));

      for i := 0 to ClippedSrcRect.Width - 1 do
      begin
        if PByte(MaskLine)^ < 128 then
          Move(SrcLine^, DstLine^, 3);

        SrcLine := pointer(integer(SrcLine) + 3);
        DstLine := pointer(integer(DstLine) + 3);
        MaskLine := pointer(integer(MaskLine) + 1);
      end;
    end;
end;

class procedure TGUITools.CopyMaskRectangle(ABuffer, AMask, ABitmap: TBitmap; SrcPoint, DstPoint: T2DIntVector; Width, Height: integer; ClipRect: T2DIntRect);
var
  BufferRect, BitmapRect: T2DIntRect;
  SrcRect, DstRect: T2DIntRect;
  ClippedSrcRect, ClippedDstRect: T2DIntRect;
  Offset: T2DIntVector;
  y: Integer;
  SrcLine: Pointer;
  DstLine: Pointer;
  i: Integer;
  MaskLine: Pointer;
begin
  if (ABuffer.PixelFormat <> pf24bit) or (ABitmap.PixelFormat <> pf24bit) then
    raise exception.create('TSpkGUITools.CopyMaskRectangle: Tylko 24-bitowe bitmapy s¹ akceptowane!');
  if AMask.PixelFormat <> pf8bit then
    raise exception.create('TSpkGUITools.CopyMaskRectangle: Tylko 8-bitowe maski s¹ akceptowane!');

// Sprawdzanie poprawnoœci
  if (Width < 1) or (Height < 1) then
    exit;

  if (ABuffer.width = 0) or (ABuffer.height = 0) or (ABitmap.width = 0) or (ABitmap.height = 0) then
    exit;

  if (ABuffer.Width <> AMask.Width) or (ABuffer.Height <> AMask.Height) then
    raise exception.create('TSpkGUITools.CopyMaskRectangle: Maska ma nieprawid³owe rozmiary!');

// Przycinamy Ÿród³owy rect do obszaru Ÿród³owej bitmapy
  BufferRect := T2DIntRect.create(0, 0, ABuffer.width - 1, ABuffer.height - 1);
  if not (BufferRect.IntersectsWith(T2DIntRect.create(SrcPoint.x, SrcPoint.y, SrcPoint.x + Width - 1, SrcPoint.y + Height - 1), SrcRect)) then
    exit;

// Przycinamy docelowy rect do obszaru docelowej bitmapy
  BitmapRect := T2DIntRect.create(0, 0, ABitmap.width - 1, ABitmap.height - 1);
  if not (BitmapRect.IntersectsWith(T2DIntRect.create(DstPoint.x, DstPoint.y, DstPoint.x + Width - 1, DstPoint.y + Height - 1), DstRect)) then
    exit;

// Dodatkowo przycinamy docelowy rect
  if not (DstRect.IntersectsWith(ClipRect, ClippedDstRect)) then
    Exit;

// Liczymy offset Ÿród³owego do docelowego recta
  Offset := DstPoint - SrcPoint;

// Sprawdzamy, czy na³o¿one na siebie recty: Ÿród³owy i docelowy przesuniêty o
// offset maj¹ jak¹œ czêœæ wspóln¹
  if not (SrcRect.IntersectsWith(ClippedDstRect - Offset, ClippedSrcRect)) then
    exit;

// Jeœli jest cokolwiek do przetworzenia, wykonaj operacjê
  if (ClippedSrcRect.left <= ClippedSrcRect.right) and (ClippedSrcRect.top <= ClippedSrcRect.bottom) then
    for y := ClippedSrcRect.top to ClippedSrcRect.bottom do
    begin
      SrcLine := ABuffer.ScanLine[y];
      SrcLine := pointer(integer(SrcLine) + 3 * ClippedSrcRect.left);

      MaskLine := AMask.ScanLine[y];
      MaskLine := pointer(integer(MaskLine) + ClippedSrcRect.left);

      DstLine := ABitmap.ScanLine[y + Offset.y];
      DstLine := pointer(integer(DstLine) + 3 * (ClippedSrcRect.left + Offset.x));

      for i := 0 to ClippedSrcRect.width - 1 do
      begin
        if PByte(MaskLine)^ < 128 then
          Move(SrcLine^, DstLine^, 3);

        SrcLine := pointer(integer(SrcLine) + 3);
        DstLine := pointer(integer(DstLine) + 3);
        MaskLine := pointer(integer(MaskLine) + 1);
      end;
    end;
end;

class procedure TGUITools.CopyRectangle(ABuffer, ABitmap: TBitmap; SrcPoint, DstPoint: T2DIntVector; Width, Height: integer; ClipRect: T2DIntRect);
var
  BufferRect, BitmapRect: T2DIntRect;
  SrcRect, DstRect: T2DIntRect;
  ClippedSrcRect, ClippedDstRect: T2DIntRect;
  Offset: T2DIntVector;
  y: Integer;
  SrcLine: Pointer;
  DstLine: Pointer;
begin
  if (ABuffer.PixelFormat <> pf24bit) or (ABitmap.PixelFormat <> pf24bit) then
    raise exception.create('TSpkGUITools.CopyRoundCorner: Tylko 24-bitowe bitmapy s¹ akceptowane!');

// Sprawdzanie poprawnoœci
  if (Width < 1) or (Height < 1) then
    exit;

  if (ABuffer.width = 0) or (ABuffer.height = 0) or (ABitmap.width = 0) or (ABitmap.height = 0) then
    exit;

// Przycinamy Ÿród³owy rect do obszaru Ÿród³owej bitmapy
  BufferRect := T2DIntRect.create(0, 0, ABuffer.width - 1, ABuffer.height - 1);
  if not (BufferRect.IntersectsWith(T2DIntRect.create(SrcPoint.x, SrcPoint.y, SrcPoint.x + Width - 1, SrcPoint.y + Height - 1), SrcRect)) then
    exit;

// Przycinamy docelowy rect do obszaru docelowej bitmapy
  BitmapRect := T2DIntRect.create(0, 0, ABitmap.width - 1, ABitmap.height - 1);
  if not (BitmapRect.IntersectsWith(T2DIntRect.create(DstPoint.x, DstPoint.y, DstPoint.x + Width - 1, DstPoint.y + Height - 1), DstRect)) then
    exit;

// Dodatkowo przycinamy docelowy rect
  if not (DstRect.IntersectsWith(ClipRect, ClippedDstRect)) then
    Exit;

// Liczymy offset Ÿród³owego do docelowego recta
  Offset := DstPoint - SrcPoint;

// Sprawdzamy, czy na³o¿one na siebie recty: Ÿród³owy i docelowy przesuniêty o
// offset maj¹ jak¹œ czêœæ wspóln¹
  if not (SrcRect.IntersectsWith(ClippedDstRect - Offset, ClippedSrcRect)) then
    exit;

// Jeœli jest cokolwiek do przetworzenia, wykonaj operacjê
  if (ClippedSrcRect.left <= ClippedSrcRect.right) and (ClippedSrcRect.top <= ClippedSrcRect.bottom) then
    for y := ClippedSrcRect.top to ClippedSrcRect.bottom do
    begin
      SrcLine := ABuffer.ScanLine[y];
      DstLine := ABitmap.ScanLine[y + Offset.y];

      Move(pointer(integer(SrcLine) + 3 * ClippedSrcRect.left)^, pointer(integer(DstLine) + 3 * (ClippedSrcRect.left + Offset.x))^, 3 * ClippedSrcRect.Width);
    end;
end;

class procedure TGUITools.CopyRoundCorner(ABuffer: TBitmap; ABitmap: TBitmap; SrcPoint, DstPoint: T2DIntVector; Radius: integer; CornerPos: TCornerPos; Convex: boolean);
var
  BufferRect, BitmapRect: T2DIntRect;
  OrgSrcRect, OrgDstRect: T2DIntRect;
  SrcRect: T2DIntRect;
  Offset: T2DIntVector;
  Center: T2DIntVector;
  y: Integer;
  SrcLine: Pointer;
  DstLine: Pointer;
  SrcPtr, DstPtr: PByte;
  x: Integer;
  Dist: double;
begin
  if (ABuffer.PixelFormat <> pf24bit) or (ABitmap.PixelFormat <> pf24bit) then
    raise exception.create('TSpkGUITools.CopyRoundCorner: Tylko 24-bitowe bitmapy s¹ akceptowane!');

// Sprawdzanie poprawnoœci
  if Radius < 1 then
    exit;

  if (ABuffer.width = 0) or (ABuffer.height = 0) or (ABitmap.width = 0) or (ABitmap.height = 0) then
    exit;

  BufferRect := T2DIntRect.create(0, 0, ABuffer.width - 1, ABuffer.height - 1);
  if not (BufferRect.IntersectsWith(T2DIntRect.create(SrcPoint.x, SrcPoint.y, SrcPoint.x + Radius - 1, SrcPoint.y + Radius - 1), OrgSrcRect)) then
    exit;

  BitmapRect := T2DIntRect.create(0, 0, ABitmap.width - 1, ABitmap.height - 1);
  if not (BitmapRect.IntersectsWith(T2DIntRect.create(DstPoint.x, DstPoint.y, DstPoint.x + Radius - 1, DstPoint.y + Radius - 1), OrgDstRect)) then
    exit;

  Offset := DstPoint - SrcPoint;

  if not (OrgSrcRect.IntersectsWith(OrgDstRect - Offset, SrcRect)) then
    exit;

// Ustalamy pozycjê œrodka ³uku

  case CornerPos of
    cpLeftTop:
      Center := T2DIntVector.create(SrcPoint.x + Radius - 1, SrcPoint.y + Radius - 1);
    cpRightTop:
      Center := T2DIntVector.create(SrcPoint.x, SrcPoint.y + Radius - 1);
    cpLeftBottom:
      Center := T2DIntVector.Create(SrcPoint.x + Radius - 1, SrcPoint.y);
    cpRightBottom:
      Center := T2DIntVector.Create(SrcPoint.x, SrcPoint.y);
  end;

// Czy jest cokolwiek do przetworzenia?
  if Convex then
  begin
    if (SrcRect.left <= SrcRect.right) and (SrcRect.top <= SrcRect.bottom) then
      for y := SrcRect.top to SrcRect.bottom do
      begin
        SrcLine := ABuffer.ScanLine[y];
        DstLine := ABitmap.ScanLine[y + Offset.y];

        SrcPtr := pointer(integer(SrcLine) + 3 * SrcRect.left);
        DstPtr := pointer(integer(DstLine) + 3 * (SrcRect.left + Offset.x));
        for x := SrcRect.left to SrcRect.right do
        begin
          Dist := Center.DistanceTo(T2DVector.create(x, y));
          if Dist <= (Radius - 1) then
            Move(SrcPtr^, DstPtr^, 3);

          inc(SrcPtr, 3);
          inc(DstPtr, 3);
        end;
      end;
  end
  else
  begin
    if (SrcRect.left <= SrcRect.right) and (SrcRect.top <= SrcRect.bottom) then
      for y := SrcRect.top to SrcRect.bottom do
      begin
        SrcLine := ABuffer.ScanLine[y];
        DstLine := ABitmap.ScanLine[y + Offset.y];

        SrcPtr := pointer(integer(SrcLine) + 3 * SrcRect.left);
        DstPtr := pointer(integer(DstLine) + 3 * (SrcRect.left + Offset.x));
        for x := SrcRect.left to SrcRect.right do
        begin
          Dist := Center.DistanceTo(T2DVector.create(x, y));
          if Dist >= (Radius - 1) then
            Move(SrcPtr^, DstPtr^, 3);

          inc(SrcPtr, 3);
          inc(DstPtr, 3);
        end;
      end;
  end;
end;

class procedure TGUITools.DrawAARoundCorner(ABitmap: TBitmap; Point: T2DIntVector; Radius: integer; CornerPos: TCornerPos; Color: TColor);
var
  CornerRect: T2DIntRect;
  Center: T2DIntVector;
  Line: PByte;
  Ptr: PByte;
  colorR, colorG, colorB: byte;
  x, y: integer;
  RadiusDist: double;
  OrgCornerRect: T2DIntRect;
  BitmapRect: T2DIntRect;
begin
  if ABitmap.PixelFormat <> pf24bit then
    raise exception.create('TSpkGUITools.DrawAARoundCorner: Bitmapa musi byæ w trybie 24-bitowym!');

// Sprawdzamy poprawnoœæ
  if Radius < 1 then
    exit;
  if (ABitmap.width = 0) or (ABitmap.height = 0) then
    exit;

// ród³owy rect...
  OrgCornerRect := T2DIntRect.create(Point.x, Point.y, Point.x + Radius - 1, Point.y + Radius - 1);

// ...przycinamy do rozmiarów bitmapy
  BitmapRect := T2DIntRect.create(0, 0, ABitmap.width - 1, ABitmap.height - 1);
  if not (BitmapRect.intersectsWith(OrgCornerRect, CornerRect)) then
    exit;

// Jeœli nie ma czego rysowaæ, wychodzimy
  if (CornerRect.left > CornerRect.right) or (CornerRect.top > CornerRect.bottom) then
    exit;

// Szukamy œrodka ³uku - zale¿nie od rodzaju naro¿nika
  case CornerPos of
    cpLeftTop:
      Center := T2DIntVector.create(Point.x + Radius - 1, Point.y + Radius - 1);
    cpRightTop:
      Center := T2DIntVector.create(Point.x, Point.y + Radius - 1);
    cpLeftBottom:
      Center := T2DIntVector.Create(Point.x + Radius - 1, Point.y);
    cpRightBottom:
      Center := T2DIntVector.Create(Point.x, Point.y);
  end;

  Color := ColorToRGB(Color);

  colorR := GetRValue(Color);
  colorG := GetGValue(Color);
  colorB := GetBValue(Color);

  for y := CornerRect.top to CornerRect.bottom do
  begin
    Line := ABitmap.ScanLine[y];
    for x := CornerRect.left to CornerRect.right do
    begin
      RadiusDist := 1 - abs((Radius - 1) - Center.DistanceTo(T2DIntVector.create(x, y)));
      if RadiusDist > 0 then
      begin
        Ptr := pointer(integer(Line) + 3 * x);
        Ptr^ := round(Ptr^ + (colorB - Ptr^) * RadiusDist);
        inc(Ptr);
        Ptr^ := round(Ptr^ + (colorG - Ptr^) * RadiusDist);
        inc(Ptr);
        Ptr^ := round(Ptr^ + (colorR - Ptr^) * RadiusDist);
      end;
    end;
  end;
end;

class procedure TGUITools.DrawAARoundCorner(ABitmap: TBitmap; Point: T2DIntVector; Radius: integer; CornerPos: TCornerPos; Color: TColor; ClipRect: T2DIntRect);
var
  CornerRect: T2DIntRect;
  Center: T2DIntVector;
  Line: PByte;
  Ptr: PByte;
  colorR, colorG, colorB: byte;
  x, y: integer;
  RadiusDist: double;
  OrgCornerRect: T2DIntRect;
  UnClippedCornerRect: T2DIntRect;
  BitmapRect: T2DIntRect;
begin
  if ABitmap.PixelFormat <> pf24bit then
    raise exception.create('TSpkGUITools.DrawAARoundCorner: Bitmapa musi byæ w trybie 24-bitowym!');

// Sprawdzamy poprawnoœæ
  if Radius < 1 then
    exit;
  if (ABitmap.width = 0) or (ABitmap.height = 0) then
    exit;

// ród³owy rect...
  OrgCornerRect := T2DIntRect.create(Point.x, Point.y, Point.x + Radius - 1, Point.y + Radius - 1);

// ...przycinamy do rozmiarów bitmapy
  BitmapRect := T2DIntRect.create(0, 0, ABitmap.width - 1, ABitmap.height - 1);
  if not (BitmapRect.intersectsWith(OrgCornerRect, UnClippedCornerRect)) then
    exit;

// ClipRect
  if not (UnClippedCornerRect.IntersectsWith(ClipRect, CornerRect)) then
    exit;

// Jeœli nie ma czego rysowaæ, wychodzimy
  if (CornerRect.left > CornerRect.right) or (CornerRect.top > CornerRect.bottom) then
    exit;

// Szukamy œrodka ³uku - zale¿nie od rodzaju naro¿nika
  case CornerPos of
    cpLeftTop:
      Center := T2DIntVector.create(Point.x + Radius - 1, Point.y + Radius - 1);
    cpRightTop:
      Center := T2DIntVector.create(Point.x, Point.y + Radius - 1);
    cpLeftBottom:
      Center := T2DIntVector.Create(Point.x + Radius - 1, Point.y);
    cpRightBottom:
      Center := T2DIntVector.Create(Point.x, Point.y);
  end;

  Color := ColorToRGB(Color);

  colorR := GetRValue(Color);
  colorG := GetGValue(Color);
  colorB := GetBValue(Color);

  for y := CornerRect.top to CornerRect.bottom do
  begin
    Line := ABitmap.ScanLine[y];
    for x := CornerRect.left to CornerRect.right do
    begin
      RadiusDist := 1 - abs((Radius - 1) - Center.DistanceTo(T2DIntVector.create(x, y)));
      if RadiusDist > 0 then
      begin
        Ptr := pointer(integer(Line) + 3 * x);
        Ptr^ := round(Ptr^ + (colorB - Ptr^) * RadiusDist);
        inc(Ptr);
        Ptr^ := round(Ptr^ + (colorG - Ptr^) * RadiusDist);
        inc(Ptr);
        Ptr^ := round(Ptr^ + (colorR - Ptr^) * RadiusDist);
      end;
    end;
  end;
end;

class procedure TGUITools.DrawAARoundCorner(ACanvas: TCanvas; Point: T2DIntVector; Radius: integer; CornerPos: TCornerPos; Color: TColor);
var
  Center: T2DIntVector;
  OrgColor: TColor;
  x, y: integer;
  RadiusDist: double;
  CornerRect: T2DIntRect;
begin
// Sprawdzamy poprawnoœæ
  if Radius < 1 then
    exit;

// ród³owy rect...
  CornerRect := T2DIntRect.create(Point.x, Point.y, Point.x + Radius - 1, Point.y + Radius - 1);

// Szukamy œrodka ³uku - zale¿nie od rodzaju naro¿nika
  case CornerPos of
    cpLeftTop:
      Center := T2DIntVector.create(Point.x + Radius - 1, Point.y + Radius - 1);
    cpRightTop:
      Center := T2DIntVector.create(Point.x, Point.y + Radius - 1);
    cpLeftBottom:
      Center := T2DIntVector.Create(Point.x + Radius - 1, Point.y);
    cpRightBottom:
      Center := T2DIntVector.Create(Point.x, Point.y);
  end;

  Color := ColorToRGB(Color);

  for y := CornerRect.top to CornerRect.bottom do
  begin
    for x := CornerRect.left to CornerRect.right do
    begin
      RadiusDist := 1 - abs((Radius - 1) - Center.DistanceTo(T2DIntVector.create(x, y)));
      if RadiusDist > 0 then
      begin
        OrgColor := ACanvas.Pixels[x, y];
        ACanvas.Pixels[x, y] := TColorTools.Shade(OrgColor, Color, RadiusDist);
      end;
    end;
  end;
end;

class procedure TGUITools.DrawAARoundCorner(ACanvas: TCanvas; Point: T2DIntVector; Radius: integer; CornerPos: TCornerPos; Color: TColor; ClipRect: T2DIntRect);
var
  UseOrgClipRgn: boolean;
  ClipRgn: HRGN;
  OrgRgn: HRGN;
begin
// Zapamiêtywanie oryginalnego ClipRgn i ustawianie nowego
  SaveClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);

  ClipRgn := CreateRectRgn(ClipRect.left, ClipRect.Top, ClipRect.Right + 1, ClipRect.Bottom + 1);
  if UseOrgClipRgn then
    CombineRgn(ClipRgn, ClipRgn, OrgRgn, RGN_AND);

  SelectClipRgn(ACanvas.Handle, ClipRgn);

  DrawAARoundCorner(ACanvas, Point, Radius, CornerPos, Color);

// Przywracanie poprzedniego ClipRgn i usuwanie wykorzystanych regionów
  RestoreClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);
  DeleteObject(ClipRgn);
end;

class procedure TGUITools.DrawAARoundFrame(ABitmap: TBitmap; Rect: T2DIntRect; Radius: integer; Color: TColor; ClipRect: T2DIntRect);
begin
  if ABitmap.PixelFormat <> pf24bit then
    raise exception.create('TGUITools.DrawAARoundFrame: Bitmapa musi byæ w trybie 24-bitowym!');

  if (Radius < 1) then
    exit;

  if (Radius > Rect.width div 2) or (Radius > Rect.height div 2) then
    exit;

// DrawAARoundCorner jest zabezpieczony przed rysowaniem poza obszarem
  DrawAARoundCorner(ABitmap, T2DIntVector.create(Rect.left, Rect.top), Radius, cpLeftTop, Color, ClipRect);
  DrawAARoundCorner(ABitmap, T2DIntVector.create(Rect.right - Radius + 1, Rect.top), Radius, cpRightTop, Color, ClipRect);
  DrawAARoundCorner(ABitmap, T2DIntVector.create(Rect.left, Rect.bottom - Radius + 1), Radius, cpLeftBottom, Color, ClipRect);
  DrawAARoundCorner(ABitmap, T2DIntVector.create(Rect.Right - Radius + 1, Rect.Bottom - Radius + 1), Radius, cpRightBottom, Color, ClipRect);

  ABitmap.Canvas.Pen.color := Color;
  ABitmap.Canvas.pen.style := psSolid;

// Draw*Line s¹ zabezpieczone przed rysowaniem poza obszarem
  DrawVLine(ABitmap, Rect.left, Rect.top + Radius, Rect.bottom - Radius, Color, ClipRect);
  DrawVLine(ABitmap, Rect.right, Rect.top + Radius, Rect.bottom - Radius, Color, ClipRect);
  DrawHLine(ABitmap, Rect.left + Radius, Rect.right - Radius, Rect.top, Color, ClipRect);
  DrawHLine(ABitmap, Rect.left + Radius, Rect.right - Radius, Rect.bottom, Color, ClipRect);
end;

class procedure TGUITools.DrawAARoundFrame(ABitmap: TBitmap; Rect: T2DIntRect; Radius: integer; Color: TColor);
begin
  if ABitmap.PixelFormat <> pf24bit then
    raise exception.create('TGUITools.DrawAARoundFrame: Bitmapa musi byæ w trybie 24-bitowym!');

  if (Radius < 1) then
    exit;

  if (Radius > Rect.width div 2) or (Radius > Rect.height div 2) then
    exit;

// DrawAARoundCorner jest zabezpieczony przed rysowaniem poza obszarem
  DrawAARoundCorner(ABitmap, T2DIntVector.create(Rect.left, Rect.top), Radius, cpLeftTop, Color);
  DrawAARoundCorner(ABitmap, T2DIntVector.create(Rect.right - Radius + 1, Rect.top), Radius, cpRightTop, Color);
  DrawAARoundCorner(ABitmap, T2DIntVector.create(Rect.left, Rect.bottom - Radius + 1), Radius, cpLeftBottom, Color);
  DrawAARoundCorner(ABitmap, T2DIntVector.create(Rect.Right - Radius + 1, Rect.Bottom - Radius + 1), Radius, cpRightBottom, Color);

  ABitmap.canvas.Pen.color := Color;
  ABitmap.canvas.pen.style := psSolid;

// Draw*Line s¹ zabezpieczone przed rysowaniem poza obszarem
  DrawVLine(ABitmap, Rect.left, Rect.top + Radius, Rect.bottom - Radius, Color);
  DrawVLine(ABitmap, Rect.right, Rect.top + Radius, Rect.bottom - Radius, Color);
  DrawHLine(ABitmap, Rect.left + Radius, Rect.right - Radius, Rect.top, Color);
  DrawHLine(ABitmap, Rect.left + Radius, Rect.right - Radius, Rect.bottom, Color);
end;

class procedure TGUITools.DrawFitWText(ABitmap: TBitmap; x1, x2, y: integer; AText: string; TextColor: TColor; Align: TAlignment);
var
  tw: integer;
  s: string;
begin
  with ABitmap.Canvas do
  begin
    s := AText;
    tw := TextWidth(s);
     // Jeœli tekst siê zmieœci, rysujemy
    if tw <= (x2 - x1 + 1) then
      case Align of
        taLeftJustify:
          TextOut(x1, y, AText);
        taRightJustify:
          TextOut(x2 - tw + 1, y, AText);
        taCenter:
          TextOut(x1 + ((x2 - x1 - tw) div 2), y, AText);
      end
    else
    begin
      while (s <> '') and (tw > (x2 - x1 + 1)) do
      begin
        delete(s, length(s), 1);
        tw := TextWidth(s + '...');
      end;
      if tw <= (x2 - x1 + 1) then
        TextOut(x1, y, s + '...');
    end;
  end;
end;

class procedure TGUITools.DrawHLine(ACanvas: TCanvas; x1, x2, y: integer; Color: TColor);
var
  tmp: integer;
begin
  if x2 < x1 then
  begin
    tmp := x1;
    x1 := x2;
    x2 := tmp;
  end;

  ACanvas.pen.color := Color;
  ACanvas.moveto(x1, y);
  ACanvas.lineto(x2 + 1, y);
end;

class procedure TGUITools.DrawHLine(ACanvas: TCanvas; x1, x2, y: integer; Color: TColor; ClipRect: T2DIntRect);
var
  UseOrgClipRgn: boolean;
  ClipRgn: HRGN;
  OrgRgn: HRGN;
begin
// Zapamiêtywanie oryginalnego ClipRgn i ustawianie nowego
  SaveClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);

  ClipRgn := CreateRectRgn(ClipRect.left, ClipRect.Top, ClipRect.Right + 1, ClipRect.Bottom + 1);
  if UseOrgClipRgn then
    CombineRgn(ClipRgn, ClipRgn, OrgRgn, RGN_AND);

  SelectClipRgn(ACanvas.Handle, ClipRgn);

  DrawHLine(ACanvas, x1, x2, y, Color);

// Przywracanie poprzedniego ClipRgn i usuwanie wykorzystanych regionów
  RestoreClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);
  DeleteObject(ClipRgn);
end;

class procedure TGUITools.DrawImage(ABitmap: TBitmap; Imagelist: TImageList; ImageIndex: integer; Point: T2DIntVector; ClipRect: T2DIntRect);
begin
  DrawImage(ABitmap.Canvas, Imagelist, ImageIndex, Point, ClipRect);
end;

class procedure TGUITools.DrawImage(ABitmap: TBitmap; Imagelist: TImageList; ImageIndex: integer; Point: T2DIntVector);
begin
  DrawImage(ABitmap.Canvas, Imagelist, ImageIndex, Point);
end;

class procedure TGUITools.DrawImage(ACanvas: TCanvas; Imagelist: TImageList; ImageIndex: integer; Point: T2DIntVector; ClipRect: T2DIntRect);
var
  UseOrgClipRgn: Boolean;
  OrgRgn: HRGN;
  ClipRgn: HRGN;
begin
// Zapamiêtywanie oryginalnego ClipRgn i ustawianie nowego
  SaveClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);

  ClipRgn := CreateRectRgn(ClipRect.left, ClipRect.Top, ClipRect.Right + 1, ClipRect.Bottom + 1);
  if UseOrgClipRgn then
    CombineRgn(ClipRgn, ClipRgn, OrgRgn, RGN_AND);

  SelectClipRgn(ACanvas.Handle, ClipRgn);

  Imagelist.Draw(ACanvas, Point.x, Point.y, ImageIndex);

  RestoreClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);
  DeleteObject(ClipRgn);
end;

class procedure TGUITools.DrawMarkedText(ACanvas: TCanvas; x, y: integer; AText, AMarkPhrase: string; TextColor: TColor; ClipRect: T2DIntRect; CaseSensitive: boolean);
var
  UseOrgClipRgn: Boolean;
  OrgRgn: HRGN;
  ClipRgn: HRGN;
begin
// Zapamiêtywanie oryginalnego ClipRgn i ustawianie nowego
  SaveClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);

  ClipRgn := CreateRectRgn(ClipRect.left, ClipRect.Top, ClipRect.Right + 1, ClipRect.Bottom + 1);
  if UseOrgClipRgn then
    CombineRgn(ClipRgn, ClipRgn, OrgRgn, RGN_AND);

  SelectClipRgn(ACanvas.Handle, ClipRgn);

  DrawMarkedText(ACanvas, x, y, AText, AMarkPhrase, TextColor, CaseSensitive);

  RestoreClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);
  DeleteObject(ClipRgn);
end;

class procedure TGUITools.DrawMarkedText(ACanvas: TCanvas; x, y: integer; AText, AMarkPhrase: string; TextColor: TColor; CaseSensitive: boolean);
var
  DrawText: string;
  BaseText: string;
  MarkText: string;
  MarkPos: Integer;
  x1: integer;
  s: string;
  MarkTextLength: Integer;
begin
  DrawText := AText;
  if CaseSensitive then
  begin
    BaseText := AText;
    MarkText := AMarkPhrase;
  end
  else
  begin
    BaseText := AnsiUpperCase(AText);
    MarkText := AnsiUpperCase(AMarkPhrase);
  end;

  x1 := x;
  MarkTextLength := length(MarkText);

  ACanvas.Font.Color := TextColor;
  ACanvas.Brush.Style := bsClear;

  MarkPos := pos(MarkText, BaseText);
  while MarkPos > 0 do
  begin
    if MarkPos > 1 then
    begin
         // Rysowanie tekstu przed wyró¿nionym
      ACanvas.Font.Style := ACanvas.Font.Style - [fsBold];
      s := copy(DrawText, 1, MarkPos - 1);

      ACanvas.TextOut(x1, y, s);
      inc(x1, ACanvas.TextWidth(s) + 1);

      delete(DrawText, 1, MarkPos - 1);
      delete(BaseText, 1, MarkPos - 1);
    end;

      // Rysowanie wyró¿nionego tekstu
    ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
    s := copy(DrawText, 1, MarkTextLength);

    ACanvas.TextOut(x1, y, s);
    inc(x1, ACanvas.TextWidth(s) + 1);

    delete(DrawText, 1, MarkTextLength);
    delete(BaseText, 1, MarkTextLength);

    MarkPos := pos(MarkText, BaseText);
  end;

  if Length(BaseText) > 0 then
  begin
    ACanvas.Font.Style := ACanvas.Font.Style - [fsBold];
    ACanvas.TextOut(x1, y, DrawText);
  end;
end;

class procedure TGUITools.DrawImage(ACanvas: TCanvas; Imagelist: TImageList; ImageIndex: integer; Point: T2DIntVector);
begin
  Imagelist.Draw(ACanvas, Point.x, Point.y, ImageIndex);
end;

class procedure TGUITools.DrawOutlinedText(ACanvas: TCanvas; x, y: integer; AText: string; TextColor, OutlineColor: TColor);
begin
  with ACanvas do
  begin
    brush.style := bsClear;
    font.color := OutlineColor;
    TextOut(x - 1, y - 1, AText);
    TextOut(x, y - 1, AText);
    TextOut(x + 1, y - 1, AText);
    TextOut(x - 1, y, AText);
    TextOut(x + 1, y, AText);
    TextOut(x - 1, y + 1, AText);
    TextOut(x, y + 1, AText);
    TextOut(x + 1, y + 1, AText);

    font.color := TextColor;
    TextOut(x, y, AText);
  end;
end;

class procedure TGUITools.DrawOutlinedText(ACanvas: TCanvas; x, y: integer; AText: string; TextColor, OutlineColor: TColor; ClipRect: T2DIntRect);
var
  WinAPIClipRect: TRect;
begin
  WinAPIClipRect := ClipRect.ForWinAPI;
  with ACanvas do
  begin
    brush.style := bsClear;
    font.color := OutlineColor;
    TextRect(WinAPIClipRect, x - 1, y - 1, AText);
    TextRect(WinAPIClipRect, x, y - 1, AText);
    TextRect(WinAPIClipRect, x + 1, y - 1, AText);
    TextRect(WinAPIClipRect, x - 1, y, AText);
    TextRect(WinAPIClipRect, x + 1, y, AText);
    TextRect(WinAPIClipRect, x - 1, y + 1, AText);
    TextRect(WinAPIClipRect, x, y + 1, AText);
    TextRect(WinAPIClipRect, x + 1, y + 1, AText);

    font.color := TextColor;
    TextRect(WinAPIClipRect, x, y, AText);
  end;
end;

class procedure TGUITools.DrawHLine(ABitmap: TBitmap; x1, x2, y: integer; Color: TColor);
var
  LineRect: T2DIntRect;
  BitmapRect: T2DIntRect;
  tmp: Integer;
begin
  if ABitmap.PixelFormat <> pf24bit then
    raise exception.create('TGUITools.DrawHLine: Bitmapa musi byæ w trybie 24-bitowym!');

  if x2 < x1 then
  begin
    tmp := x1;
    x1 := x2;
    x2 := tmp;
  end;

  BitmapRect := T2DIntRect.create(0, 0, ABitmap.width - 1, ABitmap.height - 1);
  if not (BitmapRect.IntersectsWith(T2DIntRect.create(x1, y, x2, y), LineRect)) then
    exit;

  ABitmap.canvas.pen.color := Color;
  ABitmap.canvas.pen.style := psSolid;
  ABitmap.canvas.moveto(LineRect.left, LineRect.Top);
  ABitmap.canvas.lineto(LineRect.right + 1, LineRect.top);
end;

class procedure TGUITools.DrawHLine(ABitmap: TBitmap; x1, x2, y: integer; Color: TColor; ClipRect: T2DIntRect);
var
  OrgLineRect: T2DIntRect;
  LineRect: T2DIntRect;
  BitmapRect: T2DIntRect;
  tmp: Integer;
begin
  if ABitmap.PixelFormat <> pf24bit then
    raise exception.create('TGUITools.DrawHLine: Bitmapa musi byæ w trybie 24-bitowym!');

  if x2 < x1 then
  begin
    tmp := x1;
    x1 := x2;
    x2 := tmp;
  end;

  BitmapRect := T2DIntRect.create(0, 0, ABitmap.width - 1, ABitmap.height - 1);
  if not (BitmapRect.IntersectsWith(T2DIntRect.create(x1, y, x2, y), OrgLineRect)) then
    exit;

  if not (OrgLineRect.IntersectsWith(ClipRect, LineRect)) then
    exit;

  ABitmap.canvas.pen.color := Color;
  ABitmap.canvas.pen.style := psSolid;
  ABitmap.canvas.moveto(LineRect.left, LineRect.Top);
  ABitmap.canvas.lineto(LineRect.right + 1, LineRect.top);
end;

class procedure TGUITools.DrawOutlinedText(ABitmap: TBitmap; x, y: integer; AText: string; TextColor, OutlineColor: TColor; ClipRect: T2DIntRect);
var
  WinAPIClipRect: TRect;
begin
  WinAPIClipRect := ClipRect.ForWinAPI;
  with ABitmap.canvas do
  begin
    brush.style := bsClear;
    font.color := OutlineColor;
    TextRect(WinAPIClipRect, x - 1, y - 1, AText);
    TextRect(WinAPIClipRect, x, y - 1, AText);
    TextRect(WinAPIClipRect, x + 1, y - 1, AText);
    TextRect(WinAPIClipRect, x - 1, y, AText);
    TextRect(WinAPIClipRect, x + 1, y, AText);
    TextRect(WinAPIClipRect, x - 1, y + 1, AText);
    TextRect(WinAPIClipRect, x, y + 1, AText);
    TextRect(WinAPIClipRect, x + 1, y + 1, AText);

    font.color := TextColor;
    TextRect(WinAPIClipRect, x, y, AText);
  end;
end;

class procedure TGUITools.DrawRegion(ACanvas: TCanvas; Region: HRGN; Rect: T2DIntRect; ColorFrom, ColorTo: TColor; GradientKind: TBackgroundKind);
var
  UseOrgClipRgn: Boolean;
  OrgRgn: HRGN;
begin
// Zapamiêtywanie oryginalnego ClipRgn i ustawianie nowego
  SaveClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);
  SelectClipRgn(ACanvas.Handle, Region);

  FillGradientRectangle(ACanvas, Rect, ColorFrom, ColorTo, GradientKind);

  RestoreClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);
end;

class procedure TGUITools.DrawRegion(ACanvas: TCanvas; Region: HRGN; Rect: T2DIntRect; ColorFrom, ColorTo: TColor; GradientKind: TBackgroundKind; ClipRect: T2DIntRect);
var
  UseOrgClipRgn: boolean;
  ClipRgn: HRGN;
  OrgRgn: HRGN;
begin
// Zapamiêtywanie oryginalnego ClipRgn i ustawianie nowego
  SaveClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);

  ClipRgn := CreateRectRgn(ClipRect.left, ClipRect.Top, ClipRect.Right + 1, ClipRect.Bottom + 1);
  if UseOrgClipRgn then
    CombineRgn(ClipRgn, ClipRgn, OrgRgn, RGN_AND);

  SelectClipRgn(ACanvas.Handle, ClipRgn);

  DrawRegion(ACanvas, Region, Rect, ColorFrom, ColorTo, GradientKind);

// Przywracanie poprzedniego ClipRgn i usuwanie wykorzystanych regionów
  RestoreClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);
  DeleteObject(ClipRgn);
end;

class procedure TGUITools.DrawRoundRect(ACanvas: TCanvas; Rect: T2DIntRect; Radius: integer; ColorFrom, ColorTo: TColor; GradientKind: TBackgroundKind; ClipRect: T2DIntRect; LeftTopRound, RightTopRound, LeftBottomRound, RightBottomRound: boolean);
var
  UseOrgClipRgn: boolean;
  ClipRgn: HRGN;
  OrgRgn: HRGN;
begin
// Zapamiêtywanie oryginalnego ClipRgn i ustawianie nowego
  SaveClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);

  ClipRgn := CreateRectRgn(ClipRect.left, ClipRect.Top, ClipRect.Right + 1, ClipRect.Bottom + 1);
  if UseOrgClipRgn then
    CombineRgn(ClipRgn, ClipRgn, OrgRgn, RGN_AND);

  SelectClipRgn(ACanvas.Handle, ClipRgn);

  DrawRoundRect(ACanvas, Rect, Radius, ColorFrom, ColorTo, GradientKind, LeftTopRound, RightTopRound, LeftBottomRound, RightBottomRound);

// Przywracanie poprzedniego ClipRgn i usuwanie wykorzystanych regionów
  RestoreClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);
  DeleteObject(ClipRgn);
end;

class procedure TGUITools.DrawText(ACanvas: TCanvas; x, y: integer; AText: string; TextColor: TColor);
begin
  with ACanvas do
  begin
    brush.style := bsClear;
    font.color := TextColor;
    TextOut(x, y, AText);
  end;
end;

class procedure TGUITools.DrawText(ACanvas: TCanvas; x, y: integer; AText: string; TextColor: TColor; ClipRect: T2DIntRect);
var
  WinAPIClipRect: TRect;
begin
  WinAPIClipRect := ClipRect.ForWinAPI;
  with ACanvas do
  begin
    brush.style := bsClear;
    font.color := TextColor;
    TextRect(WinAPIClipRect, x, y, AText);
  end;
end;

class procedure TGUITools.DrawRoundRect(ACanvas: TCanvas; Rect: T2DIntRect; Radius: integer; ColorFrom, ColorTo: TColor; GradientKind: TBackgroundKind; LeftTopRound, RightTopRound, LeftBottomRound, RightBottomRound: boolean);
var
  RoundRgn: HRGN;
  TmpRgn: HRGN;
  OrgRgn: HRGN;
  UseOrgClipRgn: Boolean;
begin
  if Radius < 1 then
    exit;

  if (Radius * 2 > Rect.width) or (Radius * 2 > Rect.height) then
    exit;

// Zapamiêtywanie oryginalnego ClipRgn i ustawianie nowego
  SaveClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);

  if not (LeftTopRound) and not (RightTopRound) and not (LeftBottomRound) and not (RightBottomRound) then
  begin
    RoundRgn := CreateRectRgn(Rect.Left, Rect.Top, Rect.Right + 1, Rect.Bottom + 1);
  end
  else
  begin
    RoundRgn := CreateRoundRectRgn(Rect.Left, Rect.Top, Rect.Right + 2, Rect.Bottom + 2, Radius * 2, Radius * 2);

    if not (LeftTopRound) then
    begin
      TmpRgn := CreateRectRgn(Rect.left, Rect.Top, Rect.left + Radius, Rect.Top + Radius);
      CombineRgn(RoundRgn, RoundRgn, TmpRgn, RGN_OR);
      DeleteObject(TmpRgn);
    end;

    if not (RightTopRound) then
    begin
      TmpRgn := CreateRectRgn(Rect.right - Radius + 1, Rect.Top, Rect.Right + 1, Rect.Top + Radius);
      CombineRgn(RoundRgn, RoundRgn, TmpRgn, RGN_OR);
      DeleteObject(TmpRgn);
    end;

    if not (LeftBottomRound) then
    begin
      TmpRgn := CreateRectRgn(Rect.left, Rect.Bottom - Radius + 1, Rect.Left + Radius, Rect.Bottom + 1);
      CombineRgn(RoundRgn, RoundRgn, TmpRgn, RGN_OR);
      DeleteObject(TmpRgn);
    end;

    if not (RightBottomRound) then
    begin
      TmpRgn := CreateRectRgn(Rect.right - Radius + 1, Rect.Bottom - Radius + 1, Rect.Right + 1, Rect.Bottom + 1);
      CombineRgn(RoundRgn, RoundRgn, TmpRgn, RGN_OR);
      DeleteObject(TmpRgn);
    end;
  end;

  if UseOrgClipRgn then
    CombineRgn(RoundRgn, RoundRgn, OrgRgn, RGN_AND);

  SelectClipRgn(ACanvas.Handle, RoundRgn);

  ColorFrom := ColorToRGB(ColorFrom);
  ColorTo := ColorToRGB(ColorTo);

  FillGradientRectangle(ACanvas, Rect, ColorFrom, ColorTo, GradientKind);

// Przywracanie poprzedniego ClipRgn i usuwanie wykorzystanych regionów
  RestoreClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);
  DeleteObject(RoundRgn);
end;

class procedure TGUITools.DrawOutlinedText(ABitmap: TBitmap; x, y: integer; AText: string; TextColor, OutlineColor: TColor);
begin
  with ABitmap.canvas do
  begin
    brush.style := bsClear;
    font.color := OutlineColor;
    TextOut(x - 1, y - 1, AText);
    TextOut(x, y - 1, AText);
    TextOut(x + 1, y - 1, AText);
    TextOut(x - 1, y, AText);
    TextOut(x + 1, y, AText);
    TextOut(x - 1, y + 1, AText);
    TextOut(x, y + 1, AText);
    TextOut(x + 1, y + 1, AText);

    font.color := TextColor;
    TextOut(x, y, AText);
  end;
end;

class procedure TGUITools.DrawText(ABitmap: TBitmap; x, y: integer; AText: string; TextColor: TColor; ClipRect: T2DIntRect);
var
  WinAPIClipRect: TRect;
begin
  WinAPIClipRect := ClipRect.ForWinAPI;
  with ABitmap.canvas do
  begin
    brush.style := bsClear;
    font.color := TextColor;
    TextRect(WinAPIClipRect, x, y, AText);
  end;
end;

class procedure TGUITools.DrawFitWOutlinedText(ABitmap: TBitmap; x1, x2, y: integer; AText: string; TextColor, OutlineColor: TColor; Align: TAlignment);
var
  tw: integer;
  s: string;
begin
  with ABitmap.Canvas do
  begin
    s := AText;
    tw := TextWidth(s) + 2;
     // Jeœli tekst siê zmieœci, rysujemy
    if tw <= (x2 - x1 + 1) then
      case Align of
        taLeftJustify:
          TGUITools.DrawOutlinedText(ABitmap, x1, y, AText, TextColor, OutlineColor);
        taRightJustify:
          TGUITools.DrawOutlinedText(ABitmap, x2 - tw + 1, y, AText, TextColor, OutlineColor);
        taCenter:
          TGUITools.DrawOutlinedText(ABitmap, x1 + ((x2 - x1 - tw) div 2), y, AText, TextColor, OutlineColor);
      end
    else
    begin
      while (s <> '') and (tw > (x2 - x1 + 1)) do
      begin
        delete(s, length(s), 1);
        tw := TextWidth(s + '...') + 2;
      end;
      if tw <= (x2 - x1 + 1) then
        TGUITools.DrawOutlinedText(ABitmap, x1, y, s + '...', TextColor, OutlineColor);
    end;
  end;
end;

class procedure TGUITools.DrawFitWOutlinedText(ACanvas: TCanvas; x1, x2, y: integer; AText: string; TextColor, OutlineColor: TColor; Align: TAlignment);
var
  tw: integer;
  s: string;
begin
  with ACanvas do
  begin
    s := AText;
    tw := TextWidth(s) + 2;
     // Jeœli tekst siê zmieœci, rysujemy
    if tw <= (x2 - x1 + 1) then
      case Align of
        taLeftJustify:
          TGUITools.DrawOutlinedText(ACanvas, x1, y, AText, TextColor, OutlineColor);
        taRightJustify:
          TGUITools.DrawOutlinedText(ACanvas, x2 - tw + 1, y, AText, TextColor, OutlineColor);
        taCenter:
          TGUITools.DrawOutlinedText(ACanvas, x1 + ((x2 - x1 - tw) div 2), y, AText, TextColor, OutlineColor);
      end
    else
    begin
      while (s <> '') and (tw > (x2 - x1 + 1)) do
      begin
        delete(s, length(s), 1);
        tw := TextWidth(s + '...') + 2;
      end;
      if tw <= (x2 - x1 + 1) then
        TGUITools.DrawOutlinedText(ACanvas, x1, y, s + '...', TextColor, OutlineColor);
    end;
  end;
end;

class procedure TGUITools.FillGradientRectangle(ACanvas: TCanvas; Rect: T2DIntRect; ColorFrom: TColor; ColorTo: TColor; GradientKind: TBackgroundKind);
var
  Mesh: array of _GRADIENT_RECT;
  GradientVertice: array of _TRIVERTEX;
  ConcaveColor: TColor;
begin
  case GradientKind of
    bkSolid:
      begin
        ACanvas.brush.color := ColorFrom;
        ACanvas.fillrect(Rect.ForWinAPI);
      end;
    bkVerticalGradient, bkHorizontalGradient:
      begin
        setlength(GradientVertice, 2);
        with GradientVertice[0] do
        begin
          x := Rect.left;
          y := Rect.top;
          Red := GetRValue(ColorFrom) shl 8;
          Green := GetGValue(ColorFrom) shl 8;
          Blue := GetBValue(ColorFrom) shl 8;
          Alpha := 255 shl 8;
        end;
        with GradientVertice[1] do
        begin
          x := Rect.Right + 1;
          y := Rect.bottom + 1;
          Red := GetRValue(ColorTo) shl 8;
          Green := GetGValue(ColorTo) shl 8;
          Blue := GetBValue(ColorTo) shl 8;
          Alpha := 255 shl 8;
        end;
        setlength(Mesh, 1);
        Mesh[0].UpperLeft := 0;
        Mesh[0].LowerRight := 1;
        if GradientKind = bkVerticalGradient then
          GradientFill(ACanvas.Handle, @GradientVertice[0], 2, @Mesh[0], 1, GRADIENT_FILL_RECT_V)
        else
          GradientFill(ACanvas.Handle, @GradientVertice[0], 2, @Mesh[0], 1, GRADIENT_FILL_RECT_H);
      end;
    bkConcave:
      begin
        ConcaveColor := TColorTools.Brighten(ColorFrom, 20);

        setlength(GradientVertice, 4);
        with GradientVertice[0] do
        begin
          x := Rect.left;
          y := Rect.top;
          Red := GetRValue(ColorFrom) shl 8;
          Green := GetGValue(ColorFrom) shl 8;
          Blue := GetBValue(ColorFrom) shl 8;
          Alpha := 255 shl 8;
        end;
        with GradientVertice[1] do
        begin
          x := Rect.Right + 1;
          y := Rect.Top + (Rect.height) div 4;
          Red := GetRValue(ConcaveColor) shl 8;
          Green := GetGValue(ConcaveColor) shl 8;
          Blue := GetBValue(ConcaveColor) shl 8;
          Alpha := 255 shl 8;
        end;
        with GradientVertice[2] do
        begin
          x := Rect.left;
          y := Rect.Top + (Rect.height) div 4;
          Red := GetRValue(ColorTo) shl 8;
          Green := GetGValue(ColorTo) shl 8;
          Blue := GetBValue(ColorTo) shl 8;
          Alpha := 255 shl 8;
        end;
        with GradientVertice[3] do
        begin
          x := Rect.Right + 1;
          y := Rect.bottom + 1;
          Red := GetRValue(ColorFrom) shl 8;
          Green := GetGValue(ColorFrom) shl 8;
          Blue := GetBValue(ColorFrom) shl 8;
          Alpha := 255 shl 8;
        end;
        setlength(Mesh, 2);
        Mesh[0].UpperLeft := 0;
        Mesh[0].LowerRight := 1;
        Mesh[1].UpperLeft := 2;
        Mesh[1].LowerRight := 3;
        GradientFill(ACanvas.Handle, @GradientVertice[0], 4, @Mesh[0], 2, GRADIENT_FILL_RECT_V);
      end;
  end;
end;

class procedure TGUITools.DrawFitWText(ACanvas: TCanvas; x1, x2, y: integer; AText: string; TextColor: TColor; Align: TAlignment);
var
  tw: integer;
  s: string;
begin
  with ACanvas do
  begin
    s := AText;
    tw := TextWidth(s);
     // Jeœli tekst siê zmieœci, rysujemy
    if tw <= (x2 - x1 + 1) then
      case Align of
        taLeftJustify:
          TextOut(x1, y, AText);
        taRightJustify:
          TextOut(x2 - tw + 1, y, AText);
        taCenter:
          TextOut(x1 + ((x2 - x1 - tw) div 2), y, AText);
      end
    else
    begin
      while (s <> '') and (tw > (x2 - x1 + 1)) do
      begin
        delete(s, length(s), 1);
        tw := TextWidth(s + '...');
      end;
      if tw <= (x2 - x1 + 1) then
        TextOut(x1, y, s + '...');
    end;
  end;
end;

class procedure TGUITools.RenderBackground(ABuffer: TBitmap; Rect: T2DIntRect; Color1, Color2: TColor; BackgroundKind: TBackgroundKind);
var
  TempRect: T2DIntRect;
begin
  if ABuffer.PixelFormat <> pf24bit then
    raise exception.create('TGUITools.RenderBackground: Bitmapa musi byæ w trybie 24-bitowym!');
  if (Rect.left > Rect.right) or (Rect.top > Rect.bottom) then
    exit;

// Zarówno metoda FillRect jak i WinAPI'owe rysowanie gradientów jest
// zabezpieczone przed rysowaniem poza obszarem p³ótna.
  case BackgroundKind of
    bkSolid:
      begin
        ABuffer.Canvas.brush.Color := Color1;
        ABuffer.Canvas.brush.style := bsSolid;
        ABuffer.Canvas.Fillrect(Rect.ForWinAPI);
      end;
    bkVerticalGradient:
      begin
        TGradientTools.VGradient(ABuffer.canvas, Color1, Color2, Rect.ForWinAPI);
      end;
    bkHorizontalGradient:
      begin
        TGradientTools.HGradient(ABuffer.canvas, Color1, Color2, Rect.ForWinAPI);
      end;
    bkConcave:
      begin
        TempRect := T2DIntRect.create(Rect.Left, Rect.top, Rect.right, Rect.Top + (Rect.bottom - Rect.top) div 4);
        TGradientTools.VGradient(ABuffer.Canvas, Color1, TColorTools.Shade(Color1, Color2, 20), TempRect.ForWinAPI);

        TempRect := T2DIntRect.create(Rect.Left, Rect.top + (Rect.bottom - Rect.top) div 4 + 1, Rect.right, Rect.bottom);
        TGradientTools.VGradient(ABuffer.Canvas, Color2, Color1, TempRect.ForWinAPI);
      end;
  end;

end;

class procedure TGUITools.RestoreClipRgn(DC: HDC; OrgRgnExists: boolean; var OrgRgn: HRGN);
begin
  if OrgRgnExists then
    SelectClipRgn(DC, OrgRgn)
  else
    SelectClipRgn(DC, 0);
  DeleteObject(OrgRgn);
end;

class procedure TGUITools.SaveClipRgn(DC: HDC; var OrgRgnExists: boolean; var OrgRgn: HRGN);
var
  i: integer;
begin
  OrgRgn := CreateRectRgn(0, 0, 1, 1);
  i := GetClipRgn(DC, OrgRgn);
  OrgRgnExists := (i = 1);
end;

class procedure TGUITools.DrawText(ABitmap: TBitmap; x, y: integer; AText: string; TextColor: TColor);
begin
  with ABitmap.canvas do
  begin
    brush.style := bsClear;
    font.color := TextColor;
    TextOut(x, y, AText);
  end;
end;

class procedure TGUITools.DrawVLine(ABitmap: TBitmap; x, y1, y2: integer; Color: TColor);
var
  LineRect: T2DIntRect;
  BitmapRect: T2DIntRect;
  tmp: Integer;
begin
  if ABitmap.PixelFormat <> pf24bit then
    raise exception.create('TGUITools.DrawHLine: Bitmapa musi byæ w trybie 24-bitowym!');

  if y2 < y1 then
  begin
    tmp := y1;
    y1 := y2;
    y2 := tmp;
  end;

  BitmapRect := T2DIntRect.create(0, 0, ABitmap.width - 1, ABitmap.height - 1);
  if not (BitmapRect.IntersectsWith(T2DIntRect.create(x, y1, x, y2), LineRect)) then
    exit;

  ABitmap.canvas.pen.color := Color;
  ABitmap.canvas.pen.style := psSolid;
  ABitmap.canvas.moveto(LineRect.left, LineRect.Top);
  ABitmap.canvas.lineto(LineRect.left, LineRect.bottom + 1);
end;

class procedure TGUITools.DrawVLine(ABitmap: TBitmap; x, y1, y2: integer; Color: TColor; ClipRect: T2DIntRect);
var
  OrgLineRect: T2DIntRect;
  LineRect: T2DIntRect;
  BitmapRect: T2DIntRect;
  tmp: Integer;
begin
  if ABitmap.PixelFormat <> pf24bit then
    raise exception.create('TGUITools.DrawHLine: Bitmapa musi byæ w trybie 24-bitowym!');

  if y2 < y1 then
  begin
    tmp := y1;
    y1 := y2;
    y2 := tmp;
  end;

  BitmapRect := T2DIntRect.create(0, 0, ABitmap.width - 1, ABitmap.height - 1);
  if not (BitmapRect.IntersectsWith(T2DIntRect.create(x, y1, x, y2), OrgLineRect)) then
    exit;

  if not (OrgLineRect.IntersectsWith(ClipRect, LineRect)) then
    exit;

  ABitmap.canvas.pen.color := Color;
  ABitmap.canvas.pen.style := psSolid;
  ABitmap.canvas.moveto(LineRect.left, LineRect.Top);
  ABitmap.canvas.lineto(LineRect.left, LineRect.bottom + 1);
end;

class procedure TGUITools.DrawVLine(ACanvas: TCanvas; x, y1, y2: integer; Color: TColor);
var
  tmp: integer;
begin
  if y2 < y1 then
  begin
    tmp := y1;
    y1 := y2;
    y2 := tmp;
  end;

  ACanvas.pen.color := Color;
  ACanvas.moveto(x, y1);
  ACanvas.lineto(x, y2 + 1);
end;

class procedure TGUITools.DrawVLine(ACanvas: TCanvas; x, y1, y2: integer; Color: TColor; ClipRect: T2DIntRect);
var
  UseOrgClipRgn: boolean;
  ClipRgn: HRGN;
  OrgRgn: HRGN;
begin
// Zapamiêtywanie oryginalnego ClipRgn i ustawianie nowego
  SaveClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);

  ClipRgn := CreateRectRgn(ClipRect.left, ClipRect.Top, ClipRect.Right + 1, ClipRect.Bottom + 1);
  if UseOrgClipRgn then
    CombineRgn(ClipRgn, ClipRgn, OrgRgn, RGN_AND);

  SelectClipRgn(ACanvas.Handle, ClipRgn);

  DrawVLine(ACanvas, x, y1, y2, Color);

// Przywracanie poprzedniego ClipRgn i usuwanie wykorzystanych regionów
  RestoreClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);
  DeleteObject(ClipRgn);
end;

class procedure TGUITools.DrawAARoundFrame(ACanvas: TCanvas; Rect: T2DIntRect; Radius: integer; Color: TColor);
begin
  if (Radius < 1) then
    exit;

  if (Radius > Rect.width div 2) or (Radius > Rect.height div 2) then
    exit;

// DrawAARoundCorner jest zabezpieczony przed rysowaniem poza obszarem
  DrawAARoundCorner(ACanvas, T2DIntVector.create(Rect.left, Rect.top), Radius, cpLeftTop, Color);
  DrawAARoundCorner(ACanvas, T2DIntVector.create(Rect.right - Radius + 1, Rect.top), Radius, cpRightTop, Color);
  DrawAARoundCorner(ACanvas, T2DIntVector.create(Rect.left, Rect.bottom - Radius + 1), Radius, cpLeftBottom, Color);
  DrawAARoundCorner(ACanvas, T2DIntVector.create(Rect.Right - Radius + 1, Rect.Bottom - Radius + 1), Radius, cpRightBottom, Color);

  ACanvas.Pen.color := Color;
  ACanvas.pen.style := psSolid;

// Draw*Line s¹ zabezpieczone przed rysowaniem poza obszarem
  DrawVLine(ACanvas, Rect.left, Rect.top + Radius, Rect.bottom - Radius, Color);
  DrawVLine(ACanvas, Rect.right, Rect.top + Radius, Rect.bottom - Radius, Color);
  DrawHLine(ACanvas, Rect.left + Radius, Rect.right - Radius, Rect.top, Color);
  DrawHLine(ACanvas, Rect.left + Radius, Rect.right - Radius, Rect.bottom, Color);
end;

class procedure TGUITools.DrawAARoundFrame(ACanvas: TCanvas; Rect: T2DIntRect; Radius: integer; Color: TColor; ClipRect: T2DIntRect);
var
  UseOrgClipRgn: boolean;
  ClipRgn: HRGN;
  OrgRgn: HRGN;
begin
// Zapamiêtywanie oryginalnego ClipRgn i ustawianie nowego
  SaveClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);

  ClipRgn := CreateRectRgn(ClipRect.left, ClipRect.Top, ClipRect.Right + 1, ClipRect.Bottom + 1);
  if UseOrgClipRgn then
    CombineRgn(ClipRgn, ClipRgn, OrgRgn, RGN_AND);

  SelectClipRgn(ACanvas.Handle, ClipRgn);

  DrawAARoundFrame(ACanvas, Rect, Radius, Color);

// Przywracanie poprzedniego ClipRgn i usuwanie wykorzystanych regionów
  RestoreClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);
  DeleteObject(ClipRgn);
end;

class procedure TGUITools.DrawDisabledImage(ABitmap: TBitmap; Imagelist: TImageList; ImageIndex: integer; Point: T2DIntVector; ClipRect: T2DIntRect);
begin
  DrawDisabledImage(ABitmap.Canvas, Imagelist, ImageIndex, Point, ClipRect);
end;

class procedure TGUITools.DrawDisabledImage(ABitmap: TBitmap; Imagelist: TImageList; ImageIndex: integer; Point: T2DIntVector);
begin
  DrawDisabledImage(ABitmap.Canvas, Imagelist, ImageIndex, Point);
end;

class procedure TGUITools.DrawDisabledImage(ACanvas: TCanvas; Imagelist: TImageList; ImageIndex: integer; Point: T2DIntVector; ClipRect: T2DIntRect);
var
  UseOrgClipRgn: Boolean;
  OrgRgn: HRGN;
  ClipRgn: HRGN;
  DCStackPos: integer;
begin
// Zapamiêtywanie oryginalnego ClipRgn i ustawianie nowego
  SaveClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);

  ClipRgn := CreateRectRgn(ClipRect.left, ClipRect.Top, ClipRect.Right + 1, ClipRect.Bottom + 1);
  if UseOrgClipRgn then
    CombineRgn(ClipRgn, ClipRgn, OrgRgn, RGN_AND);

  SelectClipRgn(ACanvas.Handle, ClipRgn);

// Hack poprawiaj¹cy b³¹d w ImageList.Draw, który nie przywraca poprzedniego
// koloru czcionki dla p³ótna
  DCStackPos := SaveDC(ACanvas.Handle);
  Imagelist.Draw(ACanvas, Point.x, Point.y, ImageIndex, false);
  RestoreDC(ACanvas.Handle, DCStackPos);

  RestoreClipRgn(ACanvas.Handle, UseOrgClipRgn, OrgRgn);

  DeleteObject(ClipRgn);
end;

class procedure TGUITools.DrawDisabledImage(ACanvas: TCanvas; Imagelist: TImageList; ImageIndex: integer; Point: T2DIntVector);
var
  DCStackPos: integer;
begin
  DCStackPos := SaveDC(ACanvas.Handle);
  Imagelist.Draw(ACanvas, Point.x, Point.y, ImageIndex, false);
  RestoreDC(ACanvas.Handle, DCStackPos);
end;

end.

