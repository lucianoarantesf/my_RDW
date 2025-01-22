{
 Esse editor SQL foi desenvolvido para integrar mais um recurso ao pacote de
 componentes REST Dataware, a inten��o � ajudar na produtividade.
 Desenvolvedor : Julio C�sar Andrade dos Anjos/Gilberto Rocha da Silva
 Data : 19/02/2018
}

unit uDWSqlEditor;

{$I uRESTDW.inc}

interface

uses
  SysUtils, Dialogs, Forms, ExtCtrls, StdCtrls, ComCtrls, DBGrids, uRESTDWPoolerDB, DB{$IFNDEF FPC}, Grids{$ENDIF}, Controls,
  Classes,{$IFDEF FPC}FormEditingIntf, PropEdits, lazideintf{$ELSE}DesignEditors, DesignIntf{$ENDIF};

Const
 cSelect = 'Select %s From %s';
 cInsert = 'Insert into %s (%s) Values (%s)';
 cDelete = 'Delete From %s Where ';
 cUpdate = 'Update %s Set %s Where ';

 Type

  { TFrmDWSqlEditor }

  TFrmDWSqlEditor = class(TForm)
   BtnCancelar: TButton;
   BtnExecute: TButton;
   BtnOk: TButton;
   DBGridRecord: TDBGrid;
   Memo: TMemo;
   PageControl: TPageControl;
   PageControlResult: TPageControl;
   PnlAction: TPanel;
   PnlButton: TPanel;
   PnlSQL: TPanel;
    pSQLEditor: TPanel;
    lbTables: TListBox;
    labSql: TLabel;
    Label1: TLabel;
    lbFields: TListBox;
    Label2: TLabel;
    pSQLTypes: TPanel;
    rbInsert: TRadioButton;
    rbSelect: TRadioButton;
    rbDelete: TRadioButton;
    rbUpdate: TRadioButton;
    TabSheetSQL: TTabSheet;
    TabSheetTable: TTabSheet;
    procedure BtnExecuteClick(Sender: TObject);
    {$IFNDEF FPC}
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    {$ELSE}
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    {$ENDIF}
    procedure FormShow(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lbTablesClick(Sender: TObject);
    procedure lbTablesKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MemoDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure MemoDragDrop(Sender, Source: TObject; X, Y: Integer);
 Private
  { Private declarations }
  DataSource         : TDataSource;
  RESTDWDatabase     : TRESTDWDatabase;
  RESTDWClientSQL,
  RESTDWClientSQLB   : TRESTDWClientSQL;
  vLastSelect,
  vOldSQL            : String;
  Procedure SetFields;
  Function  BuildSQL : String;
 Public
  { Public declarations }
  Procedure SetClientSQL(Value : TRESTDWClientSQL);
 End;

 Type
  TDWSQLEditor = Class(TStringProperty)
 Public
  Function  GetAttributes        : TPropertyAttributes; Override;
  Procedure Edit;                                       Override;
  Function  GetValue             : String;              Override;
 End;

Var
 FrmDWSqlEditor : TFrmDWSqlEditor;

Implementation

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

Function TDWSQLEditor.GetValue : String;
Begin
 Result := Trim(TRESTDWClientSQL(GetComponent(0)).SQL.Text);
 If Trim(Result) = '' Then
  Result := 'Click here to set SQL...'
End;

Procedure TDWSQLEditor.Edit;
Var
 objObj : TRESTDWClientSQL;
Begin
 FrmDWSqlEditor := TFrmDWSqlEditor.Create(Application);
 Try
  objObj        := TRESTDWClientSQL(GetComponent(0));
  FrmDWSqlEditor.SetClientSQL(objObj);
  FrmDWSqlEditor.ShowModal;
  {ELOY}
  objObj        := Nil;
  FrmDWSqlEditor.Free;
 Except
 End;
End;

Function TDWSQLEditor.GetAttributes: TPropertyAttributes;
Begin
 Result := [paDialog, paReadonly];
End;

procedure TFrmDWSqlEditor.BtnCancelarClick(Sender: TObject);
begin
 RESTDWClientSQL.SQL.Text := vOldSQL;
end;

Procedure TFrmDWSqlEditor.BtnExecuteClick(Sender: TObject);
Begin
 Screen.Cursor := crHourGlass;
 Try
  RESTDWClientSQLB.Close;
  RESTDWClientSQLB.BinaryRequest        := RESTDWClientSQL.BinaryRequest;
  {$IFNDEF DWMEMTABLE}
  RESTDWClientSQLB.BinaryCompatibleMode := RESTDWClientSQL.BinaryCompatibleMode;
  {$ENDIF}
  RESTDWClientSQLB.SQL.Clear;
  RESTDWClientSQLB.SQL.Add(Memo.Lines.Text);
  RESTDWClientSQLB.Open;
 Finally
  Screen.Cursor := crDefault;
 End;
End;

{$IFNDEF FPC}
procedure TFrmDWSqlEditor.FormClose(Sender: TObject; var Action: TCloseAction);
{$ELSE}
procedure TFrmDWSqlEditor.FormClose(Sender: TObject; var CloseAction: TCloseAction);
{$ENDIF}
begin
 If MessageDlg({$IFDEF FPC}'SQL Editor', {$ENDIF}'Realmente deseja sair ?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes  then
  Begin
   {$IFNDEF FPC}Action:={$ELSE}CloseAction:={$ENDIF}caNone;
   Exit;
  End;
 {ELOY}
 {$IFNDEF FPC}
 RESTDWClientSQLB.Active := False;
 FreeAndNil(RESTDWClientSQLB);
 RESTDWDatabase.Active   := False;
 FreeAndNil(RESTDWDatabase);
 FreeAndNil(DataSource);
 Release;
 {$ENDIF}
end;

procedure TFrmDWSqlEditor.BtnOkClick(Sender: TObject);
begin
 RESTDWClientSQL.SQL.Text := Memo.Text;
end;

procedure TFrmDWSqlEditor.FormCreate(Sender: TObject);
begin
 RESTDWClientSQLB          := TRESTDWClientSQL.Create(Self);
 RESTDWDatabase            := TRESTDWDatabase.Create(Self);
 RESTDWClientSQLB.DataBase := RESTDWDatabase;
 vLastSelect               := '';
end;

procedure TFrmDWSqlEditor.FormShow(Sender: TObject);
begin
 DataSource                := TDataSource.Create(Self);
 DataSource.DataSet        := RESTDWClientSQLB;
 DBGridRecord.DataSource   := DataSource;
 PnlButton.Visible         := False;
 PageControlResult.Visible := PnlButton.Visible;
 If RESTDWClientSQL <> Nil Then
  Begin
   PnlButton.Visible         := RESTDWClientSQL.DataBase <> Nil;
   PageControlResult.Visible := PnlButton.Visible;
  End;
 pSQLEditor.Visible        := PageControlResult.Visible;
end;

Procedure TFrmDWSqlEditor.SetFields;
Var
 vMemString : TStringList;
Begin
 If (lbTables.Count > 0) And (lbTables.ItemIndex > -1)  And
    (vLastSelect <> lbTables.Items[lbTables.itemIndex]) Then
  Begin
   If RESTDWClientSQL.DataBase <> Nil Then
    Begin
     vLastSelect                          := lbTables.Items[lbTables.itemIndex];
     vMemString                           := TStringList.Create;
     Try
      RESTDWDatabase.GetFieldNames(lbTables.Items[lbTables.itemIndex], vMemString);
      lbFields.Items.Text                 := vMemString.Text;
     Finally
      FreeAndNil(vMemString);
     End;
    End;
  End
 Else If (lbTables.Count > 0) And (lbTables.ItemIndex = -1) Then
  lbFields.Items.Clear;
End;

Procedure TFrmDWSqlEditor.SetClientSQL(Value: TRESTDWClientSQL);
Var
 vMemString : TStringList;
Begin
 RESTDWClientSQL           := Value;
 vOldSQL                   := RESTDWClientSQL.SQL.Text;
 Memo.Lines.Text           := vOldSQL;
 If RESTDWClientSQL.DataBase <> Nil Then
  Begin
   RESTDWDatabase.AccessTag             := RESTDWClientSQL.DataBase.AccessTag;
   RESTDWDatabase.Encoding              := RESTDWClientSQL.DataBase.Encoding;
   RESTDWDatabase.Context               := RESTDWClientSQL.DataBase.Context;
   RESTDWDatabase.EncodeStrings         := RESTDWClientSQL.DataBase.EncodeStrings;
   RESTDWDatabase.Compression           := RESTDWClientSQL.DataBase.Compression;
   RESTDWDatabase.ParamCreate           := RESTDWClientSQL.DataBase.ParamCreate;
   RESTDWDatabase.PoolerName            := RESTDWClientSQL.DataBase.PoolerName;
   RESTDWDatabase.PoolerPort            := RESTDWClientSQL.DataBase.PoolerPort;
   RESTDWDatabase.PoolerService         := RESTDWClientSQL.DataBase.PoolerService;
   RESTDWDatabase.PoolerURL             := RESTDWClientSQL.DataBase.PoolerURL;
   RESTDWDatabase.Proxy                 := RESTDWClientSQL.DataBase.Proxy;
   RESTDWDatabase.ProxyOptions.Server   := RESTDWClientSQL.DataBase.ProxyOptions.Server;
   RESTDWDatabase.ProxyOptions.Port     := RESTDWClientSQL.DataBase.ProxyOptions.Port;
   RESTDWDatabase.ProxyOptions.Login    := RESTDWClientSQL.DataBase.ProxyOptions.Login;
   RESTDWDatabase.ProxyOptions.Password := RESTDWClientSQL.DataBase.ProxyOptions.Password;
   RESTDWDatabase.RequestTimeOut        := RESTDWClientSQL.DataBase.RequestTimeOut;
   RESTDWDatabase.TypeRequest           := RESTDWClientSQL.DataBase.TypeRequest;
   RESTDWDatabase.WelcomeMessage        := RESTDWClientSQL.DataBase.WelcomeMessage;
   RESTDWDatabase.CriptOptions.Use      := RESTDWClientSQL.DataBase.CriptOptions.Use;
   RESTDWDatabase.CriptOptions.Key      := RESTDWClientSQL.DataBase.CriptOptions.Key;
   RESTDWDatabase.DataRoute             := RESTDWClientSQL.DataBase.DataRoute;
   RESTDWDatabase.ServerContext         := RESTDWClientSQL.DataBase.ServerContext;
   RESTDWDatabase.AuthenticationOptions.Assign(RESTDWClientSQL.DataBase.AuthenticationOptions);
   vMemString                           := TStringList.Create;
   Try
    RESTDWDatabase.GetTableNames(vMemString);
    lbTables.Items.Text                 := vMemString.Text;
    If lbTables.Count > 0 Then
     Begin
      lbTables.ItemIndex                 := 0;
      SetFields;
     End;
   Finally
    FreeAndNil(vMemString);
   End;
  End;
End;

procedure TFrmDWSqlEditor.FormResize(Sender: TObject);
begin
 PageControl.Top    := 0;
 PageControl.Left   := pSQLEditor.Width;
 PageControl.Height := (Height - PageControlResult.Height) - PnlAction.Height{$IFNDEF FPC} - 48{$ELSE} - 10{$ENDIF};
 PageControl.Width  := Width  - pSQLEditor.Width - PnlButton.Width{$IFNDEF FPC} - 25{$ELSE} - 10{$ENDIF};
end;

procedure TFrmDWSqlEditor.lbTablesClick(Sender: TObject);
begin
 SetFields;
end;

procedure TFrmDWSqlEditor.lbTablesKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 SetFields;
end;

procedure TFrmDWSqlEditor.MemoDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
 Accept := Source is Tlistbox;
end;

Function TFrmDWSqlEditor.BuildSQL : String;
Var
 I         : Integer;
 vFieldsA,
 vFieldsB  : String;
Begin
 Result   := '';
 vFieldsA := Result;
 vFieldsB := Result;
 If lbTables.itemIndex < 0 Then
  Exit;
 If rbSelect.Checked Then
  Result := Format(cSelect, ['%s', lbTables.Items[lbTables.itemIndex]]);
 If rbInsert.Checked Then
  Result := Format(cInsert, [lbTables.Items[lbTables.itemIndex], '%s', '%s']);
 If rbDelete.Checked Then
  Result := Format(cDelete, [lbTables.Items[lbTables.itemIndex]]);
 If rbUpdate.Checked Then
  Result := Format(cUpdate, [lbTables.Items[lbTables.itemIndex], '%s']);
 If lbFields.SelCount > 0 Then
  Begin
   If rbSelect.Checked Then
    Begin
     For I := 0 To lbFields.Count -1 Do
      Begin
       If lbFields.Selected[I] Then
       If vFieldsA = '' Then
        vFieldsA := lbFields.Items[I]
       Else
        vFieldsA := vFieldsA + ', ' + lbFields.Items[I];
      End;
     Result := Format(Result, [vFieldsA]);
    End;
   If rbInsert.Checked Then
    Begin
     For I := 0 To lbFields.Count -1 Do
      Begin
       If lbFields.Selected[I] Then
       If vFieldsA = '' Then
        vFieldsA := lbFields.Items[I]
       Else
        vFieldsA := vFieldsA + ', ' + lbFields.Items[I];
       If lbFields.Selected[I] Then
       If vFieldsB = '' Then
        vFieldsB := ':' + lbFields.Items[I]
       Else
        vFieldsB := vFieldsB + ', :' + lbFields.Items[I];
      End;
     Result := Format(Result, [vFieldsA, vFieldsB]);
    End;
   If rbUpdate.Checked Then
    Begin
     For I := 0 To lbFields.Count -1 Do
      Begin
       If lbFields.Selected[I] Then
       If vFieldsA = '' Then
        vFieldsA := lbFields.Items[I] + ' = :' + lbFields.Items[I]
       Else
        vFieldsA := vFieldsA + ', ' + lbFields.Items[I] + ' = :' + lbFields.Items[I];
      End;
     Result := Format(Result, [vFieldsA]);
    End;
  End
 Else
  Begin
   If rbSelect.Checked Then
    Result := Format(Result, ['*']);
   If rbInsert.Checked Then
    Begin
     For I := 0 To lbFields.Count -1 Do
      Begin
       If vFieldsA = '' Then
        vFieldsA := lbFields.Items[I]
       Else
        vFieldsA := vFieldsA + ', ' + lbFields.Items[I];
       If vFieldsB = '' Then
        vFieldsB := ':' + lbFields.Items[I]
       Else
        vFieldsB := vFieldsB + ', :' + lbFields.Items[I];
      End;
     Result := Format(Result, [vFieldsA, vFieldsB]);
    End;
   If rbUpdate.Checked Then
    Begin
     For I := 0 To lbFields.Count -1 Do
      Begin
       If vFieldsA = '' Then
        vFieldsA := lbFields.Items[I] + ' = :' + lbFields.Items[I]
       Else
        vFieldsA := vFieldsA + ', ' + lbFields.Items[I] + ' = :' + lbFields.Items[I];
      End;
     Result := Format(Result, [vFieldsA]);
    End;
  End;
End;

procedure TFrmDWSqlEditor.MemoDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
 If Source = lbTables Then
  If Trim(TMemo(Sender).Lines.Text) = '' Then
   TMemo(Sender).Lines.Text := BuildSQL
  Else
   TMemo(Sender).Lines.Text := TMemo(Sender).Lines.Text + sLineBreak + BuildSQL;
end;

end.
