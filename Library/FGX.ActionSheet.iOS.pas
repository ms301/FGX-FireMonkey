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

unit FGX.ActionSheet.iOS;

interface

uses
  System.Classes, System.Generics.Collections, Macapi.ObjectiveC, iOSapi.CocoaTypes, iOSapi.UIKit, FMX.Helpers.iOS,
  FGX.ActionSheet, FGX.ActionSheet.Types;

type

  { TiOSActionSheetService }

  TiOSActionSheetDelegate = class;

  TiOSActionSheetService = class(TInterfacedObject, IFGXActionSheetService)
  private
    [Weak] FActions: TfgActionsCollections;
    FActionsLinks: TDictionary<NSInteger, TfgActionCollectionItem>;
    FActionSheet: UIActionSheet;
    FDelegate: TiOSActionSheetDelegate;
  protected
    procedure DoButtonClicked(const AButtonIndex: Integer); virtual;
    function CreateActionButton(const Action: TfgActionCollectionItem): NSInteger; virtual;
    procedure CreateSheetActions(const AUseUIGuidline: Boolean); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    { IFGXActionSheetService }
    procedure Show(const Title: string; Actions: TfgActionsCollections; const UseUIGuidline: Boolean = True);
  end;

  TNotifyButtonClicked = procedure (const AButtonIndex: Integer) of object;

  TiOSActionSheetDelegate = class(TOCLocal, UIActionSheetDelegate)
  private
    FOnButtonClicked: TNotifyButtonClicked;
  public
    constructor Create(const AOnButtonClicked: TNotifyButtonClicked);
    { UIActionSheetDelegate }
    procedure actionSheet(actionSheet: UIActionSheet; clickedButtonAtIndex: NSInteger); cdecl;
    procedure actionSheetCancel(actionSheet: UIActionSheet); cdecl;
    procedure didPresentActionSheet(actionSheet: UIActionSheet); cdecl;
    procedure willPresentActionSheet(actionSheet: UIActionSheet); cdecl;
  end;

procedure RegisterService;

implementation

uses
  System.SysUtils, System.Devices, Macapi.Helpers, FMX.Platform, FGX.Helpers.iOS, FGX.Asserts;

procedure RegisterService;
begin
  TPlatformServices.Current.AddPlatformService(IFGXActionSheetService, TiOSActionSheetService.Create);
end;

{ TiOSActionSheetService }

constructor TiOSActionSheetService.Create;
begin
  FDelegate := TiOSActionSheetDelegate.Create(DoButtonClicked);
  FActionsLinks := TDictionary<NSInteger, TfgActionCollectionItem>.Create;
end;

function TiOSActionSheetService.CreateActionButton(const Action: TfgActionCollectionItem): NSInteger;
begin
  AssertIsNotNil(Action);
  AssertIsNotNil(FActionsLinks);

  Result := FActionSheet.addButtonWithTitle(StrToNSStr(Action.Caption));
  FActionsLinks.Add(Result, Action);
end;

procedure TiOSActionSheetService.CreateSheetActions(const AUseUIGuidline: Boolean);

  function GetDeviceClass: TDeviceInfo.TDeviceClass;
  var
    DeviceService: IFMXDeviceService;
  begin
    if TPlatformServices.Current.SupportsPlatformService(IFMXDeviceService, DeviceService) then
      Result := DeviceService.GetDeviceClass
    else
      Result := TDeviceInfo.TDeviceClass.Unknown;
  end;

var
  Action: TfgActionCollectionItem;
  I: Integer;
  Index: Integer;
