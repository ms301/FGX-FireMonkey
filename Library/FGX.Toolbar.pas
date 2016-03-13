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

unit FGX.ToolBar;

interface

uses
  System.Classes, System.Types, System.UITypes, System.Generics.Collections, System.ImageList,
  FMX.Controls, FMX.Objects, FMX.StdCtrls, FMX.Types, FMX.Menus, FMX.Dialogs, FMX.ImgList, FMX.ActnList, FMX.ListBox,
  FMX.Layouts, FGX.BitBtn;

type

{ TfgToolBar }

  TfgCustomToolBar = class;
  TfgToolBarDisplayOption = (Text, Image);
  TfgToolBarDisplayOptions = set of TfgToolBarDisplayOption;

  IfgToolbarButton = interface
  ['{8EDF7D8B-0839-4C21-9302-D191B6F6C2C9}']
    procedure SetToolbar(const AToolbar: TfgCustomToolBar);
    procedure UpdateToPreferSize;
    procedure UpdateDisplayOptions(const ADisplayOptions: TfgToolBarDisplayOptions);
  end;

  TfgCustomToolBar = class(TStyledControl, IItemsContainer)
  public const
    DefaultAutoSize = True;
    DefaultHorizontalGap = 3;
    DefaultDisplayOptions = [TfgToolBarDisplayOption.Text, TfgToolBarDisplayOption.Image];
  strict private
    FButtons: TList<TControl>;
    FAutoSize: Boolean;
    FHorizontalGap: Single;
    FDisplayOptions: TfgToolBarDisplayOptions;
  private
    procedure SetAutoSize(const Value: Boolean);
    procedure SetHorizontalGap(const Value: Single);
    procedure SetDisplayOptions(const Value: TfgToolBarDisplayOptions);
  protected
    function GetDefaultSize: TSizeF; override;
    procedure Resize; override;
    procedure RefreshButtonsSize;
    procedure RefreshDisplayOptions;
    { Tree objects structure }
    procedure DoAddObject(const AObject: TFmxObject); override;
    procedure DoInsertObject(Index: Integer; const AObject: TFmxObject); override;
    procedure DoRemoveObject(const AObject: TFmxObject); override;
    { IItemsContainer }
    function GetItemsCount: Integer;
    function GetItem(const AIndex: Integer): TFmxObject;
    function GetObject: TFmxObject;
    { IFreeNotification }
    procedure FreeNotification(AObject: TObject); override;
    { Style }
    function GetDefaultStyleLookupName: string; override;
    procedure DoRealign; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  public
    property AutoSize: Boolean read FAutoSize write SetAutoSize;
    property Buttons: TList<TControl> read FButtons;
    property HorizontalGap: Single read FHorizontalGap write SetHorizontalGap;
    property DisplayOptions: TfgToolBarDisplayOptions read FDisplayOptions write SetDisplayOptions;
  end;

  TfgToolBar = class(TfgCustomToolBar)
  published
    property AutoSize default TfgCustomToolBar.DefaultAutoSize;
    property HorizontalGap;
    property DisplayOptions default TfgCustomToolBar.DefaultDisplayOptions;
    { TStyledControl }
    property Action;
    property Align default TAlignLayout.Top;
    property Anchors;
    property ClipChildren default False;
    property ClipParent default False;
    property Cursor default crDefault;
    property DragMode default TDragMode.dmManual;
    property EnableDragHighlight default True;
    property Enabled default True;
    property Locked default False;
    property Height;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property HitTest default True;
    property Padding;
    property Opacity;
    property Margins;
    property PopupMenu;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    property StyleLookup;
    property TabOrder;
    property TouchTargetExpansion;
    property Visible default True;
    property Width;
    property OnApplyStyleLookup;
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    property OnKeyDown;
    property OnKeyUp;
    property OnCanFocus;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnPainting;
    property OnPaint;
    property OnResize;
  end;

{ TfgToolBarButton }

  TfgToolBarButton = class(TSpeedButton, IfgToolbarButton, IGlyph)
  private
    FDisplayOptions: TfgToolBarDisplayOptions;
    [Weak] FToolBar: TfgCustomToolBar;
  protected
    { Size }
    function GetDefaultSize: TSizeF; override;
    { Visibility }
    procedure Hide; override;
    procedure Show; override;
    { Style }
    procedure ApplyStyle; override;
    function GetStyleObject: TFmxObject; override;
    function GetAdjustType: TAdjustType; override;
    function GetAdjustSizeValue: TSizeF; override;
  public
    { IToolbarButton }
    procedure SetToolbar(const AToolbar: TfgCustomToolBar);
    procedure UpdateToPreferSize; virtual;
    procedure UpdateDisplayOptions(const ADisplayOptions: TfgToolBarDisplayOptions); virtual;
  end;

