unit uDWJSONInterface;

{$I uRESTDW.inc}

interface

Uses
 SysUtils, Classes,{$IFNDEF FPC}{$IF Defined(HAS_FMX)}system.json,{$ELSE}
                    uDWJSON,{$IFEND}{$ELSE}uDWJSON,{$ENDIF}Variants;  //fpjson, jsonparser

Type
 TElementType = (etObject, etArray, etString, etNumeric, etBoolean);

Type
 TJSONBaseClass = Class
End;

Type
 TJSONBaseObjectClass = Class
 Private
  vJSONObject : TJSONBaseClass;
  Function  GetObject : TJSONObject;
  Procedure SetObject(Value : TJSONObject);
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Property    JSONObject : TJSONObject Read GetObject Write SetObject;
End;

Type
 TJSONBaseArrayClass = Class
 Private
  vJSONObject : TJSONBaseClass;
  Function  GetObject : TJSONArray;
  Procedure SetObject(Value : TJSONArray);
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Property    JSONObject : TJSONArray Read GetObject Write SetObject;
End;

Type
 TDWJSONPair = Packed Record
  isnull : Boolean;
  ClassName,
  Name,
  Value : String;
End;

Type
 TDWJSONBase = Class(TJSONBaseObjectClass)
 Private
 Public
  Constructor Create(ParentJSON : TJSONBaseClass);
  Destructor Destroy; Override;
  Function PairCount   : Integer;
End;

Type
 TDWJSONValue = Class(TDWJSONBase)
 Private
  Function  GetPair(Index : Integer) : TDWJSONPair;
  Procedure PutPair(Index : Integer;
                    Value : TDWJSONPair);
 Public
  Property Pair[Index  : Integer] : TDWJSONPair Read GetPair Write PutPair;
End;

Type
 TDWJSONArray = Class(TJSONBaseArrayClass)
 Public
  Function ElementCount : Integer;
  Function GetObject(Index : Integer) : TDWJSONBase;
  Function ToJSON : String;
  Constructor Create;
  Destructor Destroy;Override;
End;

Type
 TDWJSONObject = Class(TJSONBaseObjectClass)
 Private
  Function  GetPair (Index   : Integer)  : TDWJSONPair;Overload;
  Function  GetPairN(Index   : String)   : TDWJSONPair;Overload;
  Procedure PutPair (Index   : Integer;
                     Item    : TDWJSONPair);           Overload;
  Procedure PutPairN(Index   : String;
                     Item    : TDWJSONPair);           Overload;
 Public
  Constructor Create(JSONValue : String);Overload;
  Destructor  Destroy;Override;
  Function    PairCount : Integer;
  Function    ToJSON    : String;
  Function    ClassType : TClass;
  Function OpenArray (key    : String)  : TDWJSONArray;Overload;
  Function OpenArray (Index  : Integer) : TDWJSONArray;Overload;
  Property Pairs     [Index  : Integer] : TDWJSONPair Read GetPair  Write PutPair;
  Property PairByName[Index  : String]  : TDWJSONPair Read GetPairN Write PutPairN;
End;

implementation

Uses uDWConsts;

Function removestr(Astr: string; Asubstr: string):string;
Begin
 result:= stringreplace(Astr, Asubstr, '', [rfReplaceAll, rfIgnoreCase]);
End;

{$IF Defined(HAS_FMX)}
Function GetElementJSON(bArray : TJSONObject; Value : String) : String;
Var
 I : Integer;
 aJSONObject : TJSONObject;
Begin
 Result := '';
 For I := 0 To bArray.Count -1 do
  Begin
   aJSONObject := TJSONObject.ParseJSONValue(bArray.Get(I).ToJSON) as TJSONObject;
   If Uppercase(Value) = Uppercase(removestr(aJSONObject.Pairs[0].JsonString.Value, '"')) Then
    Begin
     Result := aJSONObject.Pairs[0].JsonValue.ToJSON;
     Break;
    End;
   FreeAndNil(aJSONObject);
  End;
End;
{$IFEND}

