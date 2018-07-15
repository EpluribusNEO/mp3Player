unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Buttons,
  MPlayer{Медиа плеер}, MMSYSTEM{WAVE_MAPPER}, FileCtrl {SelectDirectory};

type
  TFrmMain = class(TForm)
    labNameTrack: TLabel;
    labTime: TLabel;
    Timer1: TTimer;
    lbPlayList: TListBox;
    sBtnPrev: TSpeedButton;
    sBtnPlay: TSpeedButton;
    sBtnNext: TSpeedButton;
    sBtnFolder: TSpeedButton;
    sBtnINFO: TSpeedButton;
    tBarVolume: TTrackBar;
    MediaPlayer1: TMediaPlayer;


    procedure FrmMain_Create(Sender: TObject);
    procedure lbPlayList_Click(Sender: TObject);
    procedure sBtnPrev_Click(Sender: TObject);
    procedure sBtnPlay_Click(Sender: TObject);
    procedure sBtnNext_Click(Sender: TObject);
    procedure sBtnFolder_Click(Sender: TObject);
    procedure sBtnINFO_Click(Sender: TObject);
    procedure tBarVolume_Change(Sender: TObject);
    procedure Timer1_Timer(Sender: TObject);

  private
    { Private declarations }
    MediaPlayer: TMediaPlayer;
    procedure Play;
    procedure PlayList(path: string);
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}
var _Path: string[255];
var _min, _sec: Integer;
var _volume: LongWord;

///
///
procedure TFrmMain.FrmMain_Create(Sender: TObject);
begin
  MediaPlayer := TMediaPlayer.Create(self);
  MediaPlayer.Parent := FrmMain;
  MediaPlayer.Visible := FALSE;
  Timer1.Enabled := FALSE;

  sBtnPlay.AllowAllUp := TRUE;
  sBtnPlay.GroupIndex := 1;
  sBtnPlay.Down := FALSE;


  PlayList('');
  lbPlayList.ItemIndex := 0;
 // labNameTrack.Caption := lbPlayList.Items[lbPlayList.ItemIndex];
  tBarVolume.Position :=7;
  _volume := (tBarVolume.Position-tBarVolume.Max+1)*6500;
  _volume := _volume + (_volume shl 16);
  waveOutSetVolume(WAVE_MAPPER, _volume);
end;
///
///
procedure TFrmMain.PlayList(path: string);
  var lpBuf: PChar; sWinDir: string[128]; SearchRec: TSearchRec;
begin
  lbPlayList.Clear;
  if FindFirst(_Path + '*.mp3', faAnyFile, SearchRec) = 0 then
  begin
  lbPlayList.Items.Add(SearchRec.Name);
  while(FindNext(searchRec) = 0) do
    lbPlayList.Items.Add(SearchRec.Name);
  end;
 lbPlayList.ItemIndex := 0;
end;
///
///
procedure TFrmMain.lbPlayList_Click(Sender: TObject);
begin
  if not sBtnPlay.Down
    then sBtnPlay.Down := TRUE;
  labNameTrack.Caption := lbPlayList.Items[lbPlayList.ItemIndex];
  Play;
end;
///
procedure TFrmMain.sBtnPlay_Click(Sender: TObject);
begin

    if lbPlayList.ItemIndex < 0 then sBtnPlay.Down := FALSE;

    if sBtnPlay.Down = TRUE then
       Play
    else
      begin
        if MediaPlayer.Mode = mpPlaying then begin
          MediaPlayer.Stop;
          Timer1.Enabled := FALSE;
          sBtnPlay.Down := FALSE;
          sBtnPlay.Hint := 'Play';
        end;
    end;

end;
///
procedure TFrmMain.sBtnPrev_Click(Sender: TObject);
begin
  if lbPlayList.ItemIndex > 0 then begin
    lbPlayList.ItemIndex := lbPlayList.ItemIndex - 1;
    Play;
    sBtnPlay.Down := TRUE;
  end;
end;

procedure TFrmMain.sBtnNext_Click(Sender: TObject);
begin
  if lbPlayList.ItemIndex < lbPlayList.Count - 1 then begin
    lbPlayList.ItemIndex := lbPlayList.ItemIndex + 1;
    Play;
    sBtnPlay.Down := TRUE;
  end
end;
//
///
procedure TFrmMain.tBarVolume_Change(Sender: TObject);
begin
  _volume := 6500 * (tBarVolume.Max - tBarVolume.Position);
  _volume := _volume + (_volume shl 16);
  waveOutSetVolume(WAVE_MAPPER, _volume);
end;
///
///
procedure TFrmMain.Play;
begin
  Timer1.Enabled := FALSE;
  labNameTrack.Caption := lbPlayList.Items[lbPlayList.ItemIndex];
  MediaPlayer.FileName := _Path + lbPlayList.Items[lbPlayList.ItemIndex];

  try
    MediaPlayer.Open;
  except
    on EMCIDeviceError do
      begin
        ShowMessage('Ошибка обращения к файлу ' + lbPlayList.Items[lbPlayList.ItemIndex]);
        sBtnPlay.Down := FALSE;
        exit;
      end;
  end;
  MediaPlayer.Play;
  _min := 0;
  _sec := 0;
  Timer1.Enabled := TRUE;
  sBtnPlay.Hint := 'Stop';
end;
///
///
procedure TFrmMain.Timer1_Timer(Sender: TObject);
begin
  if _sec < 59 then
    inc(_sec)
  else begin
    _sec := 0;
    inc(_min);
  end;
  labTime.Caption := IntToStr(_min) + ':';
  if _sec < 10 then
    labTime.Caption := labTime.Caption + '0'+ IntToStr(_sec)
  else labTime.Caption := labTime.Caption + IntToStr(_sec);

  if MediaPlayer.Position < MediaPlayer.Length then
    exit;

  Timer1.Enabled := FALSE;
  MediaPlayer.Stop;
  if lbPlayList.ItemIndex < lbPlayList.Count then begin
    lbPlayList.ItemIndex := lbPlayList.ItemIndex + 1;
    Play;
  end
end;
 ///
 ///
procedure TFrmmain.sBtnFolder_Click(Sender: TObject);
  var root: String; pwRoot: PWideChar; dir: String;
begin
    root := '';
    GetMem(pwRoot, (Length(root) + 1 ) * 2);
    pwRoot := StringToWideChar(root, pwRoot, MAX_PATH*2);
    if not (SelectDirectory('Выберите папку', pwRoot, dir)) then dir := ''
    else dir := dir + '\';
    _Path := dir;
    PlayList(_Path);
end;

procedure TFrmMain.sBtnINFO_Click(Sender: TObject);
var str: String;
begin
  str := 'Created by Hikaru.' + #13#10
        + '(c) All rights reserved. 14 July 2018 '
        + #13#10 + 'v0.9 (technical preview)';
  MessageDlg(str, mtInformation, mbYesNo, 0);

end;

end.
