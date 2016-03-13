program FlipViewDemo;





{$R *.dres}

uses
  FMX.Forms,
  MainFrm in 'MainFrm.pas' {FormMain};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
