unit SpkToolbar;

(*******************************************************************************
*                                                                              *
*  Plik: SpkToolbar.pas                                                        *
*  Opis: G³ówny komponent toolbara                                             *
*  Copyright: (c) 2009 by Spook. Jakiekolwiek u¿ycie komponentu bez            *
*             uprzedniego uzyskania licencji od autora stanowi z³amanie        *
*             prawa autorskiego!                                               *
*                                                                              *
*******************************************************************************)

interface

uses Windows, Graphics, SysUtils, Controls, Classes, Messages, Math, Dialogs,
     Types,
     SpkGraphTools, SpkGUITools, SpkMath, SpkXMLParser,
     spkt_Appearance, spkt_BaseItem, spkt_Const, spkt_Dispatch, spkt_Tab,
     spkt_Pane, spkt_Exceptions, spkt_Types;

type /// <summary>Typ opisuj¹cy regiony toolbara, które s¹ u¿ywane podczas
     /// obs³ugi interakcji z mysz¹</summary>
     TSpkMouseToolbarElement = (teNone, teToolbarArea, teTabs, teTabContents);

type TSpkToolbar = class;

     /// <summary>Klasa dyspozytora s³u¿¹ca do bezpiecznego przyjmowania
     /// informacji oraz ¿¹dañ od pod-elementów</summary>
     TSpkToolbarDispatch = class(TSpkBaseToolbarDispatch)
     private
     /// <summary>Komponent toolbara, który przyjmuje informacje i ¿¹dania
     /// od pod-elementów</summary>
       FToolbar : TSpkToolbar;
     protected
     public
     // *******************
     // *** Konstruktor ***
     // *******************

     /// <summary>Konstruktor</summary>
       constructor Create(AToolbar : TSpkToolbar);

     // ******************************************************************
     // *** Implementacja abstrakcyjnych metod TSpkBaseToolbarDispatch ***
     // ******************************************************************

     /// <summary>Metoda wywo³ywana, gdy zmieni siê zawartoœæ obiektu wygl¹du
     /// zawieraj¹cego kolory i czcionki u¿ywane do rysowania toolbara.
     /// </summary>
       procedure NotifyAppearanceChanged; override;
     /// <summary>Metoda wywo³ywana, gdy zmieni siê lista pod-elementów jednego
     /// z elementów toolbara</summary>
       procedure NotifyItemsChanged; override;
     /// <summary>Metoda wywo³ywana, gdy zmieni siê rozmiar lub po³o¿enie
     /// (metryka) jednego z elementów toolbara</summary>
       procedure NotifyMetricsChanged; override;
     /// <summary>Metoda wywo³ywana, gdy zmieni siê wygl¹d jednego z elementów
     /// toolbara, nie wymagaj¹cy jednak przebudowania metryk.</summary>
       procedure NotifyVisualsChanged; override;
     /// <summary>Metoda ¿¹da dostarczenia przez toolbar pomocniczej
     /// bitmapy u¿ywanej - przyk³adowo - do obliczania rozmiarów renderowanego
     /// tekstu</summary>
       function GetTempBitmap : TBitmap; override;
     /// <summary>Metoda przelicza wspó³rzêdne toolbara na wspó³rzêdne
     /// ekranu, co umo¿liwia - na przyk³ad - rozwiniêcie popup menu.</summary>
       function ClientToScreen(Point : T2DIntPoint) : T2DIntPoint; override;
     end;

     /// <summary>Rozszerzony pasek narzêdzi inspirowany Microsoft Fluent
     /// UI</summary>
     TSpkToolbar = class(TCustomControl)
     private
     /// <summary>Instancja obiektu dyspozytora przekazywanego elementom
     /// toolbara</summary>
       FToolbarDispatch : TSpkToolbarDispatch;

     /// <summary>Bufor w którym rysowany jest toolbar</summary>
       FBuffer : TBitmap;
     /// <summary>Pomocnicza bitmapa przekazywana na ¿yczenie elementom
     /// toolbara</summary>
       FTemporary : TBitmap;

     /// <summary>Tablica rectów "uchwytów" zak³adek</summary>
       FTabRects : array of T2DIntRect;
     /// <summary>Cliprect obszaru "uchwytów" zak³adek</summary>
       FTabClipRect : T2DIntRect;
     /// <summary>Cliprect obszaru zawartoœci zak³adki</summary>
       FTabContentsClipRect : T2DIntRect;

     /// <summary>Element toolbara znajduj¹cy siê obecnie pod myszk¹</summary>
       FMouseHoverElement : TSpkMouseToolbarElement;
     /// <summary>Element toolbara maj¹cy obecnie wy³¹cznoœæ na otrzymywanie
     /// komunikatów od myszy</summary>
       FMouseActiveElement : TSpkMouseToolbarElement;

     /// <summary>"Uchwyt" zak³adki, nad którym znajduje siê obecnie mysz
     /// </summary>
       FTabHover : integer;

     /// <summary>Flaga informuj¹ca o tym, czy metryki toolbara i jego elementów
     /// s¹ aktualne</summary>
       FMetricsValid : boolean;
     /// <summary>Flaga informuj¹ca o tym, czy zawartoœæ bufora jest aktualna
     /// </summary>
       FBufferValid : boolean;
     /// <summary>Flaga InternalUpdating pozwala na zablokowanie walidacji
     /// metryk i bufora w momencie, gdy komponent przebudowuje swoj¹ zawartoœæ.
     /// FInternalUpdating jest zapalana i gaszona wewnêtrznie, przez komponent.
     /// </summary>
       FInternalUpdating : boolean;
     /// <summary>Flaga IUpdating pozwala na zablokowanie walidacji
     /// metryk i bufora w momencie, gdy u¿ytkownik przebudowuje zawartoœæ
     /// komponentu. FUpdating jest sterowana przez u¿ytkownika.</summary>
       FUpdating : boolean;
     protected
     /// <summary>Instancja obiektu wygl¹du, przechowuj¹cego kolory i czcionki
     /// u¿ywane podczas renderowania komponentu</summary>
       FAppearance : TSpkToolbarAppearance;
     /// <summary>Zak³adki toolbara</summary>
       FTabs : TSpkTabs;
     /// <summary>Indeks wybranej zak³adki</summary>
       FTabIndex : integer;
     /// <summary>Lista ma³ych obrazków elementów toolbara</summary>
       FImages : TImageList;
     /// <summary>Lista ma³ych obrazków w stanie "disabled". Jeœli nie jest
     /// przypisana, obrazki w stanie "disabled" bêd¹ generowane automatycznie.
     /// </summary>
       FDisabledImages : TImageList;
     /// <summary>Lista du¿ych obrazków elementów toolbara</summary>
       FLargeImages : TImageList;
     /// <summary>Lista du¿ych obrazków w stanie "disabled". Jeœli nie jest
     /// przypisana, obrazki w stanie "disabled" bêd¹ generowane automatycznie.
     /// </summary>
       FDisabledLargeImages : TImageList;

     // *******************************************
     // *** Zarz¹dzanie stanem metryki i bufora ***
     // *******************************************

     /// <summary>Metoda gasi flagi: FMetricsValid oraz FBufferValid</summary>
       procedure SetMetricsInvalid;
     /// <summary>Metoda gasi flagê FBufferValid</summary>
       procedure SetBufferInvalid;
     /// <summary>Metoda waliduje metryki toolbara i jego elementów</summary>
       procedure ValidateMetrics;
     /// <summary>Metoda waliduje zawartoœæ bufora</summary>
       procedure ValidateBuffer;
     /// <summary>Metoda w³¹cza tryb wewnêtrznej przebudowy - zapala flagê
     /// FInternalUpdating</summary>
       procedure InternalBeginUpdate;
     /// <summary>Metoda wy³¹cza tryb wewnêtrznej przebudowy - gasi flagê
     /// FInternalUpdating</summary>
       procedure InternalEndUpdate;

     // ********************************************
     // *** Pokrycie metod z dziedziczonych klas ***
     // ********************************************

     /// <summary>Zmiana rozmiaru komponentu</summary>
       procedure Resize; override;
     /// <summary>Metoda wywo³ywana po opuszczeniu obszaru komponentu przez
     /// wskaŸnik myszy</summary>
       procedure MouseLeave;
     /// <summary>Metoda wywo³ywana po wciœniêciu przycisku myszy</summary>
       procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
         X, Y: Integer); override;
     /// <summary>Metoda wywo³ywana, gdy nad komponentem przesunie siê wskaŸnik
     /// myszy</summary>
       procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
     /// <summary>Metoda wywo³ywana po puszczeniu przycisku myszy</summary>
       procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
         X, Y: Integer); override;
     /// <summary>Metoda wywo³ywana, gdy ca³y komponent wczyta siê z DFMa
     /// </summary>
       procedure Loaded; override;
     /// <summary>Metoda wywo³ywana, gdy komponent staje siê Ownerem innego
     /// komponentu, b¹dŸ gdy jeden z jego pod-komponentów jest zwalniany
     /// </summary>
       procedure Notification(AComponent: TComponent;
         Operation: TOperation); override;

     // ******************************************
     // *** Obs³uga zdarzeñ myszy dla zak³adek ***
     // ******************************************

     /// <summary>Metoda wywo³ywana po opuszczeniu przez wskaŸnik myszy obszaru
     /// "uchwytów" zak³adek</summary>
       procedure TabMouseLeave;
     /// <summary>Metoda wywo³ywana po wciœniêciu przycisku myszy, gdy wskaŸnik
     /// jest nad obszarem zak³adek</summary>
       procedure TabMouseDown(Button: TMouseButton; Shift: TShiftState;
         X, Y: Integer);
     /// <summary>Metoda wywo³ywana, gdy mysz przesunie siê ponad obszarem
     /// "uchwytów" zak³adek</summary>
       procedure TabMouseMove(Shift: TShiftState; X, Y: Integer);
     /// <summary>Metoda wywo³ywana, gdy jeden z przycisków myszy zostanie
     /// puszczony, gdy obszar zak³adek by³ aktywnym elementem toolbara
     /// </summary>
       procedure TabMouseUp(Button: TMouseButton; Shift: TShiftState;
         X, Y: Integer);

     // ******************
     // *** Pomocnicze ***
     // ******************

     /// <summary>Metoda sprawdza, czy choæ jedna zak³adka ma ustawion¹ flagê
     /// widocznoœci (Visible)</summary>
       function AtLeastOneTabVisible : boolean;

     // ***************************
     // *** Obs³uga komunikatów ***
     // ***************************

     /// <summary>Komunikat odbierany, gdy mysz opuœci obszar komponentu
     /// </summary>
       procedure CMMouseLeave(var msg : TMessage); message CM_MOUSELEAVE;

     // ********************************
     // *** Obs³uga designtime i DFM ***
     // ********************************

     /// <summary>Metoda zwraca elementy, które maj¹ zostaæ zapisane jako
     /// pod-elementy komponentu</summary>
       procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
     /// <summary>Metoda pozwala na zapisanie lub odczytanie dodatkowych
     /// w³asnoœci komponentu</summary>
       procedure DefineProperties(Filer : TFiler); override;

     // *************************
     // *** Gettery i settery ***
     // *************************

     /// <summary>Getter dla w³asnoœci Height</summary>
       function GetHeight: integer;
     /// <summary>Setter dla w³asnoœci Appearance</summary>
       procedure SetAppearance(const Value: TSpkToolbarAppearance);
     /// <summary>Getter dla w³asnoœci Color</summary>
       function GetColor: TColor;
     /// <summary>Setter dla w³asnoœci Color</summary>
       procedure SetColor(const Value: TColor);
     /// <summary>Setter dla w³asnoœci TabIndex</summary>
       procedure SetTabIndex(const Value: integer);
     /// <summary>Setter dla w³asnoœci Images</summary>
       procedure SetImages(const Value: TImageList);
     /// <summary>Setter dla w³asnoœci DisabledImages</summary>
       procedure SetDisabledImages(const Value : TImageList);
     /// <summary>Setter dla w³asnoœci LargeImages</summary>
       procedure SetLargeImages(const Value : TImageList);
     /// <summary>Setter dla w³asnoœci DisabledLargeImages</summary>
       procedure SetDisabledLargeImages(const Value : TImageList);
     public

     // ***********************************
     // *** Obs³uga zdarzeñ dyspozytora ***
     // ***********************************

     /// <summary>Reakcja na zmianê struktury elementów toolbara</summary>
       procedure NotifyItemsChanged;
     /// <summary>Reakcja na zmianê metryki elementów toolbara</summary>
       procedure NotifyMetricsChanged;
     /// <summary>Reakcja na zmianê wygl¹du elementów toolbara</summary>
       procedure NotifyVisualsChanged;
     /// <summary>Reakcja na zmianê zawartoœci klasy wygl¹du toolbara</summary>
       procedure NotifyAppearanceChanged;
     /// <summary>Metoda zwraca instancjê pomocniczej bitmapy</summary>
       function GetTempBitmap : TBitmap;

     // ********************************
     // *** Konstruktor i destruktor ***
     // ********************************

     /// <summary>Konstruktor</summary>
       constructor Create(AOwner : TComponent); override;
     /// <summary>Destruktor</summary>
       destructor Destroy; override;

     // *****************
     // *** Rysowanie ***
     // *****************

     /// <summary>Metoda odrysowuje zawartoœæ komponentu</summary>
       procedure Paint; override;
     /// <summary>Metoda wymusza przebudowanie metryk i bufora</summary>
       procedure ForceRepaint;
     /// <summary>Metoda prze³¹cza komponent w tryb aktualizacji zawartoœci
     /// poprzez zapalenie flagi FUpdating</summary>
       procedure BeginUpdate;
     /// <summary>Metoda wy³¹cza tryb aktualizacji zawartoœci poprzez zgaszenie
     /// flagi FUpdating</summary>
       procedure EndUpdate;

     // *************************
     // *** Obs³uga elementów ***
     // *************************

     /// <summary>Metoda wywo³ywana w momencie, gdy jedna z zak³adek
     /// jest zwalniana</summary>
     /// <remarks>Nie nale¿y wywo³ywaæ metody FreeingTab z kodu! Jest ona
     /// wywo³ywana wewnêtrznie, a jej zadaniem jest zaktualizowanie wewnêtrznej
     /// listy zak³adek.</remarks>
       procedure FreeingTab(ATab : TSpkTab);

     // **************************
     // *** Dostêp do zak³adek ***
     // **************************

     /// <summary>W³asnoœæ daje dostê do zak³adek w trybie runtime. Do edycji
     /// zak³adek w trybie designtime s³u¿y odpowiedni edytor, zaœ zapisywanie
     /// i odczytywanie z DFMa jest zrealizowane manualnie.</summary>
       property Tabs : TSpkTabs read FTabs;
     published
     /// <summary>Kolor t³a komponentu</summary>
       property Color : TColor read GetColor write SetColor;
     /// <summary>Obiekt zawieraj¹cy atrybuty wygl¹du toolbara</summary>
       property Appearance : TSpkToolbarAppearance read FAppearance write SetAppearance;
     /// <summary>Wysokoœæ toolbara (tylko do odczytu)</summary>
       property Height : integer read GetHeight;
     /// <summary>Aktywna zak³adka</summary>
       property TabIndex : integer read FTabIndex write SetTabIndex;
     /// <summary>Lista ma³ych obrazków</summary>
       property Images : TImageList read FImages write SetImages;
     /// <summary>Lista ma³ych obrazków w stanie "disabled"</summary>
       property DisabledImages : TImageList read FDisabledImages write SetDisabledImages;
     /// <summary>Lista du¿ych obrazków</summary>
       property LargeImages : TImageList read FLargeImages write SetLargeImages;
     /// <summary>Lista du¿ych obrazków w stanie "disabled"</summary>
       property DisabledLargeImages : TImageList read FDisabledLargeImages write SetDisabledLargeImages;
     end;

