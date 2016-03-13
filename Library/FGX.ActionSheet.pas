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

unit FGX.ActionSheet;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes, FMX.Platform, FMX.Types, FGX.ActionSheet.Types, FGX.Consts;

type

{ TfgActionSheet }

  TfgCustomActionSheet = class(TFmxObject)
  public const
    DefaultUseUIGuidline = True;
  private
    FActions: TfgActionsCollections;
    FUseUIGuidline: Boolean;
    FTitle: string;
    FActionSheetService: IFGXActionSheetService;
    procedure SetActions(const Value: TfgActionsCollections);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Show; virtual;
    function Supported: Boolean;
    property ActionSheetService: IFGXActionSheetService read FActionSheetService;
  public
    property Actions: TfgActionsCollections read FActions write SetActions;
    property UseUIGuidline: Boolean read FUseUIGuidline write FUseUIGuidline default DefaultUseUIGuidline;
    property Title: string read FTitle write FTitle;
  end;

  [ComponentPlatformsAttribute(fgMobilePlatforms)]
  TfgActionSheet = class(TfgCustomActionSheet)
  published
    property Actions;
    property UseUIGuidline;
    property Title;
  end;

implementation

uses
  System.SysUtils, FGX.Asserts
{$IFDEF IOS}
   , FGX.ActionSheet.iOS
{$ENDIF}
{$IFDEF ANDROID}
   , FGX.ActionSheet.Android
{$ENDIF}
;

{ TActionSheet }

constructor TfgCustomActionSheet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FActions := TfgActionsCollections.Create(Self);
  FUseUIGuidline := DefaultUseUIGuidline;
  TPlatformServices.Current.SupportsPlatformService(IFGXActionSheetService, FActionSheetService);
end;

destructor TfgCustomActionSheet.Destroy;
begin
  FActionSheetService := nil;
  FreeAndNil(FActions);
  inherited Destroy;
end;

procedure TfgCustomActionSheet.SetActions(const Value: TfgActionsCollections);
begin
  AssertIsNotNil(Value);
  FActions.Assign(Value);
end;

procedure TfgCustomActionSheet.Show;
begin
  if Supported then
    FActionSheetService.Show(Title, Actions, UseUIGuidline);
end;

function TfgCustomActionSheet.Supported: Boolean;
begin
  Result := ActionSheetService <> nil;
end;

initialization
  RegisterFmxClasses([TfgCustomActionSheet, TfgActionSheet]);

{$IF Defined(IOS) OR Defined(ANDROID)}
  RegisterService;
{$ENDIF}
end.
