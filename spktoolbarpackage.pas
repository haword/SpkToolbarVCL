{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit SpkToolbarPackage; 

interface

uses
  spkt_Appearance, spkt_BaseItem, spkt_Buttons, spkt_Const, spkt_Dispatch, 
  spkt_Exceptions, spkt_Items, spkt_Pane, spkt_Tab, spkt_Tools, spkt_Types, 
  SpkToolbar, SpkMath, SpkGUITools, SpkGraphTools, SpkXMLIni, SpkXMLParser, 
  SpkXMLTools, RegisterSpkToolbar, SpkToolbarEditor, spkte_AppearanceEditor, 
  spkte_EditWindow,DesignEditors, DesignIntf, DesignMenus, VCLEditors;

implementation

procedure Register; 
begin
//  RegisterUnit('RegisterSpkToolbar', @RegisterSpkToolbar.Register);
end;

initialization
//  RegisterPackage('SpkToolbarPackage', @Register);
end.
