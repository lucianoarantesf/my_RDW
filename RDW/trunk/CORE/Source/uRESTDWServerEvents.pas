unit uRESTDWServerEvents;

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


interface

Uses
 SysUtils, Classes, uDWJSONObject, uDWConsts, uDWConstsData, uDWAbout,
 uRESTDWBase, uDWJSONTools, uDWConstsCharset, uDWJSONInterface;

Const
 TServerEventsConst = '{"typeobject":"%s", "objectdirection":"%s", "objectvalue":"%s", "paramname":"%s", "encoded":"%s", "default":"%s"}';

Type
 TDWReplyEvent       = Procedure(Var   Params      : TDWParams;
                                 Var   Result      : String)          Of Object;
 TDWReplyEventByType = Procedure(Var   Params      : TDWParams;
                                 Var   Result      : String;
                                 Const RequestType : TRequestType;
                                 Var   StatusCode  : Integer;
                                 RequestHeader     : TStringList)    Of Object;
 TDWAuthRequest      = Procedure(Const Params      : TDWParams;
                                 Var   Rejected    : Boolean;
                                 Var   ResultError : String;
                                 Var   StatusCode  : Integer;
                                 RequestHeader     : TStringList)     Of Object;
 TObjectEvent        = Procedure(aSelf             : TComponent)      Of Object;
 TObjectExecute      = Procedure(Const aSelf       : TCollectionItem) Of Object;
 TOnBeforeSend       = Procedure(aSelf             : TComponent)      Of Object;

Type
 TDWReplyEventData = Class(TComponent)
 Private
  vReplyEvent         : TDWReplyEvent;
  vDWReplyEventByType : TDWReplyEventByType;
  vDWAuthRequest      : TDWAuthRequest;
  vBeforeExecute      : TObjectExecute;
 Public
  Property    OnReplyEvent       : TDWReplyEvent       Read vReplyEvent         Write vReplyEvent;
  Property    OnReplyEventByType : TDWReplyEventByType Read vDWReplyEventByType Write vDWReplyEventByType;
  Property    OnAuthRequest      : TDWAuthRequest      Read vDWAuthRequest      Write vDWAuthRequest;
  Property    OnBeforeExecute    : TObjectExecute      Read vBeforeExecute      Write vBeforeExecute;
End;

Type
 TDWParamMethod = Class;
 TDWParamMethod = Class(TCollectionItem)
 Private
  vTypeObject      : TTypeObject;
  vObjectDirection : TObjectDirection;
  vObjectValue     : TObjectValue;
  vAlias,
  vDefaultValue,
  vParamName       : String;
  vEncoded         : Boolean;
  vDescription     : TStrings;    //uhmano
  Procedure SetDescription     (Strings  : TStrings);    //uhmano
 Public
  Function    GetDisplayName             : String;       Override;
  Procedure   SetDisplayName(Const Value : String);      Override;
  Constructor Create        (aCollection : TCollection); Override;
  Destructor  Destroy;                                   Override;
 Published
  Property TypeObject      : TTypeObject      Read vTypeObject      Write vTypeObject;
  Property ObjectDirection : TObjectDirection Read vObjectDirection Write vObjectDirection;
  Property ObjectValue     : TObjectValue     Read vObjectValue     Write vObjectValue;
  Property ParamName       : String           Read GetDisplayName   Write SetDisplayName;
  Property Alias           : String           Read vAlias           Write vAlias;
  Property Encoded         : Boolean          Read vEncoded         Write vEncoded;
  Property DefaultValue    : String           Read vDefaultValue    Write vDefaultValue;
  Property Description     : TStrings         Read vDescription     Write SetDescription;    //uhmano
End;

