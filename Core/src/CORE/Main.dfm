object frmMain: TfrmMain
  Left = 314
  Top = 155
  Width = 408
  Height = 535
  Caption = 's'
  Color = clCream
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
  PixelsPerInch = 96
  TextHeight = 18
  object lbl00: TLabel
    Left = 189
    Top = 9
    Width = 30
    Height = 16
    Alignment = taRightJustify
    AutoSize = False
    Caption = '('#180'-`)'
  end
  object Label85: TLabel
    Left = 0
    Top = 56
    Width = 41
    Height = 18
    Caption = 'Label85'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 462
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
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 400
    Height = 462
    ActivePage = TabSheet1
    Align = alClient
    Constraints.MinHeight = 445
    Constraints.MinWidth = 400
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnChange = PageControl1Change
    object TabSheet1: TTabSheet
      Caption = 'Server Console'
      DesignSize = (
        392
        429)
      object txtDebug: TMemo
        Left = 0
        Top = 0
        Width = 392
        Height = 400
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
        Top = 402
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
      object PageControl2: TPageControl
        Left = 0
        Top = 0
        Width = 392
        Height = 429
        ActivePage = TabSheet4
        Align = alClient
        TabOrder = 0
        OnChange = PageControl2Change
        object TabSheet4: TTabSheet
          Caption = 'Server Options'
          object Label17: TLabel
            Left = 4
            Top = 8
            Width = 57
            Height = 18
            Caption = 'IP Address'
          end
          object Label18: TLabel
            Left = 132
            Top = 8
            Width = 69
            Height = 18
            Caption = 'Server Name'
          end
          object Label19: TLabel
            Left = 260
            Top = 8
            Width = 36
            Height = 18
            Caption = 'NPC ID'
          end
          object Label20: TLabel
            Left = 4
            Top = 48
            Width = 57
            Height = 18
            Caption = 'Login Port'
          end
          object Label21: TLabel
            Left = 132
            Top = 48
            Width = 83
            Height = 18
            Caption = 'Character Port'
          end
          object Label22: TLabel
            Left = 260
            Top = 48
            Width = 58
            Height = 18
            Caption = 'Game Port'
          end
          object Label25: TLabel
            Left = 132
            Top = 136
            Width = 92
            Height = 18
            Caption = 'MySQL Password'
          end
          object Label23: TLabel
            Left = 132
            Top = 96
            Width = 98
            Height = 18
            Caption = 'MySQL IP Address'
          end
          object Label24: TLabel
            Left = 4
            Top = 136
            Width = 95
            Height = 18
            Caption = 'MySQL Username'
          end
          object Label26: TLabel
            Left = 260
            Top = 96
            Width = 90
            Height = 18
            Caption = 'MySQL Database'
          end
          object Label27: TLabel
            Left = 4
            Top = 96
            Width = 61
            Height = 18
            Caption = 'Use MySQL'
          end
          object Label33: TLabel
            Left = 260
            Top = 224
            Width = 63
            Height = 18
            Caption = 'GM Logging'
          end
          object Label28: TLabel
            Left = 132
            Top = 224
            Width = 115
            Height = 18
            Caption = 'Auto-Backup Interval'
          end
          object Label29: TLabel
            Left = 4
            Top = 224
            Width = 99
            Height = 18
            Caption = 'Auto-Save Interval'
          end
          object Label30: TLabel
            Left = 260
            Top = 184
            Width = 104
            Height = 18
            Caption = '_M/_F Registration'
          end
          object Label31: TLabel
            Left = 132
            Top = 184
            Width = 84
            Height = 18
            Caption = 'Maximum Users'
          end
          object Label32: TLabel
            Left = 4
            Top = 184
            Width = 57
            Height = 18
            Caption = 'Auto-Start'
          end
          object Label36: TLabel
            Left = 260
            Top = 272
            Width = 31
            Height = 18
            Caption = 'Timer'
          end
          object Label34: TLabel
            Left = 4
            Top = 272
            Width = 103
            Height = 18
            Caption = 'Show Script Errors'
          end
          object Label35: TLabel
            Left = 132
            Top = 272
            Width = 66
            Height = 18
            Caption = 'Warp Debug'
          end
          object Label37: TLabel
            Left = 4
            Top = 312
            Width = 41
            Height = 18
            Caption = 'Priority'
          end
          object Label38: TLabel
            Left = 132
            Top = 312
            Width = 103
            Height = 18
            Caption = 'Enable Lower Dyes'
          end
          object Label60: TLabel
            Left = 260
            Top = 136
            Width = 64
            Height = 18
            Caption = 'W.A.C. Port'
          end
          object Edit17: TEdit
            Left = 4
            Top = 24
            Width = 121
            Height = 26
            TabOrder = 0
          end
          object Edit22: TEdit
            Left = 260
            Top = 64
            Width = 121
            Height = 26
            TabOrder = 5
          end
          object Edit21: TEdit
            Left = 132
            Top = 64
            Width = 121
            Height = 26
            TabOrder = 4
          end
          object Edit20: TEdit
            Left = 4
            Top = 64
            Width = 121
            Height = 26
            TabOrder = 3
          end
          object Edit19: TEdit
            Left = 260
            Top = 24
            Width = 121
            Height = 26
            TabOrder = 2
          end
          object Edit18: TEdit
            Left = 132
            Top = 24
            Width = 121
            Height = 26
            TabOrder = 1
          end
          object Button5: TButton
            Left = 276
            Top = 328
            Width = 75
            Height = 25
            Caption = 'Save'
            TabOrder = 21
            OnClick = Button5Click
          end
          object Edit23: TEdit
            Left = 4
            Top = 152
            Width = 121
            Height = 26
            TabOrder = 9
          end
          object Edit24: TEdit
            Left = 132
            Top = 112
            Width = 121
            Height = 26
            TabOrder = 7
          end
          object Edit25: TEdit
            Left = 132
            Top = 152
            Width = 121
            Height = 26
            TabOrder = 11
          end
          object Edit26: TEdit
            Left = 260
            Top = 112
            Width = 121
            Height = 26
            TabOrder = 8
          end
          object ComboBox1: TComboBox
            Left = 4
            Top = 112
            Width = 121
            Height = 26
            ItemHeight = 18
            TabOrder = 6
            Items.Strings = (
              'No'
              'Yes')
          end
          object Edit29: TEdit
            Left = 132
            Top = 200
            Width = 121
            Height = 26
            TabOrder = 12
          end
          object Edit30: TEdit
            Left = 132
            Top = 240
            Width = 121
            Height = 26
            TabOrder = 15
          end
          object Edit31: TEdit
            Left = 4
            Top = 240
            Width = 121
            Height = 26
            TabOrder = 14
          end
          object ComboBox2: TComboBox
            Left = 4
            Top = 200
            Width = 121
            Height = 26
            ItemHeight = 18
            TabOrder = 10
            Items.Strings = (
              'No'
              'Yes')
          end
          object ComboBox3: TComboBox
            Left = 260
            Top = 200
            Width = 121
            Height = 26
            ItemHeight = 18
            TabOrder = 13
            Items.Strings = (
              'No'
              'Yes')
          end
          object ComboBox4: TComboBox
            Left = 260
            Top = 240
            Width = 121
            Height = 26
            ItemHeight = 18
            TabOrder = 16
            Items.Strings = (
              'No'
              'Yes')
          end
          object ComboBox5: TComboBox
            Left = 5
            Top = 288
            Width = 121
            Height = 26
            ItemHeight = 18
            TabOrder = 17
            Items.Strings = (
              'No'
              'Yes')
          end
          object ComboBox6: TComboBox
            Left = 132
            Top = 288
            Width = 121
            Height = 26
            ItemHeight = 18
            TabOrder = 18
            Items.Strings = (
              'No'
              'Yes')
          end
          object ComboBox7: TComboBox
            Left = 260
            Top = 288
            Width = 121
            Height = 26
            ItemHeight = 18
            TabOrder = 19
            Items.Strings = (
              'No'
              'Yes')
          end
          object ComboBox8: TComboBox
            Left = 5
            Top = 328
            Width = 121
            Height = 26
            ItemHeight = 18
            TabOrder = 20
            Items.Strings = (
              'Real Time'
              'High'
              'Above Normal'
              'Normal'
              'Below Normal'
              'Low')
          end
          object ComboBox17: TComboBox
            Left = 132
            Top = 328
            Width = 121
            Height = 26
            ItemHeight = 18
            TabOrder = 22
            Items.Strings = (
              'No'
              'Yes')
          end
          object Edit5: TEdit
            Left = 260
            Top = 152
            Width = 121
            Height = 26
            TabOrder = 23
          end
        end
        object TabSheet5: TTabSheet
          Caption = 'Game Options'
          ImageIndex = 1
          object Label43: TLabel
            Left = 4
            Top = 272
            Width = 111
            Height = 18
            Caption = 'Base Death Exp Loss'
          end
          object Label44: TLabel
            Left = 132
            Top = 272
            Width = 106
            Height = 18
            Caption = 'Job Death Exp Loss'
          end
          object Label45: TLabel
            Left = 260
            Top = 272
            Width = 96
            Height = 18
            Caption = 'Party Share Level'
          end
          object Label49: TLabel
            Left = 4
            Top = 96
            Width = 100
            Height = 18
            Caption = 'Disable Level Limit'
          end
          object Label50: TLabel
            Left = 260
            Top = 96
            Width = 89
            Height = 18
            Caption = 'Enable Pet Skills'
          end
          object Label51: TLabel
            Left = 4
            Top = 136
            Width = 59
            Height = 18
            Caption = 'Enable PvP'
          end
          object Label52: TLabel
            Left = 132
            Top = 96
            Width = 102
            Height = 18
            Caption = 'Disable Equip Limit'
          end
          object Label53: TLabel
            Left = 132
            Top = 136
            Width = 90
            Height = 18
            Caption = 'Enable PvP Steal'
          end
          object Label55: TLabel
            Left = 132
            Top = 48
            Width = 96
            Height = 18
            Caption = 'Pet Capture Rate'
          end
          object Label56: TLabel
            Left = 4
            Top = 48
            Width = 104
            Height = 18
            Caption = 'Steal Success Rate'
          end
          object Label57: TLabel
            Left = 260
            Top = 8
            Width = 111
            Height = 18
            Caption = 'Item Drop Multiplier'
          end
          object Label58: TLabel
            Left = 132
            Top = 8
            Width = 100
            Height = 18
            Caption = 'Job Exp Multiplier'
          end
          object Label59: TLabel
            Left = 4
            Top = 8
            Width = 105
            Height = 18
            Caption = 'Base Exp Multiplier'
          end
          object Label54: TLabel
            Left = 260
            Top = 136
            Width = 109
            Height = 18
            Caption = 'Enable PvP Exp Loss'
          end
          object Label47: TLabel
            Left = 260
            Top = 224
            Width = 83
            Height = 18
            Caption = 'Default Y Point'
          end
          object Label39: TLabel
            Left = 4
            Top = 184
            Width = 70
            Height = 18
            Caption = 'Default Zeny'
          end
          object Label40: TLabel
            Left = 4
            Top = 224
            Width = 66
            Height = 18
            Caption = 'Default Map'
          end
          object Label41: TLabel
            Left = 132
            Top = 224
            Width = 83
            Height = 18
            Caption = 'Default X Point'
          end
          object Label42: TLabel
            Left = 132
            Top = 184
            Width = 87
            Height = 18
            Caption = 'Default Weapon'
          end
          object Label46: TLabel
            Left = 260
            Top = 184
            Width = 76
            Height = 18
            Caption = 'Default Armor'
          end
          object Label48: TLabel
            Left = 4
            Top = 312
            Width = 93
            Height = 18
            Caption = 'Disable Skill Limit'
          end
          object ComboBox16: TComboBox
            Left = 4
            Top = 112
            Width = 121
            Height = 26
            ItemHeight = 18
            TabOrder = 5
            Items.Strings = (
              'No'
              'Yes')
          end
          object Button2: TButton
            Left = 260
            Top = 328
            Width = 75
            Height = 25
            Caption = 'Save'
            TabOrder = 20
            OnClick = Button2Click
          end
          object Edit37: TEdit
            Left = 132
            Top = 24
            Width = 121
            Height = 26
            TabOrder = 1
          end
          object Edit38: TEdit
            Left = 260
            Top = 24
            Width = 121
            Height = 26
            TabOrder = 2
          end
          object Edit39: TEdit
            Left = 4
            Top = 64
            Width = 121
            Height = 26
            TabOrder = 3
          end
          object Edit40: TEdit
            Left = 132
            Top = 64
            Width = 121
            Height = 26
            TabOrder = 4
          end
          object Edit42: TEdit
            Left = 4
            Top = 24
            Width = 121
            Height = 26
            TabOrder = 0
          end
          object Edit27: TEdit
            Left = 4
            Top = 240
            Width = 121
            Height = 26
            TabOrder = 14
          end
          object Edit28: TEdit
            Left = 132
            Top = 240
            Width = 121
            Height = 26
            TabOrder = 15
          end
          object Edit43: TEdit
            Left = 132
            Top = 200
            Width = 121
            Height = 26
            TabOrder = 12
          end
          object Edit44: TEdit
            Left = 260
            Top = 200
            Width = 121
            Height = 26
            TabOrder = 13
          end
          object Edit45: TEdit
            Left = 260
            Top = 240
            Width = 121
            Height = 26
            TabOrder = 16
          end
          object Edit34: TEdit
            Left = 260
            Top = 288
            Width = 121
            Height = 26
            TabOrder = 19
          end
          object Edit32: TEdit
            Left = 4
            Top = 288
            Width = 121
            Height = 26
            TabOrder = 17
          end
          object Edit33: TEdit
            Left = 132
            Top = 288
            Width = 121
            Height = 26
            TabOrder = 18
          end
          object Edit35: TEdit
            Left = 4
            Top = 200
            Width = 121
            Height = 26
            TabOrder = 11
          end
          object ComboBox9: TComboBox
            Left = 132
            Top = 112
            Width = 121
            Height = 26
            ItemHeight = 18
            TabOrder = 6
            Items.Strings = (
              'No'
              'Yes')
          end
          object ComboBox10: TComboBox
            Left = 260
            Top = 112
            Width = 121
            Height = 26
            ItemHeight = 18
            TabOrder = 7
            Items.Strings = (
              'No'
              'Yes')
          end
          object ComboBox11: TComboBox
            Left = 4
            Top = 152
            Width = 121
            Height = 26
            ItemHeight = 18
            TabOrder = 8
            Items.Strings = (
              'No'
              'Yes')
          end
          object ComboBox12: TComboBox
            Left = 132
            Top = 152
            Width = 121
            Height = 26
            ItemHeight = 18
            TabOrder = 9
            Items.Strings = (
              'No'
              'Yes')
          end
          object ComboBox13: TComboBox
            Left = 260
            Top = 152
            Width = 121
            Height = 26
            ItemHeight = 18
            TabOrder = 10
            Items.Strings = (
              'No'
              'Yes')
          end
          object ComboBox14: TComboBox
            Left = 4
            Top = 328
            Width = 121
            Height = 26
            ItemHeight = 18
            TabOrder = 21
            Items.Strings = (
              'No'
              'Yes')
          end
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Accounts'
      ImageIndex = 2
      object Label1: TLabel
        Left = 264
        Top = 8
        Width = 65
        Height = 18
        Caption = 'Account ID:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
      end
      object Label2: TLabel
        Left = 264
        Top = 48
        Width = 85
        Height = 18
        Caption = 'Account Name:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
      end
      object Label3: TLabel
        Left = 264
        Top = 88
        Width = 106
        Height = 18
        Caption = 'Account Password:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
      end
      object Label4: TLabel
        Left = 264
        Top = 128
        Width = 74
        Height = 18
        Caption = 'Account Sex:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
      end
      object Label5: TLabel
        Left = 264
        Top = 168
        Width = 82
        Height = 18
        Caption = 'Account Email:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
      end
      object Label6: TLabel
        Left = 264
        Top = 208
        Width = 96
        Height = 18
        Caption = 'Account Banned:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
      end
      object Label7: TLabel
        Left = 8
        Top = 248
        Width = 109
        Height = 18
        Caption = 'Delete Character 1:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
      end
      object Label8: TLabel
        Left = 136
        Top = 248
        Width = 109
        Height = 18
        Caption = 'Delete Character 2:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
      end
      object Label9: TLabel
        Left = 264
        Top = 248
        Width = 109
        Height = 18
        Caption = 'Delete Character 3:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
      end
      object Label10: TLabel
        Left = 8
        Top = 288
        Width = 109
        Height = 18
        Caption = 'Delete Character 4:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
      end
      object Label11: TLabel
        Left = 136
        Top = 288
        Width = 109
        Height = 18
        Caption = 'Delete Character 5:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
      end
      object Label12: TLabel
        Left = 264
        Top = 288
        Width = 109
        Height = 18
        Caption = 'Delete Character 6:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
      end
      object Label13: TLabel
        Left = 8
        Top = 328
        Width = 109
        Height = 18
        Caption = 'Delete Character 7:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
      end
      object Label14: TLabel
        Left = 136
        Top = 328
        Width = 109
        Height = 18
        Caption = 'Delete Character 8:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
      end
      object Label15: TLabel
        Left = 264
        Top = 328
        Width = 109
        Height = 18
        Caption = 'Delete Character 9:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
      end
      object Label16: TLabel
        Left = 8
        Top = 8
        Width = 74
        Height = 18
        Caption = 'Account List:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
      end
      object ListBox1: TListBox
        Left = 8
        Top = 24
        Width = 249
        Height = 225
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ItemHeight = 18
        MultiSelect = True
        ParentFont = False
        TabOrder = 0
        OnClick = ListBox1Click
      end
      object Edit2: TEdit
        Left = 264
        Top = 24
        Width = 121
        Height = 26
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object Edit3: TEdit
        Left = 264
        Top = 64
        Width = 121
        Height = 26
        Color = 12582911
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
      end
      object Edit4: TEdit
        Left = 264
        Top = 104
        Width = 121
        Height = 26
        Color = 12582911
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
      end
      object Edit6: TEdit
        Left = 264
        Top = 184
        Width = 121
        Height = 26
        Color = 12582911
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 5
      end
      object Button3: TButton
        Left = 8
        Top = 376
        Width = 75
        Height = 25
        Caption = '&Clear'
        TabOrder = 16
        OnClick = Button3Click
      end
      object Button4: TButton
        Left = 168
        Top = 376
        Width = 75
        Height = 25
        Caption = '&Save'
        TabOrder = 18
        OnClick = Button4Click
      end
      object Button6: TButton
        Left = 88
        Top = 376
        Width = 75
        Height = 25
        Caption = '&Delete'
        TabOrder = 17
        OnClick = Button6Click
      end
      object ComboBox15: TComboBox
        Left = 264
        Top = 144
        Width = 121
        Height = 26
        ItemHeight = 18
        TabOrder = 4
        Items.Strings = (
          'Female'
          'Male')
      end
      object ComboBox18: TComboBox
        Left = 263
        Top = 224
        Width = 121
        Height = 26
        ItemHeight = 18
        TabOrder = 6
        Items.Strings = (
          'No'
          'Yes')
      end
      object Button7: TButton
        Left = 8
        Top = 264
        Width = 121
        Height = 25
        TabOrder = 7
        OnClick = Button7Clic
      end
      object Button8: TButton
        Left = 136
        Top = 264
        Width = 121
        Height = 25
        TabOrder = 8
        OnClick = Button8Click
      end
      object Button9: TButton
        Left = 264
        Top = 264
        Width = 121
        Height = 25
        TabOrder = 9
        OnClick = Button9Click
      end
      object Button10: TButton
        Left = 8
        Top = 304
        Width = 121
        Height = 25
        TabOrder = 10
        OnClick = Button10Click
      end
      object Button11: TButton
        Left = 136
        Top = 304
        Width = 121
        Height = 25
        TabOrder = 11
        OnClick = Button11Click
      end
      object Button12: TButton
        Left = 264
        Top = 304
        Width = 121
        Height = 25
        TabOrder = 12
        OnClick = Button12Click
      end
      object Button13: TButton
        Left = 8
        Top = 344
        Width = 121
        Height = 25
        TabOrder = 13
        OnClick = Button13Click
      end
      object Button14: TButton
        Left = 136
        Top = 344
        Width = 121
        Height = 25
        TabOrder = 14
        OnClick = Button14Click
      end
      object Button15: TButton
        Left = 264
        Top = 344
        Width = 121
        Height = 25
        TabOrder = 15
        OnClick = Button15Click
      end
    end
    object TabSheet7: TTabSheet
      Caption = 'Characters'
      object PageControl3: TPageControl
        Left = 0
        Top = 0
        Width = 393
        Height = 433
        ActivePage = TabSheet6
        TabOrder = 0
        OnChange = PageControl3Change
        object TabSheet6: TTabSheet
          Caption = 'Online'
          ImageIndex = 6
          object Label95: TLabel
            Left = 8
            Top = 368
            Width = 4
            Height = 18
            Visible = False
          end
          object Label96: TLabel
            Left = 8
            Top = 184
            Width = 128
            Height = 18
            Caption = 'Message the Character'
          end
          object ListBox3: TListBox
            Left = 8
            Top = 8
            Width = 233
            Height = 177
            ItemHeight = 18
            TabOrder = 0
            OnClick = ListBox3Click
          end
          object Button17: TButton
            Left = 264
            Top = 8
            Width = 97
            Height = 25
            Caption = 'Refresh'
            TabOrder = 1
            OnClick = Button17Click
          end
          object Button18: TButton
            Left = 264
            Top = 40
            Width = 97
            Height = 25
            Caption = 'Kick'
            TabOrder = 2
            OnClick = Button18Click
          end
          object Edit8: TEdit
            Left = 8
            Top = 200
            Width = 369
            Height = 26
            TabOrder = 3
            OnKeyPress = Edit8KeyPress
          end
          object Button19: TButton
            Left = 8
            Top = 352
            Width = 105
            Height = 17
            Caption = 'Send'
            TabOrder = 4
            Visible = False
            OnClick = Button19Click
          end
          object Button20: TButton
            Left = 264
            Top = 72
            Width = 97
            Height = 25
            Caption = 'Kick / Ban'
            TabOrder = 5
            OnClick = Button20Click
          end
        end
        object TabSheet9: TTabSheet
          Caption = 'Stats'
          object Label61: TLabel
            Left = 0
            Top = 0
            Width = 78
            Height = 18
            Caption = 'Character List'
          end
          object Label63: TLabel
            Left = 296
            Top = 0
            Width = 69
            Height = 18
            Caption = 'Character ID'
          end
          object Label64: TLabel
            Left = 184
            Top = 40
            Width = 34
            Height = 18
            Caption = 'Job ID'
          end
          object Label67: TLabel
            Left = 184
            Top = 0
            Width = 30
            Height = 18
            Caption = 'Name'
          end
          object Label62: TLabel
            Left = 240
            Top = 40
            Width = 47
            Height = 18
            Caption = 'Base Lvl.'
          end
          object Label66: TLabel
            Left = 184
            Top = 80
            Width = 49
            Height = 18
            Caption = 'Base EXP'
          end
          object Label68: TLabel
            Left = 240
            Top = 80
            Width = 44
            Height = 18
            Caption = 'Job EXP'
          end
          object Label69: TLabel
            Left = 296
            Top = 40
            Width = 42
            Height = 18
            Caption = 'Job Lvl.'
          end
          object Label70: TLabel
            Left = 296
            Top = 120
            Width = 59
            Height = 18
            Caption = 'Status Pts.'
          end
          object Label71: TLabel
            Left = 240
            Top = 120
            Width = 46
            Height = 18
            Caption = 'Skill Pts.'
          end
          object Label72: TLabel
            Left = 296
            Top = 80
            Width = 27
            Height = 18
            Caption = 'Zeny'
          end
          object Label73: TLabel
            Left = 184
            Top = 120
            Width = 34
            Height = 18
            Caption = 'Speed'
          end
          object Label74: TLabel
            Left = 184
            Top = 160
            Width = 53
            Height = 18
            Caption = 'Hair Style'
          end
          object Label75: TLabel
            Left = 240
            Top = 160
            Width = 55
            Height = 18
            Caption = 'Hair Color'
          end
          object Label76: TLabel
            Left = 296
            Top = 160
            Width = 67
            Height = 18
            Caption = 'Cloths Color'
          end
          object Label77: TLabel
            Left = 24
            Top = 160
            Width = 37
            Height = 18
            Caption = 'S. Map'
          end
          object Label78: TLabel
            Left = 72
            Top = 160
            Width = 48
            Height = 18
            Caption = 'S. Map X'
          end
          object Label79: TLabel
            Left = 128
            Top = 160
            Width = 44
            Height = 18
            Caption = 'S.Map Y'
          end
          object Label80: TLabel
            Left = 16
            Top = 200
            Width = 23
            Height = 18
            Caption = 'Map'
          end
          object Label94: TLabel
            Left = 296
            Top = 240
            Width = 21
            Height = 18
            Caption = 'LUK'
          end
          object Label93: TLabel
            Left = 240
            Top = 240
            Width = 20
            Height = 18
            Caption = 'DEX'
          end
          object Label92: TLabel
            Left = 184
            Top = 240
            Width = 18
            Height = 18
            Caption = 'INT'
          end
          object Label91: TLabel
            Left = 128
            Top = 240
            Width = 17
            Height = 18
            Caption = 'VIT'
          end
          object Label90: TLabel
            Left = 72
            Top = 240
            Width = 18
            Height = 18
            Caption = 'AGI'
          end
          object Label89: TLabel
            Left = 16
            Top = 240
            Width = 20
            Height = 18
            Caption = 'STR'
          end
          object Label88: TLabel
            Left = 240
            Top = 200
            Width = 44
            Height = 18
            Caption = 'Status 2'
          end
          object Label87: TLabel
            Left = 184
            Top = 200
            Width = 44
            Height = 18
            Caption = 'Status 1'
          end
          object Label86: TLabel
            Left = 296
            Top = 200
            Width = 38
            Height = 18
            Caption = 'Option'
          end
          object Label84: TLabel
            Left = 72
            Top = 280
            Width = 13
            Height = 18
            Caption = 'SP'
          end
          object Label83: TLabel
            Left = 16
            Top = 280
            Width = 15
            Height = 18
            Caption = 'HP'
          end
          object Label82: TLabel
            Left = 128
            Top = 200
            Width = 45
            Height = 18
            Caption = 'C-Map Y'
          end
          object Label81: TLabel
            Left = 72
            Top = 200
            Width = 45
            Height = 18
            Caption = 'C-Map X'
          end
          object Label65: TLabel
            Left = 128
            Top = 280
            Width = 45
            Height = 18
            Caption = 'Max HP:'
          end
          object Label97: TLabel
            Left = 184
            Top = 280
            Width = 43
            Height = 18
            Caption = 'Max SP:'
          end
          object Label98: TLabel
            Left = 128
            Top = 296
            Width = 21
            Height = 18
            Caption = 'N/A'
          end
          object Label99: TLabel
            Left = 184
            Top = 296
            Width = 21
            Height = 18
            Caption = 'N/A'
          end
          object Label102: TLabel
            Left = 296
            Top = 296
            Width = 21
            Height = 18
            Caption = 'N/A'
          end
          object Label101: TLabel
            Left = 296
            Top = 280
            Width = 21
            Height = 18
            Caption = 'AID:'
          end
          object Edit52: TEdit
            Left = 16
            Top = 216
            Width = 49
            Height = 26
            TabOrder = 0
          end
          object Edit15: TEdit
            Left = 184
            Top = 96
            Width = 49
            Height = 26
            TabOrder = 1
          end
          object Edit14: TEdit
            Left = 240
            Top = 56
            Width = 49
            Height = 26
            TabOrder = 2
          end
          object Edit10: TEdit
            Left = 184
            Top = 56
            Width = 49
            Height = 26
            TabOrder = 3
          end
          object Edit7: TEdit
            Left = 184
            Top = 16
            Width = 105
            Height = 26
            TabOrder = 4
          end
          object Edit9: TEdit
            Left = 296
            Top = 16
            Width = 49
            Height = 26
            TabOrder = 5
          end
          object ListBox2: TListBox
            Left = 16
            Top = 16
            Width = 161
            Height = 145
            ItemHeight = 18
            TabOrder = 6
            OnClick = ListBox2Click
          end
          object Edit11: TEdit
            Left = 296
            Top = 136
            Width = 49
            Height = 26
            TabOrder = 7
          end
          object Edit12: TEdit
            Left = 296
            Top = 56
            Width = 49
            Height = 26
            TabOrder = 8
          end
          object Edit13: TEdit
            Left = 240
            Top = 96
            Width = 49
            Height = 26
            TabOrder = 9
          end
          object Edit16: TEdit
            Left = 240
            Top = 136
            Width = 49
            Height = 26
            TabOrder = 10
          end
          object Edit36: TEdit
            Left = 296
            Top = 96
            Width = 49
            Height = 26
            TabOrder = 11
          end
          object Edit41: TEdit
            Left = 184
            Top = 136
            Width = 49
            Height = 26
            TabOrder = 12
          end
          object Edit46: TEdit
            Left = 184
            Top = 176
            Width = 49
            Height = 26
            TabOrder = 13
          end
          object Edit47: TEdit
            Left = 240
            Top = 176
            Width = 49
            Height = 26
            TabOrder = 14
          end
          object Edit48: TEdit
            Left = 296
            Top = 176
            Width = 49
            Height = 26
            TabOrder = 15
          end
          object Edit49: TEdit
            Left = 16
            Top = 176
            Width = 49
            Height = 26
            TabOrder = 16
          end
          object Edit50: TEdit
            Left = 72
            Top = 176
            Width = 49
            Height = 26
            TabOrder = 17
          end
          object Edit51: TEdit
            Left = 128
            Top = 176
            Width = 49
            Height = 26
            TabOrder = 18
          end
          object Button16: TButton
            Left = 16
            Top = 336
            Width = 81
            Height = 25
            Caption = 'Save'
            TabOrder = 19
            OnClick = Button16Click
          end
          object Edit67: TEdit
            Left = 16
            Top = 256
            Width = 49
            Height = 26
            TabOrder = 20
          end
          object Edit66: TEdit
            Left = 72
            Top = 256
            Width = 49
            Height = 26
            TabOrder = 21
          end
          object Edit65: TEdit
            Left = 128
            Top = 256
            Width = 49
            Height = 26
            TabOrder = 22
          end
          object Edit64: TEdit
            Left = 240
            Top = 254
            Width = 49
            Height = 26
            TabOrder = 23
          end
          object Edit63: TEdit
            Left = 184
            Top = 256
            Width = 49
            Height = 26
            TabOrder = 24
          end
          object Edit61: TEdit
            Left = 296
            Top = 254
            Width = 49
            Height = 26
            TabOrder = 25
          end
          object Edit59: TEdit
            Left = 128
            Top = 216
            Width = 49
            Height = 26
            TabOrder = 26
          end
          object Edit58: TEdit
            Left = 16
            Top = 296
            Width = 49
            Height = 26
            TabOrder = 27
          end
          object Edit57: TEdit
            Left = 72
            Top = 216
            Width = 49
            Height = 26
            TabOrder = 28
          end
          object Edit56: TEdit
            Left = 184
            Top = 216
            Width = 49
            Height = 26
            TabOrder = 29
          end
          object Edit55: TEdit
            Left = 240
            Top = 216
            Width = 49
            Height = 26
            TabOrder = 30
          end
          object Edit54: TEdit
            Left = 296
            Top = 216
            Width = 49
            Height = 26
            TabOrder = 31
          end
          object Edit53: TEdit
            Left = 72
            Top = 296
            Width = 49
            Height = 26
            TabOrder = 32
          end
        end
        object TabSheet14: TTabSheet
          Caption = 'Skills'
          ImageIndex = 5
        end
        object TabSheet10: TTabSheet
          Caption = 'Inventory'
          ImageIndex = 1
          object ListBox4: TListBox
            Left = 8
            Top = 16
            Width = 193
            Height = 153
            ItemHeight = 18
            TabOrder = 0
          end
        end
        object TabSheet13: TTabSheet
          Caption = 'Cart'
          ImageIndex = 4
        end
        object TabSheet12: TTabSheet
          Caption = 'Memo'
          ImageIndex = 3
        end
        object TabSheet11: TTabSheet
          Caption = 'Flags'
          ImageIndex = 2
        end
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
    Left = 20
    Top = 192
  end
  object sv2: TServerSocket
    Active = False
    Port = 5964
    ServerType = stNonBlocking
    OnClientConnect = sv2ClientConnect
    OnClientDisconnect = sv2ClientDisconnect
    OnClientRead = sv2ClientRead
    OnClientError = sv2ClientError
    Left = 52
    Top = 192
  end
  object sv3: TServerSocket
    Active = False
    Port = 5967
    ServerType = stNonBlocking
    OnClientConnect = sv3ClientConnect
    OnClientDisconnect = sv3ClientDisconnect
    OnClientRead = sv3ClientRead
    OnClientError = sv3ClientError
    Left = 84
    Top = 192
  end
  object DBsaveTimer: TTimer
    Enabled = False
    Interval = 300000
    OnTimer = DBsaveTimerTimer
    Left = 80
    Top = 160
  end
  object BackupTimer: TTimer
    Enabled = False
    OnTimer = BackupTimerTimer
    Left = 16
    Top = 160
  end
  object MainMenu1: TMainMenu
    Left = 48
    Top = 160
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
      Caption = 'Database'
      object Save1: TMenuItem
        Caption = 'Online Save'
        OnClick = Save1Click
      end
      object S1: TMenuItem
        Caption = 'Comprehensive Save'
        OnClick = S1Click
      end
      object Backup1: TMenuItem
        Caption = 'Backup'
        OnClick = Backup1Click
      end
    end
    object Control1: TMenuItem
      Caption = 'Control'
      object MinimizetoTray2: TMenuItem
        Caption = 'Minimize to Tray'
        OnClick = MinimizetoTray2Click
      end
      object ConnecttoISCS1: TMenuItem
        Caption = 'Connect to ISCS'
        OnClick = ConnecttoISCS1Click
      end
      object EnableWebAccountCreator1: TMenuItem
        Caption = 'Enable Web Account Creator'
        OnClick = EnableWebAccountCreator1Click
      end
    end
  end
end
