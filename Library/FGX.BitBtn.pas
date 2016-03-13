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

unit FGX.BitBtn;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes, System.UITypes, FMX.Types, FMX.Controls, FMX.Objects, FMX.StdCtrls, FMX.Graphics;

type

{ TfgCustomBitBtn }

  /// <summary>
  ///   Тип кнопки с картинкой:
  ///   <para>
  ///     <c>StylizedGlyph</c> - Картинка для кнопки берется из StyleBook по
  ///     имени стиля
  ///   </para>
  ///   <para>
  ///     <c>CustomGlyph</c> - Картинка для кнопки берется из TfgBitBtn.Glyph
  ///   </para>
  ///   <para>
  ///     <c>Остальные</c> - Картинка для кнопки берется текущего стиля по заранее
  ///     заданному имени стиля
  ///   </para>
  /// </summary>
  TfgBitBtnKind = (Custom, OK, Cancel, Help, Yes, No, Close, Retry, Ignore);

  TfgCustomBitBtn = class (TSpeedButton)
  public
    const DEFAULT_KIND = TfgBitBtnKind.Custom;
  private
    FKind: TfgBitBtnKind;
    FStyleImage: TImage;
    FMousePressed: Boolean;
    procedure SetKind(const Value: TfgBitBtnKind);
    function GetIsMousePressed: Boolean;
    function GetStyleText: TControl;
  protected
    procedure UpdateGlyph; virtual;
    procedure DoImageLinkChanged(Sender: TObject);
    { Style }
    procedure ApplyStyle; override;
    procedure FreeStyle; override;
    function GetDefaultStyleLookupName: string; override;
    property StyleImage: TImage read FStyleImage;
    property StyleText: TControl read GetStyleText;
    { Mouse Events }
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
  public
    property IsMousePressed: Boolean read GetIsMousePressed;
    property Kind: TfgBitBtnKind read FKind write SetKind default DEFAULT_KIND;
  end;

{ TfgBitBtn }

  TfgBitBtn = class (TfgCustomBitBtn)
  published
    property Kind;
    property GroupName;
    { TfgCustomButton }
    property Align;
    property Action;
    property Anchors;
    property AutoTranslate default True;
    property CanFocus default True;
    property CanParentFocus;
    property ClipChildren default False;
    property ClipParent default False;
    property Cursor default crDefault;
    property DisableFocusEffect;
    property DragMode default TDragMode.dmManual;
    property EnableDragHighlight default True;
    property Enabled default True;
    property Font;
    property Height;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property HitTest default True;
    property StaysPressed default False;
    property IsPressed default False;
    property Locked default False;
    property Padding;
    property ModalResult default mrNone;
    property Opacity;
    property Margins;
    property PopupMenu;
    property Position;
    property RepeatClick default False;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property StyleLookup;
    property TabOrder;
    property Text;
    property TextAlign default TTextAlign.Center;
    property TouchTargetExpansion;
    property Visible default True;
    property Width;
    property WordWrap default False;
    property OnApplyStyleLookup;
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    property OnKeyDown;
    property OnKeyUp;
    property OnCanFocus;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnPainting;
    property OnPaint;
    property OnResize;
  end;

implementation

uses
  System.SysUtils, FMX.Styles;

const
  BITBTN_KIND_STYLES : array [TfgBitBtnKind] of string = ('', 'imgOk',
  'imgCancel', 'imgHelp', 'imgYes', 'imgNo', 'imgClose', 'imgRetry',
  'imgIgnore');

{ TfgCustomBitBtn }

procedure TfgCustomBitBtn.ApplyStyle;
var
  T: TFmxObject;
begin
  inherited ApplyStyle;
  T := FindStyleResource('glyph');
  if Assigned(T) and (T is TImage) then
  begin
    FStyleImage := T as TImage;
    UpdateGlyph;
  end;
end;

constructor TfgCustomBitBtn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FKind := DEFAULT_KIND;
end;

procedure TfgCustomBitBtn.DoImageLinkChanged(Sender: TObject);
begin
  UpdateGlyph;
end;

procedure TfgCustomBitBtn.FreeStyle;
begin
  FStyleImage := nil;
  inherited FreeStyle;
end;

function TfgCustomBitBtn.GetDefaultStyleLookupName: string;
begin
  Result := 'buttonstyle';
end;

function TfgCustomBitBtn.GetIsMousePressed: Boolean;
begin
  Result := FMousePressed;
end;

function TfgCustomBitBtn.GetStyleText: TControl;
begin
  if TextObject <> nil then
    Result := TextObject
  else
    Result := nil;
end;

procedure TfgCustomBitBtn.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FMousePressed := True;
  StartTriggerAnimation(Self, 'IsMousePressed');
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TfgCustomBitBtn.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited MouseUp(Button, Shift, X, Y);
  FMousePressed := False;
  StartTriggerAnimation(Self, 'IsMousePressed');
end;

procedure TfgCustomBitBtn.SetKind(const Value: TfgBitBtnKind);
begin
  if FKind <> Value then
  begin
    FKind := Value;
    UpdateGlyph;
  end;
end;

procedure TfgCustomBitBtn.UpdateGlyph;

  procedure FindAndSetStandartButtonKind(const AStyleName: string);
  var
    StyleObject: TFmxObject;
    Finded: Boolean;
    Style: TFmxObject;
  begin
    // Выбираем ветку стиля:
    //   - Если для формы указан StyleBook, то берем его.
    //   - Если для формы не задан StyleBook, то берем стиль по умолчанию
    if Assigned(Scene.StyleBook) then
      Style := Scene.StyleBook.Style
    else
      Style := TStyleManager.ActiveStyleForScene(Scene);

    // Ищем стиль по указанному имени в текущей ветки стиля
    StyleObject := Style.FindStyleResource(AStyleName);
    Finded := Assigned(StyleObject) and (StyleObject is TImage);
    if Finded then
      FStyleImage.Bitmap.Assign(TImage(StyleObject).Bitmap);
    FStyleImage.Visible := Finded;
  end;

begin
  if not Assigned(FStyleImage) then
    Exit;

//  case Kind of
//    TfgBitBtnKind.Custom: FindAndSetGlyph;
//  else
    FindAndSetStandartButtonKind(BITBTN_KIND_STYLES[Kind]);
//  end;
  FStyleImage.Visible := not FStyleImage.Bitmap.IsEmpty;
end;

initialization
  RegisterFmxClasses([TfgCustomBitBtn, TfgBitBtn]);
end.