Type
 TDWParamsMethods = Class;
 TDWParamsMethods = Class(TOwnedCollection)
 Private
  fOwner      : TPersistent;
  vAlias      : String;
  Function    GetRec    (Index       : Integer) : TDWParamMethod;  Overload;
  Procedure   PutRec    (Index       : Integer;
                         Item        : TDWParamMethod);            Overload;
  Procedure   ClearList;
  Function    GetRecName(Index       : String)  : TDWParamMethod;  Overload;
  Procedure   PutRecName(Index       : String;
                         Item        : TDWParamMethod);            Overload;
 Public
  Constructor Create     (AOwner     : TPersistent;
                          aItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Procedure   Delete     (Index      : Integer);                   Overload;
  Function    Add        (Item       : TDWParamMethod) : Integer;  Overload;
  Property    Items      [Index      : Integer]   : TDWParamMethod Read GetRec     Write PutRec; Default;
  Property    ParamByName[Index      : String ]   : TDWParamMethod Read GetRecName Write PutRecName;
End;

Type
 TDWEvent = Class;
 TDWEvent = Class(TCollectionItem)
 Protected
 Private
  vDescription                           : TStrings;
  vDWRoutes                              : TDWRoutes;
  vJsonMode                              : TJsonMode;
  vEventName,
  FName                                  : String;
  vDWParams                              : TDWParamsMethods;
  vOwnerCollection                       : TCollection;
  vOnlyPreDefinedParams,
  vNeedAuthorization                     : Boolean;
  DWReplyEventData                       : TDWReplyEventData;
  vBeforeExecute                         : TObjectExecute;
  Function  GetReplyEvent                : TDWReplyEvent;
  Procedure SetReplyEvent      (Value    : TDWReplyEvent);
  Function  GetReplyEventByType          : TDWReplyEventByType;
  Procedure SetReplyEventByType(Value    : TDWReplyEventByType);
  Function  GetAuthRequest               : TDWAuthRequest;
  Procedure SetAuthRequest     (Value    : TDWAuthRequest);
  Procedure SetDescription     (Strings  : TStrings);
 Public
  Function    GetDisplayName             : String;       Override;
  Procedure   SetDisplayName(Const Value : String);      Override;
  Procedure   CompareParams (Var Dest    : TDWParams);
  Procedure   Assign        (Source      : TPersistent); Override;
  Constructor Create        (aCollection : TCollection); Override;
  Function    GetNamePath  : String;                     Override;
  Destructor  Destroy; Override;
 Published
  Property    Routes               : TDWRoutes           Read vDWRoutes             Write vDWRoutes;
  Property    NeedAuthorization    : Boolean             Read vNeedAuthorization    Write vNeedAuthorization;
  Property    DWParams             : TDWParamsMethods    Read vDWParams             Write vDWParams;
  Property    JsonMode             : TJsonMode           Read vJsonMode             Write vJsonMode;
  Property    Name                 : String              Read GetDisplayName        Write SetDisplayName;
  Property    EventName            : String              Read vEventName            Write vEventName;
  Property    Description          : TStrings            Read vDescription          Write SetDescription;
  Property    OnlyPreDefinedParams : Boolean             Read vOnlyPreDefinedParams Write vOnlyPreDefinedParams;
  Property    OnReplyEvent         : TDWReplyEvent       Read GetReplyEvent         Write SetReplyEvent;
  Property    OnReplyEventByType   : TDWReplyEventByType Read GetReplyEventByType   Write SetReplyEventByType;
  Property    OnAuthRequest        : TDWAuthRequest      Read GetAuthRequest        Write SetAuthRequest;
  Property    OnBeforeExecute      : TObjectExecute      Read vBeforeExecute        Write vBeforeExecute;
End;

Type
 TDWEventList = Class;
 TDWEventList = Class(TDWOwnedCollection)
 Protected
  vEditable   : Boolean;
  Function    GetOwner: TPersistent; override;
 Private
  fOwner      : TPersistent;
  Function    GetRec    (Index       : Integer) : TDWEvent;       Overload;
  Procedure   PutRec    (Index       : Integer;
                         Item        : TDWEvent);                 Overload;
  Procedure   ClearList;
  Function    GetRecName(Index       : String)  : TDWEvent;       Overload;
  Procedure   PutRecName(Index       : String;
                         Item        : TDWEvent);                 Overload;
//  Procedure   Editable  (Value : Boolean);
 Public
  Function    Add    : TCollectionItem;
  Constructor Create     (AOwner     : TPersistent;
                          aItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Function    ToJSON : String;
  Procedure   FromJSON   (Value      : String );
  Procedure   Delete     (Index      : Integer);                  Overload;
  Property    Items      [Index      : Integer]  : TDWEvent       Read GetRec     Write PutRec; Default;
  Property    EventByName[Index      : String ]  : TDWEvent       Read GetRecName Write PutRecName;
End;

Type
 TDWServerEvents = Class(TDWComponent)
 Protected
 Private
  vIgnoreInvalidParams : Boolean;
  vEventList           : TDWEventList;
  vAccessTag,
  vServerContext       : String;
  vOnCreate            : TObjectEvent;
  vDescription         : TStrings;    //uhmano
  Procedure SetDescription     (Strings  : TStrings);   //uhmano
 Public
  Destructor  Destroy; Override;
  Constructor Create(AOwner : TComponent);Override; //Cria o Componente
  Procedure   CreateDWParams(EventName    : String;
                             Var DWParams : TDWParams);
 Published
  Property    IgnoreInvalidParams : Boolean      Read vIgnoreInvalidParams Write vIgnoreInvalidParams;
  Property    Events              : TDWEventList Read vEventList           Write vEventList;
  Property    AccessTag           : String       Read vAccessTag           Write vAccessTag;
  Property    ContextName         : String       Read vServerContext       Write vServerContext;
  Property    OnCreate            : TObjectEvent Read vOnCreate            Write vOnCreate;
  Property    Description         : TStrings     Read vDescription         Write SetDescription;    //uhmano
End;

Type
 { TDWClientEvents }
 TDWClientEvents = Class(TDWComponent)
 Private
  vServerEventName  : String;
  vEditParamList,
  vGetEvents        : Boolean;
  vEventList        : TDWEventList;
  vRESTClientPooler : TRESTClientPooler;
  vOnBeforeSend     : TOnBeforeSend;
  vCripto           : TCripto;
  vDescription      : TStrings;   //uhmano
  Procedure SetDescription     (Strings  : TStrings);   // Ma
  Procedure GetOnlineEvents         (Value  : Boolean);
  Procedure SetEventList            (aValue : TDWEventList);
  Function  GetRESTClientPooler             : TRESTClientPooler;
  Procedure SetRESTClientPooler(Const Value : TRESTClientPooler);
  Procedure TokenValidade(Var DWParams : TDWParams;
                          Var Error    : String);
 Protected
  procedure Notification(AComponent: TComponent; Operation: TOperation); override;
 Public
  Destructor  Destroy; Override;
  Constructor Create        (AOwner    : TComponent);Override; //Cria o Componente
  Procedure   CreateDWParams(EventName  : String; Var DWParams     : TDWParams);
  Function    SendEvent     (EventName  : String; Var DWParams     : TDWParams;
                             Var Error  : String; EventType        : TSendEvent = sePOST;
                             Assyncexec : Boolean = False)         : Boolean; Overload;
  Function    SendEvent     (EventName  : String; Var DWParams     : TDWParams;
                             Var Error  : String; Var NativeResult : String;
                             EventType  : TSendEvent = sePOST;
                             Assyncexec : Boolean = False) : Boolean; Overload;
  Procedure   ClearEvents;
  Property    GetEvents        : Boolean           Read vGetEvents          Write GetOnlineEvents;
 Published
  Property    ServerEventName  : String            Read vServerEventName    Write vServerEventName;
  Property    CriptOptions     : TCripto           Read vCripto             Write vCripto;
  Property    RESTClientPooler : TRESTClientPooler Read GetRESTClientPooler Write SetRESTClientPooler;
  Property    Events           : TDWEventList      Read vEventList          Write SetEventList;
  Property    OnBeforeSend     : TOnBeforeSend     Read vOnBeforeSend       Write vOnBeforeSend; // Add Evento por Ico Menezes
  Property    Description      : TStrings          Read vDescription        Write SetDescription;    //uhmano
End;

implementation

{ TDWEvent }

Uses ServerUtils;

Function TDWEvent.GetNamePath: String;
Begin
 Result := vOwnerCollection.GetNamePath + FName;
End;

constructor TDWEvent.Create(aCollection: TCollection);
begin
 Inherited;
 vDWParams             := TDWParamsMethods.Create(aCollection, TDWParamMethod);
 vJsonMode             := jmDataware;
 DWReplyEventData      := TDWReplyEventData.Create(Nil);
 vOwnerCollection      := aCollection;
 FName                 := 'dwevent' + IntToStr(aCollection.Count);
 DWReplyEventData.Name := FName;
 vNeedAuthorization    := True;
 vOnlyPreDefinedParams := False;
 vEventName            := '';
 vDescription          := TStringList.Create;
 vDWRoutes             := [crAll];
end;

Destructor TDWEvent.Destroy;
Begin
 vDWParams.Free;
 DWReplyEventData.Free;
 vDescription.Free;
 Inherited;
End;

Function TDWEvent.GetAuthRequest: TDWAuthRequest;
Begin
 Result := DWReplyEventData.OnAuthRequest;
End;

Function TDWEvent.GetDisplayName: String;
Begin
 Result := DWReplyEventData.Name;
End;

Procedure TDWEvent.Assign(Source: TPersistent);
begin
 If Source is TDWEvent then
  Begin
   FName       := TDWEvent(Source).Name;
   vDWParams   := TDWEvent(Source).DWParams;
   DWReplyEventData.OnBeforeExecute := TDWEvent(Source).OnBeforeExecute;
   DWReplyEventData.OnReplyEvent := TDWEvent(Source).OnReplyEvent;
  End
 Else
  Inherited;
End;

Function TDWEvent.GetReplyEvent: TDWReplyEvent;
Begin
 Result := DWReplyEventData.OnReplyEvent;
End;

Function TDWEvent.GetReplyEventByType : TDWReplyEventByType;
Begin
 Result := DWReplyEventData.OnReplyEventByType;
End;

Procedure TDWEvent.SetDescription(Strings : TStrings);
Begin
 vDescription.Assign(Strings);
End;

Procedure TDWEvent.SetAuthRequest(Value   : TDWAuthRequest);
Begin
 DWReplyEventData.OnAuthRequest := Value;
End;

Procedure TDWEvent.SetDisplayName(Const Value: String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create(cInvalidEvent)
 Else
  Begin
   FName := Value;
   DWReplyEventData.Name := FName;
   If vEventName = '' Then
    vEventName := DWReplyEventData.Name;
   Inherited;
  End;
End;

procedure TDWEvent.SetReplyEvent(Value: TDWReplyEvent);
begin
 DWReplyEventData.OnReplyEvent := Value;
end;

Procedure TDWEvent.SetReplyEventByType(Value: TDWReplyEventByType);
Begin
 DWReplyEventData.OnReplyEventByType := Value;
End;

Procedure TDWEvent.CompareParams(Var Dest : TDWParams);
Var
 I : Integer;
Begin
 If vOnlyPreDefinedParams Then
  Begin
   If Not Assigned(Dest) Then
    Exit;
   If vDWParams.Count = 0 Then
    Dest.Clear;
   For I := Dest.Count -1 DownTo 0 Do
    Begin
     If (vDWParams.ParamByName[Dest.Items[I].Alias]     = Nil) And
        (vDWParams.ParamByName[Dest.Items[I].ParamName] = Nil) Then
      Dest.Delete(I);
    End;
  End;
End;

Function TDWEventList.Add : TCollectionItem;
Begin
 Result := Nil;
 If vEditable Then
  Result := TDWEvent(Inherited Add);
End;

procedure TDWEventList.ClearList;
Var
 I : Integer;
 vOldEditable : Boolean;
Begin
 vOldEditable := vEditable;
 vEditable    := True;
 Try
  For I := Count - 1 Downto 0 Do
   Delete(I);
 Finally
  Self.Clear;
  vEditable := vOldEditable;
 End;
End;

Constructor TDWEventList.Create(AOwner     : TPersistent;
                                aItemClass : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TDWEvent);
 Self.fOwner := AOwner;
 vEditable   := True;
End;

procedure TDWEventList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  TOwnedCollection(Self).Delete(Index);
end;

destructor TDWEventList.Destroy;
begin
 ClearList;
 inherited;
end;

Procedure TDWEventList.FromJSON(Value : String);
Var
 bJsonOBJBase   : TDWJSONBase;
 bJsonOBJ,
 bJsonOBJb,
 bJsonOBJc      : TDWJSONObject;
 bJsonArray,
 bJsonArrayB,
 bJsonArrayC    : TDWJSONArray;
 I, X, Y        : Integer;
 vDWEvent       : TDWEvent;
 vDWParamMethod : TDWParamMethod;
 vEventName,
 vJsonMode,
 vparams,
 vparamname     : String;
 vneedauth,
 vonlypredefparams : Boolean;
Begin
 Try
  bJsonOBJBase := TDWJSONBase(TDWJSONObject.Create(Value));
  bJsonArray   := TDWJSONArray(bJsonOBJBase);
  For I := 0 to bJsonArray.ElementCount - 1 Do
   Begin
    bJsonOBJ := TDWJSONObject(bJsonArray.GetObject(I));
    Try
     bJsonArrayB := bJsonOBJ.OpenArray('serverevents'); //  Tjsonarray.Create(bJsonOBJ.get('serverevents').tostring);
     For X := 0 To bJsonArrayB.ElementCount - 1 Do
      Begin
       bJsonOBJb  := TDWJSONObject(bJsonArrayB.GetObject(X));
       vEventName := bJsonOBJb.Pairs[0].Value; //eventname
       vJsonMode  := bJsonOBJb.Pairs[1].Value; //jsonmode
       vparams    := bJsonOBJb.Pairs[2].Value; //params
       vneedauth  := StringToBoolean(bJsonOBJb.Pairs[3].Value); //params
       vonlypredefparams := StringToBoolean(bJsonOBJb.Pairs[4].Value); //params
       If EventByName[vEventName] = Nil Then
        vDWEvent  := TDWEvent(Self.Add)
       Else
        vDWEvent  := EventByName[vEventName];
       vDWEvent.Name := vEventName;
       vDWEvent.JsonMode := GetJSONModeName(vJsonMode);
       vDWEvent.NeedAuthorization    := vneedauth;
       vDWEvent.OnlyPreDefinedParams := vonlypredefparams;
       If vparams <> '' Then
        Begin
         bJsonArrayC    := bJsonOBJb.OpenArray('params');
         Try
          For Y := 0 To bJsonArrayC.ElementCount - 1 do
           Begin
            bJsonOBJc                      := TDWJSONObject(bJsonArrayC.GetObject(Y));
            vparamname                     := bJsonOBJc.Pairs[3].Value; // .get('paramname').toString;
            If vDWEvent.vDWParams.ParamByName[vparamname] = Nil Then
             vDWParamMethod                := TDWParamMethod(vDWEvent.vDWParams.Add)
            Else
             vDWParamMethod                := vDWEvent.vDWParams.ParamByName[vparamname];
            vDWParamMethod.TypeObject      := GetObjectName(bJsonOBJc.Pairs[0].Value); // GetObjectName(bJsonOBJc.get('typeobject').toString);
            vDWParamMethod.ObjectDirection := GetDirectionName(bJsonOBJc.Pairs[1].Value); // GetDirectionName(bJsonOBJc.get('objectdirection').toString);
            vDWParamMethod.ObjectValue     := GetValueType(bJsonOBJc.Pairs[2].Value); // GetValueType(bJsonOBJc.get('objectvalue').toString);
            vDWParamMethod.ParamName       := vparamname;
            If bJsonArrayC.ElementCount > 4 Then
             vDWParamMethod.Encoded         := StringToBoolean(bJsonOBJc.Pairs[4].Value); // StringToBoolean(bJsonOBJc.get('encoded').toString);
            If bJsonArrayC.ElementCount > 5 Then
             If Trim(bJsonOBJc.Pairs[5].Value) <> '' Then //Trim(bJsonOBJc.get('default').toString) <> '' Then
              vDWParamMethod.DefaultValue   := DecodeStrings(bJsonOBJc.Pairs[5].Value{$IFDEF FPC}, csUndefined{$ENDIF}); // bJsonOBJc.get('default').toString{$IFDEF FPC}, csUndefined{$ENDIF});
            FreeAndNil(bJsonOBJc);
           End;
         Finally
          FreeAndNil(bJsonArrayC);
         End;
        End
       Else
        vDWEvent.vDWParams.ClearList;
       FreeAndNil(bJsonOBJb);
      End;
    Finally
     FreeAndNil(bJsonArrayB);
    End;
    FreeAndNil(bJsonOBJ);
   End;
 Finally
  FreeAndNil(bJsonOBJBase);
 End;
End;

Function TDWEventList.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

function TDWEventList.GetRec(Index: Integer): TDWEvent;
begin
 Result := TDWEvent(Inherited GetItem(Index));
end;

function TDWEventList.GetRecName(Index: String): TDWEvent;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(TDWEvent(Items[I]).EventName)) Then
    Begin
     Result := TDWEvent(Self.Items[I]);
     Break;
    End;
  End;
End;

procedure TDWEventList.PutRec(Index: Integer; Item: TDWEvent);
begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  SetItem(Index, Item);
end;

procedure TDWEventList.PutRecName(Index: String; Item: TDWEvent);
Var
 I : Integer;
Begin
 If (vEditable) Then
  Begin
   For I := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(TDWEvent(Items[I]).EventName)) Then
      Begin
       Self.Items[I] := Item;
       Break;
      End;
    End;
  End;
End;

Function TDWEventList.ToJSON: String;
Var
 A, I : Integer;
 vTagEvent,
 vParamsLines,
 vParamLine,
 vParamLine2,
 vEventsLines : String;
Begin
 Result := '';
 vEventsLines := '';
 For I := 0 To Count -1 Do
  Begin
   vParamLine2  := Format('"needauth":"%s", "onlypredefparams":"%s"', [BooleanToString(Items[I].NeedAuthorization),
                                                                       BooleanToString(Items[I].OnlyPreDefinedParams)]);
   vTagEvent    := Format('{"eventname":"%s"', [TDWEvent(Items[I]).EventName]);
   vTagEvent    := vTagEvent + Format(', "jsonmode":"%s"', [GetJSONModeName(Items[I].vJsonMode)]);
   vTagEvent    := vTagEvent + ', "params":[%s], ' + vParamLine2 + '}';
   vParamsLines := '';
   For A := 0 To Items[I].vDWParams.Count -1 Do
    Begin
     vParamLine := Format(TServerEventsConst,
                          [GetObjectName(Items[I].vDWParams[A].vTypeObject),
                           GetDirectionName(Items[I].vDWParams[A].vObjectDirection),
                           GetValueType(Items[I].vDWParams[A].vObjectValue),
                           Items[I].vDWParams[A].vParamName,
                           BooleanToString(Items[I].vDWParams[A].vEncoded),
                           EncodeStrings(Items[I].vDWParams[A].vDefaultValue{$IFDEF FPC}, csUndefined{$ENDIF})]);
     If vParamsLines = '' Then
      vParamsLines := vParamLine
     Else
      vParamsLines := vParamsLines + ', ' + vParamLine;
    End;
   If vEventsLines = '' Then
    vEventsLines := vEventsLines + Format(vTagEvent, [vParamsLines])
   Else
    vEventsLines := vEventsLines + Format(', ' + vTagEvent, [vParamsLines]);
  End;
 Result := Format('{"serverevents":[%s]}', [vEventsLines]);
End;

Procedure TDWServerEvents.CreateDWParams(EventName    : String;
                                         Var DWParams : TDWParams);
Var
 vParamNameS : String;
 dwParam     : TJSONParam;
 vParamName,
 I           : Integer;
 vFound      : Boolean;
Begin
 vParamNameS := '';
 If vEventList.EventByName[EventName] <> Nil Then
  Begin
   If Not Assigned(DWParams) Then
    DWParams := TDWParams.Create;
   DWParams.JsonMode := vEventList.EventByName[EventName].JsonMode;
   For I := 0 To vEventList.EventByName[EventName].vDWParams.Count -1 Do
    Begin
     vParamNameS := '';
     vFound  := (DWParams.ItemsString[vEventList.EventByName[EventName].vDWParams.Items[I].ParamName] <> Nil);
     If vFound Then
      vParamNameS := vEventList.EventByName[EventName].vDWParams.Items[I].ParamName
     Else
      Begin
       vFound  := (DWParams.ItemsString[vEventList.EventByName[EventName].vDWParams.Items[I].Alias]   <> Nil);
       If vFound Then
        vParamNameS := vEventList.EventByName[EventName].vDWParams.Items[I].Alias;
      End;
     If Not(vFound) Then
      Begin
       dwParam                 := TJSONParam.Create(DWParams.Encoding);
       dwParam.Alias           := vEventList.EventByName[EventName].vDWParams.Items[I].Alias;
       dwParam.ParamName       := vEventList.EventByName[EventName].vDWParams.Items[I].ParamName;
       dwParam.ObjectDirection := vEventList.EventByName[EventName].vDWParams.Items[I].ObjectDirection;
       dwParam.ObjectValue     := vEventList.EventByName[EventName].vDWParams.Items[I].ObjectValue;
       dwParam.Encoded         := vEventList.EventByName[EventName].vDWParams.Items[I].Encoded;
       dwParam.JsonMode        := DWParams.JsonMode;
       If (vEventList.EventByName[EventName].vDWParams.Items[I].DefaultValue <> '')  And
          (Trim(dwParam.AsString) = '') Then
        dwParam.Value          := vEventList.EventByName[EventName].vDWParams.Items[I].DefaultValue;
       DWParams.Add(dwParam);
      End
     Else
      Begin
       If (DWParams.ItemsString[vParamNameS].ParamName             =  '') Or
          ((DWParams.ItemsString[vParamNameS].ParamName            <> '') And
           (Lowercase(DWParams.ItemsString[vParamNameS].ParamName) <>
            Lowercase(vEventList.EventByName[EventName].vDWParams.Items[I].ParamName))) Then
        Begin
         DWParams.ItemsString[vParamNameS].Alias      := vEventList.EventByName[EventName].vDWParams.Items[I].Alias;
         DWParams.ItemsString[vParamNameS].ParamName  := vEventList.EventByName[EventName].vDWParams.Items[I].ParamName;
        End;
       If DWParams.ItemsString[vParamNameS].Alias      = '' Then
        DWParams.ItemsString[vParamNameS].Alias       := vEventList.EventByName[EventName].vDWParams.Items[I].Alias;
      End;
    End;
  End
 Else
  DWParams := Nil;
End;

Constructor TDWServerEvents.Create(AOwner : TComponent);
Begin
 Inherited;
 vEventList := TDWEventList.Create(Self, TDWEvent);
 vIgnoreInvalidParams := False;
 If Assigned(vOnCreate) Then
  vOnCreate(Self);
 vDescription          := TStringList.Create;   //uhmano
End;

Destructor TDWServerEvents.Destroy;
Begin
 vEventList.Free;
 vDescription.Free;		//uhmano
 Inherited;
End;

Procedure TDWServerEvents.SetDescription(Strings : TStrings);    //uhmano
Begin
 vDescription.Assign(Strings);
End;

procedure TDWParamsMethods.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Begin
   Delete(I);
  End;
 Self.Clear;
End;

constructor TDWParamsMethods.Create(AOwner     : TPersistent;
                                    aItemClass : TCollectionItemClass);
begin
 Inherited Create(AOwner, TDWParamMethod);
 Self.fOwner := AOwner;
 vAlias      := '';
end;

Function TDWParamsMethods.Add(Item : TDWParamMethod): Integer;
Var
 vItem : ^TDWParamMethod;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

procedure TDWParamsMethods.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
end;

destructor TDWParamsMethods.Destroy;
begin
 ClearList;
 Inherited;
end;

Function TDWParamsMethods.GetRec(Index: Integer): TDWParamMethod;
Begin
 Result := TDWParamMethod(inherited GetItem(Index));
End;

function TDWParamsMethods.GetRecName(Index: String): TDWParamMethod;
Var
 I : Integer;
Begin
 Result := Nil;
 If Uppercase(Index) <> '' Then
  Begin
   For I := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(Self.Items[I].vParamName)) Or
        (Uppercase(Index) = Uppercase(Self.Items[I].vAlias))     Then
      Begin
       Result := TDWParamMethod(Self.Items[I]);
       Break;
      End;
    End;
  End;
