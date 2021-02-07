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

unit FmGX.FlipView.Types;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes, FMX.Filter.Effects, FmGX.Types;

type

{ TfgFlipViewSlideOptions }

  /// <summary>Direction of switching images in [Sliding] mode</summary>
  TfgxSlideDirection = (Horizontal, Vertical);

  ///  <summary>Way of switching image slides</summary>
  ///  <remarks>
  ///   <list type="bullet">
  ///     <item><c>Effects</c> - switching slides by transition effects</item>
  ///     <item><c>Sliding</c> - switching slides by shifting of images</item>
  ///     <item><c>Custom</c> - user's way. Requires implementation a presentation with name <b>FlipView-Custom</b></item>
  ///   </list>
  /// </remarks>
  TfgxFlipViewMode = (Effects, Sliding, Custom);

  /// <summary>Direction of sliding</summary>
  TfgxDirection = (Forward, Backward);

  TfgxChangingImageEvent = procedure (Sender: TObject; const NewItemIndex: Integer) of object;

  /// <summary>Notifications about starting and finishing sliding process</summary>
  IfgxFlipViewNotifications = interface
  ['{0D4A9AF7-4B56-4972-8EF2-5693AFBD2857}']
    procedure StartChanging;
    procedure FinishChanging;
  end;

  /// <summary>Settings of slider in [Sliding] mode</summary>
  TfgxFlipViewSlideOptions = class(TfgxPersistent)
  public const
    DefaultDirection = TfgxSlideDirection.Horizontal;
    DefaultDuration = 0.4;
  private
    FDirection: TfgxSlideDirection;
    FDuration: Single;
    procedure SetSlideDirection(const Value: TfgxSlideDirection);
    procedure SetDuration(const Value: Single);
    function IsDurationStored: Boolean;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(AOwner: TPersistent); override;
    function AreDefaultValues: Boolean; override;
  published
    property Direction: TfgxSlideDirection read FDirection write SetSlideDirection default DefaultDirection;
    property Duration: Single read FDuration write SetDuration stored IsDurationStored nodefault;
  end;

{ TfgEffectSlidingOptions }

  TfgxImageFXEffectClass = class of TImageFXEffect;

  TfgxTransitionEffectKind = (Random, Blind, Line, Crumple, Fade, Ripple, Dissolve, Circle, Drop, Swirl, Magnify, Wave,
    Blood, Blur, Water, Wiggle, Shape, RotateCrumple, Banded, Saturate, Pixelate);

  /// <summary>Settings of slider in [Effect] mode</summary>
  TfgxFlipViewEffectOptions = class(TfgxPersistent)
  public const
    DefaultKind = TfgxTransitionEffectKind.Random;
    DefaultDuration = 0.4;
  private
    FKind: TfgxTransitionEffectKind;
    FDuration: Single;
    procedure SetKind(const Value: TfgxTransitionEffectKind);
    procedure SetDuration(const Value: Single);
    function GetTransitionEffectClass: TfgxImageFXEffectClass;
    function IsDurationStored: Boolean;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(AOwner: TPersistent); override;
    function AreDefaultValues: Boolean; override;
    property TransitionEffectClass: TfgxImageFXEffectClass read GetTransitionEffectClass;
  published
    property Kind: TfgxTransitionEffectKind read FKind write SetKind default DefaultKind;
    property Duration: Single read FDuration write SetDuration stored IsDurationStored nodefault;
  end;

{ TfgFlipViewSlideShowOptions }

  TfgxFlipViewSlideShowOptions = class(TfgxPersistent)
  public const
    DefaultEnabled = False;
    DefaultDuration = 4;
  private
    FEnabled: Boolean;
    FDuration: Integer;
    procedure SetDuration(const Value: Integer);
    procedure SetEnabled(const Value: Boolean);
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(AOwner: TPersistent); overload; override;
    function AreDefaultValues: Boolean; override;
  published
    property Duration: Integer read FDuration write SetDuration default DefaultDuration;
    property Enabled: Boolean read FEnabled write SetEnabled default DefaultEnabled;
  end;

implementation

uses
  System.Math, System.SysUtils, FmGX.Consts, FmGX.Asserts;

const
  TRANSITION_EFFECTS: array [TfgxTransitionEffectKind] of TfgxImageFXEffectClass = (nil, TBlindTransitionEffect,
    TLineTransitionEffect, TCrumpleTransitionEffect, TFadeTransitionEffect, TRippleTransitionEffect,
    TDissolveTransitionEffect, TCircleTransitionEffect, TDropTransitionEffect, TSwirlTransitionEffect,
    TMagnifyTransitionEffect, TWaveTransitionEffect, TBloodTransitionEffect, TBlurTransitionEffect,
    TWaterTransitionEffect, TWiggleTransitionEffect, TShapeTransitionEffect, TRotateCrumpleTransitionEffect,
    TBandedSwirlTransitionEffect, TSaturateTransitionEffect, TPixelateTransitionEffect);

