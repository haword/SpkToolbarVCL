unit spkt_Buttons;

(*******************************************************************************
*                                                                              *
*  Plik: spkt_Buttons.pas                                                      *
*  Opis: Modu³ zawieraj¹cy komponenty przycisków dla toolbara.                 *
*  Copyright: (c) 2009 by Spook. Jakiekolwiek u¿ycie komponentu bez            *
*             uprzedniego uzyskania licencji od autora stanowi z³amanie        *
*             prawa autorskiego!                                               *
*                                                                              *
*******************************************************************************)

interface

uses Windows, Graphics, Classes, Controls, Menus, ImgList, ActnList, Math,
     Types, Dialogs,
     SpkGuiTools, SpkGraphTools, SpkMath,
     spkt_Const, spkt_BaseItem, spkt_Exceptions, spkt_Tools;

type TSpkButtonState = (bsIdle,
                        bsBtnHottrack, bsBtnPressed,
                        bsDropdownHottrack, bsDropdownPressed);
     TSpkMouseButtonElement = (beNone, beButton, beDropdown);
     TSpkButtonKind = (bkButton, bkButtonDropdown, bkDropdown);

type TSpkBaseButton = class;

     TSpkButtonActionLink = class(TActionLink)
     private
     protected
       FClient : TSpkBaseButton;

       procedure AssignClient(AClient: TObject); override;
       function IsCaptionLinked: Boolean; override;
       function IsEnabledLinked: Boolean; override;
       function IsVisibleLinked: Boolean; override;
       function IsOnExecuteLinked: Boolean; override;
       procedure SetCaption(const Value: string); override;
       procedure SetEnabled(Value: Boolean); override;
       procedure SetVisible(Value: Boolean); override;
       procedure SetOnExecute(Value: TNotifyEvent); override;
     public
     end;

     TSpkBaseButton = class abstract(TSpkBaseItem)
     private
       FMouseHoverElement : TSpkMouseButtonElement;
       FMouseActiveElement : TSpkMouseButtonElement;
     protected
       FCaption : string;
       FOnClick : TNotifyEvent;

       FActionLink : TSpkButtonActionLink;

       FButtonState : TSpkButtonState;

       FButtonRect : T2DIntRect;
       FDropdownRect : T2DIntRect;

       FButtonKind : TSpkButtonKind;
       FDropdownMenu : TPopupMenu;

     // *** Obs³uga rysowania ***

     /// <summary>Zadaniem metody w odziedziczonych klasach jest obliczenie
     /// rectów przycisku i menu dropdown w zale¿noœci od FButtonState</summary>
       procedure CalcRects; virtual; abstract;

       function GetDropdownPoint : T2DIntPoint; virtual; abstract;

     // *** Obs³uga akcji ***

       procedure ActionChange(Sender : TObject);

     // *** Gettery i settery ***

       procedure SetEnabled(const Value : boolean); override;
       procedure SetDropdownMenu(const Value : TPopupMenu);
       procedure SetRect(const Value: T2DIntRect); override;
       procedure SetCaption(const Value : string);
       procedure SetAction(const Value : TBasicAction);
       procedure SetButtonKind(const Value : TSpkButtonKind);
       function GetAction: TBasicAction;
     public
       constructor Create(AOwner : TComponent); override;

       procedure MouseLeave; override;
       procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
         X, Y: Integer); override;
       procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
       procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
         X, Y: Integer); override;
     published
       property ButtonKind : TSpkButtonKind read FButtonKind write SetButtonKind;
       property DropdownMenu : TPopupMenu read FDropdownMenu write SetDropdownMenu;
       property Caption : string read FCaption write SetCaption;
       property Action : TBasicAction read GetAction write SetAction;
       property OnClick : TNotifyEvent read FOnClick write FOnClick;
     end;

type TSpkLargeButton = class(TSpkBaseButton)
     private
       procedure FindBreakPlace(s : string; out Position : integer; out Width : integer);
     protected
       FLargeImageIndex : integer;

       procedure CalcRects; override;
       function GetDropdownPoint : T2DIntPoint; override;
       procedure SetLargeImageIndex(const Value: integer);
     public
       constructor Create(AOwner : TComponent); override;
       function GetWidth : integer; override;
       function GetTableBehaviour : TSpkItemTableBehaviour; override;
       function GetGroupBehaviour : TSpkItemGroupBehaviour; override;
       function GetSize : TSpkItemSize; override;
       procedure Draw(ABuffer : TBitmap; ClipRect : T2DIntRect); override;
     published
       property LargeImageIndex : integer read FLargeImageIndex write SetLargeImageIndex;
     end;

type TSpkSmallButton = class(TSpkBaseButton)
     private
     protected
       FImageIndex : integer;

       FTableBehaviour : TSpkItemTableBehaviour;
       FGroupBehaviour : TSPkItemGroupBehaviour;
       FHideFrameWhenIdle : boolean;
       FShowCaption : boolean;

       procedure CalcRects; override;
       function GetDropdownPoint : T2DIntPoint; override;
       procedure ConstructRects(var BtnRect, DropRect : T2DIntRect);
       procedure SetImageIndex(const Value : integer);
       procedure SetGroupBehaviour(const Value: TSpkItemGroupBehaviour);
       procedure SetHideFrameWhenIdle(const Value: boolean);
       procedure SetTableBehaviour(const Value: TSpkItemTableBehaviour);
       procedure SetShowCaption(const Value: boolean);
     public
       constructor Create(AOwner : TComponent); override;

       function GetWidth : integer; override;
       function GetTableBehaviour : TSpkItemTableBehaviour; override;
       function GetGroupBehaviour : TSpkItemGroupBehaviour; override;
       function GetSize : TSpkItemSize; override;
       procedure Draw(ABuffer : TBitmap; ClipRect : T2DIntRect); override;
     published
       property ShowCaption : boolean read FShowCaption write SetShowCaption;
       property TableBehaviour : TSpkItemTableBehaviour read FTableBehaviour write SetTableBehaviour;
       property GroupBehaviour : TSpkItemGroupBehaviour read FGroupBehaviour write SetGroupBehaviour;
       property HideFrameWhenIdle : boolean read FHideFrameWhenIdle write SetHideFrameWhenIdle;
       property ImageIndex : integer read FImageIndex write SetImageIndex;
     end;

implementation

{ TSpkButtonActionLink }

procedure TSpkButtonActionLink.AssignClient(AClient: TObject);
begin
  inherited AssignClient(AClient);
  FClient:=TSpkBaseButton(AClient);
end;

function TSpkButtonActionLink.IsCaptionLinked: Boolean;
begin
result:=(inherited IsCaptionLinked) and
        (assigned(FClient)) and
        (FClient.Caption = (Action as TCustomAction).Caption);
end;

function TSpkButtonActionLink.IsEnabledLinked: Boolean;
begin
result:=(inherited IsEnabledLinked) and
        (assigned(FClient)) and
        (FClient.Enabled = (Action as TCustomAction).Enabled);
end;

function TSpkButtonActionLink.IsOnExecuteLinked: Boolean;
begin
  Result := inherited IsOnExecuteLinked and
    (@TSpkBaseButton(FClient).OnClick = @Action.OnExecute);
end;

function TSpkButtonActionLink.IsVisibleLinked: Boolean;
begin
result:=(inherited IsVisibleLinked) and
        (assigned(FClient)) and
        (FClient.Visible = (Action as TCustomAction).Visible);
end;

procedure TSpkButtonActionLink.SetCaption(const Value: string);
begin
  if IsCaptionLinked then FClient.Caption := Value;
end;

procedure TSpkButtonActionLink.SetEnabled(Value: Boolean);
begin
  if IsEnabledLinked then FClient.Enabled := Value;
end;

procedure TSpkButtonActionLink.SetOnExecute(Value: TNotifyEvent);
begin
  if IsOnExecuteLinked then FClient.OnClick := Value;
end;

procedure TSpkButtonActionLink.SetVisible(Value: Boolean);
begin
  if IsVisibleLinked then FClient.Visible := Value;
end;

{ TSpkBaseButton }

procedure TSpkBaseButton.ActionChange(Sender: TObject);
begin
  if Sender is TCustomAction then
    with TCustomAction(Sender) do
    begin
      if (Self.Caption = '') or (Self.Caption = 'Button') then
         Self.Caption := Caption;
      if (Self.Enabled = True) then
         Self.Enabled := Enabled;
      if (Self.Visible = True) then
         Self.Visible := Visible;
      if not Assigned(Self.OnClick) then
         Self.OnClick := OnExecute;
    end;
end;

constructor TSpkBaseButton.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FCaption:='Button';
  FOnClick:=nil;
  FActionLink:=nil;
  FButtonState:=bsIdle;
  FButtonRect:=T2DIntRect.Create(0, 0, 1, 1);
  FButtonKind:=bkButton;
  FDropdownRect:=T2DIntRect.Create(0, 0, 1, 1);
  FDropdownMenu:=nil;
  FMouseHoverElement:=beNone;
  FMouseActiveElement:=beNone;
end;

function TSpkBaseButton.GetAction: TBasicAction;
begin
if assigned(FActionLink) then
   result:=FActionLink.Action else
   result:=nil;
end;

