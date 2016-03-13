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
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.Layouts, FMX.Memo, FMX.Edit,
  FGX.VirtualKeyboard, FMX.Controls.Presentation, FMX.ScrollBox;

type
  TFormMain = class(TForm)
    fgVirtualKeyboard: TfgVirtualKeyboard;
    Edit1: TEdit;
    MemoLog: TMemo;
    LayoutMain: TLayout;
    procedure fgVirtualKeyboardHide(Sender: TObject; const Bounds: TRect);
    procedure fgVirtualKeyboardShow(Sender: TObject; const Bounds: TRect);
    procedure fgVirtualKeyboardSizeChanged(Sender: TObject; const Bounds: TRect);
    procedure fgVirtualKeyboard1Buttons0Click(Sender: TObject);
  private
    procedure WriteRect(const AMessage: string; const Bounds: TRect);
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

procedure TFormMain.fgVirtualKeyboard1Buttons0Click(Sender: TObject);
begin
  MemoLog.Lines.Add(Sender.ClassName);
end;

procedure TFormMain.fgVirtualKeyboardHide(Sender: TObject; const Bounds: TRect);
begin
  WriteRect('Keyboard is hidden', Bounds);
  LayoutMain.Align := TAlignLayout.Client;
end;

procedure TFormMain.fgVirtualKeyboardShow(Sender: TObject; const Bounds: TRect);
begin
  WriteRect('Keyboard is shown', Bounds);
  LayoutMain.Align := TAlignLayout.Top;
  if BorderStyle <> TFmxFormBorderStyle.None then
    LayoutMain.Height := Screen.Size.Height - Bounds.Height
  else
    LayoutMain.Height := Screen.Size.Height - Bounds.Height - 20;
end;

procedure TFormMain.fgVirtualKeyboardSizeChanged(Sender: TObject; const Bounds: TRect);
begin
  WriteRect('Keyboard changes size', Bounds);
end;

procedure TFormMain.WriteRect(const AMessage: string; const Bounds: TRect);
begin
  MemoLog.Lines.Add(AMessage);
  MemoLog.Lines.Add(Format('  Position=(%d, %d)', [Bounds.Left, Bounds.Top]));
  MemoLog.Lines.Add(Format('  Size=(%d, %d)', [Bounds.Width, Bounds.Height]));
  MemoLog.Lines.Add('------------------------------');
end;

end.
