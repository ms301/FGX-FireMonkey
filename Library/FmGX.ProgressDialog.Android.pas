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
    procedure RecreateNativeDialog; virtual;
    procedure InitNativeDialog; virtual;
    { inherited }
    procedure TitleChanged; override;
    procedure ThemeChanged; override;
    procedure ThemeIDChanged; override;
    procedure MessageChanged; override;
    procedure CancellableChanged; override;
    function GetIsShown: Boolean; override;
  public
    constructor Create(const AOwner: TObject); override;
    destructor Destroy; override;
    function IsNativeDialogCreated: Boolean;
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
    procedure RecreateNativeDialog; virtual;
    procedure InitNativeDialog; virtual;
    { inherited }
    procedure TitleChanged; override;
    procedure ThemeChanged; override;
    procedure ThemeIDChanged; override;
    procedure KindChanged; override;
    procedure MessageChanged; override;
    procedure ProgressChanged; override;
    procedure CancellableChanged; override;
    procedure RangeChanged; override;
    function GetIsShown: Boolean; override;
  public
    constructor Create(const AOwner: TObject); override;
    destructor Destroy; override;
    function IsNativeDialogCreated: Boolean;
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

type

  TfgDialogThemeHelper = record helper for TfgDialogTheme
  public
    function ToThemeID(const Context: TObject): Integer;
  end;

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
  inherited;

  if IsNativeDialogCreated then
    CallInUIThread(procedure begin
      FNativeDialog.setCancelable(Cancellable);
      FNativeDialog.setCanceledOnTouchOutside(Cancellable);
    end);
end;

constructor TAndroidNativeActivityDialog.Create(const AOwner: TObject);
begin
  inherited Create(AOwner);
  FID := TfgGeneratorUniqueID.GenerateID;
  FDialogListener := TDialogDismissListener.Create(Self);
end;

destructor TAndroidNativeActivityDialog.Destroy;
begin
  FNativeDialog := nil;
  FreeAndNil(FDialogListener);
  inherited Destroy;
end;

function TAndroidNativeActivityDialog.GetIsShown: Boolean;
begin
  Result := IsNativeDialogCreated and FNativeDialog.isShowing;
end;

procedure TAndroidNativeActivityDialog.Hide;
begin
  inherited;
  if FNativeDialog <> nil then
  begin
    DoHide;
    CallInUIThread(procedure begin
      HideDialog(FNativeDialog, FID);
    end);
  end;
end;

procedure TAndroidNativeActivityDialog.InitNativeDialog;
begin
  TfgAssert.IsNotNil(FNativeDialog);

  FNativeDialog.setTitle(StrToJCharSequence(Title));
  FNativeDialog.setMessage(StrToJCharSequence(Message));
  FNativeDialog.setProgressStyle(TJProgressDialog.JavaClass.STYLE_SPINNER);
  FNativeDialog.setCanceledOnTouchOutside(Cancellable);
  FNativeDialog.setCancelable(Cancellable);
  FNativeDialog.setOnCancelListener(FDialogListener);
end;

function TAndroidNativeActivityDialog.IsNativeDialogCreated: Boolean;
begin
  Result := FNativeDialog <> nil;
end;

procedure TAndroidNativeActivityDialog.MessageChanged;
begin
  inherited;

  if IsNativeDialogCreated then
    CallInUIThread(procedure begin
      FNativeDialog.setMessage(StrToJCharSequence(Message));
    end);
end;

procedure TAndroidNativeActivityDialog.RecreateNativeDialog;
var
  LThemeID: Integer;
begin
  if IsNativeDialogCreated then
    FNativeDialog.setOnCancelListener(nil)
  else
    FNativeDialog := nil;

  if (Theme = TfgDialogTheme.Custom) and (ThemeID <> UndefinedThemeID) then
    LThemeID := ThemeID
  else
    LThemeID := Theme.ToThemeID(Owner);

  CallInUIThreadAndWaitFinishing(procedure begin
    FNativeDialog := TJProgressDialog.JavaClass.init(TAndroidHelper.Context, LThemeID);
  end);
end;

procedure TAndroidNativeActivityDialog.Show;
begin
  inherited;

  if FNativeDialog = nil then
    RecreateNativeDialog;

  CallInUIThread(procedure begin
    InitNativeDialog;
    ShowDialog(FNativeDialog, FID);
  end);
  DoShow;
end;

procedure TAndroidNativeActivityDialog.ThemeChanged;
begin
  inherited;

  if not IsShown then
    RecreateNativeDialog;
end;

procedure TAndroidNativeActivityDialog.ThemeIDChanged;
begin
  inherited;

  if not IsShown and (Theme = TfgDialogTheme.Custom) then
    RecreateNativeDialog;
end;

procedure TAndroidNativeActivityDialog.TitleChanged;
begin
  inherited;

  if IsNativeDialogCreated then
    CallInUIThread(procedure begin
      FNativeDialog.setTitle(StrToJCharSequence(Title));
    end);
end;

{ TAndroidNativeActivityDialog }

procedure TAndroidNativeProgressDialog.CancellableChanged;
begin
  if IsNativeDialogCreated then
    CallInUIThread(procedure begin
      FNativeDialog.setCancelable(Cancellable);
      FNativeDialog.setCanceledOnTouchOutside(Cancellable);
    end);
