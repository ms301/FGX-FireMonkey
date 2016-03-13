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

unit FGX.FlipView;

interface

uses
  System.Classes, System.UITypes, FMX.Graphics, FMX.Types, FMX.Controls.Presentation, FMX.Controls.Model,
  FGX.Images.Types, FGX.FlipView.Types, FGX.Types, FGX.Consts;

type

{ TfgFlipView }

  TfgFlipViewMessages = class
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
  TfgShowImageInfo = record
    NewItemIndex: Integer;
    Animate: Boolean;
    Direction: TfgDirection;
  end;

  TfgCustomFlipView = class;

  TfgImageClickEvent = procedure (Sender: TObject; const AFlipView: TfgCustomFlipView; const AImageIndex: Integer) of object;

  TfgFlipViewModel = class(TDataModel)
  public const
    DefaultShowNavigationButtons = True;
  private
    FFlipViewEvents: IfgFlipViewNotifications;
    FImages: TfgImageCollection;
    FItemIndex: Integer;
    FSlideShowOptions: TfgFlipViewSlideShowOptions;
    FSlidingOptions: TfgFlipViewSlideOptions;
    FEffectOptions: TfgFlipViewEffectOptions;
    FIsSliding: Boolean;
    FShowNavigationButtons: Boolean;
    FOnStartChanging: TfgChangingImageEvent;
    FOnFinishChanging: TNotifyEvent;
    FOnImageClick: TfgImageClickEvent;
    procedure SetEffectOptions(const Value: TfgFlipViewEffectOptions);
    procedure SetImages(const Value: TfgImageCollection);
    procedure SetItemIndex(const Value: Integer);
    procedure SetSlideShowOptions(const Value: TfgFlipViewSlideShowOptions);
    procedure SetSlidingOptions(const Value: TfgFlipViewSlideOptions);
    procedure SetShowNavigationButtons(const Value: Boolean);
    function GetCurrentImage: TBitmap;
    function GetImageCount: Integer;
    procedure HandlerOptionsChanged(Sender: TObject);
    procedure HandlerSlideShowOptionsChanged(Sender: TObject);
    procedure HandlerEffectOptionsChanged(Sender: TObject);
    procedure HandlerImagesChanged(Collection: TfgCollection; Item: TCollectionItem; const Action: TfgCollectionNotification);
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
    property EffectOptions: TfgFlipViewEffectOptions read FEffectOptions write SetEffectOptions;
    property Images: TfgImageCollection read FImages write SetImages;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
    property SlideOptions: TfgFlipViewSlideOptions read FSlidingOptions write SetSlidingOptions;
    property SlideShowOptions: TfgFlipViewSlideShowOptions read FSlideShowOptions write SetSlideShowOptions;
    property ShowNavigationButtons: Boolean read FShowNavigationButtons write SetShowNavigationButtons;
    property OnStartChanging: TfgChangingImageEvent read FOnStartChanging write FOnStartChanging;
    property OnFinishChanging: TNotifyEvent read FOnFinishChanging write FOnFinishChanging;
    property OnImageClick: TfgImageClickEvent read FOnImageClick write FOnImageClick;
  end;

  TfgCustomFlipView = class(TPresentedControl, IfgFlipViewNotifications)
  public const
    DefaultMode = TfgFlipViewMode.Effects;
  private
    FSlideShowTimer: TTimer;
    FMode: TfgFlipViewMode;
    function GetModel: TfgFlipViewModel;
    function GetEffectOptions: TfgFlipViewEffectOptions;
    function GetImages: TfgImageCollection;
    function GetItemIndex: Integer;
    function GetSlideShowOptions: TfgFlipViewSlideShowOptions;
    function GetSlidingOptions: TfgFlipViewSlideOptions;
    function GetShowNavigationButtons: Boolean;
    function GetOnFinishChanging: TNotifyEvent;
    function GetOnStartChanging: TfgChangingImageEvent;
    function GetOnImageClick: TfgImageClickEvent;
    function IsEffectOptionsStored: Boolean;
    function IsSlideOptionsStored: Boolean;
    function IsSlideShowOptionsStored: Boolean;
    procedure SetEffectOptions(const Value: TfgFlipViewEffectOptions);
    procedure SetImages(const Value: TfgImageCollection);
    procedure SetItemIndex(const Value: Integer);
    procedure SetSlideShowOptions(const Value: TfgFlipViewSlideShowOptions);
    procedure SetSlidingOptions(const Value: TfgFlipViewSlideOptions);
    procedure SetShowNavigationButtons(const Value: Boolean);
    procedure SetMode(const Value: TfgFlipViewMode);
    procedure SetOnFinishChanging(const Value: TNotifyEvent);
    procedure SetOnStartChanging(const Value: TfgChangingImageEvent);
    procedure SetOnImageClick(const Value: TfgImageClickEvent);
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
    procedure GoToImage(const AImageIndex: Integer; const ADirection: TfgDirection = TfgDirection.Forward;
      const Animate: Boolean = True);
    property Model: TfgFlipViewModel read GetModel;
  public
    property EffectOptions: TfgFlipViewEffectOptions read GetEffectOptions write SetEffectOptions
      stored IsEffectOptionsStored;
    property Images: TfgImageCollection read GetImages write SetImages;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex default -1;
    property Mode: TfgFlipViewMode read FMode write SetMode default DefaultMode;
    property SlideOptions: TfgFlipViewSlideOptions read GetSlidingOptions write SetSlidingOptions
      stored IsSlideOptionsStored;
    property SlideShowOptions: TfgFlipViewSlideShowOptions read GetSlideShowOptions write SetSlideShowOptions
      stored IsSlideShowOptionsStored;
    property ShowNavigationButtons: Boolean read GetShowNavigationButtons write SetShowNavigationButtons
      default TfgFlipViewModel.DefaultShowNavigationButtons;
    property OnStartChanging: TfgChangingImageEvent read GetOnStartChanging write SetOnStartChanging;
    property OnFinishChanging: TNotifyEvent read GetOnFinishChanging write SetOnFinishChanging;
    property OnImageClick: TfgImageClickEvent read GetOnImageClick write SetOnImageClick;
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
  TfgFlipView = class(TfgCustomFlipView)
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
  System.SysUtils, System.Math, FGX.Asserts, FGX.FlipView.Effect, FGX.FlipView.Sliding;

