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

unit FmGX.Animations;

interface

uses
  System.Types, System.Classes, FMX.Ani, FMX.Types, FMX.Types3D, FMX.Styles.Objects, FMX.Forms,
  FmGX.Consts;

type

{ TfgCustomPropertyAnimation }

  TfgxCustomPropertyAnimation<T: TPersistent, constructor> = class(TCustomPropertyAnimation)
  public const
    DefaultDuration = 0.2;
    DefaultAnimationType = TAnimationType.In;
    DefaultAutoReverse = False;
    DefaultEnabled = False;
    DefaultInterpolation = TInterpolationType.Linear;
    DefaultInverse = False;
    DefaultLoop = False;
    DefaultStartFromCurrent = False;
  private
    FStartFromCurrent: Boolean;
    FStartValue: T;
    FStopValue: T;
    FCurrentValue: T;
  protected
    { Bug of Compiler with generics. Compiler cannot mark this property as published and show it in IDE.
      So i put them in protected and public in each successor declare property }
    procedure SetStartValue(const Value: T);
    procedure SetStopValue(const Value: T);
    function GetStartValue: T;
    function GetStopValue: T;
  protected
    procedure FirstFrame; override;
    procedure ProcessAnimation; override;
    procedure DefineCurrentValue(const ANormalizedTime: Single); virtual; abstract;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property CurrentValue: T read FCurrentValue;
    property StartFromCurrent: Boolean read FStartFromCurrent write FStartFromCurrent default False;
    property StartValue: T read GetStartValue write SetStartValue;
    property StopValue: T read GetStopValue write SetStopValue;
  end;

