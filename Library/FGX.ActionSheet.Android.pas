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
  System.Generics.Collections, Androidapi.JNIBridge, Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.App,
  Androidapi.JNI.JavaTypes, FGX.ActionSheet, FGX.ActionSheet.Types;

type

  { TAndroidActionSheetService }

  TfgActionSheetListener = class;

  TAndroidActionSheetService = class(TInterfacedObject, IFGXActionSheetService)
  private
    FListener: TfgActionSheetListener;
    FActions: TfgActionsCollections;
    FVisibleActions: TList<TfgActionCollectionItem>;
  protected
    procedure DoButtonClicked(const AButtonIndex: Integer); virtual;
    function ItemsToJavaArray: TJavaObjectArray<JCharSequence>; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    { IFGXActionSheetService }
    procedure Show(const ATitle: string; Actions: TfgActionsCollections; const UseUIGuidline: Boolean = True);
  public
    property Actions: TfgActionsCollections read FActions;
    property VisibleActions: TList<TfgActionCollectionItem> read FVisibleActions;
  end;

  TfgNotifyButtonClicked = procedure (const ButtonIndex: Integer) of object;

  TfgActionSheetListener = class(TJavaLocal, JDialogInterface_OnClickListener)
  private
    FOnButtonClicked: TfgNotifyButtonClicked;
  public
    constructor Create(const AOnButtonClicked: TfgNotifyButtonClicked);
    { JPopupMenu_OnMenuItemClickListener }
     procedure onClick(dialog: JDialogInterface; which: Integer); cdecl;
  end;

procedure RegisterService;

implementation

uses
  System.Classes, System.Math, System.SysUtils, Androidapi.Helpers, FMX.Platform, FMX.Platform.Android,
  FMX.Types, FMX.Controls, FMX.Dialogs, FGX.Helpers.Android, FMX.Helpers.Android, FGX.Asserts;

procedure RegisterService;
begin
  if TOSVersion.Check(2, 0) then
    TPlatformServices.Current.AddPlatformService(IFGXActionSheetService, TAndroidActionSheetService.Create);
end;

{ TAndroidActionSheetService }

constructor TAndroidActionSheetService.Create;
begin
  FListener := TfgActionSheetListener.Create(DoButtonClicked);
  FVisibleActions := TList<TfgActionCollectionItem>.Create;
end;

destructor TAndroidActionSheetService.Destroy;
begin
  FreeAndNil(FListener);
  FreeAndNil(FVisibleActions);
  inherited Destroy;
end;

procedure TAndroidActionSheetService.DoButtonClicked(const AButtonIndex: Integer);
var
  Action: TfgActionCollectionItem;
begin
  AssertIsNotNil(VisibleActions, 'List of all actions (TActionCollection) already was destroyed');
  AssertInRange(AButtonIndex, 0, VisibleActions.Count - 1, 'Android returns wrong index of actions. Out of range.');
  AssertIsNotNil(VisibleActions[AButtonIndex]);

  if InRange(AButtonIndex, 0, VisibleActions.Count - 1) then
  begin
    Action := VisibleActions.Items[AButtonIndex];
    if Assigned(Action.OnClick) then
      Action.OnClick(Action)
    else if Action.Action <> nil then
      Action.Action.ExecuteTarget(nil);
  end;
end;

function TAndroidActionSheetService.ItemsToJavaArray: TJavaObjectArray<JCharSequence>;
var
  Action: TfgActionCollectionItem;
  I: Integer;
  Items: TJavaObjectArray<JCharSequence>;
  IndexOffset: Integer;
begin
  AssertIsNotNil(VisibleActions);
  AssertIsNotNil(FActions);
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

procedure TAndroidActionSheetService.Show(const ATitle: string; Actions: TfgActionsCollections; const UseUIGuidline: Boolean = True);
var
  DialogBuilder: JAlertDialog_Builder;
  Dialog: JAlertDialog;
  Items: TJavaObjectArray<JCharSequence>;
begin
  AssertIsNotNil(Actions);

  FActions := Actions;

  { Create Alert Dialog }
  if TOSVersion.Major <= 2 then
    DialogBuilder := TJAlertDialog_Builder.JavaClass.init(TAndroidHelper.Context)
  else
    DialogBuilder := TJAlertDialog_Builder.JavaClass.init(TAndroidHelper.Context, GetNativeTheme);

  { Forming  Action List }
  Items := ItemsToJavaArray;
  if not ATitle.IsEmpty then
    DialogBuilder.setTitle(StrToJCharSequence(ATitle));
  DialogBuilder.setItems(Items, FListener);
  DialogBuilder.setCancelable(True);

  CallInUIThread(procedure begin
    Dialog := DialogBuilder.Create;
    Dialog.Show;
  end);
end;

{ TActionSheetListener }

constructor TfgActionSheetListener.Create(const AOnButtonClicked: TfgNotifyButtonClicked);
begin
  inherited Create;
  FOnButtonClicked := AOnButtonClicked;
end;

procedure TfgActionSheetListener.onClick(dialog: JDialogInterface; which: Integer);
begin
  if Assigned(FOnButtonClicked) then
    TThread.Synchronize(nil, procedure begin
      FOnButtonClicked(which);
    end);
end;

end.
