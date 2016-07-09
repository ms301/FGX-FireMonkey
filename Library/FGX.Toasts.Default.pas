unit FGX.Toasts.Default;

interface

uses
  FGX.Toasts, FMX.Objects, FMX.StdCtrls, System.Types, FMX.Effects,
  System.Messaging;

type

{ TfgDefaultToast }

  TfgDefaultToast = class(TfgToast)
  private
    FBackground: TRectangle;
    FText: TLabel;
    { Handlers }
    procedure FormSizeChangedHandler(const ASender: TObject; const AMessage: TMessage);
  protected
    procedure DoMessageChanged; override;
    function DefineMessageSize: TSizeF;
    procedure UpdateToastPosition;
  public
    constructor Create(const AMessage: string; const ADuration: TfgToastDuration);
    destructor Destroy; override;
  public
    property Background: TRectangle read FBackground;
  end;

{ TfgDefaultToastService }

  TfgDefaultToastService = class(TInterfacedObject, IFGXToastService)
  public
    { IFGXToastService }
    function CreateToast(const AMessage: string; const ADuration: TfgToastDuration): TfgToast;
    procedure Show(const AToast: TfgToast);
    procedure Cancel(const AToast: TfgToast);
  end;

implementation

uses
  System.UITypes, FMX.Platform, FMX.Types, FMX.Forms, FMX.Ani, FMX.Graphics, FMX.TextLayout, FGX.Asserts,
  System.Classes, System.SysUtils;

{ TfgDefaultToast }

constructor TfgDefaultToast.Create(const AMessage: string; const ADuration: TfgToastDuration);
const
  BackgroundColor = TAlphaColor($C0000000);
begin
  TMessageManager.DefaultManager.SubscribeToMessage(TSizeChangedMessage, FormSizeChangedHandler);
  FBackground := TRectangle.Create(nil);
  FBackground.Fill.Color := BackgroundColor;
  FBackground.Stroke.Kind := TBrushKind.None;
  FBackground.Stored := False;
  FBackground.Lock;
  FBackground.Padding.Rect := DefaultPadding;

  FText := TLabel.Create(nil);
  FText.Align := TAlignLayout.Client;
  FText.Parent := FBackground;
  FText.TextAlign := TTextAlign.Center;
  FText.TextSettings.FontColor := TAlphaColorRec.White;
  FText.StyledSettings := [];

  Message := AMessage;
  Duration := ADuration;
end;

function TfgDefaultToast.DefineMessageSize: TSizeF;
var
  TextLayout: TTextLayout;
  TextRect: TRectF;
begin
  TextLayout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    TextLayout.BeginUpdate;
    try
      TextLayout.Text := Message;
      TextLayout.MaxSize := TPointF.Create(1000, 1000);
      TextLayout.Font := FText.ResultingTextSettings.Font;
    finally
      TextLayout.EndUpdate;
    end;
    TextRect := TextLayout.TextRect;
    Result := TSizeF.Create(TextRect.Width, TextRect.Height);
  finally
    TextLayout.Free;
  end;
end;

destructor TfgDefaultToast.Destroy;
begin
//  FText.Parent := nil;
//  FText.Free;
//  FBackground.Parent := nil;
//  FBackground.Free;
//  TMessageManager.DefaultManager.Unsubscribe(TSizeChangedMessage, FormSizeChangedHandler);
  inherited;
end;

procedure TfgDefaultToast.DoMessageChanged;
var
  MessageSize: TSizeF;
begin
  inherited;
  FText.Text := Message;
  MessageSize := DefineMessageSize;
  FBackground.Width := MessageSize.Width + DefaultPadding.Right + DefaultPadding.Left;
  FBackground.Height := MessageSize.Height + DefaultPadding.Top + DefaultPadding.Bottom;
end;

procedure TfgDefaultToast.FormSizeChangedHandler(const ASender: TObject; const AMessage: TMessage);
begin
  TfgAssert.IsNotNil(AMessage);
  TfgAssert.IsClass(AMessage, TSizeChangedMessage);
  TfgAssert.IsClass(ASender, TCommonCustomForm);

  if (AMessage is TSizeChangedMessage) and (FBackground.Parent = ASender) then
    UpdateToastPosition;
end;

procedure TfgDefaultToast.UpdateToastPosition;
var
  Position: TPointF;
begin
  Position := TPointF.Create(Screen.ActiveForm.ClientWidth / 2, Screen.ActiveForm.ClientHeight);
  Background.Position.Point := Position - TPointF.Create(Background.Width / 2, Background.Height + 10);
end;

{ TfgDefaultToastService }

procedure TfgDefaultToastService.Cancel(const AToast: TfgToast);
begin

end;

function TfgDefaultToastService.CreateToast(const AMessage: string; const ADuration: TfgToastDuration): TfgToast;
begin
  Result := TfgDefaultToast.Create(AMessage, ADuration);
end;

procedure TfgDefaultToastService.Show(const AToast: TfgToast);

  procedure DefineToastPosition(const AToast: TfgDefaultToast);
  var
    Position: TPointF;
  begin
    Position := TPointF.Create(Screen.ActiveForm.ClientWidth / 2, Screen.ActiveForm.ClientHeight );
    AToast.Background.Position.Point := Position - TPointF.Create(AToast.Background.Width / 2, AToast.Background.Height + 10);
  end;

var
  Toast: TfgDefaultToast;
  HideThread: TThread;
begin
  TfgAssert.IsNotNil(AToast);
  TfgAssert.IsClass(AToast, TfgDefaultToast);

  if Screen.ActiveForm <> nil then
  begin
    Toast := TfgDefaultToast(AToast);
    Toast.Background.Opacity := 0;
    Toast.Background.Parent := Screen.ActiveForm;
    DefineToastPosition(Toast);
    TAnimator.AnimateFloat(Toast.Background, 'opacity', 1);
    HideThread := TThread.CreateAnonymousThread(procedure
      begin
        Sleep(2000);
//        Toast.Background.Parent := nil;
        TThread.Synchronize(nil, procedure
        begin
          TAnimator.AnimateFloat(Toast.Background, 'opacity', 0);
        end);
      end);
    HideThread.Start;
  end;
end;

initialization
  TPlatformServices.Current.AddPlatformService(IFGXToastService, TfgDefaultToastService.Create);
finalization
  TPlatformServices.Current.RemovePlatformService(IFGXToastService);
end.
