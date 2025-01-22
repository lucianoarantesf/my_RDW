unit uRESTDWPoolerDB;

{$I uRESTDW.inc}

{
  REST Dataware vers�o CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tamb�m tem por objetivo levar componentes compat�veis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionaFields.Countis.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc� usu�rio que precisa
 de produtividade e flexibilidade para produ��o de Servi�os REST/JSON/BINARY, simplificando o processo para voc� programador.

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
 Thiago Pedro				        - Member Tester and DEMO Developer.
}


interface

uses SysUtils,  Classes,
     DB,        uDWPoolerMethod,
     uRESTDWMasterDetailData, uDWAbout,
     uDWMassiveBuffer,        SyncObjs, uDWJSONTools,
     uDWResponseTranslator,   uSystemEvents, uRESTDWBase, uDWDataset, uDWConstsCharset, ServerUtils
     //Add Sistema de Threads
     {$IFDEF FPC}
       , uDWConsts, uDWJSON, uDWJSONObject, Variants
      {$IFDEF UNIDACMEM}
      , DADump, UniDump, VirtualTable
      {$ENDIF}
      {$IFNDEF LAMW}
      , Controls, Forms, memds, BufDataset
      {$ELSE} //Quando usa LAMW
      {$ENDIF}, uDWConstsData;
     {$ELSE}
       {$IF Defined(HAS_FMX)},FMX.Forms{$ELSE}{$IF CompilerVersion <= 22},Forms{$ELSE},VCL.Forms{$IFEND}{$IFEND}
       {$IFDEF MSWINDOWS},Windows {$ENDIF}
       {$IFDEF UNIDACMEM}
       , DADump, UniDump, VirtualTable, MemDS
       {$ENDIF}
       {$IFDEF RESTKBMMEMTABLE}
       , kbmmemtable
       {$ENDIF}
       {$IF CompilerVersion > 25} // Delphi XE7 pra cima
          , FireDAC.Comp.Client
          {$IF Defined(HAS_FMX)}  // Inclu�do inicialmente para iOS/Brito
          , System.json,  uDWJSONObject
          {$IFNDEF LINUXFMX}
          , FMX.Platform, FMX.Types,   System.UITypes, FMX.Forms //FMX
          {$ELSE}
           , System.UITypes
          {$ENDIF}
          {$ELSE}
            {$IFDEF CLIENTDATASET}
            , DBClient
            {$ENDIF}
            {$IFDEF WINFMX} // FireMonkey Windows
            , FMX.Platform, FMX.Types, System.UITypes
            {$ENDIF}
            , uDWJSON,  uDWJSONObject, vcl.Controls
          {$IFEND}
          {$IFDEF RESTFDMEMTABLE}
          , FireDAC.Stan.Intf,    FireDAC.Stan.Option,  FireDAC.Stan.Param
          , FireDAC.Stan.Error,   FireDAC.DatS,         FireDAC.Phys.Intf
          , FireDAC.DApt.Intf,    FireDAC.Comp.DataSet
          {$ENDIF}
       {$ELSE}
          , uDWJSON, uDWJSONObject, Controls, DBClient
          {$IFDEF RESTADMEMTABLE}
          , uADStanIntf,    uADStanOption,  uADStanParam
          , uADStanError,   uADPhysIntf
          , uADDAptIntf,    uADCompDataSet, uADCompClient
          {$ENDIF}
       {$IFEND}
       , uDWConstsData, Variants, uDWConsts;
     {$ENDIF}

Type
 TOnExecuteData           = Procedure                                        Of Object;
 TOnThreadRequestError    = Procedure (ErrorCode          : Integer;
                                       MessageError       : String)          Of Object;
 TOnEventDB               = Procedure (DataSet            : TDataSet)        Of Object;
 TOnFiltered              = Procedure (Var Filtered       : Boolean;
                                       Var Filter         : String)          Of Object;
 TOnAfterScroll           = Procedure (DataSet            : TDataSet)        Of Object;
 TOnBeforeRefresh         = Procedure (DataSet            : TDataSet)        Of Object;
 TOnAfterRefresh          = Procedure (DataSet            : TDataSet)        Of Object;
 TOnAfterOpen             = Procedure (DataSet            : TDataSet)        Of Object;
 TOnBeforeClose           = Procedure (DataSet            : TDataSet)        Of Object;
 TOnAfterClose            = Procedure (DataSet            : TDataSet)        Of Object;
 TOnCalcFields            = Procedure (DataSet            : TDataSet)        Of Object;
 TOnAfterCancel           = Procedure (DataSet            : TDataSet)        Of Object;
 TOnAfterInsert           = Procedure (DataSet            : TDataSet)        Of Object;
 TOnBeforeDelete          = Procedure (DataSet            : TDataSet)        Of Object;
 TOnBeforePost            = Procedure (DataSet            : TDataSet)        Of Object;
 TOnAfterPost             = Procedure (DataSet            : TDataSet)        Of Object;
 TOnAfterDelete           = Procedure (DataSet            : TDataSet)        Of Object;
 TOnEventConnection       = Procedure (Sucess             : Boolean;
                                       Const Error        : String)          Of Object;
 TOnEventBeforeConnection = Procedure (Sender             : TComponent)      Of Object;
 TOnEventTimer            = Procedure                                        Of Object;
 TBeforeGetRecords        = Procedure (Sender             : TObject;
                                       Var OwnerData      : OleVariant)      Of Object;
 TOnPrepareConnection     = Procedure (Var ConnectionDefs : TConnectionDefs) Of Object;
 TOnFieldGetValue         = Procedure (Value              : Variant)         Of Object;
 TOnTableBeforeOpen       = Procedure (Var Dataset        : TDataset;
                                       Params             : TDWParams;
                                       Tablename          : String)          Of Object;
 TOnQueryBeforeOpen       = Procedure (Var Dataset        : TDataset;
                                       Params             : TDWParams)       Of Object;
 TOnQueryException        = Procedure (Var Dataset        : TDataset;
                                       Params             : TDWParams;
                                       Error              : String)       Of Object;

Type
 TTimerData = Class(TThread)
 Private
  FValue : Integer;          //Milisegundos para execu��o
  FLock  : TCriticalSection; //Se��o cr�tica
  vEvent : TOnEventTimer;    //Evento a ser executado
 Public
  Property OnEventTimer : TOnEventTimer Read vEvent Write vEvent; //Evento a ser executado
 Protected
  Constructor Create(AValue: Integer; ALock: TCriticalSection);   //Construtor do Evento
  Procedure   Execute; Override;                                  //Procedure de Execu��o autom�tica
End;

Type
 TAutoCheckData = Class(TPersistent)
 Private
  vAutoCheck : Boolean;                            //Se tem Autochecagem
  vInTime    : Integer;                            //Em milisegundos o timer
  Timer      : TTimerData;                         //Thread do temporizador
  vEvent     : TOnEventTimer;                      //Evento a executar
  FLock      : TCriticalSection;                   //CriticalSection para execu��o segura
  Procedure  SetState(Value : Boolean);            //Ativa ou desativa a classe
  Procedure  SetInTime(Value : Integer);           //Diz o Timeout
  Procedure  SetEventTimer(Value : TOnEventTimer); //Seta o Evento a ser executado
 Public
  Constructor Create; //Cria o Componente
  Destructor  Destroy;Override;//Destroy a Classe
  Procedure   Assign(Source : TPersistent); Override;
 Published
  Property AutoCheck    : Boolean       Read vAutoCheck Write SetState;      //Se tem Autochecagem
  Property InTime       : Integer       Read vInTime    Write SetInTime;     //Em milisegundos o timer
  Property OnEventTimer : TOnEventTimer Read vEvent     Write SetEventTimer; //Evento a executar
End;

 TProxyOptions = Class(TPersistent)
 Private
  vServer,              //Servidor Proxy na Rede
  vLogin,               //Login do Servidor Proxy
  vPassword : String;   //Senha do Servidor Proxy
  vPort     : Integer;  //Porta do Servidor Proxy
 Public
  Constructor Create;
  Procedure   Assign(Source : TPersistent); Override;
 Published
  Property Server   : String  Read vServer   Write vServer;   //Servidor Proxy na Rede
  Property Port     : Integer Read vPort     Write vPort;     //Porta do Servidor Proxy
  Property Login    : String  Read vLogin    Write vLogin;    //Login do Servidor Proxy
  Property Password : String  Read vPassword Write vPassword; //Senha do Servidor Proxy
End;

Type
 TClientConnectionDefs = Class(TPersistent)
 Private
  FOwner  : TPersistent;
  vActive : Boolean;
  vConnectionDefs : TConnectionDefs;
  Procedure DestroyParam;
  Procedure SetClientConnectionDefs(Value : Boolean);
  Procedure SetConnectionDefs(Value : TConnectionDefs);
 Protected
  Function    GetOwner            : TPersistent; Override;
 Public
  Constructor Create(AOwner         : TPersistent); //Cria o Componente
  Destructor  Destroy;Override;//Destroy a Classe
 Published
  Property Active         : Boolean         Read vActive         Write SetClientConnectionDefs;
  Property ConnectionDefs : TConnectionDefs Read vConnectionDefs Write SetConnectionDefs;
End;

Type
 TRESTDWConnectionServer = Class(TCollectionItem)
 Private
  vBinaryRequest,
  vEncodeStrings,
  vCompression,
  vActive,
  vProxy                : Boolean;
  vTimeOut,
  vConnectTimeOut,
  vPoolerPort           : Integer;
  vPoolerList           : TStringList;
  vAuthOptionParams     : TRDWClientAuthOptionParams;
  vDataRoute,
  vServerContext,
  vListName,
  vAccessTag,
  vWelcomeMessage,
  vRestPooler,
  vRestURL,
  vRestWebService       : String;
  vProxyOptions         : TProxyOptions;
  vEncoding             : TEncodeSelect;
  {$IFDEF FPC}
  vDatabaseCharSet      : TDatabaseCharSet;
  {$ENDIF}
  vTypeRequest          : TTypeRequest;
  vClientConnectionDefs : TClientConnectionDefs;
  Function    GetPoolerList     : TStringList;
 Public
  Function    GetDisplayName             : String;      Override;
  Procedure   SetDisplayName(Const Value : String);     Override;
  Constructor Create        (aCollection : TCollection);Override;
  Destructor  Destroy;Override;//Destroy a Classe
  Property    PoolerList        : TStringList                 Read GetPoolerList;
 Published
  Property Active                : Boolean                    Read vActive               Write vActive;            //Seta o Estado da Conex�o
  Property BinaryRequest         : Boolean                    Read vBinaryRequest        Write vBinaryRequest;
  Property Compression           : Boolean                    Read vCompression          Write vCompression;       //Compress�o de Dados
  Property AuthenticationOptions : TRDWClientAuthOptionParams Read vAuthOptionParams     Write vAuthOptionParams;
  Property Proxy                 : Boolean                    Read vProxy                Write vProxy;             //Diz se tem servidor Proxy
  Property ProxyOptions          : TProxyOptions              Read vProxyOptions         Write vProxyOptions;      //Se tem Proxy diz quais as op��es
  Property PoolerService         : String                     Read vRestWebService       Write vRestWebService;    //Host do WebService REST
  Property PoolerURL             : String                     Read vRestURL              Write vRestURL;           //URL do WebService REST
  Property PoolerPort            : Integer                    Read vPoolerPort           Write vPoolerPort;        //A Porta do Pooler do DataSet
  Property PoolerName            : String                     Read vRestPooler           Write vRestPooler;        //Qual o Pooler de Conex�o ligado ao componente
  Property RequestTimeOut        : Integer                    Read vTimeOut              Write vTimeOut;           //Timeout da Requisi��o
  Property ConnectTimeOut        : Integer                    Read vConnectTimeOut       Write vConnectTimeOut;
  Property EncodeStrings         : Boolean                    Read vEncodeStrings        Write vEncodeStrings;
  Property Encoding              : TEncodeSelect              Read vEncoding             Write vEncoding;          //Encoding da string
  Property WelcomeMessage        : String                     Read vWelcomeMessage       Write vWelcomeMessage;
  Property DataRoute             : String                     Read vDataRoute            Write vDataRoute;
  Property ServerContext         : String                     Read vServerContext        Write vServerContext;
  {$IFDEF FPC}
  Property DatabaseCharSet      : TDatabaseCharSet            Read vDatabaseCharSet      Write vDatabaseCharSet;
  {$ENDIF}
  Property Name                 : String                      Read vListName             Write vListName;
  Property AccessTag            : String                      Read vAccessTag            Write vAccessTag;
  Property TypeRequest          : TTypeRequest                Read vTypeRequest          Write vTypeRequest       Default trHttp;
  Property ClientConnectionDefs : TClientConnectionDefs       Read vClientConnectionDefs Write vClientConnectionDefs;
End;

Type
 TOnFailOverExecute       = Procedure (ConnectionServer   : TRESTDWConnectionServer) Of Object;
 TOnFailOverError         = Procedure (ConnectionServer   : TRESTDWConnectionServer;
                                       MessageError       : String)                  Of Object;

Type
 TListDefConnections = Class(TDWOwnedCollection)
 Private
  fOwner      : TPersistent;
  Function    GetOwner: TPersistent; override;
  Function    GetRec     (Index       : Integer) : TRESTDWConnectionServer;  Overload;
  Procedure   PutRec     (Index       : Integer;
                          Item        : TRESTDWConnectionServer);            Overload;
  Function    GetRecName(Index        : String)  : TRESTDWConnectionServer;  Overload;
  Procedure   PutRecName(Index        : String;
                         Item         : TRESTDWConnectionServer);            Overload;
  Procedure   ClearList;
 Public
  Constructor Create     (AOwner      : TPersistent;
                          aItemClass  : TCollectionItemClass);
  Destructor  Destroy; Override;
  Function    Add                     : TCollectionItem;
  Procedure   Delete     (Index       : Integer);  Overload;
  Procedure   Delete     (Index       : String);   Overload;
  Property    Items      [Index       : Integer] : TRESTDWConnectionServer Read GetRec     Write PutRec; Default;
  Property    ItemsByName[Index       : String ] : TRESTDWConnectionServer Read GetRecName Write PutRecName;
End;

Type
 TRESTDWDataBase = Class(TDWComponent)
 Private
  vOnWork              : TOnWork;
  vOnWorkBegin         : TOnWorkBegin;
  vOnWorkEnd           : TOnWorkEnd;
  vOnStatus            : TOnStatus;
  vOnFailOverExecute   : TOnFailOverExecute;
  vOnFailOverError     : TOnFailOverError;
  vOnBeforeGetToken    : TOnBeforeGetToken;
  vCripto              : TCripto;
  vRestPoolers         : TStringList;
  vAuthOptionParams    : TRDWClientAuthOptionParams;
  vContentex,
  vUserAgent,
  vAccessTag,
  vWelcomeMessage,
  vDataRoute,
  vPoolerNotFoundMessage,
  vRestWebService,                                   //Rest WebService para consultas
  vRestURL,                                          //URL do WebService REST
  vMyIP,                                             //Meu IP vindo do Servidor
  vServerContext,
  vRestPooler           : String;                    //Qual o Pooler de Conex�o do DataSet
  vRedirectMaximum,
  vPoolerPort           : Integer;                   //A Porta do Pooler
  vClientConnectionDefs : TClientConnectionDefs;
  vProxyOptions         : TProxyOptions;             //Se tem Proxy diz quais as op��es
  vOnEventConnection    : TOnEventConnection;        //Evento de Estado da Conex�o
  vOnBeforeConnection   : TOnEventBeforeConnection;  //Evento antes de Connectar o Database
  vAutoCheckData        : TAutoCheckData;            //Autocheck de Conex�o
  vTimeOut              : Integer;
  vConnectTimeOut       : Integer;
  vEncoding             : TEncodeSelect;             //Enconding se usar CORS usar UTF8 - Alexandre Abade
  vHandleRedirects,
  vFailOver,
  vProxy,                                            //Diz se tem servidor Proxy
  vFailOverReplaceDefaults,
  vEncodeStrings,
  vCompression,                                      //Se Vai haver compress�o de Dados
  vConnected,                                        //Diz o Estado da Conex�o
  vStrsTrim,
  vStrsEmpty2Null,
  vStrsTrim2Len,
  vParamCreate         : Boolean;
  vTypeRequest         : Ttyperequest;
  vFailOverConnections : TListDefConnections;
  Function  RenewToken              (Var PoolerMethodClient : TDWPoolerMethodClient;
                                     Var Params             : TDWParams;
                                     Var Error              : Boolean;
                                     Var MessageError       : String) : String;
  Procedure SetOnWork               (Value                  : TOnWork);
  Procedure SetOnWorkBegin          (Value                  : TOnWorkBegin);
  Procedure SetOnWorkEnd            (Value                  : TOnWorkEnd);
  Procedure SetOnStatus             (Value                  : TOnStatus);
  Procedure SetConnection           (Value                  : Boolean);          //Seta o Estado da Conex�o
  Procedure SetRestPooler           (Value                  : String);           //Seta o Restpooler a ser utilizado
  Procedure SetPoolerPort           (Value                  : Integer);          //Seta a Porta do Pooler a ser usada
  Function  TryConnect : Boolean;                    //Tenta Conectar o Servidor para saber se posso executar comandos
  Function  GetStateDB : Boolean;
  Procedure SetMyIp(Value : String);
  Procedure ReconfigureConnection   (Var Connection        : TDWPoolerMethodClient;
                                     Var ConnectionExec    : TRESTClientPooler;
                                     TypeRequest           : Ttyperequest;
                                     WelcomeMessage,
                                     Host                  : String;
                                     Port                  : Integer;
                                     Compression,
                                     EncodeStrings         : Boolean;
                                     Encoding              : TEncodeSelect;
                                     AccessTag             : String;
                                     AuthenticationOptions : TRDWClientAuthOptionParams);
  Function    GetRestPoolers : TStringList;          //Retorna a Lista de DataSet Sources do Pooler
 Protected
   //Magno
  Procedure Loaded; override;
 Public
  Procedure ExecuteCommand          (Var PoolerMethodClient : TDWPoolerMethodClient;
                                     Var SQL                : TStringList;
                                     Var Params             : TParams;
                                     Var Error              : Boolean;
                                     Var MessageError       : String;
                                     Var Result             : TJSONValue;
                                     Var RowsAffected       : Integer;
                                     Execute                : Boolean = False;
                                     BinaryRequest          : Boolean = False;
                                     BinaryCompatibleMode   : Boolean = False;
                                     Metadata               : Boolean = False;
                                     RESTClientPooler       : TRESTClientPooler     = Nil);
  Procedure ExecuteCommandTB        (Var PoolerMethodClient : TDWPoolerMethodClient;
                                     Tablename              : String;
                                     Var Params             : TParams;
                                     Var Error              : Boolean;
                                     Var MessageError       : String;
                                     Var Result             : TJSONValue;
                                     Var RowsAffected       : Integer;
                                     BinaryRequest          : Boolean = False;
                                     BinaryCompatibleMode   : Boolean = False;
                                     Metadata               : Boolean = False;
                                     RESTClientPooler       : TRESTClientPooler     = Nil);
  Procedure ExecuteProcedure        (Var PoolerMethodClient : TDWPoolerMethodClient;
                                     ProcName               : String;
                                     Params                 : TParams;
                                     Var Error              : Boolean;
                                     Var MessageError       : String);
  Function InsertMySQLReturnID      (Var PoolerMethodClient : TDWPoolerMethodClient;
                                     Var SQL                : TStringList;
                                     Var Params             : TParams;
                                     Var Error              : Boolean;
                                     Var MessageError       : String;
                                     RESTClientPooler       : TRESTClientPooler = Nil) : Integer;
  Procedure ApplyUpdates            (Var PoolerMethodClient : TDWPoolerMethodClient;
                                     Massive                : TMassiveDatasetBuffer;
                                     SQL                    : TStringList;
                                     Var Params             : TParams;
                                     Var Error,
                                     hBinaryRequest         : Boolean;
                                     Var MessageError       : String;
                                     Var Result             : TJSONValue;
                                     Var RowsAffected       : Integer;
                                     RESTClientPooler       : TRESTClientPooler = Nil);Overload;
  Procedure ApplyUpdatesTB          (Var PoolerMethodClient : TDWPoolerMethodClient;
                                     Massive                : TMassiveDatasetBuffer;
                                     Var Params             : TParams;
                                     Var Error,
                                     hBinaryRequest         : Boolean;
                                     Var MessageError       : String;
                                     Var Result             : TJSONValue;
                                     Var RowsAffected       : Integer;
                                     RESTClientPooler       : TRESTClientPooler = Nil);Overload;
  Function    GetServerEvents                               : TStringList;
  Constructor Create                (AOwner                 : TComponent);Override; //Cria o Componente
  Destructor  Destroy; Override;                      //Destroy a Classe
  Procedure   Close;
  Procedure   Open;
  Procedure   ApplyUpdates          (Var MassiveCache       : TDWMassiveCache);Overload;
  Procedure   ApplyUpdates          (Var MassiveCache       : TDWMassiveCache;
                                     Var   Error            : Boolean;
                                     Var   MessageError     : String);Overload;
  Procedure   ApplyUpdates          (Datasets               : Array of {$IFDEF FPC}TRESTDWClientSQLBase{$ELSE}TObject{$ENDIF};
                                     Var   Error            : Boolean;
                                     Var   MessageError     : String);Overload;
  Procedure   ProcessMassiveSQLCache(Var MassiveSQLCache    : TDWMassiveSQLCache;
                                     Var   Error            : Boolean;
                                     Var   MessageError     : String);Overload;
  Procedure   ProcessMassiveSQLCache(Var MassiveSQLCache    : TDWMassiveCacheSQLList;
                                     Var   Error            : Boolean;
                                     Var   MessageError     : String);Overload;
  Procedure   OpenDatasets          (Datasets               : Array of {$IFDEF FPC}TRESTDWClientSQLBase{$ELSE}TObject{$ENDIF};
                                     Var   Error            : Boolean;
                                     Var   MessageError     : String;
                                     BinaryRequest          : Boolean = True);Overload;
  Function    GetTableNames         (Var   TableNames       : TStringList)  : Boolean;
  Function    GetFieldNames         (TableName              : String;
                                     Var FieldNames         : TStringList)  : Boolean;
  Function    GetKeyFieldNames      (TableName              : String;
                                     Var FieldNames         : TStringList)  : Boolean;
  Procedure   OpenDatasets          (Datasets               : Array of {$IFDEF FPC}TRESTDWClientSQLBase{$ELSE}TObject{$ENDIF});Overload;
  Property    Connected            : Boolean                    Read GetStateDB               Write SetConnection;
  Property    PoolerList           : TStringList                Read GetRestPoolers;
 Published
  Property OnConnection            : TOnEventConnection         Read vOnEventConnection       Write vOnEventConnection; //Evento relativo a tudo que acontece quando tenta conectar ao Servidor
  Property OnBeforeConnect         : TOnEventBeforeConnection   Read vOnBeforeConnection      Write vOnBeforeConnection; //Evento antes de Connectar o Database
  Property Active                  : Boolean                    Read vConnected               Write SetConnection;      //Seta o Estado da Conex�o
  Property Compression             : Boolean                    Read vCompression             Write vCompression;       //Compress�o de Dados
  Property CriptOptions            : TCripto                    Read vCripto                  Write vCripto;
  Property DataRoute               : String                     Read vDataRoute               Write vDataRoute;
  Property MyIP                    : String                     Read vMyIP                    Write SetMyIp;
  Property AuthenticationOptions   : TRDWClientAuthOptionParams Read vAuthOptionParams        Write vAuthOptionParams;
  Property Proxy                   : Boolean                    Read vProxy                   Write vProxy;             //Diz se tem servidor Proxy
  Property ProxyOptions            : TProxyOptions              Read vProxyOptions            Write vProxyOptions;      //Se tem Proxy diz quais as op��es
  Property PoolerService           : String                     Read vRestWebService          Write vRestWebService;    //Host do WebService REST
  Property PoolerURL               : String                     Read vRestURL                 Write vRestURL;           //URL do WebService REST
  Property PoolerPort              : Integer                    Read vPoolerPort              Write SetPoolerPort;      //A Porta do Pooler do DataSet
  Property PoolerName              : String                     Read vRestPooler              Write SetRestPooler;      //Qual o Pooler de Conex�o ligado ao componente
  Property StateConnection         : TAutoCheckData             Read vAutoCheckData           Write vAutoCheckData;     //Autocheck da Conex�o
  Property RequestTimeOut          : Integer                    Read vTimeOut                 Write vTimeOut;           //Timeout da Requisi��o
  Property ConnectTimeOut          : Integer                    Read vConnectTimeOut          Write vConnectTimeOut;
  Property EncodeStrings           : Boolean                    Read vEncodeStrings           Write vEncodeStrings;
  Property Encoding                : TEncodeSelect              Read vEncoding                Write vEncoding;          //Encoding da string
  Property Context                 : String                     Read vContentex               Write vContentex;         //Contexto
  Property StrsTrim                : Boolean                    Read vStrsTrim                Write vStrsTrim;
  Property StrsEmpty2Null          : Boolean                    Read vStrsEmpty2Null          Write vStrsEmpty2Null;
  Property StrsTrim2Len            : Boolean                    Read vStrsTrim2Len            Write vStrsTrim2Len;
  Property PoolerNotFoundMessage   : String                     Read vPoolerNotFoundMessage   Write vPoolerNotFoundMessage;
  Property WelcomeMessage          : String                     Read vWelcomeMessage          Write vWelcomeMessage;
  Property HandleRedirects         : Boolean                    Read vHandleRedirects         Write vHandleRedirects;
  Property RedirectMaximum         : Integer                    Read vRedirectMaximum         Write vRedirectMaximum;
  Property OnWork                  : TOnWork                    Read vOnWork                  Write SetOnWork;
  Property OnWorkBegin             : TOnWorkBegin               Read vOnWorkBegin             Write SetOnWorkBegin;
  Property OnWorkEnd               : TOnWorkEnd                 Read vOnWorkEnd               Write SetOnWorkEnd;
  Property OnStatus                : TOnStatus                  Read vOnStatus                Write SetOnStatus;
  Property OnFailOverExecute       : TOnFailOverExecute         Read vOnFailOverExecute       Write vOnFailOverExecute;
  Property OnFailOverError         : TOnFailOverError           Read vOnFailOverError         Write vOnFailOverError;
  Property OnBeforeGetToken        : TOnBeforeGetToken          Read vOnBeforeGetToken        Write vOnBeforeGetToken;
  Property AccessTag               : String                     Read vAccessTag               Write vAccessTag;
  Property ParamCreate             : Boolean                    Read vParamCreate             Write vParamCreate;
  Property TypeRequest             : TTypeRequest               Read vTypeRequest             Write vTypeRequest       Default trHttp;
  Property FailOver                : Boolean                    Read vFailOver                Write vFailOver;
  Property FailOverConnections     : TListDefConnections        Read vFailOverConnections     Write vFailOverConnections;
  Property FailOverReplaceDefaults : Boolean                    Read vFailOverReplaceDefaults Write vFailOverReplaceDefaults;
  Property ClientConnectionDefs    : TClientConnectionDefs      Read vClientConnectionDefs    Write vClientConnectionDefs;
  Property UserAgent               : String                     Read vUserAgent               Write vUserAgent;
  Property ServerContext           : String                     Read vServerContext           Write vServerContext;
End;

Type
 TRESTDWUpdateSQL = Class(TDWComponent) //Classe com as funcionalidades de um DBQuery
 Protected
  Procedure Notification(AComponent : TComponent;
                         Operation  : TOperation); override;
 Private
  vEncoding            : TEncodeSelect;
  vMassiveCacheSQLList : TDWMassiveCacheSQLList;
  vClientSQLBase       : TRESTDWClientSQLBase;
  vSQLInsert,
  vSQLDelete,
  vSQLUpdate,
  vSQLLock,
  vSQLUnlock,
  vSQLRefresh          : TStringList;
  fsAbout              : TDWAboutInfo;
  Function  GetVersionInfo      : String;
  Function  getClientSQLB       : TRESTDWClientSQLBase;
  Procedure setClientSQLB(Value : TRESTDWClientSQLBase);
  Procedure SetSQLDelete (Value : TStringList);
  Procedure SetSQLInsert (Value : TStringList);
  Procedure SetSQLLock   (Value : TStringList);
  Procedure SetSQLUnlock (Value : TStringList);
  Procedure SetSQLRefresh(Value : TStringList);
  Procedure SetSQLUpdate (Value : TStringList);
 Public
  Procedure Clear;
  Function  MassiveCount      : Integer;
  Function  ToJSON            : String;
  Procedure SetClientSQL(Value  : TRESTDWClientSQLBase);
  Procedure Store     (SQL                  : String;
                       Dataset              : TDataset;
                       DeleteCommand        : Boolean = False);
  Constructor Create  (AOwner : TComponent);Override;//Cria o Componente
  Destructor  Destroy;Override;                                                   //Destroy a Classe
  Property    VersionInfo : String Read GetVersionInfo;
 Published
  Property Dataset        : TRESTDWClientSQLBase Read getClientSQLB  Write setClientSQLB;
  Property Encoding       : TEncodeSelect        Read vEncoding      Write vEncoding;
  Property DeleteSQL      : TStringList          Read vSQLDelete     Write SetSQLDelete;
  Property InsertSQL      : TStringList          Read vSQLInsert     Write SetSQLInsert;
  Property LockSQL        : TStringList          Read vSQLLock       Write SetSQLLock;
  Property UnlockSQL      : TStringList          Read vSQLUnlock     Write SetSQLUnlock;
  Property FetchRowSQL    : TStringList          Read vSQLRefresh    Write SetSQLRefresh;
  Property ModifySQL      : TStringList          Read vSQLUpdate     Write SetSQLUpdate;
  Property AboutInfo      : TDWAboutInfo         Read fsAbout        Write fsAbout Stored False;
End;

Type
 TRESTDwThreadRequest = Class(TThread)
 Protected
  Procedure ProcessMessages;
  Procedure Execute;Override;
 Private
  vSelf                             : TComponent;
  vOnExecuteData,
  vAbortData                        : TOnExecuteData;
  vOnThreadRequestError             : TOnThreadRequestError;
 Public
  Procedure   Kill;
  Destructor  Destroy; Override;
  Constructor Create(aSelf                : TComponent;
                     OnExecuteData,
                     AbortData            : TOnExecuteData;
                     OnThreadRequestError : TOnThreadRequestError);
End;

Type
 TRESTDWClientSQL = Class(TRESTDWClientSQLBase) //Classe com as funcionalidades de um DBQuery
 Private
  vActualPoolerMethodClient : TDWPoolerMethodClient;
  vOldState             : TDatasetState;
  vOldCursor,
  vActionCursor         : TCursor;
  vDWResponseTranslator : TDWResponseTranslator;
  vUpdateSQL            : TRESTDWUpdateSQL;
  vMasterDetailItem     : TMasterDetailItem;
  vFieldsList           : TFieldsList;
  vMassiveCache         : TDWMassiveCache;
  vOldStatus            : TDatasetState;
  vDataSource           : TDataSource;
  vOnFiltered           : TOnFiltered;
  vOnAfterScroll        : TOnAfterScroll;
  vOnAfterOpen          : TOnAfterOpen;
  vOnBeforeClose        : TOnBeforeClose;
  vOnAfterClose         : TOnAfterClose;
  vOnBeforeRefresh      : TOnBeforeRefresh;
  vOnAfterRefresh       : TOnAfterRefresh;
  vOnCalcFields         : TDatasetEvents;
  vThreadRequest        : TRESTDwThreadRequest;
  vNewRecord,
  vBeforeOpen,
  vOnBeforeScroll,
  vBeforeEdit,
  vBeforeInsert,
  vBeforePost,
  vBeforeDelete,
  vAfterDelete,
  vAfterEdit,
  vAfterInsert,
  vAfterPost,
  vAfterCancel          : TDatasetEvents;
  vMassiveMode          : TMassiveType;
  vRowsAffected,
  vOldRecordCount,
  vDatapacks,
  vJsonCount,
  vParamCount,
  vActualRec            : Integer;
  vActualJSON,
  vOldSQL,
  vMasterFields,
  vUpdateTableName      : String;                            //Tabela que ser� feito Update no Servidor se for usada Reflex�o de Dados
  vInitDataset,
  vInternalLast,
  vFiltered,
  vActiveCursor,
  vOnOpenCursor,
  vCacheUpdateRecords,
  vReadData,
  vOnPacks,
  vCascadeDelete,
  vBeforeClone,
  vDataCache,                                               //Se usa cache local
  vConnectedOnce,                                           //Verifica se foi conectado ao Servidor
  vCommitUpdates,
  vCreateDS,
  GetNewData,
  vErrorBefore,
  vNotRepage,
  vBinaryRequest,
  vRaiseError,
  vReflectChanges,
  vInDesignEvents,
  vAutoCommitData,
  vAutoRefreshAfterCommit,
  vPropThreadRequest,
  vInRefreshData,
  vInBlockEvents        : Boolean;
  vRelationFields,
  vSQL                  : TStringList;                       //SQL a ser utilizado na conex�o
  vParams               : TParams;                           //Parametros de Dataset
  vCacheDataDB          : TDataset;                          //O Cache de Dados Salvo para utiliza��o r�pida
  vOnGetDataError       : TOnEventConnection;                //Se deu erro na hora de receber os dados ou n�o
  vOnThreadRequestError : TOnThreadRequestError;
  vRESTDataBase         : TRESTDWDataBase;                   //RESTDataBase do Dataset
  FieldDefsUPD          : TFieldDefs;
  vMasterDataSet        : TRESTDWClientSQL;
  vMasterDetailList     : TMasterDetailList;                 //DataSet MasterDetail Function
  vMassiveDataset       : TMassiveDataset;
  vLastOpen             : Integer;
  {$IFDEF FPC}
  {$IFDEF LAZDRIVER}
  procedure CloneDefinitions     (Source  : TMemDataset;
                                  aSelf   : TMemDataset);
  {$ENDIF}
  {$IFDEF DWMEMTABLE}
  Procedure CloneDefinitions     (Source  : TDWMemtable;
                                  aSelf   : TDWMemtable); //Fields em Defini��es
  {$ENDIF}
  {$IFDEF UNIDACMEM}
  Procedure CloneDefinitions     (Source  : TVirtualTable;
                                   aSelf  : TVirtualTable);
  {$ENDIF}
  {$ELSE}
  {$IFDEF CLIENTDATASET}
  Procedure  CloneDefinitions    (Source  : TClientDataset;
                                  aSelf   : TClientDataset); //Fields em Defini��es
  {$ENDIF}
  {$IFDEF UNIDACMEM}
  Procedure CloneDefinitions     (Source  : TVirtualTable;
                                   aSelf  : TVirtualTable);
  {$ENDIF}
  {$IFDEF RESTKBMMEMTABLE}
  Procedure  CloneDefinitions    (Source  : TKbmMemtable;
                                  aSelf   : TKbmMemtable); //Fields em Defini��es
  {$ENDIF}
  {$IFDEF RESTFDMEMTABLE}
  Procedure  CloneDefinitions    (Source  : TFdMemtable;
                                  aSelf   : TFdMemtable); //Fields em Defini��es
  {$ENDIF}
  {$IFDEF RESTADMEMTABLE}
  Procedure  CloneDefinitions    (Source  : TAdMemtable;
                                  aSelf   : TAdMemtable); //Fields em Defini��es
  Property CommandText;
  {$ENDIF}
  {$IFDEF DWMEMTABLE}
  Procedure  CloneDefinitions    (Source  : TDWMemtable;
                                  aSelf   : TDWMemtable); //Fields em Defini��es
  {$ENDIF}
  {$ENDIF}
  Procedure   OnChangingSQL      (Sender  : TObject);       //Quando Altera o SQL da Lista
  Procedure   OnBeforeChangingSQL(Sender  : TObject);
  Procedure   SetActiveDB        (Value   : Boolean);       //Seta o Estado do Dataset
  Procedure   SetSQL             (Value     : TStringList);   //Seta o SQL a ser usado
  Procedure   CreateParams;                                 //Cria os Parametros na lista de Dataset
  Procedure   SetDataBase        (Value     : TRESTDWDataBase); //Diz o REST Database
  Procedure   ExecuteOpen;
  Function    GetData            (DataSet   : TJSONValue = Nil) : Boolean;//Recebe os Dados da Internet vindo do Servidor REST
  Procedure   SetUpdateTableName (Value     : String);        //Diz qual a tabela que ser� feito Update no Banco
  Procedure   OldAfterPost       (DataSet   : TDataSet);      //Eventos do Dataset para realizar o AfterPost
  Procedure   OldAfterDelete     (DataSet   : TDataSet);      //Eventos do Dataset para realizar o AfterDelete
  Procedure   SetMasterDataSet   (Value     : TRESTDWClientSQL);
  Procedure   SetUpdateSQL       (Value     : TRESTDWUpdateSQL);
  Function    GetUpdateSQL                  : TRESTDWUpdateSQL;
  Procedure   SetCacheUpdateRecords(Value   : Boolean);
  Function    FirstWord          (Value     : String) : String;
  Procedure   ProcBeforeScroll   (DataSet   : TDataSet);
  Procedure   ProcAfterScroll    (DataSet   : TDataSet);
  Procedure   ProcBeforeOpen     (DataSet   : TDataSet);
  Procedure   ProcAfterOpen      (DataSet   : TDataSet);
  Procedure   ProcBeforeClose    (DataSet   : TDataSet);
  Procedure   ProcAfterClose     (DataSet   : TDataSet);
  Procedure   ProcBeforeRefresh  (DataSet   : TDataSet);
  Procedure   ProcAfterRefresh   (DataSet   : TDataSet);
  Procedure   ProcBeforeInsert   (DataSet   : TDataSet);
  Procedure   ProcAfterInsert    (DataSet   : TDataSet);
  Procedure   ProcNewRecord      (DataSet   : TDataSet);
  Procedure   ProcBeforeDelete   (DataSet   : TDataSet); //Evento para Delta
  Procedure   ProcBeforeEdit     (DataSet   : TDataSet); //Evento para Delta
  Procedure   ProcAfterEdit      (DataSet   : TDataSet);
  Procedure   ProcBeforePost     (DataSet   : TDataSet); //Evento para Delta
  Procedure   ProcAfterCancel    (DataSet   : TDataSet);
  Procedure   ProcCalcFields     (DataSet   : TDataSet);
  Procedure   ProcBeforeExec     (DataSet   : TDataSet);
  procedure   CreateMassiveDataset;
  procedure   SetParams(const Value: TParams);
  Procedure   CleanFieldList;
  Procedure   GetTmpCursor;
  Procedure   SetCursor;
  Procedure   SetOldCursor;
  Procedure   ChangeCursor(OldCursor : Boolean = False);
  Procedure   SetDatapacks(Value : Integer);
  Procedure   SetReflectChanges(Value       : Boolean);
  Procedure   SetAutoRefreshAfterCommit(Value : Boolean);
  Function    ProcessChanges   (MassiveJSON : String): Boolean;
  function    GetMassiveCache: TDWMassiveCache;
  procedure   SetMassiveCache(const Value: TDWMassiveCache);
  function    GetDWResponseTranslator: TDWResponseTranslator;
  procedure   SetDWResponseTranslator(const Value: TDWResponseTranslator);
  Function    GetReadData                   : Boolean;
  Property    MasterFields                  : String   Read vMasterFields  Write vMasterFields;
//  Procedure   InternalDeferredPost;override; // Gilberto Rocha 12/04/2019 - usado para poder fazer datasource.dataset.Post
 Protected
  vBookmark : Integer;
  vActive,
  vInactive : Boolean;
  Procedure   InternalPost; override; // Gilberto Rocha 12/04/2019 - usado para poder fazer datasource.dataset.Post
  procedure   InternalOpen; override; // Gilberto Rocha 03/09/2021 - usado para poder fazer datasource.dataset.Open
  Function    GetRecordCount : Integer; Override;
  procedure   InternalRefresh; override; // Gilberto Rocha 03/09/2021 - usado para poder fazer datasource.dataset.Refresh
  procedure   CloseCursor; override; // Gilberto Rocha 03/09/2021 - usado para poder fazer datasource.dataset.Close
  Procedure   Notification(AComponent: TComponent; Operation: TOperation); override;
  Procedure   ThreadStart(ExecuteData : TOnExecuteData);
  Procedure   ThreadDestroy;
  Procedure   AbortData;
 Public
  //M�todos
  Procedure   SetInactive      (Const Value            : Boolean);
  Procedure   Post; Override;
  Function    OpenJson         (JsonValue              : String = '';
                                Const ElementRoot      : String = '';
                                Const Utf8SpecialChars : Boolean = False) : Boolean;
  Procedure   SetInBlockEvents (Const Value            : Boolean);Override;
  Procedure   SetInitDataset   (Const Value            : Boolean);Override;
  Procedure   SetInDesignEvents(Const Value            : Boolean);Overload;
  Function    GetInBlockEvents  : Boolean;
  Function    GetInDesignEvents : Boolean;
  Procedure   NewFieldList;
  Function    GetFieldListByName(aName : String) : TFieldDefinition;
  Procedure   NewDataField(Value : TFieldDefinition);
  Function    FieldListCount    : Integer;
  Procedure   Newtable;
  Procedure   PrepareDetailsNew; Override;
  Procedure   PrepareDetails     (ActiveMode : Boolean);Override;
  Procedure   FieldDefsToFields;
  Procedure   RebuildMassiveDataset;
  Class Function FieldDefExist   (Const Dataset : TDataset;
                                  Value   : String) : TFieldDef;
  Function    FieldExist         (Value   : String) : TField;
  Procedure   Open; Overload; //Virtual;                     //M�todo Open que ser� utilizado no Componente
  Procedure   Open               (strSQL  : String);Overload; Virtual;//M�todo Open que ser� utilizado no Componente
  Procedure   ExecOrOpen;                                        //M�todo Open que ser� utilizado no Componente
  Procedure   Close; Virtual;                                    //M�todo Close que ser� utilizado no Componente
  Procedure   CreateDataSet;
  Class Procedure CreateEmptyDataset(Const Dataset : TDataset);
  Procedure   CreateDatasetFromList;
  Procedure   ExecSQL;Overload;                                        //M�todo ExecSQL que ser� utilizado no Componente
  Function    ExecSQL          (Var Error : String) : Boolean;Overload;//M�todo ExecSQL que ser� utilizado no Componente
  Function    InsertMySQLReturnID : Integer;                     //M�todo de ExecSQL com retorno de Incremento
  Function    ParamByName          (Value : String) : TParam;    //Retorna o Parametro de Acordo com seu nome
  Procedure   ApplyUpdates;Overload;
  Function    ApplyUpdates     (Var Error : String; ReleaseCache : Boolean = True) : Boolean;Overload;//Aplica Altera��es no Banco de Dados
  Constructor Create              (AOwner : TComponent);Override;//Cria o Componente
  Destructor  Destroy;Override;                                  //Destroy a Classe
  Procedure   Loaded; Override;
  procedure   OpenCursor       (InfoQuery : Boolean); Override;  //Subscrevendo o OpenCursor para n�o ter erros de ADD Fields em Tempo de Design
  Procedure   GotoRec       (Const aRecNo : Integer);
  Function    ParamCount            : Integer;
  Procedure   DynamicFilter(cFields : Array of String;
                            Value   : String;
                            InText  : Boolean;
                            AndOrOR : String);
  {$IFNDEF FPC}
   {$IFDEF DWMEMTABLE}
   Property    Encoding;
   {$ENDIF}
  {$ENDIF}
  Procedure   Refresh;
  Procedure   SaveToStream    (Var Stream : TMemoryStream);
  Procedure   LoadFromStream      (Stream : TMemoryStream);
  Procedure   ClearMassive;
  Function    MassiveCount  : Integer;
  Function    MassiveToJSON : String; //Transporte de MASSIVE em formato JSON
  Procedure   DWParams        (Var Value  : TDWParams);
  Procedure   RestoreDatasetPosition;
  Procedure   SetFilteredB(aValue  : Boolean);
  Procedure   InternalLast;Override;
  Procedure   Setnotrepage (Value : Boolean);
  Procedure   SetRecordCount(aJsonCount, aRecordCount : Integer);
  Property    RowsAffected         : Integer               Read vRowsAffected;
  Property    ServerFieldList      : TFieldsList           Read vFieldsList;
  Property    Inactive             : Boolean               Read vInactive                 Write vInactive;
  Property    LastOpen             : Integer               Read vLastOpen                 Write vLastOpen;
  Property    FieldDefs;
  Property    ReadData             : Boolean               Read GetReadData;
  Property    MasterDetailList     : TMasterDetailList     Read vMasterDetailList         Write vMasterDetailList;
 Published
  Property MasterDataSet           : TRESTDWClientSQL      Read vMasterDataSet            Write SetMasterDataSet;
  {$IFDEF FPC}
  Property DatabaseCharSet;
  {$ENDIF}
  Property BinaryCompatibleMode;
  Property MasterCascadeDelete     : Boolean               Read vCascadeDelete            Write vCascadeDelete;
  Property BinaryRequest           : Boolean               Read vBinaryRequest            Write vBinaryRequest;
  Property Datapacks               : Integer               Read vDatapacks                Write SetDatapacks;
  Property OnGetDataError          : TOnEventConnection    Read vOnGetDataError           Write vOnGetDataError;         //Recebe os Erros de ExecSQL ou de GetData
  Property AfterScroll             : TOnAfterScroll        Read vOnAfterScroll            Write vOnAfterScroll;
  Property AfterOpen               : TOnAfterOpen          Read vOnAfterOpen              Write vOnAfterOpen;
  Property BeforeClose             : TOnBeforeClose        Read vOnBeforeClose            Write vOnBeforeClose;
  Property AfterClose              : TOnAfterClose         Read vOnAfterClose             Write vOnAfterClose;
  Property BeforeRefresh           : TOnBeforeRefresh      Read vOnBeforeRefresh          Write vOnBeforeRefresh;
  Property AfterRefresh            : TOnAfterRefresh       Read vOnAfterRefresh           Write vOnAfterRefresh;
  Property OnFiltered              : TOnFiltered           Read vOnFiltered               Write vOnFiltered;
  Property Active                  : Boolean               Read vActive                   Write SetActiveDB;             //Estado do Dataset
  Property DataCache               : Boolean               Read vDataCache                Write vDataCache;              //Diz se ser� salvo o �ltimo Stream do Dataset
  Property MassiveType             : TMassiveType          Read vMassiveMode              Write vMassiveMode;
  Property Params                  : TParams               Read vParams                   Write SetParams;                 //Parametros de Dataset
  Property DataBase                : TRESTDWDataBase       Read vRESTDataBase             Write SetDataBase;             //Database REST do Dataset
  Property SQL                     : TStringList           Read vSQL                      Write SetSQL;                  //SQL a ser Executado
  Property RelationFields          : TStringList           Read vRelationFields           Write vRelationFields;
  Property UpdateTableName         : String                Read vUpdateTableName          Write SetUpdateTableName;      //Tabela que ser� usada para Reflex�o de Dados
  Property CacheUpdateRecords      : Boolean               Read vCacheUpdateRecords       Write SetCacheUpdateRecords;
  Property AutoCommitData          : Boolean               Read vAutoCommitData           Write vAutoCommitData;
  Property AutoRefreshAfterCommit  : Boolean               Read vAutoRefreshAfterCommit   Write SetAutoRefreshAfterCommit;
  Property ThreadRequest           : Boolean               Read vPropThreadRequest        Write vPropThreadRequest;
  Property RaiseErrors             : Boolean               Read vRaiseError               Write vRaiseError;
  Property BeforeOpen              : TDatasetEvents        Read vBeforeOpen               Write vBeforeOpen;
  Property BeforeEdit              : TDatasetEvents        Read vBeforeEdit               Write vBeforeEdit;
  Property BeforeScroll            : TDatasetEvents        Read vOnBeforeScroll           Write vOnBeforeScroll;
  Property BeforeInsert            : TDatasetEvents        Read vBeforeInsert             Write vBeforeInsert;
  Property BeforePost              : TDatasetEvents        Read vBeforePost               Write vBeforePost;
  Property BeforeDelete            : TDatasetEvents        Read vBeforeDelete             Write vBeforeDelete;
  Property AfterDelete             : TDatasetEvents        Read vAfterDelete              Write vAfterDelete;
  Property AfterEdit               : TDatasetEvents        Read vAfterEdit                Write vAfterEdit;
  Property AfterInsert             : TDatasetEvents        Read vAfterInsert              Write vAfterInsert;
  Property AfterPost               : TDatasetEvents        Read vAfterPost                Write vAfterPost;
  Property AfterCancel             : TDatasetEvents        Read vAfterCancel              Write vAfterCancel;
  Property OnThreadRequestError    : TOnThreadRequestError Read vOnThreadRequestError     Write vOnThreadRequestError;
  Property UpdateSQL               : TRESTDWUpdateSQL      Read GetUpdateSQL              Write SetUpdateSQL;
  Property OnCalcFields            : TDatasetEvents        Read vOnCalcFields             Write vOnCalcFields;
  Property OnNewRecord             : TDatasetEvents        Read vNewRecord                Write vNewRecord;
  Property MassiveCache            : TDWMassiveCache       Read GetMassiveCache           Write SetMassiveCache;
  Property Filtered                : Boolean               Read vFiltered                 Write SetFilteredB;
  Property DWResponseTranslator    : TDWResponseTranslator Read GetDWResponseTranslator   Write SetDWResponseTranslator;
  Property ActionCursor            : TCursor               Read vActionCursor             Write vActionCursor;
  Property ReflectChanges          : Boolean               Read vReflectChanges           Write SetReflectChanges;
End;


Type
 TRESTDWTable  = Class(TRESTDWClientSQLBase) //Classe com as funcionalidades de um DBTable
 Private
  vActualPoolerMethodClient : TDWPoolerMethodClient;
  vOldState             : TDatasetState;
  vOldCursor,
  vActionCursor         : TCursor;
  vDWResponseTranslator : TDWResponseTranslator;
  vUpdateSQL            : TRESTDWUpdateSQL;
  vMasterDetailItem     : TMasterDetailItem;
  vFieldsList           : TFieldsList;
  vMassiveCache         : TDWMassiveCache;
  vOldStatus            : TDatasetState;
  vDataSource           : TDataSource;
  vOnFiltered           : TOnFiltered;
  vOnAfterScroll        : TOnAfterScroll;
  vOnAfterOpen          : TOnAfterOpen;
  vOnBeforeClose        : TOnBeforeClose;
  vOnAfterClose         : TOnAfterClose;
  vOnBeforeRefresh      : TOnBeforeRefresh;
  vOnAfterRefresh       : TOnAfterRefresh;
  vOnCalcFields         : TDatasetEvents;
  vMassiveMode          : TMassiveType;
  vNewRecord,
  vBeforeOpen,
  vOnBeforeScroll,
  vBeforeEdit,
  vBeforeInsert,
  vBeforePost,
  vBeforeDelete,
  vAfterDelete,
  vAfterEdit,
  vAfterInsert,
  vAfterPost,
  vAfterCancel          : TDatasetEvents;
  vRowsAffected,
  vOldRecordCount,
  vDatapacks,
  vJsonCount,
  vParamCount,
  vActualRec            : Integer;
  vActualJSON,
  vMasterFields,
  vTableName            : String;                            //Tabela que ser� feito Update no Servidor se for usada Reflex�o de Dados
  vInitDataset,
  vInternalLast,
  vFiltered,
  vActiveCursor,
  vOnOpenCursor,
  vCacheUpdateRecords,
  vReadData,
  vOnPacks,
  vCascadeDelete,
  vBeforeClone,
  vDataCache,                                               //Se usa cache local
  vConnectedOnce,                                           //Verifica se foi conectado ao Servidor
  vCommitUpdates,
  vCreateDS,
  GetNewData,
  vErrorBefore,
  vNotRepage,
  vBinaryRequest,
  vRaiseError,
  vInDesignEvents,
  vAutoCommitData,
  vAutoRefreshAfterCommit,
  vInRefreshData,
  vInBlockEvents        : Boolean;
  vRelationFields       : TStringList;                       //SQL a ser utilizado na conex�o
  vParams               : TParams;                           //Parametros de Dataset
  vCacheDataDB          : TDataset;                          //O Cache de Dados Salvo para utiliza��o r�pida
  vOnGetDataError       : TOnEventConnection;                //Se deu erro na hora de receber os dados ou n�o
  vRESTDataBase         : TRESTDWDataBase;                   //RESTDataBase do Dataset
  FieldDefsUPD          : TFieldDefs;
  vMasterDataSet        : TRESTDWClientSQLBase;
  vMasterDetailList     : TMasterDetailList;                 //DataSet MasterDetail Function
  vMassiveDataset       : TMassiveDataset;
  vLastOpen             : Integer;
  Procedure   SetActiveDB        (Value     : Boolean);       //Seta o Estado do Dataset
  Procedure   SetDataBase        (Value     : TRESTDWDataBase); //Diz o REST Database
  Function    GetData            (DataSet   : TJSONValue = Nil) : Boolean;//Recebe os Dados da Internet vindo do Servidor REST
  Procedure   OldAfterPost       (DataSet   : TDataSet);      //Eventos do Dataset para realizar o AfterPost
  Procedure   OldAfterDelete     (DataSet   : TDataSet);      //Eventos do Dataset para realizar o AfterDelete
  Procedure   SetMasterDataSet   (Value     : TRESTDWClientSQLBase);
  Procedure   SetUpdateSQL       (Value     : TRESTDWUpdateSQL);
  Function    GetUpdateSQL                  : TRESTDWUpdateSQL;
  Procedure   SetCacheUpdateRecords(Value   : Boolean);
  Function    FirstWord          (Value     : String) : String;
  Procedure   ProcBeforeScroll   (DataSet   : TDataSet);
  Procedure   ProcAfterScroll    (DataSet   : TDataSet);
  Procedure   ProcBeforeOpen     (DataSet   : TDataSet);
  Procedure   ProcAfterOpen      (DataSet   : TDataSet);
  Procedure   ProcBeforeClose    (DataSet   : TDataSet);
  Procedure   ProcAfterClose     (DataSet   : TDataSet);
  Procedure   ProcBeforeRefresh  (DataSet   : TDataSet);
  Procedure   ProcAfterRefresh   (DataSet   : TDataSet);
  Procedure   ProcBeforeInsert   (DataSet   : TDataSet);
  Procedure   ProcAfterInsert    (DataSet   : TDataSet);
  Procedure   ProcNewRecord      (DataSet   : TDataSet);
  Procedure   ProcBeforeDelete   (DataSet   : TDataSet); //Evento para Delta
  Procedure   ProcBeforeEdit     (DataSet   : TDataSet); //Evento para Delta
  Procedure   ProcAfterEdit      (DataSet   : TDataSet);
  Procedure   ProcBeforePost     (DataSet   : TDataSet); //Evento para Delta
  Procedure   ProcAfterCancel    (DataSet   : TDataSet);
  Procedure   ProcCalcFields     (DataSet: TDataSet);
  procedure   CreateMassiveDataset;
  procedure   SetParams(const Value: TParams);
  Procedure   CleanFieldList;
  Procedure   GetTmpCursor;
  Procedure   SetCursor;
  Procedure   SetOldCursor;
  Procedure   ChangeCursor(OldCursor : Boolean = False);
  Procedure   SetDatapacks(Value : Integer);
  Procedure   SetAutoRefreshAfterCommit(Value : Boolean);
  Function    ProcessChanges   (MassiveJSON : String): Boolean;
  Function    GetMassiveCache: TDWMassiveCache;
  Procedure   SetMassiveCache(const Value: TDWMassiveCache);
  function    GetDWResponseTranslator: TDWResponseTranslator;
  procedure   SetDWResponseTranslator(const Value: TDWResponseTranslator);
  Property    MasterFields                  : String   Read vMasterFields  Write vMasterFields;
//  Procedure   InternalDeferredPost;override; // Gilberto Rocha 12/04/2019 - usado para poder fazer datasource.dataset.Post
  Procedure   SetTablename(Value : String);
 Protected
  vBookmark : Integer;
  vActive,
  vInactive : Boolean;
  Procedure   InternalPost; override; // Gilberto Rocha 12/04/2019 - usado para poder fazer datasource.dataset.Post
  procedure   InternalOpen; override; // Gilberto Rocha 07/09/2020 - usado para poder fazer datasource.dataset.Open
  Function  GetRecordCount : Integer; Override;
  procedure InternalRefresh; override; // Gilberto Rocha 07/09/2020 - usado para poder fazer datasource.dataset.Refresh
  procedure CloseCursor; override; // Gilberto Rocha 07/09/2020 - usado para poder fazer datasource.dataset.Close
  Procedure Notification(AComponent: TComponent; Operation: TOperation); override;
 Public
  //M�todos
  Procedure   Post; Override;
  Function    OpenJson         (JsonValue              : String = '';
                                Const ElementRoot      : String = '';
                                Const Utf8SpecialChars : Boolean = False) : Boolean;
  Procedure   SetInBlockEvents (Const Value            : Boolean);Override;
  Procedure   SetInitDataset   (Const Value            : Boolean);Override;
  Procedure   SetInDesignEvents(Const Value            : Boolean);Overload;
  Function    GetInBlockEvents  : Boolean;
  Function    GetInDesignEvents : Boolean;
  Procedure   NewFieldList;
  Function    GetFieldListByName(aName : String) : TFieldDefinition;
  Procedure   NewDataField(Value : TFieldDefinition);
  Function    FieldListCount    : Integer;
  Procedure   Newtable;
  Procedure   PrepareDetailsNew; Override;
  Procedure   PrepareDetails     (ActiveMode : Boolean);Override;
  Procedure   FieldDefsToFields;
  Procedure   RebuildMassiveDataset;
  Class Function FieldDefExist   (Const Dataset : TDataset;
                                  Value   : String) : TFieldDef;
  Function    FieldExist         (Value   : String) : TField;
  Procedure   Open; Overload; //Virtual;                     //M�todo Open que ser� utilizado no Componente
  Procedure   Close; Virtual;                                    //M�todo Close que ser� utilizado no Componente
  Procedure   CreateDataSet;
  Class Procedure CreateEmptyDataset(Const Dataset : TDataset);
  Procedure   CreateDatasetFromList;
  Function    ParamByName          (Value : String) : TParam;    //Retorna o Parametro de Acordo com seu nome
  Procedure   ApplyUpdates;Overload;
  Function    ApplyUpdates     (Var Error : String; ReleaseCache : Boolean = True) : Boolean;Overload;//Aplica Altera��es no Banco de Dados
  Constructor Create              (AOwner : TComponent);Override;//Cria o Componente
  Destructor  Destroy;Override;                                  //Destroy a Classe
  Procedure   Loaded; Override;
  procedure   OpenCursor       (InfoQuery : Boolean); Override;  //Subscrevendo o OpenCursor para n�o ter erros de ADD Fields em Tempo de Design
  Procedure   GotoRec       (Const aRecNo : Integer);
  Function    ParamCount            : Integer;
  Procedure   DynamicFilter(cFields : Array of String;
                            Value   : String;
                            InText  : Boolean;
                            AndOrOR : String);
  {$IFNDEF FPC}
   {$IFDEF DWMEMTABLE}
   Property    Encoding;
   {$ENDIF}
  {$ENDIF}
  Procedure   Refresh;
  Procedure   SaveToStream    (Var Stream : TMemoryStream);
  Procedure   LoadFromStream      (Stream : TMemoryStream);
  Procedure   ClearMassive;
  Function    MassiveCount  : Integer;
  Function    MassiveToJSON : String; //Transporte de MASSIVE em formato JSON
  Procedure   DWParams        (Var Value  : TDWParams);
  Procedure   RestoreDatasetPosition;
  Procedure   SetFilteredB(aValue  : Boolean);
  Procedure   InternalLast;Override;
  Procedure   Setnotrepage (Value : Boolean);
  Procedure   SetRecordCount(aJsonCount, aRecordCount : Integer);
  Property    RowsAffected         : Integer               Read vRowsAffected;
  Property    ServerFieldList      : TFieldsList           Read vFieldsList;
  Property    Inactive             : Boolean               Read vInactive                 Write vInactive;
  Property    LastOpen             : Integer               Read vLastOpen                 Write vLastOpen;
  Property    FieldDefs;
 Published
  Property MasterDataSet           : TRESTDWClientSQLBase  Read vMasterDataSet            Write SetMasterDataSet;
  {$IFDEF FPC}
  Property DatabaseCharSet;
  {$ENDIF}
  Property BinaryCompatibleMode;
  Property MasterCascadeDelete     : Boolean               Read vCascadeDelete            Write vCascadeDelete;
  Property BinaryRequest           : Boolean               Read vBinaryRequest            Write vBinaryRequest;
  Property Datapacks               : Integer               Read vDatapacks                Write SetDatapacks;
  Property OnGetDataError          : TOnEventConnection    Read vOnGetDataError           Write vOnGetDataError;         //Recebe os Erros de ExecSQL ou de GetData
  Property AfterScroll             : TOnAfterScroll        Read vOnAfterScroll            Write vOnAfterScroll;
  Property AfterOpen               : TOnAfterOpen          Read vOnAfterOpen              Write vOnAfterOpen;
  Property BeforeClose             : TOnBeforeClose        Read vOnBeforeClose            Write vOnBeforeClose;
  Property AfterClose              : TOnAfterClose         Read vOnAfterClose             Write vOnAfterClose;
  Property BeforeRefresh           : TOnBeforeRefresh      Read vOnBeforeRefresh          Write vOnBeforeRefresh;
  Property AfterRefresh            : TOnAfterRefresh       Read vOnAfterRefresh           Write vOnAfterRefresh;
  Property OnFiltered              : TOnFiltered           Read vOnFiltered               Write vOnFiltered;
  Property Active                  : Boolean               Read vActive                   Write SetActiveDB;             //Estado do Dataset
  Property DataCache               : Boolean               Read vDataCache                Write vDataCache;              //Diz se ser� salvo o �ltimo Stream do Dataset
  Property MassiveType             : TMassiveType          Read vMassiveMode              Write vMassiveMode;
  Property Params                  : TParams               Read vParams                   Write SetParams;                 //Parametros de Dataset
  Property DataBase                : TRESTDWDataBase       Read vRESTDataBase             Write SetDataBase;             //Database REST do Dataset
  Property RelationFields          : TStringList           Read vRelationFields           Write vRelationFields;
  Property TableName               : String                Read vTableName                Write SetTableName;      //Tabela que ser� usada para Reflex�o de Dados
  Property CacheUpdateRecords      : Boolean               Read vCacheUpdateRecords       Write SetCacheUpdateRecords;
  Property AutoCommitData          : Boolean               Read vAutoCommitData           Write vAutoCommitData;
  Property AutoRefreshAfterCommit  : Boolean               Read vAutoRefreshAfterCommit   Write SetAutoRefreshAfterCommit;
  Property RaiseErrors             : Boolean               Read vRaiseError               Write vRaiseError;
  Property BeforeOpen              : TDatasetEvents        Read vBeforeOpen               Write vBeforeOpen;
  Property BeforeEdit              : TDatasetEvents        Read vBeforeEdit               Write vBeforeEdit;
  Property BeforeScroll            : TDatasetEvents        Read vOnBeforeScroll           Write vOnBeforeScroll;
  Property BeforeInsert            : TDatasetEvents        Read vBeforeInsert             Write vBeforeInsert;
  Property BeforePost              : TDatasetEvents        Read vBeforePost               Write vBeforePost;
  Property BeforeDelete            : TDatasetEvents        Read vBeforeDelete             Write vBeforeDelete;
  Property AfterDelete             : TDatasetEvents        Read vAfterDelete              Write vAfterDelete;
  Property AfterEdit               : TDatasetEvents        Read vAfterEdit                Write vAfterEdit;
  Property AfterInsert             : TDatasetEvents        Read vAfterInsert              Write vAfterInsert;
  Property AfterPost               : TDatasetEvents        Read vAfterPost                Write vAfterPost;
  Property AfterCancel             : TDatasetEvents        Read vAfterCancel              Write vAfterCancel;
  Property UpdateSQL               : TRESTDWUpdateSQL      Read GetUpdateSQL              Write SetUpdateSQL;
  Property OnCalcFields            : TDatasetEvents        Read vOnCalcFields             Write vOnCalcFields;
  Property OnNewRecord             : TDatasetEvents        Read vNewRecord                Write vNewRecord;
  Property MassiveCache            : TDWMassiveCache       Read GetMassiveCache           Write SetMassiveCache;
  Property Filtered                : Boolean               Read vFiltered                 Write SetFilteredB;
  Property DWResponseTranslator    : TDWResponseTranslator Read GetDWResponseTranslator   Write SetDWResponseTranslator;
  Property ActionCursor            : TCursor               Read vActionCursor             Write vActionCursor;
End;


Type
 TDWFieldKind          = (dwfk_Keyfield, dwfk_Autoinc, dwfk_NotNull);
 TDWFieldType          = Set of TDWFieldKind;
 TRESTDWBatchFieldItem = Class(TCollectionItem)
 Private
  vListName,
  vSourceField,
  vDestField,
  vDefaultValue    : String;
  vFieldConfig     : TDWFieldType;
  vOnFieldGetValue : TOnFieldGetValue;
 Public
  Function    GetDisplayName             : String;      Override;
  Procedure   SetDisplayName(Const Value : String);     Override;
  Constructor Create        (aCollection : TCollection);Override;
  Destructor  Destroy;Override;//Destroy a Classe
 Published
  Property    SourceField     : String           Read vSourceField     Write vSourceField;
  Property    DestField       : String           Read vDestField       Write vDestField;
  Property    DefaultValue    : String           Read vDefaultValue    Write vDefaultValue;
  Property    FieldConfig     : TDWFieldType     Read vFieldConfig     Write vFieldConfig;
  Property    FieldRuleName   : String           Read vListName        Write vListName;
  Property    OnFieldGetValue : TOnFieldGetValue Read vOnFieldGetValue Write vOnFieldGetValue;
End;

Type
 TRESTDWBatchFieldsDefs = Class(TDWOwnedCollection)
 Private
  Function    GetOwner: TPersistent; override;
 Private
  fOwner      : TPersistent;
  Function    GetRec     (Index       : Integer) : TRESTDWBatchFieldItem;  Overload;
  Procedure   PutRec     (Index       : Integer;
                          Item        : TRESTDWBatchFieldItem);            Overload;
  Function    GetRecName(Index        : String)  : TRESTDWBatchFieldItem;  Overload;
  Procedure   PutRecName(Index        : String;
                         Item         : TRESTDWBatchFieldItem);            Overload;
  Procedure   ClearList;
 Public
  Constructor Create     (AOwner      : TPersistent;
                          aItemClass  : TCollectionItemClass);
  Destructor  Destroy; Override;
  Function    Add                     : TCollectionItem;
  Procedure   Delete     (Index       : Integer);  Overload;
  Procedure   Delete     (Index       : String);   Overload;
  Property    Items      [Index       : Integer] : TRESTDWBatchFieldItem Read GetRec     Write PutRec; Default;
  Property    ItemsByName[Index       : String ] : TRESTDWBatchFieldItem Read GetRecName Write PutRecName;
End;

Type
 TRESTDWBatchMoveActionType = (bmat_Insert, bmat_Update,
                               bmat_Delete, bmat_InsertUpdate);
 TRESTDWProcessSide         = (psClient, psServer);
 TOnLineProcess             = Procedure (Source   : TRESTDWClientSQL;
                                         Var Dest : TRESTDWClientSQL) Of Object;
 TOnProcessError            = Procedure (Connection : TRESTDWConnectionServer;
                                         ActualReg,
                                         RegsCount  : Integer;
                                         Action     : TRESTDWBatchMoveActionType;
                                         Error      : String)  Of Object;
 TOnProcess                 = Procedure (RegsCount  : Integer) Of Object;
 TOnActProcess              = Procedure (ActualReg,
                                         RegsCount  : Integer) Of Object;
 TRESTDWBatchMove = Class(TDWComponent)
 Private
  vOnLineProcess         : TOnLineProcess;
  vSourceSQLCommand,
  vDestSQLCommand        : String;
  vCommitOnRecs          : Integer;
  vDestConnections       : TListDefConnections;
  vSourceConnection      : TRESTDWConnectionParams;
  vRESTDWBatchFieldsDefs : TRESTDWBatchFieldsDefs;
  vOnProcessError        : TOnProcessError;
  vOnBeginProcess,
  vOnEndProcess          : TOnProcess;
  vOnProcess             : TOnActProcess;
  vSourceClient,
  vDestClient            : TRESTDWClientSQL;
  vRESTDWProcessSide     : TRESTDWProcessSide;
 Public
  Constructor Create(AOwner  : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;
  Function    Start(Action : TRESTDWBatchMoveActionType = bmat_InsertUpdate) : Integer;Overload;
  Function    Start(Source : TRESTDWClientSQL;
                    Action : TRESTDWBatchMoveActionType = bmat_InsertUpdate) : Integer;Overload;
 Published
  Property CommitOnRecs       : Integer                  Read vCommitOnRecs          Write vCommitOnRecs;
  Property DestCommand        : String                   Read vDestSQLCommand        Write vDestSQLCommand;
  Property DestConnections    : TListDefConnections      Read vDestConnections       Write vDestConnections;
  Property FieldsDefs         : TRESTDWBatchFieldsDefs   Read vRESTDWBatchFieldsDefs Write vRESTDWBatchFieldsDefs;
  Property SourceCommand      : String                   Read vSourceSQLCommand      Write vSourceSQLCommand;
  Property SourceConnection   : TRESTDWConnectionParams  Read vSourceConnection      Write vSourceConnection;
  Property OnLineProcess      : TOnLineProcess           Read vOnLineProcess         Write vOnLineProcess;
  Property OnProcessError     : TOnProcessError          Read vOnProcessError        Write vOnProcessError;
  Property OnBeginProcess     : TOnProcess               Read vOnBeginProcess        Write vOnBeginProcess;
  Property OnProcess          : TOnActProcess            Read vOnProcess             Write vOnProcess;
  Property OnEndProcess       : TOnProcess               Read vOnEndProcess          Write vOnEndProcess;
  Property ProcessSide        : TRESTDWProcessSide       Read vRESTDWProcessSide     Write vRESTDWProcessSide;
End;

Type
 TRESTDWStoredProc = Class(TRESTDWClientSQLBase)
 Private
  vActualPoolerMethodClient : TDWPoolerMethodClient;
  vParams        : TParams;
  vBinaryRequest : Boolean;
  vFieldsList    : TFieldsList;
  vParamCount,
  vActualRec     : Integer;
  vSchemaName,
  vProcName      : String;
  vUpdateSQL     : TRESTDWUpdateSQL;
  vRESTDataBase  : TRESTDWDataBase;
  Procedure SetDataBase (Const Value : TRESTDWDataBase);
  Procedure Notification(AComponent  : TComponent;
                         Operation   : TOperation); override;
  Procedure SetUpdateSQL  (Value     : TRESTDWUpdateSQL);
  Function  GetUpdateSQL             : TRESTDWUpdateSQL;
 Public
  Constructor Create   (AOwner       : TComponent);Override; //Cria o Componente
  Function    ExecProc (Var Error    : String) : Boolean;
  Destructor  Destroy;Override;                             //Destroy a Classe
  Function    ParamByName(Value      : String) : TParam;
 Published
  Property DataBase            : TRESTDWDataBase     Read vRESTDataBase      Write SetDataBase;             //Database REST do Dataset
  Property Params              : TParams             Read vParams            Write vParams;                 //Parametros de Dataset
  Property UpdateSQL           : TRESTDWUpdateSQL    Read GetUpdateSQL       Write SetUpdateSQL;
  Property SchemaName          : String              Read vSchemaName        Write vSchemaName;             //SchemaName
  Property StoredProcName      : String              Read vProcName          Write vProcName;               //Procedure a ser Executada
End;

Type
 TRESTDWPoolerList = Class(TDWComponent)
 Private
  vEncoding            : TEncodeSelect;
  vUserAgent,
  vAccessTag,
  vWelcomeMessage,
  vPoolerPrefix,                                     //Prefixo do WS
  vDataRoute,
  vServerContext,
  vRestWebService,                                   //Rest WebService para consultas
  vPoolerNotFoundMessage,
  vRestURL             : String;                     //Qual o Pooler de Conex�o do DataSet
  vTimeOut,
  vConnectTimeOut,
  vRedirectMaximum,
  vPoolerPort          : Integer;                    //A Porta do Pooler
  vCompression,
  vHandleRedirects,
  vConnected,
  vProxy               : Boolean;                    //Diz se tem servidor Proxy
  vProxyOptions        : TProxyOptions;              //Se tem Proxy diz quais as op��es
  vPoolerList          : TStringList;
  vAuthOptionParams    : TRDWClientAuthOptionParams;
  vCripto              : TCripto;
  vTypeRequest         : TTypeRequest;
  Procedure SetConnection(Value : Boolean);          //Seta o Estado da Conex�o
  Procedure SetPoolerPort(Value : Integer);          //Seta a Porta do Pooler a ser usada
  Function  TryConnect : Boolean;                    //Tenta Conectar o Servidor para saber se posso executar comandos
//  Procedure SetConnectionOptions(Var Value : TRESTClientPooler); //Seta as Op��es de Conex�o
 Public
  Constructor Create(AOwner  : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                      //Destroy a Classe
 Published
  Property Active                : Boolean                    Read vConnected          Write SetConnection;      //Seta o Estado da Conex�o
  Property WelcomeMessage        : String                     Read vWelcomeMessage     Write vWelcomeMessage;    //Welcome Message Event
  Property Proxy                 : Boolean                    Read vProxy              Write vProxy;             //Diz se tem servidor Proxy
  Property Compression           : Boolean                    Read vCompression        Write vCompression;       //Compress�o de Dados
  Property DataRoute             : String                     Read vDataRoute          Write vDataRoute;
  Property RequestTimeOut        : Integer                    Read vTimeOut            Write vTimeOut;           //Timeout da Requisi��o
  Property ConnectTimeOut        : Integer                    Read vConnectTimeOut     Write vConnectTimeOut;
  Property ServerContext         : String                     Read vServerContext      Write vServerContext;
  Property AuthenticationOptions : TRDWClientAuthOptionParams Read vAuthOptionParams   Write vAuthOptionParams;
  Property CriptOptions          : TCripto                    Read vCripto             Write vCripto;
  Property ProxyOptions          : TProxyOptions              Read vProxyOptions       Write vProxyOptions;      //Se tem Proxy diz quais as op��es
  Property PoolerService         : String                     Read vRestWebService     Write vRestWebService;    //Host do WebService REST
  Property PoolerURL             : String                     Read vRestURL            Write vRestURL;           //URL do WebService REST
  Property PoolerPort            : Integer                    Read vPoolerPort         Write SetPoolerPort;      //A Porta do Pooler do DataSet
  Property PoolerPrefix          : String                     Read vPoolerPrefix       Write vPoolerPrefix;      //Prefixo do WebService REST
  Property Poolers               : TStringList                Read vPoolerList;
  Property HandleRedirects       : Boolean                    Read vHandleRedirects    Write vHandleRedirects;
  Property RedirectMaximum       : Integer                    Read vRedirectMaximum    Write vRedirectMaximum;
  Property AccessTag             : String                     Read vAccessTag          Write vAccessTag;
  Property Encoding              : TEncodeSelect              Read vEncoding           Write vEncoding;          //Encoding da string
  Property UserAgent             : String                     Read vUserAgent          Write vUserAgent;
  Property PoolerNotFoundMessage : String                     Read vPoolerNotFoundMessage Write vPoolerNotFoundMessage;
  Property TypeRequest           : TTypeRequest               Read vTypeRequest        Write vTypeRequest       Default trHttp;
 End;

Type
 PRESTDWValueKey = ^TRESTDWValueKey;
 TRESTDWValueKey = Class
 Private
  vKeyname             : String;
  vValue               : Variant;
  vIsStream,
  vIsNull              : Boolean;
  vObjectValue         : TObjectValue;
  vStreamValue         : TMemoryStream;
 Public
  Constructor Create;
  Property Keyname     : String       Read vKeyname     Write vKeyname;
  Property Value       : Variant      Read vValue       Write vValue;
  Property IsStream    : Boolean      Read vIsStream    Write vIsStream;
  Property IsNull      : Boolean      Read vIsNull      Write vIsNull;
  Property ObjectValue : TObjectValue Read vObjectValue Write vObjectValue;
End;

Type
 TRESTDWValueKeys = Class(TList)
 Private
 Private
  Function    GetRec     (Index       : Integer) : TRESTDWValueKey;  Overload;
  Procedure   PutRec     (Index       : Integer;
                          Item        : TRESTDWValueKey);            Overload;
  Function    GetRecName(Index        : String)  : TRESTDWValueKey;  Overload;
  Procedure   PutRecName(Index        : String;
                         Item         : TRESTDWValueKey);            Overload;
  Procedure   ClearList;
 Public
  Constructor Create;
  Destructor  Destroy; Override;
  Function    BuildArrayValues        : TArrayData;
  Function    BuildKeyNames           : String;
  Function    Add        (Item        : TRESTDWValueKey) : Integer;  Overload;
  Procedure   Delete     (Index       : Integer);  Overload;
  Procedure   Delete     (Index       : String);   Overload;
  Property    Items      [Index       : Integer] : TRESTDWValueKey Read GetRec     Write PutRec; Default;
  Property    ItemsByName[Index       : String ] : TRESTDWValueKey Read GetRecName Write PutRecName;
End;

Type
 TRESTDWDriver    = Class(TDWComponent)
 Private
  vStrsTrim,
  vStrsEmpty2Null,
  vStrsTrim2Len,
  vEncodeStrings,
  vCompression         : Boolean;
  vEncoding            : TEncodeSelect;
  vCommitRecords       : Integer;
  {$IFDEF FPC}
  vDatabaseCharSet     : TDatabaseCharSet;
  {$ENDIF}
  vParamCreate         : Boolean;
  vOnPrepareConnection : TOnPrepareConnection;
  vOnTableBeforeOpen   : TOnTableBeforeOpen;
  vOnQueryBeforeOpen   : TOnQueryBeforeOpen;
  vOnQueryException    : TOnQueryException;
 Public
  Function  ConnectionSet                                   : Boolean;         Virtual;Abstract;
  Function  GetGenID                  (Query                : TComponent;
                                       GenName              : String): Integer;Virtual;Abstract;
  Constructor Create                  (AOwner               : TComponent);Override; //Cria o Componente
  Function ApplyUpdates               (Massive,
                                       SQL                  : String;
                                       Params               : TDWParams;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var RowsAffected     : Integer) : TJSONValue;     Virtual;Abstract;
  Function ApplyUpdates_MassiveCache  (MassiveCache         : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String) : TJSONValue;     Virtual;Abstract;
  Function ProcessMassiveSQLCache     (MassiveSQLCache      : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String) : TJSONValue;     Virtual;Abstract;
  Function ApplyUpdatesTB             (Massive              : String;
                                       Params               : TDWParams;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var RowsAffected     : Integer) : TJSONValue;     Virtual;Abstract;
  Function ApplyUpdates_MassiveCacheTB(MassiveCache         : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String) : TJSONValue;     Virtual;Abstract;
  Function ExecuteCommandTB           (Tablename            : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var BinaryBlob       : TMemoryStream;
                                       Var RowsAffected     : Integer;
                                       BinaryEvent          : Boolean = False;
                                       MetaData             : Boolean = False;
                                       BinaryCompatibleMode : Boolean = False) : String;Overload;Virtual;Abstract;
  Function ExecuteCommandTB           (Tablename            : String;
                                       Params               : TDWParams;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var BinaryBlob       : TMemoryStream;
                                       Var RowsAffected     : Integer;
                                       BinaryEvent          : Boolean = False;
                                       MetaData             : Boolean = False;
                                       BinaryCompatibleMode : Boolean = False) : String;Overload;Virtual;Abstract;
  Function ExecuteCommand             (SQL                  : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var BinaryBlob       : TMemoryStream;
                                       Var RowsAffected     : Integer;
                                       Execute              : Boolean = False;
                                       BinaryEvent          : Boolean = False;
                                       MetaData             : Boolean = False;
                                       BinaryCompatibleMode : Boolean = False) : String;Overload;Virtual;Abstract;
  Function ExecuteCommand             (SQL                  : String;
                                       Params               : TDWParams;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var BinaryBlob       : TMemoryStream;
                                       Var RowsAffected     : Integer;
                                       Execute              : Boolean = False;
                                       BinaryEvent          : Boolean = False;
                                       MetaData             : Boolean = False;
                                       BinaryCompatibleMode : Boolean = False) : String;Overload;Virtual;Abstract;
  Function InsertMySQLReturnID        (SQL                  : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String)        : Integer;Overload;Virtual;Abstract;
  Function InsertMySQLReturnID        (SQL                  : String;
                                       Params               : TDWParams;
                                       Var Error            : Boolean;
                                       Var MessageError     : String)        : Integer;Overload;Virtual;Abstract;
  Procedure ExecuteProcedure          (ProcName             : String;
                                       Params               : TDWParams;
                                       Var Error            : Boolean;
                                       Var MessageError     : String);                  Virtual;Abstract;
  Procedure ExecuteProcedurePure      (ProcName             : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String);                  Virtual;Abstract;
  Function  OpenDatasets              (DatasetsLine         : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var BinaryBlob       : TMemoryStream) : TJSONValue; Virtual;Abstract;
  Procedure GetTableNames             (Var TableNames       : TStringList;
                                       Var Error            : Boolean;
                                       Var MessageError     : String);                  Virtual;Abstract;
  Procedure GetFieldNames             (TableName            : String;
                                       Var FieldNames       : TStringList;
                                       Var Error            : Boolean;
                                       Var MessageError     : String);                  Virtual;Abstract;
  Procedure GetKeyFieldNames          (TableName            : String;
                                       Var FieldNames       : TStringList;
                                       Var Error            : Boolean;
                                       Var MessageError     : String);                  Virtual;Abstract;
  Procedure GetProcNames              (Var ProcNames        : TStringList;
                                       Var Error            : Boolean;
                                       Var MessageError     : String);                  Virtual;Abstract;
  Procedure GetProcParams             (ProcName             : String;
                                       Var ParamNames       : TStringList;
                                       Var Error            : Boolean;
                                       Var MessageError     : String);                  Virtual;Abstract;
  Class Procedure CreateConnection    (Const ConnectionDefs : TConnectionDefs;
                                       Var Connection       : TObject);                 Virtual;Abstract;
  Procedure PrepareConnection         (Var ConnectionDefs   : TConnectionDefs);         Virtual;Abstract;
  Procedure Close;Virtual;abstract;
  Procedure BuildDatasetLine          (Var Query            : TDataset;
                                       Massivedataset       : TMassivedatasetBuffer;
                                       MassiveCache         : Boolean = False);
  Property StrsTrim                  : Boolean              Read vStrsTrim              Write vStrsTrim;
  Property StrsEmpty2Null            : Boolean              Read vStrsEmpty2Null        Write vStrsEmpty2Null;
  Property StrsTrim2Len              : Boolean              Read vStrsTrim2Len          Write vStrsTrim2Len;
  Property Compression               : Boolean              Read vCompression           Write vCompression;
  Property EncodeStringsJSON         : Boolean              Read vEncodeStrings         Write vEncodeStrings;
  Property Encoding                  : TEncodeSelect        Read vEncoding              Write vEncoding;
  property ParamCreate               : Boolean              Read vParamCreate           Write vParamCreate;
 Published
 {$IFDEF FPC}
  Property DatabaseCharSet           : TDatabaseCharSet     Read vDatabaseCharSet       Write vDatabaseCharSet;
 {$ENDIF}
  Property CommitRecords             : Integer              Read vCommitRecords         Write vCommitRecords;
  Property OnPrepareConnection       : TOnPrepareConnection Read vOnPrepareConnection   Write vOnPrepareConnection;
  Property OnTableBeforeOpen         : TOnTableBeforeOpen   Read vOnTableBeforeOpen     Write vOnTableBeforeOpen;
  Property OnQueryBeforeOpen         : TOnQueryBeforeOpen   Read vOnQueryBeforeOpen     Write vOnQueryBeforeOpen;
  Property OnQueryException          : TOnQueryException    Read vOnQueryException      Write vOnQueryException;
End;

//PoolerDB Control
Type
 TRESTDWPoolerDBP = ^TDWComponent;
 TRESTDWPoolerDB  = Class(TDWComponent)
 Private
  FLock          : TCriticalSection;
  vRESTDriver    : TRESTDWDriver;
  vActive,
  vStrsTrim,
  vStrsEmpty2Null,
  vStrsTrim2Len,
  vCompression   : Boolean;
  vEncoding      : TEncodeSelect;
  vAccessTag,
  vMessagePoolerOff : String;
  vParamCreate   : Boolean;
  Procedure SetConnection(Value : TRESTDWDriver);
  Function  GetConnection  : TRESTDWDriver;
 protected
  procedure Notification(AComponent: TComponent; Operation: TOperation); override;
 Public
  Function ExecuteCommand(SQL              : String;
                          Var Error        : Boolean;
                          Var MessageError : String;
                          Var BinaryBlob   : TMemoryStream;
                          Var RowsAffected : Integer;
                          Execute          : Boolean = False) : String;Overload;
  Function ExecuteCommand(SQL              : String;
                          Params           : TDWParams;
                          Var Error        : Boolean;
                          Var MessageError : String;
                          Var BinaryBlob   : TMemoryStream;
                          Var RowsAffected : Integer;
                          Execute          : Boolean = False) : String;Overload;
  Function InsertMySQLReturnID(SQL              : String;
                               Var Error        : Boolean;
                               Var MessageError : String) : Integer;Overload;
  Function InsertMySQLReturnID(SQL              : String;
                               Params           : TDWParams;
                               Var Error        : Boolean;
                               Var MessageError : String) : Integer;Overload;
  Procedure ExecuteProcedure  (ProcName         : String;
                               Params           : TDWParams;
                               Var Error        : Boolean;
                               Var MessageError : String);
  Procedure ExecuteProcedurePure(ProcName         : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String);
  Constructor Create(AOwner : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                     //Destroy a Classe
 Published
  Property    RESTDriver       : TRESTDWDriver Read GetConnection     Write SetConnection;
  Property    Compression      : Boolean       Read vCompression      Write vCompression;
  Property    Encoding         : TEncodeSelect Read vEncoding         Write vEncoding;
  Property    StrsTrim         : Boolean       Read vStrsTrim         Write vStrsTrim;
  Property    StrsEmpty2Null   : Boolean       Read vStrsEmpty2Null   Write vStrsEmpty2Null;
  Property    StrsTrim2Len     : Boolean       Read vStrsTrim2Len     Write vStrsTrim2Len;
  Property    Active           : Boolean       Read vActive           Write vActive;
  Property    PoolerOffMessage : String        Read vMessagePoolerOff Write vMessagePoolerOff;
  Property    AccessTag        : String        Read vAccessTag        Write vAccessTag;
  Property    ParamCreate      : Boolean       Read vParamCreate      Write vParamCreate;
End;

 Function GetDWParams(Params : TParams; Encondig : TEncodeSelect) : TDWParams;

implementation

Uses uDWJSONInterface;

Function GetDWParams(Params : TParams; Encondig : TEncodeSelect) : TDWParams;
Var
 I         : Integer;
 JSONParam : TJSONParam;
Begin
 Result := Nil;
 If Params <> Nil Then
  Begin
   If Params.Count > 0 Then
    Begin
     Result := TDWParams.Create;
     Result.Encoding := Encondig;
     For I := 0 To Params.Count -1 Do
      Begin
       JSONParam         := TJSONParam.Create(Result.Encoding);
       JSONParam.ParamName := Params[I].Name;
       JSONParam.Encoded   := True;
       JSONParam.LoadFromParam(Params[I]);
       Result.Add(JSONParam);
      End;
    End;
  End;
End;

Constructor TRESTDWBatchMove.Create(AOwner : TComponent);
Begin
 Inherited;
 vDestConnections       := TListDefConnections.Create(Self, TRESTDWConnectionServer);
 vSourceConnection      := TRESTDWConnectionParams.Create;
 vRESTDWBatchFieldsDefs := TRESTDWBatchFieldsDefs.Create(Self, TRESTDWBatchFieldItem);
 vCommitOnRecs          := 100;
 vSourceClient          := TRESTDWClientSQL.Create(Nil);
 vDestClient            := TRESTDWClientSQL.Create(Nil);
 vRESTDWProcessSide     := psClient;
End;

Destructor TRESTDWBatchMove.Destroy;
Begin
 FreeAndNil(vSourceClient);
 FreeAndNil(vDestClient);
 FreeAndNil(vDestConnections);
 FreeAndNil(vSourceConnection);
 FreeAndNil(vRESTDWBatchFieldsDefs);
 Inherited;
End;

Function   TRESTDWBatchMove.Start(Source : TRESTDWClientSQL;
                                  Action : TRESTDWBatchMoveActionType = bmat_InsertUpdate) : Integer;
Begin
 Result := 0;

End;

Function   TRESTDWBatchMove.Start(Action : TRESTDWBatchMoveActionType = bmat_InsertUpdate) : Integer;
Begin
 Result := 0;

End;

Function  TRESTDWConnectionServer.GetDisplayName             : String;
Begin
 Result := vListName;
End;

Procedure TRESTDWConnectionServer.SetDisplayName(Const Value : String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create(cInvalidConnectionName)
 Else
  Begin
   vListName := Trim(Value);
   Inherited;
  End;
End;

Procedure TAutoCheckData.Assign(Source: TPersistent);
Var
 Src : TAutoCheckData;
Begin
 If Source is TAutoCheckData Then
  Begin
   Src        := TAutoCheckData(Source);
   vAutoCheck := Src.AutoCheck;
   vInTime    := Src.InTime;
//   vEvent     := Src.OnEventTimer;
  End
 Else
  Inherited;
End;

Procedure TProxyOptions.Assign(Source: TPersistent);
Var
 Src : TProxyOptions;
Begin
 If Source is TProxyOptions Then
  Begin
   Src := TProxyOptions(Source);
   vServer := Src.Server;
   vLogin  := Src.Login;
   vPassword := Src.Password;
   vPort     := Src.Port;
  End
 Else
  Inherited;
End;

Function  TRESTDWPoolerDB.GetConnection : TRESTDWDriver;
Begin
 Result := vRESTDriver;
End;

Procedure TRESTDWPoolerDB.SetConnection(Value : TRESTDWDriver);
Begin
  //Alexandre Magno - 25/11/2018
  if vRESTDriver <> Value then
    vRESTDriver := Value;
  if vRESTDriver <> nil then
    vRESTDriver.FreeNotification(Self);
End;

Function TRESTDWPoolerDB.InsertMySQLReturnID(SQL              : String;
                                           Var Error        : Boolean;
                                           Var MessageError : String) : Integer;
Begin
 Result := -1;
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.vStrsTrim          := vStrsTrim;
   vRESTDriver.vStrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.vStrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.vCompression       := vCompression;
   vRESTDriver.vEncoding          := vEncoding;
   vRESTDriver.vParamCreate       := vParamCreate;
   Result := vRESTDriver.InsertMySQLReturnID(SQL, Error, MessageError);
  End
 Else
  Begin
   Error        := True;
   MessageError := 'Selected Pooler Does Not Have a Driver Set';
  End;
End;

Function TRESTDWPoolerDB.InsertMySQLReturnID(SQL              : String;
                                           Params           : TDWParams;
                                           Var Error        : Boolean;
                                           Var MessageError : String) : Integer;
Begin
 Result := -1;
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.vStrsTrim          := vStrsTrim;
   vRESTDriver.vStrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.vStrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.vCompression       := vCompression;
   vRESTDriver.vEncoding          := vEncoding;
   vRESTDriver.vParamCreate       := vParamCreate;
   Result := vRESTDriver.InsertMySQLReturnID(SQL, Params, Error, MessageError);
  End
 Else
  Begin
   Error        := True;
   MessageError := 'Selected Pooler Does Not Have a Driver Set';
  End;
End;

procedure TRESTDWPoolerDB.Notification(AComponent: TComponent; Operation: TOperation);
begin
  //Alexandre Magno - 25/11/2018
  if (Operation = opRemove) and (AComponent = vRESTDriver) then
  begin
    vRESTDriver := nil;
  end;
  inherited Notification(AComponent, Operation);
end;

Function TRESTDWPoolerDB.ExecuteCommand(SQL              : String;
                                        Var Error        : Boolean;
                                        Var MessageError : String;
                                        Var BinaryBlob   : TMemoryStream;
                                        Var RowsAffected : Integer;
                                        Execute          : Boolean = False) : String;
Begin
  Result := '';
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.vStrsTrim          := vStrsTrim;
   vRESTDriver.vStrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.vStrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.vCompression       := vCompression;
   vRESTDriver.vEncoding          := vEncoding;
   vRESTDriver.vParamCreate       := vParamCreate;
   Result := vRESTDriver.ExecuteCommand(SQL, Error, MessageError, BinaryBlob, RowsAffected, Execute);
  End
 Else
  Begin
   Error        := True;
   MessageError := 'Selected Pooler Does Not Have a Driver Set';
  End;
End;

Function TRESTDWPoolerDB.ExecuteCommand(SQL              : String;
                                        Params           : TDWParams;
                                        Var Error        : Boolean;
                                        Var MessageError : String;
                                        Var BinaryBlob   : TMemoryStream;
                                        Var RowsAffected : Integer;
                                        Execute          : Boolean = False) : String;
Begin
 Result := '';
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.vStrsTrim          := vStrsTrim;
   vRESTDriver.vStrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.vStrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.vCompression       := vCompression;
   vRESTDriver.vEncoding          := vEncoding;
   vRESTDriver.vParamCreate       := vParamCreate;
   Result := vRESTDriver.ExecuteCommand(SQL, Params, Error, MessageError, BinaryBlob, RowsAffected, Execute);
  End
 Else
  Begin
   Error        := True;
   MessageError := 'Selected Pooler Does Not Have a Driver Set';
  End;
End;

Procedure TRESTDWPoolerDB.ExecuteProcedure(ProcName         : String;
                                         Params           : TDWParams;
                                         Var Error        : Boolean;
                                         Var MessageError : String);
Begin
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.vStrsTrim          := vStrsTrim;
   vRESTDriver.vStrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.vStrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.vCompression       := vCompression;
   vRESTDriver.vEncoding          := vEncoding;
   vRESTDriver.vParamCreate       := vParamCreate;
   vRESTDriver.ExecuteProcedure(ProcName, Params, Error, MessageError);
  End
 Else
  Begin
   Error        := True;
   MessageError := 'Selected Pooler Does Not Have a Driver Set';
  End;
End;

Procedure TRESTDWPoolerDB.ExecuteProcedurePure(ProcName         : String;
                                             Var Error        : Boolean;
                                             Var MessageError : String);
Begin
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.vStrsTrim          := vStrsTrim;
   vRESTDriver.vStrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.vStrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.vCompression       := vCompression;
   vRESTDriver.vEncoding          := vEncoding;
   vRESTDriver.vParamCreate       := vParamCreate;
   vRESTDriver.ExecuteProcedurePure(ProcName, Error, MessageError);
  End
 Else
  Begin
   Error        := True;
   MessageError := 'Selected Pooler Does Not Have a Driver Set';
  End;
End;

Constructor TRESTDWPoolerDB.Create(AOwner : TComponent);
Begin
 Inherited;
 FLock             := TCriticalSection.Create;
 FLock.Acquire;
 vCompression      := True;
 vStrsTrim         := False;
 vStrsEmpty2Null   := False;
 vStrsTrim2Len     := True;
 vActive           := True;
 {$IFNDEF FPC}
 {$IF CompilerVersion > 21}
  vEncoding         := esUtf8;
 {$ELSE}
  vEncoding         := esAscii;
 {$IFEND}
 {$ELSE}
  vEncoding         := esUtf8;
 {$ENDIF}
 vMessagePoolerOff := 'RESTPooler not active.';
 vParamCreate      := True;
End;

Destructor  TRESTDWPoolerDB.Destroy;
Begin
 If Assigned(FLock) Then
  Begin
   {.$IFNDEF POSIX}
   FLock.Release;
   {.$ENDIF}
   FreeAndNil(FLock);
  End;
 Inherited;
End;

Constructor TAutoCheckData.Create;
Begin
 Inherited;
 vAutoCheck := False;
 vInTime    := 1000;
 vEvent     := Nil;
 Timer      := Nil;
 FLock      := TCriticalSection.Create;
End;

Destructor  TAutoCheckData.Destroy;
Begin
 SetState(False);
 FLock.Release;
 FLock.Free;
 Inherited;
End;

Procedure  TAutoCheckData.SetState(Value : Boolean);
Begin
 vAutoCheck := Value;
 If vAutoCheck Then
  Begin
   If Timer <> Nil Then
    Begin
     Timer.Terminate;
     Timer := Nil;
    End;
   Timer              := TTimerData.Create(vInTime, FLock);
   Timer.OnEventTimer := vEvent;
  End
 Else
  Begin
   If Timer <> Nil Then
    Begin
     Timer.Terminate;
     Timer := Nil;
    End;
  End;
End;

Procedure  TAutoCheckData.SetInTime(Value : Integer);
Begin
 vInTime    := Value;
 SetState(vAutoCheck);
End;

Procedure  TAutoCheckData.SetEventTimer(Value : TOnEventTimer);
Begin
 vEvent := Value;
 SetState(vAutoCheck);
End;

Constructor TTimerData.Create(AValue: Integer; ALock: TCriticalSection);
Begin
 FValue := AValue;
 FLock := ALock;
 Inherited Create(False);
End;

Procedure TTimerData.Execute;
Begin
 While Not Terminated do
  Begin
   Sleep(FValue);
   If Assigned(FLock) then
    FLock.Acquire;
   if Assigned(vEvent) then
    vEvent;
   If Assigned(FLock) then
    FLock.Release;
  End;
End;

Constructor TProxyOptions.Create;
Begin
 Inherited;
 vServer   := '';
 vLogin    := vServer;
 vPassword := vLogin;
 vPort     := 8888;
End;

{
Procedure TRESTDWPoolerList.SetConnectionOptions(Var Value : TRESTClientPooler);
Begin
 Value                   := TRESTClientPooler.Create(Nil);
 Value.TypeRequest       := trHttp;
 Value.Host              := vRestWebService;
 Value.Port              := vPoolerPort;
 Value.UrlPath           := vRestURL;
 Value.UserName          := vLogin;
 Value.Password          := vPassword;
 if vProxy then
  Begin
   Value.ProxyOptions.ProxyServer   := vProxyOptions.vServer;
   Value.ProxyOptions.ProxyPort     := vProxyOptions.vPort;
   Value.ProxyOptions.ProxyUsername := vProxyOptions.vLogin;
   Value.ProxyOptions.ProxyPassword := vProxyOptions.vPassword;
  End
 Else
  Begin
   Value.ProxyOptions.ProxyServer   := '';
   Value.ProxyOptions.ProxyPort     := 0;
   Value.ProxyOptions.ProxyUsername := '';
   Value.ProxyOptions.ProxyPassword := '';
  End;
End;
}

Procedure TRESTDWDataBase.SetOnStatus(Value : TOnStatus);
Begin
 {$IFDEF FPC}
  vOnStatus            := Value;
 {$ELSE}
  vOnStatus            := Value;
 {$ENDIF}
End;

Function  TRESTDWDataBase.RenewToken(Var PoolerMethodClient : TDWPoolerMethodClient;
                                     Var Params             : TDWParams;
                                     Var Error              : Boolean;
                                     Var MessageError       : String) : String;
Var
 I                    : Integer;
 vTempSend            : String;
 vConnection          : TDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPooler;
 Procedure DestroyComponents;
 Begin
  If Assigned(RESTClientPoolerExec) Then
   FreeAndNil(RESTClientPoolerExec);
 End;
Begin
 //Atualiza��o de Token na autentica��o
 Result                       := '';
 RESTClientPoolerExec         := Nil;
 vConnection                  := TDWPoolerMethodClient.Create(Nil);
 PoolerMethodClient           := vConnection;
 vConnection.PoolerNotFoundMessage := PoolerNotFoundMessage;
 vConnection.HandleRedirects  := vHandleRedirects;
 vConnection.RedirectMaximum  := vRedirectMaximum;
 vConnection.UserAgent        := vUserAgent;
 vConnection.TypeRequest      := vTypeRequest;
 vConnection.WelcomeMessage   := vWelcomeMessage;
 vConnection.Host             := vRestWebService;
 vConnection.Port             := vPoolerPort;
 vConnection.Compression      := vCompression;
 vConnection.EncodeStrings    := EncodeStrings;
 vConnection.Encoding         := Encoding;
 vConnection.AccessTag        := vAccessTag;
 vConnection.CriptOptions.Use := vCripto.Use;
 vConnection.CriptOptions.Key := vCripto.Key;
 vConnection.DataRoute        := DataRoute;
 vConnection.ServerContext    := ServerContext;
 vConnection.AuthenticationOptions.Assign(AuthenticationOptions);
 {$IFNDEF FPC}
  vConnection.Encoding      := vEncoding;
 {$ELSE}
  vConnection.DatabaseCharSet := csUndefined;
 {$ENDIF}
 If vAuthOptionParams.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
  Begin
   Try
    Try
     Case vAuthOptionParams.AuthorizationOption Of
      rdwAOBearer : Begin
                     vTempSend := vConnection.GetToken(vRestURL,     '',
                                                       Params,       Error,
                                                       MessageError, vTimeOut,
                                                       vConnectTimeOut, Nil,
                                                       RESTClientPoolerExec);
                     vTempSend                                           := GettokenValue(vTempSend);
                     TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                    End;
      rdwAOToken  : Begin
                     vTempSend := vConnection.GetToken(vRestURL,        '',
                                                       Params,          Error,
                                                       MessageError,    vTimeOut,
                                                       vConnectTimeOut, Nil,
                                                       RESTClientPoolerExec);
                     vTempSend                                          := GettokenValue(vTempSend);
                     TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                    End;
     End;
     Result      := vTempSend;
     If csDesigning in ComponentState Then
      If Error Then Raise Exception.Create(PChar(cAuthenticationError));
     If Error Then
      Begin
       Result      := '';
       If vFailOver Then
        Begin
         If vFailOverConnections.Count = 0 Then
          Begin
           Result      := '';
           vMyIP       := '';
           If csDesigning in ComponentState Then
            Raise Exception.Create(PChar(cInvalidConnection));
           If Assigned(vOnEventConnection) Then
            vOnEventConnection(False, cInvalidConnection)
           Else
            Raise Exception.Create(cInvalidConnection);
          End
         Else
          Begin
           For I := 0 To vFailOverConnections.Count -1 Do
            Begin
             If I = 0 Then
              Begin
               If ((vFailOverConnections[I].vTypeRequest    = vConnection.TypeRequest)    And
                   (vFailOverConnections[I].vWelcomeMessage = vConnection.WelcomeMessage) And
                   (vFailOverConnections[I].vRestWebService = vConnection.Host)           And
                   (vFailOverConnections[I].vPoolerPort     = vConnection.Port)           And
                   (vFailOverConnections[I].vCompression    = vConnection.Compression)    And
                   (vFailOverConnections[I].EncodeStrings   = vConnection.EncodeStrings)  And
                   (vFailOverConnections[I].Encoding        = vConnection.Encoding)       And
                   (vFailOverConnections[I].vAccessTag      = vConnection.AccessTag)      And
                   (vFailOverConnections[I].vRestPooler     = vRestPooler)                And
                   (vFailOverConnections[I].vRestURL        = vRestURL))                  Or
                 (Not (vFailOverConnections[I].Active))                                   Then
               Continue;
              End;
             If Assigned(vOnFailOverExecute) Then
              vOnFailOverExecute(vFailOverConnections[I]);
             If Not Assigned(RESTClientPoolerExec) Then
              RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
             RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
             ReconfigureConnection(vConnection,
                                   RESTClientPoolerExec,
                                   vFailOverConnections[I].vTypeRequest,
                                   vFailOverConnections[I].vWelcomeMessage,
                                   vFailOverConnections[I].vRestWebService,
                                   vFailOverConnections[I].vPoolerPort,
                                   vFailOverConnections[I].vCompression,
                                   vFailOverConnections[I].EncodeStrings,
                                   vFailOverConnections[I].Encoding,
                                   vFailOverConnections[I].vAccessTag,
                                   vFailOverConnections[I].AuthenticationOptions);
             Try
              Case vAuthOptionParams.AuthorizationOption Of
               rdwAOBearer : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vRestURL, '',
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut,vConnectTimeOut,
                                                                Nil, RESTClientPoolerExec);
                              vTempSend                                          := GettokenValue(vTempSend);
                              TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
               rdwAOToken  : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vRestURL, '',
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut,vConnectTimeOut,
                                                                Nil,          RESTClientPoolerExec);
                              vTempSend                                         := GettokenValue(vTempSend);
                              TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
              End;
              Result      := vTempSend;
              If Not(Error) Then
               Begin
                If vFailOverReplaceDefaults Then
                 Begin
                  vTypeRequest      := vConnection.TypeRequest;
                  vWelcomeMessage   := vConnection.WelcomeMessage;
                  vRestWebService   := vConnection.Host;
                  vPoolerPort       := vConnection.Port;
                  vCompression      := vConnection.Compression;
                  vEncodeStrings    := vConnection.EncodeStrings;
                  vEncoding         := vConnection.Encoding;
                  vAccessTag        := vConnection.AccessTag;
                  vRestURL          := vFailOverConnections[I].vRestURL;
                  vRestPooler       := vFailOverConnections[I].vRestPooler;
                  vTimeOut          := vFailOverConnections[I].vTimeOut;
                  vConnectTimeOut   := vFailOverConnections[I].vConnectTimeOut;
                  vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
                 End;
               End;
              If csDesigning in ComponentState Then
               If Error Then
                Raise Exception.Create(PChar(cAuthenticationError))
               Else
                Break;
             Except
              On E : Exception do
               Begin
                If Assigned(vOnFailOverError) Then
                 vOnFailOverError(vFailOverConnections[I], E.Message);
               End;
             End;
            End;
          End;
        End
       Else
        Begin
         If Assigned(vOnEventConnection) Then
          vOnEventConnection(False, cAuthenticationError);
        End;
      End;
    Except
     On E : Exception do
      Begin
       DestroyComponents;
       If vFailOver Then
        Begin
         If vFailOverConnections.Count > 0 Then
          Begin
           If Assigned(vFailOverConnections) Then
           For I := 0 To vFailOverConnections.Count -1 Do
            Begin
             DestroyComponents;
             If I = 0 Then
              Begin
               If ((vFailOverConnections[I].vTypeRequest    = vConnection.TypeRequest)    And
                   (vFailOverConnections[I].vWelcomeMessage = vConnection.WelcomeMessage) And
                   (vFailOverConnections[I].vRestWebService = vConnection.Host)           And
                   (vFailOverConnections[I].vPoolerPort     = vConnection.Port)           And
                   (vFailOverConnections[I].vCompression    = vConnection.Compression)    And
                   (vFailOverConnections[I].EncodeStrings   = vConnection.EncodeStrings)  And
                   (vFailOverConnections[I].Encoding        = vConnection.Encoding)       And
                   (vFailOverConnections[I].vAccessTag      = vConnection.AccessTag)      And
                   (vFailOverConnections[I].vRestPooler     = vRestPooler)                And
                   (vFailOverConnections[I].vRestURL        = vRestURL))                  Or
                   (Not (vFailOverConnections[I].Active))                                 Then
               Continue;
              End;
             If Assigned(vOnFailOverExecute) Then
              vOnFailOverExecute(vFailOverConnections[I]);
             If Not Assigned(RESTClientPoolerExec) Then
              RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
             RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
             ReconfigureConnection(vConnection,
                                   RESTClientPoolerExec,
                                   vFailOverConnections[I].vTypeRequest,
                                   vFailOverConnections[I].vWelcomeMessage,
                                   vFailOverConnections[I].vRestWebService,
                                   vFailOverConnections[I].vPoolerPort,
                                   vFailOverConnections[I].vCompression,
                                   vFailOverConnections[I].EncodeStrings,
                                   vFailOverConnections[I].Encoding,
                                   vFailOverConnections[I].vAccessTag,
                                   vFailOverConnections[I].AuthenticationOptions);
             Try
              Case vAuthOptionParams.AuthorizationOption Of
               rdwAOBearer : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vRestURL, '',
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut,vConnectTimeOut,
                                                                Nil, RESTClientPoolerExec);
                              vTempSend                                          := GettokenValue(vTempSend);
                              TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
               rdwAOToken  : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vRestURL, '',
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut,vConnectTimeOut,
                                                                Nil, RESTClientPoolerExec);
                              vTempSend                                         := GettokenValue(vTempSend);
                              TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
              End;
              Result      := vTempSend;
              If Not(Error) Then
               Begin
                If vFailOverReplaceDefaults Then
                 Begin
                  vTypeRequest      := vConnection.TypeRequest;
                  vWelcomeMessage   := vConnection.WelcomeMessage;
                  vRestWebService   := vConnection.Host;
                  vPoolerPort       := vConnection.Port;
                  vCompression      := vConnection.Compression;
                  vEncodeStrings    := vConnection.EncodeStrings;
                  vEncoding         := vConnection.Encoding;
                  vAccessTag        := vConnection.AccessTag;
                  vRestURL          := vFailOverConnections[I].vRestURL;
                  vRestPooler       := vFailOverConnections[I].vRestPooler;
                  vTimeOut          := vFailOverConnections[I].vTimeOut;
                  vConnectTimeOut   := vFailOverConnections[I].vConnectTimeOut;
                  vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
                 End;
               End;
              If csDesigning in ComponentState Then
               If Error Then
                Raise Exception.Create(PChar(cAuthenticationError))
               Else
                Break;
             Except
              On E : Exception do
               Begin
                If Assigned(vOnFailOverError) Then
                 vOnFailOverError(vFailOverConnections[I], E.Message);
               End;
             End;
            End;
          End
         Else
          Begin
           Result      := '';
           If csDesigning in ComponentState Then
            Raise Exception.Create(PChar(E.Message));
           If Assigned(vOnEventConnection) Then
            vOnEventConnection(False, E.Message)
           Else
            Raise Exception.Create(E.Message);
          End;
        End
       Else
        Begin
         Result      := '';
         If csDesigning in ComponentState Then
          Raise Exception.Create(PChar(E.Message));
         If Assigned(vOnEventConnection) Then
          vOnEventConnection(False, E.Message)
         Else
          Raise Exception.Create(E.Message);
        End;
      End;
    End;
   Finally
    DestroyComponents;
    If vConnection <> Nil Then
     FreeAndNil(vConnection);
   End;
  End;
End;

Procedure TRESTDWDataBase.SetOnWork(Value : TOnWork);
Begin
 {$IFDEF FPC}
  vOnWork            := Value;
 {$ELSE}
  vOnWork            := Value;
 {$ENDIF}
End;

Procedure TRESTDWDataBase.SetOnWorkBegin(Value : TOnWorkBegin);
Begin
 {$IFDEF FPC}
  vOnWorkBegin            := Value;
 {$ELSE}
  vOnWorkBegin            := Value;
 {$ENDIF}
End;

Procedure TRESTDWDataBase.SetOnWorkEnd(Value : TOnWorkEnd);
Begin
 {$IFDEF FPC}
  vOnWorkEnd            := Value;
 {$ELSE}
  vOnWorkEnd            := Value;
 {$ENDIF}
End;

Procedure TRESTDWDataBase.ApplyUpdatesTB(Var PoolerMethodClient : TDWPoolerMethodClient;
                                         Massive                : TMassiveDatasetBuffer;
                                         Var Params             : TParams;
                                         Var Error,
                                         hBinaryRequest         : Boolean;
                                         Var MessageError       : String;
                                         Var Result             : TJSONValue;
                                         Var RowsAffected       : Integer;
                                         RESTClientPooler       : TRESTClientPooler = Nil);
Var
 vRESTConnectionDB    : TDWPoolerMethodClient;
 LDataSetList         : TJSONValue;
 DWParams             : TDWParams;
 SocketError          : Boolean;
 I                    : Integer;
 RESTClientPoolerExec : TRESTClientPooler;
 Function GetLineSQL(Value : TStringList) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  If Value <> Nil Then
   For I := 0 To Value.Count -1 do
    Begin
     If I = 0 then
      Result := Value[I]
     Else
      Result := Result + ' ' + Value[I];
    End;
 End;
 Procedure ParseParams;
 Var
  I : Integer;
 Begin
  If Params <> Nil Then
   For I := 0 To Params.Count -1 Do
    Begin
     If Params[I].DataType = ftUnknown then
      Params[I].DataType := ftString;
    End;
 End;
Begin
 SocketError := False;
 RESTClientPoolerExec := nil;
 if vRestPooler = '' then
  Exit;
 ParseParams;
 vRESTConnectionDB                 := TDWPoolerMethodClient.Create(Nil);
 PoolerMethodClient                := vRESTConnectionDB;
 vRESTConnectionDB.PoolerNotFoundMessage := PoolerNotFoundMessage;
 vRESTConnectionDB.AuthenticationOptions.Assign(vAuthOptionParams);
 vRESTConnectionDB.HandleRedirects := vHandleRedirects;
 vRESTConnectionDB.RedirectMaximum := vRedirectMaximum;
 vRESTConnectionDB.UserAgent       := vUserAgent;
 vRESTConnectionDB.WelcomeMessage := vWelcomeMessage;
 vRESTConnectionDB.Host           := vRestWebService;
 vRESTConnectionDB.Port           := vPoolerPort;
 vRESTConnectionDB.Compression    := vCompression;
 vRESTConnectionDB.TypeRequest    := VtypeRequest;
 vRESTConnectionDB.BinaryRequest  := hBinaryRequest;
 vRESTConnectionDB.Encoding       := vEncoding;
 vRESTConnectionDB.EncodeStrings  := EncodeStrings;
 vRESTConnectionDB.OnWork         := vOnWork;
 vRESTConnectionDB.OnWorkBegin    := vOnWorkBegin;
 vRESTConnectionDB.OnWorkEnd      := vOnWorkEnd;
 vRESTConnectionDB.OnStatus       := vOnStatus;
 vRESTConnectionDB.AccessTag      := vAccessTag;
 vRESTConnectionDB.CriptOptions.Use := VCripto.Use;
 vRESTConnectionDB.CriptOptions.Key := VCripto.Key;
 vRESTConnectionDB.DataRoute        := DataRoute;
 vRESTConnectionDB.ServerContext    := ServerContext;
 {$IFDEF FPC}
  vRESTConnectionDB.DatabaseCharSet := csUndefined;
 {$ENDIF}
 Try
  If Params.Count > 0 Then
   DWParams     := GetDWParams(Params, vEncoding)
  Else
   DWParams     := Nil;
  For I := 0 To 1 Do
   Begin
    LDataSetList := vRESTConnectionDB.ApplyUpdatesTB(Massive,      vRestPooler,
                                                     vRestURL,
                                                     DWParams,     Error,
                                                     MessageError, SocketError, RowsAffected, vTimeOut, vConnectTimeOut, '',
                                                     vClientConnectionDefs.vConnectionDefs,
                                                     RESTClientPooler);
    If Not(Error) or (MessageError <> cInvalidAuth) Then
     Break
    Else
     Begin
      Case AuthenticationOptions.AuthorizationOption Of
       rdwAOBearer : Begin
                      If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                           (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                         TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect;
                       End;
                     End;
       rdwAOToken  : Begin
                      If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                           (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                         TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect;
                       End;
                     End;
      End;
     End;
   End;
  If SocketError Then
   Begin
    If vFailOver Then
     Begin
      If Assigned(LDataSetList) Then
       FreeAndNil(LDataSetList);
      For I := 0 To vFailOverConnections.Count -1 Do
       Begin
        If I = 0 Then
         Begin
          If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
              (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
              (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
              (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
              (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
              (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
              (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
              (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
              (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
              (vFailOverConnections[I].vRestURL        = vRestURL))                        Or
             (Not (vFailOverConnections[I].Active))                                        Then
          Continue;
         End;
        If Assigned(vOnFailOverExecute) Then
         vOnFailOverExecute(vFailOverConnections[I]);
        If Not Assigned(RESTClientPoolerExec) Then
         RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
        RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
        ReconfigureConnection(vRESTConnectionDB,
                              RESTClientPoolerExec,
                              vFailOverConnections[I].vTypeRequest,
                              vFailOverConnections[I].vWelcomeMessage,
                              vFailOverConnections[I].vRestWebService,
                              vFailOverConnections[I].vPoolerPort,
                              vFailOverConnections[I].vCompression,
                              vFailOverConnections[I].EncodeStrings,
                              vFailOverConnections[I].Encoding,
                              vFailOverConnections[I].vAccessTag,
                              vFailOverConnections[I].AuthenticationOptions);
        LDataSetList := vRESTConnectionDB.ApplyUpdatesTB(Massive,
                                                         vFailOverConnections[I].vRestPooler,
                                                         vFailOverConnections[I].vRestURL,
                                                         DWParams,     Error,
                                                         MessageError, SocketError, RowsAffected, vTimeOut, vConnectTimeOut, '',
                                                         vClientConnectionDefs.vConnectionDefs,
                                                         RESTClientPooler);
        If Not SocketError Then
         Begin
          If vFailOverReplaceDefaults Then
           Begin
            vTypeRequest    := vRESTConnectionDB.TypeRequest;
            vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
            vRestWebService := vRESTConnectionDB.Host;
            vPoolerPort     := vRESTConnectionDB.Port;
            vCompression    := vRESTConnectionDB.Compression;
            vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
            vEncoding       := vRESTConnectionDB.Encoding;
            vAccessTag      := vRESTConnectionDB.AccessTag;
            vRestURL        := vFailOverConnections[I].vRestURL;
            vRestPooler     := vFailOverConnections[I].vRestPooler;
            vTimeOut        := vFailOverConnections[I].vTimeOut;
            vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
            vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
           End;
          Break;
         End;
       End;
     End;
   End;
  If Params.Count > 0 Then
   If DWParams <> Nil Then
    FreeAndNil(DWParams);
  If (LDataSetList <> Nil) Then
   Begin
    Result := Nil;
    Error  := Trim(MessageError) <> '';
    If (LDataSetList <> Nil) And
       (Not (Error))        Then
     Begin
      Try
       Result          := TJSONValue.Create;
       Result.Encoding := LDataSetList.Encoding;
       Result.SetValue(LDataSetList.value);
      Finally
      End;
     End;
    If (Not (Error)) Then
     Begin
      If Assigned(vOnEventConnection) Then
       vOnEventConnection(True, 'ApplyUpdates Ok');
     End
    Else
     Begin
      Error        := MessageError <> '';
      MessageError := MessageError;
      If Assigned(vOnEventConnection) then
       vOnEventConnection(False, MessageError);
     End;
   End
  Else
   Begin
    Error        := MessageError <> '';
    MessageError := MessageError;
    If Assigned(vOnEventConnection) Then
     vOnEventConnection(False, MessageError);
   End;
 Except
  On E : Exception do
   Begin
    Error        := E.Message <> '';
    MessageError := E.Message;
    If Assigned(vOnEventConnection) Then
     vOnEventConnection(False, E.Message);
   End;
 End;
 FreeAndNil(vRESTConnectionDB);
 If Assigned(LDataSetList) then
  FreeAndNil(LDataSetList);
End;

Procedure TRESTDWDataBase.ApplyUpdates(Var PoolerMethodClient : TDWPoolerMethodClient;
                                       Massive                : TMassiveDatasetBuffer;
                                       SQL                    : TStringList;
                                       Var Params             : TParams;
                                       Var Error,
                                       hBinaryRequest         : Boolean;
                                       Var MessageError       : String;
                                       Var Result             : TJSONValue;
                                       Var RowsAffected       : Integer;
                                       RESTClientPooler       : TRESTClientPooler = Nil);
Var
 vRESTConnectionDB    : TDWPoolerMethodClient;
 LDataSetList         : TJSONValue;
 DWParams             : TDWParams;
 SocketError          : Boolean;
 I                    : Integer;
 RESTClientPoolerExec : TRESTClientPooler;
 Function GetLineSQL(Value : TStringList) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  If Value <> Nil Then
   For I := 0 To Value.Count -1 do
    Begin
     If I = 0 then
      Result := Value[I]
     Else
      Result := Result + ' ' + Value[I];
    End;
 End;
 Procedure ParseParams;
 Var
  I : Integer;
 Begin
  If Params <> Nil Then
   For I := 0 To Params.Count -1 Do
    Begin
     If Params[I].DataType = ftUnknown then
      Params[I].DataType := ftString;
    End;
 End;
Begin
// Result := Nil;
 SocketError := False; //Leandro 11/08/2020
 RESTClientPoolerExec := nil; //Leandro 11/08/2020
 If vRestPooler = '' Then
  Exit;
 ParseParams;
 vRESTConnectionDB                 := TDWPoolerMethodClient.Create(Nil);
 PoolerMethodClient                := vRESTConnectionDB;
 vRESTConnectionDB.PoolerNotFoundMessage := PoolerNotFoundMessage;
 vRESTConnectionDB.AuthenticationOptions.Assign(vAuthOptionParams);
 vRESTConnectionDB.HandleRedirects := vHandleRedirects;
 vRESTConnectionDB.RedirectMaximum := vRedirectMaximum;
 vRESTConnectionDB.UserAgent       := vUserAgent;
 vRESTConnectionDB.WelcomeMessage  := vWelcomeMessage;
 vRESTConnectionDB.Host            := vRestWebService;
 vRESTConnectionDB.Port            := vPoolerPort;
 vRESTConnectionDB.Compression     := vCompression;
 vRESTConnectionDB.TypeRequest     := VtypeRequest;
 vRESTConnectionDB.BinaryRequest   := hBinaryRequest;
 vRESTConnectionDB.Encoding        := vEncoding;
 vRESTConnectionDB.EncodeStrings   := EncodeStrings;
 vRESTConnectionDB.OnWork          := vOnWork;
 vRESTConnectionDB.OnWorkBegin     := vOnWorkBegin;
 vRESTConnectionDB.OnWorkEnd       := vOnWorkEnd;
 vRESTConnectionDB.OnStatus        := vOnStatus;
 vRESTConnectionDB.AccessTag       := vAccessTag;
 vRESTConnectionDB.CriptOptions.Use := VCripto.Use;
 vRESTConnectionDB.CriptOptions.Key := VCripto.Key;
 vRESTConnectionDB.DataRoute        := DataRoute;
 vRESTConnectionDB.ServerContext    := ServerContext;
 {$IFDEF FPC}
  vRESTConnectionDB.DatabaseCharSet := csUndefined;
 {$ENDIF}
 Try
  If Params.Count > 0 Then
   DWParams     := GetDWParams(Params, vEncoding)
  Else
   DWParams     := Nil;
  For I := 0 To 1 Do
   Begin
    LDataSetList := vRESTConnectionDB.ApplyUpdates(Massive,      vRestPooler,
                                                   vRestURL,  GetLineSQL(SQL),
                                                   DWParams,     Error,
                                                   MessageError, SocketError, RowsAffected, vTimeOut, vConnectTimeOut, '',
                                                   vClientConnectionDefs.vConnectionDefs,
                                                   RESTClientPooler);
    If Not(Error) or (MessageError <> cInvalidAuth) Then
     Break
    Else
     Begin
      Case AuthenticationOptions.AuthorizationOption Of
       rdwAOBearer : Begin
                      If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                           (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                         TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect;
                       End;
                     End;
       rdwAOToken  : Begin
                      If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                           (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                         TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect;
                       End;
                     End;
      End;
     End;
   End;
  If SocketError Then
   Begin
    If vFailOver Then
     Begin
      If Assigned(LDataSetList) Then
       FreeAndNil(LDataSetList);
      For I := 0 To vFailOverConnections.Count -1 Do
       Begin
        If I = 0 Then
         Begin
          If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
              (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
              (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
              (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
              (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
              (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
              (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
              (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
              (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
              (vFailOverConnections[I].vRestURL        = vRestURL))                        Or
             (Not (vFailOverConnections[I].Active))                                        Then
          Continue;
         End;
        If Assigned(vOnFailOverExecute) Then
         vOnFailOverExecute(vFailOverConnections[I]);
        If Not Assigned(RESTClientPoolerExec) Then
         RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
        RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
        ReconfigureConnection(vRESTConnectionDB,
                              RESTClientPoolerExec,
                              vFailOverConnections[I].vTypeRequest,
                              vFailOverConnections[I].vWelcomeMessage,
                              vFailOverConnections[I].vRestWebService,
                              vFailOverConnections[I].vPoolerPort,
                              vFailOverConnections[I].vCompression,
                              vFailOverConnections[I].EncodeStrings,
                              vFailOverConnections[I].Encoding,
                              vFailOverConnections[I].vAccessTag,
                              vFailOverConnections[I].AuthenticationOptions);
        LDataSetList := vRESTConnectionDB.ApplyUpdates(Massive,
                                                       vFailOverConnections[I].vRestPooler,
                                                       vFailOverConnections[I].vRestURL,
                                                       GetLineSQL(SQL), DWParams,     Error,
                                                       MessageError, SocketError, RowsAffected, vTimeOut, vConnectTimeOut, '',
                                                       vClientConnectionDefs.vConnectionDefs,
                                                       RESTClientPooler);
        If Not SocketError Then
         Begin
          If vFailOverReplaceDefaults Then
           Begin
            vTypeRequest    := vRESTConnectionDB.TypeRequest;
            vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
            vRestWebService := vRESTConnectionDB.Host;
            vPoolerPort     := vRESTConnectionDB.Port;
            vCompression    := vRESTConnectionDB.Compression;
            vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
            vEncoding       := vRESTConnectionDB.Encoding;
            vAccessTag      := vRESTConnectionDB.AccessTag;
            vRestURL        := vFailOverConnections[I].vRestURL;
            vRestPooler     := vFailOverConnections[I].vRestPooler;
            vTimeOut        := vFailOverConnections[I].vTimeOut;
            vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
            vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
           End;
          Break;
         End;
       End;
     End;
   End;
  If Params.Count > 0 Then
   If DWParams <> Nil Then
    FreeAndNil(DWParams);
  If (LDataSetList <> Nil) Then
   Begin
    Result := Nil;
    Error  := Trim(MessageError) <> '';
    If (LDataSetList <> Nil) And
       (Not (Error))        Then
     Begin
      Try
       Result          := TJSONValue.Create;
       Result.Encoding := LDataSetList.Encoding;
       Result.SetValue(LDataSetList.value);
      Finally
      End;
     End;
    If (Not (Error)) Then
     Begin
      If Assigned(vOnEventConnection) Then
       vOnEventConnection(True, 'ApplyUpdates Ok');
     End
    Else
     Begin
      Error        := MessageError <> '';
      MessageError := MessageError;
      If Assigned(vOnEventConnection) then
       vOnEventConnection(False, MessageError);
     End;
   End
  Else
   Begin
    Error        := MessageError <> '';
    MessageError := MessageError;
    If Assigned(vOnEventConnection) Then
     vOnEventConnection(False, MessageError);
   End;
 Except
  On E : Exception do
   Begin
    Error        := E.Message <> '';
    MessageError := E.Message;
    If Assigned(vOnEventConnection) Then
     vOnEventConnection(False, E.Message);
   End;
 End;
 FreeAndNil(vRESTConnectionDB);
 If Assigned(LDataSetList) then
  FreeAndNil(LDataSetList);
End;

Function TRESTDWDataBase.InsertMySQLReturnID(Var PoolerMethodClient : TDWPoolerMethodClient;
                                             Var SQL                : TStringList;
                                             Var Params             : TParams;
                                             Var Error              : Boolean;
                                             Var MessageError       : String;
                                             RESTClientPooler       : TRESTClientPooler = Nil) : Integer;
Var
 vRESTConnectionDB    : TDWPoolerMethodClient;
 I, LDataSetList      : Integer;
 DWParams             : TDWParams;
 SocketError          : Boolean;
 RESTClientPoolerExec : TRESTClientPooler;
 Function GetLineSQL(Value : TStringList) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  If Value <> Nil Then
   For I := 0 To Value.Count -1 do
    Begin
     If I = 0 then
      Result := Value[I]
     Else
      Result := Result + ' ' + Value[I];
    End;
 End;
 Procedure ParseParams;
 Var
  I : Integer;
 Begin
  If Params <> Nil Then
   For I := 0 To Params.Count -1 Do
    Begin
     If Params[I].DataType = ftUnknown then
      Params[I].DataType := ftString;
    End;
 End;
Begin
 SocketError := False; //Leandro 11/08/2020
 RESTClientPoolerExec := nil; //Leandro 11/08/2020
 Result := -1;
 if vRestPooler = '' then
  Exit;
 ParseParams;
 vRESTConnectionDB                  := TDWPoolerMethodClient.Create(Nil);
 PoolerMethodClient                 := vRESTConnectionDB;
 vRESTConnectionDB.PoolerNotFoundMessage := PoolerNotFoundMessage;
 vRESTConnectionDB.UserAgent        := vUserAgent;
 vRESTConnectionDB.HandleRedirects  := vHandleRedirects;
 vRESTConnectionDB.RedirectMaximum  := vRedirectMaximum;
 vRESTConnectionDB.WelcomeMessage   := vWelcomeMessage;
 vRESTConnectionDB.Host             := vRestWebService;
 vRESTConnectionDB.Port             := vPoolerPort;
 vRESTConnectionDB.Compression      := vCompression;
 vRESTConnectionDB.TypeRequest      := VtypeRequest;
 vRESTConnectionDB.Encoding         := vEncoding;
 vRESTConnectionDB.OnWork           := vOnWork;
 vRESTConnectionDB.OnWorkBegin      := vOnWorkBegin;
 vRESTConnectionDB.OnWorkEnd        := vOnWorkEnd;
 vRESTConnectionDB.OnStatus         := vOnStatus;
 vRESTConnectionDB.AccessTag        := vAccessTag;
 vRESTConnectionDB.CriptOptions.Use := VCripto.Use;
 vRESTConnectionDB.CriptOptions.Key := VCripto.Key;
 vRESTConnectionDB.DataRoute        := DataRoute;
 vRESTConnectionDB.ServerContext    := ServerContext;
 {$IFDEF FPC}
  vRESTConnectionDB.DatabaseCharSet := csUndefined;
 {$ENDIF}
 vRESTConnectionDB.AuthenticationOptions.Assign(AuthenticationOptions);
 Try
  For I := 0 To 1 Do
   Begin
    If Params.Count > 0 Then
     Begin
      DWParams     := GetDWParams(Params, vEncoding);
      LDataSetList := vRESTConnectionDB.InsertValue(vRestPooler,
                                                    vRestURL, GetLineSQL(SQL),
                                                    DWParams, Error,
                                                    MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                    vClientConnectionDefs.vConnectionDefs, RESTClientPooler);
      FreeAndNil(DWParams);
     End
    Else
     LDataSetList := vRESTConnectionDB.InsertValuePure (vRestPooler,
                                                        vRestURL,
                                                        GetLineSQL(SQL), Error,
                                                        MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                        vClientConnectionDefs.vConnectionDefs, RESTClientPooler);
    If Not(Error) or (MessageError <> cInvalidAuth) Then
     Break
    Else
     Begin
      Case AuthenticationOptions.AuthorizationOption Of
       rdwAOBearer : Begin
                      If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                           (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                         TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect;
                       End;
                     End;
       rdwAOToken  : Begin
                      If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                           (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                         TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect;
                       End;
                     End;
      End;
     End;
   End;
  If SocketError Then
   Begin
    If vFailOver Then
     Begin
      LDataSetList := -1;
      For I := 0 To vFailOverConnections.Count -1 Do
       Begin
        If I = 0 Then
         Begin
          If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
              (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
              (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
              (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
              (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
              (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
              (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
              (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
              (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
              (vFailOverConnections[I].vRestURL        = vRestURL))                        Or
             (Not (vFailOverConnections[I].Active))                                        Then
          Continue;
         End;
        If Assigned(vOnFailOverExecute) Then
         vOnFailOverExecute(vFailOverConnections[I]);
        If Not Assigned(RESTClientPoolerExec) Then
         RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
        RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
        ReconfigureConnection(vRESTConnectionDB,
                              RESTClientPoolerExec,
                              vFailOverConnections[I].vTypeRequest,
                              vFailOverConnections[I].vWelcomeMessage,
                              vFailOverConnections[I].vRestWebService,
                              vFailOverConnections[I].vPoolerPort,
                              vFailOverConnections[I].vCompression,
                              vFailOverConnections[I].EncodeStrings,
                              vFailOverConnections[I].Encoding,
                              vFailOverConnections[I].vAccessTag,
                              vFailOverConnections[I].AuthenticationOptions);
        If Params.Count > 0 Then
         Begin
          DWParams     := GetDWParams(Params, vEncoding);
          LDataSetList := vRESTConnectionDB.InsertValue(vFailOverConnections[I].vRestPooler,
                                                        vFailOverConnections[I].vRestURL, GetLineSQL(SQL),
                                                        DWParams, Error,
                                                        MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                        vClientConnectionDefs.vConnectionDefs, RESTClientPooler);
          FreeAndNil(DWParams);
         End
        Else
         LDataSetList := vRESTConnectionDB.InsertValuePure (vFailOverConnections[I].vRestPooler,
                                                            vFailOverConnections[I].vRestURL,
                                                            GetLineSQL(SQL), Error,
                                                            MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                            vClientConnectionDefs.vConnectionDefs, RESTClientPooler);
        If Not SocketError Then
         Begin
          If vFailOverReplaceDefaults Then
           Begin
            vTypeRequest    := vRESTConnectionDB.TypeRequest;
            vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
            vRestWebService := vRESTConnectionDB.Host;
            vPoolerPort     := vRESTConnectionDB.Port;
            vCompression    := vRESTConnectionDB.Compression;
            vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
            vEncoding       := vRESTConnectionDB.Encoding;
            vAccessTag      := vRESTConnectionDB.AccessTag;
            vRestURL        := vFailOverConnections[I].vRestURL;
            vRestPooler     := vFailOverConnections[I].vRestPooler;
            vTimeOut        := vFailOverConnections[I].vTimeOut;
            vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
            vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
           End;
          Break;
         End;
       End;
     End;
   End;
  If (LDataSetList <> -1) Then
   Begin
//    If Not Assigned(Result) Then //Corre��o fornecida por romyllldo no Forum
    Result := -1;
    Error  := Trim(MessageError) <> '';
    If (LDataSetList <> -1) And
       (Not (Error))        Then
     Begin
      Try
       Result := LDataSetList;
      Finally
      End;
     End;
    If (Not (Error)) Then
     Begin
      If Assigned(vOnEventConnection) Then
       vOnEventConnection(True, 'InsertValue Ok');
     End
    Else
     Begin
      If Assigned(vOnEventConnection) then
       vOnEventConnection(False, MessageError)
      Else
       Raise Exception.Create(PChar(MessageError));
     End;
   End
  Else
   Begin
    If Assigned(vOnEventConnection) Then
     vOnEventConnection(False, MessageError);
   End;
 Except
  On E : Exception do
   Begin
    if Assigned(vOnEventConnection) then
     vOnEventConnection(False, E.Message);
   End;
 End;
 FreeAndNil(vRESTConnectionDB);
End;

procedure TRESTDWDataBase.Loaded;
begin
  inherited Loaded;
  if not (csDesigning in ComponentState) then
    SetConnection(False);
end;

Procedure TRESTDWDataBase.Open;
Begin
 SetConnection(True);
End;

Function TRESTDWDataBase.GetTableNames(Var TableNames         : TStringList)  : Boolean;
Var
 I                    : Integer;
 MessageError,
 vUpdateLine          : String;
 vRESTConnectionDB    : TDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPooler;
 SocketError          : Boolean;
Begin
 SocketError := False; //Leandro 11/08/2020
 RESTClientPoolerExec := nil; //Leandro 11/08/2020
 Result := False;
 If Not Assigned(TableNames) Then
  TableNames := TStringList.Create;
 If vRestPooler = '' Then
  Exit;
 If Not vConnected Then
  SetConnection(True);
 If vConnected Then
  Begin
   vRESTConnectionDB                       := TDWPoolerMethodClient.Create(Nil);
   vRESTConnectionDB.PoolerNotFoundMessage := PoolerNotFoundMessage;
   vRESTConnectionDB.UserAgent             := vUserAgent;
   vRESTConnectionDB.HandleRedirects       := vHandleRedirects;
   vRESTConnectionDB.RedirectMaximum       := vRedirectMaximum;
   vRESTConnectionDB.WelcomeMessage   := vWelcomeMessage;
   vRESTConnectionDB.Host             := vRestWebService;
   vRESTConnectionDB.Port             := vPoolerPort;
   vRESTConnectionDB.Compression      := vCompression;
   vRESTConnectionDB.TypeRequest      := VtypeRequest;
   vRESTConnectionDB.Encoding         := vEncoding;
   vRESTConnectionDB.AccessTag        := vAccessTag;
   vRESTConnectionDB.CriptOptions.Use := VCripto.Use;
   vRESTConnectionDB.CriptOptions.Key := VCripto.Key;
   vRESTConnectionDB.DataRoute        := DataRoute;
   vRESTConnectionDB.ServerContext    := ServerContext;
   vRESTConnectionDB.AuthenticationOptions.Assign(AuthenticationOptions);
   {$IFNDEF FPC}
   vRESTConnectionDB.OnWork           := vOnWork;
   vRESTConnectionDB.OnWorkBegin      := vOnWorkBegin;
   vRESTConnectionDB.OnWorkEnd        := vOnWorkEnd;
   vRESTConnectionDB.OnStatus         := vOnStatus;
   {$ELSE}
   vRESTConnectionDB.OnWork           := vOnWork;
   vRESTConnectionDB.OnWorkBegin      := vOnWorkBegin;
   vRESTConnectionDB.OnWorkEnd        := vOnWorkEnd;
   vRESTConnectionDB.OnStatus         := vOnStatus;
   vRESTConnectionDB.DatabaseCharSet  := csUndefined;
   {$ENDIF}
   Try
    Result := vRESTConnectionDB.GetTableNames(vRestPooler, vRestURL, TableNames,
                                              Result,      MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                              vClientConnectionDefs.vConnectionDefs);
    If SocketError Then
     Begin
      If vFailOver Then
       Begin
        For I := 0 To vFailOverConnections.Count -1 Do
         Begin
          If I = 0 Then
           Begin
            If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
                (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
                (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
                (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
                (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
                (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
                (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
                (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
                (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
                (vFailOverConnections[I].vRestURL        = vRestURL))                        Or
                (Not (vFailOverConnections[I].Active))                                       Then
            Continue;
           End;
          If Assigned(vOnFailOverExecute) Then
           vOnFailOverExecute(vFailOverConnections[I]);
          If Not Assigned(RESTClientPoolerExec) Then
           RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
          RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
          ReconfigureConnection(vRESTConnectionDB,
                                RESTClientPoolerExec,
                                vFailOverConnections[I].vTypeRequest,
                                vFailOverConnections[I].vWelcomeMessage,
                                vFailOverConnections[I].vRestWebService,
                                vFailOverConnections[I].vPoolerPort,
                                vFailOverConnections[I].vCompression,
                                vFailOverConnections[I].EncodeStrings,
                                vFailOverConnections[I].Encoding,
                                vFailOverConnections[I].vAccessTag,
                                vFailOverConnections[I].AuthenticationOptions);
          Result := vRESTConnectionDB.GetTableNames(vFailOverConnections[I].vRestPooler,
                                                    vFailOverConnections[I].vRestURL, TableNames,
                                                    Result,      MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                    vClientConnectionDefs.vConnectionDefs);
          If Not SocketError Then
           Begin
            If vFailOverReplaceDefaults Then
             Begin
              vTypeRequest    := vRESTConnectionDB.TypeRequest;
              vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
              vRestWebService := vRESTConnectionDB.Host;
              vPoolerPort     := vRESTConnectionDB.Port;
              vCompression    := vRESTConnectionDB.Compression;
              vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
              vEncoding       := vRESTConnectionDB.Encoding;
              vAccessTag      := vRESTConnectionDB.AccessTag;
              vRestURL        := vFailOverConnections[I].vRestURL;
              vRestPooler     := vFailOverConnections[I].vRestPooler;
              vTimeOut        := vFailOverConnections[I].vTimeOut;
              vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
              vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
             End;
            Break;
           End;
         End;
       End;
     End;
   Finally
    FreeAndNil(vRESTConnectionDB);
   End;
  End;
End;

Function TRESTDWDataBase.GetFieldNames(TableName              : String;
                                       Var FieldNames         : TStringList)  : Boolean;
Var
 I                    : Integer;
 MessageError,
 vUpdateLine          : String;
 vRESTConnectionDB    : TDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPooler;
 SocketError          : Boolean;
Begin
 SocketError := False; //Leandro 11/08/2020
 RESTClientPoolerExec := nil; //Leandro 11/08/2020
 Result := False;
 If Not Assigned(FieldNames) Then
  FieldNames := TStringList.Create;
 If vRestPooler = '' Then
  Exit;
 If Not vConnected Then
  SetConnection(True);
 If vConnected Then
  Begin
   vRESTConnectionDB                  := TDWPoolerMethodClient.Create(Nil);
   vRESTConnectionDB.PoolerNotFoundMessage := PoolerNotFoundMessage;
   vRESTConnectionDB.UserAgent        := vUserAgent;
   vRESTConnectionDB.HandleRedirects  := vHandleRedirects;
   vRESTConnectionDB.RedirectMaximum  := vRedirectMaximum;
   vRESTConnectionDB.WelcomeMessage   := vWelcomeMessage;
   vRESTConnectionDB.Host             := vRestWebService;
   vRESTConnectionDB.Port             := vPoolerPort;
   vRESTConnectionDB.Compression      := vCompression;
   vRESTConnectionDB.TypeRequest      := VtypeRequest;
   vRESTConnectionDB.Encoding         := vEncoding;
   vRESTConnectionDB.AccessTag        := vAccessTag;
   vRESTConnectionDB.CriptOptions.Use := VCripto.Use;
   vRESTConnectionDB.CriptOptions.Key := VCripto.Key;
   vRESTConnectionDB.DataRoute        := DataRoute;
   vRESTConnectionDB.ServerContext    := ServerContext;
   vRESTConnectionDB.AuthenticationOptions.Assign(AuthenticationOptions);
   {$IFNDEF FPC}
   vRESTConnectionDB.OnWork           := vOnWork;
   vRESTConnectionDB.OnWorkBegin      := vOnWorkBegin;
   vRESTConnectionDB.OnWorkEnd        := vOnWorkEnd;
   vRESTConnectionDB.OnStatus         := vOnStatus;
   {$ELSE}
   vRESTConnectionDB.OnWork           := vOnWork;
   vRESTConnectionDB.OnWorkBegin      := vOnWorkBegin;
   vRESTConnectionDB.OnWorkEnd        := vOnWorkEnd;
   vRESTConnectionDB.OnStatus         := vOnStatus;
   vRESTConnectionDB.DatabaseCharSet  := csUndefined;
   {$ENDIF}
   Try
    Result := vRESTConnectionDB.GetFieldNames(vRestPooler, vRestURL, TableName, FieldNames,
                                              Result,      MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                              vClientConnectionDefs.vConnectionDefs);
    If SocketError Then
     Begin
      If vFailOver Then
       Begin
        For I := 0 To vFailOverConnections.Count -1 Do
         Begin
          If I = 0 Then
           Begin
            If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
                (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
                (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
                (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
                (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
                (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
                (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
                (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
                (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
                (vFailOverConnections[I].vRestURL        = vRestURL))                        Or
                (Not (vFailOverConnections[I].Active))                                       Then
            Continue;
           End;
          If Assigned(vOnFailOverExecute) Then
           vOnFailOverExecute(vFailOverConnections[I]);
          If Not Assigned(RESTClientPoolerExec) Then
           RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
          RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
          ReconfigureConnection(vRESTConnectionDB,
                                RESTClientPoolerExec,
                                vFailOverConnections[I].vTypeRequest,
                                vFailOverConnections[I].vWelcomeMessage,
                                vFailOverConnections[I].vRestWebService,
                                vFailOverConnections[I].vPoolerPort,
                                vFailOverConnections[I].vCompression,
                                vFailOverConnections[I].EncodeStrings,
                                vFailOverConnections[I].Encoding,
                                vFailOverConnections[I].vAccessTag,
                                vFailOverConnections[I].AuthenticationOptions);
          Result := vRESTConnectionDB.GetFieldNames(vFailOverConnections[I].vRestPooler,
                                                    vFailOverConnections[I].vRestURL, TableName, FieldNames,
                                                    Result,      MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                    vClientConnectionDefs.vConnectionDefs);
          If Not SocketError Then
           Begin
            If vFailOverReplaceDefaults Then
             Begin
              vTypeRequest    := vRESTConnectionDB.TypeRequest;
              vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
              vRestWebService := vRESTConnectionDB.Host;
              vPoolerPort     := vRESTConnectionDB.Port;
              vCompression    := vRESTConnectionDB.Compression;
              vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
              vEncoding       := vRESTConnectionDB.Encoding;
              vAccessTag      := vRESTConnectionDB.AccessTag;
              vRestURL        := vFailOverConnections[I].vRestURL;
              vRestPooler     := vFailOverConnections[I].vRestPooler;
              vTimeOut        := vFailOverConnections[I].vTimeOut;
              vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
              vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
             End;
            Break;
           End;
         End;
       End;
     End;
   Finally
    FreeAndNil(vRESTConnectionDB);
   End;
  End;
End;

Function TRESTDWDataBase.GetKeyFieldNames(TableName              : String;
                                          Var FieldNames         : TStringList)  : Boolean;
Var
 I                    : Integer;
 MessageError,
 vUpdateLine          : String;
 vRESTConnectionDB    : TDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPooler;
 SocketError          : Boolean;
Begin
 SocketError := False; //Leandro 11/08/2020
 RESTClientPoolerExec := nil; //Leandro 11/08/2020
 Result := False;
 If Not Assigned(FieldNames) Then
  FieldNames := TStringList.Create;
 If vRestPooler = '' Then
  Exit;
 If Not vConnected Then
  SetConnection(True);
 If vConnected Then
  Begin
   vRESTConnectionDB                  := TDWPoolerMethodClient.Create(Nil);
   vRESTConnectionDB.PoolerNotFoundMessage := PoolerNotFoundMessage;
   vRESTConnectionDB.UserAgent        := vUserAgent;
   vRESTConnectionDB.HandleRedirects  := vHandleRedirects;
   vRESTConnectionDB.RedirectMaximum  := vRedirectMaximum;
   vRESTConnectionDB.WelcomeMessage   := vWelcomeMessage;
   vRESTConnectionDB.Host             := vRestWebService;
   vRESTConnectionDB.Port             := vPoolerPort;
   vRESTConnectionDB.Compression      := vCompression;
   vRESTConnectionDB.TypeRequest      := VtypeRequest;
   vRESTConnectionDB.Encoding         := vEncoding;
   vRESTConnectionDB.AccessTag        := vAccessTag;
   vRESTConnectionDB.CriptOptions.Use := VCripto.Use;
   vRESTConnectionDB.CriptOptions.Key := VCripto.Key;
   vRESTConnectionDB.DataRoute        := DataRoute;
   vRESTConnectionDB.ServerContext    := ServerContext;
   vRESTConnectionDB.AuthenticationOptions.Assign(AuthenticationOptions);
   {$IFNDEF FPC}
   vRESTConnectionDB.OnWork           := vOnWork;
   vRESTConnectionDB.OnWorkBegin      := vOnWorkBegin;
   vRESTConnectionDB.OnWorkEnd        := vOnWorkEnd;
   vRESTConnectionDB.OnStatus         := vOnStatus;
   {$ELSE}
   vRESTConnectionDB.OnWork           := vOnWork;
   vRESTConnectionDB.OnWorkBegin      := vOnWorkBegin;
   vRESTConnectionDB.OnWorkEnd        := vOnWorkEnd;
   vRESTConnectionDB.OnStatus         := vOnStatus;
   vRESTConnectionDB.DatabaseCharSet  := csUndefined;
   {$ENDIF}
   Try
    FieldNames.Clear;
    Result := vRESTConnectionDB.GetKeyFieldNames(vRestPooler, vRestURL, TableName, FieldNames,
                                                 Result,      MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                 vClientConnectionDefs.vConnectionDefs);
    If SocketError Then
     Begin
      If vFailOver Then
       Begin
        For I := 0 To vFailOverConnections.Count -1 Do
         Begin
          If I = 0 Then
           Begin
            If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
                (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
                (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
                (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
                (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
                (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
                (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
                (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
                (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
                (vFailOverConnections[I].vRestURL        = vRestURL))                        Or
                (Not (vFailOverConnections[I].Active))                                       Then
            Continue;
           End;
          If Assigned(vOnFailOverExecute) Then
           vOnFailOverExecute(vFailOverConnections[I]);
          If Not Assigned(RESTClientPoolerExec) Then
           RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
          RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
          ReconfigureConnection(vRESTConnectionDB,
                                RESTClientPoolerExec,
                                vFailOverConnections[I].vTypeRequest,
                                vFailOverConnections[I].vWelcomeMessage,
                                vFailOverConnections[I].vRestWebService,
                                vFailOverConnections[I].vPoolerPort,
                                vFailOverConnections[I].vCompression,
                                vFailOverConnections[I].EncodeStrings,
                                vFailOverConnections[I].Encoding,
                                vFailOverConnections[I].vAccessTag,
                                vFailOverConnections[I].AuthenticationOptions);
          Result := vRESTConnectionDB.GetKeyFieldNames(vFailOverConnections[I].vRestPooler,
                                                       vFailOverConnections[I].vRestURL, TableName, FieldNames,
                                                       Result,      MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                       vClientConnectionDefs.vConnectionDefs);
          If Not SocketError Then
           Begin
            If vFailOverReplaceDefaults Then
             Begin
              vTypeRequest    := vRESTConnectionDB.TypeRequest;
              vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
              vRestWebService := vRESTConnectionDB.Host;
              vPoolerPort     := vRESTConnectionDB.Port;
              vCompression    := vRESTConnectionDB.Compression;
              vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
              vEncoding       := vRESTConnectionDB.Encoding;
              vAccessTag      := vRESTConnectionDB.AccessTag;
              vRestURL        := vFailOverConnections[I].vRestURL;
              vRestPooler     := vFailOverConnections[I].vRestPooler;
              vTimeOut        := vFailOverConnections[I].vTimeOut;
              vConnectTimeOut        := vFailOverConnections[I].vConnectTimeOut;
              vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
             End;
            Break;
           End;
         End;
       End;
     End;
   Finally
    FreeAndNil(vRESTConnectionDB);
   End;
  End;
End;

Procedure TRESTDWDataBase.OpenDatasets(Datasets         : Array of {$IFDEF FPC}TRESTDWClientSQLBase{$ELSE}TObject{$ENDIF});
Var
 Error        : Boolean;
 MessageError : String;
Begin
 OpenDatasets(Datasets, Error, MessageError);
 If Error Then
  Raise Exception.Create(PChar(MessageError));
End;

Procedure TRESTDWDataBase.OpenDatasets(Datasets               : Array of {$IFDEF FPC}TRESTDWClientSQLBase{$ELSE}TObject{$ENDIF};
                                       Var Error              : Boolean;
                                       Var MessageError       : String;
                                       BinaryRequest          : Boolean = True);
Var
 vJsonLine,
 vLinesDS             : String;
 vJsonCount,
 I                    : Integer;
 vRESTConnectionDB    : TDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPooler;
 vJSONValue           : TJSONValue;
 vJsonValueB          : TDWJSONBase;
 vJsonArray           : TDWJSONArray;
 vJsonOBJ             : TDWJSONObject;
 SocketError          : Boolean;
 vStream              : TMemoryStream;
 Function DatasetRequestToJSON(Value : TRESTDWClientSQLBase) : String;
 Var
  vDWParams    : TDWParams;
  vTempLineParams,
  vTempLineSQL : String;
 Begin
  vTempLineParams := '';
  vTempLineSQL    := vTempLineParams;
  Result          := vTempLineSQL;
  If Value <> Nil Then
   Begin
    TRESTDWClientSQL(Value).DWParams(vDWParams);
    If vDWParams <> Nil Then
     Begin
      {$IFDEF FPC}
      vTempLineParams := aEncodeStrings(vDWParams.ToJSON, TRESTDWClientSQL(Value).DatabaseCharSet);
      {$ELSE}
      vTempLineParams := aEncodeStrings(vDWParams.ToJSON);
      {$ENDIF}
      FreeAndNil(vDWParams);
     End;
    {$IFDEF FPC}
    vTempLineSQL      := aEncodeStrings(TRESTDWClientSQL(Value).SQL.Text, TRESTDWClientSQL(Value).DatabaseCharSet);
    {$ELSE}
    vTempLineSQL      := aEncodeStrings(TRESTDWClientSQL(Value).SQL.Text);
    {$ENDIF}
    Result            := Format(TDatasetRequestJSON, [vTempLineSQL, vTempLineParams,
                                                      BooleanToString(TRESTDWClientSQL(Value).BinaryRequest),
                                                      BooleanToString(TRESTDWClientSQL(Value).Fields.Count = 0),
                                                      BooleanToString(TRESTDWClientSQL(Value).BinaryCompatibleMode)]);
   End;
 End;
Begin
 SocketError := False; //Leandro 11/08/2020
 RESTClientPoolerExec := nil; //Leandro 11/08/2020

 vStream := Nil;
 vLinesDS := '';
 For I := 0 To Length(Datasets) -1 Do
  Begin
   TRESTDWClientSQL(Datasets[I]).ProcBeforeOpen(TRESTDWClientSQL(Datasets[I]));
   If I = 0 Then
    vLinesDS := DatasetRequestToJSON(TRESTDWClientSQL(Datasets[I]))
   Else
    vLinesDS := Format('%s, %s', [vLinesDS, DatasetRequestToJSON(TRESTDWClientSQL(Datasets[I]))]);
  End;
 If vLinesDS <> '' Then
  vLinesDS := Format('[%s]', [vLinesDS])
 Else
  vLinesDS := '[]';
 if vRestPooler = '' then
  Exit;
 If Not vConnected Then
  SetConnection(True);
 vRESTConnectionDB                  := TDWPoolerMethodClient.Create(Nil);
 vRESTConnectionDB.PoolerNotFoundMessage := PoolerNotFoundMessage;
 vRESTConnectionDB.UserAgent        := vUserAgent;
 vRESTConnectionDB.HandleRedirects  := vHandleRedirects;
 vRESTConnectionDB.RedirectMaximum  := vRedirectMaximum;
 vRESTConnectionDB.WelcomeMessage   := vWelcomeMessage;
 vRESTConnectionDB.Host             := vRestWebService;
 vRESTConnectionDB.Port             := vPoolerPort;
 vRESTConnectionDB.Compression      := vCompression;
 vRESTConnectionDB.TypeRequest      := VtypeRequest;
 vRESTConnectionDB.Encoding         := vEncoding;
 vRESTConnectionDB.AccessTag        := vAccessTag;
 vRESTConnectionDB.CriptOptions.Use := VCripto.Use;
 vRESTConnectionDB.CriptOptions.Key := VCripto.Key;
 vRESTConnectionDB.DataRoute        := DataRoute;
 vRESTConnectionDB.ServerContext    := ServerContext;
 vRESTConnectionDB.BinaryRequest    := BinaryRequest;
 vRESTConnectionDB.AuthenticationOptions.Assign(AuthenticationOptions);
 {$IFNDEF FPC}
  vRESTConnectionDB.OnWork          := vOnWork;
  vRESTConnectionDB.OnWorkBegin     := vOnWorkBegin;
  vRESTConnectionDB.OnWorkEnd       := vOnWorkEnd;
  vRESTConnectionDB.OnStatus        := vOnStatus;
 {$ELSE}
  vRESTConnectionDB.OnWork          := vOnWork;
  vRESTConnectionDB.OnWorkBegin     := vOnWorkBegin;
  vRESTConnectionDB.OnWorkEnd       := vOnWorkEnd;
  vRESTConnectionDB.OnStatus        := vOnStatus;
  vRESTConnectionDB.DatabaseCharSet := csUndefined;
 {$ENDIF}
 Try
  For I := 0 To 1 Do
   Begin
    vLinesDS := vRESTConnectionDB.OpenDatasets(vLinesDS, vRestPooler,  vRestURL,
                                               Error,    MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                               vClientConnectionDefs.vConnectionDefs);
    If Not(Error) or (MessageError <> cInvalidAuth) Then
     Break
    Else
     Begin
      Case AuthenticationOptions.AuthorizationOption Of
       rdwAOBearer : Begin
                      If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                           (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                         TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect;
                       End;
                     End;
       rdwAOToken  : Begin
                      If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                           (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                         TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect;
                       End;
                     End;
      End;
     End;
   End;
  If SocketError Then
   Begin
    If vFailOver Then
     Begin
      vLinesDS := '';
      For I := 0 To vFailOverConnections.Count -1 Do
       Begin
        If I = 0 Then
         Begin
          If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
              (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
              (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
              (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
              (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
              (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
              (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
              (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
              (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
              (vFailOverConnections[I].vRestURL        = vRestURL))                        Or
             (Not (vFailOverConnections[I].Active))                                        Then
          Continue;
         End;
        If Assigned(vOnFailOverExecute) Then
         vOnFailOverExecute(vFailOverConnections[I]);
        If Not Assigned(RESTClientPoolerExec) Then
         RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
        RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
        ReconfigureConnection(vRESTConnectionDB,
                              RESTClientPoolerExec,
                              vFailOverConnections[I].vTypeRequest,
                              vFailOverConnections[I].vWelcomeMessage,
                              vFailOverConnections[I].vRestWebService,
                              vFailOverConnections[I].vPoolerPort,
                              vFailOverConnections[I].vCompression,
                              vFailOverConnections[I].EncodeStrings,
                              vFailOverConnections[I].Encoding,
                              vFailOverConnections[I].vAccessTag,
                              vFailOverConnections[I].AuthenticationOptions);
        vLinesDS := vRESTConnectionDB.OpenDatasets(vLinesDS, vFailOverConnections[I].vRestPooler,  vFailOverConnections[I].vRestURL,
                                                   Error,    MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                   vClientConnectionDefs.vConnectionDefs);
        If Not SocketError Then
         Begin
          If vFailOverReplaceDefaults Then
           Begin
            vTypeRequest    := vRESTConnectionDB.TypeRequest;
            vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
            vRestWebService := vRESTConnectionDB.Host;
            vPoolerPort     := vRESTConnectionDB.Port;
            vCompression    := vRESTConnectionDB.Compression;
            vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
            vEncoding       := vRESTConnectionDB.Encoding;
            vAccessTag      := vRESTConnectionDB.AccessTag;
            vRestURL        := vFailOverConnections[I].vRestURL;
            vRestPooler     := vFailOverConnections[I].vRestPooler;
            vTimeOut        := vFailOverConnections[I].vTimeOut;
            vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
            vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
           End;
          Break;
         End;
       End;
     End;
   End;
  If Not Error Then
   Begin
    If BinaryRequest Then
     vJsonOBJ      := TDWJSONObject.Create(DecodeStrings(vLinesDS{$IFDEF FPC}, csUndefined{$ENDIF}))
    Else
     Begin
      vJSONValue := TJSONValue.Create;
      Try
       vJSONValue.Encoded  := True;
       vJSONValue.Encoding := vEncoding;
       vJSONValue.LoadFromJSON(vLinesDS);
       vJsonLine := vJSONValue.value;
      Finally
       FreeAndNil(vJSONValue);
      End;
      vJsonOBJ := TDWJSONObject.Create(vJsonLine);
     End;
    vJsonArray     := TDWJSONArray(vJsonOBJ);
    Try
     For I := 0 To vJsonArray.ElementCount -1 do
      Begin
       vJsonValueB := vJsonArray.GetObject(I);
       vJsonCount  := 0;
       vJSONValue  := TJSONValue.Create;
       vJSONValue.Utf8SpecialChars := True;
       Try //Alexandre Magno - 21/01/2019 - Add Try Finally para remover memoryleaks
        vJSONValue.Encoding := vEncoding;
        If Not TRESTDWClientSQL(Datasets[I]).BinaryRequest Then
         Begin
          vJSONValue.LoadFromJSON(TDWJSONObject(vJsonValueB).ToJson);
          vJSONValue.Encoded := True;
          vJSONValue.OnWriterProcess := TRESTDWClientSQL(Datasets[I]).OnWriterProcess;
          vJSONValue.ServerFieldList := TRESTDWClientSQL(Datasets[I]).ServerFieldList;
          {$IFDEF FPC}
           vJSONValue.DatabaseCharSet := TRESTDWClientSQL(Datasets[I]).DatabaseCharSet;
           vJSONValue.NewFieldList    := @TRESTDWClientSQL(Datasets[I]).NewFieldList;
           vJSONValue.NewDataField    := @TRESTDWClientSQL(Datasets[I]).NewDataField;
           vJSONValue.SetInitDataset  := @TRESTDWClientSQL(Datasets[I]).SetInitDataset;
           vJSONValue.SetRecordCount     := @TRESTDWClientSQL(Datasets[I]).SetRecordCount;
           vJSONValue.Setnotrepage       := @TRESTDWClientSQL(Datasets[I]).Setnotrepage;
           vJSONValue.SetInDesignEvents  := @TRESTDWClientSQL(Datasets[I]).SetInDesignEvents;
           vJSONValue.SetInBlockEvents   := @TRESTDWClientSQL(Datasets[I]).SetInBlockEvents;
           vJSONValue.SetInactive        := @TRESTDWClientSQL(Datasets[I]).SetInactive;
           vJSONValue.FieldListCount     := @TRESTDWClientSQL(Datasets[I]).FieldListCount;
           vJSONValue.GetInDesignEvents  := @TRESTDWClientSQL(Datasets[I]).GetInDesignEvents;
           vJSONValue.PrepareDetailsNew  := @TRESTDWClientSQL(Datasets[I]).PrepareDetailsNew;
           vJSONValue.PrepareDetails     := @TRESTDWClientSQL(Datasets[I]).PrepareDetails;
          {$ELSE}
           vJSONValue.NewFieldList    := TRESTDWClientSQL(Datasets[I]).NewFieldList;
           vJSONValue.CreateDataSet   := TRESTDWClientSQL(Datasets[I]).CreateDataSet;
           vJSONValue.NewDataField    := TRESTDWClientSQL(Datasets[I]).NewDataField;
           vJSONValue.SetInitDataset  := TRESTDWClientSQL(Datasets[I]).SetInitDataset;
           vJSONValue.SetRecordCount     := TRESTDWClientSQL(Datasets[I]).SetRecordCount;
           vJSONValue.Setnotrepage       := TRESTDWClientSQL(Datasets[I]).Setnotrepage;
           vJSONValue.SetInDesignEvents  := TRESTDWClientSQL(Datasets[I]).SetInDesignEvents;
           vJSONValue.SetInBlockEvents   := TRESTDWClientSQL(Datasets[I]).SetInBlockEvents;
           vJSONValue.SetInactive        := TRESTDWClientSQL(Datasets[I]).SetInactive;
           vJSONValue.FieldListCount     := TRESTDWClientSQL(Datasets[I]).FieldListCount;
           vJSONValue.GetInDesignEvents  := TRESTDWClientSQL(Datasets[I]).GetInDesignEvents;
           vJSONValue.PrepareDetailsNew  := TRESTDWClientSQL(Datasets[I]).PrepareDetailsNew;
           vJSONValue.PrepareDetails     := TRESTDWClientSQL(Datasets[I]).PrepareDetails;
          {$ENDIF}
          vJSONValue.WriteToDataset(dtFull, vJSONValue.ToJSON, TRESTDWClientSQL(Datasets[I]),
                                   vJsonCount, TRESTDWClientSQL(Datasets[I]).Datapacks);
          TRESTDWClientSQL(Datasets[I]).vActualJSON := vJSONValue.ToJSON;
          TRESTDWClientSQLBase(Datasets[I]).SetInBlockEvents(False);
          If TRESTDWClientSQL(Datasets[I]).Active Then
           If TRESTDWClientSQL(Datasets[I]).BinaryRequest Then
            TRESTDWClientSQL(Datasets[I]).ProcAfterOpen(TRESTDWClientSQL(Datasets[I]));
         End
        Else
         Begin
          vStream := Decodeb64Stream(TDWJSONObject(vJsonValueB).pairs[0].value);
          {$IFNDEF DWMEMTABLE}
          TRESTDWClientSQLBase(Datasets[I]).BinaryCompatibleMode := TRESTDWClientSQL(Datasets[I]).BinaryCompatibleMode;
          {$ENDIF}
          TRESTDWClientSQLBase(Datasets[I]).SetInBlockEvents(True);
          Try
           TRESTDWClientSQLBase(Datasets[I]).LoadFromStream(TMemoryStream(vStream));
          Finally
           TRESTDWClientSQLBase(Datasets[I]).SetInBlockEvents(False);
           If TRESTDWClientSQL(Datasets[I]).Active Then
            If TRESTDWClientSQL(Datasets[I]).BinaryRequest Then
             TRESTDWClientSQL(Datasets[I]).ProcAfterOpen(TRESTDWClientSQL(Datasets[I]));
          End;
          TRESTDWClientSQL(Datasets[I]).DisableControls;
          Try
           TRESTDWClientSQL(Datasets[I]).SetInBlockEvents(True); // Novavix
           TRESTDWClientSQL(Datasets[I]).Last;
           TRESTDWClientSQL(Datasets[I]).SetInBlockEvents(False); // Novavix
           vJsonCount := TRESTDWClientSQLBase(Datasets[I]).RecNo;
           //A Linha a baixo e pedido do Tiago Istuque que n�o mostrava o recordcount com BN
           TRESTDWClientSQL(Datasets[I]).SetRecordCount(vJsonCount, vJsonCount);
           TRESTDWClientSQL(Datasets[I]).SetInBlockEvents(True); // Novavix
           TRESTDWClientSQL(Datasets[I]).First;
           TRESTDWClientSQL(Datasets[I]).SetInBlockEvents(False); // Novavix
          Finally
           TRESTDWClientSQL(Datasets[I]).EnableControls;
           If Assigned(vStream) Then
            vStream.Free;
           If TRESTDWClientSQL(Datasets[I]).State = dsBrowse Then
            Begin
             If TRESTDWClientSQL(Datasets[I]).RecordCount = 0 Then
              TRESTDWClientSQL(Datasets[I]).PrepareDetailsNew
             Else
              TRESTDWClientSQL(Datasets[I]).PrepareDetails(True);
            End;
          End;
         End;
        TRESTDWClientSQL(Datasets[I]).CreateMassiveDataset;
       Finally
        FreeAndNil(vJSONValue);
        FreeAndNil(vJsonValueB);
       End;
      End;
    Finally
     FreeAndNil(vJsonArray);
    End;
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

Procedure TRESTDWDataBase.ExecuteCommandTB(Var PoolerMethodClient : TDWPoolerMethodClient;
                                           Tablename              : String;
                                           Var Params             : TParams;
                                           Var Error              : Boolean;
                                           Var MessageError       : String;
                                           Var Result             : TJSONValue;
                                           Var RowsAffected       : Integer;
                                           BinaryRequest          : Boolean = False;
                                           BinaryCompatibleMode   : Boolean = False;
                                           Metadata               : Boolean = False;
                                           RESTClientPooler       : TRESTClientPooler = Nil);
Var
 vRESTConnectionDB    : TDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPooler;
 LDataSetList         : TJSONValue;
 DWParams             : TDWParams;
 vSQL,
 vTempValue           : String;
 SocketError          : Boolean;
 I                    : Integer;
 Procedure ParseParams;
 Var
  I : Integer;
 Begin
 If Params <> Nil Then
   For I := 0 To Params.Count -1 Do
    Begin
     If Params[I].DataType = ftUnknown then
      Params[I].DataType := ftString;
    End;
 End;
Begin
 LDataSetList         := Nil;
 RESTClientPoolerExec := Nil;
 SocketError          := False;
 If vRestPooler = '' Then
  Exit;
 ParseParams;
 vRESTConnectionDB                  := TDWPoolerMethodClient.Create(Nil);
 PoolerMethodClient                 := vRESTConnectionDB;
 vRESTConnectionDB.PoolerNotFoundMessage := PoolerNotFoundMessage;
 vRESTConnectionDB.UserAgent        := vUserAgent;
 vRESTConnectionDB.HandleRedirects  := vHandleRedirects;
 vRESTConnectionDB.RedirectMaximum  := vRedirectMaximum;
 vRESTConnectionDB.WelcomeMessage   := vWelcomeMessage;
 vRESTConnectionDB.Host             := vRestWebService;
 vRESTConnectionDB.Port             := vPoolerPort;
 vRESTConnectionDB.Compression      := vCompression;
 vRESTConnectionDB.TypeRequest      := VtypeRequest;
 vRESTConnectionDB.Encoding         := vEncoding;
 vRESTConnectionDB.EncodeStrings    := EncodeStrings;
 vRESTConnectionDB.OnWork           := vOnWork;
 vRESTConnectionDB.OnWorkBegin      := vOnWorkBegin;
 vRESTConnectionDB.OnWorkEnd        := vOnWorkEnd;
 vRESTConnectionDB.OnStatus         := vOnStatus;
 vRESTConnectionDB.AccessTag        := vAccessTag;
 vRESTConnectionDB.CriptOptions.Use := VCripto.Use;
 vRESTConnectionDB.CriptOptions.Key := VCripto.Key;
 vRESTConnectionDB.DataRoute        := DataRoute;
 vRESTConnectionDB.ServerContext    := ServerContext;
 vRESTConnectionDB.BinaryRequest    := BinaryRequest;
 vRESTConnectionDB.AuthenticationOptions.Assign(AuthenticationOptions);
 {$IFDEF FPC}
  vRESTConnectionDB.DatabaseCharSet := csUndefined;
 {$ENDIF}
 Try
  If Params.Count > 0 Then
   Begin
    DWParams     := GetDWParams(Params, vEncoding);
    LDataSetList := vRESTConnectionDB.ExecuteCommandJSONTB(vRestPooler,
                                                           vRestURL,
                                                           Tablename,
                                                           DWParams, Error,
                                                           MessageError, SocketError, RowsAffected, BinaryRequest, BinaryCompatibleMode,
                                                           Metadata, vTimeOut, vConnectTimeOut, vClientConnectionDefs.vConnectionDefs, RESTClientPooler);
    FreeAndNil(DWParams);
   End
  Else
   LDataSetList := vRESTConnectionDB.ExecuteCommandPureJSONTB(vRestPooler,
                                                              vRestURL,
                                                              Tablename,
                                                              Error,
                                                              MessageError, SocketError, RowsAffected, BinaryRequest, BinaryCompatibleMode,
                                                              Metadata, vTimeOut, vConnectTimeOut, vClientConnectionDefs.vConnectionDefs, RESTClientPooler);
  If SocketError Then
   Begin
    If vFailOver Then
     Begin
      If Assigned(LDataSetList) Then
       FreeAndNil(LDataSetList);
      For I := 0 To vFailOverConnections.Count -1 Do
       Begin
        If I = 0 Then
         Begin
          If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
              (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
              (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
              (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
              (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
              (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
              (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
              (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
              (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
              (vFailOverConnections[I].vRestURL        = vRestURL))                        Or
             (Not (vFailOverConnections[I].Active))                                        Then
          Continue;
         End;
        If Assigned(vOnFailOverExecute) Then
         vOnFailOverExecute(vFailOverConnections[I]);
        If Not Assigned(RESTClientPoolerExec) Then
         RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
        RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
        ReconfigureConnection(vRESTConnectionDB,
                              RESTClientPoolerExec,
                              vFailOverConnections[I].vTypeRequest,
                              vFailOverConnections[I].vWelcomeMessage,
                              vFailOverConnections[I].vRestWebService,
                              vFailOverConnections[I].vPoolerPort,
                              vFailOverConnections[I].vCompression,
                              vFailOverConnections[I].EncodeStrings,
                              vFailOverConnections[I].Encoding,
                              vFailOverConnections[I].vAccessTag,
                              vFailOverConnections[I].AuthenticationOptions);
        If Params.Count > 0 Then
         Begin
          DWParams     := GetDWParams(Params, vEncoding);
          LDataSetList := vRESTConnectionDB.ExecuteCommandJSONTB(vFailOverConnections[I].vRestPooler,
                                                                 vFailOverConnections[I].vRestURL,
                                                                 Tablename,
                                                                 DWParams, Error,
                                                                 MessageError, SocketError, RowsAffected, BinaryRequest, BinaryCompatibleMode,
                                                                 Metadata, vTimeOut, vConnectTimeOut, vClientConnectionDefs.vConnectionDefs, RESTClientPooler);
          FreeAndNil(DWParams);
         End
        Else
         LDataSetList := vRESTConnectionDB.ExecuteCommandPureJSONTB(vFailOverConnections[I].vRestPooler,
                                                                    vFailOverConnections[I].vRestURL,
                                                                    Tablename,
                                                                    Error,
                                                                    MessageError, SocketError, RowsAffected, BinaryRequest, BinaryCompatibleMode,
                                                                    Metadata, vTimeOut, vConnectTimeOut, vClientConnectionDefs.vConnectionDefs, RESTClientPooler);
        If Not SocketError Then
         Begin
          If vFailOverReplaceDefaults Then
           Begin
            vTypeRequest    := vRESTConnectionDB.TypeRequest;
            vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
            vRestWebService := vRESTConnectionDB.Host;
            vPoolerPort     := vRESTConnectionDB.Port;
            vCompression    := vRESTConnectionDB.Compression;
            vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
            vEncoding       := vRESTConnectionDB.Encoding;
            vAccessTag      := vRESTConnectionDB.AccessTag;
            vRestURL        := vFailOverConnections[I].vRestURL;
            vRestPooler     := vFailOverConnections[I].vRestPooler;
            vTimeOut        := vFailOverConnections[I].vTimeOut;
            vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
            vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
           End;
          Break;
         End;
       End;
     End;
   End;
  If (LDataSetList <> Nil) Then
   Begin
    Result := TJSONValue.Create;
    Result.Encoding := vRESTConnectionDB.Encoding;
    Error  := Trim(MessageError) <> '';
    If Not BinaryRequest Then
     Begin
      If Not LDataSetList.IsNull Then
       vTempValue := LDataSetList.ToJSON;
     End
    Else
     Begin
      If Not LDataSetList.IsNull Then
       vTempValue := LDataSetList.Value;
     End;
    If (Trim(vTempValue) <> '{}') And
       (Trim(vTempValue) <> '')    And
       (Not (Error))                       Then
     Begin
      Try
       {$IFDEF  ANDROID}
       Result.Clear;
       If Not BinaryRequest Then
        Begin
         Result.Encoded := False;
         Result.LoadFromJSON(vTempValue);
        End
       Else
        Result.SetValue(LDataSetList.Value, False);
       {$ELSE}
        If Not BinaryRequest Then
         Result.LoadFromJSON(vTempValue)
        Else
         Begin
          If vTempValue <> '' Then
           Result.SetValue(vTempValue, False)
          Else
           Begin
            If Not LDataSetList.IsNull Then
             vTempValue := LDataSetList.ToJSON
           End;
         End;
       {$ENDIF}
      Finally
      End;
     End;
    vTempValue := '';
    If (Not (Error)) Then
     Begin
      If Assigned(vOnEventConnection) Then
       vOnEventConnection(True, 'ExecuteCommand Ok');
     End
    Else
     Begin
      If Assigned(vOnEventConnection) then
       vOnEventConnection(False, MessageError)
      Else
       Raise Exception.Create(PChar(MessageError));
     End;
   End
  Else
   Begin
    If Assigned(vOnEventConnection) Then
     vOnEventConnection(False, MessageError);
   End;
 Except
  On E : Exception do
   Begin
    if Assigned(vOnEventConnection) then
     vOnEventConnection(False, E.Message);
   End;
 End;
 If LDataSetList <> Nil Then
  FreeAndNil(LDataSetList);
 FreeAndNil(vRESTConnectionDB);
End;

Procedure TRESTDWDataBase.ExecuteCommand(Var PoolerMethodClient : TDWPoolerMethodClient;
                                         Var SQL                : TStringList;
                                         Var Params             : TParams;
                                         Var Error              : Boolean;
                                         Var MessageError       : String;
                                         Var Result             : TJSONValue;
                                         Var RowsAffected       : Integer;
                                         Execute                : Boolean = False;
                                         BinaryRequest          : Boolean = False;
                                         BinaryCompatibleMode   : Boolean = False;
                                         Metadata               : Boolean = False;
                                         RESTClientPooler       : TRESTClientPooler     = Nil);
Var
 vRESTConnectionDB    : TDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPooler;
 LDataSetList         : TJSONValue;
 DWParams             : TDWParams;
 vSQL,
 vTempValue           : String;
 vLocalClient,
 SocketError          : Boolean;
 I                    : Integer;
 Function GetLineSQL(Value : TStringList) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  If Value <> Nil Then
   For I := 0 To Value.Count -1 do
    Begin
     If I = 0 then
      Result := Value[I]
     Else
      Result := Result + ' ' + Value[I];
    End;
 End;
 Procedure ParseParams;
 Var
  I : Integer;
 Begin
 If Params <> Nil Then
   For I := 0 To Params.Count -1 Do
    Begin
     If Params[I].DataType = ftUnknown then
      Params[I].DataType := ftString;
    End;
 End;
Begin
 LDataSetList         := Nil;
 RESTClientPoolerExec := Nil;
 SocketError          := False; //Leandro 11/08/2020
 vLocalClient         := False;
 If vRestPooler = '' Then
  Exit;
 ParseParams;
 vRESTConnectionDB                  := TDWPoolerMethodClient.Create(Nil);
 PoolerMethodClient                 := vRESTConnectionDB;
 vRESTConnectionDB.PoolerNotFoundMessage := PoolerNotFoundMessage;
 vRESTConnectionDB.UserAgent        := vUserAgent;
 vRESTConnectionDB.HandleRedirects  := vHandleRedirects;
 vRESTConnectionDB.RedirectMaximum  := vRedirectMaximum;
 vRESTConnectionDB.WelcomeMessage   := vWelcomeMessage;
 vRESTConnectionDB.Host             := vRestWebService;
 vRESTConnectionDB.Port             := vPoolerPort;
 vRESTConnectionDB.Compression      := vCompression;
 vRESTConnectionDB.TypeRequest      := VtypeRequest;
 vRESTConnectionDB.Encoding         := vEncoding;
 vRESTConnectionDB.EncodeStrings    := EncodeStrings;
 vRESTConnectionDB.OnWork           := vOnWork;
 vRESTConnectionDB.OnWorkBegin      := vOnWorkBegin;
 vRESTConnectionDB.OnWorkEnd        := vOnWorkEnd;
 vRESTConnectionDB.OnStatus         := vOnStatus;
 vRESTConnectionDB.AccessTag        := vAccessTag;
 vRESTConnectionDB.CriptOptions.Use := VCripto.Use;
 vRESTConnectionDB.CriptOptions.Key := VCripto.Key;
 vRESTConnectionDB.DataRoute        := DataRoute;
 vRESTConnectionDB.ServerContext    := ServerContext;
 vRESTConnectionDB.BinaryRequest    := BinaryRequest;
 vRESTConnectionDB.AuthenticationOptions.Assign(AuthenticationOptions);
 {$IFDEF FPC}
  vRESTConnectionDB.DatabaseCharSet := csUndefined;
 {$ENDIF}
 {Eloy - Adicionado mais um try para free de objects}
 Try
   Try
    vSQL           := SQL.Text;
    If Params.Count > 0 Then
     Begin
      DWParams     := GetDWParams(Params, vEncoding);
      LDataSetList := vRESTConnectionDB.ExecuteCommandJSON(vRestPooler,
                                                           vRestURL, vSQL,
                                                           DWParams, Error,
                                                           MessageError, SocketError, RowsAffected, Execute, BinaryRequest, BinaryCompatibleMode,
                                                           Metadata, vTimeOut, vConnectTimeOut, vClientConnectionDefs.vConnectionDefs, RESTClientPooler);
      FreeAndNil(DWParams);
     End
    Else
     LDataSetList := vRESTConnectionDB.ExecuteCommandPureJSON(vRestPooler,
                                                              vRestURL,
                                                              vSQL, Error,
                                                              MessageError, SocketError, RowsAffected, Execute, BinaryRequest, BinaryCompatibleMode,
                                                              Metadata, vTimeOut, vConnectTimeOut, vClientConnectionDefs.vConnectionDefs, RESTClientPooler);
    If SocketError Then
     Begin
      If vFailOver Then
       Begin
        If Assigned(LDataSetList) Then
         FreeAndNil(LDataSetList);
        For I := 0 To vFailOverConnections.Count -1 Do
         Begin
          If I = 0 Then
           Begin
            If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
                (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
                (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
                (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
                (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
                (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
                (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
                (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
                (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
                (vFailOverConnections[I].vRestURL        = vRestURL))                        Or
               (Not (vFailOverConnections[I].Active))                                        Then
            Continue;
           End;
          If Assigned(vOnFailOverExecute) Then
           vOnFailOverExecute(vFailOverConnections[I]);
          If Not Assigned(RESTClientPoolerExec) Then
           Begin
            vLocalClient := True;
            RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
           End;
          RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
          ReconfigureConnection(vRESTConnectionDB,
                                RESTClientPoolerExec,
                                vFailOverConnections[I].vTypeRequest,
                                vFailOverConnections[I].vWelcomeMessage,
                                vFailOverConnections[I].vRestWebService,
                                vFailOverConnections[I].vPoolerPort,
                                vFailOverConnections[I].vCompression,
                                vFailOverConnections[I].EncodeStrings,
                                vFailOverConnections[I].Encoding,
                                vFailOverConnections[I].vAccessTag,
                                vFailOverConnections[I].AuthenticationOptions);
          If Params.Count > 0 Then
           Begin
            DWParams     := GetDWParams(Params, vEncoding);
            LDataSetList := vRESTConnectionDB.ExecuteCommandJSON(vFailOverConnections[I].vRestPooler,
                                                                 vFailOverConnections[I].vRestURL, GetLineSQL(SQL),
                                                                 DWParams, Error,
                                                                 MessageError, SocketError, RowsAffected, Execute, BinaryRequest, BinaryCompatibleMode,
                                                                 Metadata, vTimeOut, vConnectTimeOut, vClientConnectionDefs.vConnectionDefs, RESTClientPooler);
            FreeAndNil(DWParams);
           End
          Else
           LDataSetList := vRESTConnectionDB.ExecuteCommandPureJSON(vFailOverConnections[I].vRestPooler,
                                                                    vFailOverConnections[I].vRestURL,
                                                                    GetLineSQL(SQL), Error,
                                                                    MessageError, SocketError, RowsAffected, Execute, BinaryRequest, BinaryCompatibleMode,
                                                                    Metadata, vTimeOut, vConnectTimeOut, vClientConnectionDefs.vConnectionDefs, RESTClientPooler);
          If Not SocketError Then
           Begin
            If vFailOverReplaceDefaults Then
             Begin
              vTypeRequest    := vRESTConnectionDB.TypeRequest;
              vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
              vRestWebService := vRESTConnectionDB.Host;
              vPoolerPort     := vRESTConnectionDB.Port;
              vCompression    := vRESTConnectionDB.Compression;
              vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
              vEncoding       := vRESTConnectionDB.Encoding;
              vAccessTag      := vRESTConnectionDB.AccessTag;
              vRestURL        := vFailOverConnections[I].vRestURL;
              vRestPooler     := vFailOverConnections[I].vRestPooler;
              vTimeOut        := vFailOverConnections[I].vTimeOut;
              vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
              vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
             End;
            Break;
           End;
         End;
       End;
     End;
    If (LDataSetList <> Nil) Then
     Begin
  //    If Not Assigned(Result) Then //Corre��o fornecida por romyllldo no Forum
      Result := TJSONValue.Create;
      Result.Encoding := vRESTConnectionDB.Encoding;
      Error  := Trim(MessageError) <> '';
      If Not BinaryRequest Then
       Begin
        If Not LDataSetList.IsNull Then
         vTempValue := LDataSetList.ToJSON;
       End
      Else
       Begin
        If Not LDataSetList.IsNull Then
         vTempValue := LDataSetList.Value;
       End;
      If (Trim(vTempValue) <> '{}') And
         (Trim(vTempValue) <> '')    And
         (Not (Error))                       Then
       Begin
        Try
         {$IFDEF  ANDROID}
         Result.Clear;
         If Not BinaryRequest Then
          Begin
           Result.Encoded := False;
           Result.LoadFromJSON(vTempValue);
          End
         Else
          Result.SetValue(LDataSetList.Value, False);
         {$ELSE}
          If Not BinaryRequest Then
           Result.LoadFromJSON(vTempValue)
          Else
           Begin
            If vTempValue <> '' Then
             Result.SetValue(vTempValue, False)
            Else
             Begin
              If Not LDataSetList.IsNull Then
               vTempValue := LDataSetList.ToJSON
             End;
           End;
         {$ENDIF}
        Finally
        End;
       End;
      vTempValue := '';
      If (Not (Error)) Then
       Begin
        If Assigned(vOnEventConnection) Then
         vOnEventConnection(True, 'ExecuteCommand Ok');
       End
      Else
       Begin
        If Assigned(vOnEventConnection) then
         vOnEventConnection(False, MessageError)
        Else
         Raise Exception.Create(PChar(MessageError));
       End;
     End
    Else
     Begin
      If Assigned(vOnEventConnection) Then
       vOnEventConnection(False, MessageError);
     End;
   Except
    On E : Exception do
     Begin
      if Assigned(vOnEventConnection) then
       vOnEventConnection(False, E.Message);
     End;
   End;
 Finally
   {Eloy - Adicionado mais um try para free de objects}
   If LDataSetList <> Nil Then
    FreeAndNil(LDataSetList);
   FreeAndNil(vRESTConnectionDB);
   If Assigned(RESTClientPoolerExec) And (vLocalClient) Then
    FreeAndNil(RESTClientPoolerExec);
 End;
End;

Procedure TRESTDWDataBase.ExecuteProcedure(Var PoolerMethodClient : TDWPoolerMethodClient;
                                           ProcName               : String;
                                           Params                 : TParams;
                                           Var Error              : Boolean;
                                           Var MessageError       : String);
Begin

End;

Function TRESTDWDataBase.GetRestPoolers : TStringList;
Var
 vConnection : TDWPoolerMethodClient;
 I           : Integer;
Begin
 Result                       := TStringList.Create;
 vConnection                  := TDWPoolerMethodClient.Create(Nil);
 vConnection.PoolerNotFoundMessage := PoolerNotFoundMessage;
 vConnection.UserAgent        := vUserAgent;
 vConnection.HandleRedirects  := vHandleRedirects;
 vConnection.RedirectMaximum  := vRedirectMaximum;
 vConnection.WelcomeMessage   := vWelcomeMessage;
 vConnection.Host             := vRestWebService;
 vConnection.Port             := vPoolerPort;
 vConnection.Compression      := vCompression;
 vConnection.TypeRequest      := VtypeRequest;
 vConnection.AccessTag        := vAccessTag;
 vConnection.Encoding         := Encoding;
 vConnection.CriptOptions.Use := VCripto.Use;
 vConnection.CriptOptions.Key := VCripto.Key;
 vConnection.DataRoute        := DataRoute;
 vConnection.ServerContext    := ServerContext;
 vConnection.AuthenticationOptions.Assign(AuthenticationOptions);
 Try
  If Assigned(vRestPoolers) Then
   FreeAndNil(vRestPoolers);
  vRestPoolers := vConnection.GetPoolerList(vRestURL, vTimeOut, vConnectTimeOut);
  Try
   If Assigned(vRestPoolers) Then
    Begin
     For I := 0 To vRestPoolers.Count -1 Do
      Result.Add(vRestPoolers[I]);
    End;
   If Assigned(vOnEventConnection) Then
    vOnEventConnection(True, 'GetRestPoolers Ok');
  Finally
   If Assigned(vConnection) Then
    FreeAndNil(vConnection);
  End;
 Except
  On E : Exception do
   Begin
    if Assigned(vOnEventConnection) then
     vOnEventConnection(False, E.Message);
   End;
 End;
 If Assigned(vConnection) Then
  FreeAndNil(vConnection);
End;

Function TRESTDWDataBase.GetServerEvents : TStringList;
Var
 vTempList   : TStringList;
 vConnection : TDWPoolerMethodClient;
 I           : Integer;
Begin
 vConnection                  := TDWPoolerMethodClient.Create(Nil);
 vConnection.PoolerNotFoundMessage := PoolerNotFoundMessage;
 vConnection.UserAgent        := vUserAgent;
 vConnection.HandleRedirects  := vHandleRedirects;
 vConnection.RedirectMaximum  := vRedirectMaximum;
 vConnection.WelcomeMessage   := vWelcomeMessage;
 vConnection.Host             := vRestWebService;
 vConnection.Port             := vPoolerPort;
 vConnection.Compression      := vCompression;
 vConnection.TypeRequest      := VtypeRequest;
 vConnection.AccessTag        := vAccessTag;
 vConnection.Encoding         := Encoding;
 vConnection.CriptOptions.Use := VCripto.Use;
 vConnection.CriptOptions.Key := VCripto.Key;
 vConnection.DataRoute        := DataRoute;
 vConnection.ServerContext    := ServerContext;
 vConnection.AuthenticationOptions.Assign(AuthenticationOptions);
 Result := TStringList.Create;
 Try
  vTempList := vConnection.GetServerEvents(vRestURL, vTimeOut, vConnectTimeOut);
  Try
   If Assigned(vTempList) Then
    For I := 0 To vTempList.Count -1 do
     Result.Add(vTempList[I]);
   If Assigned(vOnEventConnection) Then
    vOnEventConnection(True, 'GetServerEvents Ok');
  Finally
   If Assigned(vTempList) Then
    FreeAndNil(vTempList);
  End;
 Except
  On E : Exception do
   Begin
    if Assigned(vOnEventConnection) then
     vOnEventConnection(False, E.Message);
   End;
 End;
End;

Function TRESTDWDataBase.GetStateDB: Boolean;
Begin
 Result := vConnected;
End;

Constructor TRESTDWPoolerList.Create(AOwner : TComponent);
Begin
 Inherited;
 vDataRoute        := '';
 vServerContext    := '';
 vPoolerNotFoundMessage := cPoolerNotFound;
 vPoolerPort       := 8082;
 vTimeOut          := 3000;
 vConnectTimeOut   := 3000;
 vProxy            := False;
 vCompression      := True;
 vTypeRequest      := trHttp;
 vProxyOptions     := TProxyOptions.Create;
 vPoolerList       := TStringList.Create;
 vAuthOptionParams := TRDWClientAuthOptionParams.Create(Self);
 vCripto           := TCripto.Create;
 vEncoding         := esUtf8;
 vUserAgent        := cUserAgent;
 vHandleRedirects  := False;
 vRedirectMaximum  := 0;
End;

Constructor TRESTDWDataBase.Create(AOwner : TComponent);
Begin
 Inherited;
 vHandleRedirects          := False;
 vRedirectMaximum          := 0;
 vConnected                := False;
 vPoolerNotFoundMessage    := cPoolerNotFound;
 vAuthOptionParams         := TRDWClientAuthOptionParams.Create(Self);
 vAuthOptionParams.AuthorizationOption := rdwAONone;
 vDataRoute                := '';
 vServerContext            := '';
 vMyIP                     := '0.0.0.0';
 vRestWebService           := '127.0.0.1';
 vCompression              := True;
 vRestPooler               := '';
 vPoolerPort               := 8082;
 vProxy                    := False;
 vEncodeStrings            := True;
 vFailOver                 := False;
 vFailOverReplaceDefaults  := False;
 vRestPoolers              := Nil;
 vProxyOptions             := TProxyOptions.Create;
 vCripto                   := TCripto.Create;
 vAutoCheckData            := TAutoCheckData.Create;
 vClientConnectionDefs     := TClientConnectionDefs.Create(Self);
 vFailOverConnections      := TListDefConnections.Create(Self, TRESTDWConnectionServer);
 vAutoCheckData.vAutoCheck := False;
 vAutoCheckData.vInTime    := 1000;
 vTimeOut                  := 10000;
 vConnectTimeOut                  := 3000;
 vUserAgent                := cUserAgent;
 {$IFNDEF FPC}
 {$IF CompilerVersion > 21}
  vEncoding                := esUtf8;
 {$ELSE}
  vEncoding                := esAscii;
 {$IFEND}
 {$ELSE}
  vEncoding                := esUtf8;
 {$ENDIF}
 vContentex                := '';
 vStrsTrim                 := False;
 vStrsEmpty2Null           := False;
 vStrsTrim2Len             := True;
 vParamCreate              := True;
End;

Destructor  TRESTDWPoolerList.Destroy;
Begin
 vProxyOptions.Free;
 FreeAndNil(vAuthOptionParams);
 FreeAndNil(vCripto);
 If vPoolerList <> Nil Then
  vPoolerList.Free;
 Inherited;
End;

Destructor  TRESTDWDataBase.Destroy;
Begin
 vAutoCheckData.vAutoCheck := False;
 If Assigned(vRestPoolers) Then
  FreeAndNil(vRestPoolers);
 FreeAndNil(vProxyOptions);
 FreeAndNil(vAutoCheckData);
 FreeAndNil(vClientConnectionDefs);
 FreeAndNil(vFailOverConnections);
 If Assigned(vAuthOptionParams) Then
  FreeAndNil(vAuthOptionParams);
 FreeAndNil(vCripto);
 Inherited;
End;

Procedure TRESTDWDataBase.ProcessMassiveSQLCache(Var MassiveSQLCache    : TDWMassiveCacheSQLList;
                                                 Var Error              : Boolean;
                                                 Var MessageError       : String);
Var
 I                    : Integer;
 vUpdateLine          : String;
 vRESTConnectionDB    : TDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPooler;
 ResultData           : TJSONValue;
 SocketError          : Boolean;
Begin
 SocketError := False; //Leandro 11/08/2020
 RESTClientPoolerExec := nil; //Leandro 11/08/2020
 If MassiveSQLCache.Count > 0 Then
  Begin
   vUpdateLine := MassiveSQLCache.ToJSON;
   If vRestPooler = '' Then
    Exit;
   If Not vConnected Then
    SetConnection(True);
   If vConnected Then
    Begin
     vRESTConnectionDB                  := TDWPoolerMethodClient.Create(Nil);
     vRESTConnectionDB.PoolerNotFoundMessage := PoolerNotFoundMessage;
     vRESTConnectionDB.UserAgent        := vUserAgent;
     vRESTConnectionDB.HandleRedirects  := vHandleRedirects;
     vRESTConnectionDB.RedirectMaximum  := vRedirectMaximum;
     vRESTConnectionDB.WelcomeMessage   := vWelcomeMessage;
     vRESTConnectionDB.Host             := vRestWebService;
     vRESTConnectionDB.Port             := vPoolerPort;
     vRESTConnectionDB.Compression      := vCompression;
     vRESTConnectionDB.TypeRequest      := VtypeRequest;
     vRESTConnectionDB.Encoding         := vEncoding;
     vRESTConnectionDB.AccessTag        := vAccessTag;
     vRESTConnectionDB.CriptOptions.Use := VCripto.Use;
     vRESTConnectionDB.CriptOptions.Key := VCripto.Key;
     vRESTConnectionDB.DataRoute        := DataRoute;
     vRESTConnectionDB.ServerContext    := ServerContext;
     vRESTConnectionDB.AuthenticationOptions.Assign(AuthenticationOptions);
     {$IFNDEF FPC}
     vRESTConnectionDB.OnWork          := vOnWork;
     vRESTConnectionDB.OnWorkBegin     := vOnWorkBegin;
     vRESTConnectionDB.OnWorkEnd       := vOnWorkEnd;
     vRESTConnectionDB.OnStatus        := vOnStatus;
     {$ELSE}
     vRESTConnectionDB.OnWork          := vOnWork;
     vRESTConnectionDB.OnWorkBegin     := vOnWorkBegin;
     vRESTConnectionDB.OnWorkEnd       := vOnWorkEnd;
     vRESTConnectionDB.OnStatus        := vOnStatus;
     vRESTConnectionDB.DatabaseCharSet := csUndefined;
     {$ENDIF}
     Try
      For I := 0 To 1 Do
       Begin
        ResultData := vRESTConnectionDB.ProcessMassiveSQLCache(vUpdateLine, vRestPooler,  vRestURL,
                                                               Error,       MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                               vClientConnectionDefs.vConnectionDefs);
        If Not(Error) or (MessageError <> cInvalidAuth) Then
         Break
        Else
         Begin
          Case AuthenticationOptions.AuthorizationOption Of
           rdwAOBearer : Begin
                          If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                           Begin
                            If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                               (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                             TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                            TryConnect;
                           End;
                         End;
           rdwAOToken  : Begin
                          If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                           Begin
                            If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                               (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                             TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                            TryConnect;
                           End;
                         End;
          End;
         End;
       End;
      If SocketError Then
       Begin
        If vFailOver Then
         Begin
          If Assigned(ResultData) Then
           FreeAndNil(ResultData);
          For I := 0 To vFailOverConnections.Count -1 Do
           Begin
            If I = 0 Then
             Begin
              If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
                  (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
                  (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
                  (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
                  (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
                  (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
                  (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
                  (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
                  (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
                  (vFailOverConnections[I].vRestURL        = vRestURL))                        Or
                  (Not (vFailOverConnections[I].Active))                                       Then
              Continue;
             End;
            If Assigned(vOnFailOverExecute) Then
             vOnFailOverExecute(vFailOverConnections[I]);
            If Not Assigned(RESTClientPoolerExec) Then
             RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
            RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
            ReconfigureConnection(vRESTConnectionDB,
                                  RESTClientPoolerExec,
                                  vFailOverConnections[I].vTypeRequest,
                                  vFailOverConnections[I].vWelcomeMessage,
                                  vFailOverConnections[I].vRestWebService,
                                  vFailOverConnections[I].vPoolerPort,
                                  vFailOverConnections[I].vCompression,
                                  vFailOverConnections[I].EncodeStrings,
                                  vFailOverConnections[I].Encoding,
                                  vFailOverConnections[I].vAccessTag,
                                  vFailOverConnections[I].AuthenticationOptions);
            ResultData := vRESTConnectionDB.ProcessMassiveSQLCache(vUpdateLine,
                                                                   vFailOverConnections[I].vRestPooler,
                                                                   vFailOverConnections[I].vRestURL,
                                                                   Error,       MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                                   vClientConnectionDefs.vConnectionDefs);
            If Not SocketError Then
             Begin
              If vFailOverReplaceDefaults Then
               Begin
                vTypeRequest    := vRESTConnectionDB.TypeRequest;
                vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
                vRestWebService := vRESTConnectionDB.Host;
                vPoolerPort     := vRESTConnectionDB.Port;
                vCompression    := vRESTConnectionDB.Compression;
                vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
                vEncoding       := vRESTConnectionDB.Encoding;
                vAccessTag      := vRESTConnectionDB.AccessTag;
                vRestURL        := vFailOverConnections[I].vRestURL;
                vRestPooler     := vFailOverConnections[I].vRestPooler;
                vTimeOut        := vFailOverConnections[I].vTimeOut;
                vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
                vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
               End;
              Break;
             End;
           End;
         End;
       End;
     Finally
      If Not Error Then
       MassiveSQLCache.Clear;
//      If Assigned(ResultData) Then
//       If (ResultData.Value <> '') Then
//        MassiveSQLCache.ProcessChanges(ResultData.Value);
      If Assigned(ResultData) Then
       FreeAndNil(ResultData);
      FreeAndNil(vRESTConnectionDB);
     End;
    End;
  End;
End;

Procedure TRESTDWDataBase.ProcessMassiveSQLCache(Var MassiveSQLCache    : TDWMassiveSQLCache;
                                                 Var Error              : Boolean;
                                                 Var MessageError       : String);
Var
 I                    : Integer;
 vUpdateLine          : String;
 vRESTConnectionDB    : TDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPooler;
 ResultData           : TJSONValue;
 SocketError          : Boolean;
Begin
 SocketError := False; //Leandro 11/08/2020
 RESTClientPoolerExec := nil; //Leandro 11/08/2020
 If MassiveSQLCache.MassiveCount > 0 Then
  Begin
   vUpdateLine := MassiveSQLCache.ToJSON;
   If vRestPooler = '' Then
    Exit;
   If Not vConnected Then
    SetConnection(True);
   If vConnected Then
    Begin
     vRESTConnectionDB                  := TDWPoolerMethodClient.Create(Nil);
     vRESTConnectionDB.PoolerNotFoundMessage := PoolerNotFoundMessage;
     vRESTConnectionDB.UserAgent        := vUserAgent;
     vRESTConnectionDB.HandleRedirects  := vHandleRedirects;
     vRESTConnectionDB.RedirectMaximum  := vRedirectMaximum;
     vRESTConnectionDB.WelcomeMessage   := vWelcomeMessage;
     vRESTConnectionDB.Host             := vRestWebService;
     vRESTConnectionDB.Port             := vPoolerPort;
     vRESTConnectionDB.Compression      := vCompression;
     vRESTConnectionDB.TypeRequest      := VtypeRequest;
     vRESTConnectionDB.Encoding         := vEncoding;
     vRESTConnectionDB.AccessTag        := vAccessTag;
     vRESTConnectionDB.CriptOptions.Use := VCripto.Use;
     vRESTConnectionDB.CriptOptions.Key := VCripto.Key;
     vRESTConnectionDB.DataRoute        := DataRoute;
     vRESTConnectionDB.ServerContext    := ServerContext;
     vRESTConnectionDB.AuthenticationOptions.Assign(AuthenticationOptions);
     {$IFNDEF FPC}
     vRESTConnectionDB.OnWork          := vOnWork;
     vRESTConnectionDB.OnWorkBegin     := vOnWorkBegin;
     vRESTConnectionDB.OnWorkEnd       := vOnWorkEnd;
     vRESTConnectionDB.OnStatus        := vOnStatus;
     {$ELSE}
     vRESTConnectionDB.OnWork          := vOnWork;
     vRESTConnectionDB.OnWorkBegin     := vOnWorkBegin;
     vRESTConnectionDB.OnWorkEnd       := vOnWorkEnd;
     vRESTConnectionDB.OnStatus        := vOnStatus;
     vRESTConnectionDB.DatabaseCharSet := csUndefined;
     {$ENDIF}
     Try
      For I := 0 To 1 Do
       Begin
        ResultData := vRESTConnectionDB.ProcessMassiveSQLCache(vUpdateLine, vRestPooler,  vRestURL,
                                                               Error,       MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                               vClientConnectionDefs.vConnectionDefs);
        If Not(Error) or (MessageError <> cInvalidAuth) Then
         Break
        Else
         Begin
          Case AuthenticationOptions.AuthorizationOption Of
           rdwAOBearer : Begin
                          If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                           Begin
                            If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                               (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                             TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                            TryConnect;
                           End;
                         End;
           rdwAOToken  : Begin
                          If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                           Begin
                            If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                               (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                             TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                            TryConnect;
                           End;
                         End;
          End;
         End;
       End;
      If SocketError Then
       Begin
        If vFailOver Then
         Begin
          If Assigned(ResultData) Then
           FreeAndNil(ResultData);
          For I := 0 To vFailOverConnections.Count -1 Do
           Begin
            If I = 0 Then
             Begin
              If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
                  (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
                  (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
                  (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
                  (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
                  (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
                  (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
                  (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
                  (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
                  (vFailOverConnections[I].vRestURL        = vRestURL))                        Or
                  (Not (vFailOverConnections[I].Active))                                       Then
              Continue;
             End;
            If Assigned(vOnFailOverExecute) Then
             vOnFailOverExecute(vFailOverConnections[I]);
            If Not Assigned(RESTClientPoolerExec) Then
             RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
            RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
            ReconfigureConnection(vRESTConnectionDB,
                                  RESTClientPoolerExec,
                                  vFailOverConnections[I].vTypeRequest,
                                  vFailOverConnections[I].vWelcomeMessage,
                                  vFailOverConnections[I].vRestWebService,
                                  vFailOverConnections[I].vPoolerPort,
                                  vFailOverConnections[I].vCompression,
                                  vFailOverConnections[I].EncodeStrings,
                                  vFailOverConnections[I].Encoding,
                                  vFailOverConnections[I].vAccessTag,
                                  vFailOverConnections[I].AuthenticationOptions);
            ResultData := vRESTConnectionDB.ProcessMassiveSQLCache(vUpdateLine,
                                                                   vFailOverConnections[I].vRestPooler,
                                                                   vFailOverConnections[I].vRestURL,
                                                                   Error,       MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                                   vClientConnectionDefs.vConnectionDefs);
            If Not SocketError Then
             Begin
              If vFailOverReplaceDefaults Then
               Begin
                vTypeRequest    := vRESTConnectionDB.TypeRequest;
                vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
                vRestWebService := vRESTConnectionDB.Host;
                vPoolerPort     := vRESTConnectionDB.Port;
                vCompression    := vRESTConnectionDB.Compression;
                vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
                vEncoding       := vRESTConnectionDB.Encoding;
                vAccessTag      := vRESTConnectionDB.AccessTag;
                vRestURL        := vFailOverConnections[I].vRestURL;
                vRestPooler     := vFailOverConnections[I].vRestPooler;
                vTimeOut        := vFailOverConnections[I].vTimeOut;
                vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
                vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
               End;
              Break;
             End;
           End;
         End;
       End;
     Finally
      If Not Error Then
       MassiveSQLCache.Clear;
//      If Assigned(ResultData) Then
//       If (ResultData.Value <> '') Then
//        MassiveSQLCache.ProcessChanges(ResultData.Value);
      If Assigned(ResultData) Then
       FreeAndNil(ResultData);
      FreeAndNil(vRESTConnectionDB);
     End;
    End;
  End;
End;

Procedure TRESTDWDataBase.ApplyUpdates(Datasets               : Array of {$IFDEF FPC}TRESTDWClientSQLBase{$ELSE}TObject{$ENDIF};
                                       Var Error              : Boolean;
                                       Var MessageError       : String);
Var
 vJsonLine,
 vLinesDS             : String;
 vJsonCount,
 I                    : Integer;
 vRESTConnectionDB    : TDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPooler;
 vJSONValue           : TJSONValue;
 vJsonValueB          : TDWJSONBase;
 vJsonArray           : TDWJSONArray;
 vJsonOBJ             : TDWJSONObject;
 SocketError          : Boolean;
 vStream              : TMemoryStream;
Begin
 vStream := Nil;
 vLinesDS  := '';
 vJsonLine := '';
 For I := 0 To Length(Datasets) -1 Do
  Begin
   vJsonLine := TRESTDWClientSQL(Datasets[I]).UpdateSQL.ToJSON;
   If (vLinesDS = '') And (vJsonLine <> '') Then
    vLinesDS := vJsonLine
   Else If (vJsonLine <> '') Then
    vLinesDS := Format('%s, %s', [vLinesDS, vJsonLine]);
  End;
 If vLinesDS <> '' Then
  vLinesDS := Format('[%s]', [vLinesDS])
 Else
  vLinesDS := '[]';
 vJsonLine := '';
 if vRestPooler = '' then
  Exit;
 vRESTConnectionDB                  := TDWPoolerMethodClient.Create(Nil);
 vRESTConnectionDB.PoolerNotFoundMessage := PoolerNotFoundMessage;
 vRESTConnectionDB.UserAgent        := vUserAgent;
 vRESTConnectionDB.HandleRedirects  := vHandleRedirects;
 vRESTConnectionDB.RedirectMaximum  := vRedirectMaximum;
 vRESTConnectionDB.WelcomeMessage   := vWelcomeMessage;
 vRESTConnectionDB.Host             := vRestWebService;
 vRESTConnectionDB.Port             := vPoolerPort;
 vRESTConnectionDB.Compression      := vCompression;
 vRESTConnectionDB.TypeRequest      := VtypeRequest;
 vRESTConnectionDB.Encoding         := vEncoding;
 vRESTConnectionDB.AccessTag        := vAccessTag;
 vRESTConnectionDB.CriptOptions.Use := VCripto.Use;
 vRESTConnectionDB.CriptOptions.Key := VCripto.Key;
 vRESTConnectionDB.DataRoute        := DataRoute;
 vRESTConnectionDB.ServerContext    := ServerContext;
 vRESTConnectionDB.AuthenticationOptions.Assign(AuthenticationOptions);
 {$IFNDEF FPC}
  vRESTConnectionDB.OnWork          := vOnWork;
  vRESTConnectionDB.OnWorkBegin     := vOnWorkBegin;
  vRESTConnectionDB.OnWorkEnd       := vOnWorkEnd;
  vRESTConnectionDB.OnStatus        := vOnStatus;
 {$ELSE}
  vRESTConnectionDB.OnWork          := vOnWork;
  vRESTConnectionDB.OnWorkBegin     := vOnWorkBegin;
  vRESTConnectionDB.OnWorkEnd       := vOnWorkEnd;
  vRESTConnectionDB.OnStatus        := vOnStatus;
  vRESTConnectionDB.DatabaseCharSet := csUndefined;
 {$ENDIF}
 Try
  For I := 0 To 1 Do
   Begin
    vLinesDS := vRESTConnectionDB.ApplyUpdates(vLinesDS, vRestPooler,  vRestURL,
                                               Error,    MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                               vClientConnectionDefs.vConnectionDefs);
    If Not(Error) or (MessageError <> cInvalidAuth) Then
     Break
    Else
     Begin
      Case AuthenticationOptions.AuthorizationOption Of
       rdwAOBearer : Begin
                      If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                           (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                         TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect;
                       End;
                     End;
       rdwAOToken  : Begin
                      If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                           (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                         TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect;
                       End;
                     End;
      End;
     End;
   End;
  If SocketError Then
   Begin
    If vFailOver Then
     Begin
      vLinesDS := '';
      For I := 0 To vFailOverConnections.Count -1 Do
       Begin
        If I = 0 Then
         Begin
          If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
              (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
              (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
              (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
              (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
              (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
              (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
              (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
              (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
              (vFailOverConnections[I].vRestURL        = vRestURL))                        Or
             (Not (vFailOverConnections[I].Active))                                        Then
          Continue;
         End;
        If Assigned(vOnFailOverExecute) Then
         vOnFailOverExecute(vFailOverConnections[I]);
        If Not Assigned(RESTClientPoolerExec) Then
         RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
        RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
        ReconfigureConnection(vRESTConnectionDB,
                              RESTClientPoolerExec,
                              vFailOverConnections[I].vTypeRequest,
                              vFailOverConnections[I].vWelcomeMessage,
                              vFailOverConnections[I].vRestWebService,
                              vFailOverConnections[I].vPoolerPort,
                              vFailOverConnections[I].vCompression,
                              vFailOverConnections[I].EncodeStrings,
                              vFailOverConnections[I].Encoding,
                              vFailOverConnections[I].vAccessTag,
                              vFailOverConnections[I].AuthenticationOptions);
        vLinesDS := vRESTConnectionDB.ApplyUpdates(vLinesDS, vFailOverConnections[I].vRestPooler,  vFailOverConnections[I].vRestURL,
                                                   Error,    MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                   vClientConnectionDefs.vConnectionDefs);
        If Not SocketError Then
         Begin
          If vFailOverReplaceDefaults Then
           Begin
            vTypeRequest    := vRESTConnectionDB.TypeRequest;
            vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
            vRestWebService := vRESTConnectionDB.Host;
            vPoolerPort     := vRESTConnectionDB.Port;
            vCompression    := vRESTConnectionDB.Compression;
            vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
            vEncoding       := vRESTConnectionDB.Encoding;
            vAccessTag      := vRESTConnectionDB.AccessTag;
            vRestURL        := vFailOverConnections[I].vRestURL;
            vRestPooler     := vFailOverConnections[I].vRestPooler;
            vTimeOut        := vFailOverConnections[I].vTimeOut;
            vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
            vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
           End;
          Break;
         End;
       End;
     End;
   End;
  If Not Error Then
   Begin
    vJSONValue := TJSONValue.Create;
    vJSONValue.Encoded  := True;
    vJSONValue.Encoding := vEncoding;
    vJSONValue.LoadFromJSON(vLinesDS);
    vJsonLine := vJSONValue.value;
    FreeAndNil(vJSONValue);
    vJsonOBJ   := TDWJSONObject.Create(vJsonLine);
    vJsonArray := TDWJSONArray(vJsonOBJ);
    Try
     For I := 0 To vJsonArray.ElementCount -1 do
      Begin
       vJsonValueB  := vJsonArray.GetObject(I);
       vJsonCount := 0;
       vJSONValue := TJSONValue.Create;
       vJSONValue.Utf8SpecialChars := True;
       Try
        vJSONValue.Encoding := vEncoding;
        If Not TRESTDWClientSQL(Datasets[I]).BinaryRequest Then
         Begin
          vJSONValue.LoadFromJSON(TDWJSONObject(vJsonValueB).ToJson);
          vJSONValue.Encoded := True;
          vJSONValue.OnWriterProcess := TRESTDWClientSQL(Datasets[I]).OnWriterProcess;
          vJSONValue.ServerFieldList := TRESTDWClientSQL(Datasets[I]).ServerFieldList;
          {$IFDEF FPC}
           vJSONValue.DatabaseCharSet := TRESTDWClientSQL(Datasets[I]).DatabaseCharSet;
           vJSONValue.NewFieldList    := @TRESTDWClientSQL(Datasets[I]).NewFieldList;
           vJSONValue.CreateDataSet   := @TRESTDWClientSQL(Datasets[I]).CreateDataSet;
           vJSONValue.NewDataField    := @TRESTDWClientSQL(Datasets[I]).NewDataField;
           vJSONValue.SetInitDataset  := @TRESTDWClientSQL(Datasets[I]).SetInitDataset;
           vJSONValue.SetRecordCount     := @TRESTDWClientSQL(Datasets[I]).SetRecordCount;
           vJSONValue.Setnotrepage       := @TRESTDWClientSQL(Datasets[I]).Setnotrepage;
           vJSONValue.SetInDesignEvents  := @TRESTDWClientSQL(Datasets[I]).SetInDesignEvents;
           vJSONValue.SetInBlockEvents   := @TRESTDWClientSQL(Datasets[I]).SetInBlockEvents;
           vJSONValue.SetInactive        := @TRESTDWClientSQL(Datasets[I]).SetInactive;
           vJSONValue.FieldListCount     := @TRESTDWClientSQL(Datasets[I]).FieldListCount;
           vJSONValue.GetInDesignEvents  := @TRESTDWClientSQL(Datasets[I]).GetInDesignEvents;
           vJSONValue.PrepareDetailsNew  := @TRESTDWClientSQL(Datasets[I]).PrepareDetailsNew;
           vJSONValue.PrepareDetails     := @TRESTDWClientSQL(Datasets[I]).PrepareDetails;
          {$ELSE}
           vJSONValue.NewFieldList    := TRESTDWClientSQL(Datasets[I]).NewFieldList;
           vJSONValue.CreateDataSet   := TRESTDWClientSQL(Datasets[I]).CreateDataSet;
           vJSONValue.NewDataField    := TRESTDWClientSQL(Datasets[I]).NewDataField;
           vJSONValue.SetInitDataset  := TRESTDWClientSQL(Datasets[I]).SetInitDataset;
           vJSONValue.SetRecordCount     := TRESTDWClientSQL(Datasets[I]).SetRecordCount;
           vJSONValue.Setnotrepage       := TRESTDWClientSQL(Datasets[I]).Setnotrepage;
           vJSONValue.SetInDesignEvents  := TRESTDWClientSQL(Datasets[I]).SetInDesignEvents;
           vJSONValue.SetInBlockEvents   := TRESTDWClientSQL(Datasets[I]).SetInBlockEvents;
           vJSONValue.SetInactive        := TRESTDWClientSQL(Datasets[I]).SetInactive;
           vJSONValue.FieldListCount     := TRESTDWClientSQL(Datasets[I]).FieldListCount;
           vJSONValue.GetInDesignEvents  := TRESTDWClientSQL(Datasets[I]).GetInDesignEvents;
           vJSONValue.PrepareDetailsNew  := TRESTDWClientSQL(Datasets[I]).PrepareDetailsNew;
           vJSONValue.PrepareDetails     := TRESTDWClientSQL(Datasets[I]).PrepareDetails;
          {$ENDIF}
          vJSONValue.WriteToDataset(dtDiff, vJSONValue.ToJSON, TRESTDWClientSQL(Datasets[I]),
                                   vJsonCount, TRESTDWClientSQL(Datasets[I]).Datapacks); //TODO Somente esse Registro
          TRESTDWClientSQL(Datasets[I]).vActualJSON := vJSONValue.ToJSON;
         End
        Else
         Begin
          {   //TODO
          vStream := Decodeb64Stream(TDWJSONObject(vJsonValueB).pairs[0].value);
          TRESTDWClientSQLBase(Datasets[I]).LoadFromStream(vStream);
          TRESTDWClientSQL(Datasets[I]).DisableControls;
          Try
           TRESTDWClientSQL(Datasets[I]).Last;
           vJsonCount := TRESTDWClientSQLBase(Datasets[I]).RecNo;
           TRESTDWClientSQL(Datasets[I]).First;
          Finally
           TRESTDWClientSQL(Datasets[I]).EnableControls;
           If Assigned(vStream) Then
            vStream.Free;
           If TRESTDWClientSQL(Datasets[I]).State = dsBrowse Then
            Begin
             If TRESTDWClientSQL(Datasets[I]).RecordCount = 0 Then
              TRESTDWClientSQL(Datasets[I]).PrepareDetailsNew
             Else
              TRESTDWClientSQL(Datasets[I]).PrepareDetails(True);
            End;
          End;
          }
         End;
        TRESTDWClientSQL(Datasets[I]).CreateMassiveDataset;
       Finally
        FreeAndNil(vJSONValue);
        FreeAndNil(vJsonValueB);
       End;
      End;
    Finally
     FreeAndNil(vJsonArray);
    End;
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

Procedure TRESTDWDataBase.ApplyUpdates(Var MassiveCache : TDWMassiveCache);
Var
 vError        : Boolean;
 vMessageError : String;
Begin
 vMessageError := '';
 ApplyUpdates(MassiveCache, vError, vMessageError);
 If (vError) Or (vMessageError <> '') Then
  Raise Exception.Create(PChar(vMessageError));
End;

Procedure TRESTDWDataBase.ApplyUpdates(Var MassiveCache       : TDWMassiveCache;
                                       Var Error              : Boolean;
                                       Var MessageError       : String);
Var
 I                    : Integer;
 vUpdateLine          : String;
 vRESTConnectionDB    : TDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPooler;
 ResultData           : TJSONValue;
 vLocalClient,
 SocketError          : Boolean;
Begin
 vLocalClient := False;
 SocketError := False; //Leandro 11/08/2020
 RESTClientPoolerExec := nil; //Leandro 11/08/2020
 If MassiveCache.MassiveCount > 0 Then
  Begin
   vUpdateLine := MassiveCache.ToJSON;
   If vRestPooler = '' Then
    Exit;
   If Not vConnected Then
    SetConnection(True);
   If vConnected Then
    Begin
     vRESTConnectionDB                  := TDWPoolerMethodClient.Create(Nil);
     vRESTConnectionDB.PoolerNotFoundMessage := PoolerNotFoundMessage;
     vRESTConnectionDB.UserAgent        := vUserAgent;
     vRESTConnectionDB.HandleRedirects  := vHandleRedirects;
     vRESTConnectionDB.RedirectMaximum  := vRedirectMaximum;
     vRESTConnectionDB.WelcomeMessage   := vWelcomeMessage;
     vRESTConnectionDB.Host             := vRestWebService;
     vRESTConnectionDB.Port             := vPoolerPort;
     vRESTConnectionDB.Compression      := vCompression;
     vRESTConnectionDB.TypeRequest      := VtypeRequest;
     vRESTConnectionDB.Encoding         := vEncoding;
     vRESTConnectionDB.AccessTag        := vAccessTag;
     vRESTConnectionDB.CriptOptions.Use := VCripto.Use;
     vRESTConnectionDB.CriptOptions.Key := VCripto.Key;
     vRESTConnectionDB.DataRoute        := DataRoute;
     vRESTConnectionDB.ServerContext    := ServerContext;
     vRESTConnectionDB.AuthenticationOptions.Assign(AuthenticationOptions);
     {$IFNDEF FPC}
     vRESTConnectionDB.OnWork           := vOnWork;
     vRESTConnectionDB.OnWorkBegin      := vOnWorkBegin;
     vRESTConnectionDB.OnWorkEnd        := vOnWorkEnd;
     vRESTConnectionDB.OnStatus         := vOnStatus;
     {$ELSE}
     vRESTConnectionDB.OnWork           := vOnWork;
     vRESTConnectionDB.OnWorkBegin      := vOnWorkBegin;
     vRESTConnectionDB.OnWorkEnd        := vOnWorkEnd;
     vRESTConnectionDB.OnStatus         := vOnStatus;
     vRESTConnectionDB.DatabaseCharSet  := csUndefined;
     {$ENDIF}
     Try
      For I := 0 To 1 Do
       Begin
        ResultData := vRESTConnectionDB.ApplyUpdates_MassiveCache(vUpdateLine, vRestPooler,  vRestURL,
                                                                  Error,       MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                                  vClientConnectionDefs.vConnectionDefs,
                                                                  MassiveCache.ReflectChanges);
        If Not(Error) or (MessageError <> cInvalidAuth) Then
         Break
        Else
         Begin
          Case AuthenticationOptions.AuthorizationOption Of
           rdwAOBearer : Begin
                          If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                           Begin
                            If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                               (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                             TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                            TryConnect;
                           End;
                         End;
           rdwAOToken  : Begin
                          If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                           Begin
                            If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                               (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                             TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                            TryConnect;
                           End;
                         End;
          End;
         End;
       End;
      If SocketError Then
       Begin
        If vFailOver Then
         Begin
          If Assigned(ResultData) Then
           FreeAndNil(ResultData);
          For I := 0 To vFailOverConnections.Count -1 Do
           Begin
            If I = 0 Then
             Begin
              If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
                  (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
                  (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
                  (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
                  (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
                  (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
                  (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
                  (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
                  (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
                  (vFailOverConnections[I].vRestURL        = vRestURL))                        Or
                  (Not (vFailOverConnections[I].Active))                                       Then
              Continue;
             End;
            If Assigned(vOnFailOverExecute) Then
             vOnFailOverExecute(vFailOverConnections[I]);
            If Not Assigned(RESTClientPoolerExec) Then
             Begin
              vLocalClient := True;
              RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
             End;
            RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
            ReconfigureConnection(vRESTConnectionDB,
                                  RESTClientPoolerExec,
                                  vFailOverConnections[I].vTypeRequest,
                                  vFailOverConnections[I].vWelcomeMessage,
                                  vFailOverConnections[I].vRestWebService,
                                  vFailOverConnections[I].vPoolerPort,
                                  vFailOverConnections[I].vCompression,
                                  vFailOverConnections[I].EncodeStrings,
                                  vFailOverConnections[I].Encoding,
                                  vFailOverConnections[I].vAccessTag,
                                  vFailOverConnections[I].AuthenticationOptions);
            If Assigned(ResultData) Then
             FreeAndNil(ResultData);
            ResultData := vRESTConnectionDB.ApplyUpdates_MassiveCache(vUpdateLine,
                                                                      vFailOverConnections[I].vRestPooler,
                                                                      vFailOverConnections[I].vRestURL,
                                                                      Error,       MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                                      vClientConnectionDefs.vConnectionDefs,
                                                                      MassiveCache.ReflectChanges);
            If Not SocketError Then
             Begin
              If vFailOverReplaceDefaults Then
               Begin
                vTypeRequest    := vRESTConnectionDB.TypeRequest;
                vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
                vRestWebService := vRESTConnectionDB.Host;
                vPoolerPort     := vRESTConnectionDB.Port;
                vCompression    := vRESTConnectionDB.Compression;
                vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
                vEncoding       := vRESTConnectionDB.Encoding;
                vAccessTag      := vRESTConnectionDB.AccessTag;
                vRestURL        := vFailOverConnections[I].vRestURL;
                vRestPooler     := vFailOverConnections[I].vRestPooler;
                vTimeOut        := vFailOverConnections[I].vTimeOut;
                vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
                vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
               End;
              Break;
             End;
           End;
         End;
       End;
     Finally
      MassiveCache.Clear;
      If Assigned(ResultData) Then
       If Not(ResultData.IsNull) Then
        MassiveCache.ProcessChanges(ResultData.Value);
      If Assigned(ResultData) Then
       FreeAndNil(ResultData);
      FreeAndNil(vRESTConnectionDB);
      If Not Error Then
       Error := MessageError <> '';
     End;
    End;
  End;
 If Assigned(RESTClientPoolerExec) And (vLocalClient) Then
  FreeAndNil(RESTClientPoolerExec);
End;

Procedure TRESTDWDataBase.Close;
Begin
 SetConnection(False);
End;

Function  TRESTDWPoolerList.TryConnect : Boolean;
Var
 vConnection : TDWPoolerMethodClient;
 I           : Integer;
Begin
 vConnection                  := TDWPoolerMethodClient.Create(Nil);
 vConnection.PoolerNotFoundMessage := PoolerNotFoundMessage;
 vConnection.UserAgent        := vUserAgent;
 vConnection.HandleRedirects  := vHandleRedirects;
 vConnection.RedirectMaximum  := vRedirectMaximum;
 vConnection.WelcomeMessage   := vWelcomeMessage;
 vConnection.Host             := vRestWebService;
 vConnection.Port             := vPoolerPort;
 vConnection.Compression      := vCompression;
 vConnection.TypeRequest      := VtypeRequest;
 vConnection.AccessTag        := vAccessTag;
 vConnection.Encoding         := Encoding;
 vConnection.CriptOptions.Use := VCripto.Use;
 vConnection.CriptOptions.Key := VCripto.Key;
 vConnection.DataRoute        := DataRoute;
 vConnection.ServerContext    := ServerContext;
 vConnection.AuthenticationOptions.Assign(AuthenticationOptions);
 Try
  vPoolerList.Clear;
  vPoolerList.Assign(vConnection.GetPoolerList(vRestURL, vTimeOut, vConnectTimeOut));
  Result      := True;
 Finally
  If Assigned(vConnection) Then
   FreeAndNil(vConnection);
 End;
End;

Procedure TRESTDWDataBase.ReconfigureConnection(Var Connection        : TDWPoolerMethodClient;
                                                Var ConnectionExec    : TRESTClientPooler;
                                                TypeRequest           : Ttyperequest;
                                                WelcomeMessage,
                                                Host                  : String;
                                                Port                  : Integer;
                                                Compression,
                                                EncodeStrings         : Boolean;
                                                Encoding              : TEncodeSelect;
                                                AccessTag             : String;
                                                AuthenticationOptions : TRDWClientAuthOptionParams);
Begin
 Connection.TypeRequest               := TypeRequest;
 Connection.WelcomeMessage            := WelcomeMessage;
 Connection.Host                      := Host;
 Connection.Port                      := Port;
 Connection.Compression               := Compression;
 Connection.EncodeStrings             := EncodeStrings;
 Connection.Encoding                  := Encoding;
 Connection.AccessTag                 := AccessTag;
 if assigned(ConnectionExec) then  //Leandro 11/08/2020
  begin
    ConnectionExec.Host                  := Connection.Host;
    ConnectionExec.Port                  := Connection.Port;
    ConnectionExec.DataCompression       := Connection.Compression;
    ConnectionExec.TypeRequest           := Connection.TypeRequest;
    ConnectionExec.WelcomeMessage        := Connection.WelcomeMessage;
    ConnectionExec.hEncodeStrings        := Connection.EncodeStrings;
    ConnectionExec.SetAccessTag(Connection.AccessTag);
    ConnectionExec.Encoding              := Connection.Encoding;
    ConnectionExec.AuthenticationOptions.Assign(AuthenticationOptions);
    {$IFDEF FPC}
     ConnectionExec.DatabaseCharSet := csUndefined;
    {$ENDIF}
  end;
End;

Function  TRESTDWDataBase.TryConnect : Boolean;
Var
 vErrorBoolean        : Boolean;
 I                    : Integer;
 vMessageError,
 vToken,
 vTempSend            : String;
 vConnectionB,
 vConnection          : TDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPooler;
 DWParams             : TDWParams;
 Procedure DestroyComponents;
 Begin
  If Assigned(RESTClientPoolerExec) Then
   FreeAndNil(RESTClientPoolerExec);
 End;
 Procedure TokenValidade;
 Begin
  DWParams := TDWParams.Create;
  Try
   DWParams.Encoding := Encoding;
   If vConnection.AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
    Begin
     Case vConnection.AuthenticationOptions.AuthorizationOption Of
      rdwAOBearer : Begin
                     If (TRDWAuthOptionBearerClient(vConnection.AuthenticationOptions.OptionParams).AutoGetToken) And
                        (TRDWAuthOptionBearerClient(vConnection.AuthenticationOptions.OptionParams).Token = '') Then
                      Begin
                       If Assigned(OnBeforeGetToken) Then
                        OnBeforeGetToken(vConnection.WelcomeMessage,
                                         vConnection.AccessTag, DWParams);
                       vToken :=  RenewToken(vConnectionB, DWParams, vErrorBoolean, vMessageError);
                       If Not vErrorBoolean Then
                        TRDWAuthOptionBearerClient(vConnection.AuthenticationOptions.OptionParams).Token := vToken;
                      End;
                    End;
      rdwAOToken  : Begin
                     If (TRDWAuthOptionTokenClient(vConnection.AuthenticationOptions.OptionParams).AutoGetToken) And
                        (TRDWAuthOptionTokenClient(vConnection.AuthenticationOptions.OptionParams).Token = '') Then
                      Begin
                       If Assigned(OnBeforeGetToken) Then
                        OnBeforeGetToken(vConnection.WelcomeMessage,
                                         vConnection.AccessTag, DWParams);
                       vToken :=  RenewToken(vConnectionB, DWParams, vErrorBoolean, vMessageError);
                       If Not vErrorBoolean Then
                        TRDWAuthOptionTokenClient(vConnection.AuthenticationOptions.OptionParams).Token := vToken;
                      End;
                    End;
     End;
    End;
  Finally
   FreeAndNil(DWParams);
  End;
 End;
Begin
 vErrorBoolean                := False;
 vMessageError                := '';
 RESTClientPoolerExec         := Nil;
 vConnection                  := TDWPoolerMethodClient.Create(Nil);
 vConnection.PoolerNotFoundMessage := PoolerNotFoundMessage;
 vConnection.UserAgent        := vUserAgent;
 vConnection.HandleRedirects  := vHandleRedirects;
 vConnection.RedirectMaximum  := vRedirectMaximum;
 vConnection.TypeRequest      := vTypeRequest;
 vConnection.WelcomeMessage   := vWelcomeMessage;
 vConnection.Host             := vRestWebService;
 vConnection.Port             := vPoolerPort;
 vConnection.Compression      := vCompression;
 vConnection.EncodeStrings    := EncodeStrings;
 vConnection.Encoding         := Encoding;
 vConnection.AccessTag        := vAccessTag;
 vConnection.CriptOptions.Use := vCripto.Use;
 vConnection.CriptOptions.Key := vCripto.Key;
 vConnection.DataRoute        := DataRoute;
 vConnection.ServerContext    := ServerContext;
 vConnection.AuthenticationOptions.Assign(AuthenticationOptions);
 {$IFNDEF FPC}
  vConnection.OnWork        := vOnWork;
  vConnection.OnWorkBegin   := vOnWorkBegin;
  vConnection.OnWorkEnd     := vOnWorkEnd;
  vConnection.OnStatus      := vOnStatus;
  vConnection.Encoding      := vEncoding;
 {$ELSE}
  vConnection.OnWork          := vOnWork;
  vConnection.OnWorkBegin     := vOnWorkBegin;
  vConnection.OnWorkEnd       := vOnWorkEnd;
  vConnection.OnStatus        := vOnStatus;
  vConnection.DatabaseCharSet := csUndefined;
 {$ENDIF}
 Try
  Try
   TokenValidade;
   If Not(vErrorBoolean) Then
    vTempSend  := vConnection.EchoPooler(vRestURL, vRestPooler, vTimeOut, vConnectTimeOut);
   Result      := Trim(vTempSend) <> '';
   If Result Then
    vMyIP       := vTempSend
   Else
    vMyIP       := '';
   If csDesigning in ComponentState Then
    If Not Result Then Raise Exception.Create(PChar(cAuthenticationError));
   If Trim(vMyIP) = '' Then
    Begin
     Result      := False;
     If vFailOver Then
      Begin
       If vFailOverConnections.Count = 0 Then
        Begin
         Result      := False;
         vMyIP       := '';
         If csDesigning in ComponentState Then
          Raise Exception.Create(PChar(cInvalidConnection));
         If Assigned(vOnEventConnection) Then
          vOnEventConnection(False, cInvalidConnection)
         Else
          Raise Exception.Create(cInvalidConnection);
        End
       Else
        Begin
         For I := 0 To vFailOverConnections.Count -1 Do
          Begin
           If I = 0 Then
            Begin
             If ((vFailOverConnections[I].vTypeRequest    = vConnection.TypeRequest)    And
                 (vFailOverConnections[I].vWelcomeMessage = vConnection.WelcomeMessage) And
                 (vFailOverConnections[I].vRestWebService = vConnection.Host)           And
                 (vFailOverConnections[I].vPoolerPort     = vConnection.Port)           And
                 (vFailOverConnections[I].vCompression    = vConnection.Compression)    And
                 (vFailOverConnections[I].EncodeStrings   = vConnection.EncodeStrings)  And
                 (vFailOverConnections[I].Encoding        = vConnection.Encoding)       And
                 (vFailOverConnections[I].vAccessTag      = vConnection.AccessTag)      And
                 (vFailOverConnections[I].vRestPooler     = vRestPooler)                And
                 (vFailOverConnections[I].vRestURL        = vRestURL))                  Or
               (Not (vFailOverConnections[I].Active))                                   Then
             Continue;
            End;
           If Assigned(vOnFailOverExecute) Then
            vOnFailOverExecute(vFailOverConnections[I]);
           If Not Assigned(RESTClientPoolerExec) Then
            RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
           RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
           ReconfigureConnection(vConnection,
                                 RESTClientPoolerExec,
                                 vFailOverConnections[I].vTypeRequest,
                                 vFailOverConnections[I].vWelcomeMessage,
                                 vFailOverConnections[I].vRestWebService,
                                 vFailOverConnections[I].vPoolerPort,
                                 vFailOverConnections[I].vCompression,
                                 vFailOverConnections[I].EncodeStrings,
                                 vFailOverConnections[I].Encoding,
                                 vFailOverConnections[I].vAccessTag,
                                 vFailOverConnections[I].AuthenticationOptions);
           Try
            TokenValidade;
            If Not(vErrorBoolean) Then
             vTempSend   := vConnection.EchoPooler(vFailOverConnections[I].vRestURL,
                                                   vFailOverConnections[I].vRestPooler,
                                                   vFailOverConnections[I].vTimeOut,
                                                   vFailOverConnections[I].vConnectTimeOut,
                                                   RESTClientPoolerExec);
            Result      := Trim(vTempSend) <> '';
            If Result Then
             Begin
              vMyIP     := vTempSend;
              If vFailOverReplaceDefaults Then
               Begin
                vTypeRequest    := vConnection.TypeRequest;
                vWelcomeMessage := vConnection.WelcomeMessage;
                vRestWebService := vConnection.Host;
                vPoolerPort     := vConnection.Port;
                vCompression    := vConnection.Compression;
                vEncodeStrings  := vConnection.EncodeStrings;
                vEncoding       := vConnection.Encoding;
                vAccessTag      := vConnection.AccessTag;
                vRestURL        := vFailOverConnections[I].vRestURL;
                vRestPooler     := vFailOverConnections[I].vRestPooler;
                vTimeOut        := vFailOverConnections[I].vTimeOut;
                vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
                vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
               End;
             End
            Else
             vMyIP       := '';
            If csDesigning in ComponentState Then
             If Not Result Then Raise Exception.Create(PChar(cAuthenticationError));
            If Trim(vMyIP) = '' Then
             Begin
              If Assigned(vOnFailOverError) Then
               vOnFailOverError(vFailOverConnections[I], cAuthenticationError);
             End
            Else
             Break;
           Except
            On E : Exception do
             Begin
              If Assigned(vOnFailOverError) Then
               vOnFailOverError(vFailOverConnections[I], E.Message);
             End;
           End;
          End;
        End;
      End
     Else
      Begin
       If Assigned(vOnEventConnection) Then
        vOnEventConnection(False, cAuthenticationError);
      End;
    End;
  Except
   On E : Exception do
    Begin
     DestroyComponents;
     If vFailOver Then
      Begin
       If vFailOverConnections.Count > 0 Then
        Begin
         If Assigned(vFailOverConnections) Then
         For I := 0 To vFailOverConnections.Count -1 Do
          Begin
           DestroyComponents;
           If I = 0 Then
            Begin
             If ((vFailOverConnections[I].vTypeRequest    = vConnection.TypeRequest)    And
                 (vFailOverConnections[I].vWelcomeMessage = vConnection.WelcomeMessage) And
                 (vFailOverConnections[I].vRestWebService = vConnection.Host)           And
                 (vFailOverConnections[I].vPoolerPort     = vConnection.Port)           And
                 (vFailOverConnections[I].vCompression    = vConnection.Compression)    And
                 (vFailOverConnections[I].EncodeStrings   = vConnection.EncodeStrings)  And
                 (vFailOverConnections[I].Encoding        = vConnection.Encoding)       And
                 (vFailOverConnections[I].vAccessTag      = vConnection.AccessTag)      And
                 (vFailOverConnections[I].vRestPooler     = vRestPooler)                And
                 (vFailOverConnections[I].vRestURL        = vRestURL))                  Or
                 (Not (vFailOverConnections[I].Active))                                 Then
             Continue;
            End;
           If Assigned(vOnFailOverExecute) Then
            vOnFailOverExecute(vFailOverConnections[I]);
           If Not Assigned(RESTClientPoolerExec) Then
            RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
           RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
           ReconfigureConnection(vConnection,
                                 RESTClientPoolerExec,
                                 vFailOverConnections[I].vTypeRequest,
                                 vFailOverConnections[I].vWelcomeMessage,
                                 vFailOverConnections[I].vRestWebService,
                                 vFailOverConnections[I].vPoolerPort,
                                 vFailOverConnections[I].vCompression,
                                 vFailOverConnections[I].EncodeStrings,
                                 vFailOverConnections[I].Encoding,
                                 vFailOverConnections[I].vAccessTag,
                                 vFailOverConnections[I].AuthenticationOptions);
           Try
            TokenValidade;
            If Not(vErrorBoolean) Then
             vTempSend   := vConnection.EchoPooler(vFailOverConnections[I].vRestURL,
                                                   vFailOverConnections[I].vRestPooler,
                                                   vFailOverConnections[I].vTimeOut,
                                                   vFailOverConnections[I].vConnectTimeOut,
                                                   RESTClientPoolerExec);
            Result      := Trim(vTempSend) <> '';
            If Result Then
             Begin
              vMyIP       := vTempSend;
              If vFailOverReplaceDefaults Then
               Begin
                vTypeRequest    := vConnection.TypeRequest;
                vWelcomeMessage := vConnection.WelcomeMessage;
                vRestWebService := vConnection.Host;
                vPoolerPort     := vConnection.Port;
                vCompression    := vConnection.Compression;
                vEncodeStrings  := vConnection.EncodeStrings;
                vEncoding       := vConnection.Encoding;
                vAccessTag      := vConnection.AccessTag;
                vRestURL        := vFailOverConnections[I].vRestURL;
                vRestPooler     := vFailOverConnections[I].vRestPooler;
                vTimeOut        := vFailOverConnections[I].vTimeOut;
                vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
                vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
               End;
             End
            Else
             vMyIP       := '';
            If csDesigning in ComponentState Then
             If Not Result Then Raise Exception.Create(PChar(cAuthenticationError));
            If Trim(vMyIP) = '' Then
             Begin
              If Assigned(vOnFailOverError) Then
               vOnFailOverError(vFailOverConnections[I], cAuthenticationError);
             End
            Else
             Break;
           Except
            On E : Exception do
             Begin
              If Assigned(vOnFailOverError) Then
               vOnFailOverError(vFailOverConnections[I], E.Message);
             End;
           End;
          End;
        End
       Else
        Begin
         Result      := False;
         vMyIP       := '';
         If csDesigning in ComponentState Then
          Raise Exception.Create(PChar(E.Message));
         If Assigned(vOnEventConnection) Then
          vOnEventConnection(False, E.Message)
         Else
          Raise Exception.Create(E.Message);
        End;
      End
     Else
      Begin
       Result      := False;
       vMyIP       := '';
       If csDesigning in ComponentState Then
        Raise Exception.Create(PChar(E.Message));
       If Assigned(vOnEventConnection) Then
        vOnEventConnection(False, E.Message)
       Else
        Raise Exception.Create(E.Message);
      End;
    End;
  End;
 Finally
  DestroyComponents;
  If vConnection <> Nil Then
   FreeAndNil(vConnection);
 End;
End;

Procedure TRESTDWDataBase.SetConnection(Value : Boolean);
Begin
 If (csLoading in ComponentState) then
  Value := False;
 If (Value) And Not(vConnected) then
  If Assigned(vOnBeforeConnection) Then
   vOnBeforeConnection(Self);
 If Not(vConnected) And (Value) Then
  Begin
   If Value then
    vConnected := TryConnect
   Else
    vMyIP := '';
  End
 Else If Not (Value) Then
  Begin
   vConnected := Value;
   vMyIP := '';
   If vAuthOptionParams.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
    Begin
     Case vAuthOptionParams.AuthorizationOption Of
      rdwAOBearer : TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).Token := '';
      rdwAOToken  : TRDWAuthOptionTokenClient (vAuthOptionParams.OptionParams).Token := '';
     End;
    End;
  End;
End;

Procedure TRESTDWPoolerList.SetConnection(Value : Boolean);
Begin
 vConnected := Value;
 If vConnected Then
  vConnected := TryConnect;
End;

Procedure TRESTDWDataBase.SetPoolerPort(Value : Integer);
Begin
 vPoolerPort := Value;
End;

Procedure TRESTDWPoolerList.SetPoolerPort(Value : Integer);
Begin
 vPoolerPort := Value;
End;

Procedure TRESTDWDataBase.SetRestPooler(Value : String);
Begin
 vRestPooler := Value;
End;
procedure TRESTDWTable.SetDataBase(Value: TRESTDWDataBase);
Begin
 If Value is TRESTDWDataBase Then
  Begin
   vRESTDataBase   := Value;
   TMassiveDatasetBuffer(vMassiveDataset).Encoding := TRESTDWDataBase(Value).Encoding;
  End
 Else
  vRESTDataBase := Nil;
End;

procedure TRESTDWClientSQL.SetDataBase(Value: TRESTDWDataBase);
Begin
 If Value is TRESTDWDataBase Then
  Begin
   vRESTDataBase   := Value;
   TMassiveDatasetBuffer(vMassiveDataset).Encoding := TRESTDWDataBase(Value).Encoding;
  End
 Else
  vRESTDataBase := Nil;
End;

Procedure TRESTDWTable.SetDatapacks(Value: Integer);
Begin
 vDatapacks := Value;
 If vDatapacks = 0 Then
  vDatapacks := -1;
End;

Procedure TRESTDWClientSQL.SetDatapacks(Value: Integer);
Begin
 vDatapacks := Value;
 If vDatapacks = 0 Then
  vDatapacks := -1;
End;

Procedure TRESTDWTable.SetDWResponseTranslator(Const Value : TDWResponseTranslator);
Begin
 If vDWResponseTranslator <> Value then
  vDWResponseTranslator := Value;
 If vDWResponseTranslator <> nil then
  vDWResponseTranslator.FreeNotification(Self);
End;

Function TRESTDWClientSQL.GetReadData : Boolean;
Begin
 Result := vReadData;
End;

Procedure TRESTDWClientSQL.SetDWResponseTranslator(Const Value : TDWResponseTranslator);
Begin
 If vDWResponseTranslator <> Value then
  vDWResponseTranslator := Value;
 If vDWResponseTranslator <> nil then
  vDWResponseTranslator.FreeNotification(Self);
End;

Procedure TRESTDWTable.SetFilteredB(aValue: Boolean);
Var
 vFilter   : String;
Begin
 vFiltered := aValue;
 vFilter   := Filter;
 If Assigned(vOnFiltered) Then
  vOnFiltered(vFiltered, vFilter);
 TDataset(Self).Filter   := vFilter;
 TDataset(Self).Filtered := vFiltered;
 If vFiltered Then
  ProcAfterScroll(Self);
End;

Procedure TRESTDWClientSQL.SetFilteredB(aValue: Boolean);
Var
 vFilter   : String;
Begin
 vFiltered := aValue;
 vFilter   := Filter;
 If Assigned(vOnFiltered) Then
  vOnFiltered(vFiltered, vFilter);
 TDataset(Self).Filter   := vFilter;
 TDataset(Self).Filtered := vFiltered;
 If vFiltered Then
  ProcAfterScroll(Self);
End;

procedure TRESTDWTable.SetInBlockEvents(const Value: Boolean);
begin
 vInBlockEvents := Value;
end;

procedure TRESTDWClientSQL.SetInBlockEvents(const Value: Boolean);
begin
 vInBlockEvents := Value;
end;

procedure TRESTDWTable.SetInDesignEvents(const Value: Boolean);
begin
 vInDesignEvents := Value;
end;

procedure TRESTDWClientSQL.SetInDesignEvents(const Value: Boolean);
begin
 vInDesignEvents := Value;
end;

procedure TRESTDWTable.SetInitDataset(const Value: Boolean);
begin
 vInitDataset := Value;
end;

procedure TRESTDWClientSQL.SetInitDataset(const Value: Boolean);
begin
 vInitDataset := Value;
end;

Function TRESTDWUpdateSQL.ToJSON       : String;
Var
 vJSONValue,
 vTempJSON,
 vParamsString : String;
 A, I          : Integer;
 vDWParams     : TDWParams;
Begin
 vJSONValue := '';
 Result     := '';
 vDWParams  := Nil;
 For A := 0 To vMassiveCacheSQLList.Count -1 Do
  Begin
   vParamsString := '';
   vDWParams     := GetDWParams(vMassiveCacheSQLList[A].Params, vEncoding);
   If Assigned(vDWParams) Then
    vParamsString := EncodeStrings(vDWParams.ToJSON{$IFDEF FPC}, csUndefined{$ENDIF});
   vTempJSON  := Format(cJSONValue, [MassiveSQLMode(msqlExecute),
                                     EncodeStrings(vMassiveCacheSQLList[A].SQL.Text{$IFDEF FPC}, csUndefined{$ENDIF}),
                                     vParamsString,
                                     EncodeStrings(vMassiveCacheSQLList[A].Bookmark{$IFDEF FPC}, csUndefined{$ENDIF}),
                                     BooleanToString(vMassiveCacheSQLList[A].BinaryRequest),
                                     EncodeStrings(vMassiveCacheSQLList[A].FetchRowSQL.Text{$IFDEF FPC}, csUndefined{$ENDIF}),
                                     EncodeStrings(vMassiveCacheSQLList[A].LockSQL.Text{$IFDEF FPC},     csUndefined{$ENDIF}),
                                     EncodeStrings(vMassiveCacheSQLList[A].UnlockSQL.Text{$IFDEF FPC},   csUndefined{$ENDIF})]);
   If vJSONValue = '' Then
    vJSONValue := vTempJSON
   Else
    vJSONValue := vJSONValue + ', ' + vTempJSON;
  End;
 If vJSONValue <> '' Then
  Result       := Format('[%s]', [vJSONValue]);
End;

Function  TRESTDWUpdateSQL.getClientSQLB       : TRESTDWClientSQLBase;
Begin
 Result := vClientSQLBase;
End;

Procedure TRESTDWUpdateSQL.SetSQLDelete (Value : TStringList);
Var
 I : Integer;
Begin
 vSQLDelete.Clear;
 For I := 0 To Value.Count -1 do
  vSQLDelete.Add(Value[I]);
End;

Procedure TRESTDWUpdateSQL.SetSQLInsert (Value : TStringList);
Var
 I : Integer;
Begin
 vSQLInsert.Clear;
 For I := 0 To Value.Count -1 do
  vSQLInsert.Add(Value[I]);
End;

Procedure TRESTDWUpdateSQL.SetSQLLock   (Value : TStringList);
Var
 I : Integer;
Begin
 vSQLLock.Clear;
 For I := 0 To Value.Count -1 do
  vSQLLock.Add(Value[I]);
End;

Procedure TRESTDWUpdateSQL.SetSQLUnlock (Value : TStringList);
Var
 I : Integer;
Begin
 vSQLUnlock.Clear;
 For I := 0 To Value.Count -1 do
  vSQLUnlock.Add(Value[I]);
End;

Procedure TRESTDWUpdateSQL.SetSQLRefresh(Value : TStringList);
Var
 I : Integer;
Begin
 vSQLRefresh.Clear;
 For I := 0 To Value.Count -1 do
  vSQLRefresh.Add(Value[I]);
End;

Procedure TRESTDWUpdateSQL.SetSQLUpdate (Value : TStringList);
Var
 I : Integer;
Begin
 vSQLUpdate.Clear;
 For I := 0 To Value.Count -1 do
  vSQLUpdate.Add(Value[I]);
End;

Procedure TRESTDWUpdateSQL.setClientSQLB(Value : TRESTDWClientSQLBase);
Begin
 If Value is TRESTDWClientSQL Then
  Begin
   If Assigned(vClientSQLBase) Then
    TRESTDWClientSQL(vClientSQLBase).UpdateSQL := Nil;
   vClientSQLBase := Value;
   TRESTDWClientSQL (vClientSQLBase).UpdateSQL := Self;
  End
 Else If Value is TRESTDWTable Then
  Begin
   If Assigned(vClientSQLBase) Then
    TRESTDWTable(vClientSQLBase).UpdateSQL := Nil;
   vClientSQLBase := Value;
   TRESTDWTable (vClientSQLBase).UpdateSQL := Self;
  End
 Else If Value is TRESTDWStoredProc Then
  Begin
   If Assigned(vClientSQLBase) Then
    TRESTDWStoredProc(vClientSQLBase).UpdateSQL := Nil;
   vClientSQLBase := Value;
   TRESTDWStoredProc (vClientSQLBase).UpdateSQL := Self;
  End
 Else
  Begin
   If Assigned(vClientSQLBase) Then
    TRESTDWClientSQL(vClientSQLBase).UpdateSQL := Nil;
   vClientSQLBase := Nil;
  End;
End;

Function TRESTDWUpdateSQL.GetVersionInfo : String;
Begin
 Result := Format('%s%s', [DWVersionINFO, DWRelease]);
End;

Function TRESTDWUpdateSQL.MassiveCount : Integer;
Begin
 Result := vMassiveCacheSQLList.Count;
End;

Procedure TRESTDWUpdateSQL.Store(SQL           : String;
                                 Dataset       : TDataset;
                                 DeleteCommand : Boolean = False);
Var
 I                     : Integer;
 vMassiveCacheSQLValue : TDWMassiveCacheSQLValue;
Begin
 If Not Dataset.IsEmpty Then
  Begin
   vMassiveCacheSQLValue                   := TDWMassiveCacheSQLValue(vMassiveCacheSQLList.Add);
   vMassiveCacheSQLValue.MassiveSQLMode    := msqlExecute;
   vMassiveCacheSQLValue.SQL.Text          := SQL;
   If Not (DeleteCommand) Then
    vMassiveCacheSQLValue.FetchRowSQL.Text := vSQLRefresh.Text
   Else
    vMassiveCacheSQLValue.FetchRowSQL.Text := '';
   vMassiveCacheSQLValue.LockSQL.Text      := vSQLLock.Text;
   vMassiveCacheSQLValue.UnlockSQL.Text    := vSQLUnlock.Text;
   For I := 0 To vMassiveCacheSQLValue.Params.Count -1 Do
    Begin
     If TRESTDWClientSQL(Dataset).FindField(vMassiveCacheSQLValue.Params[I].Name) <> Nil Then
      vMassiveCacheSQLValue.Params[I].AssignField(TRESTDWClientSQL(Dataset).FindField(vMassiveCacheSQLValue.Params[I].Name)); // .AssignValues(TRESTDWClientSQL(Dataset).Params);
    End;
  End;
End;

Procedure TRESTDWUpdateSQL.Notification(AComponent : TComponent;
                                        Operation  : TOperation);
Begin
 If (Operation = opRemove) and (AComponent = vClientSQLBase) Then
  vClientSQLBase := Nil;
 Inherited Notification(AComponent, Operation);
End;

procedure TRESTDWUpdateSQL.Clear;
begin
 vMassiveCacheSQLList.Clear;
end;

Destructor  TRESTDWUpdateSQL.Destroy;
Begin
 FreeAndNil(vMassiveCacheSQLList);
 FreeAndNil(vSQLInsert);
 FreeAndNil(vSQLDelete);
 FreeAndNil(vSQLUpdate);
 FreeAndNil(vSQLRefresh);
 FreeAndNil(vSQLLock);
 FreeAndNil(vSQLUnlock);
 Inherited;
End;

Constructor TRESTDWUpdateSQL.Create    (AOwner : TComponent);
Begin
 Inherited;
 vClientSQLBase := Nil;
 {$IFNDEF FPC}
 {$IF CompilerVersion > 21}
  vEncoding         := esUtf8;
 {$ELSE}
  vEncoding         := esAscii;
 {$IFEND}
 {$ELSE}
  vEncoding         := esUtf8;
 {$ENDIF}
 vMassiveCacheSQLList := TDWMassiveCacheSQLList.Create(Self, TDWMassiveCacheSQLValue);
 vSQLInsert           := TStringList.Create;
 vSQLDelete           := TStringList.Create;
 vSQLUpdate           := TStringList.Create;
 vSQLRefresh          := TStringList.Create;
 vSQLLock             := TStringList.Create;
 vSQLUnlock           := TStringList.Create;
End;

Procedure TRESTDWUpdateSQL.SetClientSQL(Value  : TRESTDWClientSQLBase);
Begin
 If (Assigned(vClientSQLBase)) And
    (vClientSQLBase <> Value)  And
    (Value <> Nil)             Then
  Begin
   If vClientSQLBase.ClassType     = TRESTDWClientSQL Then
    TRESTDWClientSQL(vClientSQLBase).UpdateSQL := Nil
   Else If vClientSQLBase.ClassType = TRESTDWStoredProc Then
    TRESTDWStoredProc(vClientSQLBase).UpdateSQL := Nil;
  End;
 vClientSQLBase := Value;
End;
Procedure TRESTDWTable.SetUpdateSQL(Value : TRESTDWUpdateSQL);
Begin
 If (Assigned(vUpdateSQL)) And
    (vUpdateSQL <> Value)  Then
  Begin
   vUpdateSQL.SetClientSQL(Nil);
   vUpdateSQL := Nil;
  End;
 If vUpdateSQL <> Value Then
  vUpdateSQL := Value;
 If vUpdateSQL <> Nil   Then
  Begin
   SetMassiveCache(Nil);
   vUpdateSQL.SetClientSQL(Self);
   vUpdateSQL.FreeNotification(Self);
  End;
End;

Procedure TRESTDWClientSQL.SetUpdateSQL(Value : TRESTDWUpdateSQL);
Begin
 If (Assigned(vUpdateSQL)) And
    (vUpdateSQL <> Value)  Then
  Begin
   vUpdateSQL.SetClientSQL(Nil);
   vUpdateSQL := Nil;
  End;
 If vUpdateSQL <> Value Then
  vUpdateSQL := Value;
 If vUpdateSQL <> Nil   Then
  Begin
   SetMassiveCache(Nil);
   vUpdateSQL.SetClientSQL(Self);
   vUpdateSQL.FreeNotification(Self);
  End;
End;

Function TRESTDWTable.GetUpdateSQL : TRESTDWUpdateSQL;
Begin
 Result := vUpdateSQL;
End;

Function TRESTDWClientSQL.GetUpdateSQL : TRESTDWUpdateSQL;
Begin
 Result := vUpdateSQL;
End;

Procedure TRESTDWTable.SetMassiveCache(Const Value : TDWMassiveCache);
Begin
 If vMassiveCache <> Value Then
  Begin
   If (Value = Nil) Then
    vMassiveCache.Clear;
   vMassiveCache := Value;
  End;
 If vMassiveCache <> Nil Then
  Begin
   SetUpdateSQL(Nil);
   vMassiveCache.FreeNotification(Self);
  End;
End;

Procedure TRESTDWClientSQL.SetMassiveCache(Const Value : TDWMassiveCache);
Begin
 If vMassiveCache <> Value Then
  Begin
   If (Value = Nil) Then
    vMassiveCache.Clear;
   vMassiveCache := Value;
  End;
 If vMassiveCache <> Nil Then
  Begin
   SetUpdateSQL(Nil);
   vMassiveCache.FreeNotification(Self);
  End;
End;

procedure TRESTDWTable.SetMasterDataSet(Value: TRESTDWClientSQLBase);
Begin
 If (vMasterDataSet <> Nil) Then
  TRESTDWTable(vMasterDataSet).vMasterDetailList.DeleteDS(TRESTClient(Self));
 If (Value = Self) And (Value <> Nil) Then
  Begin
   vMasterDataSet := Nil;
   MasterFields   := '';
   Exit;
  End;
 vMasterDataSet := Value;
 If (vMasterDataSet <> Nil) Then
  Begin
   If vMasterDetailItem = Nil Then
    FreeAndNil(vMasterDetailItem);
   vMasterDetailItem    := TMasterDetailItem.Create;
   vMasterDetailItem.DataSet := TRESTClient(Self);
   TRESTDWTable(vMasterDataSet).vMasterDetailList.Add(vMasterDetailItem);
   vDataSource.DataSet := Value;
  End
 Else
  Begin
   MasterFields := '';
  End;
End;

procedure TRESTDWClientSQL.SetMasterDataSet(Value: TRESTDWClientSQL);
Begin
 If (vMasterDataSet <> Nil) Then
  TRESTDWClientSQL(vMasterDataSet).vMasterDetailList.DeleteDS(TRESTClient(Self));
 If (Value = Self) And (Value <> Nil) Then
  Begin
   vMasterDataSet := Nil;
   MasterFields   := '';
   Exit;
  End;
 vMasterDataSet := Value;
 If (vMasterDataSet <> Nil) Then
  Begin
   If vMasterDetailItem = Nil Then
    FreeAndNil(vMasterDetailItem);
//    Begin
   vMasterDetailItem    := TMasterDetailItem.Create;
   vMasterDetailItem.DataSet := TRESTClient(Self);
   TRESTDWClientSQL(vMasterDataSet).vMasterDetailList.Add(vMasterDetailItem);
//    End;
   vDataSource.DataSet := Value;
  End
 Else
  Begin
   MasterFields := '';
  End;
End;

Procedure TRESTDWTable.Setnotrepage(Value: Boolean);
Begin
 vNotRepage := Value;
End;

Procedure TRESTDWClientSQL.Setnotrepage(Value: Boolean);
Begin
 vNotRepage := Value;
End;

Procedure TRESTDWTable.SetOldCursor;
{$IFNDEF FPC}
{$IFDEF WINFMX}
Var
 CS: IFMXCursorService;
{$ENDIF}
{$ENDIF}
Begin
{$IFNDEF FPC}
 {$IFDEF WINFMX}
  If TPlatformServices.Current.SupportsPlatformService(IFMXCursorService) Then
   CS := TPlatformServices.Current.GetPlatformService(IFMXCursorService) As IFMXCursorService;
  If Assigned(CS) then
   CS.SetCursor(vOldCursor);
 {$ELSE}
  {$IFNDEF HAS_FMX}
   Screen.Cursor := vOldCursor;
  {$ENDIF}
 {$ENDIF}
{$ELSE}
 Screen.Cursor := vOldCursor;
{$ENDIF}
End;

Procedure TRESTDWClientSQL.SetOldCursor;
{$IFNDEF FPC}
{$IFDEF WINFMX}
Var
 CS: IFMXCursorService;
{$ENDIF}
{$ENDIF}
Begin
{$IFNDEF FPC}
 {$IFDEF WINFMX}
  If TPlatformServices.Current.SupportsPlatformService(IFMXCursorService) Then
   CS := TPlatformServices.Current.GetPlatformService(IFMXCursorService) As IFMXCursorService;
  If Assigned(CS) then
   CS.SetCursor(vOldCursor);
 {$ELSE}
  {$IFNDEF HAS_FMX}
   Screen.Cursor := vOldCursor;
  {$ENDIF}
 {$ENDIF}
{$ELSE}
 Screen.Cursor := vOldCursor;
{$ENDIF}
End;

Procedure TRESTDWTable.SetParams(const Value: TParams);
begin
 vParams.Assign(Value);
end;

procedure TRESTDWClientSQL.SetParams(const Value: TParams);
begin
 vParams.Assign(Value);
end;

Procedure TRESTDWTable.SetRecordCount(aJsonCount, aRecordCount : Integer);
begin
 vJsonCount      := aJsonCount;
 vOldRecordCount := aRecordCount;
end;

Procedure TRESTDWClientSQL.SetRecordCount(aJsonCount, aRecordCount : Integer);
begin
 vJsonCount      := aJsonCount;
 vOldRecordCount := aRecordCount;
end;

Procedure TRESTDWClientSQL.SetReflectChanges(Value: Boolean);
Begin
 vReflectChanges := Value;
 If Value Then
  vAutoRefreshAfterCommit := False;
 TMassiveDatasetBuffer(vMassiveDataset).ReflectChanges := vReflectChanges;
End;

Constructor TRESTDWTable.Create(AOwner: TComponent);
Begin
 Inherited;
 vParamCount                       := 0;
 vJsonCount                        := 0;
 vRowsAffected                     := 0;
 vOldRecordCount                   := -1;
 vActualJSON                       := '';
 vMassiveMode                      := mtMassiveCache;
 vFiltered                         := False;
 vBinaryRequest                    := False;
 vInitDataset                      := False;
 vOnPacks                          := False;
 vInternalLast                     := False;
 vNotRepage                        := False;
 vInactive                         := False;
 vInBlockEvents                    := False;
 vOnOpenCursor                     := False;
 vDataCache                        := False;
 vAutoCommitData                   := False;
 vAutoRefreshAfterCommit           := False;
 vFiltered                         := False;
 OnLoadStream                      := False;
 vRaiseError                       := True;
 vConnectedOnce                    := True;
 GetNewData                        := True;
 vActive                           := False;
 vCacheUpdateRecords               := True;
 vBeforeClone                      := False;
 vReadData                         := False;
 vActiveCursor                     := False;
 vInDesignEvents                   := False;
 vDatapacks                        := -1;
 vCascadeDelete                    := True;
 vRelationFields                   := TStringList.Create;
 vParams                           := TParams.Create(Self);
 vTableName                        := '';
 FieldDefsUPD                      := TFieldDefs.Create(Self);
 FieldDefs                         := FieldDefsUPD;
 vMasterDetailList                 := TMasterDetailList.Create;
 vMasterDataSet                    := Nil;
 vDataSource                       := TDataSource.Create(Nil);
 {$IFDEF FPC}
 TDataset(Self).AfterScroll        := @ProcAfterScroll;
 TDataset(Self).BeforeScroll       := @ProcBeforeScroll;
 TDataset(Self).BeforeOpen         := @ProcBeforeOpen;
 TDataset(Self).AfterOpen          := @ProcAfterOpen;
 TDataset(Self).BeforeClose        := @ProcBeforeClose;
 TDataset(Self).AfterClose         := @ProcAfterClose;
 TDataset(Self).BeforeRefresh      := @ProcBeforeRefresh;
 TDataset(Self).AfterRefresh       := @ProcAfterRefresh;
 TDataset(Self).BeforeInsert       := @ProcBeforeInsert;
 TDataset(Self).AfterInsert        := @ProcAfterInsert;
 TDataset(Self).BeforeEdit         := @ProcBeforeEdit;
 TDataset(Self).AfterEdit          := @ProcAfterEdit;
 TDataset(Self).BeforePost         := @ProcBeforePost;
 TDataset(Self).AfterCancel        := @ProcAfterCancel;
 TDataset(Self).BeforeDelete       := @ProcBeforeDelete;
 TDataset(Self).OnNewRecord        := @ProcNewRecord;
 TDataset(Self).OnCalcFields       := @ProcCalcFields;
// TDataset(Self).Last               := @Last;
 Inherited AfterPost               := @OldAfterPost;
 Inherited AfterDelete             := @OldAfterDelete;
 {$ELSE}
 TDataset(Self).AfterScroll        := ProcAfterScroll;
 TDataset(Self).BeforeScroll       := ProcBeforeScroll;
 TDataset(Self).BeforeOpen         := ProcBeforeOpen;
 TDataset(Self).AfterOpen          := ProcAfterOpen;
 TDataset(Self).BeforeClose        := ProcBeforeClose;
 TDataset(Self).AfterClose         := ProcAfterClose;
 TDataset(Self).BeforeRefresh      := ProcBeforeRefresh;
 TDataset(Self).AfterRefresh       := ProcAfterRefresh;
 TDataset(Self).BeforeInsert       := ProcBeforeInsert;
 TDataset(Self).AfterInsert        := ProcAfterInsert;
 TDataset(Self).BeforeEdit         := ProcBeforeEdit;
 TDataset(Self).AfterEdit          := ProcAfterEdit;
 TDataset(Self).BeforePost         := ProcBeforePost;
 TDataset(Self).BeforeDelete       := ProcBeforeDelete;
 TDataset(Self).AfterCancel        := ProcAfterCancel;
 TDataset(Self).OnNewRecord        := ProcNewRecord;
 TDataset(Self).OnCalcFields       := ProcCalcFields;
 Inherited AfterPost               := OldAfterPost;
 Inherited AfterDelete             := OldAfterDelete;
 {$ENDIF}
 vMassiveDataset                   := TMassiveDatasetBuffer.Create(Self);
 vActionCursor                     := crHourGlass;
 vUpdateSQL                        := Nil;
 SetComponentTAG;
End;


Constructor TRESTDWClientSQL.Create(AOwner: TComponent);
Begin
 Inherited;
 vParamCount                       := 0;
 vJsonCount                        := 0;
 vRowsAffected                     := 0;
 vOldRecordCount                   := -1;
 vActualJSON                       := '';
 vMassiveMode                      := mtMassiveCache;
 vFiltered                         := False;
 vBinaryRequest                    := False;
 vInitDataset                      := False;
 vOnPacks                          := False;
 vInternalLast                     := False;
 vNotRepage                        := False;
 vInactive                         := False;
 vInBlockEvents                    := False;
 vOnOpenCursor                     := False;
 vDataCache                        := False;
 vAutoCommitData                   := False;
 vAutoRefreshAfterCommit           := False;
 vFiltered                         := False;
 OnLoadStream                      := False;
 vPropThreadRequest                := False;
 vRaiseError                       := True;
 vConnectedOnce                    := True;
 GetNewData                        := True;
 vReflectChanges                   := False;
 vActive                           := False;
 vCacheUpdateRecords               := True;
 vBeforeClone                      := False;
 vReadData                         := False;
 vActiveCursor                     := False;
 vInDesignEvents                   := False;
 vDatapacks                        := -1;
 vCascadeDelete                    := True;
 vSQL                              := TStringList.Create;
 vRelationFields                   := TStringList.Create;
 {$IFDEF FPC}
  vSQL.OnChanging                  := @OnBeforeChangingSQL;
  vSQL.OnChange                    := @OnChangingSQL;
 {$ELSE}
  vSQL.OnChanging                  := OnBeforeChangingSQL;
  vSQL.OnChange                    := OnChangingSQL;
 {$ENDIF}
 vParams                           := TParams.Create(Self);
 vUpdateTableName                  := '';
 FieldDefsUPD                      := TFieldDefs.Create(Self);
 FieldDefs                         := FieldDefsUPD;
 vMasterDetailList                 := TMasterDetailList.Create;
 vMasterDataSet                    := Nil;
 vDataSource                       := TDataSource.Create(Nil);
 {$IFDEF FPC}
 TDataset(Self).AfterScroll        := @ProcAfterScroll;
 TDataset(Self).BeforeScroll       := @ProcBeforeScroll;
 TDataset(Self).BeforeOpen         := @ProcBeforeOpen;
 TDataset(Self).AfterOpen          := @ProcAfterOpen;
 TDataset(Self).BeforeClose        := @ProcBeforeClose;
 TDataset(Self).AfterClose         := @ProcAfterClose;
 TDataset(Self).BeforeRefresh      := @ProcBeforeRefresh;
 TDataset(Self).AfterRefresh       := @ProcAfterRefresh;
 TDataset(Self).BeforeInsert       := @ProcBeforeInsert;
 TDataset(Self).AfterInsert        := @ProcAfterInsert;
 TDataset(Self).BeforeEdit         := @ProcBeforeEdit;
 TDataset(Self).AfterEdit          := @ProcAfterEdit;
 TDataset(Self).BeforePost         := @ProcBeforePost;
 TDataset(Self).AfterCancel        := @ProcAfterCancel;
 TDataset(Self).BeforeDelete       := @ProcBeforeDelete;
 TDataset(Self).OnNewRecord        := @ProcNewRecord;
 TDataset(Self).OnCalcFields       := @ProcCalcFields;
// TDataset(Self).Last               := @Last;
 Inherited AfterPost               := @OldAfterPost;
 Inherited AfterDelete             := @OldAfterDelete;
 {$ELSE}
 TDataset(Self).AfterScroll        := ProcAfterScroll;
 TDataset(Self).BeforeScroll       := ProcBeforeScroll;
 TDataset(Self).BeforeOpen         := ProcBeforeOpen;
 TDataset(Self).AfterOpen          := ProcAfterOpen;
 TDataset(Self).BeforeClose        := ProcBeforeClose;
 TDataset(Self).AfterClose         := ProcAfterClose;
 TDataset(Self).BeforeRefresh      := ProcBeforeRefresh;
 TDataset(Self).AfterRefresh       := ProcAfterRefresh;
 TDataset(Self).BeforeInsert       := ProcBeforeInsert;
 TDataset(Self).AfterInsert        := ProcAfterInsert;
 TDataset(Self).BeforeEdit         := ProcBeforeEdit;
 TDataset(Self).AfterEdit          := ProcAfterEdit;
 TDataset(Self).BeforePost         := ProcBeforePost;
 TDataset(Self).BeforeDelete       := ProcBeforeDelete;
 TDataset(Self).AfterCancel        := ProcAfterCancel;
 TDataset(Self).OnNewRecord        := ProcNewRecord;
 TDataset(Self).OnCalcFields       := ProcCalcFields;
 Inherited AfterPost               := OldAfterPost;
 Inherited AfterDelete             := OldAfterDelete;
 {$ENDIF}
 vMassiveDataset                   := TMassiveDatasetBuffer.Create(Self);
 vActionCursor                     := crHourGlass;
 vUpdateSQL                        := Nil;
 SetComponentTAG;
End;

Destructor TRESTDWTable.Destroy;
Begin
 FreeAndNil(vRelationFields);
 FreeAndNil(vParams);
 FreeAndNil(FieldDefsUPD);
 If (vMasterDataSet <> Nil) Then
  If vMasterDetailItem <> Nil Then
   TRESTDWClientSQL(vMasterDataSet).vMasterDetailList.DeleteDS(vMasterDetailItem.DataSet);
 FreeAndNil(vDataSource);
 If Assigned(vCacheDataDB) Then
  FreeAndNil(vCacheDataDB);
 vInactive := False;
 FreeAndNil(vMassiveDataset);
 If Assigned(vMasterDetailList) Then
  FreeAndNil(vMasterDetailList);
 NewFieldList;
 Inherited;
End;

Destructor TRESTDWClientSQL.Destroy;
Begin
 If Assigned(vThreadRequest) Then
  ThreadDestroy;
 FreeAndNil(vSQL);
 FreeAndNil(vRelationFields);
 FreeAndNil(vParams);
 FreeAndNil(FieldDefsUPD);
 If (vMasterDataSet <> Nil) Then
  If vMasterDetailItem <> Nil Then
   TRESTDWClientSQL(vMasterDataSet).vMasterDetailList.DeleteDS(vMasterDetailItem.DataSet);
 FreeAndNil(vDataSource);
 If Assigned(vCacheDataDB) Then
  FreeAndNil(vCacheDataDB);
 vInactive := False;
 FreeAndNil(vMassiveDataset);
 If Assigned(vMasterDetailList) Then
  FreeAndNil(vMasterDetailList);
 NewFieldList;
 Inherited;
End;

Procedure TRESTDWTable.DWParams(Var Value: TDWParams);
Begin
 Value := Nil;
 If vRESTDataBase <> Nil Then
  If ParamCount > 0 Then
    Value := GetDWParams(vParams, vRESTDataBase.Encoding);
End;

Procedure TRESTDWClientSQL.DWParams(Var Value: TDWParams);
Begin
 Value := Nil;
 If vRESTDataBase <> Nil Then
  If ParamCount > 0 Then
    Value := GetDWParams(vParams, vRESTDataBase.Encoding);
End;

Procedure TRESTDWTable.DynamicFilter(cFields: array of String;
  Value: String; InText: Boolean; AndOrOR: String);
Var
 I : Integer;
begin
 Open;
 Filter := '';
 If vActive Then
  Begin
   If Length(Value) > 0 Then
    Begin
     Filtered := False;
     For I := 0 to High(cFields) do
      Begin
       If I = High(cFields) Then
        AndOrOR := '';
       If InText Then
        Filter := Filter + Format('%s Like ''%s'' %s ', [cFields[I], '%' + Value + '%', AndOrOR])
       Else
        Filter := Filter + Format('%s Like ''%s'' %s ', [cFields[I], Value + '%', AndOrOR]);
      End;
     If Not (Filtered) Then
      Filtered := True;
    End
   Else
    Begin
     Filter   := '';
     Filtered := False;
    End;
  End;
End;

Procedure TRESTDWClientSQL.DynamicFilter(cFields: array of String;
  Value: String; InText: Boolean; AndOrOR: String);
Var
 I : Integer;
begin
 ExecOrOpen;
 Filter := '';
 If vActive Then
  Begin
   If Length(Value) > 0 Then
    Begin
     Filtered := False;
     For I := 0 to High(cFields) do
      Begin
       If I = High(cFields) Then
        AndOrOR := '';
       If InText Then
        Filter := Filter + Format('%s Like ''%s'' %s ', [cFields[I], '%' + Value + '%', AndOrOR])
       Else
        Filter := Filter + Format('%s Like ''%s'' %s ', [cFields[I], Value + '%', AndOrOR]);
      End;
     If Not (Filtered) Then
      Filtered := True;
    End
   Else
    Begin
     Filter   := '';
     Filtered := False;
    End;
  End;
End;

Function ScanParams(SQL : String) : TStringList;
Var
 vTemp        : String;
 FCurrentPos  : PChar;
 vOldChar     : Char;
 vParamName   : String;
 Function GetParamName : String;
 Begin
  Result := '';
  If FCurrentPos^ = ':' Then
   Begin
    Inc(FCurrentPos);
    If vOldChar in [' ', ',', '=', '-', '+', '<', '>', '(', ')', ':', '|'] Then //Corre��o postada por Jos� no Forum.
//    if vOldChar in [' ', '=', '-', '+', '<', '>', '(', ')', ':', '|'] then
     Begin
      While Not (FCurrentPos^ = #0) Do
       Begin
        if FCurrentPos^ in ['0'..'9', 'A'..'Z','a'..'z', '_'] then

         Result := Result + FCurrentPos^
        Else
         Break;
        Inc(FCurrentPos);
       End;
     End;
   End
  Else
   Inc(FCurrentPos);
  vOldChar := FCurrentPos^;
 End;
Begin
 Result := TStringList.Create;
 vTemp  := SQL;
 FCurrentPos := PChar(vTemp);
 While Not (FCurrentPos^ = #0) do
  Begin
   If Not (FCurrentPos^ in [#0..' ', ',',
                           '''', '"',
                           '0'..'9', 'A'..'Z',
                           'a'..'z', '_',
                           '$', #127..#255]) Then


    Begin
     vParamName := GetParamName;
     If Trim(vParamName) <> '' Then
      Begin
       Result.Add(vParamName);
       Inc(FCurrentPos);
      End;
    End
   Else
    Begin
     vOldChar := FCurrentPos^;
     Inc(FCurrentPos);
    End;
  End;
End;

Function ReturnParams(SQL : String) : TStringList;
Begin
 Result := ScanParams(SQL);
End;

Function ReturnParamsAtual(ParamsList : TParams) : TStringList;
Var
 I : Integer;
Begin
 Result := Nil;
 If ParamsList.Count > 0 Then
  Begin
   Result := TStringList.Create;
   For I := 0 To ParamsList.Count -1 Do
    Result.Add(ParamsList[I].Name);
  End;
End;

procedure TRESTDWClientSQL.CreateParams;
Var
 I         : Integer;
 ParamsListAtual,
 ParamList : TStringList;
 Procedure CreateParam(Value : String);
  Function ParamSeek (Name : String) : Boolean;
  Var
   I : Integer;
  Begin
   Result := False;
   For I := 0 To vParams.Count -1 Do
    Begin
     Result := LowerCase(vParams.items[i].Name) = LowerCase(Name);
     If Result Then
      Break;
    End;
  End;
 Var
  FieldDef : TField;
 Begin
  FieldDef := FindField(Value);
  If FieldDef <> Nil Then
   Begin
    If Not (ParamSeek(Value)) Then
     Begin
      vParams.CreateParam(FieldDef.DataType, Value, ptInput);
      vParams.ParamByName(Value).Size := FieldDef.Size;
     End
    Else
     vParams.ParamByName(Value).DataType := FieldDef.DataType;
   End
  Else If Not(ParamSeek(Value)) Then
   vParams.CreateParam(ftString, Value, ptInput);
 End;
 Function CompareParams(A, B : TStringList) : Boolean;
 Var
  I, X : Integer;
 Begin
  Result := (A <> Nil) And (B <> Nil);
  If Result Then
   Begin
    For I := 0 To A.Count -1 Do
     Begin
      For X := 0 To B.Count -1 Do
       Begin
        Result := lowercase(A[I]) = lowercase(B[X]);
        If Result Then
         Break;
       End;
      If Not Result Then
       Break;
     End;
   End;
  If Result Then
   Result := B.Count > 0;
 End;
Begin
 ParamList       := ReturnParams(vSQL.Text);
 ParamsListAtual := ReturnParamsAtual(vParams);
 vParamCount     := 0;
 If Not CompareParams(ParamsListAtual, ParamList) Then
  vParams.Clear;
 If ParamList <> Nil Then
 For I := 0 to ParamList.Count -1 Do
  CreateParam(ParamList[I]);
 If ParamList.Count > 0 Then
  vParamCount := vParams.Count;
 ParamList.Free;
 If Assigned(ParamsListAtual) then
  FreeAndNil(ParamsListAtual);
End;

Procedure TRESTDWTable.ProcCalcFields(DataSet: TDataSet);
Begin
 If (vInBlockEvents) Then
  Exit;
 If Assigned(vOnCalcFields) Then
  vOnCalcFields(Dataset);
End;

procedure TRESTDWClientSQL.ProcCalcFields(DataSet: TDataSet);
Begin
 If (vInBlockEvents) Then
  Exit;
 If Assigned(vOnCalcFields) Then
  vOnCalcFields(Dataset);
End;

Procedure TRESTDWTable.ProcAfterScroll(DataSet: TDataSet);
Var
 JSONValue    : TJSONValue;
 vRecordCount : Integer;
Begin
 If vInBlockEvents Then
  Exit;
 If State = dsBrowse Then
  Begin
   If Not Active Then
    PrepareDetailsNew
   Else
    Begin
     vActualRec      := Recno;
     vRecordCount    := vOldRecordCount;
     If Not vNotRepage Then
      Begin
       If (vRESTDataBase <> Nil)                  And
          ((vDatapacks > -1) And (vActualRec > 0) And
           (vActualRec = vRecordCount)            And
           (vRecordCount < vJsonCount))           Then
        Begin
         vOnPacks := True;
         JSONValue := TJSONValue.Create;
         Try
          JSONValue.Encoding := vRESTDataBase.Encoding;
          JSONValue.Encoded  := vRESTDataBase.EncodeStrings;
          {$IFDEF FPC}
          JSONValue.DatabaseCharSet := DatabaseCharSet;
          {$ENDIF}
          JSONValue.Utf8SpecialChars := True;
          If vInternalLast Then
           Begin
            vInternalLast := False;
            JSONValue.OnWriterProcess := OnWriterProcess;
            JSONValue.ServerFieldList := ServerFieldList;
            {$IFDEF FPC}
             JSONValue.NewFieldList       := @NewFieldList;
             JSONValue.CreateDataSet      := @CreateDataSet;
             JSONValue.NewDataField       := @NewDataField;
             JSONValue.SetInitDataset     := @SetInitDataset;
             JSONValue.SetRecordCount     := @SetRecordCount;
             JSONValue.Setnotrepage       := @Setnotrepage;
             JSONValue.SetInDesignEvents  := @SetInDesignEvents;
             JSONValue.SetInBlockEvents   := @SetInBlockEvents;
             JSONValue.FieldListCount     := @FieldListCount;
             JSONValue.GetInDesignEvents  := @GetInDesignEvents;
             JSONValue.PrepareDetailsNew  := @PrepareDetailsNew;
             JSONValue.PrepareDetails     := @PrepareDetails;
            {$ELSE}
             JSONValue.NewFieldList       := NewFieldList;
             JSONValue.CreateDataSet      := CreateDataSet;
             JSONValue.NewDataField       := NewDataField;
             JSONValue.SetInitDataset     := SetInitDataset;
             JSONValue.SetRecordCount     := SetRecordCount;
             JSONValue.Setnotrepage       := Setnotrepage;
             JSONValue.SetInDesignEvents  := SetInDesignEvents;
             JSONValue.SetInBlockEvents   := SetInBlockEvents;
             JSONValue.FieldListCount     := FieldListCount;
             JSONValue.GetInDesignEvents  := GetInDesignEvents;
             JSONValue.PrepareDetailsNew  := PrepareDetailsNew;
             JSONValue.PrepareDetails     := PrepareDetails;
            {$ENDIF}
            JSONValue.WriteToDataset(dtFull, vActualJSON, Self, vJsonCount, vJsonCount - vActualRec, vActualRec);
            vOldRecordCount := vJsonCount;
            Last;
           End
          Else
           Begin
            JSONValue.OnWriterProcess := OnWriterProcess;
            JSONValue.ServerFieldList := ServerFieldList;
            {$IFDEF FPC}
             JSONValue.NewFieldList   := @NewFieldList;
             JSONValue.CreateDataSet  := @CreateDataSet;
             JSONValue.NewDataField   := @NewDataField;
             JSONValue.SetInitDataset := @SetInitDataset;
             JSONValue.SetRecordCount     := @SetRecordCount;
             JSONValue.Setnotrepage       := @Setnotrepage;
             JSONValue.SetInDesignEvents  := @SetInDesignEvents;
             JSONValue.SetInBlockEvents   := @SetInBlockEvents;
             JSONValue.FieldListCount     := @FieldListCount;
             JSONValue.GetInDesignEvents  := @GetInDesignEvents;
             JSONValue.PrepareDetailsNew  := @PrepareDetailsNew;
             JSONValue.PrepareDetails     := @PrepareDetails;
            {$ELSE}
             JSONValue.NewFieldList   := NewFieldList;
             JSONValue.CreateDataSet  := CreateDataSet;
             JSONValue.NewDataField   := NewDataField;
             JSONValue.SetInitDataset := SetInitDataset;
             JSONValue.SetRecordCount     := SetRecordCount;
             JSONValue.Setnotrepage       := Setnotrepage;
             JSONValue.SetInDesignEvents  := SetInDesignEvents;
             JSONValue.SetInBlockEvents   := SetInBlockEvents;
             JSONValue.FieldListCount     := FieldListCount;
             JSONValue.GetInDesignEvents  := GetInDesignEvents;
             JSONValue.PrepareDetailsNew  := PrepareDetailsNew;
             JSONValue.PrepareDetails     := PrepareDetails;
            {$ENDIF}
            JSONValue.WriteToDataset(dtFull, vActualJSON, Self, vJsonCount, vDatapacks, vActualRec);
            vOldRecordCount := Recno + vDatapacks;
            If vOldRecordCount > vJsonCount Then
             vOldRecordCount := vJsonCount;
           End;
         Finally
          JSONValue.Free;
          vOnPacks := False;
         End;
        End;
      End;
     vNotRepage := False;
     If RecordCount = 0 Then
      PrepareDetailsNew
     Else
      PrepareDetails(True)
    End;
  End
 Else If State = dsInactive Then
  PrepareDetails(False)
 Else If State = dsInsert Then
  PrepareDetailsNew;
 If Not ((vOnPacks) or (vInitDataset)) Then
  If Assigned(vOnAfterScroll) Then
   vOnAfterScroll(Dataset);
End;

procedure TRESTDWClientSQL.ProcAfterScroll(DataSet: TDataSet);
Var
 JSONValue    : TJSONValue;
 vRecordCount : Integer;
Begin
 If vInBlockEvents Then
  Exit;
 If State = dsBrowse Then
  Begin
   If Not Active Then
    PrepareDetailsNew
   Else
    Begin
     vActualRec      := Recno;
     vRecordCount    := vOldRecordCount;
     If Not vNotRepage Then
      Begin
       If (vRESTDataBase <> Nil)                  And
          ((vDatapacks > -1) And (vActualRec > 0) And
           (vActualRec = vRecordCount)            And
           (vRecordCount < vJsonCount))           Then
        Begin
         vOnPacks := True;
         JSONValue := TJSONValue.Create;
         Try
          JSONValue.Encoding := vRESTDataBase.Encoding;
          JSONValue.Encoded  := vRESTDataBase.EncodeStrings;
          JSONValue.ServerFieldList := ServerFieldList;
          {$IFDEF FPC}
           JSONValue.DatabaseCharSet := DatabaseCharSet;
           JSONValue.NewFieldList    := @NewFieldList;
           JSONValue.CreateDataSet   := @CreateDataSet;
           JSONValue.NewDataField    := @NewDataField;
           JSONValue.SetInitDataset  := @SetInitDataset;
           JSONValue.SetRecordCount     := @SetRecordCount;
           JSONValue.Setnotrepage       := @Setnotrepage;
           JSONValue.SetInDesignEvents  := @SetInDesignEvents;
           JSONValue.SetInBlockEvents   := @SetInBlockEvents;
           JSONValue.SetInactive        := @SetInactive;
           JSONValue.FieldListCount     := @FieldListCount;
           JSONValue.GetInDesignEvents  := @GetInDesignEvents;
           JSONValue.PrepareDetailsNew  := @PrepareDetailsNew;
           JSONValue.PrepareDetails     := @PrepareDetails;
          {$ELSE}
           JSONValue.NewFieldList   := NewFieldList;
           JSONValue.CreateDataSet  := CreateDataSet;
           JSONValue.NewDataField   := NewDataField;
           JSONValue.SetInitDataset := SetInitDataset;
           JSONValue.SetRecordCount     := SetRecordCount;
           JSONValue.Setnotrepage       := Setnotrepage;
           JSONValue.SetInDesignEvents  := SetInDesignEvents;
           JSONValue.SetInBlockEvents   := SetInBlockEvents;
           JSONValue.SetInactive        := SetInactive;
           JSONValue.FieldListCount     := FieldListCount;
           JSONValue.GetInDesignEvents  := GetInDesignEvents;
           JSONValue.PrepareDetailsNew  := PrepareDetailsNew;
           JSONValue.PrepareDetails     := PrepareDetails;
          {$ENDIF}
          JSONValue.Utf8SpecialChars := True;
          If vInternalLast Then
           Begin
            vInternalLast := False;
            JSONValue.OnWriterProcess := OnWriterProcess;
            JSONValue.WriteToDataset(dtFull, vActualJSON, Self, vJsonCount, vJsonCount - vActualRec, vActualRec);
            vOldRecordCount := vJsonCount;
            Last;
           End
          Else
           Begin
            JSONValue.OnWriterProcess := OnWriterProcess;
            JSONValue.WriteToDataset(dtFull, vActualJSON, Self, vJsonCount, vDatapacks, vActualRec);
            vOldRecordCount := Recno + vDatapacks;
            If vOldRecordCount > vJsonCount Then
             vOldRecordCount := vJsonCount;
           End;
         Finally
          JSONValue.Free;
          vOnPacks := False;
         End;
        End;
      End;
     vNotRepage := False;
     If RecordCount = 0 Then
      PrepareDetailsNew
     Else
      PrepareDetails(True)
    End;
  End
 Else If State = dsInactive Then
  PrepareDetails(False)
 Else If State = dsInsert Then
  PrepareDetailsNew;
 If Not ((vOnPacks) or (vInitDataset)) Then
  If Assigned(vOnAfterScroll) Then
   vOnAfterScroll(Dataset);
End;

Procedure TRESTDWTable.GotoRec(const aRecNo: Integer);
Var
 ActiveRecNo,
 Distance     : Integer;
Begin
 If (aRecNo > 0) Then
  Begin
   ActiveRecNo := Self.RecNo;
   If (aRecNo <> ActiveRecNo) Then
    Begin
     Self.DisableControls;
     Try
      Distance := aRecNo - ActiveRecNo;
      Self.MoveBy(Distance);
     Finally
      Self.EnableControls;
     End;
    End;
  End;
End;

Procedure TRESTDWClientSQL.GotoRec(const aRecNo: Integer);
Var
 ActiveRecNo,
 Distance     : Integer;
Begin
 If (aRecNo > 0) Then
  Begin
   ActiveRecNo := Self.RecNo;
   If (aRecNo <> ActiveRecNo) Then
    Begin
     Self.DisableControls;
     Try
      Distance := aRecNo - ActiveRecNo;
      Self.MoveBy(Distance);
     Finally
      Self.EnableControls;
     End;
    End;
  End;
End;

Procedure TRESTDWTable.ProcBeforeDelete(DataSet: TDataSet);
Var
 I             : Integer;
 vDetailClient : TRESTDWClientSQLBase;
Begin
 If Not vReadData Then
  Begin
   vReadData := True;
   vOldStatus   := State;
   Try
    vActualRec   := RecNo;
   Except
    vActualRec   := -1;
   End;
   Try
    If vCascadeDelete Then
     Begin
      For I := 0 To vMasterDetailList.Count -1 Do
       Begin
        vMasterDetailList.Items[I].ParseFields(TRESTDWTable(vMasterDetailList.Items[I].DataSet).RelationFields.Text);
        vDetailClient        := TRESTDWTable(vMasterDetailList.Items[I].DataSet);
        If vDetailClient <> Nil Then
         Begin
          Try
           vDetailClient.First;
           While Not vDetailClient.Eof Do
            vDetailClient.Delete;
          Finally
           vReadData := False;
          End;
         End;
       End;
     End;
    If Not((vInBlockEvents) or (vInitDataset)) Then
     Begin
      If Assigned(vBeforeDelete) Then
       vBeforeDelete(DataSet);
      SetRecordCount(RecordCount - 1, RecordCount - 1);
      If (Trim(vTableName) <> '') Or (vUpdateSQL <> Nil) Then
       Begin
        If (vUpdateSQL <> Nil) Then
         vUpdateSQL.Store(vUpdateSQL.vSQLDelete.Text, Self)
        Else
         Begin
          TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
          TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
          TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, mmDelete,
                                                             TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          If vMassiveCache <> Nil Then
           Begin
            vMassiveCache.Add(TMassiveDatasetBuffer(vMassiveDataset).ToJSON, Self);
            TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
           End;
         End;
       End;
     End;
    vReadData := False;
   Except
    On e : EAbort Do
     Begin
      vReadData := False;
      Abort;
     End;
    On E : Exception do
     begin
      vReadData := False;
      Raise Exception.Create(e.Message);
      Abort;
     End;
   End;
  End;
End;

procedure TRESTDWClientSQL.ProcBeforeDelete(DataSet: TDataSet);
Var
 I             : Integer;
 vDetailClient : TRESTDWClientSQL;
Begin
 If Not vReadData Then
  Begin
   vReadData := True;
   vOldStatus   := State;
   Try
    vActualRec   := RecNo;
   Except
    vActualRec   := -1;
   End;
   Try
//    SaveToStream(OldData);
    If vCascadeDelete Then
     Begin
      For I := 0 To vMasterDetailList.Count -1 Do
       Begin
        vMasterDetailList.Items[I].ParseFields(TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet).RelationFields.Text);
        vDetailClient        := TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet);
        If vDetailClient <> Nil Then
         Begin
          Try
           vDetailClient.First;
           While Not vDetailClient.Eof Do
            vDetailClient.Delete;
          Finally
           vReadData := False;
          End;
         End;
       End;
     End;
    If Not((vInBlockEvents) or (vInitDataset)) Then
     Begin
      If Assigned(vBeforeDelete) Then
       vBeforeDelete(DataSet);
      SetRecordCount(RecordCount - 1, RecordCount - 1);
      If (Trim(vUpdateTableName) <> '') Or (vUpdateSQL <> Nil) Then
       Begin
        If (vUpdateSQL <> Nil) Then
         vUpdateSQL.Store(vUpdateSQL.vSQLDelete.Text, Self)
        Else
         Begin
          TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
          TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
          TMassiveDatasetBuffer(vMassiveDataset).MassiveMode := mmDelete;
          TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, mmDelete,
                                                             TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          If vMassiveCache <> Nil Then
           Begin
            vMassiveCache.Add(TMassiveDatasetBuffer(vMassiveDataset).ToJSON, Self);
            TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
           End;
         End;
       End;
     End;
    vReadData := False;
   Except
    On e : EAbort Do
     Begin
      vReadData := False;
      Abort;
     End; //Corre��o enviada por Endrigo Rodriguez
     //Alexande Magno - 28/11/2018 - Pedido do Magnele
    On E : Exception do
     begin
      vReadData := False;
      Raise Exception.Create(e.Message);
      Abort;
     End;
   End;
  End;
End;

Procedure TRESTDWTable.ProcBeforeEdit(DataSet: TDataSet);
Begin
 If Not((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If (Trim(vTableName) <> '') And (vUpdateSQL = Nil) Then
    Begin
     TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
     TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
     TMassiveDatasetBuffer(vMassiveDataset).NewBuffer  (Self, mmUpdate, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
     TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, mmUpdate, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
    End;
   If Assigned(vBeforeEdit) Then
    vBeforeEdit(Dataset);
  End;
End;

procedure TRESTDWClientSQL.ProcBeforeEdit(DataSet: TDataSet);
Begin
 If Not((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If (Trim(vUpdateTableName) <> '') And (vUpdateSQL = Nil) Then
    Begin
     TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
     TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
     TMassiveDatasetBuffer(vMassiveDataset).MassiveMode := mmUpdate;
     TMassiveDatasetBuffer(vMassiveDataset).NewBuffer  (Self,
                                                        TMassiveDatasetBuffer(vMassiveDataset).MassiveMode,
                                                        TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
     TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self,
                                                        TMassiveDatasetBuffer(vMassiveDataset).MassiveMode,
                                                        TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
    End;
   If Assigned(vBeforeEdit) Then
    vBeforeEdit(Dataset);
  End;
End;

procedure TRESTDWTable.ProcBeforeInsert(DataSet: TDataSet);
Begin
 If Not((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If Assigned(vBeforeInsert) Then
    vBeforeInsert(Dataset);
  End;
End;

procedure TRESTDWClientSQL.ProcBeforeInsert(DataSet: TDataSet);
Begin
 If Not((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If Assigned(vBeforeInsert) Then
    vBeforeInsert(Dataset);
  End;
End;

Procedure TRESTDWTable.ProcBeforeOpen(DataSet: TDataSet);
Begin
 MasterFields := '';
 If Not((vInBlockEvents) or (vInitDataset) or (vInRefreshData)) Then
  Begin
   If Assigned(vBeforeOpen) Then
   vBeforeOpen(Dataset);
  End;
End;

procedure TRESTDWClientSQL.ProcBeforeOpen(DataSet: TDataSet);
Begin
 MasterFields := '';
 If Not((vInBlockEvents) or (vInitDataset) or (vInRefreshData)) Then
  Begin
   If Assigned(vBeforeOpen) Then
   vBeforeOpen(Dataset);
  End;
End;

Procedure TRESTDWTable.ProcBeforePost(DataSet: TDataSet);
Begin
 If Not vReadData Then
  Begin
   vActualRec    := -1;
   vReadData     := True;
   vOldState     := State;
   vOldStatus    := State;
   Try
    If vOldState = dsInsert then
     vActualRec  := RecNo + 1
    Else
     vActualRec  := RecNo;
    Edit;
    vReadData     := False;
    If Not((vInBlockEvents) or (vInitDataset)) Then
     Begin
      If vOldState = dsInsert then
       SetRecordCount(RecordCount + 1, RecordCount + 1);
      If Assigned(vBeforePost) Then
       vBeforePost(DataSet);
      If ((Trim(vTableName) <> '') Or (vUpdateSQL <> Nil)) And (vOldState = dsEdit) Then
       Begin
        If (vUpdateSQL <> Nil) Then
         vUpdateSQL.Store(vUpdateSQL.vSQLUpdate.Text, Self)
        Else
         Begin
          TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
          TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
          TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, DatasetStateToMassiveType(vOldState),
                                                             vOldState = dsEdit,
                                                             TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          If vOldState = dsEdit Then
           Begin
            If TMassiveDatasetBuffer(vMassiveDataset).TempBuffer <> Nil Then
             Begin
              If TMassiveDatasetBuffer(vMassiveDataset).TempBuffer.UpdateFieldChanges <> Nil Then
               Begin
                If TMassiveDatasetBuffer(vMassiveDataset).TempBuffer.UpdateFieldChanges.Count = 0 Then
                 TMassiveDatasetBuffer(vMassiveDataset).ClearLine
                Else
                 TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
               End
              Else
               TMassiveDatasetBuffer(vMassiveDataset).ClearLine;
             End
            Else
             TMassiveDatasetBuffer(vMassiveDataset).ClearLine;
           End
          Else
           TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          If vMassiveCache <> Nil Then
           Begin
            vMassiveCache.Add(TMassiveDatasetBuffer(vMassiveDataset).ToJSON, Self);
            TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
           End;
         End;
       End;
     End;
   Except
    On e : EAbort Do
     Begin
      vActualRec   := -1;
      vReadData    := False;
      Abort;
     End;
    On E : Exception Do
     Begin
      vActualRec   := -1;
      vReadData    := False;
      Raise Exception.Create(e.Message);
      Abort;
     End;
   End;
  End;
End;

procedure TRESTDWClientSQL.ProcBeforePost(DataSet: TDataSet);
Begin
 If Not vReadData Then
  Begin
   vActualRec    := -1;
   vReadData     := True;
   vOldState     := State;
   vOldStatus    := State;
   Try
    If vOldState = dsInsert then
     vActualRec  := RecNo + 1
    Else
     vActualRec  := RecNo;
    Edit;
    vReadData     := False;
    If Not((vInBlockEvents) or (vInitDataset)) Then
     Begin
      If vOldState = dsInsert then
       SetRecordCount(RecordCount + 1, RecordCount + 1);
      If Assigned(vBeforePost) Then
       vBeforePost(DataSet);
      If ((Trim(vUpdateTableName) <> '') Or (vUpdateSQL <> Nil)) And (vOldState = dsEdit) Then
       Begin
        If (vUpdateSQL <> Nil) Then
         vUpdateSQL.Store(vUpdateSQL.vSQLUpdate.Text, Self)
        Else
         Begin
          TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
          TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
          TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, DatasetStateToMassiveType(vOldState),
                                                             vOldState = dsEdit, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          If vOldState = dsEdit Then
           Begin
            If TMassiveDatasetBuffer(vMassiveDataset).TempBuffer <> Nil Then
             Begin
              If TMassiveDatasetBuffer(vMassiveDataset).TempBuffer.UpdateFieldChanges <> Nil Then
               Begin
                If TMassiveDatasetBuffer(vMassiveDataset).TempBuffer.UpdateFieldChanges.Count = 0 Then
                 TMassiveDatasetBuffer(vMassiveDataset).ClearLine
                Else
                 TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
               End
              Else
               TMassiveDatasetBuffer(vMassiveDataset).ClearLine;
             End
            Else
             TMassiveDatasetBuffer(vMassiveDataset).ClearLine;
           End
          Else
           TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          If vMassiveCache <> Nil Then
           Begin
            vMassiveCache.Add(TMassiveDatasetBuffer(vMassiveDataset).ToJSON, Self);
            TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
           End;
         End;
       End;
     End;
   Except
    On e : EAbort Do
     Begin
      vActualRec   := -1;
      vReadData    := False;
      Abort;
     End;
    On E : Exception Do
     Begin
      vActualRec   := -1;
      vReadData    := False;
      Raise Exception.Create(e.Message);
      Abort;
     End;
   End;
  End;
End;

procedure TRESTDWClientSQL.ProcBeforeExec(DataSet: TDataSet);
Begin
 If Not vReadData Then
  Begin
   vReadData     := True;
   Try
    If MassiveType = mtMassiveObject Then
     Begin
      Try
       If Not((vInBlockEvents) or (vInitDataset)) Then
        Begin
         If (vUpdateSQL <> Nil) Then
          vUpdateSQL.Store(vUpdateSQL.vSQLUpdate.Text, Self)
         Else
          Begin
           TMassiveDatasetBuffer(vMassiveDataset).MassiveMode   := mmExec;
           TMassiveDatasetBuffer(vMassiveDataset).MassiveType   := MassiveType;
           TMassiveDatasetBuffer(vMassiveDataset).LastOpen      := vLastOpen;
           TMassiveDatasetBuffer(vMassiveDataset).Dataexec.Text := vSQL.Text;
           TMassiveDatasetBuffer(vMassiveDataset).Params.LoadFromParams(Params);
           TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self,  TMassiveDatasetBuffer(vMassiveDataset).MassiveMode,
                                                              False, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
           TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer (Self,  TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
           If vMassiveCache <> Nil Then
            Begin
             vMassiveCache.MassiveType                          := MassiveType;
             vMassiveCache.Add(TMassiveDatasetBuffer(vMassiveDataset).ToJSON, Self);
             TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
            End;
          End;
        End;
      Except
       On E : Exception Do
        Begin
         Raise Exception.Create(e.Message);
         Abort;
        End;
      End;
     End;
   Finally
    vReadData := False;
   End;
  End;
End;

Procedure TRESTDWTable.ProcBeforeScroll(DataSet: TDataSet);
Begin
 If ((vInBlockEvents) or (vInitDataset)) Then
  Exit;
 If Not vOnPacks Then
  If Assigned(vOnBeforeScroll) Then
   vOnBeforeScroll(Dataset);
End;

Procedure TRESTDWClientSQL.ProcBeforeScroll(DataSet: TDataSet);
Begin
 If ((vInBlockEvents) or (vInitDataset)) Then
  Exit;
 If Not vOnPacks Then
  If Assigned(vOnBeforeScroll) Then
   vOnBeforeScroll(Dataset);
End;

Procedure TRESTDWTable.ProcNewRecord(DataSet: TDataSet);
Begin
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If Assigned(vNewRecord) Then
    vNewRecord(Dataset);
  End;
End;

procedure TRESTDWClientSQL.ProcNewRecord(DataSet: TDataSet);
begin
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If Assigned(vNewRecord) Then
    vNewRecord(Dataset);
  End;
end;

Procedure TRESTDWTable.RebuildMassiveDataset;
Begin
 CreateMassiveDataset;
End;

procedure TRESTDWClientSQL.RebuildMassiveDataset;
Begin
 CreateMassiveDataset;
End;

Procedure TRESTDWTable.Refresh;
Var
 Cursor : Integer;
Begin
 Cursor := 0;
 If Active then
  Begin
   If RecordCount > 0 then
    Cursor := Self.CurrentRecord;
   Close;
   Open;
   If Active then
    Begin
     If RecordCount > 0 Then
      MoveBy(Cursor);
    End;
  End;
End;

Procedure TRESTDWClientSQL.Refresh;
Var
 Cursor : Integer;
Begin
 Cursor := 0;
 If Active then
  Try
   ProcBeforeRefresh(Self);
   vInRefreshData := True;
   If RecordCount > 0 then
    Cursor := Self.CurrentRecord;
   Close;
   Open;
   If Active then
    Begin
     If RecordCount > 0 Then
      MoveBy(Cursor);
    End;
   ProcAfterRefresh(Self);
  Finally
    vInRefreshData := False;
  End;
End;

Procedure TRESTDWTable.RestoreDatasetPosition;
begin
 vInBlockEvents := False;
 TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
 RebuildMassiveDataset;
 vInBlockEvents := False;
end;

procedure TRESTDWClientSQL.RestoreDatasetPosition;
begin
 vInBlockEvents := False;
 TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
 RebuildMassiveDataset;
 vInBlockEvents := False;
end;

procedure TRESTDWTable.ProcBeforeClose(DataSet: TDataSet);
Begin
 If (Assigned(vOnBeforeClose) and not vInBlockEvents and not vInRefreshData) then
  vOnBeforeClose(Dataset);
End;

procedure TRESTDWTable.ProcAfterClose(DataSet: TDataSet);
Var
 I : Integer;
 vDetailClient : TRESTDWClientSQLBase;
Begin
 vActualJSON   := '';
 If (Assigned(vOnAfterClose) and not vInBlockEvents and not vInRefreshData) then
  vOnAfterClose(Dataset);
 For I := 0 To vMasterDetailList.Count -1 Do
  Begin
   vMasterDetailList.Items[I].ParseFields(TRESTDWTable(vMasterDetailList.Items[I].DataSet).RelationFields.Text);
   vDetailClient        := TRESTDWTable(vMasterDetailList.Items[I].DataSet);
   If vDetailClient <> Nil Then
    vDetailClient.Close;
  End;
End;

procedure TRESTDWTable.ProcBeforeRefresh(DataSet: TDataSet);
Begin
  If (Assigned(vOnBeforeRefresh) and not vInBlockEvents) Then
   vOnBeforeRefresh(DataSet);
End;

procedure TRESTDWTable.ProcAfterRefresh(DataSet: TDataSet);
Begin
  If (Assigned(vOnAfterRefresh) and not vInBlockEvents) Then
   vOnAfterRefresh(DataSet);
End;

procedure TRESTDWClientSQL.ProcBeforeClose(DataSet: TDataSet);
Begin
 If (Assigned(vOnBeforeClose) and not vInBlockEvents and not vInRefreshData) then
  vOnBeforeClose(Dataset);
End;

procedure TRESTDWClientSQL.ProcAfterClose(DataSet: TDataSet);
Var
 I : Integer;
 vDetailClient : TRESTDWClientSQL;
Begin
 vActualJSON   := '';
 If (Assigned(vOnAfterClose) and not vInBlockEvents and not vInRefreshData) then
  vOnAfterClose(Dataset);
 For I := 0 To vMasterDetailList.Count -1 Do
  Begin
   vMasterDetailList.Items[I].ParseFields(TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet).RelationFields.Text);
   vDetailClient        := TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet);
   If vDetailClient <> Nil Then
    vDetailClient.Close;
  End;
End;

procedure TRESTDWClientSQL.ProcBeforeRefresh(DataSet: TDataSet);
Begin
  If (Assigned(vOnBeforeRefresh) and not vInBlockEvents) Then
   vOnBeforeRefresh(DataSet);
End;

procedure TRESTDWClientSQL.ProcAfterRefresh(DataSet: TDataSet);
Begin
  If (Assigned(vOnAfterRefresh) and not vInBlockEvents) Then
   vOnAfterRefresh(DataSet);
End;

Procedure TRESTDWTable.ProcAfterEdit(DataSet: TDataSet);
Begin
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  If Assigned(vAfterEdit) Then
   vAfterEdit(Dataset);
End;

procedure TRESTDWClientSQL.ProcAfterEdit(DataSet: TDataSet);
Begin
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  If Assigned(vAfterEdit) Then
   vAfterEdit(Dataset);
End;

Procedure TRESTDWTable.ProcAfterInsert(DataSet: TDataSet);
Var
 I             : Integer;
 vFieldA,
 vFieldD       : String;
 vFields       : TStringList;
 vDetailClient : TRESTDWClientSQLBase;
 Procedure CloneDetails(Value : TRESTDWClientSQLBase; FieldName, FieldNameDest : String);
 Begin
  If (FindField(FieldNameDest) <> Nil) And (Value.FindField(FieldName) <> Nil) Then
   FindField(FieldNameDest).Value := Value.FindField(FieldName).Value;
 End;
 Procedure ParseFields(Value : String);
 Var
  I           : Integer;
  vTempFields : TStringList;
 Begin
  vFields.Clear;
  vTempFields      := TStringList.Create;
  vTempFields.Text := Value;
  Try
   For I := vTempFields.Count -1 DownTo 0 Do
    Begin
     If Pos(';', vTempFields[I]) > 0 Then
      Begin
       vFields.Add(UpperCase(Trim(Copy(vTempFields[I], 1, Pos(';', vTempFields[I]) -1))));
       vTempFields.Delete(I);
      End
     Else
      Begin
       vFields.Add(UpperCase(Trim(vTempFields[I])));
       vTempFields.Clear;
      End;
    End;
  Finally
   FreeAndNil(vTempFields);
  End;
 End;
Begin
 vDetailClient := vMasterDataSet;
 If (vDetailClient <> Nil) And (Fields.Count > 0) Then
  Begin
   vFields      := TStringList.Create;
   vFields.Text := RelationFields.Text;
   For I := 0 To vFields.Count -1 Do
    Begin
     vFieldA := Copy(vFields[I], InitStrPos, (Pos('=', vFields[I]) -1) - FinalStrPos);
     vFieldD := Copy(vFields[I], (Pos('=', vFields[I]) - FinalStrPos) + 1, Length(vFields[I]));
     If vDetailClient.FindField(vFieldA) <> Nil Then
      CloneDetails(vDetailClient, vFieldA, vFieldD);
    End;
   vFields.Free;
  End;
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If (Trim(vTableName) <> '') And (vUpdateSQL = Nil) Then
    Begin
     TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
     TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
     TMassiveDatasetBuffer(vMassiveDataset).NewBuffer  (Self, mmInsert, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
     TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, mmInsert, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
    End;
   If Assigned(vAfterInsert) Then
    vAfterInsert(Dataset);
  End;
End;

procedure TRESTDWClientSQL.ProcAfterInsert(DataSet: TDataSet);
Var
 I             : Integer;
 vFieldA,
 vFieldD       : String;
 vFields       : TStringList;
 vDetailClient : TRESTDWClientSQL;
 Procedure CloneDetails(Value : TRESTDWClientSQL; FieldName, FieldNameDest : String);
 Begin
  If (FindField(FieldNameDest) <> Nil) And (Value.FindField(FieldName) <> Nil) Then
   FindField(FieldNameDest).Value := Value.FindField(FieldName).Value;
 End;
 Procedure ParseFields(Value : String);
 Var
  I           : Integer;
  vTempFields : TStringList;
 Begin
  vFields.Clear;
  vTempFields      := TStringList.Create;
  vTempFields.Text := Value;
  Try
   For I := vTempFields.Count -1 DownTo 0 Do
    Begin
     If Pos(';', vTempFields[I]) > 0 Then
      Begin
       vFields.Add(UpperCase(Trim(Copy(vTempFields[I], 1, Pos(';', vTempFields[I]) -1))));
       vTempFields.Delete(I);
      End
     Else
      Begin
       vFields.Add(UpperCase(Trim(vTempFields[I])));
       vTempFields.Clear;
      End;
    End;
  Finally
   FreeAndNil(vTempFields);
  End;
 End;
Begin
 vDetailClient := vMasterDataSet;
 If (vDetailClient <> Nil) And (Fields.Count > 0) Then
  Begin
   vFields      := TStringList.Create;
   vFields.Text := RelationFields.Text;
   For I := 0 To vFields.Count -1 Do
    Begin
     vFieldA := Copy(vFields[I], InitStrPos, (Pos('=', vFields[I]) -1) - FinalStrPos);
     vFieldD := Copy(vFields[I], (Pos('=', vFields[I]) - FinalStrPos) + 1, Length(vFields[I]));
     If vDetailClient.FindField(vFieldA) <> Nil Then
      CloneDetails(vDetailClient, vFieldA, vFieldD);
    End;
   vFields.Free;
  End;
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If (Trim(vUpdateTableName) <> '') And (vUpdateSQL = Nil) Then
    Begin
     TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
     TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
     TMassiveDatasetBuffer(vMassiveDataset).MassiveMode := mmInsert;
     TMassiveDatasetBuffer(vMassiveDataset).NewBuffer  (Self, mmInsert, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
     TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, mmInsert, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
    End;
   If Assigned(vAfterInsert) Then
    vAfterInsert(Dataset);
  End;
End;

procedure TRESTDWTable.ProcAfterOpen(DataSet: TDataSet);
Begin
 If Not ((vInBlockEvents) or (vInitDataset) or (vInRefreshData)) Then
  Begin
   If Assigned(vOnAfterOpen) Then
    vOnAfterOpen(Dataset);
  End;
End;

procedure TRESTDWClientSQL.ProcAfterOpen(DataSet: TDataSet);
Begin
 If Not ((vInBlockEvents) or (vInitDataset) or (vInRefreshData)) Then
  Begin
   If Assigned(vOnAfterOpen) Then
    vOnAfterOpen(Dataset);
  End;
End;

Procedure TRESTDWTable.ProcAfterCancel(DataSet: TDataSet);
Begin
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If (Trim(vTableName) <> '') And (vUpdateSQL = Nil) Then
    TMassiveDatasetBuffer(vMassiveDataset).ClearLine;
   If Assigned(vAfterCancel) Then
    vAfterCancel(Dataset);
  End;
End;

procedure TRESTDWClientSQL.ProcAfterCancel(DataSet: TDataSet);
Begin
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If (Trim(vUpdateTableName) <> '') And (vUpdateSQL = Nil) Then
    TMassiveDatasetBuffer(vMassiveDataset).ClearLine;
   If Assigned(vAfterCancel) Then
    vAfterCancel(Dataset);
  End;
End;

Function TRESTDWTable.ProcessChanges(MassiveJSON : String) : Boolean;
Var
 I, A,
 vActualRecB   : Integer;
 bJsonValueC,
 bJsonValueB   : TDWJSONBase;
 bJsonArray,
 bJsonOBJ      : TDWJSONArray;
 bJsonValue    : TDWJSONObject;
 vOldReadOnly  : Boolean;
 vLastTimeB,
 vValue        : String;
 vStringStream : TMemoryStream;
 Function DecodeREC(BookmarkSTR  : String;
                    Var LastTime : String) : Integer;
 Var
  vTempString : String;
 Begin
  Result := -1;
  vTempString := BookmarkSTR;
  If Pos('|', vTempString) > 0 Then
   Begin
    Result := StrToInt(Copy(vTempString, InitStrPos, Pos('|', vTempString) -1));
    vTempString := Copy(vTempString, Pos('|', vTempString) +1, Length(vTempString));
    LastTime := DecodeStrings(vTempString{$IFDEF FPC}, csUndefined{$ENDIF});
   End;
 End;
Begin
 Result       := False;
 vStringStream := Nil;
 bJsonValueC   := Nil;
 bJsonValueB   := Nil;
 bJsonArray    := Nil;
 bJsonOBJ      := Nil;
 bJsonValue    := Nil;
 If Trim(MassiveJSON) = '' Then
  Exit;
 bJsonValue   := TDWJSONObject.Create(StringReplace(MassiveJSON, #$FEFF, '', [rfReplaceAll]));
 bJsonOBJ     := TDWJSONArray(bJsonValue);
 Try
  For I := 0 To bJsonOBJ.ElementCount -1 do
   Begin
    bJsonValueB  := bJsonOBJ.GetObject(I);
    Try
     vValue := DecodeStrings(TDWJSONObject(bJsonValueB).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF});
     Try
      vActualRecB := DecodeREC(vValue, vLastTimeB);
      If (vActualRecB > -1) Then
       Begin
        Self.GotoBookmark(TBookMark(HexToBookmark(vLastTimeB)));
        bJsonArray := TDWJSONObject(bJsonValueB).OpenArray('reflectionlines');
        Self.Edit;
        For A := 0 To bJsonArray.ElementCount -1 Do
         Begin
          bJsonValueC := bJsonArray.GetObject(A);
          //Alexandre Magno - 20/01/2019 - ADD Try Finally
          try
            If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name) <> Nil Then
             Begin
              vOldReadOnly := Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).ReadOnly;
              Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).ReadOnly := False;
              If (TDWJSONObject(bJsonValueC).Pairs[0].Value = 'null') Or
                 (Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).ReadOnly) Then
               Begin
                If Not (Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).ReadOnly) Then
                 Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Clear;
                Continue;
               End;
              If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                        ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                        ftString,    ftWideString,
                                                                        ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                                {$IF CompilerVersion > 21}
                                                                                        , ftWideMemo
                                                                                 {$IFEND}
                                                                                {$ENDIF}]    Then
               Begin
                If (TDWJSONObject(bJsonValueC).Pairs[0].Value <> Null) And
                   (Trim(TDWJSONObject(bJsonValueC).Pairs[0].Value) <> 'null') Then
                 Begin
                  vValue := DecodeStrings(TDWJSONObject(bJsonValueC).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF}); //TDWJSONObject(bJsonValueC).Pairs[0].Value;
                  {$IFNDEF FPC}{$IF CompilerVersion < 18}
                  vValue := utf8Decode(vValue);
                  {$IFEND}{$ENDIF}
                  If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Size > 0 Then
                   Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsString := Copy(vValue, 1, Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Size)
                  Else
                   Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsString := vValue;
                 End
                Else
                 Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Clear;
               End
              Else
               Begin
                If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                 Begin
                  If Not TDWJSONObject(bJsonValueC).Pairs[0].isnull Then
                   Begin
                    If TDWJSONObject(bJsonValueC).Pairs[0].Value <> Null Then
                     Begin
                      If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                       Begin
                        {$IFNDEF FPC}
                         {$IF CompilerVersion > 21}Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsLargeInt := StrToInt64(DecodeStrings(TDWJSONObject(bJsonValueC).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
                         {$ELSE} Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsInteger                    := StrToInt64(DecodeStrings(TDWJSONObject(bJsonValueC).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
                         {$IFEND}
                        {$ELSE}
                         Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsLargeInt := StrToInt64(DecodeStrings(TDWJSONObject(bJsonValueC).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
                        {$ENDIF}
                       End
                      Else
                       Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsInteger  := StrToInt(DecodeStrings(TDWJSONObject(bJsonValueC).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
                     End;
                   End
                  Else
                   Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Clear;
                 End
                Else If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle{$IFEND}{$ENDIF}] Then
                 Begin
                  If Not TDWJSONObject(bJsonValueC).Pairs[0].isnull Then
                   Begin
                    {$IFNDEF FPC}
                     Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Value   := StrToFloat(BuildFloatString(TDWJSONObject(bJsonValueC).Pairs[0].Value));
                    {$ELSE}
                     Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsFloat := StrToFloat(BuildFloatString(TDWJSONObject(bJsonValueC).Pairs[0].Value));
                    {$ENDIF}
                   End
                  Else
                   Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Clear;
                 End
                Else If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                 Begin
                  If (Not (TDWJSONObject(bJsonValueC).Pairs[0].isnull)) Then
                   Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsDateTime  := UnixToDateTime(StrToInt64(TDWJSONObject(bJsonValueC).Pairs[0].Value))
                  Else
                   Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Clear;
                 End  //Tratar Blobs de Parametros...
                Else If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                               ftGraphic, ftOraBlob, ftOraClob] Then
                 Begin
                  Try
                   If Not TDWJSONObject(bJsonValueC).Pairs[0].isnull Then
                    Begin
                     vStringStream := Decodeb64Stream(TDWJSONObject(bJsonValueC).Pairs[0].Value);
                     vStringStream.Position := 0;
                     TBlobfield(Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name)).LoadFromStream(vStringStream);
                    End
                   Else
                    Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Clear;
                  Finally
                   If Assigned(vStringStream) Then
                    FreeAndNil(vStringStream);
                  End;
                 End
                Else If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).DataType in [ftBoolean] Then
                  Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsBoolean := StringToBoolean(vValue)
                Else If Not TDWJSONObject(bJsonValueC).Pairs[0].isnull Then
                 Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Value := DecodeStrings(TDWJSONObject(bJsonValueC).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF})
                Else
                 Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Clear;
               End;
              Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).ReadOnly := vOldReadOnly;
             End;
          finally
            FreeAndNil(bJsonValueC);
          end;
         End;
        Self.Post;
       End;
     Except
      If Assigned(bJsonValueC) then
       FreeAndNil(bJsonValueC);
      If Assigned(bJsonValueB) then
       FreeAndNil(bJsonValueB);
     End;
    Finally
     FreeAndNil(bJsonArray);
     FreeAndNil(bJsonValueB);
    End;
   End;
 Finally
  FreeAndNil(bJsonValue);
 End;
End;

Function TRESTDWClientSQL.ProcessChanges(MassiveJSON : String) : Boolean;
Var
 I, A,
 vActualRecB   : Integer;
 bJsonValueC,
 bJsonValueB   : TDWJSONBase;
 bJsonArray,
 bJsonOBJ      : TDWJSONArray;
 bJsonValue    : TDWJSONObject;
 vOldReadOnly  : Boolean;
 vLastTimeB,
 vValue        : String;
 vBookmarkD    : Integer;
 vStringStream : TMemoryStream;
 Function DecodeREC(BookmarkSTR  : String;
                    Var LastTime : String) : Integer;
 Var
  vTempString : String;
 Begin
  Result := -1;
  vTempString := BookmarkSTR;
  If Pos('|', vTempString) > 0 Then
   Begin
    Result := StrToInt(Copy(vTempString, InitStrPos, Pos('|', vTempString) -1));
    vTempString := Copy(vTempString, Pos('|', vTempString) +1, Length(vTempString));
    LastTime := DecodeStrings(vTempString{$IFDEF FPC}, csUndefined{$ENDIF});
   End;
 End;
Begin
 Result       := False;
 vStringStream := Nil;
 bJsonValueC   := Nil;
 bJsonValueB   := Nil;
 bJsonArray    := Nil;
 bJsonOBJ      := Nil;
 bJsonValue    := Nil;
 If Trim(MassiveJSON) = '' Then
  Exit;
 bJsonValue   := TDWJSONObject.Create(StringReplace(MassiveJSON, #$FEFF, '', [rfReplaceAll]));
 bJsonOBJ     := TDWJSONArray(bJsonValue);
 Try
  For I := 0 To bJsonOBJ.ElementCount -1 do
   Begin
    bJsonValueB  := bJsonOBJ.GetObject(I);
    Try
     vValue := DecodeStrings(TDWJSONObject(bJsonValueB).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF});
     Try
      vActualRecB := DecodeREC(vValue, vLastTimeB);
      If (vActualRecB > -1) Then
       Begin
        Self.GotoBookmark(TBookmark(HexToBookmark(vLastTimeB)));
//        Self.RecNo := vActualRecB;
        bJsonArray := TDWJSONObject(bJsonValueB).OpenArray('reflectionlines');
        Self.Edit;
        For A := 0 To bJsonArray.ElementCount -1 Do
         Begin
          bJsonValueC := bJsonArray.GetObject(A);
          //Alexandre Magno - 20/01/2019 - ADD Try Finally
          try
            If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name) <> Nil Then
             Begin
              vOldReadOnly := Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).ReadOnly;
              Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).ReadOnly := False;
              If (TDWJSONObject(bJsonValueC).Pairs[0].Value = 'null') Or
                 (Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).ReadOnly) Then
               Begin
                If Not (Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).ReadOnly) Then
                 Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Clear;
                Continue;
               End;
              If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                        ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                        ftString,    ftWideString,
                                                                        ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                                {$IF CompilerVersion > 21}
                                                                                        , ftWideMemo
                                                                                 {$IFEND}
                                                                                {$ENDIF}]    Then
               Begin
                If (TDWJSONObject(bJsonValueC).Pairs[0].Value <> Null) And
                   (Trim(TDWJSONObject(bJsonValueC).Pairs[0].Value) <> 'null') Then
                 Begin
                  vValue := DecodeStrings(TDWJSONObject(bJsonValueC).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF}); //TDWJSONObject(bJsonValueC).Pairs[0].Value;
                  {$IFNDEF FPC}{$IF CompilerVersion < 18}
                  vValue := utf8Decode(vValue);
                  {$IFEND}{$ENDIF}
                  If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Size > 0 Then
                   Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsString := Copy(vValue, 1, Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Size)
                  Else
                   Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsString := vValue;
                 End
                Else
                 Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Clear;
               End
              Else
               Begin
                If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                 Begin
                  If Not TDWJSONObject(bJsonValueC).Pairs[0].isnull Then
                   Begin
                    If TDWJSONObject(bJsonValueC).Pairs[0].Value <> Null Then
                     Begin
                      If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                       Begin
                        {$IFNDEF FPC}
                         {$IF CompilerVersion > 21}Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsLargeInt := StrToInt64(DecodeStrings(TDWJSONObject(bJsonValueC).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
                         {$ELSE} Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsInteger                    := StrToInt64(DecodeStrings(TDWJSONObject(bJsonValueC).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
                         {$IFEND}
                        {$ELSE}
                         Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsLargeInt := StrToInt64(DecodeStrings(TDWJSONObject(bJsonValueC).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
                        {$ENDIF}
                       End
                      Else
                       Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsInteger  := StrToInt(DecodeStrings(TDWJSONObject(bJsonValueC).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
                     End;
                   End
                  Else
                   Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Clear;
                 End
                Else If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle{$IFEND}{$ENDIF}] Then
                 Begin
                  If Not TDWJSONObject(bJsonValueC).Pairs[0].isnull Then
                   Begin
                    {$IFNDEF FPC}
                     Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Value   := StrToFloat(BuildFloatString(TDWJSONObject(bJsonValueC).Pairs[0].Value));
                    {$ELSE}
                     Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsFloat := StrToFloat(BuildFloatString(TDWJSONObject(bJsonValueC).Pairs[0].Value));
                    {$ENDIF}
                   End
                  Else
                   Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Clear;
                 End
                Else If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                 Begin
                  If (Not (TDWJSONObject(bJsonValueC).Pairs[0].isnull)) Then
                   Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsDateTime  := UnixToDateTime(StrToInt64(TDWJSONObject(bJsonValueC).Pairs[0].Value))
                  Else
                   Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Clear;
                 End  //Tratar Blobs de Parametros...
                Else If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                               ftGraphic, ftOraBlob, ftOraClob] Then
                 Begin
                  Try
                   If Not TDWJSONObject(bJsonValueC).Pairs[0].isnull Then
                    Begin
                     vStringStream := Decodeb64Stream(TDWJSONObject(bJsonValueC).Pairs[0].Value);
                     vStringStream.Position := 0;
                     TBlobfield(Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name)).LoadFromStream(vStringStream);
                    End
                   Else
                    Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Clear;
                  Finally
                   If Assigned(vStringStream) Then
                    FreeAndNil(vStringStream);
                  End;
                 End
                Else If Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).DataType in [ftBoolean] Then
                  Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).AsBoolean := StringToBoolean(vValue)
                Else If Not TDWJSONObject(bJsonValueC).Pairs[0].isnull Then
                 Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Value := DecodeStrings(TDWJSONObject(bJsonValueC).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF})
                Else
                 Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).Clear;
               End;
              Self.FindField(TDWJSONObject(bJsonValueC).Pairs[0].Name).ReadOnly := vOldReadOnly;
             End;
          finally
            FreeAndNil(bJsonValueC);
          end;
         End;
        Self.Post;
       End;
     Except
      If Assigned(bJsonValueC) then
       FreeAndNil(bJsonValueC);
      If Assigned(bJsonValueB) then
       FreeAndNil(bJsonValueB);
     End;
    Finally
     FreeAndNil(bJsonArray);
     FreeAndNil(bJsonValueB);
    End;
   End;
 Finally
  FreeAndNil(bJsonValue);
 End;
End;

Procedure TRESTDWTable.ApplyUpdates;
Var
 vError : String;
Begin
 ApplyUpdates(vError);
 If vError <> '' Then
  Raise Exception.Create(PChar(vError));
End;

Procedure TRESTDWClientSQL.ApplyUpdates;
Var
 vError : String;
Begin
 ApplyUpdates(vError);
 If vError <> '' Then
  Raise Exception.Create(PChar(vError));
End;

Function TRESTDWTable.ApplyUpdates(Var Error: String; ReleaseCache : Boolean = True): Boolean;
Var
 vError        : Boolean;
 vErrorMSG,
 vMassiveJSON  : String;
 vResult       : TJSONValue;
 vActualReg    : TBookmark;
Begin
 Result  := False;
 vError  := False;
 vResult := Nil;
 If (vUpdateSQL <> Nil) Then
  Begin
   If vUpdateSQL.MassiveCount = 0 Then
    Error := cInvalidDataToApply
   Else
    Begin
     vRESTDataBase.ProcessMassiveSQLCache(vUpdateSQL.vMassiveCacheSQLList, vError, vErrorMSG);
     If vError Then
      Error := vErrorMSG;
     Result := Not (vError);
    End;
  End
 Else
  Begin
   If TMassiveDatasetBuffer(vMassiveDataset).RecordCount = 0 Then
    Error := 'No data to "Applyupdates"...'
   Else
    Begin
     vMassiveJSON := TMassiveDatasetBuffer(vMassiveDataset).ToJSON;
     Result       := vMassiveJSON <> '';
     If Result Then
      Begin
       Result     := False;
       If vRESTDataBase <> Nil Then
        Begin
         If vAutoRefreshAfterCommit Then
          vRESTDataBase.ApplyUpdatesTB(vActualPoolerMethodClient, TMassiveDatasetBuffer(vMassiveDataset), vParams, vError, vBinaryRequest, vErrorMSG, vResult, vRowsAffected, Nil)
         Else
          vRESTDataBase.ApplyUpdatesTB(vActualPoolerMethodClient, TMassiveDatasetBuffer(vMassiveDataset), vParams, vError, vBinaryRequest, vErrorMSG, vResult, vRowsAffected, Nil);
         Result := Not vError;
         Error  := vErrorMSG;
         If (Assigned(vResult) And (vAutoRefreshAfterCommit)) And
            (Not (TMassiveDatasetBuffer(vMassiveDataset).ReflectChanges)) Then
          Begin
           Try
            vActive := False;
            ProcBeforeOpen(Self);
            vInBlockEvents := True;
            Filter         := '';
            Filtered       := False;
            vActive        := GetData(vResult);
            If State = dsBrowse Then
             Begin
              If Trim(vTableName) <> '' Then
               TMassiveDatasetBuffer(vMassiveDataset).BuildDataset(Self, Trim(vTableName));
              PrepareDetails(True);
             End
            Else If State = dsInactive Then
             PrepareDetails(False);
            vInBlockEvents := False; //Alexandre Magno - 09/10/2018
           Except
            On E : Exception do
             Begin
              vInBlockEvents := False;
              If csDesigning in ComponentState Then
               Raise Exception.Create(PChar(E.Message))
              Else
               Begin
                If Assigned(vOnGetDataError) Then
                 vOnGetDataError(False, E.Message);
                If vRaiseError Then
                 Raise Exception.Create(PChar(E.Message));
               End;
             End;
           End;
          End
         Else If Assigned(vResult) And
                         (TMassiveDatasetBuffer(vMassiveDataset).ReflectChanges) Then
          Begin
           //Edit Dataset with values back.
           vActualReg     := GetBookmark;
           vInBlockEvents := True;
           If Not vResult.isnull Then
            Begin
             ProcessChanges(vResult.Value);
             GotoBookmark(vActualReg);
            End;
           vInBlockEvents := False;
           If State = dsBrowse Then
            Begin
             If Trim(vTableName) <> '' Then
              TMassiveDatasetBuffer(vMassiveDataset).BuildDataset(Self, Trim(vTableName));
            End
           Else If State = dsInactive Then
            PrepareDetails(False);
          End
         Else
          Begin
           If vError Then
            Begin
             vInBlockEvents := False;
             If ReleaseCache Then
              Begin
               TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
               RebuildMassiveDataset;
              End;
             If Assigned(vOnGetDataError) Then
              vOnGetDataError(False, vErrorMSG);
             If vRaiseError Then
              Raise Exception.Create(PChar(vErrorMSG));
            End;
          End;
         If Assigned(vResult) Then
          FreeAndNil(vResult);
        End
       Else
        Error := cEmptyDBName;
      End;
     If Result Then
      Begin
       If ReleaseCache Then
        TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
      End
     Else
      Error := vErrorMSG;
    End;
  End;
End;

Function TRESTDWClientSQL.ApplyUpdates(Var Error: String; ReleaseCache : Boolean = True): Boolean;
Var
 vError        : Boolean;
 vErrorMSG,
 vMassiveJSON  : String;
 vResult       : TJSONValue;
 vActualReg    : TBookmark;
Begin
 Result  := False;
 vError  := False;
 vResult := Nil;
 If (vUpdateSQL <> Nil) Then
  Begin
   If vUpdateSQL.MassiveCount = 0 Then
    Error := cInvalidDataToApply
   Else
    Begin
     vRESTDataBase.ProcessMassiveSQLCache(vUpdateSQL.vMassiveCacheSQLList, vError, vErrorMSG);
     If vError Then
      Error := vErrorMSG;
     Result := Not (vError);
    End;
  End
 Else
  Begin
   If TMassiveDatasetBuffer(vMassiveDataset).RecordCount = 0 Then
    Error := 'No data to "Applyupdates"...'
   Else
    Begin
     vMassiveJSON := TMassiveDatasetBuffer(vMassiveDataset).ToJSON;
     Result       := vMassiveJSON <> '';
     If Result Then
      Begin
       Result     := False;
       If vRESTDataBase <> Nil Then
        Begin
         If vAutoRefreshAfterCommit Then
          vRESTDataBase.ApplyUpdates(vActualPoolerMethodClient, TMassiveDatasetBuffer(vMassiveDataset), vSQL, vParams, vError, vBinaryRequest, vErrorMSG, vResult, vRowsAffected, Nil)
         Else
          vRESTDataBase.ApplyUpdates(vActualPoolerMethodClient, TMassiveDatasetBuffer(vMassiveDataset), Nil,  vParams, vError, vBinaryRequest, vErrorMSG, vResult, vRowsAffected, Nil);
         Result := Not vError;
         Error  := vErrorMSG;
         If (Assigned(vResult) And (vAutoRefreshAfterCommit)) And
            (Not (TMassiveDatasetBuffer(vMassiveDataset).ReflectChanges)) Then
          Begin
           Try
            vActive := False;
            ProcBeforeOpen(Self);
            vInBlockEvents := True;
            Filter         := '';
            Filtered       := False;
            vActive        := GetData(vResult);
            If State = dsBrowse Then
             Begin
              If Trim(vUpdateTableName) <> '' Then
               TMassiveDatasetBuffer(vMassiveDataset).BuildDataset(Self, Trim(vUpdateTableName));
              PrepareDetails(True);
             End
            Else If State = dsInactive Then
             PrepareDetails(False);
            vInBlockEvents := False; //Alexandre Magno - 09/10/2018
           Except
            On E : Exception do
             Begin
              vInBlockEvents := False;
              If csDesigning in ComponentState Then
               Raise Exception.Create(PChar(E.Message))
              Else
               Begin
                If Assigned(vOnGetDataError) Then
                 vOnGetDataError(False, E.Message);
                If vRaiseError Then
                 Raise Exception.Create(PChar(E.Message));
               End;
             End;
           End;
          End
         Else If Assigned(vResult) And
                         (TMassiveDatasetBuffer(vMassiveDataset).ReflectChanges) Then
          Begin
           //Edit Dataset with values back.
           vActualReg     := GetBookmark;
           vInBlockEvents := True;
           If Not vResult.isnull Then
            Begin
             ProcessChanges(vResult.Value);
             GotoBookmark(vActualReg);
            End;
           vInBlockEvents := False;
           If State = dsBrowse Then
            Begin
             If Trim(vUpdateTableName) <> '' Then
              TMassiveDatasetBuffer(vMassiveDataset).BuildDataset(Self, Trim(vUpdateTableName));
            End
           Else If State = dsInactive Then
            PrepareDetails(False);
  //         vInBlockEvents := False; //Alexandre Magno - 09/10/2018
          End
         Else
          Begin
           If vError Then
            Begin
             vInBlockEvents := False;
             If ReleaseCache Then
              Begin
               TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
               RebuildMassiveDataset;
              End;
             If Assigned(vOnGetDataError) Then
              vOnGetDataError(False, vErrorMSG);
             If vRaiseError Then
              Raise Exception.Create(PChar(vErrorMSG));
            End;
          End;
         If Assigned(vResult) Then
          FreeAndNil(vResult);
        End
       Else
        Error := cEmptyDBName;
      End;
     If Result Then
      Begin
       If ReleaseCache Then
        TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
      End
     Else
      Error := vErrorMSG;
    End;
  End;
End;

Function TRESTDWTable.ParamByName(Value: String): TParam;
Var
 I : Integer;
 vParamName,
 vTempParam : String;
 Function CompareValue(Value1, Value2 : String) : Boolean;
 Begin
   Result := Value1 = Value2;
 End;
Begin
 Result := Nil;
 For I := 0 to vParams.Count -1 do
  Begin
   vParamName := UpperCase(vParams[I].Name);
   vTempParam := UpperCase(Trim(Value));
   if CompareValue(vTempParam, vParamName) then
    Begin
     Result := vParams[I];
     Break;
    End;
  End;
End;

Function TRESTDWClientSQL.ParamByName(Value: String): TParam;
Var
 I : Integer;
 vParamName,
 vTempParam : String;
 Function CompareValue(Value1, Value2 : String) : Boolean;
 Begin
   Result := Value1 = Value2;
 End;
Begin
 Result := Nil;
 For I := 0 to vParams.Count -1 do
  Begin
   vParamName := UpperCase(vParams[I].Name);
   vTempParam := UpperCase(Trim(Value));
   if CompareValue(vTempParam, vParamName) then
    Begin
     Result := vParams[I];
     Break;
    End;
  End;
End;

Function TRESTDWTable.ParamCount: Integer;
Begin
 Result := vParamCount;
End;

Function TRESTDWClientSQL.ParamCount: Integer;
Begin
 Result := vParamCount;
End;

Procedure TRESTDWTable.FieldDefsToFields;
Var
 I          : Integer;
 FieldValue : TField;
Begin
 For I := 0 To FieldDefs.Count -1 Do
  Begin
   FieldValue           := TField.Create(Self);
   FieldValue.DataSet   := Self;
   FieldValue.FieldName := FieldDefs[I].Name;
   FieldValue.SetFieldType(FieldDefs[I].DataType);
   FieldValue.Size      := FieldDefs[I].Size;
   Fields.Add(FieldValue);
  End;
End;

Procedure TRESTDWClientSQL.FieldDefsToFields;
Var
 I          : Integer;
 FieldValue : TField;
Begin
 For I := 0 To FieldDefs.Count -1 Do
  Begin
   FieldValue           := TField.Create(Self);
   FieldValue.DataSet   := Self;
   FieldValue.FieldName := FieldDefs[I].Name;
   FieldValue.SetFieldType(FieldDefs[I].DataType);
   FieldValue.Size      := FieldDefs[I].Size;
   Fields.Add(FieldValue);
  End;
End;

Function TRESTDWTable.FirstWord(Value: String): String;
Var
 vTempValue : PChar;
Begin
 vTempValue := PChar(Trim(Value));
 While Not (vTempValue^ = #0) Do
  Begin
   If (vTempValue^ <> ' ') Then
    Result := Result + vTempValue^
   Else
    Break;
   Inc(vTempValue);
  End;
End;

Function TRESTDWClientSQL.FirstWord(Value: String): String;
Var
 vTempValue : PChar;
Begin
 vTempValue := PChar(Trim(Value));
 While Not (vTempValue^ = #0) Do
  Begin
   If (vTempValue^ <> ' ') Then
    Result := Result + vTempValue^
   Else
    Break;
   Inc(vTempValue);
  End;
End;

procedure TRESTDWClientSQL.ExecOrOpen;
Var
 vError : String;
 Function OpenSQL : Boolean;
 Var
  vSQLText : String;
 Begin
  vSQLText := UpperCase(Trim(vSQL.Text));
  Result := FirstWord(vSQLText) = 'SELECT';
 End;
Begin
 If OpenSQL Then
  Open
 Else
  Begin
   If Not ExecSQL(vError) Then
    Begin
     If csDesigning in ComponentState Then
      Raise Exception.Create(PChar(vError))
     Else
      Begin
       If Assigned(vOnGetDataError) Then
        vOnGetDataError(False, vError)
       Else
        Raise Exception.Create(PChar(vError));
      End;
    End;
  End;
End;

Procedure TRESTDWClientSQL.ExecSQL;
Var
 vError : String;
Begin
 ExecSQL(vError);
 If vError <> '' Then
  Raise Exception.Create(PChar(vError));
End;

function TRESTDWClientSQL.ExecSQL(Var Error: String): Boolean;
Var
 vError        : Boolean;
 vMessageError : String;
 vResult       : TJSONValue;
Begin
 vResult       := Nil;
 vRowsAffected := 0;
 Try
  ChangeCursor;
  Result := False;
  If MassiveType = mtMassiveObject Then
   Begin
    ProcBeforeExec(Self);
    Result := True;
   End
  Else
   Begin
    Try
     If vRESTDataBase <> Nil Then
      Begin
       If Not vRESTDataBase.Active Then
        vRESTDataBase.Active := True;
       If Not vRESTDataBase.Active then
        Exit;
       vRESTDataBase.ExecuteCommand(vActualPoolerMethodClient, vSQL, vParams, vError, vMessageError, vResult, vRowsAffected, True, False, False, False, Nil);
       Result := Not vError;
       Error  := vMessageError;
       If Assigned(vResult) Then
        FreeAndNil(vResult);
       If (vRaiseError) And (vError) Then
        Raise Exception.Create(PChar(vMessageError));
      End
     Else
      Begin
       If (vRaiseError) Then
        Raise Exception.Create(PChar(cEmptyDBName));
      End;
    Except
     On E : Exception do
      Begin
       If (vRaiseError) Then
        Raise Exception.Create(e.Message);
      End;
    End;
   End;
 Finally
  ChangeCursor(True);
 End;
End;

function TRESTDWClientSQL.InsertMySQLReturnID: Integer;
Var
 vError        : Boolean;
 vMessageError : String;
Begin
 Result := -1;
 Try
  If vRESTDataBase <> Nil Then
   Result := vRESTDataBase.InsertMySQLReturnID(vActualPoolerMethodClient, vSQL, vParams, vError, vMessageError,  Nil)
  Else 
   Raise Exception.Create(PChar(cEmptyDBName));
 Except
 End;
End;

procedure TRESTDWClientSQL.OnBeforeChangingSQL(Sender: TObject);
begin
 vOldSQL := vSQL.Text;
end;

procedure TRESTDWClientSQL.OnChangingSQL(Sender: TObject);
Begin
 GetNewData := TStringList(Sender).Text <> vOldSQL;
 If GetNewData Then
  vOldSQL := TStringList(Sender).Text;
 CreateParams;
End;

procedure TRESTDWClientSQL.SetSQL(Value: TStringList);
Var
 I : Integer;
Begin
 vSQL.Clear;
 For I := 0 To Value.Count -1 do
  vSQL.Add(Value[I]);
End;

Procedure TRESTDWTable.CreateDataSet;
Begin
 vCreateDS := True;
 SetInBlockEvents(True);
 Try
  {$IFDEF FPC}
   {$IFDEF ZEOSDRIVER} //TODO
   {$ENDIF}
   {$IFDEF DWMEMTABLE}
    TDWMemtable(Self).Close;
    TDWMemtable(Self).Open;
   {$ENDIF}
   {$IFDEF LAZDRIVER}
    TMemDataset(Self).CreateTable;
    TMemDataset(Self).Open;
   {$ENDIF}
   {$IFDEF UNIDACMEM}
    TVirtualTable(Self).Close;
    TVirtualTable(Self).Open;
   {$ENDIF}
  {$ELSE}
  {$IFDEF CLIENTDATASET}
   TClientDataset(Self).CreateDataSet;
   TClientDataset(Self).Open;
  {$ENDIF}
  {$IFDEF UNIDACMEM}
   TVirtualTable(Self).Close;
   TVirtualTable(Self).Open;
  {$ENDIF}
  {$IFDEF RESTKBMMEMTABLE}
   Tkbmmemtable(Self).Close;
   Tkbmmemtable(Self).open;
  {$ENDIF}
  {$IFDEF RESTFDMEMTABLE}
   TFDmemtable(Self).CreateDataSet;
   TFDmemtable(Self).Open;
  {$ENDIF}
  {$IFDEF RESTADMEMTABLE}
   TADmemtable(Self).CreateDataSet;
   TADmemtable(Self).Open;
  {$ENDIF}
  {$IFDEF DWMEMTABLE}
   TDWMemtable(Self).Close;
   TDWMemtable(Self).Open;
   {$ENDIF}
  {$ENDIF}
  vCreateDS := False;
  vActive   := Not vCreateDS;
 Finally
 End;
End;

Procedure TRESTDWClientSQL.SetInactive(Const Value : Boolean);
Begin
 vInactive := Value;
End;

Procedure TRESTDWClientSQL.CreateDataSet;
Begin
 vCreateDS := True;
 SetInBlockEvents(True);
 Try
  {$IFDEF FPC}
   {$IFDEF ZEOSDRIVER} //TODO
   {$ENDIF}
   {$IFDEF DWMEMTABLE}
    TDWMemtable(Self).Close;
    TDWMemtable(Self).Open;
   {$ENDIF}
   {$IFDEF LAZDRIVER}
    TMemDataset(Self).CreateTable;
    TMemDataset(Self).Open;
   {$ENDIF}
   {$IFDEF UNIDACMEM}
    TVirtualTable(Self).Close;
    TVirtualTable(Self).Open;
   {$ENDIF}
  {$ELSE}
  {$IFDEF CLIENTDATASET}
   TClientDataset(Self).CreateDataSet;
   TClientDataset(Self).Open;
  {$ENDIF}
  {$IFDEF UNIDACMEM}
   TVirtualTable(Self).Close;
   TVirtualTable(Self).Open;
  {$ENDIF}
  {$IFDEF RESTKBMMEMTABLE}
   Tkbmmemtable(Self).Close;
   Tkbmmemtable(Self).open;
  {$ENDIF}
  {$IFDEF RESTFDMEMTABLE}
   TFDmemtable(Self).CreateDataSet;
   TFDmemtable(Self).Open;
  {$ENDIF}
  {$IFDEF RESTADMEMTABLE}
   TADmemtable(Self).CreateDataSet;
   TADmemtable(Self).Open;
  {$ENDIF}
  {$IFDEF DWMEMTABLE}
   TDWMemtable(Self).Close;
   TDWMemtable(Self).Open;
   {$ENDIF}
  {$ENDIF}
  vCreateDS := False;
  vActive   := Not vCreateDS;
 Finally
 End;
End;

Class Procedure TRESTDWTable.CreateEmptyDataset(Const Dataset : TDataset);
Begin
 Try
  If (Dataset.ClassParent = TDWMemtable) Or
     (Dataset.ClassType   = TDWMemtable) Then
   Begin
    TDWMemtable(Dataset).Close;
    TDWMemtable(Dataset).Open;
   End;
  {$IFDEF FPC}
   If (Dataset.ClassParent = TMemDataset) Or
      (Dataset.ClassType   = TMemDataset) Then
    Begin
     TMemDataset(Dataset).CreateTable;
//     TMemDataset(Self).Open;
    End;
   If (Dataset.ClassParent = TBufDataset) Or
      (Dataset.ClassType   = TBufDataset) Then
    Begin
     TBufDataset(Dataset).Close;
     TBufDataset(Dataset).CreateDataset;
    End;
  {$ELSE}
   {$IF CompilerVersion > 27} // Delphi XE7 pra cima
    {$IFNDEF HAS_FMX}  // Inclu�do inicialmente para iOS/Brito
     {$IFDEF CLIENTDATASET}
     If (Dataset.ClassParent = TCustomClientDataSet) Or
        (Dataset.ClassType   = TCustomClientDataSet) Or
        (Dataset.ClassParent = TClientDataSet)       Or
        (Dataset.ClassType   = TClientDataSet)       Then
      Begin
       TClientDataset(Dataset).Close;
       TClientDataset(Dataset).CreateDataSet;
      End;
     {$ENDIF}
     If (Dataset.ClassParent = TFDmemtable) Or
        (Dataset.ClassType   = TFDmemtable) Then
      Begin
       TFDmemtable(Dataset).Close;
       TFDmemtable(Dataset).CreateDataSet;
      End;
    {$ENDIF}
   {$ELSE}
    {$IFDEF CLIENTDATASET}
    If (Dataset.ClassParent = TCustomClientDataSet) Or
       (Dataset.ClassType   = TCustomClientDataSet) Or
       (Dataset.ClassParent = TClientDataSet)       Or
       (Dataset.ClassType   = TClientDataSet)       Then
     Begin
      TClientDataset(Dataset).Close;
      TClientDataset(Dataset).CreateDataSet;
     End;
    {$ENDIF}
   {$IFEND}
  {$ENDIF}
 Finally
 End;
End;

Class Procedure TRESTDWClientSQL.CreateEmptyDataset(Const Dataset : TDataset);
Begin
 Try
  If (Dataset.ClassParent = TDWMemtable) Or
     (Dataset.ClassType   = TDWMemtable) Then
   Begin
    TDWMemtable(Dataset).Close;
    TDWMemtable(Dataset).Open;
   End;
  {$IFDEF FPC}
   If (Dataset.ClassParent = TMemDataset) Or
      (Dataset.ClassType   = TMemDataset) Then
    Begin
     TMemDataset(Dataset).CreateTable;
//     TMemDataset(Self).Open;
    End;
   If (Dataset.ClassParent = TBufDataset) Or
      (Dataset.ClassType   = TBufDataset) Then
    Begin
     TBufDataset(Dataset).Close;
     TBufDataset(Dataset).CreateDataset;
    End;
  {$ELSE}
   {$IF CompilerVersion > 27} // Delphi XE7 pra cima
    {$IFNDEF HAS_FMX}  // Inclu�do inicialmente para iOS/Brito
    {$IFDEF CLIENTDATASET}
     If (Dataset.ClassParent = TCustomClientDataSet) Or
        (Dataset.ClassType   = TCustomClientDataSet) Or
        (Dataset.ClassParent = TClientDataSet)       Or
        (Dataset.ClassType   = TClientDataSet)       Then
      Begin
       TClientDataset(Dataset).Close;
       TClientDataset(Dataset).CreateDataSet;
      End;
    {$ENDIF}
     If (Dataset.ClassParent = TFDmemtable) Or
        (Dataset.ClassType   = TFDmemtable) Then
      Begin
       TFDmemtable(Dataset).Close;
       TFDmemtable(Dataset).CreateDataSet;
      End;
    {$ENDIF}
   {$ELSE}
    {$IFDEF CLIENTDATASET}
    If (Dataset.ClassParent = TCustomClientDataSet) Or
       (Dataset.ClassType   = TCustomClientDataSet) Or
       (Dataset.ClassParent = TClientDataSet)       Or
       (Dataset.ClassType   = TClientDataSet)       Then
     Begin
      TClientDataset(Dataset).Close;
      TClientDataset(Dataset).CreateDataSet;
     End;
    {$ENDIF}
   {$IFEND}
  {$ENDIF}
 Finally
 End;
End;

Procedure TRESTDWTable.CreateDatasetFromList;
Var
 I        : Integer;
 FieldDef : TFieldDef;
Begin
 TDataset(Self).Close;
 For I := 0 To Length(vFieldsList) -1 Do
  Begin
   FieldDef := FieldDefExist(Self, vFieldsList[I].FieldName);
   If FieldDef = Nil Then
    Begin
     FieldDef          := TDataset(Self).FieldDefs.AddFieldDef;
     FieldDef.Name     := vFieldsList[I].FieldName;
     FieldDef.DataType := vFieldsList[I].DataType;
     FieldDef.Size     := vFieldsList[I].Size;
     If FieldDef.DataType In [ftFloat, ftCurrency, ftBCD, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                                          {$IFEND}{$ENDIF}ftFMTBcd] Then
      Begin
       FieldDef.Size      := vFieldsList[I].Size;
       FieldDef.Precision := vFieldsList[I].Precision;
      End;
     FieldDef.Required    :=  vFieldsList[I].Required;
    End
   Else
    FieldDef.Required    :=  vFieldsList[I].Required;
  End;
 CreateDataset;
End;

Procedure TRESTDWClientSQL.CreateDatasetFromList;
Var
 I        : Integer;
 FieldDef : TFieldDef;
Begin
 TDataset(Self).Close;
 For I := 0 To Length(vFieldsList) -1 Do
  Begin
   FieldDef := FieldDefExist(Self, vFieldsList[I].FieldName);
   If FieldDef = Nil Then
    Begin
     FieldDef          := TDataset(Self).FieldDefs.AddFieldDef;
     FieldDef.Name     := vFieldsList[I].FieldName;
     FieldDef.DataType := vFieldsList[I].DataType;
     FieldDef.Size     := vFieldsList[I].Size;
     If FieldDef.DataType In [ftFloat, ftCurrency, ftBCD, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                                          {$IFEND}{$ENDIF}ftFMTBcd] Then
      Begin
       FieldDef.Size      := vFieldsList[I].Size;
       FieldDef.Precision := vFieldsList[I].Precision;
      End;
     FieldDef.Required    :=  vFieldsList[I].Required;
    End
   Else
    FieldDef.Required    :=  vFieldsList[I].Required;
  End;
 CreateDataset;
End;

Procedure TRESTDWTable.ChangeCursor(OldCursor : Boolean = False);
Begin
 If Not OldCursor Then
  Begin
   GetTmpCursor;
   SetCursor;
  End
 Else
  SetOldCursor;
End;

Procedure TRESTDWClientSQL.ChangeCursor(OldCursor : Boolean = False);
Begin
 If Not OldCursor Then
  Begin
   GetTmpCursor;
   SetCursor;
  End
 Else
  SetOldCursor;
End;

procedure TRESTDWTable.CleanFieldList;
Var
 I : Integer;
Begin
 If Self is TRESTDWTable Then
  For I := 0 To Length(vFieldsList) -1 Do
   FreeAndNil(vFieldsList[I]);
End;

procedure TRESTDWClientSQL.CleanFieldList;
Var
 I : Integer;
Begin
 If Self is TRESTDWClientSQL Then
  For I := 0 To Length(vFieldsList) -1 Do
   FreeAndNil(vFieldsList[I]);
End;

Procedure TRESTDWTable.ClearMassive;
Begin
 If Trim(vTableName) <> '' Then
  If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
   TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
End;

Procedure TRESTDWClientSQL.ClearMassive;
Begin
 If Trim(vUpdateTableName) <> '' Then
  If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
   TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
End;

Procedure TRESTDWTable.Close;
Begin
 vInactive       := False;
 vInternalLast   := False;
 vOldRecordCount := -1;
 If vActive Then
  Begin
   vActive         := False;
   SetActiveDB(vActive);
  End;
 Inherited Close;
End;

procedure TRESTDWClientSQL.Close;
Begin
 vInactive       := False;
 vInternalLast   := False;
 vReadData       := False;
 vOldRecordCount := -1;
 If vActive Then
  Begin
   vActive         := False;
   SetActiveDB(vActive);
  End;
 Inherited Close;
End;

Procedure TRESTDWTable.CloseCursor;
begin
 If Not (csDesigning in ComponentState) Then
  Close;
 Inherited;
end;

procedure TRESTDWClientSQL.CloseCursor;
begin
 If Not (csDesigning in ComponentState) Then
  Close;
 Inherited;
end;

Procedure TRESTDWTable.Open;
Begin
 Try
  If Not vInactive Then
   Begin
    If (vActive) Then
     vActive := False;
    If Not vActive Then
     SetActiveDB(True);
   End;
  If vActive Then
   Inherited Open;
 Finally
  vInBlockEvents  := False;
 End;
End;

Procedure TRESTDWClientSQL.Open;
Begin
 Try
  If Not vInactive Then
   Begin
    If (vActive) Then
     vActive := False;
    If Not vActive Then
     SetActiveDB(True);
   End;
  If vActive Then
   Inherited Open;
 Finally
  vInBlockEvents  := False;
 End;
End;

procedure TRESTDWClientSQL.Open(strSQL: String);
Begin
 If Not vActive Then
  Begin
   Close;
   vSQL.Clear;
   vSQL.Add(strSQL);
   SetActiveDB(True);
   Inherited Open;
  End;
End;

Procedure TRESTDWTable.OpenCursor(InfoQuery: Boolean);
Begin
 Try
  If (vRESTDataBase <> Nil) And
     ((Not(((vInBlockEvents) or (vInitDataset))) or (GetNewData)) Or (vInDesignEvents)) And
       Not(vActive) And (Not (BinaryLoadRequest)) Then
   Begin
    GetNewData := False;
    If Not (vRESTDataBase.Active)   Then
     vRESTDataBase.Active := True;
    If  ((Self.FieldDefs.Count = 0) Or
         (vInDesignEvents))         And
        (Not (vActiveCursor))       Or
         (GetNewData)               Then
     Begin
      vActiveCursor := True;
      Try
       SetActiveDB(True);
       If vActive Then
        Begin
         Inherited Open;
         vActiveCursor := False;
         Exit;
        End;
      Except
       On E : Exception Do
        Begin
         vActiveCursor := False;
         Raise Exception.Create(E.Message);
        End;
      End;
      vActiveCursor := False;
     End
    Else If ((Self.FieldDefs.Count > 0) Or
             (Self.Fields.Count > 0)    Or
             (vInDesignEvents))         Then
     Begin
      Try
       If Not((vInBlockEvents) or (vInitDataset)) Then
        Begin
         If Not vActive Then
          SetActiveDB(True);
        End
       Else
        Inherited OpenCursor(InfoQuery);
      Except
       If Not (csDesigning in ComponentState) Then
        Exception.Create(Name + ': ' + cErrorOpenDataset);
      End;
     End
    Else If (Self.FieldDefs.Count = 0)    And
            (Self.FieldListCount = 0) Then
     Raise Exception.Create(Name + ': ' + cErrorNoFieldsDataset)
    Else If Not (csDesigning in ComponentState) Then
     Raise Exception.Create(Name + ': ' + cErrorOpenDataset);
   End
  Else If (((vRESTDataBase <> Nil) Or (Assigned(vDWResponseTranslator))) And
           ((Self.FieldDefs.Count > 0)) Or (BinaryLoadRequest))          And
          (Not(OnLoadStream))                                            Then
   Begin
    If Not((vInBlockEvents) or (vInitDataset)) Then
     Begin
      If Not vActive Then
       SetActiveDB(True);
     End
    Else
     Inherited OpenCursor(InfoQuery);
   End
  Else If csDesigning in ComponentState Then
   Begin
    If (vRESTDataBase = Nil) then
     Raise Exception.Create(Name + ': ' + cErrorDatabaseNotFound)
    Else If Not (csDesigning in ComponentState) Then
     Raise Exception.Create(Name + ': ' + cErrorOpenDataset);
   End;
 Except
  On E : Exception do
   Begin
    If csDesigning in ComponentState Then
     Raise Exception.Create(Name+': ' + PChar(E.Message))
    Else
     Begin
      If Assigned(vOnGetDataError) Then
       vOnGetDataError(False, Name+': '+E.Message)
      Else
       Raise Exception.Create(PChar(Name+': ' + E.Message));
     End;
   End;
 End;
End;

Procedure TRESTDWClientSQL.OpenCursor(InfoQuery: Boolean);
Begin
 Try
  If (vRESTDataBase <> Nil) And
     ((Not(((vInBlockEvents) or (vInitDataset))) or (GetNewData)) Or (vInDesignEvents)) And
       Not(vActive) And (Not (BinaryLoadRequest)) Then
   Begin
    GetNewData := False;
    If Not (vRESTDataBase.Active)   Then
     vRESTDataBase.Active := True;
    If  ((Self.FieldDefs.Count = 0) Or
         (vInDesignEvents))         And
        (Not (vActiveCursor))       Or
         (GetNewData)               Then
     Begin
      vActiveCursor := True;
      Try
       SetActiveDB(True);
       If vActive Then
        Begin
         Inherited Open;
         vActiveCursor := False;
         Exit;
        End;
      Except
       On E : Exception Do
        Begin
         vActiveCursor := False;
         Raise Exception.Create(E.Message);
        End;
      End;
      vActiveCursor := False;
     End
    Else If ((Self.FieldDefs.Count > 0) Or
             (Self.Fields.Count > 0)    Or
             (vInDesignEvents))         Then
     Begin
      Try
       If Not((vInBlockEvents) or (vInitDataset)) Then
        Begin
         If Not vActive Then
          SetActiveDB(True);
        End
       Else
        Inherited OpenCursor(InfoQuery);
      Except
       If Not (csDesigning in ComponentState) Then
        Exception.Create(Name + ': ' + cErrorOpenDataset);
      End;
     End
    Else If (Self.FieldDefs.Count = 0)    And
            (Self.FieldListCount = 0) Then
     Raise Exception.Create(Name + ': ' + cErrorNoFieldsDataset)
    Else If Not (csDesigning in ComponentState) Then
     Raise Exception.Create(Name + ': ' + cErrorOpenDataset);
   End
  Else If (((vRESTDataBase <> Nil) Or (Assigned(vDWResponseTranslator))) And
           ((Self.FieldDefs.Count > 0)) Or (BinaryLoadRequest))          And
          (Not(OnLoadStream))                                            Then
   Begin
    If Not((vInBlockEvents) or (vInitDataset)) Then
     Begin
      If Not vActive Then
       SetActiveDB(True);
     End
    Else
     Inherited OpenCursor(InfoQuery);
   End
  Else If csDesigning in ComponentState Then
   Begin
    If (vRESTDataBase = Nil) then
     Raise Exception.Create(Name + ': ' + cErrorDatabaseNotFound)
    Else If Not (csDesigning in ComponentState) Then
     Raise Exception.Create(Name + ': ' + cErrorOpenDataset);
   End;
 Except
  On E : Exception do
   Begin
    If csDesigning in ComponentState Then
     Raise Exception.Create(Name+': ' + PChar(E.Message))
    Else
     Begin
      If Assigned(vOnGetDataError) Then
       vOnGetDataError(False, Name+': '+E.Message)
      Else
       Raise Exception.Create(PChar(Name+': ' + E.Message));
     End;
   End;
 End;
End;

procedure TRESTDWTable.OldAfterPost(DataSet: TDataSet);
Var
 vError     : String;
Begin
 vErrorBefore := False;
 vError       := '';
 If Not vReadData Then
  Begin
   If Not ((vInBlockEvents) or (vInitDataset)) Then
    Begin
     Try
      If ((Trim(vTableName) <> '') Or (vUpdateSQL <> Nil)) And (vOldState = dsInsert) Then
       Begin
        If (vUpdateSQL <> Nil) Then
         vUpdateSQL.Store(vUpdateSQL.vSQLInsert.Text, Self)
        Else
         Begin
          TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
          TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
          TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, DatasetStateToMassiveType(vOldState),
                                                             vOldState = dsEdit,
                                                             TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          If vMassiveCache <> Nil Then
           Begin
            vMassiveCache.Add(TMassiveDatasetBuffer(vMassiveDataset).ToJSON, Self);
            TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
           End;
         End;
       End;
      If ((Trim(vTableName) <> '') Or (vUpdateSQL <> Nil)) Then
       If vAutoCommitData Then
        Begin
         If (vUpdateSQL <> Nil) Then
          ApplyUpdates(vError)
         Else If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
          ApplyUpdates(vError);
        End;
      If vError <> '' Then
       Raise Exception.Create(vError)
      Else
       Begin
        If Assigned(vAfterPost) Then
         vAfterPost(Dataset);
        ProcAfterScroll(Dataset);
       End;
     Except

     End;
    End;
  End;
End;

procedure TRESTDWClientSQL.OldAfterPost(DataSet: TDataSet);
Var
 vError     : String;
Begin
 vErrorBefore := False;
 vError       := '';
 If Not vReadData Then
  Begin
   If Not ((vInBlockEvents) or (vInitDataset)) Then
    Begin
     Try
      If ((Trim(vUpdateTableName) <> '') Or (vUpdateSQL <> Nil)) And (vOldState = dsInsert) Then
       Begin
        If (vUpdateSQL <> Nil) Then
         vUpdateSQL.Store(vUpdateSQL.vSQLInsert.Text, Self)
        Else
         Begin
          TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
          TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
          TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, DatasetStateToMassiveType(vOldState),
                                                             vOldState = dsEdit,
                                                             TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          If vMassiveCache <> Nil Then
           Begin
            vMassiveCache.Add(TMassiveDatasetBuffer(vMassiveDataset).ToJSON, Self);
            TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
           End;
         End;
       End;
      If ((Trim(vUpdateTableName) <> '') Or (vUpdateSQL <> Nil)) Then
       If vAutoCommitData Then
        Begin
         If (vUpdateSQL <> Nil) Then
          ApplyUpdates(vError)
         Else If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
          ApplyUpdates(vError);
        End;
      If vError <> '' Then
       Raise Exception.Create(vError)
      Else
       Begin
        If Assigned(vAfterPost) Then
         vAfterPost(Dataset);
        ProcAfterScroll(Dataset);
       End;
     Except
      On E: Exception Do
       Begin
        Raise Exception.Create(E.Message);
       End;
     End;
    End;
  End;
End;

procedure TRESTDWTable.OldAfterDelete(DataSet: TDataSet);
Var
 vError : String;
Begin
 vErrorBefore := False;
 vError       := '';
 Try
  If Not vReadData Then
   Begin
    Try
     If Trim(vTableName) <> '' Then
      If vAutoCommitData Then
       If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
        ApplyUpdates(vError);
     If vError <> '' Then
      Raise Exception.Create(vError)
     Else
      Begin
       If Assigned(vAfterDelete) Then
        vAfterDelete(Self);
       ProcAfterScroll(Dataset);
      End;
    Except
    End;
   End;
 Finally
  vReadData := False;
 End;
End;

procedure TRESTDWClientSQL.OldAfterDelete(DataSet: TDataSet);
Var
 vError : String;
Begin
 vErrorBefore := False;
 vError       := '';
 Try
  If Not vReadData Then
   Begin
    Try
     If Trim(vUpdateTableName) <> '' Then
      If vAutoCommitData Then
       If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
        ApplyUpdates(vError);
     If vError <> '' Then
      Raise Exception.Create(vError)
     Else
      Begin
       If Assigned(vAfterDelete) Then  //Alexandre Magno
        vAfterDelete(Self);
       ProcAfterScroll(Dataset);
      End;
    Except
    End;
   End;
 Finally
  vReadData := False;
 End;
End;

procedure TRESTDWClientSQL.SetUpdateTableName(Value: String);
Begin
 vCommitUpdates    := Trim(Value) <> '';
 vUpdateTableName  := Value;
End;

Procedure TRESTDWClientSQL.AbortData;
Begin
 If Assigned(vRESTDataBase) Then
  If Assigned(vActualPoolerMethodClient) Then
   Begin
    vActualPoolerMethodClient.Abort;
    vActualPoolerMethodClient := Nil;
   End;
End;

Procedure TRESTDWClientSQL.ThreadStart(ExecuteData : TOnExecuteData);
Begin
 If Assigned(vThreadRequest) Then
  ThreadDestroy;
 {$IFDEF FPC}
  vThreadRequest        := TRESTDwThreadRequest.Create(Self,
                                                       ExecuteData,
                                                       @AbortData,
                                                       vOnThreadRequestError);
 {$ELSE}
  vThreadRequest        := TRESTDwThreadRequest.Create(Self,
                                                       ExecuteData,
                                                       AbortData,
                                                       vOnThreadRequestError);
 {$ENDIF}
 vThreadRequest.Resume;
End;

Procedure TRESTDWClientSQL.ThreadDestroy;
Begin
 Try
  vThreadRequest.Kill;
  {$IFDEF FPC}
   WaitForThreadTerminate(vThreadRequest.Handle, INFINITE);
  {$ELSE}
   {$IF Not Defined(HAS_FMX)}
    WaitForSingleObject  (vThreadRequest.Handle, INFINITE);
   {$IFEND}
  {$ENDIF}
 Except
 End;
 FreeAndNil(vThreadRequest);
End;

Procedure TRESTDWTable.InternalLast;
Begin
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  Begin
   vActualRec    := vJsonCount;
   vInternalLast := True;
  End;
 Inherited InternalLast;
End;

Procedure TRESTDWClientSQL.InternalLast;
Begin
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  Begin
   vActualRec    := vJsonCount;
   vInternalLast := True;
  End;
 Inherited InternalLast;
End;

Procedure TRESTDWTable.InternalPost;
Begin
 Inherited;
End;

procedure TRESTDWTable.SetTableName(Value: String);
Begin
 vCommitUpdates    := Trim(Value) <> '';
 vTableName  := Value;
End;

procedure TRESTDWTable.InternalOpen;
begin
 Try
  vActive := True;
  Inherited;
  If Not vInBlockEvents Then
   Begin
    If Not (BinaryRequest) Then
     Begin
      If Not (csDesigning in ComponentState) then
       Open;
     End;
   End;
 Except
  On e : Exception do
   Begin
    Raise Exception.Create(e.Message);
   End;
 End;
end;

Procedure TRESTDWClientSQL.InternalPost;
Begin
 Inherited;
End;

procedure TRESTDWClientSQL.InternalOpen;
begin
 Try
  vActive := True;
  Inherited;
  If Not vInBlockEvents Then
   Begin
    If Not (BinaryRequest) Then
     Begin
      If Not (csDesigning in ComponentState) then
       Open;
     End;
   End;
 Except
  On e : Exception do
   Begin
    Raise Exception.Create(e.Message);
   End;
 End;
end;

Procedure TRESTDWTable.InternalRefresh;
Begin
 Inherited;
 If Not (csDesigning In ComponentState) Then
  If Not vInBlockEvents Then
   Refresh;
End;

Procedure TRESTDWClientSQL.InternalRefresh;
Begin
 Inherited;
 If Not (csDesigning In ComponentState) Then
  If Not vInBlockEvents Then
   Refresh;
End;

Procedure TRESTDWTable.Loaded;
Begin
 Inherited Loaded;
 Try
  If Not (csDesigning in ComponentState) Then
   SetActiveDB(False);
 Except
  If Not (csDesigning in ComponentState) Then
   Raise;
 End;
End;

Procedure TRESTDWClientSQL.Loaded;
Begin
 Inherited Loaded;
  try
    if not (csDesigning in ComponentState) then
      SetActiveDB(False);
  except
    if not (csDesigning in ComponentState) then
      raise;
  end;
End;

Procedure TRESTDWTable.LoadFromStream(Stream : TMemoryStream);
Begin
 If Not Assigned(Stream) Then
  Exit;
 DisableControls;
 Close;
 vInBlockEvents := True;
 Try
  Stream.Position := 0;
  {$IFNDEF DWMEMTABLE}
  BinaryCompatibleMode := False;
  {$ENDIF}
  TRESTDWClientSQLBase(Self).LoadFromStream(Stream);
 Finally
  vInBlockEvents := False;
 End;
 EnableControls;
End;

Procedure TRESTDWClientSQL.LoadFromStream(Stream : TMemoryStream);
begin
 If Not Assigned(Stream) Then
  Exit;
 DisableControls;
 Close;
 vInBlockEvents := True;
 Try
  Stream.Position := 0;
  {$IFNDEF DWMEMTABLE}
  BinaryCompatibleMode := False;
  {$ENDIF}
  TRESTDWClientSQLBase(Self).LoadFromStream(Stream);
 Finally
  vInBlockEvents := False;
 End;
 EnableControls;
end;

Function TRESTDWTable.MassiveCount: Integer;
Begin
 Result := 0;
 If Trim(vTableName) <> '' Then
  Result := TMassiveDatasetBuffer(vMassiveDataset).RecordCount;
End;

Function TRESTDWClientSQL.MassiveCount: Integer;
Begin
 Result := 0;
 If Trim(vUpdateTableName) <> '' Then
  Result := TMassiveDatasetBuffer(vMassiveDataset).RecordCount;
End;

Function TRESTDWTable.MassiveToJSON: String;
Begin
 Result := '';
 If vMassiveDataset <> Nil Then
  If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
   Result := TMassiveDatasetBuffer(vMassiveDataset).ToJSON;
End;

Function TRESTDWClientSQL.MassiveToJSON: String;
Begin
 Result := '';
 If vMassiveDataset <> Nil Then
  If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
   Result := TMassiveDatasetBuffer(vMassiveDataset).ToJSON;
End;

Procedure TRESTDWTable.NewDataField(Value: TFieldDefinition);
Var
 I : Integer;
begin
 SetLength(vFieldsList, Length(vFieldsList) +1);
 I := Length(vFieldsList) -1;
 vFieldsList[I]           := TFieldDefinition.Create;
 vFieldsList[I].FieldName := Value.FieldName;
 vFieldsList[I].DataType  := Value.DataType;
 vFieldsList[I].Size      := Value.Size;
 vFieldsList[I].Required  := Value.Required;
end;

Procedure TRESTDWClientSQL.NewDataField(Value: TFieldDefinition);
Var
 I : Integer;
begin
 SetLength(vFieldsList, Length(vFieldsList) +1);
 I := Length(vFieldsList) -1;
 vFieldsList[I]           := TFieldDefinition.Create;
 vFieldsList[I].FieldName := Value.FieldName;
 vFieldsList[I].DataType  := Value.DataType;
 vFieldsList[I].Size      := Value.Size;
 vFieldsList[I].Required  := Value.Required;
end;

Function TRESTDWTable.FieldListCount: Integer;
Begin
 Result := 0;
 If Self is TRESTDWTable Then
  Result := Length(vFieldsList);
End;

Function TRESTDWClientSQL.FieldListCount: Integer;
Begin
 Result := 0;
 If Self is TRESTDWClientSQL Then
  Result := Length(vFieldsList);
End;

Procedure TRESTDWTable.NewFieldList;
Begin
 CleanFieldList;
 If Self is TRESTDWTable Then
  SetLength(vFieldsList, 0);
End;

Procedure TRESTDWClientSQL.NewFieldList;
Begin
 CleanFieldList;
 If Self is TRESTDWClientSQL Then
  SetLength(vFieldsList, 0);
End;

Procedure TRESTDWTable.Newtable;
Begin
 TRESTDWTable(Self).Inactive   := True;
 Try
 {$IFNDEF FPC}
  Self.Close;
  Self.Open;
 {$ELSE}
  {$IFDEF ZEOSDRIVER} //TODO
  {$ELSE}
   {$IFDEF DWMEMTABLE} //TODO
    TDWMemtable(Self).Close;
    TDWMemtable(Self).Open;
   {$ELSE}
    {$IFNDEF UNIDACMEM}
     If Self is TMemDataset Then
      TMemDataset(Self).CreateTable;
    {$ELSE}
     TVirtualTable(Self).Close;
     TVirtualTable(Self).Open;
    {$ENDIF}
   {$ENDIF}
  {$ENDIF}
  Self.Open;
  TRESTDWTable(Self).Active     := True;
 {$ENDIF}
 Finally
  TRESTDWTable(Self).Inactive   := False;
 End;
End;

procedure TRESTDWClientSQL.Newtable;
Begin
 TRESTDWClientSQL(Self).Inactive   := True;
 Try
 {$IFNDEF FPC}
  Self.Close;
  Self.Open;
 {$ELSE}
  {$IFDEF ZEOSDRIVER} //TODO
  {$ELSE}
   {$IFDEF DWMEMTABLE} //TODO
    TDWMemtable(Self).Close;
    TDWMemtable(Self).Open;
   {$ELSE}
    {$IFNDEF UNIDACMEM}
     If Self is TMemDataset Then
      TMemDataset(Self).CreateTable;
    {$ELSE}
     TVirtualTable(Self).Close;
     TVirtualTable(Self).Open;
    {$ENDIF}
   {$ENDIF}
  {$ENDIF}
  Self.Open;
  TRESTDWClientSQL(Self).Active     := True;
 {$ENDIF}
 Finally
  TRESTDWClientSQL(Self).Inactive   := False;
 End;
end;

Procedure TRESTDWTable.Notification(AComponent : TComponent;
                                    Operation  : TOperation);
Begin
 If (Operation    = opRemove)              And
    (AComponent   = vRESTDataBase)         Then
  vRESTDataBase := Nil;
 If (Operation    = opRemove)              And
    (AComponent   = vMassiveCache)         Then
  vMassiveCache := Nil;
 If (Operation    = opRemove)              And
    (AComponent   = vDWResponseTranslator) Then
  vDWResponseTranslator := Nil;
 If (Operation    = opRemove)              And
    (AComponent   = vUpdateSQL)            Then
  vUpdateSQL      := Nil;
 Inherited Notification(AComponent, Operation);
End;

Procedure TRESTDWClientSQL.Notification(AComponent : TComponent;
                                        Operation  : TOperation);
Begin
 If (Operation    = opRemove)              And
    (AComponent   = vRESTDataBase)         Then
   vRESTDataBase := Nil;
 If (Operation    = opRemove)              And
    (AComponent   = vMassiveCache)         Then
   vMassiveCache := Nil;
 If (Operation    = opRemove)              And
    (AComponent   = vDWResponseTranslator) Then
   vDWResponseTranslator := Nil;
 If (Operation    = opRemove)              And
    (AComponent   = vUpdateSQL)            Then
  vUpdateSQL      := Nil;
 Inherited Notification(AComponent, Operation);
End;

Destructor TRESTDWConnectionServer.Destroy;
Begin
 If Assigned(vPoolerList) Then
  FreeAndNil(vPoolerList);
 FreeAndNil(vClientConnectionDefs);
 FreeAndNil(vProxyOptions);
 If Assigned(vAuthOptionParams) Then
  FreeAndNil(vAuthOptionParams);
 Inherited;
End;

Function TRESTDWBatchFieldsDefs.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

Function TRESTDWBatchFieldsDefs.GetRec(Index : Integer) : TRESTDWBatchFieldItem;
Begin
 Result := TRESTDWBatchFieldItem(Inherited GetItem(Index));
End;

Procedure TRESTDWBatchFieldsDefs.PutRec(Index: Integer; Item: TRESTDWBatchFieldItem);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
End;

procedure TRESTDWBatchFieldsDefs.ClearList;
Var
 I      : Integer;
Begin
 Try
  For I := Count - 1 Downto 0 Do
   Delete(I);
 Finally
  Self.Clear;
 End;
End;

Function TRESTDWBatchFieldsDefs.Add: TCollectionItem;
Begin
 Result := TRESTDWBatchFieldItem(Inherited Add);
End;

Procedure TRESTDWBatchFieldsDefs.Delete(Index : Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
End;

Procedure TRESTDWBatchFieldsDefs.Delete(Index : String);
Begin
 If ItemsByName[Index] <> Nil Then
  TOwnedCollection(Self).Delete(ItemsByName[Index].Index);
End;

Constructor TRESTDWBatchFieldsDefs.Create(AOwner      : TPersistent;
                                          aItemClass  : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TRESTDWBatchFieldItem);
 fOwner  := AOwner;
End;

Destructor TRESTDWBatchFieldsDefs.Destroy;
Begin
 ClearList;
 Inherited;
End;

Procedure TRESTDWBatchFieldsDefs.PutRecName(Index        : String;
                                            Item         : TRESTDWBatchFieldItem);
Var
 I : Integer;
Begin
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].vListName)) Then
    Begin
     Self.Items[I] := Item;
     Break;
    End;
  End;
End;

Function  TRESTDWBatchFieldsDefs.GetRecName(Index : String)  : TRESTDWBatchFieldItem;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].vListName)) Then
    Begin
     Result := TRESTDWBatchFieldItem(Self.Items[I]);
     Break;
    End;
  End;
End;

Constructor TRESTDWBatchFieldItem.Create(aCollection: TCollection);
Begin
 Inherited;
 vFieldConfig := [dwfk_Keyfield, dwfk_NotNull];
 vListName    := Trim(Format('FieldRule%d', [aCollection.Count -1]));
End;

Destructor TRESTDWBatchFieldItem.Destroy;
Begin
 Inherited;
End;

Function  TRESTDWBatchFieldItem.GetDisplayName             : String;
Begin
 Result := vListName;
End;

Procedure TRESTDWBatchFieldItem.SetDisplayName(Const Value : String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create(cInvalidConnectionName)
 Else
  Begin
   vListName := Value;
   Inherited;
  End;
End;

Function    TRESTDWConnectionServer.GetPoolerList     : TStringList;
Var
 I             : Integer;
 vTempDatabase : TRESTDWDataBase;
Begin
 vTempDatabase := TRESTDWDataBase.Create(Nil);
 Result                                := TStringList.Create;
 Try
  vTempDatabase.vAccessTag             := vAccessTag;
  vTempDatabase.Compression            := vCompression;
  vTempDatabase.TypeRequest            := vTypeRequest;
  vTempDatabase.DataRoute              := DataRoute;
  vTempDatabase.ServerContext          := ServerContext;
  vTempDatabase.AuthenticationOptions.Assign(AuthenticationOptions);
  vTempDatabase.Proxy                  := vProxy;             //Diz se tem servidor Proxy
  vTempDatabase.ProxyOptions.vServer   := vProxyOptions.vServer;      //Se tem Proxy diz quais as op��es
  vTempDatabase.ProxyOptions.vLogin    := vProxyOptions.vLogin;      //Se tem Proxy diz quais as op��es
  vTempDatabase.ProxyOptions.vPassword := vProxyOptions.vPassword;      //Se tem Proxy diz quais as op��es
  vTempDatabase.ProxyOptions.vPort     := vProxyOptions.vPort;      //Se tem Proxy diz quais as op��es
  vTempDatabase.PoolerService          := vRestWebService;    //Host do WebService REST
  vTempDatabase.PoolerURL              := vRestURL;           //URL do WebService REST
  vTempDatabase.PoolerPort             := vPoolerPort;        //A Porta do Pooler do DataSet
//  vTempDatabase.PoolerName           := vRestPooler;        //Qual o Pooler de Conex�o ligado ao componente
  vTempDatabase.RequestTimeOut         := vTimeOut;           //Timeout da Requisi��o
  vTempDatabase.ConnectTimeOut         := vConnectTimeOut;
  vTempDatabase.EncodeStrings          := vEncodeStrings;
  vTempDatabase.Encoding               := vEncoding;          //Encoding da string
  vTempDatabase.WelcomeMessage         := vWelcomeMessage;
  If Assigned(vPoolerList) Then
   FreeAndNil(vPoolerList);
  vPoolerList                          := vTempDatabase.GetRestPoolers;
  If Assigned(vPoolerList) Then
   Begin
    For I := 0 To vPoolerList.Count -1 Do
     Result.Add(vPoolerList[I]);
   End;
 Finally
  vTempDatabase.Active                 := False;
  FreeAndNil(vTempDatabase);
 End;
End;

Constructor TRESTDWConnectionServer.Create(aCollection: TCollection);
Begin
 Inherited;
 vPoolerList           := Nil;
 vClientConnectionDefs := TClientConnectionDefs.Create(Self);
 {$IFNDEF FPC}
 {$IF CompilerVersion > 21}
  vEncoding            := esUtf8;
 {$ELSE}
  vEncoding            := esAscii;
 {$IFEND}
 {$ELSE}
  vEncoding           := esUtf8;
 {$ENDIF}
 vListName            :=  Format('server(%d)', [aCollection.Count]);
 vRestWebService      := '127.0.0.1';
 vCompression         := True;
 vBinaryRequest       := False;
 vAuthOptionParams    := TRDWClientAuthOptionParams.Create(Self);
 vAuthOptionParams.AuthorizationOption := rdwAONone;
 vRestPooler          := '';
 vPoolerPort          := 8082;
 vProxy               := False;
 vEncodeStrings       := True;
 vProxyOptions        := TProxyOptions.Create;
 vTimeOut             := 10000;
 vConnectTimeOut      := 3000;
 vActive              := True;
 vDataRoute           := '';
 vServerContext       := '';
End;

Function TListDefConnections.Add: TCollectionItem;
Begin
 Result := TRESTDWConnectionServer(Inherited Add);
End;

procedure TListDefConnections.ClearList;
Var
 I      : Integer;
Begin
 Try
  For I := Count - 1 Downto 0 Do
   Delete(I);
 Finally
  Self.Clear;
 End;
End;

Constructor TListDefConnections.Create(AOwner      : TPersistent;
                                        aItemClass  : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TRESTDWConnectionServer);
 fOwner  := AOwner;
End;

Procedure TListDefConnections.Delete(Index : String);
Begin
 If ItemsByName[Index] <> Nil Then
  TOwnedCollection(Self).Delete(ItemsByName[Index].Index);
End;

Procedure TListDefConnections.Delete(Index : Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
End;

Destructor TListDefConnections.Destroy;
Begin
 ClearList;
 Inherited;
End;

Function TListDefConnections.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

Function  TListDefConnections.GetRecName(Index : String)  : TRESTDWConnectionServer;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].vListName)) Then
    Begin
     Result := TRESTDWConnectionServer(Self.Items[I]);
     Break;
    End;
  End;
End;

Procedure TListDefConnections.PutRecName(Index        : String;
                                          Item         : TRESTDWConnectionServer);
Var
 I : Integer;
Begin
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].vListName)) Then
    Begin
     Self.Items[I] := Item;
     Break;
    End;
  End;
End;

function TListDefConnections.GetRec(Index : Integer) : TRESTDWConnectionServer;
begin
 Result := TRESTDWConnectionServer(Inherited GetItem(Index));
end;

procedure TListDefConnections.PutRec(Index: Integer; Item: TRESTDWConnectionServer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
end;

constructor TRESTDwThreadRequest.Create(aSelf                : TComponent;
                                        OnExecuteData,
                                        AbortData            : TOnExecuteData;
                                        OnThreadRequestError : TOnThreadRequestError);
Begin
 Inherited Create(False);
 vSelf                := aSelf;
 vOnExecuteData        := OnExecuteData;
 vAbortData            := AbortData;
 vOnThreadRequestError := OnThreadRequestError;
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   {$IF Not Defined(HAS_UTF8)}
    Priority          := tpLowest;
   {$IFEND}
  {$ELSE}
   Priority           := tpLowest;
  {$IFEND}
 {$ENDIF}
End;

Destructor TRESTDwThreadRequest.Destroy;
Begin
 Inherited;
End;

Procedure TRESTDwThreadRequest.Execute;
Begin
 If (Not(Terminated)) Then
  Begin
   Try
    If Assigned(vOnExecuteData) Then
     vOnExecuteData;
   Except
    On E : Exception Do
     Begin
      If Assigned(vOnThreadRequestError) Then
       vOnThreadRequestError(500, E.Message);
     End;
   End;
  End;
End;

Procedure TRESTDwThreadRequest.Kill;
Begin
 Terminate;
 ProcessMessages;
 If Assigned(vAbortData) Then
  vAbortData;
 ProcessMessages;
 If Assigned(vOnThreadRequestError) Then
  vOnThreadRequestError(499, 'Client Closed Request');
 ProcessMessages;
End;

Procedure TRESTDwThreadRequest.ProcessMessages;
Begin
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}{$IF Not Defined(HAS_UTF8)}FMX.Forms.TApplication.ProcessMessages;{$IFEND}
  {$ELSE}Application.Processmessages;{$IFEND}
 {$ENDIF}
End;

{$IFDEF FPC}
{$IFDEF LAZDRIVER}
procedure TRESTDWClientSQL.CloneDefinitions(Source  : TMemDataset;
                                            aSelf   : TMemDataset);
{$ENDIF}
{$IFDEF DWMEMTABLE}
Procedure TRESTDWClientSQL.CloneDefinitions(Source  : TDWMemtable;
                                            aSelf   : TDWMemtable); //Fields em Defini��es
{$ENDIF}
{$IFDEF UNIDACMEM}
Procedure TRESTDWClientSQL.CloneDefinitions(Source : TVirtualTable; aSelf : TVirtualTable);
{$ENDIF}
{$ELSE}
{$IFDEF CLIENTDATASET}
Procedure TRESTDWClientSQL.CloneDefinitions(Source : TClientDataset; aSelf : TClientDataset);
{$ENDIF}
{$IFDEF UNIDACMEM}
Procedure TRESTDWClientSQL.CloneDefinitions(Source : TVirtualTable; aSelf : TVirtualTable);
{$ENDIF}
{$IFDEF RESTKBMMEMTABLE}
Procedure TRESTDWClientSQL.CloneDefinitions(Source : TKbmmemtable; aSelf : TKbmmemtable);
{$ENDIF}
{$IFDEF RESTFDMEMTABLE}
Procedure TRESTDWClientSQL.CloneDefinitions(Source : TFDmemtable; aSelf : TFDmemtable);
{$ENDIF}
{$IFDEF RESTADMEMTABLE}
Procedure TRESTDWClientSQL.CloneDefinitions(Source : TADmemtable; aSelf : TADmemtable);
{$ENDIF}
{$IFDEF DWMEMTABLE}
Procedure TRESTDWClientSQL.CloneDefinitions(Source  : TDWMemtable;
                                            aSelf   : TDWMemtable); //Fields em Defini��es
{$ENDIF}
{$ENDIF}
Var
 I, A : Integer;
Begin
 aSelf.Close;
 For I := 0 to Source.FieldDefs.Count -1 do
  Begin
   For A := 0 to aSelf.FieldDefs.Count -1 do
    If Uppercase(Source.FieldDefs[I].Name) = Uppercase(aSelf.FieldDefs[A].Name) Then
     Begin
      aSelf.FieldDefs.Delete(A);
      Break;
     End;
  End;
 For I := 0 to Source.FieldDefs.Count -1 do
  Begin
   If Trim(Source.FieldDefs[I].Name) <> '' Then
    Begin
     With aSelf.FieldDefs.AddFieldDef Do
      Begin
       Name     := Source.FieldDefs[I].Name;
       DataType := Source.FieldDefs[I].DataType;
       Size     := Source.FieldDefs[I].Size;
       Required := Source.FieldDefs[I].Required;
       CreateField(aSelf);
      End;
    End;
  End;
 If aSelf.FieldDefs.Count > 0 Then
  aSelf.Open;
End;

Procedure TRESTDWTable.PrepareDetailsNew;
Var
 I, J : Integer;
 vDetailClient : TRESTDWClientSQLBase;
 vOldInBlock   : Boolean;
Begin
 For I := 0 To vMasterDetailList.Count -1 Do
  Begin
   vMasterDetailList.Items[I].ParseFields(TRESTDWTable(vMasterDetailList.Items[I].DataSet).RelationFields.Text);
   vDetailClient        := TRESTDWClientSQLBase(vMasterDetailList.Items[I].DataSet);
   If vDetailClient <> Nil Then
    Begin
     For J := 0 to TRESTDWTable(vDetailClient).Params.Count -1 Do
      TRESTDWTable(vDetailClient).Params[J].Clear;
     If vDetailClient.Active Then
      Begin
       vOldInBlock   := TRESTDWTable(vDetailClient).GetInBlockEvents;
       Try
        vDetailClient.SetInBlockEvents(True);
        If Self.State = dsInsert Then
         TRESTDWTable(vDetailClient).Newtable;
       Finally
        vDetailClient.SetInBlockEvents(vOldInBlock);
       End;
       TRESTDWTable(vDetailClient).ProcAfterScroll(vDetailClient);
      End
     Else
      Begin
       vOldInBlock   := TRESTDWTable(vDetailClient).GetInBlockEvents;
       Try
        vDetailClient.SetInBlockEvents(True);
        vDetailClient.Active := True;
       Finally
        vDetailClient.SetInBlockEvents(vOldInBlock);
       End;
      End;
    End;
  End;
End;


procedure TRESTDWClientSQL.PrepareDetailsNew;
Var
 I, J : Integer;
 vDetailClient : TRESTDWClientSQL;
 vOldInBlock   : Boolean;
Begin
 For I := 0 To vMasterDetailList.Count -1 Do
  Begin
   vMasterDetailList.Items[I].ParseFields(TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet).RelationFields.Text);
   vDetailClient        := TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet);
   If vDetailClient <> Nil Then
    Begin
     for J := 0 to vDetailClient.Params.Count -1 do //Alexandre Magno - 09/10/2018 - Limpa parametros
       vDetailClient.Params[J].Clear;

     If vDetailClient.Active Then
      Begin
       vOldInBlock   := vDetailClient.GetInBlockEvents;
       Try
        vDetailClient.SetInBlockEvents(True);
        If Self.State = dsInsert Then
         vDetailClient.Newtable;
       Finally
        vDetailClient.SetInBlockEvents(vOldInBlock);
       End;
       vDetailClient.ProcAfterScroll(vDetailClient);
      End
     Else
      Begin
       vOldInBlock   := vDetailClient.GetInBlockEvents;
       Try
        vDetailClient.SetInBlockEvents(True);
        vDetailClient.Active := True;
       Finally
        vDetailClient.SetInBlockEvents(vOldInBlock);
       End;
      End;
    End;
  End;
End;

Procedure TRESTDWTable.PrepareDetails(ActiveMode: Boolean);
Var
 I, j : Integer;
 vDetailClient : TRESTDWTable;
 Function CloneDetails(Value : TRESTDWTable) : Boolean;
 Var
  I : Integer;
  vTempValue,
  vFieldA,
  vFieldD       : String;
 Begin
  Result := False;
  For I := 0 To Value.RelationFields.Count -1 Do
   Begin
    vTempValue := Value.RelationFields[I];
    vFieldA    := Copy(vTempValue, InitStrPos, (Pos('=', vTempValue) -1) - FinalStrPos);
    vFieldD    := Copy(vTempValue, (Pos('=', vTempValue) - FinalStrPos) + 1, Length(vTempValue));
    If (FindField(vFieldA) <> Nil) And (Value.ParamByName(vFieldD) <> Nil) Then
     Begin
      If Not Result Then
       Result := Not (Value.ParamByName(vFieldD).Value = FindField(vFieldA).Value);
      If (Value.ParamByName(vFieldD).Value = FindField(vFieldA).Value) then
       Continue;
      Value.ParamByName(vFieldD).DataType := FindField(vFieldA).DataType;
      Value.ParamByName(vFieldD).Size     := FindField(vFieldA).Size;
      If Value.ParamByName(vFieldD).DataType in [ftGuid] Then
       Begin
        If Not FindField(vFieldA).IsNull Then
         Begin
          {$IFNDEF FPC}
           {$IF CompilerVersion > 31}
            Value.ParamByName(vFieldD).AsGUID := FindField(vFieldA).AsGUID;
           {$ELSE}
            Value.ParamByName(vFieldD).AsString := FindField(vFieldA).AsString;
           {$IFEND}
          {$ELSE}
           Value.ParamByName(vFieldD).AsString := FindField(vFieldA).AsString;
          {$ENDIF}
         End
        Else
         Value.ParamByName(vFieldD).Clear;
       End
      Else
       Value.ParamByName(vFieldD).Value      := FindField(vFieldA).Value;
     End;
   End;
  For I := 0 To Value.Params.Count -1 Do
   Begin
    If FindField(Value.Params[I].Name) <> Nil Then
     Begin
      If Not Result Then
       Result := Not (Value.Params[I].Value = FindField(Value.Params[I].Name).Value) or (Value.Params[0].isnull);
      If ((Value.Params[I].Value = FindField(Value.Params[I].Name).Value)) And
         (Not(Value.Params[0].isnull)) Then
       Continue;
      Value.Params[I].DataType := FindField(Value.Params[I].Name).DataType;
      Value.Params[I].Size     := FindField(Value.Params[I].Name).Size;
      Value.Params[I].Value    := FindField(Value.Params[I].Name).Value;
     End;
   End;
 End;
Begin
 If vReadData Then
  Exit;
 If vMasterDetailList <> Nil Then
 For I := 0 To vMasterDetailList.Count -1 Do
  Begin
   vMasterDetailList.Items[I].ParseFields(TRESTDWTable(vMasterDetailList.Items[I].DataSet).RelationFields.Text);
   vDetailClient        := TRESTDWTable(vMasterDetailList.Items[I].DataSet);
   If vDetailClient <> Nil Then
    Begin
     vDetailClient.vInactive := False;
     For J := 0 to vDetailClient.Params.Count -1 Do
      vDetailClient.Params[J].Clear;
     If CloneDetails(vDetailClient) Then
      Begin
       vDetailClient.Active := False;
       vDetailClient.Active := ActiveMode;
      End;
    End;
  End;
End;


Procedure TRESTDWClientSQL.PrepareDetails(ActiveMode: Boolean);
Var
 I, j : Integer;
 vDetailClient : TRESTDWClientSQL;
 Function CloneDetails(Value : TRESTDWClientSQL) : Boolean;
 Var
  I : Integer;
  vTempValue,
  vFieldA,
  vFieldD       : String;
 Begin
  Result := False;
  For I := 0 To Value.RelationFields.Count -1 Do
   Begin
    vTempValue := Value.RelationFields[I];
    vFieldA    := Copy(vTempValue, InitStrPos, (Pos('=', vTempValue) -1) - FinalStrPos);
    vFieldD    := Copy(vTempValue, (Pos('=', vTempValue) - FinalStrPos) + 1, Length(vTempValue));
    If (FindField(vFieldA) <> Nil) And (Value.ParamByName(vFieldD) <> Nil) Then
     Begin
      If Not Result Then
       Result := Not (Value.ParamByName(vFieldD).Value = FindField(vFieldA).Value);
      If (Value.ParamByName(vFieldD).Value = FindField(vFieldA).Value) then
       Continue;
      Value.ParamByName(vFieldD).DataType := FindField(vFieldA).DataType;
      Value.ParamByName(vFieldD).Size     := FindField(vFieldA).Size;
      If Value.ParamByName(vFieldD).DataType in [ftGuid] Then
       Begin
        If Not FindField(vFieldA).IsNull Then
         Begin
          {$IFNDEF FPC}
           {$IF CompilerVersion > 31}
            Value.ParamByName(vFieldD).AsGUID := FindField(vFieldA).AsGUID;
           {$ELSE}
            Value.ParamByName(vFieldD).AsString := FindField(vFieldA).AsString;
           {$IFEND}
          {$ELSE}
           Value.ParamByName(vFieldD).AsString := FindField(vFieldA).AsString;
          {$ENDIF}
         End
        Else
         Value.ParamByName(vFieldD).Clear;
       End
      Else
       Value.ParamByName(vFieldD).Value      := FindField(vFieldA).Value;
     End;
   End;
  For I := 0 To Value.Params.Count -1 Do
   Begin
    If FindField(Value.Params[I].Name) <> Nil Then
     Begin
      If Not Result Then
       Result := Not (Value.Params[I].Value = FindField(Value.Params[I].Name).Value) or (Value.Params[0].isnull);
      If ((Value.Params[I].Value = FindField(Value.Params[I].Name).Value)) And
         (Not(Value.Params[0].isnull)) Then
       Continue;
      Value.Params[I].DataType := FindField(Value.Params[I].Name).DataType;
      Value.Params[I].Size     := FindField(Value.Params[I].Name).Size;
      Value.Params[I].Value    := FindField(Value.Params[I].Name).Value;
     End;
   End;
 End;
Begin
 If vReadData Then
  Exit;
 If vMasterDetailList <> Nil Then
 For I := 0 To vMasterDetailList.Count -1 Do
  Begin
   vMasterDetailList.Items[I].ParseFields(TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet).RelationFields.Text);
   vDetailClient        := TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet);
   If vDetailClient <> Nil Then
    Begin
     vDetailClient.vInactive := False;
     for J := 0 to vDetailClient.Params.Count -1 do //Alexandre Magno - 09/10/2018 - Limpa parametros
       vDetailClient.Params[J].Clear;
     If CloneDetails(vDetailClient) Then
      Begin
       vDetailClient.Active := False;
       vDetailClient.Active := ActiveMode;
      End;
    End;
  End;
End;

Procedure TRESTDWTable.Post;
Begin
 {$IFDEF FPC}
 If State <> dsSetKey then // Lazarus bug
 {$ENDIF}
  Inherited;
 If State = dsSetKey Then
  Begin
   DataEvent(deCheckBrowseMode, 0);
   SetState(dsBrowse);
   DataEvent(deDataSetChange, 0);
  End;
End;

Procedure TRESTDWClientSQL.Post;
Begin
 {$IFDEF FPC}
 If State <> dsSetKey then // Lazarus bug
 {$ENDIF}
  Inherited;
 If State = dsSetKey Then
  Begin
   DataEvent(deCheckBrowseMode, 0);
   SetState(dsBrowse);
   DataEvent(deDataSetChange, 0);
  End;
End;


Function TRESTDWTable.OpenJson(JsonValue              : String = '';
                               Const ElementRoot      : String = '';
                               Const Utf8SpecialChars : Boolean = False) : Boolean;
Var
 LDataSetList  : TJSONValue;
 vMessageError : String;
 oDWResponseTranslator: TDWResponseTranslator;
 vBool: Boolean;
Begin
  Result       := False;
  vBool := False;
  LDataSetList := Nil;
  Close;
  oDWResponseTranslator := vDWResponseTranslator;
  vBool := Not Assigned(vDWResponseTranslator);
  If vBool Then
   Begin
    oDWResponseTranslator := TDWResponseTranslator.Create(Self);
    oDWResponseTranslator.ElementRootBaseName := ElementRoot;
    Self.DWResponseTranslator := oDWResponseTranslator;
   End;
  LDataSetList := TJSONValue.Create;
  Try
   If JsonValue <> '' Then
    Begin
     LDataSetList.Encoded  := False;
     LDataSetList.Encoding := esUtf8;
     LDataSetList.ServerFieldList := ServerFieldList;
     {$IFDEF FPC}
      LDataSetList.DatabaseCharSet := DatabaseCharSet;
      LDataSetList.NewFieldList    := @NewFieldList;
      LDataSetList.CreateDataSet   := @CreateDataSet;
      LDataSetList.NewDataField    := @NewDataField;
      LDataSetList.SetInitDataset  := @SetInitDataset;
      LDataSetList.SetRecordCount     := @SetRecordCount;
      LDataSetList.Setnotrepage       := @Setnotrepage;
      LDataSetList.SetInDesignEvents  := @SetInDesignEvents;
      LDataSetList.SetInBlockEvents   := @SetInBlockEvents;
      LDataSetList.FieldListCount     := @FieldListCount;
      LDataSetList.GetInDesignEvents  := @GetInDesignEvents;
      LDataSetList.PrepareDetailsNew  := @PrepareDetailsNew;
      LDataSetList.PrepareDetails     := @PrepareDetails;
     {$ELSE}
      LDataSetList.NewFieldList    := NewFieldList;
      LDataSetList.CreateDataSet   := CreateDataSet;
      LDataSetList.NewDataField    := NewDataField;
      LDataSetList.SetInitDataset  := SetInitDataset;
      LDataSetList.SetRecordCount     := SetRecordCount;
      LDataSetList.Setnotrepage       := Setnotrepage;
      LDataSetList.SetInDesignEvents  := SetInDesignEvents;
      LDataSetList.SetInBlockEvents   := SetInBlockEvents;
      LDataSetList.FieldListCount     := FieldListCount;
      LDataSetList.GetInDesignEvents  := GetInDesignEvents;
      LDataSetList.PrepareDetailsNew  := PrepareDetailsNew;
      LDataSetList.PrepareDetails     := PrepareDetails;
     {$ENDIF}
     LDataSetList.Utf8SpecialChars := Utf8SpecialChars;
     Try
      LDataSetList.OnWriterProcess := OnWriterProcess;
      LDataSetList.Utf8SpecialChars := True;
      LDataSetList.WriteToDataset(JsonValue, Self, oDWResponseTranslator, rtJSONAll);
      Result := True;
     Except
      On E : Exception Do
       Begin
        Raise Exception.Create(E.Message);
       End;
     End;
    End;
  Finally
   If (LDataSetList <> Nil) Then
    FreeAndNil(LDataSetList);
   If (oDWResponseTranslator <> nil) And (vBool) Then
    Begin
     FreeAndNil(oDWResponseTranslator);
     DWResponseTranslator := Nil;
    End;
   vInBlockEvents  := False;
  End;
End;

// ajuste 19/12/2018 - Thiago Pedro - https://pastebin.com/mFBxbhkN
Function TRESTDWClientSQL.OpenJson(JsonValue              : String = '';
                                   Const ElementRoot      : String = '';
                                   Const Utf8SpecialChars : Boolean = False) : Boolean;
Var
 LDataSetList  : TJSONValue;
 vMessageError : String;
 oDWResponseTranslator: TDWResponseTranslator;
 vBool: Boolean;
Begin
  Result       := False;
  vBool := False;
  LDataSetList := Nil;
  Close;
  oDWResponseTranslator := vDWResponseTranslator;
  vBool := Not Assigned(vDWResponseTranslator);
  If vBool Then
   Begin
    oDWResponseTranslator := TDWResponseTranslator.Create(Self);
    oDWResponseTranslator.ElementRootBaseName := ElementRoot;
    Self.DWResponseTranslator := oDWResponseTranslator;
   End;
  LDataSetList := TJSONValue.Create;
  Try
   If JsonValue <> '' Then
    Begin
     LDataSetList.Encoded  := False;
     LDataSetList.Encoding := esUtf8;
     LDataSetList.ServerFieldList := ServerFieldList;
     {$IFDEF FPC}
      LDataSetList.DatabaseCharSet := DatabaseCharSet;
      LDataSetList.NewFieldList    := @NewFieldList;
      LDataSetList.CreateDataSet   := @CreateDataSet;
      LDataSetList.NewDataField    := @NewDataField;
      LDataSetList.SetInitDataset  := @SetInitDataset;
      LDataSetList.SetRecordCount     := @SetRecordCount;
      LDataSetList.Setnotrepage       := @Setnotrepage;
      LDataSetList.SetInDesignEvents  := @SetInDesignEvents;
      LDataSetList.SetInBlockEvents   := @SetInBlockEvents;
      LDataSetList.SetInactive        := @SetInactive;
      LDataSetList.FieldListCount     := @FieldListCount;
      LDataSetList.GetInDesignEvents  := @GetInDesignEvents;
      LDataSetList.PrepareDetailsNew  := @PrepareDetailsNew;
      LDataSetList.PrepareDetails     := @PrepareDetails;
     {$ELSE}
      LDataSetList.NewFieldList    := NewFieldList;
      LDataSetList.CreateDataSet   := CreateDataSet;
      LDataSetList.NewDataField    := NewDataField;
      LDataSetList.SetInitDataset  := SetInitDataset;
      LDataSetList.SetRecordCount     := SetRecordCount;
      LDataSetList.Setnotrepage       := Setnotrepage;
      LDataSetList.SetInDesignEvents  := SetInDesignEvents;
      LDataSetList.SetInBlockEvents   := SetInBlockEvents;
      LDataSetList.SetInactive        := SetInactive;
      LDataSetList.FieldListCount     := FieldListCount;
      LDataSetList.GetInDesignEvents  := GetInDesignEvents;
      LDataSetList.PrepareDetailsNew  := PrepareDetailsNew;
      LDataSetList.PrepareDetails     := PrepareDetails;
     {$ENDIF}
     LDataSetList.Utf8SpecialChars := Utf8SpecialChars;
     Try
      LDataSetList.OnWriterProcess := OnWriterProcess;
      LDataSetList.Utf8SpecialChars := True;
      LDataSetList.WriteToDataset(JsonValue, Self, oDWResponseTranslator, rtJSONAll);
      Result := True;
     Except
      On E : Exception Do
       Begin
        Raise Exception.Create(E.Message);
       End;
     End;
    End;
  Finally
   If (LDataSetList <> Nil) Then
    FreeAndNil(LDataSetList);
   If (oDWResponseTranslator <> nil) And (vBool) Then
    Begin
     FreeAndNil(oDWResponseTranslator);
     DWResponseTranslator := Nil;
    End;
   vInBlockEvents  := False;
  End;
End;

Function TRESTDWTable.GetData(DataSet: TJSONValue): Boolean;
Var
 LDataSetList  : TJSONValue;
 vError        : Boolean;
 vValue,
 vMessageError : String;
 vStream       : TMemoryStream;
 vTempDS       : TRESTDWClientSQLBase;
 Procedure NewBinaryFieldList;
 Var
  J                : Integer;
  vFieldDefinition : TFieldDefinition;
 Begin
  NewFieldList;
  vFieldDefinition := TFieldDefinition.Create;
  Try
   If vTempDS <> Nil Then
    Begin
     If (vTempDS.Fields.Count > 0) Then
      Begin
       For J := 0 To vTempDS.Fields.Count - 1 Do
        Begin
         If vTempDS.Fields[J].FieldKind = fkData Then
          Begin
           vFieldDefinition.FieldName := vTempDS.Fields[J].FieldName;
           vFieldDefinition.DataType  := vTempDS.Fields[J].DataType;
           If (vFieldDefinition.DataType <> ftFloat) Then
            vFieldDefinition.Size     := vTempDS.Fields[J].Size
           Else
            vFieldDefinition.Size         := 0;
           If (vFieldDefinition.DataType In [ftCurrency, ftBCD,
                                             {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                             {$IFEND}{$ENDIF} ftFMTBcd]) Then
            vFieldDefinition.Precision := TBCDField(vTempDS.Fields[J]).Precision
           Else If (vFieldDefinition.DataType = ftFloat) Then
            vFieldDefinition.Precision := TFloatField(vTempDS.Fields[J]).Precision;
           vFieldDefinition.Required   := vTempDS.Fields[J].Required;
           NewDataField(vFieldDefinition);
          End;
        End;
      End;
    End;
  Finally
   FreeAndNil(vFieldDefinition);
  End;
 End;
Begin
 vValue        := '';
 Result        := False;
 LDataSetList  := Nil;
 vStream       := Nil;
 vRowsAffected := 0;
 Self.Close;
 If Assigned(vDWResponseTranslator) Then
  Begin
   LDataSetList          := TJSONValue.Create;
   Try
    LDataSetList.Encoded  := False;
    If Assigned(vDWResponseTranslator.ClientREST) Then
     LDataSetList.Encoding := vDWResponseTranslator.ClientREST.RequestCharset;
    Try
     vValue := vDWResponseTranslator.Open(vDWResponseTranslator.RequestOpen,
                                          vDWResponseTranslator.RequestOpenUrl);
    Except
     Self.Close;
    End;
    If vValue = '[]' Then
     vValue := '';
    {$IFDEF FPC}
     vValue := StringReplace(vValue, #10, '', [rfReplaceAll]);
    {$ELSE}
     vValue := StringReplace(vValue, #$A, '', [rfReplaceAll]);
    {$ENDIF}
    vError := vValue = '';
    If (Assigned(LDataSetList)) And (Not (vError)) Then
     Begin
      Try
       LDataSetList.ServerFieldList := ServerFieldList;
       {$IFDEF FPC}
        LDataSetList.DatabaseCharSet := DatabaseCharSet;
        LDataSetList.NewFieldList    := @NewFieldList;
        LDataSetList.CreateDataSet   := @CreateDataSet;
        LDataSetList.NewDataField    := @NewDataField;
        LDataSetList.SetInitDataset  := @SetInitDataset;
        LDataSetList.SetRecordCount     := @SetRecordCount;
        LDataSetList.Setnotrepage       := @Setnotrepage;
        LDataSetList.SetInDesignEvents  := @SetInDesignEvents;
        LDataSetList.SetInBlockEvents   := @SetInBlockEvents;
        LDataSetList.FieldListCount     := @FieldListCount;
        LDataSetList.GetInDesignEvents  := @GetInDesignEvents;
        LDataSetList.PrepareDetailsNew  := @PrepareDetailsNew;
        LDataSetList.PrepareDetails     := @PrepareDetails;
       {$ELSE}
        LDataSetList.NewFieldList    := NewFieldList;
        LDataSetList.CreateDataSet   := CreateDataSet;
        LDataSetList.NewDataField    := NewDataField;
        LDataSetList.SetInitDataset  := SetInitDataset;
        LDataSetList.SetRecordCount     := SetRecordCount;
        LDataSetList.Setnotrepage       := Setnotrepage;
        LDataSetList.SetInDesignEvents  := SetInDesignEvents;
        LDataSetList.SetInBlockEvents   := SetInBlockEvents;
        LDataSetList.FieldListCount     := FieldListCount;
        LDataSetList.GetInDesignEvents  := GetInDesignEvents;
        LDataSetList.PrepareDetailsNew  := PrepareDetailsNew;
        LDataSetList.PrepareDetails     := PrepareDetails;
       {$ENDIF}
       LDataSetList.OnWriterProcess := OnWriterProcess;
       LDataSetList.Utf8SpecialChars := True;
       LDataSetList.WriteToDataset(vValue, Self, vDWResponseTranslator, rtJSONAll);
       Result := True;
      Except
      End;
     End;
   Finally
    LDataSetList.Free;
   End;
  End
 Else If Assigned(vRESTDataBase) Then
  Begin
   Try
    If DataSet = Nil Then
     Begin
      vRESTDataBase.ExecuteCommandTB(vActualPoolerMethodClient, vTablename, vParams, vError, vMessageError, LDataSetList,
                                     vRowsAffected, BinaryRequest,  BinaryCompatibleMode, Fields.Count = 0, Nil);
      If LDataSetList <> Nil Then
       Begin
        If BinaryRequest Then
         Begin
          If Not LDataSetList.IsNull Then
           vValue := LDataSetList.Value;
         End;
        LDataSetList.Encoded  := vRESTDataBase.EncodeStrings;
        LDataSetList.Encoding := DataBase.Encoding;
        If Not BinaryRequest Then
         Begin
          If Not LDataSetList.IsNull Then
           vValue := LDataSetList.ToJSON;
         End;
       End;
     End
    Else
     Begin
      If Not DataSet.IsNull Then
       vValue                := DataSet.Value;
      LDataSetList          := TJSONValue.Create;
      LDataSetList.Encoded  := vRESTDataBase.EncodeStrings;
      LDataSetList.Encoding := DataBase.Encoding;
      vError                := False;
     End;
    If (Assigned(LDataSetList)) And (Not (vError)) Then
     Begin
      Try
       vActualJSON := vValue;
       vActualRec  := 0;
       vJsonCount  := 0;
       LDataSetList.OnWriterProcess := OnWriterProcess;
       LDataSetList.ServerFieldList := ServerFieldList;
       {$IFDEF FPC}
        LDataSetList.DatabaseCharSet := DatabaseCharSet;
        LDataSetList.NewFieldList    := @NewFieldList;
        LDataSetList.CreateDataSet   := @CreateDataSet;
        LDataSetList.NewDataField    := @NewDataField;
        LDataSetList.SetInitDataset  := @SetInitDataset;
        LDataSetList.SetRecordCount     := @SetRecordCount;
        LDataSetList.Setnotrepage       := @Setnotrepage;
        LDataSetList.SetInDesignEvents  := @SetInDesignEvents;
        LDataSetList.SetInBlockEvents   := @SetInBlockEvents;
        LDataSetList.FieldListCount     := @FieldListCount;
        LDataSetList.GetInDesignEvents  := @GetInDesignEvents;
        LDataSetList.PrepareDetailsNew  := @PrepareDetailsNew;
        LDataSetList.PrepareDetails     := @PrepareDetails;
       {$ELSE}
        LDataSetList.NewFieldList    := NewFieldList;
        LDataSetList.CreateDataSet   := CreateDataSet;
        LDataSetList.NewDataField    := NewDataField;
        LDataSetList.SetInitDataset  := SetInitDataset;
        LDataSetList.SetRecordCount     := SetRecordCount;
        LDataSetList.Setnotrepage       := Setnotrepage;
        LDataSetList.SetInDesignEvents  := SetInDesignEvents;
        LDataSetList.SetInBlockEvents   := SetInBlockEvents;
        LDataSetList.FieldListCount     := FieldListCount;
        LDataSetList.GetInDesignEvents  := GetInDesignEvents;
        LDataSetList.PrepareDetailsNew  := PrepareDetailsNew;
        LDataSetList.PrepareDetails     := PrepareDetails;
       {$ENDIF}
       LDataSetList.Utf8SpecialChars := True;
       SetInBlockEvents(True);
       If Not BinaryRequest Then
        LDataSetList.WriteToDataset(dtFull, vValue, Self, vJsonCount, vDatapacks, vActualRec)
       Else
        Begin
         vStream         := Decodeb64Stream(vValue);
         If (csDesigning in ComponentState) Then //Clone end compare Fields
          Begin
           vStream.Position := 0;
           vTempDS := TRESTDWClientSQL.Create(Nil);
           Try
            TRESTDWClientSQLBase(vTempDS).BinaryCompatibleMode := BinaryCompatibleMode;
            If BinaryCompatibleMode Then
             TRESTDWClientSQLBase(vTempDS).LoadFromStream(TMemoryStream(vStream), stMetadata)
            Else
             TRESTDWClientSQL(vTempDS).LoadFromStream(TMemoryStream(vStream));
            NewBinaryFieldList;
           Finally
            FreeAndNil(vTempDS);
           End;
          End;
         vStream.Position := 0;
         SetInBlockEvents(True);
         TRESTDWClientSQLBase(Self).BinaryCompatibleMode := BinaryCompatibleMode;
         Try
          TRESTDWClientSQLBase(Self).LoadFromStream(TMemoryStream(vStream));
          TRESTDWClientSQLBase(Self).DisableControls;
          SetInBlockEvents(True);
          If TRESTDWClientSQLBase(Self).Active Then
           Begin
            TRESTDWClientSQLBase(Self).SetInBlockEvents(True); // Novavix
            TRESTDWClientSQLBase(Self).Last;
            TRESTDWClientSQLBase(Self).SetInBlockEvents(False); // Novavix
            If TRESTDWClientSQLBase(Self).Recordcount > 0 Then
             vJsonCount := TRESTDWClientSQLBase(Self).Recordcount
            Else
             vJsonCount := TRESTDWClientSQLBase(Self).RecNo;
            //A Linha a baixo e pedido do Tiago Istuque que n�o mostrava o recordcount com BN
            TRESTDWClientSQL(Self).SetRecordCount(vJsonCount, vJsonCount);
            TRESTDWClientSQLBase(Self).SetInBlockEvents(True); // Novavix
            TRESTDWClientSQLBase(Self).First;
            TRESTDWClientSQLBase(Self).SetInBlockEvents(False); // Novavix
           End;
         Finally
          TRESTDWClientSQLBase(Self).EnableControls;
          SetInBlockEvents(False);
          If Active Then
           If Not (vInBlockEvents) and not vBinaryRequest and not vInRefreshData Then
            Begin
             If Assigned(vOnAfterOpen) Then
              vOnAfterOpen(Self);
            End;
          If Assigned(vStream) Then
           FreeAndNil(vStream);
          If State = dsBrowse Then
           Begin
            If RecordCount = 0 Then
             PrepareDetailsNew
            Else
             PrepareDetails(True);
           End;
         End;
        End;
       If vDatapacks <> -1 Then
        Begin
         vOldRecordCount := vDatapacks;
         If vOldRecordCount > vJsonCount Then
          vOldRecordCount := vJsonCount;
        End;
       Result := True;
      Except
        //Alexandre Magno - 16/01/2019
        On E: Exception Do
         Begin
          If Assigned(vStream) Then
           FreeAndNil(vStream);
          If Assigned(LDataSetList) Then
           FreeAndNil(LDataSetList);
          Raise Exception.Create(E.Message);
        End;
      End;
     End;
   Except
    On E: Exception Do
     Raise Exception.Create(E.Message);
   End;
   If (LDataSetList <> Nil) Then
    FreeAndNil(LDataSetList);
   If vError Then
    Begin
     If csDesigning in ComponentState Then
      Raise Exception.Create(PChar(vMessageError))
     Else
      Begin
       If Assigned(vOnGetDataError) Then
        vOnGetDataError(Not(vError), vMessageError)
       Else
        Raise Exception.Create(PChar(vMessageError));
      End;
    End;
  End
 Else If csDesigning in ComponentState Then
  Raise Exception.Create(PChar(cEmptyDBName));
End;

Function TRESTDWClientSQL.GetData(DataSet: TJSONValue): Boolean;
Var
 I             : Integer;
 LDataSetList  : TJSONValue;
 vError        : Boolean;
 vValue,
 vMessageError : String;
 vStream       : TMemoryStream;
 vTempDS       : TRESTDWClientSQLBase;
 Procedure NewBinaryFieldList;
 Var
  J                : Integer;
  vFieldDefinition : TFieldDefinition;
 Begin
  NewFieldList;
  vFieldDefinition := TFieldDefinition.Create;
  Try
   If vTempDS <> Nil Then
    Begin
     If (vTempDS.Fields.Count > 0) Then
      Begin
       For J := 0 To vTempDS.Fields.Count - 1 Do
        Begin
         If vTempDS.Fields[J].FieldKind = fkData Then
          Begin
           vFieldDefinition.FieldName := vTempDS.Fields[J].FieldName;
           vFieldDefinition.DataType  := vTempDS.Fields[J].DataType;
           If (vFieldDefinition.DataType <> ftFloat) Then
            vFieldDefinition.Size     := vTempDS.Fields[J].Size
           Else
            vFieldDefinition.Size         := 0;
           If (vFieldDefinition.DataType In [ftCurrency, ftBCD,
                                             {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                             {$IFEND}{$ENDIF} ftFMTBcd]) Then
            vFieldDefinition.Precision := TBCDField(vTempDS.Fields[J]).Precision
           Else If (vFieldDefinition.DataType = ftFloat) Then
            vFieldDefinition.Precision := TFloatField(vTempDS.Fields[J]).Precision;
           vFieldDefinition.Required   := vTempDS.Fields[J].Required;
           NewDataField(vFieldDefinition);
          End;
        End;
      End;
    End;
  Finally
   FreeAndNil(vFieldDefinition);
  End;
 End;
Begin
 vValue        := '';
 Result        := False;
 LDataSetList  := Nil;
 vStream       := Nil;
 vRowsAffected := 0;
 Self.Close;
 If Assigned(vDWResponseTranslator) Then
  Begin
   LDataSetList          := TJSONValue.Create;
   Try
    LDataSetList.Encoded  := False;
    If Assigned(vDWResponseTranslator.ClientREST) Then
     LDataSetList.Encoding := vDWResponseTranslator.ClientREST.RequestCharset;
    Try
     vValue := vDWResponseTranslator.Open(vDWResponseTranslator.RequestOpen,
                                          vDWResponseTranslator.RequestOpenUrl);
    Except
     Self.Close;
    End;
    If vValue = '[]' Then
     vValue := '';
    {$IFDEF FPC}
     vValue := StringReplace(vValue, #10, '', [rfReplaceAll]);
    {$ELSE}
     vValue := StringReplace(vValue, #$A, '', [rfReplaceAll]);
    {$ENDIF}
    vError := vValue = '';
    If (Assigned(LDataSetList)) And (Not (vError)) Then
     Begin
      Try
       LDataSetList.ServerFieldList := ServerFieldList;
       {$IFDEF FPC}
        LDataSetList.DatabaseCharSet := DatabaseCharSet;
        LDataSetList.NewFieldList    := @NewFieldList;
        LDataSetList.CreateDataSet   := @CreateDataSet;
        LDataSetList.NewDataField    := @NewDataField;
        LDataSetList.SetInitDataset  := @SetInitDataset;
        LDataSetList.SetRecordCount     := @SetRecordCount;
        LDataSetList.Setnotrepage       := @Setnotrepage;
        LDataSetList.SetInDesignEvents  := @SetInDesignEvents;
        LDataSetList.SetInBlockEvents   := @SetInBlockEvents;
        LDataSetList.SetInactive        := @SetInactive;
        LDataSetList.FieldListCount     := @FieldListCount;
        LDataSetList.GetInDesignEvents  := @GetInDesignEvents;
        LDataSetList.PrepareDetailsNew  := @PrepareDetailsNew;
        LDataSetList.PrepareDetails     := @PrepareDetails;
       {$ELSE}
        LDataSetList.NewFieldList    := NewFieldList;
        LDataSetList.CreateDataSet   := CreateDataSet;
        LDataSetList.NewDataField    := NewDataField;
        LDataSetList.SetInitDataset  := SetInitDataset;
        LDataSetList.SetRecordCount     := SetRecordCount;
        LDataSetList.Setnotrepage       := Setnotrepage;
        LDataSetList.SetInDesignEvents  := SetInDesignEvents;
        LDataSetList.SetInBlockEvents   := SetInBlockEvents;
        LDataSetList.SetInactive        := SetInactive;
        LDataSetList.FieldListCount     := FieldListCount;
        LDataSetList.GetInDesignEvents  := GetInDesignEvents;
        LDataSetList.PrepareDetailsNew  := PrepareDetailsNew;
        LDataSetList.PrepareDetails     := PrepareDetails;
       {$ENDIF}
       LDataSetList.OnWriterProcess := OnWriterProcess;
       LDataSetList.Utf8SpecialChars := True;
       LDataSetList.WriteToDataset(vValue, Self, vDWResponseTranslator, rtJSONAll);
       Result := True;
      Except
      End;
     End;
   Finally
    LDataSetList.Free;
   End;
  End
 Else If Assigned(vRESTDataBase) Then
  Begin
   Try
    If DataSet = Nil Then
     Begin
      For I := 0 To 1 Do
       Begin
        vRESTDataBase.ExecuteCommand(vActualPoolerMethodClient, vSQL, vParams, vError, vMessageError, LDataSetList,
                                     vRowsAffected, False, BinaryRequest,  BinaryCompatibleMode, Fields.Count = 0, Nil);
        If Not(vError) or (vMessageError <> cInvalidAuth) Then
         Break
        Else
         Begin
          Case vRESTDataBase.AuthenticationOptions.AuthorizationOption Of
           rdwAOBearer : Begin
                          If (TRDWAuthOptionBearerClient(vRESTDataBase.AuthenticationOptions.OptionParams).AutoRenewToken) Then
                           Begin
                            If (TRDWAuthOptionBearerClient(vRESTDataBase.AuthenticationOptions.OptionParams).AutoGetToken) And
                               (TRDWAuthOptionBearerClient(vRESTDataBase.AuthenticationOptions.OptionParams).Token <> '')  Then
                             TRDWAuthOptionBearerClient(vRESTDataBase.AuthenticationOptions.OptionParams).Token := '';
                            vRESTDataBase.TryConnect;
                           End;
                         End;
           rdwAOToken  : Begin
                          If (TRDWAuthOptionTokenClient(vRESTDataBase.AuthenticationOptions.OptionParams).AutoRenewToken) Then
                           Begin
                            If (TRDWAuthOptionTokenClient(vRESTDataBase.AuthenticationOptions.OptionParams).AutoGetToken)  And
                               (TRDWAuthOptionTokenClient(vRESTDataBase.AuthenticationOptions.OptionParams).Token  <> '')  Then
                             TRDWAuthOptionTokenClient(vRESTDataBase.AuthenticationOptions.OptionParams).Token := '';
                            vRESTDataBase.TryConnect;
                           End;
                         End;
          End;
         End;
       End;
      If LDataSetList <> Nil Then
       Begin
        If BinaryRequest Then
         Begin
          If Not LDataSetList.IsNull Then
           vValue := LDataSetList.Value;
         End;
        LDataSetList.Encoded  := vRESTDataBase.EncodeStrings;
        LDataSetList.Encoding := DataBase.Encoding;
        If Not BinaryRequest Then
         Begin
          If Not LDataSetList.IsNull Then
           vValue := LDataSetList.ToJSON;
         End;
       End;
     End
    Else
     Begin
      If Not DataSet.IsNull Then
       vValue                := DataSet.Value;
      LDataSetList          := TJSONValue.Create;
      LDataSetList.Encoded  := vRESTDataBase.EncodeStrings;
      LDataSetList.Encoding := DataBase.Encoding;
      vError                := False;
     End;
    If (Assigned(LDataSetList)) And (Not (vError)) Then
     Begin
      Try
       vActualJSON := vValue;
       vActualRec  := 0;
       vJsonCount  := 0;
       LDataSetList.OnWriterProcess     := OnWriterProcess;
       LDataSetList.ServerFieldList := ServerFieldList;
       {$IFDEF FPC}
        LDataSetList.DatabaseCharSet    := DatabaseCharSet;
        LDataSetList.NewFieldList       := @NewFieldList;
        LDataSetList.CreateDataSet      := @CreateDataSet;
        LDataSetList.NewDataField       := @NewDataField;
        LDataSetList.SetInitDataset     := @SetInitDataset;
        LDataSetList.SetRecordCount     := @SetRecordCount;
        LDataSetList.Setnotrepage       := @Setnotrepage;
        LDataSetList.SetInDesignEvents  := @SetInDesignEvents;
        LDataSetList.SetInBlockEvents   := @SetInBlockEvents;
        LDataSetList.SetInactive        := @SetInactive;
        LDataSetList.FieldListCount     := @FieldListCount;
        LDataSetList.GetInDesignEvents  := @GetInDesignEvents;
        LDataSetList.PrepareDetailsNew  := @PrepareDetailsNew;
        LDataSetList.PrepareDetails     := @PrepareDetails;
        LDataSetList.ServerFieldList    := ServerFieldList;
       {$ELSE}
        LDataSetList.NewFieldList       := NewFieldList;
        LDataSetList.CreateDataSet      := CreateDataSet;
        LDataSetList.NewDataField       := NewDataField;
        LDataSetList.SetInitDataset     := SetInitDataset;
        LDataSetList.SetRecordCount     := SetRecordCount;
        LDataSetList.Setnotrepage       := Setnotrepage;
        LDataSetList.SetInDesignEvents  := SetInDesignEvents;
        LDataSetList.SetInBlockEvents   := SetInBlockEvents;
        LDataSetList.SetInactive        := SetInactive;
        LDataSetList.FieldListCount     := FieldListCount;
        LDataSetList.GetInDesignEvents  := GetInDesignEvents;
        LDataSetList.PrepareDetailsNew  := PrepareDetailsNew;
        LDataSetList.PrepareDetails     := PrepareDetails;
        LDataSetList.ServerFieldList    := ServerFieldList;
       {$ENDIF}
       LDataSetList.Utf8SpecialChars := True;
       If Not BinaryRequest Then
        LDataSetList.WriteToDataset(dtFull, vValue, Self, vJsonCount, vDatapacks, vActualRec)
       Else
        Begin
         vStream         := Decodeb64Stream(vValue);
         If (csDesigning in ComponentState) Then //Clone end compare Fields
          Begin
           vStream.Position := 0;
           vTempDS := TRESTDWClientSQL.Create(Nil);
           Try
            TRESTDWClientSQLBase(vTempDS).BinaryCompatibleMode := BinaryCompatibleMode;
            If BinaryCompatibleMode Then
             TRESTDWClientSQLBase(vTempDS).LoadFromStream(TMemoryStream(vStream), stMetadata)
            Else
             TRESTDWClientSQL(vTempDS).LoadFromStream(TMemoryStream(vStream));
            NewBinaryFieldList;
           Finally
            FreeAndNil(vTempDS);
           End;
          End;
         vStream.Position := 0;
         SetInBlockEvents(True);
         TRESTDWClientSQLBase(Self).BinaryCompatibleMode := BinaryCompatibleMode;
         Try
          TRESTDWClientSQLBase(Self).LoadFromStream(TMemoryStream(vStream));
          TRESTDWClientSQLBase(Self).DisableControls;
          SetInBlockEvents(True);
          If TRESTDWClientSQLBase(Self).Active Then
           Begin
            TRESTDWClientSQLBase(Self).SetInBlockEvents(True); // Novavix
            TRESTDWClientSQLBase(Self).Last;
            TRESTDWClientSQLBase(Self).SetInBlockEvents(False); // Novavix
            If TRESTDWClientSQLBase(Self).Recordcount > 0 Then
             vJsonCount := TRESTDWClientSQLBase(Self).Recordcount
            Else
             vJsonCount := TRESTDWClientSQLBase(Self).RecNo;
            //A Linha a baixo e pedido do Tiago Istuque que n�o mostrava o recordcount com BN
            TRESTDWClientSQL(Self).SetRecordCount(vJsonCount, vJsonCount);
            TRESTDWClientSQLBase(Self).SetInBlockEvents(True); // Novavix
            TRESTDWClientSQLBase(Self).First;
            TRESTDWClientSQLBase(Self).SetInBlockEvents(False); // Novavix
           End;
         Finally
          TRESTDWClientSQLBase(Self).EnableControls;
          SetInBlockEvents(False);
          If Active Then
           If Not (vInBlockEvents) and not vBinaryRequest and not vInRefreshData Then
            Begin
             If Assigned(vOnAfterOpen) Then
              vOnAfterOpen(Self);
            End;
          If Assigned(vStream) Then
           FreeAndNil(vStream);
          If State = dsBrowse Then
           Begin
            If RecordCount = 0 Then
             PrepareDetailsNew
            Else
             PrepareDetails(True);
           End;
         End;
        End;
       If vDatapacks <> -1 Then
        Begin
         vOldRecordCount := vDatapacks;
         If vOldRecordCount > vJsonCount Then
          vOldRecordCount := vJsonCount;
        End;
       Result := True;
      Except
        //Alexandre Magno - 16/01/2019
        On E: Exception Do
         Begin
          If Assigned(vStream) Then
           FreeAndNil(vStream);
          If Assigned(LDataSetList) Then
           FreeAndNil(LDataSetList);
          Raise Exception.Create(E.Message);
        End;
      End;
     End;
   Except
     //Alexandre Magno - 16/01/2019
    On E: Exception Do
     Raise Exception.Create(E.Message);
   End;
   If (LDataSetList <> Nil) Then
    FreeAndNil(LDataSetList);
   If vError Then
    Begin
     If csDesigning in ComponentState Then
      Raise Exception.Create(PChar(vMessageError))
     Else
      Begin
       If Assigned(vOnGetDataError) Then
        vOnGetDataError(Not(vError), vMessageError)
       Else
        Raise Exception.Create(PChar(vMessageError));
      End;
    End;
  End
 Else If csDesigning in ComponentState Then
  Raise Exception.Create(PChar(cEmptyDBName));
End;

Function TRESTDWTable.GetDWResponseTranslator: TDWResponseTranslator;
Begin
 Result := vDWResponseTranslator;
End;

function TRESTDWClientSQL.GetDWResponseTranslator: TDWResponseTranslator;
begin
  Result := vDWResponseTranslator;
end;

Function TRESTDWTable.GetFieldListByName(aName: String): TFieldDefinition;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Length(vFieldsList) -1 Do
  Begin
   If UpperCase(vFieldsList[I].FieldName) = Uppercase(aName) Then
    Begin
     Result := vFieldsList[I];
     Break;
    End;
  End;
End;

Function TRESTDWClientSQL.GetFieldListByName(aName: String): TFieldDefinition;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Length(vFieldsList) -1 Do
  Begin
   If UpperCase(vFieldsList[I].FieldName) = Uppercase(aName) Then
    Begin
     Result := vFieldsList[I];
     Break;
    End;
  End;
End;

Function TRESTDWTable.GetInBlockEvents: Boolean;
Begin
 Result := vInBlockEvents;
End;

Function TRESTDWClientSQL.GetInBlockEvents: Boolean;
Begin
 Result := vInBlockEvents;
End;

Function TRESTDWTable.GetInDesignEvents: Boolean;
Begin
 Result := vInDesignEvents;
End;

Function TRESTDWClientSQL.GetInDesignEvents: Boolean;
Begin
 Result := vInDesignEvents;
End;

Function TRESTDWTable.GetMassiveCache : TDWMassiveCache;
begin
  Result := vMassiveCache;
end;

function TRESTDWClientSQL.GetMassiveCache: TDWMassiveCache;
begin
  Result := vMassiveCache;
end;

Function TRESTDWTable.GetRecordCount : Integer;
Begin
 If Not Filtered Then
  Result := vJsonCount
 Else
  Result := Inherited GetRecordCount;
End;

Function TRESTDWClientSQL.GetRecordCount : Integer;
Begin
 If Not Filtered Then
  Result := vJsonCount
 Else
  Result := Inherited GetRecordCount;
End;

Procedure TRESTDWTable.GetTmpCursor;
{$IFNDEF FPC}
{$IFDEF WINFMX}
Var
 CS: IFMXCursorService;
{$ENDIF}
{$ENDIF}
Begin
{$IFNDEF FPC}
 {$IFDEF WINFMX}
  If TPlatformServices.Current.SupportsPlatformService(IFMXCursorService) Then
   CS := TPlatformServices.Current.GetPlatformService(IFMXCursorService) As IFMXCursorService;
  If Assigned(CS) then
   Begin
    If CS.GetCursor <> vActionCursor Then
     vOldCursor := CS.GetCursor;
   End;
 {$ELSE}
  {$IFNDEF HAS_FMX}
  If Screen.Cursor <> vActionCursor Then
   vOldCursor := Screen.Cursor;
  {$ENDIF}
 {$ENDIF}
{$ELSE}
 If Screen.Cursor <> vActionCursor Then
  vOldCursor := Screen.Cursor;
{$ENDIF}
End;

Procedure TRESTDWClientSQL.GetTmpCursor;
{$IFNDEF FPC}
{$IFDEF WINFMX}
Var
 CS: IFMXCursorService;
{$ENDIF}
{$ENDIF}
Begin
{$IFNDEF FPC}
 {$IFDEF WINFMX}
  If TPlatformServices.Current.SupportsPlatformService(IFMXCursorService) Then
   CS := TPlatformServices.Current.GetPlatformService(IFMXCursorService) As IFMXCursorService;
  If Assigned(CS) then
   Begin
    If CS.GetCursor <> vActionCursor Then
     vOldCursor := CS.GetCursor;
   End;
 {$ELSE}
  {$IFNDEF HAS_FMX}
  If Screen.Cursor <> vActionCursor Then
   vOldCursor := Screen.Cursor;
  {$ENDIF}
 {$ENDIF}
{$ELSE}
 If Screen.Cursor <> vActionCursor Then
  vOldCursor := Screen.Cursor;
{$ENDIF}
End;

Procedure TRESTDWTable.SaveToStream(Var Stream : TMemoryStream);
Begin
 If Not Assigned(Stream) then
  Exit;
 vInBlockEvents := True;
 Try
  TRESTDWClientSQLBase(Self).SaveToStream(Stream);
 Finally
  vInBlockEvents := False;
 End;
End;

Procedure TRESTDWClientSQL.SaveToStream(Var Stream : TMemoryStream);
Begin
 If Not Assigned(Stream) then
  Exit;
 vInBlockEvents := True;
 Try
  TRESTDWClientSQLBase(Self).SaveToStream(Stream);
 Finally
  vInBlockEvents := False;
 End;
End;

Procedure TRESTDWTable.CreateMassiveDataset;
Begin
 If Trim(vTableName) <> '' Then
  Begin
   vLastOpen := Random(9999);
   TMassiveDatasetBuffer(vMassiveDataset).BuildDataset(Self, Trim(vTableName));
  End;
End;

procedure TRESTDWClientSQL.CreateMassiveDataset;
Begin
 If Trim(vUpdateTableName) <> '' Then
  Begin
   vLastOpen := Random(9999);
   TMassiveDatasetBuffer(vMassiveDataset).BuildDataset(Self, Trim(vUpdateTableName));
  End;
End;

procedure TRESTDWClientSQL.ExecuteOpen;
Begin
 Try
  If (Not vInDesignEvents) Then
   ProcBeforeOpen(Self);
  vInBlockEvents := True;
  Filter         := '';
  Filtered       := False;
  vInBlockEvents := False;
  GetNewData     := Filtered;
  vActive        := (GetData) And Not(vInDesignEvents);
  GetNewData     := Not vActive;
  If Not (vInBlockEvents) and not vInRefreshData Then
   Begin
    If Assigned(vOnAfterOpen) Then
     vOnAfterOpen(Self);
   End;
  If vInDesignEvents Then
   Begin
    vInactive       := False;
    vInDesignEvents := False;
    vInBlockEvents  := vInDesignEvents;
    Exit;
   End;
  If State = dsBrowse Then
   CreateMassiveDataset;
  If BinaryRequest        Then
   Begin
    If Assigned(OnCalcFields) Then
     Begin
      DisableControls;
      Last;
      First;
      EnableControls;
     End;
   End;
 Except
  Raise;
 End;
End;

Procedure TRESTDWTable.SetActiveDB(Value: Boolean);
Begin
 Try
  ChangeCursor;
  If (vInactive) And Not(vInDesignEvents) Then
   Begin
    vActive := (Value) And Not(vInDesignEvents);
    If vActive Then
     BaseOpen
    Else
     Begin
      BaseClose;
      vinactive := False;
     End;
    Exit;
   End;
  If (vActive) And (Assigned(vDWResponseTranslator)) Then
   vActive := False;
  If Assigned(vDWResponseTranslator) Then
   Begin
    If vDWResponseTranslator.FieldDefs.Count <> FieldDefs.Count Then
     FieldDefs.Clear;
   End;
  If ((vDWResponseTranslator <> Nil) Or (vRESTDataBase <> Nil)) And (Value) Then
   Begin
    If Not Assigned(vDWResponseTranslator) Then
     Begin
      If vRESTDataBase <> Nil Then
       If Not vRESTDataBase.Active Then
        vRESTDataBase.Active := True;
      If Not vRESTDataBase.Active then
       Begin
        vActive := False;
        Exit;
       End;
     End;
    Try
     If (Not(vActive) And (Value)) Or (GetNewData) Or (vInDesignEvents) Then
      Begin
       GetNewData := False;
       If (Not vInDesignEvents) Then
        ProcBeforeOpen(Self);
       vInBlockEvents := True;
       Filter         := '';
       Filtered       := False;
       vInBlockEvents := False;
       GetNewData     := Filtered;
       vActive        := (GetData) And Not(vInDesignEvents);
       GetNewData     := Not vActive;
       If Not (vInBlockEvents) and not vInRefreshData Then
        Begin
         If Assigned(vOnAfterOpen) Then
          vOnAfterOpen(Self);
        End;
       If vInDesignEvents Then
        Begin
         vInactive       := False;
         vInDesignEvents := False;
         vInBlockEvents  := vInDesignEvents;
         Exit;
        End;
       If State = dsBrowse Then
        CreateMassiveDataset;
      End
     Else
      Begin
       If State = dsBrowse Then
        Begin
         CreateMassiveDataset;
         PrepareDetails(True);
        End
       Else If State = dsInactive Then
        PrepareDetails(False);
      End;
    Except
     On E : Exception do
      Begin
       vInBlockEvents := False;
       If csDesigning in ComponentState Then
        Raise Exception.Create(PChar(E.Message))
       Else
        Begin
         If Assigned(vOnGetDataError) Then
          vOnGetDataError(False, E.Message);
         If (vRaiseError) Then
          Raise Exception.Create(PChar(E.Message));
        End;
      End;
    End;
   End
  Else
   Begin
    vInDesignEvents := False;
    If Not InLoadFromStream Then
     Begin
      vActive := False;
      Close;
      If Not (csLoading in ComponentState) And
         Not (csReading in ComponentState) Then
       If Value Then
        If vRESTDataBase = Nil Then
         Begin
          If (vRaiseError) Then
           Raise Exception.Create(PChar(cEmptyDBName));
         End;
     End;
   End;
 Finally
  ChangeCursor(True);
 End;
End;

procedure TRESTDWClientSQL.SetActiveDB(Value: Boolean);
Begin
 Try
  ChangeCursor;
  If (vInactive) And Not(vInDesignEvents) Then
   Begin
    vActive := (Value) And Not(vInDesignEvents);
    If vActive Then
     BaseOpen
    Else
     Begin
      BaseClose;
      vinactive := False;
     End;
    Exit;
   End;
  If (vActive) And (Assigned(vDWResponseTranslator)) Then
   vActive := False;
  If Assigned(vDWResponseTranslator) Then
   Begin
    If vDWResponseTranslator.FieldDefs.Count <> FieldDefs.Count Then
     FieldDefs.Clear;
   End;
  If ((vDWResponseTranslator <> Nil) Or (vRESTDataBase <> Nil)) And (Value) Then
   Begin
    If Not Assigned(vDWResponseTranslator) Then
     Begin
      If vRESTDataBase <> Nil Then
       If Not vRESTDataBase.Active Then
        vRESTDataBase.Active := True;
      If Not vRESTDataBase.Active then
       Begin
        vActive := False;
        Exit;
       End;
     End;
    Try
     If (Not(vActive) And (Value)) Or (GetNewData) Or (vInDesignEvents) Then
      Begin
       GetNewData := False;
       If Not (vPropThreadRequest) Then
        ExecuteOpen
       Else
        Begin
         {$IFDEF FPC}
          ThreadStart(@ExecuteOpen);
         {$ELSE}
          ThreadStart(ExecuteOpen);
         {$ENDIF}
        End;
      End
     Else
      Begin
       If State = dsBrowse Then
        Begin
         CreateMassiveDataset;
         PrepareDetails(True);
        End
       Else If State = dsInactive Then
        Begin
         vReadData := False;
         PrepareDetails(False);
        End;
      End;
    Except
     On E : Exception do
      Begin
       vInBlockEvents := False;
       If csDesigning in ComponentState Then
        Raise Exception.Create(PChar(E.Message))
       Else
        Begin
         If Assigned(vOnGetDataError) Then
          vOnGetDataError(False, E.Message);
         If (vRaiseError) Then
          Raise Exception.Create(PChar(E.Message));
        End;
      End;
    End;
   End
  Else
   Begin
    vInDesignEvents := False;
    If Not InLoadFromStream Then
     Begin
      vActive := False;
      Close;
      If Not (csLoading in ComponentState) And
         Not (csReading in ComponentState) Then
       If Value Then
        If vRESTDataBase = Nil Then
         Begin
          If (vRaiseError) Then
           Raise Exception.Create(PChar(cEmptyDBName));
         End;
     End;
   End;
 Finally
  ChangeCursor(True);
 End;
End;

Procedure TRESTDWTable.SetAutoRefreshAfterCommit(Value: Boolean);
Begin
 vAutoRefreshAfterCommit := Value;
End;

Procedure TRESTDWClientSQL.SetAutoRefreshAfterCommit(Value: Boolean);
Begin
 vAutoRefreshAfterCommit := Value;
 If Value Then
  vReflectChanges := False;
End;

procedure TRESTDWTable.SetCacheUpdateRecords(Value: Boolean);
Begin
 vCacheUpdateRecords := Value;
End;

procedure TRESTDWClientSQL.SetCacheUpdateRecords(Value: Boolean);
Begin
 vCacheUpdateRecords := Value;
End;

Procedure TRESTDWTable.SetCursor;
{$IFNDEF FPC}
{$IFDEF WINFMX}
Var
 CS: IFMXCursorService;
{$ENDIF}
{$ENDIF}
Begin
{$IFNDEF FPC}
 {$IFDEF WINFMX}
  If TPlatformServices.Current.SupportsPlatformService(IFMXCursorService) Then
   CS := TPlatformServices.Current.GetPlatformService(IFMXCursorService) As IFMXCursorService;
  If Assigned(CS) then
   Begin
    If vActionCursor <> crNone Then
     If CS.GetCursor <> vActionCursor Then
      CS.SetCursor(vActionCursor);
   End;
 {$ELSE}
  {$IFNDEF HAS_FMX}
  If vActionCursor <> crNone Then
   If Screen.Cursor <> vActionCursor Then
    Screen.Cursor := vActionCursor;
  {$ENDIF}
 {$ENDIF}
{$ELSE}
 If vActionCursor <> crNone Then
  If Screen.Cursor <> vActionCursor Then
   Screen.Cursor := vActionCursor;
{$ENDIF}
End;

Procedure TRESTDWClientSQL.SetCursor;
{$IFNDEF FPC}
{$IFDEF WINFMX}
Var
 CS: IFMXCursorService;
{$ENDIF}
{$ENDIF}
Begin
{$IFNDEF FPC}
 {$IFDEF WINFMX}
  If TPlatformServices.Current.SupportsPlatformService(IFMXCursorService) Then
   CS := TPlatformServices.Current.GetPlatformService(IFMXCursorService) As IFMXCursorService;
  If Assigned(CS) then
   Begin
    If vActionCursor <> crNone Then
     If CS.GetCursor <> vActionCursor Then
      CS.SetCursor(vActionCursor);
   End;
 {$ELSE}
  {$IFNDEF HAS_FMX}
  If vActionCursor <> crNone Then
   If Screen.Cursor <> vActionCursor Then
    Screen.Cursor := vActionCursor;
  {$ENDIF}
 {$ENDIF}
{$ELSE}
 If vActionCursor <> crNone Then
  If Screen.Cursor <> vActionCursor Then
   Screen.Cursor := vActionCursor;
{$ENDIF}
End;

constructor TRESTDWStoredProc.Create(AOwner: TComponent);
begin
 Inherited;
 vParams        := TParams.Create(Self);
 vProcName      := '';
 vSchemaName    := vProcName;
 vParamCount    := 0;
 vBinaryRequest := False;
end;

destructor TRESTDWStoredProc.Destroy;
begin
 vParams.Free;
 Inherited;
end;

Function TRESTDWStoredProc.ExecProc(Var Error : String) : Boolean;
Begin
 If vRESTDataBase <> Nil Then
  Begin
   If vParams.Count > 0 Then
    vRESTDataBase.ExecuteProcedure(vActualPoolerMethodClient, vProcName, vParams, Result, Error);
  End
 Else
  Raise Exception.Create(PChar(cEmptyDBName));
End;

Function TRESTDWStoredProc.ParamByName(Value: String): TParam;
Begin
 Result := Params.ParamByName(Value);
End;

Procedure TRESTDWStoredProc.SetUpdateSQL(Value : TRESTDWUpdateSQL);
Begin
 If (Assigned(vUpdateSQL)) And
    (vUpdateSQL <> Value)  Then
  Begin
   vUpdateSQL.SetClientSQL(Nil);
   vUpdateSQL := Nil;
  End;
 If vUpdateSQL <> Value Then
  vUpdateSQL := Value;
 If vUpdateSQL <> Nil   Then
  Begin
   vUpdateSQL.SetClientSQL(Self);
   vUpdateSQL.FreeNotification(Self);
  End;
End;

Function  TRESTDWStoredProc.GetUpdateSQL       : TRESTDWUpdateSQL;
Begin
 Result := vUpdateSQL;
End;

Procedure TRESTDWStoredProc.Notification(AComponent : TComponent;
                                         Operation  : TOperation);
Begin
 If (Operation    = opRemove)              And
    (AComponent   = vRESTDataBase)         Then
  vRESTDataBase  := Nil;
 If (Operation    = opRemove)              And
    (AComponent   = vUpdateSQL)            Then
  vUpdateSQL      := Nil;
 Inherited Notification(AComponent, Operation);
end;

procedure TRESTDWStoredProc.SetDataBase(const Value: TRESTDWDataBase);
begin
 vRESTDataBase := Value;
end;

Procedure TClientConnectionDefs.SetConnectionDefs(Value : TConnectionDefs);
Begin
 If vActive Then
  vConnectionDefs := Value;
End;

Constructor TClientConnectionDefs.Create(AOwner       : TPersistent);
Begin
 inherited Create;
 vActive := False;
 FOwner  := AOwner;
End;

Destructor TClientConnectionDefs.Destroy;
Begin
 If Assigned(vConnectionDefs) Then
  FreeAndNil(vConnectionDefs);
 Inherited;
End;

Function    TClientConnectionDefs.GetOwner  : TPersistent;
Begin
 Result := FOwner;
End;

Procedure TClientConnectionDefs.DestroyParam;
Begin
 {$IFDEF FPC}
 If Not(csDesigning in TComponent(GetOwner).ComponentState) Then
  Begin
   If Assigned(vConnectionDefs) Then
    FreeAndNil(vConnectionDefs);
  End
 Else
  Begin
   If Not (vActive) Then
    vConnectionDefs := Nil;
  End;
 {$ELSE}
 If Assigned(vConnectionDefs) Then
  FreeAndNil(vConnectionDefs);
 {$ENDIF}
End;

Procedure TClientConnectionDefs.SetClientConnectionDefs(Value : Boolean);
Begin
 vActive := Value;
 Case Value Of
  True  : Begin
           If Not Assigned(vConnectionDefs) Then
            vConnectionDefs := TConnectionDefs.Create;
          End;
  False : DestroyParam;
 End;
End;

Procedure TRESTDWDataBase.SetMyIp(Value: String);
Begin
End;

Class Function TRESTDWTable.FieldDefExist(Const Dataset : TDataset;
                                          Value         : String) : TFieldDef;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Dataset.FieldDefs.Count -1 Do
  Begin
   If UpperCase(Value) = UpperCase(Dataset.FieldDefs[I].Name) Then
    Begin
     Result := Dataset.FieldDefs[I];
     Break;
    End;
  End;
End;

Class Function TRESTDWClientSQL.FieldDefExist(Const Dataset : TDataset;
                                              Value         : String) : TFieldDef;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Dataset.FieldDefs.Count -1 Do
  Begin
   If UpperCase(Value) = UpperCase(Dataset.FieldDefs[I].Name) Then
    Begin
     Result := Dataset.FieldDefs[I];
     Break;
    End;
  End;
End;

Function TRESTDWTable.FieldExist(Value: String): TField;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Fields.Count -1 Do
  Begin
   If UpperCase(Value) = UpperCase(Fields[I].FieldName) Then
    Begin
     Result := Fields[I];
     Break;
    End;
  End;
End;

Function TRESTDWClientSQL.FieldExist(Value: String): TField;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Fields.Count -1 Do
  Begin
   If UpperCase(Value) = UpperCase(Fields[I].FieldName) Then
    Begin
     Result := Fields[I];
     Break;
    End;
  End;
End;

Procedure TRESTDWDriver.BuildDatasetLine(Var Query      : TDataset;
                                         Massivedataset : TMassivedatasetBuffer;
                                         MassiveCache   : Boolean = False);
Var
 I, A              : Integer;
 vMasterField,
 vTempValue        : String;
 vStringStream     : TMemoryStream;
 MassiveField      : TMassiveField;
 MassiveReplyValue : TMassiveReplyValue;
 MassiveReplyCache : TMassiveReplyCache;
Begin
 vTempValue    := '';
 vStringStream := Nil;
 If Massivedataset.MassiveMode = mmUpdate Then
  Begin
   For I := 0 To Massivedataset.AtualRec.UpdateFieldChanges.Count -1 Do
    Begin
     MassiveField  := MassiveDataset.Fields.FieldByName(Massivedataset.AtualRec.UpdateFieldChanges[I]);
     If (Lowercase(MassiveField.FieldName) = Lowercase(DWFieldBookmark)) then
      Continue;
     If (MassiveField <> Nil) Then
      Begin
       If MassiveField.IsNull Then
        vTempValue := ''
       Else
        vTempValue := MassiveField.Value;
       If MassiveCache Then
        Begin
         If (MassiveField.KeyField) And (Not (MassiveField.ReadOnly)) Then
          Begin
           MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag];
           If MassiveReplyCache = Nil Then
            Begin
             If Not MassiveField.IsNull Then
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag, MassiveField.FieldName, MassiveField.OldValue, MassiveField.Value);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, MassiveField.OldValue);
              End
             Else
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag, MassiveField.FieldName, Null, MassiveField.OldValue);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, Null);
              End;
             If Not MassiveField.IsNull Then
              vTempValue                   := MassiveReplyValue.NewValue
             Else
              vTempValue                   := MassiveReplyValue.OldValue;
            End
           Else
            Begin
             If Not MassiveField.IsNull Then
              MassiveReplyValue            := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, MassiveField.OldValue)
             Else
              MassiveReplyValue            := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, MassiveField.Value);
             If MassiveReplyValue = Nil Then
              Begin
               MassiveReplyValue           := TMassiveReplyValue.Create;
               MassiveReplyValue.ValueName := MassiveField.FieldName;
               If Not MassiveField.IsNull Then
                MassiveReplyValue.OldValue := MassiveField.Value
               Else
                MassiveReplyValue.OldValue := MassiveField.OldValue;
               MassiveReplyValue.NewValue  := Null;
               MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].Add(MassiveReplyValue);
               If Not MassiveField.IsNull Then
                vTempValue := MassiveField.Value;
              End
             Else
              Begin
               MassiveField.Value := MassiveReplyValue.NewValue;
               If Not MassiveField.IsNull Then
                vTempValue := MassiveField.Value;
              End;
            End;
          End
         Else
          Begin
           If Trim(MassiveDataset.MasterCompTag) <> '' Then
            Begin
             MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag];
             If MassiveReplyCache <> Nil Then
              Begin
               MassiveReplyValue := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag].ItemByValue(MassiveField.FieldName, MassiveField.Value);
               If MassiveReplyValue <> Nil Then
                vTempValue := MassiveReplyValue.NewValue;
              End;
            End
           Else If Not MassiveField.IsNull Then
            vTempValue := MassiveField.Value;
          End;
        End;
       If ((vTempValue = 'null')  Or
           (Query.FieldByName(MassiveField.FieldName).ReadOnly) Or
           (MassiveField.IsNull)) Then
        Begin
         If Not (Query.FieldByName(MassiveField.FieldName).ReadOnly) Then
          Query.FieldByName(MassiveField.FieldName).Clear;
         Continue;
        End;
       If MassiveField.IsNull Then
        Continue;
       If Query.FieldByName(MassiveField.FieldName).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                 ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                 ftString,    ftWideString,
                                                                 ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                         {$IF CompilerVersion > 21}
                                                                                 , ftWideMemo
                                                                          {$IFEND}
                                                                         {$ENDIF}]    Then
        Begin
         If (vTempValue <> Null) And (vTempValue <> '') And
            (Trim(vTempValue) <> 'null') Then
          Begin
           If Query.FieldByName(MassiveField.FieldName).Size > 0 Then
            Query.FieldByName(MassiveField.FieldName).AsString := Copy(vTempValue, 1, Query.FieldByName(MassiveField.FieldName).Size)
           Else
            Query.FieldByName(MassiveField.FieldName).AsString := vTempValue;
          End
         Else
          Query.FieldByName(MassiveField.FieldName).Clear;
        End
       Else
        Begin
         If Query.FieldByName(MassiveField.FieldName).DataType in [ftBoolean] Then
          Begin
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.FieldByName(MassiveField.FieldName).Value := vTempValue
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
          Begin
           If Lowercase(Query.FieldByName(MassiveField.FieldName).FieldName) = Lowercase(Massivedataset.SequenceField) Then
            Continue;
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Begin
             If vTempValue <> Null Then
              Begin
               If Query.FieldByName(MassiveField.FieldName).DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                Begin
                 {$IFNDEF FPC}
                  {$IF CompilerVersion > 21}Query.FieldByName(MassiveField.FieldName).AsLargeInt := StrToInt64(vTempValue);
                  {$ELSE} Query.FieldByName(MassiveField.FieldName).AsInteger                    := StrToInt64(vTempValue);
                  {$IFEND}
                 {$ELSE}
                  Query.FieldByName(MassiveField.FieldName).AsLargeInt := StrToInt64(vTempValue);
                 {$ENDIF}
                End
               Else
                Query.FieldByName(MassiveField.FieldName).AsInteger  := StrToInt(vTempValue);
              End;
            End
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle{$IFEND}{$ENDIF}] Then
          Begin
           If (vTempValue <> Null) And (vTempValue <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.FieldByName(MassiveField.FieldName).AsFloat  := StrToFloat(vTempValue)
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
          Begin
           If (vTempValue <> Null) And (vTempValue <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.FieldByName(MassiveField.FieldName).AsDateTime  := StrToDatetime(vTempValue)
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End  //Tratar Blobs de Parametros...
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                        ftGraphic, ftOraBlob, ftOraClob] Then
          Begin
           Try
            If (vTempValue <> 'null') And
               (vTempValue <> '') Then
             Begin
              vStringStream := Decodeb64Stream(vTempValue);
              vStringStream.Position := 0;
              TBlobfield(Query.FieldByName(MassiveField.FieldName)).LoadFromStream(vStringStream);
             End
            Else
             Query.FieldByName(MassiveField.FieldName).Clear;
           Finally
            If Assigned(vStringStream) Then
             FreeAndNil(vStringStream);
           End;
          End
         Else If (vTempValue <> Null) And
                 (Trim(vTempValue) <> 'null') Then
          Query.FieldByName(MassiveField.FieldName).Value := vTempValue
         Else
          Query.FieldByName(MassiveField.FieldName).Clear;
        End;
      End;
    End;
  End
 Else
  Begin
   For I := 0 To Query.Fields.Count -1 Do
    Begin
     If (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName) <> Nil) Then
      Begin
       If (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue) Then
        Begin
         A := -1;
         If (MassiveDataset.SequenceName <> '') Then
          A := GetGenID(Query, MassiveDataset.SequenceName);
         If A > -1 Then
          Query.Fields[I].Value := A;
         Continue;
        End
       Else If (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).isNull) Or
               (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).ReadOnly) Then
        Begin
         If ((Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).ReadOnly)) And
             (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue))) Then
          Query.Fields[I].Clear;
         Continue;
        End;
       If MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
        vTempValue := ''
       Else
        vTempValue := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
       If MassiveCache Then
        Begin
         If MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).KeyField Then
          Begin
           MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag];
           If MassiveReplyCache = Nil Then
            Begin
             If Not MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).OldValue,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(Query.Fields[I].FieldName,
                                                                                                                              MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).OldValue);
              End
             Else
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName,
                                                          Null,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).OldValue);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(Query.Fields[I].FieldName,
                                                                                                                              Null);
              End;
             If Not MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
              vTempValue                   := MassiveReplyValue.NewValue
             Else
              vTempValue                   := MassiveReplyValue.OldValue;
            End
           Else
            Begin
             MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName,
                                                                                                                            MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
             If MassiveReplyValue = Nil Then
              Begin
               MassiveReplyValue           := TMassiveReplyValue.Create;
               MassiveReplyValue.ValueName := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName;
               MassiveReplyValue.OldValue  := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
               MassiveReplyValue.NewValue  := MassiveReplyValue.OldValue;
               MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].Add(MassiveReplyValue);
               vTempValue                  := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
              End;
            End;
           vMasterField := MassiveDataset.MasterFieldFromDetail(Query.Fields[I].FieldName);
           If vMasterField <> '' Then
            Begin
             MassiveReplyValue := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag].ItemByValue(vMasterField, MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
             If MassiveReplyValue <> Nil Then
              vTempValue := MassiveReplyValue.NewValue;
            End;
          End
         Else
          Begin
           If Trim(MassiveDataset.MasterCompTag) <> '' Then
            Begin
             MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag];
             If MassiveReplyCache <> Nil Then
              Begin
               vMasterField := MassiveDataset.MasterFieldFromDetail(Query.Fields[I].FieldName);
               If vMasterField = '' Then
                vMasterField := Query.Fields[I].FieldName;
               MassiveReplyValue := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag].ItemByValue(vMasterField, MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
               If MassiveReplyValue <> Nil Then
                vTempValue := MassiveReplyValue.NewValue;
              End;
            End
           Else If Not MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
            vTempValue := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
          End;
        End;
       If MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
        Continue;
       If Query.Fields[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                             ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                             ftString,    ftWideString,
                             ftMemo, ftFmtMemo {$IFNDEF FPC}
                                     {$IF CompilerVersion > 21}
                                      , ftWideMemo
                                     {$IFEND}
                                    {$ENDIF}]    Then
        Begin
         If (vTempValue <> Null) And
            (Trim(vTempValue) <> 'null') Then
          Begin
           If Query.Fields[I].Size > 0 Then
            Query.Fields[I].AsString := Copy(vTempValue, 1, Query.Fields[I].Size)
           Else
            Query.Fields[I].AsString := vTempValue;
          End
         Else
          Query.Fields[I].Clear;
        End
       Else
        Begin
         If Query.Fields[I].DataType in [ftBoolean] Then
          Begin
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.Fields[I].Value := vTempValue
           Else
            Query.Fields[I].Clear;
          End
         Else If Query.Fields[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
          Begin
           If Lowercase(Query.Fields[I].FieldName) = Lowercase(Massivedataset.SequenceField) Then
            Continue;
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Begin
             If vTempValue <> Null Then
              Begin
               If Query.Fields[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                Begin
                 {$IFNDEF FPC}
                  {$IF CompilerVersion > 21}Query.Fields[I].AsLargeInt := StrToInt64(vTempValue)
                  {$ELSE} Query.Fields[I].AsInteger                    := StrToInt64(vTempValue)
                  {$IFEND}
                 {$ELSE}
                  Query.Fields[I].AsLargeInt := StrToInt64(vTempValue);
                 {$ENDIF}
                End
               Else
                Query.Fields[I].AsInteger  := StrToInt(vTempValue);
              End;
            End
           Else
            Query.Fields[I].Clear;
          End
         Else If Query.Fields[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle, ftExtended{$IFEND}{$ENDIF}] Then
          Begin
           If (vTempValue <> Null) And
              (Trim(vTempValue) <> 'null') And
              (Trim(vTempValue) <> '') Then
            Query.Fields[I].AsFloat := StrToFloat(BuildFloatString(vTempValue))
           Else
            Query.Fields[I].Clear;
          End
         Else If Query.Fields[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
          Begin
           If (vTempValue <> Null) And
              (Trim(vTempValue) <> 'null') And
              (Trim(vTempValue) <> '') Then
            Query.Fields[I].AsDateTime  := StrToDatetime(vTempValue)
           Else
            Query.Fields[I].Clear;
          End  //Tratar Blobs de Parametros...
         Else If Query.Fields[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                              ftGraphic, ftOraBlob, ftOraClob] Then
          Begin
           Try
            If (vTempValue <> 'null') And
               (vTempValue <> '') Then
             Begin
              vStringStream := Decodeb64Stream(vTempValue);
              vStringStream.Position := 0;
              TBlobfield(Query.Fields[I]).LoadFromStream(vStringStream);
             End
            Else
             Query.Fields[I].Clear;
           Finally
            If Assigned(vStringStream) Then
             FreeAndNil(vStringStream);
           End;
          End
         Else If (vTempValue <> Null) And
                 (Trim(vTempValue) <> 'null') Then
          Begin
           If Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue) Then
            Query.Fields[I].Value := vTempValue;
          End
         Else
          Begin
           If Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue) Then
            Query.Fields[I].Clear;
          End;
        End;
      End;
    End;
  End;
end;

Constructor TRESTDWValueKey.Create;
Begin
 vKeyname      := '';
 vValue        := Null;
 vIsStream     := False;
 vIsNull       := True;
 vObjectValue  := ovUnknown;
 vStreamValue  := Nil;
End;

Function TRESTDWValueKeys.GetRec(Index : Integer) : TRESTDWValueKey;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TRESTDWValueKey(TList(Self).Items[Index]^);
End;

Procedure TRESTDWValueKeys.PutRec(Index : Integer;
                                  Item  : TRESTDWValueKey);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TRESTDWValueKey(TList(Self).Items[Index]^) := Item;
End;

Function TRESTDWValueKeys.GetRecName(Index : String) : TRESTDWValueKey;
Var
 I         : Integer;
Begin
 Result    := Nil;
 If Assigned(Self) And (Lowercase(Index) <> '') Then
  Begin
   For i := 0 To Self.Count - 1 Do
    Begin
     If Uppercase(Index) = Uppercase(TRESTDWValueKey(TList(Self).Items[i]^).vKeyname)Then
      Begin
       Result := TRESTDWValueKey(TList(Self).Items[i]^);
       Break;
      End;
    End;
  End;
End;

Procedure TRESTDWValueKeys.PutRecName(Index : String;
                                      Item  : TRESTDWValueKey);
Var
 I         : Integer;
 vNotFount : Boolean;
Begin
 vNotFount := True;
 If Assigned(Self) And (Lowercase(Index) <> '') Then
  Begin
   For i := 0 To Self.Count - 1 Do
    Begin
     If Lowercase(Index) = Lowercase(TRESTDWValueKey(TList(Self).Items[i]^).vKeyname)  Then
      Begin
       TRESTDWValueKey(TList(Self).Items[i]^) := Item;
       vNotFount := False;
       Break;
      End;
    End;
  End;
 If vNotFount Then
  Begin
   Item         := TRESTDWValueKey.Create;
   Item.Keyname := Index;
   Add(Item);
  End;
End;

Procedure TRESTDWValueKeys.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(i);
 Self.Clear;
End;

Constructor TRESTDWValueKeys.Create;
Begin
 Inherited;
End;

Destructor TRESTDWValueKeys.Destroy;
Begin
 ClearList;
 Inherited;
End;

Procedure TRESTDWValueKeys.Delete(Index : Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index])  Then
    Begin
     {$IFDEF FPC}
     FreeAndNil(TList(Self).Items[Index]^);
     {$ELSE}
      {$IF CompilerVersion > 33}
       FreeAndNil(TRESTDWValueKey(TList(Self).Items[Index]^));
      {$ELSE}
       FreeAndNil(TList(Self).Items[Index]^);
      {$IFEND}
     {$ENDIF}
     {$IFDEF FPC}
      Dispose(PRESTDWValueKey(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Procedure TRESTDWValueKeys.Delete(Index : String);
Var
 I : Integer;
Begin
 For I := 0 To Count -1 Do
  Begin
   If Lowercase(Items[I].vKeyname) = Lowercase(Index) Then
    Begin
     Delete(I);
     Break;
    End;
  End;
End;

Function    TRESTDWValueKeys.BuildKeyNames        : String;
Var
 I : Integer;
Begin
 Result := '';
 For I := 0 To Count -1 Do
  Result := Result + Items[I].vKeyname;
End;

Function    TRESTDWValueKeys.BuildArrayValues     : TArrayData;
Var
 I : Integer;
 Function CreateVariantStream(MS : TMemoryStream) : Variant;
 Var
  P: Pointer;
 Begin
  Result := VarArrayCreate([0, MS.Size-1], varByte);
  If MS.Size > 0 then
   Begin
    P := VarArrayLock(Result);
    MS.ReadBuffer(P^, MS.Size);
    VarArrayUnlock(Result);
   End;
 End;
Begin
 Setlength(Result, Count);
 For I := 0 To Count -1 Do
  Begin
   Result[I] := Null;
   If Items[I].vIsNull Then
    Begin
     If Items[I].vIsStream Then
      Result[I] := CreateVariantStream(Items[I].vStreamValue)
     Else
      Result[I] := Items[I].vValue;
    End;
  End;
End;

Function TRESTDWValueKeys.Add(Item : TRESTDWValueKey) : Integer;
Var
 vItem : ^TRESTDWValueKey;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Constructor TRESTDWDriver.Create(AOwner: TComponent);
Begin
 Inherited;
 vEncodeStrings       := True;
 {$IFDEF FPC}
 vDatabaseCharSet     := csUndefined;
 {$ENDIF}
 vCommitRecords       := 100;
 vOnTableBeforeOpen   := Nil;
 vOnPrepareConnection := Nil;
 vParamCreate         := False;
 vStrsTrim            := vParamCreate;
 vStrsEmpty2Null      := vParamCreate;
 vStrsTrim2Len        := vParamCreate;
 vEncodeStrings       := vParamCreate;
 vCompression         := vParamCreate;
End;

end.

