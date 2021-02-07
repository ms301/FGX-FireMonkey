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

unit FmGX.Types;

interface

uses
  System.SysUtils, System.Generics.Defaults, System.Generics.Collections, System.Classes, System.Types,
  FmGX.Types.StateValue;

type

  EfgException = class(Exception);

{ Comparators }

  /// <summary>Ќабор компараторов дл€ разых типов значений</summary>
  TfgxEqualityComparators = class
  public
    /// <summary>ѕроверка равенства двух вещественных чисел типа Single</summary>
    class function SingleEquality(const Value1, Value2: Single): Boolean; static; inline;
  end;

{ TfgPersistent }

  TfgxPersistent = class(TPersistent)
  private
    [Weak] FOwner: TPersistent;
    FState: TfgStateValue;
    FOnInternalChanged: TNotifyEvent;
    FOnChange: TNotifyEvent;
    function GetState: TfgStateValue;
  protected
    function GetOwner: TPersistent; override;
    procedure DoInternalChanged; virtual;
    procedure DoChanged; virtual;
    property OnInternalChanged: TNotifyEvent read FOnInternalChanged;
  public
    constructor Create(AOwner: TPersistent); overload; virtual;
    constructor Create(AOwner: TPersistent; const AOnInternalChanged: TNotifyEvent); overload;
    destructor Destroy; override;
    procedure Changed;
    function AreDefaultValues: Boolean; virtual;
  public
    property Owner: TPersistent read FOwner;
    property State: TfgStateValue read GetState;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;
  TfgxPersistentClass = class of TfgxPersistent;

{ TfgPair }

  /// <summary>Ўаблонный класс дл€ хранени€ в ресурсах двух однотипных значений (размеры, координаты точки и тд).</summary>
  TfgxPair<T> = class(TfgxPersistent)
  private
    FValue1: T;
    FValue2: T;
    FDefaultValue1: T;
    FDefaultValue2: T;
    FComparator: TEqualityComparison<T>;
  protected
    procedure AssignTo(Dest: TPersistent); override;
    function EqualsValue(const Value1, Value2: T): Boolean; virtual;
    { Setter and Getters }
    procedure SetValue1(const Value: T);
    procedure SetValue2(const Value: T);
    function GetValue1: T; inline;
    function GetValue2: T; inline;
    function GetDefaultValue1: T; inline;
    function GetDefaultValue2: T; inline;
    property Comparator: TEqualityComparison<T> read FComparator write FComparator;
  public
    constructor Create(AOwner: TPersistent; const ADefaultV1, ADefaultV2: T; const AOnInternalChanged: TNotifyEvent); overload;
    procedure AfterConstruction; override;
  end;

  TfgxSinglePair = class(TfgxPair<Single>)
  protected
    function IsValue1Stored: Boolean; virtual;
    function IsValue2Stored: Boolean; virtual;
  public
    constructor Create(AOwner: TPersistent); override;
    function AreDefaultValues: Boolean; override;
  end;

  TfgxSingleSize = class(TfgxSinglePair)
  public
    function ToSizeF: TSizeF;
    property DefaultWidth: Single read GetDefaultValue1;
    property DefaultHeight: Single read GetDefaultValue2;
  published
    property Width: Single read GetValue1 write SetValue1 stored IsValue1Stored nodefault;
    property Height: Single read GetValue2 write SetValue2 stored IsValue2Stored nodefault;
  end;

  TfgxSinglePoint = class(TfgxSinglePair)
  public
    function ToPointF: TPointF;
    property DefaultX: Single read GetDefaultValue1;
    property DefaultY: Single read GetDefaultValue2;
  published
    property X: Single read GetValue1 write SetValue1 stored IsValue1Stored nodefault;
    property Y: Single read GetValue2 write SetValue2 stored IsValue2Stored nodefault;
  end;

