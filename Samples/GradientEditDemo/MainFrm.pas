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
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FGX.GradientEdit, FMX.Colors, FMX.Controls.Presentation, FMX.Layouts, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.EditBox,
  FMX.SpinBox;

type
  TFormMain = class(TForm)
    fgGradientEdit: TfgGradientEdit;
    Memo1: TMemo;
    Layout1: TLayout;
    Button1: TButton;
    Layout2: TLayout;
    Label1: TLabel;
    SpinBoxPickerSize: TSpinBox;
    Layout3: TLayout;
    Label3: TLabel;
    SpinBoxBorderRadius: TSpinBox;
    Layout4: TLayout;
    Label4: TLabel;
    ComboColorBoxBorderColor: TComboColorBox;
    procedure fgGradientEditPointAdded(AGradientEdit: TObject; const AGradientPoint: TGradientPoint);
    procedure fgGradientEditPointClick(AGradientEdit: TObject; const AGradientPoint: TGradientPoint);
    procedure fgGradientEditPointDblClick(AGradientEdit: TObject; const AGradientPoint: TGradientPoint);
    procedure fgGradientEditPointRemoved(AGradientEdit: TObject; const AGradientPoint: TGradientPoint);
    procedure fgGradientEditChangeTracking(Sender: TObject);
    procedure fgGradientEditChanged(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SpinBoxPickerSizeChangeTracking(Sender: TObject);
    procedure SpinBoxBorderRadiusChangeTracking(Sender: TObject);
    procedure ComboColorBoxBorderColorChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

procedure TFormMain.Button1Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TFormMain.ComboColorBoxBorderColorChange(Sender: TObject);
begin
  fgGradientEdit.BorderColor := ComboColorBoxBorderColor.Color;
end;

procedure TFormMain.fgGradientEditChanged(Sender: TObject);
begin
  Memo1.Lines.Add('TfgGradientEdit.OnChange');
end;

procedure TFormMain.fgGradientEditChangeTracking(Sender: TObject);
begin
  Memo1.Lines.Add('TfgGradientEdit.OnChangeTracking');
end;

procedure TFormMain.fgGradientEditPointAdded(AGradientEdit: TObject;
  const AGradientPoint: TGradientPoint);
begin
  Memo1.Lines.Add(Format('TfgGradientEdit.OnPointAdded: color=%d offset=%f', [AGradientPoint.Color, AGradientPoint.Offset]));
end;

procedure TFormMain.fgGradientEditPointClick(AGradientEdit: TObject;
  const AGradientPoint: TGradientPoint);
begin
  Memo1.Lines.Add(Format('TfgGradientEdit.OnPointClick: color=%d offset=%f', [AGradientPoint.Color, AGradientPoint.Offset]));
end;

procedure TFormMain.fgGradientEditPointDblClick(AGradientEdit: TObject;
  const AGradientPoint: TGradientPoint);
begin
  Memo1.Lines.Add(Format('TfgGradientEdit.OnPointDblClick: color=%d offset=%f', [AGradientPoint.Color, AGradientPoint.Offset]));
end;

procedure TFormMain.fgGradientEditPointRemoved(AGradientEdit: TObject; const AGradientPoint: TGradientPoint);
begin
  Memo1.Lines.Add(Format('TfgGradientEdit.OnPointRemoved: color=%d offset=%f', [AGradientPoint.Color, AGradientPoint.Offset]));
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  ComboColorBoxBorderColor.Color := fgGradientEdit.BorderColor;
  SpinBoxBorderRadius.Value := fgGradientEdit.BorderRadius;
  SpinBoxPickerSize.Value := fgGradientEdit.PickerSize;
end;

procedure TFormMain.SpinBoxBorderRadiusChangeTracking(Sender: TObject);
begin
  fgGradientEdit.BorderRadius := SpinBoxBorderRadius.Value;
end;

procedure TFormMain.SpinBoxPickerSizeChangeTracking(Sender: TObject);
begin
  fgGradientEdit.PickerSize := SpinBoxPickerSize.Value;
end;

end.
