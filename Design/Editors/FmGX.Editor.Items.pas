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

unit FmGX.Editor.Items;

interface

uses
  DesignEditors, DesignMenus, DesignIntf, System.Classes, System.Generics.Collections, FmGX.Designer.Items, FmGX.Items;

resourcestring
  rsItemsEditor = 'Items Editor...';

type

{ TfgItemsEditor }

  TfgxItemsEditor = class(TComponentEditor)
  protected
    FAllowChild: Boolean;
    FItemsClasses: TList<TfgxItemInformation>;
    FForm: TfgFormItemsDesigner;
    procedure DoCreateItem(Sender: TObject); virtual;
  public
    constructor Create(AComponent: TComponent; ADesigner: IDesigner); override;
    destructor Destroy; override;
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
    procedure PrepareItem(Index: Integer; const AItem: IMenuItem); override;
    procedure Edit; override;
  end;

implementation

{ TItemsEditor }

uses
  System.SysUtils, FMX.Types, FmGX.Toolbar;

constructor TfgxItemsEditor.Create(AComponent: TComponent; ADesigner: IDesigner);
begin
  inherited;
  FItemsClasses := TList<TfgxItemInformation>.Create;
end;

destructor TfgxItemsEditor.Destroy;
begin
  FItemsClasses.Free;
  inherited;
end;

procedure TfgxItemsEditor.DoCreateItem(Sender: TObject);
begin

end;

procedure TfgxItemsEditor.Edit;
begin
  ExecuteVerb(0);
end;

procedure TfgxItemsEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0:
      if Supports(Component, IItemsContainer) then
      begin
        if FForm = nil then
          FForm := TfgFormItemsDesigner.Create(nil);
        FForm.Designer := Designer;
        FForm.Component := Component as IItemsContainer;
        FForm.Show;
      end;
  end;
end;

function TfgxItemsEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := rsItemsEditor;
  end;
end;

function TfgxItemsEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TfgxItemsEditor.PrepareItem(Index: Integer; const AItem: IMenuItem);
begin
  inherited;

end;

end.
