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

unit FGX.Helpers.Android;

interface

uses
  System.UITypes, Androidapi.JNI.App, Androidapi.JNI.GraphicsContentViewText, FMX.Graphics;

{ Dialogs }

  procedure ShowDialog(ADialog: JDialog; const ADialogID: Integer);
  procedure HideDialog(ADialog: JDialog; const ADialogID: Integer);

{ Conversionse }

  function AlphaColorToJColor(const AColor: TAlphaColor): Integer;

  function BitmapToJBitmap(const ABitmap: TBitmap): JBitmap;

  function GetNativeTheme(const AOwner: TObject): Integer;

implementation

uses
  System.Classes, FMX.Helpers.Android, FMX.Platform.Android, FMX.Surfaces, FMX.Forms, FMX.Styles, FMX.Controls,
  FGX.Asserts, System.SysUtils;

procedure ShowDialog(ADialog: JDialog; const ADialogID: Integer);
begin
  if IsGingerbreadDevice then
    MainActivity.showDialog(ADialogID, ADialog)
  else
    ADialog.show;
end;

procedure HideDialog(ADialog: JDialog; const ADialogID: Integer);
begin
  if IsGingerbreadDevice then
  begin
    MainActivity.dismissDialog(ADialogID);
    MainActivity.removeDialog(ADialogID);
  end
  else
    ADialog.dismiss;
end;

function AlphaColorToJColor(const AColor: TAlphaColor): Integer;
begin
  Result := TJColor.JavaClass.argb(TAlphaColorRec(AColor).A, TAlphaColorRec(AColor).R, TAlphaColorRec(AColor).G, TAlphaColorRec(AColor).B)
end;

function BitmapToJBitmap(const ABitmap: TBitmap): JBitmap;
var
  BitmapSurface: TBitmapSurface;
begin
  TfgAssert.IsNotNil(ABitmap);

  Result := TJBitmap.JavaClass.createBitmap(ABitmap.Width, ABitmap.Height, TJBitmap_Config.JavaClass.ARGB_8888);
  BitmapSurface := TBitmapSurface.Create;
  try
    BitmapSurface.Assign(ABitmap);
    if not SurfaceToJBitmap(BitmapSurface, Result) then
      Result := nil;
  finally
    BitmapSurface.Free;
  end;
end;

function FindForm(const AOwner: TObject): TCommonCustomForm;
var
  OwnerTmp: TComponent;
begin
  Result := nil;
  if AOwner is TComponent then
  begin
    OwnerTmp := TComponent(AOwner);
    while not (OwnerTmp is TCommonCustomForm) and (OwnerTmp <> nil) do
      OwnerTmp := OwnerTmp.Owner;
    if OwnerTmp is TCommonCustomForm then
      Result := TCommonCustomForm(OwnerTmp);
  end;
end;

const
  ANDROID_LIGHT_THEME = '[LIGHTSTYLE]';
  ANDROID_DARK_THEME = '[DARKSTYLE]';

function IsGingerbreadDevice: Boolean;
begin
  Result := TOSVersion.Major = 2;
end;

function GetThemeFromDescriptor(ADescriptor: TStyleDescription): Integer;
begin
  Result := 0;
  if ADescriptor <> nil then
  begin
    if ADescriptor.PlatformTarget.Contains(ANDROID_LIGHT_THEME) then
      Result := TJAlertDialog.JavaClass.THEME_HOLO_LIGHT;
    if ADescriptor.PlatformTarget.Contains(ANDROID_DARK_THEME) then
      Result := TJAlertDialog.JavaClass.THEME_HOLO_DARK;
  end;
end;

function GetNativeTheme(const AOwner: TObject): Integer;
var
  Form: TCommonCustomForm;
  LStyleDescriptor: TStyleDescription;
begin
  Form := FindForm(AOwner);
  if Form <> nil then
  begin
    if Form.StyleBook <> nil then
      LStyleDescriptor := TStyleManager.FindStyleDescriptor(Form.StyleBook.Style)
    else
      LStyleDescriptor := TStyleManager.FindStyleDescriptor(TStyleManager.ActiveStyleForScene(Form as IScene));
    Result := GetThemeFromDescriptor(LStyleDescriptor);
  end
  else
    Result := TJAlertDialog.JavaClass.THEME_HOLO_LIGHT;
end;

end.
