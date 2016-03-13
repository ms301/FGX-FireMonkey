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

unit FGX.Types;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Defaults, System.Generics.Collections;

type

  { TfgPair }

  /// <summary>
  ///   Ўаблонный класс дл€ хранени€ в ресурсах двух однотипных значений (размеры, координаты точки и тд).
  /// </summary>
  TfgPair<T> = class(TPersistent)
  private
    FValue1: T;
    FValue2: T;
    FComparator: TEqualityComparison<T>;
    FOnChange: TNotifyEvent;
  protected
    procedure DoChange; virtual;
    procedure AssignTo(Dest: TPersistent); override;
    function EqualsValue(const Value1, Value2: T): Boolean; virtual;
    { Setter and Getters }
    procedure SetValue1(const Value: T);
    procedure SetValue2(const Value: T);
    function GetValue1: T; inline;
    function GetValue2: T; inline;
  public
    constructor Create(const AX, AY: T; AComparator: TEqualityComparison<T> = nil); virtual;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TfgSingleSize = class (TfgPair<Single>)
  published
    property Width: Single read GetValue1 write SetValue1;
    property Height: Single read GetValue2 write SetValue2;
  end;

  { Comparators }

  /// <summary>
  ///   Ќабор компараторов дл€ разых типов значений
  /// </summary>
  TfgEqualityComparators = class
  public
    /// <summary>
    ///   ѕроверка равенства двух вещественных чисел типа Single
    /// </summary>
    class function SingleEquality(const Value1, Value2: Single): Boolean; static; inline;
  end;

{ TfgPersistent }

  TfgPersistent = class (TPersistent)
  private
    [Weak] FOwner: TComponent;
    FOnInternalChanged: TNotifyEvent;
  protected
    function GetOwner: TPersistent; override;
    procedure DoInternalChanged; virtual;
    property Owner: TComponent read FOwner;
  public
    constructor Create(AOwner: TComponent); overload; virtual;
    constructor Create(AOwner: TComponent; const AOnInternalChanged: TNotifyEvent); overload;
    destructor Destroy; override;
    function IsDefaultValues: Boolean; virtual;
  end;

implementation

uses
  System.Math, FGX.Consts;

{ TfgPair<T> }

procedure TfgPair<T>.AssignTo(Dest: TPersistent);
var
  DestSize: TfgPair<T>;
begin
  if Dest is TfgPair<T> then
  begin
    DestSize := Dest as TfgPair<T>;
    DestSize.FValue1 := GetValue1;
    DestSize.FValue2 := GetValue2;
  end
  else
    inherited AssignTo(Dest);
end;

function TfgPair<T>.EqualsValue(const Value1, Value2: T): Boolean;
begin
  if Assigned(FComparator) then
    Result := FComparator(Value1, Value2)
  else
    Result := False;
end;

function TfgPair<T>.GetValue1: T;
begin
  Result := FValue1;
end;

function TfgPair<T>.GetValue2: T;
begin
  Result := FValue2;
end;

constructor TfgPair<T>.Create(const AX, AY: T; AComparator: TEqualityComparison<T> = nil);
begin
  FValue2 := AX;
  FValue1 := AY;
  FComparator := AComparator;
end;

procedure TfgPair<T>.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TfgPair<T>.SetValue1(const Value: T);
begin
  if not EqualsValue(FValue1, Value) then
  begin
    FValue1 := Value;
    DoChange;
  end;
end;

procedure TfgPair<T>.SetValue2(const Value: T);
begin
  if not EqualsValue(FValue2, Value) then
  begin
    FValue2 := Value;
    DoChange;
  end;
end;

{ TfgEqualityComparators }

class function TfgEqualityComparators.SingleEquality(const Value1, Value2: Single): Boolean;
begin
  Result := SameValue(Value1, Value2, EPSILON_SINGLE);
end;

{ TfgPersistent }

constructor TfgPersistent.Create(AOwner: TComponent);
begin
  inherited Create;
  FOwner := AOwner;
end;

constructor TfgPersistent.Create(AOwner: TComponent; const AOnInternalChanged: TNotifyEvent);
begin
  Create(AOwner);
  FOnInternalChanged := AOnInternalChanged;
end;

destructor TfgPersistent.Destroy;
begin
  FOnInternalChanged := nil;
  inherited Destroy;
end;

procedure TfgPersistent.DoInternalChanged;
begin
  if Assigned(FOnInternalChanged) then
    FOnInternalChanged(Self);
end;

function TfgPersistent.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TfgPersistent.IsDefaultValues: Boolean;
begin
  Result := False;
end;

end.