End;

procedure TDWParamsMethods.PutRec(Index: Integer; Item: TDWParamMethod);
begin
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
end;

procedure TDWParamsMethods.PutRecName(Index: String; Item: TDWParamMethod);
Var
 I : Integer;
Begin
 If Uppercase(Index) <> '' Then
  Begin
   For I := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(Self.Items[I].vParamName)) Or
        (Uppercase(Index) = Uppercase(Self.Items[I].vAlias))     Then
      Begin
       Self.Items[I] := Item;
       Break;
      End;
    End;
  End;
End;

Constructor TDWParamMethod.Create(aCollection: TCollection);
Begin
 Inherited;
 vTypeObject      := toParam;
 vObjectDirection := odINOUT;
 vObjectValue     := ovString;
 vParamName       := 'dwparam' + IntToStr(aCollection.Count);
 vEncoded         := True;
 vDefaultValue    := '';
 vAlias           := '';
 vDescription     := TStringList.Create;    //uhmano
End;

Destructor TDWParamMethod.Destroy;
Begin
 vDescription.Free;		//uhmano
 Inherited;
End;

function TDWParamMethod.GetDisplayName: String;
begin
 Result := vParamName;
end;

procedure TDWParamMethod.SetDisplayName(const Value: String);
begin
 If Trim(Value) = '' Then
  Raise Exception.Create(cInvalidParamName)
 Else
  Begin
   vParamName := Trim(Value);
   Inherited;
  End;
