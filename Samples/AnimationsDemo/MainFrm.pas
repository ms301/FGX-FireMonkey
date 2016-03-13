unit MainFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Ani, FGX.Animations, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Viewport3D, System.Math.Vectors, FMX.Controls3D, FMX.Objects3D,
  FMX.Types3D, FMX.MaterialSources, FMX.Styles.Objects;

type
  TFormMain = class(TForm)
    Image1: TImage;
    GroupBox1: TGroupBox;
    fgPositionAnimation1: TfgPositionAnimation;
    GroupBox2: TGroupBox;
    Viewport3D1: TViewport3D;
    Sphere1: TSphere;
    fgPosition3DAnimation1: TfgPosition3DAnimation;
    Light1: TLight;
    LightMaterialSource1: TLightMaterialSource;
    StyleObject1: TStyleObject;
    GroupBox3: TGroupBox;
    ImageSource: TImage;
    fgBitmapLinkAnimation1: TfgBitmapLinkAnimation;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

end.
