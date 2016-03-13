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

unit FGX.ProgressDialog;

interface

uses
  System.Classes, FGX.ProgressDialog.Types, FGX.Consts;

type

  /// <summary>
  ///   Generic Abstract base class provide base functionality for creation and using progress/activity dialog.
  ///   Each dialog has Message and Title and holds instance of wrapper native dialog.
  /// </summary>
  TfgCustomDialog<T: TfgNativeDialog> = class abstract(TComponent)
  private
    FNativeProgressDialog: T;
    FTitle: string;
    FMessage: string;
    FOnShow: TNotifyEvent;
    FOnHide: TNotifyEvent;
    FOnCancel: TNotifyEvent;  // Reserved on future;
    procedure SetMessage(const Value: string);
    procedure SetTitle(const Value: string);
    procedure SetOnCancel(const Value: TNotifyEvent); { TODO -oBrovin Y.D. -cFeatures : Implement OnCancel event for Progress Dialogs }
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
    property NativeDialog: T read FNativeProgressDialog;
  public
    property Message: string read FMessage write SetMessage;
    property Title: string read FTitle write SetTitle;
    property OnShow: TNotifyEvent read FOnShow write SetOnShow;
    property OnHide: TNotifyEvent read FOnHide write SetOnHide;
  end;

  { TfgActivityDialog }

  TfgCustomActivityDialog = class(TfgCustomDialog<TfgNativeActivityDialog>)
  protected
    function CreateNativeDialog: TfgNativeActivityDialog; override;
  end;

  /// <summary>
  ///   Native Modal dialog with activity indicator, title and message
  /// </summary>
  [ComponentPlatformsAttribute(fgMobilePlatforms)]
  TfgActivityDialog = class(TfgCustomActivityDialog)
  published
    property Message;
    property Title;
    property OnShow;
    property OnHide;
  end;

  { TfgProgressDialog }

  TfgCustomProgressDialog = class(TfgCustomDialog<TfgNativeProgressDialog>)
  public const
    DefaultKind = TfgProgressDialogKind.Determinated;
  private
    FKind: TfgProgressDialogKind;
    FProgress: Single;
    procedure SetKind(const Value: TfgProgressDialogKind);
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
  TfgProgressDialog = class(TfgCustomProgressDialog)
  published
    property Kind;
    property Message;
    property Progress;
    property Title;
    property OnShow;
    property OnHide;
  end;

implementation

uses
  System.Math, System.SysUtils, FMX.Types, FMX.Platform, FGX.Helpers, FGX.Asserts
{$IFDEF IOS}
   , FGX.ProgressDialog.iOS
{$ENDIF}
{$IFDEF ANDROID}
   , FGX.ProgressDialog.Android
{$ENDIF}
;

{ TfgCustomProgressDialog }

constructor TfgCustomDialog<T>.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNativeProgressDialog := CreateNativeDialog;
end;

destructor TfgCustomDialog<T>.Destroy;
begin
  FreeAndNil(FNativeProgressDialog);
  inherited Destroy;
end;

procedure TfgCustomDialog<T>.DoInitDialog;
begin
  AssertIsNotNil(FNativeProgressDialog);

  FNativeProgressDialog.Message := Message;
  FNativeProgressDialog.Title := Title;
  FNativeProgressDialog.OnShow := OnShow;
  FNativeProgressDialog.OnHide := OnHide;
end;

procedure TfgCustomDialog<T>.Hide;
begin
  if Supported then
    FNativeProgressDialog.Hide;
end;

procedure TfgCustomDialog<T>.SetMessage(const Value: string);
begin
  if Message <> Value then
  begin
    FMessage := Value;
    if Supported then
      FNativeProgressDialog.Message := Message;
  end;
end;

procedure TfgCustomDialog<T>.SetOnCancel(const Value: TNotifyEvent);
begin
  FOnCancel := Value;
  if Supported then
    FNativeProgressDialog.OnCancel := FOnCancel;
end;

procedure TfgCustomDialog<T>.SetOnHide(const Value: TNotifyEvent);
begin
  FOnHide := Value;
  if Supported then
    FNativeProgressDialog.OnHide := FOnHide;
end;

procedure TfgCustomDialog<T>.SetOnShow(const Value: TNotifyEvent);
begin
  FOnShow := Value;
  if Supported then
    FNativeProgressDialog.OnShow := FOnShow;
end;

procedure TfgCustomDialog<T>.SetTitle(const Value: string);
begin
  if Title <> Value then
  begin
    FTitle := Value;
    if Supported then
      FNativeProgressDialog.Title := Title;
  end;
end;

procedure TfgCustomDialog<T>.Show;
begin
  if Supported then
  begin
    DoInitDialog;
    FNativeProgressDialog.Show;
  end;
end;

function TfgCustomDialog<T>.Supported: Boolean;
begin
  Result := FNativeProgressDialog <> nil;
end;

{ TfgCustomActivityDialog }

function TfgCustomActivityDialog.CreateNativeDialog: TfgNativeActivityDialog;
var
  ProgressService: IFGXProgressDialogService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFGXProgressDialogService, ProgressService) then
    Result := ProgressService.CreateNativeActivityDialog(Self)
  else
    Result := nil;
end;

{ TfgCustomProgressDialog }

constructor TfgCustomProgressDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FKind := DefaultKind;
end;

function TfgCustomProgressDialog.CreateNativeDialog: TfgNativeProgressDialog;
var
  ProgressService: IFGXProgressDialogService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFGXProgressDialogService, ProgressService) then
    Result := ProgressService.CreateNativeProgressDialog(Self)
  else
    Result := nil;
end;

procedure TfgCustomProgressDialog.DoInitDialog;
begin
  inherited DoInitDialog;
  FNativeProgressDialog.Kind := Kind;
  FNativeProgressDialog.Progress := Progress;
end;

procedure TfgCustomProgressDialog.SetKind(const Value: TfgProgressDialogKind);
begin
  if Kind <> Value then
  begin
    FKind := Value;
    if Supported then
      NativeDialog.Kind := Kind;
  end;
end;

procedure TfgCustomProgressDialog.SetProgress(const Value: Single);
begin
  AssertInRange(Value, 0, 100, 'Progress value must be in range [0..100]');

  if not SameValue(Progress, Value, EPSILON_SINGLE) then
  begin
    FProgress := EnsureRange(Value, 0, 100);
    if Supported then
      NativeDialog.Progress := Progress;
  end;
end;

procedure TfgCustomProgressDialog.ResetProgress;
begin
  FProgress := 0;
  if Supported then
    NativeDialog.ResetProgress;
end;

initialization
  RegisterFmxClasses([TfgCustomActivityDialog, TfgActivityDialog, TfgCustomProgressDialog, TfgProgressDialog]);

{$IF Defined(ANDROID) OR Defined(IOS)}
  RegisterService;
{$ENDIF}
end.