end;

Procedure TDWParamMethod.SetDescription(Strings : TStrings);    //uhmano
Begin
 vDescription.Assign(Strings);
End;

{ TDWClientEvents }

constructor TDWClientEvents.Create(AOwner: TComponent);
begin
 Inherited;
 vEventList     := TDWEventList.Create(Self, TDWEvent);
 vCripto        := TCripto.Create;
 vGetEvents     := False;
 vEditParamList := True;
 vDescription   := TStringList.Create;		//uhmano
end;

procedure TDWClientEvents.CreateDWParams(EventName: String;
  Var DWParams: TDWParams);
Var
 vParamName : String;
 dwParam    : TJSONParam;
 I          : Integer;
 vFound     : Boolean;
Begin
 vParamName := '';
 vDescription          := TStringList.Create;   //uhmano
 If vEventList.EventByName[EventName] <> Nil Then
  Begin
//   If (Not Assigned(DWParams)) or (dwParams = nil) Then
   DWParams := TDWParams.Create;
   DWParams.Encoding := vRESTClientPooler.Encoding;
   For I := 0 To vEventList.EventByName[EventName].vDWParams.Count -1 Do
    Begin
     vParamName := '';
     vFound  := (DWParams.ItemsString[vEventList.EventByName[EventName].vDWParams.Items[I].ParamName] <> Nil);
     If vFound Then
      vParamName := vEventList.EventByName[EventName].vDWParams.Items[I].ParamName
     Else
      Begin
       vFound  := (DWParams.ItemsString[vEventList.EventByName[EventName].vDWParams.Items[I].Alias]   <> Nil);
       If vFound Then
        vParamName := vEventList.EventByName[EventName].vDWParams.Items[I].Alias;
      End;
     If Not(vFound) Then
      dwParam                := TJSONParam.Create(DWParams.Encoding)
     Else
      dwParam                := DWParams.ItemsString[vParamName];
     dwParam.ParamName       := vEventList.EventByName[EventName].vDWParams.Items[I].ParamName;
     dwParam.Alias           := vEventList.EventByName[EventName].vDWParams.Items[I].Alias;
     dwParam.ObjectDirection := vEventList.EventByName[EventName].vDWParams.Items[I].ObjectDirection;
     dwParam.ObjectValue     := vEventList.EventByName[EventName].vDWParams.Items[I].ObjectValue;
     dwParam.Encoded         := vEventList.EventByName[EventName].vDWParams.Items[I].Encoded;
     dwParam.JsonMode        := jmDataware;
     If (vEventList.EventByName[EventName].vDWParams.Items[I].DefaultValue <> '') And
        (Trim(dwParam.AsString) = '') Then
      dwParam.Value           := vEventList.EventByName[EventName].vDWParams.Items[I].DefaultValue;
     If Not(vFound) Then
      DWParams.Add(dwParam);
    End;
  End
 Else
  DWParams := Nil;