Function TDWJSONObject.OpenArray(key : String) : TDWJSONArray;
{$IF Defined(HAS_FMX)}
Var
 vEIndex     : Integer;
 aJSONObject : TJSONObject;
 aJSONArray  : Tjsonarray;
{$IFEND}
Begin
 Result := TDWJSONArray.Create;
 If JSONObject = Nil Then
  Exit;
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   If TJSONObject(JSONObject).classname = 'TJSONObject' Then
    Begin
     aJSONObject        := TJSONObject.ParseJSONValue(TJSONObject(JSONObject).ToJSON) as TJSONObject;
     aJSONArray         := TJSONObject.ParseJSONValue(TJSONObject(aJSONObject).Get(Key).JsonValue.ToJSON) as TJSONArray;
     Result.vJSONObject := TJSONBaseClass(aJSONArray);
     FreeAndNil(aJSONObject);
    End
   Else
    Begin
     aJSONArray         := TJSONObject.ParseJSONValue(GetElementJSON(TJSONObject(JSONObject), Key)) as TJSONArray;
     Result.vJSONObject := TJSONBaseClass(aJSONArray); // (Key).ToJSON) as TJSONArray);
    End;
  {$ELSE}
   Result.vJSONObject := TJSONBaseClass(JSONObject.getJSONArray(key));
  {$IFEND}
 {$ELSE}
  Result.vJSONObject := TJSONBaseClass(JSONObject.getJSONArray(key));
//  Result.vJSONObject := TJSONBaseClass(TJSONObject(JSONObject).Arrays[key]);
 {$ENDIF}
End;

Function TDWJSONObject.OpenArray(Index : Integer) : TDWJSONArray;
{$IF Defined(HAS_FMX)}
Var
 vEIndex     : Integer;
 aJSONObject : TJSONObject;
 aJSONArray  : Tjsonarray;
{$IFEND}
Begin
 Result := TDWJSONArray.Create;
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   If TJSONObject(JSONObject).classname = 'TJSONObject' Then
    Begin
     aJSONObject        := TJSONObject.ParseJSONValue(TJSONObject(JSONObject).ToJSON) as TJSONObject;
     aJSONArray         := TJSONObject.ParseJSONValue(TJSONObject(aJSONObject).Pairs[Index].JsonValue.ToJSON) as TJSONArray;
     Result.vJSONObject := TJSONBaseClass(aJSONArray);
     FreeAndNil(aJSONObject);
    End
   Else
    Begin
     aJSONArray         := TJSONObject.ParseJSONValue(TJSONObject(aJSONObject).Pairs[Index].JsonValue.ToJSON) as TJSONArray;
     Result.vJSONObject := TJSONBaseClass(aJSONArray); // (Key).ToJSON) as TJSONArray);
    End;
  {$ELSE}
   If TJSONObject(JSONObject).classname = 'TJSONObject' Then
    Result.vJSONObject := TJSONBaseClass(TJSONObject(vJSONObject).opt(TJSONObject(vJSONObject).names.get(Index).toString))
   Else If TJSONObject(JSONObject).classname = 'TJSONArray' Then
    Result.vJSONObject := TJSONBaseClass(TJSONArray(vJSONObject).get(Index));
  {$IFEND}
 {$ELSE}
  If TJSONObject(JSONObject).classname = 'TJSONObject' Then
   Result.vJSONObject := TJSONBaseClass(TJSONObject(vJSONObject).opt(TJSONObject(vJSONObject).names.get(Index).toString))
  Else If TJSONObject(JSONObject).classname = 'TJSONArray' Then
   Result.vJSONObject := TJSONBaseClass(TJSONArray(vJSONObject).get(Index));
 {
  If TJSONObject(JSONObject).classname = 'TJSONObject' Then
   Result.vJSONObject := TJSONBaseClass(TJSONObject(vJSONObject).Items[Index].toString)
  Else If TJSONObject(JSONObject).classname = 'TJSONArray' Then
   Result.vJSONObject := TJSONBaseClass(TJSONArray(vJSONObject).Items[Index]);
 }
 {$ENDIF}
End;

Constructor TDWJSONArray.Create;
Begin
 Inherited Create;
End;

Destructor TDWJSONArray.Destroy;
Begin
 inherited;
End;

