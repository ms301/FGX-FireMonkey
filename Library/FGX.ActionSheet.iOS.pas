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
  System.Classes, System.Generics.Collections, System.TypInfo, Macapi.ObjectiveC, iOSapi.CocoaTypes, iOSapi.UIKit,
  iOSapi.Foundation, FMX.Helpers.iOS, FGX.ActionSheet, FGX.ActionSheet.Types;

type

  { TiOSActionSheetService }

  TfgIOSActionSheetDelegate = class;

  TfgIOSActionSheetService = class(TInterfacedObject, IFGXActionSheetService)
  private
    [Weak] FActions: TfgActionsCollections;
    [Weak] FOwner: TObject;
    FActionsLinks: TDictionary<NSInteger, TfgActionCollectionItem>;
    FActionSheet: UIActionSheet;
    FDelegate: TfgIOSActionSheetDelegate;
    FOnShow: TNotifyEvent;
    FOnHide: TNotifyEvent;
    FOnItemClick: TfgActionSheetItemClickEvent;
  protected
    procedure DoButtonClicked(const AButtonIndex: Integer); virtual;
    procedure DoShow; virtual;
    procedure DoHide; virtual;
    function CreateActionButton(const Action: TfgActionCollectionItem): NSInteger; virtual;
    procedure FillActionSheet(const AUseUIGuidline: Boolean); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    { IFGXActionSheetService }
    procedure Show(const AParams: TfgActionSheetQueryParams);
  end;

  TNotifyButtonClicked = procedure (const AButtonIndex: Integer) of object;
  TfgMethodCallback = procedure of object;

  IFGXDelayedQueueMessages = interface(NSObject)
  ['{E75C798C-C506-4ED5-B643-11C3E25417EA}']
    procedure InvokeActionExecute; cdecl;
    procedure InvokeHide; cdecl;
  end;

  TfgDelayedQueueMessages = class(TOCLocal)
  protected
    FButtonIndex: Integer;
    FOnInvoke: TNotifyButtonClicked;
    FOnHide: TfgMethodCallback;
    function GetObjectiveCClass: PTypeInfo; override;
  public
    procedure InvokeActionExecute; cdecl;
    procedure InvokeHide; cdecl;
  public
    property ButtonIndex: Integer read FButtonIndex write FButtonIndex;
    property OnInvoke: TNotifyButtonClicked read FOnInvoke write FOnInvoke;
    property OnHide: TfgMethodCallback read FOnHide write FOnHide;
  end;

  TfgIOSActionSheetDelegate = class(TOCLocal, UIActionSheetDelegate)
  private
    FQueue: TfgDelayedQueueMessages;
    FOnButtonClicked: TNotifyButtonClicked;
    FOnShow: TfgMethodCallback;
    FOnHide: TfgMethodCallback;
  public
    constructor Create(const AOnButtonClicked: TNotifyButtonClicked; const AOnShow, AOnHide: TfgMethodCallback);
    destructor Destroy; override;
    { UIActionSheetDelegate }
    procedure actionSheet(actionSheet: UIActionSheet; clickedButtonAtIndex: NSInteger); cdecl;
    procedure actionSheetCancel(actionSheet: UIActionSheet); cdecl;
    procedure didPresentActionSheet(actionSheet: UIActionSheet); cdecl;
    procedure willPresentActionSheet(actionSheet: UIActionSheet); cdecl;
  end;

procedure RegisterService;

implementation

uses
  System.SysUtils, System.Devices, Macapi.Helpers, FMX.Platform, FGX.Helpers.iOS, FGX.Asserts,
  Macapi.ObjCRuntime;

procedure RegisterService;
begin
  TPlatformServices.Current.AddPlatformService(IFGXActionSheetService, TfgIOSActionSheetService.Create);
end;

{ TiOSActionSheetService }

constructor TfgIOSActionSheetService.Create;
begin
  FDelegate := TfgIOSActionSheetDelegate.Create(DoButtonClicked, DoShow, DoHide);
  FActionsLinks := TDictionary<NSInteger, TfgActionCollectionItem>.Create;
end;

function TfgIOSActionSheetService.CreateActionButton(const Action: TfgActionCollectionItem): NSInteger;
begin
  AssertIsNotNil(Action);
  AssertIsNotNil(FActionsLinks);

  Result := FActionSheet.addButtonWithTitle(StrToNSStr(Action.Caption));
  FActionsLinks.Add(Result, Action);
end;

procedure TfgIOSActionSheetService.FillActionSheet(const AUseUIGuidline: Boolean);

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
  AssertIsNotNil(FActionsLinks);
  AssertIsNotNil(FActionSheet);

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

