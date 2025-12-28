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
    class function FormatCSS2(const CSS: string; Mode: TCssFormatMode): string;

  private
    class function PackBootstrap(const Buffer: string): string;
    class function PackSafe(const Buffer: string): string;
    class function UnpackPretty(const Buffer: string): string;
  end;


implementation

class function TCSSTools.FormatCSS2(const CSS: string; Mode: TCssFormatMode): string;
begin
  case Mode of
    cssPackBootstrap:
      Result := PackBootstrap(CSS);

    cssPackSafe:
      Result := PackSafe(CSS);

    cssUnpackPretty:
      Result := UnpackPretty(CSS);
  else
    Result := CSS;
  end;
end;

class function TCSSTools.PackBootstrap(const Buffer: string): string;
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

  procedure BootstrapOptimiseAt(var Index: Integer);
  begin
    (* Hex colour shortening *)
    if Buffer[Index] = '#' then
    begin
      var Short: string;
      var Used := TryShortenHex(Index, Short);
      if Used > 0 then
      begin
        SB.Append(Short);
        Inc(Index, Used);
        Exit;
      end;
    end;

    (* 0.5 -> .5 *)
    if IsLeadingZeroDecimal(Index) then
    begin
      SB.Append('.');
      Inc(Index, 2);
      Exit;
    end;

    (* 0px -> 0 (length units only) *)
    if IsStandaloneZero(Index) then
    begin
      var UL: Integer;
      if MatchLengthUnit(Index + 1, UL) then
      begin
        SB.Append('0');
        Inc(Index, UL + 1);

        (* Preserve token boundaries *)
        if (Index <= Length(Buffer)) and TCharacter.IsWhiteSpace(Buffer[Index]) then
        begin
          SB.Append(' ');
          Index := SkipWhitespace(Index);
        end;

        Exit;
      end;
    end;
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
            if (C = '@') and SameText(Copy(Buffer, I + 1, 7), 'charset') then
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

            (* Bootstrap lexical optimisations *)
            var Before := I;
            BootstrapOptimiseAt(I);
            if I <> Before then
              Continue;

            (* Whitespace *)
            if TCharacter.IsWhiteSpace(C) then
            begin
              if not PrevWasSpace then
              begin
                SB.Append(' ');
                PrevWasSpace := True;
                Inc(I);
              end
              else
                Inc(I);
              Continue;
            end;


            (* Bootstrap delimiter tightening *)
            if (C in Delims) then
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

        stCalc:
          begin
            var Before := I;
            BootstrapOptimiseAt(I);
            if I <> Before then
              Continue;

            SB.Append(C);
            Inc(I);
            if C = ')' then
              State := stNormal;
          end;

        stURL:
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

    Result := SB.ToString.Trim;

  finally
    SB.Free;
  end;
end;

class function TCSSTools.PackSafe(const Buffer: string): string;
type
  TState = (stNormal, stString, stComment, stURL, stCalc);
var
  SB: TStringBuilder;
  I: Integer;
  C, Next: Char;
  State: TState;
  Quote: Char;
  PrevWasSpace: Boolean;

  procedure TrimTrailingSpace;
  begin
    if (SB.Length > 0) and (SB.Chars[SB.Length - 1] = ' ') then
      SB.Length := SB.Length - 1;
  end;

  function LastNonSpaceChar: Char;
  var
    J: Integer;
  begin
    J := SB.Length - 1;
    while (J >= 0) and (SB.Chars[J] = ' ') do
      Dec(J);
    if J >= 0 then
      Result := SB.Chars[J]
    else
      Result := #0;
  end;