implementation

{ TSpkToolbarDispatch }

function TSpkToolbarDispatch.ClientToScreen(Point: T2DIntPoint): T2DIntPoint;
begin
  if FToolbar<>nil then
     result:=FToolbar.ClientToScreen(Point) else
     result:=T2DIntPoint.Create(-1,-1);
end;

constructor TSpkToolbarDispatch.Create(AToolbar: TSpkToolbar);
begin
  inherited Create;
  FToolbar:=AToolbar;
end;

function TSpkToolbarDispatch.GetTempBitmap: TBitmap;
begin
  if FToolbar<>nil then
     result:=FToolbar.GetTempBitmap else
     result:=nil;
end;

procedure TSpkToolbarDispatch.NotifyAppearanceChanged;
begin
  if FToolbar<>nil then
     FToolbar.NotifyAppearanceChanged;
end;

procedure TSpkToolbarDispatch.NotifyMetricsChanged;
begin
  if FToolbar<>nil then
     FToolbar.NotifyMetricsChanged;
end;

procedure TSpkToolbarDispatch.NotifyItemsChanged;
begin
  if FToolbar<>nil then
     FToolbar.NotifyItemsChanged;
end;

procedure TSpkToolbarDispatch.NotifyVisualsChanged;
begin
  if FToolbar<>nil then
     FToolbar.NotifyVisualsChanged;
