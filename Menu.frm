VERSION 5.00
Begin VB.Form Menu 
   Caption         =   "MenuForm"
   ClientHeight    =   3030
   ClientLeft      =   225
   ClientTop       =   555
   ClientWidth     =   4560
   LinkTopic       =   "Form1"
   ScaleHeight     =   3030
   ScaleWidth      =   4560
   StartUpPosition =   3  '����ȱʡ
   Begin VB.Menu Optional 
      Caption         =   "ѡ��"
      Visible         =   0   'False
      Begin VB.Menu OptionalSave 
         Caption         =   "���ô��Ŀ¼"
      End
      Begin VB.Menu OtherSetting 
         Caption         =   "��������"
         Begin VB.Menu DeleteSorcSetting 
            Caption         =   "�Ƿ��滻Դ�ļ�"
            Begin VB.Menu NeedDeleteSorcSetting 
               Caption         =   "��"
            End
            Begin VB.Menu NoDeleteSorcSetting 
               Caption         =   "��"
            End
         End
         Begin VB.Menu BadSetting 
            Caption         =   "����ʧ��ʱ�Ƿ��˳�����"
            Begin VB.Menu NeedBadSetting 
               Caption         =   "��Ҫ"
            End
            Begin VB.Menu NoBadSetting 
               Caption         =   "����Ҫ"
            End
         End
         Begin VB.Menu PasswordSetting 
            Caption         =   "����������������"
            Begin VB.Menu NeedPasswordSetting 
               Caption         =   "����"
            End
            Begin VB.Menu NoPasswordSetting 
               Caption         =   "������"
            End
         End
      End
      Begin VB.Menu Nothing1 
         Caption         =   "-"
      End
      Begin VB.Menu TryToUpdate 
         Caption         =   "������"
      End
      Begin VB.Menu Nothing2 
         Caption         =   "-"
      End
      Begin VB.Menu GiveMeAdvice 
         Caption         =   "����Ʒ�����"
      End
      Begin VB.Menu ShareIt 
         Caption         =   "�������"
      End
      Begin VB.Menu About 
         Caption         =   "��������"
      End
   End
   Begin VB.Menu FileListOptional 
      Caption         =   "�ļ��б�ѡ��"
      Visible         =   0   'False
      Begin VB.Menu ClearThis 
         Caption         =   "�������"
      End
      Begin VB.Menu ClearAll 
         Caption         =   "���������"
      End
   End
End
Attribute VB_Name = "Menu"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Type BROWSEINFO
  hOwner As Long
  pidlRoot As Long
  pszDisplayName As String
  lpszTitle As String
  ulFlags As Long
  lpfn As Long
  lParam As Long
  iImage As Long
End Type

Private Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" (ByVal hwnd As Long, ByVal lpOperation As String, ByVal lpFile As String, ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long

Private Declare Function SHGetPathFromIDList Lib "shell32.dll" Alias "SHGetPathFromIDListA" (ByVal pidl As Long, ByVal pszPath As String) As Long
Private Declare Function SHBrowseForFolder Lib "shell32.dll" Alias "SHBrowseForFolderA" (lpBrowseInfo As BROWSEINFO) As Long
Private Declare Sub sapiCoTaskMemFree Lib "ole32" Alias "CoTaskMemFree" (ByVal pv As Long)
                        
Private Const BIF_RETURNONLYFSDIRS = &H1

Private Declare Function GetCurrentProcessId Lib "kernel32" () As Long

Private Const URL_UPDATE_VERSION = "http://www.ic2012.cn/software/LockerUpdateVersion.html"

Private Const URL_PRODUCE_SHARE = "http://www.ic2012.cn/thread-htm-fid-53.html"
Private Const URL_IC2012 = "http://www.ic2012.cn"

Private Const STR_STAT_DELETESORC = "�Զ��滻Ŀ���ļ�"

Private Function BrowseFolder(szDialogTitle As String, hwnd As Long) As String
  Dim x As Long, bi As BROWSEINFO, dwIList As Long
  Dim szPath As String, wPos As Integer
  
    With bi
        .hOwner = hwnd
        .lpszTitle = szDialogTitle
        .ulFlags = BIF_RETURNONLYFSDIRS
    End With
    
    dwIList = SHBrowseForFolder(bi)
    szPath = Space$(512)
    x = SHGetPathFromIDList(ByVal dwIList, ByVal szPath)
    
    If x Then
        wPos = InStr(szPath, Chr(0))
        BrowseFolder = Left$(szPath, wPos - 1)
        Call sapiCoTaskMemFree(dwIList)
    Else
        BrowseFolder = vbNullString
    End If
