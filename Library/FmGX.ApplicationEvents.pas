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

unit FmGX.ApplicationEvents;

interface

{$SCOPEDENUMS ON}

uses
  System.Messaging, System.Classes, {$IFDEF ANDROID}Androidapi.JNI.GraphicsContentViewText, Androidapi.Helpers, {$ENDIF}
  FMX.Types, FMX.Platform, FMX.Forms, FmGX.Consts, FMX.Controls;

type

{$IFDEF ANDROID}
  TIntent = JIntent;
{$ELSE}
  TIntent = type TObject;
{$ENDIF}

(*
// TBeforeStyleChangingMessage
*)

{ TfgApplicationEvents }

  TfgxDeviceOrientationChangedEvent = procedure (const AOrientation: TScreenOrientation) of object;
  TfgxMainFormChangedEvent = procedure (Sender: TObject; const ANewForm: TCommonCustomForm) of object;
  TfgxMainFormCaptionChangedEvent = procedure (Sender: TObject; const ANewForm: TCommonCustomForm; const ANewCaption: string) of object;
  TfgxStyleChangedEvent = procedure (Sender: TObject; const AScene: IScene; const AStyleBook: TStyleBook) of object;
  TfgxFormNotifyEvent = procedure (Sender: TObject; const AForm: TCommonCustomForm) of object;
  TfgxActivityResultEvent = procedure (Sender: TObject; const ARequestCode: Integer; const AResultCode: Integer;
    const AIntent: TIntent) of object;

  [ComponentPlatformsAttribute(fgAllPlatform)]
  TfgxApplicationEvents = class(TFmxObject)
  private
    FOnActivityResult: TfgxActivityResultEvent;
    FOnActionUpdate: TActionEvent;
    FOnActionExecute: TActionEvent;
    FOnException: TExceptionEvent;
    FOnOrientationChanged: TfgxDeviceOrientationChangedEvent;
    FOnFormSizeChanged: TfgxFormNotifyEvent;
    FOnMainFormChanged: TfgxMainFormChangedEvent;
    FOnMainFormCaptionChanged: TfgxMainFormCaptionChangedEvent;
    FOnIdle: TIdleEvent;
    FOnSaveState: TNotifyEvent;
    FOnStateChanged: TApplicationEventHandler;
    FOnStyleChanged: TfgxStyleChangedEvent;
    FOnFormsCreated: TNotifyEvent;
    FOnFormReleased: TfgxFormNotifyEvent;
    FOnFormBeforeShown: TfgxFormNotifyEvent;
    FOnFormActivate: TfgxFormNotifyEvent;
    FOnFormDeactivate: TfgxFormNotifyEvent;

    FOnFormCreate: TfgxFormNotifyEvent;
    FOnFormDestroy: TfgxFormNotifyEvent;
    FOnScaleChanged: TNotifyEvent;

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
    procedure ActivityResultMessageHandler(const ASender: TObject; const AMessage: TMessage);
    procedure FormBeforeShownHandler(const ASender: TObject; const AMessage: TMessage);
    procedure FormActivateHandler(const ASender: TObject; const AMessage: TMessage);
    procedure FormDeactivateHandler(const ASender: TObject; const AMessage: TMessage);
    procedure ScaleChangedHandler(const ASender: TObject; const AMessage: TMessage);
    procedure FormAfterCreateHandler(const ASender: TObject; const AMessage: TMessage);
    procedure FormBeforeDestroyHandler(const ASender: TObject; const AMessage: TMessage);
  protected
    procedure DoStateChanged(const AEventData: TApplicationEventData); virtual;
    procedure DoOrientationChanged(const AOrientation: TScreenOrientation); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property OnActivityResult: TfgxActivityResultEvent read FOnActivityResult write FOnActivityResult;
    property OnActionExecute: TActionEvent read FOnActionExecute write SetOnActionExecute;
    property OnActionUpdate: TActionEvent read FOnActionUpdate write SetOnActionUpdate;
    property OnException: TExceptionEvent read FOnException write SetOnException;
    property OnIdle: TIdleEvent read FOnIdle write SetOnIdle;
    property OnFormSizeChanged: TfgxFormNotifyEvent read FOnFormSizeChanged write FOnFormSizeChanged;
    property OnSaveState: TNotifyEvent read FOnSaveState write FOnSaveState;
    property OnStateChanged: TApplicationEventHandler read FOnStateChanged write FOnStateChanged;
    property OnStyleChanged: TfgxStyleChangedEvent read FOnStyleChanged write FOnStyleChanged;
    property OnOrientationChanged: TfgxDeviceOrientationChangedEvent read FOnOrientationChanged write FOnOrientationChanged;
    property OnFormsCreated: TNotifyEvent read FOnFormsCreated write FOnFormsCreated;
    property OnFormReleased: TfgxFormNotifyEvent read FOnFormReleased write FOnFormReleased;
    property OnFormBeforeShown: TfgxFormNotifyEvent read FOnFormBeforeShown write FOnFormBeforeShown;
    property OnFormActivate: TfgxFormNotifyEvent read FOnFormActivate write FOnFormActivate;
    property OnFormDeactivate: TfgxFormNotifyEvent read FOnFormDeactivate write FOnFormDeactivate;
    property OnFormCreate: TfgxFormNotifyEvent read FOnFormCreate write FOnFormCreate;
    property OnFormDestroy: TfgxFormNotifyEvent read FOnFormDestroy write FOnFormDestroy;
    property OnScaleChanged: TNotifyEvent read FOnScaleChanged write FOnScaleChanged;
    property OnMainFormChanged: TfgxMainFormChangedEvent read FOnMainFormChanged write FOnMainFormChanged;
    property OnMainFormCaptionChanged: TfgxMainFormCaptionChangedEvent read FOnMainFormCaptionChanged write FOnMainFormCaptionChanged;
  end;