destructor TfgIOSActionSheetService.Destroy;
begin
  FOwner := nil;
  FOnHide := nil;
  FOnShow := nil;
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

procedure TfgIOSActionSheetService.DoButtonClicked(const AButtonIndex: Integer);

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
    else if Action.Action <> nil then
      Action.Action.ExecuteTarget(nil);

    if Assigned(FOnItemClick) then
      FOnItemClick(FOwner, Action);
  end;
end;

procedure TfgIOSActionSheetService.DoHide;
begin
  if Assigned(FOnHide) then
    FOnHide(FOwner);
end;

procedure TfgIOSActionSheetService.DoShow;
begin
  if Assigned(FOnShow) then
    FOnShow(FOwner);
end;

procedure TfgIOSActionSheetService.Show(const AParams: TfgActionSheetQueryParams);
var
  Theme: UIActionSheetStyle;
begin
  AssertIsNotNil(AParams.Actions);
  AssertIsNotNil(SharedApplication);
  AssertIsNotNil(SharedApplication.keyWindow);
  AssertIsNotNil(SharedApplication.keyWindow.rootViewController);

  FActions := AParams.Actions;
  FOnHide := AParams.HideCallback;
  FOnShow := AParams.ShowCallback;
  FOnItemClick := AParams.ItemClickCallback;
  FOwner := AParams.Owner;

  { Removing old UIActionSheet and get new instance }
  if FActionSheet <> nil then
    FActionSheet.release;

  FActionSheet := TUIActionSheet.Alloc;
  if AParams.Title.IsEmpty then
  begin
    FActionSheet.init;
    FActionSheet.setDelegate(FDelegate.GetObjectID);
  end
  else
    FActionSheet.initWithTitle(StrToNSStr(AParams.Title), FDelegate.GetObjectID, nil, nil, nil);

  FillActionSheet(AParams.UseUIGuidline);

  case AParams.Theme of
    TfgActionSheetTheme.Auto:
      Theme := UIActionSheetStyleAutomatic;
    TfgActionSheetTheme.Dark:
      Theme := UIActionSheetStyleBlackTranslucent;
  else
    Theme := UIActionSheetStyleAutomatic;
  end;
  FActionSheet.setActionSheetStyle(Theme);

  { Displaying }
  FActionSheet.showInView(SharedApplication.keyWindow.rootViewController.view);
end;

{ TiOSActionSheetDelegate }

procedure TfgIOSActionSheetDelegate.actionSheet(actionSheet: UIActionSheet; clickedButtonAtIndex: NSInteger);
begin
  FQueue.ButtonIndex := clickedButtonAtIndex;
  FQueue.OnInvoke := FOnButtonClicked;
  FQueue.OnHide := FOnHide;
  NSObject(FQueue.Super).performSelector(sel_getUid('InvokeActionExecute'), FQueue.GetObjectID, 1);
  NSObject(FQueue.Super).performSelector(sel_getUid('InvokeHide'), FQueue.GetObjectID, 1);
end;

procedure TfgIOSActionSheetDelegate.actionSheetCancel(actionSheet: UIActionSheet);
begin
  if Assigned(FOnHide) then
    FOnHide;
end;

constructor TfgIOSActionSheetDelegate.Create(const AOnButtonClicked: TNotifyButtonClicked; const AOnShow, AOnHide: TfgMethodCallback);
begin
  inherited Create;
  FQueue := TfgDelayedQueueMessages.Create;
  FOnButtonClicked := AOnButtonClicked;
  FOnShow := AOnShow;
  FOnHide := AOnHide;
end;

destructor TfgIOSActionSheetDelegate.Destroy;
begin
  FreeAndNil(FQueue);
  inherited;
end;

procedure TfgIOSActionSheetDelegate.didPresentActionSheet(actionSheet: UIActionSheet);
begin
  if Assigned(FOnShow) then
    FOnShow;
end;

procedure TfgIOSActionSheetDelegate.willPresentActionSheet(actionSheet: UIActionSheet);
begin
end;

{ TiOSQueue }

function TfgDelayedQueueMessages.GetObjectiveCClass: PTypeInfo;
begin
  Result := TypeInfo(IFGXDelayedQueueMessages);
end;

procedure TfgDelayedQueueMessages.InvokeActionExecute;
begin
  if Assigned(OnInvoke) then
    OnInvoke(FButtonIndex);
end;

procedure TfgDelayedQueueMessages.InvokeHide;
begin
  if Assigned(FOnHide) then
    FOnHide;
end;

end.
