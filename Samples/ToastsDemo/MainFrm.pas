unit MainFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.DateTimeCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.ListBox, FMX.Effects, FMX.Objects, FMX.Layouts, FMX.Colors;

type
  TFormMain = class(TForm)
    EditToastMessage: TEdit;
    Button1: TButton;
    ComboBoxDurationType: TComboBox;
    ListBoxItem1: TListBoxItem;
    ShadowEffect1: TShadowEffect;
    ListBoxItem2: TListBoxItem;
    Image1: TImage;
    SwitchShowIcon: TSwitch;
    ListBox1: TListBox;
    ListBoxItem3: TListBoxItem;
    ListBoxGroupHeader1: TListBoxGroupHeader;
    ListBoxItem4: TListBoxItem;
    ListBoxGroupHeader2: TListBoxGroupHeader;
    ListBoxItem5: TListBoxItem;
    ListBoxItem6: TListBoxItem;
    ListBoxGroupHeader3: TListBoxGroupHeader;
    ListBoxItem7: TListBoxItem;
    ListBoxItem8: TListBoxItem;
    Button2: TButton;
    ShadowEffect2: TShadowEffect;
    ColorComboBoxMessage: TComboColorBox;
    ColorComboBoxBackground: TComboColorBox;
    Button3: TButton;
    ListBoxItem9: TListBoxItem;
    ListBoxItem10: TListBoxItem;
    ListBoxGroupHeader4: TListBoxGroupHeader;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

uses
  FGX.Toasts, FGX.Graphics;

procedure TFormMain.Button1Click(Sender: TObject);
begin
  TfgToast.Show(EditToastMessage.Text, TfgToastDuration(ComboBoxDurationType.ItemIndex));
end;

procedure TFormMain.Button2Click(Sender: TObject);
var
  Toast: TfgToast;
begin
  Toast := TfgToast.Create(EditToastMessage.Text, TfgToastDuration(ComboBoxDurationType.ItemIndex));
  try
    if SwitchShowIcon.IsChecked then
      Toast.Icon := Image1.Bitmap;
    Toast.MessageColor := ColorComboBoxMessage.Color;
    Toast.BackgroundColor := ColorComboBoxBackground.Color;
    Toast.Show;
  finally
    Toast.Free;
  end;
end;

procedure TFormMain.Button3Click(Sender: TObject);
begin
  ColorComboBoxBackground.Color := TfgToast.DefaultBackgroundColor;
  ColorComboBoxMessage.Color := TfgToast.DefaultMessageColor;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  ColorComboBoxMessage.Color := TfgToast.DefaultMessageColor;
  ColorComboBoxBackground.Color := TfgToast.DefaultBackgroundColor;
end;

end.
