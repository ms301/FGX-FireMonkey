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

unit FmGX.ComponentReg;

interface

{$I 'jedi.inc'}

resourcestring
  rsCategoryExtended = 'FGX: Extended FM Controls';
  rsAnimations = 'FGX: Animations';

{$IF Defined(DELPHIXE8_UP)}
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
  FmGX.ActionSheet, FmGX.VirtualKeyboard, FmGX.ProgressDialog, FmGX.GradientEdit, FmGX.BitBtn, FmGX.Toolbar,
  FmGX.ColorsPanel, FmGX.LinkedLabel, FmGX.FlipView, FmGX.ApplicationEvents, FmGX.Animations,
  FmGX.Items, FmGX.Consts,
  FmGX.Editor.Items, FMX.Styles;

procedure Register;
begin
  { Components Registration }
  RegisterComponents(rsCategoryExtended, [
    TfgxActionSheet,
    TfgxActivityDialog,
    TfgxApplicationEvents,
    TfgxBitBtn,
    TfgxColorsPanel,
    TfgxFlipView,
    TfgxGradientEdit,
    TfgLinkedLabel,
    TfgxProgressDialog,
    TfgToolBar,
    TfgxVirtualKeyboard
    ]);

  RegisterComponents(rsAnimations, [
    TfgxPositionAnimation,
    TfgxPosition3DAnimation,
    TfgxBitmapLinkAnimation
    ]);

{$IF Defined(DELPHIXE8_UP)}
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
