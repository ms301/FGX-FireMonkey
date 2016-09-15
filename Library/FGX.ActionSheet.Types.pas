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

unit FGX.ActionSheet.Types;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes, FMX.ActnList;

resourcestring
  SNormal = 'Normal';
  SCancel = 'Cancel';
  SDestructive = 'Destructive';
  SUnknown = 'Unknown';
  SErrorWrongIndex = 'Wrong Index: %d. Admissible range is [0, %d]';

type

{ TfgActionsCollections }

  TfgActionStyle = (Normal, Cancel, Destructive);

  TfgActionStyleHelper = record helper for TfgActionStyle
    function ToString: string;
  end;

  TfgActionSheetTheme = (Auto, Dark, Light, Custom);

  TfgActionCollectionItem = class;

  TfgActionsCollections = class(TCollection)
  private
    FOwner: TPersistent;
    function GetAction(const Index: Integer): TfgActionCollectionItem;
    function GetCountOfVisibleActions: Integer;
  protected
    { Inherited }
    function GetOwner: TPersistent; override;
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
    { Manipulation }
    function IndexOfFirstAction(const AStyle: TfgActionStyle): Integer; virtual;
    procedure ItemChanged(const AItem: TfgActionCollectionItem); virtual;
  public
    constructor Create(const AOwner: TPersistent);
    /// <summary>
    ///   Return Index of first "destructive" action (action with style as acDestructive).
    ///   If action is not found, return -1
    /// </summary>
    function IndexOfDestructiveButton: Integer;
    function IndexOfCancelButton: Integer;
  public
    property Actions[const Index: Integer]: TfgActionCollectionItem read GetAction; default;
    property CountOfVisibleActions: Integer read GetCountOfVisibleActions;
  end;

{ TfgActionCollectionItem }

  TfgOnActionCollectionItemChanged = procedure (const AItem: TfgActionCollectionItem) of object;

  TfgActionCollectionItem = class(TCollectionItem)
  public const
    DefaultStyle = TfgActionStyle.Normal;
    DefaultVisible = True;
  private
    FActionLink: TActionLink;
    FCaption: string;
    FStyle: TfgActionStyle;
    FVisible: Boolean;
    FOnClick: TNotifyEvent;
    FOnInternalChanged: TfgOnActionCollectionItemChanged;
    procedure SetStyle(const Value: TfgActionStyle);
    function GetAction: TBasicAction;
    procedure SetAction(const Value: TBasicAction);
    procedure DoActionChange(Sender: TObject);
  protected
    procedure DoInternalChanged; virtual;
    { Inherited }
    procedure AssignTo(Dest: TPersistent); override;
    function Collection: TfgActionsCollections; virtual;
    function GetDisplayName: string; override;
    { Actions }
    procedure ActionChange(Sender: TBasicAction; CheckDefaults: Boolean); virtual;
    property ActionLink: TActionLink read FActionLink;
    property OnChanged: TfgOnActionCollectionItemChanged read FOnInternalChanged write FOnInternalChanged;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property Action: TBasicAction read GetAction write SetAction;
    property Caption: string read FCaption write FCaption;
    property Style: TfgActionStyle read FStyle write SetStyle default DefaultStyle;
    property Visible: Boolean read FVisible write FVisible default DefaultVisible;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

{ IFGXActionSheetService }

  TfgActionSheetItemClickEvent = procedure (Sender: TObject; const AAction: TfgActionCollectionItem) of object;

type

  TfgActionSheetQueryParams = record
  public
    const UndefinedThemeID = 0;
  public
    Owner: TObject;
    Title: string;
    Actions: TfgActionsCollections;
    UseUIGuidline: Boolean;
    Theme: TfgActionSheetTheme;
    ThemeID: Integer;
    ShowCallback: TNotifyEvent;
    HideCallback: TNotifyEvent;
    ItemClickCallback: TfgActionSheetItemClickEvent;
  end;

  IFGXActionSheetService = interface
  ['{70269D3A-52DF-484F-A241-DE9A07C0D593}']
    procedure Show(const AParams: TfgActionSheetQueryParams);
  end;

implementation

uses
  System.SysUtils, System.Math, System.Actions, System.RTLConsts, FMX.StdActns, FGX.Asserts;

type