{ TfgCustomFlipView }

function TfgCustomFlipView.CanSlideShow: Boolean;
begin
  AssertIsNotNil(Model);
  AssertIsNotNil(SlideShowOptions);

  Result := SlideShowOptions.Enabled and not(csDesigning in ComponentState) and not Model.IsSliding;
end;

constructor TfgCustomFlipView.Create(AOwner: TComponent);
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

function TfgCustomFlipView.DefineModelClass: TDataModelClass;
begin
  Result := TfgFlipViewModel;
end;

function TfgCustomFlipView.DefinePresentationName: string;
var
  Postfix: string;
begin
  case Mode of
    TfgFlipViewMode.Effects:
      Postfix := 'Effect';
    TfgFlipViewMode.Sliding:
      Postfix := 'Sliding';
    TfgFlipViewMode.Custom:
      Postfix := 'Custom';
  else
    raise Exception.Create('Unknown value of [FGX.FlipView.Types.TfgFlipViewMode])');
  end;
  Result := 'fgFlipView-' + Postfix;
end;

destructor TfgCustomFlipView.Destroy;
begin
  FreeAndNil(FSlideShowTimer);
  inherited;
end;

function TfgCustomFlipView.GetEffectOptions: TfgFlipViewEffectOptions;
begin
  AssertIsNotNil(Model);

  Result := Model.EffectOptions;
end;

function TfgCustomFlipView.GetImages: TfgImageCollection;
begin
  AssertIsNotNil(Model);

  Result := Model.Images;
end;

