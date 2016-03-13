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
  System.Messaging, System.Classes, FMX.Types, FMX.Platform, FMX.Forms, FGX.Consts,
  FMX.Controls;

type

{ TfgApplicationEvents }

  TfgDeviceOrientationChanged = procedure (const AOrientation: TScreenOrientation) of object;
  TfgMainFormChanged = procedure (Sender: TObject; const ANewForm: TCommonCustomForm) of object;
  TfgMainFormCaptionChanged = procedure (Sender: TObject; const ANewForm: TCommonCustomForm; const ANewCaption: string) of object;
  TfgStyleChanged = procedure (Sender: TObject; const AScene: IScene; const AStyleBook: TStyleBook) of object;
  TfgFormNotify = procedure (Sender: TObject; const AForm: TCommonCustomForm) of object;

  [ComponentPlatformsAttribute(fgAllPlatform)]
  TfgApplicationEvents = class(TFmxObject)
  private
    FOnActionUpdate: TActionEvent;
    FOnActionExecute: TActionEvent;
    FOnException: TExceptionEvent;
    FOnOrientationChanged: TfgDeviceOrientationChanged;
    FOnFormSizeChanged: TfgFormNotify;
    FOnMainFormChanged: TfgMainFormChanged;
    FOnMainFormCaptionChanged: TfgMainFormCaptionChanged;
    FOnIdle: TIdleEvent;
    FOnSaveState: TNotifyEvent;
    FOnStateChanged: TApplicationEventHandler;
    FOnStyleChanged: TfgStyleChanged;
    FOnFormsCreated: TNotifyEvent;
    FOnFormReleased: TfgFormNotify;
    procedure SetOnActionExecute(const Value: TActionEvent);
    procedure SetOnActionUpdate(const Value: TActionEvent);
    procedure SetOnException(const Value: TExceptionEvent);
    procedure SetOnIdle(const Value: TIdleEvent);
    { Handlers }
    procedure ApplicationEventChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
    procedure OrientationChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
    procedure FormSizeChangedHandler(const ASender: TObject; const AMessage: TMessage);
    procedure FormReleasedHandler(const ASender: TObject; const AMessage: TMessage);
    procedure FormsCreatedMessageHandler(const ASender: TObject; const AMessage: TMessage);
    procedure MainFormChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
    procedure MainFormCaptionChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
    procedure StyleChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
    procedure SaveStateMessageHandler(const ASender: TObject; const AMessage: TMessage);
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
    property OnFormSizeChanged: TfgFormNotify read FOnFormSizeChanged write FOnFormSizeChanged;
    property OnSaveState: TNotifyEvent read FOnSaveState write FOnSaveState;
    property OnStateChanged: TApplicationEventHandler read FOnStateChanged write FOnStateChanged;
    property OnStyleChanged: TfgStyleChanged read FOnStyleChanged write FOnStyleChanged;
    property OnOrientationChanged: TfgDeviceOrientationChanged read FOnOrientationChanged write FOnOrientationChanged;
    property OnFormsCreated: TNotifyEvent read FOnFormsCreated write FOnFormsCreated;
    property OnFormReleased: TfgFormNotify read FOnFormReleased write FOnFormReleased;
    property OnMainFormChanged: TfgMainFormChanged read FOnMainFormChanged write FOnMainFormChanged;
    property OnMainFormCaptionChanged: TfgMainFormCaptionChanged read FOnMainFormCaptionChanged write FOnMainFormCaptionChanged;
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
  TMessageManager.DefaultManager.SubscribeToMessage(TFormsCreatedMessage, FormsCreatedMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TMainFormChangedMessage, MainFormChangedMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TMainCaptionChangedMessage, MainFormCaptionChangedMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TStyleChangedMessage, StyleChangedMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TSaveStateMessage, SaveStateMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TSizeChangedMessage, FormSizeChangedHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TFormReleasedMessage, FormReleasedHandler);

  { TODO -oBrovin Y.D. -cNextRelease : Need to add event handlers for these messages }
// TScaleChangedMessage
// TBeforeStyleChangingMessage
end;