{ TfgActionCollectionItemActionLink }

  TfgActionCollectionItemActionLink = class(FMX.ActnList.TActionLink)
  private
    FClient: TfgActionCollectionItem;
  protected
    property Client: TfgActionCollectionItem read FClient;
    procedure AssignClient(AClient: TObject); override;
    function IsCaptionLinked: Boolean; override;
    function IsVisibleLinked: Boolean; override;
    function IsOnExecuteLinked: Boolean; override;
    procedure SetCaption(const Value: string); override;
    procedure SetVisible(Value: Boolean); override;
    procedure SetOnExecute(Value: TNotifyEvent); override;
  end;

{ TfgActionsCollections }

constructor TfgActionsCollections.Create(const AOwner: TPersistent);
begin
  inherited Create(TfgActionCollectionItem);
  FOwner := AOwner;
end;

function TfgActionsCollections.GetAction(const Index: Integer): TfgActionCollectionItem;
begin
  TfgAssert.InRange(Index, 0, Count - 1);

  if not InRange(Index, 0, Count - 1) then
    raise EInvalidArgument.Create(Format(SErrorWrongIndex, [Index, Count - 1]));
  Result := Items[Index] as TfgActionCollectionItem;
end;

function TfgActionsCollections.GetCountOfVisibleActions: Integer;
var
  I: Integer;
  CountVisibleActions: Integer;
begin
  CountVisibleActions := 0;
  for I := 0 to Count - 1 do
    if Actions[I].Visible then
      Inc(CountVisibleActions);
  Result := CountVisibleActions;
end;

function TfgActionsCollections.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TfgActionsCollections.IndexOfFirstAction(const AStyle: TfgActionStyle): Integer;
var
  Index: Integer;
  Found: Boolean;
begin
  Index := 0;
  Found := False;
  while (Index < Count) and not Found do
    if Actions[Index].Style = AStyle then
      Found := True
    else
      Inc(Index);
  if Found then
    Result := Index
  else
    Result := -1;
end;

function TfgActionsCollections.IndexOfCancelButton: Integer;
begin
  Result := IndexOfFirstAction(TfgActionStyle.Cancel);
end;

function TfgActionsCollections.IndexOfDestructiveButton: Integer;
begin
  Result := IndexOfFirstAction(TfgActionStyle.Destructive);
end;

procedure TfgActionsCollections.ItemChanged(const AItem: TfgActionCollectionItem);
var
  I: Integer;
  Action: TfgActionCollectionItem;
begin
  TfgAssert.IsNotNil(AItem);

  // This collection doesn't suppport more then 1 item with Destructiv and Cancel style. So, we should reset style
  // for all items, if current item is not in normal style
  if AItem.Style <> TfgActionStyle.Normal then
    for I := 0 to Count - 1 do
    begin
      Action := Actions[I];
      if (Action <> AItem) and (Action.Style = AItem.Style) then
        Action.Style := TfgActionStyle.Normal;
    end;
end;

procedure TfgActionsCollections.Notify(Item: TCollectionItem; Action: TCollectionNotification);
begin
  TfgAssert.IsNotNil(Item);
  TfgAssert.IsClass(Item, TfgActionCollectionItem);

  if Action = TCollectionNotification.cnAdded then
    TfgActionCollectionItem(Item).OnChanged := ItemChanged;
end;

{ TfgActionCollectionItem }

procedure TfgActionCollectionItem.ActionChange(Sender: TBasicAction; CheckDefaults: Boolean);
begin
  TfgAssert.IsNotNil(Sender);

  if Sender is TCustomAction then
  begin
    if not CheckDefaults or not Caption.IsEmpty then
    begin
      if Sender is TSysCommonAction then
        Caption := TSysCommonAction(Sender).CustomText
      else
        Caption := TCustomAction(Sender).Caption;
      if Caption.IsEmpty then
        Caption := Sender.Name;
    end;
    Visible := TCustomAction(Sender).Visible;
    OnClick := TCustomAction(Sender).OnExecute;
  end;
end;

procedure TfgActionCollectionItem.AssignTo(Dest: TPersistent);
var
  DestAction: TfgActionCollectionItem;
begin
  if Dest is TfgActionCollectionItem then
  begin
    DestAction := Dest as TfgActionCollectionItem;
    DestAction.Action := Action;
    DestAction.Caption := Caption;
    DestAction.Visible := Visible;
    DestAction.Style := Style;
    DestAction.OnClick := OnClick;
  end
  else
    inherited AssignTo(Dest);
end;

function TfgActionCollectionItem.Collection: TfgActionsCollections;
begin
  TfgAssert.IsNotNil(Collection);
  TfgAssert.IsClass(Collection, TfgActionsCollections);

  Result := Collection as TfgActionsCollections;
end;

