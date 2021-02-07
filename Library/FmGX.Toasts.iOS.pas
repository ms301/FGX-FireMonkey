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

unit FGX.Toasts.iOS;

interface

uses
  System.UITypes, System.Generics.Collections, System.TypInfo, Macapi.ObjectiveC, iOSapi.UIKit, iOSapi.Foundation,
  FGX.Toasts;

type

  TfgiOSToast = class;

  IFGXToastsQueue = interface(NSObject)
    ['{D5FBE77D-447D-47E5-A4C4-D3D81EAEAF47}']
    procedure ShouldHide; cdecl;
    procedure ToastDisappeared; cdecl;
  end;

  TiOSToastsQueue = class(TOCLocal)
  private
    FToasts: TObjectList<TfgiOSToast>;
    FShowingToast: Boolean;
    [Weak] FActiveToast: TfgiOSToast;
  protected
    function GetObjectiveCClass: PTypeInfo; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure EnqueueToast(const AToast: TfgiOSToast);
    procedure DequeueToast(const AToast: TfgiOSToast);
    procedure ShowNextToast;
    { IFGXToastsQueue }
    procedure ShouldHide; cdecl;
    procedure ToastDisappeared; cdecl;
  end;

{ TfgiOSToast }

  TfgiOSToast = class(TfgToast)
  public const
    DefaultMessageFontSize = 13;
    DefaultCornerRadius = 3;
  private
    FBackgroundView: UIView;
    FIconView: UIImageView;
    FMessageView: UILabel;
  protected
    procedure Realign;
    { inherited }
    procedure DoBackgroundColorChanged; override;
    procedure DoMessageChanged; override;
    procedure DoMessageColorChanged; override;
    procedure DoIconChanged; override;
  public
    constructor Create(const AMessage: string; const ADuration: TfgToastDuration);
    destructor Destroy; override;
    property ToastView: UIView read FBackgroundView;
    property MessageView: UILabel read FMessageView;
    property IconView: UIImageView read FIconView;
  end;

{ TfgiOSToastService }

  TfgiOSToastService = class(TInterfacedObject, IFGXToastService)
  public
    { IFGXToastService }
    function CreateToast(const AMessage: string; const ADuration: TfgToastDuration): TfgToast;
    procedure Show(const AToast: TfgToast);
    procedure Cancel(const AToast: TfgToast);
  end;

  TfgToastDurationHelper = record helper for TfgToastDuration
  public
    function ToDuration: Single; // secs
  end;

procedure RegisterService;
procedure UnregisterService;

implementation

uses
  System.SysUtils, System.Types, iOSapi.CoreGraphics, Macapi.ObjCRuntime, Macapi.Helpers, FMX.Forms, FMX.Platform,
  FMX.Helpers.iOS, FGX.Asserts, FGX.Helpers.iOS;

var
  ToastsQueue: TiOSToastsQueue;

procedure RegisterService;
begin
  ToastsQueue := TiOSToastsQueue.Create;
  TPlatformServices.Current.AddPlatformService(IFGXToastService, TfgiOSToastService.Create);
end;

procedure UnregisterService;
begin
  TPlatformServices.Current.RemovePlatformService(IFGXToastService);
  FreeAndNil(ToastsQueue);
end;

{ TfgiOSToastService }

procedure TfgiOSToastService.Cancel(const AToast: TfgToast);
begin
  TfgAssert.IsNotNil(AToast);
  TfgAssert.IsClass(AToast, TfgiOSToast);

  ToastsQueue.DequeueToast(TfgiOSToast(AToast));
end;

function TfgiOSToastService.CreateToast(const AMessage: string; const ADuration: TfgToastDuration): TfgToast;
begin
  Result := TfgiOSToast.Create(AMessage, ADuration);
end;

procedure TfgiOSToastService.Show(const AToast: TfgToast);
begin
  TfgAssert.IsNotNil(AToast);
  TfgAssert.IsClass(AToast, TfgiOSToast);

  ToastsQueue.EnqueueToast(TfgiOSToast(AToast));
end;

{ TfgToastDurationHelper }

function TfgToastDurationHelper.ToDuration: Single;
begin
  case Self of
    TfgToastDuration.Short:
      Result := 3;
    TfgToastDuration.Long:
      Result := 5;
  else
    Result := 3;
  end;
end;

{ TfgiOSToast }

constructor TfgiOSToast.Create(const AMessage: string; const ADuration: TfgToastDuration);
begin
  inherited Create;
  FBackgroundView := TUIView.Create;
  FBackgroundView.addSubview(FIconView);
  FBackgroundView.setBackgroundColor(AlphaColorToUIColor(TfgToast.DefaultBackgroundColor));
  FBackgroundView.setOpaque(True);
  FBackgroundView.setAlpha(0);
  FBackgroundView.layer.setCornerRadius(DefaultCornerRadius);

  FIconView := TUIImageView.Create;
  FBackgroundView.addSubview(FIconView);

  FMessageView := TUILabel.Create;
  FMessageView.setText(StrToNSStr(AMessage));
  FMessageView.setFont(FMessageView.font.fontWithSize(DefaultMessageFontSize));
  FMessageView.setTextColor(AlphaColorToUIColor(TfgToast.DefaultMessageColor));

  FBackgroundView.addSubview(FMessageView);

  // Adding Shadow to application
  SharedApplication.keyWindow.rootViewController.view.AddSubview(FBackgroundView);
  Realign;
  Duration := ADuration;
