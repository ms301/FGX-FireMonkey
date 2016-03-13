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

unit FGX.Designer.Items;

interface

uses
  System.Types, System.UITypes, System.Classes, System.Variants, System.Generics.Collections, System.ImageList,
  System.Actions, DesignIntf, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Layouts,
  FMX.TreeView, FMX.ActnList, FMX.ListBox, FMX.Controls.Presentation, FMX.ImgList, FMX.Menus, FGX.Toolbar, FGX.BitBtn,
  FGX.Items, FGX.LinkedLabel;

resourcestring
  rsNotNamed = 'Not Named';
  rsTotalCount = 'Total count: %d';

type

  TTreeViewItemWithData = class;

  TfgFormItemsDesigner = class(TForm)
    TreeView: TTreeView;
    ExToolBar1: TfgToolBar;
    fgToolBarButton7: TfgToolBarButton;
    tbiClassesSeparator: TfgToolBarSeparator;
    StyleBook: TStyleBook;
    ActionList: TActionList;
    ActionAdd: TAction;
    ActionAddChild: TAction;
    ActionDelete: TAction;
    ActionCopy: TAction;
    ActionPaste: TAction;
    ActionSortAsc: TAction;
    ActionSortDesc: TAction;
    ActionUp: TAction;
    ActionDown: TAction;
    fgToolBarButton2: TfgToolBarButton;
    fgToolBarButton4: TfgToolBarButton;
    StatusBar1: TStatusBar;
    fgToolBarButton5: TfgToolBarButton;
    ImageList: TImageList;
    ComboBoxItemsInfo: TfgToolBarComboBox;
    fgToolBarPopupButton1: TfgToolBarPopupButton;
    PopupMenuAdd: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    ActionAddX: TAction;
    LabelTotalCount: TLabel;
    ActionHome: TAction;
    ActionEnd: TAction;
    fgToolBarPopupButton2: TfgToolBarPopupButton;
    fgToolBarButton1: TfgToolBarButton;
    fgToolBarButton3: TfgToolBarButton;
    ActionCut: TAction;
    PopupMenuAddChild: TPopupMenu;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    ActionAddChildX: TAction;
    fgToolBarSeparator1: TfgToolBarSeparator;
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure ActionAddExecute(Sender: TObject);
    procedure ActionAddXExecute(Sender: TObject);
    procedure ActionAddChildExecute(Sender: TObject);
    procedure ActionAddChildXExecute(Sender: TObject);
    procedure ActionDeleteExecute(Sender: TObject);
    procedure ActionCopyExecute(Sender: TObject);
    procedure ActionPasteExecute(Sender: TObject);
    procedure ActionSortAscExecute(Sender: TObject);
    procedure ActionSortDescExecute(Sender: TObject);
    procedure ActionUpExecute(Sender: TObject);
    procedure ActionDownExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TreeViewKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure TreeViewChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function GetSelectedNode: TTreeViewItemWithData;
  private
    [Weak] FDesigner: IDesigner;
    [Weak] FComponent: IItemsContainer;
    [Weak] FItemsList: TList<TfgItemInformation>;
    function HasComponent: Boolean;
    procedure SetComponent(const Value: IItemsContainer);
    function DefineItemCaption(const AItem: TFmxObject): string;
    procedure FillClassItemsInfo;
    { IDE Designer }
    procedure ReselectItemComponent(const AItem: TFmxObject);
    { Items Tree }
    procedure RebuildTree;
    function AddTreeNode(const ARootNode: TFmxObject; const AItem: TFmxObject; const AItemInformation: TfgItemInformation; const AIndex: Integer = -1): TTreeViewItemWithData;
    function FindParentNode(const AObject: TFmxObject): TTreeViewItemWithData;
    procedure UpdateNodeVisibilityButton(const ANode: TTreeViewItemWithData);
    procedure ScrollToSelectedNode;
    procedure RefreshTotalCount;
    procedure SetNodeIndex(const ANode: TTreeViewItemWithData; const AIndex: Integer);
    procedure SetItemVisible(const ANodeStyleObject: TObject; const AVisible: Boolean);
    { Events }
    procedure HideItemHandler(Sender: TObject);
    procedure ShowItemHandler(Sender: TObject);
  public
    property Component: IItemsContainer read FComponent write SetComponent;
    property Designer: IDesigner read FDesigner write FDesigner;
    property SelectedNode: TTreeViewItemWithData read GetSelectedNode;
  end;

  TTreeViewItemWithData = class(TTreeViewItem)
  private
    [Weak] FItemComponent: TFmxObject;
    FItemInformation: TfgItemInformation;
  public
    property Item: TFmxObject read FItemComponent write FItemComponent;
    property Information: TfgItemInformation read FItemInformation write FItemInformation;
  end;

