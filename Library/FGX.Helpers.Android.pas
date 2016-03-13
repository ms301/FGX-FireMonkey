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

implementation

uses
  FMX.Helpers.Android, FMX.Platform.Android, FMX.Surfaces, FGX.Asserts;

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
  AssertIsNotNil(ABitmap);

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

end.
