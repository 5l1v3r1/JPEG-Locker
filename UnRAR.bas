Attribute VB_Name = "RAR"
Option Explicit
'
'
'******************************************************************
'ģ����;��
'   ��ѹ RAR ��ʽ��ѹ������
'
'
'******************************************************************
'ע��
'   1. Ҫʹ�ñ�ģ�飬���븽�� UnRAR.dll �ļ�����ǰ�汾Ϊ��3.90.100.227
'   2. ��ģ��ı��� WinRAR �ٷ����ص� UnRARDLL.exe ѹ��������������е� VBasic Sample 1��
'       �� UnRARDLL.rar ���� http://www.rarlab.com/rar_add.htm ������ UnRAR.dll (UnRAR dynamic library for Windows software developers.)
'       ֱ���������ӣ�http://www.rarlab.com/rar/UnRARDLL.exe    (�� 2009-10-20 ������Ч)
'   3. ���� UnRAR.dll �ĵ����������壬
'           �������и�����ϸ������˵����������Unicode�汾�ĵ���������http://baike.baidu.com/view/697654.htm��
'           �����İ汾˵������ϸ��ԭ���Ӣ��˵������ UnRARDLL.exe ѹ�����е� unrardll.txt �ļ���
'
'
'******************************************************************
'�÷�ʾ����
'    'Ҫ�Ѿ������ܵ�RAR�� C:\ѹ������.rar �ļ���ѹ�� C:\Temp Ŀ¼�£�������123456
'    lngResult = RARExecute(OP_EXTRACT, "C:\ѹ������.rar", "C:\Temp\", "123456")
'    If lngResult = 0 Then
'        MsgBox "��ѹ�ɹ�"
'    Else
'        MsgBox "��ѹʧ�ܣ����صĴ��������[" & lngResult & "]"
'    End If
'
'�÷�����˵����
'   Mode        - ����ģʽ����OP_EXTRACT = ��ѹ��OP_TEST = ���ԣ�OP_LIST = �鿴��
'   RarFile     - RAR�ļ���
'   SaveTo      - ��ѹĿ¼��Ϊ�ձ�ʾ�ڵ�ǰĿ¼��ѹ��
'   Password    - ����
'
'******************************************************************
'�޸�����Ϣ��
'   �޸��ߣ�ZhongWei
'   QQ��1124091881
'   Email��1124091881@qq.com
'   �޸�ʱ�䣺2009-10-21
'
'******************************************************************
'   �˴�Ϊ�ٷ� UnRARDLL.exe ѹ�����е� VBasic Sample 1 ��������Ϣ��
'
'   Ported to Visual Basic by Pedro Lamas
'
'E-mail:  sniper@hotpop.com
'HomePage (dedicated to VB):  www.terravista.pt/portosanto/3723/
'
'******************************************************************

'--------------------------------------------------------------------------------------------
'       ��������
'--------------------------------------------------------------------------------------------

Const ERAR_END_ARCHIVE = 10
Const ERAR_NO_MEMORY = 11           '�ڴ治�㡣
Const ERAR_BAD_DATA = 12            '���ݴ��󣬿�����ѹ�����ļ�ͷ��ʧ�������ļ�CRCУ�����
Const ERAR_BAD_ARCHIVE = 13         '�����
Const ERAR_UNKNOWN_FORMAT = 14      'δ֪��ѹ������ʽ��
Const ERAR_EOPEN = 15               '�򿪾�ʧ�ܡ�
Const ERAR_ECREATE = 16             '�����ļ�ʧ�ܡ�
Const ERAR_ECLOSE = 17              '�ر��ļ�ʧ�ܡ�
Const ERAR_EREAD = 18               '������
Const ERAR_EWRITE = 19              'д����
Const ERAR_SMALL_BUF = 20           '��������С��
 
Const RAR_OM_LIST = 0       '�鿴������������ RAROpenArchiveData �ṹ��ֻΪ��ȡ�ļ�ͷ����ѹ������
Const RAR_OM_EXTRACT = 1    '��ѹ������������ RAROpenArchiveData �ṹ��Ϊ�����߽�ѹ������ѹ������
 
Const RAR_SKIP = 0      '������������ RARProcessFile �� Operation ������
Const RAR_TEST = 1      '���ԣ������� RARProcessFile �� Operation ������
Const RAR_EXTRACT = 2   '��ѹ�������� RARProcessFile �� Operation ������
 
