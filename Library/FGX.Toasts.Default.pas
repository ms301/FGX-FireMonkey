unit FGX.Toasts.Default;

interface

uses
  FGX.Toasts, FMX.Objects, FMX.StdCtrls, System.Types, FMX.Effects;

type

{ TfgDefaultToast }

  TfgDefaultToast = class(TfgToast)
  private
    FBackground: TRectangle;
    FText: TLabel;
  protected
    procedure DoMessageChanged; override;
    function DefineMessageSize: TSizeF;
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
  System.Classes;

{ TfgDefaultToast }

constructor TfgDefaultToast.Create(const AMessage: string; const ADuration: TfgToastDuration);
const
  BackgroundColor = TAlphaColor($C0000000);
begin
  FBackground := TRectangle.Create(nil);
  FBackground.Fill.Color := BackgroundColor;
  FBackground.Stroke.Kind := TBrushKind.None;
  FBackground.Stored := False;
  FBackground.Lock;
  FBackground.Padding.Rect := TRectF.Create(5, 5, 5, 5);

  FText := TLabel.Create(nil);
  FText.Align := TAlignLayout.Client;
  FText.Parent := FBackground;
  FText.TextAlign := TTextAlign.Center;
  FText.TextSettings.FontColor := TAlphaColorRec.White;
  FText.TextSettings.Font.Style := [TFontStyle.fsBold];
  FText.StyledSettings := [];
  FText.WordWrap := False;

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
//      TextLayout.WordWrap := FText.WordWrap;
      TextLayout.Font := FText.ResultingTextSettings.Font;
//      TextLayout.HorizontalAlign := FText.TextAlign;
//      TextLayout.VerticalAlign := FText.VertTextAlign;
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
  inherited;
end;

procedure TfgDefaultToast.DoMessageChanged;
var
  MessageSize: TSizeF;
begin
  inherited;
  FText.Text := Message;
  MessageSize := DefineMessageSize;
  FBackground.Width := MessageSize.Width + 10;
  FBackground.Height := MessageSize.Height + 10;
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
//  HideThread: TThread;
begin
  AssertIsNotNil(AToast);
  AssertIsClass(AToast, TfgDefaultToast);

  if Screen.ActiveForm <> nil then
  begin
    Toast := TfgDefaultToast(AToast);
    Toast.Background.Opacity := 0;
    Toast.Background.Parent := Screen.ActiveForm;
    DefineToastPosition(Toast);
    TAnimator.AnimateFloat(Toast.Background, 'opacity', 1);
//    HideThread := TThread.CreateAnonymousThread(procedure
//      begin
//        Toast.Background.Parent := nil;
//      end);
//    HideThread.Sleep(2000);
//    HideThread.Start;
  end;
end;

initialization
  TPlatformServices.Current.AddPlatformService(IFGXToastService, TfgDefaultToastService.Create);
finalization
  TPlatformServices.Current.RemovePlatformService(IFGXToastService);
end.
