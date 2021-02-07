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

unit FmGX.Types.StateValue;

interface

{$SCOPEDENUMS ON}

type

{ TfgStateValue }

  ///  <summary>Базовый класс - счетчик, служащий для контролирования процессов, которые имею фазы начала и конца
  ///  обновления. Позволяет отследить из вне фазу завершения процесса обновления через событие <c>OnEndUpdate</c> и
  ///  коллбэк <c>OnEndUpdateCallback</c></summary>
  ///  <remarks>Например, этот класс используется для пакетного изменения настроек. Если мы не хотим, чтобы при пакетном
  ///  обновлении свойств объекта, каждое изменение приводило к каким-либо действиям, то используя этот объект,
  ///  эти действия можно выполнить один раз по окончанию изменения.</remarks>
  TfgStateValue = class
  public type
    TfgChangeKind = (BeginUpdate, EndUpdate);
    TfgOnChange = procedure (const AKind: TfgChangeKind) of object;
    TfgOnEndUpdateMethod = procedure of object;
    TfgOnEndUpdateCallback = reference to procedure;
  private
    FUpdatingCount: Integer;
    FOnChange: TfgOnChange;
    FOnEndUpdateMethod: TfgOnEndUpdateMethod;
    FOnEndUpdateCallback: TfgOnEndUpdateCallback;
  protected
    procedure DoChange(const AKind: TfgChangeKind); virtual;
    procedure DoEndUpdate; virtual;
  public
    constructor Create(const AOnEndUpdate: TfgOnEndUpdateMethod = nil); overload;
    constructor Create(const AOnEndUpdateCallback: TfgOnEndUpdateCallback = nil); overload;
    destructor Destroy; override;
    /// <summary>Сигнализировать о начале процесса обновления.</summary>
    /// <remarks>Можно вызывать более одного раза. В этом случае на каждый вызов требуется вызывать в конце <c>EndUpdate</c>.</remarks>
    procedure BeginUpdate;
    /// <summary>Сигнализировать об окончании процесса обновления. Если процесс обновления закончен <c>IsUpdating = False</c>,
    /// то будет вызвано событие <c>OnEndUpdate</c> и коллбэк <c>OnEndUpdateCallback</c>.</summary>
    /// <remarks>Это метод обязательно должен быть вызван столько раз, сколько было вызвано до <c>BeginUpdate</c>.
    /// При этом, если объект не находился в состоянии обновления, то это не приведет к срабатыванию события
    /// <c>OnEndUpdate</c> и коллбэк <c>OnEndUpdateCallback</c>.</remarks>
    procedure EndUpdate;
    /// <summary>В процессе обновления?</summary>
    function IsUpdating: Boolean;
  public
    property OnChange: TfgOnChange read FOnChange write FOnChange;
    property OnEndUpdateCallback: TfgOnEndUpdateCallback read FOnEndUpdateCallback write FOnEndUpdateCallback;
    property OnEndUpdateMethod: TfgOnEndUpdateMethod read FOnEndUpdateMethod write FOnEndUpdateMethod;
  end;

implementation

uses
  FmGX.Asserts;

{ TfgStateValue }

procedure TfgStateValue.DoChange(const AKind: TfgChangeKind);
begin
  if Assigned(FOnChange) then
    FOnChange(AKind);
end;

procedure TfgStateValue.DoEndUpdate;
begin
  if Assigned(FOnEndUpdateMethod) then
    FOnEndUpdateMethod;
  if Assigned(FOnEndUpdateCallback) then
    FOnEndUpdateCallback;
end;

constructor TfgStateValue.Create(const AOnEndUpdate: TfgOnEndUpdateMethod);
begin
  inherited Create;
  FOnEndUpdateMethod := AOnEndUpdate;
end;

constructor TfgStateValue.Create(const AOnEndUpdateCallback: TfgOnEndUpdateCallback);
begin
  inherited Create;
  FOnEndUpdateCallback := AOnEndUpdateCallback;
end;

destructor TfgStateValue.Destroy;
begin
  TfgxAssert.IsFalse(IsUpdating, 'При удалении объекта состояния TfgStateValue обнаружено, что он находится в состоянии обновления. Это вызвано тем, что клиент не вызвал парный EndUpdate метод');

  inherited;
end;

procedure TfgStateValue.BeginUpdate;
begin
  TfgxAssert.MoreAndEqulThan(FUpdatingCount, 0);

  DoChange(TfgChangeKind.BeginUpdate);
  Inc(FUpdatingCount);
end;

procedure TfgStateValue.EndUpdate;
begin
  TfgxAssert.StrickMoreThan(FUpdatingCount, 0);

  if IsUpdating then
  begin
    DoChange(TfgChangeKind.EndUpdate);
    Dec(FUpdatingCount);
    if FUpdatingCount = 0 then
      DoEndUpdate;
  end;
end;

function TfgStateValue.IsUpdating: Boolean;
begin
  TfgxAssert.MoreAndEqulThan(FUpdatingCount, 0);

  Result := FUpdatingCount > 0;
end;

end.