End;

destructor TDWClientEvents.Destroy;
begin
 vEventList.Free;
 vDescription.Free;		//uhmano
 FreeAndNil(vCripto);
 Inherited;
end;

procedure TDWClientEvents.GetOnlineEvents(Value: Boolean);
Var
 RESTClientPoolerExec : TRESTClientPooler;
 vResult,
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TDWParams;
 vRaised              : Boolean;
Begin
 vRaised := False;
 If Assigned(vRESTClientPooler) Then
  RESTClientPoolerExec := vRESTClientPooler
 Else
  Exit;
 If Assigned(vRESTClientPooler) Then
  If Assigned(vRESTClientPooler.OnBeforeExecute) Then
   vRESTClientPooler.OnBeforeExecute(Self);
 DWParams                        := TDWParams.Create;
 DWParams.CriptOptions.Use       := CriptOptions.Use;
 DWParams.CriptOptions.Key       := CriptOptions.Key;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'dwservereventname';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := vServerEventName;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsBoolean             := False;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsString              := '';
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'BinaryRequest';
 JSONParam.ObjectDirection       := odIn;
 If Assigned(vRESTClientPooler) Then
  JSONParam.AsBoolean            := vRESTClientPooler.BinaryRequest
 Else
  JSONParam.AsBoolean            := False;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOut;
 JSONParam.AsString              := '';
 DWParams.Add(JSONParam);
 Try
  Try
   RESTClientPoolerExec.NewToken;
   lResponse := RESTClientPoolerExec.SendEvent('GetEvents', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     If Not DWParams.ItemsString['error'].AsBoolean Then
      Begin
//       If vRESTClientPooler.CriptOptions.Use Then
//        DWParams.ItemsString['Result'].CriptOptions.Use := False;
       vResult := DWParams.ItemsString['Result'].AsString;
       If Trim(vResult) <> '' Then //Carreta o ParamList
        vEventList.FromJSON(Trim(vResult));
      End
     Else
      Begin
       vRaised := True;
       Raise Exception.Create(DWParams.ItemsString['MessageError'].AsString);
      End;
    End
   Else
    Begin
     If (lResponse = '') Then
      lResponse  := Format('Unresolved Host : ''%s''', [RESTClientPoolerExec.Host])
     Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
      lResponse  := 'Unauthorized...';
     Raise Exception.Create(lResponse);
     lResponse   := '';
    End;
  Except
   On E : Exception Do
    Begin
     If Not vRaised Then
      Begin
       If Trim(vServerEventName) = '' Then
        Raise Exception.Create(cInvalidServerEventName)
       Else
        Raise Exception.Create(cServerEventNotFound);
      End;
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

function TDWClientEvents.GetRESTClientPooler: TRESTClientPooler;
begin
  Result := vRESTClientPooler;
end;

procedure TDWClientEvents.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = vRESTClientPooler) then
  begin
    vRESTClientPooler := nil;
  end;
  inherited Notification(AComponent, Operation);
