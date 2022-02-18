;**************************
;*  uVNC Remote Control   *
;*          By            *
;*     OldNESJunkie       *
;*      07/03/2015        *
;*  Updated 2/18/2022     *
;**************************

;  *******************
;  * Embed Help Text *
;{ *******************
DataSection
  p_helptext:
  IncludeBinary ("includes\VNCHelp.txt")
  Data.l 0
EndDataSection
;}

;  *********************
;  * Define Prototypes *
;{ *********************
Prototype ProcessFirst(Snapshot, Process)
Prototype ProcessNext(Snapshot, Process)
;}

;  *********************
;  * Define Structures *
;{ *********************
Structure VNCList
 VNCHostName.s
 VNCDescription.s
 VNCPID.i
 VNCSelection.i
EndStructure
;}

;  ***************************
;  * Create global variables *
;{ ***************************
Global flip1, flip2, flip3, flip4, flip5, flip6, flip7, flip8, flip9, flip10
Global flip11, flip12, flip13, flip14, flip15, flip16, flip17, flip18, flip19
Global flip20, flip21, flip22, flip23, flip24, flip25, flip26, flip27, flip28
Global flip29, flip30, flip31, flip32, flip33
Global lastx, lasty, logme
Global myhostname.s, pcname.s, mydescription.s
Global totalItemsSelected
Global is.LVHITTESTINFO
Global Ping_Port = IcmpCreateFile_()
Global myname.s=GetEnvironmentVariable("username")
Global PasswordHash.s, connectsuccess.i
Global p_myhelptext.i = ?p_helptext
Global selection, myid.l, myprog.l
Global ProcessFirst.ProcessFirst
Global ProcessNext.ProcessNext
Global NewList MyVNCList.VNCList()
;}

;  ******************************
;  * Include external libraries *
;{ ******************************
XIncludeFile "Includes\Listicon.pb"
;}

;  **************************************
;  * Enumerate all windows and controls *
;{ **************************************
Enumeration
;Window
#Window_0
;App Panel
#Panel_1
;Disconnect Options
#Options_1
;Gadgets
#Hosts_List
#PC_Blank
#PC_Connected
#Text_HostName
#String_HostName
#Text_Description
#String_Description
#Connect_Button
#Text_Search
#String_Search
#StatusBar0
;Server Options Panel
#Frame_1
#Frame_2
#Server_CaptureSemiTransparentWindows
#Server_DisableAero
#Server_DisableScreensaver
#Server_DisableTrayIcon
#Server_DisconnectNothing
#Server_DisconnectLock
#Server_DisconnectLogoff
#Server_EnableDriver
#Server_EnableFileTransfers
#Server_IdleTimeout
#Server_MaxCPU
#String_MaxCPU
#Server_MultiMonitorSupport
#Server_OnlyPollOnEvent
#Server_RDPMode
#Server_RemoveWallpaper
;Viewer Options Panel
#Frame_3
#Viewer_256Colors
#Viewer_AutoScale ;Scale viewer to match remote screen
#Viewer_ConfirmExit
#Viewer_DisableClipboard
#Viewer_DisableRemoteInput
#Viewer_Fullscreen
#Viewer_PromptUser
#Viewer_ShowToolbar ;Show VNC Toolbar on connect
#Viewer_StatusWindow
#Viewer_StretchScreen
#Viewer_ViewOnly
;App Options Panel
#Frame_4
#App_ClearHostsList
#App_EnableScrollLock
#App_ImportFromAD
#App_LogConnects
#App_LastConnect
#App_RemoveFilesOnExit
#App_SaveWindowPosition
#App_SortHostsOnExit
#App_Help
#App_Update
;About Panel
#Frame_5
#Editor_0
#Weblink_1
#Weblink_2
#Weblink_3
#Weblink_4
;Pop-Up Menu
#Menu_PopUp
#PopUp_Disconnect
#PopUp_EditDescription
#PopUp_RemoveHost
;Enter Shortcut
#Menu_EnterKey
#Edit
#Quit
#Recycle
EndEnumeration
;}

