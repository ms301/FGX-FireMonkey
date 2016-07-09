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
    DefaultTheme = TfgActionSheetTheme.Auto;
  private
    FActions: TfgActionsCollections;
    FUseUIGuidline: Boolean;
    FTitle: string;
    FActionSheetService: IFGXActionSheetService;
    FTheme: TfgActionSheetTheme;
    FOnItemClick: TfgActionSheetItemClickEvent;
    FOnShow: TNotifyEvent;
    FOnHide: TNotifyEvent;
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
    property Theme: TfgActionSheetTheme read FTheme write FTheme default DefaultTheme;
    property Title: string read FTitle write FTitle;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnHide: TNotifyEvent read FOnHide write FOnHide;
    property OnItemClick: TfgActionSheetItemClickEvent read FOnItemClick write FOnItemClick;
  end;

  [ComponentPlatformsAttribute(fgMobilePlatforms)]
  TfgActionSheet = class(TfgCustomActionSheet)
  published
    property Actions;
    property UseUIGuidline;
    property Theme;
    property Title;
    { Events }
    property OnShow;
    property OnHide;
    property OnItemClick;
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
  FTheme := DefaultTheme;
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
  TfgAssert.IsNotNil(Value);
  FActions.Assign(Value);
end;

procedure TfgCustomActionSheet.Show;
var
  Params: TfgActionSheetQueryParams;
begin
  if Supported then
  begin
    Params.Owner := Self;
    Params.Title := Title;
    Params.Actions := Actions;
    Params.UseUIGuidline := UseUIGuidline;
    Params.Theme := Theme;
    Params.ShowCallback := FOnShow;
    Params.HideCallback := FOnHide;
    Params.ItemClickCallback := FOnItemClick;
    FActionSheetService.Show(Params);
  end;
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
