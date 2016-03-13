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

unit FGX.FlipView.Types;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes, FMX.Filter.Effects, FGX.Types;

type

{ TfgFlipViewSlideOptions }

  /// <summary>Direction of switching images in [Sliding] mode</summary>
  TfgSlideDirection = (Horizontal, Vertical);

  ///  <summary>Way of switching image slides</summary>
  ///  <remarks>
  ///   <list type="bullet">
  ///     <item><c>Effects</c> - switching slides by transition effects</item>
  ///     <item><c>Sliding</c> - switching slides by shifting of images</item>
  ///     <item><c>Custom</c> - user's way. Requires implementation a presentation with name <b>FlipView-Custom</b></item>
  ///   </list>
  /// </remarks>
  TfgFlipViewMode = (Effects, Sliding, Custom);

  /// <summary>Direction of sliding</summary>
  TfgDirection = (Forward, Backward);

  TfgChangingImageEvent = procedure (Sender: TObject; const NewItemIndex: Integer) of object;

  IfgFlipViewNotifications = interface
  ['{0D4A9AF7-4B56-4972-8EF2-5693AFBD2857}']
    procedure StartChanging;
    procedure FinishChanging;
  end;

  /// <summary>Settings of slider in [Sliding] mode</summary>
  TfgFlipViewSlideOptions = class(TfgPersistent)
  public const
    DefaultDirection = TfgSlideDirection.Horizontal;
    DefaultDuration = 0.4;
  private
    FDirection: TfgSlideDirection;
    FDuration: Single;
    procedure SetSlideDirection(const Value: TfgSlideDirection);
    procedure SetDuration(const Value: Single);
    function IsDurationStored: Boolean;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(AOwner: TComponent); override;
    function IsDefaultValues: Boolean; override;
  published
    property Direction: TfgSlideDirection read FDirection write SetSlideDirection default DefaultDirection;
    property Duration: Single read FDuration write SetDuration stored IsDurationStored nodefault;
  end;

{ TfgEffectSlidingOptions }

  TfgImageFXEffectClass = class of TImageFXEffect;

  TfgTransitionEffectKind = (Random, Blind, Line, Crumple, Fade, Ripple, Dissolve, Circle, Drop, Swirl, Magnify, Wave,
    Blood, Blur, Water, Wiggle, Shape, RotateCrumple, Banded, Saturate, Pixelate);

  /// <summary>Settings of slider in [Effect] mode</summary>
  TfgFlipViewEffectOptions = class(TfgPersistent)
  public const
    DefaultKind = TfgTransitionEffectKind.Random;
    DefaultDuration = 0.4;
  private
    FKind: TfgTransitionEffectKind;
    FDuration: Single;
    procedure SetKind(const Value: TfgTransitionEffectKind);
    procedure SetDuration(const Value: Single);
    function GetTransitionEffectClass: TfgImageFXEffectClass;
    function IsDurationStored: Boolean;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(AOwner: TComponent); override;
    function IsDefaultValues: Boolean; override;
    property TransitionEffectClass: TfgImageFXEffectClass read GetTransitionEffectClass;
  published
    property Kind: TfgTransitionEffectKind read FKind write SetKind default DefaultKind;
    property Duration: Single read FDuration write SetDuration stored IsDurationStored nodefault;
  end;

{ TfgFlipViewSlideShowOptions }

  TfgFlipViewSlideShowOptions = class(TfgPersistent)
  public const
    DefaultEnabled = True;
    DefaultDuration = 4;
  private
    FEnabled: Boolean;
    FDuration: Integer;
    procedure SetDuration(const Value: Integer);
    procedure SetEnabled(const Value: Boolean);
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(AOwner: TComponent); overload; override;
    function IsDefaultValues: Boolean; override;
  published
    property Duration: Integer read FDuration write SetDuration default DefaultDuration;
    property Enabled: Boolean read FEnabled write SetEnabled default DefaultEnabled;
  end;

implementation

uses
  System.Math, FGX.Consts, FGX.Asserts;

const
  TRANSITION_EFFECTS: array [TfgTransitionEffectKind] of TfgImageFXEffectClass = (nil, TBlindTransitionEffect,
    TLineTransitionEffect, TCrumpleTransitionEffect, TFadeTransitionEffect, TRippleTransitionEffect,
    TDissolveTransitionEffect, TCircleTransitionEffect, TDropTransitionEffect, TSwirlTransitionEffect,
    TMagnifyTransitionEffect, TWaveTransitionEffect, TBloodTransitionEffect, TBlurTransitionEffect,
    TWaterTransitionEffect, TWiggleTransitionEffect, TShapeTransitionEffect, TRotateCrumpleTransitionEffect,
    TBandedSwirlTransitionEffect, TSaturateTransitionEffect, TPixelateTransitionEffect);

{ TfgSlidingOptions }