var
  fgFormItemsDesigner: TfgFormItemsDesigner;

implementation

uses
  System.TypInfo, System.SysUtils, System.Math, System.Rtti, System.Generics.Defaults, FMX.Platform, FGX.Asserts;

{$R *.fmx}

procedure TfgFormItemsDesigner.ActionAddChildExecute(Sender: TObject);
var
  ItemClass: TFmxObjectClass;
  Item: TFmxObject;
  Node: TTreeViewItemWithData;
begin
  AssertIsNotNil(FItemsList);
  AssertIsNotNil(FComponent);
  AssertIsNotNil(Designer);
  AssertIsNotNil(SelectedNode);
  AssertInRange(ComboBoxItemsInfo.ItemIndex, 0, ComboBoxItemsInfo.Items.Count - 1);
  AssertInRange(ComboBoxItemsInfo.ItemIndex, 0, FItemsList.Count - 1);

  ItemClass := FItemsList[ComboBoxItemsInfo.ItemIndex].ItemClass;
  Item := ItemClass.Create(Designer.GetRoot);
  Item.Parent := SelectedNode.Item;
  Item.Name := Designer.UniqueName(Item.ClassName);

  Node := AddTreeNode(SelectedNode, Item, FItemsList[ComboBoxItemsInfo.ItemIndex]);
  Node.Select;
  UpdateActions;
end;

procedure TfgFormItemsDesigner.ActionAddChildXExecute(Sender: TObject);
var
  CountStr: string;
  Count: Integer;
  I: Integer;
begin
  CountStr := InputBox('Package creating items' , 'Count of Items:', '10');
  if TryStrToInt(CountStr, Count) then
  begin
    TreeView.BeginUpdate;
    try
      for I := 1 to Count do
        ActionAddChild.Execute;
    finally
      TreeView.EndUpdate;
    end;
  end;
end;

procedure TfgFormItemsDesigner.ActionAddExecute(Sender: TObject);

  function DefineParentItem: TFmxObject;
  begin
    if (SelectedNode = nil) or not FItemsList[ComboBoxItemsInfo.ItemIndex].AcceptsChildItems then
      Result := Component.GetObject
    else
      Result := TTreeViewItemWithData(TreeView.Selected).Item.Parent;
  end;

  function DefineIndex: Integer;
  begin
    if SelectedNode = nil then
      Result := 0
    else
      Result := SelectedNode.Index + 1;
  end;

var
  ItemClass: TFmxObjectClass;
  Item: TFmxObject;
  Node: TTreeViewItem;
  NewIndex: Integer;
  ItemInformation: TfgItemInformation;
begin
  AssertIsNotNil(FItemsList);
  AssertIsNotNil(FComponent);
  AssertIsNotNil(Designer);
  AssertInRange(ComboBoxItemsInfo.ItemIndex, 0, ComboBoxItemsInfo.Items.Count - 1);
  AssertInRange(ComboBoxItemsInfo.ItemIndex, 0, FItemsList.Count - 1);

  ItemInformation := FItemsList[ComboBoxItemsInfo.ItemIndex];
  ItemClass := ItemInformation.ItemClass;
  Item := ItemClass.Create(Designer.GetRoot);
  Item.Parent := DefineParentItem;
  Item.Name := Designer.UniqueName(Item.ClassName);
  if SelectedNode <> nil then
  begin
    NewIndex := SelectedNode.Index + 1;
    Item.Index := NewIndex;
  end
  else
    NewIndex := -1;

  if SelectedNode = nil then
    Node := AddTreeNode(TreeView, Item, ItemInformation)
  else if SelectedNode.ParentItem <> nil then
    Node := AddTreeNode(SelectedNode.ParentItem, Item, ItemInformation,  NewIndex)
  else
    Node := AddTreeNode(TreeView, Item, ItemInformation, NewIndex);

  Node.Select;
  UpdateActions;
end;

procedure TfgFormItemsDesigner.ActionAddXExecute(Sender: TObject);
var
  CountStr: string;
  Count: Integer;
  I: Integer;
begin
  CountStr := InputBox('Package creating items' , 'Count of Items:', '10');
  if TryStrToInt(CountStr, Count) then
  begin
    TreeView.BeginUpdate;
    try
      for I := 1 to Count do
        ActionAdd.Execute;
    finally
      TreeView.EndUpdate;
    end;
  end;
end;

procedure TfgFormItemsDesigner.ActionCopyExecute(Sender: TObject);
var
  ClipBoardService: IFMXClipboardService;