{ TfgPositionAnimation }

  TfgxCustomPositionAnimation = class(TfgxCustomPropertyAnimation<TPosition>)
  protected
    procedure DefineCurrentValue(const ANormalizedTime: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
    property StartValue: TPosition read GetStartValue write SetStartValue;
    property StopValue: TPosition read GetStopValue write SetStopValue;
  end;

  [ComponentPlatformsAttribute(fgAllPlatform)]
  TfgxPositionAnimation = class(TfgxCustomPositionAnimation)
  published
    property AnimationType default TfgxCustomPositionAnimation.DefaultAnimationType;
    property AutoReverse default TfgxCustomPositionAnimation.DefaultAutoReverse;
    property Enabled default TfgxCustomPositionAnimation.DefaultEnabled;
    property Delay;
    property Duration nodefault;
    property Interpolation default TfgxCustomPositionAnimation.DefaultInterpolation;
    property Inverse default TfgxCustomPositionAnimation.DefaultInverse;
    property Loop default TfgxCustomPositionAnimation.DefaultLoop;
    property PropertyName;
    property StartValue;
    property StartFromCurrent default TfgxCustomPositionAnimation.DefaultStartFromCurrent;
    property StopValue;
    property Trigger;
    property TriggerInverse;
    property OnProcess;
    property OnFinish;
  end;

{ TfgPosition3DAnimation }

  TfgxCustomPosition3DAnimation = class(TfgxCustomPropertyAnimation<TPosition3D>)
  protected
    procedure DefineCurrentValue(const ANormalizedTime: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
    property StartValue: TPosition3D read GetStartValue write SetStartValue;
    property StopValue: TPosition3D read GetStopValue write SetStopValue;
  end;

  [ComponentPlatformsAttribute(fgAllPlatform)]
  TfgxPosition3DAnimation = class(TfgxCustomPosition3DAnimation)
  published
    property AnimationType default TfgxCustomPosition3DAnimation.DefaultAnimationType;
    property AutoReverse default TfgxCustomPosition3DAnimation.DefaultAutoReverse;
    property Enabled default TfgxCustomPosition3DAnimation.DefaultEnabled;
    property Delay;
    property Duration nodefault;
    property Interpolation default TfgxCustomPosition3DAnimation.DefaultInterpolation;
    property Inverse default TfgxCustomPosition3DAnimation.DefaultInverse;
    property Loop default TfgxCustomPosition3DAnimation.DefaultLoop;
    property PropertyName;
    property StartValue;
    property StartFromCurrent default TfgxCustomPosition3DAnimation.DefaultStartFromCurrent;
    property StopValue;
    property Trigger;
    property TriggerInverse;
    property OnProcess;
    property OnFinish;
  end;

{ TfgCustomBitmapLinkAnimation }

  TfgxBitmapLinkAnimationOption = (AnimateSourceRect, AnimateCapInsets);
  TfgxBitmapLinkAnimationOptions = set of TfgxBitmapLinkAnimationOption;

  TfgxCustomBitmapLinkAnimation = class(TfgxCustomPropertyAnimation<TBitmapLinks>)
  public const
    DefaultOptions = [TfgxBitmapLinkAnimationOption.AnimateSourceRect, TfgxBitmapLinkAnimationOption.AnimateCapInsets];
  private
    FOptions: TfgxBitmapLinkAnimationOptions;
    FStopValue: TBitmapLinks;
    FStartValue: TBitmapLinks;
    procedure SetStartValue(const Value: TBitmapLinks);
    procedure SetStopValue(const Value: TBitmapLinks);
  protected
    procedure DefineCurrentValue(const ANormalizedTime: Single); override;
    procedure ProcessAnimation; override;
    function GetSceneScale: Single;
  public
    constructor Create(AOwner: TComponent); override;
    property Options: TfgxBitmapLinkAnimationOptions read FOptions write FOptions default DefaultOptions;
    property StartValue: TBitmapLinks read GetStartValue write SetStartValue;
    property StopValue: TBitmapLinks read GetStopValue write SetStopValue;
  end;

  [ComponentPlatformsAttribute(fgAllPlatform)]
  TfgxBitmapLinkAnimation = class(TfgxCustomBitmapLinkAnimation)
  published
    property AnimationType default TfgxCustomBitmapLinkAnimation.DefaultAnimationType;
    property AutoReverse default TfgxCustomBitmapLinkAnimation.DefaultAutoReverse;
    property Enabled default TfgxCustomBitmapLinkAnimation.DefaultEnabled;
    property Delay;
    property Duration nodefault;
    property Interpolation default TfgxCustomBitmapLinkAnimation.DefaultInterpolation;
    property Inverse default TfgxCustomBitmapLinkAnimation.DefaultInverse;
    property Loop default TfgxCustomBitmapLinkAnimation.DefaultLoop;
    property Options;
    property PropertyName;
    property StartValue;
    property StartFromCurrent default TfgxCustomBitmapLinkAnimation.DefaultStartFromCurrent;
    property StopValue;
    property Trigger;
    property TriggerInverse;
    property OnProcess;
    property OnFinish;
  end;

function fgxInterpolateRectF(const AStart: TRectF; const AStop: TRectF; const ANormalizedTime: Single): TRectF; inline;

implementation

uses
  System.SysUtils, System.Math.Vectors, FmGX.Asserts, FMX.Utils, FMX.Controls;

function fgxInterpolateRectF(const AStart, AStop: TRectF; const ANormalizedTime: Single): TRectF;
begin
  Result.Left := InterpolateSingle(AStart.Left, AStop.Left, ANormalizedTime);
  Result.Top := InterpolateSingle(AStart.Top, AStop.Top, ANormalizedTime);
  Result.Right := InterpolateSingle(AStart.Right, AStop.Right, ANormalizedTime);
  Result.Bottom := InterpolateSingle(AStart.Bottom, AStop.Bottom, ANormalizedTime);
end;

{ TfgCustomPropertyAnimation<T> }

constructor TfgxCustomPropertyAnimation<T>.Create(AOwner: TComponent);
begin
  inherited;
  FStartValue := T.Create;
  FStopValue := T.Create;
  FCurrentValue := T.Create;
  AnimationType := DefaultAnimationType;
  AutoReverse := DefaultAutoReverse;
  Duration := DefaultDuration;
  Enabled := DefaultEnabled;
  Interpolation := DefaultInterpolation;
  Inverse := DefaultInverse;
  Loop := DefaultLoop;
  StartFromCurrent := DefaultStartFromCurrent;
end;

destructor TfgxCustomPropertyAnimation<T>.Destroy;
begin
  FreeAndNil(FStartValue);
  FreeAndNil(FStopValue);
  FreeAndNil(FCurrentValue);
  inherited Destroy;
end;

procedure TfgxCustomPropertyAnimation<T>.FirstFrame;
begin
  TfgxAssert.IsNotNil(FCurrentValue);

  if StartFromCurrent and (FRttiProperty <> nil) and FRttiProperty.PropertyType.IsInstance then
    T(FRttiProperty.GetValue(FInstance).AsObject).Assign(FCurrentValue);
end;

function TfgxCustomPropertyAnimation<T>.GetStartValue: T;
begin
  Result := FStartValue;
end;

function TfgxCustomPropertyAnimation<T>.GetStopValue: T;
begin
  Result := FStopValue;
end;

procedure TfgxCustomPropertyAnimation<T>.ProcessAnimation;
begin
  TfgxAssert.IsNotNil(FStartValue);
  TfgxAssert.IsNotNil(FStopValue);
  TfgxAssert.IsNotNil(FCurrentValue);

  inherited;
  if (FInstance <> nil) and (FRttiProperty <> nil) then
  begin
    DefineCurrentValue(NormalizedTime);
    if FRttiProperty.PropertyType.IsInstance then
      T(FRttiProperty.GetValue(FInstance).AsObject).Assign(FCurrentValue);
  end;
end;

procedure TfgxCustomPropertyAnimation<T>.SetStartValue(const Value: T);
begin
  TfgxAssert.IsNotNil(FStartValue);
  TfgxAssert.IsNotNil(Value);

  FStartValue.Assign(Value);
end;

procedure TfgxCustomPropertyAnimation<T>.SetStopValue(const Value: T);
begin
  TfgxAssert.IsNotNil(FStopValue);
  TfgxAssert.IsNotNil(Value);

  FStopValue.Assign(Value);
end;

{ TfgCustomPositionAnimation }

constructor TfgxCustomPositionAnimation.Create(AOwner: TComponent);
begin
  inherited;
  StartValue.DefaultValue := TPointF.Zero;
  StopValue.DefaultValue := TPointF.Zero;
end;

procedure TfgxCustomPositionAnimation.DefineCurrentValue(const ANormalizedTime: Single);
begin
  FCurrentValue.X := InterpolateSingle(StartValue.X, StopValue.X, ANormalizedTime);
  FCurrentValue.Y := InterpolateSingle(StartValue.Y, StopValue.Y, ANormalizedTime);
end;

{ TfgCustomPosition3DAnimation }

constructor TfgxCustomPosition3DAnimation.Create(AOwner: TComponent);
begin
  inherited;
  FStartValue.DefaultValue := TPoint3D.Zero;
  FStopValue.DefaultValue := TPoint3D.Zero;
  FCurrentValue.DefaultValue := TPoint3D.Zero;
end;

procedure TfgxCustomPosition3DAnimation.DefineCurrentValue(const ANormalizedTime: Single);
begin
  FCurrentValue.X := InterpolateSingle(StartValue.X, StopValue.X, ANormalizedTime);
  FCurrentValue.Y := InterpolateSingle(StartValue.Y, StopValue.Y, ANormalizedTime);
  FCurrentValue.Z := InterpolateSingle(StartValue.Z, StopValue.Z, ANormalizedTime);
end;

{ TfgCustomBitmapLinkAnimation }

constructor TfgxCustomBitmapLinkAnimation.Create(AOwner: TComponent);
begin
  inherited;
  FOptions := DefaultOptions;
end;

procedure TfgxCustomBitmapLinkAnimation.DefineCurrentValue(const ANormalizedTime: Single);
var
  SceneScale: Single;
  LinkStart: TBitmapLink;
  LinkStop: TBitmapLink;
  Link: TBitmapLink;
begin
  SceneScale := GetSceneScale;
  LinkStart := StartValue.LinkByScale(SceneScale, True);
  LinkStop := StopValue.LinkByScale(SceneScale, True);
  TfgxAssert.IsNotNil(LinkStart, Format('For current scene scale |%f|, Animator doesn''t have specified Start link', [SceneScale]));
  TfgxAssert.IsNotNil(LinkStop, Format('For current scene scale |%f|, Animator doesn''t have specified Stop link', [SceneScale]));

  Link := CurrentValue.LinkByScale(SceneScale, True);
  if Link = nil then
  begin
    Link := TBitmapLink(CurrentValue.Add);
    Link.Scale := SceneScale;
  end;

  if TfgxBitmapLinkAnimationOption.AnimateSourceRect in Options then
    Link.SourceRect.Rect := fgxInterpolateRectF(LinkStart.SourceRect.Rect, LinkStop.SourceRect.Rect, NormalizedTime);
  if TfgxBitmapLinkAnimationOption.AnimateCapInsets in Options then
    Link.CapInsets.Rect := fgxInterpolateRectF(LinkStart.CapInsets.Rect, LinkStop.CapInsets.Rect, NormalizedTime);
end;

function TfgxCustomBitmapLinkAnimation.GetSceneScale: Single;
var
  ScreenScale: Single;
  ParentControl: TControl;
begin
  if Parent is TControl then
  begin
    ParentControl := TControl(Parent);
    if ParentControl.Scene <> nil then
      ScreenScale := ParentControl.Scene.GetSceneScale
    else
      ScreenScale := ParentControl.Canvas.Scale;
  end
  else
    ScreenScale := 1;
  Result := ScreenScale;
end;

procedure TfgxCustomBitmapLinkAnimation.ProcessAnimation;
begin
  TfgxAssert.AreEqual(StartValue.Count, StopValue.Count, 'Count of links in StartValue and StopValue must be identical');
  inherited;
  // Workaround: TStyleObject doesn't repaint itself, when we change BitmapLinks. So we force painting in this case
  if Parent is TStyleObject then
    TStyleObject(Parent).Repaint;
end;

procedure TfgxCustomBitmapLinkAnimation.SetStartValue(const Value: TBitmapLinks);
begin
  FStartValue := Value;
end;

procedure TfgxCustomBitmapLinkAnimation.SetStopValue(const Value: TBitmapLinks);
begin
  FStopValue := Value;
end;

initialization
  RegisterFmxClasses([TfgxPositionAnimation, TfgxPosition3DAnimation, TfgxBitmapLinkAnimation]);
end.
