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

unit FmGX.ProgressDialog;

interface

uses
  System.Classes, FmGX.ProgressDialog.Types, FmGX.Consts;

type

  /// <summary>
  ///   Generic Abstract base class provide base functionality for creation and using progress/activity dialog.
  ///   Each dialog has Message and Title and holds instance of wrapper native dialog.
  /// </summary>
  TfgxCustomDialog<T: TfgNativeDialog> = class abstract(TComponent)
  public const
    DefaultCancellable = False;
    DefaultTheme = TfgDialogTheme.Auto;
    DefaultThemeID = TfgNativeDialog.UndefinedThemeID;
  private
    FNativeDialog: T;
    FTitle: string;
    FMessage: string;
    FCancellable: Boolean;
    FTheme: TfgDialogTheme;
    FThemeID: Integer;
    FOnShow: TNotifyEvent;
    FOnHide: TNotifyEvent;
    FOnCancel: TNotifyEvent;
    procedure SetCancellabel(const Value: Boolean);
    procedure SetMessage(const Value: string);
    procedure SetTitle(const Value: string);
    procedure SetTheme(const Value: TfgDialogTheme);
    procedure SetThemeID(const Value: Integer);
    procedure SetOnCancel(const Value: TNotifyEvent);
    procedure SetOnHide(const Value: TNotifyEvent);
    procedure SetOnShow(const Value: TNotifyEvent);
  protected
    /// <summary>
    ///   Returning a instance of wrapper native dialog. You should override this method for using custom native dialog.
    /// </summary>
    function CreateNativeDialog: T; virtual; abstract;
    /// <summary>
    ///   Way for perform additional initialization before showing dialog
    /// </summary>
    procedure DoInitDialog; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    /// <summary>
    ///   Return Does current platform has implementation of native dialog or not
    /// </summary>
    function Supported: Boolean;
    procedure Show; virtual;
    procedure Hide; virtual;
    function IsShown: Boolean;
    property NativeDialog: T read FNativeDialog;
  public
    property Cancellable: Boolean read FCancellable write SetCancellabel default DefaultCancellable;
    property Message: string read FMessage write SetMessage;
    property Title: string read FTitle write SetTitle;
    property Theme: TfgDialogTheme read FTheme write SetTheme default DefaultTheme;
    property ThemeID: Integer read FThemeID write SetThemeID default DefaultThemeID;
    property OnCancel: TNotifyEvent read FOnCancel write SetOnCancel;
    property OnShow: TNotifyEvent read FOnShow write SetOnShow;
    property OnHide: TNotifyEvent read FOnHide write SetOnHide;
  end;

  { TfgActivityDialog }

  TfgxCustomActivityDialog = class(TfgxCustomDialog<TfgNativeActivityDialog>)
  protected
    function CreateNativeDialog: TfgNativeActivityDialog; override;
  end;

  /// <summary>
  ///   Native Modal dialog with activity indicator, title and message
  /// </summary>
  [ComponentPlatformsAttribute(fgMobilePlatforms)]
  TfgxActivityDialog = class(TfgxCustomActivityDialog)
  published
    property Cancellable;
    property Message;
    property Title;
    property Theme;
    property ThemeID;
    property OnCancel;
    property OnShow;
    property OnHide;
  end;

  { TfgProgressDialog }

  TfgxCustomProgressDialog = class(TfgxCustomDialog<TfgNativeProgressDialog>)
  public const
    DefaultKind = TfgProgressDialogKind.Determinated;
    DefaultMax = 100;
  private
    FKind: TfgProgressDialogKind;
    FProgress: Single;
    FMax: Single;
    procedure SetKind(const Value: TfgProgressDialogKind);
    procedure SetMax(const Value: Single);
    procedure SetProgress(const Value: Single);
  protected
    { inherited }
    function CreateNativeDialog: TfgNativeProgressDialog; override;
    procedure DoInitDialog; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ResetProgress;
  public
    property Kind: TfgProgressDialogKind read FKind write SetKind default DefaultKind;
    property Max: Single read FMax write SetMax;
    /// <summary>
    ///    Current progress value of dialog in range [0..100]. When dialog is displayed, progress will set with animation
    /// </summary>
    property Progress: Single read FProgress write SetProgress;
  end;

  /// <summary>
  ///   <para>
  ///     Native Modal dialog with progress bar, title and message
  ///   </para>
  ///   <note type="note">
  ///     <list type="table">
  ///       <item>
  ///         <term>iOS</term>
  ///         <description>Doesn't support <see cref="TfgProgressDialog.Kind">Kind</see> property and
  ///         <see cref="TfgProgressDialog.Kind">OnCancel</see></description>
  ///       </item>
  ///       <item>
  ///         <term>Android</term>
  ///         <description>All property is supported</description>
  ///       </item>
  ///     </list>
  ///   </note>
  /// </summary>
  [ComponentPlatformsAttribute(fgMobilePlatforms)]
  TfgxProgressDialog = class(TfgxCustomProgressDialog)
  published
    property Cancellable;
    property Kind;
    property Message;
    property Max;
    property Progress;
    property Title;
    property Theme;
    property ThemeID;
    property OnCancel;
    property OnShow;
    property OnHide;
  end;

implementation

uses
  System.Math, System.SysUtils, FMX.Types, FMX.Platform, FmGX.Helpers, FmGX.Asserts
{$IFDEF IOS}
   , FGX.ProgressDialog.iOS
{$ENDIF}
{$IFDEF ANDROID}
   , FGX.ProgressDialog.Android
{$ENDIF}
;

{ TfgCustomProgressDialog }

constructor TfgxCustomDialog<T>.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTheme := DefaultTheme;
  FThemeID := DefaultThemeID;
  FCancellable := DefaultCancellable;
  FNativeDialog := CreateNativeDialog;