begin
  AssertIsNotNil(SelectedNode);

  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, ClipBoardService) then
    ClipBoardService.SetClipboard(TValue.From<TTreeViewItemWithData>(SelectedNode));
end;

procedure TfgFormItemsDesigner.ActionDeleteExecute(Sender: TObject);
var
  ItemComponent: TObject;
  OldIndex: Integer;
  Node: TTreeViewItemWithData;
begin
  AssertIsNotNil(SelectedNode);

  ItemComponent := SelectedNode.Item;
  try
    OldIndex := SelectedNode.Index;
    SelectedNode.Item := nil;
    SelectedNode.Free;
  finally
    ItemComponent.Free;
  end;

  // ¬ыбираем новый итем
  if OldIndex = TreeView.Count then
    OldIndex := TreeView.Count - 1;

  if InRange(OldIndex, 0, TreeView.Count - 1) then
  begin
    Node := TreeView.ItemByIndex(OldIndex) as TTreeViewItemWithData;
    Node.Select;
  end
  else
    TreeView.Selected := nil;

  RefreshTotalCount;
  UpdateActions;
end;

procedure TfgFormItemsDesigner.ActionUpExecute(Sender: TObject);
begin
  AssertIsNotNil(SelectedNode);

  SetNodeIndex(SelectedNode, SelectedNode.Index - 1);
  ScrollToSelectedNode;
end;

procedure TfgFormItemsDesigner.ActionDownExecute(Sender: TObject);
begin
  AssertIsNotNil(SelectedNode);

  SetNodeIndex(SelectedNode, SelectedNode.Index + 1);
  ScrollToSelectedNode;
end;

procedure TfgFormItemsDesigner.ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  ActionAddChild.Enabled := (SelectedNode <> nil) and SelectedNode.Information.AcceptsChildItems;
  ActionDelete.Enabled := SelectedNode <> nil;
  ActionCopy.Enabled := SelectedNode <> nil;
  ActionUp.Enabled := (SelectedNode <> nil) and (SelectedNode.Index > 0);
  ActionDown.Enabled := (SelectedNode <> nil) and (SelectedNode.Index < TreeView.Count - 1);
end;

procedure TfgFormItemsDesigner.ActionPasteExecute(Sender: TObject);
var
  NodeCopy: TTreeViewItemWithData;
  ItemCopy: TFmxObject;
  ClipBoardService: IFMXClipboardService;
  Value: TValue;
  SourceNode: TTreeViewItemWithData;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, ClipBoardService) then
  begin
    Value := ClipBoardService.GetClipboard;
    if Value.IsType<TTreeViewItemWithData> then
    begin
      SourceNode := Value.AsType<TTreeViewItemWithData>;

      AssertIsNotNil(SourceNode.Item);

      NodeCopy := SourceNode.Clone(SourceNode.Owner) as TTreeViewItemWithData;

      TreeView.AddObject(NodeCopy);

      ItemCopy := SourceNode.Item.Clone(SourceNode.Item.Owner);
      NodeCopy.Item := ItemCopy;
    end;
  end;
end;

procedure TfgFormItemsDesigner.ActionSortAscExecute(Sender: TObject);
begin
  TreeView.Sorted := True;
  TreeView.Sort(
    function(Left, Right: TFmxObject): Integer
    begin
      Result := CompareText(TTreeViewItem(Left).Text, TTreeViewItem(Right).Text);
    end);
end;

procedure TfgFormItemsDesigner.ActionSortDescExecute(Sender: TObject);
begin
  TreeView.Sorted := True;
  TreeView.Sort(
    function(Left, Right: TFmxObject): Integer
    begin
      Result := CompareText(TTreeViewItem(Right).Text, TTreeViewItem(Left).Text);
    end);
end;

function TfgFormItemsDesigner.AddTreeNode(const ARootNode: TFmxObject; const AItem: TFmxObject;
  const AItemInformation: TfgItemInformation; const AIndex: Integer = -1): TTreeViewItemWithData;
var
  Node: TTreeViewItemWithData;
begin
  AssertIsNotNil(AItem);
  AssertIsNotNil(ARootNode);
  AssertIsClass(AItem, TControl);

  Node := TTreeViewItemWithData.Create(Self);
  with Node do
  begin
    Item := AItem;
    Information := AItemInformation;
    StyleLookup := 'TreeViewItem_onelevel_Style';
    StylesData['description'] := AItem.ClassName;
    StylesData['visible.OnClick'] := TValue.From<TNotifyEvent>(HideItemHandler);
    StylesData['unvisible.OnClick'] := TValue.From<TNotifyEvent>(ShowItemHandler);
    UpdateNodeVisibilityButton(Node);
    Text := DefineItemCaption(AItem);
  end;
  if AIndex = -1 then
    ARootNode.AddObject(Node)
  else
    ARootNode.InsertObject(AIndex, Node);

  // TTreeView doesn't realign content, when we add new item. It's bug.
  TreeView.RealignContent;

  RefreshTotalCount;
  Result := Node;
