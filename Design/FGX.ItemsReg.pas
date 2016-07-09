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

unit FGX.ItemsReg;

interface

procedure Register;

implementation

uses
  DesignIntf, FMX.Header, FMX.Menus, FMX.TreeView, FMX.SearchBox, FMX.ListBox, FMX.Edit, FMX.Grid, FGX.GradientEdit,
  FGX.Editor.Items, FGX.Items, FGX.Toolbar;

procedure Register;
begin
{$IFDEF REGISTER_ITEMS_DESIGNER}
  { Registration Class of Items for Item Editor }
  TfgItemsManager.RegisterItems(TfgToolBar, [TfgToolBarButton, TfgToolBarPopupButton, TfgToolBarSeparator,
                                             TfgToolBarDivider, TfgToolBarComboBox]);
  TfgItemsManager.RegisterItems(TfgToolBarComboBox, [TListBoxItem, TMetropolisUIListBoxItem,
                                                     TListBoxHeader, TSearchBox, TListBoxGroupHeader,
                                                     TListBoxGroupFooter]);

  { Register Items designer for standard controls }
  TfgItemsManager.RegisterItems(TListBox, [TListBoxItem, TMetropolisUIListBoxItem, TListBoxHeader, TSearchBox,
                                           TListBoxGroupHeader, TListBoxGroupFooter]);
  TfgItemsManager.RegisterItem(TTreeView, TfgItemInformation.Create(TTreeViewItem, True));
  TfgItemsManager.RegisterItems(TEdit, [TEditButton, TClearEditButton, TPasswordEditButton, TSearchEditButton,
                                        TEllipsesEditButton, TDropDownEditButton, TSpinEditButton]);
  TfgItemsManager.RegisterItems(TComboBox, [TListBoxItem, TMetropolisUIListBoxItem, TListBoxHeader, TSearchBox,
                                           TListBoxGroupHeader, TListBoxGroupFooter]);
  TfgItemsManager.RegisterItems(TStringGrid, [TStringColumn]);
  TfgItemsManager.RegisterItems(TGrid, [TColumn, TCheckColumn, TStringColumn, TProgressColumn, TPopupColumn,
                                        TImageColumn, TDateColumn, TTimeColumn]);
  TfgItemsManager.RegisterItems(THeader, [THeaderItem]);
  TfgItemsManager.RegisterItem(TPopupMenu, TfgItemInformation.Create(TMenuItem, True));
  TfgItemsManager.RegisterItem(TMenuBar, TfgItemInformation.Create(TMenuItem, True));
  TfgItemsManager.RegisterItem(TMainMenu, TfgItemInformation.Create(TMenuItem, True));

  { Component Editors }
  RegisterComponentEditor(TfgToolBar, TfgItemsEditor);
  RegisterComponentEditor(TfgToolBarComboBox, TfgItemsEditor);

  RegisterComponentEditor(TListBox, TfgItemsEditor);
  RegisterComponentEditor(TTreeView, TfgItemsEditor);
  RegisterComponentEditor(TEdit, TfgItemsEditor);
  RegisterComponentEditor(TComboBox, TfgItemsEditor);
  RegisterComponentEditor(TStringGrid, TfgItemsEditor);
  RegisterComponentEditor(TGrid, TfgItemsEditor);
  RegisterComponentEditor(THeader, TfgItemsEditor);
  RegisterComponentEditor(TPopupMenu, TfgItemsEditor);
  RegisterComponentEditor(TMenuBar, TfgItemsEditor);
  RegisterComponentEditor(TMainMenu, TfgItemsEditor);
{$ENDIF}
end;

end.