{ TToolBarPopupButton}

  TfgToolBarPopupButton = class(TfgToolBarButton)
  strict private
    FDropDownButton: TControl;
    FPopupMenu: TPopupMenu;
    FIsDropDown: Boolean;
  protected
    { Style }
    procedure ApplyStyle; override;
    procedure FreeStyle; override;
    { Location }
    function GetDefaultSize: TSizeF; override;
    { Mouse Events }
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single); override;
    { Drop Down Menu }
    procedure DoDropDown; virtual;
  public
    { IToolbarButton }
    procedure UpdateToPreferSize; override;
    function HasPopupMenu: Boolean;
  published
    property IsDropDown: Boolean read FIsDropDown;
    property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;
  end;

{ TToolBarSeparator }

  TfgToolBarSeparator = class(TStyledControl, IfgToolbarButton)
  protected
    function GetDefaultSize: TSizeF; override;
    { IfgToolbarButton }
    procedure SetToolbar(const AToolbar: TfgCustomToolBar);
    procedure UpdateToPreferSize;
    procedure UpdateDisplayOptions(const ADisplayOptions: TfgToolBarDisplayOptions); virtual;
    { Visibility }
    procedure Hide; override;
    procedure Show; override;
    { Styles }
    function GetStyleObject: TFmxObject; override;
    function GetAdjustType: TAdjustType; override;
    function GetAdjustSizeValue: TSizeF; override;
  published
    property Action;
    property Anchors;
    property AutoTranslate default True;
    property CanFocus default True;
    property CanParentFocus;
    property ClipChildren default False;
    property ClipParent default False;
    property Cursor default crDefault;
    property DisableFocusEffect;
    property DragMode default TDragMode.dmManual;
    property EnableDragHighlight default True;
    property Enabled default True;
    property Height;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property HitTest default True;
    property Locked default False;
    property Padding;
    property Opacity;
    property Margins;
    property PopupMenu;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property StyleLookup;
    property TabOrder;
    property TouchTargetExpansion;
    property Visible default True;
    property Width;
  end;

{ TfgToolBarComboBox }

  TfgToolBarComboBox = class(TComboBox, IfgToolbarButton)
  private
    { IfgToolbarButton }
    procedure SetToolbar(const AToolbar: TfgCustomToolBar);
    procedure UpdateToPreferSize;
    procedure UpdateDisplayOptions(const ADisplayOptions: TfgToolBarDisplayOptions); virtual;
  protected
    { Visibility }
    procedure Hide; override;
    procedure Show; override;
  end;

{ TfgToolBarDivider }

  TfgToolBarDivider = class(TLayout, IfgToolbarButton)
  private
    { IfgToolbarButton }
    procedure SetToolbar(const AToolbar: TfgCustomToolBar);
    procedure UpdateToPreferSize;
    procedure UpdateDisplayOptions(const ADisplayOptions: TfgToolBarDisplayOptions);
  protected
    function GetDefaultSize: TSizeF; override;
  end;

implementation

uses
  System.SysUtils, System.Math, FMX.Utils, FGX.Asserts, FMX.Styles;

{ TfgCustomToolBar }

constructor TfgCustomToolBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButtons := TList<TControl>.Create;
  FAutoSize := DefaultAutoSize;
  FHorizontalGap := DefaultHorizontalGap;
  FDisplayOptions := DefaultDisplayOptions;
  Align := TAlignLayout.Top;
end;

destructor TfgCustomToolBar.Destroy;
var
  Button: TControl;
begin
  for Button in FButtons do
    Button.RemoveFreeNotify(Self);
  FButtons.Free;
  inherited Destroy;
end;

procedure TfgCustomToolBar.DoAddObject(const AObject: TFmxObject);
var
  ToolBarButton: IfgToolbarButton;
begin
  inherited DoAddObject(AObject);
  if (AObject is TControl) and AObject.GetInterface(IfgToolbarButton, ToolBarButton) then
  begin
    ToolBarButton.SetToolbar(Self);
    ToolBarButton.UpdateToPreferSize;
    ToolBarButton.UpdateDisplayOptions(DisplayOptions);
    FButtons.Add(TControl(AObject));
    AObject.AddFreeNotify(Self);
    Realign;
  end;
