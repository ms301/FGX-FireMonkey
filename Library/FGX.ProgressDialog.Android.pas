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
  AndroidApi.ProgressDialog, AndroidApi.JNIBridge, Androidapi.JNI.GraphicsContentViewText,
  FGX.ProgressDialog, FGX.ProgressDialog.Types;

type

  { TAndroidProgressDialogService }

  TAndroidProgressDialogService = class(TInterfacedObject, IFGXProgressDialogService)
  public
    { IFGXProgressDialogService }
    function CreateNativeProgressDialog(const AOwner: TObject): TfgNativeProgressDialog;
    function CreateNativeActivityDialog(const AOwner: TObject): TfgNativeActivityDialog;
  end;

  TDialogDismissListener = class;

  TAndroidNativeActivityDialog = class(TfgNativeActivityDialog)
  private
    FID: Integer;
    FNativeDialog: JProgressDialog;
    FDialogListener: TDialogDismissListener;
  protected
    procedure InitNativeDialog; virtual;
    { inherited }
    procedure TitleChanged; override;
    procedure MessageChanged; override;
    procedure CancellableChanged; override;
    function GetIsShown: Boolean; override;
  public
    constructor Create(const AOwner: TObject); override;
    destructor Destroy; override;
    procedure Show; override;
    procedure Hide; override;
    property ID: Integer read FID;
  end;

  TAndroidNativeProgressDialog = class(TfgNativeProgressDialog)
  private
    FID: Integer;
    FNativeDialog: JProgressDialog;
    FDialogListener: TDialogDismissListener;
  protected
    function IsDialogKindDeterminated(const DialogKind: TfgProgressDialogKind): Boolean;
    procedure InitNativeDialog; virtual;
    { inherited }
    procedure TitleChanged; override;
    procedure KindChanged; override;
    procedure MessageChanged; override;
    procedure ProgressChanged; override;
    procedure CancellableChanged; override;
    procedure RangeChanged; override;
    function GetIsShown: Boolean; override;
  public
    constructor Create(const AOwner: TObject); override;
    destructor Destroy; override;
    procedure ResetProgress; override;
    procedure Show; override;
    procedure Hide; override;
    property ID: Integer read FID;
  end;

  TDialogDismissListener = class(TJavaLocal, JDialogInterface_OnCancelListener)
  private
    [Weak] FDialog: TfgNativeDialog;
  public
    constructor Create(const ADialog: TfgNativeDialog);
    { JDialogInterface_OnCancelListener }
    procedure onCancel(dialog: JDialogInterface); cdecl;
  end;

procedure RegisterService;
procedure UnregisterService;

implementation

uses
  System.SysUtils, System.Classes, Androidapi.Helpers, AndroidApi.JNI.JavaTypes, Androidapi.JNI.App, FMX.Platform,
  FMX.Platform.Android, FMX.Helpers.Android, FMX.Types, FGX.Helpers, FGX.Helpers.Android, FGX.Asserts;

procedure RegisterService;
begin
  if TOSVersion.Check(2, 0) then
    TPlatformServices.Current.AddPlatformService(IFGXProgressDialogService, TAndroidProgressDialogService.Create);
end;

procedure UnregisterService;
begin
  TPlatformServices.Current.RemovePlatformService(IFGXProgressDialogService);
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

procedure TAndroidNativeActivityDialog.CancellableChanged;
begin
  AssertIsNotNil(FNativeDialog);

  CallInUIThread(procedure begin
    FNativeDialog.setCancelable(Cancellable);
    FNativeDialog.setCanceledOnTouchOutside(Cancellable);
  end);
end;

constructor TAndroidNativeActivityDialog.Create(const AOwner: TObject);
var
  ThemeID: Integer;
begin
  inherited Create(AOwner);
  FID := TfgGeneratorUniqueID.GenerateID;
  FDialogListener := TDialogDismissListener.Create(Self);
  ThemeID := GetNativeTheme(AOwner);
  CallInUIThreadAndWaitFinishing(procedure begin
    FNativeDialog := TJProgressDialog.JavaClass.init(TAndroidHelper.Context, ThemeID);
  end);
end;

destructor TAndroidNativeActivityDialog.Destroy;
begin
  FNativeDialog := nil;
  FreeAndNil(FDialogListener);
  inherited Destroy;
end;

function TAndroidNativeActivityDialog.GetIsShown: Boolean;
begin
  Result := FNativeDialog.isShowing;
end;

procedure TAndroidNativeActivityDialog.Hide;
begin
  AssertIsNotNil(FNativeDialog);

  inherited;

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
  FNativeDialog.setCanceledOnTouchOutside(Cancellable);
  FNativeDialog.setCancelable(Cancellable);
  FNativeDialog.setOnCancelListener(FDialogListener);
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

  inherited;
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

procedure TAndroidNativeProgressDialog.CancellableChanged;
begin
  AssertIsNotNil(FNativeDialog);

  CallInUIThread(procedure begin
    FNativeDialog.setCancelable(Cancellable);
    FNativeDialog.setCanceledOnTouchOutside(Cancellable);
  end);
end;

constructor TAndroidNativeProgressDialog.Create(const AOwner: TObject);
var
  ThemeID: Integer;
begin
  inherited Create(AOwner);
  FID := TfgGeneratorUniqueID.GenerateID;
  FDialogListener := TDialogDismissListener.Create(Self);
  ThemeID := GetNativeTheme(AOwner);
  CallInUIThreadAndWaitFinishing(procedure begin
    FNativeDialog := TJProgressDialog.JavaClass.init(TAndroidHelper.Context, ThemeID);
  end);
end;

destructor TAndroidNativeProgressDialog.Destroy;
begin
  FNativeDialog := nil;
  FreeAndNil(FDialogListener);
  inherited Destroy;
end;

function TAndroidNativeProgressDialog.GetIsShown: Boolean;
begin
  Result := FNativeDialog.isShowing;
end;

procedure TAndroidNativeProgressDialog.Hide;
begin
  AssertIsNotNil(FNativeDialog);

  inherited;

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
  FNativeDialog.setMax(Round(Max));
  FNativeDialog.setProgress(Round(Progress));
  FNativeDialog.setProgressStyle(TJProgressDialog.JavaClass.STYLE_HORIZONTAL);
  FNativeDialog.setIndeterminate(IsDialogKindDeterminated(Kind));
  FNativeDialog.setCanceledOnTouchOutside(Cancellable);
  FNativeDialog.setCancelable(Cancellable);
  FNativeDialog.setOnCancelListener(FDialogListener);
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

procedure TAndroidNativeProgressDialog.RangeChanged;
begin
  AssertIsNotNil(FNativeDialog);

  inherited RangeChanged;
  CallInUIThread(procedure begin
    FNativeDialog.setMax(Round(Max));
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

  inherited;

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

{ TDialogDismissListener }

constructor TDialogDismissListener.Create(const ADialog: TfgNativeDialog);
begin
  AssertIsNotNil(ADialog);

  inherited Create;
  FDialog := ADialog;
end;

procedure TDialogDismissListener.onCancel(dialog: JDialogInterface);
begin
  AssertIsNotNil(FDialog);

  TThread.Synchronize(nil, procedure
    begin
      if Assigned(FDialog.OnCancel) then
        FDialog.OnCancel(FDialog.Owner);
    end);
end;

end.
