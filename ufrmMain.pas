unit ufrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Webdriver4D, iniFiles;

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
    procedure Button2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
    function CreateWebDriver: TWebDriver;
    procedure Delay(ADelay: Integer);
    procedure KirimPesan;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

  WebSession: String;
  StatusKirim: Boolean;
  FWD: TWebDriver;
  ShowAwal: Boolean;

implementation

{$R *.dfm}

procedure TfrmMain.Timer2Timer(Sender: TObject);
var
  FcurElement: TWebElement;
  StrA: string;
  lst: TStringList;
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
    //memLog.Text   := FcurElement.AttributeValue('innerHTML');

    for i := 2 to lst.Count-1 do begin
      Pesan     := '';
      Waktu     := '';
      StatusPesan :=  '';

      StrA      := lst.Strings[i];
      StrA      := Copy(StrA,Pos('title="',StrA),MaxInt);
      StrA      := Copy(StrA,Pos('>',StrA)+1,MaxInt);

      Pengirim  := Copy(StrA,1,Pos('<',StrA)-1);
      Pengirim  := StringReplace(Pengirim,'+','',[rfReplaceAll,rfIgnoreCase]);
      Pengirim  := StringReplace(Pengirim,'-','',[rfReplaceAll,rfIgnoreCase]);
      Pengirim  := StringReplace(Pengirim,' ','',[rfReplaceAll,rfIgnoreCase]);

      StrA      := Copy(StrA,Pos('<',StrA)+1,MaxInt);
      StrA      := Copy(StrA,Pos('<',StrA)+1,MaxInt);
      StrA      := Copy(StrA,Pos('<',StrA)+1,MaxInt);
      StrA      := Copy(StrA,Pos('<',StrA)+1,MaxInt);
      StrA      := Copy(StrA,Pos('<',StrA)+1,MaxInt);
      StrA      := Copy(StrA,Pos('<',StrA)+1,MaxInt);
      StrA      := Copy(StrA,Pos('>',StrA)+1,MaxInt);

      Waktu     := Copy(StrA,1,Pos('<',StrA)-1);

      if Pos('"status-image"',StrA) <> 0 then begin
        Pesan     := '';
      end
      else begin
        StrA      := Copy(StrA,Pos('title=',StrA),MaxInt);
        StrA      := Copy(StrA,Pos('<',StrA)+1,MaxInt);
        StrA      := Copy(StrA,Pos('>',StrA)+1,MaxInt);

        Pesan     := Copy(StrA,1,Pos('</span>',StrA)-1);
      end;

      if Pos('unread message',StrA) <> 0 then begin
        StrA      := Copy(StrA,Pos('</span>',StrA)+7,MaxInt);
        StrA      := Copy(StrA,Pos('unread message',StrA)+7,MaxInt);
        StrA      := Copy(StrA,Pos('>',StrA)+1,MaxInt);

        StatusPesan   := Copy(StrA,1,Pos('<',StrA)-1);
      end
      else begin
        StatusPesan := '';
      end;

      // click posisi pesan
      if StatusPesan <> '' then begin
        FcurElement := FWd.FindElementByXPath('//*[@title=''_2_1wd copyable-text selectable-text'' or @data-tab=''3'']');
        if not FcurElement.IsEmpty then begin
          FcurElement.SendKey(Pengirim);
          FcurElement.Enter;
        end;
      end;
    end;

    lst.Free;

    // Kirim Pesan
    KirimPesan;
  end;

  Timer2.Enabled := True;
end;

procedure TfrmMain.KirimPesan;
var
  FcurElement: TWebElement;
begin
  if StatusKirim then begin

    FcurElement := FWd.FindElementByXPath('//*[@title=''_2_1wd copyable-text selectable-text'' or @data-tab=''3'']');
    if not FcurElement.IsEmpty then begin
      FcurElement.SendKey(Edit1.Text);
      FcurElement.Enter;
    end;

    Delay(1000);

    FcurElement := FWd.FindElementByXPath('//*[@title=''_2_1wd copyable-text selectable-text'' or @data-tab=''6'']');
    if not FcurElement.IsEmpty then begin
      FcurElement.SendKey(Edit2.Text);
      FcurElement.Enter;
    end;

    StatusKirim := False;
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
