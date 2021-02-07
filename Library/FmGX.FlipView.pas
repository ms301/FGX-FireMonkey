{ *********************************************************************
  *
  * This Source Code Form is subject to the terms of the Mozilla Public
  * License, v. 2.0. If a copy of the MPL was not distributed with this
  * file, You can obtain one at http://mozilla.org/MPL/2.0/.
  *
  * Autor: Brovin Y.D.
  * E-mail: y.brovin@gmail.com
  *
  ******************************************************************** }

unit FmGX.FlipView;

interface

uses
  System.Classes, System.UITypes, FMX.Graphics, FMX.Types, FMX.Controls.Presentation, FMX.Controls.Model,
  FmGX.Images.Types, FmGX.FlipView.Types, FmGX.Types, FmGX.Consts;

type

{ TfgFlipView }

  TfgxFlipViewMessages = class
  public const
    { Model messages }
    MM_ITEM_INDEX_CHANGED = MM_USER + 1;
    MM_EFFECT_OPTIONS_CHANGED = MM_USER + 2;
    MM_SLIDE_OPTIONS_CHANGED = MM_USER + 3;
    MM_SLIDESHOW_OPTIONS_CHANGED = MM_USER + 4;
    MM_SHOW_NAVIGATION_BUTTONS_CHANGED = MM_USER + 5;
    MM_FLIPVIEW_USER = MM_USER + 6;
    { Control messages }
    PM_GO_TO_IMAGE = PM_USER + 1;
    PM_FLIPVIEW_USER = PM_USER + 2;
  end;

  /// <summary>Information showing new image action. Is used for sending message from <b>TfgCustomFlipView</b>
  /// to presentation in <c>TfgCustomFlipView.GoToImage</c></summary>
  TfgxShowImageInfo = record
    NewItemIndex: Integer;
    Animate: Boolean;
    Direction: TfgxDirection;
  end;

  TfgxCustomFlipView = class;

  TfgxImageClickEvent = procedure (Sender: TObject; const AFlipView: TfgxCustomFlipView; const AImageIndex: Integer) of object;

  TfgxFlipViewModel = class(TDataModel)
  public const
    DefaultShowNavigationButtons = True;
  private
    FFlipViewEvents: IfgxFlipViewNotifications;
    FImages: TfgxImageCollection;
    FItemIndex: Integer;
    FSlideShowOptions: TfgxFlipViewSlideShowOptions;
    FSlidingOptions: TfgxFlipViewSlideOptions;
    FEffectOptions: TfgxFlipViewEffectOptions;
    FIsSliding: Boolean;
    FShowNavigationButtons: Boolean;
    FOnStartChanging: TfgxChangingImageEvent;
    FOnFinishChanging: TNotifyEvent;
    FOnImageClick: TfgxImageClickEvent;
    procedure SetEffectOptions(const Value: TfgxFlipViewEffectOptions);
    procedure SetImages(const Value: TfgxImageCollection);
    procedure SetItemIndex(const Value: Integer);
    procedure SetSlideShowOptions(const Value: TfgxFlipViewSlideShowOptions);
    procedure SetSlidingOptions(const Value: TfgxFlipViewSlideOptions);
    procedure SetShowNavigationButtons(const Value: Boolean);
    function GetCurrentImage: TBitmap;
    function GetImageCount: Integer;
    procedure HandlerOptionsChanged(Sender: TObject);
    procedure HandlerSlideShowOptionsChanged(Sender: TObject);
    procedure HandlerEffectOptionsChanged(Sender: TObject);
    procedure HandlerImagesChanged(Collection: TfgxCollection; Item: TCollectionItem; const Action: TfgxCollectionNotification);
  public
    constructor Create; override;
    destructor Destroy; override;
    function IsFirstImage: Boolean;
    function IsLastImage: Boolean;
    procedure StartChanging(const ANewItemIndex: Integer); virtual;
    procedure FinishChanging; virtual;
    procedure UpdateCurrentImage;
    property CurrentImage: TBitmap read GetCurrentImage;
    property ImagesCount: Integer read GetImageCount;
    property IsSliding: Boolean read FIsSliding;
  public
    property EffectOptions: TfgxFlipViewEffectOptions read FEffectOptions write SetEffectOptions;
    property Images: TfgxImageCollection read FImages write SetImages;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
    property SlideOptions: TfgxFlipViewSlideOptions read FSlidingOptions write SetSlidingOptions;
    property SlideShowOptions: TfgxFlipViewSlideShowOptions read FSlideShowOptions write SetSlideShowOptions;
    property ShowNavigationButtons: Boolean read FShowNavigationButtons write SetShowNavigationButtons;
    property OnStartChanging: TfgxChangingImageEvent read FOnStartChanging write FOnStartChanging;
    property OnFinishChanging: TNotifyEvent read FOnFinishChanging write FOnFinishChanging;
    property OnImageClick: TfgxImageClickEvent read FOnImageClick write FOnImageClick;
  end;

  TfgxCustomFlipView = class(TPresentedControl, IfgxFlipViewNotifications)
  public const
    DefaultMode = TfgxFlipViewMode.Effects;
  private
    FSlideShowTimer: TTimer;
    FMode: TfgxFlipViewMode;
    function GetModel: TfgxFlipViewModel;
    function GetEffectOptions: TfgxFlipViewEffectOptions;
    function GetImages: TfgxImageCollection;
    function GetItemIndex: Integer;
    function GetSlideShowOptions: TfgxFlipViewSlideShowOptions;
    function GetSlidingOptions: TfgxFlipViewSlideOptions;
    function GetShowNavigationButtons: Boolean;
    function GetOnFinishChanging: TNotifyEvent;
    function GetOnStartChanging: TfgxChangingImageEvent;
    function GetOnImageClick: TfgxImageClickEvent;
    function IsEffectOptionsStored: Boolean;
    function IsSlideOptionsStored: Boolean;
    function IsSlideShowOptionsStored: Boolean;
    procedure SetEffectOptions(const Value: TfgxFlipViewEffectOptions);
    procedure SetImages(const Value: TfgxImageCollection);
    procedure SetItemIndex(const Value: Integer);
    procedure SetSlideShowOptions(const Value: TfgxFlipViewSlideShowOptions);
    procedure SetSlidingOptions(const Value: TfgxFlipViewSlideOptions);
    procedure SetShowNavigationButtons(const Value: Boolean);
    procedure SetMode(const Value: TfgxFlipViewMode);
    procedure SetOnFinishChanging(const Value: TNotifyEvent);
    procedure SetOnStartChanging(const Value: TfgxChangingImageEvent);
    procedure SetOnImageClick(const Value: TfgxImageClickEvent);
  protected
    procedure HandlerTimer(Sender: TObject); virtual;
    procedure UpdateTimer;
    { IfgFlipViewEvents }
    procedure StartChanging;
    procedure FinishChanging;
  protected
    function DefineModelClass: TDataModelClass; override;
    function DefinePresentationName: string; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CanSlideShow: Boolean;
    { Manipulation }
    procedure GoToNext(const Animate: Boolean = True);
    procedure GoToPrevious(const Animate: Boolean = True);
    procedure GoToImage(const AImageIndex: Integer; const ADirection: TfgxDirection = TfgxDirection.Forward;
      const Animate: Boolean = True);
    property Model: TfgxFlipViewModel read GetModel;
  public
    property EffectOptions: TfgxFlipViewEffectOptions read GetEffectOptions write SetEffectOptions
      stored IsEffectOptionsStored;
    property Images: TfgxImageCollection read GetImages write SetImages;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex default -1;
    property Mode: TfgxFlipViewMode read FMode write SetMode default DefaultMode;
    property SlideOptions: TfgxFlipViewSlideOptions read GetSlidingOptions write SetSlidingOptions
      stored IsSlideOptionsStored;
    property SlideShowOptions: TfgxFlipViewSlideShowOptions read GetSlideShowOptions write SetSlideShowOptions
      stored IsSlideShowOptionsStored;
    property ShowNavigationButtons: Boolean read GetShowNavigationButtons write SetShowNavigationButtons
      default TfgxFlipViewModel.DefaultShowNavigationButtons;
    property OnStartChanging: TfgxChangingImageEvent read GetOnStartChanging write SetOnStartChanging;
    property OnFinishChanging: TNotifyEvent read GetOnFinishChanging write SetOnFinishChanging;
    property OnImageClick: TfgxImageClickEvent read GetOnImageClick write SetOnImageClick;
  end;

  /// <summary>
  /// Slider of images. Supports several way for displaying images.
  /// </summary>
  /// <remarks>
  /// <note type="note">
  /// Style's elements:
  /// <list type="table">
  /// <item>
  /// <term>image: TImage</term>
  /// <description>Container for current slide</description>
  /// </item>
  /// <item>
  /// <term>image-next: TImage</term>
  /// <description>Additional container for second image (in case of sliding mode)</description>
  /// </item>
  /// <item>
  /// <term>next-button: TControl</term>
  /// <description>Button 'Next slide'</description>
  /// </item>
  /// <item>
  /// <term>prev-button: TControl</term>
  /// <description>Button 'Previous slide'</description>
  /// </item>
  /// </list>
  /// </note>
  /// </remarks>
  [ComponentPlatformsAttribute(fgAllPlatform)]
  TfgxFlipView = class(TfgxCustomFlipView)
  published
    property Images;
    property ItemIndex;
    property Mode;
    property EffectOptions;
    property SlideOptions;
    property SlideShowOptions;
    property ShowNavigationButtons;
    property OnStartChanging;
    property OnFinishChanging;
    property OnImageClick;
    { inherited }
    property Align;
    property Anchors;
    property ClipChildren default False;
    property ClipParent default False;
    property Cursor default crDefault;
    property DragMode default TDragMode.dmManual;
    property EnableDragHighlight default True;
    property Enabled default True;
    property Locked default False;
    property Height;
    property HitTest default True;
    property Padding;
    property Opacity;
    property Margins;
    property PopupMenu;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    property StyleLookup;
    property TabOrder;
    property TouchTargetExpansion;
    property Visible default True;
    property Width;
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    property OnKeyDown;
    property OnKeyUp;
    property OnCanFocus;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnPainting;
    property OnPaint;
    property OnPresentationNameChoosing;
    property OnResize;
  end;