end;

{ TSpkToolbar }

function TSpkToolbar.AtLeastOneTabVisible: boolean;

var i : integer;
    TabVisible : boolean;

begin
result:=FTabs.count>0;
if result then
   begin
   TabVisible:=false;
   i:=FTabs.count-1;
   while (i>=0) and not(TabVisible) do
         begin
         TabVisible:=FTabs[i].Visible;
         dec(i);
         end;
   result:=result and TabVisible;
   end;
end;

procedure TSpkToolbar.BeginUpdate;
begin
  FUpdating:=true;
end;

procedure TSpkToolbar.CMMouseLeave(var msg: TMessage);
begin
  inherited;
  MouseLeave;
end;

constructor TSpkToolbar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  // Inicjacja dziedziczonych w³asnoœci
  inherited Align:=alTop;
  inherited AlignWithMargins:=true;
  inherited Height:=TOOLBAR_HEIGHT;
  inherited Doublebuffered:=true;

  // Inicjacja wewnêtrznych pól danych
  FToolbarDispatch:=TSpkToolbarDispatch.Create(self);

  FBuffer:=TBitmap.create;
  FBuffer.PixelFormat:=pf24bit;

  FTemporary:=TBitmap.create;
  FTemporary.Pixelformat:=pf24bit;

  setlength(FTabRects,0);
  FTabClipRect:=T2DIntRect.create(0,0,0,0);
  FTabContentsClipRect:=T2DIntRect.create(0,0,0,0);

  FMouseHoverElement:=teNone;
  FMouseActiveElement:=teNone;

  FTabHover:=-1;

  FMetricsValid:=false;
  FBufferValid:=false;
  FInternalUpdating:=false;
  FUpdating:=false;

  // Inicjacja pól
  FAppearance:=TSpkToolbarAppearance.Create(FToolbarDispatch);

  FTabs:=TSpkTabs.Create(self);
  FTabs.ToolbarDispatch:=FToolbarDispatch;
  FTabs.Appearance:=FAppearance;

  FTabIndex:=-1;

  FImages:=nil;
  FDisabledImages:=nil;
  FLargeImages:=nil;
  FDisabledLargeImages:=nil;
end;

procedure TSpkToolbar.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);

  Filer.DefineProperty('Tabs',FTabs.ReadNames,FTabs.WriteNames,true);
end;

destructor TSpkToolbar.Destroy;
begin
  // Zwalniamy pola
  FTabs.Free;

  FAppearance.Free;

  // Zwalniamy wewnêtrzne pola
  FTemporary.Free;
  FBuffer.Free;

  FToolbarDispatch.Free;

  inherited Destroy;
end;

procedure TSpkToolbar.EndUpdate;
begin
  FUpdating:=false;

  ValidateMetrics;
  ValidateBuffer;
  Repaint;
end;

procedure TSpkToolbar.ForceRepaint;
begin
SetMetricsInvalid;
SetBufferInvalid;
Repaint;
end;

procedure TSpkToolbar.FreeingTab(ATab: TSpkTab);
begin
FTabs.RemoveReference(ATab);
end;

procedure TSpkToolbar.GetChildren(Proc: TGetChildProc; Root: TComponent);

var i : integer;

begin
inherited;

if FTabs.Count>0 then
   for i := 0 to FTabs.Count - 1 do
       Proc(FTabs.Items[i]);
end;

function TSpkToolbar.GetColor: TColor;
begin
result:=inherited Color;
end;

function TSpkToolbar.GetHeight: integer;
begin
result:=inherited Height;
end;

function TSpkToolbar.GetTempBitmap: TBitmap;
begin
result:=FTemporary;
end;

procedure TSpkToolbar.InternalBeginUpdate;
begin
  FInternalUpdating:=true;
