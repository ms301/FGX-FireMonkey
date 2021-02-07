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

unit FmGX.ActionSheet;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes, FMX.Platform, FMX.Types, FmGX.ActionSheet.Types, FmGX.Consts;

type

{ TfgxActionSheet }

  TfgxCustomActionSheet = class(TFmxObject)
  public const
    DefaultUseUIGuidline = True;
    DefaultTheme = TfgxActionSheetTheme.Auto;
    DefaultThemeID = TfgxActionSheetQueryParams.UndefinedThemeID;
  private
    FActions: TfgxActionsCollections;
    FUseUIGuidline: Boolean;
    FTitle: string;
    FActionSheetService: IFGXActionSheetService;
    FTheme: TfgxActionSheetTheme;
    FThemeID: Integer;
    FOnItemClick: TfgxActionSheetItemClickEvent;
    FOnShow: TNotifyEvent;
    FOnHide: TNotifyEvent;
    procedure SetActions(const Value: TfgxActionsCollections);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Show; virtual;
    function Supported: Boolean;
    property ActionSheetService: IFGXActionSheetService read FActionSheetService;
  public
    property Actions: TfgxActionsCollections read FActions write SetActions;
    property UseUIGuidline: Boolean read FUseUIGuidline write FUseUIGuidline default DefaultUseUIGuidline;
    property Theme: TfgxActionSheetTheme read FTheme write FTheme default DefaultTheme;
    /// <summary>ID of theme resource on Android</summary>
    /// <remark>Only for Android</remark>
    property ThemeID: Integer read FThemeID write FThemeID default DefaultThemeID;
    property Title: string read FTitle write FTitle;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnHide: TNotifyEvent read FOnHide write FOnHide;
    property OnItemClick: TfgxActionSheetItemClickEvent read FOnItemClick write FOnItemClick;
  end;

  [ComponentPlatformsAttribute(fgMobilePlatforms)]
  TfgxActionSheet = class(TfgxCustomActionSheet)
  published
    property Actions;
    property UseUIGuidline;
    property Theme;
    property ThemeID;
    property Title;
    { Events }
    property OnShow;
    property OnHide;
    property OnItemClick;
  end;

implementation

uses
  System.SysUtils, FmGX.Asserts
{$IFDEF IOS}
   , FmGX.ActionSheet.iOS
{$ENDIF}
{$IFDEF ANDROID}
   , FmGX.ActionSheet.Android
{$ENDIF}
;

{ TActionSheet }

constructor TfgxCustomActionSheet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FActions := TfgxActionsCollections.Create(Self);
  FUseUIGuidline := DefaultUseUIGuidline;
  FTheme := DefaultTheme;
  FThemeID := DefaultThemeID;
  TPlatformServices.Current.SupportsPlatformService(IFGXActionSheetService, FActionSheetService);
end;

destructor TfgxCustomActionSheet.Destroy;
begin
  FActionSheetService := nil;
  FreeAndNil(FActions);
  inherited Destroy;
end;

procedure TfgxCustomActionSheet.SetActions(const Value: TfgxActionsCollections);
begin
  TfgxAssert.IsNotNil(Value);

  FActions.Assign(Value);
end;

procedure TfgxCustomActionSheet.Show;
var
  Params: TfgxActionSheetQueryParams;
begin
  if Supported then
  begin
    Params.Owner := Self;
    Params.Title := Title;
    Params.Actions := Actions;
    Params.UseUIGuidline := UseUIGuidline;
    Params.Theme := Theme;
    Params.ThemeID := ThemeID;
    Params.ShowCallback := FOnShow;
    Params.HideCallback := FOnHide;
    Params.ItemClickCallback := FOnItemClick;
    FActionSheetService.Show(Params);
  end;
end;

function TfgxCustomActionSheet.Supported: Boolean;
begin
  Result := ActionSheetService <> nil;
end;

initialization
  RegisterFmxClasses([TfgxCustomActionSheet, TfgxActionSheet]);

{$IF Defined(IOS) OR Defined(ANDROID)}
  RegisterService;
{$ENDIF}
end.
