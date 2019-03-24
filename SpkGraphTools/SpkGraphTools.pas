unit SpkGraphTools;

{$DEFINE SPKGRAPHTOOLS}

interface

uses Windows, Graphics, Classes, Math, Sysutils, Dialogs,
     SpkMath;

const NUM_ZERO = 0.00000001;

(*******************************************************************************
*                                                                              *
*                              Proste struktury                                *
*                                                                              *
*******************************************************************************)

type // WskaŸnik do tablicy TRGBTriple
     PRGBTripleArray = ^TRGBTripleArray;
     // Tablica TRGBTriple (u¿ywana podczas operacji ze ScanLine)
     TRGBTripleArray = array[word] of TRGBTriple;

type THSLTriple = record
                  H, S, L : extended;
                  end;

type // Typ u¿ywany podczas rysowania gradientów
     TRIVERTEX = packed record
                        x,y : DWORD;
                        Red,
                        Green,
                        Blue,
                        Alpha : Word;
                        end;

type // Rodzaj gradientu
     TGradientType = (gtVertical, gtHorizontal);
     // Rodzaj linii gradientowej (miejsce rozmycia)
     TGradientLineShade = (lsShadeStart, lsShadeEnds, lsShadeCenter, lsShadeEnd);
     // Rodzaj linii gradientowej (wypuk³oœæ)
     TGradient3dLine = (glRaised, glLowered);

(*******************************************************************************
*                                                                              *
*                      Nag³ówki dla zewnêtrznych funkcji                       *
*                                                                              *
*******************************************************************************)

function GradientFill(DC : hDC; pVertex : Pointer; dwNumVertex : DWORD; pMesh : Pointer; dwNumMesh, dwMode: DWORD) : DWord; stdcall; external 'msimg32.dll';

(*******************************************************************************
*                                                                              *
*                              Klasy narzêdziowe                               *
*                                                                              *
*******************************************************************************)

type TColorTools = class(TObject)
     private
     protected
     public
       class function Darken(kolor : TColor; percentage : byte) : TColor;
       class function Brighten(kolor : TColor; percentage : byte) : TColor;
       class function Shade(kol1,kol2 : TColor; percentage : byte) : TColor; overload;
       class function Shade(kol1,kol2 : TColor; Step : extended) : TColor; overload;
       class function AddColors(c1, c2 : TColor) : TColor;
       class function MultiplyColors(c1, c2 : TColor) : TColor;
       class function MultiplyColor(color : TColor; scalar : integer) : TColor; overload;
       class function MultiplyColor(color : TColor; scalar : extended) : TColor; overload;
       class function percent(min, pos, max : integer) : byte;
       class function RGB2HSL(ARGB : TRGBTriple) : THSLTriple;
       class function HSL2RGB(AHSL : THSLTriple) : TRGBTriple;
       class function RgbTripleToColor(ARgbTriple : TRGBTriple) : TColor;
       class function ColorToRgbTriple(AColor : TColor) : TRGBTriple;
       class function ColorToGrayscale(AColor : TColor) : TColor;
     end;

type TGradientTools = class(TObject)
     private
     protected
     public
       class procedure HGradient(canvas : TCanvas; cStart,cEnd : TColor; rect : T2DIntRect); overload;
       class procedure HGradient(canvas : TCanvas; cStart,cEnd : TColor; p1, p2 : TPoint); overload;
       class procedure HGradient(canvas : TCanvas; cStart,cEnd : TColor; x1,y1,x2,y2 : integer); overload;

       class procedure VGradient(canvas : TCanvas; cStart,cEnd : TColor; rect : T2DIntRect); overload;
       class procedure VGradient(canvas : TCanvas; cStart,cEnd : TColor; p1, p2 : TPoint); overload;
       class procedure VGradient(canvas : TCanvas; cStart,cEnd : TColor; x1,y1,x2,y2 : integer); overload;

       class procedure Gradient(canvas : TCanvas; cStart,cEnd : TColor; rect : T2DIntRect; GradientType : TGradientType); overload;
       class procedure Gradient(canvas : TCanvas; cStart,cEnd : TColor; p1, p2 : TPoint; GradientType : TGradientType); overload;
       class procedure Gradient(canvas : TCanvas; cStart,cEnd : TColor; x1,y1,x2,y2 : integer; GradientType : TGradientType); overload;

       class procedure HGradientLine(canvas : TCanvas; cBase, cShade : TColor; x1, x2 , y : integer; ShadeMode : TGradientLineShade);
       class procedure VGradientLine(canvas : TCanvas; cBase, cShade : TColor; x, y1 , y2 : integer; ShadeMode : TGradientLineShade);

       class procedure HGradient3dLine(canvas : TCanvas; x1,x2,y : integer; ShadeMode : TGradientLineShade; A3dKind : TGradient3dLine = glLowered);
       class procedure VGradient3dLine(canvas : TCanvas; x,y1,y2 : integer; ShadeMode : TGradientLineShade; A3dKind : TGradient3dLine = glLowered);
     end;

