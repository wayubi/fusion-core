object frmMain: TfrmMain
  Left = 281
  Top = 255
  Width = 607
  Height = 382
  Caption = '#33'
  Color = clCream
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS P????'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 16
  object lbl00: TLabel
    Left = 189
    Top = 9
    Width = 30
    Height = 16
    Alignment = taRightJustify
    AutoSize = False
    Caption = '('#180'-`)'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 329
    Width = 599
    Height = 19
    Color = clCream
    Panels = <
      item
        Alignment = taRightJustify
        Width = 300
      end
      item
        Width = 300
      end>
  end
  object txtDebug: TMemo
    Left = 0
    Top = 37
    Width = 599
    Height = 292
    Align = alClient
    Color = 14071432
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -12
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 599
    Height = 37
    Align = alTop
    BevelOuter = bvNone
    Constraints.MaxHeight = 37
    Constraints.MinHeight = 37
    ParentColor = True
    TabOrder = 1
    DesignSize = (
      599
      37)
    object cmdStart: TButton
      Left = 5
      Top = 5
      Width = 68
      Height = 24
      Caption = 'Start'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = cmdStartClick
    end
    object cmdStop: TButton
      Left = 77
      Top = 5
      Width = 68
      Height = 24
      Caption = 'Stop'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      OnClick = cmdStopClick
    end
    object Edit1: TEdit
      Left = 154
      Top = 5
      Width = 297
      Height = 26
      Anchors = [akLeft, akTop, akRight]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      MaxLength = 83
      ParentFont = False
      TabOrder = 3
      OnKeyPress = Edit1KeyPress
    end
    object Button1: TButton
      Left = 455
      Top = 5
      Width = 108
      Height = 24
      Anchors = [akTop, akRight]
      Caption = 'Send Message'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 571
      Top = 5
      Width = 22
      Height = 24
      Anchors = [akTop, akRight]
      Caption = 'T'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = cmdMinTray
    end
  end
  object sv1: TServerSocket
    Active = False
    Port = 6900
    ServerType = stNonBlocking
    OnClientConnect = sv1ClientConnect
    OnClientDisconnect = sv1ClientDisconnect
    OnClientRead = sv1ClientRead
    OnClientError = sv1ClientError
    Left = 12
    Top = 248
  end
  object sv2: TServerSocket
    Active = False
    Port = 5964
    ServerType = stNonBlocking
    OnClientConnect = sv2ClientConnect
    OnClientDisconnect = sv2ClientDisconnect
    OnClientRead = sv2ClientRead
    OnClientError = sv2ClientError
    Left = 44
    Top = 248
  end
  object sv3: TServerSocket
    Active = False
    Port = 5967
    ServerType = stNonBlocking
    OnClientConnect = sv3ClientConnect
    OnClientDisconnect = sv3ClientDisconnect
    OnClientRead = sv3ClientRead
    OnClientError = sv3ClientError
    Left = 76
    Top = 248
  end
  object DBsaveTimer: TTimer
    Enabled = False
    Interval = 300000
    OnTimer = DBsaveTimerTimer
    Left = 112
    Top = 248
  end
  object BackupTimer: TTimer
    Enabled = False
    OnTimer = BackupTimerTimer
    Left = 368
    Top = 200
  end
end
