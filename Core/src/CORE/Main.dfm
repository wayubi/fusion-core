object frmMain: TfrmMain
  Left = 238
  Top = 171
  Width = 680
  Height = 344
  Caption = 'c'
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS P????'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnResize = FormResize
  DesignSize = (
    672
    317)
  PixelsPerInch = 96
  TextHeight = 15
  object lbl00: TLabel
    Left = 129
    Top = 8
    Width = 28
    Height = 15
    Alignment = taRightJustify
    AutoSize = False
    Caption = '('#180'-`)'
  end
  object cmdStart: TButton
    Left = 5
    Top = 5
    Width = 63
    Height = 22
    Caption = 'Start'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Century Gothic'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = cmdStartClick
  end
  object cmdStop: TButton
    Left = 72
    Top = 5
    Width = 64
    Height = 22
    Caption = 'Stop'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Century Gothic'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = cmdStopClick
  end
  object Edit1: TEdit
    Left = 165
    Top = 5
    Width = 362
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Century Gothic'
    Font.Style = []
    MaxLength = 83
    ParentFont = False
    TabOrder = 3
    OnKeyPress = Edit1KeyPress
  end
  object Button1: TButton
    Left = 533
    Top = 5
    Width = 93
    Height = 22
    Anchors = [akTop, akRight]
    Caption = 'Send Message'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Century Gothic'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnClick = Button1Click
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 298
    Width = 672
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 300
      end
      item
        Alignment = taRightJustify
        Width = 50
      end>
    SimplePanel = False
  end
  object txtDebug: TMemo
    Left = 0
    Top = 48
    Width = 672
    Height = 250
    Align = alBottom
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = cl3DDkShadow
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -12
    Font.Name = 'Century Gothic'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object sv1: TServerSocket
    Active = False
    Port = 6900
    ServerType = stNonBlocking
    OnClientConnect = sv1ClientConnect
    OnClientDisconnect = sv1ClientDisconnect
    OnClientRead = sv1ClientRead
    OnClientError = sv1ClientError
    Left = 20
    Top = 112
  end
  object sv2: TServerSocket
    Active = False
    Port = 5964
    ServerType = stNonBlocking
    OnClientConnect = sv2ClientConnect
    OnClientDisconnect = sv2ClientDisconnect
    OnClientRead = sv2ClientRead
    OnClientError = sv2ClientError
    Left = 108
    Top = 112
  end
  object sv3: TServerSocket
    Active = False
    Port = 5967
    ServerType = stNonBlocking
    OnClientConnect = sv3ClientConnect
    OnClientDisconnect = sv3ClientDisconnect
    OnClientRead = sv3ClientRead
    OnClientError = sv3ClientError
    Left = 60
    Top = 120
  end
  object DBsaveTimer: TTimer
    Enabled = False
    Interval = 300000
    OnTimer = DBsaveTimerTimer
    Left = 64
    Top = 160
  end
end
