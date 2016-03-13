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

unit FGX.FlipView.Presentations;

interface

{$SCOPEDENUMS ON}

uses
  FMX.Graphics, FMX.Filter.Effects, FMX.Ani, FMX.Objects, FGX.FlipView;

const
  rsCannotShowImage = 'Невозможно отобразить изображение. Параметр |AImage|=nil';

type

{ TfgTransEffectsPresenter }

  TfgTransEffectsPresenter = class(TfgFlipViewPresenter)
  private
    FTransitionEffect: TImageFXEffect;
    FTransitionAnimaton: TFloatAnimation;
    [Weak] FNewImage: TBitmap;
    [Weak] FImageContainer: TImage;
    procedure HandlerFinishAnimation(Sender: TObject);
  protected
    { Installation }
    function DoLoad: Boolean; override;
    procedure DoUnload; override;
    procedure DoShowBitmap(const AImage: TBitmap; const ADirection: TfgDirection); override;
    procedure DoShowBitmapImmediately(const AImage: TBitmap); override;
    { Styles }
    procedure ConnectWithStyleObjects; virtual;
    function HasImageContainer: Boolean;
  end;

{ TfgShiftPresenter }

  TfgShiftPresenter = class (TfgFlipViewPresenter)
  strict private
    FImageAnimator: TRectAnimation;
    FAdditionalImageAnimator: TRectAnimation;
    [Weak] FNewImage: TBitmap;
    [Weak] FImageContainer: TImage;
    [Weak] FAdditionalImageContainer: TImage;
    procedure HandlerFinishAnimation(Sender: TObject);
  protected
    { Installation }
    function DoLoad: Boolean; override;
    procedure DoUnload; override;
    procedure DoShowBitmap(const AImage: TBitmap; const ADirection: TfgDirection); override;
    procedure DoShowBitmapImmediately(const AImage: TBitmap); override;
    procedure InitAnimatorParams(const ADirection: TfgDirection);
    { Styles }
    function HasImageContainers: Boolean;
  end;

implementation

uses
  System.SysUtils, System.Rtti, System.Math, System.Classes, FMX.Types,
  System.Types, FGX.FlipView.Types, FGX.Asserts;

{ TfgTransEffectsPresenter }

procedure TfgTransEffectsPresenter.DoShowBitmap(const AImage: TBitmap; const ADirection: TfgDirection);
var
  RttiCtx: TRttiContext;
  RttiType: TRttiType;
  TargetBitmapProperty: TRttiProperty;
  TargetBitmap: TBitmap;
begin
  AssertIsNotNil(AImage);

  if AImage = nil then
    raise EArgumentNilException.Create(rsCannotShowImage);

  if csDesigning in FlipView.ComponentState then
  begin
    if HasImageContainer then
      FImageContainer.Bitmap.Assign(AImage)
  end
  else
  begin
    FTransitionAnimaton.Stop;
    FNewImage := AImage;
    RttiCtx := TRttiContext.Create;
    try
      RttiType := RttiCtx.GetType(FTransitionEffect.ClassInfo);
      TargetBitmapProperty := RttiType.GetProperty('Target');
      TargetBitmap := TBitmap(TargetBitmapProperty.GetValue(FTransitionEffect).AsObject);
      TargetBitmap.Assign(AImage);
    finally
      RttiCtx.Free;
    end;
    FTransitionEffect.Enabled := True;
    FTransitionAnimaton.StartValue := 0;
    FTransitionAnimaton.Start;
  end;
end;

procedure TfgTransEffectsPresenter.DoShowBitmapImmediately(const AImage: TBitmap);
begin
  if (AImage <> nil) and HasImageContainer then
    FImageContainer.Bitmap.Assign(AImage);
  FTransitionEffect.Enabled := False;
end;

procedure TfgTransEffectsPresenter.HandlerFinishAnimation(Sender: TObject);
begin
  ShowBitmapImmediately(FNewImage);
end;

function TfgTransEffectsPresenter.HasImageContainer: Boolean;
begin
  Result := FImageContainer <> nil;
end;