implementation

uses
  System.SysUtils, System.Math, FmGX.Asserts, FmGX.FlipView.Effect, FmGX.FlipView.Sliding;

{ TfgCustomFlipView }

function TfgxCustomFlipView.CanSlideShow: Boolean;
begin
  TfgxAssert.IsNotNil(Model);
  TfgxAssert.IsNotNil(SlideShowOptions);

  Result := SlideShowOptions.Enabled and not(csDesigning in ComponentState) and not Model.IsSliding;
end;

constructor TfgxCustomFlipView.Create(AOwner: TComponent);
begin
  inherited;
  FMode := DefaultMode;
  FSlideShowTimer := TTimer.Create(nil);
  FSlideShowTimer.Stored := False;
  UpdateTimer;
  FSlideShowTimer.OnTimer := HandlerTimer;
  Touch.InteractiveGestures := Touch.InteractiveGestures + [TInteractiveGesture.Pan];
  Touch.DefaultInteractiveGestures := Touch.DefaultInteractiveGestures + [TInteractiveGesture.Pan];
  Touch.StandardGestures := Touch.StandardGestures + [TStandardGesture.sgLeft, TStandardGesture.sgRight,
    TStandardGesture.sgUp, TStandardGesture.sgDown];
end;

function TfgxCustomFlipView.DefineModelClass: TDataModelClass;
begin
  Result := TfgxFlipViewModel;
