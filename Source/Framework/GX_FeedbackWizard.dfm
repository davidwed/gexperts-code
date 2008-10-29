object fmFeedbackWizard: TfmFeedbackWizard
  Left = 285
  Top = 155
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'GExperts Feedback Wizard'
  ClientHeight = 399
  ClientWidth = 584
  Color = clBtnFace
  Constraints.MinHeight = 414
  Constraints.MinWidth = 554
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 584
    Height = 83
    Align = alTop
    BevelOuter = bvNone
    FullRepaint = False
    TabOrder = 0
    object pnlHeader: TPanel
      Left = 0
      Top = 0
      Width = 584
      Height = 43
      Align = alTop
      BevelOuter = bvNone
      Color = 6488064
      TabOrder = 0
      DesignSize = (
        584
        43)
      object lblFeeedback: TLabel
        Left = 9
        Top = 10
        Width = 275
        Height = 24
        Alignment = taRightJustify
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GExperts Feedback Wizard'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWhite
        Font.Height = -21
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
    end
    object pnlDescription: TPanel
      Left = 0
      Top = 43
      Width = 584
      Height = 40
      Align = alClient
      BevelInner = bvRaised
      BevelOuter = bvNone
      BorderWidth = 1
      FullRepaint = False
      TabOrder = 1
      object lblDescription: TLabel
        Left = 2
        Top = 2
        Width = 580
        Height = 36
        Align = alClient
        Alignment = taCenter
        Caption = 'Feedback Type'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
      end
    end
  end
  object pnlContent: TPanel
    Left = 0
    Top = 83
    Width = 584
    Height = 280
    Align = alClient
    BevelOuter = bvNone
    FullRepaint = False
    TabOrder = 1
    object Splitter: TSplitter
      Left = 376
      Top = 0
      Width = 5
      Height = 280
      Cursor = crHSplit
      Align = alRight
      AutoSnap = False
      Beveled = True
      MinSize = 100
    end
    object pgeInfo: TPageControl
      Left = 381
      Top = 0
      Width = 203
      Height = 280
      ActivePage = tshInfoHelp
      Align = alRight
      MultiLine = True
      TabIndex = 0
      TabOrder = 0
      object tshInfoHelp: TTabSheet
        Caption = 'Help'
        object mmoInfoHelp: TMemo
          Left = 0
          Top = 0
          Width = 195
          Height = 252
          Align = alClient
          Color = 15858687
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          TabOrder = 0
          OnEnter = InfoMemoEnter
        end
      end
      object tshInfoExample: TTabSheet
        Caption = 'Example'
        ImageIndex = 1
        object mmoInfoExample: TMemo
          Left = 0
          Top = 0
          Width = 195
          Height = 238
          Align = alClient
          Color = 15858687
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          TabOrder = 0
          OnEnter = InfoMemoEnter
        end
      end
    end
    object pnlMain: TPanel
      Left = 0
      Top = 0
      Width = 376
      Height = 280
      Align = alClient
      BorderWidth = 1
      FullRepaint = False
      TabOrder = 1
      object pgeMain: TPageControl
        Left = 2
        Top = 2
        Width = 372
        Height = 276
        ActivePage = tshType
        Align = alClient
        TabIndex = 0
        TabOrder = 0
        OnResize = pgeMainResize
        object tshType: TTabSheet
          Caption = 'Feedback Type'
          object rgpFeedbackType: TRadioGroup
            Left = 8
            Top = 6
            Width = 177
            Height = 73
            Caption = ' Feedback Type '
            ItemIndex = 0
            Items.Strings = (
              '&Bug Report'
              '&Feature Request')
            TabOrder = 0
            OnClick = rgpFeedbackTypeClick
          end
        end
        object tshDescription: TTabSheet
          Caption = 'Bug Description'
          ImageIndex = 1
          object mmoDescription: TMemo
            Left = 0
            Top = 0
            Width = 372
            Height = 255
            Align = alClient
            ScrollBars = ssVertical
            TabOrder = 0
          end
        end
        object tshBugDetails: TTabSheet
          Caption = 'Bug Details'
          ImageIndex = 2
          object gbxBugDetails: TGroupBox
            Left = 8
            Top = 6
            Width = 305
            Height = 129
            Caption = ' Bug Details '
            TabOrder = 0
            object lblPercent: TLabel
              Left = 70
              Top = 48
              Width = 60
              Height = 13
              Caption = '% of the &time'
              FocusControl = edtPercent
            end
            object chkProjectSpecific: TCheckBox
              Left = 13
              Top = 98
              Width = 288
              Height = 17
              Caption = 'T&he bug is project specific'
              TabOrder = 3
            end
            object chkMultipleMachines: TCheckBox
              Left = 13
              Top = 74
              Width = 288
              Height = 17
              Caption = 'The bug occurs on &multiple machines'
              TabOrder = 2
            end
            object edtPercent: TEdit
              Left = 26
              Top = 44
              Width = 39
              Height = 21
              MaxLength = 3
              TabOrder = 1
              Text = '100'
              OnKeyPress = edtPercentKeyPress
            end
            object chkReproducible: TCheckBox
              Left = 13
              Top = 21
              Width = 288
              Height = 17
              Caption = 'The bug is &reproducible'
              Checked = True
              State = cbChecked
              TabOrder = 0
              OnClick = chkReproducibleClick
            end
          end
        end
        object tshBugSteps: TTabSheet
          Caption = 'Bug Duplication Steps'
          ImageIndex = 3
          object mmoBugSteps: TMemo
            Left = 0
            Top = 0
            Width = 372
            Height = 255
            Align = alClient
            ScrollBars = ssVertical
            TabOrder = 0
          end
        end
        object tshConfiguration: TTabSheet
          Caption = 'Configuration Data to Report'
          ImageIndex = 5
          object gbxConfigurationData: TGroupBox
            Left = 8
            Top = 2
            Width = 305
            Height = 188
            Caption = ' Configuration Data to Report '
            TabOrder = 0
            object chkGExpertsVer: TCheckBox
              Left = 16
              Top = 20
              Width = 280
              Height = 17
              Caption = 'GExperts &Version'
              Checked = True
              Enabled = False
              State = cbChecked
              TabOrder = 0
            end
            object chkOS: TCheckBox
              Left = 16
              Top = 60
              Width = 280
              Height = 17
              Caption = '&Operating System'
              Checked = True
              Enabled = False
              State = cbChecked
              TabOrder = 2
            end
            object chkExperts: TCheckBox
              Left = 16
              Top = 100
              Width = 280
              Height = 17
              Caption = 'Installed E&xperts'
              Checked = True
              State = cbChecked
              TabOrder = 4
            end
            object chkIdeVer: TCheckBox
              Left = 16
              Top = 40
              Width = 280
              Height = 17
              Caption = 'Borland &IDE Version'
              Checked = True
              Enabled = False
              State = cbChecked
              TabOrder = 1
            end
            object chkPackages: TCheckBox
              Left = 16
              Top = 120
              Width = 280
              Height = 17
              Caption = 'Inst&alled Packages'
              Checked = True
              State = cbChecked
              TabOrder = 5
            end
            object chkLocaleKeyboard: TCheckBox
              Left = 16
              Top = 140
              Width = 280
              Height = 17
              Caption = 'Locale/&Keyboard Information'
              Checked = True
              State = cbChecked
              TabOrder = 6
            end
            object chkCpu: TCheckBox
              Left = 16
              Top = 160
              Width = 280
              Height = 17
              Caption = 'CP&U Information'
              Checked = True
              State = cbChecked
              TabOrder = 7
            end
            object chkGExpertsSettings: TCheckBox
              Left = 16
              Top = 80
              Width = 280
              Height = 17
              Caption = '&GExperts Settings'
              Checked = True
              State = cbChecked
              TabOrder = 3
            end
          end
        end
        object tshReport: TTabSheet
          Caption = 'Completed Bug Report'
          ImageIndex = 4
          object mmoReport: TMemo
            Left = 0
            Top = 0
            Width = 265
            Height = 255
            Align = alClient
            ScrollBars = ssBoth
            TabOrder = 0
            WordWrap = False
          end
          object pnlReportButtons: TPanel
            Left = 265
            Top = 0
            Width = 107
            Height = 255
            Align = alRight
            BevelOuter = bvNone
            TabOrder = 1
            object btnSave: TButton
              Left = 4
              Top = 46
              Width = 103
              Height = 27
              Caption = '&Save Report...'
              TabOrder = 1
              OnClick = btnSaveClick
            end
            object btnCopy: TButton
              Left = 4
              Top = 6
              Width = 103
              Height = 27
              Caption = 'Copy to &Clipboard'
              TabOrder = 0
              OnClick = btnCopyClick
            end
            object btnEmail: TButton
              Left = 4
              Top = 86
              Width = 103
              Height = 27
              Caption = 'Compose &Email'
              TabOrder = 2
              OnClick = btnEmailClick
            end
          end
        end
      end
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 363
    Width = 584
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    FullRepaint = False
    TabOrder = 2
    OnResize = pnlButtonsResize
    object pnlButtonsCenter: TPanel
      Left = 152
      Top = 3
      Width = 289
      Height = 30
      BevelOuter = bvNone
      FullRepaint = False
      TabOrder = 0
      object btnPrev: TButton
        Left = 11
        Top = 3
        Width = 74
        Height = 25
        Action = actPrev
        TabOrder = 0
      end
      object btnNext: TButton
        Left = 94
        Top = 3
        Width = 73
        Height = 25
        Action = actNext
        Default = True
        TabOrder = 1
      end
      object btnCancel: TButton
        Left = 205
        Top = 3
        Width = 74
        Height = 25
        Cancel = True
        Caption = 'Cancel'
        TabOrder = 2
        OnClick = btnCancelClick
      end
    end
  end
  object Actions: TActionList
    Left = 475
    Top = 328
    object actPrev: TAction
      Caption = '<  &Prev'
      OnExecute = actPrevExecute
      OnUpdate = actPrevUpdate
    end
    object actNext: TAction
      Caption = '&Next  >'
      OnExecute = actNextExecute
      OnUpdate = actNextUpdate
    end
  end
  object dlgSaveReport: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Text Files (*.txt)|*.txt|All Files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 512
    Top = 328
  end
end