end;

destructor TfgxCustomDialog<T>.Destroy;
begin
  FreeAndNil(FNativeDialog);
  inherited Destroy;
end;

procedure TfgxCustomDialog<T>.DoInitDialog;
begin
  TfgxAssert.IsNotNil(FNativeDialog);

  FNativeDialog.Cancellable := Cancellable;
  FNativeDialog.Message := Message;
  FNativeDialog.Title := Title;
  FNativeDialog.Theme := Theme;
  FNativeDialog.ThemeID := ThemeID;
  FNativeDialog.OnCancel := OnCancel;
  FNativeDialog.OnShow := OnShow;
  FNativeDialog.OnHide := OnHide;
end;

procedure TfgxCustomDialog<T>.Hide;
begin
  if Supported then
    FNativeDialog.Hide;
end;

function TfgxCustomDialog<T>.IsShown: Boolean;
begin
  if Supported then
    Result := NativeDialog.IsShown
  else
    Result := False;
end;

procedure TfgxCustomDialog<T>.SetCancellabel(const Value: Boolean);
begin
  if Cancellable <> Value then
  begin
    FCancellable := Value;
    if Supported then
      FNativeDialog.Cancellable := Cancellable;
  end;
end;

procedure TfgxCustomDialog<T>.SetMessage(const Value: string);
begin
  if Message <> Value then
  begin
    FMessage := Value;
    if Supported then
      FNativeDialog.Message := Message;
  end;
end;

procedure TfgxCustomDialog<T>.SetOnCancel(const Value: TNotifyEvent);
begin
  FOnCancel := Value;
  if Supported then
    FNativeDialog.OnCancel := FOnCancel;
end;

procedure TfgxCustomDialog<T>.SetOnHide(const Value: TNotifyEvent);
begin
  FOnHide := Value;
  if Supported then
    FNativeDialog.OnHide := FOnHide;
end;

procedure TfgxCustomDialog<T>.SetOnShow(const Value: TNotifyEvent);
begin
  FOnShow := Value;
  if Supported then
    FNativeDialog.OnShow := FOnShow;
end;

procedure TfgxCustomDialog<T>.SetTheme(const Value: TfgDialogTheme);
begin
  if Theme <> Value then
  begin
    FTheme := Value;
    if Supported then
      FNativeDialog.Theme := Theme;
  end;
end;

procedure TfgxCustomDialog<T>.SetThemeID(const Value: Integer);
begin
  if ThemeID <> Value then
  begin
    FThemeID := Value;
    if Supported then
      FNativeDialog.ThemeID := ThemeID;
  end;
end;

procedure TfgxCustomDialog<T>.SetTitle(const Value: string);
begin
  if Title <> Value then
  begin
    FTitle := Value;
    if Supported then
      FNativeDialog.Title := Title;
  end;
end;

procedure TfgxCustomDialog<T>.Show;
begin
  if Supported then
  begin
    DoInitDialog;
    FNativeDialog.Show;
  end;
end;

function TfgxCustomDialog<T>.Supported: Boolean;
begin
  Result := FNativeDialog <> nil;
end;

{ TfgCustomActivityDialog }

function TfgxCustomActivityDialog.CreateNativeDialog: TfgNativeActivityDialog;
var
  ProgressService: IFGXProgressDialogService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFGXProgressDialogService, ProgressService) then
    Result := ProgressService.CreateNativeActivityDialog(Self)
  else
    Result := nil;
end;

{ TfgCustomProgressDialog }

constructor TfgxCustomProgressDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FKind := DefaultKind;
  FMax := DefaultMax;
end;

function TfgxCustomProgressDialog.CreateNativeDialog: TfgNativeProgressDialog;
var
  ProgressService: IFGXProgressDialogService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFGXProgressDialogService, ProgressService) then
    Result := ProgressService.CreateNativeProgressDialog(Self)
  else
    Result := nil;
end;

procedure TfgxCustomProgressDialog.DoInitDialog;
begin
  inherited DoInitDialog;
  FNativeDialog.Kind := Kind;
  FNativeDialog.Progress := Progress;
  FNativeDialog.Max := Max;
end;

procedure TfgxCustomProgressDialog.SetKind(const Value: TfgProgressDialogKind);
begin
  if Kind <> Value then
  begin
    FKind := Value;
    if Supported then
      NativeDialog.Kind := Kind;
  end;
end;

procedure TfgxCustomProgressDialog.SetMax(const Value: Single);
begin
  TfgxAssert.StrickMoreThan(Value, 0, 'Max Value cannot be less than 0');

  if not SameValue(Max, Value, Single.Epsilon) then
  begin
    FMax := Value;
    if Supported then
      NativeDialog.Max := Max;
    Progress := EnsureRange(Progress, 0, Max);
  end;
end;

procedure TfgxCustomProgressDialog.SetProgress(const Value: Single);
begin
  TfgxAssert.InRange(Value, 0, Max, 'Progress value must be in range [0..Max]');

  if not SameValue(Progress, Value, Single.Epsilon) then
  begin
    FProgress := EnsureRange(Value, 0, Max);
    if Supported then
      NativeDialog.Progress := Progress;
  end;
end;

procedure TfgxCustomProgressDialog.ResetProgress;
begin
  FProgress := 0;
  if Supported then
    NativeDialog.ResetProgress;
end;

initialization
  RegisterFmxClasses([TfgxCustomActivityDialog, TfgxActivityDialog, TfgxCustomProgressDialog, TfgxProgressDialog]);

{$IF Defined(ANDROID) OR Defined(IOS)}
  RegisterService;
{$ENDIF}
finalization
{$IF Defined(ANDROID) OR Defined(IOS)}
  UnregisterService;
{$ENDIF}
end.