Const RAR_VOL_ASK = 0
Const RAR_VOL_NOTIFY = 1

Enum RarOperations
    OP_EXTRACT = 0      '��ѹ
    OP_TEST = 1         '����
    OP_LIST = 2         '�鿴
End Enum
 
' Flags ��־��ȡֵ��
'        0x01 - file continued from previous volume ǰ����ļ�����
'        0x02 - file continued on next volume ��һ�����и��ļ��Ĳ���
'        0x04 - file encrypted with password �ļ��Ѽ���
'        0x08 - file comment present �ļ�����ע��
'        0x10 - compression of previous files is used (solid flag) ���ļ�ѹ��ͬǰ����ļ��йأ���ʵ��־��
'                  Bits   7 6 5
'                         0 0 0 - Ŀ¼��СΪ 64 Kb
'                         0 0 1 - Ŀ¼��СΪ 128 Kb
'                         0 1 0 - Ŀ¼��СΪ 256 Kb
'                         0 1 1 - Ŀ¼��СΪ 512 Kb
'                         1 0 0 - Ŀ¼��СΪ 1024 Kb
'                         1 0 1 - Ŀ¼��СΪ 2048 KB
'                         1 1 0 - Ŀ¼��СΪ 4096 KB
'                         1 1 1 - �ļ�����Ŀ¼
'                         �����ֽڱ���

Private Type RARHeaderData
    ArcName As String * 260     '���ѹ���ļ�������0�������ַ����� Ҳ�����ǵ�ǰ�����ơ�
    FileName As String * 260    'Ŀ¼�������ļ���������ѹ�����ڵ�·������0�������ַ�������OEM (DOS)���뷽ʽ������
    Flags As Long               '����ļ���־��
    PackSize As Long            '���ѹ���ļ��ķְ���С�����ļ��и��С��
    UnpSize As Long             '��ѹ����ļ���С��
    HostOS As Long              'ѹ���ļ�����������ϵͳ��0 - MS DOS��1 - OS/2��2 - Win32��3 - Unix��
    FileCRC As Long             'ѹ��֮ǰ�ļ���CRCֵ������ļ����ָ��ͬ�ľ��У��������ھ��и�������������λ���˼������˵������㽫һ���ļ�ѹ����������У�ÿ���־�������Ų����ļ���CRC���������и�һ���ļ���������Ȼ�����еļ�������������Ŀ¼��ʹ��WinRar�򿪣���������CRCֵ��ͬ�������ѹ��֮ǰ�ļ���CRCֵ������ļ����ָ��ͬ�ľ��У��������ھ��и�������������λ���˼������˵������㽫һ���ļ�ѹ����������У�ÿ���־�������Ų����ļ���CRC���������и�һ���ļ���������Ȼ�����еļ�������������Ŀ¼��ʹ��WinRar�򿪣���������CRCֵ��ͬ����
    FileTime As Long            '����MS DOS��ʽ��������ں�ʱ�䡣
    UnpVer As Long              '��ѹ��Ҫ��Rar�汾������10 * Major version + minor version��ʽ������
    Method As Long              'ѹ����ʽ��
    FileAttr As Long            '�ļ����ԡ�
    CmtBuf As String            '�ļ�ע�ͻ�������(��˵)��������汾��Dll��û��ʵ�֣�CmtState ʼ��Ϊ0��
    CmtBufSize As Long          'ע�͵Ļ�������С������ע�ͳ���Ϊ64KB��
    CmtSize As Long             '��ȡ����������ʵ��ע�ʹ�С�����ܳ���CmtBufSize��
    CmtState As Long            'ע��״̬���� RAROpenArchiveData �ṹ��˵����
End Type

