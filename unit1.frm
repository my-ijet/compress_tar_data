object Form1: TForm1
  Left = 86
  Height = 210
  Top = 85
  Width = 290
  BorderStyle = bsDialog
  Caption = 'Упаковщик'
  ClientHeight = 210
  ClientWidth = 290
  Font.Height = -24
  OnCreate = FormCreate
  LCLVersion = '7.9'
  object Button1: TButton
    AnchorSideTop.Side = asrBottom
    Left = 0
    Height = 44
    Top = 166
    Width = 290
    Align = alBottom
    Anchors = [akBottom]
    AutoSize = True
    Caption = 'Выбрать директорию'
    OnClick = Button1Click
    TabOrder = 0
  end
  object Memo1: TMemo
    Left = 8
    Height = 150
    Top = 8
    Width = 274
    Align = alClient
    BorderSpacing.Left = 8
    BorderSpacing.Top = 8
    BorderSpacing.Right = 8
    BorderSpacing.Bottom = 8
    Lines.Strings = (
      'Эта программа запакует базу данных тарификации в'
      'zip архив'
    )
    ParentBidiMode = False
    ReadOnly = True
    TabOrder = 1
  end
  object SelectDirectoryDialog1: TSelectDirectoryDialog
    Title = 'Выбрать директорию тарификации'
    Options = [ofNoChangeDir, ofPathMustExist, ofEnableSizing, ofViewDetail]
    Left = 10
    Top = 10
  end
end