implementation

uses
  FmGX.Helpers, FmGX.Asserts;

{ TfgApplicationEvents }

constructor TfgxApplicationEvents.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TMessageManager.DefaultManager.SubscribeToMessage(TApplicationEventMessage, ApplicationEventChangedMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TOrientationChangedMessage, OrientationChangedMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TFormsCreatedMessage, FormsCreatedMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TMainFormChangedMessage, MainFormChangedMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TMainCaptionChangedMessage, MainFormCaptionChangedMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TStyleChangedMessage, StyleChangedMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TSaveStateMessage, SaveStateMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TScaleChangedMessage, ScaleChangedHandler);
  { Form size }
  TMessageManager.DefaultManager.SubscribeToMessage(TSizeChangedMessage, FormSizeChangedHandler);
  { Form Creation / Destroying }
  TMessageManager.DefaultManager.SubscribeToMessage(TAfterCreateFormHandle, FormAfterCreateHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TBeforeDestroyFormHandle, FormBeforeDestroyHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TFormReleasedMessage, FormReleasedHandler);
  { Form Activation / Deactiovation }
  TMessageManager.DefaultManager.SubscribeToMessage(TFormActivateMessage, FormActivateHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TFormDeactivateMessage, FormDeactivateHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TFormBeforeShownMessage, FormBeforeShownHandler);
{$IFDEF ANDROID}
  TMessageManager.DefaultManager.SubscribeToMessage(TMessageResultNotification, ActivityResultMessageHandler);
{$ENDIF}
end;

destructor TfgxApplicationEvents.Destroy;
begin
{$IFDEF ANDROID}
  TMessageManager.DefaultManager.Unsubscribe(TMessageResultNotification, ActivityResultMessageHandler);
{$ENDIF}
  TMessageManager.DefaultManager.Unsubscribe(TScaleChangedMessage, ScaleChangedHandler);
  TMessageManager.DefaultManager.Unsubscribe(TAfterCreateFormHandle, FormAfterCreateHandler);
  TMessageManager.DefaultManager.Unsubscribe(TBeforeDestroyFormHandle, FormBeforeDestroyHandler);
  TMessageManager.DefaultManager.Unsubscribe(TFormBeforeShownMessage, FormBeforeShownHandler);
  TMessageManager.DefaultManager.Unsubscribe(TFormActivateMessage, FormActivateHandler);
  TMessageManager.DefaultManager.Unsubscribe(TFormDeactivateMessage, FormDeactivateHandler);
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

procedure TfgxApplicationEvents.ActivityResultMessageHandler(const ASender: TObject; const AMessage: TMessage);
{$IFDEF ANDROID}
var
  Message: TMessageResultNotification;
