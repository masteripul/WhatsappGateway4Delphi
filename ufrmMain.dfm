object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Whatsapp Gateway for Delphi'
  ClientHeight = 555
  ClientWidth = 729
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 729
    Height = 49
    Align = alTop
    TabOrder = 0
    DesignSize = (
      729
      49)
    object Button2: TButton
      Left = 553
      Top = 17
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Start'
      TabOrder = 0
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 634
      Top = 17
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Stop'
      TabOrder = 1
      OnClick = Button3Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 49
    Width = 729
    Height = 506
    Align = alClient
    TabOrder = 1
    object memLog: TMemo
      Left = 1
      Top = 394
      Width = 727
      Height = 111
      Align = alBottom
      ScrollBars = ssVertical
      TabOrder = 0
      Visible = False
      WordWrap = False
    end
    object Memo1: TMemo
      Left = 1
      Top = 1
      Width = 727
      Height = 264
      Align = alClient
      ScrollBars = ssVertical
      TabOrder = 1
      WordWrap = False
    end
    object Panel3: TPanel
      Left = 1
      Top = 265
      Width = 727
      Height = 129
      Align = alBottom
      TabOrder = 2
      object Label6: TLabel
        Left = 23
        Top = 16
        Width = 65
        Height = 13
        Caption = 'No Hp Tujuan'
      end
      object Label7: TLabel
        Left = 23
        Top = 43
        Width = 29
        Height = 13
        Caption = 'Pesan'
      end
      object Label1: TLabel
        Left = 23
        Top = 70
        Width = 30
        Height = 13
        Caption = 'Image'
      end
      object Button6: TButton
        Left = 112
        Top = 98
        Width = 75
        Height = 25
        Caption = 'Kirim'
        TabOrder = 0
        OnClick = Button6Click
      end
      object Edit1: TEdit
        Left = 112
        Top = 13
        Width = 233
        Height = 21
        TabOrder = 1
      end
      object Edit2: TEdit
        Left = 112
        Top = 40
        Width = 441
        Height = 21
        TabOrder = 2
      end
      object Edit3: TEdit
        Left = 112
        Top = 67
        Width = 441
        Height = 21
        TabOrder = 3
      end
      object Button1: TButton
        Left = 558
        Top = 65
        Width = 27
        Height = 25
        Caption = '...'
        TabOrder = 4
        OnClick = Button1Click
      end
    end
  end
  object Timer2: TTimer
    Enabled = False
    OnTimer = Timer2Timer
    Left = 16
    Top = 73
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Left = 545
    Top = 186
  end
end
