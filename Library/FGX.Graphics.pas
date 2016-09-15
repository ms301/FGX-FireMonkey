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
  if SameValue(Round(Source * Screen.Scale), Source * Screen.Scale, Single.Epsilon) then
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
  TfgAssert.InRange(AOpacity, 0, 1);

  Result := ASource;
  TAlphaColorRec(Result).A := Round(255 * AOpacity);
end;

end.