begin
  TfgxAssert.IsNotNil(AMessage);
  TfgxAssert.IsClass(AMessage, TMessageResultNotification);

  if (AMessage is TMessageResultNotification) and Assigned(FOnActivityResult) then
  begin
    Message := TMessageResultNotification(AMessage);
    FOnActivityResult(Self, Message.RequestCode, Message.ResultCode, Message.Value);
  end;
end;
{$ELSE}
begin
  // Don't have meaning for other platform
end;
{$ENDIF}

procedure TfgxApplicationEvents.ApplicationEventChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
var
  EventData: TApplicationEventData;
begin
  TfgxAssert.IsNotNil(AMessage);
  TfgxAssert.IsClass(AMessage, TApplicationEventMessage);

  if AMessage is TApplicationEventMessage then
  begin
    EventData := TApplicationEventMessage(AMessage).Value;
    DoStateChanged(EventData)
  end;
end;

procedure TfgxApplicationEvents.DoOrientationChanged(const AOrientation: TScreenOrientation);
begin
  if Assigned(OnOrientationChanged) then
    OnOrientationChanged(AOrientation);
end;

procedure TfgxApplicationEvents.OrientationChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
begin
  TfgxAssert.IsNotNil(AMessage);
  TfgxAssert.IsClass(AMessage, TOrientationChangedMessage);

  if AMessage is TOrientationChangedMessage then
    DoOrientationChanged(Screen.Orientation);
end;

procedure TfgxApplicationEvents.SaveStateMessageHandler(const ASender: TObject; const AMessage: TMessage);
begin
  TfgxAssert.IsNotNil(AMessage);
  TfgxAssert.IsClass(AMessage, TSaveStateMessage);

  if AMessage is TSaveStateMessage then
    if Assigned(OnSaveState) then
      OnSaveState(Self);
end;

procedure TfgxApplicationEvents.ScaleChangedHandler(const ASender: TObject; const AMessage: TMessage);
begin
  TfgxAssert.IsNotNil(AMessage);
  TfgxAssert.IsClass(AMessage, TScaleChangedMessage);

  if (AMessage is TScaleChangedMessage) and Assigned(OnScaleChanged) then
    OnScaleChanged(Self);
end;

procedure TfgxApplicationEvents.SetOnActionExecute(const Value: TActionEvent);
begin
  TfgxAssert.IsNotNil(Application);

  FOnActionExecute := Value;
  Application.OnActionExecute := Value;
end;

procedure TfgxApplicationEvents.SetOnActionUpdate(const Value: TActionEvent);
begin
  TfgxAssert.IsNotNil(Application);

  FOnActionUpdate := Value;
  Application.OnActionUpdate := Value;
end;

procedure TfgxApplicationEvents.SetOnException(const Value: TExceptionEvent);
begin
  TfgxAssert.IsNotNil(Application);

  FOnException := Value;
  Application.OnException := Value;
end;

procedure TfgxApplicationEvents.SetOnIdle(const Value: TIdleEvent);
begin
  TfgxAssert.IsNotNil(Application);

  FOnIdle := Value;
  Application.OnIdle := Value;
end;

procedure TfgxApplicationEvents.StyleChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
var
  Scene: IScene;
  StyleBook: TStyleBook;
begin
  TfgxAssert.IsNotNil(AMessage);
  TfgxAssert.IsClass(AMessage, TStyleChangedMessage);

  if (AMessage is TStyleChangedMessage) and Assigned(OnStyleChanged) then
  begin
    Scene := TStyleChangedMessage(AMessage).Scene;
    StyleBook := TStyleChangedMessage(AMessage).Value;
    OnStyleChanged(Self, Scene, StyleBook);
  end;
end;

procedure TfgxApplicationEvents.DoStateChanged(const AEventData: TApplicationEventData);
begin
  if Assigned(OnStateChanged) then
    OnStateChanged(AEventData.Event, AEventData.Context);
end;

procedure TfgxApplicationEvents.FormActivateHandler(const ASender: TObject; const AMessage: TMessage);
var
  Form: TCommonCustomForm;
begin
  TfgxAssert.IsNotNil(AMessage);
  TfgxAssert.IsClass(AMessage, TFormActivateMessage);

  if (AMessage is TFormActivateMessage) and Assigned(OnFormActivate) then
  begin
    Form := TFormActivateMessage(AMessage).Value;
    OnFormActivate(Self, Form);
  end;
end;

procedure TfgxApplicationEvents.FormAfterCreateHandler(const ASender: TObject; const AMessage: TMessage);
var
  Form: TCommonCustomForm;
