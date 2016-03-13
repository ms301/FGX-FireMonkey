program ApplicationEventsDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainFrm in 'MainFrm.pas' {FormMain},
  ChildFrm in 'ChildFrm.pas' {FormChild};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
