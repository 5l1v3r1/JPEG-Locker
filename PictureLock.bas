Attribute VB_Name = "PictureLock"

Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)

Private Const RND_RANGE = 256  ''  ��������ɷ�Χ

Private Const LEN_ALLOWDATA = 256  ''  �ṹͷƫ�����ݳ��ȷ�Χ

Private Const LEN_LONG = 4  ''  Long �ṹ����

Private Enum RANK  ''  ���з�ʽ
No = 0
Yes
End Enum

Private Enum FLAG_LOCK_V1_0  ''  ��д�㶮�� 1.0 �汾����
FLAGRANK = 4                 ''  �ĸ��������־
FLAG1 = &HFFFF0208           ''  ����־
FLAG2 = &H6F852D0E
FLAG3 = &HC7522AD0
FLAG4 = &H291A6EF5
End Enum

Private Function GetLockFlag(ByVal Index As Long) As Long  ''  ��������ȡ����־
Select Case Index
    Case 1:
        GetLockFlag = FLAG_LOCK_V1_0.FLAG1
    Case 2:
        GetLockFlag = FLAG_LOCK_V1_0.FLAG2
    Case 3:
        GetLockFlag = FLAG_LOCK_V1_0.FLAG3
    Case 4:
        GetLockFlag = FLAG_LOCK_V1_0.FLAG4
    Case Else
        GetLockFlag = FLAG_LOCK_V1_0.FLAG1
End Select
End Function

Private Function ChackLockFlag(ByVal Number As Long) As Boolean  ''  �ж�����־
Select Case Number
    Case FLAG_LOCK_V1_0.FLAG1:
        ChackLockFlag = True
    Case FLAG_LOCK_V1_0.FLAG2:
        ChackLockFlag = True
    Case FLAG_LOCK_V1_0.FLAG3:
        ChackLockFlag = True
    Case FLAG_LOCK_V1_0.FLAG4:
        ChackLockFlag = True
    Case Else
        ChackLockFlag = False
End Select
End Function

Private Function CreateRnd(ByVal Range As Long) As Long  ''  ����һ�������(����ȡֵ��Χ,����[0,Range) [Ҳ�п���ȡ��Range ])
Randomize
CreateRnd = CLng(Range * Rnd)  ''  ע��VB ����������ȡֵ��
End Function

Private Function CreateString(ByVal StringLength As Long) As String  ''  ����һ������ַ���(�����ַ�����)
Dim rtn As String
For I = 1 To StringLength
    rtn = rtn & Chr(CreateRnd(RND_RANGE))
Next

CreateString = rtn
End Function

Private Function CreateLockFlag() As Long  ''  �����������־
CreateLockFlag = GetLockFlag(CreateRnd(FLAG_LOCK_V1_0.FLAGRANK) + 1)
End Function

Private Function GetString(ByVal Str As String, ByVal Point As Long) As String  ''  ��ȡ�ַ�����ĳ��λ�õķ���
If Point = 0 Or Point > Len(Str) Then Exit Function

GetString = Mid(Left(Str, Point), Point)
End Function

Private Sub StringToByte(ByVal InString As String, ByVal LenString As Long, InByte() As Byte)  ''  String ���ݱ���תByte
For I = 1 To LenString
InByte(I - 1) = CByte(Asc(GetString(InString, I)))
Next
End Sub

Function IsLockFile(ByVal FilePath As String) As Boolean  ''  �ж��ļ��Ƿ��Ѿ�������
Dim Data(LEN_LONG - 1) As Byte

Open FilePath For Binary As #1
Get #1, , Data
Close

Dim Number As String
Open FilePath For Binary As #1
Get #1, , Data
Close
Number = Hex(Data(3))
Number = Number & IIf(Data(2) <= &HF, "0" & Hex(Data(2)), Hex(Data(2)))
Number = Number & IIf(Data(1) <= &HF, "0" & Hex(Data(1)), Hex(Data(1)))
Number = Number & IIf(Data(0) <= &HF, "0" & Hex(Data(0)), Hex(Data(0)))

IsLockFile = ChackLockFlag(Val("&H" & Number))
End Function

''LockPicture FILE_PATH_OPEN, FILE_PATH_SAVE, FILE_NUM

Sub LockPicture(ByVal FilePathOpen As String, ByVal FilePathSave As String, ByVal LockString As String)  ''  ����ͼƬ
If IsLockFile(FilePathOpen) = True Then Exit Sub  ''  �����Ѿ������˵�ͼƬ�������˳�,��ֹ���˵���

Dim Data() As Byte  ''  ԴͼƬ�ļ�����
Dim Exchange() As Byte  ''  ���ܺ��ͼƬ����
Dim SorcFileLength As Long  ''  ԴͼƬ�ļ�����

