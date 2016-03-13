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

unit FGX.Toasts.Android;

interface

uses
  FGX.Toasts, AndroidApi.JNI.Toasts, AndroidApi.JNI.GraphicsContentViewText, AndroidApi.JNI.Widget,
  System.UITypes;

type

{ TfgAndroidToast }

  TfgAndroidToast = class(TfgToast)
  private
    FToast: JToast;
    FBackgroundView: JView;
    FIconView: JImageView;
    FMessageView: JTextView;
  protected
    { inherited }
    procedure DoBackgroundColorChanged; override;
    procedure DoDurationChanged; override;
    procedure DoMessageChanged; override;
    procedure DoMessageColorChanged; override;
    procedure DoIconChanged; override;
    { Creating custom view and preparing data for Toast }
    function CreateBitmapIcon: JBitmap;
    function CreateBackgroundImage: JBitmap;
    procedure CreateCustomView;
    procedure RemoveCustomView;
  public
    constructor Create(const AMessage: string; const ADuration: TfgToastDuration);
    destructor Destroy; override;
    property Toast: JToast read FToast;
  end;

{ TfgAndroidToastService }

  TfgAndroidToastService = class(TInterfacedObject, IFGXToastService)
  public
    { IFGXToastService }
    function CreateToast(const AMessage: string; const ADuration: TfgToastDuration): TfgToast;
    procedure Show(const AToast: TfgToast);
    procedure Cancel(const AToast: TfgToast);
  end;

  TfgToastDurationHelper = record helper for TfgToastDuration
  public
    function ToJDuration: Integer;
  end;

procedure RegisterService;
procedure UnregisterService;

implementation

uses
  System.SysUtils, System.Types, System.IOUtils, Androidapi.Helpers, Androidapi.JNIBridge,
  Androidapi.JNI.JavaTypes, FMX.Platform, FMX.Helpers.Android, FMX.Graphics, FMX.Surfaces, FMX.Types, FGX.Helpers.Android, FGX.Graphics,
  FGX.Asserts;

procedure RegisterService;
begin
  TPlatformServices.Current.AddPlatformService(IFGXToastService, TfgAndroidToastService.Create);
end;

procedure UnregisterService;
begin
  TPlatformServices.Current.RemovePlatformService(IFGXToastService);
end;

{ TfgAndroidToast }

constructor TfgAndroidToast.Create(const AMessage: string; const ADuration: TfgToastDuration);
begin
  Assert(AMessage <> '');

  inherited Create;
  CallInUIThreadAndWaitFinishing(procedure
    begin
      FToast := TJToast.JavaClass.makeText(TAndroidHelper.Context, StrToJCharSequence(AMessage), ADuration.ToJDuration);
    end);
  Message := AMessage;
  Duration := ADuration;
end;

function TfgAndroidToast.CreateBackgroundImage: JBitmap;
var
  Bitmap: TBitmap;
begin
  Bitmap := Create9PatchShadow(TSizeF.Create(100, 20), BackgroundColor);
  try
    Result := BitmapToJBitmap(Bitmap)
  finally
    Bitmap.Free;
  end;
end;

procedure TfgAndroidToast.CreateCustomView;
const
  CENTER_VERTICAL = 16;
  IMAGE_MARGIN_RIGHT = 10;
var
  Layout: JLinearLayout;
  DestBitmap: JBitmap;
  Params : JViewGroup_LayoutParams;
begin
  RemoveCustomView;

  { Background }
  Layout := TJLinearLayout.JavaClass.init(TAndroidHelper.Context);
  Layout.setOrientation(TJLinearLayout.JavaClass.HORIZONTAL);
  Layout.setPadding(Round(TfgToast.DefaultPadding.Left), Round(TfgToast.DefaultPadding.Top),
                    Round(TfgToast.DefaultPadding.Right), Round(TfgToast.DefaultPadding.Bottom));
  Layout.setGravity(CENTER_VERTICAL);
  Layout.setBackgroundColor(AlphaColorToJColor(TfgToast.DefaultBackgroundColor));
  Params := TJViewGroup_LayoutParams.JavaClass.init(TJViewGroup_LayoutParams.JavaClass.WRAP_CONTENT, TJViewGroup_LayoutParams.JavaClass.WRAP_CONTENT);
  Layout.setLayoutParams(Params);
  FBackgroundView := Layout;

  { Image }
  DestBitmap := CreateBitmapIcon;
  if DestBitmap <> nil then
  begin
    FIconView := TJImageView.JavaClass.init(TAndroidHelper.Context);
    FIconView.setImageBitmap(DestBitmap);
    FIconView.setPadding(0, 0, IMAGE_MARGIN_RIGHT, 0);
    Params := TJViewGroup_LayoutParams.JavaClass.init(TJViewGroup_LayoutParams.JavaClass.WRAP_CONTENT, TJViewGroup_LayoutParams.JavaClass.WRAP_CONTENT);
    FIconView.setLayoutParams(Params);
    Layout.addView(FIconView, Params);
  end;

  { Message }
  FMessageView := TJTextView.JavaClass.init(TAndroidHelper.Context);
  FMessageView.setText(StrToJCharSequence(Message));
  FMessageView.setTextColor(AlphaColorToJColor(MessageColor));
  Params := TJViewGroup_LayoutParams.JavaClass.init(TJViewGroup_LayoutParams.JavaClass.WRAP_CONTENT, TJViewGroup_LayoutParams.JavaClass.WRAP_CONTENT);
  FMessageView.setLayoutParams(Params);
  Layout.addView(FMessageView);

  FToast.setView(Layout);