End Function

Private Sub About_Click()
MsgBox "��������LCatro ����,��л���ʹ��.." & vbCrLf & vbCrLf & "�ر���л:" & vbCrLf & "Yenter(�ύ©���뽨��)" & vbCrLf & "ɵX(�ύ©���뽨��)" & vbCrLf & "С���(�ύ����)", vbOKOnly, "��������"
End Sub

Private Sub ClearAll_Click()
Stat = WaitSelect
Main.SetStartButtonStyleToEnter
Main.PrintPictureOnButton Main.StartButton.Left + 1, Main.StartButton.Top + 1
Main.SelectFileAll

Main.FileList.Clear
End Sub

Private Sub ClearThis_Click()
Main.FileList.RemoveItem Main.FileList.ListIndex

If Main.FileList.ListCount = 0 Then
Stat = WaitSelect
Main.SetStartButtonStyleToEnter
Main.PrintPictureOnButton Main.StartButton.Left, Main.StartButton.Top
End If
End Sub

Sub NeedDeleteSorcSetting_Click()
Main.FilePath.Caption = STR_STAT_DELETESORC
DeleteSorc = True
NeedDeleteSorcSetting.Enabled = False
NoDeleteSorcSetting.Enabled = True
End Sub

Sub NeedBadSetting_Click()
BadExit = True
NeedBadSetting.Enabled = False
NoBadSetting.Enabled = True
End Sub

Sub NeedPasswordSetting_Click()
PasswordCanSee = True
NeedPasswordSetting.Enabled = False
NoPasswordSetting.Enabled = True
End Sub

Sub NoDeleteSorcSetting_Click()
Main.FilePath.Caption = "���Ŀ¼:" & SavePath & "\"
DeleteSorc = False
NeedDeleteSorcSetting.Enabled = True
NoDeleteSorcSetting.Enabled = False
End Sub

Sub NoBadSetting_Click()
BadExit = False
NeedBadSetting.Enabled = True
NoBadSetting.Enabled = False
End Sub

Sub NoPasswordSetting_Click()
PasswordCanSee = False
NeedPasswordSetting.Enabled = True
NoPasswordSetting.Enabled = False
End Sub

Private Sub OptionalSave_Click()
Dim rtn As String
rtn = BrowseFolder("���ô��·��", Me.hwnd)

If Not rtn = "" Then
    SavePath = rtn
    Main.FilePath.Caption = "���Ŀ¼:" & SavePath & "\"
End If
End Sub

Private Sub GiveMeAdvice_Click()
GiveAdvice.Show
End Sub

Private Sub ShareIt_Click()
ShellExecute Me.hwnd, "Open", URL_PRODUCE_SHARE, 0, 0, 0
End Sub

Sub GotoIC2012()
ShellExecute Me.hwnd, "Open", URL_IC2012, 0, 0, 0
End Sub

Sub TryToUpdate_Click()
On Error GoTo ERR:
Dim DownloadFileURL As String
If Update.CheckUpdate(URL_UPDATE_VERSION, DownloadFileURL) Then
    If (MsgBox("������Ը���,��Ҫ��?", vbYesNo + vbDefaultButton2 + vbQuestion, "���³���") = vbYes) Then
        If DownloadFileURL = "" Then
            MsgBox "�������ʧ��,ԭ��:" & vbCrLf & "��ȡ�����ļ���ַʧ��", vbCritical, , "���³���"
            Exit Sub
        End If
        
        If Update.DownLoadFile(DownloadFileURL, App.Path & "\Update.rar") Then
            MsgBox "�������ʧ��,ԭ��:" & vbCrLf & "�����ļ�ʧ��", vbCritical, , "���³���"
            Exit Sub
        End If
        RAR.RARExecute OP_EXTRACT, App.Path & "\Update.rar", App.Path
        
        Kill App.Path & "\Update.rar"
        
        If Shell(App.Path & "\HelpUpdate.exe " & App.Path & " " & App.EXEName & " " & GetCurrentProcessId, vbMinimizedNoFocus) = 0 Then MsgBox "�������ʧ��,ԭ��:" & vbCrLf & "ȱ��HelpUpdate.exe ����" & vbCrLf & "���ֶ�����,���°汾�ĳ����Ѿ����ص���ǰĿ¼(Update.exe)", vbCritical, , "���³���"
        End
    End If
Else
    MsgBox "��ǰ�������°汾", vbYes, "���³���"
End If
Exit Sub

ERR:
MsgBox "����ʧ��", vbCritical, "���³���"
End Sub