type TTextTools = class
     private
     protected
     public
       class procedure OutlinedText(Canvas : TCanvas; x, y : integer; text : string);
     end;

implementation

{ TColorTools }

class function TColorTools.Darken(kolor : TColor; percentage : byte) : TColor;

var r,g,b : byte;

begin
r:=round(GetRValue(ColorToRGB(kolor))*(100-percentage)/100);
g:=round(GetGValue(ColorToRGB(kolor))*(100-percentage)/100);
b:=round(GetBValue(ColorToRGB(kolor))*(100-percentage)/100);
result:=rgb(r,g,b);
end;

class function TColorTools.Brighten(kolor : TColor; percentage : byte) : TColor;

var r,g,b : byte;

begin
r:=round(GetRValue(ColorToRGB(kolor))+( (255-GetRValue(ColorToRGB(kolor)))*(percentage/100) ));
g:=round(GetGValue(ColorToRGB(kolor))+( (255-GetGValue(ColorToRGB(kolor)))*(percentage/100) ));
b:=round(GetBValue(ColorToRGB(kolor))+( (255-GetBValue(ColorToRGB(kolor)))*(percentage/100) ));
result:=rgb(r,g,b);
end;

class function TColorTools.Shade(kol1,kol2 : TColor; percentage : byte) : TColor;

var r,g,b : byte;

begin
r:=round(GetRValue(ColorToRGB(kol1))+( (GetRValue(ColorToRGB(kol2))-GetRValue(ColorToRGB(kol1)))*(percentage/100) ));
g:=round(GetGValue(ColorToRGB(kol1))+( (GetGValue(ColorToRGB(kol2))-GetGValue(ColorToRGB(kol1)))*(percentage/100) ));
b:=round(GetBValue(ColorToRGB(kol1))+( (GetBValue(ColorToRGB(kol2))-GetBValue(ColorToRGB(kol1)))*(percentage/100) ));
result:=rgb(r,g,b);
end;

class function TColorTools.Shade(kol1,kol2 : TColor; Step : extended) : TColor;

var r,g,b : byte;

begin
r:=round(GetRValue(ColorToRGB(kol1))+( (GetRValue(ColorToRGB(kol2))-GetRValue(ColorToRGB(kol1)))*(Step) ));
g:=round(GetGValue(ColorToRGB(kol1))+( (GetGValue(ColorToRGB(kol2))-GetGValue(ColorToRGB(kol1)))*(Step) ));
b:=round(GetBValue(ColorToRGB(kol1))+( (GetBValue(ColorToRGB(kol2))-GetBValue(ColorToRGB(kol1)))*(Step) ));
result:=rgb(r,g,b);
end;

class function TColorTools.AddColors(c1, c2 : TColor) : TColor;

begin
result:=rgb(max( 0,min( 255,GetRValue(c1)+GetRValue(c2) ) ),
            max( 0,min( 255,GetGValue(c1)+GetGValue(c2) ) ),
            max( 0,min( 255,GetBValue(c1)+GetBValue(c2) ) ));
end;

class function TColorTools.MultiplyColors(c1, c2 : TColor) : TColor;

begin
result:=rgb(max( 0,min( 255,GetRValue(c1)*GetRValue(c2) ) ),
            max( 0,min( 255,GetGValue(c1)*GetGValue(c2) ) ),
            max( 0,min( 255,GetBValue(c1)*GetBValue(c2) ) ));
end;

class function TColorTools.MultiplyColor(color : TColor; scalar : integer) : TColor;

begin
result:=rgb(max( 0,min( 255,GetRValue(color)*scalar ) ),
            max( 0,min( 255,GetGValue(color)*scalar ) ),
            max( 0,min( 255,GetBValue(color)*scalar ) ));
end;

class function TColorTools.MultiplyColor(color : TColor; scalar : extended) : TColor;

