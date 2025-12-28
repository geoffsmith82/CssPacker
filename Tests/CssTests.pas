unit CssTests;

interface

uses
  DUnitX.TestFramework,
  cssunpack;

type
  [TestFixture]
  TCssFormatterTests = class
  private
  public
    [Test] procedure Bootstrap_DropsCharset;
    [Test] procedure Bootstrap_DropsFinalSemicolon;
    [Test] procedure Bootstrap_RemovesWhitespaceAroundDelimiters;
    [Test] procedure SafeMode_PreservesCalcSpacing;
    [Test] procedure Bootstrap_DropsFinalSemicolon_PreservesCalc;
    [Test] procedure SafeMode_PreservesUrlData;
    [Test] procedure Pretty_UnpacksBlocks;
    [Test] procedure RoundTrip_Pretty_Bootstrap_Pretty;
  end;

implementation

procedure TCssFormatterTests.Bootstrap_DropsCharset;
const
  Input  = '@charset "UTF-8"; body { color: red; }';
  Expect = 'body{color:red}';
begin
  Assert.AreEqual( Expect, TCSSTools.FormatCSS2(Input, cssPackBootstrap));
end;

procedure TCssFormatterTests.Bootstrap_RemovesWhitespaceAroundDelimiters;
const
  Input  = ':root, [x = y] { a : b ; }';
  Expect = ':root,[x = y]{a:b}';
begin
  Assert.AreEqual( Expect, TCSSTools.FormatCSS2(Input, cssPackBootstrap));
end;

procedure TCssFormatterTests.Bootstrap_DropsFinalSemicolon;
const
  Input  = '.a { x: 1; y: 2; }';
  Expect = '.a{x:1;y:2}';
begin
  Assert.AreEqual(Expect, TCSSTools.FormatCSS2(Input, cssPackBootstrap));
end;

procedure TCssFormatterTests.SafeMode_PreservesCalcSpacing;
const
  Input  = '.a { width: calc(100% - 20px); }';
  Expect = '.a { width: calc(100% - 20px); }';
begin
  Assert.AreEqual(Expect, TCSSTools.FormatCSS2(Input, cssPackSafe));
end;

procedure TCssFormatterTests.Bootstrap_DropsFinalSemicolon_PreservesCalc;
const
  Input  = '.a { width: calc(100% - 20px); }';
  Expect = '.a{width:calc(100% - 20px)}';
begin
  Assert.AreEqual(Expect, TCSSTools.FormatCSS2(Input, cssPackBootstrap));
end;

procedure TCssFormatterTests.SafeMode_PreservesUrlData;
const
  Input  = '.a { background: url(data:image/svg+xml;utf8,<svg viewBox="0 0 10 10">); }';
begin
  Assert.AreEqual(Input, TCSSTools.FormatCSS2(Input, cssPackSafe));
end;

procedure TCssFormatterTests.Pretty_UnpacksBlocks;
const
  Input = '.a{color:red;background:blue}';

  Expect =
    '.a {' + sLineBreak +
    '  color:red;' + sLineBreak +
    '  background:blue' + sLineBreak +
    '}';// + sLineBreak;
begin
  Assert.AreEqual(Expect, TCSSTools.FormatCSS2(Input, cssUnpackPretty));
end;

procedure TCssFormatterTests.RoundTrip_Pretty_Bootstrap_Pretty;
const
  Input =
    '.a {' + sLineBreak +
    '  width: calc(100% - 20px);' + sLineBreak +
    '  background: url(icon.svg);' + sLineBreak +
    '}' + sLineBreak;
var
  Pretty1, Bootstrap, Pretty2: string;
begin
  Pretty1 := Input;
  Bootstrap := TCSSTools.FormatCSS2(Pretty1, cssPackBootstrap);
  Pretty2 := TCSSTools.FormatCSS2(Bootstrap, cssUnpackPretty);

  Assert.AreEqual(TCSSTools.FormatCSS2(Pretty1, cssPackSafe), TCSSTools.FormatCSS2(Pretty2, cssPackSafe));
end;


initialization
  TDUnitX.RegisterTestFixture(TCssFormatterTests);

end.
