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

unit FGX.ProgressDialog.iOS;

interface

uses
  System.UITypes, System.UIConsts, System.Messaging, System.TypInfo, Macapi.ObjectiveC, iOSapi.UIKit, iOSapi.Foundation,
  FGX.ProgressDialog, FGX.ProgressDialog.Types, FGX.Asserts;

const
  SHADOW_ALPHA       = 180;
  MESSAGE_FONT_SIZE  = 15;
  MESSAGE_MARGINS    = 5;
  MESSAGE_HEIGHT     = 20;
  INDICATOR_MARGIN   = 5;
  PROGRESSBAR_WIDTH  = 200;
  PROGRESSBAR_HEIGHT = 20;

type

  { TIOSProgressDialogService }

  TIOSProgressDialogService = class(TInterfacedObject, IFGXProgressDialogService)
  public
    { IFGXProgressDialogService }
    function CreateNativeProgressDialog(const AOwner: TObject): TfgNativeProgressDialog;
    function CreateNativeActivityDialog(const AOwner: TObject): TfgNativeActivityDialog;
  end;

  IiOSShadow = interface(NSObject)
  ['{5E0B5363-01B8-4670-A90A-107EDD428029}']
    procedure tap; cdecl;
  end;

  TiOSDelegate = class(TOCLocal)
  private
    [Weak] FNativeDialog: TfgNativeDialog;
  protected
    function GetObjectiveCClass: PTypeInfo; override;
  public
    constructor Create(const ADialog: TfgNativeDialog);
    { UIView }
    procedure tap; cdecl;
  end;

  TiOSNativeActivityDialog = class(TfgNativeActivityDialog)
  private
    FActivityIndicator: UIActivityIndicatorView;
    FShadow: TiOSDelegate;
    FShadowColor: TAlphaColor;
    FShadowView: UIView;
    FMessageLabel: UILabel;
    FMessageColor: TAlphaColor;
    FDelegate: TiOSDelegate;
    FTapRecognizer: UITapGestureRecognizer;
    procedure DoOrientationChanged(const Sender: TObject; const M: TMessage);
  protected
    procedure MessageChanged; override;
    procedure ThemeChanged; override;
    procedure UpdateTheme; virtual;
  public
    constructor Create(const AOwner: TObject); override;
    destructor Destroy; override;
    procedure Show; override;
    procedure Hide; override;
    procedure Realign;
  end;

  TiOSNativeProgressDialog = class(TfgNativeProgressDialog)
  private
    FDelegate: TiOSDelegate;
    FTapRecognizer: UITapGestureRecognizer;
    FProgressView: UIProgressView;
    FShadowColor: TAlphaColor;
    FShadowView: UIView;
    FMessageLabel: UILabel;
    FMessageColor: TAlphaColor;
    procedure DoOrientationChanged(const Sender: TObject; const M: TMessage);
  protected
    procedure MessageChanged; override;
    procedure ProgressChanged; override;
    procedure ThemeChanged; override;
    procedure UpdateTheme; virtual;
  public
    constructor Create(const AOwner: TObject); override;
    destructor Destroy; override;
    procedure ResetProgress; override;
    procedure Show; override;
    procedure Hide; override;
    procedure Realign;
  end;

procedure RegisterService;
procedure UnregisterService;

implementation

uses
  System.Types, System.Math, System.SysUtils, iOSapi.CoreGraphics, Macapi.ObjCRuntime, Macapi.Helpers,
  FMX.Platform, FMX.Platform.iOS, FMX.Forms, FMX.Helpers.iOS, FGX.Helpers.iOS;

procedure RegisterService;
begin
  TPlatformServices.Current.AddPlatformService(IFGXProgressDialogService, TIOSProgressDialogService.Create);
end;

procedure UnregisterService;
begin
  TPlatformServices.Current.RemovePlatformService(IFGXProgressDialogService);
end;

{ TIOSProgressDialogService }

function TIOSProgressDialogService.CreateNativeActivityDialog(const AOwner: TObject): TfgNativeActivityDialog;
begin
  Result := TiOSNativeActivityDialog.Create(AOwner);
end;

function TIOSProgressDialogService.CreateNativeProgressDialog(const AOwner: TObject): TfgNativeProgressDialog;
begin
  Result := TiOSNativeProgressDialog.Create(AOwner);
