        ��  ��                  t  8   ��
 R D W C G I S R V F R M         0         object %0:s: T%0:s
  OldCreateOrder = False
  OnCreate = WebModuleCreate
  Actions = <
    item
      Default = True
      Name = 'DefaultHandler'
      PathInfo = '/'
      OnAction = dwCGIServiceDefaultHandlerAction
    end>
  Height = 240
  Width = 290
  object RESTServiceCGI1: TRESTServiceCGI
    CORS = False
    CORS_CustomHeaders.Strings = (
      'Access-Control-Allow-Origin=*'
      
        'Access-Control-Allow-Methods=GET, POST, PATCH, PUT, DELETE, OPTI' +
        'ONS'
      
        'Access-Control-Allow-Headers=Content-Type, Origin, Accept, Autho' +
        'rization, X-CUSTOM-HEADER')
    ServerParams.HasAuthentication = True
    ServerParams.UserName = 'testserver'
    ServerParams.Password = 'testserver'
    Encoding = esUtf8
    ForceWelcomeAccess = False
    ServerContext = 'restdataware'
    RootPath = '/'
    CriptOptions.Use = False
    CriptOptions.Key = 'RDWBASEKEY256'
    TokenOptions.Active = False
    TokenOptions.ServerRequest = 'RESTDWServer01'
    TokenOptions.TokenHash = 'RDWTS_HASH'
    TokenOptions.LifeCycle = 30
    Left = 120
    Top = 112
  end
end
  8   ��
 R D W C G I S R V U N I T       0         unit %0:s;

// Cria��o de Exemplo usando CGI para Apache Server feito por "Gilberto Rocha da Silva",
//para uso do Componente TRESTServiceCGI

interface

uses
  SysUtils, Classes, HTTPApp, WSDLPub, SOAPPasInv, SOAPHTTPPasInv,
  SOAPHTTPDisp, WebBrokerSOAP, Soap.InvokeRegistry, Soap.WSDLIntf,
  System.TypInfo, Soap.WebServExp, Soap.WSDLBind, Xml.XMLSchema,
  uRESTDWBase, uDWAbout,%4:s;

type
  T%1:s = class(%2:s)
    RESTServiceCGI1: TRESTServiceCGI;
    procedure dwCGIServiceDefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  %1:s: T%1:s;

implementation

uses WebReq;

{$R *.dfm}


procedure T%1:s.dwCGIServiceDefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
 If RESTServiceCGI1 <> Nil Then
  RESTServiceCGI1.Command(Request, Response, Handled);
end;

procedure T%1:s.WebModuleCreate(Sender: TObject);
begin
 RESTServiceCGI1.RootPath := '.\';
 RESTServiceCGI1.ServerMethodClass := T%3:s;
end;

initialization
  WebRequestHandler.WebModuleClass := T%1:s;

end.
S+  <   ��
 R D W C G I D A T A M F R M         0         object %0:s: T%0:s
  OldCreateOrder = False
  Encoding = esUtf8
  Height = 178
  Width = 264
  object RESTDWPoolerDB1: TRESTDWPoolerDB
    Compression = True
    Encoding = esUtf8
    StrsTrim = False
    StrsEmpty2Null = False
    StrsTrim2Len = True
    Active = True
    PoolerOffMessage = 'RESTPooler not active.'
    ParamCreate = True
    Left = 44
    Top = 119
  end
  object DWServerEvents1: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crAll]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odOUT
            ObjectValue = ovDateTime
            ParamName = 'result'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'inputdata'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odINOUT
            ObjectValue = ovString
            ParamName = 'resultstring'
            Encoded = False
          end>
        JsonMode = jmDataware
        Name = 'servertime'
        OnReplyEvent = DWServerEvents1EventsservertimeReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'entrada'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'helloworld'
        OnReplyEvent = DWServerEvents1EventshelloworldReplyEvent
      end>
    ContextName = 'se1'
    Left = 80
    Top = 31
  end
  object DWServerContext1: TDWServerContext
    IgnoreInvalidParams = False
    ContextList = <
      item
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'entrada'
            Encoded = True
          end>
        ContentType = 'text/html'
        ContextName = 'init'
        Routes = [crAll]
        IgnoreBaseHeader = False
        OnReplyRequest = DWServerContext1ContextListinitReplyRequest
      end
      item
        DWParams = <>
        ContentType = 'text/html'
        ContextName = 'openfile'
        Routes = [crAll]
        IgnoreBaseHeader = False
      end
      item
        DWParams = <>
        ContentType = 'text/html'
        ContextName = 'webpascal'
        DefaultHtml.Strings = (
          '<!DOCTYPE html>'
          '<html lang="pt-br">'
          '<head>'
          '    <meta charset="UTF-8">'
          ''
          
            '    <meta http-equiv="Content-Type" content="text/html; charset=' +
            'UTF-8">'
          
            '    <meta name="viewport" content="width=device-width, initial-s' +
            'cale=1, shrink-to-fit=no">'
          
            '    <meta name="description" content="Consumindo servidor RestDa' +
            'taware">'
          '    <link rel="icon" href="img/browser.ico">'
          ''
          
            '    <link rel="alternate" type="application/rss+xml" title="RSS ' +
            '2.0" href="http://www.datatables.net/rss.xml">'
          
            '    <link rel="stylesheet" type="text/css" href="https://cdnjs.c' +
            'loudflare.com/ajax/libs/twitter-bootstrap/4.1.1/css/bootstrap.cs' +
            's">'
          
            '    <link rel="stylesheet" type="text/css" href="https://cdn.dat' +
            'atables.net/1.10.19/css/dataTables.bootstrap4.min.css">'
          ''
          ''
          
            '    <script type="text/javascript" language="javascript" src="ht' +
            'tps://code.jquery.com/jquery-3.3.1.js"></script>'
          
            '    <script type="text/javascript" language="javascript" src="ht' +
            'tps://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js"></' +
            'script>'
          
            '    <script type="text/javascript" language="javascript" src="ht' +
            'tps://cdn.datatables.net/1.10.19/js/dataTables.bootstrap4.min.js' +
            '"></script>'
          ''
          '    {%%labeltitle%%}'
          ''
          
            '    <link rel="stylesheet" type="text/css" href="//cdn.datatable' +
            's.net/1.10.15/css/jquery.dataTables.css">'
          ''
          '</head>'
          '<body>'
          ''
          '    {%%navbar%%}'
          '    {%%datatable%%}'
          '    {%%incscripts%%} '
          '</body>'
          '</html>')
        Routes = [crAll]
        ContextRules = dwcrEmployee
        IgnoreBaseHeader = False
      end>
    BaseContext = 'www'
    RootContext = 'webpascal'
    Left = 152
    Top = 24
  end
  object dwcrEmployee: TDWContextRules
    ContentType = 'text/html'
    MasterHtml.Strings = (
      '<!DOCTYPE html>'
      '<html lang="pt-br">'
      '<head>'
      '    <meta charset="UTF-8">'
      ''
      
        '    <meta http-equiv="Content-Type" content="text/html; charset=' +
        'UTF-8">'
      
        '    <meta name="viewport" content="width=device-width, initial-s' +
        'cale=1, shrink-to-fit=no">'
      
        '    <meta name="description" content="Consumindo servidor RestDa' +
        'taware">'
      '    <link rel="icon" href="img/browser.ico">'
      ''
      
        '    <link rel="alternate" type="application/rss+xml" title="RSS ' +
        '2.0" href="http://www.datatables.net/rss.xml">'
      
        '    <link rel="stylesheet" type="text/css" href="https://cdnjs.c' +
        'loudflare.com/ajax/libs/twitter-bootstrap/4.1.1/css/bootstrap.cs' +
        's">'
      
        '    <link rel="stylesheet" type="text/css" href="https://cdn.dat' +
        'atables.net/1.10.19/css/dataTables.bootstrap4.min.css">'
      ''
      ''
      
        '    <script type="text/javascript" language="javascript" src="ht' +
        'tps://code.jquery.com/jquery-3.3.1.js"></script>'
      
        '    <script type="text/javascript" language="javascript" src="ht' +
        'tps://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js"></' +
        'script>'
      
        '    <script type="text/javascript" language="javascript" src="ht' +
        'tps://cdn.datatables.net/1.10.19/js/dataTables.bootstrap4.min.js' +
        '"></script>'
      ''
      '    {%%labeltitle%%}'
      ''
      
        '    <link rel="stylesheet" type="text/css" href="//cdn.datatable' +
        's.net/1.10.15/css/jquery.dataTables.css">'
      ''
      '</head>'
      '<body>'
      '    {%%navbar%%}'
      '    {%%datatable%%}'
      '    {%%incscripts%%} '
      '</body>'
      '</html>')
    MasterHtmlTag = '$body'
    IncludeScripts.Strings = (
      '<script src="https://code.jquery.com/jquery-1.12.4.js"></script>'
      
        '    <script src="https://cdn.datatables.net/1.10.16/js/jquery.da' +
        'taTables.min.js"></script>'
      '    <script type="text/javascript">'
      '        $(document).ready(function () {'
      
        '            var datatable = $('#39'#my-table'#39').DataTable({ //dataTab' +
        'le tamb'#233'm funcionar'
      
        '                dom: "Bfrtip", // Use dom: '#39'Blfrtip'#39', para fazer' +
        ' o seletor "por p'#225'gina" aparecer.'
      '                ajax: {'
      '                    url: window.location + '#39'?dwmark:datatable'#39','
      '                    type: '#39'GET'#39','
      
        '                    '#39'beforeSend'#39': function (request) {request.se' +
        'tRequestHeader("content-type","application/x-www-form-urlencoded' +
        '; charset=UTF-8");},'
      '                    dataSrc: '#39#39'},'
      '                stateSave: true,'
      '                columns: ['
      '                    {title: '#39'CODIGO'#39', data: '#39'EMP_NO'#39'},'
      '                    {title: '#39'NOME'#39', data: '#39'FIRST_NAME'#39'},'
      '                    {title: '#39'SOBRENOME'#39', data: '#39'LAST_NAME'#39'},'
      '                    {title: '#39'TELEFONE'#39', data: '#39'PHONE_EXT'#39'},'
      '                    {title: '#39'DATA'#39', data: '#39'HIRE_DATE'#39'},'
      '                    {title: '#39'DEPARTAMENTO'#39', data: '#39'DEPT_NO'#39'},'
      '                    {title: '#39'CARGO'#39', data: '#39'JOB_CODE'#39'},'
      '                    {title: '#39'CARGO/ID'#39', data: '#39'JOB_GRADE'#39'},'
      
        '                    {title: '#39'EMPREGO/PAIS'#39', data: '#39'JOB_COUNTRY'#39'}' +
        ','
      '                    {title: '#39'SALARIO'#39', data: '#39'SALARY'#39'},'
      '                    {title: '#39'NOME COMPLETO'#39', data: '#39'FULL_NAME'#39'},'
      '                ],'
      '            });'
      '            console.log(datatable);'
      '        });'
      '    </script>')
    IncludeScriptsHtmlTag = '{%%incscripts%%}'
    Items = <
      item
        ContextTag = '<title>Consumindo servidor RestDataware</title>'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'labeltitle'
        TagReplace = '{%%labeltitle%%}'
        ObjectName = 'labeltitle'
      end
      item
        ContextTag = 
          '<nav class="navbar navbar-dark sticky-top bg-dark flex-md-nowrap' +
          ' p-0">'#13#10'        <a class="navbar-brand col-sm-3 col-md-2 mr-0" h' +
          'ref="index.html">'#13#10'            <img src="imgs/logodw.png" alt="R' +
          'EST DATAWARE" title="REST DATAWARE"/>'#13#10'        </a>'#13#10'        <h4' +
          ' style="color: #fff">Consumindo API REST (RDW) com Javascript</h' +
          '4>'#13#10'    </nav>'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'navbar'
        TagReplace = '{%%navbar%%}'
        ObjectName = 'navbar'
      end
      item
        ContextTag = 
          '<main role="main" class="col-md-9 ml-sm-auto col-lg-12 pt-3 px-4' +
          '">'#13#10'        <div class="d-flex justify-content-between flex-wrap' +
          ' flex-md-nowrap align-pessoas-center pb-2 mb-3 border-bottom">'#13#10 +
          '            <h5 class="">Listagem de EMPREGADOS </h5>'#13#10'        <' +
          '/div>'#13#10'    </main>'#13#10#13#10'    <div class="col-xs-12 col-sm-12 col-md' +
          '-12 col-lg-12">'#13#10'        <div id="data-table_wrapper" class="dat' +
          'aTables_wrapper form-inline dt-bootstrap no-footer">'#13#10'          ' +
          '  <table id="my-table" class="display"></table>'#13#10'        </div>'#13 +
          #10'    </div>'
        TypeItem = 'text'
        ClassItem = 'form-control item'
        TagID = 'datatable'
        TagReplace = '{%%datatable%%}'
        ObjectName = 'datatable'
      end>
    Left = 173
    Top = 81
  end
end
 =  <   ��
 R D W C G I D A T A M U N I T       0         Unit %0:s;

Interface

Uses
  Sysutils,
  Classes,
  Systypes,
  Udwdatamodule,
  Udwmassivebuffer,
  System.Json,
  Udwjsonobject,
  Serverutils,
  Udwconstsdata,
  Urestdwpoolerdb,
  Udwconsts, Urestdwserverevents, Udwabout, Urestdwservercontext;

Type
  T%1:s = class(%2:s)
    Restdwpoolerdb1: Trestdwpoolerdb;
    Dwservercontext1: Tdwservercontext;
    Dwcremployee: Tdwcontextrules;
    Procedure Dwserverevents1eventsservertimereplyevent(Var Params: Tdwparams;
      Var Result: String);
    Procedure Dwserverevents1eventshelloworldreplyevent(Var Params: Tdwparams;
      Var Result: String);
    Procedure Dwservercontext1contextlistopenfilereplyrequeststream(
      Const Params: Tdwparams; Var Contenttype: String;
      Var Result: Tmemorystream; Const Requesttype: Trequesttype);
    Procedure Dwservercontext1contextlistinitreplyrequest(
      Const Params: Tdwparams; Var Contenttype, Result: String;
      Const Requesttype: Trequesttype);
  Private
    { private declarations }
    Vidvenda: Integer;
    Function Consultabanco(Var Params: Tdwparams): String; Overload;
  Public
    { public declarations }
  End;

Var
  %1:s: T%1:s;

Implementation

{%%classgroup 'vcl.controls.tcontrol'}
{$R *.dfm}

Uses Udwjsontools;

Function T%1:s.Consultabanco(Var Params: Tdwparams): String;
Begin

End;

Procedure T%1:s.Dwservercontext1contextlistinitreplyrequest(
  Const Params: Tdwparams; Var Contenttype, Result: String;
  Const Requesttype: Trequesttype);
Begin
  Result := '<!DOCTYPE html> ' +
    '<html>' +
    '  <head>' +
    '    <meta charset="utf-8">' +
    '    <title>My test page</title>' +
    '    <link href=''http://fonts.googleapis.com/css?family=Open+Sans'' rel=''stylesheet'' type=''text/css''>' +
    '  </head>' +
    '  <body>' +
    '    <h1>REST Dataware is cool</h1>' +
    '    <img src="http://www.resteasyobjects.com.br/myimages/LogoDW.png" alt="The REST Dataware logo: Powerfull Web Service.">' +
    '  ' +
    '  ' +
    '    <p>working together to keep the Internet alive and accessible, help us to help you. Be free.</p>' +
    ' ' +
    '    <p><a href="http://www.restdw.com.br/">REST Dataware site</a> to learn and help us.</p>' +
    '  </body>' +
    '</html>';
End;

Procedure T%1:s.Dwservercontext1contextlistopenfilereplyrequeststream(
  Const Params: Tdwparams; Var Contenttype: String; Var Result: Tmemorystream;
  Const Requesttype: Trequesttype);
Var
  Vnotfound: Boolean;
  Vfilename: String;
  Vstringstream: Tstringstream;
Begin
  Vnotfound := True;
  Result := Tmemorystream.Create;
  If Params.Itemsstring['filename'] <> Nil Then
  Begin
    Vfilename := '.\www\' + Decodestrings(Params.Itemsstring['filename'].Asstring);
    Vnotfound := Not Fileexists(Vfilename);
    If Not Vnotfound Then
    Begin
      Try
        Result.Loadfromfile(Vfilename);
        Contenttype := Getmimetype(Vfilename);
      Finally
      End;
    End;
  End;
  If Vnotfound Then
  Begin
    Vstringstream := Tstringstream.Create('<!DOCTYPE html> ' +
      '<html>' +
      '  <head>' +
      '    <meta charset="utf-8">' +
      '    <title>My test page</title>' +
      '    <link href=''http://fonts.googleapis.com/css?family=Open+Sans'' rel=''stylesheet'' type=''text/css''>' +
      '  </head>' +
      '  <body>' +
      '    <h1>REST Dataware</h1>' +
      '    <img src="http://www.resteasyobjects.com.br/myimages/LogoDW.png" alt="The REST Dataware logo: Powerfull Web Service.">' +
      '  ' +
      '  ' +
      '    <p>File not Found.</p>' +
      '  </body>' +
      '</html>');
    Try
      Vstringstream.Position := 0;
      Result.Copyfrom(Vstringstream, Vstringstream.Size);
    Finally
      Vstringstream.Free;
    End;
  End;
End;

Procedure T%1:s.Dwserverevents1eventshelloworldreplyevent(
  Var Params: Tdwparams; Var Result: String);
Begin
  Result := Format('{"Message":"%%s"}', [Params.Itemsstring['entrada'].Asstring]);
End;

Procedure T%1:s.Dwserverevents1eventsservertimereplyevent(
  Var Params: Tdwparams; Var Result: String);
Begin
  If Params.Itemsstring['inputdata'].Asstring <> '' Then //servertime
    Params.Itemsstring['result'].Asdatetime := Now
  Else
    Params.Itemsstring['result'].Asdatetime := Now - 1;
  Params.Itemsstring['resultstring'].Asstring := 'testservice';
End;

