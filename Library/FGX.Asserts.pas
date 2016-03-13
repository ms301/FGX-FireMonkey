{*********************************************************************
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Autor: Brovin Y.D.
 * E-mail: y.brovin@gmail.com
 *
 ********************************************************************}

unit FGX.Asserts;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils;

type
  EAssertError = class(Exception);

resourcestring
  SObjectIsNotNilError = 'The not nil object is required, but instead of it the empty is received. ';
  SValueIsNotInRange = 'The current value "%f" is not in range [%f, %f]. ';
  SValueLess = 'The current value "%f" less than [%f].';
  SValueMore = 'The current value "%f" more than [%f].';
  SValueIsNotRequriedClass = 'The current object has invalid class. Expected receive "%s", but "%s" is received. ';
  SValuesIsNotEqual = 'Specified values "%d" and "%d" is not equal';
  SValuesIsTrue = 'Specified values is not True.' ;
  SValuesIsFalse = 'Specified values is not False.' ;

procedure AssertIsNotNil(const AValue: IInterface; const AMessage: string = ''); overload;
procedure AssertIsNotNil(const AValue: TObject; const AMessage: string = ''); overload;
procedure AssertIsNotNil(const AValue: TClass; const AMessage: string = ''); overload;
procedure AssertInRange(const AValue, ALow, AHight: Integer; const AMessage: string = ''); overload;
procedure AssertInRange(const AValue, ALow, AHight: Single; const AMessage: string = ''); overload;
procedure AssertLessThan(const AValue, AHigh: Integer; const AMessage: string = ''); overload;
procedure AssertLessThan(const AValue, AHigh: Single; const AMessage: string = ''); overload;
procedure AssertMoreThan(const AValue, ALow: Integer; const AMessage: string = ''); overload;
procedure AssertMoreThan(const AValue, ALow: Single; const AMessage: string = ''); overload;
procedure AssertIsClass(const AValue: TObject; const AClass: TClass; const AMessage: string = '');
procedure AssertEqual(const AValue1: Integer; const AValue2: Integer; const AMessage: string = '');
procedure AssertIsTrue(const AValue: Boolean; const AMessage: string = '');
procedure AssertIsFalse(const AValue: Boolean; const AMessage: string = '');

implementation

uses
  System.Math;

procedure AssertIsNotNil(const AValue: TObject; const AMessage: string = '');
begin
{$IFDEF DEBUG}
  if AValue = nil then
    raise EAssertError.Create(SObjectIsNotNilError + AMessage);
{$ENDIF}
end;

procedure AssertIsNotNil(const AValue: IInterface; const AMessage: string = '');
begin
{$IFDEF DEBUG}
  if AValue = nil then
    raise EAssertError.Create(SObjectIsNotNilError + AMessage);
{$ENDIF}
end;

procedure AssertIsNotNil(const AValue: TClass; const AMessage: string = ''); overload;
begin
{$IFDEF DEBUG}
  if AValue = nil then
    raise EAssertError.Create(SObjectIsNotNilError + AMessage);
{$ENDIF}
end;

procedure AssertInRange(const AValue, ALow, AHight: Integer; const AMessage: string = ''); overload;
begin
{$IFDEF DEBUG}
  if not InRange(AValue, ALow, AHight) then
    raise EAssertError.Create(Format(SValueIsNotInRange, [AValue, ALow, AHight]) + AMessage);
{$ENDIF}
end;

procedure AssertInRange(const AValue, ALow, AHight: Single; const AMessage: string = ''); overload;
begin
{$IFDEF DEBUG}
  if not InRange(AValue, ALow, AHight) then
    raise EAssertError.Create(Format(SValueIsNotInRange, [AValue, ALow, AHight]) + AMessage);
{$ENDIF}
end;

procedure AssertLessThan(const AValue, AHigh: Integer; const AMessage: string = ''); overload;
begin
{$IFDEF DEBUG}
  if AValue > AHigh then
    raise EAssertError.Create(Format(SValueLess, [AValue, AHigh]) + AMessage);
{$ENDIF}
end;

procedure AssertLessThan(const AValue, AHigh: Single; const AMessage: string = ''); overload;
begin
{$IFDEF DEBUG}
  if AValue > AHigh then
    raise EAssertError.Create(Format(SValueLess, [AValue, AHigh]) + AMessage);
{$ENDIF}
end;

procedure AssertMoreThan(const AValue, ALow: Integer; const AMessage: string = ''); overload;
begin
{$IFDEF DEBUG}
  if AValue < ALow then
    raise EAssertError.Create(Format(SValueLess, [AValue, ALow]) + AMessage);
{$ENDIF}
end;

procedure AssertMoreThan(const AValue, ALow: Single; const AMessage: string = ''); overload;
begin
{$IFDEF DEBUG}
  if AValue < ALow then
    raise EAssertError.Create(Format(SValueLess, [AValue, ALow]) + AMessage);
{$ENDIF}
end;

procedure AssertIsClass(const AValue: TObject; const AClass: TClass; const AMessage: string = '');
begin
{$IFDEF DEBUG}
  if not (AValue is AClass) then
    raise EAssertError.Create(Format(SValueIsNotRequriedClass, [AClass.ClassName, AValue.ClassName]) + AMessage);
{$ENDIF}
end;

procedure AssertEqual(const AValue1: Integer; const AValue2: Integer; const AMessage: string = '');
begin
{$IFDEF DEBUG}
  if AValue1 <> AValue2 then
    raise EAssertError.Create(Format(SValuesIsNotEqual, [AValue1, AValue2]) + AMessage);
{$ENDIF}
end;

procedure AssertIsTrue(const AValue: Boolean; const AMessage: string = '');
begin
{$IFDEF DEBUG}
  if not AValue then
    raise EAssertError.Create(SValuesIsTrue + AMessage);
{$ENDIF}
end;

procedure AssertIsFalse(const AValue: Boolean; const AMessage: string = '');
begin
{$IFDEF DEBUG}
  if AValue then
    raise EAssertError.Create(SValuesIsFalse + AMessage);
{$ENDIF}
end;


end.