end;

{ TiOSNativeProgressDialog }

constructor TiOSNativeActivityDialog.Create(const AOwner: TObject);
begin
  TfgAssert.IsNotNil(MainScreen);
  TfgAssert.IsNotNil(SharedApplication.keyWindow);
  TfgAssert.IsNotNil(SharedApplication.keyWindow.rootViewController);
  TfgAssert.IsNotNil(SharedApplication.keyWindow.rootViewController.view);

  inherited Create(AOwner);
  FShadowColor := MakeColor(0, 0, 0, SHADOW_ALPHA);
  FMessageColor := TAlphaColorRec.White;

  FDelegate := TiOSDelegate.Create(Self);
  FTapRecognizer := TUITapGestureRecognizer.Create;
  FTapRecognizer.setNumberOfTapsRequired(1);
  FTapRecognizer.addTarget(FDelegate.GetObjectID, sel_getUid('tap'));

  // Shadow
  FShadowView := TUIView.Create;
  FShadowView.setUserInteractionEnabled(True);
  FShadowView.setHidden(True);
  FShadowView.setAutoresizingMask(UIViewAutoresizingFlexibleWidth or UIViewAutoresizingFlexibleHeight);
  FShadowView.setBackgroundColor(TUIColor.MakeColor(FShadowColor));
  FShadowView.addGestureRecognizer(FTapRecognizer);

  // Creating Ani indicator
  FActivityIndicator := TUIActivityIndicatorView.Alloc;
  FActivityIndicator.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleWhite);
  FActivityIndicator.setUserInteractionEnabled(False);
  FActivityIndicator.startAnimating;
  FActivityIndicator.setAutoresizingMask(UIViewAutoresizingFlexibleLeftMargin or UIViewAutoresizingFlexibleRightMargin);

  // Creating message label
  FMessageLabel := TUILabel.Create;
  FMessageLabel.setUserInteractionEnabled(False);
  FMessageLabel.setTextColor(TUIColor.MakeColor(FMessageColor));
  FMessageLabel.setBackgroundColor(TUIColor.clearColor);
  FMessageLabel.setFont(FMessageLabel.font.fontWithSize(MESSAGE_FONT_SIZE));
  FMessageLabel.setTextAlignment(UITextAlignmentCenter);

  // Adding view
  FShadowView.addSubview(FActivityIndicator);
  FShadowView.addSubview(FMessageLabel);

  // Adding Shadow to application
  SharedApplication.keyWindow.rootViewController.view.AddSubview(FShadowView);
  Realign;
  UpdateTheme;

  { Message subscription }
  TMessageManager.DefaultManager.SubscribeToMessage(TOrientationChangedMessage, DoOrientationChanged);
end;

destructor TiOSNativeActivityDialog.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TOrientationChangedMessage, DoOrientationChanged);
  FreeAndNil(FShadow);
  FActivityIndicator.removeFromSuperview;
  FActivityIndicator.release;
  FActivityIndicator := nil;
  FMessageLabel.removeFromSuperview;
  FMessageLabel.release;
  FMessageLabel := nil;
  FShadowView.removeFromSuperview;
  FShadowView.release;
  FShadowView := nil;
  inherited Destroy;
end;

procedure TiOSNativeActivityDialog.DoOrientationChanged(const Sender: TObject; const M: TMessage);
begin
  Realign;
end;

procedure TiOSNativeActivityDialog.Hide;
begin
  TfgAssert.IsNotNil(FShadowView);

  inherited;

  FadeOut(FShadowView, DEFAULT_ANIMATION_DURATION);
  DoHide;
end;

procedure TiOSNativeActivityDialog.MessageChanged;
begin
  TfgAssert.IsNotNil(FMessageLabel);

  FMessageLabel.setText(StrToNSStr(Message));

  // We should call it once for starting animation
  if IsShown then
    Application.ProcessMessages;
end;

procedure TiOSNativeActivityDialog.Realign;
var
  ScreenBounds: TSize;
  CenterPoint: NSPoint;
begin
  ScreenBounds := Screen.Size;
  FShadowView.setFrame(CGRect.Create(ScreenBounds.Width, ScreenBounds.Height));
  CenterPoint := FShadowView.center;
  FActivityIndicator.setCenter(CGPointMake(CenterPoint.X, CenterPoint.Y - FActivityIndicator.bounds.height - INDICATOR_MARGIN));
  FMessageLabel.setBounds(CGRect.Create(FShadowView.bounds.width, 25));
  FMessageLabel.setCenter(CGPointMake(CenterPoint.X, CenterPoint.Y + MESSAGE_MARGINS));