;  **************
;  * Procedures *
;{ **************

;{ Procedure declarations
Declare BalloonTip(iWindowID.i, iGadget.i, sTip.s , sTitle.s, iIcon.i)
Declare CheckForUpdate()
Declare CheckRunningProcesses()
Declare ClearHosts()
Declare ConnectHostButton()
Declare ConnectHostMouse()
Declare CreateConnection(hostname.s)
Declare CreateLocalFiles()
Declare.s CreatePassword()
Declare CreateServerINIFile(dir.s)
Declare.i CreateViewerConfigFile(hostname.s)
Declare DisconnectFromPC()
Declare EditMyDescription(Title$)
Declare.l FileOp(FromLoc.s, ToLoc.s, Flag)
Declare FindPartWin(part$)
Declare.i FindStringRev(String$, StringToFind$, UseCase.i=#PB_String_NoCase)
Declare.s GetIPAddress(host.s)
Declare.s GetOSType(hostname.s)
Declare.s GetPidProcessEx(Name.s)
Declare.s IdleTimeout(Title$)
Declare ImportAD()
Declare IsMouseOver(hWnd)
Declare.q lngNewAddress(strAdd.s)
Declare Match(FirstString.s,SecondString.s,Type.b,CaseSensitive.b)
Declare PingHost(Address.s,PING_TIMEOUT=1000,strMessage.s = "Echo This Information Back To Me")
Declare RefreshList()
Declare RemoveHost()
Declare RemoveService(hostname.s)
Declare SaveFile()
Declare SearchMe(search.s)
Declare SetColumnWidths()
Declare SetIcons()
Declare SortFile(file.s)
Declare WriteLog(filename.s, error.s)
Declare x_littlehelp(title.s,text.s,pointer.i=0,flags.i=-1)
Declare.s x_peeks(addr.i,length.i=-1,flags.i=-1,terminator.s="")
;}

Procedure BalloonTip(iWindowID.i, iGadget.i, sTip.s , sTitle.s, iIcon.i)
    iToolTip = CreateWindowEx_(0, "ToolTips_Class32", "", #WS_POPUP | #TTS_NOPREFIX | #TTS_BALLOON, 0, 0, 0, 0, iWindowID, 0, GetModuleHandle_(0), 0)
    SendMessage_(iToolTip, #TTM_SETDELAYTIME, #TTDT_AUTOPOP, 30000)
    SendMessage_(iToolTip, #TTM_SETTIPTEXTCOLOR, GetSysColor_(#COLOR_INFOTEXT), 0)
    SendMessage_(iToolTip, #TTM_SETTIPBKCOLOR, GetSysColor_(#COLOR_INFOBK), 0)
    SendMessage_(iToolTip, #TTM_SETMAXTIPWIDTH, 0, 280)
    Balloon.TOOLINFO\cbSize=SizeOf(TOOLINFO)
    Balloon\uFlags = #TTF_IDISHWND | #TTF_SUBCLASS
    Balloon\hwnd = GadgetID(iGadget)
    Balloon\uId = GadgetID(iGadget)
    Balloon\lpszText = @sTip
    SendMessage_(iToolTip, #TTM_ADDTOOL, 0, @Balloon)
    If (sTitle > "")
        SendMessage_(iToolTip, #TTM_SETTITLE, iIcon, @sTitle)
    EndIf
EndProcedure

Procedure CheckForUpdate()
RunProgram("Update uVNC.exe","","")
EndProcedure

Procedure CheckRunningProcesses()
 If ListSize(MyVNCList())>0
   ResetList(MyVNCList())
  While NextElement(MyVNCList())
    myproc.s=GetPidProcessEx("vncviewer.exe")
   If match(myproc,Str(MyVNCList()\VNCPID),0,#False) = #True
     For aa=0 To CountGadgetItems(#Hosts_List)-1
       test.s=GetGadgetItemText(#Hosts_List,aa,2)
       If match(Str(MyVNCList()\VNCSelection),test,1,#False)=#True
         SetGadgetItemImage(#Hosts_List,aa,CatchImage(#PC_Connected,?PCConnected))
       EndIf
     Next aa
   Else
     WriteLog(myhostname,"uVNC viewer closed on localhost - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
      StatusBarText(#StatusBar0,0,"Removing uVNC from "+MyVNCList()\VNCHostName,#PB_StatusBar_Center) 
       UpdateWindow_(WindowID(#Window_0))
        WriteLog(myhostname,"Removing uVNC service on "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
         RunProgram("paexec","\\"+MyVNCList()\VNCHostName+" C:\RCTemp\winvnc -uninstall","",#PB_Program_Hide|#PB_Program_Wait)
          RunProgram("taskkill","/s \\"+MyVNCList()\VNCHostName+" /f /im winvnc.exe","",#PB_Program_Hide|#PB_Program_Wait)
           WriteLog(myhostname,"Removing uVNC files on "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
            WriteLog(myhostname,"Removing the uVNC configuration files on localhost - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
             FileOp("\\"+MyVNCList()\VNCHostName+"\C$\RCTemp","",#FO_DELETE)
              DeleteFile("view\"+MyVNCList()\VNCHostName+".vnc", #PB_FileSystem_Force)
               DeleteFile("view\options.vnc", #PB_FileSystem_Force)
                StatusBarText(#StatusBar0,0,"Ready",#PB_StatusBar_Center)
                 For bb=0 To CountGadgetItems(#Hosts_List)-1
                  test1.s=GetGadgetItemText(#Hosts_List,bb,2)
                  If match(Str(MyVNCList()\VNCSelection),test1,1,#False)=#True
                    SetGadgetItemImage(#Hosts_List,bb,CatchImage(#PC_Connected,?PCBlank))
                  EndIf
                 Next bb
                  DeleteElement(MyVNCList(),1)
                   WriteLog(myhostname,"All operations completed successfully - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
                    WriteLog(myhostname,"");For spacing
      If FindPartWin("- service mode")=#False
       If GetGadgetState(#App_EnableScrollLock)=1
        If GetKeyState_(#VK_SCROLL)=1
          keybd_event_(#VK_SCROLL,0,0,0)
           keybd_event_(#VK_SCROLL,0,#KEYEVENTF_KEYUP,0)
        EndIf
       EndIf
      EndIf
   EndIf
  Wend
 EndIf
EndProcedure

Procedure ClearHosts()
 clearallhosts=MessageRequester("Clear All Hosts", "Do you wish to clear all hosts?", #PB_MessageRequester_YesNo|#MB_ICONQUESTION|#MB_DEFBUTTON2)
  If clearallhosts=#PB_MessageRequester_Yes
    ClearGadgetItems(#Hosts_List)
     ClearList(nslist())
      SetGadgetText(#String_HostName, "")
       SetGadgetText(#String_Description, "")
        DeleteFile("hosts.dat", #PB_FileSystem_Force)
  EndIf
EndProcedure

Procedure ConnectHostButton()
Protected pointer
 myhostname=GetGadgetText(#String_HostName)
  mydescription=GetGadgetText(#String_Description)
   If SearchListIcon(#Hosts_List,myhostname,@Pos,0)=#True
     mypos=GetGadgetState(#Hosts_List)
      SetGadgetText(#String_Description,GetGadgetItemText(#Hosts_List,mypos,1))
       SelectElement(nslist(),mypos)
        selection=nslist()\myindexlist
         CreateConnection(myhostname)
          selection=0
    Else
     If FindString(myhostname,".",1)>0
       pingresult=PingHost(myhostname,1000,"")
     Else
       myip.s=GetIPAddress(myhostname)
        pingresult=PingHost(myip,1000,"")
     EndIf
      If pingresult<>-1
        pointer=AddElement(nslist())
         nslist()\myhostnamelist = myhostname
         nslist()\mydescriptionlist = mydescription
       If CountGadgetItems(#Hosts_List)=0
         nslist()\myindexlist=0
       Else
         nslist()\myindexlist=ListSize(nslist())-1
       EndIf
         nslist()\mypointer=pointer
        *old_element = @nslist()
          ChangeCurrentElement(nslist(),*old_element)
           AddGadgetItem(#Hosts_List,0,nslist()\myhostnamelist+Chr(10)+nslist()\mydescriptionlist+Chr(10)+nslist()\myindexlist+Chr(10)+nslist()\mypointer)
            selection=0
           SetColumnWidths()
          SaveFile()
         SetGadgetState(#Hosts_List,0)
        CreateConnection(myhostname)
      Else
        MessageRequester("Error","Cannot connect to "+myhostname+"."+#CRLF$+"Make sure the computer is turned on and connected to the network.",#MB_ICONERROR)
      EndIf
   EndIf
EndProcedure

Procedure ConnectHostMouse()
 If GetGadgetText(#Hosts_List)<>""
   myhostname=GetGadgetText(#Hosts_List)
     SetGadgetText(#String_HostName, myhostname)
      SetGadgetText(#String_Description,GetGadgetItemText(#Hosts_List,GetGadgetState(#Hosts_List),1))
       CreateConnection(myhostname)
 EndIf 
EndProcedure

Procedure CreateConnection(hostname.s)
Protected checkvnc, connectsuccess, isrunning.s, myip.s, myos.s, pingresult, success

checkvnc=0; Used when checking to see if the UltraVNC service is started on remote PC
success=0; Used to add host to list only if connection was successful
connectsuccess=0; Used to save if last connection attempt was successful
While WaitWindowEvent(1)
DisableGadget(#Panel_1,1):DisableGadget(#Text_HostName,1):DisableGadget(#Text_Description,1):DisableGadget(#Text_Search,1):DisableGadget(#String_Hostname,1):DisableGadget(#String_Description,1):DisableGadget(#String_Search,1)
Wend
If FindString(myhostname,".",1)>0
  pingresult=PingHost(myhostname,1000,"")
Else
  myip=GetIPAddress(myhostname)
   pingresult=PingHost(myip,1000,"")
    WriteLog(myhostname,"");For spacing
 If pingresult=-1
   WriteLog(myhostname,"Unable to Ping host: "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
 EndIf
EndIf
  If pingresult<>-1
    WriteLog(myhostname,"Ping Time: "+pingresult+"ms"+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
     StatusBarText(#StatusBar0,0,"Creating uVNC files",#PB_StatusBar_Center)
       CreatePassword()
        WriteLog(myhostname,"Successfully created all of the required local files - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
         StatusBarText(#StatusBar0,0,"Checking for uVNC on "+myhostname,#PB_StatusBar_Center)
          WriteLog(myhostname,"Checking for running uVNC on remote computer "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
result=InitNetwork()
  If result<>0
    isopen=OpenNetworkConnection(myhostname,5900,#PB_Network_TCP,1000)
   If isopen=0
     StatusBarText(#StatusBar0,0,"No uVNC found on "+myhostname,#PB_StatusBar_Center)
      WriteLog(myhostname,"No uVNC found running, continuing process on "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
   Else
     StatusBarText(#StatusBar0,0,"Found uVNC running on "+myhostname+", stopping and removing",#PB_StatusBar_Center)
      WriteLog(myhostname,"uVNC found running, removing uVNC on remote computer "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
       RemoveService(myhostname)
   EndIf
  EndIf
      CreateViewerConfigFile(myhostname)
     While WindowEvent():Wend;Refresh status bar
      StatusBarText(#StatusBar0,0,"Copying files to "+myhostname,#PB_StatusBar_Center)
       myos=GetOSType(myhostname)
    If myos="32"
      CreateServerINIFile("Serve86\")
       Delay(1000)
     If FileOp("Serve86\*.*","\\"+myhostname+"\C$\RCTemp",#FO_COPY) = 0
       WriteLog(myhostname,"Successfully copied required 32-bit files to "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
     Else
       MessageRequester("Error","Failed to copy required files to "+myhostname+"."+#CRLF$+"Make sure you have admin rights on the remote computer.",#MB_ICONERROR)
        WriteLog(myhostname,"Failed to copy required 32-bit files to "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
         success=0
          connectsuccess=0
           Goto theend
     EndIf
    ElseIf myos="64"
      CreateServerINIFile("Serve\")
       Delay(1000)
     If FileOp("Serve\*.*","\\"+myhostname+"\C$\RCTemp",#FO_COPY) = 0
       WriteLog(myhostname,"Successfully copied required 64-bit files to "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
     Else
       MessageRequester("Error","Failed to copy required files to "+myhostname+"."+#CRLF$+"Make sure you have admin rights on the remote computer.",#MB_ICONERROR)
        WriteLog(myhostname,"Failed to copy required 64-bit files to "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
         success=0
          connectsuccess=0
           Goto theend
     EndIf
    Else
      MessageRequester("Error","Failed to determine OS type and copy files to "+myhostname+"."+#CRLF$+"Make sure you have admin rights on the remote computer.",#MB_ICONERROR)
       WriteLog(myhostname,"Failed to determine OS type on "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
        success=0
         connectsuccess=0
          Goto osfailure
    EndIf
       WriteLog(myhostname,"Attempting to install and start uVNC service on "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
      StatusBarText(#StatusBar0,0,"Starting uVNC server on "+myhostname,#PB_StatusBar_Center)
     RunProgram("paexec","\\"+myhostname+" C:\RCTemp\winvnc -install","",#PB_Program_Hide|#PB_Program_Wait)
    WriteLog(myhostname,"Checking uVNC service status on "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
   While WindowEvent():Wend;Refresh status bar
  StatusBarText(#StatusBar0,0,"Checking uVNC status on "+myhostname,#PB_StatusBar_Center)
 Sleep_(2000)

checkservice:

result=InitNetwork()
 If result<>0
   isopen=OpenNetworkConnection(myhostname,5900,#PB_Network_TCP,1000)
   If isopen=0
     WriteLog(myhostname,"Re-checking uVNC service status on "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
      checkvnc=checkvnc+1
      Sleep_(2000)
    If checkvnc=5
      StatusBarText(#StatusBar0,0,"uVNC failed to start on "+myhostname+", starting removal process",#PB_StatusBar_Center)
       Sleep_(2000)
        WriteLog(myhostname,"uVNC service failed to start on "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
         WriteLog(myhostname,"Starting removal process on "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
         success=0
        connectsuccess=0
       checkvnc=0
      RemoveService(myhostname)
     Goto theend
    EndIf
     Goto checkservice
  Else
    WriteLog(myhostname,"uVNC found running on "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
     success=1
      StatusBarText(#StatusBar0,0,"Found uVNC running on "+myhostname+", starting uVNC viewer",#PB_StatusBar_Center)
      While WindowEvent():Wend;Refresh status bar
    Goto carryon
  EndIf
 EndIf

carryon:

 While WindowEvent():Wend;Refresh status bar
  Delay(2000)
   WriteLog(myhostname,"Starting uVNC viewer on localhost - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
    myprog=RunProgram("view\vncviewer","-config view\"+hostname+".vnc","",#PB_Program_Open|#PB_Program_Read|#PB_Program_Unicode)
   If IsProgram(myprog)
     myid=ProgramID(myprog)
      AddElement(MyVNCList())
       MyVNCList()\VNCHostName = hostname
       MyVNCList()\VNCPID = myid
       MyVNCList()\VNCSelection = Val(GetGadgetItemText(#Hosts_List,selection,2))
;Enable Scroll Lock
    If GetGadgetState(#App_EnableScrollLock)=1
     If GetKeyState_(#VK_SCROLL)=0
       keybd_event_(#VK_SCROLL,0,0,0)
        keybd_event_(#VK_SCROLL,0,#KEYEVENTF_KEYUP,0)
     EndIf
    EndIf
;*****************************************************
connectsuccess=1
 If connectsuccess=1
  If GetGadgetText(#String_HostName) And GetGadgetText(#String_Description)<>""
    OpenPreferences("vnc.prefs")
     WritePreferenceString("LastConnect", GetGadgetText(#String_HostName)+","+GetGadgetText(#String_Description))
      ClosePreferences()
       connectsuccess=0
  EndIf
 EndIf
   Else
     connectsuccess=0
      WriteLog(myhostname,"Could not capture the uVNC Viewer process, exiting - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
   EndIf

theend:

While WindowEvent():Wend;Refresh status bar

osfailure:

  StatusBarText(#StatusBar0,0,"Ready",#PB_StatusBar_Center)
   DisableGadget(#Panel_1,0):DisableGadget(#Text_HostName,0):DisableGadget(#Text_Description,0):DisableGadget(#Text_Search,0):DisableGadget(#String_Hostname,0):DisableGadget(#String_Description,0):DisableGadget(#String_Search,0)
  Else
    MessageRequester("Error","Cannot connect to "+myhostname+"."+#CRLF$+"Make sure the computer is turned on and connected to the network.",#MB_ICONERROR)
     WriteLog(myhostname,"")
      WriteLog(myhostname,"Failed to connect to remote host "+myhostname+" - "+FormatDate("%mm/%dd/%yyyy"+" "+"%hh:%ii:%ss" ,Date()))
     WriteLog(myhostname,"")
    DisableGadget(#Panel_1,0):DisableGadget(#Text_HostName,0):DisableGadget(#Text_Description,0):DisableGadget(#Text_Search,0):DisableGadget(#String_Hostname,0):DisableGadget(#String_Description,0):DisableGadget(#String_Search,0)
  EndIf
EndProcedure

Procedure CreateLocalFiles()
If FileSize("Logs")<>-2
  CreateDirectory("Logs")
EndIf
 If FileSize("View")<>-2
   CreateDirectory("View")
 EndIf
  If FileSize("Serve")<>-2
    CreateDirectory("Serve")
  EndIf
   If FileSize("Serve86")<>-2
     CreateDirectory("Serve86")
   EndIf

If FileSize("View\vncviewer.exe")=-1
CreateFile(1,"View\vncviewer.exe")
 WriteData(1,?viewer64start,?viewer64end-?viewer64start)
CloseFile(1)
EndIf

If FileSize("Serve\winvnc.exe")=-1
CreateFile(2,"Serve\winvnc.exe")
 WriteData(2,?server64start,?server64end-?server64start)
CloseFile(2)
EndIf

If FileSize("Serve\ddengine64.dll")=-1
CreateFile(3,"Serve\ddengine64.dll")
 WriteData(3,?ddengine64start,?ddengine64end-?ddengine64start)
CloseFile(3)
EndIf

If FileSize("Serve86\winvnc.exe")=-1
CreateFile(6,"Serve86\winvnc.exe")
 WriteData(6,?server32start,?server32end-?server32start)
CloseFile(6)
EndIf

If FileSize("Serve86\ddengine.dll")=-1
CreateFile(7,"Serve86\ddengine.dll")
 WriteData(7,?ddengine32start,?ddengine32end-?ddengine32start)
CloseFile(7)
EndIf

If FileSize("paexec.exe")=-1
CreateFile(10,"paexec.exe")
 WriteData(10,?remotestart,?remoteend-?remotestart)
CloseFile(10)
EndIf
EndProcedure

Procedure.s CreatePassword()
strInputString.s
strCode.s
intNameLength.i
intRnd.i

strInputString = "ABCDEF0123456789" ;Characters To choose from to generate random string
intNameLength = 18 ;Define length of random string

;Generate the random string
For intStep = 1 To intNameLength
   intRnd = Random(16)
   strCode = strCode + Mid(strInputString, intRnd, 1)
Next
;Return the string
PasswordHash.s = strCode
ProcedureReturn PasswordHash
EndProcedure

Procedure CreateServerINIFile(dir.s)
  Protected.i File, Result
  ;Create the file if it doesn't exist
  File = CreateFile(#PB_Any, dir+"UltraVNC.ini");"Serve\UltraVNC.ini")
  If File
    WriteStringN(File, "[admin]", #PB_Ascii)
    WriteStringN(File, "UseRegistry=0", #PB_Ascii)
    WriteStringN(File, "MSLogonRequired=0", #PB_Ascii)
    WriteStringN(File, "NewMSLogon=0", #PB_Ascii)
    WriteStringN(File, "DebugMode=0", #PB_Ascii)
    WriteStringN(File, "Avilog=0", #PB_Ascii)
    WriteStringN(File, "path=C:\RCTemp", #PB_Ascii)
    WriteStringN(File, "accept_reject_mesg="+myname+" wants to connect to your computer. Do you wish to allow the connection?", #PB_Ascii)
    WriteStringN(File, "debugLevel=0", #PB_Ascii)
; Disable Server System Tray Icon
  If GetGadgetState(#Server_DisableTrayIcon)<>0
    WriteStringN(File, "DisableTrayIcon=1", #PB_Ascii)
  Else
    WriteStringN(File, "DisableTrayIcon=0", #PB_Ascii)
  EndIf
;********************************
; Enable RDP Mode
  If GetGadgetState(#Server_RDPMode)<>0
    WriteStringN(File, "rdpmode=1", #PB_Ascii)
  Else
    WriteStringN(File, "rdpmode=0", #PB_Ascii)
  EndIf
;****************
; Disable Screensaver
  If GetGadgetState(#Server_DisableScreensaver)<>0
    WriteStringN(file,"noscreensaver=1",#PB_Ascii)
  Else
    WriteStringN(file,"noscreensaver=0",#PB_Ascii)
  EndIf
;*******************
    WriteStringN(File, "LoopbackOnly=0", #PB_Ascii)
    WriteStringN(File, "UseDSMPlugin=0", #PB_Ascii)
    WriteStringN(File, "AllowLoopback=0", #PB_Ascii)
    WriteStringN(File, "AuthRequired=1", #PB_Ascii)
    WriteStringN(File, "ConnectPriority=0", #PB_Ascii)
    WriteStringN(File, "DSMPlugin=", #PB_Ascii)
    WriteStringN(File, "AuthHosts=", #PB_Ascii)
    WriteStringN(File, "DSMPluginConfig=", #PB_Ascii)
    WriteStringN(File, "AllowShutdown=0", #PB_Ascii);Disable ability to shut down server if tray icon visible
    WriteStringN(File, "AllowProperties=0", #PB_Ascii);Disable server properties menu if tray icon visible
    WriteStringN(File, "AllowEditClients=0", #PB_Ascii);Disable client editing if tray icon visible
; File Transfers
  If GetGadgetState(#Server_EnableFileTransfers)<>0
    WriteStringN(File, "FileTransferEnabled=1", #PB_Ascii)
  Else
    WriteStringN(File, "FileTransferEnabled=0", #PB_Ascii)
  EndIf
;***************
    WriteStringN(File, "FTUserImpersonation=1", #PB_Ascii);Impersonate as desktop user,0=use 'system' account (no access to mapped drives, security holes)
    WriteStringN(File, "BlankMonitorEnabled=0", #PB_Ascii);Allow viewer to blank the screen
; Capture Semi-Transparent Windows
  If GetGadgetState(#Server_CaptureSemiTransparentWindows)<>0
    WriteStringN(File, "CaptureAlphaBlending=1", #PB_Ascii);Capture semi-transparent windows
  Else
    WriteStringN(File, "CaptureAlphaBlending=0", #PB_Ascii)
  EndIf
;*********************************
    WriteStringN(File, "BlackAlphaBlending=0", #PB_Ascii);No pwr mgr to black window, layer a window on top and capture windows below. Custom background.bmp for custom lock screen
    WriteStringN(File, "BlankInputsOnly=1", #PB_Ascii);Keeps the monitor from blanking, only disables KB & Mouse input
    WriteStringN(File, "DefaultScale=1", #PB_Ascii)
    WriteStringN(File, "primary=1", #PB_Ascii)
; Multi-Monitor Support
  If GetGadgetState(#Server_MultiMonitorSupport)<>0
    WriteStringN(File, "secondary=1", #PB_Ascii);Enable multi-monitor support
  Else
    WriteStringN(File, "secondary=0", #PB_Ascii);Disable multi-monitor support
  EndIf
;**********************
    WriteStringN(File, "SocketConnect=1", #PB_Ascii)
    WriteStringN(File, "HTTPConnect=0", #PB_Ascii)
    WriteStringN(File, "AutoPortSelect=0", #PB_Ascii)
    WriteStringN(File, "PortNumber=5900", #PB_Ascii)
    WriteStringN(File, "HTTPPortNumber=5800", #PB_Ascii)
; Idle Timeout
OpenPreferences("vnc.prefs")
  theidletime=ReadPreferenceInteger("IdleTime",0)
ClosePreferences()
  If theidletime<>0
    WriteStringN(File, "IdleInputTimeout="+theidletime, #PB_Ascii)
  Else
    WriteStringN(File, "IdleInputTimeout=0", #PB_Ascii)
  EndIf
;*************
; Remove wallpaper
  If GetGadgetState(#Server_RemoveWallpaper)<>0
    WriteStringN(File, "RemoveWallpaper=1", #PB_Ascii)
  Else
    WriteStringN(File, "RemoveWallpaper=0", #PB_Ascii)
  EndIf
;*****************
; Disable Aero
  If GetGadgetState(#Viewer_PromptUser)<>0
    WriteStringN(File, "RemoveAero=1", #PB_Ascii)
  Else
    WriteStringN(File, "RemoveAero=0", #PB_Ascii)
  EndIf
;*************
; Prompt user to connect
  If GetGadgetState(#Viewer_PromptUser)<>0
    WriteStringN(File, "QuerySetting=4", #PB_Ascii);Enable connection query
  Else
    WriteStringN(File, "QuerySetting=2", #PB_Ascii);disable connectiom query
  EndIf
;***********************
    WriteStringN(File, "QueryTimeout=30", #PB_Ascii)
    WriteStringN(File, "QueryAccept=2", #PB_Ascii);Set in case screen is locked
    WriteStringN(File, "QueryIfNoLogon=1", #PB_Ascii);Set in case screen is locked
    WriteStringN(File, "InputsEnabled=1", #PB_Ascii)
; Lock Workstation on Disconnect
  If GetGadgetState(#Server_DisconnectNothing)<>0
    WriteStringN(File, "LockSetting=0", #PB_Ascii);0=Nothing
  EndIf
  If GetGadgetState(#Server_DisconnectLock)<>0
    WriteStringN(File, "LockSetting=1", #PB_Ascii);1=Lock workstation on disconnect
  EndIf
  If GetGadgetState(#Server_DisconnectLogoff)<>0
    WriteStringN(File, "LockSetting=2", #PB_Ascii);2=Log off on disconnect
  EndIf
;*******************************
;Disable hosts mouse and keyboard
  If GetGadgetState(#Viewer_DisableRemoteInput)<>0
    WriteStringN(File, "LocalInputsDisabled=1", #PB_Ascii)
  Else
    WriteStringN(File, "LocalInputsDisabled=0", #PB_Ascii)
  EndIf
;********************************
    WriteStringN(File, "EnableJapInput=0", #PB_Ascii)
    WriteStringN(File, "kickrdp=0", #PB_Ascii)
    WriteStringN(File, "clearconsole=0", #PB_Ascii)
    WriteStringN(File, "[admin_auth]", #PB_Ascii)
    WriteStringN(File, "group1=", #PB_Ascii)
    WriteStringN(File, "group2=", #PB_Ascii)
    WriteStringN(File, "group3=", #PB_Ascii)
    WriteStringN(File, "locdom1=0", #PB_Ascii)
    WriteStringN(File, "locdom2=0", #PB_Ascii)
    WriteStringN(File, "locdom3=0", #PB_Ascii)
    WriteStringN(File, "[UltraVNC]", #PB_Ascii)
    WriteStringN(File, "passwd="+PasswordHash, #PB_Ascii)
    WriteStringN(File, "passwd2="+CreatePassword(), #PB_Ascii)
    WriteStringN(File, "[poll]", #PB_Ascii)
    WriteStringN(File, "TurboMode=1", #PB_Ascii)
    WriteStringN(File, "PollUnderCursor=0", #PB_Ascii)
    WriteStringN(File, "PollForeground=0", #PB_Ascii)
    WriteStringN(File, "PollFullScreen=1", #PB_Ascii)
    WriteStringN(File, "OnlyPollConsole=0", #PB_Ascii)
; Only Poll on Event
  If GetGadgetState(#Server_OnlyPollOnEvent)<>0
    WriteStringN(File, "OnlyPollOnEvent=1", #PB_Ascii);Only update screen when KB/Mouse used
  Else
    WriteStringN(File, "OnlyPollOnEvent=0", #PB_Ascii);Only update screen when KB/Mouse used
  EndIf
;*******************
; Maximum CPU Usage
  If GetGadgetState(#Server_MaxCPU)<>0
    WriteStringN(File, "MaxCpu="+GetGadgetText(#String_MaxCPU), #PB_Ascii)
  Else
    WriteStringN(File, "MaxCpu=40", #PB_Ascii)
  EndIf
;******************
;Enable VNC Driver (ddengine64.dll)
  If GetGadgetState(#Server_EnableDriver)<>0
    WriteStringN(File, "EnableDriver=1", #PB_Ascii);Use ddengine64.dll
  Else
    WriteString(File, "EnableDriver=0", #PB_Ascii);Dont' use ddengine64.dll
  EndIf
;**********************************
    WriteStringN(File, "EnableHook=0", #PB_Ascii);Use vnchooks.dll
    WriteStringN(File, "EnableVirtual=0", #PB_Ascii)
    WriteStringN(File, "SingleWindow=0", #PB_Ascii)
    WriteStringN(File, "SingleWindowName=", #PB_Ascii)
    CloseFile(File)
    Result = #True
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure.i CreateViewerConfigFile(hostname.s)
  Protected.i File, Result
  ;Create the file if it doesn't exist
  File = CreateFile(#PB_Any, "View\"+hostname+".vnc")
  If File
    WriteStringN(File, "[connection]", #PB_Ascii)
    WriteStringN(File, "host=" + hostname, #PB_Ascii)
    WriteStringN(File, "port=5900", #PB_Ascii)
    WriteStringN(File, "password="+PasswordHash, #PB_Ascii)
    WriteStringN(File, "proxyhost=", #PB_Ascii)
    WriteStringN(File, "proxyport=0", #PB_Ascii)
    WriteStringN(File, "[options]", #PB_Ascii)
    WriteStringN(File, "use_encoding_0=1", #PB_Ascii)
    WriteStringN(File, "use_encoding_1=1", #PB_Ascii)
    WriteStringN(File, "use_encoding_2=1", #PB_Ascii)
    WriteStringN(File, "use_encoding_3=0", #PB_Ascii)
    WriteStringN(File, "use_encoding_4=1", #PB_Ascii)
    WriteStringN(File, "use_encoding_5=1", #PB_Ascii)
    WriteStringN(File, "use_encoding_6=1", #PB_Ascii)
    WriteStringN(File, "use_encoding_7=1", #PB_Ascii)
    WriteStringN(File, "use_encoding_8=1", #PB_Ascii)
    WriteStringN(File, "use_encoding_9=1", #PB_Ascii)
    WriteStringN(File, "use_encoding_10=1", #PB_Ascii)
    WriteStringN(File, "use_encoding_11=0", #PB_Ascii)
    WriteStringN(File, "use_encoding_12=0", #PB_Ascii)
    WriteStringN(File, "use_encoding_13=0", #PB_Ascii)
    WriteStringN(File, "use_encoding_14=0", #PB_Ascii)
    WriteStringN(File, "use_encoding_15=0", #PB_Ascii)
    WriteStringN(File, "use_encoding_16=1", #PB_Ascii)
    WriteStringN(File, "use_encoding_17=1", #PB_Ascii)
    WriteStringN(File, "use_encoding_18=1", #PB_Ascii)
    WriteStringN(File, "use_encoding_19=1", #PB_Ascii)
    WriteStringN(File, "preferred_encoding=16", #PB_Ascii)
    WriteStringN(File, "restricted=0", #PB_Ascii)
; View hosts screen only, no input from viewer
  If GetGadgetState(#Viewer_ViewOnly)<>0
    WriteStringN(File, "viewonly=1", #PB_Ascii)
  Else
    WriteStringN(File, "viewonly=0", #PB_Ascii)
  EndIf
;***********************
; Show VNC connection status window
  If GetGadgetState(#Viewer_StatusWindow)<>0
    WriteStringN(File, "nostatus=0", #PB_Ascii)
  Else
    WriteStringN(File, "nostatus=1", #PB_Ascii)
  EndIf
;***********************
    WriteStringN(File, "nohotkeys=0", #PB_Ascii)
;Show Toolbar
  If GetGadgetState(#Viewer_ShowToolbar)<>0
    WriteStringN(File, "showtoolbar=1", #PB_Ascii)
  Else
    WriteStringN(File, "showtoolbar=0", #PB_Ascii)
  EndIf
;************
;Automatic scaling - Window size matches host size
  If GetGadgetState(#Viewer_AutoScale)<>0
    WriteStringN(File, "autoscaling=1", #PB_Ascii)
  Else
    WriteStringN(File, "autoscaling=0", #PB_Ascii)
  EndIf
;***********
;Fullscreen
  If GetGadgetState(#Viewer_Fullscreen)<>0
    WriteStringN(File, "fullscreen=1", #PB_Ascii)
  Else
    WriteStringN(File, "fullscreen=0", #PB_Ascii)
  EndIf
;**********
    WriteStringN(File, "savepos=0", #PB_Ascii)
    WriteStringN(File, "savesize=0", #PB_Ascii)
;Enable Host screen stretch
  If GetGadgetState(#Viewer_StretchScreen)<>0
    WriteStringN(File, "directx=1", #PB_Ascii)
  Else
    WriteStringN(File, "directx=0", #PB_Ascii)
  EndIf
;*************************
    WriteStringN(File, "autodetect=1", #PB_Ascii)
;Enable 256 color mode
  If GetGadgetState(#Viewer_256Colors)<>0
    WriteStringN(File, "8bit=1", #PB_Ascii)
  Else
    WriteStringN(File, "8bit=0", #PB_Ascii)
  EndIf
;*********************
    WriteStringN(File, "shared=0", #PB_Ascii);1 in original file
    WriteStringN(File, "swapmouse=0", #PB_Ascii)
    WriteStringN(File, "belldeiconify=0", #PB_Ascii)
    WriteStringN(File, "emulate3=1", #PB_Ascii)
    WriteStringN(File, "JapKeyboard=0", #PB_Ascii)
    WriteStringN(File, "emulate3timeout=100", #PB_Ascii)
    WriteStringN(File, "emulate3fuzz=4", #PB_Ascii)
;Disable Clipboard
If GetGadgetState(#Viewer_DisableClipboard)<>0
    WriteStringN(File, "disableclipboard=1", #PB_Ascii);Clipboard disabled
Else
    WriteStringN(File, "disableclipboard=0", #PB_Ascii);Clipboard enabled
EndIf
;*****************
    WriteStringN(File, "localcursor=1", #PB_Ascii);Show local cursor
    WriteStringN(File, "scaling=0", #PB_Ascii)
    WriteStringN(File, "cursorshape=0", #PB_Ascii);Sets the "Let remote server deal with mouse cursor", 1=viewer renders
    WriteStringN(File, "noremotecursor=0", #PB_Ascii)
    WriteStringN(File, "compresslevel=6", #PB_Ascii)
    WriteStringN(File, "quality=6", #PB_Ascii)
    WriteStringN(File, "serverscale=1", #PB_Ascii)
    WriteStringN(File, "reconnect=5", #PB_Ascii); Time between auto-reconnect attempts
    WriteStringN(File, "enablecache=0", #PB_Ascii)
    WriteStringN(File, "quickoption=1", #PB_Ascii)
    WriteStringN(File, "usedsmplugin=0", #PB_Ascii)
    WriteStringN(File, "useproxy=0", #PB_Ascii)
    WriteStringN(File, "sponsor=1", #PB_Ascii);Turns off the sponsor logo on connect screen
    WriteStringN(File, "selectedscreen=1", #PB_Ascii)
    WriteStringN(File, "dsmplugin=noplugin", #PB_Ascii)
    WriteStringN(File, "autoreconnect=3", #PB_Ascii);How many tries to autoreconnect
If GetGadgetState(#Viewer_ConfirmExit)<>0;Prompt when closing the remote connection
    WriteStringN(File, "exitcheck=1", #PB_Ascii)   
Else
    WriteStringN(File, "exitcheck=0", #PB_Ascii)
EndIf
    WriteStringN(File, "filetransfertimeout=30", #PB_Ascii)
    WriteStringN(File, "keepaliveinterval=5", #PB_Ascii)
    WriteStringN(File, "socketkeepalivetimeout=10000", #PB_Ascii)
    WriteStringN(File, "throttlemouse=0", #PB_Ascii)
    WriteStringN(File, "autoacceptincoming=0", #PB_Ascii)
    WriteStringN(File, "autoacceptnodsm=0", #PB_Ascii)
    WriteStringN(File, "requireencryption=0", #PB_Ascii)
    WriteStringN(File, "preemptiveupdates=0", #PB_Ascii)
    CloseFile(File)
    Result = #True
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure DisconnectFromPC()
  disc=MessageRequester("Disconnect","Do you wish to disconnect from "+GetGadgetItemText(#Hosts_List,selection)+"?",#PB_MessageRequester_YesNo|#MB_ICONQUESTION)
  If disc=#PB_MessageRequester_Yes
    serverselection.s=GetGadgetItemText(#Hosts_List,selection,0)
     RunProgram("taskkill","/FI "+Chr(34)+"WINDOWTITLE eq "+serverselection+"*"+Chr(34)+" /t","",#PB_Program_Hide)
      SetGadgetText(#String_HostName,"")
       SetGadgetText(#String_Description,"")
  EndIf
EndProcedure

Procedure EditMyDescription(Title$)
Protected Window, EditMe, OK, Cancel
SelectElement(nslist(),Val(GetGadgetItemText(#Hosts_List,GetGadgetState(#Hosts_List),2)))
GetWindowRect_(WindowID(#Window_0),win.RECT); Store its dimensions in "win" structure.
 x=win\left : y=win\top : w=win\right-win\left ; Get it's X/Y position and width.
  Window = OpenWindow(#PB_Any,x+75,y+150,340,85,Title$,#PB_Window_ScreenCentered)
   DisableGadget(#Hosts_List,1)
    SetWindowPos_(WindowID(Window),0,x+75,y+150,0,0,#SWP_NOSIZE|#SWP_NOACTIVATE); Dock other window.
     StickyWindow(Window,1)
  
 If Window
   EditMe  = StringGadget(#PB_Any,10,10,320,20,"")
    OK      = ButtonGadget(#PB_Any,40,48,80,25,"OK",#PB_Button_Default)
     Cancel  = ButtonGadget(#PB_Any,220,48,80,25,"Cancel")
      SetActiveGadget(EditMe)
       SetGadgetText(EditMe,nslist()\mydescriptionlist)

  Repeat

    Select WaitWindowEvent()

      Case #PB_Event_Gadget      
        If EventGadget() = OK
          SetGadgetText(#Hosts_List,myhostname+Chr(10)+GetGadgetText(EditMe))
           nslist()\mydescriptionlist=GetGadgetText(EditMe)
            SetGadgetItemText(#Hosts_List,GetGadgetState(#Hosts_List),nslist()\mydescriptionlist,1)
             SaveFile()
          If GetGadgetText(#String_Hostname)<>""
            SetGadgetText(#String_Description,nslist()\mydescriptionlist)
          EndIf
            Break
        EndIf

        If EventGadget() = Cancel
          Break
        EndIf

      Case #PB_Event_MoveWindow
         GetWindowRect_(WindowID(#Window_0),win.RECT); Store its dimensions in "win" structure.
          x=win\left : y=win\top : w=win\right-win\left ; Get it's X/Y position and width.
           SetWindowPos_(WindowID(Window),0,x+50,y+150,0,0,#SWP_NOSIZE);|#SWP_NOACTIVATE); Dock other window.

      EndSelect

  If GetKeyState_(#VK_RETURN) > 1
    SetGadgetText(#Hosts_List,myhostname+Chr(10)+GetGadgetText(EditMe))
     nslist()\mydescriptionlist=GetGadgetText(EditMe)
      SetGadgetItemText(#Hosts_List,GetGadgetState(#Hosts_List),nslist()\mydescriptionlist,1)
       SaveFile()
   If GetGadgetText(#String_Hostname)<>""
     SetGadgetText(#String_Description,nslist()\mydescriptionlist)
   EndIf
     Break
  EndIf
  ForEver
 EndIf
  CloseWindow(Window)
EndProcedure

Procedure.l FileOp(FromLoc.s, ToLoc.s, Flag)
  ;Flag can be the following: #FO_COPY, #FO_DELETE, #FO_MOVE, #FO_RENAME
  Switches.SHFILEOPSTRUCT ;Windows API Structure
  ;The filename needs to be double null-terminated.
  temp1$=Space(#MAX_PATH+SizeOf(character))
  RtlZeroMemory_(@temp1$, #MAX_PATH+SizeOf(character))
  PokeS(@temp1$, FromLoc)
  temp2$=Space(#MAX_PATH+SizeOf(character))
  RtlZeroMemory_(@temp2$, #MAX_PATH+SizeOf(character))
  PokeS(@temp2$, ToLoc)
  Switches\wFunc = Flag
  Switches\pFrom = @temp1$
  Switches\pTo = @temp2$
  Switches\fFlags = #FOF_NOCONFIRMATION | #FOF_NOCONFIRMMKDIR | #FOF_SIMPLEPROGRESS
  Result.l = SHFileOperation_(@Switches)
  ; If cancel was pressed then result will NOT be zero (0)
ProcedureReturn Result
EndProcedure

Procedure FindPartWin(part$)
  r=GetWindow_(GetDesktopWindow_(),#GW_CHILD)
  Repeat
    t$=Space(999) : GetWindowText_(r,t$,999)
    If FindString(LCase(t$), LCase(part$),1)<>0 And IsWindowVisible_(r)=#True
      w=r
    Else
      r=GetWindow_(r,#GW_HWNDNEXT)
    EndIf
  Until r=0 Or w<>0
  ProcedureReturn w
EndProcedure

Procedure.i FindStringRev(String$, StringToFind$, UseCase.i=#PB_String_NoCase)
  Protected.i length = Len(StringToFind$)
  Protected.i *pos = @String$ + (Len(String$)-length) * SizeOf(Character)
  While @String$ <= *pos
    If CompareMemoryString(*pos, @StringToFind$, UseCase, length) = #PB_String_Equal ; = 0
      ProcedureReturn (*pos - @String$) / SizeOf(Character) + 1
    EndIf
    *pos - SizeOf(Character)
  Wend
  ProcedureReturn 0
EndProcedure

Procedure.s GetIPAddress(host.s)
  Protected *host.HOSTENT, *m
  If host > ""
    If WSAStartup_ ((1<<8|1), wsa.WSADATA) = #NOERROR
      *m = AllocateMemory(#MAX_COMPUTERNAME_LENGTH+1)
      PokeS(*m,host,#MAX_COMPUTERNAME_LENGTH,#PB_Ascii)
      *host.HOSTENT = gethostbyname_(*m)
      WSACleanup_()
      FreeMemory(*m)
      If *host
        ProcedureReturn PeekS(inet_ntoa_(PeekL(PeekL(*host\h_addr_list))),#MAX_COMPUTERNAME_LENGTH,#PB_Ascii)
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure.s GetOSType(hostname.s)
Protected myprogram, output$
myprogram=RunProgram("cmd","/c powershell "+Chr(34)+"Invoke-Command -computername "+hostname+" {(Get-CimInstance Win32_operatingsystem).OSArchitecture}"+Chr(34),"",#PB_Program_Open|#PB_Program_Read|#PB_Program_Hide)
output$=""
If myprogram
 While ProgramRunning(myprogram)
  If AvailableProgramOutput(myprogram)
   output$ + ReadProgramString(myprogram) + Chr(13)
Debug output$
  EndIf
 Wend
output$ + "Exitcode: "+Str(ProgramExitCode(myprogram))
If FindString(output$,"32-bit",1,#PB_String_NoCase)
Debug "OS is 32-Bit"
  ProcedureReturn "32"
ElseIf FindString(output$,"64-bit",1,#PB_String_NoCase)
Debug "OS is 64-Bit"
  ProcedureReturn "64"
EndIf
CloseProgram(myprogram)
EndIf
EndProcedure

Procedure.s GetPidProcessEx(Name.s)
  ;/// Return all process id as string separate by comma
  ;/// Author : jpd
  Protected ProcLib
  Protected ProcName.s
  Protected Process.PROCESSENTRY32
  Protected x
  Protected retval=#False
  Name=UCase(Name.s)
  ProcLib= OpenLibrary(#PB_Any, "Kernel32.dll") 
  If ProcLib
    CompilerIf #PB_Compiler_Unicode
      ProcessFirst           = GetFunction(ProcLib, "Process32FirstW") 
      ProcessNext            = GetFunction(ProcLib, "Process32NextW") 
    CompilerElse
      ProcessFirst           = GetFunction(ProcLib, "Process32First") 
      ProcessNext            = GetFunction(ProcLib, "Process32Next") 
    CompilerEndIf
    If  ProcessFirst And ProcessNext 
      Process\dwSize = SizeOf(PROCESSENTRY32) 
      Snapshot =CreateToolhelp32Snapshot_(#TH32CS_SNAPALL,0)
      If Snapshot 
        ProcessFound = ProcessFirst(Snapshot, Process) 
        x=1
        While ProcessFound 
          ProcName=PeekS(@Process\szExeFile)
          ProcName=GetFilePart(ProcName)
          If UCase(ProcName)=UCase(Name)
            If ProcessList.s<>"" : ProcessList+",": EndIf
            ProcessList+Str(Process\th32ProcessID)
          EndIf
          ProcessFound = ProcessNext(Snapshot, Process) 
          x=x+1  
        Wend 
      EndIf 
      CloseHandle_(Snapshot) 
    EndIf 
    CloseLibrary(ProcLib) 
  EndIf 
  ProcedureReturn ProcessList

EndProcedure

Procedure.s IdleTimeout(Title$)
  Protected Window, Trackme, OK, myidle, setme, mystate
GetWindowRect_(WindowID(#Window_0),win.RECT); Store its dimensions in "win" structure.
 x=win\left : y=win\top : w=win\right-win\left ; Get it's X/Y position and width.
  Window = OpenWindow(#PB_Any,x+75,y+150,300,105,Title$,#PB_Window_ScreenCentered)
   DisableGadget(#Hosts_List,1)
    SetWindowPos_(WindowID(Window),0,x+75,y+150,0,0,#SWP_NOSIZE|#SWP_NOACTIVATE); Dock other window.
     StickyWindow(Window,1)
  If Window
    Trackme  = TrackBarGadget(#PB_Any,10,10,280,32,0,12,#PB_TrackBar_Ticks)
               TextGadget(#PB_Any,21,40,280,20,"0     5    10   15   20   25   30   35   40   45   50   55   60")
    OK      = ButtonGadget(#PB_Any,110,68,80,25,"OK",#PB_Button_Default)
OpenPreferences("vnc.prefs")
  setme=ReadPreferenceInteger("IdleTime",0)
ClosePreferences()
;{ Get Idle Timeout
Select setme
  Case 0
    mystate=0
  Case 300
    mystate=1
  Case 600
    mystate=2
  Case 900
    mystate=3
  Case 1200
    mystate=4
  Case 1500
    mystate=5
  Case 1800
    mystate=6
  Case 2100
    mystate=7
  Case 2400
    mystate=8
  Case 2700
    mystate=9
  Case 3000
    mystate=10
  Case 3300
    mystate=11
  Case 3600
    mystate=12
EndSelect
;}
  SetGadgetState(Trackme,mystate)
    Repeat
;{ Get trackgadget state
Select GetGadgetState(Trackme)
  Case 0
    myidle=0
  Case 1
    myidle=300
  Case 2
    myidle=600
  Case 3
    myidle=900
  Case 4
    myidle=1200
  Case 5
    myidle=1500
  Case 6
    myidle=1800
  Case 7
    myidle=2100
  Case 8
    myidle=2400
  Case 9
    myidle=2700
  Case 10
    myidle=3000
  Case 11
    myidle=3300
  Case 12
    myidle=3600
EndSelect
;}
     Select WaitWindowEvent()
       Case #PB_Event_Gadget      
        If EventGadget() = OK
         If GetGadgetState(Trackme)<>0
           OpenPreferences("vnc.prefs")
            WritePreferenceInteger("ConfirmExit",0)
             WritePreferenceInteger("IdleTimeout",1)
              WritePreferenceInteger("IdleTime",myidle)
           ClosePreferences()
           flip17=0
            SetGadgetState(#Viewer_ConfirmExit, 0)
             DisableGadget(#Viewer_ConfirmExit, 1)
         Else
           OpenPreferences("vnc.prefs")
            WritePreferenceInteger("IdleTimeout",0)
             WritePreferenceInteger("IdleTime",myidle)
           ClosePreferences()
            DisableGadget(#Viewer_ConfirmExit, 0)
         EndIf
          Break
        EndIf
       Case #PB_Event_MoveWindow
         GetWindowRect_(WindowID(#Window_0),win.RECT); Store its dimensions in "win" structure.
          x=win\left : y=win\top : w=win\right-win\left ; Get it's X/Y position and width.
           SetWindowPos_(WindowID(Window),0,x+75,y+150,0,0,#SWP_NOSIZE);|#SWP_NOACTIVATE); Dock other window.
      EndSelect
      If GetKeyState_(#VK_RETURN) > 1
       If GetGadgetState(Trackme)<>0
         OpenPreferences("vnc.prefs")
          WritePreferenceInteger("ConfirmExit",0)
           WritePreferenceInteger("IdleTimeout",1)
            WritePreferenceInteger("IdleTime",myidle)
             ClosePreferences()
              flip17=0
               SetGadgetState(#Viewer_ConfirmExit, 0)
                DisableGadget(#Viewer_ConfirmExit, 1)
                 Break
       Else
         OpenPreferences("vnc.prefs")
          WritePreferenceInteger("IdleTimeout",0)
           WritePreferenceInteger("IdleTime",myidle)
            ClosePreferences()
             DisableGadget(#Viewer_ConfirmExit, 0)
              Break
       EndIf
      EndIf
    ForEver
  EndIf
  CloseWindow(Window)
EndProcedure

Procedure ImportAD()
myresult=MessageRequester("AD Import","Are you sure you wish to import from AD?"+#CRLF$+"No Domain Controllers, Server OS or Disabled Computers."+#CRLF$+"This will clear your current hosts List.",#PB_MessageRequester_YesNo|#MB_ICONWARNING)
 If myresult=#PB_MessageRequester_Yes
   StatusBarText(#StatusBar0,0,"Please wait, importing from AD...",#PB_StatusBar_Center)
    ClearGadgetItems(#Hosts_List)
     ClearList(nslist())
      SetGadgetText(#String_HostName, "")
       SetGadgetText(#String_Description, "")
        DeleteFile("hosts.dat", #PB_FileSystem_Force)
       RunProgram("cmd","/c adfind -csv -f "+Chr(34)+"(&(objectCategory=computer)(!userAccountControl:1.2.840.113556.1.4.803:=2)(!primaryGroupID=516)(!operatingsystem=Windows Server*))"+Chr(34)+" -sl -nodn name description -nocsvheader -csvnoq > PC.csv","",#PB_Program_Hide|#PB_Program_Wait)
      FillListIcon(#Hosts_List,"PC.csv")
     SaveFile()
    DeleteFile("pc.csv",#PB_FileSystem_Force)
   StatusBarText(#StatusBar0,0,"Ready",#PB_StatusBar_Center)
;Autosize the listicon columns
SetColumnWidths()
 Else
   ;cancelled
 EndIf
EndProcedure

Procedure IsMouseOver(hWnd)
    GetWindowRect_(hWnd,r.RECT)
    GetCursorPos_(p.POINT)
    Result = PtInRect_(r,p\y << 32 + p\x)
    ProcedureReturn Result
EndProcedure

Procedure.q lngNewAddress(strAdd.s)
  Protected sDummy.s=strAdd
  Protected Position = FindString(sDummy, ".",1)
  If Position>0
    Protected a1=Val(Left(sDummy,Position-1))
    sDummy=Right(sDummy,Len(sDummy)-Position)
    Position = FindString(sDummy, ".",1)
    If Position>0
      Protected A2=Val(Left(sDummy,Position-1))
      sDummy=Right(sDummy,Len(sDummy)-Position)
      Position = FindString(sDummy, ".",1)
      If Position>0
        Protected A3=Val(Left(sDummy,Position-1))
        sDummy=Right(sDummy,Len(sDummy)-Position)
        Protected A4=Val(sDummy)
        Protected dummy.q=0
        PokeB(@dummy,A1)
        PokeB(@dummy+1,A2)
        PokeB(@dummy+2,A3)
        PokeB(@dummy+3,A4)
        ProcedureReturn dummy
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure Match(FirstString.s,SecondString.s,Type.b,CaseSensitive.b) 
  If CaseSensitive=#False
    FirstString=LCase(FirstString)
    SecondString=LCase(SecondString)
  EndIf

  Select Type

    Case 0
      If FindString(FirstString,SecondString)
        ProcedureReturn #True
      EndIf

    Case 1
      If FirstString=SecondString
        ProcedureReturn #True
      EndIf

    Case 2
      If Left(FirstString,Len(SecondString))=SecondString
        ProcedureReturn #True
      EndIf

    Case 3
      If Right(FirstString,Len(SecondString))=SecondString
        ProcedureReturn #True
      EndIf

  EndSelect
EndProcedure

Procedure PingHost(Address.s,PING_TIMEOUT=1000,strMessage.s = "Echo This Information Back To Me")
  If Ping_Port
    Protected MsgLen = Len(strMessage) 
    Protected ECHO.ICMP_ECHO_REPLY 
    Protected IPAddressNumber.q = lngNewAddress(Address.s)
    Protected *buffer=AllocateMemory(SizeOf(ICMP_ECHO_REPLY)+MsgLen) 
    Protected lngResult = IcmpSendEcho_(Ping_Port, IPAddressNumber, @strMessage, MsgLen , #Null,*buffer, SizeOf(ICMP_ECHO_REPLY)+MsgLen,PING_TIMEOUT) 
    If lngResult
      CopyMemory(*buffer,@ECHO,SizeOf(ICMP_ECHO_REPLY)) 
    EndIf
    FreeMemory(*buffer)
    If lngResult
      ProcedureReturn ECHO\RoundTripTime
    Else
      ProcedureReturn -1
    EndIf
  EndIf
EndProcedure

Procedure RefreshList()
ClearGadgetItems(#Hosts_List)
ResetList(nslist())
 While NextElement(nslist())
   AddGadgetItem(#Hosts_List, -1, nslist()\myhostnamelist+#LF$+nslist()\mydescriptionlist+#LF$+nslist()\myindexlist+#LF$+nslist()\mypointer)
 Wend
EndProcedure

Procedure RemoveHost()
Protected clearcurrenthost, ni, Result, NbItems
If totalItemsSelected=1
  clearcurrenthost=MessageRequester("","Are you sure you wish to remove "+GetGadgetText(#Hosts_List)+" ?",#PB_MessageRequester_YesNo|#MB_ICONQUESTION|#MB_DEFBUTTON2)
 If clearcurrenthost=#PB_MessageRequester_Yes
   SelectElement(nslist(),Val(GetGadgetItemText(#Hosts_List,GetGadgetState(#Hosts_List),2)))
    DeleteElement(nslist(),1)
     RemoveGadgetItem(#Hosts_List,GetGadgetState(#Hosts_List))
      SetGadgetText(#String_HostName,"")
       SetGadgetText(#String_Description,"")
        SetGadgetText(#String_Search,"")
       SaveFile()
      ClearList(nslist())
     ClearGadgetItems(#Hosts_List)
    FillListIcon(#Hosts_List,"hosts.dat")
   totalItemsSelected=0
 EndIf
Else
 clearcurrenthost=MessageRequester("","Are you sure you wish to remove all selected items ?",#PB_MessageRequester_YesNo|#MB_ICONQUESTION|#MB_DEFBUTTON2)
 If clearcurrenthost=#PB_MessageRequester_Yes
   NbItems=CountGadgetItems(#Hosts_List)
   For ni = NbItems -1 To 0 Step -1
    result=GetGadgetItemState(#Hosts_List,ni)
  If result & #PB_ListIcon_Selected
    SelectElement(nslist(),ni)
     DeleteElement(nslist(),1)
      RemoveGadgetItem(#Hosts_List, ni)
  EndIf
   Next
   SetGadgetText(#String_HostName,"")
    SetGadgetText(#String_Description,"")
     SetGadgetText(#String_Search,"")
      SaveFile()
      ClearList(nslist())
     ClearGadgetItems(#Hosts_List)
    FillListIcon(#Hosts_List,"hosts.dat")
   totalItemsSelected=0
 EndIf
EndIf
EndProcedure

Procedure RemoveService(hostname.s)
RunProgram("paexec","\\"+hostname+" C:\RCTemp\winvnc -uninstall","",#PB_Program_Hide|#PB_Program_Wait)
 RunProgram("taskkill","/s \\"+hostname+" /f /im winvnc.exe","",#PB_Program_Hide|#PB_Program_Wait)
  FileOp("\\"+hostname+"\C$\RCTemp","",#FO_DELETE)
   DeleteFile("view\"+myhostname+".vnc", #PB_FileSystem_Force)
    DeleteFile("view\options.vnc", #PB_FileSystem_Force)
EndProcedure

Procedure SaveFile()
Protected NbItems, host.s, desc.s, add.s
DeleteFile("hosts.dat",#PB_FileSystem_Force)
NbItems=CountGadgetItems(#Hosts_List)
 CreateFile(0,"hosts.dat")
  OpenFile(0,"hosts.dat")
   For x=0 To NbItems
    host=GetGadgetItemText(#Hosts_List,x)
    desc=GetGadgetItemText(#Hosts_List,x,1)
    add=host+","+desc
    If add<>","
      WriteStringN(0,add,#PB_Ascii)
    EndIf
   Next
  CloseFile(0)
EndProcedure

Procedure SearchMe(search.s)
ClearGadgetItems(#Hosts_List)
If ListSize(nslist())>0
  ResetList(nslist())
    While NextElement(nslist())
     If FindStringRev(nslist()\myhostnamelist,search,1)
       AddGadgetItem(#Hosts_List, -1, nslist()\myhostnamelist+#LF$+nslist()\mydescriptionlist+#LF$+nslist()\myindexlist+#LF$+nslist()\mypointer)
     ElseIf FindStringRev(nslist()\mydescriptionlist,search,1)
       AddGadgetItem(#Hosts_List, -1, nslist()\myhostnamelist+#LF$+nslist()\mydescriptionlist+#LF$+nslist()\myindexlist+#LF$+nslist()\mypointer)
     ElseIf GetGadgetText(#String_Search)=""
       AddGadgetItem(#Hosts_List, -1, nslist()\myhostnamelist+#LF$+nslist()\mydescriptionlist+#LF$+nslist()\myindexlist+#LF$+nslist()\mypointer)
     EndIf
    Wend
EndIf
EndProcedure

Procedure SetColumnWidths()
;Set Column Widths Automatically
firstcolumnwidth=SendMessage_(GadgetID(#Hosts_List),#LVM_GETCOLUMNWIDTH,0,#Null)
secondcolumnwidth=SendMessage_(GadgetID(#Hosts_List),#LVM_GETCOLUMNWIDTH,1,#Null)
SendMessage_(GadgetID(#Hosts_List), #LVM_SETCOLUMNWIDTH, 0, #LVSCW_AUTOSIZE)
SendMessage_(GadgetID(#Hosts_List), #LVM_SETCOLUMNWIDTH, 1, #LVSCW_AUTOSIZE)
getfirstcolumnwidth=SendMessage_(GadgetID(#Hosts_List),#LVM_GETCOLUMNWIDTH,0,#Null)
getsecondcolumnwidth=SendMessage_(GadgetID(#Hosts_List),#LVM_GETCOLUMNWIDTH,1,#Null)
 
If getfirstcolumnwidth < firstcolumnwidth
SendMessage_(GadgetID(#Hosts_List), #LVM_SETCOLUMNWIDTH, 0, #LVSCW_AUTOSIZE_USEHEADER)
EndIf
If getsecondcolumnwidth < secondcolumnwidth
SendMessage_(GadgetID(#Hosts_List), #LVM_SETCOLUMNWIDTH, 1, #LVSCW_AUTOSIZE_USEHEADER)
EndIf
EndProcedure

Procedure SetIcons()
Protected z
For z = 0 To CountGadgetItems(#Hosts_List)-1
  SetGadgetItemImage(#Hosts_List,z,CatchImage(#PC_Blank,?PCBlank))
Next
EndProcedure

Procedure SortFile(file.s)
;Read file and add to a new list
NewList ListSort.s()
 r = OpenFile(0, file)
  pos = 0
 While Eof(0)=0
  text$ = ReadString(0)
  If text$ <> ","
   AddElement(ListSort())
    ListSort() = text$
     pos = pos - 1
  EndIf
 Wend
CloseFile(0)
DeleteFile(file,#PB_FileSystem_Force)
;Sort the list and save back to the file
SortList(ListSort(),#PB_Sort_NoCase)
OpenFile(1,file)
 ForEach ListSort()
  text$ = ListSort()
   If text$ <> ""
     WriteStringN(1,text$)
   EndIf
 Next
  CloseFile(1)
EndProcedure

Procedure WriteLog(filename.s, error.s)
If logme=1
 OpenFile(0,"Logs\"+filename+".log",#PB_File_SharedRead|#PB_File_SharedWrite|#PB_File_Append)
  WriteStringN(0, error.s, #PB_Ascii)
 CloseFile(0)
EndIf
EndProcedure

Procedure x_littlehelp(title.s,text.s,pointer.i=0,flags.i=-1); show a few small help windows
  Protected text_size.i, page_size.i, page_number.i, page_count.i, event.i
  Protected p.i, n.i, l.i,  h.i, width.i, height.i, w_showhelp.i, g_text.i, g_counter.i, g_previous.i, g_next.i, g_done.i, font_nr.i
  Protected Dim page_start.i(20), Dim page_size.i(20)
  ;
  ; *** displays a little window with the given text, and allows to browse through that text
  ;
  ; in:   title.s    - window title
  ;       text.s     - multi line text seperated by CRLF's
  ;       pointer.i  - pointer to text in memory ending on #00 $00, ignored if test.s <> ""
  ;       flags.i    - text format, #PB_Ascii, #PB_Unicode, -1
  ;
  ; typically used in windows / console apps when launched without command line parameters, or parameters such as /help or /?
  ; or when I'm too lazy to include a decent help file
  ;
  If text = "" And pointer > 0
    text = x_peeks(pointer,-1,flags)
  EndIf
  ;
  ExamineDesktops()
  text_size = CountString(text,#CRLF$)+1
  page_size = DesktopHeight(0)/23
  height = page_size*17
  ;
  page_count = 1+(text_size-1)/page_size
  width = 600
  ;
  p = 1
  n = 0
  Repeat
    n = n+1
    page_start.i(n) = p
    l = 0
    Repeat
      p = FindString(text,#CRLF$,p+1)
      l = l+1
    Until l >= page_size Or p = 0
    If p > 0
      page_size(n) = p-page_start(n)
      p = p+2
    Else
      page_size(n) = Len(text)-page_start(n)+1
    EndIf
  Until p <= 0
  ;
  font_nr = LoadFont(#PB_Any,"Courier New",9)
  w_showhelp = OpenWindow(#PB_Any,10,10,width+16,height+16,title,#PB_Window_SystemMenu|#PB_Window_ScreenCentered)
  AddKeyboardShortcut(w_showhelp,#PB_Shortcut_Return,1)
  AddKeyboardShortcut(w_showhelp,#PB_Shortcut_Escape,1)
  AddKeyboardShortcut(w_showhelp,#PB_Shortcut_Space,2)
  AddKeyboardShortcut(w_showhelp,#PB_Shortcut_Down,2)
  AddKeyboardShortcut(w_showhelp,#PB_Shortcut_Up,3)
  ;
  g_text = TextGadget(#PB_Any,16,16,width,height-60,"")
  g_counter = TextGadget(#PB_Any,16,height-12,32,16,"")
  g_previous = ButtonGadget(#PB_Any,width-140,height-12,50,22,"<")
  g_next = ButtonGadget(#PB_Any,width-90,height-12,50,22,">")
  g_done = ButtonGadget(#PB_Any,width-40,height-12,50,22,"Ok")
  SetGadgetFont(g_text,FontID(font_nr))
  SetGadgetFont(g_counter,FontID(font_nr))
  ;
  page_number = 1
  SetGadgetText(g_text,Mid(text,page_start(page_number),page_size(page_number)))
  SetGadgetText(g_counter,Str(page_number)+"/"+Str(page_count))
  Repeat
    If page_number = 1
      DisableGadget(g_previous,1)
    Else
      DisableGadget(g_previous,0)
    EndIf
    If page_number = page_count
      DisableGadget(g_next,1)
    Else
      DisableGadget(g_next,0)
    EndIf
    event = WaitWindowEvent()
    Select event
        Case #PB_Event_Menu
          Select EventMenu()
              Case 1
                event = #PB_Event_CloseWindow
              Case 2
                page_number = page_number+1
                If page_number > page_count
                  page_number = page_count
                EndIf
              Case 3
                page_number = page_number-1
                If page_number < 1
                  page_number = 1
                EndIf
          EndSelect
          SetGadgetText(g_text,Mid(text,page_start(page_number),page_size(page_number)))
          SetGadgetText(g_counter,Str(page_number)+"/"+Str(page_count))
        Case #PB_Event_Gadget
          Select EventGadget()
              Case g_previous
                page_number = page_number-1
              Case g_next
                page_number = page_number+1
              Case g_done
                event = #PB_Event_CloseWindow
          EndSelect
          SetGadgetText(g_text,Mid(text,page_start(page_number),page_size(page_number)))
          SetGadgetText(g_counter,Str(page_number)+"/"+Str(page_count))
    EndSelect
  Until event = #PB_Event_CloseWindow
  CloseWindow(w_showhelp)
  FreeFont(font_nr)
  ;
EndProcedure

Procedure.s x_peeks(addr.i,length.i=-1,flags.i=-1,terminator.s=""); read string from mem until a null is found or max length is reached
  Protected string.s, p.l
  ; Global x_retval.i, x_peeks_read.i
  ;
  ; *** read a string from memory until terminating condition is met
  ;
  ; in:     addr.i             - location in memory
  ;         [ length.i = n ]   - max length in BYTES
  ;                    = -1    - default: ignore
  ;         [ flags.i  = n ]   - #PB_Ascii, #PB_Unicode, #PB_UTF8
  ;                    = -1    - default: use #PB_Ascii if program is compiled in ascii mode, #PB_Unicode if compiled in unicode mode
  ;         terminator.s       - seperator
  ; retval: .s                 - string found
  ; out:    x_retval.i         - length of string as found in memory in BYTES
  ;         x_peeks_read.i     - as x_retval.i
  ;
  ; notes:
  ;
  ; - terminating condition can be string, a null character, or hitting maximal length
  ; - purebasic's peeks() uses chars not bytes! (in 4.02 the included helpfile is wrong)
  ; - x_peeks() uses bytes not chars!
  ; - a terminating zero in unicode mode is actually TWO zeroes, ie. $ 00 00!
  ; - no support for UTF8 in memory, use ASCII
  ;
  If flags = -1
    CompilerIf #PB_Compiler_Unicode
      flags = #PB_Unicode
    CompilerElse
      flags = #PB_Ascii
    CompilerEndIf
  EndIf
  ;
  If length > 0
    If flags = #PB_Unicode
      string = PeekS(addr,length/2,flags)
    Else
      string = PeekS(addr,length,flags)
    EndIf
  Else
    string = PeekS(addr,-1,flags)
  EndIf
  ;
  x_retval = StringByteLength(string,flags)
  If x_retval < length Or length = -1
    If flags = #PB_Unicode
      x_retval = x_retval+2
    Else
      x_retval = x_retval+1
    EndIf
  EndIf
  ;
  If terminator > ""
    p = FindString(string,terminator,1)
    If p > 0
      string = Left(string,p-1)
      x_retval = StringByteLength(string+terminator,flags)
    EndIf
  EndIf
  ;
  x_peeks_read = x_retval
  ProcedureReturn string
EndProcedure
;}

;  ****************************
;  * Create application files *
;{ ****************************
CreateLocalFiles()
If OpenPreferences("vnc.prefs")=0
  CreatePreferences("vnc.prefs")
   OpenPreferences("vnc.prefs")
;App Prefs
    WritePreferenceInteger("EnableScrollLock", 0)
    WritePreferenceInteger("LogConnects", 0)
    WritePreferenceInteger("LoadLastConnect", 0)
    WritePreferenceString("LastConnect", "")
    WritePreferenceInteger("RemoveFiles", 0)
    WritePreferenceInteger("SaveWindowPosition", 0)
    WritePreferenceInteger("SortHosts", 0)
;VNC Prefs
    WritePreferenceInteger("Use256Colors", 0)
    WritePreferenceInteger("ConfirmExit", 0)
    WritePreferenceInteger("DisableAero", 0)
    WritePreferenceInteger("DisableClipboard", 0)
    WritePreferenceInteger("DisableRemoteInput", 0)
    WritePreferenceInteger("DisableScreensaver", 0)
    WritePreferenceInteger("DisableTrayIcon", 0)
    WritePreferenceInteger("EnableDriver", 0)
    WritePreferenceInteger("PromptUser", 0)
    WritePreferenceInteger("DisconnectAction", 0)
    WritePreferenceInteger("SemitransparentWindows", 0)
    WritePreferenceInteger("FileXfers", 0)
    WritePreferenceInteger("RDPMode", 0)
    WritePreferenceInteger("IdleTimeout", 0)
    WritePreferenceInteger("IdleTime",0)
    WritePreferenceInteger("MultiMonitorSupport", 0)
    WritePreferenceInteger("MyMaxCPU", 40)
    WritePreferenceInteger("OnlyPollOnEvent", 0)
    WritePreferenceInteger("RemoveWallpaper", 0)
    WritePreferenceInteger("SetMaxCPU", 0)
    WritePreferenceInteger("ShowStatus", 0)
    WritePreferenceInteger("ShowToolbar", 0)
    WritePreferenceInteger("ViewOnly", 0)
    WritePreferenceInteger("Autoscale", 0)
    WritePreferenceInteger("Fullscreen", 0)
    WritePreferenceInteger("StretchHost", 0)
;Misc Prefs
    WritePreferenceInteger("LastX", 5)
    WritePreferenceInteger("LastY", 5)
   ClosePreferences()
Else
  OpenPreferences("vnc.prefs")
;App Prefs
 enablescrllock.i=ReadPreferenceInteger("EnableScrollLock", 0)
          logme.i=ReadPreferenceInteger("LogConnects", 0)
savelastconnect.i=ReadPreferenceInteger("LoadLastConnect", 0)
    lastconnect.s=ReadPreferenceString("LastConnect", "")
    removefiles.i=ReadPreferenceInteger("RemoveFiles", 0)
        savepos.i=ReadPreferenceInteger("SaveWindowPosition", 0)
      sorthosts.i=ReadPreferenceInteger("SortHosts", 0)
;VNC Prefs
   lowcolormode.i=ReadPreferenceInteger("Use256Colors", 0)
    confirmexit.i=ReadPreferenceInteger("ConfirmExit", 0)
    disableclip.i=ReadPreferenceInteger("DisableClipboard", 0)
    disableaero.i=ReadPreferenceInteger("DisableAero", 0)
       noremote.i=ReadPreferenceInteger("DisableRemoteInput", 0)
   noscreensave.i=ReadPreferenceInteger("DisableScreensaver", 0)
    disabletray.i=ReadPreferenceInteger("DisableTrayIcon", 0)
   enabledriver.i=ReadPreferenceInteger("EnableDriver" ,0)
       promptme.i=ReadPreferenceInteger("PromptUser", 0)
     disconnect.i=ReadPreferenceInteger("DisconnectAction", 0)
semitransparent.i=ReadPreferenceInteger("SemitransparentWindows", 0)
       filexfer.i=ReadPreferenceInteger("FileXfers", 0)
        rdpmode.i=ReadPreferenceInteger("RDPMode", 0)
      mytimeout.i=ReadPreferenceInteger("IdleTimeout", 0)
     myidletime.i=ReadPreferenceInteger("IdleTime", 0)
         maxcpu.i=ReadPreferenceInteger("SetMaxCPU", 0)
  multimonitors.i=ReadPreferenceInteger("MultiMonitorSupport", 0)
    myownmaxcpu.i=ReadPreferenceInteger("MyMaxCPU", 0)
  polleventonly.i=ReadPreferenceInteger("OnlyPollOnEvent", 0)
    nowallpaper.i=ReadPreferenceInteger("RemoveWallpaper", 0)
         status.i=ReadPreferenceInteger("ShowStatus", 0)
        toolbar.i=ReadPreferenceInteger("ShowToolbar", 0)
       viewonly.i=ReadPreferenceInteger("ViewOnly", 0)
      autoscale.i=ReadPreferenceInteger("Autoscale", 0)
     fullscreen.i=ReadPreferenceInteger("Fullscreen", 0)
        stretch.i=ReadPreferenceInteger("StretchHost", 0)
;Misc Prefs
          lastx.i=ReadPreferenceInteger("LastX", 5)
          lasty.i=ReadPreferenceInteger("LastY", 5)
  ClosePreferences()
EndIf
;}

;  *******************************************************
;  * Code to ensure only one instance of program running *
;{ *******************************************************
 MutexID=CreateMutex_(0,1,"uVNC Remote Control")
 MutexError=GetLastError_()
 If MutexID=0 Or MutexError<>0
   MessageRequester("Error","uVNC Remote Control is already running.",#MB_ICONWARNING)
   End
 EndIf
;}

;  **************************************
;  * Create window and populate gadgets *
;{ **************************************
OpenWindow(#Window_0,lastx,lasty,450,450,"uVNC Remote Control",#PB_Window_SystemMenu|#PB_Window_MinimizeGadget)
 SetWindowCallback(@ColumnClickCallback(), #Window_0)
  AddWindowTimer(#Window_0,9999,250)
PanelGadget(#Panel_1,0,0,453,430)
;{ Connections
 AddGadgetItem(#Panel_1,-1,"Connections")
 If CreatePopupImageMenu(#Menu_PopUp)
   MenuItem(#PopUp_Disconnect,"Disconnect from",CatchImage(#Quit,?quit))
    MenuBar()
   MenuItem(#PopUp_EditDescription,"Edit description for",CatchImage(#Edit,?edit))
    MenuBar()
   MenuItem(#PopUp_RemoveHost, "",CatchImage(#Recycle,?recycle))
    DisableMenuItem(#Menu_PopUp,#PopUp_Disconnect,1)
 EndIf
  ListIconGadget(#Hosts_List,10,0,425,308,"Host Name",150,#PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_FullRowSelect|#PB_ListIcon_MultiSelect)
   AddGadgetColumn(#Hosts_List,1,"Description",226)
    SetGadgetItemAttribute(#Hosts_List,1,#PB_ListIcon_ColumnWidth,130)
   AddGadgetColumn(#Hosts_List,2,"Index",0);<-80 to view indexes, 0 to hide
   AddGadgetColumn(#Hosts_List,3,"Pointer",0);<-80 to view pointers, 0 to hide
  HyperLinkGadget(#Text_HostName,10,317,65,20,"Host Name:",#Blue)
   BalloonTip(#Window_0,#Text_HostName,"Click to clear the host name field","",#MB_ICONINFORMATION)
   StringGadget(#String_HostName,80,315,250,20,"")
    SendMessage_(GadgetID(#String_HostName),#EM_SETCUEBANNER,#True,@"Enter Computer Name or IP Address")
  HyperLinkGadget(#Text_Description,10,347,65,20,"Description:",#Blue)
   BalloonTip(#Window_0,#Text_Description,"Click to clear the description field","",#MB_ICONINFORMATION)
   StringGadget(#String_Description,80,345,250,20,"")
    SendMessage_(GadgetID(#String_Description),#EM_SETCUEBANNER,#True,@"Enter a Description")
  ButtonGadget(#Connect_Button,336,317,100,75,"Connect")
  HyperLinkGadget(#Text_Search,10,377,40,20,"Search:",#Blue)
   BalloonTip(#Window_0,#Text_Search,"Click to clear the search field","",#MB_ICONINFORMATION)
   StringGadget(#String_Search,80,375,250,20,"")
    SendMessage_(GadgetID(#String_Search),#EM_SETCUEBANNER,#True,@"Enter Search Parameters")
   AddKeyboardShortcut(#Window_0,#PB_Shortcut_Return,#Menu_EnterKey)
CreateStatusBar(#StatusBar0, WindowID(#Window_0))
AddStatusBarField(#PB_Ignore)
StatusBarText(#StatusBar0,0,"Ready",#PB_StatusBar_Center)
  SetActiveGadget(#String_Hostname)
CloseGadgetList()
;}
;{ Server Options
OpenGadgetList(#Panel_1)
AddGadgetItem(#Panel_1,-1,"Server Options")
FrameGadget(#Frame_1,10,10,425,380,"Server")
 CheckBoxGadget(#Server_CaptureSemiTransparentWindows,95,30,205,20,"Capture Semi-Transparent Windows")
 CheckBoxGadget(#Server_DisableAero,95,50,150,20,"Disable Aero")
 CheckBoxGadget(#Server_DisableScreensaver,95,70,150,20,"Disable Screen Saver")
 CheckBoxGadget(#Server_DisableTrayIcon,95,90,150,20,"Disable Tray Icon");70
  FrameGadget(#Frame_2,95,110,180,90,"Disconnect Action")
   OptionGadget(#Server_DisconnectNothing,100,130,160,20,"No Action")
   OptionGadget(#Server_DisconnectLock,100,150,155,20,"Lock Remote Workstation")
   OptionGadget(#Server_DisconnectLogoff,100,170,170,20,"Log Off Remote Workstation")
 CheckBoxGadget(#Server_EnableDriver,95,200,155,20,"Enable DDEngine Driver")
 CheckBoxGadget(#Server_EnableFileTransfers,95,220,150,20,"Enable File Transfers")
  ButtonGadget(#Server_IdleTimeout,94,240,150,20,"Idle Timeout")
 CheckBoxGadget(#Server_MultiMonitorSupport,95,260,150,20,"Multi-Monitor Support")
 CheckBoxGadget(#Server_OnlyPollOnEvent,95,280,195,20,"Only Poll on Event (KB/Mouse)")
 CheckBoxGadget(#Server_RDPMode,95,300,150,20,"RDP Mode")
 CheckBoxGadget(#Server_RemoveWallpaper,95,320,120,20,"Remove Wallpaper")
 CheckBoxGadget(#Server_MaxCPU,95,340,155,20,"Set Maximum CPU Usage:")
  StringGadget(#String_MaxCPU,252,339,50,20,"40",#PB_String_Numeric)
   DisableGadget(#String_MaxCPU,1)
CloseGadgetList()
;}
;{ Viewer Options
OpenGadgetList(#Panel_1)
AddGadgetItem(#Panel_1,-1,"Viewer Options")
 FrameGadget(#Frame_3,10,10,425,380,"Viewer")
 CheckBoxGadget(#Viewer_256Colors,95,30,160,20,"256 Color (8-Bit) Mode");Slow connections
 CheckBoxGadget(#Viewer_AutoScale,95,50,160,20,"Autoscale Viewer Window");Scale viewer to match remote screen
 CheckBoxGadget(#Viewer_ConfirmExit,95,70,180,20,"Confirm Exit (No Idle Timeout)")
 CheckBoxGadget(#Viewer_DisableClipboard,95,90,150,20,"Disable Clipboard")
 CheckBoxGadget(#Viewer_DisableRemoteInput,95,110,150,20,"Disable Remote Input")
 CheckBoxGadget(#Viewer_Fullscreen,95,130,150,20,"Fullscreen")
 CheckBoxGadget(#Viewer_PromptUser,95,150,150,20,"Prompt User to Connect")
 CheckBoxGadget(#Viewer_ShowToolbar,95,170,150,20,"Show VNC Toolbar");Show VNC Toolbar
 CheckBoxGadget(#Viewer_StatusWindow,95,190,160,20,"Show VNC Status Window")
 CheckBoxGadget(#Viewer_StretchScreen,95,210,150,20,"Stretch Remote Screen")
 CheckBoxGadget(#Viewer_ViewOnly,95,230,150,20,"View-Only")
CloseGadgetList()
;}
;{ App Options
OpenGadgetList(#Panel_1)
AddGadgetItem(#Panel_1,-1,"Program Options")
 FrameGadget(#Frame_4,10,10,425,380,"Options")
  CheckBoxGadget(#App_EnableScrollLock,95,30,285,20,"Enable Scroll Lock (Windows Hotkeys Passthrough)")
   CheckBoxGadget(#App_LastConnect,95,50,130,20,"Load Last Connection")
    CheckBoxGadget(#App_LogConnects,95,70,120,20,"Log Connections")
     CheckBoxGadget(#App_RemoveFilesOnExit,95,90,150,20,"Remove App Files on Exit")
      CheckBoxGadget(#App_SaveWindowPosition,95,110,140,20,"Save Window Position")
       CheckBoxGadget(#App_SortHostsOnExit,95,130,150,20,"Sort Hosts On Exit (A-Z)")
        ButtonGadget(#App_ClearHostsList,15,350,130,30,"Clear Hosts List")
         ButtonGadget(#App_ImportFromAD,162,350,131,30,"Import Hosts from AD")
          ButtonGadget(#App_Help,310,350,120,30,"Help")
           If FileSize("Update uVNC.exe")<>-1
            ButtonGadget(#App_Update,15,350,120,30,"Check for Update")
           EndIf
CloseGadgetList()
;}
;{ About
OpenGadgetList(#Panel_1)
AddGadgetItem(#Panel_1,-1,"About")
 FrameGadget(#Frame_5,10,10,425,380,"About")
  EditorGadget(#Editor_0,35,40,375,325,#PB_Editor_ReadOnly|1);0-Left,1-Center,2-Right
   HyperLinkGadget(#Weblink_1,35,370,40,15,"ADFind",#Blue)
   HyperLinkGadget(#Weblink_2,130,370,40,15,"PAExec",#Blue)
   HyperLinkGadget(#Weblink_3,220,370,50,15,"UltraVNC",#Blue)
   HyperLinkGadget(#Weblink_4,330,370,80,15,"My Homepage",#Blue)
    SetGadgetText(#Editor_0,#CRLF$+"uVNC Remote Control" + #CRLF$ +
                                         "by" + #CRLF$ +
	                                       "Daniel Ford" + #CRLF$ +
                                         "oldnesjunkie@gmail.com" + #CRLF$ +
	                                       "Version 1.0.7 - February 18, 2022" + #CRLF$ +
                                         "Uses ADFind version 1.56.00" + #CRLF$ +
                                         "Uses PAExec Version 1.28" + #CRLF$ +
                                         "Uses UltraVNC Version 1.3.6.0" + #CRLF$ + #CRLF$ +
                                         "Created with the following from the PureBasic Forums:"+#CRLF$+
                                         "FindStringRev by skywalk"+#CRLF$+
                                         "ListIcon Sort by netmaestro"+#CRLF$+
                                         "FindPartWin by PB"+#CRLF$+
                                         "SearchListIcon by infratec"+#CRLF$+
                                         "Anyone else I failed to mention :)")
CloseGadgetList()
;}
;}

;  ***************************
;  * Set Options accordingly *
;{ ***************************
;Disable RemoteInput
If noremote=1
  flip1=1
   SetGadgetState(#Viewer_DisableRemoteInput,1)
EndIf

;Prompt User to connect
If promptme=1
  flip2=1
   SetGadgetState(#Viewer_PromptUser,1)
EndIf

;Remove Wallpaper
If nowallpaper=1
  flip3=1
   SetGadgetState(#Server_RemoveWallpaper,1)
EndIf

;View Only Mode
If viewonly=1
  flip4=1
   SetGadgetState(#Viewer_ViewOnly,1)
EndIf

;Save Window Position
If savepos=1
 flip5=1
  SetGadgetState(#App_SaveWindowPosition,1) 
EndIf

;Sort Hosts on Exit
If sorthosts=1
 flip6=1
  SetGadgetState(#App_SortHostsOnExit,1)
EndIf

;Fullscreen on connect
If fullscreen=1
 flip7=1
  SetGadgetState(#Viewer_Fullscreen,1)
   DisableGadget(#Viewer_StretchScreen,0)
EndIf

;Stretch Host Screen
If fullscreen=0
  stretch=0
   flip8=0
    DisableGadget(#Viewer_StretchScreen,1)
EndIf

If stretch=1
 flip8=1
  SetGadgetState(#Viewer_StretchScreen,1)
EndIf

;Enable File Transfers
If filexfer=1
 flip9=1
  SetGadgetState(#Server_EnableFileTransfers,1)
EndIf

;Autoscale host to yur screen size if larger
If autoscale=1
 flip11=1
  SetGadgetState(#Viewer_AutoScale,1)
EndIf

;Show VNC Toolbar on connect
If toolbar=1
 flip12=1
  SetGadgetState(#Viewer_ShowToolbar,1)
EndIf

;Show connection status window
If status=1
  flip13=1
   SetGadgetState(#Viewer_StatusWindow, 1)
EndIf

;Enable RDP Mode
If rdpmode=1
  flip14=1
   SetGadgetState(#Server_RDPMode, 1)
EndIf

;Enable Logging
If logme=1
  flip15=1; Enable logging
   SetGadgetState(#App_LogConnects, 1)
EndIf

;Load last connection
If savelastconnect=1
  flip16=1
   SetGadgetState(#App_LastConnect, 1)
   If lastconnect<>""
     count=FindString(lastconnect,",")
      myhost.s=Left(lastconnect,count-1)
       SetGadgetText(#String_Hostname, myhost)
        left$=Left(lastconnect,Len(lastconnect))
       count=FindString(lastconnect,",")
      mydesc.s=Right(left$,(Len(left$)-(count)))
     SetGadgetText(#String_Description,mydesc)
   EndIf
EndIf

;Confirm Viewer exit
If mytimeout<>0
  DisableGadget(#Viewer_ConfirmExit, 1)
EndIf
If confirmexit=1
  flip17=1
   SetGadgetState(#Viewer_ConfirmExit, 1)
EndIf

;Disable server tray icon
If disabletray=1
  flip18=1
   SetGadgetState(#Server_DisableTrayIcon, 1)
EndIf

;Enable multi-monitor support
If multimonitors=1
  flip19=1
   SetGadgetState(#Server_MultiMonitorSupport, 1)
EndIf

;Viewer disconnect action
If disconnect=0
  flip20=1
   SetGadgetState(#Server_DisconnectNothing, 1)
ElseIf disconnect=1
  flip21=1
   SetGadgetState(#Server_DisconnectLock, 1)
ElseIf disconnect=2
  flip22=1
   SetGadgetState(#Server_DisconnectLogoff, 1)
EndIf

;View semi-transparent windows
If semitransparent=1
  flip23=1
   SetGadgetState(#Server_CaptureSemiTransparentWindows, 1)
EndIf

;Enable VNC Driver (ddengine64.dll)
If enabledriver=1
  flip24=1
   SetGadgetState(#Server_EnableDriver, 1)
EndIf

;Disable Clipboard
If disableclip=1
 flip25=1
  SetGadgetState(#Viewer_DisableClipboard, 1)
EndIf

;Disable Aero
If disableaero=1
  flip26=1
   SetGadgetState(#Server_DisableAero, 1)
EndIf

;Only Poll on event
If polleventonly=1
  flip27=1
   SetGadgetState(#Server_OnlyPollOnEvent, 1)
EndIf

;Set Maximum CPU Usage
If maxcpu=1
  flip29=1
   SetGadgetState(#Server_MaxCPU,1)
    DisableGadget(#String_MaxCPU,0)
EndIf

;Set MaxCPU String
SetGadgetText(#String_MaxCPU,Str(myownmaxcpu))

;Enable Scroll Lock
If enablescrllock=1
  flip30=1
   SetGadgetState(#App_EnableScrollLock,1)
EndIf

;Disable Screensaver
If noscreensave=1
  flip31=1
   SetGadgetState(#Server_DisableScreensaver,1)
EndIf

;Remove Files on Exit
If removefiles=1
  flip32=1
   SetGadgetState(#App_RemoveFilesOnExit,1)
EndIf

;256 Color Mode
If lowcolormode=1
  flip33=1
   SetGadgetState(#Viewer_256Colors, 1)
EndIf
;}

;  *********************
;  * Main program loop *
;{ *********************

;{ Add items to Hosts List
FillListIcon(#Hosts_List,"hosts.dat")
SetIcons()
SetColumnWidths()
If FileSize("adfind.exe")=-1
  HideGadget(#App_ImportFromAD,1)
EndIf
;}

Repeat

  event=WaitWindowEvent(1)

;{ Process Testing/Remove VNC
If event = #PB_Event_Timer And EventTimer() = 9999
CheckRunningProcesses()
EndIf
;}

;{ Disable Gadgets
   If CountGadgetItems(#Hosts_List)=0
     DisableGadget(#Hosts_List,1)
   Else
     DisableGadget(#Hosts_List,0)
   EndIf

   If GetGadgetText(#String_HostName) <> ""
      DisableGadget(#Connect_Button,0)
   Else
      DisableGadget(#Connect_Button,1)
   EndIf

   If FindPartWin(" - service mode")
     DisableGadget(#App_ClearHostsList,1)
     DisableGadget(#App_ImportFromAD,1)
   Else
     DisableGadget(#App_ClearHostsList,0)
     DisableGadget(#App_ImportFromAD,0)
   EndIf
;}

;  *******************
;{ ***Window Events***
 Select event

   Case #PB_Event_Gadget
     eventgadget=EventGadget()
      eventtype=EventType()
       eventwindow=EventWindow()

;  *******************
;{ ***Gadget Events***
     Select eventgadget

;{ ***Connections***
       Case #Text_Description
         SetGadgetText(#String_Description,"")

       Case #Text_HostName
         SetGadgetText(#String_Hostname,"")

       Case #Text_Search
         SetGadgetText(#String_Hostname,"")
          SetGadgetText(#String_Description,"")
           SetGadgetText(#String_Search,"")
            SetGadgetState(#Hosts_List,-1)
             RefreshList()

       Case #Connect_Button
         selected.s=GetGadgetText(#String_Hostname)
          If FindPartWin(selected+" ( ")
            serverselection.s=GetGadgetItemText(#Hosts_List,selection,0)
             myhwnd=FindPartWin(serverselection)
              ShowWindow_(myhwnd,#SW_RESTORE)
          Else
            ConnectHostButton()
          EndIf

       Case #String_Search
         If EventType()=#PB_EventType_Change
           find.s = GetGadgetText(#String_Search)
            SearchMe(find)
         EndIf
;}

;{ ***Server Options***
        Case #Server_CaptureSemiTransparentWindows; Capture Semi-transparent Windows
          flip23=1-flip23
          If flip23=1
            SetGadgetState(#Server_CaptureSemiTransparentWindows,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("SemitransparentWindows",1)
               ClosePreferences()
          Else
            SetGadgetState(#Server_CaptureSemiTransparentWindows,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("SemitransparentWindows",0)
               ClosePreferences()
          EndIf

        Case #Server_DisableAero
          flip26=1-flip26
          If flip26=1
            SetGadgetState(#Server_DisableAero,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("DisableAero",1)
               ClosePreferences()
          Else
            SetGadgetState(#Server_DisableAero,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("DisableAero",0)
               ClosePreferences()
          EndIf

        Case #Server_DisableScreensaver; Disable Screensaver
          flip31=1-flip31
          If flip31=1
            SetGadgetState(#Server_DisableScreensaver,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("DisableScreensaver",1)
             ClosePreferences()
          Else
            SetGadgetState(#Server_DisableScreensaver,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("DisableScreensaver",0)
             ClosePreferences()
          EndIf

        Case #Server_DisableTrayIcon; Disable system Tray Icon
          flip18=1-flip18
          If flip18=1
            SetGadgetState(#Server_DisableTrayIcon,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("DisableTrayIcon",1)
             ClosePreferences()
          Else
            SetGadgetState(#Server_DisableTrayIcon,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("DisableTrayIcon",0)
             ClosePreferences()
          EndIf

        Case #Server_DisconnectNothing
          flip20=1-flip20
          If flip20=1
            SetGadgetState(#Server_DisconnectNothing,1)
             flip21=0
              flip22=0
               OpenPreferences("vnc.prefs")
                WritePreferenceInteger("DisconnectAction",0)
                 ClosePreferences()
          EndIf

        Case #Server_DisconnectLock
          flip21=1-flip21
          If flip21=1
            SetGadgetState(#Server_DisconnectLock,1)
             flip20=0
              flip22=0
               OpenPreferences("vnc.prefs")
                WritePreferenceInteger("DisconnectAction",1)
                 ClosePreferences()
          EndIf

        Case #Server_DisconnectLogoff
          flip22=1-flip22
          If flip22=1
            SetGadgetState(#Server_DisconnectLogoff,1)
             flip20=0
              flip21=0
               OpenPreferences("vnc.prefs")
                WritePreferenceInteger("DisconnectAction",2)
                 ClosePreferences()
          EndIf

        Case #Server_EnableDriver
          flip24=1-flip24
          If flip24=1
            SetGadgetState(#Server_EnableDriver,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("EnableDriver",1)
             ClosePreferences()
          Else
            SetGadgetState(#Server_EnableDriver,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("EnableDriver",0)
             ClosePreferences()
          EndIf

        Case #Server_EnableFileTransfers; Enable File Transfers
          flip9=1-flip9
          If flip9=1
            SetGadgetState(#Server_EnableFileTransfers,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("FileXfers",1)
               ClosePreferences()
          Else
            SetGadgetState(#Server_EnableFileTransfers,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("FileXfers",0)
               ClosePreferences()
          EndIf

        Case #Server_IdleTimeout; Idle Timeout of 5 minutes
          IdleTimeout("Idle Timeout In Minutes (0=Disabled)")

        Case #Server_MaxCPU
          flip29=1-flip29
          If flip29=1
            SetGadgetState(#Server_MaxCPU,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("SetMaxCPU",1)
               DisableGadget(#String_MaxCPU,0)
                ClosePreferences()
          Else
            SetGadgetState(#Server_MaxCPU,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("SetMaxCPU",0)
               DisableGadget(#String_MaxCPU,1)
                ClosePreferences()
          EndIf

        Case #String_MaxCPU
          OpenPreferences("vnc.prefs")
           WritePreferenceInteger("MyMaxCPU",Val(GetGadgetText(#String_MaxCPU)))
            maxcputest.i=Val(GetGadgetText(#String_MaxCPU))
            If maxcputest>100
              MessageRequester("Warning","CPU maximum cannot be over 100.",#MB_ICONERROR)
               SetGadgetText(#String_MaxCPU,"100")
            ElseIf Left(Str(maxcputest),1)="0"
              MessageRequester("Warning","CPU maximum cannot start with a 0.",#MB_ICONERROR)
               SetGadgetText(#String_MaxCPU,"1")
            EndIf
            ClosePreferences()

        Case #Server_MultiMonitorSupport
          flip19=1-flip19
          If flip19=1
            SetGadgetState(#Server_MultiMonitorSupport,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("MultiMonitorSupport",1)
               ClosePreferences()
          Else
            SetGadgetState(#Server_MultiMonitorSupport,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("MultiMonitorSupport",0)
               ClosePreferences()
          EndIf

        Case #Server_OnlyPollOnEvent
          flip27=1-flip27
          If flip27=1
            SetGadgetState(#Server_OnlyPollOnEvent,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("OnlyPollOnEvent",1)
               ClosePreferences()
          Else
            SetGadgetState(#Server_OnlyPollOnEvent,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("OnlyPollOnEvent",0)
               ClosePreferences()
          EndIf

        Case #Server_RDPMode; Enable RDP Mode
          flip14=1-flip14
          If flip14=1
            SetGadgetState(#Server_RDPMode,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("RDPMode",1)
               ClosePreferences()
          Else
            SetGadgetState(#Server_RDPMode,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("RDPMode",0)
               ClosePreferences()
          EndIf

        Case #Server_RemoveWallpaper; Remove Wallpaper
          flip3=1-flip3
          If flip3=1
            SetGadgetState(#Server_RemoveWallpaper,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("RemoveWallpaper",1)
               ClosePreferences()
          Else
            SetGadgetState(#Server_RemoveWallpaper,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("RemoveWallpaper",0)
               ClosePreferences()
          EndIf
;}

;{ ***Viewer Options***
        Case #Viewer_256Colors
          flip33=1-flip33
          If flip33=1
            SetGadgetState(#Viewer_256Colors,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("Use256Colors",1)
               ClosePreferences()
          Else
            SetGadgetState(#Viewer_256Colors,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("Use256Colors",0)
               ClosePreferences()
          EndIf

        Case #Viewer_AutoScale; Scale viewer to best fit remote screensize
          flip11=1-flip11
          If flip11=1
            SetGadgetState(#Viewer_AutoScale,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("Autoscale",1)
               ClosePreferences()
          Else
            SetGadgetState(#Viewer_AutoScale,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("Autoscale",0)
               ClosePreferences()
          EndIf

        Case #Viewer_ConfirmExit
          flip17=1-flip17
          If flip17=1
            SetGadgetState(#Viewer_ConfirmExit,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("ConfirmExit", 1)
               ClosePreferences()
          Else
            SetGadgetState(#Viewer_ConfirmExit,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("ConfirmExit", 0)
               ClosePreferences()
          EndIf

        Case #Viewer_DisableClipboard
          flip25=1-flip25
          If flip25=1
            SetGadgetState(#Viewer_DisableClipboard,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("DisableClipboard",1)
               ClosePreferences()
          Else
            SetGadgetState(#Viewer_DisableClipboard,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("DisableClipboard",0)
               ClosePreferences()
          EndIf

        Case #Viewer_DisableRemoteInput; Disable Remote Input
          flip1=1-flip1
          If flip1=1
            SetGadgetState(#Viewer_DisableRemoteInput,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("DisableRemoteInput",1)
               ClosePreferences()
          Else
            SetGadgetState(#Viewer_DisableRemoteInput,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("DisableRemoteInput",0)
               ClosePreferences()
          EndIf

        Case #Viewer_Fullscreen; Viewer is fullscreen
          flip7=1-flip7
          If flip7=1
            SetGadgetState(#Viewer_Fullscreen,1)
             DisableGadget(#Viewer_StretchScreen,0)
              OpenPreferences("vnc.prefs")
               WritePreferenceInteger("Fullscreen",1)
                ClosePreferences()
          Else
            SetGadgetState(#Viewer_Fullscreen,0)
             SetGadgetState(#Viewer_StretchScreen,0)
              DisableGadget(#Viewer_StretchScreen,1)
               OpenPreferences("vnc.prefs")
                WritePreferenceInteger("Fullscreen",0)
                 WritePreferenceInteger("StretchHost",0)
                  ClosePreferences()
                   flip8=1-flip8
          EndIf

        Case #Viewer_PromptUser; Prompt User
          flip2=1-flip2
          If flip2=1
            SetGadgetState(#Viewer_PromptUser,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("PromptUser",1)
               ClosePreferences()
          Else
            SetGadgetState(#Viewer_PromptUser,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("PromptUser",0)
               ClosePreferences()
          EndIf

        Case #Viewer_ShowToolbar; Enable VNC Toolbar on viewer
          flip12=1-flip12
          If flip12=1
            SetGadgetState(#Viewer_ShowToolbar,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("ShowToolbar",1)
               ClosePreferences()
          Else
            SetGadgetState(#Viewer_ShowToolbar,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("ShowToolbar",0)
               ClosePreferences()
          EndIf

        Case #Viewer_StatusWindow; Show/Hide Connection Status Window
          flip13=1-flip13
          If flip13=1
            SetGadgetState(#Viewer_StatusWindow,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("ShowStatus",1)
               ClosePreferences()
          Else
            SetGadgetState(#Viewer_StatusWindow,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("ShowStatus",0)
               ClosePreferences()
          EndIf

        Case #Viewer_StretchScreen; Stretch remote screen to fit
          flip8=1-flip8
          If flip8=1
            SetGadgetState(#Viewer_StretchScreen,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("StretchHost",1)
               ClosePreferences()
          Else
            SetGadgetState(#Viewer_StretchScreen,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("StretchHost",0)
               ClosePreferences()
          EndIf

        Case #Viewer_ViewOnly; View Only
          flip4=1-flip4
          If flip4=1
            SetGadgetState(#Viewer_ViewOnly,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("ViewOnly",1)
               ClosePreferences()
          Else
            SetGadgetState(#Viewer_ViewOnly,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("ViewOnly",0)
               ClosePreferences()
          EndIf
;}

;{ ***App Options***

        Case #App_EnableScrollLock; Enable Hotkey Support
          flip30=1-flip30
          If flip30=1
            SetGadgetState(#App_EnableScrollLock,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("EnableScrollLock",1)
               ClosePreferences()
          Else
            SetGadgetState(#App_EnableScrollLock,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("EnableScrollLock",0)
               ClosePreferences()
          EndIf

        Case #App_ClearHostsList; Clear Hosts List
          ClearHosts()

        Case #App_Help
          x_littlehelp("Help","",p_myhelptext,#PB_Ascii)

        Case #App_ImportFromAD
          ImportAD()

        Case #App_LogConnects; Log connections
          flip15=1-flip15
          If flip15=1
            SetGadgetState(#App_LogConnects,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("LogConnects",1)
               logme=1
                ClosePreferences()
          Else
            SetGadgetState(#App_LogConnects,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("LogConnects",0)
               logme=0
                ClosePreferences()
          EndIf

        Case #App_LastConnect; Load Last connection
          flip16=1-flip16
          If flip16=1
            SetGadgetState(#App_LastConnect, 1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("LoadLastConnect", 1)
               lastconnect=ReadPreferenceString("LastConnect","")
                ClosePreferences()
           If lastconnect<>""
             count=FindString(lastconnect,",")
              myhost.s=Left(lastconnect,count-1)
               SetGadgetText(#String_Hostname, myhost)
                left$=Left(lastconnect,Len(lastconnect))
                 count=FindString(lastconnect,",")
                  mydesc.s=Right(left$,(Len(left$)-(count)))
                   SetGadgetText(#String_Description,mydesc)
           EndIf
          Else
            SetGadgetState(#App_LastConnect, 0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("LoadLastConnect", 0)
               ClosePreferences()
                SetGadgetText(#String_Hostname, "")
                 SetGadgetText(#String_Description, "")
          EndIf

        Case #App_RemoveFilesOnExit; Save Window Position
          flip32=1-flip32
          If flip32=1
            SetGadgetState(#App_RemoveFilesOnExit,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("RemoveFiles",1)
               ClosePreferences()
          Else
            SetGadgetState(#App_RemoveFilesOnExit,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("RemoveFiles",0)
               ClosePreferences()
          EndIf


        Case #App_SaveWindowPosition; Save Window Position
          flip5=1-flip5
          If flip5=1
            SetGadgetState(#App_SaveWindowPosition,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("SaveWindowPosition",1)
               ClosePreferences()
          Else
            SetGadgetState(#App_SaveWindowPosition,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("SaveWindowPosition",0)
               ClosePreferences()
          EndIf

        Case #App_SortHostsOnExit; Sort Hosts List on Exit
          flip6=1-flip6
          If flip6=1
            SetGadgetState(#App_SortHostsOnExit,1)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("SortHosts",1)
               ClosePreferences()
          Else
            SetGadgetState(#App_SortHostsOnExit,0)
             OpenPreferences("vnc.prefs")
              WritePreferenceInteger("SortHosts",0)
               ClosePreferences()
          EndIf

        Case #App_Update
          CheckForUpdate()
;}

;{ ***About***
        Case #Weblink_1
          RunProgram("http://www.joeware.net/freetools/tools/adfind/index.htm","","")

        Case #Weblink_2
          RunProgram("https://www.poweradmin.com/paexec/","","")

        Case #Weblink_3
          RunProgram("http://www.uvnc.com","","")

        Case #Weblink_4
          RunProgram("https://oldnesjunkie.com","","")
;}

     EndSelect
;}
;  *******************

;  ******************
;{ ***Mouse Events***
     Select eventtype

       Case #PB_EventType_LeftClick
         
         Select eventgadget
             
           Case #Hosts_List
             selection=GetGadgetState(#Hosts_List)
              If GetGadgetText(#Hosts_List)<>""
              selected.s=GetGadgetItemText(#Hosts_List,selection,0)
                 SetGadgetText(#String_HostName, GetGadgetItemText(#Hosts_List,GetGadgetState(#Hosts_List),0))
                  SetGadgetText(#String_Description,GetGadgetItemText(#Hosts_List,GetGadgetState(#Hosts_List),1))
              EndIf
             
         EndSelect

       Case #PB_EventType_LeftDoubleClick

         Select eventgadget

           Case #Hosts_List
             selection=GetGadgetState(#Hosts_List)
              selected.s=GetGadgetItemText(#Hosts_List,selection,0)
              If FindPartWin(selected+" ( ")
                serverselection.s=GetGadgetItemText(#Hosts_List,selection,0)
                 myhwnd=FindPartWin(serverselection)
                  ShowWindow_(myhwnd,#SW_RESTORE)
              Else
                ConnectHostMouse()
              EndIf

         EndSelect

       Case #PB_EventType_RightClick

         Select eventgadget

           Case #Hosts_List
             DisableMenuItem(#Menu_PopUp,#PopUp_EditDescription,0)
              DisableMenuItem(#Menu_PopUp,#PopUp_RemoveHost,0)
;May remove this later
         If FindPartWin("service mode")=#False
            DisableMenuItem(#Menu_PopUp,#PopUp_RemoveHost,0)
         Else
           DisableMenuItem(#Menu_PopUp,#PopUp_RemoveHost,1)
         EndIf
;--------------------
              If GetGadgetText(#Hosts_List)<>""
               totalItemsSelected = SendMessage_(GadgetID(#Hosts_List), #LVM_GETSELECTEDCOUNT, 0, 0)
               If totalItemsSelected=1
                 SetMenuItemText(#Menu_PopUp,#PopUp_Disconnect,"Disconnect from "+GetGadgetText(#Hosts_List))
                  SetMenuItemText(#Menu_PopUp,#PopUp_EditDescription,"Edit description for "+GetGadgetText(#Hosts_List)+" ?")
                   SetMenuItemText(#Menu_PopUp,#PopUp_RemoveHost,"Remove "+GetGadgetText(#Hosts_List)+" ?")
                    selection=GetGadgetState(#Hosts_List)
                     selected.s=GetGadgetItemText(#Hosts_List,selection,0)
                If FindPartWin(selected+" (")
                  DisableMenuItem(#Menu_PopUp, #PopUp_Disconnect,0)
                   DisableMenuItem(#Menu_PopUp,#PopUp_EditDescription,0);1
                    DisableMenuItem(#Menu_PopUp, #PopUp_RemoveHost,1)
                Else
                  DisableMenuItem(#Menu_PopUp, #PopUp_Disconnect,1)
                EndIf
               Else
                 SetMenuItemText(#Menu_PopUp,#PopUp_RemoveHost,"Remove all selected items ?")
                  DisableMenuItem(#Menu_PopUp,#PopUp_EditDescription,1)
               EndIf
              DisplayPopupMenu(#Menu_PopUp,WindowID(#Window_0))
             EndIf

         EndSelect

     EndSelect
;}
;  ******************

;  *****************
;{ ***Menu Events***
   Case #PB_Event_Menu

     Select EventMenu()

       Case #Menu_EnterKey; Enter Key Shortcut
         selected.s=GetGadgetText(#Hosts_List)
         If GetGadgetState(#Panel_1)=0
          If GetGadgetText(#String_HostName)<>""
           If FindPartWin(selected+" ( ")
             serverselection.s=GetGadgetItemText(#Hosts_List,selection,0)
              myhwnd=FindPartWin(serverselection)
               ShowWindow_(myhwnd,#SW_RESTORE)
           Else
            ConnectHostButton()
           EndIf
         EndIf
        EndIf

       Case #PopUp_Disconnect
         DisconnectFromPC()

       Case #PopUp_EditDescription
         myhostname=GetGadgetItemText(#Hosts_List,GetGadgetState(#Hosts_List))
          mydescription=GetGadgetItemText(#Hosts_List,GetGadgetState(#Hosts_List),1)
           SetGadgetText(#String_HostName,myhostname)
            SetGadgetText(#String_Description,mydescription)
             EditMyDescription("Edit Description")

       Case #PopUp_RemoveHost; Remove Host Pop-Up Menu
         RemoveHost()

     EndSelect
;}
;  *****************

;  *********************
;{ ***Mouseover Event***
   Case #WM_MOUSEMOVE
     If IsMouseOver(GadgetID(#Hosts_List))
       GetCursorPos_(p.POINT)
        ScreenToClient_ (GadgetID(#Hosts_List), @p)           
         is\pt\x = p\x
          is\pt\y = p\y
           index = SendMessage_(GadgetID(#Hosts_List),#LVM_GETHOTITEM ,0,0)
            SendMessage_(GadgetID(#Hosts_List),#LVM_SUBITEMHITTEST ,0,@is)
      If is\iItem >= 0 And index >= 0
        SetActiveGadget(#Hosts_List)
         SetGadgetItemColor(#Hosts_List,olditem,#PB_Gadget_BackColor,-1)
          SetGadgetItemColor(#Hosts_List,is\iItem,#PB_Gadget_BackColor,RGB(229,243,255))
           olditem = is\iItem
      Else
        SetGadgetItemColor(#Hosts_List,olditem,#PB_Gadget_BackColor,-1)
         SetGadgetItemColor(#Hosts_List,is\iItem,#PB_Gadget_BackColor,-1)
      EndIf
     EndIf
;}
;  *********************

;  *************************
;{ ***Close Window Events***
   Case #PB_Event_CloseWindow
    If FindPartWin("- service mode") Or FindPartWin("- connection dropped")
     myanswer=MessageRequester("Warning","There are active uVNC Viewer sessions."+#CRLF$+"Do you want to close the application?"+#CRLF$+"This will leave uVNC running on the remote computer(s)."+#CRLF$+"You will have to reconnect and close normally to remove the service.",#PB_MessageRequester_YesNo|#MB_ICONWARNING)
     If myanswer=#PB_MessageRequester_Yes
       Goto closeapp
     Else
       ;do nothing
     EndIf
    Else
     closeapp:
       SetWindowState(#Window_0,#PB_Window_Normal)
        DeleteDirectory("View","*.vnc",#PB_FileSystem_Force)
      If GetGadgetState(#App_RemoveFilesOnExit)=1
        DeleteDirectory("View", "", #PB_FileSystem_Recursive| #PB_FileSystem_Force)
         DeleteDirectory("Serve", "", #PB_FileSystem_Recursive|#PB_FileSystem_Force)
          DeleteDirectory("Serve86", "", #PB_FileSystem_Recursive|#PB_FileSystem_Force)
           DeleteFile("paexec.exe", #PB_FileSystem_Force)
      EndIf
       If GetGadgetState(#App_EnableScrollLock)=1
        If GetKeyState_(#VK_SCROLL)=1
          keybd_event_(#VK_SCROLL,0,0,0)
           keybd_event_(#VK_SCROLL,0,#KEYEVENTF_KEYUP,0)
        EndIf
       EndIf
          If flip5=1
            OpenPreferences("vnc.prefs")
             WritePreferenceInteger("LastX",WindowX(#Window_0))
              WritePreferenceInteger("LastY",WindowY(#Window_0))
               ClosePreferences()
          Else
            OpenPreferences("vnc.prefs")
             WritePreferenceInteger("LastX",5)
              WritePreferenceInteger("LastY",5)
               ClosePreferences()
          EndIf
           If flip6=1
            If CountGadgetItems(#Hosts_List)>1
              SortFile("hosts.dat")
            EndIf
          EndIf
            ReleaseMutex_(MutexID)
             CloseHandle_(MutexID)
          End
    EndIf
;}
;  *************************

 EndSelect
;}
;  *******************

ForEver
;}

;  ********************
;  * Include binaries *
;{ ********************
DataSection

  server32start:
  IncludeBinary "Includes\VNC86\winvnc.exe"
  server32end:

  ddengine32start:
  IncludeBinary "Includes\VNC86\ddengine.dll"
  ddengine32end:

  viewer64start:
  IncludeBinary "Includes\VNC\vncviewer.exe"
  viewer64end:

  server64start:
  IncludeBinary "Includes\VNC\winvnc.exe"
  server64end:

  ddengine64start:
  IncludeBinary "Includes\VNC\ddengine64.dll"
  ddengine64end:

  remotestart:
  IncludeBinary "Includes\paexec.exe"
  remoteend:

  PCConnected:
  IncludeBinary "gfx\monitor.ico"

  PCBlank:
  IncludeBinary "gfx\blank.ico"

  edit:
  IncludeBinary "gfx\edit.ico"

  quit:
  IncludeBinary "gfx\quit.ico"

  recycle:
  IncludeBinary "gfx\recycle.ico"

EndDataSection 
;}
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 1838
; Folding = AAAAIAAAAAAA+
; EnableThread
; EnableXP
; UseIcon = gfx\Icon.ico
; Executable = C:\Temp\uVNCRemoteControl.exe
; Debugger = IDE
; Warnings = Display
; IncludeVersionInfo
; VersionField0 = 1.0.0.0
; VersionField1 = 1.0.0.0
; VersionField2 = OldNESJunkie
; VersionField3 = VNC Remote Control
; VersionField4 = 1.0
; VersionField5 = 1.0
; VersionField6 = VNC Remote Control
; VersionField7 = VNCRemoteControl
; VersionField8 = VNCRemoteControl.exe
; VersionField14 = http://www.oldnesjunkie.com