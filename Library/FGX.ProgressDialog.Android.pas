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

 unit FGX.ProgressDialog.Android;

interface

uses
  AndroidApi.ProgressDialog, FGX.ProgressDialog, FGX.ProgressDialog.Types;

type

  { TAndroidProgressDialogService }

  TAndroidProgressDialogService = class(TInterfacedObject, IFGXProgressDialogService)
  public
    { IFGXProgressDialogService }
    function CreateNativeProgressDialog(const AOwner: TObject): TfgNativeProgressDialog;
    function CreateNativeActivityDialog(const AOwner: TObject): TfgNativeActivityDialog;
  end;

  TAndroidNativeActivityDialog = class(TfgNativeActivityDialog)
  private
    FID: Integer;
    FNativeDialog: JProgressDialog;
  protected
    procedure InitNativeDialog; virtual;
    { inherited }
    procedure TitleChanged; override;
    procedure MessageChanged; override;
  public
    constructor Create(const AOwner: TObject); override;
    destructor Destroy; override;
    procedure Show; override;
    procedure Hide; override;
    property ID: Integer read FID;
  end;

  TAndroidNativeProgressDialog = class (TfgNativeProgressDialog)
  private
    FID: Integer;
    FNativeDialog: JProgressDialog;
  protected
    function IsDialogKindDeterminated(const DialogKind: TfgProgressDialogKind): Boolean;
    procedure InitNativeDialog; virtual;
    { inherited }
    procedure TitleChanged; override;
    procedure KindChanged; override;
    procedure MessageChanged; override;
    procedure ProgressChanged; override;
  public
    constructor Create(const AOwner: TObject); override;
    destructor Destroy; override;
    procedure ResetProgress; override;
    procedure Show; override;
    procedure Hide; override;
    property ID: Integer read FID;
  end;

procedure RegisterService;

implementation

uses
  System.SysUtils, Androidapi.Helpers, FMX.Platform, FMX.Platform.Android, FMX.Helpers.Android, FMX.Types, FGX.Helpers,
  FGX.Helpers.Android, FGX.Asserts;

procedure RegisterService;
begin
  if TOSVersion.Check(2, 0) then
    TPlatformServices.Current.AddPlatformService(IFGXProgressDialogService, TAndroidProgressDialogService.Create);
end;

{ TAndroidProgressDialogService }

function TAndroidProgressDialogService.CreateNativeActivityDialog(const AOwner: TObject): TfgNativeActivityDialog;
begin
  Result := TAndroidNativeActivityDialog.Create(AOwner);
end;

function TAndroidProgressDialogService.CreateNativeProgressDialog(const AOwner: TObject): TfgNativeProgressDialog;
begin
  Result := TAndroidNativeProgressDialog.Create(AOwner);
end;

{ TAndroidNativeProgressDialog }

constructor TAndroidNativeActivityDialog.Create(const AOwner: TObject);
begin
  inherited Create(AOwner);
  FID := TfgGeneratorUniqueID.GenerateID;
  CallInUIThreadAndWaitFinishing(procedure begin
    FNativeDialog := TJProgressDialog.JavaClass.init(SharedActivityContext, GetNativeTheme);
  end);
end;

destructor TAndroidNativeActivityDialog.Destroy;
begin
  FNativeDialog := nil;
  inherited Destroy;
end;

procedure TAndroidNativeActivityDialog.Hide;
begin
  AssertIsNotNil(FNativeDialog);

  DoHide;
  CallInUIThread(procedure begin
    HideDialog(FNativeDialog, FID);
  end);
end;

procedure TAndroidNativeActivityDialog.InitNativeDialog;
begin
  AssertIsNotNil(FNativeDialog);

  FNativeDialog.setTitle(StrToJCharSequence(Title));
  FNativeDialog.setMessage(StrToJCharSequence(Message));
  FNativeDialog.setProgressStyle(TJProgressDialog.JavaClass.STYLE_SPINNER);
  FNativeDialog.setCanceledOnTouchOutside(False);
  FNativeDialog.setCancelable(False);