end;

procedure TiOSNativeActivityDialog.Show;
begin
  TfgAssert.IsNotNil(FShadowView);
  TfgAssert.IsNotNil(FMessageLabel);

  inherited;

  FadeIn(FShadowView, DEFAULT_ANIMATION_DURATION);
  DoShow;

  // We should call it once for starting animation
  Application.ProcessMessages;
end;

procedure TiOSNativeActivityDialog.ThemeChanged;
begin
  inherited;
  UpdateTheme;
end;

procedure TiOSNativeActivityDialog.UpdateTheme;
begin
  case Theme of
    TfgDialogTheme.Auto,
    TfgDialogTheme.Dark:
    begin
      FShadowColor := MakeColor(0, 0, 0, SHADOW_ALPHA);
      FMessageColor := TAlphaColorRec.White;
    end;
    TfgDialogTheme.Light:
    begin
      FShadowColor := MakeColor(255, 255, 255, SHADOW_ALPHA);
      FMessageColor := TAlphaColorRec.Black;
    end;
  else
    begin
      FShadowColor := MakeColor(0, 0, 0, SHADOW_ALPHA);
      FMessageColor := TAlphaColorRec.White;
    end;
  end;

  FShadowView.setBackgroundColor(TUIColor.MakeColor(FShadowColor));
  FMessageLabel.setTextColor(TUIColor.MakeColor(FMessageColor));
end;

{ TiOSNativeProgressDialog }

constructor TiOSNativeProgressDialog.Create(const AOwner: TObject);
begin
  TfgAssert.IsNotNil(MainScreen);
  TfgAssert.IsNotNil(SharedApplication.keyWindow);
  TfgAssert.IsNotNil(SharedApplication.keyWindow.rootViewController);
  TfgAssert.IsNotNil(SharedApplication.keyWindow.rootViewController.view);

  inherited Create(AOwner);
  FShadowColor := MakeColor(0, 0, 0, SHADOW_ALPHA);
  FMessageColor := TAlphaColorRec.White;

  FDelegate := TiOSDelegate.Create(Self);
  FTapRecognizer := TUITapGestureRecognizer.Create;
  FTapRecognizer.setNumberOfTapsRequired(1);
  FTapRecognizer.addTarget(FDelegate.GetObjectID, sel_getUid('tap'));

  // Shadow
  FShadowView := TUIView.Create;
  FShadowView.setUserInteractionEnabled(True);
  FShadowView.setHidden(True);
  FShadowView.setAutoresizingMask(UIViewAutoresizingFlexibleWidth or UIViewAutoresizingFlexibleHeight);
  FShadowView.setBackgroundColor(TUIColor.MakeColor(FShadowColor));
  FShadowView.addGestureRecognizer(FTapRecognizer);

  // Creating message label
  FMessageLabel := TUILabel.Create;
  FMessageLabel.setBackgroundColor(TUIColor.clearColor);
  FMessageLabel.setTextColor(TUIColor.whiteColor);
  FMessageLabel.setTextAlignment(UITextAlignmentCenter);
  FMessageLabel.setFont(FMessageLabel.font.fontWithSize(MESSAGE_FONT_SIZE));

  // Creating Ani indicator
  FProgressView := TUIProgressView.Alloc;
  FProgressView.initWithProgressViewStyle(UIProgressViewStyleDefault);

  // Adding view
  FShadowView.addSubview(FProgressView);
  FShadowView.addSubview(FMessageLabel);

  // Adding Shadow to application
  SharedApplication.keyWindow.rootViewController.view.AddSubview(FShadowView);
  Realign;
  UpdateTheme;

  { Message subscription }
  TMessageManager.DefaultManager.SubscribeToMessage(TOrientationChangedMessage, DoOrientationChanged);
end;

destructor TiOSNativeProgressDialog.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TOrientationChangedMessage, DoOrientationChanged);
  FreeAndNil(FDelegate);
  FProgressView.removeFromSuperview;
  FProgressView.release;
  FProgressView := nil;
  FMessageLabel.removeFromSuperview;
  FMessageLabel.release;
  FMessageLabel := nil;
  FShadowView.removeFromSuperview;
  FShadowView.release;
  FShadowView := nil;
  inherited Destroy;