begin
result:=rgb(max( 0,min( 255,round(GetRValue(color)*scalar) ) ),
            max( 0,min( 255,round(GetGValue(color)*scalar) ) ),
            max( 0,min( 255,round(GetBValue(color)*scalar) ) ));
end;

class function TColorTools.Percent(min, pos, max : integer) : byte;

begin
if max=min then result:=max else
   result:=round((pos-min)*100/(max-min));
end;

{.$MESSAGE WARN 'Porównywanie liczb rzeczywistych? Trzeba poprawiæ'}
class function TColorTools.RGB2HSL(ARGB : TRGBTriple) : THSLTriple;

var RGBmin, RGBmax : extended;
    R, G, B : extended;
    H, S, L : extended;

begin
R:=ARGB.rgbtRed/255;
G:=ARGB.rgbtGreen/255;
B:=ARGB.rgbtBlue/255;

RGBmin:=min(R,min(G,B));
RGBmax:=max(R,min(G,B));

H:=0;
if RGBmax=RGBmin then
   begin
   // H jest nieoznaczone, ale przyjmijmy zero dla sensownoœci obliczeñ
   H:=0;
   end else
if (R=RGBmax) and (G>=B) then
   begin
   H:=(pi/3)*((G-B)/(RGBmax-RGBmin))+0;
   end else
if (R=RGBmax) and (G<B) then
   begin
   H:=(pi/3)*((G-B)/(RGBmax-RGBmin))+(2*pi);
   end else
if (G=RGBmax) then
   begin
   H:=(pi/3)*((B-R)/(RGBmax-RGBmin))+(2*pi/3);
   end else
if (B=RGBmax) then
   begin
   H:=(pi/3)*((R-G)/(RGBmax-RGBmin))+(4*pi/3);
   end;

L:=(RGBmax+RGBmin)/2;

S:=0;
if (L<NUM_ZERO) or (rgbMin=rgbMax) then
   begin
   S:=0;
   end else
if (L<=0.5) then
   begin
   S:=((RGBmax-RGBmin)/(2*L));
   end else
if (L>0.5) then
   begin
   S:=((RGBmax-RGBmin)/(2-2*L));
   end;

result.H:=H/(2*pi);
result.S:=S;
result.L:=L;
end;

class function TColorTools.HSL2RGB(AHSL : THSLTriple) : TRGBTriple;

var R, G, B : extended;
    TR, TG, TB : extended;
    Q, P : extended;

  function ProcessColor(Tc : extended) : extended;

  begin
  if (Tc<(1/6)) then
     result:=P+((Q-P)*6.0*Tc) else
  if (Tc<(1/2)) then
     result:=Q else
  if (Tc<(2/3)) then
     result:=P+((Q-P)*((2/3)-Tc)*6.0) else
     result:=P;
  end;

begin
if AHSL.S<NUM_ZERO then
   begin
   R:=AHSL.L;
   G:=AHSL.L;
   B:=AHSL.L;
   end else
       begin
       if (AHSL.L<0.5) then
          Q:=AHSL.L*(AHSL.S+1.0) else
          Q:=AHSL.L+AHSL.S-(AHSL.L*AHSL.S);

       P:=2.0*AHSL.L-Q;

       TR:=AHSL.H+(1/3);
       TG:=AHSL.H;
       TB:=AHSL.H-(1/3);

       if (TR<0) then TR:=TR+1 else
          if (TR>1) then TR:=TR-1;

       if (TG<0) then TG:=TG+1 else
          if (TG>1) then TG:=TG-1;

       if (TB<0) then TB:=TB+1 else
          if (TB>1) then TB:=TB-1;

       R:=ProcessColor(TR);
       G:=ProcessColor(TG);
       B:=ProcessColor(TB);
       end;

result.rgbtRed:=round(255*R);
result.rgbtGreen:=round(255*G);
result.rgbtBlue:=round(255*B);
end;

class function TColorTools.RgbTripleToColor(ARgbTriple : TRGBTriple) : TColor;

begin
result:=rgb(ARgbTriple.rgbtRed,ARgbTriple.rgbtGreen,ARgbTriple.rgbtBlue);
end;

class function TColorTools.ColorToGrayscale(AColor: TColor): TColor;

var avg : byte;

begin
avg:=(GetRValue(Acolor) + GetGValue(AColor) + GetBValue(AColor)) div 3;
result:=rgb(avg,avg,avg);
end;

class function TColorTools.ColorToRgbTriple(AColor : TColor) : TRGBTriple;

