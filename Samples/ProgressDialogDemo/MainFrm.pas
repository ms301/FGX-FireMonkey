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
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FGX.ProgressDialog, FGX.ProgressDialog.Types,
  FMX.StdCtrls, FMX.Layouts, FMX.Controls.Presentation;

type
  TFormMain = class(TForm)
    btnProgressDialog: TButton;
    fgProgressDialog: TfgProgressDialog;
    fgActivityDialog: TfgActivityDialog;
    btnActivityDialog: TButton;
    LayoutButtons: TLayout;
    procedure btnProgressDialogClick(Sender: TObject);
    procedure btnActivityDialogClick(Sender: TObject);
    procedure fgProgressDialogHide(Sender: TObject);
    procedure fgProgressDialogShow(Sender: TObject);
  public
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

procedure TFormMain.btnProgressDialogClick(Sender: TObject);
begin
  fgProgressDialog.ResetProgress;
  fgProgressDialog.Show;
  try
    fgProgressDialog.Message := 'Preparing downloading content';
    fgProgressDialog.Kind := TfgProgressDialogKind.Undeterminated;
    Sleep(1000);
    fgProgressDialog.Kind := TfgProgressDialogKind.Determinated;
    Sleep(1000);
    fgProgressDialog.Message := 'Union units...';
    fgProgressDialog.Progress := 10;
    Sleep(1000);
    fgProgressDialog.Message := 'Sorting units in package...';
    fgProgressDialog.Progress := 20;
    Sleep(1000);
    fgProgressDialog.Message := 'Removed comments...';
    fgProgressDialog.Progress := 60;
    Sleep(1000);
    fgProgressDialog.Message := 'Finishig';
    fgProgressDialog.Progress := 90;
    Sleep(500);
    fgProgressDialog.Progress := 100;
    Sleep(500);
  finally
    fgProgressDialog.Hide;
  end;
end;

procedure TFormMain.btnActivityDialogClick(Sender: TObject);
begin
  fgActivityDialog.Message := 'Please, Wait';
  fgActivityDialog.Show;
  try
    Sleep(1000);
    fgActivityDialog.Message := 'Downloading file info.txt';
    Sleep(1000);
    fgActivityDialog.Message := 'Downloading file game.level';
    Sleep(1000);
    fgActivityDialog.Message := 'Downloading file delphi.zip';
    Sleep(1000);
    fgActivityDialog.Message := 'Finishig';
    Sleep(500);
  finally
    fgActivityDialog.Hide;
  end;
end;

procedure TFormMain.fgProgressDialogHide(Sender: TObject);
begin
  Log.d('OnHide');
end;

procedure TFormMain.fgProgressDialogShow(Sender: TObject);
begin
  Log.d('OnShow');
end;

end.