End.

   N� 0   ��
 R D W S R V F R M       0         object %0:s: T%0:s
  Left = 538
  Top = 155
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'REST Dataware CORE - Simple Server'
  ClientHeight = 600
  ClientWidth = 640
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label8: TLabel
    Left = 8
    Top = 15
    Width = 3
    Height = 13
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Bevel3: TBevel
    Left = 13
    Top = 341
    Width = 496
    Height = 2
    Shape = bsTopLine
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 58
    Width = 640
    Height = 505
    ActivePage = tsConfigs
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object tsConfigs: TTabSheet
      Caption = 'Configuration'
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 632
        Height = 473
        Align = alClient
        BevelOuter = bvNone
        ParentBackground = False
        TabOrder = 0
        DesignSize = (
          632
          473)
        object Label1: TLabel
          Left = 9
          Top = 37
          Width = 31
          Height = 17
          Caption = 'Porta'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object Label2: TLabel
          Left = 63
          Top = 37
          Width = 45
          Height = 17
          Caption = 'Usu'#225'rio'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object Label3: TLabel
          Left = 176
          Top = 37
          Width = 35
          Height = 17
          Caption = 'Senha'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object labPorta: TLabel
          Left = 292
          Top = 203
          Width = 24
          Height = 17
          Caption = 'Port'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object labUsuario: TLabel
          Left = 347
          Top = 203
          Width = 27
          Height = 17
          Caption = 'User'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object labSenha: TLabel
          Left = 459
          Top = 203
          Width = 56
          Height = 17
          Caption = 'Password'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lbPasta: TLabel
          Left = 7
          Top = 259
          Width = 37
          Height = 17
          Caption = 'Folder'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object labNomeBD: TLabel
          Left = 459
          Top = 259
          Width = 55
          Height = 17
          Caption = 'BD Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object Label14: TLabel
          Left = 7
          Top = 142
          Width = 35
          Height = 17
          Caption = 'Driver'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object Label5: TLabel
          Left = 7
          Top = 201
          Width = 10
          Height = 17
          Caption = 'IP'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object Label6: TLabel
          Left = 0
          Top = 456
          Width = 632
          Height = 17
          Align = alBottom
          Alignment = taCenter
          AutoSize = False
          Caption = 
            'OBS.: A porta do servidor RestDW deve estar adicionada nas regra' +
            's do FIREWALL'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clMaroon
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label15: TLabel
          Left = 7
          Top = 357
          Width = 87
          Height = 17
          Anchors = [akLeft, akBottom]
          Caption = 'Private Key File'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object Label16: TLabel
          Left = 458
          Top = 357
          Width = 124
          Height = 17
          Anchors = [akLeft, akBottom]
          Caption = 'Private Key Password'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object Label17: TLabel
          Left = 7
          Top = 410
          Width = 50
          Height = 17
          Anchors = [akLeft, akBottom]
          Caption = 'Cert. File'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object labConexao: TLabel
          Left = 0
          Top = 0
          Width = 632
          Height = 23
          Align = alTop
          AutoSize = False
          Caption = ' .: SERVER CONFIGURATION'
          Color = clGrayText
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -16
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          Transparent = False
          Layout = tlCenter
        end
        object Label7: TLabel
          Left = 292
          Top = 37
          Width = 35
          Height = 17
          Caption = 'Extras'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object labDBConfig: TLabel
          Left = 1
          Top = 107
          Width = 734
          Height = 23
          AutoSize = False
          Caption = ' .: DATABASE CONFIGURATION'
          Color = clGrayText
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -16
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          Transparent = False
          Layout = tlCenter
        end
        object labSSL: TLabel
          Left = 1
          Top = 327
          Width = 734
          Height = 23
          AutoSize = False
          Caption = ' .: SSL CONFIGURATION'
          Color = clGrayText
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -16
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          Transparent = False
          Layout = tlCenter
        end
        object labVersao: TLabel
          Left = 297
          Top = 3
          Width = 312
          Height = 23
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Vers'#227'o'
          Color = clGrayText
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'Consolas'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          Transparent = True
          Layout = tlCenter
        end
        object Panel4: TPanel
          Left = 694
          Top = 10
          Width = 59
          Height = 37
          Anchors = [akTop, akRight]
          BevelOuter = bvNone
          Caption = 'paPortugues'
          Color = 2763306
          ParentBackground = False
          TabOrder = 0
          object Image8: TImage
            Left = 4
            Top = 0
            Width = 55
            Height = 37
            Cursor = crHandPoint
            Align = alRight
            AutoSize = True
            Center = True
            Picture.Data = {
              0A544A504547496D616765262F0000FFD8FFE107424578696600004D4D002A00
              0000080007011200030000000100010000011A00050000000100000062011B00
              05000000010000006A0128000300000001000200000131000200000022000000
              720132000200000014000000948769000400000001000000A8000000D4000AFC
              8000002710000AFC800000271041646F62652050686F746F73686F7020434320
              32303138202857696E646F77732900323031383A30383A30332030383A30343A
              3331000003A001000300000001FFFF0000A00200040000000100000037A00300
              0400000001000000210000000000000006010300030000000100060000011A00
              050000000100000122011B0005000000010000012A0128000300000001000200
              0002010004000000010000013202020004000000010000060800000000000000
              48000000010000004800000001FFD8FFED000C41646F62655F434D0002FFEE00
              0E41646F626500648000000001FFDB0084000C08080809080C09090C110B0A0B
              11150F0C0C0F1518131315131318110C0C0C0C0C0C110C0C0C0C0C0C0C0C0C0C
              0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C010D0B0B0D0E0D100E0E10140E0E
              0E14140E0E0E0E14110C0C0C0C0C11110C0C0C0C0C0C110C0C0C0C0C0C0C0C0C
              0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0CFFC00011080021003703012200
              021101031101FFDD00040004FFC4013F00000105010101010101000000000000
              00030001020405060708090A0B01000105010101010101000000000000000100
              02030405060708090A0B1000010401030204020507060805030C330100021103
              04211231054151611322718132061491A1B14223241552C16233347282D14307
              259253F0E1F163733516A2B283264493546445C2A3743617D255E265F2B384C3
              D375E3F3462794A485B495C4D4E4F4A5B5C5D5E5F55666768696A6B6C6D6E6F6
              37475767778797A7B7C7D7E7F711000202010204040304050607070605350100
              021103213112044151617122130532819114A1B14223C152D1F0332462E17282
              92435315637334F1250616A2B283072635C2D2449354A317644555367465E2F2
              B384C3D375E3F34694A485B495C4D4E4F4A5B5C5D5E5F55666768696A6B6C6D6
              E6F62737475767778797A7B7C7FFDA000C03010002110311003F00C1AF2F0B39
              829BDADADFF9AC718649FF00B8F77B9D8EEFF82B3F5755B2FA5DF4EE75736319
              AB9B116307FC257FBBFF000ACFD1A5FB0BAD7FE57E47FDB4FF00FC8ABB898DF5
              868DACB3A7E4DB533E80F4DED7B3CE8B76EEAFFA9FCDAD638FD9B972D38F0F5C
              1397EACFFB397F9392C19E3CC011E7212E2DA3CCC07EBA3FEDA3FE5A3FF3DC4E
              472BA8B3FA43FF00F4DA3FF3C2067743B2DC7394FA2DC61C3AE7566B009ED934
              7F83FF008FC7FD1AB0F0C766BEB1657AE0FA5BF70D9BBD1D91EA7F5952F88737
              8F2C308F9270CB1E384B787FDF41D2F85723970CF99901EE639F2D9863C98F58
              48F0FCBFBD19FF0051E58111CFC55EC4E9775DB5D6CD4C7EB5B409B1FF00F155
              7EEFFC2D9FA35A783D11F5D032ABA2CCA8302F6D4EB06E1DB1688FD27FC75FFA
              241CBC7FAC378732AE9F95556FFA67D37BAC7FFC7DDB773FFA8DFD12BB2E6CE6
              261CB9888ED2CF93E4FF00A943FCA39C392C7CB8E2E6EE53FD1E5B1FF39FF569
              FF0092FF00D28A75B814460D6371B4863EBA9E00126272330FF3B637F719FABD
              692A5FB0BADFFE57E47FDB4FFF00C8A487DD306FEE9F7B7F7F8FF59FF7BC3FD4
              57FA473DF0FB51FBBEDF76E0FD4D7FD2E3FF0059C4FF00FFD0C2FB5F44FF004B
              99FF006D57FF00BD29C65F4424016E649E22AAFF00F7A567E2E05F932F115D2D
              30EB9FA341FDD1F9D659FC8AD696EC1E943DBBBD7FDED3D63FF54CC1AFFCFC95
              732F23C840F0471CB2653B63848F17F85FB8DDC1F16F8B648FB92CF1C5806F97
              242023E50F4FEB27FDC6CDB858828739965EDBC09F46E631BB5BFE9321CDBACF
              41BFC97FE9104F4E70C8341B5800ABD7F5752CDBB3D6F0DDF47F92B272B36FC9
              1B4C32A065B5374683FBC7F7DFFCB7AE82DFE90FFF00D368FF00CF0A9737F0D8
              E28E39CBD32CB9230E089D2103FD63F33A5C87C73366966C712671C383266197
              20889E4C901E9F443D3087F5515385886905F65EEBF914D2D63B737F7F1DEFBA
              A6DFFD56FBD55395D10120D99808D0835573FF00B72B3B1736EC71B443EA265D
              53B5693FBCDFDC7FFC2316987E17546C59B8DC07223D76FF00D4B33ABFFD9856
              4FC331603FADC72CB8BFCEE332E3C7FED31FFDEB4C7C739BE647EA738C39FAE1
              C821ED64FF00639651FF0099918FDAFA1FFA5CCFFB6ABFFDE94952B7A5DD4BD9
              2E6BB1EC7060C964B9809FDF6FF395BFFE09E929FF00D1FF000DE0F734E0EFC6
              D4FF004C7C67DDF678A5EEEDC1EDC78FECE17FFFD1A98FFF00793FF127F295CB
              59FCE3FF00AC7F2AE7925A3F0FFF0074733FDE0CDF13FF0072723FECDE81DFC1
              7516FF00487FFE9B47FEDBAF37490F8B6D83FDAC11F01F9B9BFF00CE5CBFF45E
              814E9FE759FD71F9573892D497CB2F27186FF57D4B0FFE54CEFEAB3FEA9892F2
              D49731FA1FF56FFBA7B4FF002FFF00A67FF72FFFD9FFED0F6A50686F746F7368
              6F7020332E30003842494D042500000000001000000000000000000000000000
              0000003842494D043A0000000000F9000000100000000100000000000B707269
              6E744F7574707574000000050000000050737453626F6F6C0100000000496E74
              65656E756D00000000496E746500000000496D67200000000F7072696E745369
              787465656E426974626F6F6C000000000B7072696E7465724E616D6554455854
              0000000100000000000F7072696E7450726F6F6653657475704F626A63000000
              160043006F006E00660069006700750072006100E700E3006F00200064006500
              2000500072006F0076006100000000000A70726F6F6653657475700000000100
              000000426C746E656E756D0000000C6275696C74696E50726F6F660000000970
              726F6F66434D594B003842494D043B00000000022D0000001000000001000000
              0000127072696E744F75747075744F7074696F6E730000001700000000437074
              6E626F6F6C0000000000436C6272626F6F6C00000000005267734D626F6F6C00
              0000000043726E43626F6F6C0000000000436E7443626F6F6C00000000004C62
              6C73626F6F6C00000000004E677476626F6F6C0000000000456D6C44626F6F6C
              0000000000496E7472626F6F6C000000000042636B674F626A63000000010000
              0000000052474243000000030000000052642020646F7562406FE00000000000
              0000000047726E20646F7562406FE0000000000000000000426C2020646F7562
              406FE000000000000000000042726454556E744623526C740000000000000000
              00000000426C6420556E744623526C7400000000000000000000000052736C74
              556E74462350786C40520000000000000000000A766563746F7244617461626F
              6F6C010000000050675073656E756D0000000050675073000000005067504300
              0000004C656674556E744623526C74000000000000000000000000546F702055
              6E744623526C7400000000000000000000000053636C20556E74462350726340
              590000000000000000001063726F705768656E5072696E74696E67626F6F6C00
              0000000E63726F7052656374426F74746F6D6C6F6E67000000000000000C6372
              6F70526563744C6566746C6F6E67000000000000000D63726F70526563745269
              6768746C6F6E67000000000000000B63726F7052656374546F706C6F6E670000
              0000003842494D03ED0000000000100048000000010001004800000001000138
              42494D042600000000000E000000000000000000003F8000003842494D040D00
              00000000040000005A3842494D04190000000000040000001E3842494D03F300
              0000000009000000000000000001003842494D271000000000000A0001000000
              00000000013842494D03F5000000000048002F66660001006C66660006000000
              000001002F6666000100A1999A0006000000000001003200000001005A000000
              06000000000001003500000001002D000000060000000000013842494D03F800
              00000000700000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF03E800
              000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF03E800000000FF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF03E800000000FFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF03E800003842494D04000000000000
              0200023842494D04020000000000060000000000003842494D04300000000000
              03010101003842494D042D0000000000060001000000033842494D0408000000
              000010000000010000024000000240000000003842494D041E00000000000400
              0000003842494D041A00000000034D0000000600000000000000000000002100
              0000370000000C00530065006D0020005400ED00740075006C006F002D003200
              0000010000000000000000000000000000000000000001000000000000000000
              0000370000002100000000000000000000000000000000010000000000000000
              000000000000000000000010000000010000000000006E756C6C000000020000
              0006626F756E64734F626A630000000100000000000052637431000000040000
              0000546F70206C6F6E6700000000000000004C6566746C6F6E67000000000000
              000042746F6D6C6F6E670000002100000000526768746C6F6E67000000370000
              0006736C69636573566C4C73000000014F626A6300000001000000000005736C
              6963650000001200000007736C69636549446C6F6E6700000000000000076772
              6F757049446C6F6E6700000000000000066F726967696E656E756D0000000C45
              536C6963654F726967696E0000000D6175746F47656E65726174656400000000
              54797065656E756D0000000A45536C6963655479706500000000496D67200000
              0006626F756E64734F626A630000000100000000000052637431000000040000
              0000546F70206C6F6E6700000000000000004C6566746C6F6E67000000000000
              000042746F6D6C6F6E670000002100000000526768746C6F6E67000000370000
              000375726C54455854000000010000000000006E756C6C544558540000000100
              00000000004D7367655445585400000001000000000006616C74546167544558
              540000000100000000000E63656C6C54657874497348544D4C626F6F6C010000
              000863656C6C546578745445585400000001000000000009686F727A416C6967
              6E656E756D0000000F45536C696365486F727A416C69676E0000000764656661
              756C740000000976657274416C69676E656E756D0000000F45536C6963655665
              7274416C69676E0000000764656661756C740000000B6267436F6C6F72547970
              65656E756D0000001145536C6963654247436F6C6F7254797065000000004E6F
              6E6500000009746F704F75747365746C6F6E67000000000000000A6C6566744F
              75747365746C6F6E67000000000000000C626F74746F6D4F75747365746C6F6E
              67000000000000000B72696768744F75747365746C6F6E670000000000384249
              4D042800000000000C000000023FF00000000000003842494D04110000000000
              0101003842494D0414000000000004000000033842494D040C00000000062400
              0000010000003700000021000000A8000015A80000060800180001FFD8FFED00
              0C41646F62655F434D0002FFEE000E41646F626500648000000001FFDB008400
              0C08080809080C09090C110B0A0B11150F0C0C0F1518131315131318110C0C0C
              0C0C0C110C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C
              010D0B0B0D0E0D100E0E10140E0E0E14140E0E0E0E14110C0C0C0C0C11110C0C
              0C0C0C0C110C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C
              0CFFC00011080021003703012200021101031101FFDD00040004FFC4013F0000
              010501010101010100000000000000030001020405060708090A0B0100010501
              010101010100000000000000010002030405060708090A0B1000010401030204
              020507060805030C33010002110304211231054151611322718132061491A1B1
              4223241552C16233347282D14307259253F0E1F163733516A2B2832644935464
              45C2A3743617D255E265F2B384C3D375E3F3462794A485B495C4D4E4F4A5B5C5
              D5E5F55666768696A6B6C6D6E6F637475767778797A7B7C7D7E7F71100020201
              0204040304050607070605350100021103213112044151617122130532819114
              A1B14223C152D1F0332462E1728292435315637334F1250616A2B283072635C2
              D2449354A317644555367465E2F2B384C3D375E3F34694A485B495C4D4E4F4A5
              B5C5D5E5F55666768696A6B6C6D6E6F62737475767778797A7B7C7FFDA000C03
              010002110311003F00C1AF2F0B39829BDADADFF9AC718649FF00B8F77B9D8EEF
              F82B3F5755B2FA5DF4EE75736319AB9B116307FC257FBBFF000ACFD1A5FB0BAD
              7FE57E47FDB4FF00FC8ABB898DF5868DACB3A7E4DB533E80F4DED7B3CE8B76EE
              AFFA9FCDAD638FD9B972D38F0F5C1397EACFFB397F9392C19E3CC011E7212E2D
              A3CCC07EBA3FEDA3FE5A3FF3DC4E472BA8B3FA43FF00F4DA3FF3C2067743B2DC
              7394FA2DC61C3AE7566B009ED9347F83FF008FC7FD1AB0F0C766BEB1657AE0FA
              5BF70D9BBD1D91EA7F5952F887378F2C308F9270CB1E384B787FDF41D2F85723
              970CF99901EE639F2D9863C98F5848F0FCBFBD19FF0051E58111CFC55EC4E977
              5DB5D6CD4C7EB5B409B1FF00F1557EEFFC2D9FA35A783D11F5D032ABA2CCA830
              2F6D4EB06E1DB1688FD27FC75FFA241CBC7FAC378732AE9F95556FFA67D37BAC
              7FFC7DDB773FFA8DFD12BB2E6CE6261CB9888ED2CF93E4FF00A943FCA39C392C
              7CB8E2E6EE53FD1E5B1FF39FF569FF0092FF00D28A75B814460D6371B4863EBA
              9E00126272330FF3B637F719FABD692A5FB0BADFFE57E47FDB4FFF00C8A487DD
              306FEE9F7B7F7F8FF59FF7BC3FD457FA473DF0FB51FBBEDF76E0FD4D7FD2E3FF
              0059C4FF00FFD0C2FB5F44FF004B99FF006D57FF00BD29C65F4424016E649E22
              AAFF00F7A567E2E05F932F115D2D30EB9FA341FDD1F9D659FC8AD696EC1E943D
              BBBD7FDED3D63FF54CC1AFFCFC95732F23C840F0471CB2653B63848F17F85FB8
              DDC1F16F8B648FB92CF1C5806F97242023E50F4FEB27FDC6CDB858828739965E
              DBC09F46E631BB5BFE9321CDBACF41BFC97FE9104F4E70C8341B5800ABD7F575
              2CDBB3D6F0DDF47F92B272B36FC91B4C32A065B5374683FBC7F7DFFCB7AE82DF
              E90FFF00D368FF00CF0A9737F0D8E28E39CBD32CB9230E089D2103FD63F33A5C
              87C73366966C712671C38326619720889E4C901E9F443D3087F5515385886905
              F65EEBF914D2D63B737F7F1DEFBAA6DFFD56FBD55395D10120D99808D0835573
              FF00B72B3B1736EC71B443EA265D53B5693FBCDFDC7FFC2316987E17546C59B8
              DC07223D76FF00D4B33ABFFD98564FC331603FADC72CB8BFCEE332E3C7FED31F
              FDEB4C7C739BE647EA738C39FAE1C821ED64FF00639651FF0099918FDAFA1FFA
              5CCFFB6ABFFDE94952B7A5DD4BD92E6BB1EC7060C964B9809FDF6FF395BFFE09
              E929FF00D1FF000DE0F734E0EFC6D4FF004C7C67DDF678A5EEEDC1EDC78FECE1
              7FFFD1A98FFF00793FF127F295CB59FCE3FF00AC7F2AE7925A3F0FFF0074733F
              DE0CDF13FF0072723FECDE81DFC17516FF00487FFE9B47FEDBAF37490F8B6D83
              FDAC11F01F9B9BFF00CE5CBFF45E814E9FE759FD71F9573892D497CB2F27186F
              F57D4B0FFE54CEFEAB3FEA9892F2D49731FA1FF56FFBA7B4FF002FFF00A67FF7
              2FFFD93842494D042100000000005D00000001010000000F00410064006F0062
              0065002000500068006F0074006F00730068006F00700000001700410064006F
              00620065002000500068006F0074006F00730068006F00700020004300430020
              003200300031003800000001003842494D040600000000000700060000000101
              00FFE10DDB687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E30
              2F003C3F787061636B657420626567696E3D22EFBBBF222069643D2257354D30
              4D7043656869487A7265537A4E54637A6B633964223F3E203C783A786D706D65
              746120786D6C6E733A783D2261646F62653A6E733A6D6574612F2220783A786D
              70746B3D2241646F626520584D5020436F726520352E362D633134322037392E
              3136303932342C20323031372F30372F31332D30313A30363A33392020202020
              202020223E203C7264663A52444620786D6C6E733A7264663D22687474703A2F
              2F7777772E77332E6F72672F313939392F30322F32322D7264662D73796E7461
              782D6E7323223E203C7264663A4465736372697074696F6E207264663A61626F
              75743D222220786D6C6E733A786D703D22687474703A2F2F6E732E61646F6265
              2E636F6D2F7861702F312E302F2220786D6C6E733A786D704D4D3D2268747470
              3A2F2F6E732E61646F62652E636F6D2F7861702F312E302F6D6D2F2220786D6C
              6E733A73744576743D22687474703A2F2F6E732E61646F62652E636F6D2F7861
              702F312E302F73547970652F5265736F757263654576656E74232220786D6C6E
              733A64633D22687474703A2F2F7075726C2E6F72672F64632F656C656D656E74
              732F312E312F2220786D6C6E733A70686F746F73686F703D22687474703A2F2F
              6E732E61646F62652E636F6D2F70686F746F73686F702F312E302F2220786D70
              3A43726561746F72546F6F6C3D2241646F62652050686F746F73686F70204343
              2032303138202857696E646F7773292220786D703A437265617465446174653D
              22323031382D30382D30335430383A30343A33312D30333A30302220786D703A
              4D65746164617461446174653D22323031382D30382D30335430383A30343A33
              312D30333A30302220786D703A4D6F64696679446174653D22323031382D3038
              2D30335430383A30343A33312D30333A30302220786D704D4D3A496E7374616E
              636549443D22786D702E6969643A61373934333766612D636462312D33343463
              2D623365622D3362313366643635633438352220786D704D4D3A446F63756D65
              6E7449443D2261646F62653A646F6369643A70686F746F73686F703A35616561
              363863342D333562322D343334612D626632662D633962626230376237313862
              2220786D704D4D3A4F726967696E616C446F63756D656E7449443D22786D702E
              6469643A34613137363437332D663763652D383034322D616634322D62393834
              3830373237396165222064633A666F726D61743D22696D6167652F6A70656722
              2070686F746F73686F703A436F6C6F724D6F64653D2233223E203C786D704D4D
              3A486973746F72793E203C7264663A5365713E203C7264663A6C692073744576
              743A616374696F6E3D2263726561746564222073744576743A696E7374616E63
              6549443D22786D702E6969643A34613137363437332D663763652D383034322D
              616634322D623938343830373237396165222073744576743A7768656E3D2232
              3031382D30382D30335430383A30343A33312D30333A3030222073744576743A
              736F6674776172654167656E743D2241646F62652050686F746F73686F702043
              432032303138202857696E646F777329222F3E203C7264663A6C692073744576
              743A616374696F6E3D227361766564222073744576743A696E7374616E636549
              443D22786D702E6969643A61373934333766612D636462312D333434632D6233
              65622D336231336664363563343835222073744576743A7768656E3D22323031
              382D30382D30335430383A30343A33312D30333A3030222073744576743A736F
              6674776172654167656E743D2241646F62652050686F746F73686F7020434320
              32303138202857696E646F777329222073744576743A6368616E6765643D222F
              222F3E203C2F7264663A5365713E203C2F786D704D4D3A486973746F72793E20
              3C2F7264663A4465736372697074696F6E3E203C2F7264663A5244463E203C2F
              783A786D706D6574613E20202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              2020202020202020202020202020202020202020202020202020202020202020
              20202020202020202020203C3F787061636B657420656E643D2277223F3EFFEE
              000E41646F626500644000000001FFDB00840002020202020202020202030202
              0203040302020304050404040404050605050505050506060707080707060909
              0A0A09090C0C0C0C0C0C0C0C0C0C0C0C0C0C0C01030303050405090606090D0A
              090A0D0F0E0E0E0E0F0F0C0C0C0C0C0F0F0C0C0C0C0C0C0F0C0C0C0C0C0C0C0C
              0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0CFFC000110800210037030111
              00021101031101FFDD00040007FFC401A2000000070101010101000000000000
              0000040503020601000708090A0B010002020301010101010000000000000001
              0002030405060708090A0B100002010303020402060703040206027301020311
              0400052112314151061361227181143291A10715B14223C152D1E1331662F024
              7282F12543345392A2B26373C235442793A3B33617546474C3D2E2082683090A
              181984944546A4B456D355281AF2E3F3C4D4E4F465758595A5B5C5D5E5F56676
              8696A6B6C6D6E6F637475767778797A7B7C7D7E7F738485868788898A8B8C8D8
              E8F82939495969798999A9B9C9D9E9F92A3A4A5A6A7A8A9AAABACADAEAFA1100
              02020102030505040506040803036D0100021103042112314105511361220671
              819132A1B1F014C1D1E1234215526272F1332434438216925325A263B2C20773
              D235E2448317549308090A18192636451A2764745537F2A3B3C32829D3E3F384
              94A4B4C4D4E4F465758595A5B5C5D5E5F5465666768696A6B6C6D6E6F6475767
              778797A7B7C7D7E7F738485868788898A8B8C8D8E8F839495969798999A9B9C9
              D9E9F92A3A4A5A6A7A8A9AAABACADAEAFAFFDA000C03010002110311003F00F2
              769BE6CF2679FAD23D0F5FB1B5D1EFC122D74FB899A1B2695DAA4E997EDCDEC5
              D9BFDD3373B727A15A95CEEB59EC676A7B3B2FCCF63C84A237963EFF0073D468
              7FE083D97ED6611A3F6961590FD3A886D207FA7E5EE60BE6CFCAFD6B4237B71A
              589F57B0B01EA5F5AB4262D4AC5295E5756A0B131D3713445A323E2A8AE74BEC
              F7B79A4ED29785A88F81A8E4632DB7F278FF006BBFE05DAFEC887E6B4A7F33A4
              97D3921B8AF3EAF2B666915BF795F84D0D6B9DF98180DC820BE635E1F41BBEF2
              D487FCEC3AA53B7E4DC67FF0DC5CF95FB58431FB677CE267B3F6AF634383FE05
              194C856C2BE6F83D5D78292E6829CF7D857BE7D4E058A8C362FC552C72E23B7C
              5EA9E52FCAED635C36377AC7D6346D3B525E7A558C717ADAA6A0B4AD6D2D0FEC
              53FDDD2948E9D0B5338AF69FDB9ECFEC71E0CBF7B98F28477DFCDF43F647FE06
              9DA5ED07EF63118B04779659ED001E9771A9F91741F4FC83A7DB8BD935B9934E
              D4747D235148A3432B88CBEA9AE3A91713216E4B1C605BC6C2ADB0E27838687B
              77B5E47B47563C3C7807898F0FF3A58FD711FE71003E93935FECC760C4764F67
              91932EA7F739B512E50865FDDE431F28C644F27FFFD0F0B37E467E74B1AFFCAA
              1F3791BFC3FA16F4835FF9E79F428EDCD0136730F9BE723B1F584DCB1CFDF5BB
              D2FCA9E5AFF9C83F2FFD4ACB51FCA1F3AEB5A258B836108D2EFA0BDD38FF003E
              9F7AB0B3C3DCFA643467BA6F9C97B49D95D87DB438A790472F49C48127BAF643
              DA9EDEF6725C38A329E13F5639826121DC47EA649E76FC90D4357D027F36DFF9
              4F5BF25C6488AEBCC777A3CFA74514CE364D5B4EE256127702E6D0B467A95DF6
              E2F45ED6EBFD9798D3EAA4351A7FE7837288F37D273FB19D93EDA44E7ECC81D2
              6B4F3C3215099EBC1D599DDA5A5C79D352D320D6B4A6327E57AE8EBA99BC8D6C
              0DDAE82B014FACB10A07A9F0EFBFB573CFB5DDB3A6CFED3FE741FDC997103E4F
              B0687D96ED2D27FC0E751D9D3C32FCC0222215BDDFDCC43C8FF92779A66871F9
              BB4EF2B6B1E7511398E0F33DAE8D71A8C0D709BB268FA770FDFB2F4FAC5D7188
              750BB54FA3F69FB79AEF68329D37674862C3C8E43B01EE7C7741FF0003CECBF6
              5231D576D939F515C434F0DC8EE1918E79BBCBDFF3909AF25EE9FA47E5179DB4
              3D27506235390E997D3EA7A90DAA750BE312BCA0D3FBB40B17F92699D07B31D8
              3D8DD952F1E7923935079CE46F7F2789F6AFDB4EDBEDBFF06C58E583491FA71C
              0102BCDE5FFF002A2FF3A800A7F287CE0A28471FD0979435ED431E7792EDFD15
              7F7D1BBEF7CD3F92B584DF8533BF3A2FFFD1F2A9F377E48F7D77F312BDFF00DC
              3695FF00799CCFFF009329ACFF00571F33FADF708FFCB526003FE33E1F21FA9B
              4F367E4A3C88916B7F98CF23B058D1345D2CB163D0281ACD493D80C65FF014D6
              46265F9911AF3291FF002D4382668767C2FA6C3F53D0752F26F945344B9B9B2D
              63CD367E618E3339F2EEBB6161682D2DBED35CEA7343A8DC2D9A0A578483D43D
              38576CF3FED7F65238730D3E1CC73E63B70C37AF792FA9FB31FF00053D4EBF4E
              75DABD1E3D26986FC73F493FD515BA40FF009757117986E7CBF379834C8E2B7D
              03FC44DAE8F59EC8DAFD4C5F29E423E66B1902BC29F4668A7ECE6AA1AFFC89FE
              F474F3EE7BD87FC123412EC59F6C08196081A35567FA5DD5F6A7DA4792FCAB2E
              8D14B7BABF99AE3CC8C9EAA797B43B2D3EEC5EDB81513E99713EA36C976B4EA8
              9F18E9C4E6EF47EC9CCEA4E975194E9F275E2DA3F021E1FB73FE0A994E9BF3DD
              9BA5C7ACD39EB1DE71FEBC4C76AF2258149E69FC958A59229B5AFCC786585BD3
              9E19344D2D5D1976E2CADAC860474A1CEFB1FF00C06759920278B551944F712F
              95E5FF00969F86299C72ECF84643A11FB167F8B7F246A29AEFE621AFFDA974AF
              FBCCE5A7FE029ABABF1C7CCB8FFF00334B888FF8CF85FB87EA7FFFD2F9EFE58F
              20EBBE69596F2158B4BF2FDBCBE95F799AFC98ED237EA228CAAB3CF291D23895
              98F5D86F9EFF00DB5ED2683B1F0F1EA7251E80732F13ECDFB2BAEEDFCDE1E931
              CA5DE7A0F32793DA84FE48FCA2888B6172FE6529F15CFEED75E92B5FB23F7B16
              910B023F9EE483DBF67CD8EA7B67DAC261881C1A5E665CA520FB14747ECDFB05
              8F8B5246B7B42B680DF1E33FD2F3786F9A7CEDADF9A54DA4ED1E9DA340ED359E
              8168192D924FF7EC81999A594F7924666F034CF42F67BD93D1762E1BC601BE72
              3F517CBBDACF6DFB4BDA2C8326AF25C3F8611DA10F203F5BEC3D4F7F306A80F4
              3F93718FA3FC36BB7CB3E7FED4983ED89E1BA337EA3EC415FF00027CC7C87DEF
              8EFCAFE75D67CB4A2D6129A968B34825BBF2FDE727B57714FDEC7C486865A2ED
              244430DAB5CFA1BB6BD98D0F6CE1F0F3C0135B1EA1F947D9BF6C3B47D9CD478B
              A3C863D08E8477105EEAB79E49FCDB8122D452EA7D7A38804B98F83798EDD541
              0054FA716B10AD29462970A3A114A9F353A5EDCF6372F1C09D4693F9BFC510FB
              1FE6BD9BF6F6006A04743DA15B4B962C87CFAD9793EADF961ABE8B7DA6196F2D
              AFBCABAB5EC5630F9DEC565B8B289E660BC6E225513412A03530C8A1DA87872E
              B9DAF677B77A0D669B2EA04BD50819707F17A45D7BF67CDBB5FF00E06FDAFD9B
              DA387499F1F0F8D923084FFC99E3908837DDBF37FFD3E79A075FF9C78FFC072E
              3FE4FC987DB4FF008D5C3EF0FB87FC0BFF00E712CBEE2F82EFBFE3A3AA7FCC74
              FF00F270E7D1BD9DFDC47FAAFCA5DA9FE359BE2A73756FF50FEACBF53FDDC7DE
              E821F4FC5F776A5FF290EA9FF9A6E2FF00C46D73E61ED6FF009CCFFCFF00D4FD
              C1D97FF46A73FB83E0C1D173EA697D3F27E229FD4532D23FE3ADA57FCC741FF2
              70657DABFDC9F73762FEF63EF1F7BF473C9DFF009343F353FE612C3FEA2EDF3E
              58D0FF00C6D65F8BF7076E7FCE17A7F7C3EF0FFFD9}
            Transparent = True
          end
        end
        object edPortaDW: TEdit
          Left = 9
          Top = 56
          Width = 40
          Height = 23
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
          Text = '8082'
        end
        object edUserNameDW: TEdit
          Left = 63
          Top = 56
          Width = 100
          Height = 23
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
          Text = 'testserver'
        end
        object edPasswordDW: TEdit
          Left = 176
          Top = 56
          Width = 100
          Height = 23
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          PasswordChar = '*'
          TabOrder = 3
          Text = 'testserver'
        end
        object cbForceWelcome: TCheckBox
          Left = 292
          Top = 72
          Width = 213
          Height = 17
          Caption = 'Force Welcome Access Events'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 4
        end
        object cbauthentication: TCheckBox
          Left = 292
          Top = 56
          Width = 123
          Height = 17
          Caption = 'Authentication'
          Checked = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          State = cbChecked
          TabOrder = 5
        end
        object edURL: TEdit
          Left = 7
          Top = 221
          Width = 269
          Height = 23
          TabOrder = 6
          Text = 'informe  a URL'
          Visible = False
        end
        object cbAdaptadores: TComboBox
          Left = 7
          Top = 221
          Width = 269
          Height = 25
          BevelKind = bkFlat
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ItemHeight = 17
          ParentFont = False
          TabOrder = 7
          Text = 'cbAdaptadores'
          OnChange = cbAdaptadoresChange
        end
        object edPortaBD: TEdit
          Left = 292
          Top = 220
          Width = 40
          Height = 23
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 8
          Text = '3050'
        end
        object edUserNameBD: TEdit
          Left = 347
          Top = 220
          Width = 100
          Height = 23
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 9
          Text = 'sysdba'
        end
        object edPasswordBD: TEdit
          Left = 459
          Top = 220
          Width = 148
          Height = 23
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          PasswordChar = '*'
          TabOrder = 10
          Text = 'masterkey'
        end
        object edPasta: TEdit
          Left = 9
          Top = 278
          Width = 438
          Height = 23
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 11
        end
        object edBD: TEdit
          Left = 459
          Top = 278
          Width = 148
          Height = 23
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 12
        end
        object cbDriver: TComboBox
          Left = 7
          Top = 161
          Width = 269
          Height = 25
          BevelKind = bkFlat
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ItemHeight = 17
          ParentFont = False
          TabOrder = 13
          Text = 'Selecione o SGBD'
          OnCloseUp = cbDriverCloseUp
          Items.Strings = (
            'FB'
            'MSSQL'
            'MySQL'
            'PostgreSQL')
        end
        object ckUsaURL: TCheckBox
          Left = 26
          Top = 201
          Width = 82
          Height = 17
          Caption = 'Uses URL'
          TabOrder = 14
          OnClick = ckUsaURLClick
        end
        object ePrivKeyFile: TEdit
          Left = 7
          Top = 376
          Width = 440
          Height = 23
          Anchors = [akLeft, akBottom]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 15
        end
        object eCertFile: TEdit
          Left = 7
          Top = 429
          Width = 600
          Height = 23
          Anchors = [akLeft, akBottom]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 16
        end
        object ePrivKeyPass: TMaskEdit
          Left = 459
          Top = 376
          Width = 148
          Height = 23
          Anchors = [akLeft, akBottom]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          PasswordChar = '*'
          TabOrder = 17
        end
        object cbUpdateLog: TCheckBox
          Left = 292
          Top = 89
          Width = 309
          Height = 17
          Caption = 'Update Memo LOG (Do not use in production)'
          Checked = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          State = cbChecked
          TabOrder = 18
        end
      end
    end
    object tsLogs: TTabSheet
      Caption = 'Logs'
      ImageIndex = 1
      object Label19: TLabel
        Left = 7
        Top = 262
        Width = 60
        Height = 17
        Caption = 'Respostas'
        Color = clBtnFace
        ParentColor = False
      end
      object Label18: TLabel
        Left = 7
        Top = 10
        Width = 69
        Height = 17
        Caption = 'Requisi'#231#245'es'
        Color = clBtnFace
        ParentColor = False
      end
      object memoReq: TMemo
        Left = 7
        Top = 30
        Width = 606
        Height = 210
        Color = clInfoBk
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Consolas'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object memoResp: TMemo
        Left = 7
        Top = 282
        Width = 606
        Height = 210
        Color = clInfoBk
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Consolas'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
    end
  end
  object paTopo: TPanel
    Left = 0
    Top = 0
    Width = 640
    Height = 58
    Align = alTop
    BevelOuter = bvNone
    Color = 2763306
    ParentBackground = False
    TabOrder = 1
    DesignSize = (
      640
      58)
    object labSistema: TLabel
      Left = 118
      Top = 4
      Width = 54
      Height = 13
      Alignment = taCenter
      Caption = 'S E R V E R'
      Color = 4227327
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 4227327
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Transparent = True
      Layout = tlCenter
      Visible = False
    end
    object Image2: TImage
      Left = 0
      Top = 0
      Width = 229
      Height = 58
      Align = alLeft
      Center = True
      Picture.Data = {
        0A544A504547496D616765F2350000FFD8FFE109944578696600004D4D002A00
        0000080007011200030000000100010000011A00050000000100000062011B00
        05000000010000006A012800030000000100020000013100020000001E000000
        720132000200000014000000908769000400000001000000A4000000D0000AFC
        DA00002710000AFCDA0000271041646F62652050686F746F73686F7020435336
        202857696E646F77732900323031393A30313A32312031313A33323A35390000
        03A001000300000001FFFF0000A002000400000001000000E6A0030004000000
        01000000320000000000000006010300030000000100060000011A0005000000
        010000011E011B00050000000100000126012800030000000100020000020100
        04000000010000012E02020004000000010000085E0000000000000048000000
        010000004800000001FFD8FFED000C41646F62655F434D0001FFEE000E41646F
        626500648000000001FFDB0084000C08080809080C09090C110B0A0B11150F0C
        0C0F1518131315131318110C0C0C0C0C0C110C0C0C0C0C0C0C0C0C0C0C0C0C0C
        0C0C0C0C0C0C0C0C0C0C0C0C0C0C010D0B0B0D0E0D100E0E10140E0E0E14140E
        0E0E0E14110C0C0C0C0C11110C0C0C0C0C0C110C0C0C0C0C0C0C0C0C0C0C0C0C
        0C0C0C0C0C0C0C0C0C0C0C0C0C0C0CFFC0001108002300A00301220002110103
        1101FFDD0004000AFFC4013F0000010501010101010100000000000000030001
        020405060708090A0B0100010501010101010100000000000000010002030405
        060708090A0B1000010401030204020507060805030C33010002110304211231
        054151611322718132061491A1B14223241552C16233347282D14307259253F0
        E1F163733516A2B283264493546445C2A3743617D255E265F2B384C3D375E3F3
        462794A485B495C4D4E4F4A5B5C5D5E5F55666768696A6B6C6D6E6F637475767
        778797A7B7C7D7E7F71100020201020404030405060707060535010002110321
        3112044151617122130532819114A1B14223C152D1F0332462E1728292435315
        637334F1250616A2B283072635C2D2449354A317644555367465E2F2B384C3D3
        75E3F34694A485B495C4D4E4F4A5B5C5D5E5F55666768696A6B6C6D6E6F62737
        475767778797A7B7C7FFDA000C03010002110311003F00E12B61B2C6D6DD0BB4
        04AB43A5E546E3B5ACFDED48FF00A940C5319351FE547DFED5D4E2562BC6FB6B
        DEE151B85040F70F737D4DEEACFD3FEAAABCCE6C98E40400D45EAECFC27E1FCB
        73387264CBC4678F20888C25C3C7194748FCB2FEB3827A634D6763CEF06093C1
        D3F77F35567615CD30EDB1E33FEC5D65DD0B21B977E3D225E3716563597B1ECA
        2EA99FD4DDEB7FC4ACFEB3D33EC0C169B458CB2C73687B4435F5B595DBEBB67F
        7BED15B3FEDC5062E6739FEB0F10E8E7F867C32718CA178E557C3096928C7F7F
        8F8DE71246C0A19919D898D612197DF554F2DD1DB6C7B2B7EDFE56D72EEBA87D
        57FF0017F83D7E9FABF90FEA34E5E50AFD2BDB607541D69732966E707FB9EF66
        CF7D1B168BCA0D9F3F496C754FAAFD4B0FEB164740C3AECEA17D3B5F59A9BABA
        A706BDB6DBF994ECDFE958E7BBD3F5154CFE8BD63A6DF5E367E15D8F75E76D0C
        2DDDEA3890DF4E8755EA32EB3DEDFD157FA4492D2496BBFEA8FD68ADD40B7A5E
        4B064383584303E27576F6D4F7399B19B9FF00A4F4D6A755FA8991D2BEB0E060
        3CDF95D2F2ADC7AEFCF158ADAD37D9E83A90F69B19EA7D0D8EFF0085494F2892
        EDFA9F47FF0016DD37AD5BD1332CEA58D7D458D7E56F0EA59EA31B731DBDC2DF
        6EDB1BBB7D0AC74FFF00171855FD63BFA4754BADBF1AEC6395D332A977A5B831
        EDAB22BB9B0E63EFA7D6A3E87E8BD3FD2FF84F4AA4A78049749F523EAB57D73A
        E6474FEA62C6538353CE47A4ED87D66D831DB5EFFECDEEFF00ADA8FF00CD668F
        AF63EAC1738E39C98DD3EFFB37A7F6DFE73FD2FA1FA3F53FD224A79D49687D60
        C5C1C2EBB9F85D3F7FD9316E34D7EA3B7BA581ADBA5FF9DFA7F5567A4A524924
        9294924924A7FFD0E0C12082390647C42E8F0BA96457434E3B835A5C2D01CC6B
        B6BC0DAD7B3D46BB658CFA2B9B47C5CA763920CBAB772DF03FBCD5073388E488
        31F9E3B7ED8BA7F07E7A1CAE694730BC19808E4B1C5C128FF379387FC2F53D5F
        4BEA07D27D165E69BD8E7BB1B29C7873C39B6B1EEFF84F52CF77FC27F5162759
        BF24575635D66F14B4D743438383585C6C7C399FCA72473686545FB83B71F6B4
        72565DB6BADB0BDDC9E0780F055795C13E3E295C6313B1FD29BABF17E7B97C78
        658F0CA3932E71FA1C3318B1CBE69F1C7FCE427E887F5FDC6C749FF95FA7FF00
        E1BC7FFCFB5AF57CDEA1F579BFE3071F0333A7B3F69BE86BB13A9BDDB807FE95
        D5D3E8BB6B59EDAECF4ADDDBFD4FD1AF20A2EB31EFAB22A205B458CB6B2448DC
        C70B19B9BF9DEE6ABFD53EB0754EABD5ABEB192F633369F4FD27D2CD8D69A5DE
        AD2E0C73ACF77A87F39CB45E5DF41C3664E1F47FAD995D5B32CC6EA5F6DF4F2F
        A8E257368A1B5E37D91F452CDEEAEAFB2E47B3DFEA6332CB2DF577D7EA2CCC3F
        AF1F573A774AC5C7AF332FAF64606537229391511636B21D55DB6DB0EDFD063D
        B92EA7D4B3FE0FF9AFE6F087D7FF00AC6DEA8FEA8D7638BAEA9B464522A229B5
        8C2F757EB57EA17FAB5FACFDB6B6DFE6FF004695DF5F7AEBACC6B31AAC2C0189
        6FAEC66351B5AE7ECB283EB6FB1FB98EA6FB99EDD8929DEEA84F50C3C9FAD5F5
        5BAFE6BF19B9353F3F02C7BC6CDD6572DA37ECF47D2DFF00CD7E92A7D3FA3AED
        FF00048DF5CF3B347F8C6E8BD3FED160C3759856FD9771F48BC5F6FE97D2FA3B
        BD8DF72E57AC7D72EB1D5BA79E9AFAF1B0B09EE0FB69C2ACD5EA3810F6BAD739
        F67E7B5AFF00623E77F8C1FAC79F8D8D4647D98BB16EAB21B90DA88B1EFA1C2E
        A7D5FD27A5B7D46EEB7D2AEBDFFF00069296FAFF0045F95F5EFA962E354FBF22
        EF41B5D4C69717138F4E9A05D7F5CCF6F44EBBF52F0EDB03B2711869CA33C32F
        653D3BD47FF21F787D9FFA0EB99B7FC687D6F7B0B5B6E3544F0F651EE1FD5F52
        DB19FF00417319995959D916E5665CFBF26E3BACBDE65E48FA307F33D3FF0006
        C67B2B494FA47D61C6B7EACF4BFAD7D4A82EAB23AA66D0DC477EF070AB22C2CF
        FAE64E733FEB6B52CC7C76FD631F5DC57BBA7FEC43735FDF7822E0E9FDF7613F
        D35E73D77EB875CFAC18B4E2F527D4EAA87FAAD1557B09786BAA0FB0EFB3F32C
        B3E86CFA699DF5BFAEBBEAF8FABC6DAFF678AC533B0FABE983BBD2F5B7EDDBFE
        0BF9AFE692538C6CB6E26EB8975B693658E3C97BCFA963BFCF726492494A4924
        925292492494FF00FFD1E09258E924A763B9E3F8A4B1D2494EC24B1D2494EC24
        B1D2494EC24B1D2494EC24B1D2494EC24B1D2494EC24B1D2494EC24B1D2494EC
        24B1D2494FFFD9FFED119450686F746F73686F7020332E30003842494D042500
        0000000010000000000000000000000000000000003842494D043A0000000000
        F9000000100000000100000000000B7072696E744F7574707574000000050000
        000050737453626F6F6C0100000000496E7465656E756D00000000496E746500
        000000496D67200000000F7072696E745369787465656E426974626F6F6C0000
        00000B7072696E7465724E616D65544558540000000100000000000F7072696E
        7450726F6F6653657475704F626A63000000160043006F006E00660069006700
        750072006100E700E3006F002000640065002000500072006F00760061000000
        00000A70726F6F6653657475700000000100000000426C746E656E756D000000
        0C6275696C74696E50726F6F660000000970726F6F66434D594B003842494D04
        3B00000000022D00000010000000010000000000127072696E744F7574707574
        4F7074696F6E7300000017000000004370746E626F6F6C0000000000436C6272
        626F6F6C00000000005267734D626F6F6C000000000043726E43626F6F6C0000
        000000436E7443626F6F6C00000000004C626C73626F6F6C00000000004E6774
        76626F6F6C0000000000456D6C44626F6F6C0000000000496E7472626F6F6C00
        0000000042636B674F626A630000000100000000000052474243000000030000
        000052642020646F7562406FE000000000000000000047726E20646F7562406F
        E0000000000000000000426C2020646F7562406FE00000000000000000004272
        6454556E744623526C74000000000000000000000000426C6420556E74462352
        6C7400000000000000000000000052736C74556E74462350786C405200938000
        00000000000A766563746F7244617461626F6F6C010000000050675073656E75
        6D00000000506750730000000050675043000000004C656674556E744623526C
        74000000000000000000000000546F7020556E744623526C7400000000000000
        000000000053636C20556E74462350726340590000000000000000001063726F
        705768656E5072696E74696E67626F6F6C000000000E63726F7052656374426F
        74746F6D6C6F6E67000000000000000C63726F70526563744C6566746C6F6E67
        000000000000000D63726F705265637452696768746C6F6E6700000000000000
        0B63726F7052656374546F706C6F6E6700000000003842494D03ED0000000000
        100048024E000100020048024E000100023842494D042600000000000E000000
        000000000000003F8000003842494D040D0000000000040000001E3842494D04
        190000000000040000001E3842494D03F3000000000009000000000000000001
        003842494D271000000000000A000100000000000000023842494D03F5000000
        000048002F66660001006C66660006000000000001002F6666000100A1999A00
        06000000000001003200000001005A0000000600000000000100350000000100
        2D000000060000000000013842494D03F80000000000700000FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF03E800000000FFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFF03E800000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFF03E800000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFF03E800003842494D040000000000000200003842494D04020000000000
        04000000003842494D043000000000000201013842494D042D00000000000600
        01000000043842494D0408000000000010000000010000024000000240000000
        003842494D041E000000000004000000003842494D041A00000000033B000000
        06000000000000000000000032000000E6000000030072006400770000000100
        000000000000000000000000000000000000010000000000000000000000E600
        0000320000000000000000000000000000000001000000000000000000000000
        0000000000000010000000010000000000006E756C6C0000000200000006626F
        756E64734F626A6300000001000000000000526374310000000400000000546F
        70206C6F6E6700000000000000004C6566746C6F6E6700000000000000004274
        6F6D6C6F6E670000003200000000526768746C6F6E67000000E600000006736C
        69636573566C4C73000000014F626A6300000001000000000005736C69636500
        00001200000007736C69636549446C6F6E67000000000000000767726F757049
        446C6F6E6700000000000000066F726967696E656E756D0000000C45536C6963
        654F726967696E0000000D6175746F47656E6572617465640000000054797065
        656E756D0000000A45536C6963655479706500000000496D672000000006626F
        756E64734F626A6300000001000000000000526374310000000400000000546F
        70206C6F6E6700000000000000004C6566746C6F6E6700000000000000004274
        6F6D6C6F6E670000003200000000526768746C6F6E67000000E6000000037572
        6C54455854000000010000000000006E756C6C54455854000000010000000000
        004D7367655445585400000001000000000006616C7454616754455854000000
        0100000000000E63656C6C54657874497348544D4C626F6F6C01000000086365
        6C6C546578745445585400000001000000000009686F727A416C69676E656E75
        6D0000000F45536C696365486F727A416C69676E0000000764656661756C7400
        00000976657274416C69676E656E756D0000000F45536C69636556657274416C
        69676E0000000764656661756C740000000B6267436F6C6F7254797065656E75
        6D0000001145536C6963654247436F6C6F7254797065000000004E6F6E650000
        0009746F704F75747365746C6F6E67000000000000000A6C6566744F75747365
        746C6F6E67000000000000000C626F74746F6D4F75747365746C6F6E67000000
        000000000B72696768744F75747365746C6F6E6700000000003842494D042800
        000000000C000000023FF00000000000003842494D0414000000000004000000
        043842494D040C00000000087A00000001000000A000000023000001E0000041
        A00000085E00180001FFD8FFED000C41646F62655F434D0001FFEE000E41646F
        626500648000000001FFDB0084000C08080809080C09090C110B0A0B11150F0C
        0C0F1518131315131318110C0C0C0C0C0C110C0C0C0C0C0C0C0C0C0C0C0C0C0C
        0C0C0C0C0C0C0C0C0C0C0C0C0C0C010D0B0B0D0E0D100E0E10140E0E0E14140E
        0E0E0E14110C0C0C0C0C11110C0C0C0C0C0C110C0C0C0C0C0C0C0C0C0C0C0C0C
        0C0C0C0C0C0C0C0C0C0C0C0C0C0C0CFFC0001108002300A00301220002110103
        1101FFDD0004000AFFC4013F0000010501010101010100000000000000030001
        020405060708090A0B0100010501010101010100000000000000010002030405
        060708090A0B1000010401030204020507060805030C33010002110304211231
        054151611322718132061491A1B14223241552C16233347282D14307259253F0
        E1F163733516A2B283264493546445C2A3743617D255E265F2B384C3D375E3F3
        462794A485B495C4D4E4F4A5B5C5D5E5F55666768696A6B6C6D6E6F637475767
        778797A7B7C7D7E7F71100020201020404030405060707060535010002110321
        3112044151617122130532819114A1B14223C152D1F0332462E1728292435315
        637334F1250616A2B283072635C2D2449354A317644555367465E2F2B384C3D3
        75E3F34694A485B495C4D4E4F4A5B5C5D5E5F55666768696A6B6C6D6E6F62737
        475767778797A7B7C7FFDA000C03010002110311003F00E12B61B2C6D6DD0BB4
        04AB43A5E546E3B5ACFDED48FF00A940C5319351FE547DFED5D4E2562BC6FB6B
        DEE151B85040F70F737D4DEEACFD3FEAAABCCE6C98E40400D45EAECFC27E1FCB
        73387264CBC4678F20888C25C3C7194748FCB2FEB3827A634D6763CEF06093C1
        D3F77F35567615CD30EDB1E33FEC5D65DD0B21B977E3D225E3716563597B1ECA
        2EA99FD4DDEB7FC4ACFEB3D33EC0C169B458CB2C73687B4435F5B595DBEBB67F
        7BED15B3FEDC5062E6739FEB0F10E8E7F867C32718CA178E557C3096928C7F7F
        8F8DE71246C0A19919D898D612197DF554F2DD1DB6C7B2B7EDFE56D72EEBA87D
        57FF0017F83D7E9FABF90FEA34E5E50AFD2BDB607541D69732966E707FB9EF66
        CF7D1B168BCA0D9F3F496C754FAAFD4B0FEB164740C3AECEA17D3B5F59A9BABA
        A706BDB6DBF994ECDFE958E7BBD3F5154CFE8BD63A6DF5E367E15D8F75E76D0C
        2DDDEA3890DF4E8755EA32EB3DEDFD157FA4492D2496BBFEA8FD68ADD40B7A5E
        4B064383584303E27576F6D4F7399B19B9FF00A4F4D6A755FA8991D2BEB0E060
        3CDF95D2F2ADC7AEFCF158ADAD37D9E83A90F69B19EA7D0D8EFF0085494F2892
        EDFA9F47FF0016DD37AD5BD1332CEA58D7D458D7E56F0EA59EA31B731DBDC2DF
        6EDB1BBB7D0AC74FFF00171855FD63BFA4754BADBF1AEC6395D332A977A5B831
        EDAB22BB9B0E63EFA7D6A3E87E8BD3FD2FF84F4AA4A78049749F523EAB57D73A
        E6474FEA62C6538353CE47A4ED87D66D831DB5EFFECDEEFF00ADA8FF00CD668F
        AF63EAC1738E39C98DD3EFFB37A7F6DFE73FD2FA1FA3F53FD224A79D49687D60
        C5C1C2EBB9F85D3F7FD9316E34D7EA3B7BA581ADBA5FF9DFA7F5567A4A524924
        9294924924A7FFD0E0C12082390647C42E8F0BA96457434E3B835A5C2D01CC6B
        B6BC0DAD7B3D46BB658CFA2B9B47C5CA763920CBAB772DF03FBCD5073388E488
        31F9E3B7ED8BA7F07E7A1CAE694730BC19808E4B1C5C128FF379387FC2F53D5F
        4BEA07D27D165E69BD8E7BB1B29C7873C39B6B1EEFF84F52CF77FC27F5162759
        BF24575635D66F14B4D743438383585C6C7C399FCA72473686545FB83B71F6B4
        72565DB6BADB0BDDC9E0780F055795C13E3E295C6313B1FD29BABF17E7B97C78
        658F0CA3932E71FA1C3318B1CBE69F1C7FCE427E887F5FDC6C749FF95FA7FF00
        E1BC7FFCFB5AF57CDEA1F579BFE3071F0333A7B3F69BE86BB13A9BDDB807FE95
        D5D3E8BB6B59EDAECF4ADDDBFD4FD1AF20A2EB31EFAB22A205B458CB6B2448DC
        C70B19B9BF9DEE6ABFD53EB0754EABD5ABEB192F633369F4FD27D2CD8D69A5DE
        AD2E0C73ACF77A87F39CB45E5DF41C3664E1F47FAD995D5B32CC6EA5F6DF4F2F
        A8E257368A1B5E37D91F452CDEEAEAFB2E47B3DFEA6332CB2DF577D7EA2CCC3F
        AF1F573A774AC5C7AF332FAF64606537229391511636B21D55DB6DB0EDFD063D
        B92EA7D4B3FE0FF9AFE6F087D7FF00AC6DEA8FEA8D7638BAEA9B464522A229B5
        8C2F757EB57EA17FAB5FACFDB6B6DFE6FF004695DF5F7AEBACC6B31AAC2C0189
        6FAEC66351B5AE7ECB283EB6FB1FB98EA6FB99EDD8929DEEA84F50C3C9FAD5F5
        5BAFE6BF19B9353F3F02C7BC6CDD6572DA37ECF47D2DFF00CD7E92A7D3FA3AED
        FF00048DF5CF3B347F8C6E8BD3FED160C3759856FD9771F48BC5F6FE97D2FA3B
        BD8DF72E57AC7D72EB1D5BA79E9AFAF1B0B09EE0FB69C2ACD5EA3810F6BAD739
        F67E7B5AFF00623E77F8C1FAC79F8D8D4647D98BB16EAB21B90DA88B1EFA1C2E
        A7D5FD27A5B7D46EEB7D2AEBDFFF00069296FAFF0045F95F5EFA962E354FBF22
        EF41B5D4C69717138F4E9A05D7F5CCF6F44EBBF52F0EDB03B2711869CA33C32F
        653D3BD47FF21F787D9FFA0EB99B7FC687D6F7B0B5B6E3544F0F651EE1FD5F52
        DB19FF00417319995959D916E5665CFBF26E3BACBDE65E48FA307F33D3FF0006
        C67B2B494FA47D61C6B7EACF4BFAD7D4A82EAB23AA66D0DC477EF070AB22C2CF
        FAE64E733FEB6B52CC7C76FD631F5DC57BBA7FEC43735FDF7822E0E9FDF7613F
        D35E73D77EB875CFAC18B4E2F527D4EAA87FAAD1557B09786BAA0FB0EFB3F32C
        B3E86CFA699DF5BFAEBBEAF8FABC6DAFF678AC533B0FABE983BBD2F5B7EDDBFE
        0BF9AFE692538C6CB6E26EB8975B693658E3C97BCFA963BFCF726492494A4924
        925292492494FF00FFD1E09258E924A763B9E3F8A4B1D2494EC24B1D2494EC24
        B1D2494EC24B1D2494EC24B1D2494EC24B1D2494EC24B1D2494EC24B1D2494EC
        24B1D2494FFFD93842494D042100000000005500000001010000000F00410064
        006F00620065002000500068006F0074006F00730068006F0070000000130041
        0064006F00620065002000500068006F0074006F00730068006F007000200043
        0053003600000001003842494D04060000000000070001000000010100FFE10E
        28687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F003C3F
        787061636B657420626567696E3D22EFBBBF222069643D2257354D304D704365
        6869487A7265537A4E54637A6B633964223F3E203C783A786D706D6574612078
        6D6C6E733A783D2261646F62653A6E733A6D6574612F2220783A786D70746B3D
        2241646F626520584D5020436F726520352E332D633031312036362E31343536
        36312C20323031322F30322F30362D31343A35363A3237202020202020202022
        3E203C7264663A52444620786D6C6E733A7264663D22687474703A2F2F777777
        2E77332E6F72672F313939392F30322F32322D7264662D73796E7461782D6E73
        23223E203C7264663A4465736372697074696F6E207264663A61626F75743D22
        2220786D6C6E733A786D703D22687474703A2F2F6E732E61646F62652E636F6D
        2F7861702F312E302F2220786D6C6E733A64633D22687474703A2F2F7075726C
        2E6F72672F64632F656C656D656E74732F312E312F2220786D6C6E733A70686F
        746F73686F703D22687474703A2F2F6E732E61646F62652E636F6D2F70686F74
        6F73686F702F312E302F2220786D6C6E733A786D704D4D3D22687474703A2F2F
        6E732E61646F62652E636F6D2F7861702F312E302F6D6D2F2220786D6C6E733A
        73744576743D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F31
        2E302F73547970652F5265736F757263654576656E74232220786D703A437265
        61746F72546F6F6C3D2241646F62652050686F746F73686F7020435336202857
        696E646F7773292220786D703A437265617465446174653D22323031392D3031
        2D32305431333A31323A34362D30323A30302220786D703A4D6F646966794461
        74653D22323031392D30312D32315431313A33323A35392D30323A3030222078
        6D703A4D65746164617461446174653D22323031392D30312D32315431313A33
        323A35392D30323A3030222064633A666F726D61743D22696D6167652F6A7065
        67222070686F746F73686F703A436F6C6F724D6F64653D2233222070686F746F
        73686F703A49434350726F66696C653D2241646F626520524742202831393938
        292220786D704D4D3A496E7374616E636549443D22786D702E6969643A323631
        3844373131383131444539313139324338463232444138464141423230222078
        6D704D4D3A446F63756D656E7449443D22786D702E6469643A32353138443731
        313831314445393131393243384632324441384641414232302220786D704D4D
        3A4F726967696E616C446F63756D656E7449443D22786D702E6469643A323531
        3844373131383131444539313139324338463232444138464141423230223E20
        3C786D704D4D3A486973746F72793E203C7264663A5365713E203C7264663A6C
        692073744576743A616374696F6E3D2263726561746564222073744576743A69
        6E7374616E636549443D22786D702E6969643A32353138443731313831314445
        39313139324338463232444138464141423230222073744576743A7768656E3D
        22323031392D30312D32305431333A31323A34362D30323A3030222073744576
        743A736F6674776172654167656E743D2241646F62652050686F746F73686F70
        20435336202857696E646F777329222F3E203C7264663A6C692073744576743A
        616374696F6E3D22636F6E766572746564222073744576743A706172616D6574
        6572733D2266726F6D20696D6167652F706E6720746F20696D6167652F6A7065
        67222F3E203C7264663A6C692073744576743A616374696F6E3D227361766564
        222073744576743A696E7374616E636549443D22786D702E6969643A32363138
        4437313138313144453931313932433846323244413846414142323022207374
        4576743A7768656E3D22323031392D30312D32315431313A33323A35392D3032
        3A3030222073744576743A736F6674776172654167656E743D2241646F626520
        50686F746F73686F7020435336202857696E646F777329222073744576743A63
        68616E6765643D222F222F3E203C2F7264663A5365713E203C2F786D704D4D3A
        486973746F72793E203C2F7264663A4465736372697074696F6E3E203C2F7264
        663A5244463E203C2F783A786D706D6574613E20202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        2020202020202020202020202020202020202020202020202020202020202020
        20202020202020202020202020202020202020203C3F787061636B657420656E
        643D2277223F3EFFE202404943435F50524F46494C4500010100000230414442
        45021000006D6E74725247422058595A2007CF00060003000000000000616373
        704150504C000000006E6F6E65000000000000000000000000000000000000F6
        D6000100000000D32D4144424500000000000000000000000000000000000000
        000000000000000000000000000000000000000000000000000000000A637072
        74000000FC0000003264657363000001300000006B777470740000019C000000
        14626B7074000001B00000001472545243000001C40000000E67545243000001
        D40000000E62545243000001E40000000E7258595A000001F400000014675859
        5A00000208000000146258595A0000021C000000147465787400000000436F70
        79726967687420313939392041646F62652053797374656D7320496E636F7270
        6F726174656400000064657363000000000000001141646F6265205247422028
        3139393829000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000000000058595A20000000000000F3
        5100010000000116CC58595A2000000000000000000000000000000000637572
        7600000000000000010233000063757276000000000000000102330000637572
        7600000000000000010233000058595A200000000000009C1800004FA5000004
        FC58595A20000000000000348D0000A02C00000F9558595A2000000000000026
        310000102F0000BE9CFFEE000E41646F626500648000000001FFDB0084000C08
        080809080C09090C110B0A0B11150F0C0C0F1518131315131318110C0C0C0C0C
        0C110C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C010D
        0B0B0D0E0D100E0E10140E0E0E14140E0E0E0E14110C0C0C0C0C11110C0C0C0C
        0C0C110C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0CFF
        C0001108003200E603012200021101031101FFDD0004000FFFC4013F00000105
        01010101010100000000000000030001020405060708090A0B01000105010101
        01010100000000000000010002030405060708090A0B10000104010302040205
        07060805030C33010002110304211231054151611322718132061491A1B14223
        241552C16233347282D14307259253F0E1F163733516A2B283264493546445C2
        A3743617D255E265F2B384C3D375E3F3462794A485B495C4D4E4F4A5B5C5D5E5
        F55666768696A6B6C6D6E6F637475767778797A7B7C7D7E7F711000202010204
        040304050607070605350100021103213112044151617122130532819114A1B1
        4223C152D1F0332462E1728292435315637334F1250616A2B283072635C2D244
        9354A317644555367465E2F2B384C3D375E3F34694A485B495C4D4E4F4A5B5C5
        D5E5F55666768696A6B6C6D6E6F62737475767778797A7B7C7FFDA000C030100
        02110311003F00E193963C0060C1E0A65B1871E832448DA1439F37B5112AE2B3
        4DEF86F2039CC93C7C7C1C31E306B8BAFF0082E5329B5E7DAD3F1476F4FB1CC2
        E6B8170FCDFF006AD7663D59008ACEDB07E69281402DF51AE1043A083E2AA4B9
        D99D62046BA7CCEC72DF03E5788C324A7925447F9AE0FEB462389C77D5630C39
        A415183131A2D6BFBAA177D12A7C5CD19900C6ACF769737F078E08CE63299080
        3200C75D3FAC812495B6747EAF631AFAF0721EC7096B9B53C820F7690D569C66
        A248B9187978A437268B282781631CC3FF004C042494A4924925292492494A49
        5AA7A5753BEB16D1877DB5BBE8BD95BDCD3F0735AA191D3F3F19BBB271ADA1BE
        3631CC1FF4C049481245C7C5CACA796635365EF024B6B697903C6180A8595595
        58EAAD63ABB1861CC7021C0F839AE494C52476E0673F1CE5331AD7638049B831
        C5903477E92367B50002E200124E800494A491B270F3310B465516505DAB45AC
        73263F77786A0A4A5249249294924924A5249249294924924A7FFFD0E196AE13
        A71879023EE594AF74DB47BAA3F11FC557E721C58891FA2789D5F816618F9D88
        91A196271FF85F347FE8F0BD3ED8EBB8F82D87E3D8DA43D90340EADAEB2C0EFA
        4CD9F4D3371287E4E3E43A1D45AF155CEED0EFD132DFC5665BD4B38B0D7EB10D
        2DD860004B7E8EDDE06F56BA26531D4D98579F638FE8CF84FE6FFDF98B3E7206
        A43A1BFA7EEBBE70E48106F510E0970F5D3D793FBCDDAFA363D9E8E13E064E33
        EBBB2DD3FE0DEE7FAADFFADB2BAFFEDC5C8E6DADB2DB6C6886D8F7168F004CB5
        6CF507F50C4CBB6C758E2FB816BAD8FA4D3A2C0B8CBA3C159E5AA7206228475F
        FBD73BE27338F979714F8CE5A11F397AB2235EC9F58FAEE6F42FAA7859B84186
        E228AFF480B843AB24E80B7F7578DAF69EB7D43A4F4FFAAF857F57C4FB6E2914
        37D1DAD77B8D7ED7EDB0B5BED857DE71AFF563AAFF00CF4E83955758C6AE18FF
        0049CE6021865A1CDB2BDE5FB2FAF72F3BE81F53BAAF5FB6DFB1EC6E2D2E2C76
        558486123F359B77BAC77F557A175ABDF6FD49765FD52F4F1B11D597D95D7586
        BFD2FA391E9EC3B2ABABDAFF005BDAF51C1C2C66FF008BAC7C6FB737A5D7934B
        0DB98E1306D77A9637E9D5FCEEEF47E9A4A790EABFE2D3AD60E1BF331ADA73AB
        A81758DA890F01BF48B1AE1B6CDBFD7F5157FABFF507ABF5BC3FB78B2BC4C474
        ECB2E265D1A17318D1F4377E7BD75BF541BF57BEACBB207FCE3C7CBA72037F45
        A561AE6CFE93F9EBBE934ED4F83D5BEAB7D63E88FF00AB97648C235BCD748DDE
        9EE6B1E4E3594B9FFA3B373366EA5E929C5C0FF169D531BAE61FAD6E2E46235E
        CC87925C43EAADF57AD57A66B76E739967E77E89FF00E916C7D79FA8D77507B3
        37A53317169C6A5E6F641ADCE2D9B3DADA6A735DEDFDF72C8BFEAAF57FAB5D7B
        A3465BF23A6599D4D75B9A5CD0D73ECADCFAACA77398DF5595FE6FF3BE9A37F8
        D9C8C8ABA86132BB5EC63E876E6B5C403EE8F700929DAC6EAB95D1FF00C5A63F
        51C40D37D14D7B37896FBEE6D4E9682DFCDB1657D5EFF1997E76757D3FAE5149
        A3288A85B5B4801CF3B5BEB5763AC63EA77D15673FFF00C91B7FE268FF00DB8A
        979D74AC6BB2BA9E2635209B6DB98D6C78970D7FB2929F4DABA4E3FD59FAF389
        661B7D2C0EB55DB49AC7D165ADDB76D60FCD63DCDABD3FEBD8B94FF19D83F65F
        ACEFB8086E654CBB4E240F41FF00F9E772E9BFC68751FB0BFA35B59FD3D190EC
        86B7CABF4FFEFC55BFAE3D22BEB39DF57B2EA1BAAB32032C3E353C0CAD7FEB78
        F6A4A76FA4F4CA71FEAFE3745BB471C4F4ED61E4EE6EDC83B7FE32D5E4DF557A
        4D96FD70C4C0B5B271B20BAD1DBF572EB1FBBFB556D5DEE475F15FF8CAA3A7EE
        8ABECBF6678EDEA3FF005C6FF9DB69AD4BA474318DF5FBABE7B9B150A596D64E
        803B235B1FFE7E3E424A793FF1A7D43ED1F585988D3EDC2A5AD70FE5D9FA677F
        E06EA571AAEF5BCF3D4BAC66674C8C8B9EF67F527F443FB35ED5492529249249
        4A4924925292492494A49249253FFFD1E194AB7BAB787B796EA1452492090410
        688D410EA32E6DCC0E6E9E23C11B1BE8BBE2B1D963AB76E6982AD37A81656435
        BEF2793C2CFCBC9CAFF57AC49FF15E9792F8E62310799263920353117EEFF77F
        AED9CDCDB98DF4FD5712786C9595CEA9DCE73DC5CE324F2532B78308C51ADC9F
        98B8BCFF003A79ACA675C101A421D87797F5A4A5DF7D6FFAD5D0FA97D54C4E9F
        85906DCBADD49B2BD8F6EDD8C731FEFB18DAFE97EE397029295A6F73FE2FBEB7
        F4DE958995D37AC5BE9633CFA9438B1D60970D97545B536C77BA18EFFB715DE9
        5F5A7EAADBD3F2BEAC753B1C7A635EF661E56D780EA4BCDD407FB7D5AADA1DF4
        1EEAD79CA4929EE7F637F8B1C326EBBAADF96D13B6966A4F91F4696BBFE9D481
        D3BA7FF8BDEA3D3715D959B674ECFAEB6B729A0901EE1F4ACFD2D7757EEFF827
        FF00D6D71A924A7BFF00ACFF005D7A536BE97D3BA31764E3F4CBA8BDD73811BB
        ECFA55537D40D7BFFE12C5A1F593AA7D41FAC186DCEC9CB3F69C7A9FE8D6DDED
        797112DAACAF63BFC27FEAC5E60924A7D2FA4FD65FA9977D51C6E89D6328B62B
        6B6FA432E9963FD56FE928ADDF9CD67D17A6C4FAC3FE2DFEAF1764F48A9F9195
        B486B836C2ED7F345999B3D2FE5FA6BCD52494EA7D64FAC397F583A93B37207A
        6D036534832D6307E6FF0029DFBEF5DF7D55FAF7F5768E83858DD5327D2CBC36
        FA7B4D763F466EAEA731F557637F983B1796A4929D6CCEB8FB7EB43FAE573A65
        8BEA1DF631F3530FFD69AD62F42EBBFE303EAD3FA3E67ECEC93667E4506AADBE
        958D702E0E6B773ECADB5FE87D57BFE9AF274925292492494A49249252924924
        94A4924925292492494FFFD2E192586924A7712586924A7712586924A7712586
        924A7712586924A7712586924A7712586924A7712586924A7712586924A77125
        86924A7712586924A7712586924A7712586924A7712586924A7712586924A7FF
        D9}
      Transparent = True
    end
    object paPortugues: TPanel
      Left = 428
      Top = 10
      Width = 59
      Height = 37
      Anchors = [akTop, akRight]
      BevelOuter = bvNone
      Caption = 'paPortugues'
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object Image3: TImage
        Left = 0
        Top = 0
        Width = 59
        Height = 37
        Cursor = crHandPoint
        Align = alClient
        AutoSize = True
        Center = True
        Picture.Data = {
          0A544A504547496D6167654D2C0000FFD8FFE1066E4578696600004D4D002A00
          0000080007011200030000000100010000011A00050000000100000062011B00
          05000000010000006A0128000300000001000200000131000200000022000000
          720132000200000014000000948769000400000001000000A8000000D4000AFC
          8000002710000AFC800000271041646F62652050686F746F73686F7020434320
          32303138202857696E646F77732900323031383A30383A30332030383A30333A
          3336000003A001000300000001FFFF0000A00200040000000100000037A00300
          0400000001000000210000000000000006010300030000000100060000011A00
          050000000100000122011B0005000000010000012A0128000300000001000200
          0002010004000000010000013202020004000000010000053400000000000000
          48000000010000004800000001FFD8FFED000C41646F62655F434D0002FFEE00
          0E41646F626500648000000001FFDB0084000C08080809080C09090C110B0A0B
          11150F0C0C0F1518131315131318110C0C0C0C0C0C110C0C0C0C0C0C0C0C0C0C
          0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C010D0B0B0D0E0D100E0E10140E0E
          0E14140E0E0E0E14110C0C0C0C0C11110C0C0C0C0C0C110C0C0C0C0C0C0C0C0C
          0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0CFFC00011080021003703012200
          021101031101FFDD00040004FFC4013F00000105010101010101000000000000
          00030001020405060708090A0B01000105010101010101000000000000000100
          02030405060708090A0B1000010401030204020507060805030C330100021103
          04211231054151611322718132061491A1B14223241552C16233347282D14307
          259253F0E1F163733516A2B283264493546445C2A3743617D255E265F2B384C3
          D375E3F3462794A485B495C4D4E4F4A5B5C5D5E5F55666768696A6B6C6D6E6F6
          37475767778797A7B7C7D7E7F711000202010204040304050607070605350100
          021103213112044151617122130532819114A1B14223C152D1F0332462E17282
          92435315637334F1250616A2B283072635C2D2449354A317644555367465E2F2
          B384C3D375E3F34694A485B495C4D4E4F4A5B5C5D5E5F55666768696A6B6C6D6
          E6F62737475767778797A7B7C7FFDA000C03010002110311003F00CA3C9495EE
          9DD1F3BA9585B8CCF6030FB5DA307CD75FD2BEAC6074F8B2C1F68C81AEF78D01
          FF0083AD61F37F11C1CB6923C53FF371F9BFF4170395E4337306E238617F3CBE
          5FA7EF3CDF4BFAB19D9A05B7FEAB8DC97BFE911FC861FF00AA7AD977D5FF00AB
          79550C5C4C9AFED2DE1ECB5AF793FCBAF77B9627D7FCDB32B2474F6F54A3171A
          A6CDB8FF00A42F73E7FC3FA75B9BB3F719BD726CFABB73FDDD3B371B2AD6C10D
          A9E6B7CFF25B7B697EFF00EAAD6F87FF00C5ECFF0010E571F39CC73B2E4BDCF5
          E0C38F1CA51847FC9CB3E59F0C65C5FBAEA4796E5B05E3E0F74ED394FF00EE7F
          75E97A9F43EA1D35C4DCCDF4F6B99AB7FB5FE8FF00B4B3D75FF527AAE767E0DF
          D3FABB1DF6DC121967AA3DCFADE0FA6EB377D3FA2E6EEFCF44EABF5431EF9B7A
          79145BC9A8FF00367E1FE8D63E7E6E5C8F399391E74C78F110067C7AE2C9190E
          3864FF000E1EA6BE7F84F147DCE5BD513AFB72F9BFC193C68E52566DE9B9B4E6
          370ADA8B2FB1C18C07825C76B76BFE8EDDC92B9EEC3838F8C7055F1DE95DDCBF
          6E7C5C1C278EEB86B5B7FFD0A985D4B33A7DC6CC5B0B09FA4DE5AEFEB3175FD2
          7EB5E1E6EDA72631B20E9A9F638FF21FFF00925C31E4A4B139BE4307323D71A9
          F49C7497FE84F3FCAF3D9B973E9371FDC97CBFFA0B3FF185D23230BABD9D4430
          9C4CD2D78B5BC0B40DAEAEC3FCAFA6C5CA39AD243843789EDF35DEF4EFAC1938
          95FD9B21A33309DA3A8B7DDA7F20BA7FE92D1FB67D4CC3ADB9985D3AA396756D
          62B00B4FF2C996B3FB0BA0F867FC69CDF0EE4F17279F959F352C51F6B0E6C128
          D64847E419E393F9BE174E1CCF2F9AE7C6311DE509FF00DC7EF36BEA3B3A8E3F
          42FB47567ED6B8CD0EB801636903DBEB58EF76D73BDD5EF51EADF5C58C9A7A68
          DEEE0DEE1ED1FF0016DFCFFED2E7FA9F59CFEA6F9C87C56356D2DD183FF25FDB
          54573DCC729F7DE772F3DCD46319E69710C18FF9AC711E9847FAED7CFF001522
          3ED72FE988D3DC3F3CBFBA3F453BB3329F9232ACB5CEC8690E6D84C9047B9B1F
          D5490024ADF04387838470EDC35A399C72BE2E23C577C57ABFFFD1CD3C94979E
          24A83CB3E86123C85E789232DBED48DDF434979E2487643E86125E7892497FFF
          D9FFED0E9250686F746F73686F7020332E30003842494D042500000000001000
          0000000000000000000000000000003842494D043A0000000000F90000001000
          00000100000000000B7072696E744F7574707574000000050000000050737453
          626F6F6C0100000000496E7465656E756D00000000496E746500000000496D67
          200000000F7072696E745369787465656E426974626F6F6C000000000B707269
          6E7465724E616D65544558540000000100000000000F7072696E7450726F6F66
          53657475704F626A63000000160043006F006E00660069006700750072006100
          E700E3006F002000640065002000500072006F0076006100000000000A70726F
          6F6653657475700000000100000000426C746E656E756D0000000C6275696C74
          696E50726F6F660000000970726F6F66434D594B003842494D043B0000000002
          2D00000010000000010000000000127072696E744F75747075744F7074696F6E
          7300000017000000004370746E626F6F6C0000000000436C6272626F6F6C0000
          0000005267734D626F6F6C000000000043726E43626F6F6C0000000000436E74
          43626F6F6C00000000004C626C73626F6F6C00000000004E677476626F6F6C00
          00000000456D6C44626F6F6C0000000000496E7472626F6F6C00000000004263
          6B674F626A630000000100000000000052474243000000030000000052642020
          646F7562406FE000000000000000000047726E20646F7562406FE00000000000
          00000000426C2020646F7562406FE000000000000000000042726454556E7446
          23526C74000000000000000000000000426C6420556E744623526C7400000000
          000000000000000052736C74556E74462350786C40520000000000000000000A
          766563746F7244617461626F6F6C010000000050675073656E756D0000000050
          6750730000000050675043000000004C656674556E744623526C740000000000
          00000000000000546F7020556E744623526C7400000000000000000000000053
          636C20556E74462350726340590000000000000000001063726F705768656E50
          72696E74696E67626F6F6C000000000E63726F7052656374426F74746F6D6C6F
          6E67000000000000000C63726F70526563744C6566746C6F6E67000000000000
          000D63726F705265637452696768746C6F6E67000000000000000B63726F7052
          656374546F706C6F6E6700000000003842494D03ED0000000000100048000000
          01000100480000000100013842494D042600000000000E000000000000000000
          003F8000003842494D040D0000000000040000005A3842494D04190000000000
          040000001E3842494D03F3000000000009000000000000000001003842494D27
          1000000000000A000100000000000000013842494D03F5000000000048002F66
          660001006C66660006000000000001002F6666000100A1999A00060000000000
          01003200000001005A00000006000000000001003500000001002D0000000600
          00000000013842494D03F80000000000700000FFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFF03E800000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFF03E800000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FF03E800000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF03E800
          003842494D040000000000000200013842494D04020000000000040000000038
          42494D043000000000000201013842494D042D00000000000600010000000238
          42494D0408000000000010000000010000024000000240000000003842494D04
          1E000000000004000000003842494D041A00000000034D000000060000000000
          00000000000021000000370000000C00530065006D0020005400ED0074007500
          6C006F002D003200000001000000000000000000000000000000000000000100
          0000000000000000000037000000210000000000000000000000000000000001
          0000000000000000000000000000000000000010000000010000000000006E75
          6C6C0000000200000006626F756E64734F626A63000000010000000000005263
          74310000000400000000546F70206C6F6E6700000000000000004C6566746C6F
          6E67000000000000000042746F6D6C6F6E670000002100000000526768746C6F
          6E670000003700000006736C69636573566C4C73000000014F626A6300000001
          000000000005736C6963650000001200000007736C69636549446C6F6E670000
          00000000000767726F757049446C6F6E6700000000000000066F726967696E65
          6E756D0000000C45536C6963654F726967696E0000000D6175746F47656E6572
          617465640000000054797065656E756D0000000A45536C696365547970650000
          0000496D672000000006626F756E64734F626A63000000010000000000005263
          74310000000400000000546F70206C6F6E6700000000000000004C6566746C6F
          6E67000000000000000042746F6D6C6F6E670000002100000000526768746C6F
          6E67000000370000000375726C54455854000000010000000000006E756C6C54
          455854000000010000000000004D736765544558540000000100000000000661
          6C74546167544558540000000100000000000E63656C6C54657874497348544D
          4C626F6F6C010000000863656C6C546578745445585400000001000000000009
          686F727A416C69676E656E756D0000000F45536C696365486F727A416C69676E
          0000000764656661756C740000000976657274416C69676E656E756D0000000F
          45536C69636556657274416C69676E0000000764656661756C740000000B6267
          436F6C6F7254797065656E756D0000001145536C6963654247436F6C6F725479
          7065000000004E6F6E6500000009746F704F75747365746C6F6E670000000000
          00000A6C6566744F75747365746C6F6E67000000000000000C626F74746F6D4F
          75747365746C6F6E67000000000000000B72696768744F75747365746C6F6E67
          00000000003842494D042800000000000C000000023FF0000000000000384249
          4D041100000000000101003842494D0414000000000004000000023842494D04
          0C000000000550000000010000003700000021000000A8000015A80000053400
          180001FFD8FFED000C41646F62655F434D0002FFEE000E41646F626500648000
          000001FFDB0084000C08080809080C09090C110B0A0B11150F0C0C0F15181313
          15131318110C0C0C0C0C0C110C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C
          0C0C0C0C0C0C0C0C010D0B0B0D0E0D100E0E10140E0E0E14140E0E0E0E14110C
          0C0C0C0C11110C0C0C0C0C0C110C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C
          0C0C0C0C0C0C0C0C0CFFC00011080021003703012200021101031101FFDD0004
          0004FFC4013F0000010501010101010100000000000000030001020405060708
          090A0B0100010501010101010100000000000000010002030405060708090A0B
          1000010401030204020507060805030C33010002110304211231054151611322
          718132061491A1B14223241552C16233347282D14307259253F0E1F163733516
          A2B283264493546445C2A3743617D255E265F2B384C3D375E3F3462794A485B4
          95C4D4E4F4A5B5C5D5E5F55666768696A6B6C6D6E6F637475767778797A7B7C7
          D7E7F71100020201020404030405060707060535010002110321311204415161
          7122130532819114A1B14223C152D1F0332462E1728292435315637334F12506
          16A2B283072635C2D2449354A317644555367465E2F2B384C3D375E3F34694A4
          85B495C4D4E4F4A5B5C5D5E5F55666768696A6B6C6D6E6F62737475767778797
          A7B7C7FFDA000C03010002110311003F00CA3C9495EE9DD1F3BA9585B8CCF603
          0FB5DA307CD75FD2BEAC6074F8B2C1F68C81AEF78D01FF0083AD61F37F11C1CB
          6923C53FF371F9BFF4170395E4337306E238617F3CBE5FA7EF3CDF4BFAB19D9A
          05B7FEAB8DC97BFE911FC861FF00AA7AD977D5FF00AB79550C5C4C9AFED2DE1E
          CB5AF793FCBAF77B9627D7FCDB32B2474F6F54A3171AA6CDB8FF00A42F73E7FC
          3FA75B9BB3F719BD726CFABB73FDDD3B371B2AD6C10DA9E6B7CFF25B7B697EFF
          00EAAD6F87FF00C5ECFF0010E571F39CC73B2E4BDCF5E0C38F1CA51847FC9CB3
          E59F0C65C5FBAEA4796E5B05E3E0F74ED394FF00EE7F75E97A9F43EA1D35C4DC
          CDF4F6B99AB7FB5FE8FF00B4B3D75FF527AAE767E0DFD3FABB1DF6DC121967AA
          3DCFADE0FA6EB377D3FA2E6EEFCF44EABF5431EF9B7A79145BC9A8FF00367E1F
          E8D63E7E6E5C8F399391E74C78F110067C7AE2C9190E3864FF000E1EA6BE7F84
          F147DCE5BD513AFB72F9BFC193C68E52566DE9B9B4E6370ADA8B2FB1C18C0782
          5C76B76BFE8EDDC92B9EEC3838F8C7055F1DE95DDCBF6E7C5C1C278EEB86B5B7
          FFD0A985D4B33A7DC6CC5B0B09FA4DE5AEFEB3175FD27EB5E1E6EDA72631B20E
          9A9F638FF21FFF00925C31E4A4B139BE4307323D71A9F49C7497FE84F3FCAF3D
          9B973E9371FDC97CBFFA0B3FF185D23230BABD9D44309C4CD2D78B5BC0B40DAE
          AEC3FCAFA6C5CA39AD243843789EDF35DEF4EFAC193895FD9B21A33309DA3A8B
          7DDA7F20BA7FE92D1FB67D4CC3ADB9985D3AA396756D62B00B4FF2C996B3FB0B
          A0F867FC69CDF0EE4F17279F959F352C51F6B0E6C128D64847E419E393F9BE17
          4E1CCF2F9AE7C6311DE509FF00DC7EF36BEA3B3A8E3F42FB47567ED6B8CD0EB8
          01636903DBEB58EF76D73BDD5EF51EADF5C58C9A7A68DEEE0DEE1ED1FF0016DF
          CFFED2E7FA9F59CFEA6F9C87C56356D2DD183FF25FDB54573DCC729F7DE772F3
          DCD46319E69710C18FF9AC711E9847FAED7CFF0015223ED72FE988D3DC3F3CBF
          BA3F453BB3329F9232ACB5CEC8690E6D84C9047B9B1FD5490024ADF043878384
          70EDC35A399C72BE2E23C577C57ABFFFD1CD3C94979E24A83CB3E86123C85E78
          9232DBED48DDF434979E2487643E86125E7892497FFFD93842494D0421000000
          00005D00000001010000000F00410064006F00620065002000500068006F0074
          006F00730068006F00700000001700410064006F00620065002000500068006F
          0074006F00730068006F00700020004300430020003200300031003800000001
          003842494D04060000000000070006000000010100FFE10DDB687474703A2F2F
          6E732E61646F62652E636F6D2F7861702F312E302F003C3F787061636B657420
          626567696E3D22EFBBBF222069643D2257354D304D7043656869487A7265537A
          4E54637A6B633964223F3E203C783A786D706D65746120786D6C6E733A783D22
          61646F62653A6E733A6D6574612F2220783A786D70746B3D2241646F62652058
          4D5020436F726520352E362D633134322037392E3136303932342C2032303137
          2F30372F31332D30313A30363A33392020202020202020223E203C7264663A52
          444620786D6C6E733A7264663D22687474703A2F2F7777772E77332E6F72672F
          313939392F30322F32322D7264662D73796E7461782D6E7323223E203C726466
          3A4465736372697074696F6E207264663A61626F75743D222220786D6C6E733A
          786D703D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E30
          2F2220786D6C6E733A786D704D4D3D22687474703A2F2F6E732E61646F62652E
          636F6D2F7861702F312E302F6D6D2F2220786D6C6E733A73744576743D226874
          74703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F73547970652F
          5265736F757263654576656E74232220786D6C6E733A64633D22687474703A2F
          2F7075726C2E6F72672F64632F656C656D656E74732F312E312F2220786D6C6E
          733A70686F746F73686F703D22687474703A2F2F6E732E61646F62652E636F6D
          2F70686F746F73686F702F312E302F2220786D703A43726561746F72546F6F6C
          3D2241646F62652050686F746F73686F702043432032303138202857696E646F
          7773292220786D703A437265617465446174653D22323031382D30382D303354
          30383A30333A33362D30333A30302220786D703A4D6574616461746144617465
          3D22323031382D30382D30335430383A30333A33362D30333A30302220786D70
          3A4D6F64696679446174653D22323031382D30382D30335430383A30333A3336
          2D30333A30302220786D704D4D3A496E7374616E636549443D22786D702E6969
          643A63613831326365302D383938612D326134662D396535342D336262346231
          3930626231362220786D704D4D3A446F63756D656E7449443D2261646F62653A
          646F6369643A70686F746F73686F703A66353666363833622D323032302D3034
          34652D623761372D3436303962663033626638322220786D704D4D3A4F726967
          696E616C446F63756D656E7449443D22786D702E6469643A6337363365343535
          2D633133332D313334662D386633312D66383963393836313132303622206463
          3A666F726D61743D22696D6167652F6A706567222070686F746F73686F703A43
          6F6C6F724D6F64653D2233223E203C786D704D4D3A486973746F72793E203C72
          64663A5365713E203C7264663A6C692073744576743A616374696F6E3D226372
          6561746564222073744576743A696E7374616E636549443D22786D702E696964
          3A63373633653435352D633133332D313334662D386633312D66383963393836
          3131323036222073744576743A7768656E3D22323031382D30382D3033543038
          3A30333A33362D30333A3030222073744576743A736F6674776172654167656E
          743D2241646F62652050686F746F73686F702043432032303138202857696E64
          6F777329222F3E203C7264663A6C692073744576743A616374696F6E3D227361
          766564222073744576743A696E7374616E636549443D22786D702E6969643A63
          613831326365302D383938612D326134662D396535342D336262346231393062
          623136222073744576743A7768656E3D22323031382D30382D30335430383A30
          333A33362D30333A3030222073744576743A736F6674776172654167656E743D
          2241646F62652050686F746F73686F702043432032303138202857696E646F77
          7329222073744576743A6368616E6765643D222F222F3E203C2F7264663A5365
          713E203C2F786D704D4D3A486973746F72793E203C2F7264663A446573637269
          7074696F6E3E203C2F7264663A5244463E203C2F783A786D706D6574613E2020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          202020202020202020202020202020202020202020202020202020202020203C
          3F787061636B657420656E643D2277223F3EFFEE000E41646F62650064400000
          0001FFDB00840002020202020202020202030202020304030202030405040404
          04040506050505050505060607070807070609090A0A09090C0C0C0C0C0C0C0C
          0C0C0C0C0C0C0C01030303050405090606090D0A090A0D0F0E0E0E0E0F0F0C0C
          0C0C0C0F0F0C0C0C0C0C0C0F0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C
          0C0C0C0C0C0C0C0CFFC00011080021003703011100021101031101FFDD000400
          07FFC401A2000000070101010101000000000000000004050302060100070809
          0A0B0100020203010101010100000000000000010002030405060708090A0B10
          0002010303020402060703040206027301020311040005211231415106136122
          7181143291A10715B14223C152D1E1331662F0247282F12543345392A2B26373
          C235442793A3B33617546474C3D2E2082683090A181984944546A4B456D35528
          1AF2E3F3C4D4E4F465758595A5B5C5D5E5F566768696A6B6C6D6E6F637475767
          778797A7B7C7D7E7F738485868788898A8B8C8D8E8F82939495969798999A9B9
          C9D9E9F92A3A4A5A6A7A8A9AAABACADAEAFA1100020201020305050405060408
          03036D0100021103042112314105511361220671819132A1B1F014C1D1E12342
          15526272F1332434438216925325A263B2C20773D235E2448317549308090A18
          192636451A2764745537F2A3B3C32829D3E3F38494A4B4C4D4E4F465758595A5
          B5C5D5E5F5465666768696A6B6C6D6E6F6475767778797A7B7C7D7E7F7384858
          68788898A8B8C8D8E8F839495969798999A9B9C9D9E9F92A3A4A5A6A7A8A9AAA
          BACADAEAFAFFDA000C03010002110311003F00E08E2B23FF00AC76FA73CEE5E9
          E4FC912E6B0EDB5684F6EFF76480B22BE2CA1124BE95FCAEFF009C63F3B79F22
          8B59D781F2579478FAD2EAB7ABC6E65886E4C30350A8A7EDC941E15CF39F693F
          E08DA5ECDFF06D38F1F289570C45EFE75BBE83ECDFFC0F75BDAA465C91F0B09F
          E296D63C83E949BFE71FFF00E71C3CD9A541E50F2779E3494F375906106A5A7E
          B76BA85FCB2756FAC5AACCDEA0FF002555699C50ED9F6DF4790F696A34393F2E
          7A189E003C8F3D9F58CDFF0003AEC6C9A5F02278663F8C73BF37C71F99BF921E
          7FFCAD9E5975CD3BEBFA1172B6FE66B20D25A36F4024DB942D4FD97FA09CF40F
          663DBDD076C4042C4331E62468BE33ED27B09DA1D8C78A50E3C5FCF8EFF3EE78
          F29E3B9EBD875073B980B1777F73C61813C97AD79FD9A1E2DF0FFB138833EA37
          EE4D46E81B1DEFFFD089FE5E7E5079E3F34AFE483CB1A59FA84337A7A86BB775
          8ECA0AEF467A12CD4FD8504FEBCF19F683DA8D2F6260F133CABCBA9F73F35F61
          FB33ACED9CDC1A78DC6F79748FBDFA39F955FF0038C9E43FCB936DAA6A312F9B
          BCD09473AADEC7FB98241DEDAD8D5529D99AADEE33E6DF6AFF00E09DABED6071
          60BC5889E9F54BC8BF417B37FF00038D1765C864CDFBDCA075FA627BC0FD6F87
          3FE73EFCE97DE6DF31C5F96F6FF9EDE5AF25794745B4593CC1E4E56D51EFEEAF
          19C02FA97D56D248CC4A0811C6246DEACC2B4E3F777FCB177FC0DB47A3D09F68
          F59D9B9757AA9C8C71CBD26108D7D6048EF296E0DDB9DED376864C67C38CB6EE
          0FCF9B2FF9C77D5AFC8BBFCB4FCCBF27F9E75BB3314B058691A849A66A0B21E5
          C1628F528ACA532FC355083A6F5CFBDB37B5BA3C6062D7767CB06295826508CA
          355FD1B7908E4955EE1FB2FF00F3853F9A9E78FCC4F2479AFF002DBF3A34FBB3
          F983F9693DBD8EABFA66022E6F74CBD490DB49742414958189D0BEFCD42B6F5A
          9FCAAFF96C9FF81B762FB2FDA3A5EDAEC29C61875C647821B08E485194AB98E2
          279793DF7B3FAC96B709C7940901B6FDC9AFE6B7FCE217977CC1F59D63F2E258
          FCAFABB7291F419B91D3676EB4422AD013EC0AFF009233C0BD93FF0082D6AB43
          5875D7971F7F50F25ED3FF00C0BB49AE072E8BF7793BBF84BE0BD4BF2DBCE9A1
          79C2C3C8DACE85369DE63D5AE62B2D2EDA72162B892E1C4313453FF76C8CEC07
          2076EF9EFF00A3F6AB45AAD14F5B8E64E28C65227B840127E54F866ABD98D6E9
          75B1D1E48819272111EF99A1F3B7FFD1E7BE4AFCC7F397E5C6B0FAA79475A9F4
          D7773F5CB124C96B7001D96681BE13E151BF8119E41DB7D81A2ED6C5E0EA31F1
          79F51EE7E63EC8EDFD6F654F8B4D9384FD87DEFD18FCA6FF009CAAF27F9E8DAE
          8DE69F4FC9FE679488D04CFF00E8375274AC3337D927B2BD0F8139F3AFB57FF0
          27D67674A59747FBCC637F3887DFBD96FF008266975C062D50F0F2F7FF0009FD
          4FCBCFF9F83FE516BDE44FCDDD5BF3361D3AE1FC8DF98F25BEA11EBB665BD283
          568E1F4E6B6BA71B2993889236A8A866A55867E90FFCB0FF00FC14F43ADEC03D
          83ADCD0C7ABC133509FA49C6680ABEAECBDA3D14C6419A02E07A87E7EDC5BC32
          CB05C42D15A2F18D9F8A989941DD5D4333163B52AA295009FB55CFBE679462C7
          21900E104FAA55C3F13D07BDE6BFBC96CFE843FE7082D3F31BCBBF91ADE63FCE
          4D48DB5BDECE27F2A5E6BB1A41A9DBE851A7EEBEBD73252428EE59E25918F153
          51F6F3F1CBFE5B6BDA4EC4ED9EDFD3F66763438F260B394E33C58CCE7B5440BA
          208DFBDEDBD9DC434B8279721E11E7B20FF367FE730EC6C96E744FCACB75D4EF
          05639BCDB749FE8C87A7FA2C245653E0CE02FB1CF03F647FE0459B51C39FB40F
          0439888E67DEF15ED4FF00C14B069F8B0680714F919741EE7C273F9BFCD17FE6
          68BCDDA86BF797BE66B7B84BCB6D6A77324B1CD037A913A5410A11802140A0F0
          CF7CD2FB3FA3D3E965A5863031CA262477890A3F37C473F6E6B33EAA3A99E427
          24642425DC626C7C9FFFD2E0727F78FF00EB1FD79E78FC9279ADA02082390EE3
          B60AB2077FDA98F3E74F7EFCBCFF009C80F32F9434E6F2BF99AC6DFF0030BF2F
          EE93D0BCF2A6B2AB71C62EB485E557000ECAE196BD38E717DAFEC761D466FCD6
          9652D36AA1BC7263D8DFC1EEFD9BF6F759D947C2C87C5C3D632FD0F661E72FF9
          C33F255859F9DBC8FF00937A0CFE759897B1D193498619ACE71404CCEEAF1C2B
          53B18C372FD91DF3473EDBFF0082676913A1D476BEA0E9B9126668C7BA9F51CB
          EDF76163D378D8F1DE4E90ADEFDFC9F38FE667E7279EBF356EDA5F326ABE9E99
          1BF3B3F2EDA728ACA2F7E35AC8C3F99EA7C2836CE87D9FF62745D923C48032C9
          2FAA72DC93EFFD0F907B49ED9EBFB6A5594F0C3A462680F7F7BCA7DFA573B08F
          A453C89DD727DA3FEAB7FC44E36A1FFFD3E2F27F78FF00EB1FD79E7C5F93CF36
          97A37CB227EA0C4BA3EF9971FA9965E6D3FF00789F2FE2330A5FDD9FEB16ED3F
          571E833261F434752B4E55D542F8FA9FF55BFE2270F548E6FF00FFD9}
        Transparent = True
      end
    end
    object paEspanhol: TPanel
      Left = 496
      Top = 10
      Width = 59
      Height = 37
      Anchors = [akTop, akRight]
      BevelOuter = bvNone
      Caption = 'paPortugues'
      Color = 2763306
      ParentBackground = False
      TabOrder = 1
      object Image4: TImage
        Left = 4
        Top = 0
        Width = 55
        Height = 37
        Cursor = crHandPoint
        Align = alRight
        AutoSize = True
        Center = True
        Picture.Data = {
          0A544A504547496D61676525270000FFD8FFE1054B4578696600004D4D002A00
          0000080007011200030000000100010000011A00050000000100000062011B00
          05000000010000006A0128000300000001000200000131000200000022000000
          720132000200000014000000948769000400000001000000A8000000D4000AFC
          8000002710000AFC800000271041646F62652050686F746F73686F7020434320
          32303138202857696E646F77732900323031383A30383A30332030383A30343A
          3538000003A001000300000001FFFF0000A00200040000000100000037A00300
          0400000001000000210000000000000006010300030000000100060000011A00
          050000000100000122011B0005000000010000012A0128000300000001000200
          0002010004000000010000013202020004000000010000041100000000000000
          48000000010000004800000001FFD8FFED000C41646F62655F434D0002FFEE00
          0E41646F626500648000000001FFDB0084000C08080809080C09090C110B0A0B
          11150F0C0C0F1518131315131318110C0C0C0C0C0C110C0C0C0C0C0C0C0C0C0C
          0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C010D0B0B0D0E0D100E0E10140E0E
          0E14140E0E0E0E14110C0C0C0C0C11110C0C0C0C0C0C110C0C0C0C0C0C0C0C0C
          0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0CFFC00011080021003703012200
          021101031101FFDD00040004FFC4013F00000105010101010101000000000000
          00030001020405060708090A0B01000105010101010101000000000000000100
          02030405060708090A0B1000010401030204020507060805030C330100021103
          04211231054151611322718132061491A1B14223241552C16233347282D14307
          259253F0E1F163733516A2B283264493546445C2A3743617D255E265F2B384C3
          D375E3F3462794A485B495C4D4E4F4A5B5C5D5E5F55666768696A6B6C6D6E6F6
          37475767778797A7B7C7D7E7F711000202010204040304050607070605350100
          021103213112044151617122130532819114A1B14223C152D1F0332462E17282
          92435315637334F1250616A2B283072635C2D2449354A317644555367465E2F2
          B384C3D375E3F34694A485B495C4D4E4F4A5B5C5D5E5F55666768696A6B6C6D6
          E6F62737475767778797A7B7C7FFDA000C03010002110311003F00E775F04A17
          AE8C3C481FA1AFFCD1FDCB9EEB3F58F03A758C6D382DC96BF77E94001B2C3B2C
          67D073B731CD5C9E1F89CB34F831E0948FF783D70FF8C166872F67FBDFFA0BC1
          C25AAF50E959381D4686BFECCDA6E2D6BDF439A3735AF9F4DC7DBFE136ABBF63
          C4FF00435FF9A3FB9372FC5FDA9184F0CA328EE3895FF2847F98FF009DFF00A0
          BE4507C1283E0BD77EC789FE86BFF347F725F63C4FF435FF009A3FB947FE9B87
          F9A3FE32BFE508FF0031FF003FFF00417C8B5497AE9C3C5FF435FF009A3FB924
          7FD370AFE68FF8C8FF009422FF0098FF009FFF00A0BFFFD0F40FCDD3985E7DD5
          5D7D39232458DBADF7383C7E6C3AC6BAB63B6B1BFF00415D1FE30ADFFB84DFFB
          70FF00E4141DF5E9AE10EE9B5380E01778FF00D6D71FC872FCD72B394BDA12BA
          AA947F44F13BF8FE17CEC49BC1C7120831E288FDAEBFD577D8F93BC6CF459151
          32E6EBECDDB9BBDDF9DFE11742385C4B7EBF16FD1E9EC6E91A3E341FF5B52FFC
          70ADFF00B84DFF00B70FFE4147CF729CDF3598E5F6C46C01F347A2D97C279D32
          2461A04E838A0F6892E2FF00F1C2B7FEE137FEDC3FF904BFF1C2B7FEE137FEDC
          3FF90553FD13CDFEE0FF001823FD11CF7F9AFF009D0FFBE7B4292E2CFF008C2B
          7FEE137FEDC3FF0090491FF44F375F20FF00182BFD11CF7F9AFF009D0FFBE7FF
          D1E7525C624B15F4B7B349718924A7B349718924A7B3497189248EAFFFD9FFED
          0D7650686F746F73686F7020332E30003842494D042500000000001000000000
          0000000000000000000000003842494D043A0000000000F90000001000000001
          00000000000B7072696E744F7574707574000000050000000050737453626F6F
          6C0100000000496E7465656E756D00000000496E746500000000496D67200000
          000F7072696E745369787465656E426974626F6F6C000000000B7072696E7465
          724E616D65544558540000000100000000000F7072696E7450726F6F66536574
          75704F626A63000000160043006F006E00660069006700750072006100E700E3
          006F002000640065002000500072006F0076006100000000000A70726F6F6653
          657475700000000100000000426C746E656E756D0000000C6275696C74696E50
          726F6F660000000970726F6F66434D594B003842494D043B00000000022D0000
          0010000000010000000000127072696E744F75747075744F7074696F6E730000
          0017000000004370746E626F6F6C0000000000436C6272626F6F6C0000000000
          5267734D626F6F6C000000000043726E43626F6F6C0000000000436E7443626F
          6F6C00000000004C626C73626F6F6C00000000004E677476626F6F6C00000000
          00456D6C44626F6F6C0000000000496E7472626F6F6C000000000042636B674F
          626A630000000100000000000052474243000000030000000052642020646F75
          62406FE000000000000000000047726E20646F7562406FE00000000000000000
          00426C2020646F7562406FE000000000000000000042726454556E744623526C
          74000000000000000000000000426C6420556E744623526C7400000000000000
          000000000052736C74556E74462350786C40520000000000000000000A766563
          746F7244617461626F6F6C010000000050675073656E756D0000000050675073
          0000000050675043000000004C656674556E744623526C740000000000000000
          00000000546F7020556E744623526C7400000000000000000000000053636C20
          556E74462350726340590000000000000000001063726F705768656E5072696E
          74696E67626F6F6C000000000E63726F7052656374426F74746F6D6C6F6E6700
          0000000000000C63726F70526563744C6566746C6F6E67000000000000000D63
          726F705265637452696768746C6F6E67000000000000000B63726F7052656374
          546F706C6F6E6700000000003842494D03ED0000000000100048000000010001
          00480000000100013842494D042600000000000E000000000000000000003F80
          00003842494D040D0000000000040000005A3842494D04190000000000040000
          001E3842494D03F3000000000009000000000000000001003842494D27100000
          0000000A000100000000000000013842494D03F5000000000048002F66660001
          006C66660006000000000001002F6666000100A1999A00060000000000010032
          00000001005A00000006000000000001003500000001002D0000000600000000
          00013842494D03F80000000000700000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFF03E800000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFF03E800000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF03E8
          00000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF03E800003842
          494D040000000000000200033842494D04020000000000080000000000000000
          3842494D0430000000000004010101013842494D042D00000000000600010000
          00043842494D0408000000000010000000010000024000000240000000003842
          494D041E000000000004000000003842494D041A00000000034D000000060000
          00000000000000000021000000370000000C00530065006D0020005400ED0074
          0075006C006F002D003200000001000000000000000000000000000000000000
          0001000000000000000000000037000000210000000000000000000000000000
          0000010000000000000000000000000000000000000010000000010000000000
          006E756C6C0000000200000006626F756E64734F626A63000000010000000000
          00526374310000000400000000546F70206C6F6E6700000000000000004C6566
          746C6F6E67000000000000000042746F6D6C6F6E670000002100000000526768
          746C6F6E670000003700000006736C69636573566C4C73000000014F626A6300
          000001000000000005736C6963650000001200000007736C69636549446C6F6E
          67000000000000000767726F757049446C6F6E6700000000000000066F726967
          696E656E756D0000000C45536C6963654F726967696E0000000D6175746F4765
          6E6572617465640000000054797065656E756D0000000A45536C696365547970
          6500000000496D672000000006626F756E64734F626A63000000010000000000
          00526374310000000400000000546F70206C6F6E6700000000000000004C6566
          746C6F6E67000000000000000042746F6D6C6F6E670000002100000000526768
          746C6F6E67000000370000000375726C54455854000000010000000000006E75
          6C6C54455854000000010000000000004D736765544558540000000100000000
          0006616C74546167544558540000000100000000000E63656C6C546578744973
          48544D4C626F6F6C010000000863656C6C546578745445585400000001000000
          000009686F727A416C69676E656E756D0000000F45536C696365486F727A416C
          69676E0000000764656661756C740000000976657274416C69676E656E756D00
          00000F45536C69636556657274416C69676E0000000764656661756C74000000
          0B6267436F6C6F7254797065656E756D0000001145536C6963654247436F6C6F
          7254797065000000004E6F6E6500000009746F704F75747365746C6F6E670000
          00000000000A6C6566744F75747365746C6F6E67000000000000000C626F7474
          6F6D4F75747365746C6F6E67000000000000000B72696768744F75747365746C
          6F6E6700000000003842494D042800000000000C000000023FF0000000000000
          3842494D041100000000000101003842494D0414000000000004000000043842
          494D040C00000000042D000000010000003700000021000000A8000015A80000
          041100180001FFD8FFED000C41646F62655F434D0002FFEE000E41646F626500
          648000000001FFDB0084000C08080809080C09090C110B0A0B11150F0C0C0F15
          18131315131318110C0C0C0C0C0C110C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C
          0C0C0C0C0C0C0C0C0C0C0C010D0B0B0D0E0D100E0E10140E0E0E14140E0E0E0E
          14110C0C0C0C0C11110C0C0C0C0C0C110C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C
          0C0C0C0C0C0C0C0C0C0C0C0CFFC00011080021003703012200021101031101FF
          DD00040004FFC4013F0000010501010101010100000000000000030001020405
          060708090A0B0100010501010101010100000000000000010002030405060708
          090A0B1000010401030204020507060805030C33010002110304211231054151
          611322718132061491A1B14223241552C16233347282D14307259253F0E1F163
          733516A2B283264493546445C2A3743617D255E265F2B384C3D375E3F3462794
          A485B495C4D4E4F4A5B5C5D5E5F55666768696A6B6C6D6E6F637475767778797
          A7B7C7D7E7F71100020201020404030405060707060535010002110321311204
          4151617122130532819114A1B14223C152D1F0332462E1728292435315637334
          F1250616A2B283072635C2D2449354A317644555367465E2F2B384C3D375E3F3
          4694A485B495C4D4E4F4A5B5C5D5E5F55666768696A6B6C6D6E6F62737475767
          778797A7B7C7FFDA000C03010002110311003F00E775F04A17AE8C3C481FA1AF
          FCD1FDCB9EEB3F58F03A758C6D382DC96BF77E94001B2C3B2C67D073B731CD5C
          9E1F89CB34F831E0948FF783D70FF8C166872F67FBDFFA0BC1C25AAF50E95938
          1D4686BFECCDA6E2D6BDF439A3735AF9F4DC7DBFE136ABBF63C4FF00435FF9A3
          FB9372FC5FDA9184F0CA328EE3895FF2847F98FF009DFF00A0BE4507C1283E0B
          D77EC789FE86BFF347F725F63C4FF435FF009A3FB947FE9B87F9A3FE32BFE508
          FF0031FF003FFF00417C8B5497AE9C3C5FF435FF009A3FB9247FD370AFE68FF8
          C8FF009422FF0098FF009FFF00A0BFFFD0F40FCDD3985E7DD55D7D39232458DB
          ADF7383C7E6C3AC6BAB63B6B1BFF00415D1FE30ADFFB84DFFB70FF00E4141DF5
          E9AE10EE9B5380E01778FF00D6D71FC872FCD72B394BDA12BAAA947F44F13BF8
          FE17CEC49BC1C7120831E288FDAEBFD577D8F93BC6CF45915132E6EBECDDB9BB
          DDF9DFE11742385C4B7EBF16FD1E9EC6E91A3E341FF5B52FFC70ADFF00B84DFF
          00B70FFE4147CF729CDF3598E5F6C46C01F347A2D97C279D322461A04E838A0F
          6892E2FF00F1C2B7FEE137FEDC3FF904BFF1C2B7FEE137FEDC3FF90553FD13CD
          FEE0FF001823FD11CF7F9AFF009D0FFBE7B4292E2CFF008C2B7FEE137FEDC3FF
          0090491FF44F375F20FF00182BFD11CF7F9AFF009D0FFBE7FFD1E7525C624B15
          F4B7B349718924A7B349718924A7B3497189248EAFFFD9003842494D04210000
          0000005D00000001010000000F00410064006F00620065002000500068006F00
          74006F00730068006F00700000001700410064006F0062006500200050006800
          6F0074006F00730068006F007000200043004300200032003000310038000000
          01003842494D04060000000000070006000000010100FFE10DDB687474703A2F
          2F6E732E61646F62652E636F6D2F7861702F312E302F003C3F787061636B6574
          20626567696E3D22EFBBBF222069643D2257354D304D7043656869487A726553
          7A4E54637A6B633964223F3E203C783A786D706D65746120786D6C6E733A783D
          2261646F62653A6E733A6D6574612F2220783A786D70746B3D2241646F626520
          584D5020436F726520352E362D633134322037392E3136303932342C20323031
          372F30372F31332D30313A30363A33392020202020202020223E203C7264663A
          52444620786D6C6E733A7264663D22687474703A2F2F7777772E77332E6F7267
          2F313939392F30322F32322D7264662D73796E7461782D6E7323223E203C7264
          663A4465736372697074696F6E207264663A61626F75743D222220786D6C6E73
          3A786D703D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E
          302F2220786D6C6E733A786D704D4D3D22687474703A2F2F6E732E61646F6265
          2E636F6D2F7861702F312E302F6D6D2F2220786D6C6E733A73744576743D2268
          7474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F7354797065
          2F5265736F757263654576656E74232220786D6C6E733A64633D22687474703A
          2F2F7075726C2E6F72672F64632F656C656D656E74732F312E312F2220786D6C
          6E733A70686F746F73686F703D22687474703A2F2F6E732E61646F62652E636F
          6D2F70686F746F73686F702F312E302F2220786D703A43726561746F72546F6F
          6C3D2241646F62652050686F746F73686F702043432032303138202857696E64
          6F7773292220786D703A437265617465446174653D22323031382D30382D3033
          5430383A30343A35382D30333A30302220786D703A4D65746164617461446174
          653D22323031382D30382D30335430383A30343A35382D30333A30302220786D
          703A4D6F64696679446174653D22323031382D30382D30335430383A30343A35
          382D30333A30302220786D704D4D3A496E7374616E636549443D22786D702E69
          69643A38303963303366372D653531352D306634382D396232382D6565633532
          326161386164382220786D704D4D3A446F63756D656E7449443D2261646F6265
          3A646F6369643A70686F746F73686F703A32316239313361322D356136312D34
          3034302D393239622D6435636366666563653131392220786D704D4D3A4F7269
          67696E616C446F63756D656E7449443D22786D702E6469643A32353132666230
          642D386136362D303434382D613938372D356162303138306539333138222064
          633A666F726D61743D22696D6167652F6A706567222070686F746F73686F703A
          436F6C6F724D6F64653D2233223E203C786D704D4D3A486973746F72793E203C
          7264663A5365713E203C7264663A6C692073744576743A616374696F6E3D2263
          726561746564222073744576743A696E7374616E636549443D22786D702E6969
          643A32353132666230642D386136362D303434382D613938372D356162303138
          306539333138222073744576743A7768656E3D22323031382D30382D30335430
          383A30343A35382D30333A3030222073744576743A736F667477617265416765
          6E743D2241646F62652050686F746F73686F702043432032303138202857696E
          646F777329222F3E203C7264663A6C692073744576743A616374696F6E3D2273
          61766564222073744576743A696E7374616E636549443D22786D702E6969643A
          38303963303366372D653531352D306634382D396232382D6565633532326161
          38616438222073744576743A7768656E3D22323031382D30382D30335430383A
          30343A35382D30333A3030222073744576743A736F6674776172654167656E74
          3D2241646F62652050686F746F73686F702043432032303138202857696E646F
          777329222073744576743A6368616E6765643D222F222F3E203C2F7264663A53
          65713E203C2F786D704D4D3A486973746F72793E203C2F7264663A4465736372
          697074696F6E3E203C2F7264663A5244463E203C2F783A786D706D6574613E20
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          3C3F787061636B657420656E643D2277223F3EFFEE000E41646F626500644000
          000001FFDB008400020202020202020202020302020203040302020304050404
          0404040506050505050505060607070807070609090A0A09090C0C0C0C0C0C0C
          0C0C0C0C0C0C0C0C01030303050405090606090D0A090A0D0F0E0E0E0E0F0F0C
          0C0C0C0C0F0F0C0C0C0C0C0C0F0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C
          0C0C0C0C0C0C0C0C0CFFC00011080021003703011100021101031101FFDD0004
          0007FFC401A20000000701010101010000000000000000040503020601000708
          090A0B0100020203010101010100000000000000010002030405060708090A0B
          1000020103030204020607030402060273010203110400052112314151061361
          227181143291A10715B14223C152D1E1331662F0247282F12543345392A2B263
          73C235442793A3B33617546474C3D2E2082683090A181984944546A4B456D355
          281AF2E3F3C4D4E4F465758595A5B5C5D5E5F566768696A6B6C6D6E6F6374757
          67778797A7B7C7D7E7F738485868788898A8B8C8D8E8F82939495969798999A9
          B9C9D9E9F92A3A4A5A6A7A8A9AAABACADAEAFA11000202010203050504050604
          0803036D0100021103042112314105511361220671819132A1B1F014C1D1E123
          4215526272F1332434438216925325A263B2C20773D235E2448317549308090A
          18192636451A2764745537F2A3B3C32829D3E3F38494A4B4C4D4E4F465758595
          A5B5C5D5E5F5465666768696A6B6C6D6E6F6475767778797A7B7C7D7E7F73848
          5868788898A8B8C8D8E8F839495969798999A9B9C9D9E9F92A3A4A5A6A7A8A9A
          AABACADAEAFAFFDA000C03010002110311003F00F1AD1C8DD1BEE39E1E4889D8
          BFA8C3518081728FCC3B81EA54D3C69B7DF844C9E453E369FF009D1F986B89EC
          A4FC863663BDFDABE369FF009D1F985DC5FF0095BC3A1C8995EF69FCC60FE747
          E61AE0DFC8DF71C78BCC23C6D3FF003A3F30EE0DFC8DF71C78BCC2F8DA7FE747
          E61DC587EC350F5D8E106FA841CF807F147E61FFD0FAC31F947CA9E9C63FC35A
          583C47FC79C1FF003467E644FB575665FDF4B7F3E4FA1FF296A80FEF25FE98FE
          B7C77F9CBFF3915E44FCB2BFD32DB44FCAEB1F38D9EA1F5955D7A28A28A01359
          4ED05D4000B7772F13A10DD3C45467A9FB2BEC576876C43F7D9E58CEC447AD48
          5897B8FF006B9FA496B7538E594659011EF91FD6F75FCACF31F913F33342B4BF
          FF000459F97B5E7B1B7D4353F2B5E5A42D71696F7864FAAC8EDE928E3308D997
          A1A0DC6733ED7763768F606523C694E025C3C5BD7173E1F7D387935FAB84F84E
          597FA63FADEA43CA3E542011E5AD2F7FF97383FE68CE2E5DB3AC07FBD97CCB1F
          E52D57FAA4BFD31FD6DFF843CABFF52D697FF48707FCD183F96B59FEA92F995F
          E52D57FAA4BFD31FD6EFF087957FEA5AD2FF00E90E0FF9A31FE5AD67FAA4BE65
          7F94B55FEA92FF004C7F5AC7F27F956829E5AD2FED2FFC79C1E23FC8C947B6B5
          97FDE4BAF53DC83DA5AAFF005497FA63FADFFFD1FAFDFEE80547EF192AB5A0DE
          9B7B0CFCBA06375CB7DFF53DB75BEAFC78FCD4B8D7344F3241E678758B5D7F57
          4373709A9441795B18AEEF219AD609961852A5998B718FA9F858EC4FD9BEC8F6
          9E1D00D1CA5103188DF0F5AF3E7B7C5EEFB37B3B4FDB1D9B3C51C9C1C13B3C47
          626B97B9F637FCE2F5F6A17C6594EA29FA39FCB96061F2FC927A97564A1CAC3E
          AB490891C300E437AA47F32A9E25B88FF830F6BE3ED0EC996402313F9B3B0E77
          C1CFF43CB76C6931E935271477206E5F64A6EAB4F0CF97A7CCBAEAAD976415D8
          AAD7E82BFCCBFAC64A2B74FF00FFD2E94BFF003F06D4C2A8FF00955F6A6800AF
          E957FF00B25CF8D65FF021D2DFF7D3E7DC3F5BF5D8FF0080365947FC687FA5FD
          A95DC7FCE74DADDA2C775F927A2DCC6858A24B78AC017FB640367B16A6FE39B3
          C1FF0003CC980563D5E502ABA72F9B2FF930D980A1AA15EE3FAD1707FCE7C4B6
          A4B5AFE50E996AC51622D0EA1E99289F652AB68365EC3A0CC5D47FC0BE1A8159
          353925BDEF5CFBF9A25FF005CB23675409FEA9FD68CFFA284EABFF0096BED7FE
          E2AFFF0064B9867FE03FA426CE69FC87EB4FFC986CBFF2943FD2FED77FD14275
          5FFCB5F6BFF7157FFB25C1FF00267749FEAD3F90FD6BFF00261B2FFCA50FF4BF
          B5DFF4509D57FF002D7DAFFDC55FFEC971FF00933BA4FF00569FC87EB5FF0093
          0D97FE5287FA5FDAB5BFE7E11AA914FF0095616BD41FF8EABF635FF965C947FE
          03DA4BFEF67F21FAD89FF80365FF0094A1FE97F6BFFFD3F190ED9E207997F50E
          3C9BC09762AEC55D8ABB1570FE0708E6893FFFD9}
        Transparent = True
      end
    end
    object paIngles: TPanel
      Left = 564
      Top = 10
      Width = 59
      Height = 37
      Anchors = [akTop, akRight]
      BevelOuter = bvNone
      Caption = 'paPortugues'
      Color = 2763306
      ParentBackground = False
      TabOrder = 2
      object Image5: TImage
        Left = 4
        Top = 0
        Width = 55
        Height = 37
        Cursor = crHandPoint
        Align = alRight
        AutoSize = True
        Center = True
        Picture.Data = {
          0A544A504547496D616765262F0000FFD8FFE107424578696600004D4D002A00
          0000080007011200030000000100010000011A00050000000100000062011B00
          05000000010000006A0128000300000001000200000131000200000022000000
          720132000200000014000000948769000400000001000000A8000000D4000AFC
          8000002710000AFC800000271041646F62652050686F746F73686F7020434320
          32303138202857696E646F77732900323031383A30383A30332030383A30343A
          3331000003A001000300000001FFFF0000A00200040000000100000037A00300
          0400000001000000210000000000000006010300030000000100060000011A00
          050000000100000122011B0005000000010000012A0128000300000001000200
          0002010004000000010000013202020004000000010000060800000000000000
          48000000010000004800000001FFD8FFED000C41646F62655F434D0002FFEE00
          0E41646F626500648000000001FFDB0084000C08080809080C09090C110B0A0B
          11150F0C0C0F1518131315131318110C0C0C0C0C0C110C0C0C0C0C0C0C0C0C0C
          0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C010D0B0B0D0E0D100E0E10140E0E
          0E14140E0E0E0E14110C0C0C0C0C11110C0C0C0C0C0C110C0C0C0C0C0C0C0C0C
          0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0CFFC00011080021003703012200
          021101031101FFDD00040004FFC4013F00000105010101010101000000000000
          00030001020405060708090A0B01000105010101010101000000000000000100
          02030405060708090A0B1000010401030204020507060805030C330100021103
          04211231054151611322718132061491A1B14223241552C16233347282D14307
          259253F0E1F163733516A2B283264493546445C2A3743617D255E265F2B384C3
          D375E3F3462794A485B495C4D4E4F4A5B5C5D5E5F55666768696A6B6C6D6E6F6
          37475767778797A7B7C7D7E7F711000202010204040304050607070605350100
          021103213112044151617122130532819114A1B14223C152D1F0332462E17282
          92435315637334F1250616A2B283072635C2D2449354A317644555367465E2F2
          B384C3D375E3F34694A485B495C4D4E4F4A5B5C5D5E5F55666768696A6B6C6D6
          E6F62737475767778797A7B7C7FFDA000C03010002110311003F00C1AF2F0B39
          829BDADADFF9AC718649FF00B8F77B9D8EEFF82B3F5755B2FA5DF4EE75736319
          AB9B116307FC257FBBFF000ACFD1A5FB0BAD7FE57E47FDB4FF00FC8ABB898DF5
          868DACB3A7E4DB533E80F4DED7B3CE8B76EEAFFA9FCDAD638FD9B972D38F0F5C
          1397EACFFB397F9392C19E3CC011E7212E2DA3CCC07EBA3FEDA3FE5A3FF3DC4E
          472BA8B3FA43FF00F4DA3FF3C2067743B2DC7394FA2DC61C3AE7566B009ED934
          7F83FF008FC7FD1AB0F0C766BEB1657AE0FA5BF70D9BBD1D91EA7F5952F88737
          8F2C308F9270CB1E384B787FDF41D2F85723970CF99901EE639F2D9863C98F58
          48F0FCBFBD19FF0051E58111CFC55EC4E9775DB5D6CD4C7EB5B409B1FF00F155
          7EEFFC2D9FA35A783D11F5D032ABA2CCA8302F6D4EB06E1DB1688FD27FC75FFA
          241CBC7FAC378732AE9F95556FFA67D37BAC7FFC7DDB773FFA8DFD12BB2E6CE6
          261CB9888ED2CF93E4FF00A943FCA39C392C7CB8E2E6EE53FD1E5B1FF39FF569
          FF0092FF00D28A75B814460D6371B4863EBA9E00126272330FF3B637F719FABD
          692A5FB0BADFFE57E47FDB4FFF00C8A487DD306FEE9F7B7F7F8FF59FF7BC3FD4
          57FA473DF0FB51FBBEDF76E0FD4D7FD2E3FF0059C4FF00FFD0C2FB5F44FF004B
          99FF006D57FF00BD29C65F4424016E649E22AAFF00F7A567E2E05F932F115D2D
          30EB9FA341FDD1F9D659FC8AD696EC1E943DBBBD7FDED3D63FF54CC1AFFCFC95
          732F23C840F0471CB2653B63848F17F85FB8DDC1F16F8B648FB92CF1C5806F97
          242023E50F4FEB27FDC6CDB858828739965EDBC09F46E631BB5BFE9321CDBACF
          41BFC97FE9104F4E70C8341B5800ABD7F5752CDBB3D6F0DDF47F92B272B36FC9
          1B4C32A065B5374683FBC7F7DFFCB7AE82DFE90FFF00D368FF00CF0A9737F0D8
          E28E39CBD32CB9230E089D2103FD63F33A5C87C73366966C712671C383266197
          20889E4C901E9F443D3087F5515385886905F65EEBF914D2D63B737F7F1DEFBA
          A6DFFD56FBD55395D10120D99808D0835573FF00B72B3B1736EC71B443EA265D
          53B5693FBCDFDC7FFC2316987E17546C59B8DC07223D76FF00D4B33ABFFD9856
          4FC331603FADC72CB8BFCEE332E3C7FED31FFDEB4C7C739BE647EA738C39FAE1
          C821ED64FF00639651FF0099918FDAFA1FFA5CCFFB6ABFFDE94952B7A5DD4BD9
          2E6BB1EC7060C964B9809FDF6FF395BFFE09E929FF00D1FF000DE0F734E0EFC6
          D4FF004C7C67DDF678A5EEEDC1EDC78FECE17FFFD1A98FFF00793FF127F295CB
          59FCE3FF00AC7F2AE7925A3F0FFF0074733FDE0CDF13FF0072723FECDE81DFC1
          7516FF00487FFE9B47FEDBAF37490F8B6D83FDAC11F01F9B9BFF00CE5CBFF45E
          814E9FE759FD71F9573892D497CB2F27186FF57D4B0FFE54CEFEAB3FEA9892F2
          D49731FA1FF56FFBA7B4FF002FFF00A67FF72FFFD9FFED0F6A50686F746F7368
          6F7020332E30003842494D042500000000001000000000000000000000000000
          0000003842494D043A0000000000F9000000100000000100000000000B707269
          6E744F7574707574000000050000000050737453626F6F6C0100000000496E74
          65656E756D00000000496E746500000000496D67200000000F7072696E745369
          787465656E426974626F6F6C000000000B7072696E7465724E616D6554455854
          0000000100000000000F7072696E7450726F6F6653657475704F626A63000000
          160043006F006E00660069006700750072006100E700E3006F00200064006500
          2000500072006F0076006100000000000A70726F6F6653657475700000000100
          000000426C746E656E756D0000000C6275696C74696E50726F6F660000000970
          726F6F66434D594B003842494D043B00000000022D0000001000000001000000
          0000127072696E744F75747075744F7074696F6E730000001700000000437074
          6E626F6F6C0000000000436C6272626F6F6C00000000005267734D626F6F6C00
          0000000043726E43626F6F6C0000000000436E7443626F6F6C00000000004C62
          6C73626F6F6C00000000004E677476626F6F6C0000000000456D6C44626F6F6C
          0000000000496E7472626F6F6C000000000042636B674F626A63000000010000
          0000000052474243000000030000000052642020646F7562406FE00000000000
          0000000047726E20646F7562406FE0000000000000000000426C2020646F7562
          406FE000000000000000000042726454556E744623526C740000000000000000
          00000000426C6420556E744623526C7400000000000000000000000052736C74
          556E74462350786C40520000000000000000000A766563746F7244617461626F
          6F6C010000000050675073656E756D0000000050675073000000005067504300
          0000004C656674556E744623526C74000000000000000000000000546F702055
          6E744623526C7400000000000000000000000053636C20556E74462350726340
          590000000000000000001063726F705768656E5072696E74696E67626F6F6C00
          0000000E63726F7052656374426F74746F6D6C6F6E67000000000000000C6372
          6F70526563744C6566746C6F6E67000000000000000D63726F70526563745269
          6768746C6F6E67000000000000000B63726F7052656374546F706C6F6E670000
          0000003842494D03ED0000000000100048000000010001004800000001000138
          42494D042600000000000E000000000000000000003F8000003842494D040D00
          00000000040000005A3842494D04190000000000040000001E3842494D03F300
          0000000009000000000000000001003842494D271000000000000A0001000000
          00000000013842494D03F5000000000048002F66660001006C66660006000000
          000001002F6666000100A1999A0006000000000001003200000001005A000000
          06000000000001003500000001002D000000060000000000013842494D03F800
          00000000700000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF03E800
          000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF03E800000000FF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF03E800000000FFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF03E800003842494D04000000000000
          0200023842494D04020000000000060000000000003842494D04300000000000
          03010101003842494D042D0000000000060001000000033842494D0408000000
          000010000000010000024000000240000000003842494D041E00000000000400
          0000003842494D041A00000000034D0000000600000000000000000000002100
          0000370000000C00530065006D0020005400ED00740075006C006F002D003200
          0000010000000000000000000000000000000000000001000000000000000000
          0000370000002100000000000000000000000000000000010000000000000000
          000000000000000000000010000000010000000000006E756C6C000000020000
          0006626F756E64734F626A630000000100000000000052637431000000040000
          0000546F70206C6F6E6700000000000000004C6566746C6F6E67000000000000
          000042746F6D6C6F6E670000002100000000526768746C6F6E67000000370000
          0006736C69636573566C4C73000000014F626A6300000001000000000005736C
          6963650000001200000007736C69636549446C6F6E6700000000000000076772
          6F757049446C6F6E6700000000000000066F726967696E656E756D0000000C45
          536C6963654F726967696E0000000D6175746F47656E65726174656400000000
          54797065656E756D0000000A45536C6963655479706500000000496D67200000
          0006626F756E64734F626A630000000100000000000052637431000000040000
          0000546F70206C6F6E6700000000000000004C6566746C6F6E67000000000000
          000042746F6D6C6F6E670000002100000000526768746C6F6E67000000370000
          000375726C54455854000000010000000000006E756C6C544558540000000100
          00000000004D7367655445585400000001000000000006616C74546167544558
          540000000100000000000E63656C6C54657874497348544D4C626F6F6C010000
          000863656C6C546578745445585400000001000000000009686F727A416C6967
          6E656E756D0000000F45536C696365486F727A416C69676E0000000764656661
          756C740000000976657274416C69676E656E756D0000000F45536C6963655665
          7274416C69676E0000000764656661756C740000000B6267436F6C6F72547970
          65656E756D0000001145536C6963654247436F6C6F7254797065000000004E6F
          6E6500000009746F704F75747365746C6F6E67000000000000000A6C6566744F
          75747365746C6F6E67000000000000000C626F74746F6D4F75747365746C6F6E
          67000000000000000B72696768744F75747365746C6F6E670000000000384249
          4D042800000000000C000000023FF00000000000003842494D04110000000000
          0101003842494D0414000000000004000000033842494D040C00000000062400
          0000010000003700000021000000A8000015A80000060800180001FFD8FFED00
          0C41646F62655F434D0002FFEE000E41646F626500648000000001FFDB008400
          0C08080809080C09090C110B0A0B11150F0C0C0F1518131315131318110C0C0C
          0C0C0C110C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C
          010D0B0B0D0E0D100E0E10140E0E0E14140E0E0E0E14110C0C0C0C0C11110C0C
          0C0C0C0C110C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C
          0CFFC00011080021003703012200021101031101FFDD00040004FFC4013F0000
          010501010101010100000000000000030001020405060708090A0B0100010501
          010101010100000000000000010002030405060708090A0B1000010401030204
          020507060805030C33010002110304211231054151611322718132061491A1B1
          4223241552C16233347282D14307259253F0E1F163733516A2B2832644935464
          45C2A3743617D255E265F2B384C3D375E3F3462794A485B495C4D4E4F4A5B5C5
          D5E5F55666768696A6B6C6D6E6F637475767778797A7B7C7D7E7F71100020201
          0204040304050607070605350100021103213112044151617122130532819114
          A1B14223C152D1F0332462E1728292435315637334F1250616A2B283072635C2
          D2449354A317644555367465E2F2B384C3D375E3F34694A485B495C4D4E4F4A5
          B5C5D5E5F55666768696A6B6C6D6E6F62737475767778797A7B7C7FFDA000C03
          010002110311003F00C1AF2F0B39829BDADADFF9AC718649FF00B8F77B9D8EEF
          F82B3F5755B2FA5DF4EE75736319AB9B116307FC257FBBFF000ACFD1A5FB0BAD
          7FE57E47FDB4FF00FC8ABB898DF5868DACB3A7E4DB533E80F4DED7B3CE8B76EE
          AFFA9FCDAD638FD9B972D38F0F5C1397EACFFB397F9392C19E3CC011E7212E2D
          A3CCC07EBA3FEDA3FE5A3FF3DC4E472BA8B3FA43FF00F4DA3FF3C2067743B2DC
          7394FA2DC61C3AE7566B009ED9347F83FF008FC7FD1AB0F0C766BEB1657AE0FA
          5BF70D9BBD1D91EA7F5952F887378F2C308F9270CB1E384B787FDF41D2F85723
          970CF99901EE639F2D9863C98F5848F0FCBFBD19FF0051E58111CFC55EC4E977
          5DB5D6CD4C7EB5B409B1FF00F1557EEFFC2D9FA35A783D11F5D032ABA2CCA830
          2F6D4EB06E1DB1688FD27FC75FFA241CBC7FAC378732AE9F95556FFA67D37BAC
          7FFC7DDB773FFA8DFD12BB2E6CE6261CB9888ED2CF93E4FF00A943FCA39C392C
          7CB8E2E6EE53FD1E5B1FF39FF569FF0092FF00D28A75B814460D6371B4863EBA
          9E00126272330FF3B637F719FABD692A5FB0BADFFE57E47FDB4FFF00C8A487DD
          306FEE9F7B7F7F8FF59FF7BC3FD457FA473DF0FB51FBBEDF76E0FD4D7FD2E3FF
          0059C4FF00FFD0C2FB5F44FF004B99FF006D57FF00BD29C65F4424016E649E22
          AAFF00F7A567E2E05F932F115D2D30EB9FA341FDD1F9D659FC8AD696EC1E943D
          BBBD7FDED3D63FF54CC1AFFCFC95732F23C840F0471CB2653B63848F17F85FB8
          DDC1F16F8B648FB92CF1C5806F97242023E50F4FEB27FDC6CDB858828739965E
          DBC09F46E631BB5BFE9321CDBACF41BFC97FE9104F4E70C8341B5800ABD7F575
          2CDBB3D6F0DDF47F92B272B36FC91B4C32A065B5374683FBC7F7DFFCB7AE82DF
          E90FFF00D368FF00CF0A9737F0D8E28E39CBD32CB9230E089D2103FD63F33A5C
          87C73366966C712671C38326619720889E4C901E9F443D3087F5515385886905
          F65EEBF914D2D63B737F7F1DEFBAA6DFFD56FBD55395D10120D99808D0835573
          FF00B72B3B1736EC71B443EA265D53B5693FBCDFDC7FFC2316987E17546C59B8
          DC07223D76FF00D4B33ABFFD98564FC331603FADC72CB8BFCEE332E3C7FED31F
          FDEB4C7C739BE647EA738C39FAE1C821ED64FF00639651FF0099918FDAFA1FFA
          5CCFFB6ABFFDE94952B7A5DD4BD92E6BB1EC7060C964B9809FDF6FF395BFFE09
          E929FF00D1FF000DE0F734E0EFC6D4FF004C7C67DDF678A5EEEDC1EDC78FECE1
          7FFFD1A98FFF00793FF127F295CB59FCE3FF00AC7F2AE7925A3F0FFF0074733F
          DE0CDF13FF0072723FECDE81DFC17516FF00487FFE9B47FEDBAF37490F8B6D83
          FDAC11F01F9B9BFF00CE5CBFF45E814E9FE759FD71F9573892D497CB2F27186F
          F57D4B0FFE54CEFEAB3FEA9892F2D49731FA1FF56FFBA7B4FF002FFF00A67FF7
          2FFFD93842494D042100000000005D00000001010000000F00410064006F0062
          0065002000500068006F0074006F00730068006F00700000001700410064006F
          00620065002000500068006F0074006F00730068006F00700020004300430020
          003200300031003800000001003842494D040600000000000700060000000101
          00FFE10DDB687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E30
          2F003C3F787061636B657420626567696E3D22EFBBBF222069643D2257354D30
          4D7043656869487A7265537A4E54637A6B633964223F3E203C783A786D706D65
          746120786D6C6E733A783D2261646F62653A6E733A6D6574612F2220783A786D
          70746B3D2241646F626520584D5020436F726520352E362D633134322037392E
          3136303932342C20323031372F30372F31332D30313A30363A33392020202020
          202020223E203C7264663A52444620786D6C6E733A7264663D22687474703A2F
          2F7777772E77332E6F72672F313939392F30322F32322D7264662D73796E7461
          782D6E7323223E203C7264663A4465736372697074696F6E207264663A61626F
          75743D222220786D6C6E733A786D703D22687474703A2F2F6E732E61646F6265
          2E636F6D2F7861702F312E302F2220786D6C6E733A786D704D4D3D2268747470
          3A2F2F6E732E61646F62652E636F6D2F7861702F312E302F6D6D2F2220786D6C
          6E733A73744576743D22687474703A2F2F6E732E61646F62652E636F6D2F7861
          702F312E302F73547970652F5265736F757263654576656E74232220786D6C6E
          733A64633D22687474703A2F2F7075726C2E6F72672F64632F656C656D656E74
          732F312E312F2220786D6C6E733A70686F746F73686F703D22687474703A2F2F
          6E732E61646F62652E636F6D2F70686F746F73686F702F312E302F2220786D70
          3A43726561746F72546F6F6C3D2241646F62652050686F746F73686F70204343
          2032303138202857696E646F7773292220786D703A437265617465446174653D
          22323031382D30382D30335430383A30343A33312D30333A30302220786D703A
          4D65746164617461446174653D22323031382D30382D30335430383A30343A33
          312D30333A30302220786D703A4D6F64696679446174653D22323031382D3038
          2D30335430383A30343A33312D30333A30302220786D704D4D3A496E7374616E
          636549443D22786D702E6969643A61373934333766612D636462312D33343463
          2D623365622D3362313366643635633438352220786D704D4D3A446F63756D65
          6E7449443D2261646F62653A646F6369643A70686F746F73686F703A35616561
          363863342D333562322D343334612D626632662D633962626230376237313862
          2220786D704D4D3A4F726967696E616C446F63756D656E7449443D22786D702E
          6469643A34613137363437332D663763652D383034322D616634322D62393834
          3830373237396165222064633A666F726D61743D22696D6167652F6A70656722
          2070686F746F73686F703A436F6C6F724D6F64653D2233223E203C786D704D4D
          3A486973746F72793E203C7264663A5365713E203C7264663A6C692073744576
          743A616374696F6E3D2263726561746564222073744576743A696E7374616E63
          6549443D22786D702E6969643A34613137363437332D663763652D383034322D
          616634322D623938343830373237396165222073744576743A7768656E3D2232
          3031382D30382D30335430383A30343A33312D30333A3030222073744576743A
          736F6674776172654167656E743D2241646F62652050686F746F73686F702043
          432032303138202857696E646F777329222F3E203C7264663A6C692073744576
          743A616374696F6E3D227361766564222073744576743A696E7374616E636549
          443D22786D702E6969643A61373934333766612D636462312D333434632D6233
          65622D336231336664363563343835222073744576743A7768656E3D22323031
          382D30382D30335430383A30343A33312D30333A3030222073744576743A736F
          6674776172654167656E743D2241646F62652050686F746F73686F7020434320
          32303138202857696E646F777329222073744576743A6368616E6765643D222F
          222F3E203C2F7264663A5365713E203C2F786D704D4D3A486973746F72793E20
          3C2F7264663A4465736372697074696F6E3E203C2F7264663A5244463E203C2F
          783A786D706D6574613E20202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          2020202020202020202020202020202020202020202020202020202020202020
          20202020202020202020203C3F787061636B657420656E643D2277223F3EFFEE
          000E41646F626500644000000001FFDB00840002020202020202020202030202
          0203040302020304050404040404050605050505050506060707080707060909
          0A0A09090C0C0C0C0C0C0C0C0C0C0C0C0C0C0C01030303050405090606090D0A
          090A0D0F0E0E0E0E0F0F0C0C0C0C0C0F0F0C0C0C0C0C0C0F0C0C0C0C0C0C0C0C
          0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0CFFC000110800210037030111
          00021101031101FFDD00040007FFC401A2000000070101010101000000000000
          0000040503020601000708090A0B010002020301010101010000000000000001
          0002030405060708090A0B100002010303020402060703040206027301020311
          0400052112314151061361227181143291A10715B14223C152D1E1331662F024
          7282F12543345392A2B26373C235442793A3B33617546474C3D2E2082683090A
          181984944546A4B456D355281AF2E3F3C4D4E4F465758595A5B5C5D5E5F56676
          8696A6B6C6D6E6F637475767778797A7B7C7D7E7F738485868788898A8B8C8D8
          E8F82939495969798999A9B9C9D9E9F92A3A4A5A6A7A8A9AAABACADAEAFA1100
          02020102030505040506040803036D0100021103042112314105511361220671
          819132A1B1F014C1D1E1234215526272F1332434438216925325A263B2C20773
          D235E2448317549308090A18192636451A2764745537F2A3B3C32829D3E3F384
          94A4B4C4D4E4F465758595A5B5C5D5E5F5465666768696A6B6C6D6E6F6475767
          778797A7B7C7D7E7F738485868788898A8B8C8D8E8F839495969798999A9B9C9
          D9E9F92A3A4A5A6A7A8A9AAABACADAEAFAFFDA000C03010002110311003F00F2
          769BE6CF2679FAD23D0F5FB1B5D1EFC122D74FB899A1B2695DAA4E997EDCDEC5
          D9BFDD3373B727A15A95CEEB59EC676A7B3B2FCCF63C84A237963EFF0073D468
          7FE083D97ED6611A3F6961590FD3A886D207FA7E5EE60BE6CFCAFD6B4237B71A
          589F57B0B01EA5F5AB4262D4AC5295E5756A0B131D3713445A323E2A8AE74BEC
          F7B79A4ED29785A88F81A8E4632DB7F278FF006BBFE05DAFEC887E6B4A7F33A4
          97D3921B8AF3EAF2B666915BF795F84D0D6B9DF98180DC820BE635E1F41BBEF2
          D487FCEC3AA53B7E4DC67FF0DC5CF95FB58431FB677CE267B3F6AF634383FE05
          194C856C2BE6F83D5D78292E6829CF7D857BE7D4E058A8C362FC552C72E23B7C
          5EA9E52FCAED635C36377AC7D6346D3B525E7A558C717ADAA6A0B4AD6D2D0FEC
          53FDDD2948E9D0B5338AF69FDB9ECFEC71E0CBF7B98F28477DFCDF43F647FE06
          9DA5ED07EF63118B04779659ED001E9771A9F91741F4FC83A7DB8BD935B9934E
          D4747D235148A3432B88CBEA9AE3A91713216E4B1C605BC6C2ADB0E27838687B
          77B5E47B47563C3C7807898F0FF3A58FD711FE71003E93935FECC760C4764F67
          91932EA7F739B512E50865FDDE431F28C644F27FFFD0F0B37E467E74B1AFFCAA
          1F3791BFC3FA16F4835FF9E79F428EDCD0136730F9BE723B1F584DCB1CFDF5BB
          D2FCA9E5AFF9C83F2FFD4ACB51FCA1F3AEB5A258B836108D2EFA0BDD38FF003E
          9F7AB0B3C3DCFA643467BA6F9C97B49D95D87DB438A790472F49C48127BAF643
          DA9EDEF6725C38A329E13F5639826121DC47EA649E76FC90D4357D027F36DFF9
          4F5BF25C6488AEBCC777A3CFA74514CE364D5B4EE256127702E6D0B467A95DF6
          E2F45ED6EBFD9798D3EAA4351A7FE7837288F37D273FB19D93EDA44E7ECC81D2
          6B4F3C3215099EBC1D599DDA5A5C79D352D320D6B4A6327E57AE8EBA99BC8D6C
          0DDAE82B014FACB10A07A9F0EFBFB573CFB5DDB3A6CFED3FE741FDC997103E4F
          B0687D96ED2D27FC0E751D9D3C32FCC0222215BDDFDCC43C8FF92779A66871F9
          BB4EF2B6B1E7511398E0F33DAE8D71A8C0D709BB268FA770FDFB2F4FAC5D7188
          750BB54FA3F69FB79AEF68329D37674862C3C8E43B01EE7C7741FF0003CECBF6
          5231D576D939F515C434F0DC8EE1918E79BBCBDFF3909AF25EE9FA47E5179DB4
          3D27506235390E997D3EA7A90DAA750BE312BCA0D3FBB40B17F92699D07B31D8
          3D8DD952F1E7923935079CE46F7F2789F6AFDB4EDBEDBFF06C58E583491FA71C
          0102BCDE5FFF002A2FF3A800A7F287CE0A28471FD0979435ED431E7792EDFD15
          7F7D1BBEF7CD3F92B584DF8533BF3A2FFFD1F2A9F377E48F7D77F312BDFF00DC
          3695FF00799CCFFF009329ACFF00571F33FADF708FFCB526003FE33E1F21FA9B
          4F367E4A3C88916B7F98CF23B058D1345D2CB163D0281ACD493D80C65FF014D6
          46265F9911AF3291FF002D4382668767C2FA6C3F53D0752F26F945344B9B9B2D
          63CD367E618E3339F2EEBB6161682D2DBED35CEA7343A8DC2D9A0A578483D43D
          38576CF3FED7F65238730D3E1CC73E63B70C37AF792FA9FB31FF00053D4EBF4E
          75DABD1E3D26986FC73F493FD515BA40FF009757117986E7CBF379834C8E2B7D
          03FC44DAE8F59EC8DAFD4C5F29E423E66B1902BC29F4668A7ECE6AA1AFFC89FE
          F474F3EE7BD87FC123412EC59F6C08196081A35567FA5DD5F6A7DA4792FCAB2E
          8D14B7BABF99AE3CC8C9EAA797B43B2D3EEC5EDB81513E99713EA36C976B4EA8
          9F18E9C4E6EF47EC9CCEA4E975194E9F275E2DA3F021E1FB73FE0A994E9BF3DD
          9BA5C7ACD39EB1DE71FEBC4C76AF2258149E69FC958A59229B5AFCC786585BD3
          9E19344D2D5D1976E2CADAC860474A1CEFB1FF00C06759920278B551944F712F
          95E5FF00969F86299C72ECF84643A11FB167F8B7F246A29AEFE621AFFDA974AF
          FBCCE5A7FE029ABABF1C7CCB8FFF00334B888FF8CF85FB87EA7FFFD2F9EFE58F
          20EBBE69596F2158B4BF2FDBCBE95F799AFC98ED237EA228CAAB3CF291D23895
          98F5D86F9EFF00DB5ED2683B1F0F1EA7251E80732F13ECDFB2BAEEDFCDE1E931
          CA5DE7A0F32793DA84FE48FCA2888B6172FE6529F15CFEED75E92B5FB23F7B16
          910B023F9EE483DBF67CD8EA7B67DAC261881C1A5E665CA520FB14747ECDFB05
          8F8B5246B7B42B680DF1E33FD2F3786F9A7CEDADF9A54DA4ED1E9DA340ED359E
          8168192D924FF7EC81999A594F7924666F034CF42F67BD93D1762E1BC601BE72
          3F517CBBDACF6DFB4BDA2C8326AF25C3F8611DA10F203F5BEC3D4F7F306A80F4
          3F93718FA3FC36BB7CB3E7FED4983ED89E1BA337EA3EC415FF00027CC7C87DEF
          8EFCAFE75D67CB4A2D6129A968B34825BBF2FDE727B57714FDEC7C486865A2ED
          244430DAB5CFA1BB6BD98D0F6CE1F0F3C0135B1EA1F947D9BF6C3B47D9CD478B
          A3C863D08E8477105EEAB79E49FCDB8122D452EA7D7A38804B98F83798EDD541
          0054FA716B10AD29462970A3A114A9F353A5EDCF6372F1C09D4693F9BFC510FB
          1FE6BD9BF6F6006A04743DA15B4B962C87CFAD9793EADF961ABE8B7DA6196F2D
          AFBCABAB5EC5630F9DEC565B8B289E660BC6E225513412A03530C8A1DA87872E
          B9DAF677B77A0D669B2EA04BD50819707F17A45D7BF67CDBB5FF00E06FDAFD9B
          DA387499F1F0F8D923084FFC99E3908837DDBF37FFD3E79A075FF9C78FFC072E
          3FE4FC987DB4FF008D5C3EF0FB87FC0BFF00E712CBEE2F82EFBFE3A3AA7FCC74
          FF00F270E7D1BD9DFDC47FAAFCA5DA9FE359BE2A73756FF50FEACBF53FDDC7DE
          E821F4FC5F776A5FF290EA9FF9A6E2FF00C46D73E61ED6FF009CCFFCFF00D4FD
          C1D97FF46A73FB83E0C1D173EA697D3F27E229FD4532D23FE3ADA57FCC741FF2
          70657DABFDC9F73762FEF63EF1F7BF473C9DFF009343F353FE612C3FEA2EDF3E
          58D0FF00C6D65F8BF7076E7FCE17A7F7C3EF0FFFD9}
        Transparent = True
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 563
    Width = 640
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 2
    DesignSize = (
      640
      37)
    object lSeguro: TLabel
      Left = 9
      Top = 12
      Width = 80
      Height = 17
      Anchors = []
      Caption = 'Seguro : N'#227'o'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object ButtonStart: TButton
      Left = 409
      Top = 6
      Width = 100
      Height = 25
      Cursor = crHandPoint
      Anchors = []
      Caption = 'Iniciar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = ButtonStartClick
    end
    object ButtonStop: TButton
      Left = 521
      Top = 6
      Width = 100
      Height = 25
      Cursor = crHandPoint
      Anchors = []
      Caption = 'Parar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = ButtonStopClick
    end
    object cbPoolerState: TCheckBox
      Left = 184
      Top = 12
      Width = 115
      Height = 17
      Anchors = []
      Caption = 'Pooler Active?'
      Checked = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      State = cbChecked
      TabOrder = 2
    end
  end
  object RESTDWServiceNotification1: TRESTDWServiceNotification
    GarbageTime = 60000
    QueueNotifications = 50
    Left = 480
    Top = 160
  end
  object RESTServicePooler1: TRESTServicePooler
    Active = False
    CORS = False
    CORS_CustomHeaders.Strings = (
      'Access-Control-Allow-Origin=*'
      
        'Access-Control-Allow-Methods=GET, POST, PATCH, PUT, DELETE, OPTI' +
        'ONS'
      
        'Access-Control-Allow-Headers=Content-Type, Origin, Accept, Autho' +
        'rization, X-CUSTOM-HEADER')
    RequestTimeout = -1
    ServicePort = 8082
    ProxyOptions.Port = 8888
    TokenOptions.Active = False
    TokenOptions.ServerRequest = 'RESTDWServer01'
    TokenOptions.TokenHash = 'RDWTS_HASH'
    TokenOptions.LifeCycle = 30
    ServerParams.HasAuthentication = False
    ServerParams.UserName = 'testserver'
    ServerParams.Password = 'testserver'
    SSLMethod = sslvSSLv2
    SSLVersions = []
    OnLastRequest = RESTServicePooler1LastRequest
    OnLastResponse = RESTServicePooler1LastResponse
    Encoding = esUtf8
    ServerContext = 'restdataware'
    RootPath = '/'
    SSLVerifyMode = []
    SSLVerifyDepth = 0
    ForceWelcomeAccess = False
    RESTServiceNotification = RESTDWServiceNotification1
    CriptOptions.Use = False
    CriptOptions.Key = 'RDWBASEKEY256'
    MultiCORE = False
    Left = 564
    Top = 168
  end
  object tupdatelogs: TTimer
    Enabled = False
    OnTimer = tupdatelogsTimer
    Left = 566
    Top = 480
  end
  object pmMenu: TPopupMenu
    Left = 560
    Top = 372
    object RestaurarAplicao1: TMenuItem
      Caption = 'Restaurar Aplica'#231#227'o'
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object SairdaAplicao1: TMenuItem
      Caption = 'Sair da Aplica'#231#227'o'
      OnClick = SairdaAplicao1Click
    end
  end
