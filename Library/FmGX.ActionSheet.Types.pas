{ *********************************************************************
  *
  * This Source Code Form is subject to the terms of the Mozilla Public
  * License, v. 2.0. If a copy of the MPL was not distributed with this
  * file, You can obtain one at http://mozilla.org/MPL/2.0/.
  *
  * Autor: Brovin Y.D.
  * E-mail: y.brovin@gmail.com
  *
  ******************************************************************** }

unit FmGX.ActionSheet.Types;

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

  TfgxActionStyle = (Normal, Cancel, Destructive);

  TfgxActionStyleHelper = record helper for TfgxActionStyle
    function ToString: string;
  end;

  TfgxActionSheetTheme = (Auto, Dark, Light, Custom);

  TfgxActionCollectionItem = class;

  TfgxActionsCollections = class(TCollection)
  private
    FOwner: TPersistent;
    function GetAction(const Index: Integer): TfgxActionCollectionItem;
    function GetCountOfVisibleActions: Integer;
  protected
    { Inherited }
    function GetOwner: TPersistent; override;
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
    { Manipulation }
    function IndexOfFirstAction(const AStyle: TfgxActionStyle): Integer; virtual;
    procedure ItemChanged(const AItem: TfgxActionCollectionItem); virtual;
  public
    constructor Create(const AOwner: TPersistent);
    /// <summary>
    /// Return Index of first "destructive" action (action with style as acDestructive).
    /// If action is not found, return -1
    /// </summary>
    function IndexOfDestructiveButton: Integer;
    function IndexOfCancelButton: Integer;
  public
    property Actions[const Index: Integer]: TfgxActionCollectionItem read GetAction; default;
    property CountOfVisibleActions: Integer read GetCountOfVisibleActions;
  end;

  { TfgActionCollectionItem }

  TfgxOnActionCollectionItemChanged = procedure(const AItem: TfgxActionCollectionItem) of object;

  TfgxActionCollectionItem = class(TCollectionItem)
  public const
    DefaultStyle = TfgxActionStyle.Normal;
    DefaultVisible = True;
  private
    FActionLink: TActionLink;
    FCaption: string;
    FStyle: TfgxActionStyle;
    FVisible: Boolean;
    FOnClick: TNotifyEvent;
    FOnInternalChanged: TfgxOnActionCollectionItemChanged;
    procedure SetStyle(const Value: TfgxActionStyle);
    function GetAction: TBasicAction;
    procedure SetAction(const Value: TBasicAction);
    procedure DoActionChange(Sender: TObject);
  protected
    procedure DoInternalChanged; virtual;
    { Inherited }
    procedure AssignTo(Dest: TPersistent); override;
    function Collection: TfgxActionsCollections; virtual;
    function GetDisplayName: string; override;
    { Actions }
    procedure ActionChange(Sender: TBasicAction; CheckDefaults: Boolean); virtual;
    property ActionLink: TActionLink read FActionLink;
    property OnChanged: TfgxOnActionCollectionItemChanged read FOnInternalChanged write FOnInternalChanged;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property Action: TBasicAction read GetAction write SetAction;
    property Caption: string read FCaption write FCaption;
    property Style: TfgxActionStyle read FStyle write SetStyle default DefaultStyle;
    property Visible: Boolean read FVisible write FVisible default DefaultVisible;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

  { IFGXActionSheetService }

  TfgxActionSheetItemClickEvent = procedure(Sender: TObject; const AAction: TfgxActionCollectionItem) of object;

type

  TfgxActionSheetQueryParams = record
  public const
    UndefinedThemeID = 0;
  public
    Owner: TObject;
    Title: string;
    Actions: TfgxActionsCollections;
    UseUIGuidline: Boolean;
    Theme: TfgxActionSheetTheme;
    ThemeID: Integer;
    ShowCallback: TNotifyEvent;
    HideCallback: TNotifyEvent;
    ItemClickCallback: TfgxActionSheetItemClickEvent;
  end;

  IFGXActionSheetService = interface
    ['{70269D3A-52DF-484F-A241-DE9A07C0D593}']
    procedure Show(const AParams: TfgxActionSheetQueryParams);
  end;

implementation

uses
  System.SysUtils, System.Math, System.Actions, System.RTLConsts, FMX.StdActns, FmGX.Asserts;