end;

procedure TSpkToolbar.InternalEndUpdate;
begin
  FInternalUpdating:=false;

  // Po wewnêtrznych zmianach odœwie¿amy metryki i bufor
  ValidateMetrics;
  ValidateBuffer;
  Repaint;
end;

procedure TSpkToolbar.Loaded;
begin
inherited;

InternalBeginUpdate;

if FTabs.ListState = lsNeedsProcessing then
   begin
   FTabs.ProcessNames(self.Owner);
   end;

InternalEndUpdate;

// Proces wewnêtrznego update'u zawsze odœwie¿a na koñcu metryki i bufor oraz
// odrysowuje komponent.
end;

procedure TSpkToolbar.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);

begin
  // Podczas procesu przebudowy mysz jest ignorowana.
  if FInternalUpdating or FUpdating then
     exit;

  inherited MouseDown(Button, Shift, X, Y);

  // Mo¿liwe, ¿e zosta³ wciœniêty kolejny przycisk myszy. W takiej sytuacji
  // aktywny obiekt otrzymuje kolejn¹ notyfikacjê.
  if FMouseActiveElement=teTabs then
     begin
     TabMouseDown(Button, Shift, X, Y);
     end else
  if FMouseActiveElement=teTabContents then
     begin
     if FTabIndex<>-1 then
        FTabs[FTabIndex].MouseDown(Button, Shift, X, Y);
     end else
  if FMouseActiveElement = teToolbarArea then
     begin
     // Placeholder, jeœli zajdzie potrzeba obs³ugi tego zdarzenia
     end else
  // Jeœli nie ma aktywnego elementu, aktywnym staje siê ten, który obecnie
  // jest pod mysz¹.
  if FMouseActiveElement=teNone then
     begin
     if FMouseHoverElement = teTabs then
        begin
        FMouseActiveElement:=teTabs;
        TabMouseDown(Button, Shift, X, Y);
        end else
     if FMouseHoverElement = teTabContents then
        begin
        FMouseActiveElement:=teTabContents;
        if FTabIndex<>-1 then
           FTabs[FTabIndex].MouseDown(Button, Shift, X, Y);
        end else
     if FMouseHoverElement = teToolbarArea then
        begin
        FMouseActiveElement:=teToolbarArea;

        // Placeholder, jeœli zajdzie potrzeba obs³ugi tego zdarzenia
        end;
     end;
end;

procedure TSpkToolbar.MouseLeave;

begin
  // Podczas procesu przebudowy mysz jest ignorowana.
  if FInternalUpdating or FUpdating then
     exit;

  // MouseLeave nie ma szans byæ zawo³ane dla obiektu aktywnego, bo po
  // wciœniêciu przycisku myszy ka¿dy jej ruch jest przekazywany jako
  // MouseMove. Jeœli mysz wyjedzie za obszar komponentu, MouseLeave
  // zostanie zawo³any zaraz po MouseUp - ale MouseUp czyœci aktywny
  // obiekt.
  if FMouseActiveElement = teNone then
     begin
     // Jeœli nie ma obiektu aktywnego, obs³ugujemy elementy pod mysz¹
     if FMouseHoverElement = teTabs then
        begin
        TabMouseLeave;
        end else
     if FMouseHoverElement = teTabContents then
        begin
        if FTabIndex<>-1 then
           FTabs[FTabIndex].MouseLeave;
        end else
     if FMouseHoverElement = teToolbarArea then
        begin
        // Placeholder, jeœli bêdzie potrzeba obs³ugi tego zdarzenia
        end;
     end;

  FMouseHoverElement:=teNone;
end;

procedure TSpkToolbar.MouseMove(Shift: TShiftState; X, Y: Integer);

var NewMouseHoverElement : TSpkMouseToolbarElement;
    MousePoint : T2DIntVector;

begin
  // Podczas procesu przebudowy mysz jest ignorowana.
  if FInternalUpdating or FUpdating then
     exit;

  inherited MouseMove(Shift, X, Y);

  // Sprawdzamy, który obiekt jest pod mysz¹
  MousePoint:=T2DIntVector.create(x,y);

  if FTabClipRect.Contains(MousePoint) then
     NewMouseHoverElement:=teTabs else
  if FTabContentsClipRect.Contains(MousePoint) then
     NewMouseHoverElement:=teTabContents else
  if (X>=0) and (Y>=0) and (X<self.width) and (Y<self.height) then
     NewMouseHoverElement:=teToolbarArea else
     NewMouseHoverElement:=teNone;

  // Jeœli jest jakiœ aktywny obiekt, to on ma wy³¹cznoœæ na komunikaty
  if FMouseActiveElement = teTabs then
     begin
     TabMouseMove(Shift, X, Y);
     end else
  if FMouseActiveElement = teTabContents then
     begin
     if FTabIndex<>-1 then
        FTabs[FTabIndex].MouseMove(Shift, X, Y);
     end else
  if FMouseActiveElement = teToolbarArea then
     begin
     // Placeholder, jeœli zajdzie potrzeba obs³ugi tego zdarzenia
     end else
  if FMouseActiveElement = teNone then
     begin
     // Jeœli element pod mysz¹ siê zmienia, informujemy poprzedni element o
     // tym, ¿e mysz opuszcza jego obszar
     if NewMouseHoverElement<>FMouseHoverElement then
        begin
        if FMouseHoverElement = teTabs then
           begin
           TabMouseLeave;
           end else
        if FMouseHoverElement = teTabContents then
           begin
           if FTabIndex<>-1 then
              FTabs[FTabIndex].MouseLeave;
           end else
        if FMouseHoverElement = teToolbarArea then
           begin
           // Placeholder, jeœli zajdzie potrzeba obs³ugi tego zdarzenia
           end;
        end;

     // Element pod mysz¹ otrzymuje MouseMove
     if NewMouseHoverElement = teTabs then
        begin
        TabMouseMove(Shift, X, Y);
        end else
     if NewMouseHoverElement = teTabContents then
        begin
        if FTabIndex<>-1 then
           FTabs[FTabIndex].MouseMove(Shift, X, Y);
        end else
     if NewMouseHoverElement = teToolbarArea then
        begin
        // Placeholder, jeœli zajdzie potrzeba obs³ugi tego zdarzenia
        end;
     end;

FMouseHoverElement:=NewMouseHoverElement;
end;

procedure TSpkToolbar.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);

var ClearActive: Boolean;

