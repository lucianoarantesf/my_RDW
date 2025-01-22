unit uDWJSONViewer;

interface

{.$DEFINE DEBBUGRDW}

uses
  SysUtils, Dialogs, Forms, ExtCtrls, StdCtrls, ComCtrls, DBGrids, Messages, Variants,
  Classes, Graphics, Controls,
  uDWJSONInterface, uDWConsts, uDWResponseTranslator, DB,
  uDWDataset, uDWConstsData, uRESTDWPoolerDB, uDWAbout, Grids{$IFNDEF DEBBUGRDW},
  {$IFDEF FPC}ComponentEditors, FormEditingIntf, PropEdits, lazideintf{$ELSE}DesignWindows, DesignEditors{$ENDIF}{$ENDIF};

Type
 PDWJsonParserItem = ^TDWJsonParserItem;
 TDWJsonParserItem = Class
  ElementName,
  JsonValue : String;
End;

Type

  { TfDWJSONViewer }

  TfDWJSONViewer = class(TForm)
    chk_datatype: TCheckBox;
    DWResponseTranslator1: TDWResponseTranslator;
    Panel1: TPanel;
    Memo1: TMemo;
    Button1: TButton;
    Label2: TLabel;
    Panel2: TPanel;
    TreeView1: TTreeView;
    Label1: TLabel;
    Button2: TButton;
    Panel3: TPanel;
    Label3: TLabel;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    RESTDWClientSQL1: TRESTDWClientSQL;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure TreeView1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
   vBaseTranslator : TDWResponseTranslator;
   Procedure LoadItem;
   Procedure ClearTree;
    { Private declarations }
  public
    { Public declarations }
   Property BaseTranslator : TDWResponseTranslator Read vBaseTranslator Write vBaseTranslator;
  end;
 {$IFNDEF DEBBUGRDW}
 Type
  TDWJSONViewer = Class(TComponentEditor)
 Public
  Function  GetVerbCount      : Integer;  Override;
  Function  GetVerb    (Index : Integer): String; Override;
  Procedure ExecuteVerb(Index : Integer); Override;
 End;
 {$ENDIF}

var
  fDWJSONViewer: TfDWJSONViewer;

implementation