end;

{
procedure TDWClientEvents.SetEditParamList(Value: Boolean);
begin
 vEditParamList := Value;
 vEventList.Editable(vEditParamList);
end;
}

Function TDWClientEvents.SendEvent(EventName        : String;
                                   Var DWParams     : TDWParams;
                                   Var Error        : String;
                                   Var NativeResult : String;
                                   EventType        : TSendEvent = sePOST;
                                   Assyncexec       : Boolean = False): Boolean;
Var
 vJsonMode : TJsonMode;
Begin
 Error := '';
 Result := False;
 If vRESTClientPooler <> Nil Then
  Begin
   If Assigned(vOnBeforeSend) Then
    vOnBeforeSend(Self);
   If Assigned(vRESTClientPooler.OnBeforeExecute) Then
    vRESTClientPooler.OnBeforeExecute(Self);
   If vEventList.EventByName[EventName] = Nil Then
    Begin
     Result := False;
     Error  := cInvalidEvent;
     Exit
    End;
   TokenValidade(DWParams, Error);
   vJsonMode    := vEventList.EventByName[EventName].vJsonMode;
   Try
    Error        := '';
    NativeResult := vRESTClientPooler.SendEvent(EventName, DWParams, EventType, vJsonMode, vServerEventName);
    Result       := (NativeResult = TReplyOK) Or (NativeResult = AssyncCommandMSG);
   Except
    On E : Exception Do
     Begin
      Error := E.Message;
      If Error = cInvalidAuth Then
       Begin
        Case vRESTClientPooler.AuthenticationOptions.AuthorizationOption Of
         rdwAOBearer : Begin
                        If (TRDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoGetToken) And
                           (TRDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token <> '')  Then
                         TRDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token := '';
                        If Assigned(vOnBeforeSend) Then
                         vOnBeforeSend(Self);
                        If Assigned(vRESTClientPooler.OnBeforeExecute) Then
                         vRESTClientPooler.OnBeforeExecute(Self);
                        If TRDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoRenewToken Then
                         TokenValidade(DWParams, Error);
                       End;
         rdwAOToken  : Begin
                        If (TRDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoGetToken)  And
                            (TRDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token  <> '')  Then
                         TRDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token := '';
                        If Assigned(vOnBeforeSend) Then
                         vOnBeforeSend(Self);
                        If Assigned(vRESTClientPooler.OnBeforeExecute) Then
                         vRESTClientPooler.OnBeforeExecute(Self);
                        If TRDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoRenewToken Then
                         TokenValidade(DWParams, Error);
                       End;
        End;
       End
      Else
       Begin
        Raise Exception.Create(Error);
       End;
     End;
   End;
  End;
