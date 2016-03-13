{*******************************************************}
{                                                       }
{           CodeGear Delphi Runtime Library             }
{ Copyright(c) 2014 Embarcadero Technologies, Inc.      }
{                                                       }
{*******************************************************}

unit AndroidApi.JNI.Toasts;

interface

uses
  Androidapi.JNIBridge,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes;

type
// ===== Forward declarations =====
  JToast = interface;//android.widget.Toast

// ===== Interface declarations =====
  JToastClass = interface(JObjectClass)
    ['{D06A7EAF-EE60-4F55-A3EA-E7B0B37EC7CB}']
    {class} function _GetLENGTH_LONG: Integer; cdecl;
    {class} function _GetLENGTH_SHORT: Integer; cdecl;
    {class} function init(context: JContext): JToast; cdecl;
    {class} function makeText(context: JContext; text: JCharSequence; duration: Integer): JToast; cdecl; overload;
    {class} function makeText(context: JContext; resId: Integer; duration: Integer): JToast; cdecl; overload;
    {class} property LENGTH_LONG: Integer read _GetLENGTH_LONG;
    {class} property LENGTH_SHORT: Integer read _GetLENGTH_SHORT;
  end;

  [JavaSignature('android/widget/Toast')]
  JToast = interface(JObject)
    ['{410DDA5F-7D4B-415E-8BE4-F545D331176C}']
    procedure cancel; cdecl;
    function getDuration: Integer; cdecl;
    function getGravity: Integer; cdecl;
    function getHorizontalMargin: Single; cdecl;
    function getVerticalMargin: Single; cdecl;
    function getView: JView; cdecl;
    function getXOffset: Integer; cdecl;
    function getYOffset: Integer; cdecl;
    procedure setDuration(duration: Integer); cdecl;
    procedure setGravity(gravity: Integer; xOffset: Integer; yOffset: Integer); cdecl;
    procedure setMargin(horizontalMargin: Single; verticalMargin: Single); cdecl;
    procedure setText(resId: Integer); cdecl; overload;
    procedure setText(s: JCharSequence); cdecl; overload;
    procedure setView(view: JView); cdecl;
    procedure show; cdecl;
  end;
  TJToast = class(TJavaGenericImport<JToastClass, JToast>) end;

  
implementation

procedure RegisterTypes;
begin
  TRegTypes.RegisterType('Androidapi.JNI.Toasts.JToast', TypeInfo(Androidapi.JNI.Toasts.JToast));
end;

initialization
  RegisterTypes;
end.