begin
  AssertIsNotNil(FActions);

  FActionsLinks.Clear;
  if AUseUIGuidline then
  begin
    { Get destructive action caption }
    Index := FActions.IndexOfDestructiveButton;
    if Index <> -1 then
    begin
      CreateActionButton(FActions[Index]);
      FActionSheet.setDestructiveButtonIndex(0);
    end;
  end;

  for I := 0 to FActions.Count - 1 do
  begin
    Action := FActions[I];
    if not Action.Visible then
      Continue;

    if (AUseUIGuidline and (Action.Style = TfgActionStyle.Normal)) or not AUseUIGuidline then
      CreateActionButton(Action);
  end;

  if AUseUIGuidline then
    { Apple doesn't recommend to use Cancel button on iPad
      See: https://developer.apple.com/library/ios/documentation/uikit/reference/UIActionSheet_Class/Reference/Reference.html#//apple_ref/occ/instp/UIActionSheet/cancelButtonIndex }
    if GetDeviceClass <> TDeviceInfo.TDeviceClass.Tablet then
    begin
      Index := FActions.IndexOfCancelButton;
      if Index <> -1 then
      begin
        CreateActionButton(FActions[Index]);
        FActionSheet.setCancelButtonIndex(FActionsLinks.Count - 1);
      end;
    end;
end;

destructor TiOSActionSheetService.Destroy;
begin
  FActions := nil;
  FreeAndNil(FActionsLinks);
  if FActionSheet <> nil then
  begin
    FActionSheet.release;
    FActionSheet := nil;
  end;
  FreeAndNil(FDelegate);
  inherited Destroy;
end;

procedure TiOSActionSheetService.DoButtonClicked(const AButtonIndex: Integer);

  function TryFindCancelAction: TfgActionCollectionItem;
  var
    IndexOfCancelButton: Integer;
  begin
    IndexOfCancelButton := FActions.IndexOfCancelButton;
    if IndexOfCancelButton = -1 then
      Result := nil
    else
      Result := FActions[IndexOfCancelButton];
  end;

var
  Action: TfgActionCollectionItem;
begin
  AssertIsNotNil(FActions);
  AssertIsNotNil(FActionsLinks);
  AssertInRange(AButtonIndex, -1, FActionsLinks.Count - 1);

  // iPad doesn't show Cancel button, so ipad AButtonIndex can be -1. It means, that user cancels actions.
  if AButtonIndex = -1 then
    Action := TryFindCancelAction
  else
    Action := FActionsLinks.Items[AButtonIndex];

  if Action <> nil then
  begin
    if Assigned(Action.OnClick) then
      Action.OnClick(Action)
    else
      Action.Action.ExecuteTarget(nil);
  end;
end;

procedure TiOSActionSheetService.Show(const Title: string; Actions: TfgActionsCollections; const UseUIGuidline: Boolean);
begin
  AssertIsNotNil(Actions);
  AssertIsNotNil(SharedApplication);
  AssertIsNotNil(SharedApplication.keyWindow);
  AssertIsNotNil(SharedApplication.keyWindow.rootViewController);

  FActions := Actions;
  { Removing old UIActionSheet and get new instance }
  if FActionSheet <> nil then
    FActionSheet.release;
  FActionSheet := TUIActionSheet.Alloc;
  FActionSheet.initWithTitle(StrToNSStr(Title), (FDelegate as ILocalObject).GetObjectID, nil, nil, nil);

  CreateSheetActions(UseUIGuidline);

  { Displaying }
  FActionSheet.showInView(SharedApplication.keyWindow.rootViewController.view);
end;

{ TiOSActionSheetDelegate }

procedure TiOSActionSheetDelegate.actionSheet(actionSheet: UIActionSheet; clickedButtonAtIndex: NSInteger);
begin
  if Assigned(FOnButtonClicked) then
    FOnButtonClicked(clickedButtonAtIndex);
end;

procedure TiOSActionSheetDelegate.actionSheetCancel(actionSheet: UIActionSheet);
begin
end;

constructor TiOSActionSheetDelegate.Create(const AOnButtonClicked: TNotifyButtonClicked);
begin
  inherited Create;
  FOnButtonClicked := AOnButtonClicked;
end;

procedure TiOSActionSheetDelegate.didPresentActionSheet(actionSheet: UIActionSheet);
begin
end;

procedure TiOSActionSheetDelegate.willPresentActionSheet(actionSheet: UIActionSheet);
begin
end;

end.