End;

Procedure TDWClientEvents.TokenValidade(Var DWParams : TDWParams;
                                        Var Error    : String);
Var
 JSONParam     : TJSONParam;
 vToken        : String;
 vErrorBoolean : Boolean;
Begin
 vErrorBoolean := False;
 If Not(Assigned(DWParams)) Then
  Begin
   DWParams                  := TDWParams.Create;
   DWParams.JsonMode         := jmDataware;
   DWParams.Encoding         := vRESTClientPooler.Encoding;
   JSONParam                 := TJSONParam.Create(vRESTClientPooler.Encoding);
   JSONParam.ParamName       := 'BinaryRequest';
   JSONParam.ObjectDirection := odIn;
   JSONParam.AsBoolean       := vRESTClientPooler.BinaryRequest;
   DWParams.Add(JSONParam);
  End;
 If vRESTClientPooler.AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
  Begin
   Case vRESTClientPooler.AuthenticationOptions.AuthorizationOption Of
    rdwAOBearer : Begin
//                   If (TRDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoGetToken)    And
//                      (TRDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).EndTime < Now()) Then
//                    TRDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token := '';
                   If (TRDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoGetToken) And
                      (TRDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token = '') Then
                    Begin
                     If Assigned(vRESTClientPooler.OnBeforeGetToken) Then
                      vRESTClientPooler.OnBeforeGetToken(vRESTClientPooler.WelcomeMessage,
                                                         vRESTClientPooler.AccessTag, DWParams);
                     vToken :=  vRESTClientPooler.RenewToken(DWParams, vErrorBoolean, Error);
                     If Not vErrorBoolean Then
                      TRDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token := vToken;
                    End;
                  End;
    rdwAOToken  : Begin