procedure TSpkBaseButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
if FEnabled then
   begin
   // Przyciski reaguj¹ tylko na lewy przycisk myszy
   if Button <> mbLeft then
      exit;

   if FMouseActiveElement = beButton then
      begin
      if FButtonState<>bsBtnPressed then
         begin
         FButtonState:=bsBtnPressed;
         if assigned(FToolbarDispatch) then
            FToolbarDispatch.NotifyVisualsChanged;
         end;
      end else
   if FMouseActiveElement = beDropdown then
      begin
      if FButtonState<>bsDropdownPressed then
         begin
         FButtonState:=bsDropdownPressed;
         if assigned(FToolbarDispatch) then
            FToolbarDispatch.NotifyVisualsChanged;
         end;
      end else
   if FMouseActiveElement = beNone then
      begin
      if FMouseHoverElement = beButton then
         begin
         FMouseActiveElement:=beButton;

         if FButtonState<>bsBtnPressed then
            begin
            FButtonState:=bsBtnPressed;
            if FToolbarDispatch<>nil then
               FToolbarDispatch.NotifyVisualsChanged;
            end;
         end else
      if FMouseHoverElement = beDropdown then
         begin
         FMouseActiveElement:=beDropdown;

         if FButtonState<>bsDropdownPressed then
            begin
            FButtonState:=bsDropdownPressed;
            if FToolbarDispatch<>nil then
               FToolbarDispatch.NotifyVisualsChanged;
            end;
         end;
      end;
   end
else
   begin
   FMouseHoverElement:=beNone;
   FMouseActiveElement:=beNone;
   if FButtonState<>bsIdle then
      begin
      FButtonState:=bsIdle;

      if assigned(FToolbarDispatch) then
         FToolbarDispatch.NotifyVisualsChanged;
      end;
   end;
end;

procedure TSpkBaseButton.MouseLeave;
begin
if FEnabled then
   begin
   if FMouseActiveElement = beNone then
      begin
      if FMouseHoverElement = beButton then
         begin
         // Placeholder, gdyby zasz³a potrzeba obs³ugi tego zdarzenia
         end else
      if FMouseHoverElement = beDropdown then
         begin
         // Placeholder, gdyby zasz³a potrzeba obs³ugi tego zdarzenia
         end;
      end;

   if FButtonState<>bsIdle then
      begin
      FButtonState:=bsIdle;
      if assigned(FToolbarDispatch) then
         FToolbarDispatch.NotifyVisualsChanged;
      end;
   end
else
   begin
   FMouseHoverElement:=beNone;
   FMouseActiveElement:=beNone;
   if FButtonState<>bsIdle then
      begin
      FButtonState:=bsIdle;

      if assigned(FToolbarDispatch) then
         FToolbarDispatch.NotifyVisualsChanged;
      end;
   end;
end;

procedure TSpkBaseButton.MouseMove(Shift: TShiftState; X, Y: Integer);

var NewMouseHoverElement : TSpkMouseButtonElement;

begin
if FEnabled then
   begin
   if FButtonRect.Contains(T2DIntPoint.Create(X,Y)) then
      NewMouseHoverElement:=beButton else
   if (FButtonKind = bkButtonDropdown) and
      (FDropdownRect.Contains(T2DIntPoint.Create(X,Y))) then
      NewMouseHoverElement:=beDropdown else
      NewMouseHoverElement:=beNone;

   if FMouseActiveElement = beButton then
      begin
      if (NewMouseHoverElement = beNone) and (FButtonState<>bsIdle) then
         begin
         FButtonState:=bsIdle;
         if FToolbarDispatch<>nil then
            FToolbarDispatch.NotifyVisualsChanged;
         end else
      if (NewMouseHoverElement = beButton) and (FButtonState<>bsBtnPressed) then
         begin
         FButtonState:=bsBtnPressed;
         if FToolbarDispatch<>nil then
            FToolbarDispatch.NotifyVisualsChanged;
         end;
      end else
   if FMouseActiveElement = beDropdown then
      begin
      if (NewMouseHoverElement = beNone) and (FButtonState<>bsIdle) then
         begin
         FButtonState:=bsIdle;
         if FToolbarDispatch<>nil then
            FToolbarDispatch.NotifyVisualsChanged;
         end else
      if (NewMouseHoverElement = beDropdown) and (FButtonState<>bsDropdownPressed) then
         begin
         FButtonState:=bsDropdownPressed;
         if FToolbarDispatch<>nil then
            FToolbarDispatch.NotifyVisualsChanged;
         end;
      end else
   if FMouseActiveElement = beNone then
      begin
      // Z uwagi na uproszczon¹ obs³ugê myszy w przycisku, nie ma potrzeby
      // informowaæ poprzedniego elementu o tym, ¿e mysz opuœci³a jego obszar.

      if NewMouseHoverElement = beButton then
         begin
         if FButtonState<>bsBtnHottrack then
            begin
            FButtonState:=bsBtnHottrack;
            if FToolbarDispatch<>nil then
               FToolbarDispatch.NotifyVisualsChanged;
            end;
         end else
      if NewMouseHoverElement = beDropdown then
         begin
         if FButtonState<>bsDropdownHottrack then
            begin
            FButtonState:=bsDropdownHottrack;
            if FToolbarDispatch<>nil then
               FToolbarDispatch.NotifyVisualsChanged;
            end;
         end;
      end;

   FMouseHoverElement:=NewMouseHoverElement;
   end
else
   begin
   FMouseHoverElement:=beNone;
   FMouseActiveElement:=beNone;
   if FButtonState<>bsIdle then
      begin
      FButtonState:=bsIdle;

      if assigned(FToolbarDispatch) then
         FToolbarDispatch.NotifyVisualsChanged;
      end;
   end;
end;

procedure TSpkBaseButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);

var ClearActive : boolean;
  DropPoint: T2DIntPoint;

begin
if FEnabled then
   begin
   // Przyciski reaguj¹ tylko na lewy przycisk myszy
   if Button <> mbLeft then
      exit;

   ClearActive:=not(ssLeft in Shift);

   if FMouseActiveElement = beButton then
      begin
      // Zdarzenie zadzia³a tylko wtedy, gdy przycisk myszy zosta³ puszczony nad
      // przyciskiem
      if FMouseHoverElement = beButton then
         begin
         if FButtonKind in [bkButton, bkButtonDropdown] then
            begin
            if assigned(FOnClick) then
               FOnClick(self)
            end else
         if FButtonKind = bkDropdown then
            begin
            if assigned(FDropdownMenu) then
               begin
               DropPoint:=FToolbarDispatch.ClientToScreen(GetDropdownPoint);
               FDropdownMenu.Popup(DropPoint.x, DropPoint.y);
               end;
            end;
         end;
      end else
   if FMouseActiveElement = beDropDown then
      begin
      // Zdarzenie zadzia³a tylko wtedy, gdy przycisk myszy zosta³ puszczony nad
      // przyciskiem DropDown

      if FMouseHoverElement = beDropDown then
         begin
         if assigned(FDropdownMenu) then
            begin
            DropPoint:=FToolbarDispatch.ClientToScreen(GetDropdownPoint);
            FDropdownMenu.Popup(DropPoint.x, DropPoint.y);
            end;
         end;
      end;

   if (ClearActive) and (FMouseActiveElement<>FMouseHoverElement) then
      begin
      // Z uwagi na uproszczon¹ obs³ugê, nie ma potrzeby informowaæ poprzedniego
      // elementu o tym, ¿e mysz opuœci³a jego obszar.

      if FMouseHoverElement = beButton then
         begin
         if FButtonState<>bsBtnHottrack then
            begin
            FButtonState:=bsBtnHottrack;
            if assigned(FToolbarDispatch) then
               FToolbarDispatch.NotifyVisualsChanged;
            end;
         end else
      if FMouseHoverElement = beDropdown then
         begin
         if FButtonState<>bsDropdownHottrack then
            begin
            FButtonState:=bsDropdownHottrack;
            if assigned(FToolbarDispatch) then
               FToolbarDispatch.NotifyVisualsChanged;
            end;
         end else
      if FMouseHoverElement = beNone then
         begin
         if FButtonState <> bsIdle then
            begin
            FButtonState:=bsIdle;
            if assigned(FToolbarDispatch) then
               FToolbarDispatch.NotifyVisualsChanged;
            end;
         end;
      end;

   if ClearActive then
      begin
      FMouseActiveElement:=beNone;
      end;
   end
else
   begin
   FMouseHoverElement:=beNone;
   FMouseActiveElement:=beNone;
   if FButtonState<>bsIdle then
      begin
      FButtonState:=bsIdle;

      if assigned(FToolbarDispatch) then
         FToolbarDispatch.NotifyVisualsChanged;
      end;
   end;

end;

procedure TSpkBaseButton.SetAction(const Value: TBasicAction);
begin
  if Value = nil then
     begin
     FActionLink.Free;
     FActionLink := nil;
     end
  else
     begin
     if FActionLink = nil then
        FActionLink := TSpkButtonActionLink.Create(self);
    FActionLink.Action := Value;
    FActionLink.OnChange := ActionChange;
    ActionChange(Value);
  end;
end;

procedure TSpkBaseButton.SetButtonKind(const Value: TSpkButtonKind);
begin
  FButtonKind:=Value;
  if assigned(FToolbarDispatch) then
     FToolbarDispatch.NotifyMetricsChanged;
end;

procedure TSpkBaseButton.SetCaption(const Value: string);
begin
  FCaption:=Value;
  if assigned(FToolbarDispatch) then
     FToolbarDispatch.NotifyMetricsChanged;
end;

procedure TSpkBaseButton.SetDropdownMenu(const Value: TPopupMenu);
begin
  FDropdownMenu:=Value;
  if assigned(FToolbarDispatch) then
     FToolbarDispatch.NotifyMetricsChanged;
end;

procedure TSpkBaseButton.SetEnabled(const Value: boolean);
begin
  inherited;
  if not(FEnabled) then
     begin
     // Jeœli przycisk zosta³ wy³¹czony, zostaje natychmiast prze³¹czony
     // w stan Idle i zerowane s¹ elementy aktywne i pod mysz¹. Jeœli zosta³
     // w³¹czony, jego stan zmieni siê podczas pierwszej akcji myszy.

     FMouseHoverElement:=beNone;
     FMouseActiveElement:=beNone;

     if FButtonState<>bsIdle then
        begin
        FButtonState:=bsIdle;

        if assigned(FToolbarDispatch) then
           FToolbarDispatch.NotifyVisualsChanged;
        end;
     end;