Function TDWJSONArray.ElementCount : Integer;
Begin
 Result := 0;
 If vJSONObject = Nil then
  Exit;
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   Result := TJSONArray(vJSONObject).Size;
  {$ELSE}
   If TJSONObject(vJSONObject).classname = 'TJSONObject' Then
    Begin
     If TJSONObject(vJSONObject).names <> Nil Then
      Result := TJSONObject(vJSONObject).names.length;
    End
   Else
    Result := TJSONArray(vJSONObject).length;
  {$IFEND}
 {$ELSE}
 If TJSONObject(vJSONObject).classname = 'TJSONObject' Then
  Result := TJSONObject(vJSONObject).names.length
 Else
  Result := TJSONArray(vJSONObject).length;
{
 If TJSONObject(vJSONObject).classname = 'TJSONObject' Then
    Result := TJSONObject(vJSONObject).Count
  Else
   Result := TJSONArray(vJSONObject).Count;
}
 {$ENDIF}
End;

Function TDWJSONArray.GetObject(Index: Integer): TDWJSONBase;
Var
{$IF Defined(HAS_FMX)}
 aJSONObject : TJSONArray;
 aJSONValue  : TJSONValue;
{$IFEND}
 vClassName : String;
Begin
 Result := TDWJSONBase.Create(vJSONObject);
 If (UpperCase(TJSONObject(vJSONObject).ClassName) = UpperCase('TJSONArray')) Then
  Begin
   {$IFNDEF FPC}
    {$IF Defined(HAS_FMX)}
     aJSONValue         := TJSONObject.ParseJSONValue(TJSONObject(JSONObject).Get(Index).ToJSON);
     If aJSONValue is TJSONObject Then
      Result.vJSONObject := TJSONBaseClass(aJSONValue as Tjsonobject)
     Else
      Result.vJSONObject := TJSONBaseClass(aJSONValue);
    {$ELSE}
     If TJSONArray(vJSONObject).isNull(Index) Then
      Result.vJSONObject := Nil
     Else
      Begin
       Result.vJSONObject := TJSONBaseClass(TJSONArray(vJSONObject).optJSONArray(Index));
       If Result.vJSONObject = Nil then
        Result.vJSONObject := TJSONBaseClass(TJSONArray(vJSONObject).opt(Index));
      End;
    {$IFEND}
   {$ELSE}
    If TJSONArray(vJSONObject).isNull(Index) Then
     Result.vJSONObject := Nil
    Else
     Begin
      Result.vJSONObject := TJSONBaseClass(TJSONArray(vJSONObject).optJSONArray(Index));
      If Result.vJSONObject = Nil then
       Result.vJSONObject := TJSONBaseClass(TJSONArray(vJSONObject).opt(Index));
     End;
{
    If TJSONArray(vJSONObject).Count > 0 Then
     Begin
      Result.vJSONObject := Nil;
      vClassName         := TJSONObject(vJSONObject).Items[index].ClassName;
      If UpperCase(vClassName) = UpperCase('TJSONArray') Then
       Result.vJSONObject := TJSONBaseClass(TJSONArray(vJSONObject).Items[Index])
      Else If UpperCase(vClassName) = UpperCase('TJSONObject') Then
       Result.vJSONObject := TJSONBaseClass(TJSONObject(TJSONArray(vJSONObject).Items[Index]))
      Else If UpperCase(vClassName) <> UpperCase('TJSONNull') Then
       Result.vJSONObject := TJSONBaseClass(TJSONString(TJSONObject(vJSONObject).Items[index]))
      Else
       Result.vJSONObject := TJSONBaseClass(TJSONNull(TJSONObject(vJSONObject).Items[index]));
     End;
}
   {$ENDIF}
  End
 Else If (UpperCase(TJSONObject(vJSONObject).ClassName) = UpperCase('TJSONObject')) Then
  Begin
   {$IFNDEF FPC}
    {$IF Defined(HAS_FMX)}
     Result.vJSONObject := TJSONBaseClass(TJSONObject.ParseJSONValue(TJSONObject(vJSONObject).Get(Index).JsonValue.ToJson) as TJSONArray);
    {$ELSE}
     Result.vJSONObject := TJSONBaseClass(TJSONObject(vJSONObject).opt(TJSONObject(vJSONObject).names.get(Index).toString));
    {$IFEND}
   {$ELSE}
    Result.vJSONObject := TJSONBaseClass(TJSONObject(vJSONObject).opt(TJSONObject(vJSONObject).names.get(Index).toString));
