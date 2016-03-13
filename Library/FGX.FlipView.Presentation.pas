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

unit FGX.FlipView.Presentation;

interface

uses
  FMX.Presentation.Style, FMX.Graphics,  FMX.Types, FMX.Controls.Model, FMX.Presentation.Messages, FMX.Objects,
  FMX.Controls, FGX.FlipView, FGX.FlipView.Types;

type

{ TStyledFlipViewBasePresentation }

  /// <summary>Base styled presentation of <c>TFlipView</c></summary>
  TfgStyledFlipViewBasePresentation = class(TStyledPresentation)
  private
    [Weak] FImageContainer: TImage;
    [Weak] FPreviousButton: TControl;
    [Weak] FNextButton: TControl;
    function GetModel: TfgFlipViewModel;
    procedure HandlerNextButtonClick(Sender: TObject);
    procedure HandlerPreviousButtonClick(Sender: TObject);
  protected
    { Messages from PresentationProxy }
    procedure PMGoToImage(var Message: TDispatchMessageWithValue<TfgShowImageInfo>); message TfgFlipViewMessages.PM_GO_TO_IMAGE;
    { Messages From Model}
    procedure MMItemIndexChanged(var AMessage: TDispatchMessageWithValue<Integer>); message TfgFlipViewMessages.MM_ITEM_INDEX_CHANGED;
  protected
    function DefineModelClass: TDataModelClass; override;
    { Styles }
    procedure ApplyStyle; override;
    procedure FreeStyle; override;
    function GetStyleObject: TFmxObject; override;
  public
    procedure ShowNextImage(const ANewItemIndex: Integer; const ADirection: TfgDirection; const AAnimate: Boolean); virtual;
    /// <summary>Returns link on style object <c>"image"</c>. Can be nil, if style doesn't have it.</summary>
    property ImageContainer: TImage read FImageContainer;
    /// <summary>Returns link on style object <c>"next-button"</c>. Can be nil, if style doesn't have it.</summary>
    property NextButton: TControl read FNextButton;
    /// <summary>Returns link on style object <c>"prev-button"</c>. Can be nil, if style doesn't have it.</summary>
    property PreviousButton: TControl read FPreviousButton;
    /// <summary>Return model of <c>TfgFlipVIew</c></summary>
    property Model: TfgFlipViewModel read GetModel;
  end;

implementation

uses
  System.Types, System.SysUtils, System.Math, FMX.Styles, FGX.Asserts;

{ TfgStyledFlipViewBasePresentation }

procedure TfgStyledFlipViewBasePresentation.ApplyStyle;
var
  StyleObject: TFmxObject;
begin
  inherited ApplyStyle;

  { Next button }
  StyleObject := FindStyleResource('next-button');
  if StyleObject is TControl then
  begin
    FNextButton := TControl(StyleObject);
    FNextButton.OnClick := HandlerNextButtonClick;
  end;

  { Previous button }
  StyleObject := FindStyleResource('prev-button');
  if StyleObject is TControl then
  begin
    FPreviousButton := TControl(StyleObject);
    FPreviousButton.OnClick := HandlerPreviousButtonClick;
  end;

  { Image container for current slide }
  StyleObject := FindStyleResource('image');
  if StyleObject is TImage then
  begin
    FImageContainer := TImage(StyleObject);
    FImageContainer.Visible := True;
  end;
end;

function TfgStyledFlipViewBasePresentation.DefineModelClass: TDataModelClass;
begin
  Result := TfgFlipViewModel;
end;

procedure TfgStyledFlipViewBasePresentation.FreeStyle;
begin
  if FNextButton <> nil then
    FNextButton.OnClick := nil;
  FNextButton := nil;
  if FPreviousButton <> nil then
    FPreviousButton.OnClick := nil;
  FPreviousButton := nil;
  FImageContainer := nil;
  inherited FreeStyle;
end;

function TfgStyledFlipViewBasePresentation.GetModel: TfgFlipViewModel;
begin
  Result := inherited GetModel<TfgFlipViewModel>;
end;

function TfgStyledFlipViewBasePresentation.GetStyleObject: TFmxObject;
const
  ResourceName = 'TfgFlipViewStyle';
var
  StyleContainer: TFmxObject;
begin
  Result := nil;
  if StyleLookup.IsEmpty and (FindResource(HInstance, PChar(ResourceName), RT_RCDATA) <> 0) then
  begin
    StyleContainer := TStyleStreaming.LoadFromResource(HInstance, ResourceName, RT_RCDATA);
    Result := StyleContainer.FindStyleResource('fgFlipViewStyle', True);
    if Result <> nil then
      Result.Parent := nil;
    StyleContainer.Free;
  end;
  if Result = nil then
    Result := inherited GetStyleObject;
end;

procedure TfgStyledFlipViewBasePresentation.HandlerNextButtonClick(Sender: TObject);
begin
  AssertIsNotNil(Model);

  ShowNextImage(IfThen(Model.IsLastImage, 0, Model.ItemIndex + 1), TfgDirection.Forward, True);
end;

procedure TfgStyledFlipViewBasePresentation.HandlerPreviousButtonClick(Sender: TObject);
begin
  AssertIsNotNil(Model);

  ShowNextImage(IfThen(Model.IsLastImage, 0, Model.ItemIndex + 1), TfgDirection.Backward, True);
end;

procedure TfgStyledFlipViewBasePresentation.MMItemIndexChanged(var AMessage: TDispatchMessageWithValue<Integer>);
begin
  AssertIsNotNil(Model);

  if ImageContainer <> nil then
    ImageContainer.Bitmap.Assign(Model.CurrentImage);
end;

procedure TfgStyledFlipViewBasePresentation.PMGoToImage(var Message: TDispatchMessageWithValue<TfgShowImageInfo>);
begin
  ShowNextImage(Message.Value.NewItemIndex, Message.Value.Direction, Message.Value.Animate);
end;

procedure TfgStyledFlipViewBasePresentation.ShowNextImage(const ANewItemIndex: Integer; const ADirection: TfgDirection;
  const AAnimate: Boolean);
begin
  AssertIsNotNil(Model);

  Model.DisableNotify;
  try
    Model.ItemIndex := ANewItemIndex;
    Model.StartChanging(ANewItemIndex);
  finally
    Model.EnableNotify;
  end;
end;

end.
