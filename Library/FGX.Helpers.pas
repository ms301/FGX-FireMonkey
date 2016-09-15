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

unit FGX.Helpers;

interface

uses
  FMX.Forms, FMX.Types;

type

{ TfgScreen }

  TfgScreenHelper = class helper for TScreen
  private
    const SCALE_UNDEFINED = -1;
    class var FScreenScale: Single;
  public
    class constructor Create;
    class function Scale: Single;
    class function Orientation: TScreenOrientation;
  end;

{ TfgGeneratorUniquiID }

  TfgGeneratorUniqueID = class sealed
  private
    class var FLastID: Int64;
  public
    class constructor Create;
    class function GenerateID: Integer;
  end;

implementation

uses
  System.Math, System.SysUtils, FMX.Platform, FGX.Consts;

{ TfgScreen }

class constructor TfgScreenHelper.Create;
begin
  FScreenScale := SCALE_UNDEFINED;
end;

class function TfgScreenHelper.Orientation: TScreenOrientation;
var
  ScreenService: IFMXScreenService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, ScreenService) then
    Result := ScreenService.GetScreenOrientation
  else
    Result := TScreenOrientation.Portrait;
end;

class function TfgScreenHelper.Scale: Single;
var
  ScreenService: IFMXScreenService;
begin
  if SameValue(FScreenScale, SCALE_UNDEFINED, Single.Epsilon) then
  begin
    if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, ScreenService) then
      FScreenScale := ScreenService.GetScreenScale
    else
      FScreenScale := 1;
  end;
  Result := FScreenScale;

  Assert(Result > 0);
end;

{ TfgGeneratorUniquiID }

class constructor TfgGeneratorUniqueID.Create;
begin
  FLastID := 0;
end;

class function TfgGeneratorUniqueID.GenerateID: Integer;
begin
  Inc(FLastID);
  Result := FLastID
end;

end.