//    Result.vJSONObject := TJSONBaseClass(TJSONObject(vJSONObject).Items[Index]);
   {$ENDIF}
  End
 Else
  Result.vJSONObject := TJSONBaseClass(TJSONObject(vJSONObject));
End;

Function TDWJSONArray.ToJSON : String;
Begin
 Result := TJSONObject(Self).ToString;
End;

Constructor TDWJSONObject.Create(JSONValue : String);
Begin
 Inherited Create;
 If JSONValue <> '' Then
  Begin
   {$IFNDEF FPC}
    {$IF Defined(HAS_FMX)}
     If JSONValue[InitStrPos] = '[' then
      vJSONObject := TJSONBaseClass(TJSONObject.ParseJSONValue(JSONValue) as TJsonArray)
     Else If JSONValue[InitStrPos] = '{' then
      vJSONObject := TJSONBaseClass(TJSONObject.ParseJSONValue(JSONValue) as TJsonObject)
     Else
      vJSONObject := TJSONBaseClass(TJSONObject.ParseJSONValue('{}') as TJsonObject)
    {$ELSE}
     If JSONValue[InitStrPos] = '[' then
      vJSONObject := TJSONBaseClass(TJSONArray.Create(JSONValue))
     Else If JSONValue[InitStrPos] = '{' then
      vJSONObject := TJSONBaseClass(TJSONObject.Create(JSONValue))
     Else
      vJSONObject := TJSONBaseClass(TJSONObject.Create('{}'))
    {$IFEND}
   {$ELSE}
    Try
     If JSONValue[InitStrPos] = '[' then
      vJSONObject := TJSONBaseClass(TJSONArray.Create(JSONValue))
     Else If JSONValue[InitStrPos] = '{' then
      vJSONObject := TJSONBaseClass(TJSONObject.Create(JSONValue))
     Else
      vJSONObject := TJSONBaseClass(TJSONObject.Create('{}'));
    Except
     vJSONObject := Nil;
    End;
   {$ENDIF}
  End;
End;

Destructor TDWJSONObject.Destroy;
Begin
 If vJSONObject <> Nil Then
  FreeAndNil(TJSONBaseClass(vJSONObject));
 Inherited;
End;

Function TDWJSONObject.GetPairN(Index   : String)  : TDWJSONPair;
Var
 I           : Integer;
 vElementName,
 vClassName  : String;
 {$IF Defined(HAS_FMX)}
 aJSONObject : TJSONObject;
 vValueJSON  : String;
 {$IFEND}