end;

procedure TAndroidNativeActivityDialog.MessageChanged;
begin
  AssertIsNotNil(FNativeDialog);

  CallInUIThread(procedure begin
    FNativeDialog.setMessage(StrToJCharSequence(Message));
  end);
end;

procedure TAndroidNativeActivityDialog.Show;
begin
  AssertIsNotNil(FNativeDialog);

  CallInUIThread(procedure begin
    InitNativeDialog;
    ShowDialog(FNativeDialog, FID);
  end);
  DoShow;
end;

procedure TAndroidNativeActivityDialog.TitleChanged;
begin
  AssertIsNotNil(FNativeDialog);

  CallInUIThread(procedure begin
    FNativeDialog.setTitle(StrToJCharSequence(Title));
  end);
end;

{ TAndroidNativeActivityDialog }

constructor TAndroidNativeProgressDialog.Create(const AOwner: TObject);
begin
  inherited Create(AOwner);
  FID := TfgGeneratorUniqueID.GenerateID;
  CallInUIThreadAndWaitFinishing(procedure begin
    FNativeDialog := TJProgressDialog.JavaClass.init(SharedActivityContext, GetNativeTheme);
  end);
end;

destructor TAndroidNativeProgressDialog.Destroy;
begin
  FNativeDialog := nil;
  inherited Destroy;
end;

procedure TAndroidNativeProgressDialog.Hide;
begin
  AssertIsNotNil(FNativeDialog);

  DoHide;
  CallInUIThread(procedure begin
    HideDialog(FNativeDialog, FID);
  end);
end;

procedure TAndroidNativeProgressDialog.InitNativeDialog;
begin
  AssertIsNotNil(FNativeDialog);

  FNativeDialog.setTitle(StrToJCharSequence(Title));
  FNativeDialog.setMessage(StrToJCharSequence(Message));
  FNativeDialog.setMax(100);
  FNativeDialog.setProgress(Round(Progress));
  FNativeDialog.setProgressStyle(TJProgressDialog.JavaClass.STYLE_HORIZONTAL);
  FNativeDialog.setIndeterminate(IsDialogKindDeterminated(Kind));
  FNativeDialog.setCanceledOnTouchOutside(False);
  FNativeDialog.setCancelable(False);
end;

function TAndroidNativeProgressDialog.IsDialogKindDeterminated(const DialogKind: TfgProgressDialogKind): Boolean;
begin
  Result := DialogKind = TfgProgressDialogKind.Undeterminated;
end;

procedure TAndroidNativeProgressDialog.KindChanged;
begin
  AssertIsNotNil(FNativeDialog);

  CallInUIThread(procedure begin
    FNativeDialog.setIndeterminate(IsDialogKindDeterminated(Kind));
  end);
end;

procedure TAndroidNativeProgressDialog.MessageChanged;
begin
  AssertIsNotNil(FNativeDialog);

  CallInUIThread(procedure begin
    FNativeDialog.setMessage(StrToJCharSequence(Message));
  end);
end;

procedure TAndroidNativeProgressDialog.ProgressChanged;
begin
  AssertIsNotNil(FNativeDialog);

  CallInUIThread(procedure begin
    FNativeDialog.setProgress(Round(Progress));
  end);
end;

procedure TAndroidNativeProgressDialog.ResetProgress;
begin
  AssertIsNotNil(FNativeDialog);

  inherited ResetProgress;
  CallInUIThread(procedure begin
    FNativeDialog.setProgress(0);
  end);
end;

procedure TAndroidNativeProgressDialog.Show;
begin
  AssertIsNotNil(FNativeDialog);

  CallInUIThread(procedure begin
    InitNativeDialog;
    ShowDialog(FNativeDialog, FID);
  end);
  DoShow;
end;

procedure TAndroidNativeProgressDialog.TitleChanged;
begin
  AssertIsNotNil(FNativeDialog);

  CallInUIThread(procedure begin
    FNativeDialog.setTitle(StrToJCharSequence(Title));
  end);
end;

end.
