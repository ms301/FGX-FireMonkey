unit MainFrm;

interface

uses
  System.SysUtils, System.Types, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FGX.ColorsPanel, FMX.Edit, FMX.Objects,
  FMX.ListBox, System.UITypes, FMX.Controls.Presentation, FMX.EditBox, FMX.NumberBox, FMX.Colors;

type
  TFormMain = class(TForm)
    fgColorsPanel: TfgColorsPanel;
    PanelSettings: TPanel;
    gbViewSettings: TGroupBox;
    Label1: TLabel;
    nbCellSizeWidth: TNumberBox;
    nbCellSizeHeight: TNumberBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    nbBorderRadius: TNumberBox;
    Line1: TLine;
    gbKindSettings: TGroupBox;
    Label5: TLabel;
    cbPresetKind: TComboBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    gbEventSettings: TGroupBox;
    cbUserPainting: TCheckBox;
    cbUsersColors: TCheckBox;
    ColorBox: TColorBox;
    lSelectedColor: TLabel;
    Label6: TLabel;
    cbStrokeColor: TComboColorBox;
    procedure nbCellSizeWidthChangeTracking(Sender: TObject);
    procedure nbBorderRadiusChangeTracking(Sender: TObject);
    procedure cbPresetKindChange(Sender: TObject);
    procedure fgColorsPanelGetColor(Sender: TObject; const Column, Row: Integer; var Color: TAlphaColor);
    procedure cbUserPaintingChange(Sender: TObject);
    procedure fgColorsPanelPaintCell(Sender: TObject; Canvas: TCanvas; const Column, Row: Integer; const Frame: TRectF;
      const AColor: TAlphaColor; Corners: TCorners; var Done: Boolean);
    procedure FormShow(Sender: TObject);
    procedure fgColorsPanelColorSelected(Sender: TObject; const AColor: TAlphaColor);
    procedure cbStrokeColorChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

uses
  System.Math;

const
  USERS_COLORS : array [1..10] of TAlphaColor = (TAlphaColorRec.Aliceblue, TAlphaColorRec.Darkviolet,
    TAlphaColorRec.Antiquewhite, TAlphaColorRec.Beige, TAlphaColorRec.Chocolate, TAlphaColorRec.Lightsteelblue,
    TAlphaColorRec.Ivory, TAlphaColorRec.Khaki, TAlphaColorRec.Navajowhite, TAlphaColorRec.Violet);

{$R *.fmx}

procedure TFormMain.cbPresetKindChange(Sender: TObject);
begin
  fgColorsPanel.PresetKind := TfgColorsPresetKind(cbPresetKind.ItemIndex);
end;

procedure TFormMain.cbStrokeColorChange(Sender: TObject);
begin
  fgColorsPanel.Stroke.Color := cbStrokeColor.Color;
end;

procedure TFormMain.cbUserPaintingChange(Sender: TObject);
begin
  fgColorsPanel.Repaint;
end;

procedure TFormMain.fgColorsPanelColorSelected(Sender: TObject; const AColor: TAlphaColor);
begin
  ColorBox.Color := AColor;
  lSelectedColor.Text := Format('Selected Color: %s', [IntToHEx(AColor, 8)]);
end;

procedure TFormMain.fgColorsPanelGetColor(Sender: TObject; const Column, Row: Integer; var Color: TAlphaColor);
var
  ColorIndex: Integer;
begin
  ColorIndex := Column;
  if Color = TAlphaColorRec.Null then
    Color := TAlphaColorRec.White;

  if cbUsersColors.IsChecked and InRange(ColorIndex, Low(USERS_COLORS), High(USERS_COLORS)) and (Row > 10) then
    Color := USERS_COLORS[ColorIndex];
end;

procedure TFormMain.fgColorsPanelPaintCell(Sender: TObject; Canvas: TCanvas; const Column, Row: Integer;
  const Frame: TRectF; const AColor: TAlphaColor; Corners: TCorners; var Done: Boolean);
begin
  if cbUserPainting.IsChecked and (Row = 10) then
  begin
    Canvas.Fill.Kind := TBrushKind.Gradient;
    Canvas.FillRect(Frame, fgColorsPanel.BorderRadius, fgColorsPanel.BorderRadius, Corners, 1);
  end;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  nbCellSizeWidth.Value := fgColorsPanel.CellSize.Width;
  nbCellSizeHeight.Value := fgColorsPanel.CellSize.Height;
  nbBorderRadius.Value := fgColorsPanel.BorderRadius;
  cbPresetKind.ItemIndex := Integer(fgColorsPanel.PresetKind);
  nbBorderRadius.Max := Min(nbCellSizeWidth.Value / 2, nbCellSizeHeight.Value / 2);
end;

procedure TFormMain.nbBorderRadiusChangeTracking(Sender: TObject);
begin
  fgColorsPanel.BorderRadius := nbBorderRadius.Value;
end;

procedure TFormMain.nbCellSizeWidthChangeTracking(Sender: TObject);
begin
  fgColorsPanel.CellSize.Width := nbCellSizeWidth.Value;
  fgColorsPanel.CellSize.Height := nbCellSizeHeight.Value;
  nbBorderRadius.Max := Min(nbCellSizeWidth.Value / 2, nbCellSizeHeight.Value / 2);
end;

end.