end;

function TfgxCustomFlipView.DefinePresentationName: string;
var
  Postfix: string;
begin
  case Mode of
    TfgxFlipViewMode.Effects:
      Postfix := 'Effect';
    TfgxFlipViewMode.Sliding:
      Postfix := 'Sliding';
    TfgxFlipViewMode.Custom:
      Postfix := 'Custom';
  else
    raise Exception.Create('Unknown value of [FGX.FlipView.Types.TfgFlipViewMode])');
  end;
  Result := 'fgFlipView-' + Postfix;
end;

destructor TfgxCustomFlipView.Destroy;
begin
  FreeAndNil(FSlideShowTimer);
  inherited;
end;

function TfgxCustomFlipView.GetEffectOptions: TfgxFlipViewEffectOptions;
begin
  TfgxAssert.IsNotNil(Model);

  Result := Model.EffectOptions;
end;

function TfgxCustomFlipView.GetImages: TfgxImageCollection;
begin
  TfgxAssert.IsNotNil(Model);

  Result := Model.Images;
end;

function TfgxCustomFlipView.GetItemIndex: Integer;
begin
  TfgxAssert.IsNotNil(Model);

  Result := Model.ItemIndex;
end;

function TfgxCustomFlipView.GetModel: TfgxFlipViewModel;
begin
  Result := inherited GetModel<TfgxFlipViewModel>;

  TfgxAssert.IsNotNil(Result, 'TfgCustomFlipView.GetModel must return Model of [TfgFlipViewModel] class');