end;

constructor TAndroidNativeProgressDialog.Create(const AOwner: TObject);
begin
  inherited Create(AOwner);
  FID := TfgGeneratorUniqueID.GenerateID;
  FDialogListener := TDialogDismissListener.Create(Self);
end;

destructor TAndroidNativeProgressDialog.Destroy;
begin
  FNativeDialog := nil;
  FreeAndNil(FDialogListener);
  inherited Destroy;
end;

function TAndroidNativeProgressDialog.GetIsShown: Boolean;
begin
  Result := IsNativeDialogCreated and FNativeDialog.isShowing;
end;

procedure TAndroidNativeProgressDialog.Hide;
begin
  inherited;

  if FNativeDialog <> nil then
  begin
    DoHide;
    CallInUIThread(procedure begin
      HideDialog(FNativeDialog, FID);
    end);
  end;
end;

procedure TAndroidNativeProgressDialog.InitNativeDialog;
begin
  TfgAssert.IsNotNil(FNativeDialog);

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

function TAndroidNativeProgressDialog.IsNativeDialogCreated: Boolean;
begin
  Result := FNativeDialog <> nil;
end;

procedure TAndroidNativeProgressDialog.KindChanged;
begin
  inherited;

  if IsNativeDialogCreated then
    CallInUIThread(procedure begin
      FNativeDialog.setIndeterminate(IsDialogKindDeterminated(Kind));
    end);
end;

procedure TAndroidNativeProgressDialog.MessageChanged;
begin
  inherited;

  if IsNativeDialogCreated then
    CallInUIThread(procedure begin
      FNativeDialog.setMessage(StrToJCharSequence(Message));
    end);
end;

procedure TAndroidNativeProgressDialog.ProgressChanged;
begin
  inherited;

  if IsNativeDialogCreated then
    CallInUIThread(procedure begin
      FNativeDialog.setProgress(Round(Progress));
    end);
end;

procedure TAndroidNativeProgressDialog.RangeChanged;
begin
  inherited;

  if IsNativeDialogCreated then
    CallInUIThread(procedure begin
      FNativeDialog.setMax(Round(Max));
    end);
end;

procedure TAndroidNativeProgressDialog.RecreateNativeDialog;
var
  LThemeID: Integer;
begin
  if IsNativeDialogCreated then
    FNativeDialog.setOnCancelListener(nil)
  else
    FNativeDialog := nil;
  
  if (Theme = TfgDialogTheme.Custom) and (ThemeID <> UndefinedThemeID) then
    LThemeID := ThemeID
  else
    LThemeID := Theme.ToThemeID(Owner);

  CallInUIThreadAndWaitFinishing(procedure begin
    FNativeDialog := TJProgressDialog.JavaClass.init(TAndroidHelper.Context, LThemeID);
  end);
end;

procedure TAndroidNativeProgressDialog.ResetProgress;
begin
  inherited;

  if IsNativeDialogCreated then
    CallInUIThread(procedure begin
      FNativeDialog.setProgress(0);
    end);
end;

procedure TAndroidNativeProgressDialog.Show;
begin
  inherited;

  if FNativeDialog = nil then
    RecreateNativeDialog;

  CallInUIThread(procedure begin
    InitNativeDialog;
    ShowDialog(FNativeDialog, FID);
  end);
  DoShow;
end;

procedure TAndroidNativeProgressDialog.ThemeChanged;
begin
  inherited;

  if not IsShown then
    RecreateNativeDialog;
end;

procedure TAndroidNativeProgressDialog.ThemeIDChanged;
begin
  inherited;

  if not IsShown and (Theme = TfgDialogTheme.Custom) then
    RecreateNativeDialog;
end;

procedure TAndroidNativeProgressDialog.TitleChanged;
begin
  inherited;

  if IsNativeDialogCreated then
    CallInUIThread(procedure begin
      FNativeDialog.setTitle(StrToJCharSequence(Title));
    end);
end;

{ TDialogDismissListener }

constructor TDialogDismissListener.Create(const ADialog: TfgNativeDialog);
begin
  TfgAssert.IsNotNil(ADialog);

  inherited Create;
  FDialog := ADialog;
end;

procedure TDialogDismissListener.onCancel(dialog: JDialogInterface);
begin
  TfgAssert.IsNotNil(FDialog);

  TThread.Synchronize(nil, procedure
    begin
      if Assigned(FDialog.OnCancel) then
        FDialog.OnCancel(FDialog.Owner);
    end);
end;

{ TfgDialogThemeHelper }

function TfgDialogThemeHelper.ToThemeID(const Context: TObject): Integer;
var
  ThemeID: Integer;
begin
  case Self of
    TfgDialogTheme.Auto:
      ThemeID := GetNativeTheme(Context);
    TfgDialogTheme.Dark:
      ThemeID := TJAlertDialog.JavaClass.THEME_HOLO_DARK;
    TfgDialogTheme.Light:
      ThemeID := TJAlertDialog.JavaClass.THEME_HOLO_LIGHT;
  else
    ThemeID := GetNativeTheme(Context);
  end;

  Result := ThemeID;
end;

end.
