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
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FGX.ActionSheet, FGX.ActionSheet.Types, FMX.StdCtrls,
  FMX.Layouts, System.Actions, FMX.ActnList, FMX.StdActns, FMX.MediaLibrary.Actions, FMX.Controls.Presentation;

type
  TFormMain = class(TForm)
    fgActionSheet: TfgActionSheet;
    Button1: TButton;
    SwitchUseUIGuildline: TSwitch;
    Label1: TLabel;
    Label2: TLabel;
    Layout1: TLayout;
    LabelError: TLabel;
    LabelLog: TLabel;
    ActionList: TActionList;
    ActionToSpam: TAction;
    TakePhotoFromCameraAction1: TTakePhotoFromCameraAction;
    TakePhotoFromLibraryAction1: TTakePhotoFromLibraryAction;
    Button2: TButton;
    EditVirtualKeyboard1: TVirtualKeyboard;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure fgActionSheetActions0Click(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

procedure TFormMain.Action1Execute(Sender: TObject);
begin
  LabelLog.Text := 'You click on To Inbox action';
end;

procedure TFormMain.Button1Click(Sender: TObject);
begin
  fgActionSheet.UseUIGuidline := SwitchUseUIGuildline.IsChecked;
  fgActionSheet.Show;
end;

procedure TFormMain.fgActionSheetActions0Click(Sender: TObject);
begin
  LabelLog.Text := Format('You click on "%s"', [(Sender as TfgActionCollectionItem).Caption]);
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  LabelError.Visible := not fgActionSheet.Supported;
end;

end.