destructor TfgApplicationEvents.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TFormReleasedMessage, FormReleasedHandler);
  TMessageManager.DefaultManager.Unsubscribe(TSizeChangedMessage, FormSizeChangedHandler);
  TMessageManager.DefaultManager.Unsubscribe(TSaveStateMessage, SaveStateMessageHandler);
  TMessageManager.DefaultManager.Unsubscribe(TStyleChangedMessage, StyleChangedMessageHandler);
  TMessageManager.DefaultManager.Unsubscribe(TMainCaptionChangedMessage, MainFormCaptionChangedMessageHandler);
  TMessageManager.DefaultManager.Unsubscribe(TMainFormChangedMessage, MainFormChangedMessageHandler);
  TMessageManager.DefaultManager.Unsubscribe(TFormsCreatedMessage, FormsCreatedMessageHandler);
  TMessageManager.DefaultManager.Unsubscribe(TOrientationChangedMessage, OrientationChangedMessageHandler);
  TMessageManager.DefaultManager.Unsubscribe(TApplicationEventMessage, ApplicationEventChangedMessageHandler);
  inherited Destroy;
end;

procedure TfgApplicationEvents.ApplicationEventChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
var
  EventData: TApplicationEventData;
begin
  AssertIsNotNil(AMessage);
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
  AssertIsNotNil(AMessage);
  AssertIsClass(AMessage, TOrientationChangedMessage);

  if AMessage is TOrientationChangedMessage then
    DoOrientationChanged(Screen.Orientation);
end;

procedure TfgApplicationEvents.SaveStateMessageHandler(const ASender: TObject; const AMessage: TMessage);
begin
  AssertIsNotNil(AMessage);
  AssertIsClass(AMessage, TSaveStateMessage);

  if AMessage is TSaveStateMessage then
    if Assigned(OnSaveState) then
      OnSaveState(Self);
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

procedure TfgApplicationEvents.StyleChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
var
  Scene: IScene;
  StyleBook: TStyleBook;
begin
  AssertIsNotNil(AMessage);
  AssertIsClass(AMessage, TStyleChangedMessage);

  if (AMessage is TStyleChangedMessage) and Assigned(OnStyleChanged) then
  begin
    Scene := TStyleChangedMessage(AMessage).Scene;
    StyleBook := TStyleChangedMessage(AMessage).Value;
    OnStyleChanged(Self, Scene, StyleBook);
  end;
end;

procedure TfgApplicationEvents.DoStateChanged(const AEventData: TApplicationEventData);
begin
  if Assigned(OnStateChanged) then
    OnStateChanged(AEventData.Event, AEventData.Context);
end;

procedure TfgApplicationEvents.FormReleasedHandler(const ASender: TObject; const AMessage: TMessage);
var
  Form: TCommonCustomForm;
begin
  AssertIsNotNil(AMessage);
  AssertIsClass(AMessage, TFormReleasedMessage);
  AssertIsClass(ASender, TCommonCustomForm);

  if (AMessage is TFormReleasedMessage) and Assigned(OnFormReleased) then
  begin
    Form := TCommonCustomForm(ASender);
    OnFormReleased(Self, Form);
  end;
end;

procedure TfgApplicationEvents.FormsCreatedMessageHandler(const ASender: TObject; const AMessage: TMessage);
begin
  if Assigned(OnFormsCreated) then
    OnFormsCreated(Self);
end;

procedure TfgApplicationEvents.FormSizeChangedHandler(const ASender: TObject; const AMessage: TMessage);
var
  Form: TCommonCustomForm;
begin
  AssertIsNotNil(AMessage);
  AssertIsClass(AMessage, TSizeChangedMessage);
  AssertIsClass(ASender, TCommonCustomForm);

  if (AMessage is TSizeChangedMessage) and Assigned(OnFormSizeChanged) then
  begin
    Form := TCommonCustomForm(ASender);
    OnFormSizeChanged(Self, Form);
  end;
end;

procedure TfgApplicationEvents.MainFormCaptionChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
var
  MainForm: TCommonCustomForm;
  Caption: string;
begin
  AssertIsNotNil(AMessage);
  AssertIsClass(AMessage, TMainCaptionChangedMessage);

  if AMessage is TMainCaptionChangedMessage then
  begin
    if Assigned(OnMainFormCaptionChanged) then
    begin
      MainForm := TMainCaptionChangedMessage(AMessage).Value;
      if MainForm <> nil then
        Caption := mainForm.Caption
      else
        Caption := '';
      OnMainFormCaptionChanged(Self, MainForm, Caption);
    end;
  end;
end;

procedure TfgApplicationEvents.MainFormChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
begin
  AssertIsNotNil(AMessage);
  AssertIsClass(AMessage, TMainFormChangedMessage);

  if AMessage is TMainFormChangedMessage then
  begin
    if Assigned(OnMainFormChanged) then
      OnMainFormChanged(Self, TMainFormChangedMessage(AMessage).Value);
  end;
end;

initialization
  RegisterFmxClasses([TfgApplicationEvents]);
end.
