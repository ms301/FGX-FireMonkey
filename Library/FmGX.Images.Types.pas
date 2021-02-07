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

unit FmGX.Images.Types;

interface

uses
  System.Classes, FMX.Graphics, FmGX.Types;

type

  { TfgImageCollection }

  TfgxImageCollectionItem = class;

  TfgxImageCollection = class(TfgxCollection)
  private
    function GetImageCollectionItem(const Index: Integer): TfgxImageCollectionItem; overload;
    function GetImageCollectionItem(const Index: string): TfgxImageCollectionItem; overload;
  public
    function AddImage(const ABitmap: TBitmap; const AName: string): TfgxImageCollectionItem; overload;
    function AddImage: TfgxImageCollectionItem; overload;
    property Images[const Index: Integer]: TfgxImageCollectionItem read GetImageCollectionItem; default;
    property Images[const Index: string]: TfgxImageCollectionItem read GetImageCollectionItem; default;
  end;

  { TfgImageCollectionItem }

  TfgxImageCollectionItem = class(TCollectionItem)
  strict private
    FBitmap: TBitmap;
    FName: string;
    procedure SetName(const Value: string);
    procedure SetBitmap(const Value: TBitmap);
    procedure HandlerBitmapChanged(Sender: TObject);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property Bitmap: TBitmap read FBitmap write SetBitmap;
    property Name: string read FName write SetName;
  end;

implementation

uses
  System.SysUtils;

{ TfgImageCollectionItem }

constructor TfgxImageCollectionItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FBitmap := TBitmap.Create(0, 0);
  FBitmap.OnChange := HandlerBitmapChanged;
end;

destructor TfgxImageCollectionItem.Destroy;
begin
  FBitmap.Free;
  inherited Destroy;
end;

function TfgxImageCollectionItem.GetDisplayName: string;
var
  DefaultName: string;
begin
  if Name.IsEmpty then
    DefaultName := inherited
  else
    DefaultName := Name;

  if Bitmap.IsEmpty then
    Result := Format('[Empty] - %s ', [DefaultName])
  else
    Result := Format('[%d x %d] - %s ', [Bitmap.Width, Bitmap.Height, DefaultName]);
end;

procedure TfgxImageCollectionItem.HandlerBitmapChanged(Sender: TObject);
begin
  Changed(False);
end;

procedure TfgxImageCollectionItem.SetBitmap(const Value: TBitmap);
begin
  FBitmap.Assign(Value);
end;

procedure TfgxImageCollectionItem.SetName(const Value: string);
begin
  if Name <> Value then
  begin
    FName := Value;
    Changed(False);
  end;
end;

{ TfgImageCollection }

function TfgxImageCollection.GetImageCollectionItem(const Index: Integer): TfgxImageCollectionItem;
begin
  Result := Items[Index] as TfgxImageCollectionItem;
end;

function TfgxImageCollection.AddImage(const ABitmap: TBitmap; const AName: string): TfgxImageCollectionItem;
begin
  Result := Add as TfgxImageCollectionItem;
  Result.Bitmap := ABitmap;
  Result.Name := AName;
end;

function TfgxImageCollection.AddImage: TfgxImageCollectionItem;
begin
  Result := Add as TfgxImageCollectionItem;
end;

function TfgxImageCollection.GetImageCollectionItem(const Index: string): TfgxImageCollectionItem;
var
  Found: Boolean;
  I: Integer;
begin
  Found := False;
  I := 0;
  while (I < Count) and not Found do
    if string.Compare(Images[I].Name, Index, True ) <> 0 then
      Found := True
    else
      Inc(I);

  if Found then
    Result := Images[I]
  else
    Result := nil;
end;

end.