{ TfgQuadruple }

  TfgxQuadruple<T> = class(TfgxPersistent)
  private
    FValue1: T;
    FValue2: T;
    FValue3: T;
    FValue4: T;
    FDefaultValue1: T;
    FDefaultValue2: T;
    FDefaultValue3: T;
    FDefaultValue4: T;
    FComparator: TEqualityComparison<T>;
  protected
    procedure AssignTo(Dest: TPersistent); override;
    function EqualsValue(const Value1, Value2: T): Boolean; virtual;
    { Setter and Getters }
    procedure SetValue1(const Value: T);
    procedure SetValue2(const Value: T);
    procedure SetValue3(const Value: T);
    procedure SetValue4(const Value: T);
    function GetValue1: T; inline;
    function GetValue2: T; inline;
    function GetValue3: T; inline;
    function GetValue4: T; inline;
    function GetDefaultValue1: T; inline;
    function GetDefaultValue2: T; inline;
    function GetDefaultValue3: T; inline;
    function GetDefaultValue4: T; inline;
    property Comparator: TEqualityComparison<T> read FComparator write FComparator;
  public
    constructor Create(AOwner: TPersistent; const ADefaultV1, ADefaultV2, ADefaultV3, ADefaultV4: T; const AOnInternalChanged: TNotifyEvent); overload;
    procedure AfterConstruction; override;
  end;

  TfgxSingleQuadruple = class(TfgxQuadruple<Single>)
  protected
    function IsValue1Stored: Boolean; virtual;
    function IsValue2Stored: Boolean; virtual;
    function IsValue3Stored: Boolean; virtual;
    function IsValue4Stored: Boolean; virtual;
  public
    constructor Create(AOwner: TPersistent); override;
    function AreDefaultValues: Boolean; override;
  end;

  TfgxSingleIndents = class(TfgxSingleQuadruple)
  public
    function ToRectF: TRectF;
    property DefaultLeft: Single read GetDefaultValue1;
    property DefaultRight: Single read GetDefaultValue2;
    property DefaultTop: Single read GetDefaultValue3;
    property DefaultBottom: Single read GetDefaultValue4;
  published
    property Left: Single read GetValue1 write SetValue1 stored IsValue1Stored nodefault;
    property Right: Single read GetValue2 write SetValue2 stored IsValue2Stored nodefault;
    property Top: Single read GetValue3 write SetValue3 stored IsValue3Stored nodefault;
    property Bottom: Single read GetValue4 write SetValue4 stored IsValue4Stored nodefault;
  end;

{ TfgCollection }

  TfgxCollection = class;
  TfgxCollectionNotification = (Added, Extracting, Deleting, Updated, OrderChanged);
  TfgxCollectionChanged = procedure (Collection: TfgxCollection; Item: TCollectionItem; const Action: TfgxCollectionNotification) of object;

  TfgxCollection = class(TCollection)
  private
    FOwner: TPersistent;
    FOnInternalChanged: TfgxCollectionChanged;
  protected
    procedure DoInternalChanged(Item: TCollectionItem; const Action: TfgxCollectionNotification); virtual;
    function CanInternalChange: Boolean;
    { inherited }
    procedure Notify(Item: TCollectionItem; Action: TfgxCollectionNotification); overload;
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); overload; override;
    procedure Update(Item: TCollectionItem); override;
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent; const AItemClass: TCollectionItemClass; const AOnInternalChanged: TfgxCollectionChanged); overload;
    constructor Create(AItemClass: TCollectionItemClass; const AOnInternalChanged: TfgxCollectionChanged); overload;
  end;

  TfgxCollectionItem = class(TCollectionItem)
  protected
    procedure SetIndex(Value: Integer); override;
  end;

implementation

uses
  System.Math, FmGX.Asserts;

{ TfgPair<T> }

procedure TfgxPair<T>.AfterConstruction;
begin
  inherited;
  TfgxAssert.IsTrue(Assigned(Comparator), 'Warning. You should specify comparator for correct working');
end;