uses uDWJSONObject;
{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

{$IFNDEF DEBBUGRDW}
Function TDWJSONViewer.GetVerbCount: Integer;
Begin
 Result := 1;
End;

Function TDWJSONViewer.GetVerb(Index: Integer): string;
Begin
 Case Index of
  0 : Result := 'FieldDefs &Editor';
 End;
End;

Procedure TDWJSONViewer.ExecuteVerb(Index: Integer);
Var
 vDWJSONViewer : TfDWJSONViewer;
Begin
 Inherited;
 Case Index of
   0 :
    Begin
     vDWJSONViewer                := TfDWJSONViewer.Create(Application);
     vDWJSONViewer.BaseTranslator := (Component as TDWResponseTranslator);
     vDWJSONViewer.Showmodal;
    End;
 End;
End;
{$ENDIF}

Function CreateItem(TreeView  : TTreeView;
                    treeNode  : TTreeNode;
                    ItemName,
                    JsonValue : String) : TTreeNode;
Var
 vClassName,
 vValue      : String;
 vJsonValue  : PDWJsonParserItem;
 I           : Integer;
 bJsonValue  : TDWJSONObject;
 bJsonValueB : TDWJSONBase;
 bJsonArrayB : TDWJSONArray;
 Function TextClass(Value : String) : String;
 Begin
  If (Lowercase(Value) = Lowercase('TJSONObject')) Or
     (Lowercase(Value) = Lowercase('TDWJSONObject')) Then
   Result := '{}'
  Else If (Lowercase(Value) = Lowercase('TJSONArray')) Or
          (Lowercase(Value) = Lowercase('TDWJSONArray')) Then
   Result := '[]';
 End;
Begin
 vValue        := Trim(JsonValue);
 Result        := Nil;
 If Trim(vValue) <> '' Then
  Begin
   If vValue[InitStrPos] = '{' Then
    Begin
     bJsonValue  := TDWJSONObject.Create(JsonValue);
     If bJsonValue.PairCount > 0 Then
      Begin
       If ItemName <> '' Then
        Begin
         Result := TreeView.Items.AddChild(treeNode, ItemName + ' - ' + TextClass(bJsonValue.Classname));
         New(vJsonValue);
         vJsonValue^             := TDWJsonParserItem.Create;
         vJsonValue^.ElementName := ItemName;
         vJsonValue^.JsonValue   := JsonValue;
         Result.Data             := vJsonValue;
//         Dispose(vJsonValue);
        End
       Else
        Result := treeNode;
       For I := 0 To bJsonValue.PairCount -1 Do
        Begin
         vClassName := bJsonValue.Pairs[I].ClassName;
         If (Lowercase(vClassName) = Lowercase('TJSONObject'))   Or
            (Lowercase(vClassName) = Lowercase('TDWJSONObject')) Or
            (Lowercase(vClassName) = Lowercase('TJSONArray'))    Or
            (Lowercase(vClassName) = Lowercase('TDWJSONArray'))  Then
          CreateItem(TreeView, Result, bJsonValue.Pairs[I].Name, unescape_chars(bJsonValue.Pairs[I].Value))
         Else
          Begin
           If bJsonValue.Pairs[I].Name <> '' Then
            TreeView.Items.AddChild(Result, Format('%s = %s', [bJsonValue.Pairs[I].Name, unescape_chars(bJsonValue.Pairs[I].Value)]))
           Else
            TreeView.Items.AddChild(Result, unescape_chars(bJsonValue.Pairs[I].Value));
          End;
        End;
      End;
     If Assigned(bJsonValue) Then
      FreeAndNil(bJsonValue);
    End
   Else If vValue[InitStrPos] = '[' Then
    Begin
     bJsonValue  := TDWJSONObject.Create(JsonValue);
     bJsonArrayB := TDWJSONArray(bJsonValue);
     If bJsonArrayB.ElementCount > 0 Then
      Begin
       Result := TreeView.Items.AddChild(treeNode, ItemName + ' - []');
       New(vJsonValue);
       vJsonValue^             := TDWJsonParserItem.Create;
       vJsonValue^.ElementName := ItemName;
       vJsonValue^.JsonValue   := JsonValue;
       Result.Data             := vJsonValue;
//       Dispose(vJsonValue);
      End;
     For I := 0 To bJsonArrayB.ElementCount -1 do
      Begin
       Try
        bJsonValueB := bJsonArrayB.GetObject(I);
        vClassName  := '';
        If ((Lowercase(TDWJSONObject(bJsonValueB).tojson) <> 'null') And
            (Lowercase(TDWJSONObject(bJsonValueB).tojson) <> ''))    Then
         Begin
          If (TDWJSONObject(bJsonValueB).Classtype = TDWJSONObject)  Then
           vClassName  := 'TJSONObject'
          Else
           vClassName  := TDWJSONObject(bJsonValueB).ClassName;
         End;
        If (Lowercase(vClassName) = Lowercase('TJSONObject'))   Or
           (Lowercase(vClassName) = Lowercase('TDWJSONObject')) Or
           (Lowercase(vClassName) = Lowercase('TJSONArray'))    Or
           (Lowercase(vClassName) = Lowercase('TDWJSONArray'))  Then
         CreateItem(TreeView, TreeView.Items.AddChild(Result, TextClass(vClassName)), '', TDWJSONObject(bJsonValueB).ToJSON)
        Else
         Begin
          If TDWJSONObject(bJsonValueB).Pairs[I].Name <> '' Then
           TreeView.Items.AddChild(Result, Format('%s = %s', [TDWJSONObject(bJsonValueB).Pairs[I].Name,
                                                              unescape_chars(TDWJSONObject(bJsonValueB).Pairs[I].Value)]))
          Else
           TreeView.Items.AddChild(Result, unescape_chars(TDWJSONObject(bJsonValueB).Pairs[I].Value));
         End;
       Finally
        FreeAndNil(bJsonValueB);
       End;
      End;
     FreeAndNil(bJsonArrayB);
    End;
  End;
End;

Function TrashRemove(Value : String) : String;
Begin
 Result := StringReplace(Value,  #13, '', [rfReplaceAll]);
 Result := StringReplace(Result, #10, '', [rfReplaceAll]);
 Result := StringReplace(Result, #9,  '', [rfReplaceAll]);
End;

Procedure TfDWJSONViewer.ClearTree;
Var
 I          : Integer;
 vJsonValue : PDWJsonParserItem;
Begin
 For I := 0 To TreeView1.Items.Count -1 Do
  Begin
   If Assigned(TreeView1.Items[I].Data) Then
    Begin
     vJsonValue := TreeView1.Items[I].Data;
     TDWJsonParserItem(vJsonValue^).Free;
     Dispose(vJsonValue);
    End;
  End;
 TreeView1.Items.Clear;
End;

procedure TfDWJSONViewer.Button1Click(Sender: TObject);
Var
 I          : Integer;
 bJsonValue : TDWJSONObject;
begin
 bJsonValue  := TDWJSONObject.Create(TrashRemove(Memo1.Lines.Text));
 Try
  ClearTree;
  If bJsonValue.PairCount > 0 Then
   Begin
    For I := 0 To bJsonValue.PairCount -1 Do
     Begin
      If (Lowercase(bJsonValue.pairs[I].classname) = Lowercase('TJSONObject'))   Or
         (Lowercase(bJsonValue.pairs[I].classname) = Lowercase('TDWJSONObject')) Or
         (Lowercase(bJsonValue.pairs[I].classname) = Lowercase('TJSONArray'))    Or
         (Lowercase(bJsonValue.pairs[I].classname) = Lowercase('TDWJSONArray')) Then
       CreateItem(TreeView1, Nil, bJsonValue.pairs[I].Name, bJsonValue.pairs[I].Value)
      Else
       Begin
        CreateItem(TreeView1, Nil, '', bJsonValue.ToJSON);
        Break;
       End;
     End;
   End;
 Finally
  FreeAndNil(bJsonValue);
  TreeView1.FullExpand;
 End;
end;

procedure TfDWJSONViewer.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
 ClearTree;
 fDWJSONViewer := Nil;
 Release;
end;

Procedure TfDWJSONViewer.LoadItem;
Begin
 If TreeView1.Selected <> Nil Then
  Begin
   If Assigned(TreeView1.Selected.Data) Then
    Begin
     RESTDWClientSQL1.Close;
     RESTDWClientSQL1.Fields.Clear;
     RESTDWClientSQL1.FieldDefs.Clear;
     DWResponseTranslator1.FieldDefs.Clear;
     DWResponseTranslator1.ElementRootBaseName := '';
     DBGrid1.Columns.Clear;
     RESTDWClientSQL1.OpenJson(TDWJsonParserItem(TreeView1.Selected.Data^).JsonValue,
                               DWResponseTranslator1.ElementRootBaseName, True);
    End;
  End;
End;

procedure TfDWJSONViewer.TreeView1Click(Sender: TObject);
begin
 LoadItem;
end;

procedure TfDWJSONViewer.Button2Click(Sender: TObject);
Var
 I      : Integer;
 vItem  : TDWFieldDef;
 vValue : string;
 bJsonValue  : TDWJSONObject;
begin
 If TreeView1.Selected <> Nil Then
  Begin
   If Assigned(TreeView1.Selected.Data) Then
    Begin
     vBaseTranslator.ElementRootBaseName := TDWJsonParserItem(TreeView1.Selected.Data^).ElementName;
     vBaseTranslator.FieldDefs.Clear;
     For I := 0 To DWResponseTranslator1.FieldDefs.Count -1 Do
      Begin
       vItem              := TDWFieldDef(vBaseTranslator.FieldDefs.Add);
       vItem.FieldName    := DWResponseTranslator1.FieldDefs[I].FieldName;
       vItem.ElementName  := DWResponseTranslator1.FieldDefs[I].ElementName;
       vItem.ElementIndex := DWResponseTranslator1.FieldDefs[I].ElementIndex;
       vItem.FieldSize    := DWResponseTranslator1.FieldDefs[I].FieldSize;
       vItem.Precision    := DWResponseTranslator1.FieldDefs[I].Precision;
       vItem.Required     := DWResponseTranslator1.FieldDefs[I].Required;
       If chk_datatype.Checked Then
        Begin
         vValue:= Trim(TDWJsonParserItem(TreeView1.Selected.Data^).JsonValue);
         If (Trim(vValue) <> '') and (vValue[InitStrPos] = '{') Then
          Begin
           bJsonValue  := TDWJSONObject.Create(vValue);
           // Unica forma que consegui passar o DataType
           if (bJsonValue.Pairs[I].ClassName = '_String') then
            vItem.DataType  := ovString
           else if (bJsonValue.Pairs[I].ClassName = '_Double') then
            vItem.DataType  := ovFloat
           else
            vItem.DataType  := ovUnknown;
           // Precisa definir todas formas aceitas no JSON
           {  ----- > tentei usar assim, mas sem sucesso < -------
           vItem.DataType   := GetValueTypeTranslator(bJsonValue.Pairs[I].ClassName);
           }
           FreeAndNil(bJsonValue);
          End
        End
       Else
        vItem.DataType     := DWResponseTranslator1.FieldDefs[I].DataType;
      End;
     ModalResult          := mrOk;
    End;
  End;
End;

end.

