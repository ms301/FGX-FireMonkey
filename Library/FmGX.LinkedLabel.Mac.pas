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

unit FGX.LinkedLabel.Mac;

interface

uses
  System.Classes, FMX.Platform, FGX.LinkedLabel;

type

{ TMacLaunchService }

  TMacLaunchService = class sealed (TInterfacedObject, IFGXLaunchService)
  public
    { IFMXLaunchService }
    function OpenURL(const AUrl: string): Boolean;
  end;

procedure RegisterService;
procedure UnregisterService;

implementation

uses
  Macapi.Foundation, Macapi.AppKit;

{ TWinLaunchService }

function TMacLaunchService.OpenURL(const AUrl: string): Boolean;
var
  Workspace: NSWorkspace;
  Url: NSURL;
begin
  Workspace := TNSWorkspace.Wrap(TNSWorkspace.OCClass.sharedWorkspace);
  Url := TNSUrl.Wrap(TNSUrl.OCClass.URLWithString(NSStr(AUrl)));
  Result := Workspace.openURL(Url);
end;

procedure RegisterService;
begin
  TPlatformServices.Current.AddPlatformService(IFGXLaunchService, TMacLaunchService.Create);
end;

procedure UnregisterService;
begin
  TPlatformServices.Current.RemovePlatformService(IFGXLaunchService);
end;

end.
