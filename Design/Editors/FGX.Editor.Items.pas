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

unit FGX.Editor.Items;

interface

uses
  DesignEditors, DesignMenus, DesignIntf, System.Classes, System.Generics.Collections, FGX.Designer.Items, FGX.Items;

resourcestring
  rsItemsEditor = 'Items Editor...';

type

{ TfgItemsEditor }

  TfgItemsEditor = class(TComponentEditor)
  protected
    FAllowChild: Boolean;
    FItemsClasses: TList<TfgItemInformation>;
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
  System.SysUtils, FMX.Types, FGX.Toolbar;

constructor TfgItemsEditor.Create(AComponent: TComponent; ADesigner: IDesigner);
begin
  inherited;
  FItemsClasses := TList<TfgItemInformation>.Create;
end;

destructor TfgItemsEditor.Destroy;
begin
  FItemsClasses.Free;
  inherited;
end;

procedure TfgItemsEditor.DoCreateItem(Sender: TObject);
begin

end;

procedure TfgItemsEditor.Edit;
begin
  ExecuteVerb(0);
end;

procedure TfgItemsEditor.ExecuteVerb(Index: Integer);
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

function TfgItemsEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := rsItemsEditor;
  end;
end;

function TfgItemsEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TfgItemsEditor.PrepareItem(Index: Integer; const AItem: IMenuItem);
begin
  inherited;

end;

end.
