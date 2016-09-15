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

{$IF Defined(VER290) or Defined(VER300)}
  rsStyleObjectsCommon = 'Style Objects: Common';
  rsStyleObjectsSwitch = 'Style Objects: Switch';
  rsStyleObjectsTabControl = 'Style Objects: TabControl';
  rsStyleObjectsButton = 'Style Objects: Button';
  rsStyleObjectsTint = 'Style Objects: Tint';
  rsStyleObjectsCheck = 'Style Objects: Check, RadioButton, CheckBox';
  rsStyleObjectsData = 'Style Objects: Data storing';
{$ELSE}
  rsStyleObjects = 'Styles';
{$ENDIF}

procedure Register;

implementation

uses
  System.Classes,
  DesignIntf,
  FMX.Graphics, FMX.Styles.Objects, FMX.Styles.Switch,
  FGX.ActionSheet, FGX.VirtualKeyboard, FGX.ProgressDialog, FGX.GradientEdit, FGX.BitBtn, FGX.Toolbar,
  FGX.ColorsPanel, FGX.LinkedLabel, FGX.FlipView, FGX.ApplicationEvents, FGX.Animations,
  FGX.Items, FGX.Consts,
  FGX.Editor.Items, FMX.Styles;

procedure Register;
begin
  { Components Registration }
  RegisterComponents(rsCategoryExtended, [
    TfgActionSheet,
    TfgActivityDialog,
    TfgApplicationEvents,
    TfgBitBtn,
    TfgColorsPanel,
    TfgFlipView,
    TfgGradientEdit,
    TfgLinkedLabel,
    TfgProgressDialog,
    TfgToolBar,
    TfgVirtualKeyboard
    ]);

  RegisterComponents(rsAnimations, [
    TfgPositionAnimation,
    TfgPosition3DAnimation,
    TfgBitmapLinkAnimation
    ]);

{$IF Defined(VER290) or Defined(VER300)}
  // Common
  RegisterComponents(rsStyleObjectsCommon, [TStyleObject, TActiveStyleObject, TMaskedImage, TActiveMaskedImage,
    TStyleTextObject, TActiveStyleTextObject, TActiveOpacityObject]);

  // RadioButton, CheckBox
  RegisterComponents(rsStyleObjectsCheck, [TCheckStyleObject]);

  // Tint
  RegisterComponents(rsStyleObjectsTint, [TTintedStyleObject, TTintedButtonStyleObject]);

  // Button
  RegisterComponents(rsStyleObjectsTabControl, [TButtonStyleObject, TSystemButtonObject, TButtonStyleTextObject]);

  // TabControl
  RegisterComponents(rsStyleObjectsTabControl, [TTabStyleObject, TTabStyleTextObject]);

  // Data storing
  RegisterComponents(rsStyleObjectsData, [TBrushObject, TBitmapObject, TFontObject, TPathObject, TColorObject]);

  // Switch
  RegisterComponents(rsStyleObjectsSwitch, [TSwitchTextObject, TSwitchObject, TBitmapSwitchObject]);
{$ELSE}
  RegisterComponents(rsStyleObjects, [TStyleTextAnimation, TSubImage, TSwitchTextObject, TSwitchObject,
    TBitmapSwitchObject, TBrushObject, TBitmapObject, TFontObject, TPathObject, TColorObject]);
{$ENDIF}
end;

end.
