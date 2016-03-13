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
  System.UITypes, System.UIConsts, System.Messaging, iOSapi.UIKit, FGX.ProgressDialog, FGX.ProgressDialog.Types,
  FGX.Asserts;

const
  SHADOW_ALPHA       = 180;
  MESSAGE_FONT_SIZE  = 15;
  MESSAGE_MARGIN     = 5;
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

  TiOSNativeActivityDialog = class(TfgNativeActivityDialog)
  private
    FActivityIndicator: UIActivityIndicatorView;
    FShadowColor: TAlphaColor;
    FShadowView: UIView;
    FMessageLabel: UILabel;
    procedure DoOrientationChanged(const Sender: TObject; const M: TMessage);
  protected
    procedure MessageChanged; override;
  public
    constructor Create(const AOwner: TObject); override;
    destructor Destroy; override;
    procedure Show; override;
    procedure Hide; override;
    procedure Realign;
  end;

  TiOSNativeProgressDialog = class (TfgNativeProgressDialog)
  private
    FProgressView: UIProgressView;
    FShadowColor: TAlphaColor;
    FShadowView: UIView;
    FMessageLabel: UILabel;
    procedure DoOrientationChanged(const Sender: TObject; const M: TMessage);
  protected
    procedure MessageChanged; override;
    procedure ProgressChanged; override;
  public
    constructor Create(const AOwner: TObject); override;
    destructor Destroy; override;
    procedure ResetProgress; override;
    procedure Show; override;
    procedure Hide; override;
    procedure Realign;
  end;

procedure RegisterService;

implementation

uses
  System.Types, System.Math, iOSapi.CoreGraphics, iOSapi.Foundation, Macapi.Helpers,
  FMX.Platform, FMX.Platform.iOS, FMX.Forms, FMX.Helpers.iOS, FGX.Helpers.iOS;

procedure RegisterService;
begin
  TPlatformServices.Current.AddPlatformService(IFGXProgressDialogService, TIOSProgressDialogService.Create);
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
  AssertIsNotNil(MainScreen);
  AssertIsNotNil(SharedApplication.keyWindow);
  AssertIsNotNil(SharedApplication.keyWindow.rootViewController);
  AssertIsNotNil(SharedApplication.keyWindow.rootViewController.view);

  inherited Create(AOwner);
  FShadowColor := MakeColor(0, 0, 0, SHADOW_ALPHA);

  // Shadow
  FShadowView := TUIView.Create;
  FShadowView.setUserInteractionEnabled(True);
  FShadowView.setHidden(True);
  FShadowView.setAutoresizingMask(UIViewAutoresizingFlexibleWidth or UIViewAutoresizingFlexibleHeight);
  FShadowView.setBackgroundColor(TUIColor.MakeColor(FShadowColor));

  // Creating Ani indicator
  FActivityIndicator := TUIActivityIndicatorView.Alloc;
  FActivityIndicator.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleWhite);
  FActivityIndicator.startAnimating;
  FActivityIndicator.setAutoresizingMask(UIViewAutoresizingFlexibleLeftMargin or UIViewAutoresizingFlexibleRightMargin);

  // Creating message label
  FMessageLabel := TUILabel.Create;
  FMessageLabel.setTextColor(TUIColor.whiteColor);
  FMessageLabel.setBackgroundColor(TUIColor.clearColor);
  FMessageLabel.setFont(FMessageLabel.font.fontWithSize(MESSAGE_FONT_SIZE));
  FMessageLabel.setTextAlignment(UITextAlignmentCenter);

  // Adding view
  FShadowView.addSubview(FActivityIndicator);
  FShadowView.addSubview(FMessageLabel);

  // Adding Shadow to application
  SharedApplication.keyWindow.rootViewController.view.AddSubview(FShadowView);
  Realign;

  { Message subscription }
  TMessageManager.DefaultManager.SubscribeToMessage(TOrientationChangedMessage, DoOrientationChanged);
end;

destructor TiOSNativeActivityDialog.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TOrientationChangedMessage, DoOrientationChanged);
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
  AssertIsNotNil(FShadowView);

  FadeOut(FShadowView, DEFAULT_ANIMATION_DURATION);
  DoHide;
end;

procedure TiOSNativeActivityDialog.MessageChanged;
begin
  AssertIsNotNil(FMessageLabel);

  FMessageLabel.setText(StrToNSStr(Message));

  // We should call it once for starting animation
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
  FMessageLabel.setCenter(CGPointMake(CenterPoint.X, CenterPoint.Y + MESSAGE_MARGIN));
end;

procedure TiOSNativeActivityDialog.Show;
begin
  AssertIsNotNil(FShadowView);
  AssertIsNotNil(FMessageLabel);

  FadeIn(FShadowView, DEFAULT_ANIMATION_DURATION);
  DoShow;

  // We should call it once for starting animation
  Application.ProcessMessages;
end;

{ TiOSNativeProgressDialog }

constructor TiOSNativeProgressDialog.Create(const AOwner: TObject);
begin
  inherited Create(AOwner);
  FShadowColor := MakeColor(0, 0, 0, SHADOW_ALPHA);

  // Shadow
  FShadowView := TUIView.Create;
  FShadowView.setUserInteractionEnabled(True);
  FShadowView.setHidden(True);
  FShadowView.setAutoresizingMask(UIViewAutoresizingFlexibleWidth or UIViewAutoresizingFlexibleHeight);
  FShadowView.setBackgroundColor(TUIColor.MakeColor(FShadowColor));

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

  { Message subscription }
  TMessageManager.DefaultManager.SubscribeToMessage(TOrientationChangedMessage, DoOrientationChanged);
end;

destructor TiOSNativeProgressDialog.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TOrientationChangedMessage, DoOrientationChanged);
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
  AssertIsNotNil(FShadowView);

  FadeOut(FShadowView, DEFAULT_ANIMATION_DURATION);
  DoHide;
end;

procedure TiOSNativeProgressDialog.MessageChanged;
begin
  AssertIsNotNil(FMessageLabel);

  FMessageLabel.setText(StrToNSStr(Message));

  // We should call it once for starting animation
  Application.ProcessMessages;
end;

procedure TiOSNativeProgressDialog.ProgressChanged;
begin
  AssertIsNotNil(FProgressView);
  AssertInRange(Progress, 0, 100);

  FProgressView.setProgress(Progress / 100, True);

  // We should call it once for starting animation
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
  AssertIsNotNil(FProgressView);

  inherited ResetProgress;
  FProgressView.setProgress(0);
end;

procedure TiOSNativeProgressDialog.Show;
begin
  AssertIsNotNil(FShadowView);

  FadeIn(FShadowView, DEFAULT_ANIMATION_DURATION);
  DoShow;

  // We should call it once for starting animation
  Application.ProcessMessages;
end;

end.
