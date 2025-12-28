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
  LengthUnits: array[0..12] of string = (
    'px','em','rem','%','vh','vw','vmin','vmax',
    'cm','mm','in','pt','pc'
  );
var
  SB: TStringBuilder;
  I, Indent: Integer;
  C, Next: Char;
  State: TState;
  Quote: Char;
  PrevWasSpace: Boolean;

  function NextNonWhitespace(Index: Integer): Char;
  begin
    while (Index <= Length(Buffer)) and TCharacter.IsWhiteSpace(Buffer[Index]) do
      Inc(Index);
    if Index <= Length(Buffer) then
      Result := Buffer[Index]
    else
      Result := #0;
  end;

  function SkipWhitespace(Index: Integer): Integer;
  begin
    Result := Index;
    while (Result <= Length(Buffer)) and TCharacter.IsWhiteSpace(Buffer[Result]) do
      Inc(Result);
  end;

  function MatchLengthUnit(StartIdx: Integer; out UnitLen: Integer): Boolean;
  var
    U: string;
  begin
    for U in LengthUnits do
      if SameText(Copy(Buffer, StartIdx, Length(U)), U) then
      begin
        UnitLen := Length(U);
        Exit(True);
      end;
    Result := False;
  end;

  function IsStandaloneZero(Index: Integer): Boolean;
  begin
    if Buffer[Index] <> '0' then Exit(False);
    if (Index > 1) and (Buffer[Index - 1] in ['0'..'9', '.']) then Exit(False);
    Result := True;
  end;

  function IsLeadingZeroDecimal(Index: Integer): Boolean;
  begin
    Result :=
      (Index < Length(Buffer)) and
      (Buffer[Index] = '0') and
      (Buffer[Index + 1] = '.') and
      ((Index = 1) or not (Buffer[Index - 1] in ['0'..'9']));
  end;

  function TryShortenHex(Index: Integer; out Short: string): Integer;
  var
    Hex: string;
  begin
    Result := 0;
    if (Index + 6 <= Length(Buffer)) then
    begin
      Hex := Copy(Buffer, Index + 1, 6);
      if (Hex[1] = Hex[2]) and (Hex[3] = Hex[4]) and (Hex[5] = Hex[6]) then
      begin
        Short := '#' + Hex[1] + Hex[3] + Hex[5];
        Result := 7;
      end;
    end;
  end;

  procedure AppendIndent;
  var J: Integer;
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
      if I < Length(Buffer) then Next := Buffer[I + 1] else Next := #0;

      case State of
        stNormal:
          begin
            (* Drop @charset in Bootstrap *)
            if (Mode = cssPackBootstrap) and (C = '@') and
               SameText(Copy(Buffer, I+1, 7), 'charset') then
            begin
              while (I <= Length(Buffer)) and (Buffer[I] <> ';') do Inc(I);
              Inc(I);
              Continue;
            end;

            (* Comments *)
            if (C = '/') and (Next = '*') then
            begin
              State := stComment;
              Inc(I, 2);
              Continue;
            end;

            (* Strings *)
            if (C = '''') or (C = '"') then
            begin
              State := stString;
              Quote := C;
              SB.Append(C);
              PrevWasSpace := False;
              Inc(I);
              Continue;
            end;

            (* Detect url()/calc() *)
            if SameText(Copy(Buffer, I, 4), 'url(') then
            begin
              State := stURL;
              SB.Append('url(');
              Inc(I, 4);
              Continue;
            end;

            if SameText(Copy(Buffer, I, 5), 'calc(') then
            begin
              State := stCalc;
              SB.Append('calc(');
              Inc(I, 5);
              Continue;
            end;

            (* Bootstrap-only lexical optimisations *)
            if Mode = cssPackBootstrap then
            begin
              (* Hex colour shortening *)
              if C = '#' then
              begin
                var Short: string;
                var Used := TryShortenHex(I, Short);
                if Used > 0 then
                begin
                  SB.Append(Short);
                  Inc(I, Used);
                  Continue;
                end;
              end;

              (* Leading zero decimal *)
              if IsLeadingZeroDecimal(I) then
              begin
                SB.Append('.');
                Inc(I, 2);
                Continue;
              end;

              (* Zero-length unit *)
              if IsStandaloneZero(I) then
              begin
                var UL: Integer;
                if MatchLengthUnit(I + 1, UL) then
                begin
                  SB.Append('0');
                  Inc(I, UL + 1);
                  Continue;
                end;
              end;
            end;

            (* Whitespace *)
            if TCharacter.IsWhiteSpace(C) then
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

            (* Structural handling *)
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

            (* Bootstrap delimiter tightening *)
            if (Mode = cssPackBootstrap) and (C in Delims) then
            begin
              if (C = ';') and (NextNonWhitespace(I + 1) = '}') then
              begin
                I := SkipWhitespace(I + 1);
                Continue;
              end;

              if (SB.Length > 0) and (SB.Chars[SB.Length - 1] = ' ') then
                SB.Length := SB.Length - 1;

              SB.Append(C);
              Inc(I);
              while (I <= Length(Buffer)) and TCharacter.IsWhiteSpace(Buffer[I]) do
                Inc(I);
              PrevWasSpace := False;
              Continue;
            end;

            SB.Append(C);
            PrevWasSpace := False;
            Inc(I);
          end;

        stCalc, stURL:
          begin
            SB.Append(C);
            Inc(I);
            if C = ')' then
              State := stNormal;
          end;

        stString:
          begin
            SB.Append(C);
            Inc(I);
            if C = Quote then
              State := stNormal;
          end;

        stComment:
          begin
            if (C = '*') and (Next = '/') then
            begin
              State := stNormal;
              Inc(I, 2);
            end
            else
              Inc(I);
          end;
      end;
    end;

    if Mode = cssUnpackPretty then
    begin
      Result := SB.ToString;
      if not Result.EndsWith(sLineBreak) then
        Result := Result + sLineBreak;
    end
    else
      Result := SB.ToString.Trim;

  finally
    SB.Free;
  end;
end;


end.
