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
  Androidapi.JNI.App;

{ Dialogs }

  procedure ShowDialog(ADialog: JDialog; const ADialogID: Integer);
  procedure HideDialog(ADialog: JDialog; const ADialogID: Integer);

implementation

uses
  FMX.Helpers.Android, FMX.Platform.Android;

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

end.