procedure TfgxPair<T>.AssignTo(Dest: TPersistent);
var
  DestSize: TfgxPair<T>;
begin
  if Dest is TfgxPair<T> then
  begin
    DestSize := Dest as TfgxPair<T>;
    DestSize.FValue1 := GetValue1;
    DestSize.FValue2 := GetValue2;
    DestSize.FDefaultValue1 := GetDefaultValue1;
    DestSize.FDefaultValue2 := GetDefaultValue2;
    DestSize.FComparator := FComparator;
  end
  else
    inherited AssignTo(Dest);
end;

function TfgxPair<T>.EqualsValue(const Value1, Value2: T): Boolean;
begin
  if Assigned(FComparator) then
    Result := FComparator(Value1, Value2)
  else
    Result := False;
end;

function TfgxPair<T>.GetDefaultValue1: T;
begin
  Result := FDefaultValue1;
end;

function TfgxPair<T>.GetDefaultValue2: T;
begin
  Result := FDefaultValue2;
end;

function TfgxPair<T>.GetValue1: T;
begin
  Result := FValue1;
end;

function TfgxPair<T>.GetValue2: T;
begin
  Result := FValue2;
end;

constructor TfgxPair<T>.Create(AOwner: TPersistent; const ADefaultV1, ADefaultV2: T; const AOnInternalChanged: TNotifyEvent);
begin
  inherited Create(AOwner, AOnInternalChanged);
  FValue1 := ADefaultV1;
  FValue2 := ADefaultV2;
  FDefaultValue1 := ADefaultV1;
  FDefaultValue2 := ADefaultV2;
end;

procedure TfgxPair<T>.SetValue1(const Value: T);
begin
  if not EqualsValue(FValue1, Value) then
  begin
    FValue1 := Value;
    DoInternalChanged;
    DoChanged;
  end;
end;

procedure TfgxPair<T>.SetValue2(const Value: T);
begin
  if not EqualsValue(FValue2, Value) then
  begin
    FValue2 := Value;
    DoInternalChanged;
    DoChanged;
  end;
end;

{ TfgEqualityComparators }

class function TfgxEqualityComparators.SingleEquality(const Value1, Value2: Single): Boolean;
begin
  Result := SameValue(Value1, Value2, Single.Epsilon);
end;

{ TfgPersistent }

function TfgxPersistent.GetState: TfgStateValue;
begin
  if FState = nil then
    FState := TfgStateValue.Create(
      procedure
      begin
        Changed;
      end);
  Result := FState;
end;

function TfgxPersistent.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TfgxPersistent.DoChanged;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TfgxPersistent.DoInternalChanged;
begin
  if Assigned(FOnInternalChanged) then
    FOnInternalChanged(Self);
end;

constructor TfgxPersistent.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
end;

procedure TfgxPersistent.Changed;
begin
  if (FState = nil) or (FState <> nil) and not FState.IsUpdating then
  begin
    DoInternalChanged;
    DoChanged;
  end;
end;

constructor TfgxPersistent.Create(AOwner: TPersistent; const AOnInternalChanged: TNotifyEvent);
begin
  FOnInternalChanged := AOnInternalChanged;
  Create(AOwner);
end;

destructor TfgxPersistent.Destroy;
begin
  FreeAndNil(FState);
  FOnInternalChanged := nil;
  FOnChange := nil;
  inherited Destroy;
end;

function TfgxPersistent.AreDefaultValues: Boolean;
begin
  Result := False;
end;

{ TfgCollection }

constructor TfgxCollection.Create(AOwner: TPersistent; const AItemClass: TCollectionItemClass;
  const AOnInternalChanged: TfgxCollectionChanged);
begin
  TfgxAssert.IsNotNil(AItemClass);

  Create(AItemClass);
  FOwner := AOwner;
  FOnInternalChanged := AOnInternalChanged;
end;

function TfgxCollection.CanInternalChange: Boolean;
var
  ForbiddenStates: TComponentState;
