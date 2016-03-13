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

unit FGX.LinkedLabel.Win;

interface

uses
  System.Classes, FMX.Platform, FGX.LinkedLabel;

type

{ TWinLaunchService }

  TWinLaunchService = class sealed (TInterfacedObject, IFGXLaunchService)
  public
    { IFMXLaunchService }
    function OpenURL(const AUrl: string): Boolean;
  end;

procedure RegisterService;
procedure UnregisterService;

implementation

uses
  Winapi.ShellApi, Winapi.Windows;

{ TWinLaunchService }

function TWinLaunchService.OpenURL(const AUrl: string): Boolean;
begin
  Result := ShellExecute(0, 'open', PChar(AUrl), nil, nil, SW_SHOWNORMAL) = NO_ERROR;
end;

procedure RegisterService;
begin
  TPlatformServices.Current.AddPlatformService(IFGXLaunchService, TWinLaunchService.Create);
end;

procedure UnregisterService;
begin
  TPlatformServices.Current.RemovePlatformService(IFGXLaunchService);
end;

end.