end;

procedure TiOSNativeProgressDialog.DoOrientationChanged(const Sender: TObject; const M: TMessage);
begin
  Realign;
end;

procedure TiOSNativeProgressDialog.Hide;
begin
  TfgAssert.IsNotNil(FShadowView);

  inherited;

  FadeOut(FShadowView, DEFAULT_ANIMATION_DURATION);
  DoHide;
end;

procedure TiOSNativeProgressDialog.MessageChanged;
begin
  TfgAssert.IsNotNil(FMessageLabel);

  FMessageLabel.setText(StrToNSStr(Message));

  // We should call it once for starting animation
  if IsShown then
    Application.ProcessMessages;
end;

procedure TiOSNativeProgressDialog.ProgressChanged;
begin
  TfgAssert.IsNotNil(FProgressView);
  TfgAssert.InRange(Progress, 0, Max);

  if Max > 0 then
    FProgressView.setProgress(Progress / Max, True)
  else
    FProgressView.setProgress(0);

  // We should call it once for starting animation
  if IsShown then
    Application.ProcessMessages;
end;

procedure TiOSNativeProgressDialog.Realign;
var
  ScreenBounds: TSize;
  CenterPoint: NSPoint;
begin
  ScreenBounds := Screen.size;
  FShadowView.setFrame(CGRect.Create(ScreenBounds.Width, ScreenBounds.Height));
  CenterPoint := FShadowView.center;
  FMessageLabel.setBounds(CGRect.Create(FShadowView.bounds.width, MESSAGE_HEIGHT));
  FMessageLabel.setCenter(CGPointMake(CenterPoint.X, CenterPoint.Y - FMessageLabel.bounds.height));
  FProgressView.setBounds(CGRect.Create(PROGRESSBAR_WIDTH, PROGRESSBAR_HEIGHT));
  FProgressView.setCenter(CenterPoint);
end;

procedure TiOSNativeProgressDialog.ResetProgress;
begin
  TfgAssert.IsNotNil(FProgressView);

  inherited ResetProgress;
  FProgressView.setProgress(0);
end;

procedure TiOSNativeProgressDialog.Show;
begin
  TfgAssert.IsNotNil(FShadowView);

  inherited;

  FadeIn(FShadowView, DEFAULT_ANIMATION_DURATION);
  DoShow;

  // We should call it once for starting animation
  Application.ProcessMessages;
end;

procedure TiOSNativeProgressDialog.ThemeChanged;
begin
  inherited;
  UpdateTheme;
end;

procedure TiOSNativeProgressDialog.UpdateTheme;
begin
  case Theme of
    TfgDialogTheme.Auto,
    TfgDialogTheme.Dark:
    begin
      FShadowColor := MakeColor(0, 0, 0, SHADOW_ALPHA);
      FMessageColor := TAlphaColorRec.White;
    end;
    TfgDialogTheme.Light:
    begin
      FShadowColor := MakeColor(255, 255, 255, SHADOW_ALPHA);
      FMessageColor := TAlphaColorRec.Black;
    end;
  else
    begin
      FShadowColor := MakeColor(0, 0, 0, SHADOW_ALPHA);
      FMessageColor := TAlphaColorRec.White;
    end;
  end;

  FShadowView.setBackgroundColor(TUIColor.MakeColor(FShadowColor));
  FMessageLabel.setTextColor(TUIColor.MakeColor(FMessageColor));
end;

{ TiOSShadow }

constructor TiOSDelegate.Create(const ADialog: TfgNativeDialog);
begin
  TfgAssert.IsNotNil(ADialog);

  inherited Create;
  FNativeDialog := ADialog;
end;

function TiOSDelegate.GetObjectiveCClass: PTypeInfo;
begin
  Result := TypeInfo(IiOSShadow);
end;

procedure TiOSDelegate.tap;
begin
  TfgAssert.IsNotNil(FNativeDialog);

  if FNativeDialog.Cancellable then
  begin
    if Assigned(FNativeDialog.OnCancel) then
      FNativeDialog.OnCancel(FNativeDialog.Owner);
    FNativeDialog.Hide;
  end;
end;


end.
