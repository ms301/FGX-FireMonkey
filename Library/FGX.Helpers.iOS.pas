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
 
unit FGX.Helpers.iOS;

interface

uses
  FMX.Types, Macapi.ObjCRuntime, iOSapi.UIKit, iOSapi.CoreGraphics, System.UITypes;

const
  DEFAULT_ANIMATION_DURATION = 0.4;

type

{ Helpers of base iOS class }

  UIColorHelper = class helper for TUIColor
  public
    class function MakeColor(const AColor: TAlphaColor): UIColor;
    class function clearColor: UIColor;
    class function whiteColor: UIColor;
  end;

  CGRectHelper = record helper for CGRect
  public
    constructor Create(const AWidth: Single; const AHeight: Single);
    function Width: Single;
    function Height: Single;
  end;

{ Interface Idiom }

  TfgInterfaceIdiom = (Desktop, Phone, Tablet);

  function InterfaceIdiom: TfgInterfaceIdiom;

{ Animation }

  procedure FadeIn(AView: UIView; const ADuration: Single = DEFAULT_ANIMATION_DURATION); overload;
  procedure FadeIn(const AView: UIView; const ADuration: Single; const ATargetObject: Pointer; const ASelector: string); overload;

  procedure FadeOut(AView: UIView; const ADuration: Single = DEFAULT_ANIMATION_DURATION); overload;
  procedure FadeOut(const AView: UIView; const ADuration: Single; const ATargetObject: Pointer; const ASelector: string); overload;

implementation

uses
  System.SysUtils, iOSapi.CoreImage, FGX.Asserts;

function InterfaceIdiom: TfgInterfaceIdiom;
begin
  if TUIDevice.Wrap(TUIDevice.OCClass.currentDevice).userInterfaceIdiom = UIUserInterfaceIdiomPad then
    Result := TfgInterfaceIdiom.Tablet
  else
    Result := TfgInterfaceIdiom.Phone;
end;

{ UIColorHelper }

class function UIColorHelper.clearColor: UIColor;
begin
  Result := TUIColor.Wrap(TUIColor.OCClass.clearColor);
end;

class function UIColorHelper.MakeColor(const AColor: TAlphaColor): UIColor;
var
  Red: Single;
  Green: Single;
  Blue: Single;
  Alpha: Single;
  ColorCI: CIColor;
begin
  Red := TAlphaColorRec(AColor).R / 255;
  Green := TAlphaColorRec(AColor).G / 255;
  Blue := TAlphaColorRec(AColor).B / 255;
  Alpha := TAlphaColorRec(AColor).A / 255;
  ColorCI := TCIColor.Wrap(TCIColor.OCClass.colorWithRed(Red, Green, Blue, Alpha));
  Result := TUIColor.Wrap(TUIColor.OCClass.colorWithCIColor(ColorCI));
end;

class function UIColorHelper.whiteColor: UIColor;
begin
  Result := TUIColor.Wrap(TUIColor.OCClass.whiteColor);
end;

{ CGRectHelper }

constructor CGRectHelper.Create(const AWidth, AHeight: Single);
begin
  Assert(AWidth >= 0);
  Assert(AHeight >= 0);

  Self.origin.x := 0;
  Self.origin.y := 0;
  Self.size.width := AWidth;
  Self.size.height := AHeight;
end;

function CGRectHelper.Height: Single;
begin
  Result := Self.size.height;
end;

function CGRectHelper.Width: Single;
begin
  Result := Self.size.width;
end;

procedure FadeIn(AView: UIView; const ADuration: Single);
begin
  FadeIn(AView, ADuration, nil, '');
end;

procedure FadeIn(const AView: UIView; const ADuration: Single; const ATargetObject: Pointer; const ASelector: string); overload;
var
  Selector: SEL;
begin
  AssertIsNotNil(AView);
  Assert(ADuration >= 0);

  AView.setHidden(False);
  AView.setAlpha(0.0);
  if AView.superview <> nil then
    TUIView.Wrap(AView.superview).bringSubviewToFront(AView);

  TUIView.OCClass.beginAnimations(nil, nil);
  try
    TUIView.OCClass.setAnimationDuration(ADuration);
    if (ATargetObject <> nil) and not ASelector.IsEmpty then
    begin
      TUIView.OCClass.setAnimationDelegate(ATargetObject);
      Selector := sel_getUid(MarshaledAString(TMarshal.AsAnsi(ASelector)));
      TUIView.OCClass.setAnimationDidStopSelector(Selector);
    end;
    AView.setAlpha(1.0);
  finally
    TUIView.OCClass.commitAnimations;
  end;
end;

procedure FadeOut(AView: UIView; const ADuration: Single);
begin
  FadeOut(AView, ADuration, nil, '');
end;

procedure FadeOut(const AView: UIView; const ADuration: Single; const ATargetObject: Pointer; const ASelector: string); overload;
var
  Selector: SEL;
begin
  AssertIsNotNil(AView);
  Assert(ADuration >= 0);

  AView.setHidden(False);
  AView.setAlpha(1.0);
  if AView.superview <> nil then
    TUIView.Wrap(AView.superview).bringSubviewToFront(AView);

  TUIView.OCClass.beginAnimations(nil, nil);
  try
    TUIView.OCClass.setAnimationDuration(ADuration);
    if (ATargetObject <> nil) and not ASelector.IsEmpty then
    begin
      TUIView.OCClass.setAnimationDelegate(ATargetObject);
      Selector := sel_getUid(MarshaledAString(TMarshal.AsAnsi(ASelector)));
      TUIView.OCClass.setAnimationDidStopSelector(Selector);
    end;
    AView.setAlpha(0.0);
  finally
    TUIView.OCClass.commitAnimations;
  end;
end;

end.