function TfgCustomFlipView.GetItemIndex: Integer;
begin
  AssertIsNotNil(Model);

  Result := Model.ItemIndex;
end;

function TfgCustomFlipView.GetModel: TfgFlipViewModel;
begin
  Result := inherited GetModel<TfgFlipViewModel>;

  AssertIsNotNil(Result, 'TfgCustomFlipView.GetModel must return Model of [TfgFlipViewModel] class');
end;

function TfgCustomFlipView.GetOnFinishChanging: TNotifyEvent;
begin
  AssertIsNotNil(Model);

  Result := Model.OnFinishChanging;
end;

function TfgCustomFlipView.GetOnImageClick: TfgImageClickEvent;
begin
  Result := Model.OnImageClick;
end;

function TfgCustomFlipView.GetOnStartChanging: TfgChangingImageEvent;
begin
  AssertIsNotNil(Model);

  Result := Model.OnStartChanging;
end;

function TfgCustomFlipView.GetShowNavigationButtons: Boolean;
begin
  Result := Model.ShowNavigationButtons;
end;

function TfgCustomFlipView.GetSlideShowOptions: TfgFlipViewSlideShowOptions;
begin
  AssertIsNotNil(Model);

  Result := Model.SlideShowOptions;
end;

function TfgCustomFlipView.GetSlidingOptions: TfgFlipViewSlideOptions;
begin
  AssertIsNotNil(Model);

  Result := Model.SlideOptions;
end;

procedure TfgCustomFlipView.GoToImage(const AImageIndex: Integer; const ADirection: TfgDirection;
  const Animate: Boolean);
var
  ShowImageInfo: TfgShowImageInfo;
begin
  if HasPresentationProxy then
  begin
    ShowImageInfo.NewItemIndex := AImageIndex;
    ShowImageInfo.Animate := Animate;
    ShowImageInfo.Direction := ADirection;
    PresentationProxy.SendMessage<TfgShowImageInfo>(TfgFlipViewMessages.PM_GO_TO_IMAGE, ShowImageInfo);
  end;
end;

procedure TfgCustomFlipView.GoToNext(const Animate: Boolean = True);
begin
  GoToImage(IfThen(Model.IsLastImage, 0, ItemIndex + 1), TfgDirection.Forward, Animate);
end;

procedure TfgCustomFlipView.GoToPrevious(const Animate: Boolean = True);
begin
  GoToImage(IfThen(Model.IsFirstImage, Model.ImagesCount - 1, ItemIndex - 1), TfgDirection.Backward, Animate);
end;

procedure TfgCustomFlipView.HandlerTimer(Sender: TObject);
begin
  AssertIsNotNil(FSlideShowTimer);

  FSlideShowTimer.Enabled := False;
  try
    GoToNext;
  finally
    FSlideShowTimer.Enabled := True;
  end;
end;

function TfgCustomFlipView.IsEffectOptionsStored: Boolean;
begin
  AssertIsNotNil(EffectOptions);

  Result := not EffectOptions.IsDefaultValues;
end;

function TfgCustomFlipView.IsSlideOptionsStored: Boolean;
begin
  AssertIsNotNil(SlideOptions);

  Result := not SlideOptions.IsDefaultValues;
end;

function TfgCustomFlipView.IsSlideShowOptionsStored: Boolean;
begin
  AssertIsNotNil(SlideShowOptions);

  Result := not SlideShowOptions.IsDefaultValues;
end;

procedure TfgCustomFlipView.SetEffectOptions(const Value: TfgFlipViewEffectOptions);
begin
  AssertIsNotNil(Value);
  AssertIsNotNil(Model);
  AssertIsNotNil(Model.EffectOptions);

  Model.EffectOptions := Value;
end;

procedure TfgCustomFlipView.SetImages(const Value: TfgImageCollection);
begin
  AssertIsNotNil(Value);
  AssertIsNotNil(Model);
  AssertIsNotNil(Model.Images);

  Model.Images := Value;
end;

