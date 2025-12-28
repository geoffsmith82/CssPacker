unit main;

interface

uses
    Windows
  , Messages
  , SysUtils
  , Variants
  , Classes
  , Graphics
  , Controls
  , Forms
  , Dialogs
  , StdCtrls
  , Clipbrd
  , ExtCtrls
  , System.UITypes
  ;

const crlf = #13 + #10;
const sp = '  ';

type
  TForm2 = class(TForm)
    cmdopen: TButton;
    Label1: TLabel;
    txtSrcFile: TEdit;
    cmdUnPack: TButton;
    chkClipabord: TCheckBox;
    cmdAbout: TButton;
    cmdExit: TButton;
    chkBackupOriginalFile: TCheckBox;
    chkIndent: TCheckBox;
    shpHeader: TShape;
    lblOptions: TLabel;
    Line3d1: TBevel;
    Shape1: TShape;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure cmdUnPackClick(Sender: TObject);
    procedure cmdopenClick(Sender: TObject);
    procedure cmdExitClick(Sender: TObject);
    procedure cmdAboutClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

uses
    System.IOUtils
  , cssunpack
  ;

function GetRightStr(src: string; index: Integer): string;
begin
//hello
  GetRightStr := Copy(src, Length(src) - index + 1, index);
end;

procedure TForm2.Button1Click(Sender: TObject);
var
  lzfile: string;
  Buffer: string;
  tf: TextFile;
begin

  //Get filename.
  lzfile := Trim(txtSrcFile.Text);

  //Check for filename.
  if Length(lzfile) = 0 then
  begin
    MessageDlg('A valid input filename is required.', mtWarning, [mbOK], 0);
    cmdopen.SetFocus;
    Exit;
  end;

  //Check if filename has been removed.
  if not FileExists(lzfile) then
  begin
    MessageDlg('Input filename was not found, or the file may have been moved:' + crlf + lzfile, mtWarning, [mbOK], 0);
    cmdopen.SetFocus;
    Exit;
  end;

  //Check if we need to make a backup of original file.
  if chkBackupOriginalFile.Checked then
  begin
    Copyfile(PChar(lzfile), PChar(lzfile + '.bak'), True);
  end;

  Buffer := TCSSTools.FormatCSS2(TFile.ReadAllText(lzfile), cssPackBootstrap);

  //Save new file.
  try
    TFile.WriteAllText(lzfile, Buffer);
    MessageDlg('File was successfully packed' + crlf + lzfile, mtInformation, [mbOK], 0);
    //Finish message.
  except
    MessageDlg('There was an error while writing to the input filename.' + crlf + lzfile, mtWarning, [mbOK], 0);
  end;

  //Check if need copying to clipboard.
  if chkClipabord.Checked then
  begin
    //Copy css to clipboard.
    clipboard.SetTextBuf(PChar(Buffer));
  end;

  Buffer := '';
end;

procedure TForm2.cmdAboutClick(Sender: TObject);
begin
  MessageDlg(Caption + ' v1.0' + crlf + 'Benjamin George', mtInformation, [mbOK], 0);
end;

procedure TForm2.cmdExitClick(Sender: TObject);
begin
  Close;
end;

procedure TForm2.cmdopenClick(Sender: TObject);
var
  dlg: TOpenDialog;
begin
  //Create object.
  dlg := TOpenDialog.Create(self);
  dlg.Title := 'Select';
  dlg.Filter := 'Cascading Style Sheets(*.css)|*.css';
  if dlg.Execute then
  begin
    //Set text box with filename.
    txtsrcfile.Text := dlg.FileName;
  end;
  dlg.CleanupInstance;
  dlg.Free;
end;

procedure TForm2.cmdUnPackClick(Sender: TObject);
var
  lzfile: string;
  Buffer: string;
  tf: TextFile;
  indentSpaces : Integer;
begin

  //Get filename.
  lzfile := Trim(txtSrcFile.Text);

  if chkIndent.Checked then
    IndentSpaces := 2
  else
    IndentSpaces := 0;

  //Check for filename.
  if Length(lzfile) = 0 then
  begin
    MessageDlg('A valid input filename is required.', mtWarning, [mbOK], 0);
    cmdopen.SetFocus;
    Exit;
  end;

  //Check if filename has been removed.
  if not FileExists(lzfile) then
  begin
    MessageDlg('Input filename was not found, or the file may have been moved:' + crlf + lzfile, mtWarning, [mbOK], 0);
    cmdopen.SetFocus;
    Exit;
  end;

  //Check if we need to make a backup of original file.
  if chkClipabord.Checked then
  begin
    copyfile(PChar(lzfile), PChar(lzfile + '.bak'), True);
  end;

  Buffer := TCSSTools.FormatCSS(TFile.ReadAllText(lzfile), indentSpaces);

  //Save new file.
  try
    //Assign file.
    AssignFile(tf, lzfile);
    Rewrite(tf);
    //Write buffer to file.
    Write(tf, Buffer);
    //Close file.
    CloseFile(tf);
    MessageDlg('File was successfully unpacked' + crlf + lzfile, mtInformation, [mbOK], 0);
    //Finish message.
  except
    MessageDlg('There was an error while writing to the input filename.' + crlf + lzfile, mtWarning, [mbOK], 0);
  end;

  //Check if need copying to clipboard.
  if chkClipabord.Checked then
  begin
    //Copy css to clipboard.
    clipboard.SetTextBuf(PChar(Buffer));
  end;

  Buffer := '';
end;

end.

