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

unit FGX.Graphics;

interface

uses
  System.Types, System.UITypes, System.Classes, FMX.Graphics;

function RoundLogicPointsToMatchPixel(const LogicPoints: Single; const AtLeastOnePixel: Boolean = False): Single;
function RoundToPixel(const Source: TRectF; const AThickness: Single = 1): TRectF; overload;
function RoundToPixel(const Source: TPointF; const AThickness: Single = 1): TPointF; overload;
function RoundToPixel(const Source: Single; const AThickness: Single = 1): Single; overload;

function MakeColor(const ASource: TAlphaColor; AOpacity: Single): TAlphaColor;
function Create9PatchShadow(const ASize: TSizeF; const AColor: TAlphaColor): TBitmap;

implementation

uses
  System.Math, System.SysUtils, FMX.Forms, FMX.Platform, FGX.Helpers, FGX.Consts,
  FGX.Asserts, FMX.Types, FMX.Filter.Custom, FMX.Filter, System.UIConsts,
  FMX.Effects;

function RoundLogicPointsToMatchPixel(const LogicPoints: Single; const AtLeastOnePixel: Boolean = False): Single;
var
  Pixels: Single;
begin
  Pixels := Round(LogicPoints * Screen.Scale);

  if (Pixels < 1) and AtLeastOnePixel then
    Pixels := 1.0;

  Result := Pixels / Screen.Scale;
end;

function RoundToPixel(const Source: Single; const AThickness: Single = 1): Single; overload;
begin
  Result := Source;
  if SameValue(Round(Source * Screen.Scale), Source * Screen.Scale, EPSILON_SINGLE) then
    Result := Source - AThickness / 2;
end;

function RoundToPixel(const Source: TPointF; const AThickness: Single = 1): TPointF; overload;
begin
  Result.X := RoundToPixel(Source.X);
  Result.Y := RoundToPixel(Source.Y);
end;

function RoundToPixel(const Source: TRectF; const AThickness: Single = 1): TRectF; overload;
begin
  Result.Left := RoundToPixel(Source.Left);
  Result.Top := RoundToPixel(Source.Top);
  Result.Right := RoundToPixel(Source.Right);
  Result.Bottom := RoundToPixel(Source.Bottom);
end;

function MakeColor(const ASource: TAlphaColor; AOpacity: Single): TAlphaColor;
begin
  AssertInRange(AOpacity, 0, 1);

  Result := ASource;
  TAlphaColorRec(Result).A := Round(255 * AOpacity);
end;

function Create9PatchShadow(const ASize: TSizeF; const AColor: TAlphaColor): TBitmap;
const
  AShadowThickness = 5;
  CornerRadius = 2;
var
  CenterRect: TRectF;
  Filter: TFilter;
  ContentMargin: Single;
begin
  Result := TBitmap.Create(Round(ASize.Width + 2 * AShadowThickness), Round(ASize.Height + 2 * AShadowThickness));
  Result.Clear(TAlphaColorRec.Null);
  with Result.Canvas do
    if BeginScene then
      try
        CenterRect := TRectF.Create(TPointF.Create(AShadowThickness, AShadowThickness), ASize.Width, ASize.Height);
        Fill.Color := AColor;
        Fill.Kind := TBrushKind.Solid;
        FillRect(CenterRect, 0, 0, AllCorners, 1);
      finally
        EndScene;
      end;

  Filter := TFilterManager.FilterByName('GlowFilter');
  if Assigned(Filter) then
  begin
    Filter.ValuesAsColor['Color'] := AColor;
    Filter.ValuesAsBitmap['Input'] := Result;
    Filter.ValuesAsFloat['BlurAmount'] := 0.3;
    Filter.ApplyWithoutCopyToOutput;
    TFilterManager.FilterContext.CopyToBitmap(Result, TRect.Create(0, 0, Result.Width, Result.Height));
  end;

  ContentMargin := AShadowThickness + CornerRadius / 2;
  with Result.Canvas do
  if BeginScene then
    try
      CenterRect := TRectF.Create(TPointF.Create(AShadowThickness, AShadowThickness), ASize.Width, ASize.Height);
      Fill.Color := AColor;
      Fill.Kind := TBrushKind.Solid;
      FillRect(CenterRect, CornerRadius, CornerRadius, AllCorners, 1);

      Stroke.Color := TAlphaColorRec.Black;
      StrokeThickness := 1;
      Stroke.Kind := TBrushKind.Solid;

      DrawLine(TPointF.Create(0.5, ContentMargin + 0.5),
               TPointF.Create(0.5, ASize.Height + 2 * AShadowThickness - ContentMargin - 0.5), 1);
      DrawLine(TPointF.Create(ContentMargin + 0.5, 0.5),
               TPointF.Create(ASize.Width + AShadowThickness - 0.5, 0.5), 1);

//      DrawLine(TPointF.Create(ASize.Width + 2 * AShadowThickness - 0.5, ContentMargin + 0.5),
//               TPointF.Create(ASize.Width + 2 * AShadowThickness - 0.5, ASize.Height + AShadowThickness - 0.5), 1);
//      DrawLine(TPointF.Create(ContentMargin + 0.5, ASize.Height + 2 * AShadowThickness - 0.5),
//               TPointF.Create(ASize.Width + 2 * AShadowThickness - ContentMargin - 0.5, ASize.Height + 2 * AShadowThickness - 0.5), 1);

    finally
      EndScene;
    end;
end;

end.
