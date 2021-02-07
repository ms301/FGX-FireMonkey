{ *********************************************************************
  *
  * This Source Code Form is subject to the terms of the Mozilla Public
  * License, v. 2.0. If a copy of the MPL was not distributed with this
  * file, You can obtain one at http://mozilla.org/MPL/2.0/.
  *
  * Autor: Brovin Y.D.
  * E-mail: y.brovin@gmail.com
  *
  ******************************************************************** }

unit FmGX.Asserts;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils;

type
  EfgAssertError = class(Exception);

type

  TfgxAssert = class
  public
    class procedure IsTrue(const AValue: Boolean; const AMessage: string = '');
    class procedure IsFalse(const AValue: Boolean; const AMessage: string = '');
    class procedure IsNotNil(const AValue: IInterface; const AMessage: string = ''); overload;
    class procedure IsNotNil(const AValue: TObject; const AMessage: string = ''); overload;
    class procedure IsNotNil(const AValue: TClass; const AMessage: string = ''); overload;
    class procedure IsClass(const AValue: TObject; const AClass: TClass; const AMessage: string = '');
    class procedure Implements(const AValue: TObject; const AInterface: IInterface; const AMessage: string = '');
    class procedure InRange(const AValue, ALow, AHight: Integer; const AMessage: string = ''); overload;
    class procedure InRange(const AValue, ALow, AHight: Extended; const AMessage: string = ''); overload;
    class procedure InRange(const AValue, ALow, AHight: Single; const AMessage: string = ''); overload;
    class procedure StrickLessThan(const AValue, AHigh: Integer; const AMessage: string = ''); overload;
    class procedure StrickLessThan(const AValue, AHigh: Extended; const AMessage: string = ''); overload;
    class procedure StrickLessThan(const AValue, AHigh: Single; const AMessage: string = ''); overload;
    class procedure StrickMoreThan(const AValue, ALow: Integer; const AMessage: string = ''); overload;
    class procedure StrickMoreThan(const AValue, ALow: Extended; const AMessage: string = ''); overload;
    class procedure StrickMoreThan(const AValue, ALow: Single; const AMessage: string = ''); overload;
    class procedure LessAndEqualThan(const AValue, AHigh: Integer; const AMessage: string = ''); overload;
    class procedure LessAndEqualThan(const AValue, AHigh: Extended; const AMessage: string = ''); overload;
    class procedure LessAndEqualThan(const AValue, AHigh: Single; const AMessage: string = ''); overload;
    class procedure MoreAndEqulThan(const AValue, ALow: Integer; const AMessage: string = ''); overload;
    class procedure MoreAndEqulThan(const AValue, ALow: Extended; const AMessage: string = ''); overload;
    class procedure MoreAndEqulThan(const AValue, ALow: Single; const AMessage: string = ''); overload;
    class procedure AreEqual(const AValue1, AValue2: Integer; const AMessage: string = ''); overload;
    class procedure AreEqual(const AValue1, AValue2: Extended; const AMessage: string = ''); overload;
    class procedure AreEqual(const AValue1, AValue2: Single; const AMessage: string = ''); overload;
  end;

implementation

uses
  System.Math, System.Rtti;

function IInterfaceToGUID(const AInterface: IInterface): TGUID;
begin
{ TODO -oBrovin Y.D. : Подумать о том, как сконвертировать интерфейс по ссылки в GUID }
//  Result := TRttiInterfaceType(TRttiContext.Create.GetType(TypeInfo(AInterface))).GUID;
end;

function IInterfaceToString(const AInterface: IInterface): string;
begin
  Result := GUIDToString(IInterfaceToGUID(AInterface));
end;

{ TfgAssert }