begin
result.rgbtRed:=GetRValue(AColor);
result.rgbtGreen:=GetGValue(AColor);
result.rgbtBlue:=GetBValue(AColor);
end;

{ TGradientTools }

class procedure TGradientTools.HGradient(canvas : TCanvas; cStart,cEnd : TColor; rect : T2DIntRect);

var vert : array[0..1] of TRIVERTEX;
    gRect : _GRADIENT_RECT;
    Col1,Col2 : TColor;

begin
Col1:=ColorToRGB(cStart);
Col2:=ColorToRGB(cEnd);
with vert[0] do
     begin
     x:=rect.left;
     y:=rect.top;
     Red:=GetRValue(Col1) shl 8;
     Green:=GetGValue(Col1) shl 8;
     Blue:=GetBValue(Col1) shl 8;
     Alpha:=0;
     end;

with vert[1] do
     begin
     x:=rect.right;
     y:=rect.bottom;
     Red:=GetRValue(Col2) shl 8;
     Green:=GetGValue(Col2) shl 8;
     Blue:=GetBValue(Col2) shl 8;
     Alpha:=0;
     end;

gRect.UpperLeft:=0;
gRect.LowerRight:=1;
GradientFill(canvas.Handle,@vert,2,@gRect,1,GRADIENT_FILL_RECT_H);
end;

class procedure TGradientTools.HGradient(canvas : TCanvas; cStart,cEnd : TColor; p1, p2 : TPoint);

begin
HGradient(canvas,cstart,cend,rect(p1.x,p1.y,p2.x,p2.y));
end;

class procedure TGradientTools.HGradient(canvas : TCanvas; cStart,cEnd : TColor; x1,y1,x2,y2 : integer);

begin
HGradient(canvas,cstart,cend,rect(x1,y1,x2,y2));
end;

class procedure TGradientTools.VGradient(canvas : TCanvas; cStart,cEnd : TColor; rect : T2DIntRect);

var vert : array[0..1] of TRIVERTEX;
    gRect : _GRADIENT_RECT;
    Col1,Col2 : TColor;

begin
Col1:=ColorToRGB(cStart);
Col2:=ColorToRGB(cEnd);
with vert[0] do
     begin
     x:=rect.left;
     y:=rect.top;
     Red:=GetRValue(Col1) shl 8;
     Green:=GetGValue(Col1) shl 8;
     Blue:=GetBValue(Col1) shl 8;
     Alpha:=0;
     end;

with vert[1] do
     begin
     x:=rect.right;
     y:=rect.bottom;
     Red:=GetRValue(Col2) shl 8;
     Green:=GetGValue(Col2) shl 8;
     Blue:=GetBValue(Col2) shl 8;
     Alpha:=0;
     end;

gRect.UpperLeft:=0;
gRect.LowerRight:=1;
GradientFill(canvas.Handle,@vert,2,@gRect,1,GRADIENT_FILL_RECT_V);
end;

class procedure TGradientTools.VGradient(canvas : TCanvas; cStart,cEnd : TColor; p1, p2 : TPoint);

begin
VGradient(canvas,cstart,cend,rect(p1.x,p1.y,p2.x,p2.y));
end;

class procedure TGradientTools.VGradient(canvas : TCanvas; cStart,cEnd : TColor; x1,y1,x2,y2 : integer); 

begin
VGradient(canvas,cstart,cend,rect(x1,y1,x2,y2));
end;

class procedure TGradientTools.Gradient(canvas : TCanvas; cStart,cEnd : TColor; rect : T2DIntRect; GradientType : TGradientType);

begin
if GradientType=gtVertical then VGradient(canvas, cStart, cEnd, rect) else
   HGradient(canvas, cStart, cEnd, rect);
end;

class procedure TGradientTools.Gradient(canvas : TCanvas; cStart,cEnd : TColor; p1, p2 : TPoint; GradientType : TGradientType);

begin
if GradientType=gtVertical then VGradient(canvas, cStart, cEnd, p1, p2) else
   HGradient(canvas, cStart, cEnd, p1, p2);
end;

class procedure TGradientTools.Gradient(canvas : TCanvas; cStart,cEnd : TColor; x1,y1,x2,y2 : integer; GradientType : TGradientType);

begin
if GradientType=gtVertical then VGradient(canvas, cStart, cEnd, x1, y1, x2, y2) else
   HGradient(canvas, cStart, cEnd, x1, y1, x2, y2);
