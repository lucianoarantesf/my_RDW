Unit uDWJSONObject;

{$I uRESTDW.inc}

Interface

Uses
  uDWJSONInterface, uDWResponseTranslator, uDWConstsCharset, uDWConsts,
  uDWJSONTools, Variants, ServerUtils, IdURI,
  {$IFDEF FPC}
   SysUtils, Classes, DB,
   memds, LConvEncoding, math, IdGlobal
  {$ELSE}
   {$IF CompilerVersion > 22} // Delphi 2010 pra cima
    System.SysUtils, System.Classes, System.IOUtils,
    IdGlobal, System.Rtti, Data.DB, Soap.EncdDecd
   {$ELSE}
    SysUtils, Classes, DB, EncdDecd,
    DbClient, IdGlobal
  {$IFEND}
  {$ENDIF};

Const                                      // \b  \t  \n   \f   \r
 TSpecialChars : Array [0 .. 7] Of Char = ('\', '"', '/', #8, #9, #10, #12, #13);
 MaxFloatLaz       = 15;
 LazDigitsSize     = 6;

Type
 TJSONBufferObject = Class
End;

Type
 TDWParamsList = Class(TObject)
End;

Type
 TOnWriterProcess   = Procedure (DataSet : TDataSet; RecNo, RecordCount : Integer;Var AbortProcess : Boolean) Of Object;
 TDWJSONType        = (TDWJSONObjectType, TDWJSONArrayType);
 TDWJSONTypes       = Set of TDWJSONType;
 TDWParamExpType    = (tdwpxt_All, tdwpxt_IN, tdwpxt_OUT, tdwpxt_INOUT);
 TProcedureEvent    = Procedure Of Object;
 TNewDataField      = Procedure (FieldDefinition : TFieldDefinition) Of Object;
 TFieldExist        = Function  (Const Dataset   : TDataset;
                                 Value           : String) : TField  Of Object;
 TSetInitDataset    = Procedure (Const Value     : Boolean)          Of Object;
 TSetRecordCount    = Procedure (aJsonCount,
                                 aRecordCount    : Integer)          Of Object;
 TSetnotrepage      = Procedure (Value           : Boolean)          Of Object;
 TFieldListCount    = Function                   : Integer           Of Object;
 TGetInDesignEvents = Function                   : Boolean           Of Object;
 TPrepareDetails    = Procedure     (ActiveMode  : Boolean)          Of Object;

Type
 TJSONValue = Class
 Private
  vFieldExist      : TFieldExist;
  vCreateDataset,
  vNewFieldList    : TProcedureEvent;
  vNewDataField    : TNewDataField;
  vSetInitDataset  : TSetInitDataset;
  vDataType        : Boolean; // Tiago Istuque - Por Nemi Vieira - 29/01/2019
  vFieldDefinition : TFieldDefinition;
  vSetRecordCount  : TSetRecordCount;
  vSetnotrepage    : TSetnotrepage;
  vFieldListCount  : TFieldListCount;
  vGetInDesignEvents : TGetInDesignEvents;
  vSetInactive,
  vSetInBlockEvents,
  vSetInDesignEvents : TSetInitDataset;
  vPrepareDetailsNew : TProcedureEvent;
  vPrepareDetails    : TPrepareDetails;
  vJsonMode        : TJsonMode;
  vInBlockEvents,
  vInactive,
  vNullValue,
  vBinary,
  vUtf8SpecialChars,
  vEncoded         : Boolean;
  vFloatDecimalFormat,
  vtagName         : String;
  vTypeObject      : TTypeObject;
  vObjectDirection : TObjectDirection;
  vObjectValue     : TObjectValue;
  aValue           : TIdBytes;
  vEncoding        : TEncodeSelect;
  vFieldsList      : TFieldsList;
  {$IFDEF FPC}
  vEncodingLazarus : TEncoding;
  vDatabaseCharSet : TDatabaseCharSet;
  {$ENDIF}
  vOnWriterProcess : TOnWriterProcess;
  Function  GetValue(CanConvert : Boolean = True)      : Variant;
  Procedure WriteValue   (bValue             : Variant);
  Function  FormatValue  (bValue             : String) : String;
  Function  GetValueJSON (bValue             : String) : String;
  Function  DatasetValues(bValue             : TDataset;
                          DateTimeFormat     : String = '';
                          JsonModeD          : TJsonMode = jmDataware;
                          FloatDecimalFormat : String = '';
                          HeaderLowercase    : Boolean = False;
                          VirtualValue       : String = '';
                          DWJSONType         : TDWJSONType = TDWJSONArrayType;
                          bDetail            : TDataset    = Nil) : String;
  Function  EncodedString : String;
  Procedure SetEncoding  (bValue             : TEncodeSelect);
  //Desacoplamento Iniciado
  Function  GetNewFieldList                  : TProcedureEvent;
  Procedure aNewFieldList;
  Function  GetNewDataField                  : TNewDataField;
  Procedure aNewDataField     (FieldDefinition : TFieldDefinition);
  Function  GetFieldExist                    : TFieldExist;
  Function  aFieldExist       (Const Dataset : TDataset;
                               Value         : String) : TField;
  Function  GetCreateDataSet                   : TProcedureEvent;
  Procedure aCreateDataSet;
  Procedure aSetInitDataset   (Const Value   : Boolean);
  Function  GetSetInitDataset : TSetInitDataset;
  Procedure aSetRecordCount    (aJsonCount,
                                aRecordCount  : Integer);
  Function  GetSetRecordCount                 : TSetRecordCount;
  Procedure aSetnotrepage      (Value         : Boolean);
  Function  GetSetnotrepage                   : TSetnotrepage;
  Procedure aSetInDesignEvents (Const Value   : Boolean);
  Function  GetSetInDesignEvents              : TSetInitDataset;
  Procedure aSetInBlockEvents  (Const Value   : Boolean);
  Function  GetSetInBlockEvents               : TSetInitDataset;
  Procedure aSetInactive       (Const Value   : Boolean);
  Function  GetSetInactive                    : TSetInitDataset;
  Function  aFieldListCount                   : Integer;
  Function  GetFieldListCount                 : TFieldListCount;
  Class Function FieldDefExist (Const Dataset : TDataset;
                                Value         : String) : TFieldDef;
  Function  aGetInDesignEvents                : Boolean;
  Function  GetGetInDesignEvents              : TGetInDesignEvents;
  Procedure aPrepareDetailsNew;
  Function  GetPrepareDetailsNew              : TProcedureEvent;
  Procedure aPrepareDetails      (ActiveMode  : Boolean);
  Function  GetPrepareDetails                 : TPrepareDetails;
  Procedure ExecSetInactive      (Value       : Boolean);
  //Desacoplamento Finalizado
  Procedure SetFieldsList(Value : TFieldsList);
  Procedure ClearFieldList;
 Public
  Function  AsString : String;
  Procedure Clear;
  Procedure ToStream       (Var bValue       : TMemoryStream);
  Procedure LoadFromDataset(TableName        : String;
                            bValue           : TDataset;
                            EncodedValue     : Boolean = True;
                            JsonModeD        : TJsonMode = jmDataware;
                            DateTimeFormat   : String = '';
                            DelimiterFormat  : String = '';
                            {$IFDEF FPC}
                            CharSet          : TDatabaseCharSet = csUndefined;
                            {$ENDIF}
                            DataType         : Boolean = False;
                            HeaderLowercase  : Boolean = False);Overload;
  Procedure LoadFromDataset(TableName        : String;
                            bValue,
                            bDetail          : TDataset;
                            DetailType       : TDWJSONType = TDWJSONArrayType;
                            DetailElementName: String      = 'detail';
                            EncodedValue     : Boolean = True;
                            JsonModeD        : TJsonMode = jmDataware;
                            DateTimeFormat   : String = '';
                            DelimiterFormat  : String = '';
                            {$IFDEF FPC}
                            CharSet          : TDatabaseCharSet = csUndefined;
                            {$ENDIF}
                            DataType         : Boolean = False;
                            HeaderLowercase  : Boolean = False);Overload;
  Procedure WriteToFieldDefs(JSONValue                : String;
                             Const ResponseTranslator : TDWResponseTranslator);
  procedure WriteToDataset2(JSONValue: String; DestDS: TDataset);
  Procedure WriteToDataset (JSONValue          : String;
                            Const DestDS       : TDataset);Overload;
  Procedure WriteToDataset (JSONValue          : String;
                            Const DestDS       : TDataset;
                            ResponseTranslator : TDWResponseTranslator;
                            ResquestMode       : TResquestMode);Overload;
  Procedure WriteToDataset (DatasetType      : TDatasetType;
                            JSONValue        : String;
                            Const DestDS     : TDataset;
                            Var JsonCount    : Integer;
                            Datapacks        : Integer          = -1;
                            ActualRec        : Integer          = 0;
                            ClearDataset     : Boolean          = False{$IFDEF FPC};
                            CharSet          : TDatabaseCharSet = csUndefined{$ENDIF});Overload;
  Procedure WriteToDataset (DatasetType      : TDatasetType;
                            JSONValue        : String;
                            Const DestDS     : TDataset;
                            ClearDataset     : Boolean          = False{$IFDEF FPC};
                            CharSet          : TDatabaseCharSet = csUndefined{$ENDIF});Overload;
  Procedure LoadFromJSON   (bValue           : String);Overload;
  Procedure LoadFromJSON   (bValue           : String;
                            JsonModeD        : TJsonMode);Overload;
  Procedure LoadFromStream (Stream           : TMemoryStream;
                            Encode           : Boolean = True);
  Procedure SaveToStream   (Const Stream     : TMemoryStream;
                            Binary           : Boolean = False);
  Procedure SaveToFile     (FileName         : String);
  Procedure StringToBytes  (Value            : String;
                            Encode           : Boolean = False);
  Function  ToJSON : String;
  Procedure SetValue       (Value            : Variant;
                            Encode           : Boolean = True);
  Function    Value           : Variant;
  Constructor Create;
  Destructor  Destroy; Override;
  Property ServerFieldList    : TFieldsList        Read vFieldsList          Write SetFieldsList;
  Property NewFieldList       : TProcedureEvent    Read GetNewFieldList      Write vNewFieldList;
  Property FieldExist         : TFieldExist        Read GetFieldExist        Write vFieldExist;
  Property CreateDataset      : TProcedureEvent    Read GetCreateDataSet       Write vCreateDataset;
  Property NewDataField       : TNewDataField      Read GetNewDataField      Write vNewDataField;
  Property SetInitDataset     : TSetInitDataset    Read GetSetInitDataset    Write vSetInitDataset;
  Property SetRecordCount     : TSetRecordCount    Read GetSetRecordCount    Write vSetRecordCount;
  Property Setnotrepage       : TSetnotrepage      Read GetSetnotrepage      Write vSetnotrepage;
  Property SetInDesignEvents  : TSetInitDataset    Read GetSetInDesignEvents Write vSetInDesignEvents;
  Property SetInBlockEvents   : TSetInitDataset    Read GetSetInBlockEvents  Write vSetInBlockEvents;
  Property SetInactive        : TSetInitDataset    Read GetSetInactive       Write vSetInactive;
  Property FieldListCount     : TFieldListCount    Read GetFieldListCount    Write vFieldListCount;
  Property GetInDesignEvents  : TGetInDesignEvents Read GetGetInDesignEvents Write vGetInDesignEvents;
  Property PrepareDetailsNew  : TProcedureEvent    Read GetPrepareDetailsNew Write vPrepareDetailsNew;
  Property PrepareDetails     : TPrepareDetails    Read GetPrepareDetails    Write vPrepareDetails;
  Function IsNull             : Boolean;
  Property TypeObject         : TTypeObject        Read vTypeObject         Write vTypeObject;
  Property ObjectDirection    : TObjectDirection   Read vObjectDirection    Write vObjectDirection;
  Property ObjectValue        : TObjectValue       Read vObjectValue        Write vObjectValue;
  Property Binary             : Boolean            Read vBinary             Write vBinary;
  Property Utf8SpecialChars   : Boolean            Read vUtf8SpecialChars   Write vUtf8SpecialChars;
  Property Encoding           : TEncodeSelect      Read vEncoding           Write SetEncoding;
  Property Tagname            : String             Read vtagName            Write vtagName;
  Property Encoded            : Boolean            Read vEncoded            Write vEncoded;
  Property JsonMode           : TJsonMode          Read vJsonMode           Write vJsonMode;
  Property FloatDecimalFormat : String             Read vFloatDecimalFormat Write vFloatDecimalFormat;
  {$IFDEF FPC}
  Property DatabaseCharSet    : TDatabaseCharSet   Read vDatabaseCharSet    Write vDatabaseCharSet;
  {$ENDIF}
  Property OnWriterProcess    : TOnWriterProcess   Read vOnWriterProcess    Write vOnWriterProcess;
  Property Inactive           : Boolean            Read vInactive           Write ExecSetInactive;
End;

Type
 PJSONParam = ^TJSONParam;
 TJSONParam = Class(TObject)
 Private
  vJSONValue       : TJSONValue;
  vJsonMode        : TJsonMode;
  vEncoding        : TEncodeSelect;
  vTypeObject      : TTypeObject;
  vObjectDirection : TObjectDirection;
  vObjectValue     : TObjectValue;
  vCripto          : TCripto;
  vAlias,
  vFloatDecimalFormat,
  vParamName,
  vParamFileName,
  vParamContentType: String;
  vDefaultValue    : Variant;
  vNullValue,
  vBinary,
  vEncoded         : Boolean;
  {$IFDEF FPC}
  vEncodingLazarus : TEncoding;
  vDatabaseCharSet : TDatabaseCharSet;
  {$ENDIF}
  Procedure WriteValue      (bValue     : Variant);
  Procedure SetParamName    (bValue     : String);
  Procedure SetParamFileName(bValue     : String);
  Function  GetAsString : String;
  Procedure SetAsString    (Value      : String);
  {$IFDEF DEFINE(FPC) Or NOT(Defined(HAS_FMX))}
  Function  GetAsWideString : WideString;
  Procedure SetAsWideString(Value      : WideString);
  Function  GetAsAnsiString : AnsiString;
  Procedure SetAsAnsiString(Value      : AnsiString);
  {$ENDIF}
  Function  GetAsBCD      : Currency;
  Procedure SetAsBCD      (Value       : Currency);
  Function  GetAsFMTBCD   : Currency;
  Procedure SetAsFMTBCD   (Value       : Currency);
  Function  GetAsCurrency : Currency;
  Procedure SetAsCurrency (Value       : Currency);
  Function  GetAsBoolean  : Boolean;
  Procedure SetAsBoolean  (Value       : Boolean);
  Function  GetAsDateTime : TDateTime;
  Procedure SetAsDateTime (Value       : TDateTime);
  Procedure SetAsDate     (Value       : TDateTime);
  Procedure SetAsTime     (Value       : TDateTime);
  Function  GetAsSingle    : Single;
  Procedure SetAsSingle   (Value       : Single);
  Function  GetAsFloat     : Double;
  Procedure SetAsFloat    (Value       : Double);
  Function  GetAsInteger  : Integer;
  Procedure SetAsInteger  (Value       : Integer);
  Function  GetAsWord     : Word;
  Procedure SetAsWord     (Value       : Word);
  Procedure SetAsSmallInt (Value       : Integer);
  Procedure SetAsShortInt (Value       : Integer);
  Function  GetAsLongWord : LongWord;
  Procedure SetAsLongWord (Value       : LongWord);
  Function  GetAsLargeInt : LargeInt;
  Procedure SetAsLargeInt (Value       : LargeInt);
  Procedure SetObjectValue(Value       : TObjectValue);
  Procedure SetObjectDirection(Value   : TObjectDirection);
  Function  GetByteString : String;
  Procedure SetAsObject   (Value       : String);
  Procedure SetEncoded    (Value       : Boolean);
  Procedure SetParamContentType(Const bValue : String);
  {$IFDEF FPC}
  Procedure SetDatabaseCharSet (Value  : TDatabaseCharSet);
  {$ENDIF}
  Function TestNilParam : Boolean;
 Public
  Procedure   Clear;
  Constructor Create      (Encoding    : TEncodeSelect);
  Procedure   Assign      (Source      : TObject);
  Destructor  Destroy; Override;
  Function    IsEmpty : Boolean;
  Function    IsNull  : Boolean;
  Procedure   FromJSON    (json        : String);
  Function    ToJSON  : String;
  Procedure   SaveToFile  (FileName       : String);
  Procedure   CopyFrom    (JSONParam   : TJSONParam);
  Procedure   SetVariantValue(Value    : Variant);
  Procedure   SetDataValue   (Value    : Variant;
                              DataType : TObjectValue);
  Function  GetVariantValue : Variant;
  Function  GetNullValue     (Value    : TObjectValue) : Variant;
  Function  GetValue         (Value    : TObjectValue) : Variant;
  Procedure SetValue         (aValue   : String;
                              Encode   : Boolean = True);
  Procedure LoadFromStream   (Stream   : TMemoryStream;
                              Encode   : Boolean = True);Overload;
  Procedure LoadFromStream   (Stream   : TStringStream;
                              Encode   : Boolean = True);Overload;
  Procedure StringToBytes    (Value    : String;
                              Encode   : Boolean = False);
  Procedure SaveToStream     (Var Stream   : TMemoryStream);Overload;
  Procedure SaveToStream     (Var Stream   : TStringStream);Overload;
  Procedure LoadFromParam    (Param    : TParam);
  Procedure SaveFromParam    (Param    : TParam);
  Property  CriptOptions      : TCripto          Read vCripto             Write vCripto;
  {$IFDEF FPC}
  Property  DatabaseCharSet   : TDatabaseCharSet Read vDatabaseCharSet    Write SetDatabaseCharSet;
  {$ENDIF}
  Property ObjectDirection    : TObjectDirection Read vObjectDirection    Write SetObjectDirection;
  Property ObjectValue        : TObjectValue     Read vObjectValue        Write SetObjectValue;
  Property Alias              : String           Read vAlias              Write vAlias;
  Property ParamName          : String           Read vParamName          Write SetParamName;
  Property ParamFileName      : String           Read vParamFileName      Write SetParamFileName;
  Property ParamContentType   : String           Read vParamContentType   Write SetParamContentType;
  Property Encoded            : Boolean          Read vEncoded            Write SetEncoded;
  Property Binary             : Boolean          Read vBinary;
  Property JsonMode           : TJsonMode        Read vJsonMode           Write vJsonMode;
  Property FloatDecimalFormat : String           Read vFloatDecimalFormat Write vFloatDecimalFormat;
  // Propriedades Novas
  Property Value              : Variant          Read GetVariantValue     Write SetVariantValue;
  Property DefaultValue       : Variant          Read vDefaultValue       Write vDefaultValue;
  // Novas defini��es por tipo
  Property AsBCD              : Currency         Read GetAsBCD            Write SetAsBCD;
  Property AsFMTBCD           : Currency         Read GetAsFMTBCD         Write SetAsFMTBCD;
  Property AsBoolean          : Boolean          Read GetAsBoolean        Write SetAsBoolean;
  Property AsCurrency         : Currency         Read GetAsCurrency       Write SetAsCurrency;
  Property AsExtended         : Currency         Read GetAsCurrency       Write SetAsCurrency;
  Property AsDate             : TDateTime        Read GetAsDateTime       Write SetAsDate;
  Property AsTime             : TDateTime        Read GetAsDateTime       Write SetAsTime;
  Property AsDateTime         : TDateTime        Read GetAsDateTime       Write SetAsDateTime;
  Property AsSingle           : Single           Read GetAsSingle         Write SetAsSingle;
  Property AsFloat            : Double           Read GetAsFloat          Write SetAsFloat;
  Property AsInteger          : Integer          Read GetAsInteger        Write SetAsInteger;
  Property AsSmallInt         : Integer          Read GetAsInteger        Write SetAsSmallInt;
  Property AsShortInt         : Integer          Read GetAsInteger        Write SetAsShortInt;
  Property AsWord             : Word             Read GetAsWord           Write SetAsWord;
  Property AsLongWord         : LongWord         Read GetAsLongWord       Write SetAsLongWord;
  Property AsLargeInt         : LargeInt         Read GetAsLargeInt       Write SetAsLargeInt;
  Property AsString           : String           Read GetAsString         Write SetAsString;
  Property AsObject           : String           Read GetAsString         Write SetAsObject;
  Property AsByteString       : String           Read GetByteString;
  {$IFDEF DEFINE(FPC) Or NOT(Defined(HAS_FMX))}
  Property AsWideString       : WideString       Read GetAsWideString     Write SetAsWideString;
  Property AsAnsiString       : AnsiString       Read GetAsAnsiString     Write SetAsAnsiString;
  {$ENDIF}
  Property AsMemo             : String           Read GetAsString         Write SetAsString;
End;

Type
 PStringStream = ^TStringStream;
 TStringStreamList = Class(TList)
 Private
  Function  GetRec(Index : Integer): TStringStream; Overload;
  Procedure PutRec(Index : Integer;
                   Item  : TStringStream); Overload;
  Procedure ClearList;
 Public
  Procedure   Clear;Override;
  Constructor Create;
  Destructor  Destroy; Override;
  Procedure   Delete(Index : Integer); Overload;
  Function    Add   (Item  : TStringStream) : Integer; Overload;
  Property    Items [Index : Integer] : TStringStream Read GetRec Write PutRec; Default;
End;

Type
 TRESTDWHeaders = Class(TObject)
  Input,
  Output : TStringList;
  Constructor Create;
  Destructor Destroy;Override;
End;

Type
 TDWParams = Class(TList)
 Private
  vJsonMode     : TJsonMode;
  vEncoding     : TEncodeSelect;
  vCripto       : TCripto;
  vHeaders      : TRESTDWHeaders;
  vUrl_Redirect : String;
  {$IFDEF FPC}
  vEncodingLazarus : TEncoding;
  vDatabaseCharSet : TDatabaseCharSet;
  {$ENDIF}
  Procedure Assign    (Source : TList);
  Function  GetRec    (Index  : Integer) : TJSONParam; Overload;
  Procedure PutRec    (Index  : Integer;
                       Item   : TJSONParam);           Overload;
  Function  GetRecName(Index  : String)  : TJSONParam; Overload;
  Function  GetRawBody        : TJSONParam;
  Procedure PutRecName(Index  : String;
                       Item   : TJSONParam);           Overload;
  Procedure PutRawBody(Item  : TJSONParam);
  Procedure ClearList;
 Public
//  Procedure   Clear;Override;
  Constructor Create;
  Procedure   CreateParam(ParamName : String;
                          Value     : String = '');
  Destructor  Destroy; Override;
  Function    ParamsReturn          : Boolean;
  Function    CountOutParams        : Integer;
  Function    CountInParams         : Integer;
  Function    ToJSON                : String;
  Procedure   SaveToFile (FileName  : String);
  Procedure   FromJSON   (json      : String; BinaryRequest : Boolean = False);
  Procedure   CopyFrom   (DWParams  : TDWParams);
  Procedure   Delete     (Index     : Integer); Overload;
  Procedure   Delete     (Param     : TJSONParam); Overload;
  Function    Add        (Item      : TJSONParam) : Integer; Overload;
  Procedure   SaveToStream  (Stream : TStream; Output : TDWParamExpType = tdwpxt_All);
  Procedure   LoadFromStream(Stream : TStream; Input  : TDWParamExpType = tdwpxt_All);
  Procedure   LoadFromParams(Params : TParams);
  Procedure   SetCriptOptions(Use   : Boolean;
                              Key   : String);
  Property    Items      [Index     : Integer]    : TJSONParam Read GetRec        Write PutRec; Default;
  Property    ItemsString[Index     : String]     : TJSONParam Read GetRecName    Write PutRecName;
  Property    RawBody               : TJSONParam               Read GetRawBody    Write PutRawBody;
  Property    JsonMode              : TJsonMode                Read vJsonMode     Write vJsonMode;
  Property    Encoding              : TEncodeSelect            Read vEncoding     Write vEncoding;
  Property    CriptOptions          : TCripto                  Read vCripto       Write vCripto;
  Property    RequestHeaders        : TRESTDWHeaders           Read vHeaders      Write vHeaders;
  Property    Url_Redirect          : String                   Read vUrl_Redirect Write vUrl_Redirect;
  {$IFDEF FPC}
  Property DatabaseCharSet          : TDatabaseCharSet Read vDatabaseCharSet    Write vDatabaseCharSet;
  {$ENDIF}
End;

Type
 TDWDatalist = Class
End;

Type
 TOnGetToken       = Procedure (Welcomemsg,
                                AccessTag         : String;
                                Params            : TDWParams;
                                AuthOptions       : TRDWAuthTokenParam;
                                Var ErrorCode     : Integer;
                                Var ErrorMessage  : String;
                                Var TokenID       : String;
                                Var Accept        : Boolean) Of Object;
 TOnBeforeGetToken = Procedure (Welcomemsg,
                                AccessTag         : String;
                                Params            : TDWParams)  Of Object;

Function StringToJsonString(OriginalString : String) : String;
Function CopyValue         (Var bValue     : String) : String;
Function unescape_chars    (s              : String) : String;
Function escape_chars      (s              : String) : String;
Function StringToGUID      (GUID           : String) : TGUID;
{$IFNDEF FPC}
  {$IF CompilerVersion > 22} // Delphi 2010 pra cima
    {$IF DEFINED(iOS) or DEFINED(ANDROID)}
    Procedure SaveLog(Value, FileName : String);
    {$IFEND}
  {$IFEND}
{$ENDIF}

implementation

Uses
 PropertyPersist;

{$IFNDEF FPC}
  {$IF CompilerVersion > 22} // Delphi 2010 pra cima
    {$IF DEFINED(iOS) or DEFINED(ANDROID)}
    Procedure SaveLog(Value, FileName : String);
    Var
     StringStream : TStringStream;
    Begin
     StringStream := TStringStream.Create(Value);
     Try
      StringStream.Position := 0;
      StringStream.SaveToFile(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetSharedDocumentsPath, FileName)); //Log FMX
     Finally
      FreeAndNil(StringStream);
     End;
    End;
    {$IFEND}
  {$IFEND}
{$ENDIF}

Function unescape_chars(s : String) : String;
 Function HexValue(C: Char): Byte;
 Begin
  Case C of
   '0'..'9':  Result := Byte(C) - Byte('0');
   'a'..'f':  Result := (Byte(C) - Byte('a')) + 10;
   'A'..'F':  Result := (Byte(C) - Byte('A')) + 10;
   Else raise Exception.Create('Illegal hexadecimal characters "' + C + '"');
  End;
 End;
Var
 C    : Char;
 I,
 ubuf : Integer;
Begin
 Result := '';
 I := InitStrPos;
 While I <= (Length(S) - FinalStrPos) Do
  Begin
   C := S[I];
   Inc(I);
   If C = '\' then
    Begin
     C := S[I];
     Inc(I);
     Case C of
      'b': Result := Result + #8;
      't': Result := Result + #9;
      'n': Result := Result + #10;
      'f': Result := Result + #12;
      'r': Result := Result + #13;
      'u': Begin
            If Not TryStrToInt('$' + Copy(S, I, 4), ubuf) Then
             Raise Exception.Create(format('Invalid unicode \u%s',[Copy(S, I, 4)]));
            Result := result + WideChar(ubuf);
            Inc(I, 4);
           End;
       Else Result := Result + C;
     End;
    End
   Else Result := Result + C;
  End;
End;