procedure TfgCustomFlipView.SetItemIndex(const Value: Integer);
begin
  AssertIsNotNil(Model);

  Model.ItemIndex := Value;
end;

procedure TfgCustomFlipView.SetMode(const Value: TfgFlipViewMode);
begin
  if FMode <> Value then
  begin
    FMode := Value;
    if [csDestroying, csReading] * ComponentState = [] then
      ReloadPresentation;
  end;
end;

procedure TfgCustomFlipView.SetOnFinishChanging(const Value: TNotifyEvent);
begin
  AssertIsNotNil(Model);

  Model.OnFinishChanging := Value;
end;

procedure TfgCustomFlipView.SetOnImageClick(const Value: TfgImageClickEvent);
begin
  Model.OnImageClick := Value;
end;

procedure TfgCustomFlipView.SetOnStartChanging(const Value: TfgChangingImageEvent);
begin
  AssertIsNotNil(Model);

  Model.OnStartChanging := Value;
end;

procedure TfgCustomFlipView.SetShowNavigationButtons(const Value: Boolean);
begin
  Model.ShowNavigationButtons := Value;
end;

procedure TfgCustomFlipView.SetSlideShowOptions(const Value: TfgFlipViewSlideShowOptions);
begin
  AssertIsNotNil(Value);
  AssertIsNotNil(Model);
  AssertIsNotNil(Model.SlideShowOptions);

  Model.SlideShowOptions := Value;
end;

procedure TfgCustomFlipView.SetSlidingOptions(const Value: TfgFlipViewSlideOptions);
begin
  AssertIsNotNil(Value);
  AssertIsNotNil(Model);
  AssertIsNotNil(Model.SlideOptions);

  Model.SlideOptions := Value;
end;

procedure TfgCustomFlipView.StartChanging;
begin
  AssertIsNotNil(FSlideShowTimer);

  FSlideShowTimer.Enabled := False;
end;

procedure TfgCustomFlipView.UpdateTimer;
begin
  FSlideShowTimer.Interval := SlideShowOptions.Duration * MSecsPerSec;
  FSlideShowTimer.Enabled := CanSlideShow;
end;

procedure TfgCustomFlipView.FinishChanging;
begin
  AssertIsNotNil(FSlideShowTimer);

  FSlideShowTimer.Enabled := CanSlideShow;
end;

{ TFgFlipViewModel }

procedure TfgFlipViewModel.StartChanging(const ANewItemIndex: Integer);
begin
  FIsSliding := True;
  if FFlipViewEvents <> nil then
    FFlipViewEvents.StartChanging;
  if Assigned(OnStartChanging) then
    OnStartChanging(Owner, ANewItemIndex);
end;

procedure TfgFlipViewModel.UpdateCurrentImage;
begin
  SendMessage<Integer>(TfgFlipViewMessages.MM_ITEM_INDEX_CHANGED, FItemIndex);
end;

constructor TfgFlipViewModel.Create;
begin
  inherited Create;
  FImages := TfgImageCollection.Create(Owner, TfgImageCollectionItem, HandlerImagesChanged);
  FItemIndex := -1;
  FIsSliding := False;
  FSlideShowOptions := TfgFlipViewSlideShowOptions.Create(Owner, HandlerSlideShowOptionsChanged);
  FSlidingOptions := TfgFlipViewSlideOptions.Create(Owner, HandlerOptionsChanged);
  FEffectOptions := TfgFlipViewEffectOptions.Create(Owner, HandlerEffectOptionsChanged);
  FShowNavigationButtons := DefaultShowNavigationButtons;
  Supports(Owner, IfgFlipViewNotifications, FFlipViewEvents);
end;

destructor TfgFlipViewModel.Destroy;
begin
  FFlipViewEvents := nil;
  FreeAndNil(FImages);
  FreeAndNil(FSlidingOptions);
  FreeAndNil(FEffectOptions);
  FreeAndNil(FSlideShowOptions);
  inherited;
end;