Dim LockFlag As Long  ''  ����־
Dim DataPoint As Long  ''  ƫ������ָ��
Dim AllocData As String  ''  �������
Dim PasswordLength As Long  ''  ���볤��
Dim Password As String  ''  ����
Dim RankNum As RANK  ''  ���з�ʽ
LockFlag = CreateLockFlag()
DataPoint = CreateRnd(LEN_ALLOWDATA)  ''  �������������ݳ���
AllocData = CreateString(DataPoint)  ''  �����������
Password = Base64Encode(LockString)  ''  ��������
PasswordLength = Len(Password)  ''  ��ȡ���ܺ�����볤��
RankNum = Yes  ''  ѡ������

Dim AllocPasswordBlockSize As Long
AllocPasswordBlockSize = LEN_LONG * 4 + DataPoint + PasswordLength  ''  ���������Ĵ�С(������Long �����ݺ�������ݺ���������)

Open FilePathOpen For Binary As #1  ''  ��ȡԴͼƬ����
    SorcFileLength = FileLen(FilePathOpen)  ''  ��ȡԴͼƬ��С
    ReDim Data(SorcFileLength - 1)  ''  ���ض�������ʱ,����VB ��������һλ���Բ���NULL ��ֹ�ַ���,���Կ��Ը���Դ�ļ����ȼ�һʹData ��������ݳ���..
    Get #1, , Data  ''  ��ȡ����
Close

ReDim Exchange(AllocPasswordBlockSize + SorcFileLength - 1)  ''  ���ܺ�����ݳ��Ȱ�����������ԴͼƬ����

CopyMemory Exchange(0), LockFlag, LEN_LONG  ''  ��������
CopyMemory Exchange(LEN_LONG), DataPoint, LEN_LONG
CopyMemory Exchange(LEN_LONG * 2), AllocData, DataPoint
CopyMemory Exchange(LEN_LONG * 2 + DataPoint), PasswordLength, LEN_LONG
For I = LEN_LONG * 3 + DataPoint To LEN_LONG * 3 + DataPoint + PasswordLength - 1  ''  д���뵽�������[��֪��Ϊʲô����ʹ��CopyMemory ,�����ָ��] -- LCatro  2013.8.23
    Exchange(I) = Asc(GetString(Password, I - (LEN_LONG * 3 + DataPoint) + 1))
Next
CopyMemory Exchange(LEN_LONG * 3 + DataPoint + PasswordLength), RankNum, LEN_LONG

Dim DataCache() As Byte
Dim DataCacheLen As Long
Encode Data, SorcFileLength, DataCache, DataCacheLen  ''  ��������
ReDim Preserve Exchange(DataCacheLen + AllocPasswordBlockSize - 1)  ''  �������ý������ݻ����С(����ԭ����)

CopyMemory Exchange(AllocPasswordBlockSize), DataCache(0), DataCacheLen     ''  ��ԴͼƬ���ݸ��Ƶ������ļ�����

Open FilePathSave For Binary As #1  ''  д����
    Put #1, , Exchange
Close
End Sub

''UnlockPicture FILE_PATH_SAVE, FILE_PATH_SAVETEST

Function UnlockPicture(ByVal FilePathOpen As String, ByVal FilePathSave As String, ByVal UnlockString As String) As Boolean
If IsLockFile(FilePathOpen) = False Then
    UnlockPicture = False
    Exit Function
End If

Dim Data() As Byte
Dim Exchange() As Byte
Dim SorcFileLength As Long
Dim DataPoint As Long
Dim AllocData As String
Dim PasswordLength As Long
Dim Password As String
Dim RankNum As RANK

Open FilePathOpen For Binary As #1
    SorcFileLength = FileLen(FilePathOpen)
    ReDim Data(SorcFileLength - 1)
    Get #1, , Data
Close

CopyMemory DataPoint, Data(LEN_LONG), LEN_LONG  ''  ��ȡ������ݳ���
CopyMemory PasswordLength, Data(LEN_LONG * 2 + DataPoint), LEN_LONG ''  ��ȡ���볤��

For I = 0 To PasswordLength - 1  ''  �����ȡ
    Password = Password & Chr(Data(LEN_LONG * 3 + DataPoint + I))
Next
Password = Base64.Base64Decode(Password)  ''  �������

CopyMemory RankNum, Data(LEN_LONG * 3 + DataPoint + PasswordLength), LEN_LONG  ''  ��ȡ���з�ʽ

If Not UnlockString = Password Then  ''  ����Ա�
    UnlockPicture = False
    Exit Function
End If

Dim AllocPasswordBlockSize As Long
AllocPasswordBlockSize = LEN_LONG * 4 + DataPoint + PasswordLength

ReDim Exchange(SorcFileLength - AllocPasswordBlockSize - 1)

CopyMemory Exchange(0), Data(AllocPasswordBlockSize), SorcFileLength - AllocPasswordBlockSize

Dim DataCache() As Byte
Dim DataCacheLen As Long
Decode Exchange, SorcFileLength - AllocPasswordBlockSize, DataCache, DataCacheLen
ReDim Exchange(DataCacheLen - 1)

CopyMemory Exchange(0), DataCache(0), DataCacheLen  ''  ��ԴͼƬ���ݸ��Ƶ������ļ�����

Open FilePathSave For Binary As #1
    Put #1, , Exchange
Close

UnlockPicture = True
End Function