Function escape_chars(s : String) : String;
Var
 b, c   : Char;
 i, len : Integer;
 sb, t  : String;
 Const
  NoConversion = ['A'..'Z','a'..'z','*','@','.','_','-',
                  '0'..'9','$','!','''','(',')', ' '];
 Function toHexString(c : char) : String;
 Begin
  Result := IntToHex(ord(c), 2);
 End;
Begin
 c      := #0;
 {$IFDEF FPC}
 b      := #0;
 i      := 0;
 {$ENDIF}
 len    := length(s);
 Result := '';
  //SetLength (s, len+4);
 t      := '';
 sb     := '';
 For  i := InitStrPos to len - FinalStrPos Do
  Begin
   b := c;
   c := s[i];
   Case (c) Of
    '\', '"' : Begin
                sb := sb + '\';
                sb := sb + c;
               End;
    '/' :      Begin
                If (b = '<') Then
                 sb := sb + '\';
                sb := sb + c;
               End;
    #8  :      Begin
                sb := sb + '\b';
               End;
    #9  :      Begin
                sb := sb + '\t';
               End;
    #10 :      Begin
                sb := sb + '\n';
               End;
    #12 :      Begin
                sb := sb + '\f';
               End;
    #13 :      Begin
                sb := sb + '\r';
               End;
    Else       Begin
                If (Not (c in NoConversion)) Then
                 Begin
                    t := '000' + toHexString(c);
                    sb := sb + '\u' + copy (t, Length(t) -3,4);
                 End
                Else
                 sb := sb + c;
               End;
   End;
  End;
 Result := sb;
End;

Procedure SetValueA(Field : TField;
                    Value : String);
Var
 vTempValue : String;
Begin
 Case Field.DataType Of
  ftUnknown,
  ftString,
  ftFixedChar,
  ftWideString : Field.AsString := Value;
  ftAutoInc,
  ftSmallint,
  ftInteger,
  ftLargeint,
  ftWord,
  {$IFNDEF FPC}
   {$IF CompilerVersion > 21} // Delphi 2010 pra cima
    ftShortint, ftByte, ftLongWord,
   {$IFEND}
  {$ENDIF}
  ftBoolean    : Begin
                  Value := Trim(Value);
                  If Value <> '' Then
                   Begin
                    If Field.DataType = ftBoolean Then
                     Begin
                      If (Value = '0') Or (Value = '1') Then
                       Field.AsBoolean := StrToInt(Value) = 1
                      Else
                       Field.AsBoolean := Lowercase(Value) = 'true';
                     End
                    Else
                     Begin
                      If Field.DataType = ftLargeint Then
                       Begin
                        {$IFNDEF FPC}
                         {$IF CompilerVersion > 22}
                          Field.AsLargeInt := StrToInt64(Value);
                         {$ELSE}
                          Field.AsInteger  := StrToInt64(Value);
                         {$IFEND}
                        {$ELSE}
                         Field.AsInteger  := StrToInt64(Value);
                        {$ENDIF}
                       End
                      Else
                       Field.AsInteger := StrToInt(Value);
                     End;
                   End;
                 End;
  ftFloat,
  ftCurrency,
  ftBCD,
  {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
  {$IFEND}{$ENDIF}
  ftFMTBcd     : Begin
                  Value := Trim(Value);
                  vTempValue := BuildFloatString(Value);
                  If vTempValue <> '' Then
                   Begin
                    Case Field.DataType Of
                     ftFloat  : Field.AsFloat := StrToFloat(vTempValue);
                     ftCurrency,
                     ftBCD,
                     {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                     {$IFEND}{$ENDIF}
                     ftFMTBcd : Begin
                                 If Field.DataType in [ftBCD, ftFMTBcd] Then
                                  {$IFDEF FPC}
                                   Field.AsFloat := StrToFloat(vTempValue)
                                  {$ELSE}
                                   {$IF CompilerVersion > 22}
                                    Field.AsBCD := StrToFloat(vTempValue)
                                   {$ELSE}
                                    Field.AsFloat := StrToFloat(vTempValue)
                                   {$IFEND}
                                  {$ENDIF}
                                 Else
                                  Field.AsFloat := StrToFloat(vTempValue);
                                End;
                    End;
                   End;
                 End;
  ftDate,
  ftTime,
  ftDateTime,
  ftTimeStamp  : Begin
                  vTempValue := Value;
                  If vTempValue <> '' Then
                   Begin
                    If (Pos('.', vTempValue) > 0) Or
                       (Pos(':', vTempValue) > 0) Or
                       (Pos('/', vTempValue) > 0) Or
                       (Pos('\', vTempValue) > 0) Or
                       (Pos('-', vTempValue) > 0) Then
                     Field.AsDateTime := StrToDateTime(vTempValue)
                    Else
                     Begin
                      {$IFDEF FPC}
                       If StrToInt64(vTempValue) > 0 Then
                        Field.AsDateTime := UnixToDateTime(StrToInt64(vTempValue));
                      {$ELSE}
                       If StrToInt64(vTempValue) > 0 Then
                       {$IF CompilerVersion < 22}
                        Field.AsDateTime := UnixToDateTime(StrToInt64(vTempValue));
                       {$ELSE}
                        Field.AsDateTime := UnixToDateTime(StrToInt64(vTempValue));
                       {$IFEND}
                      {$ENDIF}
                     End;
                   End;
                 End;
 End;
End;

Function RemoveSTR(Astr: string; Asubstr: string): string;
Begin
 Result := StringReplace(Astr, Asubstr, '', [rfReplaceAll, rfIgnoreCase]);
End;

Function StringToJsonString(OriginalString: String): String;
Var
 I : Integer;
 Function NewChar(OldChar: String): String;
 Begin
  Result := '';
  If Length(OldChar) > 0 Then
   Begin
    Case OldChar[1] Of
     '\' : Result := '\\';
     '"' : Result := '\"';
     '/' : Result := '\/';
     #8  : Result := '\b';
     #9  : Result := '\t';
     #10 : Result := '\n';
     #12 : Result := '\f';
     #13 : Result := '\r';
    End;
   End;
 End;
Begin
 Result := OriginalString;
 For I := 0 To Length(TSpecialChars) - 1 Do
  Result := StringReplace(Result, TSpecialChars[i], NewChar(TSpecialChars[i]), [rfReplaceAll]);
End;

Function Expnumber(number, exponent : Integer) : Integer;
Var
 counter : Integer;
Begin
 Result :=1;
 If exponent = 0 Then exit;
 For counter := 1 To exponent Do
  Result := Result * number;
End;

Function hextodec(hex : String) : Integer;
Var
 counter,
 value    : Integer;
Begin
 Result:=0;
 For counter := 0 To length(hex) - 1 Do
  Begin
   Case hex[length(hex)-counter] of
    'A': value := 10;
    'B': value := 11;
    'C': value := 12;
    'D': value := 13;
    'E': value := 14;
    'F': value := 15;
    Else Value := Strtoint(hex[length(hex) - counter]);
   End;
   Result := Result + Value * expnumber(16, counter);
  End;
End;

Function StringToGUID(GUID : String) : TGUID;
Var
 counter : Integer;
 newword : String;
begin
 If (guid[InitStrPos] <> '{') or
    (guid[10 - FinalStrPos] <> '-') or (guid[15 - FinalStrPos] <> '-') or
    (guid[20 - FinalStrPos] <> '-') or (guid[25 - FinalStrPos] <> '-') or
    (guid[38 - FinalStrPos] <> '}') Then exit;
  //Do D1
 newword := '';
 For counter := 2 to 9 do
  newword  := newword + guid[counter];
 Result.d1 := hextodec(newword);
  //Do D2
 newword   := '';
 For counter := 11 to 14 do
  newword  := newword + guid[counter];
 Result.d2 := hextodec(newword);
  //Do D3
 newword   := '';
 For counter := 16 to 19 do
  newword  := newword + guid[counter];
 Result.d3 := hextodec(newword);
  //Do D4a
 Result.D4[0] := hextodec(guid[21]+guid[22]);
 Result.D4[1] := hextodec(guid[23]+guid[24]);
  //Do D4b
 Result.D4[2] := hextodec(guid[26]+guid[27]);
 Result.D4[3] := hextodec(guid[28]+guid[29]);
 Result.D4[4] := hextodec(guid[30]+guid[31]);
 Result.D4[5] := hextodec(guid[32]+guid[33]);
 Result.D4[6] := hextodec(guid[34]+guid[35]);
 Result.D4[7] := hextodec(guid[36]+guid[37]);
End;

Function CopyValue(Var bValue : String): String;
Var
 vOldString,
 vStringBase,
 vTempString      : String;
 A, vLengthString : Integer;
Begin
 If bValue = '' Then
  Exit;
 vOldString := bValue;
 vStringBase := '"ValueType":"';
 vLengthString := Length(vStringBase);
 vTempString := Copy(bValue, Pos(vStringBase, bValue) + vLengthString, Length(bValue));
 A := Pos(':', vTempString);
 vTempString := Copy(vTempString, A, Length(vTempString));
 If vTempString <> '' Then
  Begin
   If vTempString[InitStrPos] = ':' Then
    Delete(vTempString, 1, 1);
   If vTempString[InitStrPos] = '"' Then
    Delete(vTempString, 1, 1);
  End;
 If vTempString = '}' Then
  vTempString := '';
 If vTempString <> '' Then
  Begin
   For A := Length(vTempString) -FinalStrPos Downto InitStrPos Do
    Begin
     If vTempString[A] <> '}' Then
      Delete(vTempString, Length(vTempString), 1)
     Else
      Begin
       Delete(vTempString, Length(vTempString), 1);
       Break;
      End;
    End;
   If vTempString[Length(vTempString) -FinalStrPos] = '"' Then
    Delete(vTempString, Length(vTempString), 1);
  End;
 Result := vTempString;
 bValue := StringReplace(bValue, Result, '', [rfReplaceAll]);
End;

Procedure TDWParams.SaveToStream(Stream : TStream;
                                 Output : TDWParamExpType = tdwpxt_All);
Var
 ParamsHeader : TDWParamsHeader;
// vTempString  : String;
 {$IFNDEF FPC}
  {$if CompilerVersion < 21}
   aStream    : TStringStream;
  {$IFEND}
 {$ENDIF}
 aCount,
 I, Temp      : Integer;
 EndPos,
 StartPos     : Int64;
 Procedure SaveParamsToStream(Var Stream : TStream);
 Var
  vNull, I : Integer;
  J, L     : DWInt64;
  {$IFNDEF FPC}
   {$IF (CompilerVersion >= 20)}
     S, W     : RawByteString;
   {$ELSE}
     S, W     : AnsiString;
   {$IFEND}
  {$ELSE}
   S, W     : AnsiString;
  {$ENDIF}
  Sing     : Single;
  WordData : Word;
  B        : Boolean;
  P        : TMemoryStream;
  T        : DWFieldTypeSize;
  D        : TDateTime;
  aParam   : TJSONParam;
 Begin
  For I := 0 To Count - 1 do
   Begin
    aParam  := GetRec(I);
    //Define who go out
    If Output <> tdwpxt_All Then
     Begin
      If ((aParam.ObjectDirection = odIN)  And
          (Output = tdwpxt_OUT)) Or
         ((aParam.ObjectDirection = odOUT) And
          (Output = tdwpxt_IN)) Then
       Continue;
     End;
    aCount := aCount + 1;
    //ParamName
    S := aParam.ParamName;
    L := Length(S);
    Stream.Write(L, Sizeof(DWInt64));
    {$IFNDEF FPC}
    If L <> 0 Then Stream.Write(S[InitStrPos], L);
    {$ELSE}
    If L <> 0 Then Stream.Write(Utf8Encode(S)[1], L);
    {$ENDIF}
    //ObjectDirection
    T := DWFieldTypeSize(aParam.ObjectDirection);
    Stream.Write(T, Sizeof(DWFieldTypeSize));
    //Encoded
    B := aParam.Encoded;
    Stream.Write(B, Sizeof(WordBool));
    //JsonMode
    T := DWFieldTypeSize(aParam.JsonMode);
    Stream.Write(T, Sizeof(DWFieldTypeSize));
    //TypeObject
    T := DWFieldTypeSize(aParam.vTypeObject);
    Stream.Write(T, Sizeof(DWFieldTypeSize));
    //DataType
    T := DWFieldTypeSize(aParam.ObjectValue);
    Stream.Write(T, Sizeof(DWFieldTypeSize));
    //GetValue from Datatype
    L     := 0;
    vNull := 0;
    Case TObjectValue(T) Of
       ovFixedChar,
       ovWideString,
       ovString,
       ovObject : Begin
                   If aParam.isnull Then
                    Begin
                     L := vNull;
                     Stream.WriteBuffer(L, Sizeof(DWInt64));
                    End
                   Else
                    Begin
                     S := aParam.AsString;
                     L := Length(S);
                     Stream.Write(L, Sizeof(DWInt64));
                    End;
                   {$IFNDEF FPC}
                   If L <> 0 Then Stream.Write(S[InitStrPos], L);
                   {$ELSE}
                   If L <> 0 Then Stream.Write(S[1], L);
                   {$ENDIF}
                  End;
       ovSmallint : Begin
                     If aParam.isnull Then
                      Begin
                       J := vNull;
                       Stream.Write(J, Sizeof(DWInteger));
                      End
                     Else
                      Begin
                       J := aParam.AsInteger;
                       Stream.Write(J, Sizeof(DWInteger));
                      End;
                    End;
       ovLongWord : Begin
                     If aParam.isnull Then
                      Begin
                       J := vNull;
                       Stream.Write(J, Sizeof(DWInteger));
                      End
                     Else
                      Begin
                       J := aParam.AsInteger;
                       Stream.Write(J, Sizeof(DWInteger));
                      End;
                    End;
       ovShortint : Begin
                     If aParam.isnull Then
                      Begin
                       J := vNull;
                       Stream.Write(J, Sizeof(DWInteger));
                      End
                     Else
                      Begin
                       J := aParam.AsInteger;
                       Stream.Write(J, Sizeof(DWInteger));
                      End;
                    End;
       ovByte     : Begin
                     If aParam.isnull Then
                      Begin
                       B := False;
                       Stream.Write(B, Sizeof(Byte));
                      End
                     Else
                      Begin
                       B := aParam.AsBoolean;
                       Stream.Write(B, Sizeof(Byte));
                      End;
                    End;
       ovBoolean  : Begin
                     If aParam.isnull Then
                      Begin
                       B := False;
                       Stream.Write(B, Sizeof(WordBool));
                      End
                     Else
                      Begin
                       B := aParam.AsBoolean;
                       Stream.Write(B, Sizeof(WordBool));
                      End;
                    End;
       ovExtended : Begin
                     If Not((aParam.IsEmpty) and (aParam.IsNull)) Then
                      Begin
                       S := BuildStringFloat(aParam.AsString);
                       J := Length(S);
                       Stream.Write(J, Sizeof(DWInteger));
                       If J <> 0 then
                        Stream.Write(S[InitStrPos], J);
                      End
                     Else
                      Begin
                       S := TNullString;
                       J := Length(S);
                       Stream.Write(J, Sizeof(DWInteger));
                       If J <> 0 then
                        Stream.WriteBuffer(S[InitStrPos], J);
                      End;
                    End;
       ovSingle   : Begin
                     If aParam.isnull Then
                      Begin
                       Sing := vNull;
                       Stream.Write(Sing, Sizeof(DWInteger));
                      End
                     Else
                      Begin
                       Sing := aParam.AsSingle;
                       Stream.Write(Sing, Sizeof(DWInteger));
                      End;
                    End;
       ovDate,
       ovTime,
       ovDateTime,
       ovTimeStamp,
       ovTimeStampOffset: Begin
                           If Not aParam.IsNull Then
                            J := DateTimeToUnix(aParam.AsDateTime)
                           Else
                            J := vNull;
                           Stream.Write(J, Sizeof(DWInt64));
                          End;
       ovInteger,
       ovAutoInc : Begin
                    If aParam.isnull Then
                     Begin
                      J := vNull;
                      Stream.Write(J, Sizeof(DWInteger));
                     End
                    Else
                     Begin
                      J := aParam.AsInteger;
                      Stream.Write(J, Sizeof(DWInteger));
                     End;
                   End;
       ovWord    : Begin
                    If aParam.isnull Then
                     Begin
                      WordData := vNull;
                      Stream.Write(WordData, Sizeof(DWInteger));
                     End
                    Else
                     Begin
                      WordData := aParam.AsWord;
                      Stream.Write(WordData, Sizeof(DWInteger));
                     End;
                   End;
       ovFloat,
       ovCurrency,
       ovBCD,
       ovFMTBcd  : Begin
                    If Not((aParam.IsEmpty) and (aParam.IsNull)) Then
                     Begin
                      S := BuildStringFloat(aParam.AsString);
                      J := Length(S);
                      Stream.Write(J, Sizeof(DWInteger));
                      If J <> 0 then
                       Stream.Write(S[InitStrPos], J);
                     End
                    Else
                     Begin
                      S := TNullString;
                      J := Length(S);
                      Stream.Write(J, Sizeof(DWInteger));
                      If J <> 0 then
                       Stream.Write(S[InitStrPos], J);
                     End;
                   End;
       ovLargeint  : Begin
                      If aParam.isnull Then
                       Begin
                        J := vNull;
                        Stream.Write(J, Sizeof(DWInt64));
                       End
                      Else
                       Begin
                        J := aParam.AsLargeInt;
                        Stream.Write(J, Sizeof(DWInt64));
                       End;
                     End;
       ovVariant   : ;
       ovInterface : ;
       ovIDispatch : ;
       ovBlob,
       ovStream,
       ovBytes : Begin
                  P := Nil;
                  If Not aParam.isnull Then
                   aParam.SaveToStream(P);
                  If Assigned(P) Then
                   Begin
                    L := P.Size;
                    Stream.Write(L, Sizeof(DWInt64));
                    P.Position := 0;
                    If L <> 0 then
                     Stream.CopyFrom(P, L);
                    FreeAndNil(P);
                   End
                  Else
                   Begin
                    L := vNull;
                    Stream.Write(L, Sizeof(DWInt64));
                   End;
                 End;
    End;
   End;
 End;
Begin
 aCount := 0;
// vTempString := '';
 {$IFNDEF FPC}
  {$if CompilerVersion < 21}
   If Not Assigned(Stream) Then
    Stream := TStringStream.Create('');
   aStream := TStringStream.Create('');
   Try
    //Write init Header
    StartPos := Stream.Position;
    With ParamsHeader Do
     Begin
      VersionNumber := DwParamsHeaderVersion;
      DataSize      := 0;
      RecordCount   := 0;
      ParamsCount   := Count;
     End;
    //Write dwParamsBinList
    SaveParamsToStream(TStream(aStream));
    //Remap Bin size
    EndPos := aStream.Size;
    ParamsHeader.DataSize    := EndPos;
    ParamsHeader.ParamsCount := aCount;
    //Rewrite init Header
    Stream.Position := 0;
    aStream.Position := 0;
    Stream.WriteBuffer(ParamsHeader, SizeOf(TDWParamsHeader));
    Stream.CopyFrom(aStream, aStream.Size);
    Stream.Position := 0;
   Finally
    FreeAndNil(aStream);
   End;
  {$ELSE}
   If Not Assigned(Stream) Then
    Begin
     {$IFDEF FPC}
      Stream := TStringStream.Create('');
     {$ELSE}
      Stream := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
     {$ENDIF}
    End;
   //Write init Header
   StartPos := Stream.Position;
   With ParamsHeader Do
    Begin
     VersionNumber := DwParamsHeaderVersion;
     DataSize      := 0;
     RecordCount   := 0;
     ParamsCount   := Count;
    End;
   Stream.WriteBuffer(ParamsHeader, SizeOf(TDWParamsHeader));
   //Write dwParamsBinList
   SaveParamsToStream(Stream);
   //Remap Bin size
   EndPos := Stream.Position;
   ParamsHeader.DataSize    := EndPos - StartPos - SizeOf(TDWParamsHeader);
   ParamsHeader.ParamsCount := aCount;
   //Rewrite init Header
   Stream.Position := StartPos;
   Stream.WriteBuffer(ParamsHeader, SizeOf(TDWParamsHeader));
   Stream.Position := 0;
  {$IFEND}
 {$ELSE}
 If Not Assigned(Stream) Then
  Stream := TMemoryStream.Create;
 //Write init Header
 StartPos := Stream.Position;
 With ParamsHeader Do
  Begin
   VersionNumber := DwParamsHeaderVersion;
   DataSize      := 0;
   RecordCount   := 0;
   ParamsCount   := Count;
  End;
 Stream.WriteBuffer(ParamsHeader, SizeOf(TDWParamsHeader));
 //Write dwParamsBinList
 SaveParamsToStream(Stream);
 //Remap Bin size
 EndPos := Stream.Position;
 ParamsHeader.DataSize    := EndPos - StartPos - SizeOf(TDWParamsHeader);
 ParamsHeader.ParamsCount := aCount;
 //Rewrite init Header
 Stream.Position := StartPos;
 Stream.WriteBuffer(ParamsHeader, SizeOf(TDWParamsHeader));
 Stream.Position := 0;
 {$ENDIF}
// SetLength(vTempString, Stream.Size);
// Stream.ReadBuffer(Pointer(vTempString)^, Length(vTempString));
// Stream.Position := 0;
End;

Procedure TDWParams.LoadFromParams(Params : TParams);
Var
 I : Integer;
 vDwParam : TJSONParam;
Begin
 Clear;
 If Assigned(Params) Then
  Begin
   For I := 0 To Params.Count -1 Do
    Begin
     vDwParam := TJSONParam.Create(Encoding);
     vDwParam.LoadFromParam(Params[I]);
     Add(vDwParam);
    End;
  End;
End;

Procedure TDWParams.LoadFromStream(Stream : TStream;
                                   Input  : TDWParamExpType = tdwpxt_All);
Var
 ParamsHeader   : TDWParamsHeader;
 VersionNumber,
 ParamsCount,
 L              : Integer;
 {$IFNDEF FPC}
  {$IF (CompilerVersion >= 20)}
   S     : RawByteString;
  {$ELSE}
   S     : AnsiString;
  {$IFEND}
 {$ELSE}
  S     : AnsiString;
 {$ENDIF}
 DataSize,
 aSize,
 StartPos       : Int64;
 Procedure CreateDWParamsFromStream;
 Var
  I, T    : Integer;
  J, L    : DWInt64;
  B       : Boolean;
  VE      : Extended;
  vItem   : TJSONParam;
  vStream : TMemoryStream;
 Begin
  For I := 0 To ParamsCount -1 Do
   Begin
    S := '';
    Stream.ReadBuffer(L, Sizeof(DWInt64));
    SetLength(S, L);
    Try
     If L <> 0 Then
      Stream.Read(S[InitStrPos], L);
     {$IFDEF FPC}
      S := GetStringEncode(S, vDatabaseCharSet);
     {$ENDIF}
    Finally
//     StrDispose(Buffer);
    End;
    vItem := ItemsString[S];
    If Not Assigned(vItem) Then
     Begin
      vItem := TJSONParam.Create(Encoding);
      Add(vItem);
     End;
    //ParamName
    vItem.ParamName := S;
    //ObjectDirection
    Stream.ReadBuffer(T, Sizeof(DWFieldTypeSize));
    vItem.ObjectDirection := TObjectDirection(T);
    //Encoded
    Stream.ReadBuffer(B, Sizeof(WordBool));
    vItem.Encoded := B;
    //JsonMode
    Stream.ReadBuffer(T, Sizeof(DWFieldTypeSize));
    vItem.JsonMode := TJsonMode(T);
    //TypeObject
    Stream.ReadBuffer(T, Sizeof(DWFieldTypeSize));
    vItem.vTypeObject := TTypeObject(T);
    //DataType
    Stream.ReadBuffer(T, Sizeof(DWFieldTypeSize));
    vItem.ObjectValue := TObjectValue(T);
    //GetValue from Datatype
    S := '';
    L := 0;
    Case vItem.ObjectValue Of
       ovFixedChar,
       ovWideString,
       ovString,
       ovObject : Begin
                   vItem.CriptOptions.Use := False;
                   Stream.ReadBuffer(L, Sizeof(DWInt64));
                   If (L = 0) Or (L > high(Sizeof(DWInt64))) Then
                    Continue;
                   SetLength(S, L);
                   Try
                    If L <> 0 Then
                     Stream.Read(S[InitStrPos], L);
                    {$IFDEF FPC}
                     S := GetStringEncode(S, vDatabaseCharSet);
                    {$ENDIF}
                   Finally
                   End;
//                   If CriptOptions.Use Then
//                    S := CriptOptions.Decrypt(S);
                   vItem.AsString := S;
                   vItem.CriptOptions.Use := CriptOptions.Use;
                   vItem.CriptOptions.Key := CriptOptions.Key;
                  End;
       ovSmallint : Begin
                     Stream.ReadBuffer(J, Sizeof(DWInteger));
                     vItem.AsInteger := J;
                    End;
       ovLongWord : Begin
                     Stream.ReadBuffer(J, Sizeof(DWInteger));
                     vItem.AsInteger := J;
                    End;
       ovShortint : Begin
                     Stream.ReadBuffer(J, Sizeof(DWInteger));
                     vItem.AsInteger := J;
                    End;
       ovByte     : Begin
                     Stream.ReadBuffer(B, Sizeof(Byte));
                     vItem.AsBoolean := B;
                    End;
       ovBoolean  : Begin
                     Stream.ReadBuffer(B, Sizeof(WordBool));
                     vItem.AsBoolean := B;
                    End;
       ovExtended : Begin
                     Stream.Read(J, Sizeof(DWInteger));
                     SetLength(S, J);
                     If J <> 0 Then
                      Begin
                       Stream.Read(S[InitStrPos], J);
                       If S = TDecimalChar Then
                        VE := Null
                       Else
                        Begin
                         S  := BuildFloatString(S);
                         VE := StrToFloat(S);
                        End;
                       vItem.AsExtended := VE;
                      End;
                    End;
       ovSingle   : Begin
                     Stream.ReadBuffer(J, Sizeof(DWInteger));
                     vItem.AsInteger := J;
                    End;
       ovDate,
       ovTime,
       ovDateTime,
       ovTimeStamp,
       ovTimeStampOffset: Begin
                           Stream.ReadBuffer(J, Sizeof(DWInt64));
                           If J <> 0 Then
                            vItem.AsDateTime := UnixToDateTime(J);
                          End;
       ovInteger,
       ovAutoInc : Begin
                    Stream.ReadBuffer(J, Sizeof(DWInteger));
                    vItem.AsInteger := J;
                   End;
       ovWord    : Begin
                    Stream.ReadBuffer(J, Sizeof(Word));
                    vItem.AsWord := J;
                   End;
       ovFloat,
       ovCurrency,
       ovBCD,
       ovFMTBcd  : Begin
                    Stream.Read(J, Sizeof(DWInteger));
                    SetLength(S, J);
                    If J <> 0 Then
                     Begin
                      Stream.Read(S[InitStrPos], J);
                      If S = TDecimalChar Then
                       VE := Null
                      Else
                       Begin
                        S  := BuildFloatString(S);
                        VE := StrToFloat(S);
                       End;
                      vItem.AsExtended := VE;
                     End;
                   End;
       ovLargeint  : Begin
                      Stream.ReadBuffer(J, Sizeof(DWInt64));
                      vItem.AsLargeInt := J;
                     End;
       ovVariant   : ;
       ovInterface : ;
       ovIDispatch : ;
       ovBlob,
       ovStream,
       ovBytes : Begin
                  Stream.ReadBuffer(J, Sizeof(DWInt64));
                  If J > 0 Then
                   Begin
                    vStream := TMemoryStream.Create;
                    Try
                     vStream.CopyFrom(Stream, J);
                     vStream.position := 0;
                     vItem.LoadFromStream(vStream);
                    Finally
                     vStream.Free;
                    End;
                   End;
                 End;
    End;
    If Input <> tdwpxt_All Then
     Begin
      If ((vItem.ObjectDirection = odIN)  And
          (Input  = tdwpxt_OUT)) Or
         ((vItem.ObjectDirection = odOUT) And
          (Input  = tdwpxt_IN)) Then
       Delete(vItem);
     End;
   End;
 End;
Begin
 If Not Assigned(Stream) Then
  Exit;
 Stream.Position := 0;
 ParamsHeader.VersionNumber := 0;
 ParamsHeader.RecordCount   := 0;
 ParamsHeader.ParamsCount   := 0;
 ParamsHeader.DataSize      := 0;
 Stream.ReadBuffer(ParamsHeader, Sizeof(TDWParamsHeader));
 VersionNumber   := ParamsHeader.VersionNumber;
 ParamsCount     := ParamsHeader.ParamsCount;
 DataSize        := ParamsHeader.DataSize;
 StartPos        := Stream.Position;
 aSize           := Stream.Size;
 If DataSize <>  aSize - StartPos Then
  Raise Exception.Create(cInvalidStream)
 Else
  Begin
   If ParamsCount > 0 Then
    CreateDWParamsFromStream;
  End;
End;

Procedure TDWParams.SetCriptOptions(Use  : Boolean;
                                    Key  : String);
Var
 I : Integer;
Begin
 For I := 0 To Count -1 Do
  Begin
   Items[I].CriptOptions.Use := Use;
   Items[I].CriptOptions.Key := Key;
  End;
End;

Function TDWParams.Add(Item : TJSONParam): Integer;
Var
 vItem : PJSONParam;
Begin
 New(vItem);
 vItem^                  := Item;
 vItem^.vEncoding        := vEncoding;
 vItem^.JsonMode         := vJsonMode;
 vItem^.CriptOptions.Use := vCripto.Use;
 vItem^.CriptOptions.Key := vCripto.Key;
 {$IFDEF FPC}
 vItem^.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 Result                  := Inherited Add(vItem);
End;

Procedure   TDWParams.CreateParam(ParamName : String;
                                  Value     : String = '');
Var
 vItem : TJSONParam;
Begin
 vItem := Nil;
 vItem := TJSONParam.Create(Encoding);
 vItem.ParamName := ParamName;
 If Value <> '' Then
  vItem.AsString := Value;
 Add(vItem);
End;

Constructor TDWParams.Create;
Begin
 Inherited;
 vCripto       := TCripto.Create;
 vJsonMode     := jmDataware;
 vHeaders      := TRESTDWHeaders.Create;
 vUrl_Redirect := '';
 {$IFNDEF FPC}
  {$IF CompilerVersion > 21}
   vEncoding := esUtf8;
  {$ELSE}
   vEncoding := esASCII;
  {$IFEND}
 {$ELSE}
  vEncoding := esUtf8;
  vDatabaseCharSet := csUndefined;
 {$ENDIF}
End;

Function TDWParams.ToJSON : String;
Var
 i : Integer;
Begin
 Result := 'null';
 If Assigned(Self) Then
  Begin
   For i := 0 To Self.Count - 1 Do
    Begin
     If TJSONParam(TList(Self).Items[i]^).vObjectValue <> ovUnknown Then
      Begin
       TJSONParam(TList(Self).Items[i]^).JsonMode := JsonMode;
       If I = 0 Then
        Result := TJSONParam(TList(Self).Items[i]^).ToJSON
       Else
        Result := Result + ', ' + TJSONParam(TList(Self).Items[i]^).ToJSON;
      End;
    End;
  End;
End;

Procedure TDWParams.FromJSON(json: String; BinaryRequest : Boolean = False);
Var
 bJsonOBJ,
 bJsonValue    : TDWJSONObject;
 bJsonArray    : TDWJSONArray;
 JSONParam     : TJSONParam;
 I             : Integer;
 vTempString   : String;
 //BinaryRequest
 vParam        : TParam;
 vStringStream : TStringStream;
Begin
 ClearList;
 If (lowercase(json) = cNullvalue) Or
    (json = '')                    Then
  Exit;
 If Not BinaryRequest Then
  Begin
   vTempString := Format('{"PARAMS":[%s]}', [json]);
   bJsonValue  := TDWJSONObject.Create(vTempString);
   bJsonArray  := bJsonValue.OpenArray(bJsonValue.Pairs[0].Name);
  End
 Else
  Begin
   vParam      := TParam.Create(Nil);
   bJsonValue  := TDWJSONObject.Create(json);
   bJsonArray := TDWJSONArray(bJsonValue);
  End;
 Try
  For i := 0 To bJsonArray.ElementCount - 1 Do
   Begin
    bJsonOBJ := TDWJSONObject(bJsonArray.GetObject(i));
    CreateParam(Lowercase(bJsonOBJ.Pairs[4].Name), '');
    JSONParam := ItemsString[Lowercase(bJsonOBJ.Pairs[4].Name)];
    If Not BinaryRequest Then
     Begin
      Try
       JSONParam.ParamName       := Lowercase(bJsonOBJ.Pairs[4].Name);
       JSONParam.ObjectDirection := GetDirectionName(bJsonOBJ.Pairs[1].Value);
       JSONParam.ObjectValue     := GetValueType(bJsonOBJ.Pairs[3].Value);
       JSONParam.Encoded         := GetBooleanFromString(bJsonOBJ.Pairs[2].Value);
       If (JSONParam.ObjectValue in [ovString, ovGuid, ovWideString]) And (JSONParam.Encoded) Then
        JSONParam.SetValue(DecodeStrings(bJsonOBJ.Pairs[4].Value{$IFDEF FPC}, csUndefined{$ENDIF}))
       Else
        JSONParam.SetValue(bJsonOBJ.Pairs[4].Value, JSONParam.Encoded);
//       Add(JSONParam);
      Finally
       bJsonOBJ.Free;
      End;
     End
    Else
     Begin
      vStringStream := TStringStream.Create(DecodeStrings(bJsonOBJ.Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
      Try
       vStringStream.Position := 0;
       TPropertyPersist(vParam).LoadFromStream(vStringStream);
       JSONParam.ParamName       := vParam.Name;
       JSONParam.ObjectValue     := FieldTypeToObjectValue(vParam.DataType);
       JSONParam.LoadFromParam(vParam);
       Add(JSONParam);
      Finally
       vStringStream.Free;
       bJsonOBJ.Free;
      End;
     End;
   End;
 Finally
  If Not BinaryRequest Then
   bJsonArray.Free;
  bJsonValue.Free;
  If BinaryRequest Then
   vParam.Free;
 End;
End;

Procedure TDWParams.CopyFrom(DWParams : TDWParams);
Var
 I         : Integer;
 p,
 JSONParam : TJSONParam;
Begin
 ClearList;
 If Assigned(DWParams) Then
  Begin
   For i := 0 To DWParams.Count - 1 Do
    Begin
     p         := DWParams.Items[i];
     JSONParam := TJSONParam.Create(DWParams.Encoding);
     JSONParam.CopyFrom(p);
     Add(JSONParam);
    End;
  End;
End;

Procedure TDWParams.Delete(Param : TJSONParam);
Var
 I : Integer;
Begin
 For I := 0 To Count -1 Do
  Begin
   If Items[I] = Param Then
    Begin
     Delete(I);
     Break;
    End;
  End;
End;

Procedure TDWParams.Delete(Index : Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   Try
    If Assigned(TList(Self).Items[Index])  Then
     Begin
      {$IFDEF FPC}
      FreeAndNil(TList(Self).Items[Index]^);
      {$ELSE}
       {$IF CompilerVersion > 33}
        FreeAndNil(TJSONParam(TList(Self).Items[Index]^));
       {$ELSE}
        FreeAndNil(TList(Self).Items[Index]^);
       {$IFEND}
      {$ENDIF}
      Dispose(PJSONParam(TList(Self).Items[Index]));
     End;
   Except
   End;
   TList(Self).Delete(Index);
  End;
End;

{
Procedure TDWParams.Clear;
Begin
 ClearList;
End;
}
Procedure TDWParams.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(i);
 Self.Clear;
End;

Destructor TDWParams.Destroy;
Begin
 ClearList;
 FreeAndNil(vCripto);
 FreeAndNil(vHeaders);
 Inherited;
End;

Function TDWParams.GetRec(Index : Integer) : TJSONParam;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TJSONParam(TList(Self).Items[Index]^);
End;

Function TDWParams.GetRecName(Index : String) : TJSONParam;
Var
 I         : Integer;
Begin
 Result    := Nil;
 If Assigned(Self) And (Lowercase(Index) <> '') Then
  Begin
   For i := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(TJSONParam(TList(Self).Items[i]^).vParamName)) Or
        (Lowercase(Index) = Lowercase(TJSONParam(TList(Self).Items[i]^).vAlias))     Then
      Begin
       Result := TJSONParam(TList(Self).Items[i]^);
       Break;
      End;
    End;
  End;
End;

Function TDWParams.GetRawBody : TJSONParam;
Var
 I         : Integer;
Begin
 Result    := Nil;
 If Assigned(Self) Then
  Result    := ItemsString[cUndefined];
End;

Function TDWParams.CountInParams : Integer;
Var
 I : Integer;
Begin
 Result := 0;
 For i := 0 To Count - 1 Do
  Begin
   If TJSONParam(TList(Self).Items[i]^).ObjectDirection in [odIN, odINOUT] Then
    Result := Result + 1;
  End;
End;

Function TDWParams.CountOutParams : Integer;
Var
 I : Integer;
Begin
 Result := 0;
 For i := 0 To Count - 1 Do
  Begin
   If TJSONParam(TList(Self).Items[i]^).ObjectDirection in [odOUT, odINOUT] Then
    Result := Result + 1;
  End;
End;

Procedure TDWParams.Assign(Source : TList);
Var
 Src        : TDWParams;
 I          : Integer;
 vJSONParam : TJSONParam;
Begin
 If Source is TDWParams Then
  Begin
   Src        := TDWParams(Source);
   For I := 0 To Src.Count-1 Do
    Begin
     vJSONParam := ItemsString[Src[I].ParamName];
     If vJSONParam = Nil Then
      Begin
       vJSONParam := TJSONParam.Create(Encoding);
       vJSONParam.Assign(Src[I]);
       Add(vJSONParam);
      End
     Else
      vJSONParam.Assign(Src[I]);
    End;
  End
 Else
  Raise Exception.Create(cInvalidDWParams);
End;

Function TDWParams.ParamsReturn : Boolean;
Var
 I : Integer;
Begin
 Result := False;
 If Assigned(Self) Then  //Alexandre Magno - 13/11/2018 (quando enviava sem parametro)
   For i := 0 To Self.Count - 1 Do
    Begin
     Result := Items[i].vObjectDirection In [odOUT, odINOUT];
     If Result Then
      Break;
    End;
End;

Procedure TDWParams.PutRec(Index : Integer;
                           Item  : TJSONParam);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TJSONParam(TList(Self).Items[Index]^) := Item;
End;

Procedure TDWParams.PutRecName(Index : String;
                               Item  : TJSONParam);
Var
 I         : Integer;
 vNotFount : Boolean;
Begin
 vNotFount := True;
 If Assigned(Self) And (Lowercase(Index) <> '') Then
  Begin
   For i := 0 To Self.Count - 1 Do
    Begin
     If (Lowercase(Index) = Lowercase(TJSONParam(TList(Self).Items[i]^).vParamName)) Or
        (Lowercase(Index) = Lowercase(TJSONParam(TList(Self).Items[i]^).vAlias))     Then
      Begin
       TJSONParam(TList(Self).Items[i]^) := Item;
       vNotFount := False;
       Break;
      End;
    End;
  End;
 If vNotFount Then
  Begin
   Item           := TJSONParam.Create(Encoding);
   Item.ParamName := Index;
   Add(Item);
  End;
End;

Procedure TDWParams.PutRawBody(Item  : TJSONParam);
Var
 I         : Integer;
 vNotFount : Boolean;
Begin
 vNotFount := True;
 If Assigned(Self) Then
  Begin
   For i := 0 To Self.Count - 1 Do
    Begin
     If (Lowercase(cUndefined) = Lowercase(TJSONParam(TList(Self).Items[i]^).vParamName)) Or
        (Lowercase(cUndefined) = Lowercase(TJSONParam(TList(Self).Items[i]^).vAlias))     Then
      Begin
       TJSONParam(TList(Self).Items[i]^) := Item;
       vNotFount := False;
       Break;
      End;
    End;
  End;
 If vNotFount Then
  Begin
   Item           := TJSONParam.Create(Encoding);
   Item.ParamName := cUndefined;
   Add(Item);
  End;
End;

Procedure TDWParams.SaveToFile(FileName : String);
Var
 vStringStream : TMemoryStream;
Begin
 SaveToStream(vStringStream);
 vStringStream.Position := 0;
 Try
  vStringStream.SaveToFile(FileName);
 Finally
  vStringStream.Free;
 End;
End;

Function EscapeQuotes(Const S: String): String;
Begin
 // Easy but not best performance
 Result := StringReplace(S,      '\', TSepValueMemString,    [rfReplaceAll]);
 Result := StringReplace(Result, '"', TQuotedValueMemString, [rfReplaceAll]);
End;

Function RevertQuotes(Const S: String): String;
Begin
 // Easy but not best performance
 Result := StringReplace(S,      TSepValueMemString,    '\', [rfReplaceAll]);
 Result := StringReplace(Result, TQuotedValueMemString, '"', [rfReplaceAll]);
End;

Constructor TJSONValue.Create;
Begin
 Inherited;
 {$IFNDEF FPC}
  {$IF CompilerVersion > 18}
   vEncoding        := esUtf8;
  {$ELSE}
   vEncoding        := esASCII;
  {$IFEND}
 {$ELSE}
  vEncoding         := esUtf8;
 {$ENDIF}
 {$IFDEF FPC}
  vDatabaseCharSet  := csUndefined;
 {$ENDIF}
 vFieldExist        := Nil;
 vNewDataField      := Nil;
 vCreateDataset     := Nil;
 vTypeObject        := toObject;
 ObjectDirection    := odINOUT;
 vObjectValue       := ovString;
 vtagName           := 'TAGJSON';
 vBinary            := True;
 vUtf8SpecialChars  := True; //Adicionado por padr�o para special Chars
 vNullValue         := vBinary;
 vJsonMode          := jmDataware;
 vOnWriterProcess   := Nil;
 vInactive          := False;
 vInBlockEvents     := False;
 vNewFieldList      := Nil;
 vSetInitDataset    := Nil;
 vSetInitDataset    := Nil;
 vSetRecordCount    := Nil;
 vSetnotrepage      := Nil;
 vSetInDesignEvents := Nil;
 vSetInBlockEvents  := Nil;
 vSetInactive       := Nil;
 vGetInDesignEvents := Nil;
 vPrepareDetails    := Nil;
 SetLength(vFieldsList, 0);
End;

Procedure TJSONValue.aCreateDataSet;
Begin

End;

Function TJSONValue.GetCreateDataSet : TProcedureEvent;
Begin
 Result := Nil;
 If Assigned(vCreateDataset) Then
  Result := vCreateDataset
 Else
  Begin
   {$IFDEF FPC}
    Result := @aCreateDataset;
   {$ELSE}
    Result := aCreateDataset;
   {$ENDIF}
  End;
End;

Function TJSONValue.aGetInDesignEvents : Boolean;
Begin
 Result := False;
End;

Destructor TJSONValue.Destroy;
Begin
 SetLength(aValue, 0);
 Clear;
 Inherited;
End;

Function TJSONValue.GetValueJSON(bValue : String): String;
Begin
 Result := bValue;
 If ((bValue = '') or (bValue = '""')) And (vNullValue) Then
  Result := 'null'
 Else If (bValue = '') Then
  bValue := '""';
End;

Function TJSONValue.IsNull : Boolean;
Begin
 Result := vNullValue;
End;

Class Function TJSONValue.FieldDefExist(Const Dataset : TDataset;
                                        Value         : String)   : TFieldDef;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 to Dataset.FieldDefs.Count -1 Do
  Begin
   If Uppercase(Dataset.FieldDefs[I].Name) = Uppercase(Value) Then
    Begin
     Result := Dataset.FieldDefs[I];
     Break;
    End;
  End;
End;

Function TJSONValue.GetFieldExist : TFieldExist;
Begin
 Result := Nil;
 If Assigned(vFieldExist) Then
  Result := vFieldExist
 Else
  Begin
   {$IFDEF FPC}
    Result := @aFieldExist;
   {$ELSE}
    Result := aFieldExist;
   {$ENDIF}
  End;
End;

Function TJSONValue.aFieldExist(Const Dataset : TDataset;
                                Value         : String) : TField;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Dataset.Fields.Count -1 Do
  Begin
   If UpperCase(Value) = UpperCase(Dataset.Fields[I].FieldName) Then
    Begin
     Result := Dataset.Fields[I];
     Break;
    End;
  End;
End;

Function TJSONValue.aFieldListCount : Integer;
Begin
 Result := 0;
End;

Function TJSONValue.FormatValue(bValue : String) : String;
Var
 aResult    : String;
 vInsertTag : Boolean;
Begin
 aResult    := bValue;
 vInsertTag := vObjectValue In [ovDate,    ovTime,    ovDateTime,
                                ovTimestamp];
 If Trim(aResult) <> '' Then
  Begin
   If (aResult[InitStrPos] = '"') And
      (aResult[Length(aResult) - FinalStrPos] = '"') Then
    Begin
     Delete(aResult, 1, 1);
     Delete(aResult, Length(aResult), 1);
    End;
  End;
 If Not vEncoded Then
  Begin
   If Trim(aResult) <> '' Then
    If Not(((Pos('{', aResult) > 0) And (Pos('}', aResult) > 0))  Or
           ((Pos('[', aResult) > 0) And (Pos(']', aResult) > 0))) Then
     If Not(vObjectValue In [ovStream, ovBlob, ovGraphic, ovOraBlob, ovOraClob]) Then
      aResult := StringToJsonString(aResult);
  End;
 If vNullValue Then
  aResult := cNullvalue
 Else If ((Trim(aResult) = '') or (Trim(bValue) = cNullvalueTag)) And vInsertTag Then
  aResult := cBlanckStringJSON;
 If JsonMode = jmDataware Then
  Begin
   If (vTypeObject  = toDataset) Then
    Result := Format(TValueFormatJSON, ['ObjectType',  GetObjectName(vTypeObject), 'Direction',
                                             GetDirectionName(vObjectDirection),        'Encoded',
                                             EncodedString, 'ValueType', GetValueType(vObjectValue),
                                             vtagName,      GetValueJSON(aResult)])
   Else If (vObjectValue = ovObject) And (vEncoded)  Then
    Result := Format(TValueFormatJSONValueS, ['ObjectType',  GetObjectName(vTypeObject), 'Direction',
                                              GetDirectionName(vObjectDirection),        'Encoded',
                                              EncodedString, 'ValueType', GetValueType(vObjectValue),
                                              vtagName,      GetValueJSON(aResult)]) //TValueFormatJSON
   Else If (vObjectValue = ovObject) Then
    Result := Format(TValueFormatJSONValue, ['ObjectType',  GetObjectName(vTypeObject), 'Direction',
                                             GetDirectionName(vObjectDirection),        'Encoded',
                                             EncodedString, 'ValueType', GetValueType(vObjectValue),
                                             vtagName,      GetValueJSON(aResult)]) //TValueFormatJSON
   Else
    Begin
     If vNullValue Then
      Result := Format(TValueFormatJSONValue, ['ObjectType', GetObjectName(vTypeObject), 'Direction',
                                                 GetDirectionName(vObjectDirection),       'Encoded',
                                                 EncodedString, 'ValueType', GetValueType(vObjectValue),
                                                 vtagName,      GetValueJSON(aResult)])
     Else If (vObjectValue in [ovString,   ovGuid,    ovWideString, ovMemo,
                               ovWideMemo, ovFmtMemo, ovFixedChar])  Or (vInsertTag) Then
      Result := Format(TValueFormatJSONValueS, ['ObjectType', GetObjectName(vTypeObject), 'Direction',
                                                GetDirectionName(vObjectDirection),       'Encoded',
                                                EncodedString, 'ValueType', GetValueType(vObjectValue),
                                                vtagName, GetValueJSON(aResult)])
     Else If (vObjectValue In [ovFloat, ovCurrency, ovBCD, ovFMTBcd, ovExtended]) Then
      Begin
       Result := Format(TValueFormatJSONValueS, ['ObjectType', GetObjectName(vTypeObject), 'Direction',
                                                 GetDirectionName(vObjectDirection),       'Encoded',
                                                 EncodedString, 'ValueType', GetValueType(vObjectValue),
                                                 vtagName, GetValueJSON(BuildStringFloat(aResult, JsonMode, vFloatDecimalFormat))]);
      End
     Else
      Begin
       If (vObjectValue In [ovBlob, ovStream, ovGraphic, ovOraBlob, ovOraClob]) Then
        Begin
         If aResult <> '' Then
          Begin
           If (((((aResult <> cBlanckStringJSON) And
              Not((aResult[InitStrPos] = '"')    And
                  (aResult[Length(aResult) - FinalStrPos] = '"'))))   And
               (vEncoded)) Or (Not(vEncoded)     And (aResult = ''))) Or
               (Pos('"', aResult) = 0)           Then
            aResult := '"' + aResult + '"'
           Else If (aResult = '') Then
            aResult := cBlanckStringJSON;
          End
         Else
          aResult := cBlanckStringJSON;
        End;
       If (Trim(bValue) = cNullvalueTag) Then
        Result := Format(TValueFormatJSONValue, ['ObjectType', GetObjectName(vTypeObject), 'Direction',
                                                 GetDirectionName(vObjectDirection),       'Encoded',
                                                 EncodedString, 'ValueType', GetValueType(vObjectValue),
                                                 vtagName,      GetValueJSON(Trim(bValue))])
       Else
        Result := Format(TValueFormatJSONValue, ['ObjectType', GetObjectName(vTypeObject), 'Direction',
                                                 GetDirectionName(vObjectDirection),       'Encoded',
                                                 EncodedString, 'ValueType', GetValueType(vObjectValue),
                                                 vtagName,      GetValueJSON(aResult)]);
      End;
    End;
  End
 Else
  Result := aResult;
End;

Function TJSONValue.GetValue(CanConvert : Boolean = True) : Variant;
Var
 vTempString : String;
Begin
 Result := '';
 If IsNull Then
  Begin
   Result := Null;
   Exit;
  End;
 If Length(aValue) = 0 Then
  Exit;
 {$IFDEF FPC}
  vTempString := BytesArrToString(aValue, GetEncodingID(vEncoding)); //vEncodingLazarus.GetString(aValue);
 {$ELSE}
  vTempString := BytesArrToString(aValue{$IFDEF INDY_NEW}, GetEncodingID(vEncoding){$ENDIF});
 {$ENDIF}
  If Length(vTempString) > 0 Then
   Begin
    If vTempString[InitStrPos]          = '"' Then
     Delete(vTempString, 1, 1);
    If vTempString[Length(vTempString) - FinalStrPos] = '"' Then
     Delete(vTempString, Length(vTempString), 1);
    vTempString := Trim(vTempString);
   End;
  If vEncoded Then
   Begin
    If (vObjectValue In [ovBytes,   ovVarBytes, ovStream, ovBlob,
                         ovGraphic, ovOraBlob,  ovOraClob]) And (vBinary) Then
     vTempString := vTempString
    Else
     Begin //TODO
      If Length(vTempString) > 0 Then
       vTempString := DecodeStrings(vTempString{$IFDEF FPC}, csUndefined{$ENDIF});
     End;
   End
  Else
   Begin
    If Length(vTempString) = 0 Then
     Begin
      {$IFDEF FPC}
       vTempString := BytesArrToString(aValue, GetEncodingID(vEncoding)); //vEncodingLazarus.GetString(aValue);
      {$ELSE}
       vTempString := BytesArrToString(aValue{$IFDEF INDY_NEW}, GetEncodingID(vEncoding){$ENDIF});
      {$ENDIF}
     End;
   End;
  If vObjectValue = ovString Then
   Begin
    If vTempString <> '' Then
     If vTempString[InitStrPos] = '"' Then
      Begin
       Delete(vTempString, 1, 1);
       If vTempString[Length(vTempString) - FinalStrPos] = '"' Then
        Delete(vTempString, Length(vTempString), 1);
      End;
    Result := vTempString;
   End
  Else
   Result := vTempString;
 If Not CanConvert Then
  Begin
   If vObjectValue In [ovSingle, ovFloat, ovCurrency, ovBCD, ovFMTBcd, ovExtended] Then
    If (vTempString <> '')                And
       (Lowercase(vTempString) <> 'null') Then
     Result := BuildStringFloat(vTempString, vJsonMode)
    Else
     Result := 0;
   Exit;
  End;
 vTempString := '';
 If vObjectValue In [ovSingle, ovFloat, ovCurrency, ovBCD, ovFMTBcd, ovExtended] Then
  Begin
   If (Result <> '')                And
      (Lowercase(Result) <> 'null') Then
    Result := StrToFloat(BuildFloatString(Result))
   Else
    Result := 0;
  End;
 If vObjectValue In [ovDate, ovTime, ovDateTime, ovTimeStamp, ovOraTimeStamp, ovTimeStampOffset] Then
  Begin
   If (Result <> '')                And
      (Lowercase(Result) <> 'null') Then
    Begin
     If (Pos('/', Result) = 0) And
        (Pos('-', Result) <= 1) Then
      Result := UnixToDateTime(StrToInt64(Result));
    End
   Else
    Result := 0;
  End;
 If vObjectValue In [ovLargeInt, ovLongWord, ovShortInt, ovSmallInt, ovInteger, ovWord,
                     ovBoolean, ovAutoInc, ovOraInterval] Then
  Begin
   If (Result <> '')                And
      (Lowercase(Result) <> 'null') Then
    Begin
     If vObjectValue = ovBoolean Then
      Result := (Result = '1')        Or
                (Lowercase(Result) = 'true')
     Else If (Trim(Result) <> '')     And
             (Trim(Result) <> 'null') Then
      Begin
       If vObjectValue in [ovLargeInt, ovLongWord] Then
        Result := StrToInt64(Result)
       Else
        Result := StrToInt(Result);
      End;
    End;
  End;
End;

Function TJSONValue.DatasetValues(bValue             : TDataset;
                                  DateTimeFormat     : String      = '';
                                  JsonModeD          : TJsonMode   = jmDataware;
                                  FloatDecimalFormat : String      = '';
                                  HeaderLowercase    : Boolean     = False;
                                  VirtualValue       : String      = '';
                                  DWJSONType         : TDWJSONType = TDWJSONArrayType;
                                  bDetail            : TDataset    = Nil) : String;
Var
 vLines,
 vFieldName,
 vFormatMask,
 vValueMask,
 vBuildSide : String;
 A, vRecNo  : Integer; //pr-19/08/2020
 Function GenerateHeader: String;
 Var
  I{$IFDEF FPC}, vSize{$ENDIF} : Integer;
  vPrimary,
  vRequired,
  vReadOnly,
  vGenerateLine,
  vAutoinc      : string;
 Begin
  For i := 0 To bValue.Fields.Count - 1 Do
   Begin
    vPrimary := 'N';
    vAutoinc := 'N';
    vReadOnly := 'N';
    If pfInKey in bValue.Fields[i].ProviderFlags Then
     vPrimary := 'S';
    vRequired := 'N';
    If bValue.Fields[i].Required Then
     vRequired := 'S';
    If Not(bValue.Fields[i].CanModify) Then
     vReadOnly := 'S';
    {$IFNDEF FPC}
     {$IF CompilerVersion > 21}
      If bValue.Fields[i].AutoGenerateValue = arAutoInc Then
       vAutoinc := 'S';
     {$ELSE}
       vAutoinc := 'N';
     {$IFEND}
    {$ENDIF}
    vFieldName := bValue.Fields[i].FieldName;
//    If vLowercaseFieldNames Then
//     vFieldName := Lowercase(bValue.Fields[i].FieldName);
    If bValue.Fields[i].DataType In [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,{$IFEND}{$ENDIF}
                                     ftFloat, ftCurrency, ftFMTBcd, ftBCD] Then
     Begin
      If bValue.Fields[i].DataType In [ftFMTBcd, ftBCD] then
       Begin
       {$IFNDEF FPC}
       vGenerateLine := Format(TJsonDatasetHeader, [vFieldName,
                                                    GetFieldType(bValue.Fields[i].DataType),
                                                    vPrimary, vRequired, TBCDField(bValue.Fields[i]).Precision,
                                                    TBCDField(bValue.Fields[i]).Size, vReadOnly, vAutoinc])
       {$ELSE}
        {$IFDEF FPC}
        vSize := TBCDField(bValue.Fields[i]).Size;
        If vSize > 0 Then
         vSize := TBCDField(bValue.Fields[i]).Precision
        Else
         vSize := Sizeof(Double) * 2;
        {$ENDIF}
        vGenerateLine := Format(TJsonDatasetHeader, [vFieldName,
                                                     GetFieldType(bValue.Fields[i].DataType),
                                                     vPrimary, vRequired, {$IFDEF FPC}vSize{$ELSE}TBCDField(bValue.Fields[i]).Precision{$ENDIF},
                                                     {$IFDEF FPC}LazDigitsSize{$ELSE}TBCDField(bValue.Fields[i]).Size{$ENDIF}, vReadOnly, vAutoinc])
       {$ENDIF}
       End
      Else
       Begin
        {$IFDEF FPC}
        vSize := TFloatField(bValue.Fields[i]).Size;
        If vSize > 0 Then
         vSize := TFloatField(bValue.Fields[i]).Precision
        Else
         vSize := (Sizeof(Double) * 2) -1;
        {$ENDIF}
        vGenerateLine := Format(TJsonDatasetHeader, [vFieldName,
                                                     GetFieldType(bValue.Fields[i].DataType),
                                                     vPrimary, vRequired, {$IFDEF FPC}vSize{$ELSE}TFloatField(bValue.Fields[i]).Precision{$ENDIF},
                                                     {$IFDEF FPC}LazDigitsSize{$ELSE}TFloatField(bValue.Fields[i]).Size{$ENDIF}, vReadOnly, vAutoinc]);
       End;
     End
    Else
     vGenerateLine   := Format(TJsonDatasetHeader, [vFieldName,
                                                    GetFieldType(bValue.Fields[i].DataType),
                                                    vPrimary, vRequired, bValue.Fields[i].Size, 0, vReadOnly, vAutoinc]);
    If i = 0 Then
     Result := vGenerateLine
    Else
     Result := Result + ', ' + vGenerateLine;
   End;
  If VirtualValue <> '' Then
   Result := Result + ', ' + Format(TJsonDatasetHeader, [cRDWDetailField, GetFieldType(ftMemo), False, False, 0, 0, False, False]);
  If HeaderLowercase Then
   Result := Lowercase(Result)
 End;
 Function GenerateLine: String;
 Var
  I             : Integer;
  vTempField,
  vTempValue    : String;
  bStream       : TStream;
  vStringStream : TStringStream;
  Function RemoveTrashTime(Value : String) : String;
  Var
   I, A, X : Integer;
   Function CountTime(Value : String) : Integer;
   Var
    I : Integer;
   Begin
    Result := 0;
    For I := Length(Value) - FinalStrPos DownTo InitStrPos Do
     Begin
      If Value[I] = ' ' Then
       Break;
      If lowercase(Value[I]) = 'm' Then
       Inc(Result)
      Else If Result > 0 Then
       Break;
     End;
   End;
  Begin
   If (Pos(':', Value) > 0) or (Pos(' ', Value) > 0) or
      (Pos('s', Value) > 0) or (Pos('h', Value) > 0) Then
    Begin
     X      := CountTime(Value);
     Result := StringReplace(Value,  'h', '', [rfReplaceAll, rfIgnoreCase]);
     Result := StringReplace(Result, 's', '', [rfReplaceAll, rfIgnoreCase]);
     Result := StringReplace(Result, ':', '', [rfReplaceAll, rfIgnoreCase]);
     Result := StringReplace(Result, ' ', '', [rfReplaceAll, rfIgnoreCase]);
     A      := 0;
     If X > 0 Then
     For I := Length(Result) - FinalStrPos DownTo InitStrPos Do
      Begin
       If (lowercase(Result[I]) = 'm') And (A < X) Then
        Begin
         Delete(Result, I, 1);
         Inc(A);
        End;
      End;
    End
   Else
    Result := Trim(Value);
  End;
  Function RemoveTrashDate(Value : String) : String;
  Var
   I, A, X : Integer;
   Function CountMonth(Value : String) : Integer;
   Var
    I : Integer;
   Begin
    Result := 0;
    For I := InitStrPos To Length(Value) - FinalStrPos Do
     Begin
      If Value[I] = ' ' Then
       Break;
      If lowercase(Value[I]) = 'm' Then
       Inc(Result)
      Else If Result > 0 Then
       Break;
     End;
   End;
  Begin
   If (Pos('/', Value) > 0) or (Pos('-', Value) > 0) or
      (Pos(' ', Value) > 0) or (Pos('d', Value) > 0) or
      (Pos('y', Value) > 0) Then
    Begin
     A      := 0;
     I      := InitStrPos;
     X      := CountMonth(Value);
     Result := StringReplace(Value,  'd', '', [rfReplaceAll, rfIgnoreCase]);
     Result := StringReplace(Result, 'y', '', [rfReplaceAll, rfIgnoreCase]);
     Result := StringReplace(Result, '/', '', [rfReplaceAll, rfIgnoreCase]);
     Result := StringReplace(Result, '-', '', [rfReplaceAll, rfIgnoreCase]);
     Result := StringReplace(Result, ' ', '', [rfReplaceAll, rfIgnoreCase]);
     If X > 0 Then
     While I <= (Length(Result) - FinalStrPos) Do
      Begin
       If (lowercase(Result[I]) = 'm') And (A < X) Then
        Begin
         Delete(Result, I, 1);
         Inc(A);
         Continue;
        End;
       Inc(I);
      End;
    End
   Else
    Result := Trim(Value);
  End;
 Begin
  For i := 0 To bValue.Fields.Count - 1 Do
   Begin
    Case JsonModeD Of
     jmDataware,
     jmUndefined : Begin
                   End;
     jmPureJSON  : Begin
                    If HeaderLowercase Then
                     vTempField := Format('"%s": ', [Lowercase(bValue.Fields[i].FieldName)])
                    Else
                     vTempField := Format('"%s": ', [bValue.Fields[i].FieldName]);
                   End;
    End;
    If Not bValue.Fields[i].IsNull then
     Begin
      If bValue.Fields[i].DataType In [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftShortint, {$IFEND}{$ENDIF}
                                       ftSmallint, ftInteger, ftLargeint, ftAutoInc] Then
       Begin
        If bValue.Fields[i].DataType In [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftShortint, {$IFEND}{$ENDIF}ftSmallint] Then
         Begin
          If bValue.Fields[i].IsNull Then
           vTempValue := Format('%s%s', [vTempField, cNullvalue])
          Else
           vTempValue := Format('%s%s', [vTempField, IntToStr(bValue.Fields[i].AsInteger)]);
         End
        Else
         Begin
           If bValue.Fields[i].IsNull Then
            vTempValue := Format('%s%s', [vTempField, cNullvalue])
           Else
          {$IFNDEF FPC}
           {$IF CompilerVersion > 22}
            vTempValue := Format('%s%s', [vTempField, IntToStr(bValue.Fields[i].AsLargeInt)]);
           {$ELSE}
            vTempValue := Format('%s%s', [vTempField, IntToStr(bValue.Fields[i].AsInteger)]);
           {$IFEND}
          {$ELSE}
            vTempValue := Format('%s%s', [vTempField, IntToStr(bValue.Fields[i].AsLargeInt)]);
          {$ENDIF}
         End;
       End
      Else If bValue.Fields[i].DataType In [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,{$IFEND}{$ENDIF}ftFloat, ftCurrency, ftFMTBcd, ftBCD] Then
       Begin
        vValueMask  := BuildStringFloat(FloatToStr(bValue.Fields[i].AsFloat), JsonModeD, '.');
        If ((FloatDecimalFormat <> '') And (FloatDecimalFormat <> '.')) Then
         vValueMask  := BuildStringFloat(FloatToStr(bValue.Fields[i].AsFloat), JsonModeD, FloatDecimalFormat);
        If vDataType or ((FloatDecimalFormat = '') or (FloatDecimalFormat = '.')) Then
         vFormatMask := '%s%s'
        Else
         vFormatMask := '%s"%s"';
        If bValue.Fields[i].IsNull Then
         vTempValue := Format('%s%s', [vTempField, cNullvalue])
        Else if JsonModeD = jmDataware then
         vTempValue := Format('%s"%s"', [vTempField, BuildStringFloat(FloatToStr(bValue.Fields[i].AsFloat), JsonModeD, FloatDecimalFormat)])
        Else
         vTempValue := Format(vFormatMask, [vTempField, vValueMask]);
       End
      Else If bValue.Fields[i].DataType in [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] Then
       Begin
        If bValue.Fields[i].IsNull Then
         vTempValue := Format('%s%s', [vTempField, cNullvalue])
        Else
         Begin
          vStringStream := TStringStream.Create('');
          bStream := bValue.CreateBlobStream(TBlobField(bValue.Fields[i]), bmRead);
          Try
           bStream.Position := 0;
           {$IFDEF FPC}
           vStringStream.CopyFrom(bStream, bStream.Size);
           {$ELSE}
            {$IF CompilerVersion > 21}
            vStringStream.LoadFromStream(bStream);
            {$ELSE}
            vStringStream.CopyFrom(bStream, bStream.Size);
            {$IFEND}
           {$ENDIF}
           vTempValue := Format('%s"%s"', [vTempField, Encodeb64Stream(vStringStream)]); //StreamToHex(vStringStream)]);
          Finally
           vStringStream.Free;
           bStream.Free;
          End;
         End;
       End
      Else
       Begin
        If bValue.Fields[i].DataType in [ftString, ftWideString, ftMemo,
                                         {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,{$IFEND}{$ELSE}ftWideMemo,{$ENDIF}
                                         ftFmtMemo, ftFixedChar] Then
         Begin
          If bValue.Fields[i].IsNull Then
           vTempValue := Format('%s%s', [vTempField, cNullvalue])
          Else
           Begin
            If (vEncoded) Or (bValue.Fields[i].DataType in [ftMemo, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,{$IFEND}{$ELSE}ftWideMemo,{$ENDIF}
                                                            ftFmtMemo]) Then
             Begin
              If JsonModeD = jmPureJSON Then
               Begin
                If (vEncoded) Then
                 Begin
                  {$IFDEF FPC}
                   vTempValue := Format('%s"%s"', [vTempField, EncodeStrings(StringToJsonString(bValue.Fields[i].AsString), vDatabaseCharSet)]);
                  {$ELSE}
                   vTempValue := Format('%s"%s"', [vTempField, EncodeStrings(StringToJsonString(bValue.Fields[i].AsString))]);
                  {$ENDIF}
                 End
                Else
                 Begin
                  If vUtf8SpecialChars Then
                   vTempValue := Format('%s"%s"', [vTempField, escape_chars(bValue.Fields[i].AsString)])
                  Else
                   vTempValue := Format('%s"%s"', [vTempField, StringToJsonString(bValue.Fields[i].AsString)]);
                 End;
               End
              Else
               Begin
                {$IFDEF FPC}
                 vTempValue := Format('%s"%s"', [vTempField, EncodeStrings(bValue.Fields[i].AsString, vDatabaseCharSet)]);
                {$ELSE}
                 vTempValue := bValue.Fields[i].AsString;
                 {$IF (CompilerVersion < 19)}
                  If vEncoding = esUtf8 Then
                   Result := UTF8Decode(vTempValue);
                 {$IFEND}
                 vTempValue := Format('%s"%s"', [vTempField, EncodeStrings(vTempValue)]);
                {$ENDIF}
               End;
             End
            Else
             Begin
              {$IFDEF FPC}
               Case DatabaseCharSet Of
                csWin1250    : vTempValue := CP1250ToUTF8(bValue.Fields[i].AsString);
                csWin1251    : vTempValue := CP1251ToUTF8(bValue.Fields[i].AsString);
                csWin1252    : vTempValue := CP1252ToUTF8(bValue.Fields[i].AsString);
                csWin1253    : vTempValue := CP1253ToUTF8(bValue.Fields[i].AsString);
                csWin1254    : vTempValue := CP1254ToUTF8(bValue.Fields[i].AsString);
                csWin1255    : vTempValue := CP1255ToUTF8(bValue.Fields[i].AsString);
                csWin1256    : vTempValue := CP1256ToUTF8(bValue.Fields[i].AsString);
                csWin1257    : vTempValue := CP1257ToUTF8(bValue.Fields[i].AsString);
                csWin1258    : vTempValue := CP1258ToUTF8(bValue.Fields[i].AsString);
                csUTF8       : vTempValue := UTF8ToUTF8BOM(bValue.Fields[i].AsString);
                csISO_8859_1 : vTempValue := ISO_8859_1ToUTF8(bValue.Fields[i].AsString);
                csISO_8859_2 : vTempValue := ISO_8859_2ToUTF8(bValue.Fields[i].AsString);
                Else
                 vTempValue  := bValue.Fields[i].AsString;
               End;
               If vUtf8SpecialChars Then
                vTempValue := escape_chars(bValue.Fields[i].AsString)
               Else
                vTempValue := StringToJsonString(bValue.Fields[i].AsString);
               vTempValue  := Format('%s"%s"', [vTempField, vTempValue]);
              {$ELSE}
               If vUtf8SpecialChars Then
                vTempValue := escape_chars(bValue.Fields[i].AsString)
               Else
                vTempValue := StringToJsonString(bValue.Fields[i].AsString);
               vTempValue  := Format('%s"%s"', [vTempField, vTempValue]);
              {$ENDIF}
             End;
           End;
         End
        Else If bValue.Fields[i].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
         Begin
          If bValue.Fields[i].IsNull Then
           vTempValue := Format('%s%s', [vTempField, cNullvalue])
          Else If (bValue.Fields[i].DataType = ftTime) and (RemoveTrashDate(DateTimeFormat) <> '') Then
           vTempValue := Format('%s"%s"', [vTempField, FormatDateTime(RemoveTrashDate(DateTimeFormat), bValue.Fields[i].AsDateTime)])
          Else
           Begin
            If (bValue.Fields[i].DataType in [ftDateTime, ftTimeStamp]) and (DateTimeFormat <> '') Then
             vTempValue := Format('%s"%s"', [vTempField, FormatDateTime(DateTimeFormat, bValue.Fields[i].AsDateTime)])
            Else If (bValue.Fields[i].DataType = ftDate) and (RemoveTrashTime(DateTimeFormat) <> '') Then
             vTempValue := Format('%s"%s"', [vTempField, FormatDateTime(RemoveTrashTime(DateTimeFormat), bValue.Fields[i].AsDateTime)])
            Else
             vTempValue := Format('%s"%s"', [vTempField, inttostr(DateTimeToUnix(bValue.Fields[i].AsDateTime))]);
           End;
         End
        Else If bValue.Fields[i].DataType in [ftBoolean] Then
         vTempValue := Format('%s%s', [vTempField, lowercase(BoolToStr(bValue.Fields[i].AsBoolean, true))])
        Else
         vTempValue := Format('%s"%s"', [vTempField, bValue.Fields[i].AsString]); // asstring
       End;
     End
    Else
     vTempValue := Format('%s%s', [vTempField, cNullvalue]);
    If I = 0 Then
     Result := vTempValue
    Else
     Result := Result + ', ' + vTempValue;
   End;
  If (VirtualValue <> '') And (bDetail <> Nil) Then
   Begin
    If Trim(Result) <> '' Then
     Result := Result + ', ';
    If bDetail.Active Then
     Begin
      If bDetail.Eof Then
       Result := Result + VirtualValue + '[]'
      Else
       Result := Result + VirtualValue + DatasetValues(bDetail, DateTimeFormat, JsonModeD, FloatDecimalFormat, HeaderLowercase, '', DWJSONType);
     End
    Else
     Result := Result + VirtualValue + '[]';
   End;
 End;
Begin
 bValue.DisableControls;
 Try
  If Not bValue.Active Then
   bValue.Open;
  bValue.First;
  {$IFDEF FPC}
  vBuildSide := 'L';
  {$ELSE}
  vBuildSide := 'D';
  {$ENDIF}
  Case JsonModeD Of
   jmDataware,
   jmUndefined : Result := '{"fields":[' + GenerateHeader + '], "buildside":"' + vBuildSide + '"}, {"lines":[%s]}';
   jmPureJSON  : Begin
                 End;
  End;
  A := 0;
  vRecNo := 1; //pr-19/08/2020
  {$IFDEF  POSIX}  // aqui para linux tem que ser diferente o rastrwio da query
  For A := 0 To bValue.Recordcount -1 Do
   Begin
    Case JsonModeD Of
     jmDataware,
     jmUndefined : Begin
                    If vRecNo = 1 Then //pr-19/08/2020
                     vLines := Format('{"line%d":[%s]}',            [A, GenerateLine])
                    Else
                     vLines := vLines + Format(', {"line%d":[%s]}', [A, GenerateLine]);
                   End;
     jmPureJSON : Begin
                    If vRecNo = 1 Then //pr-19/08/2020
                    vLines := Format('{%s}', [GenerateLine])
                   Else
                    vLines := vLines + Format(', {%s}', [GenerateLine]);
                  End;
    End;
    If DWJSONType <> TDWJSONArrayType Then
     Break;
    bValue.Next;
    Inc(vRecNo); //pr-19/08/2020
   End;
  {$ELSE}
   While Not bValue.Eof Do
    Begin
     Case JsonModeD Of
      jmDataware,
      jmUndefined : Begin
                    If vRecNo = 1 Then //pr-19/08/2020
                      vLines := Format('{"line%d":[%s]}', [A, GenerateLine])
                     Else
                      vLines := vLines + Format(', {"line%d":[%s]}', [A, GenerateLine]);
                    End;
      jmPureJSON  : Begin
                    If vRecNo = 1 Then //pr-19/08/2020
                      vLines := Format('{%s}', [GenerateLine])
                     Else
                      vLines := vLines + Format(', {%s}', [GenerateLine]);
                    End;
     End;
     If DWJSONType <> TDWJSONArrayType Then
      Break;
     bValue.Next;
     Inc(A);
     Inc(vRecNo); //pr-19/08/2020
    End;
  {$ENDIF}
  Case JsonModeD Of
   jmDataware,
   jmUndefined : Begin
                  If vEncoding = esUtf8 Then
                   Result := Format(Result, [vLines])
                  Else
                  {$IF Defined(HAS_FMX)}
                   Result := Format(Result, [vLines]);
                  {$ELSE}
                   Result := Format(Result, [AnsiString(vLines)]);
                  {$IFEND}
                 End;
   jmPureJSON  : Begin
                  If vtagName <> '' Then
                   Result := Format('{"%s": [%s]}', [vtagName, vLines])
                  Else
                   Result := Format('[%s]', [vLines]);
                 End;
  End;
  bValue.First;
 Finally
  bValue.EnableControls;
 End;
End;

Function TJSONValue.EncodedString: String;
Begin
 If vEncoded Then
  Result := 'true'
 Else
  Result := 'false';
End;

Procedure TJSONValue.LoadFromDataset(TableName        : String;
                                     bValue,
                                     bDetail          : TDataset;
                                     DetailType       : TDWJSONType = TDWJSONArrayType;
                                     DetailElementName: String      = 'detail';
                                     EncodedValue     : Boolean     = True;
                                     JsonModeD        : TJsonMode   = jmDataware;
                                     DateTimeFormat   : String = '';
                                     DelimiterFormat  : String = '';
                                     {$IFDEF FPC}
                                     CharSet          : TDatabaseCharSet = csUndefined;
                                     {$ENDIF}
                                     DataType         : Boolean = False;
                                     HeaderLowercase  : Boolean = False);
Var
 vTagGeral,
 vVirtualValue : String;
 {$IFNDEF FPC}
 {$IF CompilerVersion < 22} // Delphi 2010 pra cima
 vSizeChar : Integer;
 {$IFEND}
 {$ENDIF}
Begin
 // Recebe o parametro "DataType" para fazer a tipagem na fun��o que gera a linha "GenerateLine"
 // Tiago Istuque - Por Nemi Vieira - 29/01/2019
 vDataType        := DataType;
 vTypeObject      := toDataset;
 vObjectDirection := odINOUT;
 vObjectValue     := ovDataSet;
 vEncoded         := EncodedValue;
 If (JsonModeD = jmDataware) And (trim(TableName) = '') Then
  TableName := 'rdwtable';
 vtagName         := Lowercase(TableName);
 {$IFDEF FPC}
  If CharSet <> csUndefined Then
   DatabaseCharSet := CharSet;
 {$ENDIF}
 If DetailType   = TDWJSONArrayType Then
  vVirtualValue := Format('"%s":', [DetailElementName])
 Else
  vVirtualValue := Format('"%s":', [DetailElementName]);
 vTagGeral     := DatasetValues(bValue, DateTimeFormat, JsonModeD, DelimiterFormat, HeaderLowercase, vVirtualValue, DetailType, bDetail);
 {$IFDEF FPC}
  If vEncodingLazarus = Nil Then
   SetEncoding(vEncoding);
  If vEncoding = esUtf8 Then
   aValue          := TIdBytes(vEncodingLazarus.GetBytes(vTagGeral))
  Else
   aValue          := ToBytes(vTagGeral, GetEncodingID(vEncoding));
 {$ELSE}
  {$IF CompilerVersion > 21} // Delphi 2010 pra cima
   aValue          := ToBytes(vTagGeral{$IFDEF INDY_NEW}, GetEncodingID(vEncoding){$ENDIF});
  {$ELSE}
   vSizeChar := 1;
   If vEncoding = esUtf8 Then
    Begin
     vSizeChar := 2;
     SetLength(aValue, Length(vTagGeral) * vSizeChar);
     move(vTagGeral[InitStrPos], pByteArray(aValue)^, Length(aValue));
    End
   Else
    Begin
     SetLength(aValue, Length(vTagGeral) * vSizeChar);
     move(AnsiString(vTagGeral)[InitStrPos], pByteArray(aValue)^, Length(vTagGeral) * vSizeChar);
    End;
//   aValue          := ToBytes(vTagGeral, GetEncodingID(vEncoding));
  {$IFEND}
 {$ENDIF}
 vJsonMode        := JsonModeD;
 vNullValue       := Length(aValue) = 0;
End;

Procedure TJSONValue.LoadFromDataset(TableName        : String;
                                     bValue           : TDataset;
                                     EncodedValue     : Boolean = True;
                                     JsonModeD        : TJsonMode = jmDataware;
                                     DateTimeFormat   : String = '';
                                     DelimiterFormat  : String = '';
                                     {$IFDEF FPC}
                                     CharSet          : TDatabaseCharSet = csUndefined;
                                     {$ENDIF}
                                     DataType         : Boolean = False;
                                     HeaderLowercase  : Boolean = False);
Var
 vTagGeral : String;
 {$IFNDEF FPC}
 {$IF CompilerVersion < 22} // Delphi 2010 pra cima
 vSizeChar : Integer;
 {$IFEND}
 {$ENDIF}
Begin
 // Recebe o parametro "DataType" para fazer a tipagem na fun��o que gera a linha "GenerateLine"
 // Tiago Istuque - Por Nemi Vieira - 29/01/2019
 vDataType        := DataType;
 vTypeObject      := toDataset;
 vObjectDirection := odINOUT;
 vObjectValue     := ovDataSet;
 vEncoded         := EncodedValue;
 If (JsonModeD = jmDataware) And (trim(TableName) = '') Then
  TableName := 'rdwtable';
 vtagName         := Lowercase(TableName);
 {$IFDEF FPC}
  If CharSet <> csUndefined Then
   DatabaseCharSet := CharSet;
 {$ENDIF}
 vTagGeral        := DatasetValues(bValue, DateTimeFormat, JsonModeD, DelimiterFormat, HeaderLowercase);
 {$IFDEF FPC}
  If vEncodingLazarus = Nil Then
   SetEncoding(vEncoding);
  If vEncoding = esUtf8 Then
   aValue          := TIdBytes(vEncodingLazarus.GetBytes(vTagGeral))
  Else
   aValue          := ToBytes(vTagGeral, GetEncodingID(vEncoding));
 {$ELSE}
  {$IF CompilerVersion > 21} // Delphi 2010 pra cima
   aValue          := ToBytes(vTagGeral{$IFDEF INDY_NEW}, GetEncodingID(vEncoding){$ENDIF});
  {$ELSE}
   vSizeChar := 1;
   If vEncoding = esUtf8 Then
    vSizeChar := 2;
   SetLength(aValue, Length(vTagGeral) * vSizeChar);
   move(AnsiString(vTagGeral)[InitStrPos], pByteArray(aValue)^, Length(vTagGeral) * vSizeChar);
  {$IFEND}
 {$ENDIF}
 vJsonMode        := JsonModeD;
 vNullValue       := Length(aValue) = 0;
End;

Function TJSONValue.ToJSON : String;
Var
 {$IFNDEF FPC}
  {$IF CompilerVersion > 21}
   vTempValue   : String;
  {$ELSE}
   vTempValue   : AnsiString;
   SizeOfString : Integer;
  {$IFEND}
 {$ELSE}
  vTempValue    : String;
 {$ENDIF}
Begin
 Result     := '';
 vTempValue := '';
 {$IFDEF FPC}
 If vEncodingLazarus = Nil Then
  SetEncoding(vEncoding);
 If vEncoding = esUtf8 Then
  vTempValue := vEncodingLazarus.GetString(aValue)
 Else
  vTempValue := BytesToString(aValue, GetEncodingID(vEncoding));
//  vTempValue := FormatValue(vEncodingLazarus.GetString(aValue))
 If vTempValue = '' Then
  Begin
   If vNullValue Then
    vTempValue := FormatValue('null')
   Else
    Begin
     If Not(vObjectValue in [ovString,   ovFixedChar, ovWideString, ovFixedWideChar,
                             ovBlob,     ovStream,    ovGraphic,    ovOraBlob,  ovOraClob, ovMemo,
                             ovWideMemo, ovGuid,      ovFmtMemo]) Then
      vTempValue := FormatValue('null')
     Else
      vTempValue := FormatValue('');
    End;
  End
 Else
  vTempValue := FormatValue(vTempValue);
 {$ELSE}
 If vTempValue = '' Then
  vTempValue := BytesToString(aValue{$IFDEF INDY_NEW}, GetEncodingID(vEncoding){$ENDIF});
 If vTempValue = '' Then
  Begin
   If vNullValue Then
    vTempValue := FormatValue('null')
   Else
    Begin
     If Not(vObjectValue in [ovString,   ovFixedChar, ovWideString, ovFixedWideChar,
                             ovBlob,     ovStream,    ovGuid,       ovGraphic,
                             ovOraBlob,  ovOraClob,   ovMemo,       ovWideMemo, ovFmtMemo]) Then
      vTempValue := FormatValue('null')
     Else
      vTempValue := FormatValue('');
    End;
  End
 Else
  Begin
   {$IF CompilerVersion > 19} // Delphi 2010 pra cima
    vTempValue   := FormatValue(vTempValue);
   {$ELSE} // Delphi 2010 pra cima
    SizeOfString := Length(aValue);
    vTempValue   := '';
    SetString(vTempValue, PChar(@aValue[0]), SizeOfString);
{ //Comentado dele��o de nulos
    While pos(#0, vTempValue) > 0 Do
     Delete(vTempValue, pos(#0, vTempValue), 1);
}
    vTempValue   := FormatValue(vTempValue);
    If vEncoding = esUtf8 Then
     vTempValue   := Utf8Decode(vTempValue);
   {$IFEND} // Delphi 2010 pra cima
  End;
 {$ENDIF}
 If Not(Pos('"TAGJSON":}', vTempValue) > 0) Then
  Result := vTempValue;
End;

Function  TJSONValue.AsString : String;
Begin
 Result := GetValue(False);
 If VarIsNull(Result) Then
  Exit;
 {$IFNDEF FPC}
  {$IF (CompilerVersion < 20)}
   Result := UTF8Decode(Result);
   If vEncoding = esUtf8 Then
    Result := UTF8Decode(Result);
  {$IFEND}
 {$ELSE}
  Result := GetStringDecode(Result, vDatabaseCharSet);
 {$ENDIF}
End;

Procedure TJSONValue.ClearFieldList;
Var
 I : Integer;
Begin
 For I := 0 To Length(vFieldsList) -1 Do
  Begin
   If Assigned(vFieldsList[I]) Then
    FreeAndNil(vFieldsList[I]);
  End;
 Setlength(vFieldsList, 0);
End;

Procedure TJSONValue.Clear;
Begin
 vNullValue := True;
 Setvalue('');
 ClearFieldList;
End;

Procedure TJSONValue.ToStream(Var bValue : TMemoryStream);
Begin
 If Length(aValue) > 0 Then
  Begin
   bValue := TMemoryStream.Create;
   bValue.Write(aValue[0], -1);
  End
 Else
  bValue := Nil;
End;

Function TJSONValue.Value : Variant;
Begin
 Result := GetValue;
 If VarIsNull(Result) Then
  Exit;
 {$IFNDEF FPC}
  {$IF (CompilerVersion < 20)}
   Result := UTF8Decode(Result);
   {$IF (CompilerVersion > 15)}
    If vEncoding = esUtf8 Then
     Result := UTF8Decode(Result);
   {$IFEND}
  {$IFEND}
 {$ELSE}
  Result := GetStringDecode(Result, vDatabaseCharSet);
 {$ENDIF}
End;

Procedure TJSONValue.WriteToFieldDefs(JSONValue                : String;
                                      Const ResponseTranslator : TDWResponseTranslator);
 Function ReadFieldDefs(JSONObject,
                        ElementRoot      : String;
                        ElementRootIndex : Integer) : String;
 Var
  bJsonValueB,
  bJsonValue   : TDWJSONObject;
  A            : Integer;
  vDWFieldDef  : TDWFieldDef;
  vStringData,
  vStringDataB : String;
 Begin
  Result     := '';
  bJsonValue := TDWJSONObject.Create(JSONObject);
  Try
   If bJsonValue.PairCount > 0 Then
    Begin
     Result := JSONObject;
     If ResponseTranslator.FieldDefs.Count = 0 Then
      Begin
       For A := 0 To bJsonValue.PairCount -1 Do
        Begin
         If (ElementRoot <> '') or (JSONObject[InitStrPos] = '[') Then
          Begin
           If (UpperCase(ElementRoot) = UpperCase(bJsonValue.pairs[A].Name)) or
              (JSONObject[InitStrPos] = '[') Then
            Begin
             vStringData  := bJsonValue.pairs[A].Value;
             bJsonValueB := TDWJSONObject.Create(vStringData);
             If (JSONObject[InitStrPos] <> '[') Then
              vStringDataB := vStringData
             Else
              vStringDataB := JSONObject;
             While bJsonValueB.ClassType = TDWJSONArray Do
              Begin
               vStringData := bJsonValueB.Pairs[0].Value;
               bJsonValueB.Free;
               bJsonValueB := TDWJSONObject.Create(vStringData);
               If bJsonValueB.ClassType = TDWJSONArray Then
                vStringDataB := vStringData;
              End;
             bJsonValueB.Free;
             Result := vStringDataB;
             ReadFieldDefs(vStringData, '', -1);
             Exit;
            End;
          End
         Else
          Begin
           If ResponseTranslator.FieldDefs.FieldDefByName[bJsonValue.pairs[A].Name] = Nil Then
            Begin
             vDWFieldDef              := TDWFieldDef(ResponseTranslator.FieldDefs.Add);
             vDWFieldDef.ElementName  := bJsonValue.pairs[A].Name;
             vDWFieldDef.ElementIndex := A;
             vDWFieldDef.FieldName    := vDWFieldDef.ElementName;
             vDWFieldDef.FieldSize    := Length(bJsonValue.pairs[A].Value);
             vDWFieldDef.DataType     := ovString;
            End;
          End;
        End;
      End;
    End;
  Finally
   bJsonValue.Free;
  End;
 End;
Var
 bJsonValue : TDWJSONObject;
Begin
 bJsonValue := TDWJSONObject.Create(JSONValue);
 Try
  If bJsonValue.PairCount > 0 Then
   ReadFieldDefs(JSONValue,
                 ResponseTranslator.ElementRootBaseName,
                 ResponseTranslator.ElementRootBaseIndex);
 Finally
  FreeAndNil(bJsonValue);
 End;
End;

Procedure TJSONValue.WriteToDataset(JSONValue          : String;
                                    Const DestDS       : TDataset;
                                    ResponseTranslator : TDWResponseTranslator;
                                    ResquestMode       : TResquestMode);
Var
 FieldValidate     : TFieldNotifyEvent;
 //vFieldDefinition : TFieldDefinition;
 bJsonValue,
 bJsonValueB,
 bJsonValueC       : TDWJSONObject;
 bJsonArrayB       : TDWJSONArray;
 ListFields        : TStringList;
 A, J, I, Z        : Integer;
 vBlobStream       : TMemoryStream;
 vTempValueJSONB,
 vTempValueJSON,
 vTempValue        : String;
 FieldDef          : TFieldDef;
 Field             : TField;
 AbortProcess,
 vOldReadOnly,
 vFindFlag         : Boolean;
 bJsonOBJB,
 bJsonOBJ          : TDWJSONBase;
 vLocSetInBlockEvents : TSetInitDataset;
 vLocNewDataField     : TNewDataField;
 vLocFieldExist       : TFieldExist;
 vLocSetRecordCount   : TSetRecordCount;
 vLocSetInitDataset   : TSetInitDataset;
 vLocNewFieldList,
 vLocCreateDataset    : TProcedureEvent;
 vLocFieldListCount   : TFieldListCount;
 Function ReadFieldDefs(Var vResult      : String;
                        JSONObject,
                        ElementRoot      : String;
                        ElementRootIndex : Integer;
                        InLoop           : Boolean = False;
                        IgnoreRules      : Boolean = False) : Boolean;
 Var
  bJsonValueB,
  bJsonValue   : TDWJSONObject;
  A, I         : Integer;
  vFieldDefsCreate,
  vFindIndex   : Boolean;
  vDWFieldDef  : TDWFieldDef;
  vStringData,
  vStringDataB,
  vStringDataTemp : String;
 Begin
  bJsonValueB := Nil;
  bJsonValue  := Nil;
  Result     := False;
  If JSONObject <> '' Then
   Begin
    bJsonValue  := TDWJSONObject.Create(JSONObject);
    vFindIndex  := False;
    Try
     If bJsonValue.PairCount > 0 Then
      Begin
  //     vResult          := JSONObject;
       vFieldDefsCreate := ResponseTranslator.FieldDefs.Count = 0;
       If Not vFieldDefsCreate Then
        vFieldDefsCreate := InLoop;
       For A := 0 To bJsonValue.PairCount -1 Do
        Begin
         If (((ElementRoot <> '') or (JSONObject[InitStrPos] = '[')) And Not(IgnoreRules)) or (Not (vFieldDefsCreate)) Then
          Begin
           vResult    := '';
           If (UpperCase(ElementRoot) = UpperCase(bJsonValue.pairs[A].Name)) or
              (JSONObject[InitStrPos] = '[') Then
            Begin
             vFindIndex   := UpperCase(ElementRoot) = UpperCase(bJsonValue.pairs[A].Name);
             vStringData  := bJsonValue.pairs[A].Value;
             If (JSONObject[InitStrPos] <> '[') Then
              vStringDataB    := vStringData
             Else
              vStringDataB    := JSONObject;
             If (vStringData = 'null') Or (vStringData = '') Then
              Begin
               vStringData := '';
               If (vStringDataB = 'null') Or (vStringDataB = '') Then
                vStringDataB := '';
               vResult := vStringDataB;
              End
             Else
              Begin
               vStringDataTemp := vStringDataB;
               bJsonValueB := TDWJSONObject.Create(vStringDataTemp);
               I := 0;
               While (bJsonValueB <> Nil) And (bJsonValueB.ClassType = TDWJSONArray) And
                     ((bJsonValueB.PairCount > 0) And (I <= bJsonValueB.PairCount))  Do
                Begin
                 vStringData := bJsonValueB.Pairs[I].Value;
                 FreeAndNil(bJsonValueB);
                 If (vStringData[InitStrPos] = '{') Or
                    (vStringData[InitStrPos] = '[') Then
                  bJsonValueB := TDWJSONObject.Create(vStringData)
                 Else
                  Begin
                   vStringData := vStringDataTemp;
                   IgnoreRules := True;
                   Break;
                  End;
                 Inc(I);
                End;
               If Assigned(bJsonValueB) Then
                bJsonValueB.Free;
               vResult := vStringDataTemp;
              End;
  //           vResult := vStringDataB;
             If Not Result Then
              Begin
               If vFindIndex Then
                Begin
                 vResult := vStringDataTemp;
                 Result := ReadFieldDefs(vResult, vStringData, '', -1, vFindIndex, IgnoreRules);
                End
               Else
                Begin
                 Result := ReadFieldDefs(vResult, vStringData, ElementRoot, -1, vFindIndex, IgnoreRules);
  //               vResult := vStringDataTemp;
                End;
              End;
             Exit;
            End;
          End
         Else If vFieldDefsCreate Then
          Begin
           Result     := True;
           vFindIndex := True;
           If ResponseTranslator.FieldDefs.FieldDefByName[bJsonValue.pairs[A].Name] = Nil Then
            Begin
             vDWFieldDef              := TDWFieldDef(ResponseTranslator.FieldDefs.Add);
             vDWFieldDef.ElementName  := bJsonValue.pairs[A].Name;
             vDWFieldDef.ElementIndex := A;
             vDWFieldDef.FieldName    := vDWFieldDef.ElementName;
             vDWFieldDef.FieldSize    := Length(bJsonValue.pairs[A].Value);
             If vDWFieldDef.FieldSize = 0 Then
              vDWFieldDef.FieldSize   := 10;
             vDWFieldDef.DataType     := ovString;
            End;
          End;
        End;
       If (ElementRoot <> '') Then
       If Not(vFindIndex) Then
        Begin
         For A := 0 To bJsonValue.PairCount -1 Do
          Begin
           vStringDataTemp := bJsonValue.pairs[A].Value;
           Result := ReadFieldDefs(vResult, vStringDataTemp, ElementRoot, -1);
           If Result Then
            Break;
          End;
        End;
      End;
    Finally
     bJsonValue.Free;
     If Not Result Then
      If vResult = '' Then
       vResult := JSONValue;
    End;
   End;
 End;
Begin
 vFieldDefinition  := Nil;
 bJsonValue        := Nil;
 bJsonValueB       := Nil;
 bJsonValueC       := Nil;
 bJsonArrayB       := Nil;
 bJsonOBJB         := Nil;
 bJsonOBJ          := Nil;
 vBlobStream       := Nil;
 AbortProcess      := False;
 vLocSetInBlockEvents := SetInBlockEvents;
 vLocNewDataField     := NewDataField;
 vLocFieldExist       := FieldExist;
 vLocFieldListCount   := FieldListCount;
 vLocNewFieldList     := NewFieldList;
 vLocCreateDataSet    := CreateDataSet;
 vLocSetRecordCount   := SetRecordCount;
 vLocSetInitDataset   := SetInitDataset;
 If (Trim(JSONValue) = '') or (Trim(JSONValue) = '{}') or (Trim(JSONValue) = '[]') Then // Ico Menezes - Tratar Erros de JsonVazio
  Exit;
 ListFields  := TStringList.Create;
 bJsonValueB := Nil;
 bJsonValue  := TDWJSONObject.Create(JSONValue);
 Try
  If bJsonValue.PairCount > 0 Then
   Begin
    vLocSetInBlockEvents(True);
    DestDS.DisableControls;
    If DestDS.Active Then
     DestDS.Close;
    vTempValueJSON := JSONValue;
    If (ResquestMode = rtOnlyFields) Or
      (((ResponseTranslator.ElementAutoReadRootIndex)    Or
        (ResponseTranslator.ElementRootBaseName <> '')   Or
        (ResponseTranslator.ElementRootBaseIndex > -1))) Then
     ReadFieldDefs(vTempValueJSON, JSONValue,
                   ResponseTranslator.ElementRootBaseName,
                   ResponseTranslator.ElementRootBaseIndex);
    vLocNewFieldList;
    vFieldDefinition := TFieldDefinition.Create;
    If DestDS.Fields.Count = 0 Then
     DestDS.FieldDefs.Clear;
    //Removendo campos inv�lidos
    For J := DestDS.Fields.Count - 1 DownTo 0 Do
     Begin
      If DestDS.Fields[J].FieldKind = fkData Then
       If ResponseTranslator.FieldDefs.FieldDefByName[DestDS.Fields[J].FieldName] = Nil Then
        DestDS.Fields.Remove(DestDS.Fields[J]);
     End;
    For J := 0 To DestDS.Fields.Count - 1 Do
     Begin
      vFieldDefinition.FieldName := DestDS.Fields[J].FieldName;
      vFieldDefinition.DataType  := DestDS.Fields[J].DataType;
      If (vFieldDefinition.DataType <> ftFloat) Then
       vFieldDefinition.Size     := DestDS.Fields[J].Size
      Else
       vFieldDefinition.Size     := 0;
      If (vFieldDefinition.DataType In [ftCurrency, ftBCD,
                                        {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                        {$IFEND}{$ENDIF} ftFMTBcd]) Then
       vFieldDefinition.Precision := TBCDField(DestDS.Fields[J]).Precision
      Else If (vFieldDefinition.DataType = ftFloat) Then
       vFieldDefinition.Precision := TFloatField(DestDS.Fields[J]).Precision;
      vFieldDefinition.Required   := DestDS.Fields[J].Required;
      vLocNewDataField(vFieldDefinition);
     End;
    For J := 0 To ResponseTranslator.FieldDefs.Count - 1 Do
     Begin
      vTempValue := Trim(ResponseTranslator.FieldDefs[J].FieldName);
      If Trim(vTempValue) <> '' Then
       Begin
        FieldDef := FieldDefExist(DestDS, vTempValue);
        If (FieldDef = Nil) Then
         Begin
          If (vLocFieldExist(DestDS, vTempValue) = Nil) Then
           Begin
            vFieldDefinition.FieldName  := vTempValue;
            vFieldDefinition.DataType   := ObjectValueToFieldType(ResponseTranslator.FieldDefs[J].DataType);
            If (vFieldDefinition.DataType <> ftFloat) Then
             vFieldDefinition.Size     := ResponseTranslator.FieldDefs[J].FieldSize
            Else
             vFieldDefinition.Size         := 0;
            If (vFieldDefinition.DataType In [ftFloat, ftCurrency, ftBCD,
                                              {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                              {$IFEND}{$ENDIF} ftFMTBcd]) Then
             vFieldDefinition.Precision := ResponseTranslator.FieldDefs[J].Precision
            Else If (vFieldDefinition.DataType = ftFloat) Then
             vFieldDefinition.Precision := ResponseTranslator.FieldDefs[J].Precision;
            vFieldDefinition.Required   := ResponseTranslator.FieldDefs[J].Required;
            vLocNewDataField(vFieldDefinition);
           End;
          FieldDef          := DestDS.FieldDefs.AddFieldDef;
          If vEncoding = esUtf8 Then
           Begin
           {$IFDEF FPC}
            FieldDef.Name   := vTempValue;
           {$ELSE}
            FieldDef.Name   := UTF8Encode(vTempValue);
           {$ENDIF}
           End
          Else
           FieldDef.Name    := vTempValue;
//            FieldDef.Name     := vTempValue;
          FieldDef.DataType := ObjectValueToFieldType(ResponseTranslator.FieldDefs[J].DataType);
          If FieldDef.DataType in [ftString, ftWideString] Then
           FieldDef.Size := 255;
          If Not (FieldDef.DataType in [ftFloat,ftCurrency
                                        {$IFNDEF FPC}{$IF CompilerVersion > 21},ftExtended,ftSingle
                                        {$IFEND}{$ENDIF}]) Then
           Begin
            If (FieldDef.Size > ResponseTranslator.FieldDefs[J].FieldSize) then // ajuste em 20/12/2018 Thiago Pedro
             ResponseTranslator.FieldDefs[J].FieldSize := FieldDef.Size
            Else
             FieldDef.Size     := ResponseTranslator.FieldDefs[J].FieldSize;
            If FieldDef.DataType in [ftString, ftWideString] Then
             If FieldDef.Size > 4000 Then
              Begin
               ResponseTranslator.FieldDefs[J].DataType := ovMemo;
               FieldDef.DataType := ObjectValueToFieldType(ResponseTranslator.FieldDefs[J].DataType);
              End;
           End;
          If (FieldDef.DataType In [ftFloat, ftCurrency, ftBCD,
                                    {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                    {$IFEND}{$ENDIF} ftFMTBcd]) Then
           FieldDef.Precision := ResponseTranslator.FieldDefs[J].Precision;
         End;
       End;
     End;
    if Assigned(vFieldDefinition) then
      FreeAndNil(vFieldDefinition);
    DestDS.FieldDefs.EndUpdate;
    Try
     vLocSetInBlockEvents(True);
     Inactive := True;
     If Assigned(vLocCreateDataSet) Then
      vLocCreateDataSet();
     If Not DestDS.Active Then
      DestDS.Open;
     If Not DestDS.Active Then
      Begin
       FreeAndNil(bJsonValue);
       FreeAndNil(ListFields);
       Raise Exception.Create('Error on Parse JSON Data...');
       Exit;
      End;
     //Add Set PK Fields
     For J := 0 To ResponseTranslator.FieldDefs.Count - 1 Do
      Begin
       If ResponseTranslator.FieldDefs[J].Required Then
        Begin
         Field := DestDS.FindField(ResponseTranslator.FieldDefs[J].FieldName);
         If Field <> Nil Then
          Begin
           If Field.FieldKind = fkData Then
            Field.ProviderFlags := [pfInUpdate, pfInWhere, pfInKey]
           Else
            Field.ProviderFlags := [];
          End;
        End;
      End;
     bJsonValueB := TDWJSONObject.Create(vTempValueJSON);
     For A := 0 To DestDS.Fields.Count - 1 Do // ADICIONA REGISTRO
      Begin
       vFindFlag := False;
       If DestDS.FindField(DestDS.Fields[A].FieldName) <> Nil Then
        If DestDS.FindField(DestDS.Fields[A].FieldName).FieldKind = fkData Then
         Begin
          If bJsonValueB.ClassType = TDWJSONObject Then
           Begin
            For J := 0 To bJsonValueB.PairCount - 1 Do
             Begin
              vFindFlag := Uppercase(Trim(bJsonValueB.pairs[J].Name)) = Uppercase(DestDS.Fields[A].FieldName);
              If vFindFlag Then
               Begin
                ListFields.Add(inttostr(J));
                Break;
               End;
//              FreeAndNil(bJsonOBJ);
             End;
           End
          Else If bJsonValueB.ClassType = TDWJSONArray Then //Enviado poir Rylan (Genesys Sistemas)
           Begin
            bJsonValueC := Nil;
            For Z := 0 to TDWJSONObject(bJsonValueB).PairCount -1 do
             Begin
              vTempValueJSONB := TDWJSONObject(bJsonValueB).pairs[Z].Value;
              If (vTempValueJSONB[InitStrPos] = '{') Or (vTempValueJSONB[InitStrPos] = '[') Then
               bJsonValueC := TDWJSONObject.Create(vTempValueJSONB);
              If Assigned(bJsonValueC) Then
               If bJsonValueC.PairCount = DestDS.Fields.Count Then
                Break;
              vTempValueJSONB := EmptyStr;
             End;
            If Assigned(bJsonValueC) Then
             FreeAndNil(bJsonValueC);
            If vTempValueJSONB = EmptyStr then
             vTempValueJSONB := TDWJSONObject(bJsonValueB).pairs[0].Value;
            If (vTempValueJSONB[InitStrPos] = '{') Or
               (vTempValueJSONB[InitStrPos] = '[') Then
             Begin
              bJsonValueB.Free;
              bJsonValueB := TDWJSONObject.Create(vTempValueJSONB);
             End;
            For J := 0 To bJsonValueB.PairCount - 1 Do
             Begin
              If Trim(bJsonValueB.pairs[J].Name) <> '' Then
               Begin
                vFindFlag := Uppercase(Trim(bJsonValueB.pairs[J].Name)) = Uppercase(DestDS.Fields[A].FieldName);
                If vFindFlag Then
                 Begin
                  ListFields.Add(inttostr(J));
                  Break;
                 End;
                End;
              FreeAndNil(bJsonOBJ);
             End;
           End;
         End;
       If Not vFindFlag Then
        ListFields.Add('-1');
      End;
     bJsonValueB.Free;
     bJsonValueB := TDWJSONObject.Create(vTempValueJSON);
     If bJsonValueB.ClassType = TDWJSONObject Then
      Begin
       vLocSetInBlockEvents(True);
       vLocSetRecordCount(1, 1);
       DestDS.Append;
       Try
        For i := 0 To DestDS.Fields.Count - 1 Do
         Begin
          vOldReadOnly                := DestDS.Fields[i].ReadOnly;
          FieldValidate               := DestDS.Fields[i].OnValidate;
          DestDS.Fields[i].OnValidate := Nil;
          DestDS.Fields[i].ReadOnly   := False;
          If DestDS.Fields[i].FieldKind = fkLookup Then
           Begin
            DestDS.Fields[i].ReadOnly := vOldReadOnly;
            DestDS.Fields[i].OnValidate := FieldValidate;
            Continue;
           End;
          If (i >= ListFields.Count) Then
           Begin
            DestDS.Fields[i].ReadOnly := vOldReadOnly;
            DestDS.Fields[i].OnValidate := FieldValidate;
            Continue;
           End;
          If (StrToInt(ListFields[i])       = -1)     Or
             Not(DestDS.Fields[i].FieldKind = fkData) Or
             (StrToInt(ListFields[i]) = -1)           Then
           Begin
            DestDS.Fields[i].ReadOnly := vOldReadOnly;
            DestDS.Fields[i].OnValidate := FieldValidate;
            Continue;
           End;
//          FreeAndNil(bJsonOBJB);
          vTempValue := bJsonValueB.Pairs[StrToInt(ListFields[i])].Value;
          If DestDS.Fields[i].DataType In [ftGraphic, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor,
                                           ftDataSet, ftBlob, ftOraBlob, ftOraClob{$IFNDEF FPC}{$IF CompilerVersion > 21},
                                           ftParams, ftStream{$IFEND}{$ENDIF}] Then
           Begin
            If (vTempValue <> 'null') And (vTempValue <> '') Then
             Begin
              //HexStringToStream(vTempValue, vBlobStream);
              vBlobStream := Decodeb64Stream(vTempValue);
              Try
               vBlobStream.Position := 0;
               TBlobField(DestDS.Fields[i]).LoadFromStream(vBlobStream);
              Finally
               {$IFNDEF FPC}
                {$IF CompilerVersion > 21}
                 vBlobStream.Clear;
                {$IFEND}
               {$ENDIF}
               FreeAndNil(vBlobStream);
              End;
             End;
           End
          Else
           Begin
            If (Lowercase(vTempValue) <> 'null') Then
             Begin
              If DestDS.Fields[i].DataType in [ftString, ftWideString,
                                               {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,
                                               {$IFEND}{$ELSE}ftWideMemo,{$ENDIF}ftMemo, ftFmtMemo, ftFixedChar] Then
               Begin
                If vTempValue = '' Then
                 DestDS.Fields[i].AsString := ''
                Else
                 Begin
//                  If vEncoded Then
//                   DestDS.Fields[i].AsString := DecodeStrings(vTempValue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
//                  Else
                  If vUtf8SpecialChars Then
                   vTempValue := Unescape_chars(vTempValue);
                  vTempValue  := {$IFDEF FPC}GetStringDecode(vTempValue, vDatabaseCharSet){$ELSE}vTempValue{$ENDIF};
                  DestDS.Fields[i].AsString := vTempValue;
                 End;
               End
              Else If (vTempValue <> '') then
               SetValueA(DestDS.Fields[i], vTempValue);
             End;
           End;
          DestDS.Fields[i].ReadOnly := vOldReadOnly;
          DestDS.Fields[i].OnValidate := FieldValidate;
         End;
       Finally
        vTempValue := '';
       End;
       DestDS.Post;
       If Assigned(vOnWriterProcess) Then
        vOnWriterProcess(DestDS, 1, 1, AbortProcess);
       If AbortProcess Then
        Exit;
      End
     Else
      Begin
       bJsonArrayB := TDWJSONArray(bJsonValueB);
       vLocSetInBlockEvents(True);
       vLocSetRecordCount(bJsonArrayB.ElementCount, bJsonArrayB.ElementCount);
       For J := 0 To bJsonArrayB.ElementCount - 1 Do
        Begin
         bJsonOBJB := TDWJSONArray(bJsonArrayB).GetObject(J);
         DestDS.Append;
         Try
          For i := 0 To DestDS.Fields.Count - 1 Do
           Begin
            vOldReadOnly                := DestDS.Fields[i].ReadOnly;
            FieldValidate               := DestDS.Fields[i].OnValidate;
            DestDS.Fields[i].OnValidate := Nil;
            DestDS.Fields[i].ReadOnly   := False;
            If DestDS.Fields[i].FieldKind = fkLookup Then
             Begin
              DestDS.Fields[i].ReadOnly := vOldReadOnly;
              DestDS.Fields[i].OnValidate := FieldValidate;
              Continue;
             End;
            If (i >= ListFields.Count) Then
             Begin
              DestDS.Fields[i].ReadOnly := vOldReadOnly;
              DestDS.Fields[i].OnValidate := FieldValidate;
              Continue;
             End;
            If (StrToInt(ListFields[i])       = -1)     Or
               Not(DestDS.Fields[i].FieldKind = fkData) Or
               (StrToInt(ListFields[i]) = -1)           Then
             Begin
              DestDS.Fields[i].ReadOnly := vOldReadOnly;
              DestDS.Fields[i].OnValidate := FieldValidate;
              Continue;
             End;
//            FreeAndNil(bJsonOBJB);
            If Not TDWJSONObject(bJsonOBJB).pairs[StrToInt(ListFields[i])].isnull Then
             vTempValue := TDWJSONObject(bJsonOBJB).pairs[StrToInt(ListFields[i])].Value // bJsonOBJTemp.get().ToString;
            Else
             Continue;
            If DestDS.Fields[i].DataType In [ftGraphic, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor,
                                             ftDataSet, ftBlob, ftOraBlob, ftOraClob{$IFNDEF FPC}{$IF CompilerVersion > 21},
                                             ftParams, ftStream{$IFEND}{$ENDIF}] Then
             Begin
              If (vTempValue <> 'null') And (vTempValue <> '') Then
               Begin
//                HexStringToStream(vTempValue, vBlobStream);
                vBlobStream := Decodeb64Stream(vTempValue);
                Try
                 vBlobStream.Position := 0;
                 TBlobField(DestDS.Fields[i]).LoadFromStream(vBlobStream);
                Finally
                 {$IFNDEF FPC}
                  {$IF CompilerVersion > 21}
                   vBlobStream.Clear;
                  {$IFEND}
                 {$ENDIF}
                 FreeAndNil(vBlobStream);
                End;
               End;
             End
            Else
             Begin
              If (Lowercase(vTempValue) <> 'null') Then
               Begin
                If DestDS.Fields[i].DataType in [ftString, ftWideString,
                                                 {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,
                                                 {$IFEND}{$ELSE}ftWideMemo,{$ENDIF}ftMemo, ftFmtMemo, ftFixedChar] Then
                 Begin
                  If vTempValue = '' Then
                   DestDS.Fields[i].AsString := ''
                  Else
                   Begin
                    if vEncoded then
                     DestDS.Fields[i].AsString := DecodeStrings(vTempValue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                    Else
                     Begin
                      If vUtf8SpecialChars Then
                       vTempValue := unescape_chars(vTempValue);
                      vTempValue := {$IFDEF FPC}GetStringDecode(vTempValue, vDatabaseCharSet){$ELSE}vTempValue{$ENDIF};
                      DestDS.Fields[i].AsString := vTempValue;
                     End;
                   End;
                 End
                Else If (vTempValue <> '') then
                 SetValueA(DestDS.Fields[i], vTempValue);
               End;
             End;
            DestDS.Fields[i].ReadOnly := vOldReadOnly;
            DestDS.Fields[i].OnValidate := FieldValidate;
           End;
         Finally
          vTempValue := '';
         End;
         FreeAndNil(bJsonOBJB);
         DestDS.Post;
         If Assigned(vOnWriterProcess) Then
          vOnWriterProcess(DestDS, J +1, bJsonArrayB.ElementCount, AbortProcess);
         If AbortProcess Then
          Break;
        End;
      End;
    Except
    End;
   End;
 Finally
  If Assigned(ListFields) Then
   FreeAndNil(ListFields);
  If DestDS.Active Then
   DestDS.First;
  DestDS.EnableControls;
  If Assigned(bJsonValue) Then
   FreeAndNil(bJsonValue);
  If Assigned(bJsonValueB) Then
   FreeAndNil(bJsonValueB);
 End;
End;

Procedure TJSONValue.WriteToDataset (DatasetType    : TDatasetType;
                                     JSONValue      : String;
                                     Const DestDS   : TDataset;
                                     ClearDataset   : Boolean          = False{$IFDEF FPC};
                                     CharSet        : TDatabaseCharSet = csUndefined{$ENDIF});
Var
 JsonCount : Integer;
Begin
 JsonCount := 0;
 JSONValue := StringReplace(JSONValue, #239#187#191, '', [rfReplaceAll]);
 JSONValue := StringReplace(JSONValue, sLineBreak,   '', [rfReplaceAll]);
 WriteToDataset(DatasetType, JSONValue, DestDS, JsonCount, -1, 0,
                ClearDataset{$IFDEF FPC}, CharSet{$ENDIF});
End;

procedure TJSONValue.WriteToDataset(JSONValue: String; const DestDS: TDataset);
Var
 FieldValidate     : TFieldNotifyEvent;
 bJsonValue,
 bJsonValueB,
 bJsonValueC       : TDWJSONObject;
 bJsonArrayB       : TDWJSONArray;
 ListFields        : TStringList;
 A, J, I, Z        : Integer;
 vBlobStream       : TMemoryStream;
 vTempValueJSONB,
 vTempValueJSON,
 vTempValue        : String;
 AbortProcess,
 vOldReadOnly,
 vFindFlag         : Boolean;
 bJsonOBJB,
 bJsonOBJ          : TDWJSONBase;
Begin
 vFieldDefinition  := Nil;
 bJsonValue        := Nil;
 bJsonValueB       := Nil;
 bJsonValueC       := Nil;
 bJsonArrayB       := Nil;
 bJsonOBJB         := Nil;
 bJsonOBJ          := Nil;
 vBlobStream       := Nil;
 AbortProcess      := False;
 If (Trim(JSONValue) = '') or (Trim(JSONValue) = '{}') or (Trim(JSONValue) = '[]') Then // Ico Menezes - Tratar Erros de JsonVazio
  Exit;
 ListFields  := TStringList.Create;
 bJsonValueB := Nil;
 bJsonValue  := TDWJSONObject.Create(JSONValue);
 Try
  If bJsonValue.PairCount > 0 Then
   Begin
    DestDS.DisableControls;
    If DestDS.Active Then
     DestDS.Close;
    vTempValueJSON := JSONValue;
    Try
     Inactive := True;
     If Not DestDS.Active Then
      DestDS.Open;
     If Not DestDS.Active Then
      Begin
       FreeAndNil(bJsonValue);
       FreeAndNil(ListFields);
       Raise Exception.Create('Error on Parse JSON Data...');
       Exit;
      End;
     bJsonValueB := TDWJSONObject.Create(vTempValueJSON);
     For A := 0 To DestDS.Fields.Count - 1 Do // ADICIONA REGISTRO
      Begin
       vFindFlag := False;
       If DestDS.FindField(DestDS.Fields[A].FieldName) <> Nil Then
        If DestDS.FindField(DestDS.Fields[A].FieldName).FieldKind = fkData Then
         Begin
          If bJsonValueB.ClassType = TDWJSONObject Then
           Begin
            For J := 0 To bJsonValueB.PairCount - 1 Do
             Begin
              vFindFlag := Uppercase(Trim(bJsonValueB.pairs[J].Name)) = Uppercase(DestDS.Fields[A].FieldName);
              If vFindFlag Then
               Begin
                ListFields.Add(inttostr(J));
                Break;
               End;
//              FreeAndNil(bJsonOBJ);
             End;
           End
          Else If bJsonValueB.ClassType = TDWJSONArray Then //Enviado poir Rylan (Genesys Sistemas)
           Begin
            bJsonValueC := Nil;
            For Z := 0 to TDWJSONObject(bJsonValueB).PairCount -1 do
             Begin
              vTempValueJSONB := TDWJSONObject(bJsonValueB).pairs[Z].Value;
              If (vTempValueJSONB[InitStrPos] = '{') Or (vTempValueJSONB[InitStrPos] = '[') Then
               bJsonValueC := TDWJSONObject.Create(vTempValueJSONB);
              If Assigned(bJsonValueC) Then
               If bJsonValueC.PairCount = DestDS.Fields.Count Then
                Break;
              vTempValueJSONB := EmptyStr;
             End;
            If Assigned(bJsonValueC) Then
             FreeAndNil(bJsonValueC);
            If vTempValueJSONB = EmptyStr then
             vTempValueJSONB := TDWJSONObject(bJsonValueB).pairs[0].Value;
            If (vTempValueJSONB[InitStrPos] = '{') Or
               (vTempValueJSONB[InitStrPos] = '[') Then
             Begin
              bJsonValueB.Free;
              bJsonValueB := TDWJSONObject.Create(vTempValueJSONB);
             End;
            For J := 0 To bJsonValueB.PairCount - 1 Do
             Begin
              If Trim(bJsonValueB.pairs[J].Name) <> '' Then
               Begin
                vFindFlag := Uppercase(Trim(bJsonValueB.pairs[J].Name)) = Uppercase(DestDS.Fields[A].FieldName);
                If vFindFlag Then
                 Begin
                  ListFields.Add(inttostr(J));
                  Break;
                 End;
                End;
              FreeAndNil(bJsonOBJ);
             End;
           End;
         End;
       If Not vFindFlag Then
        ListFields.Add('-1');
      End;
     bJsonValueB.Free;
     bJsonValueB := TDWJSONObject.Create(vTempValueJSON);
     If bJsonValueB.ClassType = TDWJSONObject Then
      Begin
       DestDS.Append;
       Try
        For i := 0 To DestDS.Fields.Count - 1 Do
         Begin
          vOldReadOnly                := DestDS.Fields[i].ReadOnly;
          FieldValidate               := DestDS.Fields[i].OnValidate;
          DestDS.Fields[i].OnValidate := Nil;
          DestDS.Fields[i].ReadOnly   := False;
          If DestDS.Fields[i].FieldKind = fkLookup Then
           Begin
            DestDS.Fields[i].ReadOnly := vOldReadOnly;
            DestDS.Fields[i].OnValidate := FieldValidate;
            Continue;
           End;
          If (i >= ListFields.Count) Then
           Begin
            DestDS.Fields[i].ReadOnly := vOldReadOnly;
            DestDS.Fields[i].OnValidate := FieldValidate;
            Continue;
           End;
          If (StrToInt(ListFields[i])       = -1)     Or
             Not(DestDS.Fields[i].FieldKind = fkData) Or
             (StrToInt(ListFields[i]) = -1)           Then
           Begin
            DestDS.Fields[i].ReadOnly := vOldReadOnly;
            DestDS.Fields[i].OnValidate := FieldValidate;
            Continue;
           End;
//          FreeAndNil(bJsonOBJB);
          vTempValue := bJsonValueB.Pairs[StrToInt(ListFields[i])].Value;
          If DestDS.Fields[i].DataType In [ftGraphic, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor,
                                           ftDataSet, ftBlob, ftOraBlob, ftOraClob{$IFNDEF FPC}{$IF CompilerVersion > 21},
                                           ftParams, ftStream{$IFEND}{$ENDIF}] Then
           Begin
            If (vTempValue <> 'null') And (vTempValue <> '') Then
             Begin
              //HexStringToStream(vTempValue, vBlobStream);
              vBlobStream := Decodeb64Stream(vTempValue);
              Try
               vBlobStream.Position := 0;
               TBlobField(DestDS.Fields[i]).LoadFromStream(vBlobStream);
              Finally
               {$IFNDEF FPC}
                {$IF CompilerVersion > 21}
                 vBlobStream.Clear;
                {$IFEND}
               {$ENDIF}
               FreeAndNil(vBlobStream);
              End;
             End;
           End
          Else
           Begin
            If (Lowercase(vTempValue) <> 'null') Then
             Begin
              If DestDS.Fields[i].DataType in [ftString, ftWideString,
                                               {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,
                                               {$IFEND}{$ELSE}ftWideMemo,{$ENDIF}ftMemo, ftFmtMemo, ftFixedChar] Then
               Begin
                If vTempValue = '' Then
                 DestDS.Fields[i].AsString := ''
                Else
                 Begin
//                  If vEncoded Then
//                   DestDS.Fields[i].AsString := DecodeStrings(vTempValue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
//                  Else
                  If vUtf8SpecialChars Then
                   vTempValue := Unescape_chars(vTempValue);
                  vTempValue  := {$IFDEF FPC}GetStringDecode(vTempValue, vDatabaseCharSet){$ELSE}vTempValue{$ENDIF};
                  DestDS.Fields[i].AsString := vTempValue;
                 End;
               End
              Else If (vTempValue <> '') then
               SetValueA(DestDS.Fields[i], vTempValue);
             End;
           End;
          DestDS.Fields[i].ReadOnly := vOldReadOnly;
          DestDS.Fields[i].OnValidate := FieldValidate;
         End;
       Finally
        vTempValue := '';
       End;
       DestDS.Post;
       If Assigned(vOnWriterProcess) Then
        vOnWriterProcess(DestDS, 1, 1, AbortProcess);
       If AbortProcess Then
        Exit;
      End
     Else
      Begin
       bJsonArrayB := TDWJSONArray(bJsonValueB);
       For J := 0 To bJsonArrayB.ElementCount - 1 Do
        Begin
         bJsonOBJB := TDWJSONArray(bJsonArrayB).GetObject(J);
         DestDS.Append;
         Try
          For i := 0 To DestDS.Fields.Count - 1 Do
           Begin
            vOldReadOnly                := DestDS.Fields[i].ReadOnly;
            FieldValidate               := DestDS.Fields[i].OnValidate;
            DestDS.Fields[i].OnValidate := Nil;
            DestDS.Fields[i].ReadOnly   := False;
            If DestDS.Fields[i].FieldKind = fkLookup Then
             Begin
              DestDS.Fields[i].ReadOnly := vOldReadOnly;
              DestDS.Fields[i].OnValidate := FieldValidate;
              Continue;
             End;
            If (i >= ListFields.Count) Then
             Begin
              DestDS.Fields[i].ReadOnly := vOldReadOnly;
              DestDS.Fields[i].OnValidate := FieldValidate;
              Continue;
             End;
            If (StrToInt(ListFields[i])       = -1)     Or
               Not(DestDS.Fields[i].FieldKind = fkData) Or
               (StrToInt(ListFields[i]) = -1)           Then
             Begin
              DestDS.Fields[i].ReadOnly := vOldReadOnly;
              DestDS.Fields[i].OnValidate := FieldValidate;
              Continue;
             End;
//            FreeAndNil(bJsonOBJB);
            If Not TDWJSONObject(bJsonOBJB).pairs[StrToInt(ListFields[i])].isnull Then
             vTempValue := TDWJSONObject(bJsonOBJB).pairs[StrToInt(ListFields[i])].Value // bJsonOBJTemp.get().ToString;
            Else
             Continue;
            If DestDS.Fields[i].DataType In [ftGraphic, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor,
                                             ftDataSet, ftBlob, ftOraBlob, ftOraClob{$IFNDEF FPC}{$IF CompilerVersion > 21},
                                             ftParams, ftStream{$IFEND}{$ENDIF}] Then
             Begin
              If (vTempValue <> 'null') And (vTempValue <> '') Then
               Begin
//                HexStringToStream(vTempValue, vBlobStream);
                vBlobStream := Decodeb64Stream(vTempValue);
                Try
                 vBlobStream.Position := 0;
                 TBlobField(DestDS.Fields[i]).LoadFromStream(vBlobStream);
                Finally
                 {$IFNDEF FPC}
                  {$IF CompilerVersion > 21}
                   vBlobStream.Clear;
                  {$IFEND}
                 {$ENDIF}
                 FreeAndNil(vBlobStream);
                End;
               End;
             End
            Else
             Begin
              If (Lowercase(vTempValue) <> 'null') Then
               Begin
                If DestDS.Fields[i].DataType in [ftString, ftWideString,
                                                 {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,
                                                 {$IFEND}{$ELSE}ftWideMemo,{$ENDIF}ftMemo, ftFmtMemo, ftFixedChar] Then
                 Begin
                  If vTempValue = '' Then
                   DestDS.Fields[i].AsString := ''
                  Else
                   Begin
                    if vEncoded then
                     DestDS.Fields[i].AsString := DecodeStrings(vTempValue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                    Else
                     Begin
                      If vUtf8SpecialChars Then
                       vTempValue := unescape_chars(vTempValue);
                      vTempValue := {$IFDEF FPC}GetStringDecode(vTempValue, vDatabaseCharSet){$ELSE}vTempValue{$ENDIF};
                      DestDS.Fields[i].AsString := vTempValue;
                     End;
                   End;
                 End
                Else If DestDS.Fields[i].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                 Begin
                  If DestDS.Fields[i].DataType = ftDate Then
                   SetValueA(DestDS.Fields[i], inttostr(DateTimeToUnix(StrToDateTime(vTempValue))))
                  Else if DestDS.Fields[i].DataType = ftTime then
                   SetValueA(DestDS.Fields[i], inttostr(DateTimeToUnix(StrToDateTime(vTempValue))))
                  Else
                   SetValueA(DestDS.Fields[i], inttostr(DateTimeToUnix(StrToDateTime(vTempValue))));
                 End
                Else If (vTempValue <> '') then
                 SetValueA(DestDS.Fields[i], vTempValue);
               End;
             End;
            DestDS.Fields[i].ReadOnly := vOldReadOnly;
            DestDS.Fields[i].OnValidate := FieldValidate;
           End;
         Finally
          vTempValue := '';
         End;
         FreeAndNil(bJsonOBJB);
         DestDS.Post;
         If Assigned(vOnWriterProcess) Then
          vOnWriterProcess(DestDS, J +1, bJsonArrayB.ElementCount, AbortProcess);
         If AbortProcess Then
          Break;
        End;
      End;
    Except
    End;
   End;
 Finally
  If Assigned(ListFields) Then
   FreeAndNil(ListFields);
  If DestDS.Active Then
   DestDS.First;
  DestDS.EnableControls;
  If Assigned(bJsonValue) Then
   FreeAndNil(bJsonValue);
  If Assigned(bJsonValueB) Then
   FreeAndNil(bJsonValueB);
 End;
End;

Procedure TJSONValue.WriteToDataset(DatasetType   : TDatasetType;
                                    JSONValue     : String;
                                    Const DestDS  : TDataset;
                                    Var JsonCount : Integer;
                                    Datapacks     : Integer = -1;
                                    ActualRec     : Integer = 0;
                                    ClearDataset  : Boolean          = False{$IFDEF FPC};
                                    CharSet       : TDatabaseCharSet = csUndefined{$ENDIF});
Var
 FieldValidate    : TFieldNotifyEvent;
 bJsonOBJB,
 bJsonOBJ         : TDWJSONBase;
 bJsonValue       : TDWJSONObject;
 bJsonOBJTemp,
 bJsonArray,
 bJsonArrayB      : TDWJSONArray;
 A, J, I,
 vPageCount       : Integer;
 FieldDef         : TFieldDef;
 Field            : TField;
 AbortProcess,
 vOldReadOnly,
 vFindFlag        : Boolean;
 vBlobStream      : TMemoryStream;
 ListFields       : TStringList;
 vBuildSide,
 vTempValue       : String;
 //vFieldDefinition : TFieldDefinition;
 vActualBookmark  : TBookmark;
 vFieldDataType   : TFieldType;
 vLocSetInBlockEvents  : TSetInitDataset;
 vLocNewDataField      : TNewDataField;
 vLocFieldExist        : TFieldExist;
 vLocSetRecordCount    : TSetRecordCount;
 vLocSetInitDataset    : TSetInitDataset;
 vLocNewFieldList,
 vLocCreateDataSet     : TProcedureEvent;
 vLocFieldListCount    : TFieldListCount;
 vLocGetInDesignEvents : TGetInDesignEvents;
 Function FieldIndex(FieldName: String): Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For i := 0 To ListFields.Count - 1 Do
   Begin
    If Uppercase(ListFields[i]) = Uppercase(FieldName) Then
     Begin
      Result := i;
      Break;
     End;
   End;
 End;
Begin
 vFieldDefinition  := Nil;
 bJsonOBJB         := Nil;
 bJsonOBJ          := Nil;
 bJsonValue        := Nil;
 bJsonOBJTemp      := Nil;
 bJsonArray        := Nil;
 bJsonArrayB       := Nil;
 vBlobStream       := Nil;
 AbortProcess      := False;
 vLocSetInBlockEvents  := SetInBlockEvents;
 vLocNewDataField      := NewDataField;
 vLocFieldExist        := FieldExist;
 vLocFieldListCount    := FieldListCount;
 vLocNewFieldList      := NewFieldList;
 vLocCreateDataSet     := CreateDataSet;
 vLocSetRecordCount    := SetRecordCount;
 vLocSetInitDataset    := SetInitDataset;
 vLocGetInDesignEvents := GetInDesignEvents;
 If JSONValue = '' Then
  Exit;
 vPageCount := 0;
 ListFields := TStringList.Create;
 Try
  If Pos('[', JSONValue) = 0 Then
   Begin
    FreeAndNil(ListFields);
    Exit;
   End;
  bJsonValue  := TDWJSONObject.Create(JSONValue);
  If bJsonValue.PairCount > 0 Then
   Begin
    bJsonArray  := TDWJSONArray(bJsonValue.openArray(bJsonValue.pairs[4].Name));
    bJsonOBJ    := bJsonArray.GetObject(0);
    bJsonArrayB := TDWJSONObject(bJsonOBJ).openArray(TDWJSONObject(bJsonOBJ).pairs[0].Name);
    vBuildSide  := TDWJSONObject(bJsonOBJ).pairs[1].Value;
    if Assigned(bJsonOBJ) then
      FreeAndNil(bJsonOBJ);
   End
  Else
   Begin
    DestDS.Close;
    Raise Exception.Create('Invalid JSON Data...');
   End;
  If ActualRec = 0 Then
   Begin
    vTypeObject      := GetObjectName(bJsonValue.pairs[0].Value);
    vObjectDirection := GetDirectionName(bJsonValue.pairs[1].Value);
    vEncoded         := GetBooleanFromString(bJsonValue.pairs[2].Value);
    vObjectValue     := GetValueType(bJsonValue.pairs[3].Value);
    vtagName         := Lowercase(bJsonValue.pairs[4].Name);
    vLocSetInBlockEvents(True);
    DestDS.DisableControls;
    If DestDS.Active Then
     DestDS.Close;
    DestDS.FieldDefs.BeginUpdate;
    vLocNewFieldList;
    vFieldDefinition := TFieldDefinition.Create;
    DestDS.FieldDefs.Clear;
    If (DestDS.Fields.Count = 0) And
       (DestDS.FieldDefs.Count > 0) Then
     DestDS.FieldDefs.Clear
    Else
     Begin
       For J := 0 To DestDS.Fields.Count - 1 Do
        Begin
         vFieldDefinition.FieldName := DestDS.Fields[J].FieldName;
         vFieldDefinition.DataType  := DestDS.Fields[J].DataType;
         If (vFieldDefinition.DataType <> ftFloat) Then
          vFieldDefinition.Size     := DestDS.Fields[J].Size
         Else
          vFieldDefinition.Size         := 0;
         If (vFieldDefinition.DataType In [ftCurrency, ftBCD,
                                           {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                           {$IFEND}{$ENDIF} ftFMTBcd]) Then
          vFieldDefinition.Precision := TBCDField(DestDS.Fields[J]).Precision
         Else If (vFieldDefinition.DataType = ftFloat) Then
          vFieldDefinition.Precision := TFloatField(DestDS.Fields[J]).Precision;
         vFieldDefinition.Required   := DestDS.Fields[J].Required;
         vLocNewDataField(vFieldDefinition);
        End;
     End;
    For J := 0 To bJsonArrayB.ElementCount - 1 Do
     Begin
      bJsonOBJ := bJsonArrayB.GetObject(J);
      Try
       vTempValue := Trim(TDWJSONObject(bJsonOBJ).pairs[0].Value);
       If Trim(vTempValue) <> '' Then
        Begin
         FieldDef := FieldDefExist(DestDS, vTempValue);
         If (FieldDef = Nil) Then
          Begin
           If (vLocFieldExist(DestDS, vTempValue) = Nil) Then
            Begin
             vFieldDefinition.FieldName     := vTempValue;
             vFieldDefinition.DataType      := GetFieldType(TDWJSONObject(bJsonOBJ).pairs[1].Value);
             If (Not(vFieldDefinition.DataType in [ftFloat, ftCurrency, ftBCD, ftFMTBcd
                                                  {$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle{$IFEND}{$ENDIF}])) Then
              vFieldDefinition.Size         := StrToInt(TDWJSONObject(bJsonOBJ).pairs[4].Value)
             Else
              vFieldDefinition.Size         := 0;
             If (vFieldDefinition.DataType In [ftFloat, ftCurrency, ftBCD,
                                               {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                               {$IFEND}{$ENDIF} ftFMTBcd]) Then
              vFieldDefinition.Precision    := StrToInt(TDWJSONObject(bJsonOBJ).pairs[4].Value);
             vFieldDefinition.Required      := Uppercase(TDWJSONObject(bJsonOBJ).pairs[3].Value) = 'S';
             vLocNewDataField(vFieldDefinition);
            End;
           FieldDef          := DestDS.FieldDefs.AddFieldDef;
           If vEncoding = esUtf8 Then
            Begin
            {$IFDEF FPC}
             FieldDef.Name   := vTempValue;
            {$ELSE}
             FieldDef.Name   := UTF8Encode(vTempValue);
            {$ENDIF}
            End
           Else
            FieldDef.Name    := vTempValue;
           FieldDef.DataType := GetFieldType(TDWJSONObject(bJsonOBJ).pairs[1].Value);
           If not (FieldDef.DataType in [ftFloat, ftCurrency, ftBCD, ftFMTBcd
                                         {$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle{$IFEND}{$ENDIF}]) Then
            FieldDef.Size    := StrToInt(TDWJSONObject(bJsonOBJ).pairs[4].Value)
           Else
            FieldDef.Precision := StrToInt(TDWJSONObject(bJsonOBJ).pairs[4].Value);
           {$IFDEF FPC}
           If (FieldDef.DataType In [ftFloat, ftCurrency, ftBCD,
                                             {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                             {$IFEND}{$ENDIF} ftFMTBcd]) Then
            Begin
             FieldDef.Size      := StrToInt(TDWJSONObject(bJsonOBJ).pairs[4].Value);
             FieldDef.Precision := StrToInt(TDWJSONObject(bJsonOBJ).pairs[5].Value);
            End;
           {$ENDIF}
          End;
        End;
      Finally
       If Assigned(bJsonOBJ) Then
        FreeAndNil(bJsonOBJ);
      End;
     End;
    If Assigned(vFieldDefinition) Then
     FreeAndNil(vFieldDefinition);
    DestDS.FieldDefs.EndUpdate;
    Try
     vLocSetInBlockEvents(True);
     Inactive := True;
     If Assigned(vLocCreateDataSet) Then
      vLocCreateDataSet();
     If Not DestDS.Active Then
      DestDS.Open;
     If Not DestDS.Active Then
      Begin
       If Assigned(bJsonValue) Then
        FreeAndNil(bJsonValue);
       FreeAndNil(ListFields);
       Raise Exception.Create('Error on Parse JSON Data...');
       Exit;
      End;
    Except
     On E : Exception Do
      Raise Exception.Create(E.Message);
    End;
   If csDesigning in DestDS.ComponentState Then
    Begin
     //Clean Invalid Fields
     For A := DestDS.Fields.Count - 1 DownTo 0 Do
      Begin
       If DestDS.Fields[A].FieldKind = fkData Then
        Begin
         vFindFlag := False;
         For J := 0 To bJsonArrayB.ElementCount - 1 Do
          Begin
           bJsonOBJ := bJsonArrayB.GetObject(J);
           Try
            If Trim(TDWJSONObject(bJsonOBJ).pairs[0].Value) <> '' Then
             Begin
              vFindFlag := Lowercase(TDWJSONObject(bJsonOBJ).pairs[0].Value) = Lowercase(DestDS.Fields[A].FieldName);
              If vFindFlag Then
               Break;
             End;
           Finally
            If Assigned(bJsonOBJ) Then
             FreeAndNil(bJsonOBJ);
           End;
          End;
         If Not vFindFlag Then
          DestDS.Fields.Remove(DestDS.Fields[A]);
        End;
      End;
    End;
    //Add Set PK Fields
    For J := 0 To bJsonArrayB.ElementCount - 1 Do
     Begin
      bJsonOBJ := bJsonArrayB.GetObject(J);
      Try
       If Uppercase(Trim(TDWJSONObject(bJsonOBJ).pairs[2].Value)) = 'S' Then
        Begin
         Field := DestDS.FindField(TDWJSONObject(bJsonOBJ).pairs[0].Value);
         If Field <> Nil Then
          Begin
           If Field.FieldKind = fkData Then
            Field.ProviderFlags := [pfInUpdate, pfInWhere, pfInKey]
           Else
            Field.ProviderFlags := [];
           {$IFNDEF FPC}
            {$IF CompilerVersion > 21}
             If bJsonOBJ.PairCount > 6 Then
              Begin
               If (Uppercase(Trim(TDWJSONObject(bJsonOBJ).pairs[7].Value)) = 'S') Then
                Field.AutoGenerateValue := arAutoInc;
              End;
            {$IFEND}
           {$ENDIF}
           End;
        End;
      Finally
       If Assigned(bJsonOBJ) then
        FreeAndNil(bJsonOBJ);
      End;
     End;
    For A := 0 To DestDS.Fields.Count - 1 Do // ADICIONA REGISTRO
     Begin
      vFindFlag := False;
      If DestDS.FindField(DestDS.Fields[A].FieldName) <> Nil Then
       If DestDS.FindField(DestDS.Fields[A].FieldName).FieldKind = fkData Then
        Begin
         For J := 0 To bJsonArrayB.ElementCount - 1 Do
          Begin
           bJsonOBJ := bJsonArrayB.GetObject(J);
           If Trim(TDWJSONObject(bJsonOBJ).pairs[0].Value) <> '' Then
            Begin
             vFindFlag := Uppercase(Trim(TDWJSONObject(bJsonOBJ).pairs[0].Value)) = Uppercase(DestDS.Fields[A].FieldName);
             If vFindFlag Then
              Begin
               ListFields.Add(inttostr(J));
               If Assigned(bJsonOBJ) Then
                FreeAndNil(bJsonOBJ);
               Break;
              End;
            End;
           If Assigned(bJsonOBJ) then
            FreeAndNil(bJsonOBJ);
          End;
        End;
      If Not vFindFlag Then
       ListFields.Add('-1');
     End;
//    If Assigned(ListFields) then
//     FreeAndNil(ListFields);
    If vLocGetInDesignEvents() Then
     Begin
      vSetInDesignEvents := SetInDesignEvents;
      vSetInDesignEvents(False);
      Exit;
     End;
   End
  Else
   Begin
    For A := 0 To DestDS.Fields.Count - 1 Do // ADICIONA REGISTRO
     Begin
      vFindFlag := False;
      If DestDS.FindField(DestDS.Fields[A].FieldName) <> Nil Then
       If DestDS.FindField(DestDS.Fields[A].FieldName).FieldKind = fkData Then
        Begin
         For J := 0 To bJsonArrayB.ElementCount - 1 Do
          Begin
           bJsonOBJ := bJsonArrayB.GetObject(J);
           If Trim(TDWJSONObject(bJsonOBJ).pairs[0].Value) <> '' Then
            Begin
             vFindFlag := Uppercase(Trim(TDWJSONObject(bJsonOBJ).pairs[0].Value)) = Uppercase(DestDS.Fields[A].FieldName);
             If vFindFlag Then
              Begin
               ListFields.Add(inttostr(J));
               If Assigned(bJsonOBJ) then
                FreeAndNil(bJsonOBJ);
               Break;
              End;
            End;
           If Assigned(bJsonOBJ) Then
            FreeAndNil(bJsonOBJ);
          End;
        End;
      If Not vFindFlag Then
       ListFields.Add('-1');
     End;
    vActualBookmark := DestDS.GetBookmark;
   End;
  If Assigned(bJsonArrayB) then
   FreeAndNil(bJsonArrayB);
  bJsonOBJ    := bJsonArray.GetObject(1);
  bJsonArrayB := TDWJSONArray(TDWJSONArray(bJsonOBJ).GetObject(0));
  vLocSetInBlockEvents(True);
  JsonCount   := bJsonArrayB.ElementCount;
  If ((ActualRec + Datapacks) > (bJsonArrayB.ElementCount - 1)) Or (Datapacks = -1) Then
   vPageCount  := bJsonArrayB.ElementCount - 1
  Else
   vPageCount  := (ActualRec + Datapacks - 1);
  For J := ActualRec To vPageCount Do
   Begin
    bJsonOBJB := TDWJSONArray(bJsonArrayB).GetObject(J);
    bJsonOBJTemp := TDWJSONObject(bJsonOBJB).openArray(TDWJSONObject(bJsonOBJB).pairs[0].Name);
    DestDS.Append;
    Try
     For i := 0 To DestDS.Fields.Count - 1 Do
      Begin
       vOldReadOnly                := DestDS.Fields[i].ReadOnly;
       FieldValidate               := DestDS.Fields[i].OnValidate;
       DestDS.Fields[i].OnValidate := Nil;
       DestDS.Fields[i].ReadOnly   := False;
       If DestDS.Fields[i].FieldKind = fkLookup Then
        Begin
         DestDS.Fields[i].ReadOnly := vOldReadOnly;
         DestDS.Fields[i].OnValidate := FieldValidate;
         Continue;
        End;
       If (i >= ListFields.Count) Then
        Begin
         DestDS.Fields[i].ReadOnly := vOldReadOnly;
         DestDS.Fields[i].OnValidate := FieldValidate;
         Continue;
        End;
       If (StrToInt(ListFields[i])       = -1)     Or
          Not(DestDS.Fields[i].FieldKind = fkData) Or
          (StrToInt(ListFields[i]) = -1)           Then
        Begin
         DestDS.Fields[i].ReadOnly := vOldReadOnly;
         DestDS.Fields[i].OnValidate := FieldValidate;
         Continue;
        End;
       If Assigned(bJsonOBJB) Then
        FreeAndNil(bJsonOBJB);
       bJsonOBJB  := bJsonOBJTemp.GetObject(StrToInt(ListFields[i]));
       If TDWJSONObject(bJsonOBJB).pairs[0].isNull Then
        Continue;
       vTempValue := TDWJSONObject(bJsonOBJB).pairs[0].Value;
       If DestDS.Fields[i].DataType In [ftGraphic, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor,
                                        ftDataSet, ftBlob,
                                        ftOraBlob, ftOraClob{$IFNDEF FPC}{$IF CompilerVersion > 21},
                                        ftParams, ftStream{$IFEND}{$ENDIF}] Then
        Begin
         If (vTempValue <> 'null') And (vTempValue <> '') Then
          Begin
           //HexStringToStream(vTempValue, vBlobStream);
           vBlobStream := Decodeb64Stream(vTempValue);
           Try
            vBlobStream.Position := 0;
            TBlobField(DestDS.Fields[i]).LoadFromStream(vBlobStream);
           Finally
            {$IFNDEF FPC}
             {$IF CompilerVersion > 21}
              vBlobStream.Clear;
             {$IFEND}
            {$ENDIF}
            FreeAndNil(vBlobStream);
           End;
          End;
        End
       Else
        Begin
         If (Lowercase(vTempValue) <> 'null') Then
          Begin
          If DestDS.Fields[i].DataType in [ftString, ftWideString,
                                             {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,
                                            {$IFEND}{$ELSE}ftWideMemo,{$ENDIF}ftMemo, ftFmtMemo, ftFixedChar, ftGuid] Then
            Begin
             If vTempValue = '' Then
              DestDS.Fields[i].AsString := ''
             Else
              Begin
               If ((vEncoded) or
                   (DestDS.Fields[i].DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,
                                                  {$IFEND}{$ELSE}ftWideMemo,{$ENDIF}ftMemo, ftFmtMemo]))   And
                  (Not (DestDS.Fields[i].DataType = ftGuid))                             Then
                Begin
                 vTempValue := DecodeStrings(vTempValue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                 {$IFNDEF FPC}
                  {$IF CompilerVersion < 19}
                   If vEncoding = esUtf8 Then
                    vTempValue := UTF8Decode(vTempValue);
                  {$IFEND}
                 {$ENDIF}
                 DestDS.Fields[i].AsString := vTempValue;
                End
               Else
                Begin
                 If vUtf8SpecialChars Then
                  vTempValue := unescape_chars(vTempValue);
                 {$IFDEF FPC}
                 DestDS.Fields[i].AsString := GetStringDecode(vTempValue, DatabaseCharSet);
                 {$ELSE}
                 DestDS.Fields[i].AsString := vTempValue;
                 {$ENDIF}
                End;
              End;
            End
           Else If (vTempValue <> '') then
            SetValueA(DestDS.Fields[i], vTempValue);
          End;
        End;
       DestDS.Fields[i].ReadOnly := vOldReadOnly;
       DestDS.Fields[i].OnValidate := FieldValidate;
       If Assigned(bJsonOBJB) Then
        FreeAndNil(bJsonOBJB);
      End;
    Finally
     vTempValue := '';
    End;
    DestDS.Post;
    If Assigned(vOnWriterProcess) Then
     vOnWriterProcess(DestDS, J +1, vPageCount, AbortProcess);
    If Assigned(bJsonOBJTemp) Then
     FreeAndNil(bJsonOBJTemp);
    If Assigned(bJsonOBJB)    Then
     FreeAndNil(bJsonOBJB);
    If AbortProcess Then
     Break;
   End;
  If (Length(ServerFieldList) > 0) Then
   Begin
    For J := 0 To Length(ServerFieldList) -1 Do
     Begin
      If Assigned(ServerFieldList[J]) Then
       If Not (vLocFieldExist(DestDS, ServerFieldList[J].FieldName) = Nil) Then
        DestDS.FindField(ServerFieldList[J].FieldName).Required := ServerFieldList[J].Required;
     End;
   End;
 Finally
  If Assigned(bJsonOBJTemp) Then
   FreeAndNil(bJsonOBJTemp);
  {$IFNDEF FPC}
  If Assigned(bJsonOBJB)    Then
   FreeAndNil(bJsonOBJB);
  {$ENDIF}
  If Assigned(bJsonArrayB)  Then
   FreeAndNil(bJsonArrayB);
  If Assigned(bJsonArray)   Then
   FreeAndNil(bJsonArray);
  If Assigned(bJsonValue)   Then
   FreeAndNil(bJsonValue);
  If Assigned(bJsonOBJ)     Then   //Tem que ser o Ultimo a ser destruido
   FreeAndNil(bJsonOBJ);
  Try
   vLocSetInBlockEvents(False);
   vLocSetInitDataset(True);
   If (DestDS.Active) And (ActualRec = 0) Then
    Begin
     If Datapacks = -1 Then
      vLocSetRecordCount(vPageCount +1, vPageCount +1)
     Else
      vLocSetRecordCount(JsonCount, vPageCount +1);
     DestDS.First;
    End
   Else
    Begin
     vSetNotRepage := SetNotRepage;
     vSetNotRepage(True);
     DestDS.GotoBookmark(vActualBookmark);
    End;
   vPrepareDetails    := PrepareDetails;
   vPrepareDetailsNew := PrepareDetailsNew;
   If DestDS.State = dsBrowse Then
    Begin
     If DestDS.RecordCount = 0 Then
      vPrepareDetailsNew
     Else
      vPrepareDetails(True);
    End;
   vLocSetInitDataset(False);
  Finally
   If Assigned(ListFields) Then
    ListFields.Free;
  End;
  DestDS.EnableControls;
 End;
End;

procedure TJSONValue.WriteToDataset2(JSONValue: String; DestDS: TDataset);
Var
  FieldsValidate: Array of TFieldNotifyEvent;
  FieldsChange: Array of TFieldNotifyEvent;
  FieldsReadOnly: Array of Boolean;
  bJsonOBJB, bJsonOBJ, FieldJson: TDWJSONBase;
  bJsonValue: TDWJSONObject;
  bJsonOBJTemp, DataSetJson, FieldsJson, LinesJson: TDWJSONArray;
  J, I: Integer;
  FieldDef: TFieldDef;
  vBlobStream: TMemoryStream;
  vTempValue: String;
  sFieldName: string;
  //vFieldDefinition: TFieldDefinition;
  AbortProcess    : Boolean;
Begin
  vFieldDefinition := Nil;
  bJsonOBJB    := Nil;
  bJsonOBJ     := Nil;
  FieldJson    := Nil;
  bJsonValue   := Nil;
  bJsonOBJTemp := Nil;
  DataSetJson  := Nil;
  FieldsJson   := Nil;
  LinesJson    := Nil;
  vBlobStream  := Nil;
  AbortProcess := False;
  If JSONValue = '' Then
    Exit;
  Try
    If Pos('[', JSONValue) = 0 Then
      Exit;
    bJsonValue := TDWJSONObject.Create(JSONValue);
    If bJsonValue.PairCount > 0 Then Begin
      vTypeObject := GetObjectName(bJsonValue.pairs[0].Value);
      vObjectDirection := GetDirectionName(bJsonValue.pairs[1].Value);
      vEncoded := GetBooleanFromString(bJsonValue.pairs[2].Value);
      vObjectValue := GetValueType(bJsonValue.pairs[3].Value);
      vtagName := Lowercase(bJsonValue.pairs[4].Name);
      DestDS.DisableControls;
      If DestDS.Active Then
        DestDS.Close;
      DataSetJson := TDWJSONArray(bJsonValue.openArray(bJsonValue.pairs[4].Name));
      bJsonOBJ := DataSetJson.GetObject(0);
      FieldsJson := TDWJSONObject(bJsonOBJ).openArray(TDWJSONObject(bJsonOBJ).pairs[0].Name);
      FreeAndNil(bJsonOBJ);
      vFieldDefinition := TFieldDefinition.Create;
      If DestDS.Fields.Count = 0 Then
       DestDS.FieldDefs.Clear;
      For J := 0 To DestDS.Fields.Count - 1 Do
        DestDS.Fields[J].Required := False;
      DestDS.FieldDefs.BeginUpdate;
      if (not DestDS.Active) and (DestDS.FieldCount = 0) then begin
        For J := 0 To FieldsJson.ElementCount - 1 Do Begin
          FieldJson := FieldsJson.GetObject(J);
          Try
            sFieldName := Trim(TDWJSONObject(FieldJson).pairs[0].Value);
            If Trim(sFieldName) <> '' Then Begin
              FieldDef := DestDS.FieldDefs.AddFieldDef;
//              FieldDef.Name := sFieldName;
              If vEncoding = esUtf8 Then
               Begin
               {$IFDEF FPC}
                FieldDef.Name   := PWidechar(UTF8Decode(sFieldName));
               {$ELSE}
                FieldDef.Name   := UTF8Decode(sFieldName);
               {$ENDIF}
               End
              Else
               FieldDef.Name    := vTempValue;
              FieldDef.DataType := GetFieldType(TDWJSONObject(FieldJson).pairs[1].Value);
              If Not (FieldDef.DataType in [ftFloat,ftCurrency
                                          {$IFNDEF FPC}{$IF CompilerVersion > 21},ftExtended,ftSingle
                                          {$IFEND}{$ENDIF}]) Then
               FieldDef.Size     := StrToInt(TDWJSONObject(FieldJson).pairs[4].Value)
              Else
               FieldDef.Size     := 0;
              If (FieldDef.DataType In [ftCurrency, ftBCD,
                                                {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                                {$IFEND}{$ENDIF} ftFMTBcd]) Then
               FieldDef.Precision := StrToInt(TDWJSONObject(FieldJson).pairs[5].Value)
              Else If (FieldDef.DataType = ftFloat) Then
               FieldDef.Precision := StrToInt(TDWJSONObject(FieldJson).pairs[5].Value);
              FieldDef.Required := TDWJSONObject(FieldJson).pairs[3].Value = 'S';
            End;
          Finally
            FreeAndNil(FieldJson);
          End;
        End;
        if Assigned(vFieldDefinition) then
          FreeAndNil(vFieldDefinition);
        DestDS.FieldDefs.EndUpdate;
      end;

      If Not DestDS.Active Then
        DestDS.Open;
      If Not DestDS.Active Then Begin
        bJsonValue.Free;
        Raise Exception.Create('Error on Parse JSON Data...');
        Exit;
      End;

      {Reservando as propriedades ReadOnly, OnValidate e OnChange de cada TField}
      for I := 0 to DestDS.FieldCount - 1 do begin
        SetLength(FieldsValidate, Length(FieldsValidate) + 1);
        FieldsValidate[High(FieldsValidate)] := DestDS.Fields[I].OnValidate;
        DestDS.Fields[I].OnValidate := nil;

        SetLength(FieldsChange, Length(FieldsChange) + 1);
        FieldsValidate[High(FieldsChange)] := DestDS.Fields[I].OnChange;
        DestDS.Fields[I].OnChange := nil;

        SetLength(FieldsReadOnly, Length(FieldsReadOnly) + 1);
        FieldsReadOnly[High(FieldsReadOnly)] := DestDS.Fields[I].ReadOnly;
        DestDS.Fields[I].ReadOnly := False;
      end;

      {Loop no dataset}
      FreeAndNil(bJsonOBJ);
      bJsonOBJ := DataSetJson.GetObject(0);
      FreeAndNil(FieldsJson);
      FieldsJson := TDWJSONObject(bJsonOBJ).openArray(TDWJSONObject(bJsonOBJ).pairs[0].Name);

      FreeAndNil(bJsonOBJ);
      bJsonOBJ := FieldsJson.GetObject(0);
      FreeAndNil(LinesJson);
      bJsonOBJ := DataSetJson.GetObject(1);
      LinesJson := TDWJSONArray(TDWJSONArray(bJsonOBJ).GetObject(0));

      For J := 0 To LinesJson.ElementCount - 1 Do Begin
        bJsonOBJB := TDWJSONArray(LinesJson).GetObject(J);
        bJsonOBJTemp := TDWJSONObject(bJsonOBJB).openArray(TDWJSONObject(bJsonOBJB).pairs[0].Name);
        DestDS.Append;
        Try
          For I := 0 To FieldsJson.ElementCount - 1 Do Begin
            FieldJson := FieldsJson.GetObject(I);
            sFieldName := Trim(TDWJSONObject(FieldJson).pairs[0].Value);
            If Assigned(bJsonOBJB) Then
             FreeAndNil(bJsonOBJB);
            bJsonOBJB := bJsonOBJTemp.GetObject(I);
            if TDWJSONObject(bJsonOBJB).pairs[0].isnull then
             Begin
              FreeAndNil(bJsonOBJB);
              Continue;
             End;
            vTempValue := TDWJSONObject(bJsonOBJB).pairs[0].Value;
            If DestDS.FieldByName(sFieldName).DataType In [ftGraphic, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, ftDataSet, ftBlob,
              ftOraBlob, ftOraClob
{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftParams, ftStream{$IFEND}{$ENDIF}] Then
            Begin
              If (vTempValue <> 'null') And (vTempValue <> '') Then Begin
                //HexStringToStream(vTempValue, vBlobStream);
                vBlobStream := Decodeb64Stream(vTempValue);
                Try
                  vBlobStream.Position := 0;
                  TBlobField(DestDS.FieldByName(sFieldName)).LoadFromStream(vBlobStream);
                Finally
{$IFNDEF FPC}{$IF CompilerVersion > 21}
                  vBlobStream.Clear;
{$IFEND}{$ENDIF}
                  FreeAndNil(vBlobStream);
                End;
              End;
            End Else Begin
              If (Lowercase(vTempValue) <> 'null') Then Begin
                If DestDS.FieldByName(sFieldName).DataType in [ftString, ftWideString,{$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo, {$IFEND}{$ELSE}ftWideMemo,{$ENDIF}ftMemo, ftFmtMemo, ftFixedChar, ftGuid] Then Begin
                  If vTempValue = '' Then
                    DestDS.FieldByName(sFieldName).Value := ''
                  Else Begin
                    If vEncoded Then
                      DestDS.FieldByName(sFieldName).Value := DecodeStrings(vTempValue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                    Else
                      DestDS.FieldByName(sFieldName).Value := vTempValue;
                  End;
                End Else If (vTempValue <> '') then
                  SetValueA(DestDS.FieldByName(sFieldName), vTempValue);
              End;
            End;
            FreeAndNil(bJsonOBJB);
          End;
        Finally
          vTempValue := '';
        End;
        FreeAndNil(bJsonOBJTemp);
        FreeAndNil(bJsonOBJB);
        DestDS.Post;
        If Assigned(vOnWriterProcess) Then
         vOnWriterProcess(DestDS, J +1, LinesJson.ElementCount, AbortProcess);
        If AbortProcess Then
         Break;
      End;
      {Devolvendo as propriedades ReadOnly, OnValidate e OnChange de cada TField}
      for I := 0 to DestDS.FieldCount - 1 do begin
        DestDS.Fields[I].OnValidate := FieldsValidate[I];
        DestDS.Fields[I].OnChange := FieldsChange[I];
        DestDS.Fields[I].ReadOnly := FieldsReadOnly[I];
      end;
    End Else Begin
      DestDS.Close;
      Raise Exception.Create('Invalid JSON Data...');
    End;
  Finally
    FreeAndNil(bJsonOBJ);
    FreeAndNil(FieldsJson);
    FreeAndNil(DataSetJson);
    FreeAndNil(bJsonValue);
    If DestDS.Active Then
      DestDS.First;
    DestDS.EnableControls;
  End;
End;

Procedure TJSONValue.SaveToFile(FileName: String);
Var
 vStringStream : TStringStream;
 {$IFDEF FPC}
 vFileStream   : TFileStream;
 {$ELSE}
   {$IF CompilerVersion < 22} // Delphi 2010 pra cima
   vFileStream : TFileStream;
   {$IFEND}
 {$ENDIF}
Begin
 vStringStream := TStringStream.Create(ToJSON);
 Try
  {$IFDEF FPC}
  vStringStream.Position := 0;
  vFileStream   := TFileStream.Create(FileName, fmCreate);
  Try
   vFileStream.CopyFrom(vStringStream, vStringStream.Size);
  Finally
   vFileStream.Free;
  End;
  {$ELSE}
   {$IF CompilerVersion > 21} // Delphi 2010 pra cima
    vStringStream.Position := 0;
    vStringStream.SaveToFile(FileName);
   {$ELSE}
    vStringStream.Position := 0;
    vFileStream   := TFileStream.Create(FileName, fmCreate);
    Try
     vFileStream.CopyFrom(vStringStream, vStringStream.Size);
    Finally
     vFileStream.Free;
    End;
   {$IFEND}
  {$ENDIF}
 Finally
  vStringStream.Free;
 End;
End;

Procedure TJSONValue.SaveToStream(Const Stream : TMemoryStream;
                                  Binary : Boolean = False);
Var
 vTempStream : TMemoryStream;
Begin
 Try
  If Not Binary Then
   Stream.Write(aValue[0], Length(aValue))
  Else
   Begin
    If Not VarIsNull(Value) Then
     Begin
      vTempStream := Decodeb64Stream(Value);
      If Assigned(vTempStream) Then
       Begin
        Stream.CopyFrom(vTempStream, vTempStream.Size);
        FreeAndNil(vTempStream);
       End;
     End;
   End;
 Finally
  If Assigned(Stream) Then
   Stream.Position := 0;
 End;
End;

Procedure TJSONValue.LoadFromJSON(bValue: String);
Var
 bJsonValue    : TDWJSONObject;
 vTempValue    : String;
 vStringStream : TMemoryStream;
Begin
 vStringStream := Nil;
 vTempValue    := StringReplace(bValue, sLineBreak, '', [rfReplaceAll]);
 bJsonValue    := TDWJSONObject.Create(vTempValue);
// {$IF DEFINED(iOS) or DEFINED(ANDROID)}
// SaveLog(vTempValue, 'json2.txt');
// {$ENDIF}
 Try
  If bJsonValue.PairCount > 0 Then
   Begin
    vNullValue := False;
    vTempValue := CopyValue(bValue);
    vTypeObject := GetObjectName(bJsonValue.pairs[0].Value);
    vObjectDirection := GetDirectionName(bJsonValue.pairs[1].Value);
    vObjectValue := GetValueType(bJsonValue.pairs[3].Value);
    vtagName := Lowercase(bJsonValue.pairs[4].Name);
    If vTypeObject = toDataset Then
     Begin
      If vTempValue[InitStrPos] = '[' Then
       Delete(vTempValue, 1, 1);
      If vTempValue[Length(vTempValue) - FinalStrPos] = ']' Then
       Delete(vTempValue, Length(vTempValue), 1);
     End;
    If vEncoded Then
     Begin
      If vObjectValue In [ovBytes, ovVarBytes, ovStream, ovBlob, ovGraphic, ovOraBlob, ovOraClob] Then
       Begin
//        vStringStream := TMemoryStream.Create;
        Try
         vStringStream := Decodeb64Stream(vTempValue); // HexToStream(vTempValue, vStringStream);
         aValue := TIdBytes(StreamToBytes(vStringStream));
        Finally
         vStringStream.Free;
        End;
       End
      Else
       vTempValue := DecodeStrings(vTempValue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
     End;
    If Not(vObjectValue In [ovBytes, ovVarBytes, ovStream, ovBlob, ovGraphic, ovOraBlob, ovOraClob]) Then
     SetValue(vTempValue, vEncoded)
    Else
     Begin
//      vStringStream := TMemoryStream.Create;
      Try
       vStringStream := Decodeb64Stream(vTempValue); // HexToStream(vTempValue, vStringStream);
       aValue := TIdBytes(StreamToBytes(vStringStream));
      Finally
       FreeAndNil(vStringStream);
      End;
     End;
   End;
 Finally
  bJsonValue.Free;
 End;
End;

Procedure TJSONValue.LoadFromJSON(bValue         : String;
                                  JsonModeD      : TJsonMode);
Var
 bJsonValue    : TDWJSONObject;
Begin
 bJsonValue    := TDWJSONObject.Create(StringReplace(bValue, sLineBreak, '', [rfReplaceAll]));
 Try
  If bJsonValue.PairCount > 0 Then
   Begin
    vTypeObject      := toObject;
    vObjectDirection := odINOUT;
    vObjectValue     := ovString;
    vtagName         := 'jsonpure';
    vNullValue       := ((bValue = '') or (bValue= 'null'));
    SetValue(bValue, vEncoded);
   End;
 Finally
  bJsonValue.Free;
 End;
End;

Procedure TJSONValue.LoadFromStream(Stream : TMemoryStream;
                                    Encode : Boolean = True);
Begin
 ObjectValue := ovBlob;
 vBinary := True;
 If Stream <> Nil Then
  SetValue(Encodeb64Stream(Stream), Encode); //StreamToHex(Stream), Encode);
End;

Function TJSONValue.GetNewDataField : TNewDataField;
Begin
 Result := Nil;
 If Assigned(vNewDataField) Then
  Result := vNewDataField
 Else
  Begin
   {$IFDEF FPC}
    Result := @aNewDataField;
   {$ELSE}
    Result := aNewDataField;
   {$ENDIF}
  End;
End;

Procedure TJSONValue.aNewDataField(FieldDefinition : TFieldDefinition);
Begin

End;

Procedure TJSONValue.aNewFieldList;
Begin

End;

Function TJSONValue.GetNewFieldList : TProcedureEvent;
Begin
 Result := Nil;
 If Assigned(vNewFieldList) Then
  Result := vNewFieldList
 Else
  Begin
   {$IFDEF FPC}
    Result := @aNewFieldList;
   {$ELSE}
    Result := aNewFieldList;
   {$ENDIF}
  End;
End;

Procedure TJSONValue.aPrepareDetails(ActiveMode : Boolean);
Begin

End;

Procedure TJSONValue.aPrepareDetailsNew;
Begin

End;

Procedure TJSONValue.StringToBytes(Value  : String;
                                   Encode : Boolean = False);
Var
 Stream: TStringStream;
Begin
 If Value <> '' Then
  Begin
   ObjectValue := ovBlob;
   vBinary     := True;
   vEncoded    := Encode;
   Stream      := TStringStream.Create(Value);
   Try
    Stream.Position := 0;
    SetValue(Encodeb64Stream(Stream), Encode); // StreamToHex(Stream), Encode);
   Finally
    Stream.Free;
   End;
  End;
End;

Procedure TJSONValue.SetEncoding(bValue : TEncodeSelect);
Begin
 vEncoding := bValue;
 {$IFDEF FPC}
  Case vEncoding Of
   esASCII : vEncodingLazarus := TEncoding.ANSI;
   esUtf8  : vEncodingLazarus := TEncoding.Utf8;
  End;
 {$ENDIF}
End;

Procedure TJSONValue.aSetInactive(Const Value : Boolean);
Begin
 vInactive := Value;
End;

Procedure TJSONValue.SetFieldsList(Value : TFieldsList);
Var
 I : Integer;
Begin
 ClearFieldList;
 SetLength(vFieldsList, Length(Value));
 For I := 0 To Length(Value) -1 Do
  Begin
   vFieldsList[I]           := TFieldDefinition.Create;
   vFieldsList[I].FieldName := Value[I].FieldName;
   vFieldsList[I].DataType  := Value[I].DataType;
   vFieldsList[I].Size      := Value[I].Size;
   vFieldsList[I].Precision := Value[I].Precision;
   vFieldsList[I].Required  := Value[I].Required;
  End;
End;

Procedure TJSONValue.ExecSetInactive  (Value       : Boolean);
Var
 vLocSetInactive : TSetInitDataset;
Begin
 vLocSetInactive := SetInactive;
 vLocSetInactive(Value);
End;

Function TJSONValue.GetPrepareDetails              : TPrepareDetails;
Begin
 Result := Nil;
 If Assigned(vPrepareDetails) Then
  Result := vPrepareDetails
 Else
  Begin
   {$IFDEF FPC}
    Result := @aPrepareDetails;
   {$ELSE}
    Result := aPrepareDetails;
   {$ENDIF}
  End;
End;

Function TJSONValue.GetPrepareDetailsNew           : TProcedureEvent;
Begin
 Result := Nil;
 If Assigned(vPrepareDetailsNew) Then
  Result := vPrepareDetailsNew
 Else
  Begin
   {$IFDEF FPC}
    Result := @aPrepareDetailsNew;
   {$ELSE}
    Result := aPrepareDetailsNew;
   {$ENDIF}
  End;
End;

Function  TJSONValue.GetGetInDesignEvents           : TGetInDesignEvents;
Begin
 Result := Nil;
 If Assigned(vGetInDesignEvents) Then
  Result := vGetInDesignEvents
 Else
  Begin
   {$IFDEF FPC}
    Result := @aGetInDesignEvents;
   {$ELSE}
    Result := aGetInDesignEvents;
   {$ENDIF}
  End;
End;

Function  TJSONValue.GetFieldListCount              : TFieldListCount;
Begin
 Result := Nil;
 If Assigned(vFieldListCount) Then
  Result := vFieldListCount
 Else
  Begin
   {$IFDEF FPC}
    Result := @aFieldListCount;
   {$ELSE}
    Result := aFieldListCount;
   {$ENDIF}
  End;
End;

Function  TJSONValue.GetSetInactive                 : TSetInitDataset;
Begin
 Result := Nil;
 If Assigned(vSetInactive) Then
  Result := vSetInactive
 Else
  Begin
   {$IFDEF FPC}
    Result := @aSetInactive;
   {$ELSE}
    Result := aSetInactive;
   {$ENDIF}
  End;
End;

Function  TJSONValue.GetSetInBlockEvents            : TSetInitDataset;
Begin
 Result := Nil;
 If Assigned(vSetInBlockEvents) Then
  Result := vSetInBlockEvents
 Else
  Begin
   {$IFDEF FPC}
    Result := @aSetInBlockEvents;
   {$ELSE}
    Result := aSetInBlockEvents;
   {$ENDIF}
  End;
End;

Procedure TJSONValue.aSetInBlockEvents (Const Value : Boolean);
Begin
 vInBlockEvents := Value;
End;

Function  TJSONValue.GetSetInDesignEvents           : TSetInitDataset;
Begin
 Result := Nil;
 If Assigned(vSetInDesignEvents) Then
  Result := vSetInDesignEvents
 Else
  Begin
   {$IFDEF FPC}
    Result := @aSetInDesignEvents;
   {$ELSE}
    Result := aSetInDesignEvents;
   {$ENDIF}
  End;
End;

Procedure TJSONValue.aSetInDesignEvents(Const Value : Boolean);
Begin

End;

Function  TJSONValue.GetSetInitDataset : TSetInitDataset;
Begin
 Result := Nil;
 If Assigned(vSetInitDataset) Then
  Result := vSetInitDataset
 Else
  Begin
   {$IFDEF FPC}
    Result := @aSetInitDataset;
   {$ELSE}
    Result := aSetInitDataset;
   {$ENDIF}
  End;
End;

Procedure TJSONValue.aSetInitDataset   (Const Value : Boolean);
Begin

End;

Function TJSONValue.GetSetnotrepage                : TSetnotrepage;
Begin
 Result := Nil;
 If Assigned(vSetnotrepage) Then
  Result := vSetnotrepage
 Else
  Begin
   {$IFDEF FPC}
    Result := @aSetnotrepage;
   {$ELSE}
    Result := aSetnotrepage;
   {$ENDIF}
  End;
End;

Procedure TJSONValue.aSetnotrepage     (Value       : Boolean);
Begin

End;

Function  TJSONValue.GetSetRecordCount            : TSetRecordCount;
Begin
 Result := Nil;
 If Assigned(vSetRecordCount) Then
  Result := vSetRecordCount
 Else
  Begin
   {$IFDEF FPC}
    Result := @aSetRecordCount;
   {$ELSE}
    Result := aSetRecordCount;
   {$ENDIF}
  End;
End;

Procedure TJSONValue.aSetRecordCount(aJsonCount,
                                     aRecordCount : Integer);
Begin

End;

Procedure TJSONValue.SetValue(Value  : Variant;
                              Encode : Boolean);
Begin
 vEncoded   := Encode;
 vNullValue := VarIsNull(Value);
 If vObjectValue in [ovDate, ovTime, ovDateTime, ovTimeStamp] then     // ajuste massive
  Begin
   If VarIsStr(Value) Then
    Begin
     If (Value = '') Then
      Begin
       WriteValue(Null);
       Value := Null;
      End
     Else
      Begin
       If (Pos(',', Value) > 0) Or
          (Pos('.', Value) > 0) Then
        Value := StrToFloat(Value)
       Else
        Value := StrToDateTime(Value);
      End;
    End;
   If (Not (vNullValue)) Then
    Value := IntToStr(DateTimeToUnix(Value))
  End;
 If Encode Then
  Begin
   If Not vNullValue Then
    Begin
     If vObjectValue in [ovBytes, ovVarBytes, ovStream, ovBlob, ovGraphic, ovOraBlob, ovOraClob] Then
      Begin
       vBinary := True;
       WriteValue(Value);
      End
     Else
      Begin
       vBinary := False;
       WriteValue(EncodeStrings(Value{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}))
      End;
    End
   Else
    WriteValue(Null);
  End
 Else
  Begin
   If Not vNullValue Then
    Begin
     If vObjectValue in [ovBytes, ovVarBytes, ovStream, ovBlob, ovGraphic, ovOraBlob, ovOraClob] Then
      Begin
       vBinary := True;
       WriteValue(Value);
      End
     Else
      Begin
       vBinary := False;
       WriteValue(Value);
      End;
    End
   Else
    WriteValue(Null);
  End;
End;

Procedure TJSONValue.WriteValue(bValue : Variant);
{$IFNDEF FPC}
{$IF CompilerVersion < 26}
Var
 vValueAnsi : AnsiString;
{$IFEND}
{$ENDIF}
Begin
 SetLength(aValue, 0);
 If VarIsNull(bValue) Then
  Begin
   vNullValue := True;
   Exit;
  End
 Else
  Begin
   vNullValue := False;
   If ((bValue = '') or (bValue = 'null')) Then
    Begin
     If Not vNullValue Then
      vNullValue := Not(vObjectValue in [ovString, ovGuid, ovMemo, ovWideMemo, ovFmtMemo]);
     Exit;
    End
   Else
    vNullValue := False;
   If vObjectValue in [ovString, ovGuid, ovMemo, ovWideMemo, ovFmtMemo, ovObject, ovDataset] Then
    Begin
     {$IFDEF FPC}
     If vEncodingLazarus = Nil Then
      SetEncoding(vEncoding);
     If vEncoded Then
      Begin
       If vEncoding = esUtf8 Then
        aValue := TIdBytes(vEncodingLazarus.GetBytes(Format(TJsonStringValue, [bValue])))
       Else
        aValue := ToBytes(Format(TJsonStringValue, [bValue]), GetEncodingID(vEncoding))
      End
     Else
      Begin
       If ((JsonMode = jmDataware) And (vEncoded)) Or Not(vObjectValue = ovObject) Then
        Begin
         If vEncoding = esUtf8 Then
          aValue := TIdBytes(vEncodingLazarus.GetBytes(Format(TJsonStringValue, [bValue])))
         Else
          aValue := ToBytes(Format(TJsonStringValue, [bValue]), GetEncodingID(vEncoding));
        End
       Else
        Begin
         If vEncoding = esUtf8 Then
          aValue := TIdBytes(vEncodingLazarus.GetBytes(bValue))
         Else
          aValue := ToBytes(String(bValue), GetEncodingID(vEncoding));
        End;
      End;
     {$ELSE}
     If vEncoded Then
      Begin
//       {$IF CompilerVersion > 25} // Delphi 2010 pra cima
       aValue := ToBytes(Format(TJsonStringValue, [bValue]){$IFDEF INDY_NEW}, GetEncodingID(vEncoding){$ENDIF});
//       {$ELSE} // Delphi 2010 pra cima
//        vValueAnsi := Format(TJsonStringValue, [bValue]);
//        SetLength(aValue, Length(vValueAnsi));
//        move(vValueAnsi[InitStrPos], pByteArray(aValue)^, Length(aValue));
//       {$IFEND}
//       aValue := ToBytes(Format(TJsonStringValue, [bValue]), GetEncodingID(vEncoding));
      End
     Else
      Begin
       If ((JsonMode = jmDataware) And (vEncoded)) Or
          Not(vObjectValue = ovObject) Then
        aValue := ToBytes(Format(TJsonStringValue, [bValue]){$IFDEF INDY_NEW}, GetEncodingID(vEncoding){$ENDIF})
       Else
        aValue := ToBytes(String(bValue){$IFDEF INDY_NEW}, GetEncodingID(vEncoding){$ENDIF});
      End;
     {$ENDIF}
    End
   Else If vObjectValue in [ovDate, ovTime, ovDateTime, ovTimeStamp, ovOraTimeStamp, ovTimeStampOffset] Then
    Begin
     {$IFDEF FPC}
      If vEncoding = esUtf8 Then
       aValue := TIdBytes(vEncodingLazarus.GetBytes(Format(TJsonStringValue, [bValue])))
      Else
       aValue := ToBytes(Format(TJsonStringValue, [bValue]), GetEncodingID(vEncoding));
     {$ELSE}
      aValue := ToBytes(Format(TJsonStringValue, [bValue]){$IFDEF INDY_NEW}, GetEncodingID(vEncoding){$ENDIF});
     {$ENDIF}
    End
   Else If vObjectValue in [ovSingle, ovFloat, ovCurrency, ovBCD, ovFMTBcd, ovExtended] Then
    Begin
     {$IFDEF FPC}
      If vEncoding = esUtf8 Then
       aValue := TIdBytes(vEncodingLazarus.GetBytes(Format(TJsonStringValue, [bValue])))
      Else
       aValue := ToBytes(Format(TJsonStringValue, [bValue]), GetEncodingID(vEncoding));
     {$ELSE}
      aValue := ToBytes(Format(TJsonStringValue, [bValue]){$IFDEF INDY_NEW}, GetEncodingID(vEncoding){$ENDIF});
     {$ENDIF}
    End
   Else
    Begin
     If bValue <> 'null' Then
      Begin
      {$IFDEF FPC}
       If vEncoding = esUtf8 Then
        aValue := TIdBytes(vEncodingLazarus.GetBytes(bValue))
       Else
        aValue := ToBytes(String(bValue), GetEncodingID(vEncoding));
      {$ELSE}
       {$IF CompilerVersion > 21} // Delphi 2010 pra cima
        aValue := ToBytes(String(bValue){$IFDEF INDY_NEW}, GetEncodingID(vEncoding){$ENDIF});
       {$ELSE} // Delphi 2010 pra cima
        vValueAnsi := bValue;
        SetLength(aValue, Length(vValueAnsi));
        move(vValueAnsi[InitStrPos], pByteArray(aValue)^, Length(aValue));
       {$IFEND}
      {$ENDIF}
      End;
    End;
  End;
End;

Procedure TJSONParam.Clear;
Begin
 vNullValue            := True;
 If vJSONValue <> Nil Then
  Begin
   vJSONValue.vNullValue := vNullValue;
   SetValue('');
  End;
End;

Procedure TJSONParam.Assign(Source : TObject);
Var
 Src     : TJSONParam;
 aStream : TMemoryStream;
Begin
 If Source Is TJSONParam Then
  Begin
   Src                    := TJSONParam(Source);
   vJsonMode              := Src.JsonMode;
   vEncoded               := Src.Encoded;
   vJSONValue.JsonMode    := Src.vJsonMode;
   vJSONValue.vEncoded    := Src.vEncoded;
   vBinary                := Src.vObjectValue in [ovStream, ovBlob, ovGraphic, ovOraBlob, ovOraClob];
   vJSONValue.ObjectValue := Src.vObjectValue;
   If vJSONValue.ObjectValue in [ovBlob, ovStream, ovBytes] Then
    Begin
     aStream := TMemoryStream.Create;
     Try
      Src.SaveToStream(aStream);
      aStream.Position := 0;
      LoadFromStream(aStream);
     Finally
      FreeAndNil(aStream);
     End;
    End
   Else
    Value := Src.Value;
  End
 Else
  Raise Exception.Create(cInvalidDWParam);
End;

Constructor TJSONParam.Create(Encoding : TEncodeSelect);
Begin
 vJSONValue          := TJSONValue.Create;
 vCripto             := TCripto.Create;
 vJsonMode           := jmDataware;
 vEncoding           := Encoding;
 vTypeObject         := toParam;
 ObjectDirection     := odINOUT;
 vObjectValue        := ovString;
 vBinary             := False;
 vJSONValue.vBinary  := vBinary;
 vNullValue          := Not vBinary;
 vEncoded            := True;
 vAlias              := '';
 vFloatDecimalFormat := '';
 vParamName          := '';
 vParamFileName      := '';
 vParamContentType   := '';
// vDefaultValue    : Variant;
 {$IFDEF FPC}
  vDatabaseCharSet  := csUndefined;
 {$ENDIF}
End;

Destructor TJSONParam.Destroy;
Begin
 Clear;
 If vJSONValue <> Nil Then
  FreeAndNil(vJSONValue);
 If vCripto <> Nil Then
  FreeAndNil(vCripto);
 Inherited;
End;

Procedure TJSONParam.SaveFromParam(Param : TParam);
Var
 ms : TMemoryStream;
Begin
 If Not Assigned(Param) Then
  Exit;
 If IsNull Then
  Param.Clear;
 If vObjectValue in [ovBlob, ovStream, ovBytes] Then
  Begin
   ms := TMemoryStream.Create;
   Try
    SaveToStream(ms);
    ms.Position := 0;
    Param.LoadFromStream(ms, ftBlob);
   Finally
    ms.Free;
   End;
  End
 Else
  Param.Value := Value;
End;

Procedure TJSONParam.LoadFromParam(Param : TParam);
Var
 MemoryStream : TMemoryStream;
 {$IFNDEF FPC}{$IF CompilerVersion > 21}MemoryStream2 : TStream;{$IFEND}{$ENDIF}
Begin
 If TestNilParam Then
  Exit;
 MemoryStream := Nil;
 If Param.IsNull Then
  Begin
   vNullValue := True;
   SetValue('');
  End
 Else If Param.DataType in [ftString, ftWideString, ftMemo, ftGuid,
                      {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,{$IFEND}{$ELSE}ftWideMemo,{$ENDIF}
                       ftFmtMemo, ftFixedChar] Then
  Begin
   vEncoded := Not (Param.DataType in [ftMemo, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,{$IFEND}{$ELSE}ftWideMemo,{$ENDIF}
                                       ftFmtMemo]);
   SetValue(Param.AsString, vEncoded);
   vEncoded := True;
  End
 Else If Param.DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongword, ftExtended, ftSingle,{$IFEND}{$ENDIF}
                            ftAutoInc, ftInteger, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftShortint, {$IFEND}{$ENDIF}
                            ftSmallint, ftLargeint, ftFloat, ftCurrency, ftFMTBcd, ftBCD] Then
  SetValue(BuildStringFloat(Param.AsString, JsonMode, vFloatDecimalFormat), False)
 Else If Param.DataType In [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] Then
  Begin
   MemoryStream := TMemoryStream.Create;
   Try
    {$IFDEF FPC}
     Param.SetData(MemoryStream);
    {$ELSE}
     {$IF CompilerVersion > 21}
      MemoryStream2 := Param.AsStream;
      MemoryStream.CopyFrom(MemoryStream2, -1);
      If Assigned(MemoryStream2) Then
       FreeAndNil(MemoryStream2);
     {$ELSE}
      Param.SetData(MemoryStream);
     {$IFEND}
    {$ENDIF}
    LoadFromStream(MemoryStream);
    vEncoded := False;
   Finally
    MemoryStream.Free;
   End;
  End
 Else If Param.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
  Begin
   If Param.DataType = ftDate Then
    SetValue(inttostr(DateTimeToUnix(Param.AsDate)), False)
   Else if Param.DataType = ftTime then
    SetValue(inttostr(DateTimeToUnix(Param.AsTime)), False)
   Else
    SetValue(inttostr(DateTimeToUnix(Param.AsDateTime)), False);
  End
 Else If Param.DataType in [ftBoolean] Then
  SetValue(GetStringFromBoolean(Param.AsBoolean), False);
 vObjectValue := FieldTypeToObjectValue(Param.DataType);
 vParamName   := Param.Name;
 vEncoded     := vObjectValue in [ovString, ovGuid, ovWideString, ovBlob, ovStream, ovGraphic, ovOraBlob, ovOraClob];
 vJSONValue.vObjectValue := vObjectValue;
End;

Procedure TJSONParam.LoadFromStream   (Stream   : TStringStream;
                                       Encode   : Boolean = True);
Var
 vStream : TMemoryStream;
Begin
 If TestNilParam Then
  Exit;
 vStream := TMemoryStream.Create;
 Try
  If Assigned(Stream) Then
   Begin
    vStream.CopyFrom(Stream, Stream.Size);
    vStream.Position := 0;
    LoadFromStream(vStream, Encode);
   End;
 Finally
  vStream.Free;
 End;
End;

Procedure TJSONParam.LoadFromStream(Stream : TMemoryStream;
                                    Encode : Boolean);
Begin
 If TestNilParam Then
  Exit;
 ObjectValue       := ovBlob;
 vEncoded          := True;
 SetValue(Encodeb64Stream(Stream), vEncoded); // StreamToHex(Stream), vEncoded);
 vBinary           := True;
 vJSONValue.Binary := vBinary;
End;

Procedure TJSONParam.FromJSON(json    : String);
Var
 bJsonValue : TDWJSONObject;
 vValue     : String;
Begin
 If TestNilParam Then
  Exit;
 If Pos(sLineBreak, json) > 0 Then
  vValue     := StringReplace(json, sLineBreak, '', [rfReplaceAll])
 Else
  vValue     := json;
 {$IFDEF FPC}
  If vEncoding = esUtf8 Then
   bJsonValue    := TDWJSONObject.Create(PWidechar(UTF8Decode(vValue)))
  Else
   bJsonValue    := TDWJSONObject.Create(vValue);
 {$ELSE}
  bJsonValue    := TDWJSONObject.Create(vValue);
 {$ENDIF}
 Try
  vValue := CopyValue(vValue);
  If bJsonValue.PairCount > 0 Then
   Begin
    vTypeObject        := GetObjectName       (bJsonValue.Pairs[0].Value);
    vObjectDirection   := GetDirectionName    (bJsonValue.Pairs[1].Value);
    vEncoded           := GetBooleanFromString(bJsonValue.Pairs[2].Value);
    vObjectValue       := GetValueType        (bJsonValue.Pairs[3].Value);
    vParamName         := Lowercase           (bJsonValue.Pairs[4].name);
    If vObjectValue = ovGuid Then
     vValue            := DecodeStrings(vValue{$IFDEF FPC}, csUndefined{$ENDIF});
    WriteValue(vValue);
    vBinary            := vObjectValue in [ovBytes, ovVarBytes, ovStream, ovBlob, ovGraphic, ovOraBlob, ovOraClob];
    vJSONValue.vBinary := vBinary;
   End;
 Finally
  bJsonValue.Free;
 End;
End;

Procedure TJSONParam.CopyFrom(JSONParam : TJSONParam);
Var
 vValue  : String;
 vStream : TMemoryStream;
Begin
 If TestNilParam Then
  Exit;
 Try
  Self.vTypeObject      := JSONParam.vTypeObject;
  Self.vObjectDirection := JSONParam.vObjectDirection;
  Self.vEncoded         := JSONParam.vEncoded;
  Self.vObjectValue     := JSONParam.vObjectValue;
  Self.vParamName       := JSONParam.vParamName;
  If JSONParam.ObjectValue in [ovBytes, ovVarBytes, ovStream, ovBlob, ovGraphic, ovOraBlob, ovOraClob] Then
   Begin
    vStream := TMemoryStream.Create;
    Try
     JSONParam.SaveToStream(vStream);
     vStream.Position := 0;
     LoadFromStream(vStream);
    Finally
     FreeAndNil(vStream);
    End;
   End
  Else
   Begin
    vValue                := JSONParam.Value;
    Self.SetValue(vValue, Self.vEncoded);
   End;
 Finally
 End;
End;

Procedure TJSONParam.SaveToFile(FileName: String);
Var
 vStringStream : TStringStream;
 {$IFDEF FPC}
 vFileStream   : TFileStream;
 {$ELSE}
   {$IF CompilerVersion < 22} // Delphi 2010 pra cima
   vFileStream : TFileStream;
   {$IFEND}
 {$ENDIF}
Begin
 If TestNilParam Then
  Exit;
 vStringStream := TStringStream.Create(ToJSON);
 Try
  {$IFDEF FPC}
  vStringStream.Position := 0;
  vFileStream   := TFileStream.Create(FileName, fmCreate);
  Try
   vFileStream.CopyFrom(vStringStream, vStringStream.Size);
  Finally
   vFileStream.Free;
  End;
  {$ELSE}
   {$IF CompilerVersion > 21} // Delphi 2010 pra cima
    vStringStream.Position := 0;
    vStringStream.SaveToFile(FileName);
   {$ELSE}
    vStringStream.Position := 0;
    vFileStream   := TFileStream.Create(FileName, fmCreate);
    Try
     vFileStream.CopyFrom(vStringStream, vStringStream.Size);
    Finally
     vFileStream.Free;
    End;
   {$IFEND}
  {$ENDIF}
 Finally
  vStringStream.Free;
 End;
End;

Procedure TJSONParam.SaveToStream(Var Stream   : TStringStream);
Var
 vStream : TMemoryStream;
Begin
 If TestNilParam Then
  Exit;
 vStream := Nil;
 SaveToStream(vStream);
 Try
  If Assigned(vStream) Then
   Begin
    If Assigned(Stream) Then
     Begin
      vStream.Position := 0;
      Stream.CopyFrom(vStream, vStream.Size);
      Stream.Position := 0;
     End;
   End;
 Finally
  If Assigned(vStream) Then
   vStream.Free;
 End;
End;

Procedure TJSONParam.SaveToStream(Var Stream: TMemoryStream);
Begin
 If TestNilParam Then
  Exit;
 If Assigned(Stream) Then
  FreeAndNil(Stream);
 Stream := Decodeb64Stream(GetAsString); // HexToStream(GetAsString, Stream);
End;

{$IFDEF DEFINE(FPC) Or NOT(DEFINE(POSIX))}
Procedure TJSONParam.SetAsAnsiString(Value: AnsiString);
Begin
 {$IFDEF FPC}
  SetDataValue(Value, ovString);
 {$ELSE}
  {$IF CompilerVersion > 21} // Delphi 2010 pra cima
   SetDataValue(Utf8ToAnsi(Value), ovString);
  {$ELSE}
   SetDataValue(Value, ovString);
  {$IFEND}
 {$ENDIF}
End;
{$ENDIF}

Procedure TJSONParam.SetAsBCD     (Value : Currency);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, ovBCD);
End;

Procedure TJSONParam.SetAsBoolean (Value : Boolean);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, ovBoolean);
End;

Procedure TJSONParam.SetAsCurrency(Value : Currency);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, ovCurrency);
End;

Procedure TJSONParam.SetAsDate    (Value : TDateTime);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, ovDate);
End;

Procedure TJSONParam.SetAsDateTime(Value : TDateTime);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, ovDateTime);
End;

Procedure TJSONParam.SetAsFloat   (Value : Double);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, ovFloat);
End;

Procedure TJSONParam.SetAsFMTBCD  (Value : Currency);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, ovFMTBcd);
End;

Procedure TJSONParam.SetAsInteger (Value : Integer);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, ovInteger);
End;

Procedure TJSONParam.SetAsLargeInt(Value : LargeInt);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, ovLargeInt);
End;

Procedure TJSONParam.SetAsLongWord(Value : LongWord);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, ovLongWord);
End;

Procedure TJSONParam.SetAsObject  (Value : String);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, ovObject);
End;

Procedure TJSONParam.SetAsShortInt(Value : Integer);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, ovShortInt);
End;

Procedure TJSONParam.SetAsSingle  (Value : Single);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, ovSmallInt);
End;

Procedure TJSONParam.SetAsSmallInt(Value : Integer);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, ovSmallInt);
End;

Procedure TJSONParam.SetAsString  (Value : String);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, ovString);
End;

Procedure TJSONParam.SetAsTime    (Value : TDateTime);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, ovTime);
End;

{$IFDEF DEFINE(FPC) Or NOT(DEFINE(POSIX))}
Procedure TJSONParam.SetAsWideString(Value    : WideString);
Begin
 SetDataValue(Value, ovWideString);
End;
{$ENDIF}

Procedure TJSONParam.SetAsWord      (Value    : Word);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, ovWord);
End;

Procedure TJSONParam.SetDataValue   (Value    : Variant;
                                     DataType : TObjectValue);
Var
 ms        : TMemoryStream;
 p         : Pointer;
 vDateTime : TDateTime;
Begin
 If TestNilParam Then
  Exit;
 ms := Nil;
 If (VarIsNull(Value))  Or
    (VarIsEmpty(Value)) Or
    (DataType in [ovBytes,    ovVarBytes,    ovStream, ovBlob, ovByte, ovGraphic, ovParadoxOle,
                  ovDBaseOle, ovTypedBinary, ovOraBlob,      ovOraClob]) Then
  Exit;
 vObjectValue   := DataType;
 Case vObjectValue Of
  ovBytes,
  ovVarBytes,
  ovBlob,
  ovByte,
  ovGraphic,
  ovParadoxOle,
  ovDBaseOle,
  ovTypedBinary,
  ovOraBlob,
  ovOraClob,
  ovStream          : Begin
                       ms := TMemoryStream.Create;
                       Try
                        ms.Position := 0;
                        p           := VarArrayLock(Value);
                        ms.Write(p^, VarArrayHighBound(Value, 1));
                        VarArrayUnlock(Value);
                        ms.Position := 0;
                        If ms.Size > 0 Then
                         LoadFromStream(ms);
                       Finally
                        ms.Free;
                       End;
                      End;
  ovVariant,
  ovUnknown         : Begin
                       vEncoded     := True;
                       vObjectValue := ovString;
                       SetValue(Value, vEncoded);
                      End;
  ovLargeInt,
  ovLongWord,
  ovShortInt,
  ovSmallInt,
  ovInteger,
  ovWord,
  ovBoolean,
  ovAutoInc,
  ovOraInterval     : Begin
                       vEncoded := False;
                       If vObjectValue = ovBoolean Then
                        Begin
                         If Boolean(Value) then
                          SetValue('true', vEncoded)
                         Else
                          SetValue('false', vEncoded);
                        End
                       Else
                        Begin
                         {$IFNDEF FPC}
                          {$if CompilerVersion <= 22}
                           SetValue(inttostr(Value), vEncoded);
                          {$ELSE}
                           If vObjectValue <> ovInteger Then
                            SetValue(IntToStr(Int64(Value)), vEncoded)
                           Else
                            SetValue(inttostr(Value), vEncoded);
                          {$IFEND}
                         {$ELSE}
                          If vObjectValue <> ovInteger Then
                           SetValue(IntToStr(Int64(Value)), vEncoded)
                          Else
                           SetValue(inttostr(Value), vEncoded);
                         {$ENDIF}
                        End;
                      End;
  ovSingle,
  ovFloat,
  ovCurrency,
  ovBCD,
  ovFMTBcd,
  ovExtended        : Begin
                       vEncoded     := False;
                       vObjectValue := ovFloat;
                       SetValue(BuildStringFloat(FloatToStr(Value), JsonMode, vFloatDecimalFormat), vEncoded);
                      End;
  ovDate,
  ovTime,
  ovDateTime,
  ovTimeStamp,
  ovOraTimeStamp,
  ovTimeStampOffset : Begin
                       vEncoded      := False;
                       vObjectValue  := ovDateTime;
                       vDateTime    := Value;
//                       {$IFDEF FPC}
//                        vDateTime    := StrToDateTime(Value);
//                       {$ELSE}
//                        vDateTime    := Value; //StrToDateTime(Value);
//                       {$ENDIF}
                       SetValue(IntToStr(DateTimeToUnix(vDateTime)), vEncoded);
                      End;
  ovString,
  ovFixedChar,
  ovWideString,
  ovWideMemo,
  ovFixedWideChar,
  ovMemo,
  ovFmtMemo,
  ovObject          : Begin
                       If vObjectValue <> ovObject then
                        vObjectValue := ovString
                       Else
                        vObjectValue := ovObject;
                       SetValue(Value, vEncoded);
                      End;
 End;
End;

Procedure TJSONParam.SetEncoded(Value: Boolean);
Begin
 If TestNilParam Then
  Exit;
 vEncoded := Value;
 vJSONValue.Encoded := vEncoded;
End;

procedure TJSONParam.SetObjectDirection(Value: TObjectDirection);
begin
 If TestNilParam Then
  Exit;
 vObjectDirection := Value;
 vJSONValue.vObjectDirection := vObjectDirection;
end;

Procedure TJSONParam.SetObjectValue (Value  : TObjectValue);
Begin
 If TestNilParam Then
  Exit;
 vObjectValue := Value;
 vBinary := vObjectValue In [ovStream, ovBlob, ovGraphic, ovOraBlob, ovOraClob];
End;

Procedure TJSONParam.SetVariantValue(Value  : Variant);
Begin
 If TestNilParam Then
  Exit;
 SetDataValue(Value, vObjectValue);
End;

Procedure TJSONParam.StringToBytes  (Value  : String;
                                     Encode : Boolean);
Begin
 If TestNilParam Then
  Exit;
 vJSONValue.JsonMode := vJsonMode;
 vObjectValue        := ovBlob;
 vBinary             := vObjectValue in [ovStream, ovBlob, ovGraphic, ovOraBlob, ovOraClob];
 If vBinary Then
  vJSONValue.StringToBytes(Value);
 vEncoded            := Encoded;
 vJSONValue.vEncoded := vEncoded;
End;

Procedure TJSONParam.SetParamName(bValue : String);
Begin
 If TestNilParam Then
  Exit;
 vParamName := Uppercase(bValue);
 vJSONValue.vtagName := vParamName;
End;

{$IFDEF FPC}
Procedure TJSONParam.SetDatabaseCharSet (Value  : TDatabaseCharSet);
Begin
 vJSONValue.DatabaseCharSet := Value;
 vDatabaseCharSet           := vJSONValue.DatabaseCharSet;
End;
{$ENDIF}

Function TJSONParam.TestNilParam : Boolean;
Begin
 Result := False;
 If Not Assigned(Self) Then
  Begin
   Result := True;
   Raise Exception.Create(cInvalidDWParam);
   Exit;
  End;
End;

procedure TJSONParam.SetParamContentType(const bValue: String);
begin
 If TestNilParam Then
  Exit;
 vParamContentType := bValue;
end;

Procedure TJSONParam.SetParamFileName(bValue : String);
Begin
 If TestNilParam Then
  Exit;
 vParamFileName := bValue;
End;

Procedure TJSONParam.SetValue    (aValue : String;
                                  Encode : Boolean);
Begin
 If TestNilParam Then
  Exit;
 vEncoded := Encode;
 vJSONValue.JsonMode := vJsonMode;
 vJSONValue.vEncoded := vEncoded;
 vBinary := vObjectValue in [ovStream, ovBlob, ovGraphic, ovOraBlob, ovOraClob];
 vJSONValue.ObjectValue := vObjectValue;
 If (vNullValue) And ((aValue = '') Or (aValue = cNullvalue)) Then
  WriteValue(Null)
 Else
  Begin
   If (Encode) And Not(vBinary) Then
    Begin
     If vEncoding = esUtf8 Then
      WriteValue(EncodeStrings(utf8encode(aValue){$IFDEF FPC}, vDatabaseCharSet{$ENDIF}))
     Else
      WriteValue(EncodeStrings(aValue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}))
    End
   Else
    WriteValue(aValue);
  End;
 vJSONValue.vBinary := vBinary;
End;

Function TJSONParam.ToJSON: String;
Begin
 If TestNilParam Then
  Exit;
 vJSONValue.Encoded      := vEncoded;
 vJSONValue.JsonMode     := vJsonMode;
 vJSONValue.TypeObject   := vTypeObject;
 vJSONValue.vtagName     := vParamName;
 vJSONValue.vObjectValue := vObjectValue;
 Result := vJSONValue.ToJSON;
 If vJsonMode = jmPureJSON Then
  Begin
   If Not(((Pos('{', Result) > 0)   And
           (Pos('}', Result) > 0))  Or
          ((Pos('[', Result) > 0)   And
           (Pos(']', Result) > 0))) Then
    Result := Format('{"%s" : "%s"}', [vParamName, vJSONValue.ToJSON]);
  End;
End;

{$IFDEF DEFINE(FPC) Or NOT(DEFINE(POSIX))}
Function TJSONParam.GetAsAnsiString: AnsiString;
Begin
 {$IFDEF FPC}
  Result := GetValue(ovString);
 {$ELSE}
  {$IF CompilerVersion > 21} // Delphi 2010 pra cima
   Result := Utf8ToAnsi(GetValue(ovString));
  {$ELSE}
   Result := GetValue(ovString);
  {$IFEND}
 {$ENDIF}
End;
{$ENDIF}

Function TJSONParam.GetAsBCD      : Currency;
Begin
 If TestNilParam Then
  Exit;
 Result := GetValue(ovBCD);
End;

Function TJSONParam.GetAsBoolean  : Boolean;
Begin
 If TestNilParam Then
  Exit;
 Result := GetValue(ovBoolean);
End;

Function TJSONParam.GetAsCurrency : Currency;
Begin
 If TestNilParam Then
  Exit;
 Result := GetValue(ovCurrency);
End;

Function TJSONParam.GetAsDateTime : TDateTime;
Begin
 If TestNilParam Then
  Exit;
 Result := GetValue(ovDateTime);
End;

Function TJSONParam.GetAsFloat    : Double;
Begin
 If TestNilParam Then
  Exit;
 Result := GetValue(ovFloat);
End;

Function TJSONParam.GetAsFMTBCD   : Currency;
Begin
 If TestNilParam Then
  Exit;
 Result := GetValue(ovFMTBcd);
End;

Function TJSONParam.GetAsInteger  : Integer;
Begin
 If TestNilParam Then
  Exit;
 Result := GetValue(ovInteger);
End;

Function TJSONParam.GetAsLargeInt : LargeInt;
Begin
 If TestNilParam Then
  Exit;
 Result := GetValue(ovLargeInt);
End;

Function TJSONParam.GetAsLongWord : LongWord;
Begin
 If TestNilParam Then
  Exit;
 Result := GetValue(ovLongWord);
End;

Function TJSONParam.GetAsSingle   : Single;
Begin
 If TestNilParam Then
  Exit;
 Result := GetValue(ovSmallInt);
End;

Function TJSONParam.GetAsString   : String;
Begin
 If TestNilParam Then
  Exit;
 Result := GetValue(ovString);
End;

{$IFDEF DEFINE(FPC) Or NOT(DEFINE(POSIX))}
Function TJSONParam.GetAsWideString : WideString;
Begin
 Result := GetValue(ovWideString);
End;
{$ENDIF}

Function TJSONParam.GetAsWord       : Word;
Begin
 If TestNilParam Then
  Exit;
 Result := GetValue(ovWord);
End;

Function TJSONParam.GetByteString   : String;
Var
 Stream  : TStringStream;
 Streamb : TMemoryStream;
Begin
 If TestNilParam Then
  Exit;
 Streamb := Nil;
 Stream := TStringStream.Create('');
 Try
  Streamb := Decodeb64Stream(GetValue(ovString)); // HexToStream(GetValue(ovString), Stream);
  Streamb.Position := 0;
  Stream.CopyFrom(Streamb, Streamb.Size);
  Stream.Position := 0;
  Result := Stream.DataString;
 Finally
  Streamb.Free;
  Stream.Free;
 End;
End;

Function TJSONParam.GetNullValue(Value : TObjectValue) : Variant;
Begin
 If TestNilParam Then
  Exit;
 Case Value Of
  ovVariant,
  ovUnknown     : Result := Null;
  ovString,
  ovFixedChar,
  ovWideString,
  ovWideMemo,
  ovFixedWideChar,
  ovMemo,
  ovFmtMemo     : Result := '';
  ovLargeInt,
  ovLongWord,
  ovShortInt,
  ovSmallInt,
  ovInteger,
  ovWord,
  ovBoolean,
  ovAutoInc,
  ovOraInterval : Result := 0;
  ovSingle,
  ovFloat,
  ovCurrency,
  ovBCD,
  ovFMTBcd,
  ovExtended    : Result := 0;
  ovDate,
  ovTime,
  ovDateTime,
  ovTimeStamp,
  ovOraTimeStamp,
  ovTimeStampOffset : Result := 0;
  ovBytes,
  ovVarBytes,
  ovBlob,
  ovByte,
  ovGraphic,
  ovParadoxOle,
  ovDBaseOle,
  ovTypedBinary,
  ovOraBlob,
  ovOraClob,
  ovStream          : Result := Null;
 End;
End;

Function TJSONParam.GetValue(Value : TObjectValue) : Variant;
Var
 ms       : TMemoryStream;
 MyBuffer : Pointer;
Begin
 If TestNilParam Then
  Exit;
 ms := Nil;
 vJSONValue.TypeObject := vTypeObject;
 Case Value Of
  ovVariant,
  ovUnknown     : Result := vJSONValue.Value;
  ovString,
  ovFixedChar,
  ovWideString,
  ovWideMemo,
  ovFixedWideChar,
  ovMemo,
  ovFmtMemo     : Begin
                   Result := vJSONValue.Value;
                   If VarIsNull(Result) Then
                    Result := GetNullValue(Value)
                   Else
                    Begin
                     If vJSONValue.ObjectValue in [ovString, ovFixedChar, ovWideString] Then
                      If vCripto.Use Then
                       Result := vCripto.Decrypt(Result);
                    End;
                  End;
  ovLargeInt,
  ovLongWord,
  ovShortInt,
  ovSmallInt,
  ovInteger,
  ovWord,
  ovBoolean,
  ovAutoInc,
  ovOraInterval : Begin
                   If vJSONValue.ObjectValue = Value Then
                    Begin
                     Result := vJSONValue.Value;
                     If VarIsNull(Result) Then
                      Result := GetNullValue(Value);
                    End
                   Else
                    Begin
                     If (Not (vJSONValue.IsNull)) Then
                      Begin
                       If Value = ovBoolean Then
                        Result := (vJSONValue.Value = '1')        Or
                                  (Lowercase(vJSONValue.Value) = 'true')
                       Else If (Trim(vJSONValue.Value) <> '')     And
                               (Trim(vJSONValue.Value) <> 'null') Then
                        Begin
                         If Value in [ovLargeInt, ovLongWord] Then
                          Result := StrToInt64(vJSONValue.Value)
                         Else
                          Result := StrToInt(vJSONValue.Value);
                        End
                       Else
                        Result := GetNullValue(Value);
                      End
                     Else
                      Result := GetNullValue(Value);
                    End;
                  End;
  ovSingle,
  ovFloat,
  ovCurrency,
  ovBCD,
  ovFMTBcd,
  ovExtended        : Begin
                       If vJSONValue.ObjectValue = Value Then
                        Begin
                         Result := vJSONValue.Value;
                         If VarIsNull(Result) Then
                          Result := GetNullValue(Value);
                        End
                       Else
                        Begin
                         If (Not (vJSONValue.IsNull)) Then
                          Begin
                           If (Trim(vJSONValue.Value) <> '')     And
                              (Trim(vJSONValue.Value) <> 'null') Then
                            Result := StrToFloat(BuildFloatString(vJSONValue.Value))
                           Else
                            Result := GetNullValue(Value);
                          End
                         Else
                          Result := GetNullValue(Value);
                        End;
                      End;
  ovDate,
  ovTime,
  ovDateTime,
  ovTimeStamp,
  ovOraTimeStamp,
  ovTimeStampOffset : Begin
                       If vJSONValue.ObjectValue = Value Then
                        Begin
                         Result := vJSONValue.Value;
                         If VarIsNull(Result) Then
                          Result := GetNullValue(Value);
                        End
                       Else
                        Begin
                         If (Not (vJSONValue.IsNull)) Then
                          Begin
                           If (Trim(vJSONValue.Value) <> '')     And
                              (Trim(vJSONValue.Value) <> 'null') Then
                            Result := vJSONValue.Value
                           Else
                            Result := GetNullValue(Value);
                          End
                         Else
                          Result := GetNullValue(Value);
                        End;
                      End;
  ovBytes,
  ovVarBytes,
  ovBlob,
  ovByte,
  ovGraphic,
  ovParadoxOle,
  ovDBaseOle,
  ovTypedBinary,
  ovOraBlob,
  ovOraClob,
  ovStream          : Begin
                       ms := TMemoryStream.Create;
                       Try
                        vJSONValue.SaveToStream(ms, vJSONValue.vBinary);
                        If ms.Size > 0 Then
                         Begin
                          Result   := VarArrayCreate([0, ms.Size - 1], VarByte);
                          MyBuffer := VarArrayLock(Result);
                          ms.ReadBuffer(MyBuffer^, ms.Size);
                          VarArrayUnlock(Result);
                         End
                        Else
                         Result := GetNullValue(Value);
                       Finally
                        ms.Free;
                       End
                      End;
 End;
End;

Function TJSONParam.GetVariantValue : Variant;
Var
 ms       : TMemoryStream;
 MyBuffer : Pointer;
Begin
 If TestNilParam Then
  Exit;
 ms := Nil;
 Case vObjectValue Of
  ovVariant,
  ovUnknown,
  ovObject          : Result := vJSONValue.Value;
  ovGuid,
  ovString,
  ovFixedChar,
  ovWideString,
  ovWideMemo,
  ovFixedWideChar,
  ovMemo,
  ovFmtMemo         : Begin
                       If isNull Then
                        Result := ''
                       Else
                        Begin
                         If vCripto.Use Then
                          Result := vCripto.Decrypt(vJSONValue.Value)
                         Else
                          Result := vJSONValue.Value;
                        End;
                      End;
  ovLargeInt,
  ovLongWord,
  ovShortInt,
  ovSmallInt,
  ovInteger,
  ovWord,
  ovBoolean,
  ovAutoInc,
  ovOraInterval     : Begin
                       If isNull Then
                        Result := 0
                       Else
                        Begin
                         If vJSONValue.ObjectValue = ObjectValue then
                          Result := vJSONValue.Value
                         Else
                          Begin
                           If (vJSONValue.Value <> '')                And
                              (Lowercase(vJSONValue.Value) <> 'null') Then
                            Begin
                             If vObjectValue = ovBoolean Then
                              Result := (vJSONValue.Value = '1') Or (Lowercase(vJSONValue.Value) = 'true')
                             Else If (Trim(vJSONValue.Value) <> '')     And
                                     (Trim(vJSONValue.Value) <> 'null') Then
                              Begin
                               If vObjectValue in [ovLargeInt, ovLongWord] Then
                                Result := StrToInt64(vJSONValue.Value)
                               Else
                                Result := StrToInt(vJSONValue.Value);
                              End;
                            End
                           Else
                            Result := Null;
                          End;
                        End;
                      End;
  ovSingle,
  ovFloat,
  ovCurrency,
  ovBCD,
  ovFMTBcd,
  ovExtended        : Begin
                       If isNull Then
                        Result := 0
                       Else
                        Begin
                         If vJSONValue.ObjectValue = ObjectValue then
                          Result := vJSONValue.Value
                         Else
                          Begin
                           If (vJSONValue.Value <> '') And (Lowercase(vJSONValue.Value) <> 'null') Then
                            Result := StrToFloat(BuildFloatString(vJSONValue.Value))
                           Else
                            Result := Null;
                          End;
                        End;
                      End;
  ovDate,
  ovTime,
  ovDateTime,
  ovTimeStamp,
  ovOraTimeStamp,
  ovTimeStampOffset : Begin
                       If isNull Then
                        Result := Null
                       Else
                        Begin
                         If vJSONValue.ObjectValue = ObjectValue then
                          Result := vJSONValue.Value
                         Else
                          Begin
                           If (vJSONValue.Value <> '') And (Lowercase(vJSONValue.Value) <> 'null') Then
                            Result := UnixToDateTime(StrToInt64(vJSONValue.Value))
                           Else
                            Result := Null;
                          End;
                        End;
                      End;
  ovBytes,
  ovVarBytes,
  ovBlob,
  ovByte,
  ovGraphic,
  ovParadoxOle,
  ovDBaseOle,
  ovTypedBinary,
  ovOraBlob,
  ovOraClob,
  ovStream          : Begin
                       If isNull Then
                        Result := Null
                       Else
                        Begin
                         ms := TMemoryStream.Create;
                         Try
                          vJSONValue.SaveToStream(ms, vJSONValue.vBinary);
                          If ms.Size > 0 Then
                           Begin
                            ms.Position := 0;
                            Result      := VarArrayCreate([0, ms.Size - 1], VarByte);
                            MyBuffer    := VarArrayLock(Result);
                            ms.ReadBuffer(MyBuffer^, ms.Size);
                            VarArrayUnlock(Result);
                           End
                          Else
                           Result := Null;
                         Finally
                          ms.Free;
                         End;
                        End;
                      End;
  End;
End;

Function TJSONParam.IsNull  : Boolean;
Begin
 If TestNilParam Then
  Exit;
 Result := vNullValue;
End;

Function TJSONParam.IsEmpty : Boolean;
Begin
 If TestNilParam Then
  Exit;
 Result := IsNull;
End;

Procedure TJSONParam.WriteValue(bValue : Variant);
Begin
 If TestNilParam Then
  Exit;
 vJSONValue.Encoding         := vEncoding;
 vJSONValue.vtagName         := vParamName;
 vJSONValue.vTypeObject      := vTypeObject;
 vJSONValue.vObjectDirection := vObjectDirection;
 vJSONValue.vObjectValue     := vObjectValue;
 vJSONValue.vEncoded         := vEncoded;
 vJSONValue.WriteValue(bValue);
 vNullValue                  := vJSONValue.vNullValue;
End;

Function TStringStreamList.Add(Item : TStringStream) : Integer;
Var
 vItem : ^TStringStream;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TStringStreamList.Clear;
Begin
 ClearList;
End;

Procedure TStringStreamList.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(i);
// Tlist(Self).Clear;
End;

Constructor TStringStreamList.Create;
Begin
 Inherited;
End;

Procedure TStringStreamList.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     {$IFDEF FPC}
     FreeAndNil(TList(Self).Items[Index]^);
     {$ELSE}
      {$IF CompilerVersion > 33}
       FreeAndNil(TStringStream(TList(Self).Items[Index]^));
      {$ELSE}
       FreeAndNil(TList(Self).Items[Index]^);
      {$IFEND}
     {$ENDIF}
     {$IFDEF FPC}
      Dispose(PStringStream(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Destructor TStringStreamList.Destroy;
Begin
 ClearList;
 Inherited;
End;

Function TStringStreamList.GetRec(Index : Integer) : TStringStream;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TStringStream(TList(Self).Items[Index]^);
End;

Procedure TStringStreamList.PutRec(Index : Integer;
                                   Item  : TStringStream);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TStringStream(TList(Self).Items[Index]^) := Item;
End;

{ TRESTDWHeaders }

Constructor TRESTDWHeaders.Create;
Begin
 Inherited;
 Input  := TStringList.Create;
 Output := TStringList.Create;
End;

Destructor TRESTDWHeaders.Destroy;
Begin
 FreeAndNil(Input);
 FreeAndNil(Output);
 Inherited;
End;

End.

