unit ufrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Webdriver4D, iniFiles,
  Vcl.ExtDlgs, MSHTML;

type
  TfrmMain = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button2: TButton;
    Button3: TButton;
    memLog: TMemo;
    Timer2: TTimer;
    Memo1: TMemo;
    Panel3: TPanel;
    Button6: TButton;
    Label6: TLabel;
    Edit1: TEdit;
    Label7: TLabel;
    Edit2: TEdit;
    Label1: TLabel;
    Edit3: TEdit;
    OpenPictureDialog1: TOpenPictureDialog;
    Button1: TButton;
    procedure Button2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    function CreateWebDriver: TWebDriver;
    procedure Delay(ADelay: Integer);
    procedure KirimPesan;
    procedure GetDataInputSearchXPath;
    procedure GetDataInputMessageXPath;
    procedure TypeMessage(Msg: string);
    function StripHTML(S: string): string;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

  WebSession: String;
  StatusKirim: Boolean;
  FWD: TWebDriver;
  ShowAwal: Boolean;

  DataInputSearchXPath: String;
  DataInputMessageXPath: string;

implementation

{$R *.dfm}

procedure TfrmMain.GetDataInputSearchXPath;
var
  StrBuff,
  StrBuff1,
  StrBuff2:String;
begin
  if DataInputSearchXPath = '' then begin
    StrBuff := FWD.GetDocument;
    if Pos('Search or start new chat',StrBuff) <> 0 then begin
      StrBuff := Copy(StrBuff,Pos('Search or start new chat',StrBuff),MaxInt);
      StrBuff := Copy(StrBuff,Pos('copyable-text selectable-text',StrBuff)-50,MaxInt);
      StrBuff   := Copy(StrBuff,Pos('class="',StrBuff)+7,maxint);
      StrBuff1  := Copy(StrBuff,1,Pos('"',StrBuff)-1);
      StrBuff   := Copy(StrBuff,Pos('data-tab="',StrBuff)+10,maxint);
      StrBuff2  := Copy(StrBuff,1,Pos('"',StrBuff)-1);
      if (StrBuff1 <> '') and (StrBuff2 <> '') then begin
        DataInputSearchXPath  := '//*[@class='''+StrBuff1+''' and @data-tab='''+StrBuff2+''']';
      end;
    end;
  end;
end;

procedure TfrmMain.GetDataInputMessageXPath;
var
  StrBuff,
  StrBuff1,
  StrBuff2:String;
  FcurElement: TWebElement;
begin
  if DataInputMessageXPath = '' then begin
    FcurElement := FWd.FindElementByXPath('//footer[contains(@tabindex,''-1'')]');
    if not FcurElement.IsEmpty then begin
      StrBuff   := FcurElement.AttributeValue('innerHTML');
      StrBuff   := Copy(StrBuff,Pos('Search or start new chat',StrBuff),MaxInt);
      StrBuff   := Copy(StrBuff,Pos('copyable-text selectable-text',StrBuff)-50,MaxInt);
      StrBuff   := Copy(StrBuff,Pos('class="',StrBuff)+7,maxint);
      StrBuff1  := Copy(StrBuff,1,Pos('"',StrBuff)-1);
      StrBuff   := Copy(StrBuff,Pos('data-tab="',StrBuff)+10,maxint);
      StrBuff2  := Copy(StrBuff,1,Pos('"',StrBuff)-1);
      if (StrBuff1 <> '') and (StrBuff2 <> '') then begin
        DataInputMessageXPath  := '//*[@class='''+StrBuff1+''' and @data-tab='''+StrBuff2+''']';
      end;
    end;
  end;
end;

function TfrmMain.StripHTML(S: string): string;
var
  doc: OleVariant;
  el: OleVariant;
  i: Integer;

  TS: TStringList;
begin
  TS := TStringList.Create;
  doc := coHTMLDocument.Create as IHTMLDocument2;

  TS.Clear;

  S := StringReplace(S, #10, '''#A''',[rfReplaceAll, rfIgnoreCase]);

  doc.write(S);
  doc.close;

  el := doc.body.all.item(0);
  if (el.tagName = 'DIV')  then
    TS.Add(el.outerText);

  Result := TS.Text;

  TS.Free;
end;

function GetNumberPhone(aStr, Phone: string) : string;
var
  doc: OleVariant;
  el: OleVariant;
  i: Integer;
  j: Int64;
  Buff: string;
