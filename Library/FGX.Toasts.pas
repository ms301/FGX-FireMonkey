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
  System.Classes, System.UITypes, FMX.Graphics;

resourcestring
  SToastsIsNotSupported = 'Toast is not supported on current platform';

type

{ TfgToast }

  TfgToast = class;

  TfgToastDuration = (Short, Long);

  IFGXToastService = interface
  ['{0F0C46CD-6BAE-4D15-B14C-60FB622AE61E}']
    { Creation }
    function CreateToast(const AMessage: string; const ADuration: TfgToastDuration): TfgToast;
    { Manipulation }
    procedure Show(const AToast: TfgToast);
    procedure Cancel(const AToast: TfgToast);
  end;

  TfgToast = class abstract
  private class var
    FToastService: IFGXToastService;
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
    class destructor Destroy;
  protected
    procedure DoBackgroundColorChanged; virtual;
    procedure DoMessageChanged; virtual;
    procedure DoMessageColorChanged; virtual;
    procedure DoDurationChanged; virtual;
    procedure DoIconChanged; virtual;
    constructor Create; overload;
  public
    class function Create(const AMessage: string; const ADuration: TfgToastDuration): TfgToast; overload;
    destructor Destroy; override;
    { Manipulations }
    class procedure Show(const AMessage: string); overload;
    class procedure Show(const AMessage: string; const AIcon: TBitmap); overload;
    class procedure Show(const AMessage: string; const ADuration: TfgToastDuration); overload;
    class procedure Show(const AMessage: string; const ADuration: TfgToastDuration; const AIcon: TBitmap); overload;
    class function Supported: Boolean;
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
  FMX.Platform, System.SysUtils, FGX.Asserts {$IFDEF ANDROID}, FGX.Toasts.Android{$ENDIF};

{ TfgCustomToast }

procedure TfgToast.Hide;
begin
  AssertIsNotNil(FToastService);

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
  inherited;
  FIcon := TBitmap.Create;
  FIcon.OnChange := IconChangedHandler;
end;

class destructor TfgToast.Destroy;
begin
  FToastService := nil;
  inherited;
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
  AssertIsNotNil(FIcon);

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
  AssertIsNotNil(FToastService);

  if FToastService <> nil then
    FToastService.Show(Self);
end;

class function TfgToast.Supported: Boolean;
begin
  Result := TPlatformServices.Current.SupportsPlatformService(IFGXToastService);
end;

initialization
{$IFDEF ANDROID}
  RegisterService;
{$ENDIF}
finalization
{$IFDEF ANDROID}
  UnregisterService;
{$ENDIF}
end.
