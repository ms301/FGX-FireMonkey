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

unit FGX.GradientEdit;

interface

uses
  System.UITypes, System.Types, FMX.Controls, FMX.Graphics, System.Classes,
  FGX.Consts;

type

  { TfgGradientEdit }

  TfgCustomGradientEdit = class;

  TfgOnPointClick = procedure (AGradientEdit: TfgCustomGradientEdit; const AGradientPoint: TGradientPoint) of object;
  TfgOnPointAdded = procedure (AGradientEdit: TfgCustomGradientEdit; const AGradientPoint: TGradientPoint) of object;

  TfgCustomGradientEdit = class (TControl)
  public
    const DEFAULT_PICKER_SIZE = 12;
    const DEFAULT_BORDER_RADIUS = 0;
    const DEFAULT_BORDER_COLOR = TAlphaColorRec.Black;
  private
    FGradient: TGradient;
    FPickerSize: Single;
    FBorderRadius: Single;
    FBorderColor: TAlphaColor;
    FBackgroundBrush: TBrush;
    FIsPointMoving: Boolean;
    [weak] FSelectedPoint: TGradientPoint;
    { Events }
    FOnPointClick: TfgOnPointClick;
    FOnPointDblClick: TfgOnPointClick;
    FOnPointAdded: TfgOnPointAdded;
    FOnChangeTracking: TNotifyEvent;
    FOnChanged: TNotifyEvent;
    function IsPickerSizeStored: Boolean;
    function IsBorderRadiusStored: Boolean;
    procedure SetPickerSize(const Value: Single);
    procedure SetBorderRadius(const Value: Single);
    procedure SetGradient(const Value: TGradient);
    procedure SetBorderColor(const Value: TAlphaColor);
  protected
    FGradientChanged: Boolean;
    { Control events }
    procedure DoGradientChanged(Sender: TObject); virtual;
    procedure DoPointAdded(AGradientPoint: TGradientPoint); virtual;
    procedure DoPointClick(const AGradientPoint: TGradientPoint); virtual;
    procedure DoPointDblClick(const AGradientPoint: TGradientPoint); virtual;
    procedure DoChanged; virtual;
    procedure DoChangeTracking; virtual;
    /// <summary>
    ///   This function insert |APoint| into sorted position by Offset value
    /// </summary>
    procedure UpdateGradientPointsOrder(APoint: TGradientPoint);
    { Hit Test }
    function FindPointAtPoint(const APoint: TPointF; var AIndex: Integer): Boolean; virtual;
    { Sizes }
    function GetDefaultSize: TSizeF; override;
    function GetGradientFieldSize: TRectF; virtual;
    { Painting }
    procedure Paint; override;
    procedure DrawBackground; virtual;
    procedure DrawGradient; virtual;
    procedure DrawPoint(const AIndex: Integer; const ASelected: Boolean = False); virtual;
    { Mouse events }
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X: Single; Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single); override;
    property IsPointMoving: Boolean read FIsPointMoving;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Selected: Boolean;
  public
    property BorderRadius: Single read FBorderRadius write SetBorderRadius stored IsBorderRadiusStored;
    property BorderColor: TAlphaColor read FBorderColor write SetBorderColor default DEFAULT_BORDER_COLOR;
    property Gradient: TGradient read FGradient write SetGradient;
    property PickerSize: Single read FPickerSize write SetPickerSize stored IsPickerSizeStored;
    property SelectedPoint: TGradientPoint read FSelectedPoint;
    property OnPointAdded: TfgOnPointAdded read FOnPointAdded write FOnPointAdded;
    property OnPointClick: TfgOnPointClick read FOnPointClick write FOnPointClick;
    property OnPointDblClick: TfgOnPointClick read FOnPointDblClick write FOnPointDblClick;
    property OnChangeTracking: TNotifyEvent read FOnChangeTracking write FOnChangeTracking;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

  [ComponentPlatformsAttribute(fgAllPlatform)]
  TfgGradientEdit = class (TfgCustomGradientEdit)
  published
    property BorderColor;
    property BorderRadius;
    property Gradient;
    property PickerSize;
    property OnPointAdded;
    property OnPointClick;
    property OnPointDblClick;
    property OnChanged;
    property OnChangeTracking;
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
    property Size;
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
  System.Math.Vectors, System.SysUtils, System.Math, FMX.Colors, FMX.Types, FGX.Graphics, FGX.Helpers;

{ TfgCustomGradientEdit }