Private Type RAROpenArchiveData
    ArcName As String           'ѹ�����ļ�����ȫ·������'\0'��Ϊ��β���ַ�����
    OpenMode As Long            '�������ͣ����� RAR_OM_LIST ����  RAR_OM_EXTRACT ������
    OpenResult As Long          '���ļ��Ľ�������ص��Ǵ�����롣0 - �򿪳ɹ����޴���
    CmtBuf As String            'ָ��һ���������ע�͵Ļ�����������ע�ͳ���Ϊ64KB��ע������0��β���ַ��������ע���ı��ĳ��ȳ�����������С��ע���ı������ضϡ���� CmtBuf Ϊ null���������ȡע�͡�
    CmtBufSize As Long          'ע�͵Ļ�������С��
    CmtSize As Long             '��ȡ����������ʵ��ע�ʹ�С�����ܳ���CmtBufSize��
    CmtState As Long            'ע��״̬��1-��ע�͡�ERAR_NO_MEMORY - �ڴ治�㣬�޷��ͷ�ע�͡�ERAR_BAD_DATA - ע���𻵡�ERAR_UNKNOWN_FORMAT - ע�͸�ʽ��Ч��ERAR_SMALL_BUF - ��������С���޷���ȡȫ��ע�͡�
End Type


'--------------------------------------------------------------------------------------------
'       API ����
'--------------------------------------------------------------------------------------------

'-----------------------
'���ã�
'   ��Rar�ļ���Ϊʹ�õĽṹ�����ռ�
'������
'   ArchiveData     - ָ�� RAROpenArchiveData ����ṹ�塣
'����ֵ��
'   ����ѹ�����ļ��� handle ,����ʱ���� null
Private Declare Function RAROpenArchive Lib "unrar.dll" (ByRef ArchiveData As RAROpenArchiveData) As Long

'-----------------------
'���ã�
'   �رմ򿪵�ѹ�������ͷŷ�����ڴ档ֻ�е�����ѹ���ļ��Ĺ��̽�����ſ��Ե���������̣��������ѹ���ļ��Ĺ���ֻ��ֹͣ��ʹ��������̽����������
'������
'   hArcData     - ���������Ŵ� RAROpenArchive ������õ�ѹ�����ļ��ľ����
'����ֵ��
'   0           - �ɹ���
'   ERAR_ECLOSE - �ر�ѹ���ļ�ʱ��������
Private Declare Function RARCloseArchive Lib "unrar.dll" (ByVal hArcData As Long) As Long

'-----------------------
'���ã�
'   ��ȡѹ������ͷ����
'������
'   hArcData    - ���������Ŵ� RAROpenArchive ������õ�ѹ�����ļ��ľ����
'   HeaderData  - ָ�� RARHeaderData �ṹ��
'����ֵ��
'   0                   - �ɹ���
'   ERAR_END_ARCHIVE    - �ĵ�������End of archive
'   ERAR_BAD_DATA       - �ļ�ͷ�𻵡�File header broken
Private Declare Function RARReadHeader Lib "unrar.dll" (ByVal hArcData As Long, ByRef HeaderData As RARHeaderData) As Long

'-----------------------
'���ã�
'   ִ�ж�����Ȼ��ָ����һ���ļ���
'   ִ��ʱ��������� RAR_OM_EXTRACT ȷ���ͷŻ��ǲ��Ե�ǰ�ļ���
'   ��������� RAR_OM_LIST ����ģʽ����ô�����������������Ե�ǰ�ļ�ֱ��ָ����һ���ļ���
'������
'   hArcData    - ���������Ŵ� RAROpenArchive ������õ�ѹ�����ļ��ľ����
'   Operation   - �ļ������������µ�ѡ��
'                ����RAR_SKIP     - ָ��ѹ�����е���һ���ļ������ѹ�����ǹ̶��� ����RAR_OM_EXTRACT �Ѿ����ã���ô�ᴦ��ǰ�ļ� ---�����ȼ򵥵Ĳ���Ҫ����
'                ����RAR_TEST     - ��⵱ǰ�ļ���Ȼ���ƶ���ѹ�����е���һ���ļ������ RAR_OM_LIST �Ѿ������˴�ģʽ����ô����ͬRAR_SKIPһ��?
'                ����RAR_EXTRACT  - ��ѹ��ǰ�ļ���Ȼ��ָ����һ���ļ������
'                ����RAR_OM_LIST  - �Ѿ������˴�ģʽ����ô����ͬRAR_SKIPһ����
'   DestPath    - ��ѹ�ļ���Ŀ¼������һ����0��β���ַ�������� DestPath Ϊ null����ʾ��ѹ����ǰĿ¼�¡�ֻ�� DestName Ϊnullʱ����������������塣
'   DestName    - ָ��һ����������·�������Ƶ���0��β���ַ�����Ĭ��Ϊnull����� DestName �ж��壨Ҳ���ǲ��� Null�������������滻ѹ�����е�ԭʼ�ļ�����·����
'����ֵ��
'    0                      - �ɹ���
'    ERAR_BAD_DATA          - �ļ�CRC����
'    ERAR_BAD_ARCHIVE       - ������Ч��Rar�ļ�
'    ERAR_UNKNOWN_FORMAT    - δ֪�ĸ�ʽ
'    ERAR_EOPEN             - ��򿪴���
'    ERAR_ECREATE           - �ļ���������
'    ERAR_ECLOSE            - �ļ��رմ���
'    ERAR_EREAD             - ��ȡ����
'    ERAR_EWRITE            - д�����
'ע�⣺
'   �����ϣ�������⵱ǰ�Ľ�ѹ�����������ڴ��� UCM_PROCESSDATA �ص�����������-1��
Private Declare Function RARProcessFile Lib "unrar.dll" (ByVal hArcData As Long, ByVal Operation As Long, ByVal DestPath As String, ByVal DestName As String) As Long

