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

unit FGX.ActionSheet.Android;

interface

uses
  System.Classes, System.Generics.Collections, Androidapi.JNIBridge, Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.App, Androidapi.JNI.JavaTypes, FGX.ActionSheet, FGX.ActionSheet.Types;

type

  { TAndroidActionSheetService }

  TfgActionSheetActionClickedListener = class;
  TfgActionSheetDialogDismissListener = class;
  TfgActionSheetDialogCancelListener = class;

  TfgAndroidActionSheetService = class(TInterfacedObject, IFGXActionSheetService)
  private
    [Weak] FOwner: TObject;
    FActionClickedListener: TfgActionSheetActionClickedListener;
    FDialogDismissListener: TfgActionSheetDialogDismissListener;
    FDialogCancelListener: TfgActionSheetDialogCancelListener;
    FActions: TfgActionsCollections;
    FVisibleActions: TList<TfgActionCollectionItem>;
    FOnShow: TNotifyEvent;
    FOnHide: TNotifyEvent;
    FOnItemClick: TfgActionSheetItemClickEvent;
  protected
    procedure DoButtonClicked(const AButtonIndex: Integer); virtual;
    procedure DoShow; virtual;
    procedure DoCancel; virtual;
    procedure DoHide; virtual;
    function ItemsToJavaArray: TJavaObjectArray<JCharSequence>; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    { IFGXActionSheetService }
    procedure Show(const AParams: TfgActionSheetQueryParams);
  public
    property Actions: TfgActionsCollections read FActions;
    property VisibleActions: TList<TfgActionCollectionItem> read FVisibleActions;
  end;

  TfgNotifyButtonClicked = procedure (const AButtonIndex: Integer) of object;
  TfgMethodCallback = procedure of object;

  TfgActionSheetActionClickedListener = class(TJavaLocal, JDialogInterface_OnClickListener)
  private
    FOnButtonClicked: TfgNotifyButtonClicked;
  public
    constructor Create(const AOnButtonClicked: TfgNotifyButtonClicked);
    { JPopupMenu_OnMenuItemClickListener }
     procedure onClick(dialog: JDialogInterface; which: Integer); cdecl;
  end;

  TfgActionSheetDialogDismissListener = class(TJavaLocal, JDialogInterface_OnDismissListener)
  private
    FOnHide: TfgMethodCallback;
  public
    constructor Create(const AOnHide: TfgMethodCallback);
    { JDialogInterface_OnDismissListener}
    procedure onDismiss(dialog: JDialogInterface); cdecl;
  end;

  TfgActionSheetDialogCancelListener = class(TJavaLocal, JDialogInterface_OnCancelListener)
  private
    FOnCancel: TfgMethodCallback;
  public
    constructor Create(const AOnCancel: TfgMethodCallback);
    { JDialogInterface_OnCancelListener}
    procedure onCancel(dialog: JDialogInterface); cdecl;
  end;

procedure RegisterService;

implementation

uses
  System.Math, System.SysUtils, Androidapi.Helpers, FMX.Platform, FMX.Platform.Android, FMX.Types, FMX.Controls,
  FMX.Dialogs, FGX.Helpers.Android, FMX.Helpers.Android, FGX.Asserts;

type

  TfgActionSheetThemeHelper = record helper for TfgActionSheetTheme
  public
    function ToThemeID: Integer;
  end;

procedure RegisterService;
begin
  if TOSVersion.Check(2, 0) then
    TPlatformServices.Current.AddPlatformService(IFGXActionSheetService, TfgAndroidActionSheetService.Create);
end;

{ TAndroidActionSheetService }

constructor TfgAndroidActionSheetService.Create;
begin
  FActionClickedListener := TfgActionSheetActionClickedListener.Create(DoButtonClicked);
  FDialogDismissListener := TfgActionSheetDialogDismissListener.Create(DoHide);
  FDialogCancelListener := TfgActionSheetDialogCancelListener.Create(DoCancel);
  FVisibleActions := TList<TfgActionCollectionItem>.Create;
end;

destructor TfgAndroidActionSheetService.Destroy;
begin
  FreeAndNil(FActionClickedListener);
  FreeAndNil(FVisibleActions);
  inherited Destroy;
end;

procedure TfgAndroidActionSheetService.DoButtonClicked(const AButtonIndex: Integer);
var
  Action: TfgActionCollectionItem;
begin
  TfgAssert.IsNotNil(VisibleActions, 'List of all actions (TActionCollection) already was destroyed');
  TfgAssert.InRange(AButtonIndex, 0, VisibleActions.Count - 1, 'Android returns wrong index of actions. Out of range.');
  TfgAssert.IsNotNil(VisibleActions[AButtonIndex]);

  if InRange(AButtonIndex, 0, VisibleActions.Count - 1) then
  begin
    Action := VisibleActions.Items[AButtonIndex];
    if Assigned(Action.OnClick) then
      Action.OnClick(Action)
    else if Action.Action <> nil then
      Action.Action.ExecuteTarget(nil);
    if Assigned(FOnItemClick) then
      FOnItemClick(FOwner, Action);
  end;
end;

procedure TfgAndroidActionSheetService.DoCancel;

  function IndexOfCancelButton: Integer;
  var
    I: Integer;
  begin
    Result := -1;
    for I := 0 to FVisibleActions.Count - 1 do
      if FVisibleActions[I].Style = TfgActionStyle.Cancel then
        Exit(I);
  end;