Begin
 Result.isnull := False;
 If vJSONObject = Nil Then
  Begin
   Result.isnull := True;
   Exit;
  End;
  vClassName  := TJSONObject(vJSONObject).ClassName;
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   If (UpperCase(vClassName) = UpperCase('TDWJSONObject')) Or
      (UpperCase(vClassName) = UpperCase('TJSONObject'))   Or
      (UpperCase(vClassName) = UpperCase('TDWJSONBase'))  Then
    Begin
     If vClassName <> '_String' Then
      Begin
       For I := 0 To TJSONObject(vJSONObject).Count -1 Do
        Begin
         Result.Name      := removestr(TJSONObject(vJSONObject).Pairs[I].JsonString.Value, '"');
         If LowerCase(Result.Name) <> LowerCase(Index) Then
          Begin
           Result.Name    := '';
           Continue;
          End; 
         If TJSONObject(vJSONObject).Pairs[I].JsonValue is TJSONObject Then
          Begin
           Result.Classname := 'TJSONObject';
           vValueJSON       := TJSONObject(vJSONObject).Pairs[I].JsonValue.ToString; //removestr(TJSONObject(vJSONObject).Pairs[index].JsonValue.tostring, '"');
           If (vValueJSON       = '') Or
              (Trim(vValueJSON) = '""') then
            Result.Value    := TJSONObject(vJSONObject).Pairs[I].JsonValue.Value
           Else
            Result.Value  := vValueJSON;
          End
         Else
          Begin
           Result.Classname := TJSONObject(vJSONObject).Pairs[I].JsonValue.ClassName;
           vValueJSON  := TJSONObject(vJSONObject).Pairs[I].JsonValue.Value;
           If (vValueJSON       = '') Or
              (Trim(vValueJSON) = '""') then
            Result.Value  := TJSONObject(vJSONObject).Pairs[I].JsonValue.ToString
           Else
            Result.Value  := vValueJSON;
          End;
         Break;
        End;
      End;
    End
   Else If UpperCase(vClassName) = UpperCase('TJSONArray') Then
    Begin
     For I := 0 To TJSONObject(vJSONObject).Count -1 Do
      Begin
       aJSONObject := TJSONObject.ParseJSONValue(TJSONObject(vJSONObject).Get(I).toJson) as TJSONObject;
       Result.Name        := removestr(aJSONObject.Value, '"');
       If LowerCase(Result.Name) <> LowerCase(Index) Then
        Begin
         FreeAndNil(aJSONObject);
         Result.Name      := '';
         Continue;
        End; 
       If (aJSONObject.tostring = '') Or
          (Trim(aJSONObject.tostring) = '""') then
        Result.Value      := ''
       Else
        Result.Value      := aJSONObject.tostring;
       Result.Classname   := 'TJSONArray';
       FreeAndNil(aJSONObject);
       Break;
      End; 
    End;
  {$ELSE}
   If (UpperCase(vClassName) = UpperCase('TDWJSONObject')) Or
      (UpperCase(vClassName) = UpperCase('TJSONObject'))   Or
      (UpperCase(vClassName) = UpperCase('TDWJSONBase'))  Then
    Begin
     If vClassName <> '_String' Then
      Begin
       For I := 0 To TJSONObject(vJSONObject).names.length -1 Do
        Begin
         If LowerCase(TJSONObject(vJSONObject).names.get(I).toString) <> LowerCase(Index) Then
          Continue;
         Result.Name        := TJSONObject(vJSONObject).names.get(I).toString;
         Result.Value       := TJSONObject(vJSONObject).get(Result.Name).toString;
         Result.Classname   := TJSONObject(vJSONObject).get(Result.Name).classname;
         Break;
        End;
      End;
    End
   Else If UpperCase(vClassName) = UpperCase('TJSONArray') Then
    Begin
     For I := 0 To TJSONArray(vJSONObject).length -1 Do
      Begin
       If Lowercase(TJSONArray(vJSONObject).get(I).classname) <> Lowercase('_String') Then
        Begin
         vClassName := TJSONArray(vJSONObject).optJSONObject(I).ClassName;
         Result.Classname := 'TJSONArray';
         If (TJSONObject(TJSONArray(vJSONObject).optJSONObject(I)).names.length > 0) And
            (UpperCase(vClassName) = UpperCase('TJSONArray')) Then
          Begin
           If (TJSONObject(TJSONArray(vJSONObject).optJSONObject(I)).names.length > I) Then
            Begin
             If LowerCase(TJSONObject(TJSONArray(vJSONObject).optJSONObject(I)).names.get(0).toString) <> LowerCase(Index) Then
              Begin
               Result.Classname := '';
               Continue;
              End;
             Result.Name        := TJSONObject(TJSONArray(vJSONObject).optJSONObject(I)).names.get(0).toString;
             Result.Value       := TJSONObject(TJSONArray(vJSONObject).optJSONObject(I)).get(Result.Name).toString;
             Break;
            End;
          End
         Else
          Begin
           Result.Name        := TJSONArray(vJSONObject).get(I).toString;
           If LowerCase(Result.Name) <> LowerCase(Index) Then
            Begin
             Result.Name := '';
             Continue;
            End;
           If (Trim(Result.Name) = '') Or
             ((Pos('{', Result.Name) > 0) Or (Pos('[', Result.Name) > 0)) Then
            Result.Name       := 'arrayobj' + IntToStr(I);
           Result.Value       := TJSONArray(vJSONObject).opt(I).toString;
           Break;
          End;
        End;
      End;
    End;
  {$IFEND}
 {$ELSE}
 If (UpperCase(vClassName) = UpperCase('TDWJSONObject')) Or
    (UpperCase(vClassName) = UpperCase('TJSONObject'))   Or
    (UpperCase(vClassName) = UpperCase('TDWJSONBase'))  Then
  Begin
   If vClassName <> '_String' Then
    Begin
     For I := 0 To TJSONObject(vJSONObject).names.length -1 Do
      Begin
       If (Lowercase(TJSONObject(vJSONObject).names.get(I).toString) <> Lowercase(Index)) Then
        Continue;
       Result.Name      := TJSONObject(vJSONObject).names.get(I).toString;
       Result.Value     := TJSONObject(vJSONObject).get(Result.Name).toString;
       Result.Classname := TJSONObject(vJSONObject).get(Result.Name).Classname;
       Break;
      End;
    End;
  End
 Else If UpperCase(vClassName) = UpperCase('TJSONArray') Then
  Begin
   For I := 0 To TJSONArray(vJSONObject).length -1 Do
    Begin
     Result.Name      := TJSONArray(vJSONObject).get(I).toString;
     If LowerCase(Result.Name) <> LowerCase(Index) Then
      Begin
       Result.Name := '';
       Continue;
      End;
     Result.Value     := TJSONArray(vJSONObject).opt(I).toString;
     Result.Classname := 'TJSONArray';
     Break;
    End;
  End;
 {$ENDIF}
 If Trim(Result.Classname) = '' Then
  Result.ClassName := vClassName;
 //Corre��o para null value
 Result.isnull := (Result.Value = 'null'); // or (Result.Value = '');
 If Result.isnull Then
  Result.Value := '';
