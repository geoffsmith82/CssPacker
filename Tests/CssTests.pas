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
    [Test] procedure Bootstrap_ZeroDeg_IsNotRemoved;
    [Test] procedure Bootstrap_ZeroInCalc_LengthUnitRemoved;
    [Test] procedure Bootstrap_ZeroLengthUnits_AreRemoved;
    [Test] procedure Bootstrap_ZeroPx_IsRemoved;
    [Test] procedure Bootstrap_ZeroTimeUnits_AreNotRemoved;
    [Test] procedure PrettyMode_DoesNotStripZeroUnits;
    [Test] procedure SafeMode_DoesNotStripZeroUnits;

    [Test] procedure Bootstrap_ShortensHexColor;
    [Test] procedure Bootstrap_DoesNotShortenInvalidHex;
    [Test] procedure SafeMode_DoesNotShortenHex;

    [Test] procedure Bootstrap_RemovesLeadingZeroFromDecimal;
    [Test] procedure Bootstrap_RemovesLeadingZeroInCalc;
    [Test] procedure Bootstrap_DoesNotChangeNonZeroDecimal;
    [Test] procedure SafeMode_DoesNotRemoveLeadingZero;
    [Test] procedure PrettyMode_DoesNotRemoveLeadingZero;
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
    '}' + sLineBreak;
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

procedure TCssFormatterTests.Bootstrap_ZeroPx_IsRemoved;
const
  Input  = '.a { margin: 0px; }';
  Expect = '.a{margin:0}';
begin
  Assert.AreEqual(Expect, TCSSTools.FormatCSS2(Input, cssPackBootstrap));
end;

procedure TCssFormatterTests.Bootstrap_ZeroLengthUnits_AreRemoved;
const
  Input  = '.a { padding: 0em 0rem 0px 0%; }';
  Expect = '.a{padding:0 0 0 0}';
begin
  Assert.AreEqual(Expect, TCSSTools.FormatCSS2(Input, cssPackBootstrap));
end;


procedure TCssFormatterTests.Bootstrap_ZeroInCalc_LengthUnitRemoved;
const
  Input  = '.a { width: calc(100% - 0px); }';
  Expect = '.a{width:calc(100% - 0)}';
begin
  Assert.AreEqual(Expect, TCSSTools.FormatCSS2(Input, cssPackBootstrap));
end;

procedure TCssFormatterTests.Bootstrap_ZeroDeg_IsNotRemoved;
const
  Input  = '.a { transform: rotate(0deg); }';
  Expect = '.a{transform:rotate(0deg)}';
begin
  Assert.AreEqual(Expect, TCSSTools.FormatCSS2(Input, cssPackBootstrap));
end;

procedure TCssFormatterTests.Bootstrap_ZeroTimeUnits_AreNotRemoved;
const
  Input  = '.a { animation-delay: 0s; transition-delay: 0ms; }';
  Expect = '.a{animation-delay:0s;transition-delay:0ms}';
begin
  Assert.AreEqual(Expect, TCSSTools.FormatCSS2(Input, cssPackBootstrap));
end;

procedure TCssFormatterTests.SafeMode_DoesNotStripZeroUnits;
const
  Input  = '.a { margin: 0px; }';
  Expect = '.a { margin: 0px; }';
begin
  Assert.AreEqual(Expect, TCSSTools.FormatCSS2(Input, cssPackSafe));
end;

procedure TCssFormatterTests.PrettyMode_DoesNotStripZeroUnits;
const
  Input  = '.a{margin:0px}';
  Expect =
    '.a {' + sLineBreak +
    '  margin:0px' + sLineBreak +
    '}' + sLineBreak;
begin
  Assert.AreEqual(Expect, TCSSTools.FormatCSS2(Input, cssUnpackPretty));
end;

procedure TCssFormatterTests.Bootstrap_ShortensHexColor;
const
  Input  = '.a { color: #ffffff; background:#aabbcc; }';
  Expect = '.a{color:#fff;background:#abc}';
begin
  Assert.AreEqual(
    Expect,
    TCSSTools.FormatCSS2(Input, cssPackBootstrap)
  );
end;

procedure TCssFormatterTests.Bootstrap_DoesNotShortenInvalidHex;
const
  Input  = '.a { color:#ababcd; }';
  Expect = '.a{color:#ababcd}';
begin
  Assert.AreEqual(
    Expect,
    TCSSTools.FormatCSS2(Input, cssPackBootstrap)
  );
end;

procedure TCssFormatterTests.SafeMode_DoesNotShortenHex;
const
  Input  = '.a { color: #ffffff; }';
  Expect = '.a { color: #ffffff; }';
begin
  Assert.AreEqual(
    Expect,
    TCSSTools.FormatCSS2(Input, cssPackSafe)
  );
end;

procedure TCssFormatterTests.Bootstrap_RemovesLeadingZeroFromDecimal;
const
  Input  = '.a { opacity: 0.5; }';
  Expect = '.a{opacity:.5}';
begin
  Assert.AreEqual(
    Expect,
    TCSSTools.FormatCSS2(Input, cssPackBootstrap)
  );
end;

procedure TCssFormatterTests.Bootstrap_RemovesLeadingZeroInCalc;
const
  Input  = '.a { width: calc(100% - 0.5rem); }';
  Expect = '.a{width:calc(100% - .5rem)}';
begin
  Assert.AreEqual(
    Expect,
    TCSSTools.FormatCSS2(Input, cssPackBootstrap)
  );
end;

procedure TCssFormatterTests.Bootstrap_DoesNotChangeNonZeroDecimal;
const
  Input  = '.a { opacity: 1.5; }';
  Expect = '.a{opacity:1.5}';
begin
  Assert.AreEqual(
    Expect,
    TCSSTools.FormatCSS2(Input, cssPackBootstrap)
  );
end;

procedure TCssFormatterTests.SafeMode_DoesNotRemoveLeadingZero;
const
  Input  = '.a { opacity: 0.5; }';
  Expect = '.a { opacity: 0.5; }';
begin
  Assert.AreEqual(
    Expect,
    TCSSTools.FormatCSS2(Input, cssPackSafe)
  );
end;


procedure TCssFormatterTests.PrettyMode_DoesNotRemoveLeadingZero;
const
  Input  = '.a{opacity:0.5}';
  Expect =
    '.a {' + sLineBreak +
    '  opacity:0.5' + sLineBreak +
    '}' + sLineBreak;
begin
  Assert.AreEqual(
    Expect,
    TCSSTools.FormatCSS2(Input, cssUnpackPretty)
  );
end;




initialization
  TDUnitX.RegisterTestFixture(TCssFormatterTests);

end.