end;

procedure TSpkBaseButton.SetRect(const Value: T2DIntRect);
begin
  inherited;
  CalcRects;
end;

{ TSpkLargeButton }

procedure TSpkLargeButton.CalcRects;
begin
if FButtonKind = bkButtonDropdown then
   begin
   FButtonRect:=T2DIntRect.Create(FRect.Left, FRect.Top, FRect.Right, FRect.Bottom - LARGEBUTTON_DROPDOWN_FIELD_SIZE);
   FDropdownRect:=T2DIntRect.Create(FRect.Left, FRect.Bottom - LARGEBUTTON_DROPDOWN_FIELD_SIZE + 1, FRect.Right, FRect.Bottom);
   end
else
   begin
   FButtonRect:=FRect;
   FDropdownRect:=T2DIntRect.Create(0, 0, 0, 0);
   end;
end;

constructor TSpkLargeButton.Create(AOwner: TComponent);
begin
  inherited;
  FLargeImageIndex:=-1;
end;

procedure TSpkLargeButton.Draw(ABuffer: TBitmap; ClipRect: T2DIntRect);

var FrameColor: TColor;
    InnerLightColor: TColor;
    InnerDarkColor: TColor;
    GradientFromColor: TColor;
    GradientToColor: TColor;
    GradientKind : TBackgroundKind;
    DrawRgn, TmpRgn : HRGN;
    x: Integer;
    y: Integer;

    FontColor: TColor;
    BreakPos: Integer;
    BreakWidth: Integer;
    s: string;
    TextHeight: Integer;

begin
if FToolbarDispatch=nil then
   exit;
if FAppearance=nil then
   exit;

if (FRect.width<2*LARGEBUTTON_RADIUS) or (FRect.Height<2*LARGEBUTTON_RADIUS) then
   exit;

if FButtonKind in [bkButton, bkDropdown] then
   begin
   {$REGION 'Tryb bez dodatkowego przycisku z rozwijanym menu'}
   // *** T³o ***
   if not(FEnabled) then
      begin
      {$REGION 'T³o dla disabled'}
      // Brak t³a
      {$ENDREGION}
      end else
   if FButtonState = bsIdle then
      begin
      {$REGION 'T³o dla Idle'}
      // Brak t³a
      {$ENDREGION}
      end else
   if FButtonState = bsBtnHottrack then
      begin
      {$REGION 'T³o dla HotTrack'}
      TGuiTools.DrawRoundRect(ABuffer.Canvas,
                              T2DIntRect.Create(FButtonRect.left,
                                                FButtonRect.Top,
                                                FButtonRect.Right,
                                                FButtonRect.Bottom),
                              LARGEBUTTON_RADIUS,
                              FAppearance.Element.HotTrackGradientFromColor,
                              FAppearance.Element.HotTrackGradientToColor,
                              FAppearance.Element.HotTrackGradientType,
                              ClipRect);

      TGuiTools.DrawAARoundFrame(ABuffer,
                                 T2DIntRect.Create(FButtonRect.left+1,
                                                   FButtonRect.top+1,
                                                   FButtonRect.right-1,
                                                   FButtonRect.Bottom-1),
                                 LARGEBUTTON_RADIUS,
                                 FAppearance.Element.HotTrackInnerLightColor,
                                 ClipRect);
      TGuiTools.DrawAARoundFrame(ABuffer,
                                 FButtonRect,
                                 LARGEBUTTON_RADIUS,
                                 FAppearance.Element.HotTrackFrameColor,
                                 ClipRect);
      {$ENDREGION}
      end else
   if FButtonState = bsBtnPressed then
      begin
      {$REGION 'T³o dla Pressed'}
      TGuiTools.DrawRoundRect(ABuffer.Canvas,
                              T2DIntRect.Create(FButtonRect.left,
                                                FButtonRect.Top,
                                                FButtonRect.Right,
                                                FButtonRect.Bottom),
                              LARGEBUTTON_RADIUS,
                              FAppearance.Element.ActiveGradientFromColor,
                              FAppearance.Element.ActiveGradientToColor,
                              FAppearance.Element.ActiveGradientType,
                              ClipRect);


      TGuiTools.DrawAARoundFrame(ABuffer,
                                 T2DIntRect.Create(FButtonRect.left+1,
                                                   FButtonRect.top+1,
                                                   FButtonRect.right-1,
                                                   FButtonRect.Bottom-1),
                                 LARGEBUTTON_RADIUS,
                                 FAppearance.Element.ActiveInnerLightColor,
                                 ClipRect);
      TGuiTools.DrawAARoundFrame(ABuffer,
                                 FButtonRect,
                                 LARGEBUTTON_RADIUS,
                                 FAppearance.Element.ActiveFrameColor,
                                 ClipRect);
      {$ENDREGION}
      end else
          raise InternalException.create('TSpkLargeButton.Draw: Nieprawid³owa wartoœæ FButtonState!');

   // *** Ikona ***
   if not(FEnabled) then
      begin
      {$REGION 'Ikona wy³¹czona'}
      if (FLargeImageIndex>=0) and
         (FDisabledLargeImages<>nil) and
         (FLargeImageIndex<FDisabledLargeImages.Count) then
         begin
         x:=FRect.left + (FRect.Width - FLargeImages.Width) div 2;
         y:=FRect.top + LARGEBUTTON_BORDER_SIZE + LARGEBUTTON_GLYPH_MARGIN;

         TGuiTools.DrawImage(ABuffer.Canvas,
                             FDisabledLargeImages,
                             FLargeImageIndex,
                             T2DIntPoint.Create(x, y),
                             ClipRect);
         end else
      if (FLargeImageIndex>=0) and
         (FLargeImages<>nil) and
         (FLargeImageIndex<FLargeImages.Count) then
         begin
         x:=FRect.left + (FRect.Width - FLargeImages.Width) div 2;
         y:=FRect.top + LARGEBUTTON_BORDER_SIZE + LARGEBUTTON_GLYPH_MARGIN;

         TGuiTools.DrawDisabledImage(ABuffer.Canvas,
                                     FLargeImages,
                                     FLargeImageIndex,
                                     T2DIntPoint.Create(x, y),
                                     ClipRect);
         end;
      {$ENDREGION}
      end
   else
      begin
      {$REGION 'Ikona zwyk³a'}
      if (FLargeImageIndex>=0) and
         (FLargeImages<>nil) and
         (FLargeImageIndex<FLargeImages.Count) then
         begin
         x:=FRect.left + (FRect.Width - FLargeImages.Width) div 2;
         y:=FRect.top + LARGEBUTTON_BORDER_SIZE + LARGEBUTTON_GLYPH_MARGIN;

         TGUITools.DrawImage(ABuffer.Canvas,
                             FLargeImages,
                             FLargeImageIndex,
                             T2DIntPoint.Create(x,y),
                             ClipRect);
         end;
      {$ENDREGION}
      end;

   // *** Tekst ***

   if not(FEnabled) then
      begin
      FontColor:=clNone;
      case FButtonState of
           bsIdle: FontColor:=TColorTools.ColorToGrayscale(FAppearance.Element.IdleCaptionColor);
           bsBtnHottrack,
           bsDropdownHottrack : FontColor:=TColorTools.ColorToGrayscale(FAppearance.Element.HotTrackCaptionColor);
           bsBtnPressed,
           bsDropdownPressed: FontColor:=TColorTools.ColorToGrayscale(FAppearance.ELement.ActiveCaptionColor);
      end;
      end
   else
      begin
      FontColor:=clNone;
      case FButtonState of
           bsIdle: FontColor:=FAppearance.Element.IdleCaptionColor;
           bsBtnHottrack,
           bsDropdownHottrack : FontColor:=FAppearance.Element.HotTrackCaptionColor;
           bsBtnPressed,
           bsDropdownPressed: FontColor:=FAppearance.ELement.ActiveCaptionColor;
      end;
      end;

   ABuffer.Canvas.Font.assign(FAppearance.Element.CaptionFont);
   ABuffer.Canvas.Font.Color:=FontColor;

   if FButtonKind = bkButton then
      FindBreakPlace(FCaption, BreakPos, BreakWidth) else
      BreakPos:=0;

   if BreakPos>0 then
      begin
      // Tekst z³amany
      TextHeight:=ABuffer.Canvas.Textheight('Wy');

      s:=copy(FCaption, 1, BreakPos-1);
      x:=FRect.Left + (FRect.width - ABuffer.Canvas.Textwidth(s)) div 2;
      y:=FRect.Top + LARGEBUTTON_CAPTION_TOP_RAIL - TextHeight div 2;
      TGUITools.DrawText(ABuffer.Canvas, x, y, s, FontColor, ClipRect);

      s:=copy(FCaption, BreakPos+1, length(FCaption) - BreakPos);
      x:=FRect.Left + (FRect.width - ABuffer.Canvas.Textwidth(s)) div 2;
      y:=FRect.Top + LARGEBUTTON_CAPTION_BOTTOM_RAIL - TextHeight div 2;
      TGUITools.DrawText(ABuffer.Canvas, x, y, s, FontColor, ClipRect);
      end
   else
      begin
      // Tekst nie z³amany
      TextHeight:=ABuffer.Canvas.Textheight('Wy');

      x:=FButtonRect.Left + (FButtonRect.width - ABuffer.Canvas.Textwidth(FCaption)) div 2;
      y:=FRect.Top + LARGEBUTTON_CAPTION_TOP_RAIL - TextHeight div 2;
      TGUITools.DrawText(ABuffer.Canvas, x, y, FCaption, FontColor, ClipRect);
      end;

   if FButtonKind = bkDropdown then
      begin
      // Chevron strza³ki w dó³

      if not(FEnabled) then
         begin
         case FButtonState of
              bsIdle: FontColor:=TColorTools.ColorToGrayscale(FAppearance.Element.IdleCaptionColor);
              bsBtnHottrack,
              bsDropdownHottrack : FontColor:=TColorTools.ColorToGrayscale(FAppearance.Element.HotTrackCaptionColor);
              bsBtnPressed,
              bsDropdownPressed: FontColor:=TColorTools.ColorToGrayscale(FAppearance.ELement.ActiveCaptionColor);
         end;
         end
      else
         begin
         case FButtonState of
              bsIdle: FontColor:=FAppearance.Element.IdleCaptionColor;
              bsBtnHottrack,
              bsDropdownHottrack : FontColor:=FAppearance.Element.HotTrackCaptionColor;
              bsBtnPressed,
              bsDropdownPressed: FontColor:=FAppearance.ELement.ActiveCaptionColor;
         end;
         end;

      ABuffer.Canvas.Font.Charset:=DEFAULT_CHARSET;
      ABuffer.Canvas.Font.Name:='Marlett';
      ABuffer.Canvas.Font.Size:=8;
      ABuffer.Canvas.Font.Style:=[];
      ABuffer.Canvas.Font.Orientation:=0;

      x:=FButtonRect.Left + (FButtonRect.width - ABuffer.Canvas.Textwidth('u')) div 2;
      y:=FButtonRect.bottom - ABuffer.Canvas.Textheight('u') - LARGEBUTTON_CHEVRON_HMARGIN;
      TGUITools.DrawText(ABuffer.Canvas, x, y, 'u', FontColor, ClipRect);
      end;

   {$ENDREGION}
   end
