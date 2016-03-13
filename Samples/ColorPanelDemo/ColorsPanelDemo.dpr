program ColorsPanelDemo;

uses
  FMX.Forms,
  MainFrm in 'MainFrm.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