end;

function TfgFormItemsDesigner.DefineItemCaption(const AItem: TFmxObject): string;
var
  Caption: string;
begin
  AssertIsNotNil(AItem);

  if GetPropInfo(AItem, 'text') <> nil then
    Caption := GetStrProp(AItem, 'text')
  else if GetPropInfo(AItem, 'caption') <> nil then
    Caption := GetStrProp(AItem, 'caption')
  else if GetPropInfo(AItem, 'title') <> nil then
    Caption := GetStrProp(AItem, 'title')
  else if GetPropInfo(AItem, 'header') <> nil then
    Caption := GetStrProp(AItem, 'header')
  else if AItem.Name <> '' then
    Caption := AItem.Name;

  if Caption.IsEmpty then
    Caption := rsNotNamed;

  Result := Caption;
end;

procedure TfgFormItemsDesigner.HideItemHandler(Sender: TObject);
begin
  SetItemVisible(Sender, False);
end;

procedure TfgFormItemsDesigner.ShowItemHandler(Sender: TObject);
begin
  SetItemVisible(Sender, True);
end;

procedure TfgFormItemsDesigner.FillClassItemsInfo;
var
  Item: TfgItemInformation;
begin
  AssertIsNotNil(FItemsList);

  // —крываем выбор класса итема, если есть всего один вариант
  ComboBoxItemsInfo.Visible := FItemsList.Count > 1;
  tbiClassesSeparator.Visible := FItemsList.Count > 1;

  ComboBoxItemsInfo.Clear;
  ComboBoxItemsInfo.BeginUpdate;
  try
    for Item in FItemsList do
      ComboBoxItemsInfo.Items.Add(Item.ItemClass.ClassName);
  finally
    ComboBoxItemsInfo.EndUpdate;
  end;
  ComboBoxItemsInfo.ItemIndex := 0;
end;

function TfgFormItemsDesigner.FindParentNode(const AObject: TFmxObject): TTreeViewItemWithData;
var
  Found: Boolean;
  CurrentObject: TFmxObject;
begin
  AssertIsNotNil(AObject);
  Found := False;
  CurrentObject := AObject;
  while not Found and (CurrentObject <> nil) do
  begin
    if CurrentObject is TTreeViewItemWithData then
      Found := True
    else
      CurrentObject := CurrentObject.Parent;
  end;
  if Found then
    Result := TTreeViewItemWithData(CurrentObject)
  else
    Result := nil;
end;

procedure TfgFormItemsDesigner.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TfgFormItemsDesigner.FormShow(Sender: TObject);
begin
  if HasComponent then
  begin
    FItemsList := TfgItemsManager.GetListByComponentClass(TFmxObjectClass(Component.GetObject.ClassType));
    FillClassItemsInfo;
    UpdateActions;
  end
  else
    raise Exception.Create('Cannot create Items designer without specified a component class');
end;

function TfgFormItemsDesigner.GetSelectedNode: TTreeViewItemWithData;
begin
  if TreeView.Selected is TTreeViewItemWithData then
    Result := TTreeViewItemWithData(TreeView.Selected)
  else
    Result := nil;
end;

function TfgFormItemsDesigner.HasComponent: Boolean;
begin
  Result := FComponent <> nil;
end;

procedure TfgFormItemsDesigner.RebuildTree;

  function FindItemInformation(const AItem: TFmxObject): TfgItemInformation;
  var
    ItemInf: TfgItemInformation;
  begin
    for ItemInf in FItemsList do
      if ItemInf.ItemClass = AItem.ClassType then
        Exit(ItemInf);
  end;

  procedure AddNode(const ARoot: TFmxObject; const AContainer: IItemsContainer);
  var
    I: Integer;
    Item: TFmxObject;
    Container: IItemsContainer;
    TreeItem: TTreeViewItem;
    Information: TfgItemInformation;
  begin
    for I := 0 to AContainer.GetItemsCount - 1 do
    begin
      Item := AContainer.GetItem(I);
      Information := FindItemInformation(Item);
      TreeItem := AddTreeNode(ARoot, Item, Information);
      if Supports(Item, IItemsContainer, Container) then
        AddNode(TreeItem, Container);
    end;
  end;