else
   begin
   {$REGION 'Tryb z rozwijanym menu'}
   // *** T³o ***
   if not(FEnabled) then
      begin
      {$REGION 'T³o dla Disabled'}
      //
      {$ENDREGION}
      end else
   if FButtonState = bsIdle then
      begin
      {$REGION 'T³o dla Idle'}
      //
      {$ENDREGION}
      end else
   if (FButtonState = bsBtnHottrack) or (FButtonState = bsDropdownHottrack) or
      (FButtonState = bsBtnPressed) or (FButtonState = bsDropdownPressed) then
      begin
      {$REGION 'T³o dla aktywnego'}

      // *** Przycisk ***

      {$REGION 'Ustalanie kolorów'}
      if FButtonState = bsBtnHottrack then
         begin
         FrameColor:=FAppearance.Element.HotTrackFrameColor;
         InnerLightColor:=FAppearance.Element.HotTrackInnerLightColor;
         GradientFromColor:=FAppearance.Element.HotTrackGradientFromColor;
         GradientToColor:=FAppearance.Element.HotTrackGradientToColor;
         GradientKind:=FAppearance.Element.HotTrackGradientType;
         end else
      if FButtonState = bsBtnPressed then
         begin
         FrameColor:=FAppearance.Element.ActiveFrameColor;
         InnerLightColor:=FAppearance.Element.ActiveInnerLightColor;
         GradientFromColor:=FAppearance.Element.ActiveGradientFromColor;
         GradientToColor:=FAppearance.Element.ActiveGradientToColor;
         GradientKind:=FAppearance.Element.ActiveGradientType;
         end
      else
         begin
         FrameColor:=TColorTools.Brighten(FAppearance.Element.HotTrackFrameColor,40);
         InnerLightColor:=TColorTools.Brighten(FAppearance.Element.HotTrackInnerLightColor,40);
         GradientFromColor:=TColorTools.Brighten(FAppearance.Element.HotTrackGradientFromColor,40);
         GradientToColor:=TColorTools.Brighten(FAppearance.Element.HotTrackGradientToColor,40);
         GradientKind:=FAppearance.Element.HotTrackGradientType;
         end;
      {$ENDREGION}

      {$REGION 'T³o przycisku'}
      DrawRgn:=CreateRectRgn(FButtonRect.Left,
                             FButtonRect.Top + LARGEBUTTON_RADIUS,
                             FButtonRect.Right + 1,
                             FButtonRect.Bottom);

      TmpRgn:=CreateRectRgn(FButtonRect.left + LARGEBUTTON_RADIUS,
                            FButtonRect.Top,
                            FButtonRect.right - LARGEBUTTON_RADIUS + 1,
                            FButtonRect.Top + LARGEBUTTON_RADIUS);
      CombineRgn(DrawRgn, DrawRgn, TmpRgn, RGN_OR);
      DeleteObject(TmpRgn);

      TmpRgn:=CreateEllipticRgn(FButtonRect.Left,
                                FButtonRect.Top,
                                FButtonRect.Left + 2 * LARGEBUTTON_RADIUS + 1,
                                FButtonRect.Top + 2 * LARGEBUTTON_RADIUS + 1);
      CombineRgn(DrawRgn, DrawRgn, TmpRgn, RGN_OR);
      DeleteObject(TmpRgn);

      TmpRgn:=CreateEllipticRgn(FButtonRect.Right - 2 * LARGEBUTTON_RADIUS + 1,
                                FButtonRect.Top,
                                FButtonRect.Right + 2,
                                FButtonRect.Top + 2 * LARGEBUTTON_RADIUS + 1);
      CombineRgn(DrawRgn, DrawRgn, TmpRgn, RGN_OR);
      DeleteObject(TmpRgn);

      TGuiTools.DrawRegion(ABuffer.Canvas,
                           DrawRgn,
                           FRect,
                           GradientFromColor,
                           GradientToColor,
                           GradientKind,
                           ClipRect);
      DeleteObject(DrawRgn);
      {$ENDREGION}

      {$REGION 'Ramka przycisku'}
      // Wewnêtrzna ramka
      TGuiTools.DrawAARoundCorner(ABuffer,
                                  T2DIntPoint.Create(FButtonRect.Left + 1, FButtonRect.Top + 1),
                                  LARGEBUTTON_RADIUS,
                                  cpLeftTop,
                                  InnerLightColor,
                                  ClipRect);
      TGuiTools.DrawAARoundCorner(ABuffer,
                                  T2DIntPoint.Create(FButtonRect.Right - LARGEBUTTON_RADIUS, FButtonRect.Top + 1),
                                  LARGEBUTTON_RADIUS,
                                  cpRightTop,
                                  InnerLightColor,
                                  ClipRect);
      TGuiTools.DrawHLine(ABuffer,
                          FButtonRect.Left + LARGEBUTTON_RADIUS + 1,
                          FButtonRect.Right - LARGEBUTTON_RADIUS - 1,
                          FButtonRect.Top + 1,
                          InnerLightColor,
                          ClipRect);
      TGuiTools.DrawVLine(ABuffer,
                          FButtonRect.Left + 1,
                          FButtonRect.Top + LARGEBUTTON_RADIUS + 1,
                          FButtonRect.Bottom,
                          InnerLightColor,
                          ClipRect);
      TGuiTools.DrawVLine(ABuffer,
                          FButtonRect.Right - 1,
                          FButtonRect.Top + LARGEBUTTON_RADIUS + 1,
                          FButtonRect.Bottom,
                          InnerLightColor,
                          ClipRect);

      if FButtonState = bsBtnPressed then
         TGuiTools.DrawHLine(ABuffer,
                             FButtonRect.Left + 1,
                             FButtonRect.Right - 1,
                             FButtonRect.Bottom,
                             FrameColor,
                             ClipRect) else
         TGuiTools.DrawHLine(ABuffer,
                             FButtonRect.Left + 1,
                             FButtonRect.Right - 1,
                             FButtonRect.Bottom,
                             InnerLightColor,
                             ClipRect);

      // Zewnêtrzna ramka
      TGuiTools.DrawAARoundCorner(ABuffer,
                                  T2DIntPoint.Create(FButtonRect.Left, FButtonRect.Top),
                                  LARGEBUTTON_RADIUS,
                                  cpLeftTop,
                                  FrameColor,
                                  ClipRect);
      TGuiTools.DrawAARoundCorner(ABuffer,
                                  T2DIntPoint.Create(FButtonRect.Right - LARGEBUTTON_RADIUS + 1, FButtonRect.Top),
                                  LARGEBUTTON_RADIUS,
                                  cpRightTop,
                                  FrameColor,
                                  ClipRect);
      TGuiTools.DrawHLine(ABuffer,
                          FButtonRect.Left + LARGEBUTTON_RADIUS,
                          FButtonRect.Right - LARGEBUTTON_RADIUS,
                          FButtonRect.Top,
                          FrameColor,
                          ClipRect);
      TGuiTools.DrawVLine(ABuffer,
                          FButtonRect.Left,
                          FButtonRect.Top + LARGEBUTTON_RADIUS,
                          FButtonRect.Bottom,
                          FrameColor,
                          ClipRect);
      TGuiTools.DrawVLine(ABuffer,
                          FButtonRect.Right,
                          FButtonRect.Top + LARGEBUTTON_RADIUS,
                          FButtonRect.Bottom,
                          FrameColor,
                          ClipRect);
      {$ENDREGION}

      // *** Dropdown ***

      {$REGION 'Ustalanie kolorów'}
      if FButtonState = bsDropdownHottrack then
         begin
         FrameColor:=FAppearance.Element.HotTrackFrameColor;
         InnerLightColor:=FAppearance.Element.HotTrackInnerLightColor;
         InnerDarkColor:=FAppearance.Element.HotTrackInnerDarkColor;
         GradientFromColor:=FAppearance.Element.HotTrackGradientFromColor;
         GradientToColor:=FAppearance.Element.HotTrackGradientToColor;
         GradientKind:=FAppearance.Element.HotTrackGradientType;
         end else
      if FButtonState = bsDropdownPressed then
         begin
         FrameColor:=FAppearance.Element.ActiveFrameColor;
         InnerLightColor:=FAppearance.Element.ActiveInnerLightColor;
         InnerDarkColor:=FAppearance.Element.ActiveInnerDarkColor;
         GradientFromColor:=FAppearance.Element.ActiveGradientFromColor;
         GradientToColor:=FAppearance.Element.ActiveGradientToColor;
         GradientKind:=FAppearance.Element.ActiveGradientType;
         end
      else
         begin
         FrameColor:=TColorTools.Brighten(FAppearance.Element.HotTrackFrameColor,20);
         InnerLightColor:=TColorTools.Brighten(FAppearance.Element.HotTrackInnerLightColor,20);
         InnerDarkColor:=TColorTools.Brighten(FAppearance.Element.HotTrackInnerDarkColor,20);
         GradientFromColor:=TColorTools.Brighten(FAppearance.Element.HotTrackGradientFromColor,20);
         GradientToColor:=TColorTools.Brighten(FAppearance.Element.HotTrackGradientToColor,20);
         GradientKind:=FAppearance.Element.HotTrackGradientType;
         end;
      {$ENDREGION}

      {$REGION 'T³o dropdown'}
      DrawRgn:=CreateRectRgn(FDropdownRect.left,
                             FDropdownRect.Top,
                             FDropdownRect.Right + 1,
                             FDropdownRect.Bottom - LARGEBUTTON_RADIUS + 1);

      TmpRgn:=CreateRectRgn(FDropdownRect.left + LARGEBUTTON_RADIUS,
                            FDropdownRect.Bottom - LARGEBUTTON_RADIUS + 1,
                            FDropdownRect.Right - LARGEBUTTON_RADIUS + 1,
                            FDropdownRect.Bottom + 1);
      CombineRgn(DrawRgn, DrawRgn, TmpRgn, RGN_OR);
      DeleteObject(TmpRgn);

      TmpRgn:=CreateEllipticRgn(FDropdownRect.Left,
                                FDropdownRect.bottom - 2 * LARGEBUTTON_RADIUS + 1,
                                FDropdownRect.left + 2 * LARGEBUTTON_RADIUS + 1,
                                FDropdownRect.Bottom + 2);
      CombineRgn(DrawRgn, DrawRgn, TmpRgn, RGN_OR);
      DeleteObject(TmpRgn);

      TmpRgn:=CreateEllipticRgn(FDropdownRect.Right - 2 * LARGEBUTTON_RADIUS + 1,
                                FDropdownRect.Bottom - 2 * LARGEBUTTON_RADIUS + 1,
                                FDropdownRect.Right + 2,
                                FDropdownRect.Bottom + 2);
      CombineRgn(DrawRgn, DrawRgn, TmpRgn, RGN_OR);
      DeleteObject(TmpRgn);

      TGuiTools.DrawRegion(ABuffer.Canvas,
                           DrawRgn,
                           FRect,
                           GradientFromColor,
                           GradientToColor,
                           GradientKind,
                           ClipRect);
      DeleteObject(DrawRgn);
      {$ENDREGION}

      {$REGION 'Ramka dropdown'}
      // Wewnêtrzna ramka

      TGuiTools.DrawAARoundCorner(ABuffer,
                                  T2DIntPoint.Create(FDropdownRect.Left + 1, FDropdownRect.Bottom - LARGEBUTTON_RADIUS),
                                  LARGEBUTTON_RADIUS,
                                  cpLeftBottom,
                                  InnerLightColor);
      TGuiTools.DrawAARoundCorner(ABuffer,
                                  T2DIntPoint.Create(FDropdownRect.right - LARGEBUTTON_RADIUS, FDropdownRect.Bottom - LARGEBUTTON_RADIUS),
                                  LARGEBUTTON_RADIUS,
                                  cpRightBottom,
                                  InnerLightColor);
      TGuiTools.DrawHLine(ABuffer,
                          FDropdownRect.Left + LARGEBUTTON_RADIUS + 1,
                          FDropdownRect.Right - LARGEBUTTON_RADIUS - 1,
                          FDropdownRect.Bottom - 1,
                          InnerLightColor,
                          ClipRect);
      TGuiTools.DrawVLine(ABuffer,
                          FDropdownRect.Left + 1,
                          FDropDownRect.Top + 1,
                          FDropDownRect.Bottom - LARGEBUTTON_RADIUS - 1,
                          InnerLightColor,
                          ClipRect);
      TGuiTools.DrawVLine(ABuffer,
                          FDropdownRect.Right - 1,
                          FDropDownRect.Top + 1,
                          FDropDownRect.Bottom - LARGEBUTTON_RADIUS - 1,
                          InnerLightColor,
                          ClipRect);

      if FButtonState = bsDropdownPressed then
         TGuiTools.DrawHLine(ABuffer,
                             FDropdownRect.Left + 1,
                             FDropdownRect.Right - 1,
                             FDropdownRect.Top,
                             FrameColor,
                             ClipRect)
      else
         TGuiTools.DrawHLine(ABuffer,
                             FDropdownRect.Left + 1,
                             FDropdownRect.Right - 1,
                             FDropdownRect.Top,
                             InnerDarkColor,
                             ClipRect);


      // Zewnêtrzna ramka
      TGuiTools.DrawAARoundCorner(ABuffer,
                                  T2DIntPoint.Create(FDropdownRect.Left, FDropdownRect.Bottom - LARGEBUTTON_RADIUS + 1),
                                  LARGEBUTTON_RADIUS,
                                  cpLeftBottom,
                                  FrameColor);
      TGuiTools.DrawAARoundCorner(ABuffer,
                                  T2DIntPoint.Create(FDropdownRect.right - LARGEBUTTON_RADIUS + 1, FDropdownRect.Bottom - LARGEBUTTON_RADIUS + 1),
                                  LARGEBUTTON_RADIUS,
                                  cpRightBottom,
                                  FrameColor);
      TGuiTools.DrawHLine(ABuffer,
                          FDropdownRect.Left + LARGEBUTTON_RADIUS,
                          FDropdownRect.Right - LARGEBUTTON_RADIUS,
                          FDropdownRect.Bottom,
                          FrameColor,
                          ClipRect);
      TGuiTools.DrawVLine(ABuffer,
                          FDropdownRect.Left,
                          FDropDownRect.Top,
                          FDropDownRect.Bottom - LARGEBUTTON_RADIUS,
                          FrameColor,
                          ClipRect);
      TGuiTools.DrawVLine(ABuffer,
                          FDropdownRect.Right,
                          FDropDownRect.Top,
                          FDropDownRect.Bottom - LARGEBUTTON_RADIUS,
                          FrameColor,
                          ClipRect);
      {$ENDREGION}

      {$ENDREGION}
      end else
          raise InternalException.create('TSpkLargeButton.Draw: Nieprawid³owa wartoœæ FButtonState!');

   // *** Ikona ***
   if not(FEnabled) then
      begin
      {$REGION 'Ikona wy³¹czona'}
      if (FLargeImageIndex>=0) and
         (FDisabledLargeImages<>nil) and
         (FLargeImageIndex<FDisabledLargeImages.Count) then
         begin
         x:=FRect.left + (FRect.Width - FLargeImages.Width) div 2;
         y:=FRect.top + LARGEBUTTON_BORDER_SIZE + LARGEBUTTON_GLYPH_MARGIN;

         TGuiTools.DrawImage(ABuffer.Canvas,
                             FDisabledLargeImages,
                             FLargeImageIndex,
                             T2DIntPoint.Create(x, y),
                             ClipRect);
         end else
      if (FLargeImageIndex>=0) and
         (FLargeImages<>nil) and
         (FLargeImageIndex<FLargeImages.Count) then
         begin
         x:=FRect.left + (FRect.Width - FLargeImages.Width) div 2;
         y:=FRect.top + LARGEBUTTON_BORDER_SIZE + LARGEBUTTON_GLYPH_MARGIN;

         TGuiTools.DrawDisabledImage(ABuffer.Canvas,
                                     FLargeImages,
                                     FLargeImageIndex,
                                     T2DIntPoint.Create(x, y),
                                     ClipRect);
         end;
      {$ENDREGION}
      end
   else
      begin
      {$REGION 'Ikona zwyk³a'}
      if (FLargeImageIndex>=0) and
         (FLargeImages<>nil) and
         (FLargeImageIndex<FLargeImages.Count) then
         begin
         x:=FRect.left + (FRect.Width - FLargeImages.Width) div 2;
         y:=FRect.top + LARGEBUTTON_BORDER_SIZE + LARGEBUTTON_GLYPH_MARGIN;

         TGUITools.DrawImage(ABuffer.Canvas,
                             FLargeImages,
                             FLargeImageIndex,
                             T2DIntPoint.Create(x,y),
                             ClipRect);
         end;
      {$ENDREGION}
      end;

   // *** Tekst ***
   if not(FEnabled) then
      begin
      FontColor:=clNone;
      case FButtonState of
           bsIdle: FontColor:=TColorTools.ColorToGrayscale(FAppearance.Element.IdleCaptionColor);
           bsBtnHottrack,
           bsDropdownHottrack : FontColor:=TColorTools.ColorToGrayscale(FAppearance.Element.HotTrackCaptionColor);
           bsBtnPressed,
           bsDropdownPressed: FontColor:=TColorTools.ColorToGrayscale(FAppearance.ELement.ActiveCaptionColor);
      end;
      end
   else
      begin
      FontColor:=clNone;
      case FButtonState of
           bsIdle: FontColor:=FAppearance.Element.IdleCaptionColor;
           bsBtnHottrack,
           bsDropdownHottrack : FontColor:=FAppearance.Element.HotTrackCaptionColor;
           bsBtnPressed,
           bsDropdownPressed: FontColor:=FAppearance.ELement.ActiveCaptionColor;
      end;
      end;

   ABuffer.Canvas.Font.assign(FAppearance.Element.CaptionFont);
   ABuffer.Canvas.Font.Color:=FontColor;

   TextHeight:=ABuffer.Canvas.Textheight('Wy');

   x:=FRect.Left + (FRect.width - ABuffer.Canvas.Textwidth(FCaption)) div 2;
   y:=FRect.Top + LARGEBUTTON_CAPTION_TOP_RAIL - TextHeight div 2;
   TGUITools.DrawText(ABuffer.Canvas, x, y, FCaption, FontColor, ClipRect);

   // *** Chevron dropdown ***

   if not(FEnabled) then
      begin
      case FButtonState of
           bsIdle: FontColor:=TColorTools.ColorToGrayscale(FAppearance.Element.IdleCaptionColor);
           bsBtnHottrack,
           bsDropdownHottrack : FontColor:=TColorTools.ColorToGrayscale(FAppearance.Element.HotTrackCaptionColor);
           bsBtnPressed,
           bsDropdownPressed: FontColor:=TColorTools.ColorToGrayscale(FAppearance.ELement.ActiveCaptionColor);
      end;
      end
   else
      begin
      case FButtonState of
           bsIdle: FontColor:=FAppearance.Element.IdleCaptionColor;
           bsBtnHottrack,
           bsDropdownHottrack : FontColor:=FAppearance.Element.HotTrackCaptionColor;
           bsBtnPressed,
           bsDropdownPressed: FontColor:=FAppearance.ELement.ActiveCaptionColor;
      end;
      end;

   ABuffer.Canvas.Font.Charset:=DEFAULT_CHARSET;
   ABuffer.Canvas.Font.Name:='Marlett';
   ABuffer.Canvas.Font.Size:=8;
   ABuffer.Canvas.Font.Style:=[];
   ABuffer.Canvas.Font.Orientation:=0;

   x:=FDropdownRect.Left + (FDropdownRect.width - ABuffer.Canvas.Textwidth('u')) div 2;
   y:=FDropdownRect.bottom - ABuffer.Canvas.Textheight('u') - LARGEBUTTON_CHEVRON_HMARGIN;
   TGUITools.DrawText(ABuffer.Canvas, x, y, 'u', FontColor, ClipRect);

   {$ENDREGION}
   end;