end;

procedure TfgCustomToolBar.DoInsertObject(Index: Integer; const AObject: TFmxObject);
var
  ToolBarButton: IfgToolbarButton;
begin
  inherited DoInsertObject(Index, AObject);
  if (AObject is TfgToolBarButton) and AObject.GetInterface(IfgToolbarButton, ToolBarButton) then
  begin
    ToolBarButton.SetToolbar(Self);
    ToolBarButton.UpdateToPreferSize;
    ToolBarButton.UpdateDisplayOptions(DisplayOptions);
    FButtons.Insert(Index, AObject as TfgToolBarButton);
    AObject.AddFreeNotify(Self);
    Realign;
  end;
end;

procedure TfgCustomToolBar.DoRealign;
var
  ControlTmp: TControl;
  LastX: Single;
begin
  inherited DoRealign;
  LastX := Padding.Left;
  for ControlTmp in Controls do
  begin
  {$IFDEF MSWINDOWS}
    if (csDesigning in ComponentState) and Supports(ControlTmp, IDesignerControl) then
      Continue;
  {$ENDIF}
    if (ResourceControl <> ControlTmp) and ControlTmp.Visible then
    begin
      LastX := LastX + Floor(HorizontalGap / 2) + ControlTmp.Margins.Left;
      ControlTmp.Position.Point := TPointF.Create(LastX, 0);
      LastX := LastX + ControlTmp.Size.Width + ControlTmp.Margins.Right +  + HorizontalGap / 2;
    end;
  end;
end;

procedure TfgCustomToolBar.DoRemoveObject(const AObject: TFmxObject);
begin
  inherited DoRemoveObject(AObject);
  if AObject is TfgToolBarButton then
  begin
    FButtons.Remove(AObject as TfgToolBarButton);
    AObject.RemoveFreeNotify(Self);
  end;
end;

procedure TfgCustomToolBar.FreeNotification(AObject: TObject);
begin
  AssertIsNotNil(AObject);

  inherited FreeNotification(AObject);
  if AObject is TfgToolBarButton then
    FButtons.Remove(AObject as TfgToolBarButton);
end;

function TfgCustomToolBar.GetDefaultSize: TSizeF;
begin
  Result := TSizeF.Create(100, 40);
end;

function TfgCustomToolBar.GetDefaultStyleLookupName: string;
begin
  Result := 'ToolbarStyle';
end;

function TfgCustomToolBar.GetItem(const AIndex: Integer): TFmxObject;
begin
  AssertIsNotNil(FButtons);
  AssertInRange(AIndex, 0, FButtons.Count - 1);

  Result := FButtons[AIndex];
end;

function TfgCustomToolBar.GetItemsCount: Integer;
begin
  AssertIsNotNil(FButtons);

  Result := FButtons.Count;
end;

function TfgCustomToolBar.GetObject: TFmxObject;
begin
  Result := Self;
end;

procedure TfgCustomToolBar.RefreshButtonsSize;
var
  ControlTmp: TControl;
  ToolBarButton: IfgToolbarButton;
begin
  inherited Resize;
  if AutoSize then
    for ControlTmp in Controls do
      if ControlTmp.GetInterface(IfgToolbarButton, ToolBarButton) then
        ToolBarButton.UpdateToPreferSize;
end;

procedure TfgCustomToolBar.RefreshDisplayOptions;
var
  ControlTmp: TControl;
  ToolBarButton: IfgToolbarButton;
begin
  for ControlTmp in Controls do
    if ControlTmp.GetInterface(IfgToolbarButton, ToolBarButton) then
      ToolBarButton.UpdateDisplayOptions(FDisplayOptions);
end;

procedure TfgCustomToolBar.Resize;
begin
  inherited;
  if AutoSize then
    RefreshButtonsSize;
end;

procedure TfgCustomToolBar.SetAutoSize(const Value: Boolean);
begin
  if AutoSize <> Value then
  begin
    FAutoSize := Value;
    if AutoSize then
      RefreshButtonsSize;
  end;
end;

procedure TfgCustomToolBar.SetDisplayOptions(const Value: TfgToolBarDisplayOptions);
begin
  FDisplayOptions := Value;
  RefreshDisplayOptions;
end;

procedure TfgCustomToolBar.SetHorizontalGap(const Value: Single);
begin
  FHorizontalGap := Value;
  Realign;
end;

{ TfgToolbarButton }

procedure TfgToolBarButton.ApplyStyle;
begin
  inherited;
  if FToolBar <> nil then
    UpdateDisplayOptions(FToolBar.DisplayOptions);