End;

Function TDWJSONObject.GetPair(Index   : Integer) : TDWJSONPair;
Var
 vElementName,
 vClassName : String;
 {$IF Defined(HAS_FMX)}
 aJSONObject : TJSONObject;
 vValueJSON  : String;
 {$IFEND}
Begin
 Result.isnull := False;
 If vJSONObject = Nil Then
  Begin
   Result.isnull := True;
   Exit;
  End;
  vClassName  := TJSONObject(vJSONObject).ClassName;
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   If (UpperCase(vClassName) = UpperCase('TDWJSONObject')) Or
      (UpperCase(vClassName) = UpperCase('TJSONObject'))   Or
      (UpperCase(vClassName) = UpperCase('TDWJSONBase'))  Then
    Begin
     If vClassName <> '_String' Then
      Begin
       If (TJSONObject(vJSONObject).Count > index) Then
        Begin
         Result.Name      := removestr(TJSONObject(vJSONObject).Pairs[index].JsonString.Value, '"');
         If TJSONObject(vJSONObject).Pairs[index].JsonValue is TJSONObject Then
          Begin
           Result.Classname := 'TJSONObject';
           vValueJSON       := TJSONObject(vJSONObject).Pairs[index].JsonValue.ToString; //removestr(TJSONObject(vJSONObject).Pairs[index].JsonValue.tostring, '"');
           If (vValueJSON       = '') Or
              (Trim(vValueJSON) = '""') then
            Result.Value    := TJSONObject(vJSONObject).Pairs[index].JsonValue.Value
           else
            Result.Value  := vValueJSON;
          End
         Else
          Begin
           Result.Classname := TJSONObject(vJSONObject).Pairs[index].JsonValue.ClassName;
           vValueJSON  := TJSONObject(vJSONObject).Pairs[index].JsonValue.Value;
           If (vValueJSON       = '') Or
              (Trim(vValueJSON) = '""') then
            Result.Value  := TJSONObject(vJSONObject).Pairs[index].JsonValue.ToString
           else
            Result.Value  := vValueJSON;
          End;
        End;
      End
     Else
      Begin
       Result.Value     := TJSONObject(vJSONObject).Pairs[index].JsonValue.Value;//removestr(TJSONObject(vJSONObject).Pairs[index].JsonValue.tostring, '"');
       Result.Classname := TJSONObject(vJSONObject).Pairs[index].JsonValue.Classname;
      End;
    End
   Else If UpperCase(vClassName) = UpperCase('TJSONArray') Then
    Begin
     aJSONObject := TJSONObject.ParseJSONValue(TJSONObject(vJSONObject).Get(index).toJson) as TJSONObject;
     Result.Name        := removestr(aJSONObject.Value, '"');
     If (aJSONObject.tostring = '') Or
        (Trim(aJSONObject.tostring) = '""') then
      Result.Value      := ''
     Else
      Result.Value      := aJSONObject.tostring;
     Result.Classname   := 'TJSONArray';
     FreeAndNil(aJSONObject);
    End
   Else
    Begin
     Result.Name        := '';
     Result.Value       := TJSONValue(vJSONObject).Value;
     If (Result.Value = '') Or
        (Trim(Result.Value) = '""') then
      Result.Value      := TJSONObject(vJSONObject).ToJson;
     Result.Classname   := 'TJSONValue';
    End;
  {$ELSE}
   If (UpperCase(vClassName) = UpperCase('TDWJSONObject')) Or
      (UpperCase(vClassName) = UpperCase('TJSONObject'))   Or
      (UpperCase(vClassName) = UpperCase('TDWJSONBase'))  Then
    Begin
     If vClassName <> '_String' Then
      Begin
       If TJSONObject(vJSONObject).names.length > 0 Then
        Begin
         If (TJSONObject(vJSONObject).names.length > index) Then
          Begin
           Result.Name        := TJSONObject(vJSONObject).names.get(index).toString;
           Result.Value       := TJSONObject(vJSONObject).get(Result.Name).toString;
           Result.Classname   := TJSONObject(vJSONObject).get(Result.Name).classname;
          End;
        End
       Else
        Begin
         Result.Value       := TJSONObject(vJSONObject).toString;
         Result.Classname   := TJSONObject(vJSONObject).ClassName;
        End;
      End
     Else
      Begin
       Result.Value       := TJSONObject(vJSONObject).toString;
       Result.Classname   := TJSONObject(vJSONObject).ClassName;
      End;
    End
   Else If UpperCase(vClassName) = UpperCase('TJSONArray') Then
    Begin
     If Lowercase(TJSONArray(vJSONObject).get(index).classname) = Lowercase('_String') Then
      Begin
       Result.Classname := '_String';
       Result.Name      := 'arrayobj' + IntToStr(Index);
       Result.Value     := TJSONArray(vJSONObject).get(index).ToString;
      End
     Else
      Begin
       vClassName := TJSONArray(vJSONObject).optJSONObject(index).ClassName;
       Result.Classname := 'TJSONArray';
       If (TJSONObject(TJSONArray(vJSONObject).optJSONObject(index)).names.length > 0) And
          (UpperCase(vClassName) = UpperCase('TJSONArray')) Then
        Begin
         If (TJSONObject(TJSONArray(vJSONObject).optJSONObject(index)).names.length > index) Then
          Begin
           Result.Name        := TJSONObject(TJSONArray(vJSONObject).optJSONObject(index)).names.get(index).toString;
           Result.Value       := TJSONObject(TJSONArray(vJSONObject).optJSONObject(index)).get(Result.Name).toString;
          End;
        End
       Else
        Begin
         Result.Name        := TJSONArray(vJSONObject).get(index).toString;
         If (Trim(Result.Name) = '') Or
           ((Pos('{', Result.Name) > 0) Or (Pos('[', Result.Name) > 0)) Then
          Result.Name       := 'arrayobj' + IntToStr(Index);
         Result.Value       := TJSONArray(vJSONObject).opt(Index).toString;
        End;
      End;
    End
   Else
    Begin
     Result.Value     := TJSONObject(vJSONObject).toString;
     Result.Classname := TJSONObject(vJSONObject).Classname;
    End;
  {$IFEND}
 {$ELSE}
 If (UpperCase(vClassName) = UpperCase('TDWJSONObject')) Or
    (UpperCase(vClassName) = UpperCase('TJSONObject'))   Or
    (UpperCase(vClassName) = UpperCase('TDWJSONBase'))  Then
  Begin
   If vClassName <> '_String' Then
    Begin
     If TJSONObject(vJSONObject).names.length > 0 Then
      Begin
       If (TJSONObject(vJSONObject).names.length > index) Then
        Begin
         Result.Name      := TJSONObject(vJSONObject).names.get(index).toString;
         Result.Value     := TJSONObject(vJSONObject).get(Result.Name).toString;
         Result.Classname := TJSONObject(vJSONObject).get(Result.Name).Classname;
        End;
      End
     Else
      Begin
       Result.Value     := TJSONObject(vJSONObject).toString;
       Result.Classname := TJSONObject(vJSONObject).Classname;
      End;
    End
   Else
    Begin
     Result.Value     := TJSONObject(vJSONObject).toString;
     Result.Classname := TJSONObject(vJSONObject).Classname;
    End;
  End
 Else If UpperCase(vClassName) = UpperCase('TJSONArray') Then
  Begin
   Result.Name      := TJSONArray(vJSONObject).get(Index).toString;
   Result.Value     := TJSONArray(vJSONObject).opt(Index).toString;
   Result.Classname := 'TJSONArray';
  End
 Else
  Begin
   Result.Value     := TJSONObject(vJSONObject).toString;
   Result.Classname := TJSONObject(vJSONObject).Classname;
  End;
 {$ENDIF}
 If Trim(Result.Classname) = '' Then
  Result.ClassName := vClassName;
 //Corre��o para null value
 Result.isnull := (Result.Value = 'null'); // or (Result.Value = '');
 If Result.isnull Then
  Result.Value := '';