constructor TfgCustomGradientEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGradient := TGradient.Create;
  FGradient.OnChanged := DoGradientChanged;
  FPickerSize := DEFAULT_PICKER_SIZE;
  FBorderRadius := DEFAULT_BORDER_RADIUS;
  FBorderColor := DEFAULT_BORDER_COLOR;
  FBackgroundBrush := TBrush.Create(TBrushKind.Bitmap, TAlphaColorRec.Null);
  MakeChessBoardBrush(FBackgroundBrush.Bitmap, 10);
  AutoCapture := True;
  SetAcceptsControls(False);
end;

destructor TfgCustomGradientEdit.Destroy;
begin
  FreeAndNil(FBackgroundBrush);
  FreeAndNil(FGradient);
  inherited Destroy;;
end;

procedure TfgCustomGradientEdit.DoGradientChanged(Sender: TObject);
begin
  Repaint;
end;

procedure TfgCustomGradientEdit.DoPointAdded(AGradientPoint: TGradientPoint);
begin
  Assert(AGradientPoint <> nil);

  if Assigned(FOnPointAdded) then
    FOnPointAdded(Self, AGradientPoint);
end;

procedure TfgCustomGradientEdit.DoPointDblClick(const AGradientPoint: TGradientPoint);
begin
  Assert(AGradientPoint <> nil);

  if Assigned(FOnPointDblClick) then
    FOnPointDblClick(Self, AGradientPoint);
end;

procedure TfgCustomGradientEdit.DoPointClick(const AGradientPoint: TGradientPoint);
begin
  Assert(AGradientPoint <> nil);

  if Assigned(FOnPointClick) then
    FOnPointClick(Self, AGradientPoint);
end;

procedure TfgCustomGradientEdit.DrawBackground;
var
  GradientRect: TRectF;
begin
  GradientRect := GetGradientFieldSize;
  Canvas.FillRect(GradientRect, BorderRadius, BorderRadius, AllCorners, AbsoluteOpacity, FBackgroundBrush);
end;

procedure TfgCustomGradientEdit.DrawGradient;
var
  GradientRect: TRectF;
begin
  GradientRect := GetGradientFieldSize;

  Canvas.Fill.Kind := TBrushKind.Gradient;
  Canvas.Fill.Gradient.Assign(FGradient);
  Canvas.Fill.Gradient.Style := TGradientStyle.Linear;
  Canvas.Fill.Gradient.StartPosition.SetPointNoChange(TPointF.Create(0, 0));
  Canvas.Fill.Gradient.StopPosition.SetPointNoChange(TPointF.Create(1, 0));
  Canvas.FillRect(GradientRect, BorderRadius, BorderRadius, AllCorners, AbsoluteOpacity);

  Canvas.Stroke.Color := BorderColor;
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.DrawRect(RoundToPixel(GradientRect), BorderRadius, BorderRadius, AllCorners, AbsoluteOpacity);
end;

procedure TfgCustomGradientEdit.DrawPoint(const AIndex: Integer; const ASelected: Boolean = False);
var
  Outline: array of TPointF;
  SelectedTriangle: TPolygon;
  FillRect: TRectF;
begin
  Assert(InRange(AIndex, 0, FGradient.Points.Count - 1));

  Canvas.Stroke.Color := BorderColor;
  Canvas.StrokeThickness := 1;
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Fill.Kind := TBrushKind.Solid;

  // Вычисляем опорные точки контура
  SetLength(Outline, 5);
  Outline[0] := TPointF.Create(FGradient.Points[AIndex].Offset * (Width - PickerSize) + PickerSize / 2, Height - PickerSize * 1.5);
  Outline[1] := Outline[0] + PointF(PickerSize / 2, PickerSize / 2);
  Outline[2] := Outline[0] + PointF(PickerSize / 2, 3 * PickerSize / 2);
  Outline[3] := Outline[0] + PointF(-PickerSize / 2, 3 * PickerSize / 2);
  Outline[4] := Outline[0] + PointF(-PickerSize / 2, PickerSize / 2);

  // Заполняем контур
  Canvas.Fill.Color := TAlphaColorRec.White;
  Canvas.FillPolygon(TPolygon(Outline), 1);

  // Рисуем контур
  Canvas.DrawLine(RoundToPixel(Outline[0]), RoundToPixel(Outline[1]), Opacity);
  Canvas.DrawLine(RoundToPixel(Outline[1]), RoundToPixel(Outline[2]), Opacity);
  Canvas.DrawLine(RoundToPixel(Outline[2]), RoundToPixel(Outline[3]), Opacity);
  Canvas.DrawLine(RoundToPixel(Outline[3]), RoundToPixel(Outline[4]), Opacity);
  Canvas.DrawLine(RoundToPixel(Outline[4]), RoundToPixel(Outline[0]), Opacity);
  Canvas.DrawLine(RoundToPixel(Outline[1]), RoundToPixel(Outline[4]), Opacity);

  if ASelected then
  begin
    SetLength(SelectedTriangle, 3);
    SelectedTriangle[0] := Outline[0];
    SelectedTriangle[1] := Outline[1];
    SelectedTriangle[2] := Outline[4];
    Canvas.Fill.Color := TAlphaColorRec.Gray;
    Canvas.FillPolygon(SelectedTriangle, 1);
  end;

  // Закрашиваем цвет опорной точки градиента
  Canvas.Fill.Color := FGradient.Points[AIndex].Color;
  FillRect := TRectF.Create(Outline[4].X + 1, Outline[4].Y + 1, Outline[2].X - 2, Outline[2].Y - 2);
  Canvas.FillRect(FillRect, 0, 0, AllCorners, Opacity);