class procedure TfgxAssert.AreEqual(const AValue1, AValue2: Single; const AMessage: string);
begin
{$IFDEF DEBUG}
  if not SameValue(AValue1, AValue2, Single.Epsilon) then
    raise EfgAssertError.CreateFmt('Specified values [%f] and [%f] are not equal. %s', [AValue1, AValue2,
      AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.AreEqual(const AValue1, AValue2: Extended; const AMessage: string);
begin
{$IFDEF DEBUG}
  if not SameValue(AValue1, AValue2, Extended.Epsilon) then
    raise EfgAssertError.CreateFmt('Specified values [%f] and [%f] are not equal. %s', [AValue1, AValue2,
      AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.AreEqual(const AValue1, AValue2: Integer; const AMessage: string);
begin
{$IFDEF DEBUG}
  if AValue1 <> AValue2 then
    raise EfgAssertError.CreateFmt('Specified values [%d] and [%d] are not equal. %s', [AValue1, AValue2,
      AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.Implements(const AValue: TObject; const AInterface: IInterface; const AMessage: string);
begin
{$IFDEF DEBUG}
  if not Supports(AValue, IInterfaceToGUID(AInterface)) then
    raise EfgAssertError.CreateFmt('[%s] does not implements interface with GUID [%s]. %s', [AValue.ClassName,
      IInterfaceToString(AInterface), AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.InRange(const AValue, ALow, AHight: Single; const AMessage: string);
begin
{$IFDEF DEBUG}
  if not System.Math.InRange(AValue, ALow, AHight) then
    raise EfgAssertError.CreateFmt('The current value [%f] is not in range [%f, %f]. %s', [AValue, ALow, AHight,
      AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.InRange(const AValue, ALow, AHight: Extended; const AMessage: string);
begin
{$IFDEF DEBUG}
  if not System.Math.InRange(AValue, ALow, AHight) then
    raise EfgAssertError.CreateFmt('The current value [%f] is not in range [%f, %f]. %s', [AValue, ALow, AHight,
      AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.InRange(const AValue, ALow, AHight: Integer; const AMessage: string);
begin
{$IFDEF DEBUG}
  if not System.Math.InRange(AValue, ALow, AHight) then
    raise EfgAssertError.CreateFmt('The current value [%d] is not in range [%d, %d]. %s', [AValue, ALow, AHight,
      AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.IsClass(const AValue: TObject; const AClass: TClass; const AMessage: string);
begin
{$IFDEF DEBUG}
  if not (AValue is AClass) then
    raise EfgAssertError.CreateFmt('The current object has invalid class. Expected receive [%s], but [%s] is received. %s',
      [AClass.ClassName, AValue.ClassName, AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.IsFalse(const AValue: Boolean; const AMessage: string);
begin
{$IFDEF DEBUG}
  if AValue then
    raise EfgAssertError.CreateFmt('Specified conditional should be False. %s', [AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.IsNotNil(const AValue: TObject; const AMessage: string);
begin
{$IFDEF DEBUG}
  if AValue = nil then
    raise EfgAssertError.CreateFmt('The not nil object is required, but instead of it the empty is received. %s',
      [AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.IsNotNil(const AValue: IInterface; const AMessage: string);
begin
{$IFDEF DEBUG}
  if AValue = nil then
    raise EfgAssertError.CreateFmt('The not nil object is required, but instead of it the empty is received. %s',
      [AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.IsNotNil(const AValue: TClass; const AMessage: string);
begin
{$IFDEF DEBUG}
  if AValue = nil then
    raise EfgAssertError.CreateFmt('The not nil object is required, but instead of it the empty is received. %s',
      [AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.IsTrue(const AValue: Boolean; const AMessage: string);
begin
{$IFDEF DEBUG}
  if not AValue then
    raise EfgAssertError.CreateFmt('Specified conditional should be True. %s', [AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.LessAndEqualThan(const AValue, AHigh: Integer; const AMessage: string);
begin
{$IFDEF DEBUG}
  if AValue > AHigh then
    raise EfgAssertError.CreateFmt('The current value [%d] should be less or equal than [%d]. %s', [AValue, AHigh, AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.LessAndEqualThan(const AValue, AHigh: Extended; const AMessage: string);
begin
{$IFDEF DEBUG}
  if AValue > AHigh then
    raise EfgAssertError.CreateFmt('The current value [%f] should be less or equal than [%f]. %s', [AValue, AHigh, AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.LessAndEqualThan(const AValue, AHigh: Single; const AMessage: string);
begin
{$IFDEF DEBUG}
  if AValue > AHigh then
    raise EfgAssertError.CreateFmt('The current value [%f] should be less or equal than [%f]. %s', [AValue, AHigh, AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.MoreAndEqulThan(const AValue, ALow: Integer; const AMessage: string);
begin
{$IFDEF DEBUG}
  if ALow > AValue then
    raise EfgAssertError.CreateFmt('The current value [%d] should be more or equal than [%d]. %s', [AValue, ALow, AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.MoreAndEqulThan(const AValue, ALow: Extended; const AMessage: string);
begin
{$IFDEF DEBUG}
  if ALow > AValue then
    raise EfgAssertError.CreateFmt('The current value [%f] should be more or equal than [%f]. %s', [AValue, ALow, AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.MoreAndEqulThan(const AValue, ALow: Single; const AMessage: string);
begin
{$IFDEF DEBUG}
  if ALow > AValue then
    raise EfgAssertError.CreateFmt('The current value [%f] should be more or equal than [%f]. %s', [AValue, ALow, AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.StrickLessThan(const AValue, AHigh: Extended; const AMessage: string);
begin
{$IFDEF DEBUG}
  if AValue >= AHigh then
    raise EfgAssertError.CreateFmt('The current value [%f] should be less than [%f]. %s', [AValue, AHigh, AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.StrickLessThan(const AValue, AHigh: Single; const AMessage: string);
begin
{$IFDEF DEBUG}
  if AValue >= AHigh then
    raise EfgAssertError.CreateFmt('The current value [%f] should be less than [%f]. %s', [AValue, AHigh, AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.StrickLessThan(const AValue, AHigh: Integer; const AMessage: string);
begin
{$IFDEF DEBUG}
  if AValue >= AHigh then
    raise EfgAssertError.CreateFmt('The current value [%d] should be less than [%d]. %s', [AValue, AHigh, AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.StrickMoreThan(const AValue, ALow: Single; const AMessage: string);
begin
{$IFDEF DEBUG}
  if ALow >= AValue then
    raise EfgAssertError.CreateFmt('The current value [%f] should be more than [%f]. %s', [AValue, ALow, AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.StrickMoreThan(const AValue, ALow: Integer; const AMessage: string);
begin
{$IFDEF DEBUG}
  if ALow >= AValue then
    raise EfgAssertError.CreateFmt('The current value [%d] should be more than [%d]. %s', [AValue, ALow, AMessage]) at ReturnAddress;
{$ENDIF}
end;

class procedure TfgxAssert.StrickMoreThan(const AValue, ALow: Extended; const AMessage: string);
begin
{$IFDEF DEBUG}
  if ALow >= AValue then
    raise EfgAssertError.CreateFmt('The current value [%f] should be more than [%f]. %s', [AValue, ALow, AMessage]) at ReturnAddress;
{$ENDIF}
end;

end.
