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

unit MainFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Variants, System.Classes,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FGX.FlipView, FMX.Ani, FMX.Effects,
  FMX.Filter.Effects, FMX.ListView.Types, FMX.ListView, FMX.Edit, FMX.ListBox, FMX.NumberBox, FMX.Controls.Presentation,
  FMX.EditBox, FMX.ScrollBox, FMX.Memo, FMX.Gestures, FMX.Layouts, FMX.MultiView;

type
  TFormMain = class(TForm)
    fgFlipView: TfgFlipView;
    nbSlideShowDuration: TNumberBox;
    cbMode: TComboBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    cbEffectDuration: TNumberBox;
    cbEffect: TComboBox;
    cbSlideDirection: TComboBox;
    nbSlideDuration: TNumberBox;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxItem7: TListBoxItem;
    ListBoxItem8: TListBoxItem;
    ListBoxItem9: TListBoxItem;
    ListBoxItem10: TListBoxItem;
    ListBoxItem11: TListBoxItem;
    ListBoxItem12: TListBoxItem;
    ListBoxItem13: TListBoxItem;
    ListBoxItem14: TListBoxItem;
    ListBoxItem15: TListBoxItem;
    ListBoxItem16: TListBoxItem;
    ListBoxItem17: TListBoxItem;
    ListBoxItem18: TListBoxItem;
    ListBoxItem19: TListBoxItem;
    ListBoxItem20: TListBoxItem;
    ListBoxItem21: TListBoxItem;
    ListBoxItem22: TListBoxItem;
    ListBoxItem23: TListBoxItem;
    ListBoxItem24: TListBoxItem;
    ListBoxItem25: TListBoxItem;
    ListBoxItem26: TListBoxItem;
    ListBoxItem27: TListBoxItem;
    Memo1: TMemo;
    GestureManager1: TGestureManager;
    MultiView1: TMultiView;
    ListBox1: TListBox;
    ListBoxGroupHeader1: TListBoxGroupHeader;
    ListBoxItem5: TListBoxItem;
    ListBoxItem6: TListBoxItem;
    ListBoxItem28: TListBoxItem;
    ListBoxItem29: TListBoxItem;
    ListBoxGroupHeader2: TListBoxGroupHeader;
    ListBoxItem30: TListBoxItem;
    ListBoxItem31: TListBoxItem;
    ListBoxGroupHeader3: TListBoxGroupHeader;
    ListBoxItem32: TListBoxItem;
    swSlideShow: TSwitch;
    MultiView2: TMultiView;
    ListBoxItem33: TListBoxItem;
    swShowNavigationButtons: TSwitch;
    SpeedButton1: TSpeedButton;
    procedure nbSlideShowDurationChange(Sender: TObject);
    procedure cbModeChange(Sender: TObject);
    procedure cbEffectChange(Sender: TObject);
    procedure cbEffectDurationChange(Sender: TObject);
    procedure nbSlideDurationChange(Sender: TObject);
    procedure cbSlideDirectionChange(Sender: TObject);
    procedure fgFlipViewStartChanging(Sender: TObject; const NewItemIndex: Integer);
    procedure fgFlipViewFinishChanging(Sender: TObject);
    procedure swSlideShowSwitch(Sender: TObject);
    procedure MultiView1PresenterChanging(Sender: TObject; var PresenterClass: TMultiViewPresentationClass);
    procedure FormCreate(Sender: TObject);
    procedure swShowNavigationButtonsSwitch(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure fgFlipViewImageClick(Sender: TObject; const AFlipView: TfgCustomFlipView; const AImageIndex: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

uses
  FGX.FlipView.Types, FMX.MultiView.Presentations;

{$R *.fmx}

procedure TFormMain.cbEffectChange(Sender: TObject);
begin
  fgFlipView.EffectOptions.Kind := TfgTransitionEffectKind(cbEffect.ItemIndex);
end;

procedure TFormMain.cbEffectDurationChange(Sender: TObject);
begin
  fgFlipView.EffectOptions.Duration := cbEffectDuration.Value;
end;

procedure TFormMain.cbModeChange(Sender: TObject);
begin
  fgFlipView.Mode := TfgFlipViewMode(cbMode.ItemIndex);
end;

procedure TFormMain.cbSlideDirectionChange(Sender: TObject);
begin
  fgFlipView.SlideOptions.Direction := TfgSlideDirection(cbSlideDirection.ItemIndex);
end;

procedure TFormMain.fgFlipViewFinishChanging(Sender: TObject);
begin
  Memo1.Lines.Add('OnFinishChanging');
end;

procedure TFormMain.fgFlipViewImageClick(Sender: TObject; const AFlipView: TfgCustomFlipView;
  const AImageIndex: Integer);
var
  Message: string;
begin
  Message := Format('OnImageClick: Image=%d', [AImageIndex]);
  Memo1.Lines.Add(Message);
  ShowMessage(Message);
end;

procedure TFormMain.fgFlipViewStartChanging(Sender: TObject; const NewItemIndex: Integer);
begin
  Memo1.Lines.Add(Format('OnStartChanging: Image=%d', [NewItemIndex]));
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  MultiView1.Mode := TMultiViewMode.PlatformBehaviour;
{$IFNDEF MSWINDOWS}
  ListBox1.ItemHeight := 0;
{$ENDIF}
end;

procedure TFormMain.MultiView1PresenterChanging(Sender: TObject; var PresenterClass: TMultiViewPresentationClass);
begin
{$IF Defined(Android) OR Defined(iOS)}
  PresenterClass := TMultiViewDrawerOverlapPresentation;
{$ELSE}
  if PresenterClass = TMultiViewNavigationPanePresentation then
    PresenterClass := TMultiViewDockedPanelPresentation;
{$ENDIF}
end;

procedure TFormMain.nbSlideShowDurationChange(Sender: TObject);
begin
  fgFlipView.SlideShowOptions.Duration := Round(nbSlideShowDuration.Value);
end;

procedure TFormMain.SpeedButton1Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TFormMain.swShowNavigationButtonsSwitch(Sender: TObject);
begin
  fgFlipView.ShowNavigationButtons := swShowNavigationButtons.IsChecked;
end;

procedure TFormMain.swSlideShowSwitch(Sender: TObject);
begin
  fgFlipView.SlideShowOptions.Enabled := swSlideShow.IsChecked;
end;

procedure TFormMain.nbSlideDurationChange(Sender: TObject);
begin
  fgFlipView.SlideOptions.Duration := nbSlideDuration.Value;
end;

end.
