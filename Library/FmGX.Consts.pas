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

unit FmGX.Consts;

interface

uses
  System.Classes;

const
  UNDEFINED = -1;

  { Additional Component Platforms Attribute flags for using in [ComponentPlatformsAttribute] }
  
  fgDesktopPlatforms = pidWin32 or pidWin64 or pidOSX32 or pidLinux32 or pidLinux64;
  fgMobilePlatforms = pidAndroid or pidiOSDevice32 or pidiOSDevice64 or pidiOSSimulator;
  fgAllPlatform = fgDesktopPlatforms or fgMobilePlatforms;

implementation

end.
