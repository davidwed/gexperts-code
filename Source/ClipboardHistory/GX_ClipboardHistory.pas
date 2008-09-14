unit GX_ClipboardHistory;

{$I GX_CondDefine.inc}

interface

uses
  Classes, Controls, Forms, StdCtrls, ExtCtrls, Menus,
  ComCtrls, ActnList, ToolWin,
  GX_Experts, GX_ConfigurationInfo, GX_IdeDock;

type
  TClipInfo = class(TObject)
  private
    FClipTimeStamp: string;
    FClipString: string;
  public
    property ClipTimeStamp: string read FClipTimeStamp write FClipTimeStamp;
    property ClipString: string read FClipString write FClipString;
  end;

  TfmClipboardHistory = class(TfmIdeDockForm)
    Splitter: TSplitter;
    mmoClipText: TMemo;
    MainMenu: TMainMenu;
    mitFile: TMenuItem;
    mitFileExit: TMenuItem;
    mitEdit: TMenuItem;
    mitEditCopy: TMenuItem;
    mitHelp: TMenuItem;
    mitHelpContents: TMenuItem;
    mitHelpAbout: TMenuItem;
    mitHelpHelp: TMenuItem;
    mitHelpSep1: TMenuItem;
    mitEditClear: TMenuItem;
    lvClip: TListView;
    ToolBar: TToolBar;
    tbnClear: TToolButton;
    tbnCopy: TToolButton;
    tbnHelp: TToolButton;
    tbnSep2: TToolButton;
    Actions: TActionList;
    actFileExit: TAction;
    actEditCopy: TAction;
    actEditClear: TAction;
    actHelpHelp: TAction;
    actHelpContents: TAction;
    actHelpAbout: TAction;
    actEditPasteToIde: TAction;
    tbnPaste: TToolButton;
    mitEditPasteToIde: TMenuItem;
    mitView: TMenuItem;
    actViewToolBar: TAction;
    mitViewToolBar: TMenuItem;
    tbnSep3: TToolButton;
    btnOptions: TToolButton;
    actViewOptions: TAction;
    mitViewOptions: TMenuItem;
    actRehookClipboard: TAction;
    mitFileRehookClipboard: TMenuItem;
    tbnDelete: TToolButton;
    actDelete: TAction;
    mitEditDelete: TMenuItem;
    tbnSep1: TToolButton;
    mitEditSep1: TMenuItem;
    procedure FormResize(Sender: TObject);
    procedure SplitterMoved(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lvClipDblClick(Sender: TObject);
    procedure lvClipChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure actEditCopyExecute(Sender: TObject);
    procedure actEditClearExecute(Sender: TObject);
    procedure actFileExitExecute(Sender: TObject);
    procedure actHelpHelpExecute(Sender: TObject);
    procedure actHelpContentsExecute(Sender: TObject);
    procedure actHelpAboutExecute(Sender: TObject);
    procedure lvClipKeyPress(Sender: TObject; var Key: Char);
    procedure actEditPasteToIdeExecute(Sender: TObject);
    procedure ActionsUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure actViewToolBarExecute(Sender: TObject);
    procedure actViewOptionsExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure actRehookClipboardExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
  private
    FHelperWindow: TWinControl;
    IgnoreClip: Boolean;
    FDataList: TList;
    FLoading: Boolean;
    SplitterRatio: Double;
    procedure ClearDataList;
    procedure LoadClips;
    procedure SaveClips;
    function ConfigurationKey: string;
    procedure HookClipboard;
    function ClipInfoForItem(Item: TListItem): TClipInfo;
    function ClipInfoFromPointer(Ptr: Pointer): TClipInfo;
    function HaveSelectedItem: Boolean;
    procedure RemoveDataListItem(Index: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    procedure SaveSettings;
    procedure LoadSettings;
  end;

  TClipExpert = class(TGX_Expert)
  private
    FMaxClip: Integer;
    FAutoStart: Boolean;
    FAutoClose: Boolean;
    FStoragePath: string;
    function GetStorageFile: string;
  protected
    procedure SetActive(New: Boolean); override;
    procedure InternalLoadSettings(Settings: TGExpertsSettings); override;
    procedure InternalSaveSettings(Settings: TGExpertsSettings); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function GetActionCaption: string; override;
    class function GetName: string; override;
    procedure Click(Sender: TObject); override;
    procedure Configure; override;
    property MaxClip: Integer read FMaxClip write FMaxClip;
    property StorageFile: string read GetStorageFile;
  end;

var
  fmClipboardHistory: TfmClipboardHistory = nil;
  ClipExpert: TClipExpert = nil;

implementation

{$R *.dfm}

uses
  {$IFOPT D+} GX_DbugIntf, {$ENDIF}
  Windows, Messages, SysUtils, Clipbrd, Dialogs, OmniXML,
  GX_GxUtils, GX_GenericUtils, GX_OtaUtils,
  GX_GExperts, GX_ClipboardOptions, GX_SharedImages, GX_XmlUtils;

const
  ClipStorageFileName = 'ClipboardHistory.xml';

type
  THelperWinControl = class(TWinControl)
  private
    FPrevWindow: HWnd;
    procedure WMChangeCBChain(var Msg: TMessage); message WM_CHANGECBCHAIN;
    procedure WMDrawClipBoard(var Msg: TMessage); message WM_DRAWCLIPBOARD;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

function FirstLineOfText(const AClipString: string): string;
begin
  with TStringList.Create do
  try
    Text := AClipString;
    if Count > 0 then
      Result := Strings[0];
  finally
    Free;
  end;
end;

{ THelperWinControl }

constructor THelperWinControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Name := 'ClipboardChainHelperWindow';
  // The clipboard chaining only works properly if this window is
  // not parented by the the clip form.  The desktop window may not
  // be the best window to choose but it works.
  ParentWindow := GetDesktopWindow;
  Visible := False;
  {$IFOPT D+} SendDebug('In THelperWinControl Create'); {$ENDIF}
  FPrevWindow := SetClipBoardViewer(Self.Handle);
  {$IFOPT D+} SendDebug('FPrevWindow = ' + IntToStr(FPrevWindow)); {$ENDIF}
end;

destructor THelperWinControl.Destroy;
begin
  //{$IFOPT D+} SendDebug('In THelperWinControl Destroy'); {$ENDIF}
  try
    ChangeClipBoardChain(Self.Handle, FPrevWindow);
  except
    on E: Exception do
    begin
      {$IFOPT D+} SendDebugError('Clip Chain Destroy: ' + E.Message); {$ENDIF}
    end;
  end;
  inherited Destroy;
end;

procedure THelperWinControl.WMChangeCBChain(var Msg: TMessage);
begin
  {$IFOPT D+} SendDebug('In THelperWinControl WMChangeCBChain'); {$ENDIF}
  if Msg.WParam = Longint(FPrevWindow) then
    FPrevWindow := Msg.lParam
  else if (FPrevWindow <> 0) then
    SendMessage(FPrevWindow, WM_CHANGECBCHAIN, Msg.WParam, Msg.LParam);
  //Msg.Result := 0; //??
end;

procedure THelperWinControl.WMDrawClipBoard(var Msg: TMessage);
var
  ItemCount: Integer;
  ClipItem: TListItem;
  Info: TClipInfo;
  Handle: Cardinal;
  DataSize: Cardinal;
  ClipText: string;
begin
  try
    {$IFOPT D+} SendDebug('In THelperWinControl WMDrawClipBoard'); {$ENDIF}
    if not Assigned(fmClipboardHistory) then
      Exit;
    if fmClipboardHistory.IgnoreClip then
      Exit;
    try
      if Clipboard.HasFormat(CF_TEXT) then
      begin
        Clipboard.Open;
        try
          Handle := Clipboard.GetAsHandle(CF_TEXT);
          DataSize := GlobalSize(Handle);  // This function might over-estimate by a few bytes
        finally
          Clipboard.Close;
        end;
        // Don't try to save clipboard items over 512 KB for speed reasons
        if DataSize > ((1024 * 512) + 32) then
          Exit;

        ClipText := Clipboard.AsText;
        if (fmClipboardHistory.FDataList.Count = 0) or
           (TClipInfo(fmClipboardHistory.FDataList[0]).ClipString <> clipText) then begin
          {$IFOPT D+} SendDebug('New clipboard text detected'); {$ENDIF}
          fmClipboardHistory.mmoClipText.Text := ClipText;

          Info := TClipInfo.Create;
          fmClipboardHistory.FDataList.Insert(0, Info);
          Info.ClipString := fmClipboardHistory.mmoClipText.Text;
          Info.ClipTimeStamp := TimeToStr(Time);

          ClipItem := fmClipboardHistory.lvClip.Items.Insert(0);
          ClipItem.Caption := Info.ClipTimeStamp;
          ClipItem.SubItems.Add(Trim(FirstLineOfText(ClipText)));
          ClipItem.Data := Info;

          ItemCount := fmClipboardHistory.lvClip.Items.Count;
          if ItemCount > ClipExpert.MaxClip then
          begin
            Dec(ItemCount);
            fmClipboardHistory.lvClip.Items.Delete(ItemCount);
            TClipInfo(fmClipboardHistory.FDataList[ItemCount]).Free;
            fmClipboardHistory.FDataList.Delete(ItemCount);
          end;
          fmClipboardHistory.lvClip.Selected := nil;
          fmClipboardHistory.lvClip.Selected := fmClipboardHistory.lvClip.Items[0];
          fmClipboardHistory.lvClip.ItemFocused := fmClipboardHistory.lvClip.Selected;
        end;
      end;
    except
      on E: Exception do
      begin
        // Ignore exceptions
      end;
    end;
  finally
    if FPrevWindow <> 0 then
      SendMessage(FPrevWindow, WM_DRAWCLIPBOARD, Msg.WParam, Msg.LParam);
  end;
end;

{ TfmClipboardHistory }

procedure TfmClipboardHistory.FormResize(Sender: TObject);
begin
  mmoClipText.Height := Trunc(SplitterRatio * (mmoClipText.Height + lvClip.Height));
end;

procedure TfmClipboardHistory.SplitterMoved(Sender: TObject);
begin
  SplitterRatio := mmoClipText.Height / (lvClip.Height + mmoClipText.Height);
  FormResize(Self);
end;

procedure TfmClipboardHistory.ClearDataList;
var
  i: Integer;
begin
  if Assigned(FDataList) then
  begin
    for i := 0 to FDataList.Count - 1 do
      ClipInfoFromPointer(FDataList.Items[i]).Free;
    FDataList.Clear;
  end;
  lvClip.Items.Clear;
end;

procedure TfmClipboardHistory.Clear;
begin
  ClearDataList;
  mmoClipText.Lines.Clear;
end;

procedure TfmClipboardHistory.SaveSettings;
var
  Settings: TGExpertsSettings;
begin
  // Do not localize.
  Settings := TGExpertsSettings.Create;
  try
    Settings.WriteInteger(ConfigurationKey, 'Left', Left);
    Settings.WriteInteger(ConfigurationKey, 'Top', Top);
    Settings.WriteInteger(ConfigurationKey, 'Width', Width);
    Settings.WriteInteger(ConfigurationKey, 'Height', Height);
    Settings.WriteInteger(ConfigurationKey, 'SplitterRatio', Round(SplitterRatio * 100));
    Settings.WriteBool(ConfigurationKey, 'ViewToolBar', ToolBar.Visible);
  finally
    FreeAndNil(Settings);
  end;
end;

procedure TfmClipboardHistory.LoadSettings;
var
  Settings: TGExpertsSettings;
begin
  // Do not localize.
  Settings := TGExpertsSettings.Create;
  try
    Left := Settings.ReadInteger(ConfigurationKey, 'Left', Left);
    Top := Settings.ReadInteger(ConfigurationKey, 'Top', Top);
    Width := Settings.ReadInteger(ConfigurationKey, 'Width', Width);
    Height := Settings.ReadInteger(ConfigurationKey, 'Height', Height);
    SplitterRatio := Settings.ReadInteger(ConfigurationKey, 'SplitterRatio', 50) / 100;
    mmoClipText.Height :=  Trunc(SplitterRatio * (mmoClipText.Height + lvClip.Height));
    ToolBar.Visible := Settings.ReadBool(ConfigurationKey, 'ViewToolBar', True);
  finally
    FreeAndNil(Settings);
  end;
  EnsureFormVisible(Self);
end;

procedure TfmClipboardHistory.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TfmClipboardHistory.lvClipDblClick(Sender: TObject);
begin
  actEditCopy.Execute;
end;

procedure TfmClipboardHistory.LoadClips;
var
  Doc: IXmlDocument;
  Nodes: IXMLNodeList;
  i: Integer;
  TimeStr: string;
  ClipStr: string;
  Info: TClipInfo;
  ClipItem: TListItem;
  TimeNode: IXMLNode;
begin
  ClearDataList;
  Doc := CreateXMLDoc;
  if FileExists(ClipExpert.StorageFile) then begin
    Doc.Load(ClipExpert.StorageFile);
    if not Assigned(Doc.DocumentElement) then
      Exit;
    Nodes := Doc.DocumentElement.selectNodes('ClipItem');
    lvClip.Items.BeginUpdate;
    try
      FLoading := True;
      for i := 0 to Nodes.Length - 1 do
      begin
        if i >= ClipExpert.MaxClip then
          Break;
        TimeNode := Nodes.Item[i].Attributes.GetNamedItem('DateTime');
        if Assigned(TimeNode) then
          TimeStr := TimeNode.NodeValue
        else
          TimeStr := TimeToStr(Time);
        ClipStr := GX_XmlUtils.GetCDataSectionTextOrNodeText(Nodes.Item[i]);

        Info := TClipInfo.Create;
        FDataList.Add(Info);
        Info.ClipString := ClipStr;
        Info.ClipTimeStamp := TimeStr;

        ClipItem := lvClip.Items.Add;
        ClipItem.Caption := Info.ClipTimeStamp;
        ClipItem.SubItems.Add(Trim(FirstLineOfText(ClipStr)));
        ClipItem.Data := Info;
      end;
    finally
      lvClip.Items.EndUpdate;
      FLoading := False;
    end;
    if lvClip.Items.Count > 0 then
    begin
      lvClip.Selected := lvClip.Items[0];
      lvClip.ItemFocused := lvClip.Selected;
    end;
  end;
end;

procedure TfmClipboardHistory.SaveClips;
var
  Doc: IXmlDocument;
  Root: IXMLElement;
  i: Integer;
  ClipItem: IXMLElement;
  ClipText: IXMLCDATASection;
begin
  // We are calling SaveClips from the destructor where
  // we may be in a forced clean-up due to an exception.
  if ExceptObject <> nil then
    Exit;

  Doc := CreateXMLDoc;
  AddXMLHeader(Doc);
  Root := Doc.CreateElement('Clips');
  Doc.AppendChild(Root);
  for i := 0 to FDataList.Count - 1 do
  begin
    ClipItem := Doc.CreateElement('ClipItem');
    ClipItem.SetAttribute('DateTime', ClipInfoFromPointer(FDataList[i]).ClipTimeStamp);
    ClipText := Doc.CreateCDATASection(EscapeCDataText(ClipInfoFromPointer(FDataList[i]).ClipString));
    ClipItem.AppendChild(ClipText);
    Root.AppendChild(ClipItem);
  end;
  if PrepareDirectoryForWriting(ExtractFileDir(ClipExpert.StorageFile)) then
    Doc.Save(ClipExpert.StorageFile, ofFlat);
end;

procedure TfmClipboardHistory.lvClipChange(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  if FLoading then
    Exit;
  if lvClip.Selected <> nil then
    mmoClipText.Lines.Text := ClipInfoForItem(lvClip.Selected).ClipString
  else
    mmoClipText.Clear;
end;

constructor TfmClipboardHistory.Create(AOwner: TComponent);
resourcestring
  SLoadingFailed = 'Loading of stored clipboard clips failed.' + sLineBreak;
begin
  inherited Create(AOwner);

  SetToolbarGradient(ToolBar);
  SetDefaultFont(Self);
  {$IFOPT D+} SendDebug('Creating clipboard history data list'); {$ENDIF}
  FDataList := TList.Create;
  SplitterRatio := 0.50;
  LoadSettings;

  CenterForm(Self);
  IgnoreClip := False;

  // With large fonts, the TMenuToolBar ends up below the ToolBar, this fixes it
  ToolBar.Align := alNone;
  ToolBar.Top := 200;
  ToolBar.Align := alTop;

  HookClipboard;

  // Now load any saved clips from our XML storage.
  // Since we do not depend on these snippets, continue
  // even in the presence of an exception.
  try
    LoadClips;
  except
    on E: Exception do
    begin
      GxLogAndShowException(E, SLoadingFailed);
      // Swallow exceptions
    end;
  end;
end;

destructor TfmClipboardHistory.Destroy;
begin
  SaveClips;

  // Now free everything.
  ClearDataList;
  FreeAndNil(FDataList);
  FreeAndNil(FHelperWindow);
  SaveSettings;

  inherited Destroy;
  fmClipboardHistory := nil;
end;

procedure TfmClipboardHistory.actEditCopyExecute(Sender: TObject);
var
  i: Integer;
  ClipItem: TListItem;
  ClipInfo: TClipInfo;
  Info: TClipInfo;
  idx: Integer;
  Buffer: string;
begin
  try
    if mmoClipText.SelLength = 0 then
    begin
      if lvClip.SelCount = 1 then
      begin
        IgnoreClip := True;
        try
          idx := lvClip.Selected.Index;
          Buffer := mmoClipText.Text;
          Clipboard.AsText := Buffer;

          lvClip.Items.Delete(idx);
          ClipInfoFromPointer(FDataList[idx]).Free;
          FDataList.Delete(idx);

          Info := TClipInfo.Create;
          FDataList.Insert(0, Info);
          Info.ClipString := Buffer;
          Info.ClipTimeStamp := TimeToStr(Time);

          ClipItem := lvClip.Items.Insert(0);
          ClipItem.Caption := Info.ClipTimeStamp;
          ClipItem.SubItems.Add(Trim(FirstLineOfText(Buffer)));
          ClipItem.Data := Info;

          lvClip.Selected := lvClip.Items[0];
          lvClip.ItemFocused := lvClip.Selected;
        finally
          IgnoreClip := False;
        end;
      end
      else
      begin
        Buffer := '';
        for i := lvClip.Items.Count - 1 downto 0 do
        begin
          ClipItem := lvClip.Items[i];
          ClipInfo := ClipInfoFromPointer(ClipItem.Data);

          if ClipItem.Selected then
          begin
            Buffer := Buffer + ClipInfo.ClipString;
            if not HasTrailingEOL(Buffer) then
              Buffer := Buffer + sLineBreak;
          end;
        end;
        Clipboard.AsText := Buffer;
      end
    end
    else
      mmoClipText.CopyToClipBoard;

    if ClipExpert.FAutoClose then
      Self.Close;
  finally
    Application.ProcessMessages;
  end;
end;

procedure TfmClipboardHistory.actEditClearExecute(Sender: TObject);
resourcestring
  SConfirmClearClipHistory = 'Clear the clipboard history?';
begin
  if MessageDlg(SConfirmClearClipHistory, mtConfirmation, [mbOK, mbCancel], 0) = mrOk then
    Self.Clear;
end;

procedure TfmClipboardHistory.actFileExitExecute(Sender: TObject);
begin
  Self.Hide;
end;

procedure TfmClipboardHistory.actHelpHelpExecute(Sender: TObject);
begin
  GxContextHelp(Self, 13);
end;

procedure TfmClipboardHistory.actHelpContentsExecute(Sender: TObject);
begin
  GxContextHelpContents(Self);
end;

procedure TfmClipboardHistory.actHelpAboutExecute(Sender: TObject);
begin
  ShowGXAboutForm;
end;

procedure TfmClipboardHistory.lvClipKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;

  if Key = #13 then
    actEditCopy.Execute;
end;

procedure TfmClipboardHistory.actEditPasteToIdeExecute(Sender: TObject);
begin
  if mmoClipText.SelLength = 0 then
    GxOtaInsertTextIntoEditor(mmoClipText.Text)
  else
    GxOtaInsertTextIntoEditor(mmoClipText.SelText);
end;

procedure TfmClipboardHistory.ActionsUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  actEditCopy.Enabled := (mmoClipText.SelLength > 0) or HaveSelectedItem;
  actEditPasteToIde.Enabled := actEditCopy.Enabled;
  actDelete.Enabled := HaveSelectedItem;
  actViewToolBar.Checked := ToolBar.Visible;
  if lvClip.Items.Count > 0 then
  begin
    lvClip.Columns[0].Width := -1;
    lvClip.Columns[1].Width := -1;
  end
  else
  begin
    lvClip.Columns[0].Width := 100;
    lvClip.Columns[1].Width := 150;
  end;
end;

procedure TfmClipboardHistory.actViewToolBarExecute(Sender: TObject);
begin
  ToolBar.Visible := not ToolBar.Visible;
end;

procedure TfmClipboardHistory.actViewOptionsExecute(Sender: TObject);
begin
  ClipExpert.Configure;
end;

procedure TfmClipboardHistory.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    Close;
  end;
end;

function TfmClipboardHistory.ConfigurationKey: string;
begin
  Result := TClipExpert.ConfigurationKey + PathDelim + 'Window';
end;

procedure TfmClipboardHistory.HookClipboard;
begin
  FreeAndNil(FHelperWindow);
  {$IFOPT D+} SendDebug('Creating clipboard history THelperWinControl'); {$ENDIF}
  // The helper window is parented by the Desktop Window and
  // it chains the clipboard for us.
  FHelperWindow := THelperWinControl.Create(nil);
  {$IFOPT D+} SendDebug('Clipboard history helper window created'); {$ENDIF}
end;

procedure TfmClipboardHistory.actRehookClipboardExecute(Sender: TObject);
begin
  IgnoreClip := True;
  try
    HookClipboard;
  finally
    IgnoreClip := False;
  end;
end;

function TfmClipboardHistory.ClipInfoForItem(Item: TListItem): TClipInfo;
begin
  Assert(Assigned(Item));
  Assert(Assigned(Item.Data));
  Result := ClipInfoFromPointer(Item.Data);
end;

function TfmClipboardHistory.ClipInfoFromPointer(Ptr: Pointer): TClipInfo;
begin
  Assert(Assigned(Ptr));
  Result := TObject(Ptr) as TClipInfo;
end;

function TfmClipboardHistory.HaveSelectedItem: Boolean;
begin
  Result := Assigned(lvClip.Selected);
end;

procedure TfmClipboardHistory.RemoveDataListItem(Index: Integer);
var
  ClipInfo: TClipInfo;
begin
  Assert(Assigned(FDataList));
  Assert(Index < FDataList.Count);
  ClipInfo := ClipInfoFromPointer(FDataList.Items[Index]);
  FreeAndNil(ClipInfo);
  FDataList.Delete(Index);
end;

procedure TfmClipboardHistory.actDeleteExecute(Sender: TObject);
var
  i: Integer;
begin
  if not HaveSelectedItem then
    Exit;
  for i := lvClip.Items.Count - 1 downto 0 do
  begin
    if lvClip.Items[i].Selected then
    begin
      lvClip.Items.Delete(i);
      RemoveDataListItem(i);
    end;
  end;
  mmoClipText.Clear;
end;

{ TClipExpert }

constructor TClipExpert.Create;
begin
  inherited Create;
  FStoragePath := ConfigInfo.ConfigPath;

  FMaxClip := 20;

  FreeAndNil(ClipExpert);
  ClipExpert := Self;
end;

destructor TClipExpert.Destroy;
begin
  FreeAndNil(fmClipboardHistory);
  ClipExpert := nil;

  inherited Destroy;
end;

function TClipExpert.GetActionCaption: string;
resourcestring
  SMenuCaption = 'Clipboard &History';
begin
  Result := SMenuCaption;
end;

class function TClipExpert.GetName: string;
begin
  Result := 'ClipboardHistory';
end;

procedure TClipExpert.Click(Sender: TObject);
begin
  // If the form doesn't exist, create it.
  if fmClipboardHistory = nil then
  begin
    fmClipboardHistory := TfmClipboardHistory.Create(nil);
    SetFormIcon(fmClipboardHistory);
  end;
  IdeDockManager.ShowForm(fmClipboardHistory);
  fmClipboardHistory.lvClip.SetFocus;
end;

procedure TClipExpert.InternalLoadSettings(Settings: TGExpertsSettings);
begin
  inherited InternalLoadSettings(Settings);
  // Do not localize.
  FMaxClip := Min(Settings.ReadInteger(ConfigurationKey, 'Maximum', 20), 100);
  FAutoStart := Settings.ReadBool(ConfigurationKey, 'AutoStart', False);
  FAutoClose := Settings.ReadBool(ConfigurationKey, 'AutoClose', False);

  // This procedure is only called once, so it is safe to
  // register the form for docking here.
  if Active then
    IdeDockManager.RegisterDockableForm(TfmClipboardHistory, fmClipboardHistory, 'fmClipboardHistory');

  if FAutoStart and (fmClipboardHistory = nil) then
    fmClipboardHistory := TfmClipboardHistory.Create(nil);
end;

procedure TClipExpert.InternalSaveSettings(Settings: TGExpertsSettings);
begin
  inherited InternalSaveSettings(Settings);
  // Do not localize.
  Settings.WriteInteger(ConfigurationKey, 'Maximum', FMaxClip);
  Settings.WriteBool(ConfigurationKey, 'AutoStart', FAutoStart);
  Settings.WriteBool(ConfigurationKey, 'AutoClose', FAutoClose);
end;

procedure TClipExpert.Configure;
var
  Dlg: TfmClipboardOptions;
begin
  Dlg := TfmClipboardOptions.Create(nil);
  try
    Dlg.edtMaxClip.Text := IntToStr(FMaxClip);
    Dlg.chkAutoStart.Checked := FAutoStart;
    Dlg.chkAutoClose.Checked := FAutoClose;
    if Dlg.ShowModal = mrOk then
    begin
      FAutoStart := Dlg.chkAutoStart.Checked;
      FAutoClose := Dlg.chkAutoClose.Checked;
      FMaxClip := Min(StrToIntDef(Dlg.edtMaxClip.Text, 20), 100);
      SaveSettings;
    end;
  finally
    FreeAndNil(Dlg);
  end;
end;

function TClipExpert.GetStorageFile: string;
begin
  Result := FStoragePath + ClipStorageFileName;
end;

procedure TClipExpert.SetActive(New: Boolean);
begin
  if New <> Active then
  begin
    inherited SetActive(New);
    if New then
      // Nothing to initialize here
    else
      FreeAndNil(fmClipboardHistory);
  end;
end;

initialization
  RegisterGX_Expert(TClipExpert);
end.