begin
  // Podczas procesu przebudowy mysz jest ignorowana.
  if FInternalUpdating or FUpdating then
     exit;

  inherited MouseUp(Button, Shift, X, Y);

  ClearActive:=not(ssLeft in Shift) and not(ssMiddle in Shift) and not(ssRight in Shift);

  // Jeœli jest jakiœ aktywny obiekt, to on ma wy³¹cznoœæ na otrzymywanie
  // komunikatów
  if FMouseActiveElement=teTabs then
     begin
     TabMouseUp(Button, Shift, X, Y);
     end else
  if FMouseActiveElement=teTabContents then
     begin
     if FTabIndex<>-1 then
        FTabs[FTabIndex].MouseUp(Button, Shift, X, Y);
     end else
  if FMouseActiveElement = teToolbarArea then
     begin
     // Placeholder, jeœli zajdzie potrzeba obs³ugi tego zdarzenia
     end;

  // Jeœli puszczono ostatni przycisk i mysz nie znajduje siê nad aktywnym
  // obiektem, trzeba dodatkowo wywo³aæ MouseLeave dla aktywnego i MouseMove
  // dla obiektu pod mysz¹.
  if ClearActive and (FMouseActiveElement<>FMouseHoverElement) then
     begin
     if FMouseActiveElement = teTabs then
        TabMouseLeave else
     if FMouseActiveElement = teTabContents then
        begin
        if FTabIndex<>-1 then
           FTabs[FTabIndex].MouseLeave;
        end else
     if FMouseActiveElement = teToolbarArea then
        begin
        // Placeholder, jeœli zajdzie potrzeba obs³ugi tego zdarzenia
        end;

     if FMouseHoverElement=teTabs then
        TabMouseMove(Shift, X, Y) else
     if FMouseHoverElement=teTabContents then
        begin
        if FTabIndex<>-1 then
           FTabs[FTabIndex].MouseMove(Shift, X, Y);
        end else
     if FMouseHoverElement = teToolbarArea then
        begin
        // Placeholder, jeœli zajdzie potrzeba obs³ugi tego zdarzenia
        end;
     end;

  // MouseUp gasi aktywny obiekt, o ile zosta³y puszczone wszystkie
  // przyciski
  if ClearActive then
     FMouseActiveElement:=teNone;
end;

procedure TSpkToolbar.Notification(AComponent: TComponent;
  Operation: TOperation);

var Tab : TSpkTab;
    Pane : TSpkPane;
    Item : TSpkBaseItem;

begin
  inherited;

  if AComponent is TSpkTab then
     begin
     FreeingTab(AComponent as TSpkTab);
     end else
  if AComponent is TSpkPane then
     begin
     Pane:=AComponent as TSpkPane;
     if (Pane.Parent<>nil) and (Pane.Parent is TSpkTab) then
        begin
        Tab:=Pane.Parent as TSpkTab;
        Tab.FreeingPane(Pane);
        end;
     end else
  if AComponent is TSpkBaseItem then
     begin
     Item:=AComponent as TSpkBaseItem;
     if (Item.Parent<>nil) and (Item.Parent is TSpkPane) then
        begin
        Pane:=Item.Parent as TSpkPane;
        Pane.FreeingItem(Item);
        end;
     end;
end;

procedure TSpkToolbar.NotifyAppearanceChanged;
begin
  SetMetricsInvalid;

  if not(FInternalUpdating or FUpdating) then
     Repaint;
end;

procedure TSpkToolbar.NotifyMetricsChanged;
begin
  SetMetricsInvalid;

  if not(FInternalUpdating or FUpdating) then
     Repaint;
end;

procedure TSpkToolbar.NotifyItemsChanged;
begin
  // Poprawianie TabIndex o ile zachodzi taka potrzeba
  if not(AtLeastOneTabVisible) then FTabIndex:=-1
  else
    begin
    FTabIndex:=max(0,min(FTabs.count-1,FTabIndex));

    // Wiem, ¿e przynajmniej jedna zak³adka jest widoczna (z wczeœniejszego
    // warunku), wiêc poni¿sza pêtla na pewno siê zakoñczy.
    while not(FTabs[FTabIndex].Visible) do
          FTabIndex:=(FTabIndex + 1) mod FTabs.count;
    end;
  FTabHover:=-1;

  SetMetricsInvalid;

  if not(FInternalUpdating or FUpdating) then
     Repaint;
end;

procedure TSpkToolbar.NotifyVisualsChanged;
begin
  SetBufferInvalid;

  if not(FInternalUpdating or FUpdating) then
     Repaint;
end;

procedure TSpkToolbar.Paint;

begin
// Jeœli trwa proces przebudowy (wewnêtrznej lub u¿ytkownika), walidacja metryk
// i bufora nie jest przeprowadzana, jednak bufor jest rysowany w takiej
// postaci, w jakiej zosta³ zapamiêtany przed rozpoczêciem procesu przebudowy.
if not(FInternalUpdating or FUpdating) then
   begin
   if not(FMetricsValid) then
      ValidateMetrics;
   if not(FBufferValid) then
      ValidateBuffer;
   end;

self.canvas.draw(0, 0, FBuffer);
end;

procedure TSpkToolbar.Resize;
begin
  inherited Height:=TOOLBAR_HEIGHT;

  SetMetricsInvalid;
  SetBufferInvalid;

  if not(FInternalUpdating or FUpdating) then
     Repaint;

  inherited;
end;

procedure TSpkToolbar.SetBufferInvalid;
begin
FBufferValid:=false;
end;

procedure TSpkToolbar.SetColor(const Value: TColor);
begin
inherited Color:=Value;
SetBufferInvalid;

if not(FInternalUpdating or FUpdating) then
   Repaint;
end;

procedure TSpkToolbar.SetDisabledImages(const Value: TImageList);
begin
  FDisabledImages := Value;
  FTabs.DisabledImages := Value;
  SetMetricsInvalid;

  if not(FInternalUpdating or FUpdating) then
     Repaint;
end;

procedure TSpkToolbar.SetDisabledLargeImages(const Value: TImageList);
begin
  FDisabledLargeImages := Value;
  FTabs.DisabledLargeImages := Value;
  SetMetricsInvalid;

  if not(FInternalUpdating or FUpdating) then
     Repaint;
end;

procedure TSpkToolbar.SetImages(const Value: TImageList);
begin
  FImages := Value;
  FTabs.Images := Value;
  SetMetricsInvalid;

  if not(FInternalUpdating or FUpdating) then
     Repaint;
end;

procedure TSpkToolbar.SetLargeImages(const Value: TImageList);
begin
  FLargeImages := Value;
  FTabs.LargeImages := Value;
  SetMetricsInvalid;

  if not(FInternalUpdating or FUpdating) then
     Repaint;
end;

procedure TSpkToolbar.SetMetricsInvalid;
begin
FMetricsValid:=false;
FBufferValid:=false;
end;

procedure TSpkToolbar.SetTabIndex(const Value: integer);
begin
  if not(AtLeastOneTabVisible) then FTabIndex:=-1
  else
    begin
    FTabIndex:=max(0,min(FTabs.count-1, Value));

    // Wiem, ¿e przynajmniej jedna zak³adka jest widoczna (z wczeœniejszego
    // warunku), wiêc poni¿sza pêtla na pewno siê zakoñczy.
    while not(FTabs[FTabIndex].Visible) do
          FTabIndex:=(FTabIndex + 1) mod FTabs.count;
    end;
  FTabHover:=-1;

  SetMetricsInvalid;

  if not(FInternalUpdating or FUpdating) then
     Repaint;
end;

procedure TSpkToolbar.TabMouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);