end
  7  4   ��
 R D W S R V U N I T         0         unit %0:s;

Interface

Uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  Winsock,
  USock,
  IniFiles,
  AppEvnts,
  StdCtrls,
  HTTPApp,
  ExtCtrls,
  Mask,
  Menus,
  URESTDWBase,
  ComCtrls,
  DB,
  IdComponent,
  IdBaseComponent,
  IdTCPConnection,
  IdTCPClient,
  IdHTTP, uDWJSONObject, uDWAbout, jpeg;


type
  T%1:s = class(%2:s)
    ButtonStart: TButton;
    ButtonStop: TButton;
    Label8: TLabel;
    Bevel3: TBevel;
    LSeguro: TLabel;
    CbPoolerState: TCheckBox;
    PageControl1: TPageControl;
    TsConfigs: TTabSheet;
    TsLogs: TTabSheet;
    MemoReq: TMemo;
    MemoResp: TMemo;
    Label19: TLabel;
    Label18: TLabel;
    RESTDWServiceNotification1: TRESTDWServiceNotification;
    RESTServicePooler1: TRESTServicePooler;
    tupdatelogs: TTimer;
    pmMenu: TPopupMenu;
    RestaurarAplicao1: TMenuItem;
    N5: TMenuItem;
    SairdaAplicao1: TMenuItem;
    Image2: TImage;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    labPorta: TLabel;
    labUsuario: TLabel;
    labSenha: TLabel;
    lbPasta: TLabel;
    labNomeBD: TLabel;
    Label14: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    labConexao: TLabel;
    Label7: TLabel;
    labDBConfig: TLabel;
    labSSL: TLabel;
    labVersao: TLabel;
    Panel4: TPanel;
    Image8: TImage;
    edPortaDW: TEdit;
    edUserNameDW: TEdit;
    edPasswordDW: TEdit;
    cbForceWelcome: TCheckBox;
    cbauthentication: TCheckBox;
    edURL: TEdit;
    cbAdaptadores: TComboBox;
    edPortaBD: TEdit;
    edUserNameBD: TEdit;
    edPasswordBD: TEdit;
    edPasta: TEdit;
    edBD: TEdit;
    cbDriver: TComboBox;
    ckUsaURL: TCheckBox;
    ePrivKeyFile: TEdit;
    eCertFile: TEdit;
    ePrivKeyPass: TMaskEdit;
    cbUpdateLog: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CbAdaptadoresChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SairdaAplicao1Click(Sender: TObject);
    procedure RESTServicePooler1LastRequest(Value: string);
    procedure RESTServicePooler1LastResponse(Value: string);
    procedure TupdatelogsTimer(Sender: TObject);
    procedure CbDriverCloseUp(Sender: TObject);
    procedure CkUsaURLClick(Sender: TObject);
  Private
    { Private declarations }
    VLastRequest,
    VLastRequestB,
    VDatabaseName,
    FCfgName,
    VDatabaseIP,
    VUsername,
    VPassword    : string;
    procedure StartServer;
  Public
    { Public declarations }
    Property Username     : String Read   VUsername     Write  VUsername;
    Property Password     : String Read   VPassword     Write  VPassword;
    Property DatabaseIP   : String Read   VDatabaseIP   Write  VDatabaseIP;
    Property DatabaseName : String Read   VDatabaseName Write  VDatabaseName;
  End;

