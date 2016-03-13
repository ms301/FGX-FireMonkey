program AnimationsDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainFrm in 'MainFrm.pas' {Form9};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm9, Form9);
  Application.Run;
end.