begin
  SB := TStringBuilder.Create(Length(Buffer));
  try
    State := stNormal;
    Quote := #0;
    PrevWasSpace := False;
    I := 1;

    while I <= Length(Buffer) do
    begin
      C := Buffer[I];
      if I < Length(Buffer) then
        Next := Buffer[I + 1]
      else
        Next := #0;

      case State of
        stNormal:
          begin
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
              PrevWasSpace := False;
              Inc(I, 4);
              Continue;
            end;

            if SameText(Copy(Buffer, I, 5), 'calc(') then
            begin
              State := stCalc;
              SB.Append('calc(');
              PrevWasSpace := False;
              Inc(I, 5);
              Continue;
            end;

            (* Whitespace → single space *)
            if TCharacter.IsWhiteSpace(C) then
            begin
              if not PrevWasSpace then
              begin
                SB.Append(' ');
                PrevWasSpace := True;
              end;
              Inc(I);
              Continue;
            end;

            (* Canonical delimiter spacing *)
            case C of
              '{':
                begin
                  TrimTrailingSpace;
                  SB.Append(' { ');
                  PrevWasSpace := True;   // delimiter already ended with space
                  Inc(I);
                  Continue;
                end;

              '}':
                begin
                  TrimTrailingSpace;

                  // Safe canonical form: ensure final declaration ends with ';'
                  if not (LastNonSpaceChar in [#0, '{', ';']) then
                    SB.Append(';');

                  SB.Append(' }');
                  PrevWasSpace := False;
                  Inc(I);
                  Continue;
                end;

              ':':
                begin
                  TrimTrailingSpace;
                  SB.Append(': ');
                  PrevWasSpace := True;   // delimiter already ended with space
                  Inc(I);
                  Continue;
                end;

              ';':
                begin
                  TrimTrailingSpace;
                  SB.Append('; ');
                  PrevWasSpace := True;   // delimiter already ended with space
                  Inc(I);
                  Continue;
                end;

              ',':
                begin
                  TrimTrailingSpace;
                  SB.Append(', ');
                  PrevWasSpace := True;   // delimiter already ended with space
                  Inc(I);
                  Continue;
                end;
            end;

            SB.Append(C);
            PrevWasSpace := False;
            Inc(I);
          end;

        stCalc:
          begin
            SB.Append(C);
            Inc(I);
            if C = ')' then
              State := stNormal;
          end;

        stURL:
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

    Result := SB.ToString.Trim;
  finally
    SB.Free;
  end;
end;


class function TCSSTools.UnpackPretty(const Buffer: string): string;
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

  procedure BootstrapOptimiseAt(var Index: Integer);
  begin
    (* Hex colour shortening *)
    if Buffer[Index] = '#' then
    begin
      var Short: string;
      var Used := TryShortenHex(Index, Short);
      if Used > 0 then
      begin
        SB.Append(Short);
        Inc(Index, Used);
        Exit;
      end;
    end;

    (* 0.5 -> .5 *)
    if IsLeadingZeroDecimal(Index) then
    begin
      SB.Append('.');
      Inc(Index, 2);
      Exit;
    end;

    (* 0px -> 0 (length units only) *)
    if IsStandaloneZero(Index) then
    begin
      var UL: Integer;
      if MatchLengthUnit(Index + 1, UL) then
      begin
        SB.Append('0');
        Inc(Index, UL + 1);

        (* Preserve token boundaries *)
        if (Index <= Length(Buffer)) and TCharacter.IsWhiteSpace(Buffer[Index]) then
        begin
          SB.Append(' ');
          Index := SkipWhitespace(Index);
        end;

        Exit;
      end;
    end;
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

            (* Pretty: conditional colon spacing *)
            if (C = ':') then
            begin
              SB.Append(':');
              Inc(I);
              while (I <= Length(Buffer)) and TCharacter.IsWhiteSpace(Buffer[I]) do
                Inc(I);
              if SameText(Copy(Buffer, I, 4), 'url(') or
                 SameText(Copy(Buffer, I, 5), 'calc(') then
                SB.Append(' ');
              Continue;
            end;

            (* Whitespace *)
            if TCharacter.IsWhiteSpace(C) then
            begin
              Inc(I)
            //  Continue;
            end;

            (* Structural handling *)
            if C = '{' then
            begin
              SB.Append(' {' + sLineBreak);
              Inc(Indent);
              AppendIndent;
              PrevWasSpace := False;
              Inc(I);
              Continue;
            end;

            if C = '}' then
            begin
              Dec(Indent);
              SB.Append(sLineBreak);
              AppendIndent;
              SB.Append('}');
              PrevWasSpace := False;
              Inc(I);
              Continue;
            end;

            if C = ';' then
            begin
              SB.Append(';');
              SB.Append(sLineBreak);
              AppendIndent;
              PrevWasSpace := False;
              Inc(I);
              Continue;
            end;

            SB.Append(C);
            PrevWasSpace := False;
            Inc(I);
          end;

        stCalc:
          begin
            SB.Append(C);
            Inc(I);
            if C = ')' then
              State := stNormal;
          end;

        stURL:
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

    Result := SB.ToString;
    if not Result.EndsWith(sLineBreak) then
      Result := Result + sLineBreak;

  finally
    SB.Free;
  end;
end;

end.
