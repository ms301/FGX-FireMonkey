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

unit FGX.ColorsPanel;

interface

{$SCOPEDENUMS ON}

uses
  System.Types, System.Classes, System.UITypes, FMX.Controls, FMX.Graphics, FMX.Types, FGX.Colors.Presets, FGX.Types;

type

  { TfgCustomColorsPanel }

  TfgOnGetColor = procedure (Sender: TObject; const Column, Row: Integer; var Color: TAlphaColor) of object;
  TfgOnColorSelected = procedure (Sender: TObject; const AColor: TAlphaColor) of object;
  TfgOnPaintCell = procedure (Sender: TObject; Canvas: TCanvas; const Column, Row: Integer; const Frame: TRectF;
    const AColor: TAlphaColor; Corners: TCorners; var Done: Boolean) of object;

  TfgColorsPresetKind = (WebSafe, X11, Custom);

  TfgCustomColorsPanel = class(TControl)
  public const
    DefaultCellSize = 18;
    MinCellSize = 5;
  private
    FCellSize: TfgSingleSize;
    FBorderRadius: Single;
    FStrokeBrush: TStrokeBrush;
    FColorsPreset: TfgColorsPreset;
    FPresetKind: TfgColorsPresetKind;
    FOnGetColor: TfgOnGetColor;
    FOnColorSelected: TfgOnColorSelected;
    FOnPaintCell: TfgOnPaintCell;
    function IsBorderRadiusStored: Boolean;
    function IsCellSizeStored: Boolean;
    procedure SetColorCellSize(const Value: TfgSingleSize);
    procedure SetBorderColor(const Value: TStrokeBrush);
    procedure SetBorderRadius(const Value: Single);
    procedure SetColorsPreset(const Value: TfgColorsPreset);
    procedure SetPresetKind(const Value: TfgColorsPresetKind);
  protected
    { Events }
    procedure DoGetColor(const AColumn, ARow: Integer; var AColor: TAlphaColor); virtual;
    procedure DoColorSelected(const AColor: TAlphaColor); virtual;
    procedure DoPaintCell(const AColumn, ARow: Integer; const AFrame: TRectF; const AColor: TAlphaColor; ACorners: TCorners;
                          var ADone: Boolean); virtual;
    procedure DoBorderStrokeChanged(Sender: TObject); virtual;
    procedure DoCellSizeChanged(Sender: TObject); virtual;
    { Sizes }
    function GetDefaultSize: TSizeF; override;
    function GetBorderFrame: TRectF; virtual;
    function GetCellFrame(const Column, Row: Integer): TRectF; virtual;
    { Painting }
    procedure Paint; override;
    procedure DrawCell(const AColumn, ARow: Integer; const AFrame: TRectF; const AColor: TAlphaColor); virtual;
    { Mouse Events }
    procedure MouseClick(Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetColor(const AColumn, ARow: Integer): TAlphaColor; virtual;
    function ColumnsCount: Integer;
    function RowsCount: Integer;
    property ColorsPreset: TfgColorsPreset read FColorsPreset write SetColorsPreset;
  public
    property BorderRadius: Single read FBorderRadius write SetBorderRadius stored IsBorderRadiusStored;
    property PresetKind: TfgColorsPresetKind read FPresetKind write SetPresetKind default TfgColorsPresetKind.WebSafe;
    property Stroke: TStrokeBrush read FStrokeBrush write SetBorderColor;
    property CellSize: TfgSingleSize read FCellSize write SetColorCellSize stored IsCellSizeStored;
    property OnGetColor: TfgOnGetColor read FOnGetColor write FOnGetColor;
    property OnColorSelected: TfgOnColorSelected read FOnColorSelected write FOnColorSelected;
    property OnPaintCell: TfgOnPaintCell read FOnPaintCell write FOnPaintCell;
  end;

  { TfgColorsPanel }

  [ComponentPlatformsAttribute(pidWin32 or pidWin64 or pidOSX32 or pidAndroid or pidiOSDevice or pidiOSSimulator)]
  TfgColorsPanel = class(TfgCustomColorsPanel)
  published
    property Stroke;
    property BorderRadius;
    property PresetKind;
    property CellSize;
    property OnGetColor;
    property OnColorSelected;
    property OnPaintCell;
    { inherited }
    property Align;
    property Anchors;
    property ClipChildren default False;
    property ClipParent default False;
    property Cursor default crDefault;
    property DragMode default TDragMode.dmManual;
    property EnableDragHighlight default True;
    property Enabled default True;
    property Locked default False;
    property Height;
    property HitTest default True;
    property Padding;
    property Opacity;
    property Margins;
    property PopupMenu;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property TabOrder;
    property TouchTargetExpansion;
    property Visible default True;
    property Width;
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
  System.Math, System.SysUtils, System.UIConsts, System.TypInfo, FGX.Graphics, FGX.Consts, FGX.Asserts;

{ TfgCustomColorsPanel }

function TfgCustomColorsPanel.ColumnsCount: Integer;
begin
  AssertIsNotNil(CellSize);

  if not SameValue(CellSize.Width - 1, 0, EPSILON_SINGLE) then
    Result := Floor(Width / (CellSize.Width - 1))
  else
    Result := 0;
end;

constructor TfgCustomColorsPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCellSize := TfgSingleSize.Create(DefaultCellSize, DefaultCellSize, TfgEqualityComparators.SingleEquality);
  FCellSize.OnChange := DoCellSizeChanged;
  FBorderRadius := 0;
  FStrokeBrush := TStrokeBrush.Create(TBrushKind.Solid, TAlphaColorRec.Black);
  FStrokeBrush.OnChanged := DoBorderStrokeChanged;
  SetAcceptsControls(False);
  { Set Default Preset }
  SetLength(FColorsPreset, Length(COLORS_PRESET_WEB_SAFE));
  System.Move(COLORS_PRESET_WEB_SAFE[1], FColorsPreset[0], SizeOf(COLORS_PRESET_WEB_SAFE));
end;

destructor TfgCustomColorsPanel.Destroy;
begin
  FreeAndNil(FCellSize);
  FreeAndNil(FStrokeBrush);
  inherited Destroy;
end;

procedure TfgCustomColorsPanel.DoBorderStrokeChanged(Sender: TObject);
begin
  Repaint;
end;

procedure TfgCustomColorsPanel.DoCellSizeChanged(Sender: TObject);
begin
  Repaint;
end;

procedure TfgCustomColorsPanel.DoColorSelected(const AColor: TAlphaColor);
begin
  if Assigned(FOnColorSelected) then
    FOnColorSelected(Self, AColor);
end;

procedure TfgCustomColorsPanel.DoGetColor(const AColumn, ARow: Integer; var AColor: TAlphaColor);
begin
  if Assigned(FOnGetColor) then
    FOnGetColor(Self, AColumn, ARow, AColor);
end;

procedure TfgCustomColorsPanel.DoPaintCell(const AColumn, ARow: Integer; const AFrame: TRectF; const AColor: TAlphaColor;
  ACorners: TCorners; var ADone: Boolean);
begin
  if Assigned(FOnPaintCell) then
    FOnPaintCell(Self, Canvas, AColumn, ARow, AFrame, AColor, ACorners, ADone);
end;

procedure TfgCustomColorsPanel.DrawCell(const AColumn, ARow: Integer; const AFrame: TRectF; const AColor: TAlphaColor);

  function DefineCorners: TCorners;
  var
    Corners: TCorners;
  begin
    Corners := [];
    if (AColumn = 1) and (ARow = 1) then
      Corners := Corners + [TCorner.TopLeft];
    if (AColumn = ColumnsCount) and (ARow = 1) then
      Corners := Corners + [TCorner.TopRight];
    if (AColumn = ColumnsCount) and (ARow = RowsCount) then
      Corners := Corners + [TCorner.BottomRight];
    if (AColumn = 1) and (ARow = RowsCount) then
      Corners := Corners + [TCorner.BottomLeft];
    Result := Corners;
  end;

var
  Corners: TCorners;
  Done: Boolean;
begin
  AssertIsNotNil(Canvas);
  AssertInRange(AColumn, 1, ColumnsCount);
  AssertInRange(ARow, 1, RowsCount);

  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := AColor;
  Corners := DefineCorners;

  Done := False;
  DoPaintCell(AColumn, ARow, AFrame, AColor, Corners, Done);
  if not Done then
    Canvas.FillRect(AFrame, BorderRadius, BorderRadius, Corners, AbsoluteOpacity);
  Canvas.DrawRect(AFrame, BorderRadius, BorderRadius, Corners, AbsoluteOpacity, Stroke);
end;

function TfgCustomColorsPanel.GetDefaultSize: TSizeF;
begin
  Result := TSizeF.Create(85, 34);
end;

function TfgCustomColorsPanel.GetCellFrame(const Column, Row: Integer): TRectF;
var
  Left: Single;
  Top: Single;
  HalfThickness: Single;
begin
  AssertIsNotNil(CellSize);
  AssertInRange(Column, 1, ColumnsCount);
  AssertInRange(Row, 1, RowsCount);

  Left := (Column - 1) * (CellSize.Width - Stroke.Thickness);
  Top := (Row - 1) * (CellSize.Height - Stroke.Thickness);

  HalfThickness := FStrokeBrush.Thickness / 2;
  Result := TRectF.Create(TPointF.Create(Left, Top), CellSize.Width, CellSize.Height);
  Result.Inflate(-HalfThickness, -HalfThickness);
end;

function TfgCustomColorsPanel.GetBorderFrame: TRectF;
var
  HalfThickness: Single;
begin
  HalfThickness := FStrokeBrush.Thickness / 2;
  Result := TRectF.Create(HalfThickness, HalfThickness, Width - HalfThickness, Height - HalfThickness);
end;

function TfgCustomColorsPanel.GetColor(const AColumn, ARow: Integer): TAlphaColor;
var
  ColorIndex: Integer;
  PresetTmp: TfgColorsPreset;
begin
  ColorIndex := (ARow - 1) * ColumnsCount + AColumn;
  case PresetKind of
    TfgColorsPresetKind.WebSafe:
    begin
      SetLength(PresetTmp, Length(COLORS_PRESET_WEB_SAFE));
      System.Move(COLORS_PRESET_WEB_SAFE[1], PresetTmp[0], SizeOf(COLORS_PRESET_WEB_SAFE));
    end;
    TfgColorsPresetKind.X11:
    begin
      SetLength(PresetTmp, Length(COLORS_PRESET_X11));
      System.Move(COLORS_PRESET_X11[1], PresetTmp[0], SizeOf(COLORS_PRESET_X11));
    end;
    TfgColorsPresetKind.Custom:
      PresetTmp := FColorsPreset;
  else
    Result := TAlphaColorRec.Null;
  end;

  if ColorIndex <= High(PresetTmp) then
    Result := PresetTmp[ColorIndex].Value
  else
    Result := TAlphaColorRec.Null;
  DoGetColor(AColumn, ARow, Result);
end;

function TfgCustomColorsPanel.IsBorderRadiusStored: Boolean;
begin
  Result := not SameValue(BorderRadius, 0, EPSILON_SINGLE);
end;

function TfgCustomColorsPanel.IsCellSizeStored: Boolean;
begin
  Result := not SameValue(FCellSize.Width, DefaultCellSize, EPSILON_SINGLE) or not SameValue(FCellSize.Height, DefaultCellSize, EPSILON_SINGLE);
end;

procedure TfgCustomColorsPanel.MouseClick(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  ClickedColor: TAlphaColor;
  Col: Integer;
  Row: Integer;
begin
  inherited MouseClick(Button, Shift, X, Y);
  Col := Floor(X / (CellSize.Width - FStrokeBrush.Thickness)) + 1;
  Row := Floor(Y / (CellSize.Height - FStrokeBrush.Thickness)) + 1;
  ClickedColor := GetColor(Col, Row);
  DoColorSelected(ClickedColor);
end;

procedure TfgCustomColorsPanel.Paint;
var
  Column: Integer;
  Row: Integer;
  Color: TAlphaColor;
begin
  if ColumnsCount > 0 then
    for Row := 1 to RowsCount do
      for Column := 1 to ColumnsCount do
      begin
        Color := GetColor(Column, Row);
        DrawCell(Column, Row, GetCellFrame(Column, Row), Color);
      end;
end;

function TfgCustomColorsPanel.RowsCount: Integer;
begin
  Result := Floor(Height / (CellSize.Height - 1));
end;

procedure TfgCustomColorsPanel.SetBorderColor(const Value: TStrokeBrush);
begin
  if FStrokeBrush.Equals(Value) then
  begin
    FStrokeBrush.Assign(Value);
    Repaint;
  end;
end;

procedure TfgCustomColorsPanel.SetBorderRadius(const Value: Single);
begin
  if not SameValue(BorderRadius, Value, EPSILON_SINGLE) then
  begin
    FBorderRadius := Value;
    Repaint;
  end;
end;

procedure TfgCustomColorsPanel.SetColorCellSize(const Value: TfgSingleSize);
begin
  AssertIsNotNil(Value);
  AssertIsNotNil(CellSize);
  Assert(Value.Width >= MinCellSize);
  Assert(Value.Height >= MinCellSize);

  if CellSize <> Value then
  begin
    FCellSize.Assign(Value);
    Repaint;
  end;
end;

procedure TfgCustomColorsPanel.SetPresetKind(const Value: TfgColorsPresetKind);
begin
  if PresetKind <> Value then
  begin
    FPresetKind := Value;
    Repaint;
  end;
end;

procedure TfgCustomColorsPanel.SetColorsPreset(const Value: TfgColorsPreset);
begin
  FColorsPreset := Value;
  Repaint;
end;

initialization
  RegisterFmxClasses([TfgCustomColorsPanel, TfgColorsPanel]);
end.
