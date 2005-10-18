object frmMain: TfrmMain
  Left = 199
  Top = 54
  Width = 828
  Height = 491
  Caption = 's'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnResize = FormResize
  DesignSize = (
    820
    445)
  PixelsPerInch = 96
  TextHeight = 18
  object lbl00: TLabel
    Left = 77
    Top = 73
    Width = 30
    Height = 16
    Alignment = taRightJustify
    AutoSize = False
    Caption = '('#180'-`)'
    Visible = False
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 426
    Width = 820
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 300
      end>
  end
  object txtDebug: TMemo
    Left = 13
    Top = 147
    Width = 287
    Height = 223
    Anchors = []
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
    Visible = False
  end
  object Button1: TButton
    Left = 81
    Top = 109
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
    Visible = False
    OnClick = Button1Click
  end
  object cmdStop: TButton
    Left = 5
    Top = 85
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
    TabOrder = 3
    Visible = False
    OnClick = cmdStopClick
  end
  object cmdStart: TButton
    Left = 5
    Top = 61
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
    TabOrder = 4
    Visible = False
    OnClick = cmdStartClick
  end
  object Edit1: TEdit
    Left = 0
    Top = 0
    Width = 819
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MaxLength = 200
    ParentFont = False
    TabOrder = 5
    OnKeyPress = Edit1KeyPress
  end
  object WebBrowser1: TWebBrowser
    Left = 0
    Top = 0
    Width = 820
    Height = 426
    Align = alClient
    TabOrder = 6
    ControlData = {
      4C000000C0540000072C00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object sv1: TServerSocket
    Active = False
    Port = 6900
    ServerType = stNonBlocking
    OnClientConnect = sv1ClientConnect
    OnClientDisconnect = sv1ClientDisconnect
    OnClientRead = sv1ClientRead
    OnClientError = sv1ClientError
    Left = 36
    Top = 512
  end
  object sv2: TServerSocket
    Active = False
    Port = 5964
    ServerType = stNonBlocking
    OnClientConnect = sv2ClientConnect
    OnClientDisconnect = sv2ClientDisconnect
    OnClientRead = sv2ClientRead
    OnClientError = sv2ClientError
    Left = 68
    Top = 512
  end
  object sv3: TServerSocket
    Active = False
    Port = 5967
    ServerType = stNonBlocking
    OnClientConnect = sv3ClientConnect
    OnClientDisconnect = sv3ClientDisconnect
    OnClientRead = sv3ClientRead
    OnClientError = sv3ClientError
    Left = 100
    Top = 512
  end
  object DBsaveTimer: TTimer
    Enabled = False
    Interval = 300000
    OnTimer = DBsaveTimerTimer
    Left = 96
    Top = 480
  end
  object BackupTimer: TTimer
    Enabled = False
    OnTimer = BackupTimerTimer
    Left = 40
    Top = 472
  end
  object MainMenu1: TMainMenu
    Left = 64
    Top = 480
    object File1: TMenuItem
      Caption = '&File'
      object Exit1: TMenuItem
        Caption = 'E&xit'
        OnClick = Exit1Click
      end
    end
    object Server1: TMenuItem
      Caption = '&Server'
      object Start1: TMenuItem
        Caption = '&Start'
        OnClick = Start1Click
      end
      object Stop1: TMenuItem
        Caption = 'S&top'
        OnClick = Stop1Click
      end
    end
    object Database1: TMenuItem
      Caption = '&Database'
      object Save1: TMenuItem
        Caption = '&Online Save'
        OnClick = Save1Click
      end
      object S1: TMenuItem
        Caption = '&Comprehensive Save'
        OnClick = S1Click
      end
      object Backup1: TMenuItem
        Caption = '&Backup'
        OnClick = Backup1Click
      end
    end
    object Control1: TMenuItem
      Caption = '&Control'
      object MinimizetoTray2: TMenuItem
        Caption = '&Minimize to Tray'
        OnClick = MinimizetoTray2Click
      end
      object EnableWebAccountCreator1: TMenuItem
        Caption = '&Enable Web Account Creator'
        OnClick = EnableWebAccountCreator1Click
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
      object FusionHomepage1: TMenuItem
        Caption = 'Fusion Home Page'
        OnClick = FusionHomepage1Click
      end
      object WikiDocumentation1: TMenuItem
        Caption = 'Documentation'
        OnClick = WikiDocumentation1Click
      end
      object IRCChatroom1: TMenuItem
        Caption = 'IRC Chatroom'
        OnClick = IRCChatroom1Click
      end
      object FusionControlPanel1: TMenuItem
        Caption = 'Fusion Control Panel'
        OnClick = FusionControlPanel1Click
      end
      object Bugtracker1: TMenuItem
        Caption = 'Report Bugs'
        OnClick = Bugtracker1Click
      end
    end
  end
  object DNSUpdateTimer: TTimer
    Enabled = False
    OnTimer = DNSUpdateTimerTimer
    Left = 128
    Top = 480
  end
  object ADODataSet1: TADODataSet
    ConnectionString = 'FILE NAME=C:\Program Files\The Fusion Project\mysql.udl'
    Parameters = <>
    Left = 144
    Top = 32
  end
end
