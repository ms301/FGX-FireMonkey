unit AndroidApi.ProgressDialog;

interface

uses
  Androidapi.JNI.App,
  Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.JavaTypes,
  Androidapi.JNIBridge;

type
  JProgressDialog = interface;//android.app.ProgressDialog


  JProgressDialogClass = interface(JAlertDialogClass)
  ['{670F662E-8777-4C53-92DD-CD78B2C6FE21}']
    { Property Methods }
    function _GetSTYLE_SPINNER: Integer;
    function _GetSTYLE_HORIZONTAL: Integer;
    { Methods }
    function init(P1: JContext): JProgressDialog; cdecl; overload;
    function init(P1: JContext; P2: Integer): JProgressDialog; cdecl; overload;
    function show(P1: JContext; P2: JCharSequence; P3: JCharSequence): JProgressDialog; cdecl; overload;
    function show(P1: JContext; P2: JCharSequence; P3: JCharSequence; P4: Boolean): JProgressDialog; cdecl; overload;
    function show(P1: JContext; P2: JCharSequence; P3: JCharSequence; P4: Boolean; P5: Boolean): JProgressDialog; cdecl; overload;
    function show(P1: JContext; P2: JCharSequence; P3: JCharSequence; P4: Boolean; P5: Boolean; P6: JDialogInterface_OnCancelListener): JProgressDialog; cdecl; overload;
    { Properties }
    property STYLE_SPINNER: Integer read _GetSTYLE_SPINNER;
    property STYLE_HORIZONTAL: Integer read _GetSTYLE_HORIZONTAL;
  end;

  [JavaSignature('android/app/ProgressDialog')]
  JProgressDialog = interface(JAlertDialog)
  ['{2CED09DE-2C56-464A-90B4-F9193B45B37D}']
    { Methods }
    procedure onStart; cdecl;
    procedure setProgress(P1: Integer); cdecl;
    procedure setSecondaryProgress(P1: Integer); cdecl;
    function getProgress: Integer; cdecl;
    function getSecondaryProgress: Integer; cdecl;
    function getMax: Integer; cdecl;
    procedure setMax(P1: Integer); cdecl;
    procedure incrementProgressBy(P1: Integer); cdecl;
    procedure incrementSecondaryProgressBy(P1: Integer); cdecl;
    procedure setProgressDrawable(P1: JDrawable); cdecl;
    procedure setIndeterminateDrawable(P1: JDrawable); cdecl;
    procedure setIndeterminate(P1: Boolean); cdecl;
    function isIndeterminate: Boolean; cdecl;
    procedure setMessage(P1: JCharSequence); cdecl;
    procedure setProgressStyle(P1: Integer); cdecl;
    procedure setProgressNumberFormat(P1: JString); cdecl;
  end;
  TJProgressDialog = class(TJavaGenericImport<JProgressDialogClass, JProgressDialog>) end;

implementation

end.