end;

procedure TSpkLargeButton.FindBreakPlace(s: string; out Position : integer; out Width : integer);

var i : integer;
    Bitmap : TBitmap;
    BeforeWidth, AfterWidth : integer;

begin
Position:=-1;
Width:=-1;

if FToolbarDispatch=nil then
   exit;
if FAppearance=nil then
   exit;

Bitmap:=FToolbarDispatch.GetTempBitmap;
if Bitmap=nil then
   exit;

Bitmap.canvas.font.assign(FAppearance.Element.CaptionFont);

Width:=Bitmap.Canvas.TextWidth(FCaption);

if length(s)>0 then
   for i := 1 to length(s) do
       if s[i]=' ' then
          begin
          if i>1 then
             BeforeWidth:=Bitmap.Canvas.TextWidth(copy(s,1,i-1)) else
             BeforeWidth:=0;

          if i<length(s) then
             AfterWidth:=Bitmap.Canvas.TextWidth(copy(s,i+1,length(s)-i)) else
             AfterWidth:=0;

          if (Position=-1) or (max(BeforeWidth,AfterWidth)<Width) then
             begin
             Width:=max(BeforeWidth,AfterWidth);
             Position:=i;
             end;
          end;
end;

function TSpkLargeButton.GetDropdownPoint: T2DIntPoint;
begin
case FButtonKind of
     bkDropdown: result:=T2DIntPoint.Create(FButtonRect.left, FButtonRect.Bottom+1);
     bkButtonDropdown: result:=T2DIntPoint.Create(FDropdownRect.left, FDropdownRect.Bottom+1);