var
  Index: Integer;
begin
  TfgAssert.IsNotNil(FVisibleActions);

  if Assigned(FOnItemClick) then
  begin
    Index := IndexOfCancelButton;
    if InRange(Index, 0, FVisibleActions.Count - 1) then
      FOnItemClick(FOwner, FVisibleActions[Index]);
  end;
end;

procedure TfgAndroidActionSheetService.DoHide;
begin
  if Assigned(FOnHide) then
    FOnHide(FOwner);
end;

procedure TfgAndroidActionSheetService.DoShow;
begin
  if Assigned(FOnShow) then
    FOnShow(FOwner);
end;

function TfgAndroidActionSheetService.ItemsToJavaArray: TJavaObjectArray<JCharSequence>;
var
  Action: TfgActionCollectionItem;
  I: Integer;
  Items: TJavaObjectArray<JCharSequence>;
  IndexOffset: Integer;
begin
  TfgAssert.IsNotNil(VisibleActions);
  TfgAssert.IsNotNil(FActions);
  Assert(FActions.CountOfVisibleActions <= FActions.Count);

  FVisibleActions.Clear;
  IndexOffset := 0;
  Items := TJavaObjectArray<JCharSequence>.Create(FActions.CountOfVisibleActions);
  for I := 0 to FActions.Count - 1 do
  begin
    Action := FActions[I];
    if Action.Visible then
    begin
      Items.SetRawItem(I - IndexOffset, (StrToJCharSequence(Action.Caption) as ILocalObject).GetObjectID);
      FVisibleActions.Add(Action);
    end
    else
      Inc(IndexOffset);
  end;
  Result := Items;
end;

procedure TfgAndroidActionSheetService.Show(const AParams: TfgActionSheetQueryParams);
var
  DialogBuilder: JAlertDialog_Builder;
  Dialog: JAlertDialog;
  Items: TJavaObjectArray<JCharSequence>;
  ThemeID: Integer;
begin
  TfgAssert.IsNotNil(AParams.Actions);

  FActions := AParams.Actions;
  FOnHide := AParams.HideCallback;
  FOnShow := AParams.ShowCallback;
  FOnItemClick := AParams.ItemClickCallback;
  FOwner := AParams.Owner;

  { Create Alert Dialog }
  if (AParams.Theme = TfgActionSheetTheme.Custom) and (AParams.ThemeID <> TfgActionSheetQueryParams.UndefinedThemeID) then
    ThemeID := AParams.ThemeID
  else
    ThemeID := AParams.Theme.ToThemeID;
  DialogBuilder := TJAlertDialog_Builder.JavaClass.init(TAndroidHelper.Context, ThemeID);

  { Forming  Action List }
  Items := ItemsToJavaArray;
  if not AParams.Title.IsEmpty then
    DialogBuilder.setTitle(StrToJCharSequence(AParams.Title));
  DialogBuilder.setItems(Items, FActionClickedListener);
  DialogBuilder.setOnDismissListener(FDialogDismissListener);
  DialogBuilder.setOnCancelListener(FDialogCancelListener);
  DialogBuilder.setCancelable(True);

  DoShow;
  CallInUIThread(procedure begin
    Dialog := DialogBuilder.Create;
    Dialog.Show;
  end);
end;

{ TActionSheetListener }

constructor TfgActionSheetActionClickedListener.Create(const AOnButtonClicked: TfgNotifyButtonClicked);
begin
  inherited Create;
  FOnButtonClicked := AOnButtonClicked;
end;

procedure TfgActionSheetActionClickedListener.onClick(dialog: JDialogInterface; which: Integer);
begin
  if Assigned(FOnButtonClicked) then
    TThread.Synchronize(nil, procedure begin
      FOnButtonClicked(which);
    end);
end;

{ TfgActionSheetDialogDismissListener }

constructor TfgActionSheetDialogDismissListener.Create(const AOnHide: TfgMethodCallback);
begin
  inherited Create;
  FOnHide := AOnHide;
end;

procedure TfgActionSheetDialogDismissListener.onDismiss(dialog: JDialogInterface);
begin
  if Assigned(FOnHide) then
    FOnHide;
end;

{ TfgActionSheetDialogCancelListener }

constructor TfgActionSheetDialogCancelListener.Create(const AOnCancel: TfgMethodCallback);
begin
  inherited Create;
  FOnCancel := AOnCancel;
end;

procedure TfgActionSheetDialogCancelListener.onCancel(dialog: JDialogInterface);
begin
  if Assigned(FOnCancel) then
    FOnCancel;
end;

{ TfgActionSheetThemeHelper }

function TfgActionSheetThemeHelper.ToThemeID: Integer;
var
  ThemeID: Integer;
begin
  case Self of
    TfgActionSheetTheme.Auto:
      ThemeID := GetNativeTheme;
    TfgActionSheetTheme.Dark:
      ThemeID := TJAlertDialog.JavaClass.THEME_HOLO_DARK;
    TfgActionSheetTheme.Light:
      ThemeID := TJAlertDialog.JavaClass.THEME_HOLO_LIGHT;
  else
    ThemeID := GetNativeTheme;
  end;
  Result := ThemeID;
end;

end.