'-----------------------
'���ã�
'   ��δ���ܵ�ѹ����������һ�����롣
'������
'   hArcData    - ���������Ŵ� RAROpenArchive ������õ�ѹ�����ļ��ľ����
'   Password    - �����ַ������� vbNull Ϊ��β��
Private Declare Sub RARSetPassword Lib "unrar.dll" (ByVal hArcData As Long, ByVal Password As String)

'-----------------------
'���ã�
'   ���Ժ�����ʹ�� RARSetCallback �����滻��
'   RARSetCallback ������һ���ص����������� http://baike.baidu.com/view/697654.htm ��˵����
Private Declare Sub RARSetChangeVolProc Lib "unrar.dll" (ByVal hArcData As Long, ByVal Mode As Long)

'-----------------------
'���ã�
'   ���� API �汾��
'ע�⣺
'    ���ص�ǰUnRar.DLL��API�İ汾���� unrar.h ���� RAR_DLL_VERSION ���塣ֻ�е� UnRar.DLL�е�API����ʱ���Ż���߰汾�š���Ҫ������汾ͬUnRar.Dll�ı���汾Ū�죬����汾��ÿһ�α����ʱ�򶼻�仯��
'    ��� RARGetDllVersion() ����ֵ�����������Ҫ�İ汾���ͱ�ʾ��ʹ�õ�DLL�汾̫�͡�
'    ���ϵ�Unrar.dll��û���ṩ������ܣ����������ʹ��ʱҪ����LoadLibrary �� GetProcAddress ���һ���Ƿ���������ܡ�
'Private Declare Sub RARGetDllVersion Lib "unrar.dll" ()



'--------------------------------------------------------------------------------------------
'       ���� ����
'--------------------------------------------------------------------------------------------