end;

destructor TfgiOSToast.Destroy;
begin
  TfgAssert.IsNotNil(FBackgroundView);

  FBackgroundView.removeFromSuperview;
  inherited;
end;

procedure TfgiOSToast.DoBackgroundColorChanged;
begin
  TfgAssert.IsNotNil(FBackgroundView);

  inherited;
  FBackgroundView.setBackgroundColor(AlphaColorToUIColor(BackgroundColor));
end;

procedure TfgiOSToast.DoIconChanged;
begin
  TfgAssert.IsNotNil(FIconView);
  TfgAssert.IsNotNil(Icon);

  inherited;
  FIconView.setImage(BitmapToUIImage(Icon));
  Realign;
end;

procedure TfgiOSToast.DoMessageChanged;
begin
  TfgAssert.IsNotNil(FMessageView);

  inherited;
  FMessageView.setText(StrToNSStr(Message));
end;

procedure TfgiOSToast.DoMessageColorChanged;
begin
  TfgAssert.IsNotNil(FMessageView);

  inherited;
  FMessageView.setTextColor(AlphaColorToUIColor(MessageColor));
end;

procedure TfgiOSToast.Realign;
const
  ToastMargins = 30;
  IconMargins = 5;
var
  BackgroundRect: TRectF;
begin
  TfgAssert.IsNotNil(FMessageView);
  TfgAssert.IsNotNil(FBackgroundView);
  TfgAssert.IsNotNil(FIconView);

  FMessageView.sizeToFit;

  { Background View }
  BackgroundRect := TRectF.Create(TPointF.Zero, FMessageView.bounds.Width, FMessageView.bounds.Height);
  if HasIcon then
    BackgroundRect.Width := BackgroundRect.Width + BackgroundRect.Height + IconMargins;
  BackgroundRect.Inflate(TfgToast.DefaultPadding.Left, TfgToast.DefaultPadding.Top,
                         TfgToast.DefaultPadding.Right, TfgToast.DefaultPadding.Bottom);
  BackgroundRect.SetLocation(Screen.Size.Width / 2 - BackgroundRect.Width / 2, Screen.Size.Height - BackgroundRect.Height - ToastMargins);
  FBackgroundView.setFrame(CGRectFromRect(BackgroundRect));

  { Icon View }
  if HasIcon then
  begin
    FIconView.setFrame(CGRectMake(TfgToast.DefaultPadding.Left, TfgToast.DefaultPadding.Top, FMessageView.bounds.Height, FMessageView.bounds.Height));
    FMessageView.setFrame(CGRectMake(FIconView.frame.origin.x + FIconView.frame.size.width + IconMargins, TfgToast.DefaultPadding.Top, FMessageView.bounds.Width, FMessageView.bounds.Height));
  end
  else
  begin
    FIconView.setFrame(CGRectMake(TfgToast.DefaultPadding.Left, TfgToast.DefaultPadding.Top, 0, 0));
    FMessageView.setFrame(CGRectMake(TfgToast.DefaultPadding.Left, TfgToast.DefaultPadding.Top, FMessageView.bounds.Width, FMessageView.bounds.Height));
  end;
end;

{ TiOSToastStack }

procedure TiOSToastsQueue.EnqueueToast(const AToast: TfgiOSToast);
begin
  TfgAssert.IsNotNil(AToast);

  FToasts.Add(AToast);
  ShowNextToast;
end;

constructor TiOSToastsQueue.Create;
begin
  inherited;
  FToasts := TObjectList<TfgiOSToast>.Create;
  FShowingToast := False;
end;

destructor TiOSToastsQueue.Destroy;
begin
  FreeAndNil(FToasts);
  inherited;
end;

procedure TiOSToastsQueue.ShouldHide;
begin
  TfgAssert.IsNotNil(FActiveToast);

  DequeueToast(FActiveToast);
end;

function TiOSToastsQueue.GetObjectiveCClass: PTypeInfo;
begin
  Result := TypeInfo(IFGXToastsQueue);
end;

procedure TiOSToastsQueue.DequeueToast(const AToast: TfgiOSToast);
begin
  TfgAssert.IsNotNil(AToast);

  // if toast is already displayed, we hide it.
  if AToast = FActiveToast then
  begin
    FShowingToast := False;
    FActiveToast := nil;
    FadeOut(AToast.ToastView, DEFAULT_ANIMATION_DURATION, GetObjectID, 'ToastDisappeared');
  end;

  FToasts.Remove(AToast);
end;

procedure TiOSToastsQueue.ShowNextToast;
begin
  if (FToasts.Count > 0) and not FShowingToast then
  begin
    FShowingToast := True;
    FActiveToast := FToasts.First;
    FadeIn(FActiveToast.ToastView);
    NSObject(Super).performSelector(sel_getUid('ShouldHide'), GetObjectID, FActiveToast.Duration.ToDuration + DEFAULT_ANIMATION_DURATION);
  end;
end;

procedure TiOSToastsQueue.ToastDisappeared;
begin
  ShowNextToast;
end;

end.
