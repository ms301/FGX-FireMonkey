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

unit FGX.ProgressDialog.Win;

interface

uses
  Winapi.ShlObj, Winapi.ActiveX, FGX.ProgressDialog.Types;


type

  { TWunProgressDialogService }

  TWunProgressDialogService = class (TInterfacedObject, IFGXProgressDialogService)
  public
    { IFGXProgressDialogService }
    function CreateNativeProgressDialog(const AOwner: TObject): TfgNativeProgressDialog;
    function CreateNativeActivityDialog(const AOwner: TObject): TfgNativeActivityDialog;
  end;

  TWinNativeProgressDialog = class (TfgNativeProgressDialog)
  private
    FNativeDialog: IProgressDialog;
  protected
    procedure ProgressChanged; override;
    procedure TitleChanged; override;
    procedure MessageChanged; override;
  public
    constructor Create(const AOwner: TObject); override;
    destructor Destroy; override;
    procedure ResetProgress; override;

    procedure Show; override;
    procedure Hide; override;
  end;

procedure RegisterService;

var
  ProgressDialogService: TWunProgressDialogService;

implementation

uses
  System.SysUtils, FMX.Platform, FMX.Types, FMX.Forms, FMX.Platform.Win,
  Winapi.Windows;

{ TWunProgressDialogService }

function TWunProgressDialogService.CreateNativeActivityDialog(const AOwner: TObject): TfgNativeActivityDialog;
begin
  Result := nil;
end;

function TWunProgressDialogService.CreateNativeProgressDialog(const AOwner: TObject): TfgNativeProgressDialog;
begin
  Result := TWinNativeProgressDialog.Create(AOwner);
end;

{ TWinNativeProgressDialog }

constructor TWinNativeProgressDialog.Create(const AOwner: TObject);
begin
  inherited;
  if S_OK <> CoCreateInstance(CLSID_ProgressDialog, nil, CLSCTX_INPROC_SERVER, IID_IProgressDialog, FNativeDialog) then
    raise Exception.Create('Ќевозможно создать нативный диалог');
end;

destructor TWinNativeProgressDialog.Destroy;
begin
  FNativeDialog := nil;
  inherited Destroy;
end;

procedure TWinNativeProgressDialog.Hide;
begin
  FNativeDialog.StopProgressDialog;
end;

procedure TWinNativeProgressDialog.MessageChanged;
begin
  FNativeDialog.SetLine(1, StringToOleStr(Message), False, nil);
end;

procedure TWinNativeProgressDialog.ProgressChanged;
begin
  FNativeDialog.SetProgress(Cardinal(Round(Progress)), 100);
end;

procedure TWinNativeProgressDialog.ResetProgress;
begin
  inherited ResetProgress;
  FNativeDialog.SetProgress(0, 100);
end;

procedure TWinNativeProgressDialog.Show;
var
  WindowsHandle: HWND;
  REs: HRESULT;
begin
  Assert(Screen.ActiveForm <> nil);
  Assert(Screen.ActiveForm.Handle <> nil);

  FNativeDialog.SetTitle(StringToOleStr(Title));
  FNativeDialog.SetProgress(Cardinal(Round(Progress)), 100);
  FNativeDialog.SetLine(1, StringToOleStr(Message), False, nil);

  WindowsHandle := WindowHandleToPlatform(Screen.ActiveForm.Handle).Wnd;
  FNativeDialog.StartProgressDialog(WindowsHandle, nil, PROGDLG_MODAL or PROGDLG_AUTOTIME or PROGDLG_NOCANCEL, nil);
  Application.ProcessMessages;
end;

procedure TWinNativeProgressDialog.TitleChanged;
begin
  inherited;

end;

procedure RegisterService;
begin
  if TOSVersion.Check(2, 0) then
  begin
    ProgressDialogService := TWunProgressDialogService.Create;
    TPlatformServices.Current.AddPlatformService(IFGXProgressDialogService, ProgressDialogService);
  end;
end;

end.
