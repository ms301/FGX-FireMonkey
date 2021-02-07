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

unit FmGX.LinkedLabel;

interface

uses
  System.Classes, System.UITypes, FMX.StdCtrls, FMX.Controls, FMX.Objects, FMX.Types, FmGX.Consts;

type

{ TfgLinkedLabel }

  IFGXLaunchService = interface;

  TfgCustomLinkedLabel = class(TLabel)
  public const
    DefaultCursor = crHandPoint;
    DefaultColor = TAlphaColorRec.Black;
    DefaultColorHover = TAlphaColorRec.Blue;
    DefaultColorVisited = TAlphaColorRec.Magenta;
    DefaultVisited = False;
  private const
    IndexColor = 0;
    IndexHoverColor = 1;
    IndexVisitedColor = 2;
  private
    FLaunchService: IFGXLaunchService;
    FUrl: string;
    FVisited: Boolean;
    FColor: TAlphaColor;
    FHoverColor: TAlphaColor;
    FVisitedColor: TAlphaColor;
    procedure SetColor(const Index: Integer; const Value: TAlphaColor);
    procedure SetVisited(const Value: Boolean);
  protected
    { Styles }
    function GetDefaultStyleLookupName: string; override;
    { Painting }
    procedure Paint; override;
    { Mouse events }
    procedure DoMouseEnter; override;
    procedure DoMouseLeave; override;
    procedure Click; override;
    procedure UpdateColor;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  public
    property Color: TAlphaColor index IndexColor read FColor write SetColor default DefaultColor;
    property HoverColor: TAlphaColor index IndexHoverColor read FHoverColor write SetColor default DefaultColorHover;
    property Url: string read FUrl write FUrl;
    property Cursor default DefaultCursor;
    property Visited: Boolean read FVisited write SetVisited default DefaultVisited;
    property VisitedColor: TAlphaColor index IndexVisitedColor read FVisitedColor write SetColor default DefaultColorVisited;
  end;

  [ComponentPlatformsAttribute(fgAllPlatform)]
  TfgLinkedLabel = class(TfgCustomLinkedLabel)
  published
    property Cursor;
    property Color;
    property HoverColor;
    property Url;
    property VisitedColor;
    property Visited;
  end;

{ IFMXLaunchService }

  IFGXLaunchService = interface
  ['{5BFFA845-EB02-480C-AFE9-EB15DE06AF10}']
    function OpenURL(const AUrl: string): Boolean;
  end;

implementation

uses
  FMX.Platform
{$IFDEF MSWINDOWS}
  , FmGX.LinkedLabel.Win
{$ENDIF}
{$IFDEF IOS}
  , FmGX.LinkedLabel.iOS
{$ELSE}
{$IFDEF MACOS}
  , FmGX.LinkedLabel.Mac
{$ENDIF}
{$ENDIF}
{$IFDEF ANDROID}
  , FmGX.LinkedLabel.Android
{$ENDIF}
  ;

{ TLinkedLabel }

procedure TfgCustomLinkedLabel.Click;
begin
  if FLaunchService <> nil then
  begin
    FVisited := True;
    Repaint;
    FLaunchService.OpenURL(Url);
  end;
end;

constructor TfgCustomLinkedLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  HitTest := True;
  Font.Style := [TFontStyle.fsUnderline];
  StyledSettings := [];
  Cursor := DefaultCursor;
  FVisited := DefaultVisited;
  FColor := DefaultColor;
  FHoverColor := DefaultColorHover;
  FVisitedColor := DefaultColorVisited;

  TPlatformServices.Current.SupportsPlatformService(IFGXLaunchService, FLaunchService);
end;

destructor TfgCustomLinkedLabel.Destroy;
begin
  FLaunchService := nil;
  inherited Destroy;
end;

procedure TfgCustomLinkedLabel.DoMouseEnter;
begin
  inherited DoMouseEnter;
  Repaint;
end;

procedure TfgCustomLinkedLabel.DoMouseLeave;
begin
  inherited DoMouseLeave;
  Repaint;
end;

function TfgCustomLinkedLabel.GetDefaultStyleLookupName: string;
begin
  Result := 'LabelStyle';
end;

procedure TfgCustomLinkedLabel.Paint;
begin
  UpdateColor;
  inherited Paint;
end;

procedure TfgCustomLinkedLabel.SetColor(const Index: Integer; const Value: TAlphaColor);
begin
  case Index of
    IndexColor: FColor := Value;
    IndexHoverColor: FHoverColor := Value;
    IndexVisitedColor: FVisitedColor := Value;
  end;
  Repaint;
end;

procedure TfgCustomLinkedLabel.SetVisited(const Value: Boolean);
begin
  if Visited <> Value then
  begin
    FVisited := Value;
    UpdateColor;
  end;
end;

procedure TfgCustomLinkedLabel.UpdateColor;
begin
  if IsMouseOver then
    TextSettings.FontColor := FHoverColor
  else if FVisited then
    TextSettings.FontColor := FVisitedColor
  else
    TextSettings.FontColor := Color;
end;

initialization
  RegisterFmxClasses([TfgCustomLinkedLabel, TfgLinkedLabel]);
  RegisterService;
finalization
  UnregisterService;
end.