else result:=T2DIntPoint.Create(0,0);
end;
end;

function TSpkLargeButton.GetGroupBehaviour: TSpkItemGroupBehaviour;
begin
result:=gbSingleItem;
end;

function TSpkLargeButton.GetSize: TSpkItemSize;
begin
result:=isLarge;
end;

function TSpkLargeButton.GetTableBehaviour: TSpkItemTableBehaviour;
begin
result:=tbBeginsColumn;
end;

function TSpkLargeButton.GetWidth: integer;

var GlyphWidth : integer;
    TextWidth : integer;
    Bitmap : TBitmap;
    BreakPos, RowWidth : integer;

begin
result:=-1;

if FToolbarDispatch=nil then
   exit;
if FAppearance=nil then
   exit;

Bitmap:=FToolbarDispatch.GetTempBitmap;
if Bitmap=nil then
   exit;

// *** Glyph ***
if FLargeImages<>nil then
   GlyphWidth:=2 * LARGEBUTTON_GLYPH_MARGIN + FLargeImages.Width else
   GlyphWidth:=0;

// *** Tekst ***
if FButtonKind = bkButton then
   begin
   // £amiemy etykietê
   FindBreakPlace(FCaption,BreakPos,RowWidth);
   TextWidth:=2 * LARGEBUTTON_CAPTION_HMARGIN + RowWidth;
   end
else
   begin
   // Nie ³amiemy etykiety
   Bitmap.canvas.font.assign(FAppearance.Element.CaptionFont);
   TextWidth:=2 * LARGEBUTTON_CAPTION_HMARGIN + Bitmap.Canvas.TextWidth(FCaption);
   end;

result:=max(LARGEBUTTON_MIN_WIDTH, max(GlyphWidth, TextWidth));
end;

procedure TSpkLargeButton.SetLargeImageIndex(const Value: integer);
begin
FLargeImageIndex:=Value;

if assigned(FToolbarDispatch) then
   FToolbarDispatch.NotifyMetricsChanged;
end;

{ TSpkSmallButton }

procedure TSpkSmallButton.CalcRects;

var RectVector : T2DIntVector;

begin
  ConstructRects(FButtonRect, FDropdownRect);
  RectVector:=T2DIntVector.Create(FRect.Left, FRect.Top);
  FButtonRect:=FButtonRect + RectVector;
  FDropdownRect:=FDropdownRect + RectVector;
end;

procedure TSpkSmallButton.ConstructRects(var BtnRect, DropRect: T2DIntRect);

var BtnWidth : integer;
    DropdownWidth: Integer;
    Bitmap : TBitmap;
    TextWidth: Integer;
  AdditionalPadding: Boolean;

begin
BtnRect:=T2DIntRect.Create(0, 0, 0, 0);
DropRect:=T2DIntRect.Create(0, 0, 0, 0);

if not(assigned(FToolbarDispatch)) then
   exit;
if not(assigned(FAppearance)) then
   exit;

Bitmap:=FToolbarDispatch.GetTempBitmap;
if not(assigned(Bitmap)) then
   exit;

// *** Niezale¿nie od rodzaju, musi byæ miejsce dla ikony i/lub tekstu ***

BtnWidth:=0;
AdditionalPadding:=false;

// Ikona
if FImageIndex<>-1 then
   begin
   BtnWidth:=BtnWidth + SMALLBUTTON_PADDING + SMALLBUTTON_GLYPH_WIDTH;
   AdditionalPadding:=true;
   end;

// Tekst
if FShowCaption then
   begin
   Bitmap.Canvas.Font.assign(FAppearance.Element.CaptionFont);
   TextWidth:=Bitmap.Canvas.TextWidth(FCaption);

   BtnWidth:=BtnWidth + SMALLBUTTON_PADDING + TextWidth;
   AdditionalPadding:=true;
   end;

// Padding za tekstem lub ikon¹
if AdditionalPadding then
   BtnWidth:=BtnWidth + SMALLBUTTON_PADDING;

// Szerokoœæ zawartoœci przycisku musi wynosiæ co najmniej SMALLBUTTON_MIN_WIDTH
BtnWidth:=max(SMALLBUTTON_MIN_WIDTH, BtnWidth);

// *** Dropdown ***
case FButtonKind of
     bkButton: begin
               // Lewa krawêdŸ przycisku
               if FGroupBehaviour in [gbContinuesGroup, gbEndsGroup] then
                  BtnWidth:=BtnWidth + SMALLBUTTON_HALF_BORDER_WIDTH else
                  BtnWidth:=BtnWidth + SMALLBUTTON_BORDER_WIDTH;

               // Prawa krawêdŸ przycisku
               if (FGroupBehaviour in [gbBeginsGroup, gbContinuesGroup]) then
                  BtnWidth:=BtnWidth + SMALLBUTTON_HALF_BORDER_WIDTH else
                  BtnWidth:=BtnWidth + SMALLBUTTON_BORDER_WIDTH;

               BtnRect:=T2DIntRect.Create(0, 0, BtnWidth - 1, PANE_ROW_HEIGHT - 1);
               DropRect:=T2DIntRect.Create(0, 0, 0, 0);
               end;
     bkButtonDropdown: begin
                       // Lewa krawêdŸ przycisku
                       if FGroupBehaviour in [gbContinuesGroup, gbEndsGroup] then
                          BtnWidth:=BtnWidth + SMALLBUTTON_HALF_BORDER_WIDTH else
                          BtnWidth:=BtnWidth + SMALLBUTTON_BORDER_WIDTH;

                       // Prawa krawêdŸ przycisku
                       BtnWidth:=BtnWidth + SMALLBUTTON_HALF_BORDER_WIDTH;

                       // Lewa krawêdŸ i zawartoœæ pola dropdown
                       DropdownWidth:=SMALLBUTTON_HALF_BORDER_WIDTH + SMALLBUTTON_DROPDOWN_WIDTH;

                       // Prawa krawêdŸ pola dropdown
                       if (FGroupBehaviour in [gbBeginsGroup, gbContinuesGroup]) then
                          DropdownWidth:=DropdownWidth + SMALLBUTTON_HALF_BORDER_WIDTH else
                          DropdownWidth:=DropdownWidth + SMALLBUTTON_BORDER_WIDTH;

                       BtnRect:=T2DIntRect.Create(0, 0, BtnWidth - 1, PANE_ROW_HEIGHT - 1);
                       DropRect:=T2DIntRect.Create(BtnRect.right+1,
                                                   0,
                                                   BtnRect.right+DropdownWidth,
                                                   PANE_ROW_HEIGHT - 1);
                       end;
     bkDropdown: begin
                 // Lewa krawêdŸ przycisku
                 if FGroupBehaviour in [gbContinuesGroup, gbEndsGroup] then
                    BtnWidth:=BtnWidth + SMALLBUTTON_HALF_BORDER_WIDTH else
                    BtnWidth:=BtnWidth + SMALLBUTTON_BORDER_WIDTH;

                 // Prawa krawêdŸ przycisku
                 if (FGroupBehaviour in [gbBeginsGroup, gbContinuesGroup]) then
                    BtnWidth:=BtnWidth + SMALLBUTTON_HALF_BORDER_WIDTH else
                    BtnWidth:=BtnWidth + SMALLBUTTON_BORDER_WIDTH;

                 // Dodatkowy obszar na dropdown + miejsce na œrodkow¹ krawêdŸ,
                 // dla kompatybilnoœci wymiarów z dkButtonDropdown
                 BtnWidth:=BtnWidth + SMALLBUTTON_BORDER_WIDTH + SMALLBUTTON_DROPDOWN_WIDTH;

                 BtnRect:=T2DIntRect.Create(0, 0, BtnWidth - 1, PANE_ROW_HEIGHT - 1);
                 DropRect:=T2DIntRect.Create(0, 0, 0, 0);
                 end;
