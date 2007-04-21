object fmFavNewFolder: TfmFavNewFolder
  Left = 266
  Top = 185
  BorderStyle = bsDialog
  Caption = 'New Folder'
  ClientHeight = 127
  ClientWidth = 293
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object gbxNewFolder: TGroupBox
    Left = 8
    Top = 8
    Width = 277
    Height = 81
    Caption = ' New Folder '
    TabOrder = 0
    object lblFolderName: TLabel
      Left = 23
      Top = 24
      Width = 58
      Height = 13
      Alignment = taRightJustify
      Caption = 'Folder &name'
      FocusControl = edtFolderName
    end
    object lblFolderType: TLabel
      Left = 29
      Top = 50
      Width = 52
      Height = 13
      Alignment = taRightJustify
      Caption = 'Folder &type'
      FocusControl = cbxFolderType
    end
    object edtFolderName: TEdit
      Left = 90
      Top = 20
      Width = 176
      Height = 21
      TabOrder = 0
      OnChange = edtFolderNameChange
    end
    object cbxFolderType: TComboBox
      Left = 90
      Top = 44
      Width = 176
      Height = 26
      Style = csOwnerDrawVariable
      ItemHeight = 20
      TabOrder = 1
      OnDrawItem = cbxFolderTypeDrawItem
      OnMeasureItem = cbxFolderTypeMeasureItem
    end
  end
  object btnCancel: TButton
    Left = 210
    Top = 96
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnOK: TButton
    Left = 130
    Top = 96
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 1
  end
end
