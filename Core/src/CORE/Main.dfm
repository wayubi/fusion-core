object frmMain: TfrmMain
  Left = 364
  Top = 132
  Width = 408
  Height = 537
  Caption = '#33'
  Color = clCream
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS P????'
  Font.Style = []
  Menu = MainMenu1
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
    Top = 464
    Width = 400
    Height = 19
    Color = clCream
    Panels = <
      item
        Width = 100
      end
      item
        Width = 300
      end>
    SimplePanel = False
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 400
    Height = 464
    ActivePage = TabSheet1
    Align = alClient
    Constraints.MinHeight = 445
    Constraints.MinWidth = 400
    TabIndex = 0
    TabOrder = 1
    OnChange = PageControl1Change
    object TabSheet1: TTabSheet
      Caption = 'Server Console'
      DesignSize = (
        392
        433)
  object txtDebug: TMemo
    Left = 0
        Top = 0
        Width = 392
        Height = 404
        Anchors = [akLeft, akTop, akRight, akBottom]
    Color = 14071432
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -12
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
        TabOrder = 0
  end
      object Edit1: TEdit
    Left = 0
        Top = 406
        Width = 392
        Height = 26
        Anchors = [akLeft, akRight, akBottom]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        MaxLength = 200
        ParentFont = False
    TabOrder = 1
        OnKeyPress = Edit1KeyPress
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
        TabOrder = 2
        Visible = False
      OnClick = cmdStartClick
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
      object Button1: TButton
        Left = 5
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
        TabOrder = 4
        Visible = False
        OnClick = Button1Click
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'INI Options'
      ImageIndex = 1
      object Label17: TLabel
        Left = 160
        Top = 208
        Width = 74
        Height = 16
        Caption = 'Coming Soon'
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Accounts'
      ImageIndex = 2
      object Label1: TLabel
        Left = 264
        Top = 8
        Width = 65
        Height = 16
        Caption = 'Account ID:'
        Font.Charset = SHIFTJIS_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS P????'
        Font.Style = []
        ParentFont = False
      end
      object Label2: TLabel
        Left = 264
        Top = 48
        Width = 87
        Height = 16
        Caption = 'Account Name:'
        Font.Charset = SHIFTJIS_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS P????'
        Font.Style = []
        ParentFont = False
    end
      object Label3: TLabel
        Left = 264
        Top = 88
      Width = 108
        Height = 16
        Caption = 'Account Password:'
        Font.Charset = SHIFTJIS_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS P????'
        Font.Style = []
        ParentFont = False
      end
      object Label4: TLabel
        Left = 264
        Top = 128
        Width = 73
        Height = 16
        Caption = 'Account Sex:'
        Font.Charset = SHIFTJIS_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS P????'
        Font.Style = []
        ParentFont = False
      end
      object Label5: TLabel
        Left = 264
        Top = 168
        Width = 84
        Height = 16
        Caption = 'Account Email:'
        Font.Charset = SHIFTJIS_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS P????'
        Font.Style = []
        ParentFont = False
      end
      object Label6: TLabel
        Left = 264
        Top = 208
        Width = 96
        Height = 16
        Caption = 'Account Banned:'
        Font.Charset = SHIFTJIS_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS P????'
        Font.Style = []
        ParentFont = False
      end
      object Label7: TLabel
        Left = 8
        Top = 248
        Width = 72
        Height = 16
        Caption = 'Character 1:'
        Font.Charset = SHIFTJIS_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS P????'
        Font.Style = []
        ParentFont = False
      end
      object Label8: TLabel
        Left = 136
        Top = 248
        Width = 72
        Height = 16
        Caption = 'Character 2:'
        Font.Charset = SHIFTJIS_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS P????'
        Font.Style = []
        ParentFont = False
      end
      object Label9: TLabel
        Left = 264
        Top = 248
        Width = 72
        Height = 16
        Caption = 'Character 3:'
        Font.Charset = SHIFTJIS_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS P????'
        Font.Style = []
        ParentFont = False
      end
      object Label10: TLabel
        Left = 8
        Top = 288
        Width = 72
        Height = 16
        Caption = 'Character 4:'
        Font.Charset = SHIFTJIS_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS P????'
        Font.Style = []
        ParentFont = False
      end
      object Label11: TLabel
        Left = 136
        Top = 288
        Width = 72
        Height = 16
        Caption = 'Character 5:'
        Font.Charset = SHIFTJIS_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS P????'
        Font.Style = []
        ParentFont = False
      end
      object Label12: TLabel
        Left = 264
        Top = 288
        Width = 72
        Height = 16
        Caption = 'Character 6:'
        Font.Charset = SHIFTJIS_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS P????'
        Font.Style = []
        ParentFont = False
      end
      object Label13: TLabel
        Left = 8
        Top = 328
        Width = 72
        Height = 16
        Caption = 'Character 7:'
        Font.Charset = SHIFTJIS_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS P????'
        Font.Style = []
        ParentFont = False
      end
      object Label14: TLabel
        Left = 136
        Top = 328
        Width = 72
        Height = 16
        Caption = 'Character 8:'
        Font.Charset = SHIFTJIS_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS P????'
        Font.Style = []
        ParentFont = False
      end
      object Label15: TLabel
        Left = 264
        Top = 328
        Width = 72
        Height = 16
        Caption = 'Character 9:'
        Font.Charset = SHIFTJIS_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
        Font.Name = 'MS P????'
      Font.Style = []
      ParentFont = False
    end
      object Label16: TLabel
        Left = 8
        Top = 8
        Width = 72
        Height = 16
        Caption = 'Account List:'
        Font.Charset = SHIFTJIS_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
        Font.Name = 'MS P????'
      Font.Style = []
      ParentFont = False
      end
      object ListBox1: TListBox
        Left = 8
        Top = 24
        Width = 249
        Height = 225
        ItemHeight = 16
        TabOrder = 0
        OnClick = ListBox1Click
      end
      object Edit2: TEdit
        Left = 264
        Top = 24
        Width = 121
        Height = 24
      TabOrder = 1
      end
      object Edit3: TEdit
        Left = 264
        Top = 64
        Width = 121
        Height = 24
        Color = 12582911
        TabOrder = 2
      end
      object Edit4: TEdit
        Left = 264
        Top = 104
        Width = 121
        Height = 24
        Color = 12582911
        TabOrder = 3
      end
      object Edit5: TEdit
        Left = 264
        Top = 144
        Width = 121
        Height = 24
        Color = 12582911
        TabOrder = 4
      end
      object Edit6: TEdit
        Left = 264
        Top = 184
        Width = 121
        Height = 24
        Color = 12582911
        TabOrder = 5
      end
      object Edit7: TEdit
        Left = 264
        Top = 224
        Width = 121
        Height = 24
        TabOrder = 6
      end
      object Edit8: TEdit
        Left = 8
        Top = 264
        Width = 121
        Height = 24
        TabOrder = 7
      end
      object Edit9: TEdit
        Left = 136
        Top = 264
        Width = 121
        Height = 24
        TabOrder = 8
      end
      object Edit10: TEdit
        Left = 264
        Top = 264
        Width = 121
        Height = 24
        TabOrder = 9
      end
      object Edit11: TEdit
        Left = 8
        Top = 304
        Width = 121
        Height = 24
        TabOrder = 10
      end
      object Edit12: TEdit
        Left = 136
        Top = 304
        Width = 121
        Height = 24
        TabOrder = 11
      end
      object Edit13: TEdit
        Left = 264
        Top = 304
        Width = 121
        Height = 24
        TabOrder = 12
      end
      object Edit14: TEdit
        Left = 8
        Top = 344
        Width = 121
        Height = 24
        TabOrder = 13
      end
      object Edit15: TEdit
        Left = 136
        Top = 344
        Width = 121
        Height = 24
        TabOrder = 14
      end
      object Edit16: TEdit
        Left = 264
        Top = 344
        Width = 121
        Height = 24
        TabOrder = 15
      end
      object Button3: TButton
        Left = 8
        Top = 376
        Width = 75
        Height = 25
        Caption = 'Clear'
        TabOrder = 16
        OnClick = Button3Click
      end
      object Button4: TButton
        Left = 88
        Top = 376
        Width = 75
        Height = 25
        Caption = 'Save'
        TabOrder = 17
        OnClick = Button4Click
      end
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
    Left = 568
    Top = 64
  end
  object BackupTimer: TTimer
    Enabled = False
    OnTimer = BackupTimerTimer
    Left = 504
    Top = 64
  end
  object MainMenu1: TMainMenu
    Left = 536
    Top = 64
    object File1: TMenuItem
      Caption = '&File'
      object Save1: TMenuItem
        Caption = '&Save'
        OnClick = Save1Click
      end
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
      object MinimizetoTray1: TMenuItem
        Caption = 'Minimize to &Tray'
        OnClick = MinimizetoTray1Click
      end
    end
  end
end