end;

function TfgxCustomFlipView.GetOnFinishChanging: TNotifyEvent;
begin
  TfgxAssert.IsNotNil(Model);

  Result := Model.OnFinishChanging;
end;

function TfgxCustomFlipView.GetOnImageClick: TfgxImageClickEvent;
begin
  Result := Model.OnImageClick;
end;

function TfgxCustomFlipView.GetOnStartChanging: TfgxChangingImageEvent;
begin
  TfgxAssert.IsNotNil(Model);

  Result := Model.OnStartChanging;
end;

function TfgxCustomFlipView.GetShowNavigationButtons: Boolean;
begin
  Result := Model.ShowNavigationButtons;
end;

function TfgxCustomFlipView.GetSlideShowOptions: TfgxFlipViewSlideShowOptions;
begin
  TfgxAssert.IsNotNil(Model);

  Result := Model.SlideShowOptions;
end;

function TfgxCustomFlipView.GetSlidingOptions: TfgxFlipViewSlideOptions;
begin
  TfgxAssert.IsNotNil(Model);

  Result := Model.SlideOptions;
end;

procedure TfgxCustomFlipView.GoToImage(const AImageIndex: Integer; const ADirection: TfgxDirection;
  const Animate: Boolean);
var
  ShowImageInfo: TfgxShowImageInfo;
begin
  if HasPresentationProxy then
  begin
    ShowImageInfo.NewItemIndex := AImageIndex;
    ShowImageInfo.Animate := Animate;
    ShowImageInfo.Direction := ADirection;
    PresentationProxy.SendMessage<TfgxShowImageInfo>(TfgxFlipViewMessages.PM_GO_TO_IMAGE, ShowImageInfo);
  end;
end;

procedure TfgxCustomFlipView.GoToNext(const Animate: Boolean = True);
begin
  GoToImage(IfThen(Model.IsLastImage, 0, ItemIndex + 1), TfgxDirection.Forward, Animate);
end;

procedure TfgxCustomFlipView.GoToPrevious(const Animate: Boolean = True);
begin
  GoToImage(IfThen(Model.IsFirstImage, Model.ImagesCount - 1, ItemIndex - 1), TfgxDirection.Backward, Animate);
end;

procedure TfgxCustomFlipView.HandlerTimer(Sender: TObject);
begin
  TfgxAssert.IsNotNil(FSlideShowTimer);

  FSlideShowTimer.Enabled := False;
  try
    GoToNext;
  finally
    FSlideShowTimer.Enabled := True;
  end;
end;

function TfgxCustomFlipView.IsEffectOptionsStored: Boolean;
begin
  TfgxAssert.IsNotNil(EffectOptions);

  Result := not EffectOptions.AreDefaultValues;
end;

function TfgxCustomFlipView.IsSlideOptionsStored: Boolean;
begin
  TfgxAssert.IsNotNil(SlideOptions);

  Result := not SlideOptions.AreDefaultValues;
end;

function TfgxCustomFlipView.IsSlideShowOptionsStored: Boolean;
begin
  TfgxAssert.IsNotNil(SlideShowOptions);

  Result := not SlideShowOptions.AreDefaultValues;
end;

procedure TfgxCustomFlipView.SetEffectOptions(const Value: TfgxFlipViewEffectOptions);
begin
  TfgxAssert.IsNotNil(Value);
  TfgxAssert.IsNotNil(Model);
  TfgxAssert.IsNotNil(Model.EffectOptions);

  Model.EffectOptions := Value;
end;

procedure TfgxCustomFlipView.SetImages(const Value: TfgxImageCollection);
begin
  TfgxAssert.IsNotNil(Value);
  TfgxAssert.IsNotNil(Model);
  TfgxAssert.IsNotNil(Model.Images);

  Model.Images := Value;
