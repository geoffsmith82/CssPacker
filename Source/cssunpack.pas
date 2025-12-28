unit cssunpack;

interface

uses
   System.SysUtils
  , System.Classes
  ;

type
  TCSSTools = class
  private
    class function RemakeCommas(StrLine: string):string ; static;
    class function RemoveSpacesOnEitherSideOfChar(Buffer: string; var StrLine: string; AxisChar: Char): String;
  public
    class function FormatCSS(Buffer: string; IndentSpaces: Integer = 0): String; static;
    class function MinifyCSS(Buffer: string): String; static;
  end;


implementation

class function TCSSTools.MinifyCSS(Buffer: string): String;
var
  i: Integer;
  StrLine : String;
  sl : TStringList;
begin
  sl := TStringList.Create;
  sl.Text := Buffer;
  for i := 0 to sl.Count - 1 do
  begin
    sl[i] := Trim(sl[i]);
  end;

  Buffer := sl.text;

  Strline := Buffer.Replace(sLineBreak, '');

  StrLine := RemoveSpacesOnEitherSideOfChar(Buffer, StrLine, ',');
  StrLine := RemoveSpacesOnEitherSideOfChar(Buffer, StrLine, '{');
  StrLine := RemoveSpacesOnEitherSideOfChar(Buffer, StrLine, '<');
  StrLine := RemoveSpacesOnEitherSideOfChar(Buffer, StrLine, '>');
  StrLine := RemoveSpacesOnEitherSideOfChar(Buffer, StrLine, ':');

  Result := StrLine;
end;

class function TCSSTools.RemoveSpacesOnEitherSideOfChar(Buffer: string; var StrLine: string; AxisChar: Char): String;
var
  Local_i: Integer;
  parts: TArray<string>;
begin
  parts := Strline.Split([AxisChar]);
  if High(parts) > 1 then
  begin
    StrLine := '';
    for Local_i := 0 to High(parts) do
    begin
      StrLine := StrLine + parts[Local_i].Trim + AxisChar;
    end;
  end;
  if not Buffer.EndsWith(AxisChar) and StrLine.EndsWith(AxisChar) then
    StrLine := StrLine.Remove(Strline.Length - 1);
end;

class function TCSSTools.RemakeCommas(StrLine: string): string;
var
  parts : TArray<string>;
  i: Integer;
begin
  parts := Strline.Split([',']);

  if High(parts) > 0 then
  begin
    StrLine := '';
    for i := 0 to High(parts) do
    begin
      StrLine := StrLine + parts[i].Trim + ', ';
    end;

    if StrLine.EndsWith(', ') then
      StrLine := StrLine.Remove(StrLine.Length-2, 2);
  end;
  Result := StrLine;
end;

function Spaces(count: Integer):string;
var
  i: Integer;
begin
  for i := 0 to count -1 do
    Result := Result + ' ';
end;


class function TCSSTools.FormatCSS(Buffer: string; IndentSpaces: Integer = 0): String;
var
  I: Integer;
  StrLine: string;
  sPos: Integer;
  StrTemp: string;
  sl: TStringList;
  sp : String;
begin
  //Create string list.
  sl := TStringList.Create;
  //Clean up the compressed css file.
  Buffer := Buffer.Replace('{', ' {' + sLineBreak, [rfReplaceAll]);
  Buffer := Buffer.Replace('}', sLineBreak +  '}' + sLineBreak, [rfReplaceAll]);
  Buffer := Buffer.Replace(';', ';' + sLineBreak , [rfReplaceAll]);
  Buffer := Buffer.Replace('*/', '*/' + sLineBreak , [rfReplaceAll]);


  if IndentSpaces > 0 then
    sp := Spaces(IndentSpaces);

  //Extract the string into the string list.
  ExtractStrings([''#13'', ''#10''], [], PChar(Buffer), sl);
  //Clear buffer.
  Buffer := '';
  //indent css propertie names add space between property and value.
  for I := 0 to sl.Count - 1 do
  begin
    //Get line
    StrLine := Trim(sl[I]);
    //Check for : in string.
    sPos := Pos(':', StrLine);
    if sPos > 0 then
    begin
      //Check for end of line marker.
{      if not StrLine.EndsWith(';') then
      begin
        //Add end marker.
        StrLine := StrLine + ';';
      end;  }
      //Check for : in string.
      sPos := Pos(':', StrLine);
      //Check for : position.
      if sPos > 0 then
      begin
        //Split the line in half.
        StrTemp := Trim(Copy(StrLine, sPos + 1));
        StrLine := Trim(Copy(StrLine, 1, sPos));
        //Remake the line with the space included.
        StrLine := StrLine + ' ' + StrTemp;
      end;

      //Check if indenting lines.
      if IndentSpaces > 0 then
      begin
        //Indent the line.
        StrLine := sp + StrLine;
      end;
    end;
    //Check for { in string.
    sPos := Pos('{', StrLine);
    //Check for : position.
    if sPos > 0 then
    begin
      //Split the line in half.
      StrTemp := Trim(Copy(StrLine, sPos));
      StrLine := Trim(Copy(StrLine, 1, sPos - 1));
      //Remake the line with the space included.
      StrLine := StrLine + ' ' + StrTemp;
    end;
    StrLine := RemakeCommas(StrLine);

    //Just add an extra line break make css more readable.
    if StrLine = '}' then
    begin
      //Append crlf to strline.
      StrLine := StrLine + sLineBreak;
    end;
    //Build the output string.
    Buffer := Buffer + StrLine + sLineBreak;
  end;
  Result := Buffer;
end;

end.