begin
  if Owner is TComponent then
  begin
    ForbiddenStates := [csLoading, csDestroying] * TComponent(Owner).ComponentState;
    Result := ForbiddenStates = [];
  end
  else
    Result := True;
end;

constructor TfgxCollection.Create(AItemClass: TCollectionItemClass; const AOnInternalChanged: TfgxCollectionChanged);
begin
  Create(nil, AItemClass, AOnInternalChanged);
end;

procedure TfgxCollection.DoInternalChanged(Item: TCollectionItem; const Action: TfgxCollectionNotification);
begin
  if Assigned(FOnInternalChanged) and (Owner <> nil) then
    FOnInternalChanged(Self, Item, Action);
end;

function TfgxCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TfgxCollection.Notify(Item: TCollectionItem; Action: TfgxCollectionNotification);
begin
  if CanInternalChange then
    DoInternalChanged(Item, Action);
end;

procedure TfgxCollection.Notify(Item: TCollectionItem; Action: TCollectionNotification);
var
  Notification: TfgxCollectionNotification;
begin
  case Action of
    cnAdded: Notification := TfgxCollectionNotification.Added;
    cnExtracting: Notification := TfgxCollectionNotification.Extracting;
    cnDeleting: Notification := TfgxCollectionNotification.Deleting;
  else
    raise Exception.Create('Unknown value of [System.Classes.TCollectionNotification])');
  end;
  Notify(Item, Notification);
  inherited;
end;

procedure TfgxCollection.Update(Item: TCollectionItem);
begin
  inherited;
  if (Item <> nil) and CanInternalChange then
    DoInternalChanged(Item, TfgxCollectionNotification.Updated);
end;

{ TfgSingleValue }

function TfgxSinglePair.AreDefaultValues: Boolean;
begin
  Result := not IsValue1Stored and not IsValue2Stored;
end;

constructor TfgxSinglePair.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  Comparator := TfgxEqualityComparators.SingleEquality;
end;

function TfgxSinglePair.IsValue1Stored: Boolean;
begin
  Result := not SameValue(GetValue1, GetDefaultValue1, Single.Epsilon);
end;

function TfgxSinglePair.IsValue2Stored: Boolean;
begin
  Result := not SameValue(GetValue2, GetDefaultValue2, Single.Epsilon);
end;

{ TfgQuadruple<T> }

procedure TfgxQuadruple<T>.AfterConstruction;
begin
  inherited;
  TfgxAssert.IsTrue(Assigned(Comparator), 'Warning. You should specify comparator for correct working');
end;

procedure TfgxQuadruple<T>.AssignTo(Dest: TPersistent);
var
  DestQuadruple: TfgxQuadruple<T>;
begin
  if Dest is TfgxQuadruple<T> then
  begin
    DestQuadruple := Dest as TfgxQuadruple<T>;
    DestQuadruple.FValue1 := GetValue1;
    DestQuadruple.FValue2 := GetValue2;
    DestQuadruple.FValue3 := GetValue3;
    DestQuadruple.FValue4 := GetValue4;
    DestQuadruple.FDefaultValue1 := GetDefaultValue1;
    DestQuadruple.FDefaultValue2 := GetDefaultValue2;
    DestQuadruple.FDefaultValue3 := GetDefaultValue3;
    DestQuadruple.FDefaultValue4 := GetDefaultValue4;
  end
  else
    inherited AssignTo(Dest);
end;

constructor TfgxQuadruple<T>.Create(AOwner: TPersistent; const ADefaultV1, ADefaultV2, ADefaultV3, ADefaultV4: T;
  const AOnInternalChanged: TNotifyEvent);
begin
  inherited Create(AOwner, AOnInternalChanged);
  FDefaultValue1 := ADefaultV1;
  FDefaultValue2 := ADefaultV2;
  FDefaultValue3 := ADefaultV3;
  FDefaultValue4 := ADefaultV4;
  FValue1 := ADefaultV1;
  FValue2 := ADefaultV2;
  FValue3 := ADefaultV3;
  FValue4 := ADefaultV4;