end;

function TfgToolBarButton.GetAdjustSizeValue: TSizeF;
begin
  Result := inherited;
  if ParentControl <> nil then
    Result.Height := ParentControl.Height;
end;

function TfgToolBarButton.GetAdjustType: TAdjustType;
begin
  Result := inherited;
  if Result = TAdjustType.FixedWidth then
    Result := TAdjustType.FixedSize;
  if Result = TAdjustType.None then
    Result := TAdjustType.FixedHeight;
end;

function TfgToolBarButton.GetDefaultSize: TSizeF;
begin
  Result := TSizeF.Create(22, 24);
end;

function TfgToolBarButton.GetStyleObject: TFmxObject;
const
  ResourceName = 'TfgToolbarStyle';
var
  StyleContainer: TFmxObject;
begin
  Result := nil;
  if StyleLookup.IsEmpty and (FindResource(HInstance, PChar(ResourceName), RT_RCDATA) <> 0) then
  begin
    StyleContainer := TStyleStreaming.LoadFromResource(HInstance, ResourceName, RT_RCDATA);
    Result := StyleContainer.FindStyleResource(GetDefaultStyleLookupName, True);
    if Result <> nil then
      Result.Parent := nil;
    StyleContainer.Free;
  end;
  if Result = nil then
    Result := inherited GetStyleObject;
end;

procedure TfgToolBarButton.Hide;
var
  AlignRoot: IAlignRoot;
begin
  inherited;
  if Supports(ParentControl.ParentControl, IAlignRoot, AlignRoot) then
    AlignRoot.Realign;
end;

procedure TfgToolBarButton.SetToolbar(const AToolbar: TfgCustomToolBar);
begin
  FToolBar := AToolbar;
end;

procedure TfgToolBarButton.Show;
var
  AlignRoot: IAlignRoot;
begin
  inherited;
  if Supports(ParentControl.ParentControl, IAlignRoot, AlignRoot) then
    AlignRoot.Realign;
end;

procedure TfgToolBarButton.UpdateDisplayOptions(const ADisplayOptions: TfgToolBarDisplayOptions);
var
  GlyphObject: TGlyph;
  StyleObject: TControl;
begin
  FDisplayOptions := ADisplayOptions;
  GlyphObject := nil;
  if FindStyleResource<TGlyph>('glyphstyle', GlyphObject) then
  begin
    GlyphObject.AutoHide := False;
    GlyphObject.Stretch := False;
    GlyphObject.Visible := TfgToolBarDisplayOption.Image in ADisplayOptions;
  end;
  if FindStyleResource<TControl>('icon', StyleObject) then
    StyleObject.Visible := TfgToolBarDisplayOption.Image in ADisplayOptions;

  if TextObject <> nil then
    TextObject.Visible := TfgToolBarDisplayOption.Text in ADisplayOptions;
end;

procedure TfgToolBarButton.UpdateToPreferSize;
begin
  if ParentControl <> nil then
    Height := ParentControl.Height;
  Width := Height;
end;

{ TfgToolBarSeparator }

function TfgToolBarSeparator.GetAdjustSizeValue: TSizeF;
begin
  Result := inherited;
  if ParentControl <> nil then
    Result.Height := ParentControl.Height;
end;

function TfgToolBarSeparator.GetAdjustType: TAdjustType;
begin
  Result := inherited;
  if Result = TAdjustType.FixedWidth then
    Result := TAdjustType.FixedSize;
  if Result = TAdjustType.None then
    Result := TAdjustType.FixedHeight;
end;

function TfgToolBarSeparator.GetDefaultSize: TSizeF;
begin
  Result := TSizeF.Create(8, 22);
end;

function TfgToolBarSeparator.GetStyleObject: TFmxObject;
const
  ResourceName = 'TfgToolbarStyle';
var
  StyleContainer: TFmxObject;
begin
  Result := nil;
  if StyleLookup.IsEmpty and (FindResource(HInstance, PChar(ResourceName), RT_RCDATA) <> 0) then
  begin
    StyleContainer := TStyleStreaming.LoadFromResource(HInstance, ResourceName, RT_RCDATA);
    Result := StyleContainer.FindStyleResource(GetDefaultStyleLookupName, True);
    if Result <> nil then
      Result.Parent := nil;
    StyleContainer.Free;
  end;
  if Result = nil then
    Result := inherited GetStyleObject;
end;

procedure TfgToolBarSeparator.Hide;
var
  AlignRoot: IAlignRoot;