end;

class procedure TGradientTools.HGradientLine(canvas : TCanvas; cBase, cShade : TColor; x1, x2 , y : integer; ShadeMode : TGradientLineShade);

var i : integer;

begin
if x1=x2 then exit;
if x1>x2 then
   begin
   i:=x1;
   x1:=x2;
   x2:=i;
   end;
case ShadeMode of
     lsShadeStart : HGradient(canvas,cShade,cBase,rect(x1,y,x2,y+1));
     lsShadeEnds : begin
                   i:=(x1+x2) div 2;
                   HGradient(canvas,cShade,cBase,rect(x1,y,i,y+1));
                   HGradient(canvas,cBase,cShade,rect(i,y,x2,y+1));
                   end;
     lsShadeCenter : begin
                     i:=(x1+x2) div 2;
                     HGradient(canvas,cBase,cShade,rect(x1,y,i,y+1));
                     HGradient(canvas,cShade,cBase,rect(i,y,x2,y+1));
                     end;
     lsShadeEnd : HGradient(canvas,cBase,cShade,rect(x1,y,x2,y+1));
end;
end;

class procedure TGradientTools.VGradientLine(canvas : TCanvas; cBase, cShade : TColor; x, y1 , y2 : integer; ShadeMode : TGradientLineShade);

var i : integer;

begin
if y1=y2 then exit;
if y1>y2 then
   begin
   i:=y1;
   y1:=y2;
   y2:=i;
   end;
case ShadeMode of
     lsShadeStart : VGradient(canvas,cShade,cBase,rect(x,y1,x+1,y2));
     lsShadeEnds : begin
                   i:=(y1+y2) div 2;
                   VGradient(canvas,cShade,cBase,rect(x,y1,x+1,i));
                   VGradient(canvas,cBase,cShade,rect(x,i,x+1,y2));
                   end;
     lsShadeCenter : begin
                     i:=(y1+y2) div 2;
                     VGradient(canvas,cBase,cShade,rect(x,y1,x+1,i));
                     VGradient(canvas,cShade,cBase,rect(x,i,x+1,y2));
                     end;
     lsShadeEnd : VGradient(canvas,cBase,cShade,rect(x,y1,x+1,y2));
end;
end;

class procedure TGradientTools.HGradient3dLine(canvas : TCanvas; x1,x2,y : integer; ShadeMode : TGradientLineShade; A3dKind : TGradient3dLine = glLowered);

begin
if A3dKind = glRaised then
   begin
   HGradientLine(canvas,clBtnHighlight,clBtnFace,x1,x2,y,ShadeMode);
   HGradientLine(canvas,clBtnShadow,clBtnFace,x1,x2,y+1,ShadeMode);
   end else
       begin
       HGradientLine(canvas,clBtnShadow,clBtnFace,x1,x2,y,ShadeMode);
       HGradientLine(canvas,clBtnHighlight,clBtnFace,x1,x2,y+1,ShadeMode);
       end;
end;

class procedure TGradientTools.VGradient3dLine(canvas : TCanvas; x,y1,y2 : integer; ShadeMode : TGradientLineShade; A3dKind : TGradient3dLine = glLowered);

begin
if A3dKind = glLowered then
   begin
   VGradientLine(canvas,clBtnFace,clBtnHighlight,x,y1,y2,ShadeMode);
   VGradientLine(canvas,clBtnFace,clBtnShadow,x+1,y1,y2,ShadeMode);
   end else
       begin
       VGradientLine(canvas,clBtnFace,clBtnShadow,x,y1,y2,ShadeMode);
       VGradientLine(canvas,clBtnFace,clBtnHighlight,x+1,y1,y2,ShadeMode);
       end;
end;

{ TTextTools }

class procedure TTextTools.OutlinedText(Canvas : TCanvas; x, y : integer; text : string);

var TmpColor : TColor;
    TmpBrushStyle : TBrushStyle;

begin
TmpColor:=Canvas.Font.color;
TmpBrushStyle:=Canvas.Brush.style;

Canvas.brush.style:=bsClear;

Canvas.font.color:=clBlack;
Canvas.TextOut(x-1,y,text);
Canvas.TextOut(x+1,y,text);
Canvas.TextOut(x,y-1,text);
Canvas.TextOut(x,y+1,text);

Canvas.font.color:=TmpColor;
Canvas.TextOut(x,y,text);

Canvas.Brush.Style:=TmpBrushStyle;
end;

end.
