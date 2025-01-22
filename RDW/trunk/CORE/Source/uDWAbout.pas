unit uDWAbout;

{$I uRESTDW.inc}

interface

uses Classes, SysUtils, uDWConstsCharset{$IFDEF FPC}, lclversion{$ENDIF};

Type
 TDWComponent = Class(TComponent)
 Private
  fsAbout: TDWAboutInfo;
  Function GetVersionInfo : String;
 Public
  Property VersionInfo : String Read GetVersionInfo;
 Published
  Property AboutInfo : TDWAboutInfo Read fsAbout Write fsAbout Stored False;
 End;

Type
 TDWOwnedCollection = Class(TOwnedCollection)
 Private
  fsAbout: TDWAboutInfo;
 Published
  Property AboutInfo : TDWAboutInfo Read fsAbout Write fsAbout Stored False;
 End;

Procedure DWAboutDialog;

Implementation

uses uDWConsts{$IFNDEF LAMW}, uAboutForm{$ENDIF};

{$IFNDEF FPC}
Function GetDelphiVersion : String;
Begin
 Result := '';
 {$IFDEF VER140}
  Result := 'Delphi 6';
 {$ENDIF}
 {$IFDEF VER150}
  Result := 'Delphi 7 (and 7.1)';
 {$ENDIF}
 {$IFDEF VER160}
  Result := 'Delphi 8 for .Net';
 {$ENDIF}
 {$IFDEF VER170}
  Result := 'Delphi 2005';
 {$ENDIF}
 {$IFNDEF ver185}
  {$IFDEF ver180} // delphi 2006
  Result := 'Delphi 2006';
  {$ENDIF}
 {$ENDIF}
 {$IFDEF ver185} // delphi 2007
  Result := 'Delphi 2007';
 {$ENDIF}
 {$IFDEF ver190} // Delphi 2007 for .Net
  Result := 'Delphi 2007 for .Net';
 {$ENDIF}
 {$IFDEF ver200} // delphi 2009
  Result := 'Delphi 2009';
 {$ENDIF}
 {$IFDEF ver210} // delphi 2010
  Result := 'Delphi 2010';
 {$ENDIF}
 {$IFDEF ver220} // delphi xe
  Result := 'Delphi XE (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver230} // delphi xe2
  Result := 'Delphi XE2 (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver240} // delphi xe3
  Result := 'Delphi XE3 (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver250} // delphi xe4
  Result := 'Delphi XE4 (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver260} // delphi xe5
  Result := 'Delphi XE5 (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver270} // delphi xe6
  Result := 'Delphi XE6 (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver280} // delphi xe7
  Result := 'Delphi XE7 (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver290} // delphi xe8
  Result := 'Delphi XE8 (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver300} // delphi xe10
  Result := 'Delphi 10 Seattle (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver310} // delphi xe10.1
  Result := 'Delphi 10.1 Berlin (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver320} // delphi xe10.2
  Result := 'Delphi 10.2 Tokyo (VCL/FMX)';
 {$ENDIF}
 {$IFDEF ver330} // delphi xe10.3
  Result := 'Delphi 10.3 Rio (VCL/FMX)';
 {$ENDIF}
End;
{$ENDIF}

Function TDWComponent.GetVersionInfo : String;
Begin
 Result := Format('%s%s', [DWVersionINFO, DWRelease]);
End;

Procedure DWAboutDialog;
Var
 Msg : String;
 {$IFNDEF LAMW}
  {$IFNDEF LINUXFMX}
  frm : Tfrm_About;
  {$ENDIF}
 {$ENDIF}
 // funcao para converter compatibilidade
 Function DWStr(const AString: String) : String;
 Begin
  {$IFDEF UNICODE}
   {$IFDEF FPC}
    Result := CP1252ToUTF8(AString);
   {$ELSE}
    Result := String(AString) ;
   {$ENDIF}
  {$ELSE}
   Result := AString
  {$ENDIF}
 End;
Begin
 {$IFDEF NOGUI}
  Msg := {$IFDEF FPC}'Lazarus/FPC ' + Format('%d.%d.%d', [lcl_major, lcl_minor, lcl_release]){$ELSE}GetDelphiVersion{$ENDIF}+sLineBreak+
         'Rest Dataware Componentes'+sLineBreak+
         'http://www.restdw.com.br'+sLineBreak+sLineBreak+
         'Version : '+ DWVERSAO;
  Msg := DWStr(Msg);
  Writeln( Msg )
 {$ELSE}
   Msg := {$IFDEF FPC}'Lazarus/FPC ' + Format('%d.%d.%d', [lcl_major, lcl_minor, lcl_release]){$ELSE}GetDelphiVersion{$ENDIF}+sLineBreak+
          'Rest Dataware Componentes'+sLineBreak+sLineBreak+
          'http://www.restdw.com.br'+sLineBreak+sLineBreak+
          'Version : '+ DWVERSAO;
   Msg := DWStr(Msg);
  {$IFNDEF LAMW}
   {$IFNDEF LINUXFMX}
    frm := Tfrm_About.Create(nil);
    {$IFNDEF FPC}
     {$IF Defined(HAS_FMX)}
      frm.lbl_msg.Text := Msg;
     {$ELSE}
      frm.lbl_msg.Caption:= Msg;
     {$IFEND}
    {$ELSE}
    frm.lbl_msg.Caption:= Msg;
    {$ENDIF}
    frm.ShowModal;
    {$ENDIF}
  {$ENDIF}
 {$ENDIF}
End;


end.

