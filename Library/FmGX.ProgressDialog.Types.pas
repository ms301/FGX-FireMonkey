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

unit FmGX.ProgressDialog.Types;

interface

uses
  System.Classes;

type

  TfgDialogTheme = (Auto, Dark, Light, Custom);

{ TfgNativeActivityDialog }

  /// <summary>
  ///   Base class for implementation native progress/activity dialogs
  /// </summary>
  TfgNativeDialog = class abstract
  public
    const UndefinedThemeID = 0;
  private
    [Weak] FOwner: TObject;
    FTitle: string;
    FMessage: string;
    FTheme: TfgDialogTheme;
    FThemeID: Integer;
    FIsShown: Boolean;
    FCancellable: Boolean;
    FOnShow: TNotifyEvent;
    FOnHide: TNotifyEvent;
    FOnCancel: TNotifyEvent;
    procedure SetMessage(const Value: string);
    procedure SetTitle(const Value: string);
    procedure SetCancellable(const Value: Boolean);
    procedure SetTheme(const Value: TfgDialogTheme);
    procedure SetThemeID(const Value: Integer);
  protected
    procedure CancellableChanged; virtual;
    procedure MessageChanged; virtual;
    procedure TitleChanged; virtual;
    procedure ThemeChanged; virtual;
    procedure ThemeIDChanged; virtual;
    function GetIsShown: Boolean; virtual;
    procedure DoShow;
    procedure DoHide;
  public
    constructor Create(const AOwner: TObject); virtual;
    procedure Show; virtual;
    procedure Hide; virtual;
  public
    property Owner: TObject read FOwner;
    property Cancellable: Boolean read FCancellable write SetCancellable;
    property Message: string read FMessage write SetMessage;
    property Title: string read FTitle write SetTitle;
    property Theme: TfgDialogTheme read FTheme write SetTheme;
    property ThemeID: Integer read FThemeID write SetThemeID;
    property IsShown: Boolean read GetIsShown;
    property OnCancel: TNotifyEvent read FOnCancel write FOnCancel;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnHide: TNotifyEvent read FOnHide write FOnHide;
  end;

  /// <summary>
  ///   Base class for implementation native activity dialogs
  /// </summary>
  TfgNativeActivityDialog = class abstract (TfgNativeDialog);

{ TfgNativeProgressDialog }

  /// <summary>
  ///   <para>
  ///     Display mode of progress dialog.
  ///   </para>
  /// </summary>
  ///  <remarks>
  ///   <list type="bullet">
  ///     <item>
  ///       Undeterminated - We temporarily don't know, when operation will start
  ///     </item>
  ///     <item>
  ///       Determinated - We already know and evaluated operation time (in %)
  ///     </item>
  ///   </list>
  ///  </remarks>
  TfgProgressDialogKind = (Undeterminated, Determinated);

  /// <summary>
  ///   Base class for implementation native progress dialogs
  /// </summary>
  TfgNativeProgressDialog = class abstract(TfgNativeDialog)
  private
    FKind: TfgProgressDialogKind;
    FProgress: Single;
    FMax: Single;
    procedure SetKind(const AValue: TfgProgressDialogKind);
    procedure SetProgress(const AValue: Single);
    procedure SetMax(const AValue: Single);
  protected
    procedure ProgressChanged; virtual;
    procedure KindChanged; virtual;
    procedure RangeChanged; virtual;
  public
    procedure ResetProgress; virtual;
  public
    property Kind: TfgProgressDialogKind read FKind write SetKind default TfgProgressDialogKind.Undeterminated;
    property Max: Single read FMax write SetMax;
    property Progress: Single read FProgress write SetProgress;
  end;

{ IFGXProgressDialogService }

  /// <summary>
  ///   Factory for creation native progress and activity dialogs
  /// </summary>
  IFGXProgressDialogService = interface
  ['{10598EF4-3AAD-4D3A-A2FF-3DF3446D815F}']
    function CreateNativeProgressDialog(const AOwner: TObject): TfgNativeProgressDialog;
    function CreateNativeActivityDialog(const AOwner: TObject): TfgNativeActivityDialog;
  end;

implementation

uses
  System.Math, System.SysUtils, FmGX.Helpers, FmGX.Consts, FmGX.Asserts;

{ TfgNativeDialog }

procedure TfgNativeDialog.CancellableChanged;
begin
  // Nothing
end;

constructor TfgNativeDialog.Create(const AOwner: TObject);
begin
  FOwner := AOwner;
  FIsShown := False;
  FThemeID := UndefinedThemeID;
end;

procedure TfgNativeDialog.DoHide;
begin
  if Assigned(FOnHide) then
    FOnHide(FOwner);
end;

procedure TfgNativeDialog.DoShow;
begin
  if Assigned(FOnShow) then
    FOnShow(FOwner);
end;

function TfgNativeDialog.GetIsShown: Boolean;
begin
  Result := FIsShown;
end;

procedure TfgNativeDialog.Hide;
begin
  FIsShown := False;
end;

procedure TfgNativeDialog.MessageChanged;
begin
  // Nothing
end;

procedure TfgNativeDialog.SetCancellable(const Value: Boolean);
begin
  if Cancellable <> Value then
  begin
    FCancellable := Value;
    CancellableChanged;
  end;
end;

procedure TfgNativeDialog.SetMessage(const Value: string);
begin
  if Message <> Value then
  begin
    FMessage := Value;
    MessageChanged;
  end;
end;

procedure TfgNativeDialog.SetTheme(const Value: TfgDialogTheme);
begin
  if Theme <> Value then
  begin
    FTheme := Value;
    ThemeChanged;
  end;
end;

procedure TfgNativeDialog.SetThemeID(const Value: Integer);
begin
  if ThemeID <> Value then
  begin
    FThemeID := Value;
    ThemeIDChanged;
  end;
end;

procedure TfgNativeDialog.SetTitle(const Value: string);
begin
  if Title <> Value then
  begin
    FTitle := Value;
    TitleChanged;
  end;
end;

procedure TfgNativeDialog.Show;
begin
  FIsShown := True;
end;

procedure TfgNativeDialog.ThemeChanged;
begin
  // Nothing
end;

procedure TfgNativeDialog.ThemeIDChanged;
begin
  // Nothing
end;

procedure TfgNativeDialog.TitleChanged;
begin
  // Nothing
end;

{ TfgNativeProgressDialog }

procedure TfgNativeProgressDialog.KindChanged;
begin
  // Nothing
end;

procedure TfgNativeProgressDialog.ProgressChanged;
begin
  // Nothing
end;

procedure TfgNativeProgressDialog.RangeChanged;
begin
  // Nothing
end;

procedure TfgNativeProgressDialog.SetKind(const AValue: TfgProgressDialogKind);
begin
  if Kind <> AValue then
  begin
    FKind := AValue;
    KindChanged;
  end;
end;

procedure TfgNativeProgressDialog.SetMax(const AValue: Single);
begin
  TfgxAssert.StrickMoreThan(AValue, 0);

  if not SameValue(AValue, Max, Single.Epsilon) then
  begin
    FMax := AValue;
    RangeChanged;
  end;
end;

procedure TfgNativeProgressDialog.SetProgress(const AValue: Single);
begin
  TfgxAssert.InRange(AValue, 0, Max, 'Progress value must be in range [Min..Max]');

  if not SameValue(Progress, AValue, Single.Epsilon) then
  begin
    FProgress := EnsureRange(AValue, 0, Max);
    ProgressChanged;
  end;
end;

procedure TfgNativeProgressDialog.ResetProgress;
begin
  FProgress := 0;
end;

end.
