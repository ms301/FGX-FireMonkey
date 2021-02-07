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

unit FGX.LinkedLabel.iOS;

interface

uses
  System.Classes, FMX.Platform, FGX.LinkedLabel;

type

{ TiOSLaunchService }

  TiOSLaunchService = class sealed (TInterfacedObject, IFGXLaunchService)
  public
    { IFMXLaunchService }
    function OpenURL(const AUrl: string): Boolean;
  end;

procedure RegisterService;
procedure UnregisterService;

implementation

uses
  iOSapi.Foundation, Macapi.Helpers, FMX.Helpers.iOS;

{ TiOSLaunchService }

function TiOSLaunchService.OpenURL(const AUrl: string): Boolean;
var
  Url: NSURL;
begin
  Url := TNSUrl.Wrap(TNSUrl.OCClass.URLWithString(StrToNSStr(AUrl)));
  Result := SharedApplication.openUrl(Url);
end;

procedure RegisterService;
begin
  TPlatformServices.Current.AddPlatformService(IFGXLaunchService, TiOSLaunchService.Create);
end;

procedure UnregisterService;
begin
  TPlatformServices.Current.RemovePlatformService(IFGXLaunchService);
end;

end.
