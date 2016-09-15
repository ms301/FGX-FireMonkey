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

unit MainFrm;

interface

uses
  System.SysUtils, System.Types, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FGX.ColorsPanel, FMX.Edit, FMX.Objects,
  FMX.ListBox, System.UITypes, FMX.Controls.Presentation, FMX.EditBox, FMX.NumberBox, FMX.Colors, FMX.Layouts,
  FMX.MultiView;

type
  TFormMain = class(TForm)
    fgColorsPanel: TfgColorsPanel;
    nbCellSizeWidth: TNumberBox;
    nbCellSizeHeight: TNumberBox;
    nbBorderRadius: TNumberBox;
    cbPresetKind: TComboBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ColorBox: TColorBox;
    lSelectedColor: TLabel;
    cbStrokeColor: TComboColorBox;
    MultiView1: TMultiView;
    ListBox1: TListBox;
    ListBoxItem4: TListBoxItem;
    ListBoxItem5: TListBoxItem;
    ListBoxItem6: TListBoxItem;
    ListBoxItem7: TListBoxItem;
    ListBoxItem8: TListBoxItem;
    ListBoxItem9: TListBoxItem;
    ListBoxItem10: TListBoxItem;
    ListBoxGroupHeader1: TListBoxGroupHeader;
    ListBoxGroupHeader2: TListBoxGroupHeader;
    ListBoxGroupHeader3: TListBoxGroupHeader;
    swUserPainting: TSwitch;
    swUsersColors: TSwitch;
    procedure nbCellSizeWidthChangeTracking(Sender: TObject);
    procedure nbBorderRadiusChangeTracking(Sender: TObject);
    procedure cbPresetKindChange(Sender: TObject);
    procedure fgColorsPanelGetColor(Sender: TObject; const Column, Row: Integer; var Color: TAlphaColor);
    procedure fgColorsPanelPaintCell(Sender: TObject; Canvas: TCanvas; const Column, Row: Integer; const Frame: TRectF;
      const AColor: TAlphaColor; Corners: TCorners; var Done: Boolean);
    procedure FormShow(Sender: TObject);
    procedure fgColorsPanelColorSelected(Sender: TObject; const AColor: TAlphaColor);
    procedure cbStrokeColorChange(Sender: TObject);
    procedure swUserPaintingSwitch(Sender: TObject);
    procedure MultiView1PresenterChanging(Sender: TObject; var PresenterClass: TMultiViewPresentationClass);
    procedure swUsersColorsSwitch(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

uses
  System.Math, FMX.MultiView.Presentations;

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

  if swUsersColors.IsChecked and InRange(ColorIndex, Low(USERS_COLORS), High(USERS_COLORS)) and (Row > 10) then
    Color := USERS_COLORS[ColorIndex];
end;

procedure TFormMain.fgColorsPanelPaintCell(Sender: TObject; Canvas: TCanvas; const Column, Row: Integer;
  const Frame: TRectF; const AColor: TAlphaColor; Corners: TCorners; var Done: Boolean);
begin
  if swUserPainting.IsChecked and (Row = 10) then
  begin
    Canvas.Fill.Kind := TBrushKind.Gradient;
    Canvas.FillRect(Frame, fgColorsPanel.BorderRadius, fgColorsPanel.BorderRadius, Corners, 1);
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  MultiView1.Mode := TMultiViewMode.PlatformBehaviour;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  nbCellSizeWidth.Value := fgColorsPanel.CellSize.Width;
  nbCellSizeHeight.Value := fgColorsPanel.CellSize.Height;
  nbBorderRadius.Value := fgColorsPanel.BorderRadius;
  cbPresetKind.ItemIndex := Integer(fgColorsPanel.PresetKind);
  nbBorderRadius.Max := Min(nbCellSizeWidth.Value / 2, nbCellSizeHeight.Value / 2);
end;

procedure TFormMain.MultiView1PresenterChanging(Sender: TObject; var PresenterClass: TMultiViewPresentationClass);
begin
  if PresenterClass = TMultiViewNavigationPanePresentation then
    PresenterClass := TMultiViewDockedPanelPresentation;
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

procedure TFormMain.swUserPaintingSwitch(Sender: TObject);
begin
  fgColorsPanel.Repaint;
end;

procedure TFormMain.swUsersColorsSwitch(Sender: TObject);
begin
  fgColorsPanel.Repaint;
end;

end.