var SelTab: Integer;
    TabRect: T2DIntRect;
    i: Integer;

begin
// Podczas procesu przebudowy mysz jest ignorowana.
if FInternalUpdating or FUpdating then
   exit;

SelTab:=-1;
if AtLeastOneTabVisible then
   for i := 0 to FTabs.count - 1 do
       if FTabs[i].visible then
          begin
          if FTabClipRect.IntersectsWith(FTabRects[i], TabRect) then
             if TabRect.Contains(T2DIntPoint.Create(x, y)) then
                SelTab:=i;
          end;

// Jeœli klikniêta zosta³a któraœ zak³adka, ró¿na od obecnie zaznaczonej,
// zmieñ zaznaczenie.
if (Button = mbLeft) and (SelTab<>-1) and (SelTab<>FTabIndex) then
   begin
   FTabIndex:=SelTab;
   SetMetricsInvalid;
   Repaint;
   end;
end;

procedure TSpkToolbar.TabMouseLeave;
begin
// Podczas procesu przebudowy mysz jest ignorowana.
if FInternalUpdating or FUpdating then
   exit;

if FTabHover<>-1 then
   begin
   FTabHover:=-1;
   SetBufferInvalid;
   Repaint;
   end;
end;

procedure TSpkToolbar.TabMouseMove(Shift: TShiftState; X, Y: Integer);

var NewTabHover : integer;
    TabRect : T2DIntRect;
    i : integer;

begin
// Podczas procesu przebudowy mysz jest ignorowana.
if FInternalUpdating or FUpdating then
   exit;

NewTabHover:=-1;
if AtLeastOneTabVisible then
   for i := 0 to FTabs.count - 1 do
       if FTabs[i].Visible then
          begin
          if FTabClipRect.IntersectsWith(FTabRects[i], TabRect) then
             if TabRect.Contains(T2DIntPoint.Create(x, y)) then
                NewTabHover:=i;
          end;

if NewTabHover<>FTabHover then
   begin
   FTabHover:=NewTabHover;
   SetBufferInvalid;
   Repaint;
   end;
end;

procedure TSpkToolbar.TabMouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
// Podczas procesu przebudowy mysz jest ignorowana.
if FInternalUpdating or FUpdating then
   exit;

// Zak³adki nie potrzebuj¹ obs³ugi MouseUp.
end;

procedure TSpkToolbar.SetAppearance(const Value: TSpkToolbarAppearance);
begin
  FAppearance.assign(Value);

  SetBufferInvalid;
  if not(FInternalUpdating or FUpdating) then
     Repaint;
end;