begin
  AssertIsNotNil(FComponent);

  TreeView.Clear;
  TreeView.BeginUpdate;
  try
    AddNode(TreeView, FComponent);
  finally
    TreeView.EndUpdate;
  end;

  if TreeView.Count > 0 then
    TreeView.Items[0].Select;
end;

procedure TfgFormItemsDesigner.RefreshTotalCount;
begin
  LabelTotalCount.Text := Format(rsTotalCount, [TreeView.GlobalCount]);
end;

procedure TfgFormItemsDesigner.ReselectItemComponent(const AItem: TFmxObject);
begin
  AssertIsNotNil(AItem);
  AssertIsNotNil(Designer);

  if Designer <> nil then
    Designer.SelectComponent(AItem);
end;

procedure TfgFormItemsDesigner.ScrollToSelectedNode;
var
  SavedSelected: TTreeViewItem;
begin
  // —местить окно просмотра, если итем не видно
  SavedSelected := TreeView.Selected;
  try
    TreeView.Selected := nil;
  finally
    TreeView.Selected := SavedSelected;
  end;
end;

procedure TfgFormItemsDesigner.SetComponent(const Value: IItemsContainer);
begin
  FComponent := Value;
  if HasComponent then
  begin
    FItemsList := TfgItemsManager.GetListByComponentClass(TFmxObjectClass(Component.GetObject.ClassType));
    FillClassItemsInfo;
    RebuildTree;
  end
  else
    TreeView.Clear;
end;

procedure TfgFormItemsDesigner.SetItemVisible(const ANodeStyleObject: TObject; const AVisible: Boolean);
var
  Node: TTreeViewItemWithData;
begin
  AssertIsNotNil(ANodeStyleObject);
  AssertIsNotNil(Designer);
  AssertIsClass(ANodeStyleObject, TFmxObject);

  Node := FindParentNode(TFmxObject(ANodeStyleObject));
  if Node <> nil then
  begin
    SetPropValue(Node.Item, 'visible', AVisible);
    Designer.Modified;
    UpdateNodeVisibilityButton(Node);
    Node.Select;
  end;
end;

procedure TfgFormItemsDesigner.SetNodeIndex(const ANode: TTreeViewItemWithData; const AIndex: Integer);
var
  Item: TFmxObject;
begin
  AssertIsNotNil(ANode);
  AssertIsNotNil(ANode.Item);
  AssertInRange(AIndex, 0, ANode.Parent.ChildrenCount - 1);
  AssertIsNotNil(TreeView);
  AssertIsNotNil(SelectedNode);
  AssertIsNotNil(Component);

  SelectedNode.Index := AIndex;
  Item := ANode.Item;
  Item.Index := AIndex;
  TreeView.RealignContent;

  if Component.GetObject is TControl then
    TControl(Component.GetObject).Repaint;
end;

procedure TfgFormItemsDesigner.TreeViewChange(Sender: TObject);
begin
  AssertIsNotNil(TreeView);
  AssertIsNotNil(Designer);

  if (SelectedNode <> nil) and (SelectedNode.Item <> nil) then
    ReselectItemComponent(SelectedNode.Item);

  UpdateActions;
end;

procedure TfgFormItemsDesigner.TreeViewKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if SelectedNode = nil then
    Exit;

  // Change visible of item
  if (Shift = []) and (Key = vkReturn) or (KeyChar = ' ') then
  begin
    if (SelectedNode.Item as TControl).Visible then
      HideItemHandler(SelectedNode)
    else
      ShowItemHandler(SelectedNode);
  end;

  // Add new item
  if (Key = vkReturn) and (ssShift in Shift) then
    ActionAdd.Execute;

  // Change order of selected item
  if ssCtrl in Shift then
  begin
    case Key of
      vkUp: ActionUp.Execute;
      vkDown: ActionDown.Execute;
      vkHome: ;
      vkEnd: ;
    end;
    Key := 0;
    KeyChar := #0;
  end;

  // Delete selected item
  if Key = vkDelete then
    ActionDelete.Execute;
end;

procedure TfgFormItemsDesigner.UpdateNodeVisibilityButton(const ANode: TTreeViewItemWithData);
var
  NodeVisible: Boolean;
begin
  AssertIsNotNil(ANode);
  AssertIsNotNil(ANode.Item);
  AssertIsClass(ANode.Item, TControl);

  NodeVisible := TControl(ANode.Item).Visible;
  ANode.StylesData['visible.visible'] := NodeVisible;
  ANode.StylesData['unvisible.visible'] := not NodeVisible;
end;

end.
