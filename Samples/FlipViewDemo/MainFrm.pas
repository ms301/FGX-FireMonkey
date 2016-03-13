unit MainFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Variants, System.Classes,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FGX.FlipView, FMX.Ani, FMX.Effects,
  FMX.Filter.Effects, FMX.ListView.Types, FMX.ListView, FMX.Edit, FMX.ListBox, FMX.NumberBox, FMX.Controls.Presentation,
  FMX.EditBox, FMX.ScrollBox, FMX.Memo;

type
  TFormMain = class(TForm)
    fgFlipView: TfgFlipView;
    PanelSettings: TPanel;
    cbSlideShow: TCheckBox;
    Label1: TLabel;
    nbSlideShowDuration: TNumberBox;
    gbCommonSettings: TGroupBox;
    Label2: TLabel;
    cbMode: TComboBox;
    Label3: TLabel;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    gbEffectSliding: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    cbEffectDuration: TNumberBox;
    cbEffect: TComboBox;
    gbShiftSliding: TGroupBox;
    Label6: TLabel;
    Label7: TLabel;
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
    gbLog: TGroupBox;
    Memo1: TMemo;
    procedure cbSlideShowChange(Sender: TObject);
    procedure nbSlideShowDurationChange(Sender: TObject);
    procedure cbModeChange(Sender: TObject);
    procedure cbEffectChange(Sender: TObject);
    procedure cbEffectDurationChange(Sender: TObject);
    procedure nbSlideDurationChange(Sender: TObject);
    procedure cbSlideDirectionChange(Sender: TObject);
    procedure fgFlipViewStartChanging(Sender: TObject; const NewItemIndex: Integer);
    procedure fgFlipViewFinishChanging(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

uses
  FGX.FlipView.Types;

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

procedure TFormMain.cbSlideShowChange(Sender: TObject);
begin
  fgFlipView.SlideShowOptions.Enabled := cbSlideShow.IsChecked;
end;

procedure TFormMain.fgFlipViewFinishChanging(Sender: TObject);
begin
  Memo1.Lines.Add('OnFinishChanging');
end;

procedure TFormMain.fgFlipViewStartChanging(Sender: TObject; const NewItemIndex: Integer);
begin
  Memo1.Lines.Add(Format('OnStartChanging: Image=%d', [NewItemIndex]));
end;

procedure TFormMain.nbSlideShowDurationChange(Sender: TObject);
begin
  fgFlipView.SlideShowOptions.Duration := Round(nbSlideShowDuration.Value);
end;

procedure TFormMain.nbSlideDurationChange(Sender: TObject);
begin
  fgFlipView.SlideOptions.Duration := nbSlideDuration.Value;
end;

end.
