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
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FGX.LinkedLabel, FMX.Edit,
  FMX.Controls.Presentation;

type
  TForm1 = class(TForm)
    PanelSettings: TPanel;
    gbCommonSettings: TGroupBox;
    Label1: TLabel;
    edURI: TEdit;
    Label2: TLabel;
    edCaption: TEdit;
    cbVisited: TCheckBox;
    fgLinkedLabel: TfgLinkedLabel;
    procedure edURIChangeTracking(Sender: TObject);
    procedure edCaptionChangeTracking(Sender: TObject);
    procedure cbVisitedChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.cbVisitedChange(Sender: TObject);
begin
  fgLinkedLabel.Visited := cbVisited.IsChecked;
end;

procedure TForm1.edCaptionChangeTracking(Sender: TObject);
begin
  fgLinkedLabel.Text := edCaption.Text;
end;

procedure TForm1.edURIChangeTracking(Sender: TObject);
begin
  fgLinkedLabel.Url := edURI.Text;
end;

end.
