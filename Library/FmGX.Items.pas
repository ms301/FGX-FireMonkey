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

unit FmGX.Items;

interface

uses
  System.Classes, System.Generics.Collections, FMX.Types;

type

{ TfgItemsManager }

  TfgxItemInformation = record
    ItemClass: TFmxObjectClass;
    Description: string;
    AcceptsChildItems: Boolean;
    constructor Create(const AItemClass: TFmxObjectClass; const AAcceptsChildItems: Boolean = False); overload;
    constructor Create(const AItemClass: TFmxObjectClass; const ADescription: string); overload;
  end;

  /// <summary>
  ///   Менеджер для хранения соответствия класса компонента и набора поддерживаемых итемов. Позволяет регистрировать
  ///   собственные классы итемов и использовать дизайнер итемов для своих компонентов, поскольку штатный редактор
  ///   итемов FireMonkey не дает такой возможности.
  /// </summary>
  /// <remarks>
  ///   Для дизайнера итемов.
  /// </remarks>
  TfgxItemsManager = class
  private
    class var FDictionary: TObjectDictionary<TComponentClass, TList<TfgxItemInformation>>;
    class constructor Create;
    class destructor Destroy;
  public
    class procedure RegisterItem(const AComponentClass: TFmxObjectClass; const AItemInformation: TfgxItemInformation);
    class procedure RegisterItems(const AComponentClass: TFmxObjectClass; const AItemsInformations: array of TfgxItemInformation); overload;
    class procedure RegisterItems(const AComponentClass: TFmxObjectClass; const AItemsClasses: array of TFmxObjectClass); overload;
    class procedure UnregisterItem(const AComponentClass: TFmxObjectClass; const AItemInformation: TfgxItemInformation);
    class procedure UnregisterItems(const AComponentClass: TFmxObjectClass; const AItemsInformations: array of TfgxItemInformation);
    class function GetListByComponentClass(const AComponentClass: TFmxObjectClass): TList<TfgxItemInformation>;
  end;

implementation

uses
  System.SysUtils, FmGX.Asserts;

{ TfgItemInformation }

constructor TfgxItemInformation.Create(const AItemClass: TFmxObjectClass; const AAcceptsChildItems: Boolean = False);
begin
  TfgxAssert.IsNotNil(AItemClass, 'Класс итема обязательно должен быть указан');

  Self.ItemClass := AItemClass;
  Self.AcceptsChildItems := AAcceptsChildItems;
end;

constructor TfgxItemInformation.Create(const AItemClass: TFmxObjectClass; const ADescription: string);
begin
  TfgxAssert.IsNotNil(AItemClass, 'Класс итема обязательно должен быть указан');

  Self.ItemClass := AItemClass;
  Self.Description := ADescription;
end;

{ TfgItemsManager }

class constructor TfgxItemsManager.Create;
begin
  FDictionary := TObjectDictionary<TComponentClass, TList<TfgxItemInformation>>.Create([doOwnsValues]);
end;

class destructor TfgxItemsManager.Destroy;
begin
  FreeAndNil(FDictionary);
end;

class function TfgxItemsManager.GetListByComponentClass(const AComponentClass: TFmxObjectClass): TList<TfgxItemInformation>;
begin
  TfgxAssert.IsNotNil(FDictionary);

  Result := nil;
  FDictionary.TryGetValue(AComponentClass, Result);
end;

class procedure TfgxItemsManager.RegisterItem(const AComponentClass: TFmxObjectClass; const AItemInformation: TfgxItemInformation);

  function AlreadyRegisteredIn(const AList: TList<TfgxItemInformation>): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to AList.Count - 1 do
      if AList[I].ItemClass = AItemInformation.ItemClass then
        Exit(True);
  end;

var
  List: TList<TfgxItemInformation>;
begin
  TfgxAssert.IsNotNil(FDictionary);
  TfgxAssert.IsNotNil(AComponentClass);

  if FDictionary.TryGetValue(AComponentClass, List) then
  begin
    if not AlreadyRegisteredIn(List) then
      List.Add(AItemInformation);
  end
  else
  begin
    List := TList<TfgxItemInformation>.Create;
    List.Add(AItemInformation);
    FDictionary.Add(AComponentClass, List);
  end;
end;

class procedure TfgxItemsManager.RegisterItems(const AComponentClass: TFmxObjectClass;
  const AItemsClasses: array of TFmxObjectClass);
var
  ItemClass: TFmxObjectClass;
begin
  TfgxAssert.IsNotNil(FDictionary);
  TfgxAssert.IsNotNil(AComponentClass);

  for ItemClass in AItemsClasses do
    RegisterItem(AComponentClass, TfgxItemInformation.Create(ItemClass));
end;

class procedure TfgxItemsManager.RegisterItems(const AComponentClass: TFmxObjectClass; const AItemsInformations: array of TfgxItemInformation);
var
  Item: TfgxItemInformation;
begin
  TfgxAssert.IsNotNil(FDictionary);
  TfgxAssert.IsNotNil(AComponentClass);

  for Item in AItemsInformations do
    RegisterItem(AComponentClass, Item);
end;

class procedure TfgxItemsManager.UnregisterItem(const AComponentClass: TFmxObjectClass; const AItemInformation: TfgxItemInformation);
var
  List: TList<TfgxItemInformation>;
begin
  TfgxAssert.IsNotNil(FDictionary);
  TfgxAssert.IsNotNil(AComponentClass);

  if FDictionary.TryGetValue(AComponentClass, List) then
  begin
    List.Remove(AItemInformation);
    if List.Count = 0 then
      FDictionary.Remove(AComponentClass);
  end;
end;

class procedure TfgxItemsManager.UnregisterItems(const AComponentClass: TFmxObjectClass; const AItemsInformations: array of TfgxItemInformation);
var
  Item: TfgxItemInformation;
begin
  TfgxAssert.IsNotNil(AComponentClass);

  for Item in AItemsInformations do
    UnregisterItem(AComponentClass, Item);
end;

end.
