unit MainFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FGX.GradientEdit, FMX.Colors;

type
  TFormMain = class(TForm)
    FMXGradientEdit: TGradientEdit;
    fgGradientEdit: TfgGradientEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

end.
