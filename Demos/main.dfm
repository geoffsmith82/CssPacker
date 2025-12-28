object Form2: TForm2
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'DM CSS Unpacker'
  ClientHeight = 211
  ClientWidth = 419
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010100000000000280100001600000028000000100000002000
    00000100040000000000C0000000000000000000000010000000000000000000
    0000000080000080000000808000800000008000800080800000C0C0C0008080
    80000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    0000000000000000000000000000000000000000000000000FF0F0FF00000000
    0FF0F0FF000000000FFFFFFF000000F0FFFFFFFFF0F000F0FF00000FF0F000FF
    FF00000FFFF0000FFFFFFFFFFF000000FF00F00FF0000000FF00F00FF0000000
    FFFFFFFFF00000000FFFFFFF000000000000000000000000000000000000FFFF
    FFFFFFFFFFFFFFFFFFFFF94FFFFFF94FFFFFF80FFFFFD005FFFFD3E5FFFFC3E1
    FFFFE003FFFFF367FFFFF367FFFFF007FFFFF80FFFFFFFFFFFFFFFFFFFFF}
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    419
    211)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 11
    Top = 12
    Width = 37
    Height = 13
    Caption = 'Source:'
  end
  object shpHeader: TShape
    Left = 0
    Top = 64
    Width = 419
    Height = 25
    Brush.Color = 15461355
    Pen.Color = 11711154
  end
  object lblOptions: TLabel
    Left = 8
    Top = 68
    Width = 48
    Height = 16
    Caption = 'Options:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object Line3d1: TBevel
    Left = 0
    Top = 157
    Width = 419
    Height = 9
    Anchors = [akLeft, akTop, akRight]
    Shape = bsBottomLine
    ExplicitWidth = 417
  end
  object Shape1: TShape
    Left = 0
    Top = 90
    Width = 419
    Height = 74
    Pen.Color = clWhite
  end
  object cmdopen: TButton
    Left = 369
    Top = 31
    Width = 42
    Height = 21
    Hint = 'Select'
    Caption = '. . .'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnClick = cmdopenClick
  end
  object txtSrcFile: TEdit
    Left = 11
    Top = 31
    Width = 352
    Height = 21
    TabOrder = 1
  end
  object cmdUnPack: TButton
    Left = 8
    Top = 174
    Width = 81
    Height = 26
    Caption = '&Unpack'
    TabOrder = 3
    OnClick = cmdUnPackClick
  end
  object chkClipabord: TCheckBox
    Left = 32
    Top = 117
    Width = 377
    Height = 17
    Caption = 'Unpack CSS style sheet code to clipboard.'
    Color = clWhite
    ParentColor = False
    TabOrder = 2
  end
  object cmdAbout: TButton
    Left = 263
    Top = 172
    Width = 66
    Height = 26
    Caption = '&About'
    TabOrder = 4
    OnClick = cmdAboutClick
  end
  object cmdExit: TButton
    Left = 343
    Top = 174
    Width = 66
    Height = 26
    Caption = 'E&xit'
    TabOrder = 5
    OnClick = cmdExitClick
  end
  object CheckBox1: TCheckBox
    Left = 32
    Top = 94
    Width = 377
    Height = 17
    Caption = 'Backup original CSS code file.'
    Color = clWhite
    ParentColor = False
    TabOrder = 6
  end
  object chkIndent: TCheckBox
    Left = 32
    Top = 141
    Width = 377
    Height = 17
    Caption = 'Indent source lines.'
    Color = clWhite
    ParentColor = False
    TabOrder = 7
  end
  object Button1: TButton
    Left = 95
    Top = 174
    Width = 81
    Height = 26
    Caption = '&Pack'
    TabOrder = 8
    OnClick = Button1Click
  end
end
