unit ChildFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts;

type
  TFormChild = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Layout1: TLayout;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormChild: TFormChild;

implementation

{$R *.fmx}

procedure TFormChild.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TFormChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FormChild := nil;
end;

end.
