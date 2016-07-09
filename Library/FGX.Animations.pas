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

unit FGX.Animations;

interface

uses
  System.Types, System.Classes, FMX.Ani, FMX.Types, FMX.Types3D, FMX.Styles.Objects, FMX.Forms,
  FGX.Consts;

type

{ TfgCustomPropertyAnimation }

  TfgCustomPropertyAnimation<T: TPersistent, constructor> = class(TCustomPropertyAnimation)
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

  TfgCustomPositionAnimation = class(TfgCustomPropertyAnimation<TPosition>)
  protected
    procedure DefineCurrentValue(const ANormalizedTime: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
    property StartValue: TPosition read GetStartValue write SetStartValue;
    property StopValue: TPosition read GetStopValue write SetStopValue;
  end;

  [ComponentPlatformsAttribute(fgAllPlatform)]
  TfgPositionAnimation = class(TfgCustomPositionAnimation)
  published
    property AnimationType default TfgCustomPositionAnimation.DefaultAnimationType;
    property AutoReverse default TfgCustomPositionAnimation.DefaultAutoReverse;
    property Enabled default TfgCustomPositionAnimation.DefaultEnabled;
    property Delay;
    property Duration nodefault;
    property Interpolation default TfgCustomPositionAnimation.DefaultInterpolation;
    property Inverse default TfgCustomPositionAnimation.DefaultInverse;
    property Loop default TfgCustomPositionAnimation.DefaultLoop;
    property PropertyName;
    property StartValue;
    property StartFromCurrent default TfgCustomPositionAnimation.DefaultStartFromCurrent;
    property StopValue;
    property Trigger;
    property TriggerInverse;
    property OnProcess;
    property OnFinish;
  end;

{ TfgPosition3DAnimation }

  TfgCustomPosition3DAnimation = class(TfgCustomPropertyAnimation<TPosition3D>)
  protected
    procedure DefineCurrentValue(const ANormalizedTime: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
    property StartValue: TPosition3D read GetStartValue write SetStartValue;
    property StopValue: TPosition3D read GetStopValue write SetStopValue;
  end;

  [ComponentPlatformsAttribute(fgAllPlatform)]
  TfgPosition3DAnimation = class(TfgCustomPosition3DAnimation)
  published
    property AnimationType default TfgCustomPosition3DAnimation.DefaultAnimationType;
    property AutoReverse default TfgCustomPosition3DAnimation.DefaultAutoReverse;
    property Enabled default TfgCustomPosition3DAnimation.DefaultEnabled;
    property Delay;
    property Duration nodefault;
    property Interpolation default TfgCustomPosition3DAnimation.DefaultInterpolation;
    property Inverse default TfgCustomPosition3DAnimation.DefaultInverse;
    property Loop default TfgCustomPosition3DAnimation.DefaultLoop;
    property PropertyName;
    property StartValue;
    property StartFromCurrent default TfgCustomPosition3DAnimation.DefaultStartFromCurrent;
    property StopValue;
    property Trigger;
    property TriggerInverse;
    property OnProcess;
    property OnFinish;
  end;

{ TfgCustomBitmapLinkAnimation }

  TfgBitmapLinkAnimationOption = (AnimateSourceRect, AnimateCapInsets);
  TfgBitmapLinkAnimationOptions = set of TfgBitmapLinkAnimationOption;

  TfgCustomBitmapLinkAnimation = class(TfgCustomPropertyAnimation<TBitmapLinks>)
  public const
    DefaultOptions = [TfgBitmapLinkAnimationOption.AnimateSourceRect, TfgBitmapLinkAnimationOption.AnimateCapInsets];
  private
    FOptions: TfgBitmapLinkAnimationOptions;
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
    property Options: TfgBitmapLinkAnimationOptions read FOptions write FOptions default DefaultOptions;
    property StartValue: TBitmapLinks read GetStartValue write SetStartValue;
    property StopValue: TBitmapLinks read GetStopValue write SetStopValue;
  end;

  [ComponentPlatformsAttribute(fgAllPlatform)]
  TfgBitmapLinkAnimation = class(TfgCustomBitmapLinkAnimation)
  published
    property AnimationType default TfgCustomBitmapLinkAnimation.DefaultAnimationType;
    property AutoReverse default TfgCustomBitmapLinkAnimation.DefaultAutoReverse;
    property Enabled default TfgCustomBitmapLinkAnimation.DefaultEnabled;
    property Delay;
    property Duration nodefault;
    property Interpolation default TfgCustomBitmapLinkAnimation.DefaultInterpolation;
    property Inverse default TfgCustomBitmapLinkAnimation.DefaultInverse;
    property Loop default TfgCustomBitmapLinkAnimation.DefaultLoop;
    property Options;
    property PropertyName;
    property StartValue;
    property StartFromCurrent default TfgCustomBitmapLinkAnimation.DefaultStartFromCurrent;
    property StopValue;
    property Trigger;
    property TriggerInverse;
    property OnProcess;
    property OnFinish;
  end;

function fgInterpolateRectF(const AStart: TRectF; const AStop: TRectF; const ANormalizedTime: Single): TRectF; inline;

implementation

uses
  System.SysUtils, System.Math.Vectors, FGX.Asserts, FMX.Utils, FMX.Controls;

function fgInterpolateRectF(const AStart, AStop: TRectF; const ANormalizedTime: Single): TRectF;
begin
  Result.Left := InterpolateSingle(AStart.Left, AStop.Left, ANormalizedTime);
  Result.Top := InterpolateSingle(AStart.Top, AStop.Top, ANormalizedTime);
  Result.Right := InterpolateSingle(AStart.Right, AStop.Right, ANormalizedTime);
  Result.Bottom := InterpolateSingle(AStart.Bottom, AStop.Bottom, ANormalizedTime);
end;

{ TfgCustomPropertyAnimation<T> }

constructor TfgCustomPropertyAnimation<T>.Create(AOwner: TComponent);
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

destructor TfgCustomPropertyAnimation<T>.Destroy;
begin
  FreeAndNil(FStartValue);
  FreeAndNil(FStopValue);
  FreeAndNil(FCurrentValue);
  inherited Destroy;
end;

procedure TfgCustomPropertyAnimation<T>.FirstFrame;
begin
  TfgAssert.IsNotNil(FCurrentValue);

  if StartFromCurrent and (FRttiProperty <> nil) and FRttiProperty.PropertyType.IsInstance then
    T(FRttiProperty.GetValue(FInstance).AsObject).Assign(FCurrentValue);
end;

function TfgCustomPropertyAnimation<T>.GetStartValue: T;
begin
  Result := FStartValue;
end;

function TfgCustomPropertyAnimation<T>.GetStopValue: T;
begin
  Result := FStopValue;
end;

procedure TfgCustomPropertyAnimation<T>.ProcessAnimation;
begin
  TfgAssert.IsNotNil(FStartValue);
  TfgAssert.IsNotNil(FStopValue);
  TfgAssert.IsNotNil(FCurrentValue);

  inherited;
  if (FInstance <> nil) and (FRttiProperty <> nil) then
  begin
    DefineCurrentValue(NormalizedTime);
    if FRttiProperty.PropertyType.IsInstance then
      T(FRttiProperty.GetValue(FInstance).AsObject).Assign(FCurrentValue);
  end;
end;

procedure TfgCustomPropertyAnimation<T>.SetStartValue(const Value: T);
begin
  TfgAssert.IsNotNil(FStartValue);
  TfgAssert.IsNotNil(Value);

  FStartValue.Assign(Value);
end;

procedure TfgCustomPropertyAnimation<T>.SetStopValue(const Value: T);
begin
  TfgAssert.IsNotNil(FStopValue);
  TfgAssert.IsNotNil(Value);

  FStopValue.Assign(Value);
end;

{ TfgCustomPositionAnimation }

constructor TfgCustomPositionAnimation.Create(AOwner: TComponent);
begin
  inherited;
  StartValue.DefaultValue := TPointF.Zero;
  StopValue.DefaultValue := TPointF.Zero;
end;

procedure TfgCustomPositionAnimation.DefineCurrentValue(const ANormalizedTime: Single);
begin
  FCurrentValue.X := InterpolateSingle(StartValue.X, StopValue.X, ANormalizedTime);
  FCurrentValue.Y := InterpolateSingle(StartValue.Y, StopValue.Y, ANormalizedTime);
end;

{ TfgCustomPosition3DAnimation }

constructor TfgCustomPosition3DAnimation.Create(AOwner: TComponent);
begin
  inherited;
  FStartValue.DefaultValue := TPoint3D.Zero;
  FStopValue.DefaultValue := TPoint3D.Zero;
  FCurrentValue.DefaultValue := TPoint3D.Zero;
end;

procedure TfgCustomPosition3DAnimation.DefineCurrentValue(const ANormalizedTime: Single);
begin
  FCurrentValue.X := InterpolateSingle(StartValue.X, StopValue.X, ANormalizedTime);
  FCurrentValue.Y := InterpolateSingle(StartValue.Y, StopValue.Y, ANormalizedTime);
  FCurrentValue.Z := InterpolateSingle(StartValue.Z, StopValue.Z, ANormalizedTime);
end;

{ TfgCustomBitmapLinkAnimation }

constructor TfgCustomBitmapLinkAnimation.Create(AOwner: TComponent);
begin
  inherited;
  FOptions := DefaultOptions;
end;

procedure TfgCustomBitmapLinkAnimation.DefineCurrentValue(const ANormalizedTime: Single);
var
  SceneScale: Single;
  LinkStart: TBitmapLink;
  LinkStop: TBitmapLink;
  Link: TBitmapLink;
begin
  SceneScale := GetSceneScale;
  LinkStart := StartValue.LinkByScale(SceneScale, True);
  LinkStop := StopValue.LinkByScale(SceneScale, True);
  TfgAssert.IsNotNil(LinkStart, Format('For current scene scale |%f|, Animator doesn''t have specified Start link', [SceneScale]));
  TfgAssert.IsNotNil(LinkStop, Format('For current scene scale |%f|, Animator doesn''t have specified Stop link', [SceneScale]));

  Link := CurrentValue.LinkByScale(SceneScale, True);
  if Link = nil then
  begin
    Link := TBitmapLink(CurrentValue.Add);
    Link.Scale := SceneScale;
  end;

  if TfgBitmapLinkAnimationOption.AnimateSourceRect in Options then
    Link.SourceRect.Rect := fgInterpolateRectF(LinkStart.SourceRect.Rect, LinkStop.SourceRect.Rect, NormalizedTime);
  if TfgBitmapLinkAnimationOption.AnimateCapInsets in Options then
    Link.CapInsets.Rect := fgInterpolateRectF(LinkStart.CapInsets.Rect, LinkStop.CapInsets.Rect, NormalizedTime);
end;

function TfgCustomBitmapLinkAnimation.GetSceneScale: Single;
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

procedure TfgCustomBitmapLinkAnimation.ProcessAnimation;
begin
  TfgAssert.AreEqual(StartValue.Count, StopValue.Count, 'Count of links in StartValue and StopValue must be identical');
  inherited;
  // Workaround: TStyleObject doesn't repaint itself, when we change BitmapLinks. So we force painting in this case
  if Parent is TStyleObject then
    TStyleObject(Parent).Repaint;
end;

procedure TfgCustomBitmapLinkAnimation.SetStartValue(const Value: TBitmapLinks);
begin
  FStartValue := Value;
end;

procedure TfgCustomBitmapLinkAnimation.SetStopValue(const Value: TBitmapLinks);
begin
  FStopValue := Value;
end;

initialization
  RegisterFmxClasses([TfgPositionAnimation, TfgPosition3DAnimation, TfgBitmapLinkAnimation]);
end.