End;

Function TDWJSONObject.PairCount: Integer;
Begin
 Result := 0;
 If vJSONObject = Nil Then
  Exit;
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   If vJSONObject <> Nil Then
    Result := TJSONObject(vJSONObject).Count;
  {$ELSE}
   If TJSONObject(vJSONObject).classname = 'TJSONObject' Then
    Begin
     If TJSONObject(vJSONObject).names <> Nil Then
      Result := TJSONObject(vJSONObject).names.length;
    End
   Else
    Result := TJSONArray(vJSONObject).length;
  {$IFEND}
 {$ELSE}
  If TJSONObject(vJSONObject).classname = 'TJSONObject' Then
   Begin
    If TJSONObject(vJSONObject).names <> Nil Then
     Result := TJSONObject(vJSONObject).names.length
   End
  Else
   Result := TJSONArray(vJSONObject).length;
 {$ENDIF}
End;

Procedure TDWJSONObject.PutPairN(Index  : String;
                                 Item   : TDWJSONPair);
Begin

End;

Procedure TDWJSONObject.PutPair(Index  : Integer;
                                Item   : TDWJSONPair);
Begin

End;

Function TDWJSONObject.ClassType : TClass;
Begin
 If TJSONObject(vJSONObject).ClassType      = TJSONObject Then
  Result := TDWJSONObject
 Else If TJSONObject(vJSONObject).ClassType = TJSONArray Then
  Result := TDWJSONArray
 Else If TJSONObject(vJSONObject).ClassType = TDWJSONBase Then
  Result := TDWJSONBase
 Else
  Result := TJSONObject(vJSONObject).ClassType;