constructor TfgActionCollectionItem.Create(Collection: TCollection);
begin
  TfgAssert.IsNotNil(Collection);
  TfgAssert.IsClass(Collection, TfgActionsCollections);

  inherited Create(Collection);
  FStyle := DefaultStyle;
  FVisible := DefaultVisible;
end;

destructor TfgActionCollectionItem.Destroy;
begin
  FreeAndNil(FActionLink);
  inherited Destroy;
end;

procedure TfgActionCollectionItem.DoActionChange(Sender: TObject);
begin
  TfgAssert.IsClass(Sender, TBasicAction);

  if Sender = Action then
    ActionChange(TBasicAction(Sender), False);
end;

procedure TfgActionCollectionItem.DoInternalChanged;
begin
  if Assigned(FOnInternalChanged) then
    FOnInternalChanged(Self);
end;

function TfgActionCollectionItem.GetAction: TBasicAction;
begin
  if FActionLink <> nil then
    Result := FActionLink.Action
  else
    Result := nil;
end;

function TfgActionCollectionItem.GetDisplayName: string;
var
  ActionName: string;
begin
  if Caption.IsEmpty then
    ActionName := inherited GetDisplayName
  else
    ActionName := Caption;

  Result := Format('%s (%s)', [ActionName, Style.ToString]);
end;

procedure TfgActionCollectionItem.SetAction(const Value: TBasicAction);
begin
  if Value = nil then
    FreeAndNil(FActionLink)
  else
  begin
    if FActionLink = nil then
      FActionLink := TfgActionCollectionItemActionLink.Create(Self);
    ActionLink.Action := Value;
    ActionLink.OnChange := DoActionChange;
    ActionChange(Value, csLoading in Value.ComponentState);
  end;
end;

procedure TfgActionCollectionItem.SetStyle(const Value: TfgActionStyle);
begin
  if Style <> Value then
  begin
    FStyle := Value;
    DoInternalChanged;
  end;
end;

{ TfgActionCollectionItemActionLink }

procedure TfgActionCollectionItemActionLink.AssignClient(AClient: TObject);
begin
  TfgAssert.IsNotNil(AClient);
  TfgAssert.IsClass(AClient, TfgActionCollectionItem);

  if AClient = nil then
    raise EActionError.CreateFMT(SParamIsNil, ['AClient']);
  if not (AClient is TfgActionCollectionItem) then
    raise EActionError.CreateFmt(StrNoClientClass, [AClient.ClassName]);
  FClient := TfgActionCollectionItem(AClient);
end;

function TfgActionCollectionItemActionLink.IsCaptionLinked: Boolean;
begin
  TfgAssert.IsNotNil(FClient);
  TfgAssert.IsNotNil(Action);
  TfgAssert.IsClass(Action, TContainedAction);

  Result := inherited IsCaptionLinked and (FClient.Caption = TContainedAction(Action).Caption);
end;

function TfgActionCollectionItemActionLink.IsOnExecuteLinked: Boolean;
begin
  TfgAssert.IsNotNil(FClient);
  TfgAssert.IsNotNil(Action);
  TfgAssert.IsClass(Action, TContainedAction);

  Result := inherited IsOnExecuteLinked and (TMethod(FClient.OnClick) = TMethod(Action.OnExecute));
end;

function TfgActionCollectionItemActionLink.IsVisibleLinked: Boolean;
begin
  TfgAssert.IsNotNil(FClient);
  TfgAssert.IsNotNil(Action);
  TfgAssert.IsClass(Action, TContainedAction);

  Result := inherited IsVisibleLinked and (FClient.Visible = TContainedAction(Action).Visible);
end;

procedure TfgActionCollectionItemActionLink.SetCaption(const Value: string);
begin
  TfgAssert.IsNotNil(FClient);

  if IsCaptionLinked then
    FClient.Caption := Value;
end;

procedure TfgActionCollectionItemActionLink.SetOnExecute(Value: TNotifyEvent);
begin
  TfgAssert.IsNotNil(FClient);

  if IsOnExecuteLinked then
    FClient.OnClick := Value;
end;

procedure TfgActionCollectionItemActionLink.SetVisible(Value: Boolean);
begin
  TfgAssert.IsNotNil(FClient);

  if IsCaptionLinked then
    FClient.Visible := Value;
end;

{ TfgActionStyleHelper }

function TfgActionStyleHelper.ToString: string;
begin
  case Self of
    TfgActionStyle.Normal:      Result := SNormal;
    TfgActionStyle.Cancel:      Result := SCancel;
    TfgActionStyle.Destructive: Result := SDestructive;
  else
    Result := SUnknown;
  end;
end;

end.
