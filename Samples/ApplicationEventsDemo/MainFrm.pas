unit MainFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Platform,
  FGX.ApplicationEvents, FMX.Layouts, FMX.Memo, FMX.StdCtrls, FMX.MultiView;

type
  TFormMain = class(TForm)
    fgApplicationEvents: TfgApplicationEvents;
    mmLog: TMemo;
    MultiView: TMultiView;
    cbOnIdle: TCheckBox;
    GroupBox: TGroupBox;
    cbOnActionExecute: TCheckBox;
    cbOnActionUpdate: TCheckBox;
    cbOnException: TCheckBox;
    cbOnOrientationChanged: TCheckBox;
    cbOnStateChanged: TCheckBox;
    BtnClearLog: TButton;
    procedure fgApplicationEventsActionExecute(Action: TBasicAction; var Handled: Boolean);
    procedure fgApplicationEventsActionUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure fgApplicationEventsException(Sender: TObject; E: Exception);
    procedure fgApplicationEventsIdle(Sender: TObject; var Done: Boolean);
    procedure fgApplicationEventsOrientationChanged(const AOrientation: TScreenOrientation);
    function fgApplicationEventsStateChange(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
    procedure BtnClearLogClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

procedure TFormMain.BtnClearLogClick(Sender: TObject);
begin
  mmLog.Lines.Clear;
end;

procedure TFormMain.fgApplicationEventsActionExecute(Action: TBasicAction; var Handled: Boolean);
begin
  if cbOnActionExecute.IsChecked then
    mmLog.Lines.Add(Format('%s: OnActionExecute', [TimeToStr(Now)]));
end;

procedure TFormMain.fgApplicationEventsActionUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  if cbOnActionUpdate.IsChecked then
    mmLog.Lines.Add(Format('%s: OnActionUpdate', [TimeToStr(Now)]));
end;

procedure TFormMain.fgApplicationEventsException(Sender: TObject; E: Exception);
begin
  if cbOnException.IsChecked then
    mmLog.Lines.Add(Format('%s: OnException', [TimeToStr(Now)]));
end;

procedure TFormMain.fgApplicationEventsIdle(Sender: TObject; var Done: Boolean);
begin
  if cbOnIdle.IsChecked then
    mmLog.Lines.Add(Format('%s: OnIdle', [TimeToStr(Now)]));
end;

procedure TFormMain.fgApplicationEventsOrientationChanged(const AOrientation: TScreenOrientation);
var
  OrientationText: string;
begin
  if cbOnOrientationChanged.IsChecked then
  begin
    case AOrientation of
      TScreenOrientation.Portrait: OrientationText := 'Portrait';
      TScreenOrientation.Landscape: OrientationText := 'Landscape';
      TScreenOrientation.InvertedPortrait: OrientationText := 'InvertedPortrait';
      TScreenOrientation.InvertedLandscape: OrientationText := 'InvertedLandscape';
    end;
    mmLog.Lines.Add(Format('%s: OnOrientationChanged=%s', [TimeToStr(Now), OrientationText]));
  end;
end;

function TFormMain.fgApplicationEventsStateChange(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
var
  StateText: string;
begin
  if cbOnStateChanged.IsChecked then
  begin
    case AAppEvent of
      TApplicationEvent.FinishedLaunching: StateText := 'FinishedLaunching';
      TApplicationEvent.BecameActive: StateText := 'BecameActive';
      TApplicationEvent.WillBecomeInactive: StateText := 'WillBecomeInactive';
      TApplicationEvent.EnteredBackground: StateText := 'EnteredBackground';
      TApplicationEvent.WillBecomeForeground: StateText := 'WillBecomeForeground';
      TApplicationEvent.WillTerminate: StateText := 'WillTerminate';
      TApplicationEvent.LowMemory: StateText := 'LowMemory';
      TApplicationEvent.TimeChange: StateText := 'TimeChange';
      TApplicationEvent.OpenURL: StateText := 'OpenURL';
    end;
    mmLog.Lines.Add(Format('%s: OnApplicationEventsStateChanged=%s', [TimeToStr(Now), StateText]));
 end;
  Result := True;
end;

end.
