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

unit FmGX.StylesDataModule;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls;

type
  TStyleDataModule = class(TDataModule)
    StyleBook: TStyleBook;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  StyleDataModule: TStyleDataModule;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

end.