begin
  inherited;
  if Supports(ParentControl.ParentControl, IAlignRoot, AlignRoot) then
    AlignRoot.Realign;
end;

procedure TfgToolBarSeparator.SetToolbar(const AToolbar: TfgCustomToolBar);
begin

end;

procedure TfgToolBarSeparator.Show;
var
  AlignRoot: IAlignRoot;
begin
  inherited;
  if Supports(ParentControl.ParentControl, IAlignRoot, AlignRoot) then
    AlignRoot.Realign;
end;

procedure TfgToolBarSeparator.UpdateDisplayOptions(const ADisplayOptions: TfgToolBarDisplayOptions);
begin

end;

procedure TfgToolBarSeparator.UpdateToPreferSize;
begin
  if ParentControl <> nil then
    Height := ParentControl.Height;
end;

{ TfgToolBaropupButton }

procedure TfgToolBarPopupButton.ApplyStyle;
var
  Obj: TFmxObject;
begin
  inherited ApplyStyle;
  Obj := FindStyleResource('drop_down_btn');
  if Obj is TControl then
    FDropDownButton := TControl(Obj);
end;

procedure TfgToolBarPopupButton.DoDropDown;
var
  PopupPos: TPointF;
begin
  if HasPopupMenu and not FIsDropDown then
  begin
    PopupPos := LocalToScreen(TPointF.Create(0, Height));
    FIsDropDown := True;
    StartTriggerAnimation(Self, 'IsDropDown');
    FPopupMenu.Popup(PopupPos.X, PopupPos.Y);
    FIsDropDown := False;
    StartTriggerAnimation(Self, 'IsDropDown');
  end
  else
    FPopupMenu.CloseMenu;
end;

procedure TfgToolBarPopupButton.FreeStyle;
begin
  FDropDownButton := nil;
  inherited;
end;

function TfgToolBarPopupButton.GetDefaultSize: TSizeF;
begin
  Result := TSizeF.Create(34, 22);
end;

function TfgToolBarPopupButton.HasPopupMenu: Boolean;
begin
  Result := Assigned(FPopupMenu);
end;

procedure TfgToolBarPopupButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  P: TPointF;
begin
  inherited MouseDown(Button, Shift, X, Y);
  P := LocalToAbsolute(TPointF.Create(X, Y));
  if FDropDownButton.PointInObject(P.X, P.Y) then
    DoDropDown;
end;

procedure TfgToolBarPopupButton.UpdateToPreferSize;
begin
  if csLoading in ComponentState then
  begin
    NeedStyleLookup;
    ApplyStyleLookup;
  end;
  if ParentControl <> nil then
    Height := ParentControl.Height;
  if Assigned(FDropDownButton) then
    Width := Height + FDropDownButton.Width
  else
    inherited UpdateToPreferSize;
end;

{ TfgToolBarComboBox }

procedure TfgToolBarComboBox.Hide;
var
  AlignRoot: IAlignRoot;
begin
  inherited;
  if Supports(ParentControl, IAlignRoot, AlignRoot) then
    AlignRoot.Realign;
end;

procedure TfgToolBarComboBox.SetToolbar(const AToolbar: TfgCustomToolBar);
begin

end;

procedure TfgToolBarComboBox.Show;
var
  AlignRoot: IAlignRoot;
begin
  inherited;
  if Supports(ParentControl, IAlignRoot, AlignRoot) then
    AlignRoot.Realign;
end;

procedure TfgToolBarComboBox.UpdateDisplayOptions(const ADisplayOptions: TfgToolBarDisplayOptions);
begin

end;

procedure TfgToolBarComboBox.UpdateToPreferSize;
begin

end;

{ TfgToolBarDivider }

function TfgToolBarDivider.GetDefaultSize: TSizeF;
begin
  Result := TSizeF.Create(50, 22);
end;

procedure TfgToolBarDivider.SetToolbar(const AToolbar: TfgCustomToolBar);
begin

end;

procedure TfgToolBarDivider.UpdateDisplayOptions(const ADisplayOptions: TfgToolBarDisplayOptions);
begin

end;

procedure TfgToolBarDivider.UpdateToPreferSize;
begin
  if ParentControl <> nil then
    Height := ParentControl.Height;
end;

initialization
  RegisterFmxClasses([TfgCustomToolBar, TfgToolBar, TfgToolBarButton, TfgToolBarSeparator, TfgToolBarPopupButton,
    TfgToolBarComboBox, TfgToolBarDivider]);
end.
