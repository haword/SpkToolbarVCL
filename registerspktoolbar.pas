unit RegisterSpkToolbar;

{.$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SpkToolbar, DesignEditors, DesignIntf, DesignMenus, VCLEditors,
  SpkToolbarEditor, spkt_Buttons, spkt_Pane, spkt_Tab, spkt_Appearance;

procedure Register;

implementation


procedure Register;
begin
  RegisterComponents('SpkToolbar', [TSpkToolbar]);
  RegisterNoIcon([TSpkLargeButton, TSpkSmallButton]);
  RegisterNoIcon([TSpkPane]);
  RegisterNoIcon([TSpkTab]);

//  RegisterUnit('SpkToolbar', @RegisterUnitSpkToolbar);
//  RegisterUnit('spkt_Buttons', @RegisterUnitSpkt_Buttons);
//  RegisterUnit('spkt_Pane', @RegisterUnitSpkt_Pane);
//  RegisterUnit('spkt_Tab', @RegisterUnitSpkt_Tab);

  RegisterComponentEditor(TSpkToolbar, TSpkToolbarEditor);
  RegisterPropertyEditor(TypeInfo(TSpkToolbarAppearance), TSpkToolbar,
    'Appearance', TSpkToolbarAppearanceEditor);
  //todo: register Caption Editor
end;

end.

