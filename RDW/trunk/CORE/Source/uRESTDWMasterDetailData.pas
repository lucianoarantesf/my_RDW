unit uRESTDWMasterDetailData;

{
  REST Dataware vers�o CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tamb�m tem por objetivo levar componentes compat�veis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc� usu�rio que precisa
 de produtividade e flexibilidade para produ��o de Servi�os REST/JSON, simplificando o processo para voc� programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do CORE do pacote.
 Ivan Cesar                 - Admin - Administrador do CORE do pacote.
 Joanan Mendon�a Jr. (jlmj) - Admin - Administrador do CORE do pacote.
 Giovani da Cruz            - Admin - Administrador do CORE do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Alexandre Souza            - Admin - Administrador do Grupo de Organiza��o.
 Anderson Fiori             - Admin - Gerencia de Organiza��o dos Projetos
 Mizael Rocha               - Member Tester and DEMO Developer.
 Fl�vio Motta               - Member Tester and DEMO Developer.
 Itamar Gaucho              - Member Tester and DEMO Developer.
 Ico Menezes                - Member Tester and DEMO Developer.
}


Interface

Uses SysUtils, Classes;

Type
 TRESTClient = Class End;

Type
 TMasterDetailItem = Class(TObject)
 Private
  vDataSet : TRESTClient;
  vFields  : TStringList;
 Protected
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Procedure   ParseFields(Value : String);
  Property    DataSet : TRESTClient    Read vDataSet Write vDataSet;
  Property    Fields  : TStringList    Read vFields  Write vFields;
End;

Type
 PMasterDetailItem = ^TMasterDetailItem;
 TMasterDetailList = Class(TList)
 Private
  Function  GetRec(Index    : Integer)      : TMasterDetailItem;  Overload;
  Procedure PutRec(Index    : Integer; Item : TMasterDetailItem); Overload;
 Protected
 Public
  Destructor  Destroy;Override;                      //Destroy a Classe
  Function  GetItem(Value: TRESTClient)       : TMasterDetailItem;
  Procedure Delete(Index : Integer);                              Overload;
  Procedure DeleteDS(Value : TRESTClient);
  Function  Add   (Item  : TMasterDetailItem) : Integer;          Overload;
  Property  Items[Index  : Integer]           : TMasterDetailItem   Read GetRec Write PutRec; Default;
End;

Implementation

Uses uRESTDWPoolerDB;

{ TMasterDetailList }

Function TMasterDetailList.Add(Item: TMasterDetailItem): Integer;
Var
 vItem : ^TMasterDetailItem;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMasterDetailList.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     {$IFDEF FPC}
     FreeAndNil(TList(Self).Items[Index]^);
     {$ELSE}
      {$IF CompilerVersion > 33}
       FreeAndNil(TMasterDetailItem(TList(Self).Items[Index]^));
      {$ELSE}
       FreeAndNil(TList(Self).Items[Index]^);
      {$IFEND}
     {$ENDIF}
     {$IFDEF FPC}
      Dispose(PMasterDetailItem(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Function TMasterDetailList.GetItem(Value : TRESTClient) : TMasterDetailItem;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count -1 Do
  Begin
   If (TMasterDetailItem(TList(Self).Items[I]^)          <> Nil)   And
      (TMasterDetailItem(TList(Self).Items[I]^).vDataSet =  Value) Then
    Begin
     Result := TMasterDetailItem(TList(Self).Items[I]^);
     Break;
    End;
  End;
End;

Procedure TMasterDetailList.DeleteDS(Value : TRESTClient);
Var
 I : Integer;
Begin
 If Self <> Nil Then
  Begin
   For I := 0 To Self.Count -1 Do
    Begin
     If (TMasterDetailItem(TList(Self).Items[I]^)          <> Nil)   And
        (TMasterDetailItem(TList(Self).Items[I]^).vDataSet =  Value) Then
      Begin
       TMasterDetailList(Self).Delete(I);
       Break;
      End;
    End;
  End;
End;

Destructor TMasterDetailList.Destroy;
Var
 I : Integer;
Begin
  For I := Count-1 downto 0 Do
   Delete(I);
  inherited;
End;

Function TMasterDetailList.GetRec(Index: Integer): TMasterDetailItem;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMasterDetailItem(TList(Self).Items[Index]^);
End;

Procedure TMasterDetailList.PutRec(Index: Integer; Item: TMasterDetailItem);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMasterDetailItem(TList(Self).Items[Index]^) := Item;
End;

Constructor TMasterDetailItem.Create;
Begin
 vFields := TStringList.Create;
End;

Destructor TMasterDetailItem.Destroy;
Begin
 vFields.Free;
 Inherited;
End;

Procedure TMasterDetailItem.ParseFields(Value : String);
Var
 vTempFields : String;
Begin
 vFields.Clear;
 vTempFields := Value;
 While (vTempFields <> '') Do
  Begin
   If Pos(';', vTempFields) > 0 Then
    Begin
     vFields.Add(UpperCase(Trim(Copy(vTempFields, 1, Pos(';', vTempFields) -1))));
     Delete(vTempFields, 1, Pos(';', vTempFields));
    End
   Else
    Begin
     vFields.Add(UpperCase(Trim(vTempFields)));
     vTempFields := '';
    End;
   vTempFields := Trim(vTempFields);
  End;
End;

end.