begin
  if TryStrToInt64(Phone,j) then begin
    Result := Phone;
    Exit;
  end;
  

  doc := coHTMLDocument.Create as IHTMLDocument2;
  doc.write(aStr);
  doc.close;

  Buff := '';

  for i := 0 to doc.body.all.length-1 do
  begin
    el := doc.body.all.item(i);
    if (el.tagName = 'IMG')  then begin
      Buff := el.outerHTML;
      Break;
    end;
  end;

  if Buff <> '' then begin
    Buff := Copy(Buff,Pos('src="',Buff)+5,MaxInt);
    Buff := Copy(Buff,1, Pos('"',Buff));
    Buff := Copy(Buff,Pos('s&amp;u=',Buff)+8,MaxInt);
    Buff := Copy(Buff,1, Pos('%40c',Buff)-1);
  end
  else begin
    Buff := Phone;
  end;

  Result := Buff;
end;

procedure TfrmMain.Timer2Timer(Sender: TObject);
var
  FcurElement: TWebElement;
  StrA: string;
  lst, TStrA: TStringList;
  i: Integer;

  Pengirim,
  Waktu,
  Pesan,
  StatusPesan: String;
begin
  Timer2.Enabled := False;

  FcurElement := FWd.FindElementByXPath('//div[@id=''pane-side'']');
  if not FcurElement.IsEmpty then begin
    lst           := TStringList.Create;
    lst.LineBreak := 'tabindex="-1"';
    lst.Text      := FcurElement.AttributeValue('innerHTML');

    for i := 2 to lst.Count-1 do begin
      Pengirim  := '';
      Pesan     := '';
      Waktu     := '';
      StatusPesan :=  '';

      StrA      := StripHTML(lst.Strings[i]);
      TStrA     := TStringList.Create;

      try
        TStrA.Text  := StrA;
        if TStrA.Count = 5 then begin
          Pengirim  := TStrA.Strings[1];
          Pengirim  := StringReplace(Pengirim,' ','',[rfReplaceAll, rfIgnoreCase]);
          Pengirim  := StringReplace(Pengirim,'-','',[rfReplaceAll, rfIgnoreCase]);
          Pengirim  := StringReplace(Pengirim,'+','',[rfReplaceAll, rfIgnoreCase]);
          Pengirim  := GetNumberPhone(lst.Strings[i], Pengirim);
          Waktu     := TStrA.Strings[2];
          Pesan     := StringReplace(TStrA.Strings[3],'''''#A''''', #13#10,[rfReplaceAll, rfIgnoreCase]);
          Pesan     := StringReplace(TStrA.Strings[3],'''#A''', #13#10,[rfReplaceAll, rfIgnoreCase]);
          StatusPesan := TStrA.Strings[4];
        end
        else begin
          Pengirim  := TStrA.Strings[1];
          Pengirim  := StringReplace(Pengirim,' ','',[rfReplaceAll, rfIgnoreCase]);
          Pengirim  := StringReplace(Pengirim,'-','',[rfReplaceAll, rfIgnoreCase]);
          Pengirim  := StringReplace(Pengirim,'+','',[rfReplaceAll, rfIgnoreCase]);
          Pengirim  := GetNumberPhone(lst.Strings[i], Pengirim);
          Waktu     := TStrA.Strings[2];
          Pesan     := StringReplace(TStrA.Strings[3],'''''#A''''', #13#10,[rfReplaceAll, rfIgnoreCase]);
          Pesan     := StringReplace(TStrA.Strings[3],'''#A''', #13#10,[rfReplaceAll, rfIgnoreCase]);
          StatusPesan := '';
        end;
      except
      end;

      TStrA.Free;

//      StrA      := Copy(StrA,Pos('title="',StrA),MaxInt);
//      StrA      := Copy(StrA,Pos('>',StrA)+1,MaxInt);
//
//      Pengirim  := Copy(StrA,1,Pos('<',StrA)-1);
//      Pengirim  := StringReplace(Pengirim,'+','',[rfReplaceAll,rfIgnoreCase]);
//      Pengirim  := StringReplace(Pengirim,'-','',[rfReplaceAll,rfIgnoreCase]);
//      Pengirim  := StringReplace(Pengirim,' ','',[rfReplaceAll,rfIgnoreCase]);
//
//      StrA      := Copy(StrA,Pos('<',StrA)+1,MaxInt);
//      StrA      := Copy(StrA,Pos('<',StrA)+1,MaxInt);
//      StrA      := Copy(StrA,Pos('<',StrA)+1,MaxInt);
//      StrA      := Copy(StrA,Pos('<',StrA)+1,MaxInt);
//      StrA      := Copy(StrA,Pos('<',StrA)+1,MaxInt);
//      StrA      := Copy(StrA,Pos('<',StrA)+1,MaxInt);
//      StrA      := Copy(StrA,Pos('>',StrA)+1,MaxInt);
//
//      Waktu     := Copy(StrA,1,Pos('<',StrA)-1);
//
//      if Pos('"status-image"',StrA) <> 0 then begin
//        Pesan     := '';
//      end
//      else begin
//        StrA      := Copy(StrA,Pos('title=',StrA),MaxInt);
//        StrA      := Copy(StrA,Pos('<',StrA)+1,MaxInt);
//        StrA      := Copy(StrA,Pos('>',StrA)+1,MaxInt);
//
//        Pesan     := Copy(StrA,1,Pos('</span>',StrA)-1);
//      end;
//
//      if Pos('unread message',StrA) <> 0 then begin
//        StrA      := Copy(StrA,Pos('</span>',StrA)+7,MaxInt);
//        StrA      := Copy(StrA,Pos('unread message',StrA)+7,MaxInt);
//        StrA      := Copy(StrA,Pos('>',StrA)+1,MaxInt);
//
//        StatusPesan   := Copy(StrA,1,Pos('<',StrA)-1);
//      end
//      else begin
//        StatusPesan := '';
//      end;

      // click posisi pesan
      if StatusPesan <> '' then begin
        GetDataInputSearchXPath;
        FcurElement := FWd.FindElementByXPath(DataInputSearchXPath);
        if not FcurElement.IsEmpty then begin
          FcurElement.SendKey(Pengirim);
          FcurElement.Enter;

          Memo1.Lines.Add('-- New Message --');
          Memo1.Lines.Add('Number: '+Pengirim);
          Memo1.Lines.Add('Time: '+Waktu);
          Memo1.Lines.Add('Message: '+Pesan);
          Memo1.Lines.Add('');
        end;
      end;
    end;

    lst.Free;

    // Kirim Pesan
    KirimPesan;
  end;

  Timer2.Enabled := True;
end;

procedure TfrmMain.TypeMessage(Msg: string);
var
  CapsOn: boolean;
  i: integer;
  ch: char;
  shift: boolean;
  key: short;
begin
  CapsOn := (GetKeyState( VK_CAPITAL ) and $1) <> 0;

  for i:=1 to length(Msg) do
  begin
    ch := Msg[i];
    ch := UpCase(ch);

    if ch <> Msg[i] then
    begin
      if CapsOn then
      begin
        keybd_event( VK_SHIFT, 0, 0, 0 );
      end;
      keybd_event( ord(ch), 0, 0, 0 );
      keybd_event( ord(ch), 0, KEYEVENTF_KEYUP, 0 );
      if CapsOn then
      begin
        keybd_event( VK_SHIFT, 0, KEYEVENTF_KEYUP, 0 );
      end;
    end
    else
    begin
      key := VKKeyScan( ch );
      // UpperCase
      if ((not CapsOn) and (ch>='A') and (ch <= 'Z')) or
         ((key and $100) > 0) then
      begin
        keybd_event( VK_SHIFT, 0, 0, 0 );
      end;
      keybd_event( key, 0, 0, 0 );
      keybd_event( key, 0, KEYEVENTF_KEYUP, 0 );
      if ((not CapsOn) and (ch>='A') and (ch <= 'Z')) or
         ((key and $100) > 0) then
      begin
        keybd_event( VK_SHIFT, 0, KEYEVENTF_KEYUP, 0 );
      end;
    end;
  end;
end;

procedure TfrmMain.KirimPesan;
var
  FcurElement: TWebElement;
  notepad: HWND;
begin
  if StatusKirim then begin

    GetDataInputSearchXPath;
    FcurElement := FWd.FindElementByXPath(DataInputSearchXPath);
    if not FcurElement.IsEmpty then begin
      FcurElement.SendKey(Edit1.Text);
      FcurElement.Enter;
    end;

    Delay(1000);

    if Edit3.Text <> '' then begin
      FcurElement := FWd.FindElementByXPath('//*[@data-testid=''clip'' and @data-icon=''clip'']');
      if not FcurElement.IsEmpty then begin
        FcurElement.Click;
      end;

      Delay(1000);

      FcurElement := FWd.FindElementByXPath('//*[@data-testid=''attach-image'' and @data-icon=''attach-image'']');
      if not FcurElement.IsEmpty then begin
        FcurElement.Click;
      end;

      Delay(1000);

      TypeMessage(Edit3.Text+#13);

      Delay(1000);

      GetDataInputMessageXPath;
      FcurElement := FWd.FindElementByXPath(DataInputMessageXPath);
      if not FcurElement.IsEmpty then begin
        FcurElement.SendKey(Edit2.Text);
        //FcurElement.Enter;
      end;

      FcurElement := FWd.FindElementByXPath('//*[@data-testid=''send'' and @data-icon=''send'']');
      if not FcurElement.IsEmpty then begin
        FcurElement.Click;
      end;

      Memo1.Lines.Add('-- Send Image --');
      Memo1.Lines.Add('Number: '+Edit1.Text);
      Memo1.Lines.Add('Time: '+FormatDateTime('hh:nn',Now));
      Memo1.Lines.Add('Message: '+Edit2.Text);
      Memo1.Lines.Add('Image: '+Edit3.Text);
      Memo1.Lines.Add('');
    end
    else begin
      GetDataInputMessageXPath;
      FcurElement := FWd.FindElementByXPath(DataInputMessageXPath);
      if not FcurElement.IsEmpty then begin
        FcurElement.SendKey(Edit2.Text);
        FcurElement.Enter;
      end;

      Memo1.Lines.Add('-- Send Message --');
      Memo1.Lines.Add('Number: '+Edit1.Text);
      Memo1.Lines.Add('Time: '+FormatDateTime('hh:nn',Now));
      Memo1.Lines.Add('Message: '+Edit2.Text);
      Memo1.Lines.Add('');
    end;

    StatusKirim := False;
  end;
end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  OpenPictureDialog1.Filter := 'All (*.gif;*.png;*.jpg;*.jpeg;*.bmp;*.ico;*.emf;*.wmf;*.tif;*.tiff)|*.gif;*.png;*.jpg;*.'+
                               'jpeg;*.bmp;*.ico;*.emf;*.wmf;*.tif;*.tiff|GIF Image (*.gif)|*.gif|Portable Network Graphics'+
                               ' (*.png)|*.png|JPEG Image File (*.jpg)|*.jpg|JPEG Image File (*.jpeg)|*.jpeg|Bitmaps (*.bmp)|'+
                               '*.bmp|Icons (*.ico)|*.ico|Enhanced Metafiles (*.emf)|*.emf|Metafiles (*.wmf)|*.wmf|TIFF Images'+
                               ' (*.tif)|*.tif|TIFF Images (*.tiff)|*.tiff';
  if OpenPictureDialog1.Execute then begin
    Edit3.Text := OpenPictureDialog1.FileName;
  end;
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
  Timer2.Enabled := True;
end;

procedure TfrmMain.Button3Click(Sender: TObject);
begin
  if (WebSession <> '') and (Assigned(FWD)) then begin
    FWD.CloseWindow(WebSession);
    FreeAndNil(FWD);
    //Chrome.Free;
    WebSession := '';
  end;
end;

procedure TfrmMain.Button6Click(Sender: TObject);
begin
  StatusKirim := True;
end;

function TfrmMain.CreateWebDriver: TWebDriver;
var
  WD:TWebDriver;
  Chrome: TChromeDriver absolute WD;
begin
  if Assigned(FWD) then FreeAndNil(FWD);

  Chrome      :=  TChromeDriver.Create(nil);
  Chrome.StartDriver(ExtractFilePath(ParamStr(0))+'chromedriver.exe');
  WebSession  := Chrome.NewSession('["start-maximized","user-data-dir=c:/tp"]');
  if WebSession = '' then
    ShowMessage(Chrome.ErrorMessage);
  result      := Chrome;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (WebSession <> '') and (Assigned(FWD)) then begin
    FWD.CloseWindow(WebSession);
    FreeAndNil(FWD);
    WebSession := '';
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  DataInputSearchXPath := '';
  DataInputMessageXPath := '';

  FWD := CreateWebDriver;
  FWD.GetURL('https://web.whatsapp.com/');

  ShowAwal := True;
  StatusKirim := False;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  if ShowAwal then begin
    ShowAwal := False;

    Button2Click(Self);
  end;
end;

procedure TfrmMain.Delay(ADelay: Integer);
var
  WaktuAwal: DWORD;
begin
  WaktuAwal := GetTickCount;
  repeat
    Sleep(1);
    Application.ProcessMessages;
  until (GetTickCount-WaktuAwal) > ADelay;
end;

end.
