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

unit FGX.ApplicationEvents;

interface

{$SCOPEDENUMS ON}

uses
  System.Messaging, System.Classes, FMX.Types, FMX.Platform, FMX.Forms;

type

{ TfgApplicationEvents }

  TfgDeviceOrientationChanged = procedure (const AOrientation: TScreenOrientation) of object;

  [ComponentPlatformsAttribute(pidWin32 or pidWin64 or pidOSX32 or pidAndroid or pidiOSDevice or pidiOSSimulator)]
  TfgApplicationEvents = class(TFmxObject)
  private
    FOnActionUpdate: TActionEvent;
    FOnActionExecute: TActionEvent;
    FOnException: TExceptionEvent;
    FOnIdle: TIdleEvent;
    FOnOrientationChanged: TfgDeviceOrientationChanged;
    FOnStateChanged: TApplicationEventHandler;
    procedure ApplicationEventChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
    procedure OrientationChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
    procedure SetOnActionExecute(const Value: TActionEvent);
    procedure SetOnActionUpdate(const Value: TActionEvent);
    procedure SetOnException(const Value: TExceptionEvent);
    procedure SetOnIdle(const Value: TIdleEvent);
  protected
    procedure DoStateChanged(const AEventData: TApplicationEventData); virtual;
    procedure DoOrientationChanged(const AOrientation: TScreenOrientation); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property OnActionExecute: TActionEvent read FOnActionExecute write SetOnActionExecute;
    property OnActionUpdate: TActionEvent read FOnActionUpdate write SetOnActionUpdate;
    property OnException: TExceptionEvent read FOnException write SetOnException;
    property OnIdle: TIdleEvent read FOnIdle write SetOnIdle;
    property OnStateChanged: TApplicationEventHandler read FOnStateChanged write FOnStateChanged;
    property OnOrientationChanged: TfgDeviceOrientationChanged read FOnOrientationChanged write FOnOrientationChanged;
  end;

implementation

uses
  FGX.Helpers, FGX.Asserts;

{ TfgApplicationEvents }

constructor TfgApplicationEvents.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TMessageManager.DefaultManager.SubscribeToMessage(TApplicationEventMessage, ApplicationEventChangedMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TOrientationChangedMessage, OrientationChangedMessageHandler);
end;

destructor TfgApplicationEvents.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TOrientationChangedMessage, OrientationChangedMessageHandler);
  TMessageManager.DefaultManager.Unsubscribe(TApplicationEventMessage, ApplicationEventChangedMessageHandler);
  inherited Destroy;
end;

procedure TfgApplicationEvents.ApplicationEventChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
var
  EventData: TApplicationEventData;
begin
  AssertIsClass(AMessage, TApplicationEventMessage);

  if AMessage is TApplicationEventMessage then
  begin
    EventData := TApplicationEventMessage(AMessage).Value;
    DoStateChanged(EventData)
  end;
end;

procedure TfgApplicationEvents.DoOrientationChanged(const AOrientation: TScreenOrientation);
begin
  if Assigned(OnOrientationChanged) then
    OnOrientationChanged(AOrientation);
end;

procedure TfgApplicationEvents.OrientationChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
begin
  AssertIsClass(AMessage, TOrientationChangedMessage);

  if AMessage is TOrientationChangedMessage then
    DoOrientationChanged(Screen.Orientation);
end;

procedure TfgApplicationEvents.SetOnActionExecute(const Value: TActionEvent);
begin
  AssertIsNotNil(Application);

  FOnActionExecute := Value;
  Application.OnActionExecute := Value;
end;

procedure TfgApplicationEvents.SetOnActionUpdate(const Value: TActionEvent);
begin
  AssertIsNotNil(Application);

  FOnActionUpdate := Value;
  Application.OnActionUpdate := Value;
end;

procedure TfgApplicationEvents.SetOnException(const Value: TExceptionEvent);
begin
  AssertIsNotNil(Application);

  FOnException := Value;
  Application.OnException := Value;
end;

procedure TfgApplicationEvents.SetOnIdle(const Value: TIdleEvent);
begin
  AssertIsNotNil(Application);

  FOnIdle := Value;
  Application.OnIdle := Value;
end;

procedure TfgApplicationEvents.DoStateChanged(const AEventData: TApplicationEventData);
begin
  if Assigned(OnStateChanged) then
    OnStateChanged(AEventData.Event, AEventData.Context);
end;

initialization
  RegisterFmxClasses([TfgApplicationEvents]);
end.