end;
end;

constructor TSpkSmallButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FImageIndex:=-1;
  FTableBehaviour:=tbContinuesRow;
  FGroupBehaviour:=gbSingleItem;
  FHideFrameWhenIdle:=false;
  FShowCaption:=true;
end;

procedure TSpkSmallButton.Draw(ABuffer: TBitmap; ClipRect: T2DIntRect);
var
  FontColor: TColor;
  x: Integer;
  y: Integer;
begin
if FToolbarDispatch=nil then
   exit;
if FAppearance=nil then
   exit;

if (FRect.width<2*LARGEBUTTON_RADIUS) or (FRect.Height<2*LARGEBUTTON_RADIUS) then
   exit;

// *** Przycisk ***

// T³o i ramka
{$REGION 'Rysowanie przycisku'}
if (FButtonState = bsIdle) and (not(FHideFrameWhenIdle)) then
   begin
   with FAppearance.Element do
        TButtonTools.DrawButton(ABuffer,
                                FButtonRect,
                                IdleFrameColor,
                                IdleInnerLightColor,
                                IdleInnerDarkColor,
                                IdleGradientFromColor,
                                IdleGradientToColor,
                                IdleGradientType,
                                (FGroupBehaviour in [gbContinuesGroup, gbEndsGroup]),
                                (FGroupBehaviour in [gbBeginsGroup, gbContinuesGroup]) or (FButtonKind = bkButtonDropdown),
                                false,
                                false,
                                SMALLBUTTON_RADIUS,
                                ClipRect);
   end else
if (FButtonState=bsBtnHottrack) then
   begin
   with FAppearance.Element do
        TButtonTools.DrawButton(ABuffer,
                                FButtonRect,
                                HotTrackFrameColor,
                                HotTrackInnerLightColor,
                                HotTrackInnerDarkColor,
                                HotTrackGradientFromColor,
                                HotTrackGradientToColor,
                                HotTrackGradientType,
                                (FGroupBehaviour in [gbContinuesGroup, gbEndsGroup]),
                                (FGroupBehaviour in [gbBeginsGroup, gbContinuesGroup]) or (FButtonKind = bkButtonDropdown),
                                false,
                                false,
                                SMALLBUTTON_RADIUS,
                                ClipRect);
   end else
if (FButtonState = bsBtnPressed) then
   begin
   with FAppearance.Element do
        TButtonTools.DrawButton(ABuffer,
                                FButtonRect,
                                ActiveFrameColor,
                                ActiveInnerLightColor,
                                ActiveInnerDarkColor,
                                ActiveGradientFromColor,
                                ActiveGradientToColor,
                                ActiveGradientType,
                                (FGroupBehaviour in [gbContinuesGroup, gbEndsGroup]),
                                (FGroupBehaviour in [gbBeginsGroup, gbContinuesGroup]) or (FButtonKind = bkButtonDropdown),
                                false,
                                false,
                                SMALLBUTTON_RADIUS,
                                ClipRect);
   end else
if (FButtonState in [bsDropdownHottrack, bsDropdownPressed]) then
   begin
   with FAppearance.Element do
        TButtonTools.DrawButton(ABuffer,
                                FButtonRect,
                                TColorTools.Brighten(HotTrackFrameColor,40),
                                TColorTools.Brighten(HotTrackInnerLightColor,40),
                                TColorTools.Brighten(HotTrackInnerDarkColor,40),
                                TColorTools.Brighten(HotTrackGradientFromColor,40),
                                TColorTools.Brighten(HotTrackGradientToColor,40),
                                HotTrackGradientType,
                                (FGroupBehaviour in [gbContinuesGroup, gbEndsGroup]),
                                (FGroupBehaviour in [gbBeginsGroup, gbContinuesGroup]) or (FButtonKind = bkButtonDropdown),
                                false,
                                false,
                                SMALLBUTTON_RADIUS,
                                ClipRect);
   end;
{$ENDREGION}

// Ikona
if not(FEnabled) then
   begin
   {$REGION 'Ikona wy³¹czona'}
   if (FImageIndex>=0) and
      (FDisabledImages<>nil) and
      (FImageIndex<FDisabledImages.Count) then
      begin
      if (FGroupBehaviour in [gbContinuesGroup, gbEndsGroup]) then
         x:=FButtonRect.Left + SMALLBUTTON_HALF_BORDER_WIDTH + SMALLBUTTON_PADDING else
         x:=FButtonRect.Left + SMALLBUTTON_BORDER_WIDTH + SMALLBUTTON_PADDING;
      y:=FButtonRect.top + (FButtonRect.height - FDisabledImages.Height) div 2;

      TGuiTools.DrawImage(ABuffer.Canvas,
                          FDisabledImages,
                          FImageIndex,
                          T2DIntPoint.Create(x, y),
                          ClipRect);
      end else
   if (FImageIndex>=0) and
      (FImages<>nil) and
      (FImageIndex<FImages.Count) then
      begin
      if (FGroupBehaviour in [gbContinuesGroup, gbEndsGroup]) then
         x:=FButtonRect.Left + SMALLBUTTON_HALF_BORDER_WIDTH + SMALLBUTTON_PADDING else
         x:=FButtonRect.Left + SMALLBUTTON_BORDER_WIDTH + SMALLBUTTON_PADDING;
      y:=FButtonRect.top + (FButtonRect.height - FImages.Height) div 2;

      TGuiTools.DrawDisabledImage(ABuffer.Canvas,
                                  FImages,
                                  FImageIndex,
                                  T2DIntPoint.Create(x, y),
                                  ClipRect);
      end;
   {$ENDREGION}
   end
else
   begin
   {$REGION 'Ikona zwyk³a'}
   if (FImageIndex>=0) and
      (FImages<>nil) and
      (FImageIndex<FImages.Count) then
      begin
      if (FGroupBehaviour in [gbContinuesGroup, gbEndsGroup]) then
         x:=FButtonRect.Left + SMALLBUTTON_HALF_BORDER_WIDTH + SMALLBUTTON_PADDING else
         x:=FButtonRect.Left + SMALLBUTTON_BORDER_WIDTH + SMALLBUTTON_PADDING;
      y:=FButtonRect.top + (FButtonRect.height - FImages.Height) div 2;

      TGUITools.DrawImage(ABuffer.Canvas,
                          FImages,
                          FImageIndex,
                          T2DIntPoint.Create(x,y),
                          ClipRect);
      end;
   {$ENDREGION}
   end;

// Tekst
if FShowCaption then
   begin
   ABuffer.Canvas.Font.Assign(FAppearance.Element.CaptionFont);

   if not(FEnabled) then
      begin
      FontColor:=clNone;
      case FButtonState of
           bsIdle: FontColor:=TColorTools.ColorToGrayscale(FAppearance.Element.IdleCaptionColor);
           bsBtnHottrack,
           bsDropdownHottrack : FontColor:=TColorTools.ColorToGrayscale(FAppearance.Element.HotTrackCaptionColor);
           bsBtnPressed,
           bsDropdownPressed: FontColor:=TColorTools.ColorToGrayscale(FAppearance.ELement.ActiveCaptionColor);
      end;
      end
   else
      begin
      FontColor:=clNone;
      case FButtonState of
           bsIdle: FontColor:=FAppearance.Element.IdleCaptionColor;
           bsBtnHottrack,
           bsDropdownHottrack : FontColor:=FAppearance.Element.HotTrackCaptionColor;
           bsBtnPressed,
           bsDropdownPressed: FontColor:=FAppearance.ELement.ActiveCaptionColor;
      end;
      end;

   if (FGroupBehaviour in [gbContinuesGroup, gbEndsGroup]) then
      x:=FButtonRect.Left + SMALLBUTTON_HALF_BORDER_WIDTH else
      x:=FButtonRect.Left + SMALLBUTTON_BORDER_WIDTH;

   if FImageIndex<>-1 then
      x:=x + 2 * SMALLBUTTON_PADDING + SMALLBUTTON_GLYPH_WIDTH else
      x:=x + SMALLBUTTON_PADDING;
   y:=FButtonRect.Top + (FButtonRect.Height - ABuffer.Canvas.TextHeight('Wy')) div 2;

   TGUITools.DrawText(ABuffer.Canvas,
                      x,
                      y,
                      FCaption,
                      FontColor,
                      ClipRect);
   end;