procedure TfgTransEffectsPresenter.ConnectWithStyleObjects;
var
  StyleObject: TFmxObject;
  NewImage: TBitmap;
begin
  { Image container for current slide }
  StyleObject := FlipView.FindStyleResource('image');
  if StyleObject is TImage then
  begin
    FImageContainer := TImage(StyleObject);
    FImageContainer.Visible := True;
    FImageContainer.Margins.Rect := TRectF.Empty;
    NewImage := FlipView.CurrentImage;
    if NewImage <> nil then
      FImageContainer.Bitmap.Assign(FlipView.CurrentImage);
  end;
end;

function TfgTransEffectsPresenter.DoLoad: Boolean;
begin
  Assert(FTransitionEffect = nil);
  Assert(FTransitionAnimaton = nil);
  AssertIsNotNil(FlipView);
  AssertIsNotNil(FlipView.EffectOptions);
  AssertIsNotNil(FlipView.EffectOptions.TransitionEffectClass);

  ConnectWithStyleObjects;

  { Create Transition Effect }
  FTransitionEffect := FlipView.EffectOptions.TransitionEffectClass.Create(nil);
  FTransitionEffect.Enabled := False;
  FTransitionEffect.Stored := False;
  if HasImageContainer then
    FTransitionEffect.Parent := FImageContainer
  else
    FTransitionEffect.Parent := FlipView;

  { Animation of transition effect }
  FTransitionAnimaton := TFloatAnimation.Create(nil);
  FTransitionAnimaton.Parent := FTransitionEffect;
  FTransitionAnimaton.Enabled := False;
  FTransitionAnimaton.Stored := False;
  FTransitionAnimaton.PropertyName := 'Progress';
  FTransitionAnimaton.StopValue := 100;
  FTransitionAnimaton.Duration := FlipView.EffectOptions.Duration;
  FTransitionAnimaton.OnFinish := HandlerFinishAnimation;

  Result := True;
end;

procedure TfgTransEffectsPresenter.DoUnload;
begin
  AssertIsNotNil(FTransitionAnimaton);
  AssertIsNotNil(FTransitionEffect);
  FImageContainer := nil;
  FTransitionAnimaton.Parent := nil;
  FreeAndNil(FTransitionAnimaton);
  FTransitionEffect.Parent := nil;
  FreeAndNil(FTransitionEffect);
end;

{ TfgShiftPresenter }

function TfgShiftPresenter.DoLoad: Boolean;
var
  StyleObject: TFmxObject;
begin
  { Image container for last slide }
  StyleObject := FlipView.FindStyleResource('image');
  if StyleObject is TImage then
  begin
    FImageContainer := TImage(StyleObject);
    FImageContainer.Visible := True;
    if InRange(FlipView.ItemIndex, 0, FlipView.ImagesCount - 1) then
      FImageContainer.Bitmap.Assign(FlipView.Images[FlipView.ItemIndex].Bitmap);
  end;

  { Image container for new slide }
  StyleObject := FlipView.FindStyleResource('image-additional');
  if (StyleObject <> nil) and (StyleObject is TImage) then
  begin
    FAdditionalImageContainer := TImage(StyleObject);
    FAdditionalImageContainer.Visible := False;
  end;

  FImageAnimator := TRectAnimation.Create(nil);
  FImageAnimator.Parent := FImageContainer;
  FImageAnimator.Enabled := False;
  FImageAnimator.Stored := False;
  FImageAnimator.PropertyName := 'Margins';
  FImageAnimator.Duration := FlipView.SlideOptions.Duration;
  FImageAnimator.OnFinish := HandlerFinishAnimation;

  FAdditionalImageAnimator := TRectAnimation.Create(nil);
  FAdditionalImageAnimator.Parent := FAdditionalImageContainer;
  FAdditionalImageAnimator.Enabled := False;
  FAdditionalImageAnimator.Stored := False;
  FAdditionalImageAnimator.PropertyName := 'Margins';
  FAdditionalImageAnimator.Duration := FlipView.SlideOptions.Duration;

  Result := HasImageContainers;
end;