{ TfgSlidingOptions }

procedure TfgxFlipViewSlideOptions.AssignTo(Dest: TPersistent);
begin
  TfgxAssert.IsNotNil(Dest);

  if Dest is TfgxFlipViewSlideOptions then
  begin
    TfgxFlipViewSlideOptions(Dest).Direction := Direction;
    TfgxFlipViewSlideOptions(Dest).Duration := Duration;
  end
  else
    inherited AssignTo(Dest);
end;

constructor TfgxFlipViewSlideOptions.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FDirection := DefaultDirection;
  FDuration := DefaultDuration;
end;

function TfgxFlipViewSlideOptions.AreDefaultValues: Boolean;
begin
  Result := (Direction = DefaultDirection) and not IsDurationStored;
end;

function TfgxFlipViewSlideOptions.IsDurationStored: Boolean;
begin
  Result := not SameValue(Duration, DefaultDuration, Single.Epsilon);
end;

procedure TfgxFlipViewSlideOptions.SetDuration(const Value: Single);
begin
  Assert(Value >= 0);

  if not SameValue(Value, Duration, Single.Epsilon) then
  begin
    FDuration := Max(0, Value);
    DoInternalChanged;
  end;
end;

procedure TfgxFlipViewSlideOptions.SetSlideDirection(const Value: TfgxSlideDirection);
begin
  if Direction <> Value then
  begin
    FDirection := Value;
    DoInternalChanged;
  end;
end;

{ TfgEffectSlidingOptions }

procedure TfgxFlipViewEffectOptions.AssignTo(Dest: TPersistent);
var
  DestOptions: TfgxFlipViewEffectOptions;
begin
  TfgxAssert.IsNotNil(Dest);

  if Dest is TfgxFlipViewEffectOptions then
  begin
    DestOptions := TfgxFlipViewEffectOptions(Dest);
    DestOptions.Kind := Kind;
    DestOptions.Duration := Duration;
  end
  else
    inherited AssignTo(Dest);
end;

constructor TfgxFlipViewEffectOptions.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FKind := DefaultKind;
  FDuration := DefaultDuration;
end;

function TfgxFlipViewEffectOptions.GetTransitionEffectClass: TfgxImageFXEffectClass;
var
  RandomEffectKind: TfgxTransitionEffectKind;
begin
  if Kind = TfgxTransitionEffectKind.Random then
  begin
    RandomEffectKind := TfgxTransitionEffectKind(Random(Integer(High(TfgxTransitionEffectKind))) + 1);
    Result := TRANSITION_EFFECTS[RandomEffectKind];
  end
  else
    Result := TRANSITION_EFFECTS[Kind];

  TfgxAssert.IsNotNil(Result, 'TfgFlipViewEffectOptions.GetTransitionEffectClass must return class of effect.');
end;

function TfgxFlipViewEffectOptions.AreDefaultValues: Boolean;
begin
  Result := not IsDurationStored and (Kind = DefaultKind);
end;

function TfgxFlipViewEffectOptions.IsDurationStored: Boolean;
begin
  Result := not SameValue(Duration, DefaultDuration, Single.Epsilon);
end;

procedure TfgxFlipViewEffectOptions.SetKind(const Value: TfgxTransitionEffectKind);
begin
  if Kind <> Value then
  begin
    FKind := Value;
    DoInternalChanged;
  end;
end;

procedure TfgxFlipViewEffectOptions.SetDuration(const Value: Single);
begin
  Assert(Value >= 0);

  if not SameValue(Value, Duration, Single.Epsilon) then
  begin
    FDuration := Max(0, Value);
    DoInternalChanged;
  end;
end;

{ TfgFlipViewSlideShowOptions }

procedure TfgxFlipViewSlideShowOptions.AssignTo(Dest: TPersistent);
var
  DestOptions: TfgxFlipViewSlideShowOptions;
begin
  TfgxAssert.IsNotNil(Dest);

  if Dest is TfgxFlipViewSlideShowOptions then
  begin
    DestOptions := TfgxFlipViewSlideShowOptions(Dest);
    DestOptions.Enabled := Enabled;
    DestOptions.Duration := Duration;
  end
  else
    inherited AssignTo(Dest);
end;

constructor TfgxFlipViewSlideShowOptions.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FEnabled := DefaultEnabled;
  FDuration := DefaultDuration;
end;

function TfgxFlipViewSlideShowOptions.AreDefaultValues: Boolean;
begin
  Result := (Duration = DefaultDuration) and (Enabled = DefaultEnabled);
end;

procedure TfgxFlipViewSlideShowOptions.SetDuration(const Value: Integer);
begin
  Assert(Value >= 0);

  if Duration <> Value then
  begin
    FDuration := Max(0, Value);
    DoInternalChanged;
  end;
end;

procedure TfgxFlipViewSlideShowOptions.SetEnabled(const Value: Boolean);
begin
  if Enabled <> Value then
  begin
    FEnabled := Value;
    DoInternalChanged;
  end;
end;

end.
