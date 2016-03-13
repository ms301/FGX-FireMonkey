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

unit FGX.ProgressDialog.Types;

interface

uses
  System.Classes;

type

{ TfgNativeActivityDialog }

  /// <summary>
  ///   Base class for implementation native progress/activity dialogs
  /// </summary>
  TfgNativeDialog = class abstract
  private
    [weak] FOwner: TObject;
    FTitle: string;
    FMessage: string;
    FIsShown: Boolean;
    FOnShow: TNotifyEvent;
    FOnHide: TNotifyEvent;
    FOnCancel: TNotifyEvent;
    procedure SetMessage(const Value: string);
    procedure SetTitle(const Value: string);
  protected
    procedure MessageChanged; virtual;
    procedure TitleChanged; virtual;
    procedure DoShow;
    procedure DoHide;
  public
    constructor Create(const AOwner: TObject); virtual;
    procedure Show; virtual;
    procedure Hide; virtual;
  public
    property Owner: TObject read FOwner;
    property Message: string read FMessage write SetMessage;
    property Title: string read FTitle write SetTitle;
    property IsShown: Boolean read FIsShown;
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
    procedure SetKind(const AValue: TfgProgressDialogKind);
    procedure SetProgress(const AValue: Single);
  protected
    procedure ProgressChanged; virtual;
    procedure KindChanged; virtual;
  public
    procedure ResetProgress; virtual;
  public
    property Kind: TfgProgressDialogKind read FKind write SetKind default TfgProgressDialogKind.Undeterminated;
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
  System.Math, FGX.Helpers, FGX.Consts, FGX.Asserts;

{ TfgNativeDialog }

constructor TfgNativeDialog.Create(const AOwner: TObject);
begin
  FOwner := AOwner;
  FIsShown := False;
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

procedure TfgNativeDialog.Hide;
begin
  FIsShown := False;
end;

procedure TfgNativeDialog.MessageChanged;
begin
  // Nothing
end;

procedure TfgNativeDialog.SetMessage(const Value: string);
begin
  if Message <> Value then
  begin
    FMessage := Value;
    MessageChanged;
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

procedure TfgNativeProgressDialog.SetKind(const AValue: TfgProgressDialogKind);
begin
  if Kind <> AValue then
  begin
    FKind := AValue;
    KindChanged;
  end;
end;

procedure TfgNativeProgressDialog.SetProgress(const AValue: Single);
begin
  AssertInRange(AValue, 0, 100, 'Progress value must be in range [0..100]');

  if not SameValue(Progress, AValue, EPSILON_SINGLE) then
  begin
    FProgress := EnsureRange(AValue, 0, 100);
    ProgressChanged;
  end;
end;

procedure TfgNativeProgressDialog.ResetProgress;
begin
  FProgress := 0;
end;

end.