procedure TSpkToolbar.ValidateBuffer;

  procedure DrawBackgroundColor;

  begin
  FBuffer.canvas.brush.color:=Color;
  FBuffer.canvas.brush.style:=bsSolid;
  FBuffer.canvas.fillrect(Rect(0, 0, self.width, self.height));
  end;

  procedure DrawBody;

  var FocusedAppearance : TSpkToolbarAppearance;
    i: Integer;

  begin
  // Pobieramy appearance aktualnie zaznaczonej zak³adki (b¹dŸ
  // FToolbarAppearance, jeœli zaznaczona zak³adka nie ma ustawionego
  // OverrideAppearance
  if (FTabIndex<>-1) and (FTabs[FTabIndex].OverrideAppearance) then
     FocusedAppearance:=FTabs[FTabIndex].CustomAppearance else
     FocusedAppearance:=FAppearance;

  TGuiTools.DrawRoundRect(FBuffer.Canvas,
                          T2DIntRect.Create(0,
                                            TOOLBAR_TAB_CAPTIONS_HEIGHT,
                                            self.width-1,
                                            self.Height-1),
                          TOOLBAR_CORNER_RADIUS,
                          FocusedAppearance.Tab.GradientFromColor,
                          FocusedAppearance.Tab.GradientToColor,
                          FocusedAppearance.Tab.GradientType);
  TGuiTools.DrawAARoundCorner(FBuffer,
                              T2DIntPoint.Create(0, TOOLBAR_TAB_CAPTIONS_HEIGHT),
                              TOOLBAR_CORNER_RADIUS,
                              cpLeftTop,
                              FocusedAppearance.Tab.BorderColor);
  TGuiTools.DrawAARoundCorner(FBuffer,
                              T2DIntPoint.Create(self.width - TOOLBAR_CORNER_RADIUS, TOOLBAR_TAB_CAPTIONS_HEIGHT),
                              TOOLBAR_CORNER_RADIUS,
                              cpRightTop,
                              FocusedAppearance.Tab.BorderColor);
  TGuiTools.DrawAARoundCorner(FBuffer,
                              T2DIntPoint.Create(0, self.height - TOOLBAR_CORNER_RADIUS),
                              TOOLBAR_CORNER_RADIUS,
                              cpLeftBottom,
                              FocusedAppearance.Tab.BorderColor);
  TGuiTools.DrawAARoundCorner(FBuffer,
                              T2DIntPoint.Create(self.width - TOOLBAR_CORNER_RADIUS, self.height - TOOLBAR_CORNER_RADIUS),
                              TOOLBAR_CORNER_RADIUS,
                              cpRightBottom,
                              FocusedAppearance.Tab.BorderColor);
  TGuiTools.DrawVLine(FBuffer, 0, TOOLBAR_TAB_CAPTIONS_HEIGHT + TOOLBAR_CORNER_RADIUS, self.height - TOOLBAR_CORNER_RADIUS, FocusedAppearance.Tab.BorderColor);
  TGuiTools.DrawHLine(FBuffer, TOOLBAR_CORNER_RADIUS, self.Width-TOOLBAR_CORNER_RADIUS, self.height-1, FocusedAppearance.Tab.BorderColor);
  TGuiTools.DrawVLine(FBuffer, self.width-1, TOOLBAR_TAB_CAPTIONS_HEIGHT + TOOLBAR_CORNER_RADIUS, self.height - TOOLBAR_CORNER_RADIUS, FocusedAppearance.Tab.BorderColor);

  if not(AtLeastOneTabVisible) then
     begin
     // Jeœli nie ma zak³adek, rysujemy poziom¹ liniê
     TGuiTools.DrawHLine(FBuffer, TOOLBAR_CORNER_RADIUS, self.width - TOOLBAR_CORNER_RADIUS, TOOLBAR_TAB_CAPTIONS_HEIGHT, FocusedAppearance.Tab.BorderColor);
     end
  else
     begin
     // Jeœli s¹, pozostawiamy miejsce na zak³adki
     // Szukamy ostatniej widocznej
     i:=FTabs.count-1;
     while not(FTabs[i].Visible) do
           dec(i);

     // Tylko prawa czêœæ, reszta bêdzie narysowana wraz z zak³adkami
     if FTabRects[i].Right<self.width - TOOLBAR_CORNER_RADIUS - 1 then
        TGuiTools.DrawHLine(FBuffer, FTabRects[i].Right+1, self.width - TOOLBAR_CORNER_RADIUS, TOOLBAR_TAB_CAPTIONS_HEIGHT, FocusedAppearance.Tab.BorderColor);
     end;
  end;

  procedure DrawTabs;

  var i: Integer;
      TabRect: T2DIntRect;
      CurrentAppearance : TSpkToolbarAppearance;
      FocusedAppearance : TSpkToolbarAppearance;

    procedure DrawTabText(index : integer; AFont : TFont);

    var
      x, y: integer;
      TabRect : T2DIntRect;

    begin
    TabRect:=FTabRects[index];

    FBuffer.canvas.font.assign(AFont);
    x:=TabRect.left + (TabRect.Width - FBuffer.Canvas.textwidth(FTabs[index].caption)) div 2;
    y:=TabRect.top + (TabRect.Height - FBuffer.Canvas.Textheight('Wy')) div 2;

    TGuiTools.DrawText(FBuffer.Canvas,
                       x,
                       y,
                       FTabs[index].Caption,
                       AFont.Color,
                       FTabClipRect);
    end;

    procedure DrawTab(index : integer;
                      Border, GradientFrom, GradientTo, TextColor : TColor);

    var TabRect : T2DIntRect;
        TabRegion : HRGN;
        TmpRegion, TmpRegion2 : HRGN;

    begin
    // * Notatka! * Zak³adki zachodz¹ jednym pikslem na obszar toolbara,
    // poniewa¿ musz¹ narysowaæ krawêdŸ, która zgra siê z krawêdzi¹ obszaru.
    TabRect:=FTabRects[index];

    // Œrodkowy prostok¹t
    TabRegion:=CreateRectRgn(TabRect.Left + TAB_CORNER_RADIUS - 1,
                             TabRect.Top + TAB_CORNER_RADIUS,
                             TabRect.Right - TAB_CORNER_RADIUS + 1 + 1,
                             TabRect.Bottom + 1);

    // Górna czêœæ z górnymi zaokr¹gleniami wypuk³ymi
    TmpRegion:=CreateRectRgn(TabRect.Left + 2*TAB_CORNER_RADIUS - 1,
                             TabRect.Top,
                             TabRect.Right - 2*TAB_CORNER_RADIUS + 1 + 1,
                             TabRect.Top + TAB_CORNER_RADIUS);
    CombineRgn(TabRegion, TabRegion, TmpRegion, RGN_OR);
    DeleteObject(TmpRegion);

    TmpRegion:=CreateEllipticRgn(TabRect.Left + TAB_CORNER_RADIUS - 1,
                                 TabRect.Top,
                                 TabRect.Left + 3 * TAB_CORNER_RADIUS,
                                 TabRect.Top + 2 * TAB_CORNER_RADIUS + 1);
    CombineRgn(TabRegion, TabRegion, TmpRegion, RGN_OR);
    DeleteObject(TmpRegion);

    TmpRegion:=CreateEllipticRgn(TabRect.Right - 3 * TAB_CORNER_RADIUS + 2,
                                 TabRect.Top,
                                 TabRect.Right - TAB_CORNER_RADIUS + 3,
                                 TabRect.Top + 2 * TAB_CORNER_RADIUS + 1);
    CombineRgn(TabRegion, TabRegion, TmpRegion, RGN_OR);
    DeleteObject(TmpRegion);

    // Dolna czêœæ z dolnymi zaokr¹gleniami wklês³ymi

    TmpRegion:=CreateRectRgn(TabRect.Left,
                             TabRect.Bottom - TAB_CORNER_RADIUS,
                             TabRect.Right + 1,
                             TabRect.Bottom + 1);

    TmpRegion2:=CreateEllipticRgn(TabRect.Left - TAB_CORNER_RADIUS,
                                  TabRect.Bottom - 2 * TAB_CORNER_RADIUS + 1,
                                  TabRect.Left + TAB_CORNER_RADIUS + 1,
                                  TabRect.Bottom + 2);
    CombineRgn(TmpRegion, TmpRegion, TmpRegion2, RGN_DIFF);
    DeleteObject(TmpRegion2);

    TmpRegion2:=CreateEllipticRgn(TabRect.Right - TAB_CORNER_RADIUS + 1,
                                  TabRect.Bottom - 2 * TAB_CORNER_RADIUS + 1,
                                  TabRect.Right + TAB_CORNER_RADIUS + 2,
                                  TabRect.Bottom + 2);
    CombineRgn(TmpRegion, TmpRegion, TmpRegion2, RGN_DIFF);
    DeleteObject(TmpRegion2);

    CombineRgn(TabRegion, TabRegion, TmpRegion, RGN_OR);
    DeleteObject(TmpRegion);

    TGUITools.DrawRegion(FBuffer.Canvas,
                         TabRegion,
                         TabRect,
                         GradientFrom,
                         GradientTo,
                         bkVerticalGradient);

    DeleteObject(TabRegion);

    // Ramka
    TGuiTools.DrawAARoundCorner(FBuffer,
                                T2DIntPoint.create(TabRect.left, TabRect.bottom - TAB_CORNER_RADIUS + 1),
                                TAB_CORNER_RADIUS,
                                cpRightBottom,
                                Border,
                                FTabClipRect);
    TGuiTools.DrawAARoundCorner(FBuffer,
                                T2DIntPoint.create(TabRect.right - TAB_CORNER_RADIUS + 1, TabRect.bottom - TAB_CORNER_RADIUS + 1),
                                TAB_CORNER_RADIUS,
                                cpLeftBottom,
                                Border,
                                FTabClipRect);

    TGuiTools.DrawVLine(FBuffer,
                        TabRect.left + TAB_CORNER_RADIUS - 1,
                        TabRect.top + TAB_CORNER_RADIUS,
                        TabRect.Bottom - TAB_CORNER_RADIUS + 1,
                        Border,
                        FTabClipRect);
    TGuiTools.DrawVLine(FBuffer,
                        TabRect.Right - TAB_CORNER_RADIUS + 1,
                        TabRect.top + TAB_CORNER_RADIUS,
                        TabRect.Bottom - TAB_CORNER_RADIUS + 1,
                        Border,
                        FTabClipRect);

    TGuiTools.DrawAARoundCorner(FBuffer,
                                T2DIntPoint.create(TabRect.left + TAB_CORNER_RADIUS - 1, 0),
                                TAB_CORNER_RADIUS,
                                cpLeftTop,
                                Border,
                                FTabClipRect);
    TGuiTools.DrawAARoundCorner(FBuffer,
                                T2DIntPoint.Create(TabRect.right - 2*TAB_CORNER_RADIUS + 2, 0),
                                TAB_CORNER_RADIUS,
                                cpRightTop,
                                Border,
                                FTabClipRect);

    TGuiTools.DrawHLine(FBuffer,
                        TabRect.left + 2*TAB_CORNER_RADIUS - 1,
                        TabRect.right - 2*TAB_CORNER_RADIUS + 2,
                        0,
                        Border,
                        FTabClipRect);
    end;

    procedure DrawBottomLine(index : integer;
                             Border : TColor);

    var TabRect : T2DIntRect;

    begin
    TabRect:=FTabRects[index];

    TGUITools.DrawHLine(FBuffer,
                        TabRect.left,
                        TabRect.right,
                        TabRect.bottom,
                        Border,
                        FTabClipRect);
    end;

  begin
  // Zak³adam, ¿e zak³adki maj¹ rozs¹dne rozmiary

  // Pobieramy appearance aktualnie zaznaczonej zak³adki (jej appearance, jeœli
  // ma zapalon¹ flagê OverrideAppearance, FToolbarAppearance w przeciwnym
  // wypadku)
  if (FTabIndex<>-1) and (FTabs[FTabIndex].OverrideAppearance) then
     FocusedAppearance:=FTabs[FTabIndex].CustomAppearance else
     FocusedAppearance:=FAppearance;

  if FTabs.count>0 then
     for i := 0 to FTabs.count - 1 do
         if FTabs[i].Visible then
            begin
            // Jest sens rysowaæ?
            if not(FTabClipRect.IntersectsWith(FTabRects[i])) then
               continue;

            // Pobieramy appearance rysowanej w³aœnie zak³adki
            if (FTabs[i].OverrideAppearance) then
               CurrentAppearance:=FTabs[i].CustomAppearance else
               CurrentAppearance:=FAppearance;

            TabRect:=FTabRects[i];

            // Rysujemy zak³adkê
            if i = FTabIndex then
               begin
               if i = FTabHover then
                  begin
                  DrawTab(i,
                          CurrentAppearance.Tab.BorderColor,
                          TColorTools.Brighten(TColorTools.Brighten(CurrentAppearance.Tab.GradientFromColor, 50),50),
                          CurrentAppearance.Tab.GradientFromColor,
                          CurrentAppearance.Tab.TabHeaderFont.Color);
                  end
               else
                  begin
                  DrawTab(i,
                          CurrentAppearance.Tab.BorderColor,
                          TColorTools.Brighten(CurrentAppearance.Tab.GradientFromColor, 50),
                          CurrentAppearance.Tab.GradientFromColor,
                          CurrentAppearance.Tab.TabHeaderFont.color);
                  end;

               DrawTabText(i, CurrentAppearance.Tab.TabHeaderFont);
               end
            else
               begin
               if i = FTabHover then
                  begin
                  DrawTab(i,
                          TColorTools.Shade(self.Color,CurrentAppearance.Tab.BorderColor,50),
                          TColorTools.Shade(self.color,TColorTools.brighten(CurrentAppearance.Tab.GradientFromColor,50),50),
                          TColorTools.Shade(self.color,CurrentAppearance.Tab.GradientFromColor, 50),
                          CurrentAppearance.Tab.TabHeaderFont.color);
                  end;

               // Dolna kreska
               // Uwaga: Niezale¿nie od zak³adki rysowana kolorem appearance
               // aktualnie zaznaczonej zak³adki!
               DrawBottomLine(i, FocusedAppearance.Tab.BorderColor);

               // Tekst
               DrawTabText(i, CurrentAppearance.Tab.TabHeaderFont);
               end;
            end;
  end;

  procedure DrawTabContents;

  begin
  if FTabIndex<>-1 then
     FTabs[FTabIndex].Draw(FBuffer, FTabContentsClipRect);
  end;

