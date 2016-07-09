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

unit FGX.Toasts;

interface

uses
  System.Types, System.Classes, System.SysUtils, System.UITypes, FMX.Graphics;

resourcestring
  SToastsIsNotSupported = 'Toast is not supported on current platform';
  SCannotCreateToastWrongCall = 'Cannot create toast. You have to use class methods [Create] of [TfgToast] for it with parameters.';

type

{ TfgToast }

  TfgToast = class;

  EfgToastError = class(Exception);

  TfgToastDuration = (Short, Long);

  /// <summary>Service interface for working with Toasts</summary>
  IFGXToastService = interface
    ['{0F0C46CD-6BAE-4D15-B14C-60FB622AE61E}']
    { Creation }
    /// <summary>Creates instance of Toast wit specified parameters</summary>
    function CreateToast(const AMessage: string; const ADuration: TfgToastDuration): TfgToast;
    { Manipulation }
    /// <summary>Shows toast</summary>
    procedure Show(const AToast: TfgToast);
    /// <summary>Hides toast</summary>
    procedure Cancel(const AToast: TfgToast);
  end;

  TfgToast = class abstract
  private class var
    FToastService: IFGXToastService;
  protected class var
    FDefaultBackgroundColor: TAlphaColor;
    FDefaultMessageColor: TAlphaColor;
    FDefaultPadding: TRectF;
  private
    FMessage: string;
    FIcon: TBitmap;
    FDuration: TfgToastDuration;
    FBackgroundColor: TAlphaColor;
    FMessageColor: TAlphaColor;
    procedure SetDuration(const Value: TfgToastDuration);
    procedure SetMessage(const Value: string);
    procedure SetMessageColor(const Value: TAlphaColor);
    procedure SetBackgroundColor(const Value: TAlphaColor);
    procedure SetIcon(const Value: TBitmap);
    { Event handlers }
    procedure IconChangedHandler(Sender: TObject);
  private
    class constructor Create;
    class destructor Destroy;
  protected
    procedure DoBackgroundColorChanged; virtual;
    procedure DoMessageChanged; virtual;
    procedure DoMessageColorChanged; virtual;
    procedure DoDurationChanged; virtual;
    procedure DoIconChanged; virtual;
  public
    constructor Create; overload;
    class function Create(const AMessage: string; const ADuration: TfgToastDuration = TfgToastDuration.Short): TfgToast; overload;
    destructor Destroy; override;
    { Manipulations }
    class procedure Show(const AMessage: string); overload;
    class procedure Show(const AMessage: string; const AIcon: TBitmap); overload;
    class procedure Show(const AMessage: string; const ADuration: TfgToastDuration); overload;
    class procedure Show(const AMessage: string; const ADuration: TfgToastDuration; const AIcon: TBitmap); overload;
    class function Supported: Boolean;
    { Default Settings }
    /// <summary>Default background color. It will be used, if user doesn't specified <c>BackgroundColor</c></summary>
    class property DefaultBackgroundColor: TAlphaColor read FDefaultBackgroundColor write FDefaultBackgroundColor;
    /// <summary>Default message color. It will be used, if user doesn't specified <c>MessageColor</c></summary>
    class property DefaultMessageColor: TAlphaColor read FDefaultMessageColor write FDefaultMessageColor;
    /// <summary>Default internal padding between border and text</summary>
    class property DefaultPadding: TRectF read FDefaultPadding write FDefaultPadding;
  public
    procedure Show; overload;
    procedure Hide;
    function HasIcon: Boolean;
  public
    /// <summary>Color of toast background</summary>
    property BackgroundColor: TAlphaColor read FBackgroundColor write SetBackgroundColor;
    /// <summary>Image on toast</summary>
    /// <remarks>If you specify icon, Toast will use custom view. It means, that view of toast can be differed from
    /// original toast with only text</remarks>
    property Icon: TBitmap read FIcon write SetIcon;
    /// <summary>Duration of showing toast</summary>
    property Duration: TfgToastDuration read FDuration write SetDuration;
    /// <summary>Text message</summary>
    property Message: string read FMessage write SetMessage;
    /// <summary>Font color of <c>Message</c></summary>
    property MessageColor: TAlphaColor read FMessageColor write SetMessageColor;
  end;

implementation

uses
  FMX.Platform, FGX.Asserts
{$IFDEF ANDROID}
  , FGX.Toasts.Android
{$ENDIF}
{$IFDEF IOS}
  , FGX.Toasts.iOS
{$ENDIF}
;

{ TfgCustomToast }

procedure TfgToast.Hide;
begin
  TfgAssert.IsNotNil(FToastService);

  if FToastService <> nil then
    FToastService.Cancel(Self);
end;

