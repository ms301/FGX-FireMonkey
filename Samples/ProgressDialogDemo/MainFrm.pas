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
  FMX.StdCtrls, FMX.Layouts, FMX.Controls.Presentation, FMX.ListBox, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.EditBox,
  FMX.NumberBox;

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
    Layout2: TLayout;
    Label2: TLabel;
    ComboBoxTheme: TComboBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    MemoLog: TMemo;
    LabelError: TLabel;
    LayoutThemeID: TLayout;
    Label4: TLabel;
    NumberBoxThemeID: TNumberBox;
    ListBoxItem4: TListBoxItem;
    procedure btnProgressDialogClick(Sender: TObject);
    procedure btnActivityDialogClick(Sender: TObject);
    procedure fgProgressDialogHide(Sender: TObject);
    procedure fgProgressDialogShow(Sender: TObject);
    procedure SwitchCancellableSwitch(Sender: TObject);
    procedure fgProgressDialogCancel(Sender: TObject);
    procedure fgActivityDialogCancel(Sender: TObject);
    procedure ComboBoxThemeChange(Sender: TObject);
    procedure fgActivityDialogHide(Sender: TObject);
    procedure fgActivityDialogShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure NumberBoxThemeIDChangeTracking(Sender: TObject);
  private
    FProgressDialogThread: TThread;
    FActivityDialogThread: TThread;
    procedure Log(const AMessage: string);
    procedure UpdateLayoutThemeIDVisible;
  end;

var
  FormMain: TFormMain;

implementation

uses
  System.Math;

{$R *.fmx}

procedure TFormMain.btnProgressDialogClick(Sender: TObject);
begin
  if not fgProgressDialog.IsShown then
  begin
    // Create separated thread for long operations
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
            fgProgressDialog.Progress := 900;
          end);
          Sleep(500);
          if TThread.CheckTerminated then
            Exit;

          TThread.Synchronize(nil, procedure
          begin
            fgProgressDialog.Progress := 1000;
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

procedure TFormMain.ComboBoxThemeChange(Sender: TObject);
begin
  if InRange(ComboBoxTheme.ItemIndex, 0, ComboBoxTheme.Items.Count - 1) then
  begin
    fgActivityDialog.Theme := TfgDialogTheme(ComboBoxTheme.ItemIndex);
    fgProgressDialog.Theme := TfgDialogTheme(ComboBoxTheme.ItemIndex);
  end;

  UpdateLayoutThemeIDVisible;
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
  Log('TfgActivityDialog.OnCancel');
  FActivityDialogThread.Terminate;
end;

procedure TFormMain.fgActivityDialogHide(Sender: TObject);
begin
  Log('TfgActivityDialog.OnHide');
end;

procedure TFormMain.fgActivityDialogShow(Sender: TObject);
begin
  Log('TfgActivityDialog.OnShow');
end;

procedure TFormMain.fgProgressDialogCancel(Sender: TObject);
begin
  Log('TfgProgressDialog.OnCancel');
  FProgressDialogThread.Terminate;
end;

procedure TFormMain.fgProgressDialogHide(Sender: TObject);
begin
  Log('TfgProgressDialog.OnHide');
end;

procedure TFormMain.fgProgressDialogShow(Sender: TObject);
begin
  Log('TfgProgressDialog.OnShow');
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  LabelError.Visible := not fgProgressDialog.Supported and not fgActivityDialog.Supported;
  SwitchCancellable.IsChecked := fgProgressDialog.Cancellable;

  UpdateLayoutThemeIDVisible;
end;

procedure TFormMain.Log(const AMessage: string);
begin
  MemoLog.Lines.Add(AMessage);
end;

procedure TFormMain.NumberBoxThemeIDChangeTracking(Sender: TObject);
begin
  fgActivityDialog.ThemeID := Round(NumberBoxThemeID.Value);
  fgProgressDialog.ThemeID := Round(NumberBoxThemeID.Value);
end;

procedure TFormMain.SwitchCancellableSwitch(Sender: TObject);
begin
  fgActivityDialog.Cancellable := SwitchCancellable.IsChecked;
  fgProgressDialog.Cancellable := SwitchCancellable.IsChecked;
end;

procedure TFormMain.UpdateLayoutThemeIDVisible;
begin
  LayoutThemeID.Visible := (TOSVersion.Platform = TOSVersion.TPlatform.pfAndroid)
    and (fgProgressDialog.Theme = TfgDialogTheme.Custom);
end;

end.