//                   If (TRDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoGetToken)    And
//                      (TRDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).EndTime < Now()) Then
//                    TRDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token := '';
                   If (TRDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoGetToken) And
                      (TRDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token = '') Then
                    Begin
                     If Assigned(vRESTClientPooler.OnBeforeGetToken) Then
                      vRESTClientPooler.OnBeforeGetToken(vRESTClientPooler.WelcomeMessage,
                                                         vRESTClientPooler.AccessTag, DWParams);
                     vToken :=  vRESTClientPooler.RenewToken(DWParams, vErrorBoolean, Error);
                     If Not vErrorBoolean Then
                      TRDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token := vToken;
                    End;
                  End;
   End;
  End;
End;

Function TDWClientEvents.SendEvent(EventName    : String;
                                   Var DWParams : TDWParams;
                                   Var Error    : String;
                                   EventType    : TSendEvent = sePOST;
                                   Assyncexec   : Boolean = False): Boolean;
Var
 vJsonMode     : TJsonMode;
 I,
 vErrorCode    : Integer;
 vRenewTokenData,
 vErrorBoolean : Boolean;
 vToken        : String;
Begin
 // Add por Ico Menezes
 Result          := False;
 vErrorCode      := 0;
 vErrorBoolean   := False;
 vRenewTokenData := False;
 Error           := '';
 If vRESTClientPooler <> Nil Then
  Begin
   If Assigned(vOnBeforeSend) Then
     vOnBeforeSend(Self);
   If Assigned(vRESTClientPooler.OnBeforeExecute) Then
    vRESTClientPooler.OnBeforeExecute(Self);
   If vEventList.EventByName[EventName] = Nil Then
    Begin
     Result := False;
     Error  := cInvalidEvent;
     Exit
    End;
   TokenValidade(DWParams, Error);
   vJsonMode := vEventList.EventByName[EventName].vJsonMode;
   For I := 0 To 1 Do
    Begin
     If Error = '' Then
      Error    := vRESTClientPooler.SendEvent(EventName, DWParams, EventType, vJsonMode, vServerEventName, Assyncexec);
     Result    := (Error = TReplyOK) Or (Error = AssyncCommandMSG);
     If Result Then
      Begin
       Error  := '';
       Break;
      End
     Else
      Begin
       If Error = cInvalidAuth Then
        Begin
         Case vRESTClientPooler.AuthenticationOptions.AuthorizationOption Of
          rdwAOBearer : Begin
                         If (TRDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoGetToken) And
                            (TRDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token <> '')  Then
                          TRDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token := '';
                         If Assigned(vOnBeforeSend) Then
                          vOnBeforeSend(Self);
                         If Assigned(vRESTClientPooler.OnBeforeExecute) Then
                          vRESTClientPooler.OnBeforeExecute(Self);
                         If TRDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoRenewToken Then
                          TokenValidade(DWParams, Error)
                         Else
                          Break;
                        End;
          rdwAOToken  : Begin
                         If (TRDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoGetToken)  And
                             (TRDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token  <> '')  Then
                          TRDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token := '';
                         If Assigned(vOnBeforeSend) Then
                          vOnBeforeSend(Self);
                         If Assigned(vRESTClientPooler.OnBeforeExecute) Then
                          vRESTClientPooler.OnBeforeExecute(Self);
                         If TRDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoRenewToken Then
                          TokenValidade(DWParams, Error)
                         Else
                          Break;
                        End;
         End;
        End
       Else
        Begin
         Break;
        End;
      End;
    End;
  End;
End;

procedure TDWClientEvents.ClearEvents;
begin
 vEventList.ClearList;
end;

procedure TDWClientEvents.SetEventList(aValue : TDWEventList);
begin
 If vEditParamList Then
  vEventList := aValue;
end;

procedure TDWClientEvents.SetRESTClientPooler(const Value: TRESTClientPooler);
begin
  //Alexandre Magno - 14/08/2019
  if vRESTClientPooler <> Value then
    vRESTClientPooler := Value;
  if vRESTClientPooler <> nil then
    vRESTClientPooler.FreeNotification(Self);
end;

Procedure TDWClientEvents.SetDescription(Strings : TStrings);    //uhmano
Begin
 vDescription.Assign(Strings);
End;

Initialization
 RegisterClass(TDWServerEvents);
 RegisterClass(TDWClientEvents);
end.