begin
if FInternalUpdating or FUpdating then
   exit;
if FBufferValid then
   exit;

// ValidateBuffer mo¿e byæ wywo³ane tylko wtedy, gdy metrics zosta³y obliczone.
// Metoda zak³ada, ¿e bufor ma ju¿ odpowiednie rozmiary oraz ¿e wszystkie
// recty, zarówno toolbara jak i elementów podrzêdnych, zosta³y poprawnie
// obliczone.

// *** T³o komponentu ***
DrawBackgroundColor;

// *** Generowanie t³a dla toolbara ***
DrawBody;

// *** Zak³adki ***
DrawTabs;

// *** Zawartoœæ zak³adek ***
DrawTabContents;

// Bufor jest poprawny
FBufferValid:=true;
end;

procedure TSpkToolbar.ValidateMetrics;

var i : integer;
    x : integer;
    TabWidth: Integer;
    TabAppearance : TSpkToolbarAppearance;

begin
if FInternalUpdating or FUpdating then
   exit;
if FMetricsValid then
   exit;

FBuffer.SetSize(self.width, self.height);

// *** Zak³adki ***

// Cliprect zak³adek (zawgórn¹ ramkê komponentu)
FTabClipRect:=T2DIntRect.Create(TOOLBAR_CORNER_RADIUS,
                                0,
                                self.width - TOOLBAR_CORNER_RADIUS - 1,
                                TOOLBAR_TAB_CAPTIONS_HEIGHT);

// Recty nag³ówków zak³adek (zawieraj¹ górn¹ ramkê komponentu)
setlength(FTabRects, FTabs.Count);
if FTabs.count>0 then
   begin
   x:=TOOLBAR_CORNER_RADIUS;
   for i := 0 to FTabs.count - 1 do
       if FTabs[i].Visible then
          begin
          // Pobieramy appearance zak³adki
          if FTabs[i].OverrideAppearance then
             TabAppearance:=FTabs[i].CustomAppearance else
             TabAppearance:=FAppearance;
          FBuffer.Canvas.font.assign(TabAppearance.Tab.TabHeaderFont);

          TabWidth:=2 +                                                          // Ramka
                    2*TAB_CORNER_RADIUS +                                        // Zaokr¹glenia
                    2*TOOLBAR_TAB_CAPTIONS_TEXT_HPADDING +                       // Wewnêtrzne marginesy
                    max(TOOLBAR_MIN_TAB_CAPTION_WIDTH,
                        FBuffer.Canvas.TextWidth(FTabs.Items[i].Caption));       // Szerokoœæ tekstu

          FTabRects[i].Left:=x;
          FTabRects[i].Right:=x + TabWidth - 1;
          FTabRects[i].Top:=0;
          FTabRects[i].Bottom:=TOOLBAR_TAB_CAPTIONS_HEIGHT;

          x:=FTabRects[i].right+1;
          end
       else
          begin
          FTabRects[i]:=T2DIntRect.Create(-1,-1,-1,-1);
          end;
   end;

// *** Tafle ***

if FTabIndex<>-1 then
   begin
   // Rect obszaru zak³adki
   FTabContentsClipRect:=T2DIntRect.Create(TOOLBAR_BORDER_WIDTH + TAB_PANE_LEFTPADDING,
                                    TOOLBAR_TAB_CAPTIONS_HEIGHT + TOOLBAR_BORDER_WIDTH + TAB_PANE_TOPPADDING,
                                    self.width - 1 - TOOLBAR_BORDER_WIDTH - TAB_PANE_RIGHTPADDING,
                                    self.Height - 1 - TOOLBAR_BORDER_WIDTH - TAB_PANE_BOTTOMPADDING);

   FTabs[FTabIndex].Rect:=FTabContentsClipRect;
   end;

FMetricsValid:=true;
end;

initialization

RegisterClass(TSpkToolbar);

finalization

UnregisterClass(TSpkToolbar);

end.