end;

function TfgAndroidToast.CreateBitmapIcon: JBitmap;
begin
  if HasIcon then
    Result := BitmapToJBitmap(Icon)
  else
    Result := nil;
end;

destructor TfgAndroidToast.Destroy;
begin
  FToast := nil;
  inherited;
end;

procedure TfgAndroidToast.DoBackgroundColorChanged;
begin
  inherited;
  if FBackgroundView <> nil then
    FBackgroundView.setBackgroundColor(AlphaColorToJColor(BackgroundColor))
  else
    Toast.getView.setBackgroundColor(AlphaColorToJColor(BackgroundColor));
end;

procedure TfgAndroidToast.DoDurationChanged;
begin
  AssertIsNotNil(FToast);

  inherited;
  CallInUIThreadAndWaitFinishing(procedure
    begin
      FToast.setDuration(Duration.ToJDuration);
    end);
end;

procedure TfgAndroidToast.DoIconChanged;
begin
  AssertIsNotNil(Icon);
  AssertIsNotNil(Toast);

  inherited;
  if HasIcon then
  begin
    if FIconView = nil then
      CreateCustomView
    else
      FIconView.setImageBitmap(CreateBitmapIcon);
  end
  else
    RemoveCustomView;
end;

procedure TfgAndroidToast.DoMessageChanged;
begin
  AssertIsNotNil(FToast);

  inherited;
  CallInUIThreadAndWaitFinishing(procedure
    begin
      FToast.setText(StrToJCharSequence(Message));
      if FMessageView <> nil then
        FMessageView.setText(StrToJCharSequence(Message));
    end);
end;

procedure TfgAndroidToast.DoMessageColorChanged;
const
  TJR_idmessage = 16908299;
var
  LMessageView: JView;
  TextView: JTextView;
begin
  inherited;
  if FMessageView <> nil then
    FMessageView.setTextColor(AlphaColorToJColor(MessageColor))
  else
  begin
    LMessageView := Toast.getView.findViewById(TJR_idmessage);
    if LMessageView <> nil then
    begin
      TextView := TJTextView.Wrap((LMessageView as ILocalObject).GetObjectID);
      TextView.setTextColor(AlphaColorToJColor(MessageColor));
    end;
  end;
end;

procedure TfgAndroidToast.RemoveCustomView;
begin
  Toast.setView(nil);
  FBackgroundView := nil;
  FIconView := nil;
  FMessageView := nil;
end;

{ TfgAndroidToastService }

procedure TfgAndroidToastService.Cancel(const AToast: TfgToast);
begin
  AssertIsNotNil(AToast);
  AssertIsClass(AToast, TfgAndroidToast);

  CallInUIThreadAndWaitFinishing(procedure
    begin
      TfgAndroidToast(AToast).Toast.cancel;
    end);
end;

function TfgAndroidToastService.CreateToast(const AMessage: string; const ADuration: TfgToastDuration): TfgToast;
begin
  Result := TfgAndroidToast.Create(AMessage, ADuration);
end;

procedure TfgAndroidToastService.Show(const AToast: TfgToast);
begin
  AssertIsNotNil(AToast);
  AssertIsClass(AToast, TfgAndroidToast);

  CallInUIThreadAndWaitFinishing(procedure
    begin
      TfgAndroidToast(AToast).Toast.show;
    end);
end;

{ TfgToastDurationHelper }

function TfgToastDurationHelper.ToJDuration: Integer;
begin
  case Self of
    TfgToastDuration.Short: Result := TJToast.JavaClass.LENGTH_SHORT;
    TfgToastDuration.Long: Result := TJToast.JavaClass.LENGTH_LONG;
  else
    raise Exception.Create('Unknown value of [FGX.Toasts.TfgToastDuration])');
  end;
end;

end.