procedure TfgFlipViewSlideOptions.AssignTo(Dest: TPersistent);
begin
  AssertIsNotNil(Dest);

  if Dest is TfgFlipViewSlideOptions then
  begin
    TfgFlipViewSlideOptions(Dest).Direction := Direction;
    TfgFlipViewSlideOptions(Dest).Duration := Duration;
  end
  else
    inherited AssignTo(Dest);
end;

constructor TfgFlipViewSlideOptions.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDirection := DefaultDirection;
  FDuration := DefaultDuration;
end;

function TfgFlipViewSlideOptions.IsDefaultValues: Boolean;
begin
  Result := (Direction = DefaultDirection) and not IsDurationStored;
end;

function TfgFlipViewSlideOptions.IsDurationStored: Boolean;
begin
  Result := not SameValue(Duration, DefaultDuration, EPSILON_SINGLE);
end;

procedure TfgFlipViewSlideOptions.SetDuration(const Value: Single);
begin
  Assert(Value >= 0);

  if not SameValue(Value, Duration, EPSILON_SINGLE) then
  begin
    FDuration := Max(0, Value);
    DoInternalChanged;
  end;
end;

procedure TfgFlipViewSlideOptions.SetSlideDirection(const Value: TfgSlideDirection);
begin
  if Direction <> Value then
  begin
    FDirection := Value;
    DoInternalChanged;
  end;
end;

{ TfgEffectSlidingOptions }

procedure TfgFlipViewEffectOptions.AssignTo(Dest: TPersistent);
var
  DestOptions: TfgFlipViewEffectOptions;
begin
  AssertIsNotNil(Dest);

  if Dest is TfgFlipViewEffectOptions then
  begin
    DestOptions := TfgFlipViewEffectOptions(Dest);
    DestOptions.Kind := Kind;
    DestOptions.Duration := Duration;
  end
  else
    inherited AssignTo(Dest);
end;

constructor TfgFlipViewEffectOptions.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FKind := DefaultKind;
  FDuration := DefaultDuration;
end;

function TfgFlipViewEffectOptions.GetTransitionEffectClass: TfgImageFXEffectClass;
var
  RandomEffectKind: TfgTransitionEffectKind;
begin
  if Kind = TfgTransitionEffectKind.Random then
  begin
    RandomEffectKind := TfgTransitionEffectKind(Random(Integer(High(TfgTransitionEffectKind))) + 1);
    Result := TRANSITION_EFFECTS[RandomEffectKind];
  end
  else
    Result := TRANSITION_EFFECTS[Kind];

  AssertIsNotNil(Result, 'TfgFlipViewEffectOptions.GetTransitionEffectClass must return class of effect.');
end;

function TfgFlipViewEffectOptions.IsDefaultValues: Boolean;
begin
  Result := not IsDurationStored and (Kind = DefaultKind);
end;

function TfgFlipViewEffectOptions.IsDurationStored: Boolean;
begin
  Result := not SameValue(Duration, DefaultDuration, EPSILON_SINGLE);
end;

procedure TfgFlipViewEffectOptions.SetKind(const Value: TfgTransitionEffectKind);
begin
  if Kind <> Value then
  begin
    FKind := Value;
    DoInternalChanged;
  end;
end;

procedure TfgFlipViewEffectOptions.SetDuration(const Value: Single);
begin
  Assert(Value >= 0);

  if not SameValue(Value, Duration, EPSILON_SINGLE) then
  begin
    FDuration := Max(0, Value);
    DoInternalChanged;
  end;
end;

{ TfgFlipViewSlideShowOptions }

procedure TfgFlipViewSlideShowOptions.AssignTo(Dest: TPersistent);
var
  DestOptions: TfgFlipViewSlideShowOptions;
begin
  AssertIsNotNil(Dest);

  if Dest is TfgFlipViewSlideShowOptions then
  begin
    DestOptions := TfgFlipViewSlideShowOptions(Dest);
    DestOptions.Enabled := Enabled;
    DestOptions.Duration := Duration;
  end
  else
    inherited AssignTo(Dest);
end;

constructor TfgFlipViewSlideShowOptions.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEnabled := DefaultEnabled;
  FDuration := DefaultDuration;
end;

function TfgFlipViewSlideShowOptions.IsDefaultValues: Boolean;
begin
  Result := (Duration = DefaultDuration) and (Enabled = DefaultEnabled);
end;

procedure TfgFlipViewSlideShowOptions.SetDuration(const Value: Integer);
begin
  Assert(Value >= 0);

  if Duration <> Value then
  begin
    FDuration := Max(0, Value);
    DoInternalChanged;
  end;
end;

procedure TfgFlipViewSlideShowOptions.SetEnabled(const Value: Boolean);
begin
  if Enabled <> Value then
  begin
    FEnabled := Value;
    DoInternalChanged;
  end;
end;

end.
