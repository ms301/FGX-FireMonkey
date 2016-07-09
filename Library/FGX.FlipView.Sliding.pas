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

unit FGX.FlipView.Sliding;

interface

uses
  FMX.Presentation.Style, FMX.Controls.Presentation, FMX.Ani, FMX.Graphics, FMX.Objects, FMX.Controls, FMX.Types,
  FMX.Presentation.Messages, FGX.FlipView, FGX.FlipView.Presentation, FGX.FlipView.Types;

type

{ TfgFlipViewSlidingPresentation }

  TfgFlipViewSlidingPresentation = class(TfgStyledFlipViewBasePresentation)
  private
    [Weak] FNextImageContainer: TImage;
    FNextImageAnimator: TRectAnimation;
    FImageAnimator: TRectAnimation;
    procedure HandlerFinishAnimation(Sender: TObject);
  protected
    { Messages From Model}
    procedure MMSlideOptionsChanged(var AMessage: TDispatchMessage); message TfgFlipViewMessages.MM_SLIDE_OPTIONS_CHANGED;
  protected
    procedure InitAnimatorParams(const ADirection: TfgDirection);
    { Styles }
    procedure ApplyStyle; override;
    procedure FreeStyle; override;
  public
    procedure ShowNextImage(const ANewItemIndex: Integer; const ADirection: TfgDirection; const AAnimate: Boolean); override;
  end;

implementation

uses
  System.Classes, System.Types, FMX.Presentation.Factory, FGX.Asserts;

{ TfgFlipViewSlidingPresentation }

procedure TfgFlipViewSlidingPresentation.ApplyStyle;
var
  StyleObject: TFmxObject;
  NewImage: TBitmap;
begin
  inherited ApplyStyle;

  { Image container for last slide }
  if ImageContainer <> nil then
  begin
    ImageContainer.Visible := True;
    NewImage := Model.CurrentImage;
    if NewImage <> nil then
      ImageContainer.Bitmap.Assign(Model.CurrentImage);
  end;

  { Image container for new slide }
  StyleObject := FindStyleResource('image-next');
  if (StyleObject <> nil) and (StyleObject is TImage) then
  begin
    FNextImageContainer := TImage(StyleObject);
    FNextImageContainer.Visible := False;
  end;

  if (ImageContainer <> nil) and (FNextImageContainer <> nil) then
  begin
    FImageAnimator := TRectAnimation.Create(nil);
    FImageAnimator.Parent := ImageContainer;
    FImageAnimator.Enabled := False;
    FImageAnimator.Stored := False;
    FImageAnimator.PropertyName := 'Margins';
    FImageAnimator.Duration := Model.SlideOptions.Duration;
    FImageAnimator.OnFinish := HandlerFinishAnimation;

    FNextImageAnimator := TRectAnimation.Create(nil);
    FNextImageAnimator.Parent := FNextImageContainer;
    FNextImageAnimator.Enabled := False;
    FNextImageAnimator.Stored := False;
    FNextImageAnimator.PropertyName := 'Margins';
    FNextImageAnimator.Duration := Model.SlideOptions.Duration;
  end;
end;

procedure TfgFlipViewSlidingPresentation.FreeStyle;
begin
  FImageAnimator := nil;
  FNextImageAnimator := nil;
  inherited FreeStyle;
end;

procedure TfgFlipViewSlidingPresentation.HandlerFinishAnimation(Sender: TObject);
begin
  try
    if (FNextImageContainer <> nil) and (ImageContainer <> nil) then
    begin
      ImageContainer.Bitmap.Assign(FNextImageContainer.Bitmap);
      ImageContainer.Margins.Rect := TRectF.Empty;
    end;
    if FNextImageAnimator <> nil then
      FNextImageContainer.Visible := False;
  finally
    Model.FinishChanging;
  end;
end;

procedure TfgFlipViewSlidingPresentation.InitAnimatorParams(const ADirection: TfgDirection);

  procedure InitHorizontalShifting(out AFirstContainerMarginsRect, ANextContainerMarginsRect: TRectF);
  var
    Offset: Extended;
  begin
    case ADirection of
      TfgDirection.Forward:
        Offset := ImageContainer.Width;
      TfgDirection.Backward:
        Offset := -ImageContainer.Width;
    else
      Offset := ImageContainer.Width;
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
        Offset := ImageContainer.Height;
      TfgDirection.Backward:
        Offset := -ImageContainer.Height;
    else
      Offset := ImageContainer.Height;
    end;
    AFirstContainerMarginsRect := TRectF.Create(0, -Offset, 0, Offset);
    ANextContainerMarginsRect := TRectF.Create(0, Offset, 0, -Offset);
  end;

var
  FirstContainerMarginsRect: TRectF;
  NextContainerMarginsRect: TRectF;
begin
  TfgAssert.IsNotNil(Model);
  TfgAssert.IsNotNil(FImageAnimator);
  TfgAssert.IsNotNil(FNextImageAnimator);
  TfgAssert.IsNotNil(ImageContainer);

  case Model.SlideOptions.Direction of
    TfgSlideDirection.Horizontal:
      InitHorizontalShifting(FirstContainerMarginsRect, NextContainerMarginsRect);
    TfgSlideDirection.Vertical:
      InitVerticalShifting(FirstContainerMarginsRect, NextContainerMarginsRect);
  end;

  FImageAnimator.StartValue.Rect := TRectF.Empty;
  FImageAnimator.StopValue.Rect := FirstContainerMarginsRect;
  FNextImageAnimator.StartValue.Rect := NextContainerMarginsRect;
  FNextImageAnimator.StopValue.Rect := TRectF.Empty;
end;

procedure TfgFlipViewSlidingPresentation.MMSlideOptionsChanged(var AMessage: TDispatchMessage);
begin
  TfgAssert.IsNotNil(Model);
  TfgAssert.IsNotNil(Model.SlideOptions);

  if FImageAnimator <> nil then
    FImageAnimator.Duration := Model.SlideOptions.Duration;
  if FNextImageAnimator <> nil then
    FNextImageAnimator.Duration := Model.SlideOptions.Duration;
end;

procedure TfgFlipViewSlidingPresentation.ShowNextImage(const ANewItemIndex: Integer; const ADirection: TfgDirection; const AAnimate: Boolean);
begin
  TfgAssert.IsNotNil(Model);

  inherited;
  if (csDesigning in ComponentState) or not AAnimate then
  begin
    if ImageContainer <> nil then
      ImageContainer.Bitmap.Assign(Model.CurrentImage);
    Model.FinishChanging;
  end
  else
  begin
    if (FNextImageContainer <> nil) and (FNextImageAnimator <> nil) and (FImageAnimator <> nil) then
    begin
      FNextImageContainer.Bitmap.Assign(Model.CurrentImage);
      InitAnimatorParams(ADirection);
      FImageAnimator.Start;
      FNextImageContainer.Visible := True;
      FNextImageAnimator.Start;
    end;
  end;
end;

initialization
  TPresentationProxyFactory.Current.Register('fgFlipView-Sliding',  TStyledPresentationProxy<TfgFlipViewSlidingPresentation>);
finalization
  TPresentationProxyFactory.Current.Unregister('fgFlipView-Sliding',  TStyledPresentationProxy<TfgFlipViewSlidingPresentation>);
end.