type

  { TfgActionCollectionItemActionLink }

  TfgxActionCollectionItemActionLink = class(FMX.ActnList.TActionLink)
  private
    FClient: TfgxActionCollectionItem;
  protected
    property Client: TfgxActionCollectionItem read FClient;
    procedure AssignClient(AClient: TObject); override;
    function IsCaptionLinked: Boolean; override;
    function IsVisibleLinked: Boolean; override;
    function IsOnExecuteLinked: Boolean; override;
    procedure SetCaption(const Value: string); override;
    procedure SetVisible(Value: Boolean); override;
    procedure SetOnExecute(Value: TNotifyEvent); override;
  end;

  { TfgActionsCollections }

constructor TfgxActionsCollections.Create(const AOwner: TPersistent);
begin
  inherited Create(TfgxActionCollectionItem);
  FOwner := AOwner;
end;

function TfgxActionsCollections.GetAction(const Index: Integer): TfgxActionCollectionItem;
begin
  TfgxAssert.InRange(Index, 0, Count - 1);

  if not InRange(Index, 0, Count - 1) then
    raise EInvalidArgument.Create(Format(SErrorWrongIndex, [Index, Count - 1]));
  Result := Items[Index] as TfgxActionCollectionItem;
end;

function TfgxActionsCollections.GetCountOfVisibleActions: Integer;
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

function TfgxActionsCollections.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TfgxActionsCollections.IndexOfFirstAction(const AStyle: TfgxActionStyle): Integer;
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

function TfgxActionsCollections.IndexOfCancelButton: Integer;
begin
  Result := IndexOfFirstAction(TfgxActionStyle.Cancel);
end;

function TfgxActionsCollections.IndexOfDestructiveButton: Integer;
begin
  Result := IndexOfFirstAction(TfgxActionStyle.Destructive);
end;

procedure TfgxActionsCollections.ItemChanged(const AItem: TfgxActionCollectionItem);
var
  I: Integer;
  Action: TfgxActionCollectionItem;
begin
  TfgxAssert.IsNotNil(AItem);

  // This collection doesn't suppport more then 1 item with Destructiv and Cancel style. So, we should reset style
  // for all items, if current item is not in normal style
  if AItem.Style <> TfgxActionStyle.Normal then
    for I := 0 to Count - 1 do
    begin
      Action := Actions[I];
      if (Action <> AItem) and (Action.Style = AItem.Style) then
        Action.Style := TfgxActionStyle.Normal;
    end;
end;

procedure TfgxActionsCollections.Notify(Item: TCollectionItem; Action: TCollectionNotification);
begin
  TfgxAssert.IsNotNil(Item);
  TfgxAssert.IsClass(Item, TfgxActionCollectionItem);

  if Action = TCollectionNotification.cnAdded then
    TfgxActionCollectionItem(Item).OnChanged := ItemChanged;
end;

{ TfgActionCollectionItem }

procedure TfgxActionCollectionItem.ActionChange(Sender: TBasicAction; CheckDefaults: Boolean);
begin
  TfgxAssert.IsNotNil(Sender);

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

procedure TfgxActionCollectionItem.AssignTo(Dest: TPersistent);
var
  DestAction: TfgxActionCollectionItem;
begin
  if Dest is TfgxActionCollectionItem then
  begin
    DestAction := Dest as TfgxActionCollectionItem;
    DestAction.Action := Action;
    DestAction.Caption := Caption;
    DestAction.Visible := Visible;
    DestAction.Style := Style;
    DestAction.OnClick := OnClick;
  end
  else
    inherited AssignTo(Dest);
end;

function TfgxActionCollectionItem.Collection: TfgxActionsCollections;
begin
  TfgxAssert.IsNotNil(Collection);
  TfgxAssert.IsClass(Collection, TfgxActionsCollections);

  Result := Collection as TfgxActionsCollections;
end;

constructor TfgxActionCollectionItem.Create(Collection: TCollection);
begin
  TfgxAssert.IsNotNil(Collection);
  TfgxAssert.IsClass(Collection, TfgxActionsCollections);

  inherited Create(Collection);
  FStyle := DefaultStyle;
  FVisible := DefaultVisible;
end;

destructor TfgxActionCollectionItem.Destroy;
begin
  FreeAndNil(FActionLink);
  inherited Destroy;
end;