class function TfgToast.Create(const AMessage: string; const ADuration: TfgToastDuration): TfgToast;
begin
  if not TPlatformServices.Current.SupportsPlatformService(IFGXToastService, FToastService) then
    raise Exception.Create(SToastsIsNotSupported);
  Result := FToastService.CreateToast(AMessage, ADuration);
end;

constructor TfgToast.Create;
begin
  if ClassType = TfgToast then
    raise EfgToastError.Create(SCannotCreateToastWrongCall);

  inherited;
  FIcon := TBitmap.Create;
  FIcon.OnChange := IconChangedHandler;
end;

class destructor TfgToast.Destroy;
begin
  FToastService := nil;
  inherited;
end;

class constructor TfgToast.Create;
begin
  FDefaultBackgroundColor := TAlphaColor($CC2A2A2A);
{$IFDEF ANDROID}
  FDefaultBackgroundColor := TAlphaColor($8A000000);
{$ENDIF}
  FDefaultMessageColor := TAlphaColorRec.White;
  FDefaultPadding := TRectF.Create(10, 10, 10, 10);
{$IFDEF ANDROID}
  FDefaultPadding := TRectF.Create(20, 20, 20, 20);
{$ENDIF}
end;

destructor TfgToast.Destroy;
begin
  FreeAndNil(FIcon);
end;

procedure TfgToast.DoBackgroundColorChanged;
begin
  // It is intended for successors
end;

procedure TfgToast.DoDurationChanged;
begin
  // It is intended for successors
end;

procedure TfgToast.DoIconChanged;
begin
  // It is intended for successors
end;

procedure TfgToast.DoMessageChanged;
begin
  // It is intended for successors
end;

procedure TfgToast.DoMessageColorChanged;
begin
  // It is intended for successors
end;

function TfgToast.HasIcon: Boolean;
begin
  TfgAssert.IsNotNil(Icon);

  Result := (Icon.Width > 0) and (Icon.Height > 0);
end;

procedure TfgToast.IconChangedHandler(Sender: TObject);
begin
  DoIconChanged;
end;

procedure TfgToast.SetBackgroundColor(const Value: TAlphaColor);
begin
  if FBackgroundColor <> Value then
  begin
    FBackgroundColor := Value;
    DoBackgroundColorChanged;
  end;
end;

procedure TfgToast.SetDuration(const Value: TfgToastDuration);
begin
  if FDuration <> Value then
  begin
    FDuration := Value;
    DoDurationChanged;
  end;
end;

procedure TfgToast.SetIcon(const Value: TBitmap);
begin
  TfgAssert.IsNotNil(Value);

  FIcon.Assign(Value);
end;

procedure TfgToast.SetMessage(const Value: string);
begin
  if FMessage <> Value then
  begin
    FMessage := Value;
    DoMessageChanged;
  end;
end;

procedure TfgToast.SetMessageColor(const Value: TAlphaColor);
begin
  if FMessageColor <> Value then
  begin
    FMessageColor := Value;
    DoMessageColorChanged;
  end;
end;

class procedure TfgToast.Show(const AMessage: string);
var
  Toast: TfgToast;
begin
  Toast := TfgToast.Create(AMessage, TfgToastDuration.Short);
  try
    Toast.Show;
  finally
    Toast.Free;
  end;
end;

class procedure TfgToast.Show(const AMessage: string; const AIcon: TBitmap);
var
  Toast: TfgToast;
begin
  Toast := TfgToast.Create(AMessage, TfgToastDuration.Short);
  try
    Toast.Icon := AIcon;
    Toast.Show;
  finally
    Toast.Free;
  end;
end;

class procedure TfgToast.Show(const AMessage: string; const ADuration: TfgToastDuration; const AIcon: TBitmap);
var
  Toast: TfgToast;
begin
  Toast := TfgToast.Create(AMessage, ADuration);
  try
    Toast.Icon := AIcon;
    Toast.Show;
  finally
    Toast.Free;
  end;
end;

class procedure TfgToast.Show(const AMessage: string; const ADuration: TfgToastDuration);
var
  Toast: TfgToast;
begin
  Toast := TfgToast.Create(AMessage, ADuration);
  try
    Toast.Show;
  finally
    Toast.Free;
  end;
end;

procedure TfgToast.Show;
begin
  TfgAssert.IsNotNil(FToastService);

  if FToastService <> nil then
    FToastService.Show(Self);
end;

class function TfgToast.Supported: Boolean;
begin
  Result := TPlatformServices.Current.SupportsPlatformService(IFGXToastService);
end;

initialization
{$IF Defined(ANDROID) OR Defined(IOS)}
  RegisterService;
{$ENDIF}
finalization
{$IF Defined(ANDROID) OR Defined(IOS)}
  UnregisterService;
{$ENDIF}
end.
