unit cssunpack;

interface

uses
   System.SysUtils
  , System.Classes
  , System.StrUtils
  , System.Character
  ;

type
  TCssFormatMode = (
    cssPackSafe,        // Never break semantics
    cssPackBootstrap,   // Matches Bootstrap-style minification
    cssUnpackPretty     // Readable, indented, stable output
  );

  TCSSTools = class
  public
    class function FormatCSS2(const Buffer: string; Mode: TCssFormatMode): string;
  end;


implementation

class function TCSSTools.FormatCSS2(
  const Buffer: string;
  Mode: TCssFormatMode
): string;
type
  TState = (stNormal, stString, stComment, stURL, stCalc);
const
  Delims: set of Char = ['{', '}', ':', ';', ',', '>'];
var
  SB: TStringBuilder;
  I, Indent: Integer;
  C, Next: Char;
  State: TState;
  Quote: Char;
  PrevWasSpace: Boolean;

  function IsDelimiter(Ch: Char): Boolean; inline;
  begin
    Result := CharInSet(Ch, Delims);
  end;

  function PeekWord(StartIdx: Integer): string;
  var
    J: Integer;
  begin
    Result := '';
    J := StartIdx;
    while (J <= Length(Buffer)) and Buffer[J].IsLetter do
    begin
      Result := Result + Buffer[J];
      Inc(J);
    end;
  end;

  function NextNonWhitespace(Index: Integer): Char;
  begin
    while (Index <= Length(Buffer)) and Buffer[Index].IsWhiteSpace do
      Inc(Index);
    if Index <= Length(Buffer) then
      Result := Buffer[Index]
    else
      Result := #0;
  end;

  procedure AppendIndent;
  var
    J: Integer;
  begin
    for J := 1 to Indent do
      SB.Append('  ');
  end;

begin
  SB := TStringBuilder.Create(Length(Buffer));
  try
    State := stNormal;
    Quote := #0;
    PrevWasSpace := False;
    Indent := 0;
    I := 1;

    while I <= Length(Buffer) do
    begin
      C := Buffer[I];
      Next := #0;
      if I < Length(Buffer) then
        Next := Buffer[I + 1];

      case State of
        stNormal:
          begin
            { Remove @charset in Bootstrap mode }
            if (Mode = cssPackBootstrap) and (C = '@') then
            begin
              var W := PeekWord(I + 1);
              if SameText(W, 'charset') then
              begin
                Inc(I, Length(W) + 1);
                while (I <= Length(Buffer)) and (Buffer[I] <> ';') do
                  Inc(I);
                Inc(I);
                Continue;
              end;
            end;

            { Comment }
            if (C = '/') and (Next = '*') then
            begin
              State := stComment;
              Inc(I, 2);
              Continue;
            end;

            { String }
            if (C = '''') or (C = '"') then
            begin
              State := stString;
              Quote := C;
              SB.Append(C);
              PrevWasSpace := False;
              Inc(I);
              Continue;
            end;

            { Detect url( / calc( }
            if C.IsLetter then
            begin
              var W := PeekWord(I);
              if W <> '' then
              begin
                var K := I + Length(W);
                if (K <= Length(Buffer)) and (Buffer[K] = '(') then
                begin
                  if SameText(W, 'url') then
                    State := stURL
                  else if SameText(W, 'calc') then
                    State := stCalc;
                end;
              end;
            end;

            { Whitespace }
            if C.IsWhiteSpace then
            begin
              if Mode = cssUnpackPretty then
                Inc(I)
              else if not PrevWasSpace then
              begin
                SB.Append(' ');
                PrevWasSpace := True;
                Inc(I);
              end
              else
                Inc(I);
              Continue;
            end;

            { SAFE MODE: canonical colon spacing }
            if (Mode = cssPackSafe) and (C = ':') then
            begin
              SB.Append(': ');
              Inc(I);
              while (I <= Length(Buffer)) and Buffer[I].IsWhiteSpace do
                Inc(I);
              PrevWasSpace := False;
              Continue;
            end;

            (* SAFE MODE: ensure final semicolon before '}' *)
            if (Mode = cssPackSafe) and (C = '}') then
            begin
              if SB.Length > 0 then
              begin
                var J := SB.Length - 1;
                while (J >= 0) and SB.Chars[J].IsWhiteSpace do
                  Dec(J);

                if (J >= 0) and (SB.Chars[J] <> ';') and (SB.Chars[J] <> '{') then
                  SB.Insert(J + 1, ';');
              end;
            end;

            { Pretty / Safe structural handling }
            if Mode <> cssPackBootstrap then
            begin
              if C = '{' then
              begin
                if Mode = cssUnpackPretty then
                begin
                  SB.Append(' {' + sLineBreak);
                  Inc(Indent);
                  AppendIndent;
                end
                else
                  SB.Append('{');
                PrevWasSpace := False;
                Inc(I);
                Continue;
              end;

              if C = '}' then
              begin
                if Mode = cssUnpackPretty then
                begin
                  Dec(Indent);
                  SB.Append(sLineBreak);
                  AppendIndent;
                  SB.Append('}');
                  SB.Append(sLineBreak);
                  AppendIndent;
                end
                else
                  SB.Append('}');
                PrevWasSpace := False;
                Inc(I);
                Continue;
              end;

              if C = ';' then
              begin
                SB.Append(';');
                if Mode = cssUnpackPretty then
                begin
                  SB.Append(sLineBreak);
                  AppendIndent;
                end;
                PrevWasSpace := False;
                Inc(I);
                Continue;
              end;
            end;

            { Bootstrap delimiter tightening }
            if (Mode = cssPackBootstrap) and IsDelimiter(C) then
            begin
              { Drop final semicolon }
              if (C = ';') and (NextNonWhitespace(I + 1) = '}') then
              begin
                Inc(I);
                PrevWasSpace := False;
                Continue;
              end;

              (* Trim space before '}' *)
              if (C = '}') and (SB.Length > 0) and (SB.Chars[SB.Length - 1] = ' ') then
                SB.Length := SB.Length - 1;

              { Trim space before delimiter }
              if (SB.Length > 0) and (SB.Chars[SB.Length - 1] = ' ') then
                SB.Length := SB.Length - 1;

              SB.Append(C);
              Inc(I);
              while (I <= Length(Buffer)) and Buffer[I].IsWhiteSpace do
                Inc(I);

              PrevWasSpace := False;
              Continue;
            end;

            SB.Append(C);
            PrevWasSpace := False;
          end;

        stString:
          begin
            SB.Append(C);
            if (C = '\') and (Next <> #0) then
            begin
              SB.Append(Next);
              Inc(I, 2);
              Continue;
            end;
            if C = Quote then
              State := stNormal;
          end;

        stComment:
          begin
            if (C = '*') and (Next = '/') then
            begin
              State := stNormal;
              Inc(I, 2);
              Continue;
            end;
          end;

        stURL, stCalc:
          begin
            SB.Append(C);
            if C = ')' then
              State := stNormal;
          end;
      end;

      Inc(I);
    end;

    Result := SB.ToString.Trim;
  finally
    SB.Free;
  end;
end;

function Spaces(count: Integer):string;
var
  i: Integer;
begin
  for i := 0 to count -1 do
    Result := Result + ' ';
end;

end.
