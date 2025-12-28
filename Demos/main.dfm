object Form2: TForm2
  Left = 0
  Top = 0
  Margins.Left = 8
  Margins.Top = 8
  Margins.Right = 8
  Margins.Bottom = 8
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'DM CSS Unpacker'
  ClientHeight = 528
  ClientWidth = 1048
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -28
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
  Position = poScreenCenter
  PixelsPerInch = 240
  DesignSize = (
    1048
    528)
  TextHeight = 34
  object Label1: TLabel
    Left = 28
    Top = 30
    Width = 95
    Height = 34
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Caption = 'Source:'
  end
  object shpHeader: TShape
    Left = 0
    Top = 160
    Width = 1048
    Height = 63
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Brush.Color = 15461355
    Pen.Color = 11711154
    Pen.Width = 3
  end
  object lblOptions: TLabel
    Left = 20
    Top = 170
    Width = 123
    Height = 40
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Caption = 'Options:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -33
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object Line3d1: TBevel
    Left = 0
    Top = 393
    Width = 1048
    Height = 22
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Anchors = [akLeft, akTop, akRight]
    Shape = bsBottomLine
  end
  object Shape1: TShape
    Left = 0
    Top = 225
    Width = 1048
    Height = 185
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Pen.Color = clWhite
    Pen.Width = 3
  end
  object cmdopen: TButton
    Left = 923
    Top = 78
    Width = 105
    Height = 52
    Hint = 'Select'
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Caption = '. . .'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnClick = cmdopenClick
  end
  object txtSrcFile: TEdit
    Left = 28
    Top = 78
    Width = 880
    Height = 42
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    TabOrder = 1
  end
  object cmdUnPack: TButton
    Left = 20
    Top = 435
    Width = 203
    Height = 65
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Caption = '&Unpack'
    TabOrder = 3
    OnClick = cmdUnPackClick
  end
  object chkClipabord: TCheckBox
    Left = 80
    Top = 293
    Width = 943
    Height = 42
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Caption = 'Unpack CSS style sheet code to clipboard.'
    Color = clWhite
    ParentColor = False
    TabOrder = 2
  end
  object cmdAbout: TButton
    Left = 658
    Top = 430
    Width = 165
    Height = 65
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Caption = '&About'
    TabOrder = 4
    OnClick = cmdAboutClick
  end
  object cmdExit: TButton
    Left = 858
    Top = 435
    Width = 165
    Height = 65
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Caption = 'E&xit'
    TabOrder = 5
    OnClick = cmdExitClick
  end
  object chkBackupOriginalFile: TCheckBox
    Left = 80
    Top = 235
    Width = 943
    Height = 43
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Caption = 'Backup original CSS code file.'
    Color = clWhite
    ParentColor = False
    TabOrder = 6
  end
  object chkIndent: TCheckBox
    Left = 80
    Top = 353
    Width = 943
    Height = 42
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Caption = 'Indent source lines.'
    Color = clWhite
    ParentColor = False
    TabOrder = 7
  end
  object Button1: TButton
    Left = 238
    Top = 435
    Width = 202
    Height = 65
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Caption = '&Pack'
    TabOrder = 8
    OnClick = Button1Click
  end
end
