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

unit FGX.FlipView.Effect;

interface

uses
  FMX.Presentation.Style, FMX.Controls.Presentation, FMX.Filter.Effects, FMX.Ani, FMX.Objects, FMX.Controls.Model,
  FMX.Graphics, FMX.Presentation.Messages, FMX.Controls, FGX.FlipView.Presentation, FGX.FlipView.Types, FGX.FlipView;

type

{ TfgFlipViewEffectPresentation }

  TfgFlipViewEffectPresentation = class(TfgStyledFlipViewBasePresentation)
  private
    [Weak] FNextImage: TBitmap;
    FTransitionEffect: TImageFXEffect;
    FTransitionAnimaton: TFloatAnimation;
    { Event handlers }
    procedure HandlerFinishAnimation(Sender: TObject);
  protected
    { Messages From Model}
    procedure MMEffectOptionsChanged(var AMessage: TDispatchMessage); message TfgFlipViewMessages.MM_EFFECT_OPTIONS_CHANGED;
  protected
    procedure RecreateEffect;
    { Styles }
    procedure ApplyStyle; override;
    procedure FreeStyle; override;
  public
    procedure ShowNextImage(const ANewItemIndex: Integer; const ADirection: TfgDirection; const AAnimate: Boolean); override;
  end;

implementation

uses
  System.Types, System.SysUtils, System.Rtti, FMX.Presentation.Factory, FMX.Types, FGX.Asserts,
  System.Classes, System.Math;

{ TfgFlipViewEffectPresentation }

procedure TfgFlipViewEffectPresentation.ApplyStyle;
var
  NewImage: TBitmap;
begin
  inherited ApplyStyle;

  { Image container for current slide }
  if ImageContainer <> nil then
  begin
    ImageContainer.Visible := True;
    ImageContainer.Margins.Rect := TRectF.Empty;
    NewImage := Model.CurrentImage;
    if NewImage <> nil then
      ImageContainer.Bitmap.Assign(Model.CurrentImage);

    FTransitionEffect := Model.EffectOptions.TransitionEffectClass.Create(nil);
    FTransitionEffect.Enabled := False;
    FTransitionEffect.Stored := False;
    FTransitionEffect.Parent := ImageContainer;
    FTransitionAnimaton := TFloatAnimation.Create(nil);
    FTransitionAnimaton.Parent := FTransitionEffect;
    FTransitionAnimaton.Enabled := False;
    FTransitionAnimaton.Stored := False;
    FTransitionAnimaton.PropertyName := 'Progress';
    FTransitionAnimaton.StopValue := 100;
    FTransitionAnimaton.Duration := Model.EffectOptions.Duration;
    FTransitionAnimaton.OnFinish := HandlerFinishAnimation;
  end;
end;

procedure TfgFlipViewEffectPresentation.FreeStyle;
begin
  FTransitionEffect := nil;
  FTransitionAnimaton := nil;
  inherited FreeStyle;
end;

procedure TfgFlipViewEffectPresentation.HandlerFinishAnimation(Sender: TObject);
begin
  try
    if (FNextImage <> nil) and (ImageContainer <> nil) then
      ImageContainer.Bitmap.Assign(FNextImage);
    if FTransitionEffect <> nil then
      FTransitionEffect.Enabled := False;
  finally
    Model.FinishChanging;
  end;
end;

procedure TfgFlipViewEffectPresentation.MMEffectOptionsChanged(var AMessage: TDispatchMessage);
begin
  RecreateEffect;
  FTransitionAnimaton.Duration := Model.EffectOptions.Duration;
end;

procedure TfgFlipViewEffectPresentation.RecreateEffect;
var
  EffectClass: TfgImageFXEffectClass;
begin
  TfgAssert.IsNotNil(Model);
  TfgAssert.IsNotNil(Model.EffectOptions);
  TfgAssert.IsNotNil(Model.EffectOptions.TransitionEffectClass);

  // We don't recreat effect, if current effect class is the same as a Options class.
  EffectClass := Model.EffectOptions.TransitionEffectClass;
  if FTransitionEffect is EffectClass then
    Exit;

  if FTransitionEffect <> nil then
  begin
    FTransitionEffect.Parent := nil;
    FTransitionAnimaton := nil;
  end;
  FreeAndNil(FTransitionEffect);

  FTransitionEffect := EffectClass.Create(nil);
  FTransitionEffect.Enabled := False;
  FTransitionEffect.Stored := False;
  FTransitionEffect.Parent := ImageContainer;
  FTransitionAnimaton := TFloatAnimation.Create(nil);
  FTransitionAnimaton.Parent := FTransitionEffect;
  FTransitionAnimaton.Enabled := False;
  FTransitionAnimaton.Stored := False;
  FTransitionAnimaton.PropertyName := 'Progress';
  FTransitionAnimaton.StopValue := 100;
  FTransitionAnimaton.Duration := Model.EffectOptions.Duration;
  FTransitionAnimaton.OnFinish := HandlerFinishAnimation;
end;

procedure TfgFlipViewEffectPresentation.ShowNextImage(const ANewItemIndex: Integer; const ADirection: TfgDirection;
  const AAnimate: Boolean);
var
  RttiCtx: TRttiContext;
  RttiType: TRttiType;
  TargetBitmapProperty: TRttiProperty;
  TargetBitmap: TBitmap;
begin
  inherited;
  if (csDesigning in ComponentState) or not AAnimate then
  begin
    FNextImage := nil;
    if ImageContainer <> nil then
      ImageContainer.Bitmap.Assign(Model.CurrentImage);
    Model.FinishChanging;
  end
  else
  begin
    FNextImage := Model.CurrentImage;
    if (FTransitionAnimaton <> nil) and (FTransitionAnimaton <> nil) then
    begin
      FTransitionAnimaton.Stop;
      if not (FTransitionEffect is Model.EffectOptions.TransitionEffectClass) then
        RecreateEffect;
      
      RttiCtx := TRttiContext.Create;
      try
        RttiType := RttiCtx.GetType(FTransitionEffect.ClassInfo);
        TargetBitmapProperty := RttiType.GetProperty('Target');
        TargetBitmap := TBitmap(TargetBitmapProperty.GetValue(FTransitionEffect).AsObject);
        TargetBitmap.Assign(Model.CurrentImage);
      finally
        RttiCtx.Free;
      end;
      FTransitionEffect.Enabled := True;
      FTransitionAnimaton.StartValue := 0;
      FTransitionAnimaton.Start;
    end;
  end;
end;

initialization
  TPresentationProxyFactory.Current.Register('fgFlipView-Effect', TStyledPresentationProxy<TfgFlipViewEffectPresentation>);
finalization
  TPresentationProxyFactory.Current.Unregister('fgFlipView-Effect',  TStyledPresentationProxy<TfgFlipViewEffectPresentation>);
end.