procedure TfgxActionCollectionItem.DoActionChange(Sender: TObject);
begin
  TfgxAssert.IsClass(Sender, TBasicAction);

  if Sender = Action then
    ActionChange(TBasicAction(Sender), False);
end;

procedure TfgxActionCollectionItem.DoInternalChanged;
begin
  if Assigned(FOnInternalChanged) then
    FOnInternalChanged(Self);
end;

function TfgxActionCollectionItem.GetAction: TBasicAction;
begin
  if FActionLink <> nil then
    Result := FActionLink.Action
  else
    Result := nil;
end;

function TfgxActionCollectionItem.GetDisplayName: string;
var
  ActionName: string;
begin
  if Caption.IsEmpty then
    ActionName := inherited GetDisplayName
  else
    ActionName := Caption;

  Result := Format('%s (%s)', [ActionName, Style.ToString]);
end;

procedure TfgxActionCollectionItem.SetAction(const Value: TBasicAction);
begin
  if Value = nil then
    FreeAndNil(FActionLink)
  else
  begin
    if FActionLink = nil then
      FActionLink := TfgxActionCollectionItemActionLink.Create(Self);
    ActionLink.Action := Value;
    ActionLink.OnChange := DoActionChange;
    ActionChange(Value, csLoading in Value.ComponentState);
  end;
end;

procedure TfgxActionCollectionItem.SetStyle(const Value: TfgxActionStyle);
begin
  if Style <> Value then
  begin
    FStyle := Value;
    DoInternalChanged;
  end;
end;

{ TfgActionCollectionItemActionLink }

procedure TfgxActionCollectionItemActionLink.AssignClient(AClient: TObject);
begin
  TfgxAssert.IsNotNil(AClient);
  TfgxAssert.IsClass(AClient, TfgxActionCollectionItem);

  if AClient = nil then
    raise EActionError.CreateFMT(SParamIsNil, ['AClient']);
  if not(AClient is TfgxActionCollectionItem) then
    raise EActionError.CreateFMT(StrNoClientClass, [AClient.ClassName]);
  FClient := TfgxActionCollectionItem(AClient);
end;

function TfgxActionCollectionItemActionLink.IsCaptionLinked: Boolean;
begin
  TfgxAssert.IsNotNil(FClient);
  TfgxAssert.IsNotNil(Action);
  TfgxAssert.IsClass(Action, TContainedAction);

  Result := inherited IsCaptionLinked and (FClient.Caption = TContainedAction(Action).Caption);
end;

function TfgxActionCollectionItemActionLink.IsOnExecuteLinked: Boolean;
begin
  TfgxAssert.IsNotNil(FClient);
  TfgxAssert.IsNotNil(Action);
  TfgxAssert.IsClass(Action, TContainedAction);

  Result := inherited IsOnExecuteLinked and (TMethod(FClient.OnClick) = TMethod(Action.OnExecute));
end;

function TfgxActionCollectionItemActionLink.IsVisibleLinked: Boolean;
begin
  TfgxAssert.IsNotNil(FClient);
  TfgxAssert.IsNotNil(Action);
  TfgxAssert.IsClass(Action, TContainedAction);

  Result := inherited IsVisibleLinked and (FClient.Visible = TContainedAction(Action).Visible);
end;

procedure TfgxActionCollectionItemActionLink.SetCaption(const Value: string);
begin
  TfgxAssert.IsNotNil(FClient);

  if IsCaptionLinked then
    FClient.Caption := Value;
end;

procedure TfgxActionCollectionItemActionLink.SetOnExecute(Value: TNotifyEvent);
begin
  TfgxAssert.IsNotNil(FClient);

  if IsOnExecuteLinked then
    FClient.OnClick := Value;
end;

procedure TfgxActionCollectionItemActionLink.SetVisible(Value: Boolean);
begin
  TfgxAssert.IsNotNil(FClient);

  if IsCaptionLinked then
    FClient.Visible := Value;
end;

{ TfgActionStyleHelper }

function TfgxActionStyleHelper.ToString: string;
begin
  case Self of
    TfgxActionStyle.Normal:
      Result := SNormal;
    TfgxActionStyle.Cancel:
      Result := SCancel;
    TfgxActionStyle.Destructive:
      Result := SDestructive;
  else
    Result := SUnknown;
  end;
end;

end.