var
   %1:s: T%1:s;

implementation

{$R *.dfm}

Uses
  ShellApi, %4:s;

Function ServerIpIndex(Items: TStrings; ChooseIP: string): Integer;
var
  I: Integer;
Begin
  Result := -1;
  For I  := 0 To Items.Count - 1 Do
  Begin
    If Pos(ChooseIP, Items[I]) > 0 Then
    Begin
      Result := I;
      Break;
    End;
  End;
End;

procedure T%1:s.CkUsaURLClick(Sender: TObject);
Begin
  If CkUsaURL.Checked Then
  Begin
    CbAdaptadores.Visible := False;
    EdURL.Visible         := True;
  End
  Else
  Begin
    EdURL.Visible         := False;
    CbAdaptadores.Visible := True;
  End;
End;

procedure T%1:s.CbDriverCloseUp(Sender: TObject);
Var
 Ini : TIniFile;
Begin
  Ini                     := TIniFile.Create(FCfgName);
  Try
   CbAdaptadores.ItemIndex := ServerIpIndex(CbAdaptadores.Items, Ini.ReadString('BancoDados', 'Servidor', '127.0.0.1'));
   EdBD.Text               := Ini.ReadString('BancoDados', 'BD', 'EMPLOYEE.FDB');
   EdPasta.Text            := Ini.ReadString('BancoDados', 'Pasta', ExtractFilePath(ParamSTR(0)) + '..\');
   EdPortaBD.Text          := Ini.ReadString('BancoDados', 'PortaBD', '3050');
   EdUserNameBD.Text       := Ini.ReadString('BancoDados', 'UsuarioBD', 'SYSDBA');
   EdPasswordBD.Text       := Ini.ReadString('BancoDados', 'SenhaBD', 'masterkey');
   EdPortaDW.Text          := Ini.ReadString('BancoDados', 'PortaDW', '8082');
   EdUserNameDW.Text       := Ini.ReadString('BancoDados', 'UsuarioDW', 'testserver');
   EdPasswordDW.Text       := Ini.ReadString('BancoDados', 'SenhaDW', 'testserver');
   Case CbDriver.ItemIndex of
    0: // FireBird
      Begin
       LbPasta.Visible         := True;
       EdPasta.Visible         := True;
       DatabaseName            := EdPasta.Text + EdBD.Text;
      End;
    1: // MSSQL
      Begin
        EdBD.Text         := 'seubanco';
        LbPasta.Visible   := False;
        EdPasta.Visible   := False;
        EdPasta.Text      := EmptyStr;
        EdPortaBD.Text    := '1433';
        EdUserNameBD.Text := 'sa';
        EdPasswordBD.Text := EmptyStr;;
        DatabaseName      := EdBD.Text;
      End;
   End;
  Finally
   Ini.Free;
  End;
End;

procedure T%1:s.RESTServicePooler1LastRequest(Value: string);
Begin
  VLastRequest := Value;
End;

procedure T%1:s.RESTServicePooler1LastResponse(Value: string);
Begin
  VLastRequestB := Value;
End;

procedure T%1:s.SairdaAplicao1Click(Sender: TObject);
Begin
  Close;
End;

procedure T%1:s.ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
Begin
  ButtonStart.Enabled   := Not RESTServicePooler1.Active;
  ButtonStop.Enabled    := RESTServicePooler1.Active;
  EdPortaDW.Enabled     := ButtonStart.Enabled;
  EdUserNameDW.Enabled  := ButtonStart.Enabled;
  EdPasswordDW.Enabled  := ButtonStart.Enabled;
  CbAdaptadores.Enabled := ButtonStart.Enabled;
  EdPortaBD.Enabled     := ButtonStart.Enabled;
  EdPasta.Enabled       := ButtonStart.Enabled;
  EdBD.Enabled          := ButtonStart.Enabled;
  EdUserNameBD.Enabled  := ButtonStart.Enabled;
  EdPasswordBD.Enabled  := ButtonStart.Enabled;
  EPrivKeyFile.Enabled  := ButtonStart.Enabled;
  EPrivKeyPass.Enabled  := ButtonStart.Enabled;
  ECertFile.Enabled     := ButtonStart.Enabled;
End;

procedure T%1:s.ButtonStartClick(Sender: TObject);
var
  Ini: TIniFile;
Begin
  If FileExists(FCfgName) Then
    DeleteFile(FCfgName);
  Ini := TIniFile.Create(FCfgName);
  If CkUsaURL.Checked Then
  Begin
    Ini.WriteString('BancoDados', 'Servidor', EdURL.Text);
  End
  Else
  Begin
    Ini.WriteString('BancoDados', 'Servidor', CbAdaptadores.Text);
  End;
  Ini.WriteInteger('BancoDados', 'DRIVER', cbDriver.ItemIndex);
  If ckUsaURL.Checked Then
   Ini.WriteInteger('BancoDados', 'USEDNS', 1)
  Else
   Ini.WriteInteger('BancoDados', 'USEDNS', 0);
  If cbUpdateLog.Checked Then
   Ini.WriteInteger('Configs', 'UPDLOG', 1)
  Else
   Ini.WriteInteger('Configs', 'UPDLOG', 0);
  Ini.WriteString('BancoDados', 'BD', EdBD.Text);
  Ini.WriteString('BancoDados', 'Pasta', EdPasta.Text);
  Ini.WriteString('BancoDados', 'PortaDB', EdPortaBD.Text);
  Ini.WriteString('BancoDados', 'PortaDW', EdPortaDW.Text);
  Ini.WriteString('BancoDados', 'UsuarioBD', EdUserNameBD.Text);
  Ini.WriteString('BancoDados', 'SenhaBD', EdPasswordBD.Text);
  Ini.WriteString('BancoDados', 'UsuarioDW', EdUserNameDW.Text);
  Ini.WriteString('BancoDados', 'SenhaDW', EdPasswordDW.Text);
  Ini.WriteString('SSL', 'PKF', EPrivKeyFile.Text);
  Ini.WriteString('SSL', 'PKP', EPrivKeyPass.Text);
  Ini.WriteString('SSL', 'CF', ECertFile.Text);
  If cbForceWelcome.Checked Then
   Ini.WriteInteger('Configs', 'ForceWelcomeAccess', 1)
  Else
   Ini.WriteInteger('Configs', 'ForceWelcomeAccess', 0);
  If cbauthentication.Checked Then
   Ini.WriteInteger('Configs', 'HasAuthentication', 1)
  Else
   Ini.WriteInteger('Configs', 'HasAuthentication', 0);
  Ini.Free;
  VUsername := EdUserNameDW.Text;
  VPassword := EdPasswordDW.Text;
  StartServer;
End;

procedure T%1:s.ButtonStopClick(Sender: TObject);
Begin
  Tupdatelogs.Enabled       := False;
  RESTServicePooler1.Active := False;
  PageControl1.ActivePage   := TsConfigs;
End;

procedure T%1:s.CbAdaptadoresChange(Sender: TObject);
Begin
  VDatabaseIP := Trim(Copy(CbAdaptadores.Text, Pos('-', CbAdaptadores.Text) + 1, 100));
End;

procedure T%1:s.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
Begin
 CanClose := Not RESTServicePooler1.Active;
 If Not CanClose Then
  Begin
   CanClose := Not Self.Visible;
   If CanClose Then
    CanClose := Application.MessageBox('Voc� deseja realmente sair do programa ?', 'Pergunta ?', Mb_IconQuestion + Mb_YesNo) = MrYes;
  End;
End;

procedure T%1:s.FormCreate(Sender: TObject);
Begin
  // define o nome do .ini de acordo c o EXE
  // dessa forma se quiser testar v�rias inst�ncias do servidor em
  // portas diferentes os arquivos n�o ir�o conflitar
  FCfgName                             := StringReplace(ExtractFileName(ParamStr(0)), '.exe', '', [RfReplaceAll]);
  FCfgName                             := ExtractFilePath(ParamSTR(0)) + 'Config_' + FCfgName + '.ini';
  RESTServicePooler1.ServerMethodClass := T%3:s;
  PageControl1.ActivePage              := TsConfigs;
End;

procedure T%1:s.FormShow(Sender: TObject);
var
  Ini:               TIniFile;
  VTag, I:           Integer;
  ANetInterfaceList: TNetworkInterfaceList;
Begin
  VTag := 0;
  If (GetNetworkInterfaces(ANetInterfaceList)) Then
  Begin
    CbAdaptadores.Items.Clear;
    For I := 0 To High(ANetInterfaceList) Do
    Begin
      CbAdaptadores.Items.Add('Placa #' + IntToStr(I) + ' - ' + ANetInterfaceList[I].AddrIP);
      If (I <= 1) or (Pos('127.0.0.1', ANetInterfaceList[I].AddrIP) > 0) Then
      Begin
        VDatabaseIP := ANetInterfaceList[I].AddrIP;
        VTag        := 1;
      End;
    End;
    CbAdaptadores.ItemIndex := VTag;
  End;
  Ini                     := TIniFile.Create(FCfgName);
  cbDriver.ItemIndex      := Ini.ReadInteger('BancoDados', 'DRIVER', 0);
  ckUsaURL.Checked        := Ini.ReadInteger('BancoDados', 'USEDNS', 0) = 1;
  CbAdaptadores.ItemIndex := ServerIpIndex(CbAdaptadores.Items, Ini.ReadString('BancoDados', 'Servidor', '127.0.0.1'));
  EdBD.Text               := Ini.ReadString('BancoDados', 'BD', 'EMPLOYEE.FDB');
  EdPasta.Text            := Ini.ReadString('BancoDados', 'Pasta', ExtractFilePath(ParamSTR(0)) + '..\');
  EdPortaBD.Text          := Ini.ReadString('BancoDados', 'PortaBD', '3050');
  EdPortaDW.Text          := Ini.ReadString('BancoDados', 'PortaDW', '8082');
  EdUserNameBD.Text       := Ini.ReadString('BancoDados', 'UsuarioBD', 'SYSDBA');
  EdPasswordBD.Text       := Ini.ReadString('BancoDados', 'SenhaBD', 'masterkey');
  EdUserNameDW.Text := Ini.ReadString('BancoDados', 'UsuarioDW', 'testserver');
  EdPasswordDW.Text := Ini.ReadString('BancoDados', 'SenhaDW', 'testserver');
  EPrivKeyFile.Text := Ini.ReadString('SSL', 'PKF', '');
  EPrivKeyPass.Text := Ini.ReadString('SSL', 'PKP', '');
  ECertFile.Text    := Ini.ReadString('SSL', 'CF', '');
  cbForceWelcome.Checked   := Ini.ReadInteger('Configs', 'ForceWelcomeAccess', 0) = 1;
  cbauthentication.Checked := Ini.ReadInteger('Configs', 'HasAuthentication', 0) = 1;
  cbUpdateLog.Checked      := Ini.ReadInteger('Configs',  'UPDLOG', 1) = 1;
  Ini.Free;
End;

procedure T%1:s.StartServer;
Begin
  If Not RESTServicePooler1.Active Then
   Begin
    RESTServicePooler1.ServerParams.HasAuthentication := cbauthentication.Checked;
    RESTServicePooler1.ServerParams.UserName := EdUserNameDW.Text;
    RESTServicePooler1.ServerParams.Password := EdPasswordDW.Text;
    RESTServicePooler1.ServicePort           := StrToInt(EdPortaDW.Text);
    RESTServicePooler1.SSLPrivateKeyFile     := EPrivKeyFile.Text;
    RESTServicePooler1.SSLPrivateKeyPassword := EPrivKeyPass.Text;
    RESTServicePooler1.SSLCertFile           := ECertFile.Text;
    RESTServicePooler1.ForceWelcomeAccess    := cbForceWelcome.Checked;
    RESTServicePooler1.Active                := True;
    If Not RESTServicePooler1.Active Then Exit;
    PageControl1.ActivePage := TsLogs;
    Tupdatelogs.Enabled := cbUpdateLog.Checked;
   End;
  If RESTServicePooler1.Secure Then
   Begin
    LSeguro.Font.Color := ClBlue;
    LSeguro.Caption    := 'Seguro : Sim';
   End
  Else
   Begin
    LSeguro.Font.Color := ClRed;
    LSeguro.Caption    := 'Seguro : N�o';
   End;
End;

procedure T%1:s.TupdatelogsTimer(Sender: TObject);
var
  VTempLastRequest, VTempLastRequestB: string;
Begin
  Tupdatelogs.Enabled := False;
  Try
    VTempLastRequest  := VLastRequest;
    VTempLastRequestB := VLastRequestB;
    If (VTempLastRequest <> '') Then
    Begin
      If MemoReq.Lines.Count > 0 Then
        If MemoReq.Lines[MemoReq.Lines.Count - 1] = VTempLastRequest Then
          Exit;
      If MemoReq.Lines.Count = 0 Then
        MemoReq.Lines.Add(Copy(VTempLastRequest, 1, 100))
      Else
        MemoReq.Lines[MemoReq.Lines.Count - 1] := Copy(VTempLastRequest, 1, 100);
      If Length(VTempLastRequest) > 1000 Then
        MemoReq.Lines[MemoReq.Lines.Count - 1] := MemoReq.Lines[MemoReq.Lines.Count - 1] + '...';
      If MemoResp.Lines.Count > 0 Then
        If MemoResp.Lines[MemoResp.Lines.Count - 1] = VTempLastRequestB Then
          Exit;
      If MemoResp.Lines.Count = 0 Then
        MemoResp.Lines.Add(Copy(VTempLastRequestB, 1, 100))
      Else
        MemoResp.Lines[MemoResp.Lines.Count - 1] := Copy(VTempLastRequestB, 1, 100);
      If Length(VTempLastRequest) > 1000 Then
        MemoResp.Lines[MemoResp.Lines.Count - 1] := MemoResp.Lines[MemoResp.Lines.Count - 1] + '...';
    End;
  Finally
    Tupdatelogs.Enabled := True;
  End;
End;

End.
  �&  0   ��
 R D W U S O C K         0         Unit uSock;
{$IFDEF FPC}
{$IFDEF Linux}
  {$mode objfpc}{$H+}
{$ELSE}
{$MODE Delphi}
{$ENDIF}
{$ENDIF}

Interface

{$IFDEF Linux}

 uses sockets, baseunix, unix;
const
  IPPROTO_IP = 0;
  IF_NAMESIZE = 16;
  SIOCGIFCONF = $8912;

type
{$packrecords c}
  tifr_ifrn = record
    case integer of
      0: (ifrn_name: array [0..IF_NAMESIZE - 1] of char);
  end;

  tifmap = record
    mem_start: PtrUInt;
    mem_end: PtrUInt;
    base_addr: word;
    irq: byte;
    dma: byte;
    port: byte;
  end;

  PIFrec = ^TIFrec;

  TIFrec = record
    ifr_ifrn: tifr_ifrn;
    case integer of
      0: (ifru_addr: TSockAddr);
      1: (ifru_dstaddr: TSockAddr);
      2: (ifru_broadaddr: TSockAddr);
      3: (ifru_netmask: TSockAddr);
      4: (ifru_hwaddr: TSockAddr);
      5: (ifru_flags: word);
      6: (ifru_ivalue: longint);
      7: (ifru_mtu: longint);
      8: (ifru_map: tifmap);
      9: (ifru_slave: array[0..IF_NAMESIZE - 1] of char);
      10: (ifru_newname: array[0..IF_NAMESIZE - 1] of char);
      11: (ifru_data: pointer);
  end;

  TIFConf = record
    ifc_len: longint;
    case integer of
      0: (ifcu_buf: pointer);
      1: (ifcu_req: ^tifrec);
  end;

  
     tNetworkInterface     = Record
                               ComputerName          : String;
                               AddrIP                : String;
                               SubnetMask            : String;
                               AddrNet               : String;
                               AddrLimitedBroadcast  : String;
                               AddrDirectedBroadcast : String;
                               IsInterfaceUp         : Boolean;
                               BroadcastSupport      : Boolean;
                               IsLoopback            : Boolean;
                             end;

     tNetworkInterfaceList = Array of tNetworkInterface;

  Function GetNetworkInterfaces (Var aNetworkInterfaceList : tNetworkInterfaceList): Boolean;
{$ELSE}
  Uses Windows, Winsock;
{ Unit to identify the network interfaces
  This code requires at least Win98/ME/2K, 95 OSR 2 or NT service pack #3
  as WinSock 2 is used (WS2_32.DLL) }


// Constants found in manual on non-officially documented M$ Winsock functions
Const SIO_GET_INTERFACE_LIST = $4004747F;
      IFF_UP                 = $00000001;
      IFF_BROADCAST          = $00000002;
      IFF_LOOPBACK           = $00000004;
      IFF_POINTTOPOINT       = $00000008;
      IFF_MULTICAST          = $00000010;


Type SockAddr_Gen          = Packed Record
                               AddressIn             : SockAddr_In;
                               Padding               : Packed Array [0..7] of Byte;
                             end;

     Interface_Info        = Record
                               iiFlags               : u_Long;
                               iiAddress             : SockAddr_Gen;
                               iiBroadcastAddress    : SockAddr_Gen;
                               iiNetmask             : SockAddr_Gen;
                             end;

     tNetworkInterface     = Record
                               ComputerName          : String;
                               AddrIP                : String;
                               SubnetMask            : String;
                               AddrNet               : String;
                               AddrLimitedBroadcast  : String;
                               AddrDirectedBroadcast : String;
                               IsInterfaceUp         : Boolean;
                               BroadcastSupport      : Boolean;
                               IsLoopback            : Boolean;
                             end;

     tNetworkInterfaceList = Array of tNetworkInterface;


Function WSAIoctl (aSocket              : TSocket;
                   aCommand             : DWord;
                   lpInBuffer           : Pointer;
                   dwInBufferLen        : DWord;
                   lpOutBuffer          : Pointer;
                   dwOutBufferLen       : DWord;
                   lpdwOutBytesReturned : LPDWord;
                   lpOverLapped         : Pointer;
                   lpOverLappedRoutine  : Pointer) : Integer; stdcall; external 'WS2_32.DLL';

Function GetNetworkInterfaces (Var aNetworkInterfaceList : tNetworkInterfaceList): Boolean;
{$ENDIF}


implementation


{$IFDEF LINUX}

function GetNetworkInterfaces(var aNetworkInterfaceList: tNetworkInterfaceList
  ): Boolean;
var
  i, n, nr,Sd: integer;
  buf: array[0..1023] of byte;
  ifc: TIfConf;
  ifp: PIFRec;
  names: string;
begin
  sd := fpSocket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
  //Result := '';
  if (sd < 0) then
    exit;
  try
    ifc.ifc_len := Sizeof(Buf);
    ifc.ifcu_buf := @buf;
    if fpioctl(sd, SIOCGIFCONF, @ifc) < 0 then
      Exit;
    n := ifc.ifc_len;
    i := 0;
    names := '';
    nr:= trunc((n/sizeof(TIFrec)));
    SetLength(aNetworkInterfaceList,nr);
    nr:=0;
    while (i < n) do
    begin
      ifp := PIFRec(PByte(ifc.ifcu_buf) + i);
      names := names + ifp^.ifr_ifrn.ifrn_name + ' ';
     // if i > 0 then
        //Begin
        aNetworkInterfaceList[nr].AddrIP:=NetAddrToStr(ifp^.ifru_addr.sin_addr);
       // end;
        //Result := Result + ',';
      //Result := Result + ifp^.ifr_ifrn.ifrn_name +' : '+NetAddrToStr(ifp^.ifru_addr.sin_addr)+' aa: '+NetAddrToStr(ifp^.ifru_netmask.sin_addr);
      i := i + sizeof(TIFrec);
      inc(nr);
    end;
     result:=true;
  finally
    //fileClose(sd);
  end;

end;

{$ELSE}


Function GetNetworkInterfaces (Var aNetworkInterfaceList : tNetworkInterfaceList): Boolean;
// Returns a complete list the of available network interfaces on a system (IPv4)
// Copyright by Dr. Jan Schulz, 23-26th March 2007
// This version can be used for free and non-profit projects. In any other case get in contact
// Written with information retrieved from MSDN
// www.code10.net
Var aSocket             : TSocket;
    aWSADataRecord      : WSAData;
    NoOfInterfaces      : Integer;
    NoOfBytesReturned   : u_Long;
    InterfaceFlags      : u_Long;
    NameLength          : DWord;
    pAddrIP             : SockAddr_In;
    pAddrSubnetMask     : SockAddr_In;
    pAddrBroadcast      : Sockaddr_In;
    DirBroadcastDummy   : In_Addr;
    NetAddrDummy        : In_Addr;
    Buffer              : Array [0..30] of Interface_Info;
    i                   : Integer;
Begin
  Result := False;
  SetLength (aNetworkInterfaceList, 0);

  // Startup of old the WinSock
  // WSAStartup ($0101, aWSADataRecord);

  // Startup of WinSock2
  WSAStartup(MAKEWORD(2, 0), aWSADataRecord);

  // Open a socket
  aSocket := Socket (AF_INET, SOCK_STREAM, 0);

  // If impossible to open a socket, not worthy to go any further
  If (aSocket = INVALID_SOCKET) THen Exit;

  Try
    If WSAIoCtl (aSocket, SIO_GET_INTERFACE_LIST, NIL, 0,
                 @Buffer, 1024, @NoOfBytesReturned, NIL, NIL) <> SOCKET_ERROR THen
    Begin
      NoOfInterfaces := NoOfBytesReturned  Div SizeOf (Interface_Info);
      SetLength (aNetworkInterfaceList, NoOfInterfaces);

      // For each of the identified interfaces get:
      For i := 0 to NoOfInterfaces - 1 do
      Begin

        With aNetworkInterfaceList[i] do
        Begin

          // Get the name of the machine
          NameLength := MAX_COMPUTERNAME_LENGTH + 1;
          SetLength (ComputerName, NameLength)  ;
          If Not GetComputerName (PChar (Computername), NameLength) THen ComputerName := '';

          // Get the IP address
          pAddrIP                  := Buffer[i].iiAddress.AddressIn;
          AddrIP                   := string(inet_ntoa (pAddrIP.Sin_Addr));

          // Get the subnet mask
          pAddrSubnetMask          := Buffer[i].iiNetMask.AddressIn;
          SubnetMask               := string(inet_ntoa (pAddrSubnetMask.Sin_Addr));

          // Get the limited broadcast address
          pAddrBroadcast           := Buffer[i].iiBroadCastAddress.AddressIn;
          AddrLimitedBroadcast     := string(inet_ntoa (pAddrBroadcast.Sin_Addr));

          // Calculate the net and the directed broadcast address
          NetAddrDummy.S_addr      := Buffer[i].iiAddress.AddressIn.Sin_Addr.S_Addr;
          NetAddrDummy.S_addr      := NetAddrDummy.S_addr And Buffer[i].iiNetMask.AddressIn.Sin_Addr.S_Addr;
          DirBroadcastDummy.S_addr := NetAddrDummy.S_addr Or Not Buffer[i].iiNetMask.AddressIn.Sin_Addr.S_Addr;

          AddrNet                  := string(inet_ntoa ((NetAddrDummy)));
          AddrDirectedBroadcast    := string(inet_ntoa ((DirBroadcastDummy)));

          // From the evaluation of the Flags we receive more information
          InterfaceFlags           := Buffer[i].iiFlags;

          // Is the network interface up or down ?
          If (InterfaceFlags And IFF_UP) = IFF_UP THen IsInterfaceUp := True
                                                  Else IsInterfaceUp := False;

          // Does the network interface support limited broadcasts ?
          If (InterfaceFlags And IFF_BROADCAST) = IFF_BROADCAST THen BroadcastSupport := True
                                                                Else BroadcastSupport := False;

          // Is the network interface a loopback interface ?
          If (InterfaceFlags And IFF_LOOPBACK) = IFF_LOOPBACK THen IsLoopback := True
                                                              Else IsLoopback := False;
        end;
      end;
    end;
  Except
    //Result := False;
  end;

  // Cleanup the mess
  CloseSocket (aSocket);
  WSACleanUp;
  Result := True;
end;
{$ENDIF}

end.
  �  4   ��
 R D W D A T A M F R M       0         object %0:s: T%0:s
  OldCreateOrder = False
  Encoding = esUtf8
  Left = 531
  Top = 234
  Height = 288
  Width = 390
  object RESTDWPoolerDB1: TRESTDWPoolerDB
    Compression = True
    Encoding = esUtf8
    StrsTrim = False
    StrsEmpty2Null = False
    StrsTrim2Len = True
    Active = True
    PoolerOffMessage = 'RESTPooler not active.'
    ParamCreate = True
    Left = 84
    Top = 71
  end
  object DWServerEvents1: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crAll]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odOUT
            ObjectValue = ovString
            ParamName = 'result'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'helloworld'
        OnReplyEvent = DWServerEvents1EventshelloworldReplyEvent
      end>
    ContextName = 'SE1'
    Left = 192
    Top = 71
  end
end
     8   ��
 R D W D A T A M U N I T         0         Unit %0:s;

Interface

Uses
  SysUtils,
  Classes,
  SysTypes,
  UDWDatamodule,
  UDWJSONObject,
  Dialogs,
  ServerUtils,
  UDWConstsData,
  URESTDWPoolerDB,
  uDWConsts, uRESTDWServerEvents,
  uSystemEvents, uDWAbout,
  uRESTDWServerContext,
  DB;

Type
  T%1:s = class(%2:s)
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    procedure DWServerEvents1EventshelloworldReplyEvent(var Params: TDWParams;
      var Result: string);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
 %1:s: T%1:s;

Implementation

{$R *.dfm}

procedure T%1:s.DWServerEvents1EventshelloworldReplyEvent(
  var Params: TDWParams; var Result: string);
begin
 Result := '{"Message":"Hello World...RDW Online..."}';
end;

End.
 