end;

procedure TfgxCustomFlipView.SetItemIndex(const Value: Integer);
begin
  TfgxAssert.IsNotNil(Model);

  Model.ItemIndex := Value;
end;

procedure TfgxCustomFlipView.SetMode(const Value: TfgxFlipViewMode);
begin
  if FMode <> Value then
  begin
    FMode := Value;
    if [csDestroying, csReading] * ComponentState = [] then
      ReloadPresentation;
  end;
end;

procedure TfgxCustomFlipView.SetOnFinishChanging(const Value: TNotifyEvent);
begin
  TfgxAssert.IsNotNil(Model);

  Model.OnFinishChanging := Value;
end;

procedure TfgxCustomFlipView.SetOnImageClick(const Value: TfgxImageClickEvent);
begin
  Model.OnImageClick := Value;
end;

procedure TfgxCustomFlipView.SetOnStartChanging(const Value: TfgxChangingImageEvent);
begin
  TfgxAssert.IsNotNil(Model);

  Model.OnStartChanging := Value;
end;

procedure TfgxCustomFlipView.SetShowNavigationButtons(const Value: Boolean);
begin
  Model.ShowNavigationButtons := Value;
end;

procedure TfgxCustomFlipView.SetSlideShowOptions(const Value: TfgxFlipViewSlideShowOptions);
begin
  TfgxAssert.IsNotNil(Value);
  TfgxAssert.IsNotNil(Model);
  TfgxAssert.IsNotNil(Model.SlideShowOptions);

  Model.SlideShowOptions := Value;
end;

procedure TfgxCustomFlipView.SetSlidingOptions(const Value: TfgxFlipViewSlideOptions);
begin
  TfgxAssert.IsNotNil(Value);
  TfgxAssert.IsNotNil(Model);
  TfgxAssert.IsNotNil(Model.SlideOptions);

  Model.SlideOptions := Value;
end;

procedure TfgxCustomFlipView.StartChanging;
begin
  TfgxAssert.IsNotNil(FSlideShowTimer);

  FSlideShowTimer.Enabled := False;
end;

procedure TfgxCustomFlipView.UpdateTimer;
begin
  FSlideShowTimer.Interval := SlideShowOptions.Duration * MSecsPerSec;
  FSlideShowTimer.Enabled := CanSlideShow;
end;

procedure TfgxCustomFlipView.FinishChanging;
begin
  TfgxAssert.IsNotNil(FSlideShowTimer);

  FSlideShowTimer.Enabled := CanSlideShow;
end;

{ TFgFlipViewModel }

procedure TfgxFlipViewModel.StartChanging(const ANewItemIndex: Integer);
begin
  FIsSliding := True;
  if FFlipViewEvents <> nil then
    FFlipViewEvents.StartChanging;
  if Assigned(OnStartChanging) then
    OnStartChanging(Owner, ANewItemIndex);
end;

procedure TfgxFlipViewModel.UpdateCurrentImage;
begin
  SendMessage<Integer>(TfgxFlipViewMessages.MM_ITEM_INDEX_CHANGED, FItemIndex);
end;

constructor TfgxFlipViewModel.Create;
begin
  inherited Create;
  FImages := TfgxImageCollection.Create(Owner, TfgxImageCollectionItem, HandlerImagesChanged);
  FItemIndex := -1;
  FIsSliding := False;
  FSlideShowOptions := TfgxFlipViewSlideShowOptions.Create(Owner, HandlerSlideShowOptionsChanged);
  FSlidingOptions := TfgxFlipViewSlideOptions.Create(Owner, HandlerOptionsChanged);
  FEffectOptions := TfgxFlipViewEffectOptions.Create(Owner, HandlerEffectOptionsChanged);
  FShowNavigationButtons := DefaultShowNavigationButtons;
  Supports(Owner, IfgxFlipViewNotifications, FFlipViewEvents);
end;

destructor TfgxFlipViewModel.Destroy;
begin
  FFlipViewEvents := nil;
  FreeAndNil(FImages);
  FreeAndNil(FSlidingOptions);
  FreeAndNil(FEffectOptions);
  FreeAndNil(FSlideShowOptions);
  inherited;