// *** Dropdown ***
if FButtonKind = bkButton then
   begin
   // Nic dodatkowego do rysowania
   end else
if FButtonKind = bkButtonDropdown then
   begin
   // T³o i ramka
   {$REGION 'Rysowanie dropdowna'}
   if (FButtonState = bsIdle) and (not(FHideFrameWhenIdle)) then
      begin
      with FAppearance.Element do
           TButtonTools.DrawButton(ABuffer,
                                   FDropdownRect,
                                   IdleFrameColor,
                                   IdleInnerLightColor,
                                   IdleInnerDarkColor,
                                   IdleGradientFromColor,
                                   IdleGradientToColor,
                                   IdleGradientType,
                                   true,
                                   (FGroupBehaviour in [gbBeginsGroup, gbContinuesGroup]),
                                   false,
                                   false,
                                   SMALLBUTTON_RADIUS,
                                   ClipRect);
      end else
   if (FButtonState in [bsBtnHottrack, bsBtnPressed]) then
      begin
      with FAppearance.Element do
           TButtonTools.DrawButton(ABuffer,
                                   FDropdownRect,
                                   TColorTools.Brighten(HottrackFrameColor, 40),
                                   TColorTools.Brighten(HottrackInnerLightColor, 40),
                                   TColorTools.Brighten(HottrackInnerDarkColor, 40),
                                   TColorTools.Brighten(HottrackGradientFromColor, 40),
                                   TColorTools.Brighten(HottrackGradientToColor, 40),
                                   HottrackGradientType,
                                   true,
                                   (FGroupBehaviour in [gbBeginsGroup, gbContinuesGroup]),
                                   false,
                                   false,
                                   SMALLBUTTON_RADIUS,
                                   ClipRect);

      end else
   if (FButtonState = bsDropdownHottrack) then
      begin
      with FAppearance.Element do
           TButtonTools.DrawButton(ABuffer,
                                   FDropdownRect,
                                   HottrackFrameColor,
                                   HottrackInnerLightColor,
                                   HottrackInnerDarkColor,
                                   HottrackGradientFromColor,
                                   HottrackGradientToColor,
                                   HottrackGradientType,
                                   true,
                                   (FGroupBehaviour in [gbBeginsGroup, gbContinuesGroup]),
                                   false,
                                   false,
                                   SMALLBUTTON_RADIUS,
                                   ClipRect);
      end else
   if (FButtonState = bsDropdownPressed) then
      begin
      with FAppearance.Element do
           TButtonTools.DrawButton(ABuffer,
                                   FDropdownRect,
                                   ActiveFrameColor,
                                   ActiveInnerLightColor,
                                   ActiveInnerDarkColor,
                                   ActiveGradientFromColor,
                                   ActiveGradientToColor,
                                   ActiveGradientType,
                                   true,
                                   (FGroupBehaviour in [gbBeginsGroup, gbContinuesGroup]),
                                   false,
                                   false,
                                   SMALLBUTTON_RADIUS,
                                   ClipRect);
      end;

   // Chevron
   if not(FEnabled) then
      begin
      FontColor:=clNone;
      case FButtonState of
           bsIdle: FontColor:=TColorTools.ColorToGrayscale(FAppearance.Element.IdleCaptionColor);
           bsBtnHottrack,
           bsDropdownHottrack : FontColor:=TColorTools.ColorToGrayscale(FAppearance.Element.HotTrackCaptionColor);
           bsBtnPressed,
           bsDropdownPressed: FontColor:=TColorTools.ColorToGrayscale(FAppearance.ELement.ActiveCaptionColor);
      end;
      end
   else
      begin
      FontColor:=clNone;
      case FButtonState of
           bsIdle: FontColor:=FAppearance.Element.IdleCaptionColor;
           bsBtnHottrack,
           bsDropdownHottrack : FontColor:=FAppearance.Element.HotTrackCaptionColor;
           bsBtnPressed,
           bsDropdownPressed: FontColor:=FAppearance.ELement.ActiveCaptionColor;
      end;
      end;

   ABuffer.Canvas.Font.Charset:=DEFAULT_CHARSET;
   ABuffer.Canvas.Font.Name:='Marlett';
   ABuffer.Canvas.Font.Size:=8;
   ABuffer.Canvas.Font.Style:=[];
   ABuffer.Canvas.Font.Orientation:=0;

   if FGroupBehaviour in [gbBeginsGroup, gbContinuesGroup] then
      x:=FDropdownRect.Right - SMALLBUTTON_HALF_BORDER_WIDTH - (SMALLBUTTON_DROPDOWN_WIDTH + ABuffer.Canvas.Textwidth('u')) div 2 + 1 else
      x:=FDropdownRect.Right - SMALLBUTTON_BORDER_WIDTH - (SMALLBUTTON_DROPDOWN_WIDTH + ABuffer.Canvas.Textwidth('u')) div 2 + 1;
   y:=FDropdownRect.top + (FDropdownRect.height - ABuffer.Canvas.Textheight('u')) div 2;
   TGUITools.DrawText(ABuffer.Canvas, x, y, 'u', FontColor, ClipRect);
   {$ENDREGION}
   end else
if FButtonKind = bkDropdown then
   begin
   // Chevron dropdown

   if not(FEnabled) then
      begin
      FontColor:=clNone;
      case FButtonState of
           bsIdle: FontColor:=TColorTools.ColorToGrayscale(FAppearance.Element.IdleCaptionColor);
           bsBtnHottrack,
           bsDropdownHottrack : FontColor:=TColorTools.ColorToGrayscale(FAppearance.Element.HotTrackCaptionColor);
           bsBtnPressed,
           bsDropdownPressed: FontColor:=TColorTools.ColorToGrayscale(FAppearance.ELement.ActiveCaptionColor);
      end;
      end
   else
      begin
      FontColor:=clNone;
      case FButtonState of
           bsIdle: FontColor:=FAppearance.Element.IdleCaptionColor;
           bsBtnHottrack,
           bsDropdownHottrack : FontColor:=FAppearance.Element.HotTrackCaptionColor;
           bsBtnPressed,
           bsDropdownPressed: FontColor:=FAppearance.ELement.ActiveCaptionColor;
      end;
      end;

   ABuffer.Canvas.Font.Charset:=DEFAULT_CHARSET;
   ABuffer.Canvas.Font.Name:='Marlett';
   ABuffer.Canvas.Font.Size:=8;
   ABuffer.Canvas.Font.Style:=[];
   ABuffer.Canvas.Font.Orientation:=0;

   if FGroupBehaviour in [gbBeginsGroup, gbContinuesGroup] then
      x:=FButtonRect.Right - SMALLBUTTON_HALF_BORDER_WIDTH - (SMALLBUTTON_DROPDOWN_WIDTH + ABuffer.Canvas.Textwidth('u')) div 2 + 1 else
      x:=FButtonRect.Right - SMALLBUTTON_BORDER_WIDTH - (SMALLBUTTON_DROPDOWN_WIDTH + ABuffer.Canvas.Textwidth('u')) div 2 + 1;
   y:=FButtonRect.top + (FButtonRect.height - ABuffer.Canvas.Textheight('u')) div 2;
   TGUITools.DrawText(ABuffer.Canvas, x, y, 'u', FontColor, ClipRect);
   end;

{$ENDREGION}
end;

function TSpkSmallButton.GetDropdownPoint: T2DIntPoint;
begin
if FButtonKind in [bkButtonDropdown, bkDropdown] then
   result:=T2DIntPoint.Create(FButtonRect.left, FButtonRect.bottom+1) else
   result:=T2DIntPoint.Create(0,0);
end;

function TSpkSmallButton.GetGroupBehaviour: TSpkItemGroupBehaviour;
begin
  result:=FGroupBehaviour;
end;

function TSpkSmallButton.GetSize: TSpkItemSize;
begin
  result:=isNormal;
end;

function TSpkSmallButton.GetTableBehaviour: TSpkItemTableBehaviour;
begin
  result:=FTableBehaviour;
end;

function TSpkSmallButton.GetWidth: integer;

var BtnRect, DropRect : T2DIntRect;

begin
result:=-1;

if FToolbarDispatch=nil then
   exit;
if FAppearance=nil then
   exit;

ConstructRects(BtnRect, DropRect);

if FButtonKind = bkButtonDropdown then
   result:=DropRect.Right+1 else
   result:=BtnRect.Right+1;
end;

procedure TSpkSmallButton.SetGroupBehaviour(
  const Value: TSpkItemGroupBehaviour);
begin
  FGroupBehaviour := Value;

  if assigned(FToolbarDispatch) then
     FToolbarDispatch.NotifyMetricsChanged;
end;

procedure TSpkSmallButton.SetHideFrameWhenIdle(const Value: boolean);
begin
  FHideFrameWhenIdle := Value;

  if assigned(FToolbarDispatch) then
     FToolbarDispatch.NotifyVisualsChanged;
end;

procedure TSpkSmallButton.SetImageIndex(const Value: integer);
begin
  FImageIndex:=Value;

  if assigned(FToolbarDispatch) then
     FToolbarDispatch.NotifyMetricsChanged;
end;

procedure TSpkSmallButton.SetShowCaption(const Value: boolean);
begin
  FShowCaption := Value;

  if assigned(FToolbarDispatch) then
     FToolbarDispatch.NotifyMetricsChanged;
end;

procedure TSpkSmallButton.SetTableBehaviour(
  const Value: TSpkItemTableBehaviour);
begin
  FTableBehaviour := Value;

  if assigned(FToolbarDispatch) then
     FToolbarDispatch.NotifyMetricsChanged;
end;

initialization

RegisterClass(TSpkLargeButton);
RegisterClass(TSpkSmallButton);

finalization

UnRegisterClass(TSpkLargeButton);
UnRegisterClass(TSpkSmallButton);

end.
