unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  StrUtils, FileUtil, zipper;

type

  { TForm1 }

  TForm1 = class(TForm)
    Memo1 :TMemo;
    Button1 :TButton;
    SelectDirectoryDialog1 :TSelectDirectoryDialog;
    procedure Button1Click(Sender :TObject);
    procedure FormCreate(Sender :TObject);
    procedure FindDbfAndCopy(dir :String; prefix :String = '');
    procedure ZippFolder(dir, zipFileName: String);
  private

  public
    TarDataDir :String;
    procedure Memo1ClearAndAdd(str :String);
    function CreateTempDir() :Boolean;
    procedure CopyFile(FromFileName, ToFileName :String);

  end;

var
  Form1 : TForm1;

implementation

{$R *.frm}

{ TForm1 }

procedure TForm1.FormCreate(Sender :TObject);
begin
  TarDataDir := GetTempDir(False) + 'tar_data' + DirectorySeparator;
end;

procedure TForm1.Button1Click(Sender :TObject);
var
  selectedDir: String;
  SubDir: String;
  splitSubDirPath: array of string;
  ZipFileName: String;
begin
  if not SelectDirectoryDialog1.Execute then Exit;
  selectedDir := SelectDirectoryDialog1.FileName + DirectorySeparator;

  if not CreateTempDir() then Exit;
  Memo1.Clear;
  Memo1.Lines.Add('Нашел:');

  {Выбираем файлы для копирования из выбранной директории}
  FindDbfAndCopy(selectedDir);

  for SubDir in FindAllDirectories(selectedDir, False) do
  begin
    splitSubDirPath := SplitString(SubDir, DirectorySeparator);
    FindDbfAndCopy(SubDir + DirectorySeparator,
                   splitSubDirPath[Length(splitSubDirPath) - 1]);
  end;

  {запаковываем в архив}
  ZipFileName := 'tar-' + FormatDateTime('YY-MM-DD:hh-mm-ss', Now) + '.zip';
  ZippFolder(TarDataDir, ZipFileName);

  Memo1ClearAndAdd('Упаковано в архив:');
  Memo1.Lines.Add(ZipFileName);
end;

procedure TForm1.FindDbfAndCopy(dir :String; prefix :String = '');
var
  Info : TSearchRec;
  sourceFile: String;
  destFile: String;
begin
  If FindFirst (dir + '*.DBF', faAnyFile, Info)=0 then
  begin
      repeat
        sourceFile := dir + Info.Name;
        if prefix = '' then
        begin
          destFile := TarDataDir + Info.Name;
          Memo1.Lines.Add(Info.Name);
        end
        else
        begin
          destFile := TarDataDir + prefix + '_' + Info.Name;
          Memo1.Lines.Add(prefix + '_' + Info.Name);
        end;

        CopyFile(sourceFile, destFile);
      until FindNext(info)<>0;
  end;
end;

procedure TForm1.CopyFile(FromFileName, ToFileName :String);
var
  SourceF, DestF: TFileStream;
begin
  SourceF := TFileStream.Create(FromFileName, fmOpenRead);
  DestF := TFileStream.Create(ToFileName, fmCreate);
  try
    DestF.CopyFrom(SourceF, SourceF.Size);
  finally
    SourceF.Free;
    DestF.Free;
  end;
end;

procedure TForm1.Memo1ClearAndAdd(str :String);
begin
  Memo1.Clear;
  Memo1.Lines.Add(str);
end;

function TForm1.CreateTempDir() :Boolean;
begin
  result := True;
  If Not DirectoryExists(TarDataDir) then
    begin
    If Not CreateDir (TarDataDir) Then
      begin
        result := False;
        Memo1ClearAndAdd('Ошибка создания временной директории!');
      end
    end
  else
  begin
    DeleteDirectory(TarDataDir, True);
    If Not RemoveDir (TarDataDir) Then
      begin
        result := False;
        Memo1ClearAndAdd('Ошибка очистки временной директории!');
      end
    else If Not CreateDir (TarDataDir) Then
      begin
        result := False;
        Memo1ClearAndAdd('Ошибка создания временной директории!');
      end
  end;
end;

procedure TForm1.ZippFolder(dir, zipFileName: String);
var
  AZipper: TZipper;
  FilePath: String;
  splitFilePath: array of string;

begin
  AZipper := TZipper.Create;
  AZipper.Filename := zipFileName;


  try
    for FilePath in FindAllFiles(dir, '*', False) do
    begin
      splitFilePath := SplitString(FilePath, DirectorySeparator);
      AZipper.Entries.AddFileEntry(FilePath, splitFilePath[Length(splitFilePath) - 1]);
    end;
    AZipper.ZipAllFiles;
  finally
    AZipper.Free;
  end;
end;

end.