end;

procedure TfgxFlipViewModel.FinishChanging;
begin
  FIsSliding := False;
  if FFlipViewEvents <> nil then
    FFlipViewEvents.FinishChanging;
  if Assigned(OnFinishChanging) then
    OnFinishChanging(Owner);
end;

function TfgxFlipViewModel.GetCurrentImage: TBitmap;
begin
  TfgxAssert.IsNotNil(FImages);
  TfgxAssert.InRange(ItemIndex, -1, ImagesCount - 1);

  if InRange(ItemIndex, 0, ImagesCount - 1) then
    Result := FImages[ItemIndex].Bitmap
  else
    Result := nil;
end;

function TfgxFlipViewModel.GetImageCount: Integer;
begin
  TfgxAssert.IsNotNil(FImages);

  Result := FImages.Count;
end;

procedure TfgxFlipViewModel.HandlerEffectOptionsChanged(Sender: TObject);
begin
  SendMessage(TfgxFlipViewMessages.MM_EFFECT_OPTIONS_CHANGED);
end;

procedure TfgxFlipViewModel.HandlerImagesChanged(Collection: TfgxCollection; Item: TCollectionItem;
  const Action: TfgxCollectionNotification);
begin
  TfgxAssert.IsNotNil(Item);
  if Action = TfgxCollectionNotification.Updated then
    UpdateCurrentImage;
  if (Action = TfgxCollectionNotification.Added) and (ItemIndex = -1) then
    ItemIndex := 0;
  if Action in [TfgxCollectionNotification.Deleting, TfgxCollectionNotification.Extracting] then
    ItemIndex := EnsureRange(ItemIndex, -1, ImagesCount - 2); // -2, because ImageCount return count before removing item
end;

procedure TfgxFlipViewModel.HandlerOptionsChanged(Sender: TObject);
begin
  SendMessage(TfgxFlipViewMessages.MM_SLIDE_OPTIONS_CHANGED);
end;

procedure TfgxFlipViewModel.HandlerSlideShowOptionsChanged(Sender: TObject);
begin
  SendMessage(TfgxFlipViewMessages.MM_SLIDESHOW_OPTIONS_CHANGED);
  if Owner is TfgxCustomFlipView then
    TfgxCustomFlipView(Owner).UpdateTimer;
end;

function TfgxFlipViewModel.IsFirstImage: Boolean;
begin
  Result := ItemIndex = 0;
end;

function TfgxFlipViewModel.IsLastImage: Boolean;
begin
  Result := ItemIndex = ImagesCount - 1;
end;

procedure TfgxFlipViewModel.SetEffectOptions(const Value: TfgxFlipViewEffectOptions);
begin
  TfgxAssert.IsNotNil(Value);

  FEffectOptions.Assign(Value);
end;

procedure TfgxFlipViewModel.SetImages(const Value: TfgxImageCollection);
begin
  TfgxAssert.IsNotNil(Value);

  FImages.Assign(Value);
end;

procedure TfgxFlipViewModel.SetItemIndex(const Value: Integer);
begin
  if FItemIndex <> Value then
  begin
    FItemIndex := EnsureRange(Value, -1, ImagesCount - 1);
    SendMessage<Integer>(TfgxFlipViewMessages.MM_ITEM_INDEX_CHANGED, FItemIndex);
  end;
end;

procedure TfgxFlipViewModel.SetShowNavigationButtons(const Value: Boolean);
begin
  if FShowNavigationButtons <> Value then
  begin
    FShowNavigationButtons := Value;
    SendMessage<Boolean>(TfgxFlipViewMessages.MM_SHOW_NAVIGATION_BUTTONS_CHANGED, FShowNavigationButtons);
  end;
end;

procedure TfgxFlipViewModel.SetSlideShowOptions(const Value: TfgxFlipViewSlideShowOptions);
begin
  TfgxAssert.IsNotNil(Value);

  FSlideShowOptions.Assign(Value);
end;

procedure TfgxFlipViewModel.SetSlidingOptions(const Value: TfgxFlipViewSlideOptions);
begin
  TfgxAssert.IsNotNil(Value);

  FSlidingOptions.Assign(Value);
end;

initialization
  RegisterFmxClasses([TfgxCustomFlipView, TfgxFlipView]);
end.
