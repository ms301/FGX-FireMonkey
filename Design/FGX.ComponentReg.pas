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

unit FGX.ComponentReg;

interface

resourcestring
  rsCategoryExtended = 'FGX: Extended FM Controls';
  rsAnimations = 'FGX: Animations';
  rsStyleObjects = 'FGX: Style objects';

procedure Register;

implementation

uses
  System.Classes, DesignIntf,
  FMX.Graphics, FMX.Styles.Objects, FMX.Styles.Switch,
  FGX.ActionSheet, FGX.VirtualKeyboard, FGX.ProgressDialog, FGX.GradientEdit, FGX.ColorsPanel, FGX.LinkedLabel,
  FGX.ApplicationEvents,
  FGX.Items, FGX.Consts;

procedure Register;
begin
  { Components Registration }
  RegisterComponents(rsCategoryExtended, [TfgActionSheet, TfgVirtualKeyboard, TfgProgressDialog, TfgActivityDialog,
    TfgGradientEdit, TfgColorsPanel, TfgLinkedLabel, TfgApplicationEvents]);

  RegisterComponents(rsStyleObjects, [TStyleObject, TSubImage, TActiveStyleObject, TTabStyleObject, TCheckStyleObject,
    TButtonStyleObject, TSystemButtonObject, TStyleTextObject, TStyleTextAnimation,
    TActiveStyleTextObject, TTabStyleTextObject, TButtonStyleTextObject, TActiveOpacityObject,
    TBrushObject, TBitmapObject, TFontObject, TPathObject, TColorObject,
    // New XE6 objects
    TTintedButtonStyleObject, TTintedStyleObject, TMaskedImage, TActiveMaskedImage,
    TSwitchTextObject, TCustomSwitchObject, TSwitchObject, TBitmapSwitchObject
    ]);
end;

end.