end;

function TfgxQuadruple<T>.EqualsValue(const Value1, Value2: T): Boolean;
begin
  if Assigned(FComparator) then
    Result := FComparator(Value1, Value2)
  else
    Result := False;
end;

function TfgxQuadruple<T>.GetDefaultValue1: T;
begin
  Result := FDefaultValue1;
end;

function TfgxQuadruple<T>.GetDefaultValue2: T;
begin
  Result := FDefaultValue2;
end;

function TfgxQuadruple<T>.GetDefaultValue3: T;
begin
  Result := FDefaultValue3;
end;

function TfgxQuadruple<T>.GetDefaultValue4: T;
begin
  Result := FDefaultValue4;
end;

function TfgxQuadruple<T>.GetValue1: T;
begin
  Result := FValue1;
end;

function TfgxQuadruple<T>.GetValue2: T;
begin
  Result := FValue2;
end;

function TfgxQuadruple<T>.GetValue3: T;
begin
  Result := FValue3;
end;

function TfgxQuadruple<T>.GetValue4: T;
begin
  Result := FValue4;
end;

procedure TfgxQuadruple<T>.SetValue1(const Value: T);
begin
  if not EqualsValue(FValue1, Value) then
  begin
    FValue1 := Value;
    DoInternalChanged;
    DoChanged;
  end;
end;

procedure TfgxQuadruple<T>.SetValue2(const Value: T);
begin
  if not EqualsValue(FValue2, Value) then
  begin
    FValue2 := Value;
    DoInternalChanged;
    DoChanged;
  end;
end;

procedure TfgxQuadruple<T>.SetValue3(const Value: T);
begin
  if not EqualsValue(FValue3, Value) then
  begin
    FValue3 := Value;
    DoInternalChanged;
    DoChanged;
  end;
end;

procedure TfgxQuadruple<T>.SetValue4(const Value: T);
begin
  if not EqualsValue(FValue4, Value) then
  begin
    FValue4 := Value;
    DoInternalChanged;
    DoChanged;
  end;
end;

{ TfgSingleQuadruple }

function TfgxSingleQuadruple.AreDefaultValues: Boolean;
begin
  Result := not IsValue1Stored and not IsValue2Stored and not IsValue3Stored and not IsValue4Stored;
end;

constructor TfgxSingleQuadruple.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  Comparator := TfgxEqualityComparators.SingleEquality;
end;

function TfgxSingleQuadruple.IsValue1Stored: Boolean;
begin
  Result := not SameValue(GetValue1, GetDefaultValue1);
end;

function TfgxSingleQuadruple.IsValue2Stored: Boolean;
begin
  Result := not SameValue(GetValue2, GetDefaultValue2);
end;

function TfgxSingleQuadruple.IsValue3Stored: Boolean;
begin
  Result := not SameValue(GetValue3, GetDefaultValue3);
end;

function TfgxSingleQuadruple.IsValue4Stored: Boolean;
begin
  Result := not SameValue(GetValue4, GetDefaultValue4);
end;

{ TfgSingleSize }

function TfgxSingleSize.ToSizeF: TSizeF;
begin
  Result := TSizeF.Create(Width, Height);
end;

{ TfgSinglePoint }

function TfgxSinglePoint.ToPointF: TPointF;
begin
  Result := TPointF.Create(X, Y);
end;

{ TfgSingleIndents }

function TfgxSingleIndents.ToRectF: TRectF;
begin
  Result := TRectF.Create(Left, Top, Right, Bottom);
end;

{ TfgCollectionItem }

procedure TfgxCollectionItem.SetIndex(Value: Integer);
begin
  TfgxAssert.IsClass(Collection, TfgxCollection);

  inherited;
  TfgxCollection(Collection).Notify(Self, TfgxCollectionNotification.OrderChanged);
end;

end.