' ���ã�
'   ��RAR�ļ��н�ѹ�ļ���
' ������
'   Mode        = �� RAR �ĵ��Ĳ�������
'   RARFile     = RAR �ļ���
'   SaveTo      = ��ѹ��ı���λ�á�
'   sPassword   = ��ѹ���� (��ѡ)
' ����ֵ��
'   0   - ������ɣ��޴���
'   111 - ���ļ������ڴ治�㡣(ERAR_NO_MEMORY)
'   112 - ���ļ�����ѹ�����ļ�ͷ��ʧ��(ERAR_BAD_DATA)
'   113 - ���ļ����󣬲���һ����Ч��RARѹ������(ERAR_BAD_ARCHIVE)
'   115 - ���ļ������޷����ļ���(ERAR_EOPEN)
'   212 - ���������г���CRCУ�����(ERAR_BAD_DATA)
'   213 - ���������г��������(ERAR_BAD_ARCHIVE)
'   214 - ���������г���δ֪��ѹ������ʽ��(ERAR_UNKNOWN_FORMAT)
'   215 - ���������г����򿪾�ʧ�ܡ�(ERAR_EOPEN)
'   216 - ���������г��������ļ�ʧ�ܡ�(ERAR_ECREATE)
'   217 - ���������г����ļ��ر�ʧ�ܡ�(ERAR_ECLOSE)
'   218 - ���������г���������(ERAR_EREAD)
'   219 - ���������г���д����(ERAR_EWRITE)
Public Function RARExecute(ByVal Mode As RarOperations, ByVal RarFile As String, ByVal SaveTo As String, Optional Password As String) As Long
    Dim lHandle As Long
    Dim iStatus As Integer
    Dim uRAR As RAROpenArchiveData
    Dim uHeader As RARHeaderData
    Dim sStat As String, Ret As Long
     
    uRAR.ArcName = RarFile
    uRAR.CmtBuf = Space(16384)      '��ʼ��ע�͵Ļ�����
    uRAR.CmtBufSize = 16384
    
    '���ò�������
    If Mode = OP_LIST Then
        uRAR.OpenMode = RAR_OM_LIST
    Else
        uRAR.OpenMode = RAR_OM_EXTRACT
    End If
    
    '��ѹ����
    lHandle = RAROpenArchive(uRAR)
    If uRAR.OpenResult <> 0 Then        '��RAR�ļ�ʧ��
        '�����uRAR.OpenResult ���صĿ��������µļ�������
        '   11     - ���ļ������ڴ治�㡣(ERAR_NO_MEMORY)
        '   12     - ���ļ�����ѹ�����ļ�ͷ��ʧ��(ERAR_BAD_DATA)
        '   13     - ���ļ����󣬲���һ����Ч��RARѹ������(ERAR_BAD_ARCHIVE)
        '   15     - ���ļ������޷����ļ���(ERAR_EOPEN)
        RARExecute = 100 + uRAR.OpenResult
        Exit Function
    End If
 
    If Password <> "" Then RARSetPassword lHandle, Password     '��Ϊ�յ�ʱ������RAR�����롣
    
    '��ע�ʹ�������ʾRARע��
    'If (uRAR.CmtState = 1) Then MsgBox uRAR.CmtBuf, vbApplicationModal + vbInformation, "ע��"
    
    'ѭ����ʾѹ�����ڵ�ÿ���ļ���
    iStatus = 0       '������ֵ���Ա����ѭ��
    Do Until iStatus <> 0
        '����ѹ�����ڵ��ļ�ͷ
        iStatus = RARReadHeader(lHandle, uHeader)
        
        If iStatus = ERAR_BAD_DATA Then     '��ȡ�ļ�ͷ����
            RARExecute = 212
            Exit Function
        End If
        
        sStat = Left(uHeader.FileName, InStr(1, uHeader.FileName, vbNullChar) - 1)  'ѹ�����е�ÿһ�������(Ŀ¼�����ļ���������·��)
        
        '���ݲ�ͬ�Ĳ�����ʽ�����ļ����д���
        Select Case Mode
            Case RarOperations.OP_EXTRACT
                'Ret = RARProcessFile(lHandle, RAR_EXTRACT, "", uHeader.FileName)
                Ret = RARProcessFile(lHandle, RAR_EXTRACT, SaveTo, "")
            Case RarOperations.OP_TEST
                Ret = RARProcessFile(lHandle, RAR_TEST, "", uHeader.FileName)
            Case RarOperations.OP_LIST
                Ret = RARProcessFile(lHandle, RAR_SKIP, "", "")
        End Select
        
        If Ret > 0 Then
            '����ʧ�ܡ������Ret ���صĿ��������µļ�������
            '   12 - CRCУ�����(ERAR_BAD_DATA)
            '   13 - �����(ERAR_BAD_ARCHIVE)
            '   14 - δ֪��ѹ������ʽ��(ERAR_UNKNOWN_FORMAT)
            '   15 - �򿪾�ʧ�ܡ�(ERAR_EOPEN)
            '   16 - �����ļ�ʧ�ܡ�(ERAR_ECREATE)
            '   17 - �ļ��ر�ʧ�ܡ�(ERAR_ECLOSE)
            '   18 - ������(ERAR_EREAD)
            '   19 - д����(ERAR_EWRITE)
            RARExecute = 200 + Ret
            Exit Function
        End If
        
        'iStatus = RARReadHeader(lHandle, uHeader)   '������һ���ļ����ļ�ͷ
        'Refresh        '�����ڽ�����ˢ����ʾ
    Loop
    
    '�ر�ѹ�������
    RARCloseArchive lHandle
    
    RARExecute = 0
End Function