end;

function TfgCustomGradientEdit.FindPointAtPoint(const APoint: TPointF; var AIndex: Integer): Boolean;
var
  I: Integer;
  Found: Boolean;
  Offset: Extended;
begin
  I := 0;
  Found := False;
  while (I < FGradient.Points.Count) and not Found do
  begin
    Offset := FGradient.Points[I].Offset * GetGradientFieldSize.Width;
    if InRange(APoint.X - PickerSize / 2, Offset - PickerSize / 2, Offset + PickerSize / 2) then
    begin
      AIndex := I;
      Found := True;
    end
    else
      Inc(I);
  end;
  Result := Found;
end;

function TfgCustomGradientEdit.GetDefaultSize: TSizeF;
begin
  Result := TSizeF.Create(100, 35);
end;

function TfgCustomGradientEdit.GetGradientFieldSize: TRectF;
begin
  Result := TRectF.Create(PickerSize / 2, 0, Width - PickerSize / 2, Height - 1.25 * PickerSize);
end;

function TfgCustomGradientEdit.IsBorderRadiusStored: Boolean;
begin
  Result := not SameValue(BorderRadius, DEFAULT_BORDER_RADIUS, EPSILON_SINGLE);
end;

function TfgCustomGradientEdit.IsPickerSizeStored: Boolean;
begin
  Result := not SameValue(PickerSize, DEFAULT_PICKER_SIZE, EPSILON_SINGLE);
end;

procedure TfgCustomGradientEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  PointIndex: Integer;
  NewGradientPoint: TGradientPoint;
  Offset: Extended;
  PointColor: TAlphaColor;
begin
  inherited MouseDown(Button, Shift, X, Y);
  FIsPointMoving := False;
  FGradientChanged := False;
  if FindPointAtPoint(TPointF.Create(X, Y), PointIndex) then
  begin
    FIsPointMoving := True;
    FSelectedPoint := FGradient.Points[PointIndex];
    if ssDouble in shift then
      DoPointDblClick(FSelectedPoint)
    else
      DoPointClick(FSelectedPoint);
  end
  else
  begin
    if InRange(Y, 0, GetGradientFieldSize.Height) then
    begin
      X := X - PickerSize / 2;  // Normalizating X
      Offset := EnsureRange(X / GetGradientFieldSize.Width, 0, 1);
      PointColor := FGradient.InterpolateColor(Offset);
      { Create new gradient point }
      NewGradientPoint := Gradient.Points.Add as TGradientPoint;
      NewGradientPoint.Offset := Offset;
      NewGradientPoint.IntColor := PointColor;
      UpdateGradientPointsOrder(NewGradientPoint);
      FSelectedPoint := NewGradientPoint;
      FIsPointMoving := True;
      DoPointAdded(FSelectedPoint);
      DoChangeTracking;
    end;
  end;
  Repaint;
end;

procedure TfgCustomGradientEdit.MouseMove(Shift: TShiftState; X, Y: Single);
var
  NewOffset: Extended;
  TmpPoint: TGradientPoint;
