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
    Layout1: TLayout;
    Label1: TLabel;
    SwitchCancellable: TSwitch;
    procedure btnProgressDialogClick(Sender: TObject);
    procedure btnActivityDialogClick(Sender: TObject);
    procedure fgProgressDialogHide(Sender: TObject);
    procedure fgProgressDialogShow(Sender: TObject);
    procedure SwitchCancellableSwitch(Sender: TObject);
    procedure fgProgressDialogCancel(Sender: TObject);
    procedure fgActivityDialogCancel(Sender: TObject);
  private
    FProgressDialogThread: TThread;
    FActivityDialogThread: TThread;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

procedure TFormMain.btnProgressDialogClick(Sender: TObject);
begin
  if not fgProgressDialog.IsShown then
  begin
    FProgressDialogThread := TThread.CreateAnonymousThread(procedure
      begin
        try
          TThread.Synchronize(nil, procedure
          begin
            fgProgressDialog.ResetProgress;
            fgProgressDialog.Show;
            fgProgressDialog.Message := 'Preparing downloading content';
            fgProgressDialog.Kind := TfgProgressDialogKind.Undeterminated;
          end);
          Sleep(1000);
          if TThread.CheckTerminated then
            Exit;

          TThread.Synchronize(nil, procedure
          begin
            fgProgressDialog.Kind := TfgProgressDialogKind.Determinated;
          end);
          Sleep(1000);
          if TThread.CheckTerminated then
            Exit;

          TThread.Synchronize(nil, procedure
          begin
            fgProgressDialog.Message := 'Union units...';
            fgProgressDialog.Progress := 10;
          end);
          Sleep(1000);
          if TThread.CheckTerminated then
            Exit;

          TThread.Synchronize(nil, procedure
          begin
            fgProgressDialog.Message := 'Sorting units in package...';
            fgProgressDialog.Progress := 20;
          end);
          Sleep(1000);
          if TThread.CheckTerminated then
            Exit;

          TThread.Synchronize(nil, procedure
          begin
            fgProgressDialog.Message := 'Removed comments...';
            fgProgressDialog.Progress := 60;
          end);
          Sleep(1000);
          if TThread.CheckTerminated then
            Exit;

          TThread.Synchronize(nil, procedure
          begin
            fgProgressDialog.Message := 'Finishig';
            fgProgressDialog.Progress := 90;
          end);
          Sleep(500);
          if TThread.CheckTerminated then
            Exit;

          TThread.Synchronize(nil, procedure
          begin
            fgProgressDialog.Progress := 100;
          end);
          Sleep(500);
          if TThread.CheckTerminated then
            Exit;
        finally
          if not TThread.CheckTerminated then
            TThread.Synchronize(nil, procedure
            begin
              fgProgressDialog.Hide;
            end);
        end;
      end);
    FProgressDialogThread.FreeOnTerminate := False;
    FProgressDialogThread.Start;
  end;
end;

procedure TFormMain.btnActivityDialogClick(Sender: TObject);
begin
  if not fgActivityDialog.IsShown then
  begin
    FActivityDialogThread := TThread.CreateAnonymousThread(procedure
      begin
        try
          TThread.Synchronize(nil, procedure
          begin
            fgActivityDialog.Message := 'Please, Wait';
            fgActivityDialog.Show;
          end);
          Sleep(1000);
          if TThread.CheckTerminated then
            Exit;

          TThread.Synchronize(nil, procedure
          begin
            fgActivityDialog.Message := 'Downloading file info.txt';
          end);
          Sleep(1000);
          if TThread.CheckTerminated then
            Exit;

          TThread.Synchronize(nil, procedure
          begin
            fgActivityDialog.Message := 'Downloading file game.level';
          end);
          Sleep(1000);
          if TThread.CheckTerminated then
            Exit;

          TThread.Synchronize(nil, procedure
          begin
            fgActivityDialog.Message := 'Downloading file delphi.zip';
          end);
          Sleep(1000);
          if TThread.CheckTerminated then
            Exit;

          TThread.Synchronize(nil, procedure
          begin
            fgActivityDialog.Message := 'Finishig';
          end);
          Sleep(500);

          if TThread.CheckTerminated then
            Exit;
        finally
          if not TThread.CheckTerminated then
            TThread.Synchronize(nil, procedure
            begin
              fgActivityDialog.Hide;
            end);
        end;
      end);
    FActivityDialogThread.FreeOnTerminate := False;
    FActivityDialogThread.Start;
  end;
end;

procedure TFormMain.fgActivityDialogCancel(Sender: TObject);
begin
  Log.d('OnCancel');
  FActivityDialogThread.Terminate;
end;

procedure TFormMain.fgProgressDialogCancel(Sender: TObject);
begin
  Log.d('OnCancel');
  FProgressDialogThread.Terminate;
end;

procedure TFormMain.fgProgressDialogHide(Sender: TObject);
begin
  Log.d('OnHide');
end;

procedure TFormMain.fgProgressDialogShow(Sender: TObject);
begin
  Log.d('OnShow');
end;

procedure TFormMain.SwitchCancellableSwitch(Sender: TObject);
begin
  fgActivityDialog.Cancellable := SwitchCancellable.IsChecked;
  fgProgressDialog.Cancellable := SwitchCancellable.IsChecked;
end;

end.