procedure TfgFlipViewModel.FinishChanging;
begin
  FIsSliding := False;
  if FFlipViewEvents <> nil then
    FFlipViewEvents.FinishChanging;
  if Assigned(OnFinishChanging) then
    OnFinishChanging(Owner);
end;

function TfgFlipViewModel.GetCurrentImage: TBitmap;
begin
  AssertIsNotNil(FImages);
  AssertInRange(ItemIndex, -1, ImagesCount - 1);

  if InRange(ItemIndex, 0, ImagesCount - 1) then
    Result := FImages[ItemIndex].Bitmap
  else
    Result := nil;
end;

function TfgFlipViewModel.GetImageCount: Integer;
begin
  AssertIsNotNil(FImages);

  Result := FImages.Count;
end;

procedure TfgFlipViewModel.HandlerEffectOptionsChanged(Sender: TObject);
begin
  SendMessage(TfgFlipViewMessages.MM_EFFECT_OPTIONS_CHANGED);
end;

procedure TfgFlipViewModel.HandlerImagesChanged(Collection: TfgCollection; Item: TCollectionItem;
  const Action: TfgCollectionNotification);
begin
  AssertIsNotNil(Item);
  if Action = TfgCollectionNotification.Updated then
    UpdateCurrentImage;
  if (Action = TfgCollectionNotification.Added) and (ItemIndex = -1) then
    ItemIndex := 0;
  if Action in [TfgCollectionNotification.Deleting, TfgCollectionNotification.Extracting] then
    ItemIndex := EnsureRange(ItemIndex, -1, ImagesCount - 2); // -2, because ImageCount return count before removing item
end;

procedure TfgFlipViewModel.HandlerOptionsChanged(Sender: TObject);
begin
  SendMessage(TfgFlipViewMessages.MM_SLIDE_OPTIONS_CHANGED);
end;

procedure TfgFlipViewModel.HandlerSlideShowOptionsChanged(Sender: TObject);
begin
  SendMessage(TfgFlipViewMessages.MM_SLIDESHOW_OPTIONS_CHANGED);
  if Owner is TfgCustomFlipView then
    TfgCustomFlipView(Owner).UpdateTimer;
end;

function TfgFlipViewModel.IsFirstImage: Boolean;
begin
  Result := ItemIndex = 0;
end;

function TfgFlipViewModel.IsLastImage: Boolean;
begin
  Result := ItemIndex = ImagesCount - 1;
end;

procedure TfgFlipViewModel.SetEffectOptions(const Value: TfgFlipViewEffectOptions);
begin
  AssertIsNotNil(Value);

  FEffectOptions.Assign(Value);
end;

procedure TfgFlipViewModel.SetImages(const Value: TfgImageCollection);
begin
  AssertIsNotNil(Value);

  FImages.Assign(Value);
end;

procedure TfgFlipViewModel.SetItemIndex(const Value: Integer);
begin
  if FItemIndex <> Value then
  begin
    FItemIndex := EnsureRange(Value, -1, ImagesCount - 1);
    SendMessage<Integer>(TfgFlipViewMessages.MM_ITEM_INDEX_CHANGED, FItemIndex);
  end;
end;

procedure TfgFlipViewModel.SetShowNavigationButtons(const Value: Boolean);
begin
  if FShowNavigationButtons <> Value then
  begin
    FShowNavigationButtons := Value;
    SendMessage<Boolean>(TfgFlipViewMessages.MM_SHOW_NAVIGATION_BUTTONS_CHANGED, FShowNavigationButtons);
  end;
end;

procedure TfgFlipViewModel.SetSlideShowOptions(const Value: TfgFlipViewSlideShowOptions);
begin
  AssertIsNotNil(Value);

  FSlideShowOptions.Assign(Value);
end;

procedure TfgFlipViewModel.SetSlidingOptions(const Value: TfgFlipViewSlideOptions);
begin
  AssertIsNotNil(Value);

  FSlidingOptions.Assign(Value);
end;

initialization
  RegisterFmxClasses([TfgCustomFlipView, TfgFlipView]);
end.