procedure TfgShiftPresenter.DoShowBitmap(const AImage: TBitmap; const ADirection: TfgDirection);
begin
  FNewImage := AImage;
  if csDesigning in FlipView.ComponentState then
    FImageContainer.Bitmap.Assign(FNewImage)
  else
  begin
    FAdditionalImageContainer.Bitmap.Assign(AImage);

    InitAnimatorParams(ADirection);

    FImageAnimator.Start;

    FAdditionalImageContainer.Visible := True;
    FAdditionalImageAnimator.Start;
  end;
end;

procedure TfgShiftPresenter.DoShowBitmapImmediately(const AImage: TBitmap);
begin
  FImageContainer.Bitmap.Assign(AImage);
  FImageContainer.Margins.Rect := TRectF.Empty;
  FAdditionalImageContainer.Visible := False;
end;

procedure TfgShiftPresenter.DoUnload;
begin
  FImageAnimator.Parent := nil;
  FreeAndNil(FImageAnimator);
  FAdditionalImageAnimator.Parent := nil;
  FreeAndNil(FAdditionalImageAnimator);

  if FImageContainer <> nil then
  begin
    FImageContainer.Visible := True;
    FImageContainer.Margins.Rect := TRectF.Empty;
    FImageContainer := nil;
  end;
  if FAdditionalImageContainer <> nil then
  begin
    FAdditionalImageContainer.Visible := False;
    FAdditionalImageContainer := nil;
  end;
end;

procedure TfgShiftPresenter.HandlerFinishAnimation(Sender: TObject);
begin
  DoShowBitmapImmediately(FNewImage);
end;

function TfgShiftPresenter.HasImageContainers: Boolean;
begin
  Result := (FImageContainer <> nil) and (FAdditionalImageContainer <> nil);
end;

procedure TfgShiftPresenter.InitAnimatorParams(const ADirection: TfgDirection);

  procedure InitHorizontalShifting(out AFirstContainerMarginsRect, ANextContainerMarginsRect: TRectF);
  var
    Offset: Extended;
  begin
    case ADirection of
      TfgDirection.Forward:
        Offset := FImageContainer.Width;
      TfgDirection.Backward:
        Offset := -FImageContainer.Width;
    else
      Offset := FImageContainer.Width;
    end;
    AFirstContainerMarginsRect := TRectF.Create(-Offset, 0, Offset, 0);
    ANextContainerMarginsRect := TRectF.Create(Offset, 0, -Offset, 0);
  end;

  procedure InitVerticalShifting(out AFirstContainerMarginsRect, ANextContainerMarginsRect: TRectF);
  var
    Offset: Extended;
  begin
    case ADirection of
      TfgDirection.Forward:
        Offset := FImageContainer.Height;
      TfgDirection.Backward:
        Offset := -FImageContainer.Height;
    else
      Offset := FImageContainer.Height;
    end;
    AFirstContainerMarginsRect := TRectF.Create(0, -Offset, 0, Offset);
    ANextContainerMarginsRect := TRectF.Create(0, Offset, 0, -Offset);
  end;

var
  FirstContainerMarginsRect: TRectF;
  NextContainerMarginsRect: TRectF;
begin
  AssertIsNotNil(FlipView);
  AssertIsNotNil(FlipView.SlideOptions);
  AssertIsNotNil(FImageAnimator);
  AssertIsNotNil(FAdditionalImageAnimator);

  case FlipView.SlideOptions.Direction of
    TfgSlideDirection.Horizontal:
      InitHorizontalShifting(FirstContainerMarginsRect, NextContainerMarginsRect);
    TfgSlideDirection.Vertical:
      InitVerticalShifting(FirstContainerMarginsRect, NextContainerMarginsRect);
  end;

  FImageAnimator.StartValue.Rect := TRectF.Empty;
  FImageAnimator.StopValue.Rect := FirstContainerMarginsRect;
  FAdditionalImageAnimator.StartValue.Rect := NextContainerMarginsRect;
  FAdditionalImageAnimator.StopValue.Rect := TRectF.Empty;
end;

end.