begin
  inherited MouseMove(Shift, X, Y);
  if (FSelectedPoint <> nil) and Pressed and IsPointMoving then
  begin
    X := X - PickerSize / 2;
    // We return gradient point to field, if we move point into control frame
    if (Y <= Height) and (FSelectedPoint.Collection = nil) then
      FSelectedPoint.Collection := FGradient.Points;

    if (Y <= Height) and (FGradient.Points.Count >= 2) or (FGradient.Points.Count = 2) and (FSelectedPoint.Collection <> nil) then
    begin
      // We move gradient point
      NewOffset := X / GetGradientFieldSize.Width;
      NewOffset := EnsureRange(NewOffset, 0, 1);
      FSelectedPoint.Offset := NewOffset;
      UpdateGradientPointsOrder(FSelectedPoint);
      Repaint;
    end
    else
    begin
      // We remove gradient point
      if FGradient.Points.Count > 2 then
      begin
        TmpPoint := TGradientPoint.Create(nil);
        TmpPoint.Assign(FSelectedPoint);
        if FSelectedPoint.Collection <> nil then
        begin
          FGradient.Points.Delete(FSelectedPoint.Index);
          Repaint;
        end;
        FSelectedPoint := TmpPoint;
      end;
    end;
    Cursor := crDefault;
    DoChangeTracking;
  end
  else
  begin
    if GetGradientFieldSize.Contains(PointF(X, Y)) then
      Cursor := crHandPoint
    else
      Cursor := crDefault;
  end;
end;

procedure TfgCustomGradientEdit.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited MouseUp(Button, Shift, X, Y);
  // If we manualy remove selected point, we should dispose of memory
  if (FSelectedPoint <> nil) and (FSelectedPoint.Collection = nil) then
  begin
    FSelectedPoint.Free;
    FSelectedPoint := nil;
  end;
  if FGradientChanged then
    DoChanged;
  FGradientChanged := False;
  FIsPointMoving := False;
end;

procedure TfgCustomGradientEdit.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TfgCustomGradientEdit.DoChangeTracking;
begin
  FGradientChanged := True;
  if Assigned(FOnChangeTracking) then
    FOnChangeTracking(Self);
end;

procedure TfgCustomGradientEdit.Paint;

  procedure DrawPoints;
  var
    I: Integer;
  begin
    for I := 0 to FGradient.Points.Count - 1 do
      DrawPoint(I, (FSelectedPoint <> nil) and (FSelectedPoint.Index = I));
  end;

begin
  DrawBackground;
  DrawGradient;
  DrawPoints;
end;

function TfgCustomGradientEdit.Selected: Boolean;
begin
  Result := FSelectedPoint <> nil;
end;

procedure TfgCustomGradientEdit.SetBorderColor(const Value: TAlphaColor);
begin
  if BorderColor <> Value then
  begin
    FBorderColor := Value;
    Repaint;
  end;
end;

procedure TfgCustomGradientEdit.SetBorderRadius(const Value: Single);
begin
  if not SameValue(BorderRadius, Value, EPSILON_SINGLE) then
  begin
    FBorderRadius := Value;
    Repaint;
  end;
end;

procedure TfgCustomGradientEdit.SetGradient(const Value: TGradient);
begin
  Assert(Value <> nil);
  FGradient.Assign(Value);
end;

procedure TfgCustomGradientEdit.SetPickerSize(const Value: Single);
begin
  if not SameValue(PickerSize, Value, EPSILON_SINGLE) then
  begin
    FPickerSize := Value;
    Repaint;
  end;
end;

procedure TfgCustomGradientEdit.UpdateGradientPointsOrder(APoint: TGradientPoint);
var
  I: Integer;
  Found: Boolean;
  PointsCount: Integer;
  OldPointIndex: Integer;
begin
  Assert(FGradient <> nil);
  Assert(APoint <> nil);
  Assert(APoint.Collection = FGradient.Points);

  I := 0;
  Found := False;
  PointsCount := Gradient.Points.Count;
  OldPointIndex := APoint.Index;
  while (I < PointsCount) and not Found do
    if (I <> OldPointIndex) and (APoint.Offset <= Gradient.Points[I].Offset) then
      Found := True
    else
      Inc(I);
  // If we found a new position, which differs from old position, we set new
  if I - 1 <> OldPointIndex then
    APoint.Index := IfThen(Found, I, PointsCount - 1);

  Assert((APoint.Index = 0) and (APoint.Offset <= FGradient.Points[1].Offset)
      or (APoint.Index = PointsCount - 1) and (FGradient.Points[PointsCount - 1].Offset <= APoint.Offset)
      or InRange(APoint.Index, 1, PointsCount - 2) and
         InRange(APoint.Offset, FGradient.Points[APoint.Index - 1].Offset, FGradient.Points[APoint.Index + 1].Offset),
      'UpdateGradientPointsOrder returned wrong point order');
end;

initialization
  RegisterFmxClasses([TfgCustomGradientEdit, TfgGradientEdit]);
end.