begin
  TfgxAssert.IsNotNil(AMessage);
  TfgxAssert.IsClass(AMessage, TAfterCreateFormHandle);

  if (AMessage is TAfterCreateFormHandle) and Assigned(OnFormCreate) then
  begin
    Form := TAfterCreateFormHandle(AMessage).Value;
    OnFormCreate(Self, Form);
  end;
end;

procedure TfgxApplicationEvents.FormBeforeDestroyHandler(const ASender: TObject; const AMessage: TMessage);
var
  Form: TCommonCustomForm;
begin
  TfgxAssert.IsNotNil(AMessage);
  TfgxAssert.IsClass(AMessage, TBeforeDestroyFormHandle);
  TfgxAssert.IsClass(ASender, TCommonCustomForm);

  if (AMessage is TBeforeDestroyFormHandle) and Assigned(OnFormDestroy) then
  begin
    Form := TCommonCustomForm(ASender);
    OnFormDestroy(Self, Form);
  end;
end;

procedure TfgxApplicationEvents.FormBeforeShownHandler(const ASender: TObject; const AMessage: TMessage);
var
  Form: TCommonCustomForm;
begin
  TfgxAssert.IsNotNil(AMessage);
  TfgxAssert.IsClass(AMessage, TFormBeforeShownMessage);

  if (AMessage is TFormBeforeShownMessage) and Assigned(OnFormBeforeShown) then
  begin
    Form := TFormBeforeShownMessage(AMessage).Value;
    OnFormBeforeShown(Self, Form);
  end;
end;

procedure TfgxApplicationEvents.FormDeactivateHandler(const ASender: TObject; const AMessage: TMessage);
var
  Form: TCommonCustomForm;
begin
  TfgxAssert.IsNotNil(AMessage);
  TfgxAssert.IsClass(AMessage, TFormDeactivateMessage);

  if (AMessage is TFormDeactivateMessage) and Assigned(OnFormDeactivate) then
  begin
    Form := TFormDeactivateMessage(AMessage).Value;
    OnFormDeactivate(Self, Form);
  end;
end;

procedure TfgxApplicationEvents.FormReleasedHandler(const ASender: TObject; const AMessage: TMessage);
var
  Form: TCommonCustomForm;
begin
  TfgxAssert.IsNotNil(AMessage);
  TfgxAssert.IsClass(AMessage, TFormReleasedMessage);
  TfgxAssert.IsClass(ASender, TCommonCustomForm);

  if (AMessage is TFormReleasedMessage) and Assigned(OnFormReleased) then
  begin
    Form := TCommonCustomForm(ASender);
    OnFormReleased(Self, Form);
  end;
end;

procedure TfgxApplicationEvents.FormsCreatedMessageHandler(const ASender: TObject; const AMessage: TMessage);
begin
  if Assigned(OnFormsCreated) then
    OnFormsCreated(Self);
end;

procedure TfgxApplicationEvents.FormSizeChangedHandler(const ASender: TObject; const AMessage: TMessage);
var
  Form: TCommonCustomForm;
begin
  TfgxAssert.IsNotNil(AMessage);
  TfgxAssert.IsClass(AMessage, TSizeChangedMessage);
  TfgxAssert.IsClass(ASender, TCommonCustomForm);

  if (AMessage is TSizeChangedMessage) and Assigned(OnFormSizeChanged) then
  begin
    Form := TCommonCustomForm(ASender);
    OnFormSizeChanged(Self, Form);
  end;
end;

procedure TfgxApplicationEvents.MainFormCaptionChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
var
  MainForm: TCommonCustomForm;
  Caption: string;
begin
  TfgxAssert.IsNotNil(AMessage);
  TfgxAssert.IsClass(AMessage, TMainCaptionChangedMessage);

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

procedure TfgxApplicationEvents.MainFormChangedMessageHandler(const ASender: TObject; const AMessage: TMessage);
begin
  TfgxAssert.IsNotNil(AMessage);
  TfgxAssert.IsClass(AMessage, TMainFormChangedMessage);

  if AMessage is TMainFormChangedMessage then
  begin
    if Assigned(OnMainFormChanged) then
      OnMainFormChanged(Self, TMainFormChangedMessage(AMessage).Value);
  end;
end;

initialization
  RegisterFmxClasses([TfgxApplicationEvents]);
end.