End;

Function TDWJSONObject.ToJSON : String;
Begin
 Result := TJSONObject(vJSONObject).ToString;
End;

{ TDWJSONValue }

Function TDWJSONValue.GetPair(Index: Integer): TDWJSONPair;
Begin
 Result.Name      := TJSONObject(Self).ToString;
 Result.Value     := TJSONObject(Self).ToString;
 Result.ClassName := TJSONObject(Self).ClassName;
End;

procedure TDWJSONValue.PutPair(Index: Integer; Value: TDWJSONPair);
begin

end;

constructor TJSONBaseArrayClass.Create;
begin
 inherited;
end;

destructor TJSONBaseArrayClass.Destroy;
begin
  inherited;
end;

Function TJSONBaseArrayClass.GetObject: TJSONArray;
Begin
 Result := TJSONArray(vJSONObject);
End;

procedure TJSONBaseArrayClass.SetObject(Value: TJSONArray);
begin
 vJSONObject := TJSONBaseClass(Value);
end;

{ TJSONBaseObjectClass }

constructor TJSONBaseObjectClass.Create;
begin
 Inherited Create;
end;

destructor TJSONBaseObjectClass.Destroy;
begin
  inherited;
end;

Function TJSONBaseObjectClass.GetObject: TJSONObject;
Begin
 Result := TJSONObject(vJSONObject);
End;

Procedure TJSONBaseObjectClass.SetObject(Value: TJSONObject);
Begin
 vJSONObject := TJSONBaseClass(Value);
End;

{ TDWJSONBase }

constructor TDWJSONBase.Create(ParentJSON : TJSONBaseClass);
begin
 Inherited Create;
 vJSONObject := ParentJSON;
end;

Destructor TDWJSONBase.Destroy;
Begin

  inherited;
End;

function TDWJSONBase.PairCount: Integer;
begin
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   Result := TJSONObject(vJSONObject).Count;
  {$ELSE}
   Result := TJSONObject(vJSONObject).names.length;
  {$IFEND}
 {$ELSE}
  Result := TJSONObject(vJSONObject).names.length;
//  Result := TJSONObject(vJSONObject).Count;
 {$ENDIF}
end;

end.

