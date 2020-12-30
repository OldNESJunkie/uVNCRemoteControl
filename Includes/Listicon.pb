Structure nslist
   myhostname.s
   mydescription.s
EndStructure

Define Pos.Point ;-<--Search List Icon Function

Structure LVWSORT
   hWndListView.l ; Window handle of the ListView controls
   SortKey.l ; Column to be sorted
   SortType.b ; Type of data to be sorted
   SortOrder.b ; Sort direction
   DateFormat.s ; Mask for 'ParseDate'
EndStructure

Global NewList nslist.nslist()

Enumeration ; Type of Column Sort
#SortString
#SortNumeric
#SortFloat
#SortDate
#SortAutoDetect
EndEnumeration

Enumeration ; Column Sort States
#NoSort   ; No Sorting
#AscSort  ; Ascending Sorting
#DescSort ; Descending Sorting
EndEnumeration

Procedure LIG_AlignColumn(gadget, index, format)
       ; change text alignment for columns
       ; #LVCFMT_LEFT / #LVCFMT_CENTER / #LVCFMT_RIGHT
       Protected lvc.LV_COLUMN
       lvc\mask = #LVCF_FMT
       lvc\fmt = format
       
       SendMessage_(GadgetID(gadget), #LVM_SETCOLUMN, index, @lvc)
EndProcedure

Procedure LIG_SetColumnWidth(gadget,index,new_width)
       ; change column header width
       SendMessage_(GadgetID(gadget),#LVM_SETCOLUMNWIDTH,index,new_width)
EndProcedure

Procedure LIG_SetSortIcon(ListGadget.i, Column.i, SortOrder.i)
    ; http://stackoverflow.com/questions/254129/how-To-i-display-a-sort-arrow-in-the-header-of-a-List-view-column-using-c   
       Protected ColumnHeader.i
       Protected ColumnCount.i
       Protected hditem.HD_ITEM
       Protected Cnt.i
       
       ColumnHeader=SendMessage_(GadgetID(ListGadget), #LVM_GETHEADER, 0, 0)
         
       ColumnCount=SendMessage_(ColumnHeader, #HDM_GETITEMCOUNT, 0, 0)
       
       For Cnt=0 To ColumnCount-1
          hditem\mask=#HDI_FORMAT
         
          If SendMessage_(ColumnHeader, #HDM_GETITEM, Cnt, @hditem)=0
             Debug "Error setting the sort icon!"
          EndIf
         
          hditem\mask=#HDI_FORMAT
          If (Cnt=Column And SortOrder<>#NoSort)
             Select SortOrder
                Case #AscSort ; wenn aufsteigend sortiert werden soll
                   hditem\fmt& ~#HDF_SORTDOWN
                   hditem\fmt|#HDF_SORTUP
                   Debug "sortup"
                Case #DescSort
                   hditem\fmt& ~#HDF_SORTUP
                   hditem\fmt|#HDF_SORTDOWN               
                   Debug "sortdown"
             EndSelect
          Else
             hditem\fmt& ~#HDF_SORTUP
             hditem\fmt& ~#HDF_SORTDOWN
          EndIf

          If (SendMessage_(ColumnHeader, #HDM_SETITEM, Cnt, @hditem)=0)
             Debug "ERROR! LIG_SetSortIcon 2"
          EndIf
         
       Next
EndProcedure

Procedure.b LIG_GetSortOrder(ListGadget.i, Column.i)
       Protected ColumnHeader.i
       Protected hditem.HD_ITEM
       Protected RetVal.b
       
       ColumnHeader=SendMessage_(GadgetID(ListGadget), #LVM_GETHEADER, 0, 0)
         
       hditem\mask=#HDI_FORMAT
       
       If SendMessage_(ColumnHeader, #HDM_GETITEM, Column, @hditem)
          If (hditem\fmt&#HDF_SORTUP)=#HDF_SORTUP
             Debug "sortup"
             RetVal=#AscSort
          ElseIf (hditem\fmt&#HDF_SORTDOWN)=#HDF_SORTDOWN
             Debug "sortdown"
             RetVal=#DescSort
          Else
             Debug "nosort"
             RetVal=#NoSort
          EndIf
         
       Else
          Debug "ERROR! LIG_GetSortOrder"
          RetVal=-1
         
       EndIf
       
       ProcedureReturn RetVal
EndProcedure

Procedure LIG_EnsureVisible(Gadget.i, Line.i)
       ; makes sure the line is visible
       SendMessage_(GadgetID(Gadget), #LVM_ENSUREVISIBLE, Line, #True)
EndProcedure

Procedure.b IsNumChar(*Text, Position.i=1)
       Select Asc(PeekS(*Text+(Position-1)*SizeOf(Character), 1))
          Case 48 To 57
             ProcedureReturn #True
          Default
             ProcedureReturn #False
       EndSelect
EndProcedure

Procedure.l CompareStrings(*sEntry1, *sEntry2, SortOrder.b)
       ; ' -----------------------------------------------------
       ; ' Returns whether the first of the two different
       ; ' Elements are larger according to the parameter SortOrder
       ; ' (1 for ascending sorting) or smaller (-1 for
       ; ' Ascending order) as the second element.
       ; ' Same elements have already been distributed in CompareFunc-
       ; ' Closed; Otherwise 0 would be returned to them.
       ; ' -----------------------------------------------------
       ; ' Return value depending on desired sorting:
       If SortOrder=#AscSort
          ; Ascending order of two different strings
          If CompareMemoryString(*sEntry1, *sEntry2, #PB_String_NoCase)=#PB_String_Lower
             ProcedureReturn -1
          Else
             ProcedureReturn 1
          EndIf
       Else ; Descending sorting
          If CompareMemoryString(*sEntry1, *sEntry2, #PB_String_NoCase)=#PB_String_Greater
             ProcedureReturn -1
          Else
             ProcedureReturn 1
          EndIf
       EndIf
EndProcedure

Procedure.l CompareNumbers(sEntry1.s, sEntry2.s, SortOrder.b)
       ; ' -----------------------------------------------------
       ; ' Returns whether the first of the two different
       ; ' Elements are larger according to the parameter SortOrder
       ; ' (1 for ascending sorting) or smaller (-1 for Ascending sorting
       ; ' ) as the second element.
       ; ' Same elements have already been distributed in CompareFunc-
       ; ' Closed; Otherwise 0 would be returned to them.
       ; ' -----------------------------------------------------
       ; ' Return value depending on desired sorting:
       If SortOrder=#AscSort
          ; Ascending order of two different numbers
          If Val(sEntry1)<Val(sEntry2)
             ProcedureReturn -1
          Else
             ProcedureReturn 1
          EndIf
       Else ; Descending sorting
          If Val(sEntry1)>Val(sEntry2)
             ProcedureReturn -1
          Else
             ProcedureReturn 1
          EndIf
       EndIf
EndProcedure

Procedure.l CompareFloat(sEntry1.s, sEntry2.s, SortOrder.b)
       ; ' -----------------------------------------------------
       ; ' Gibt zurück, ob das erste der beiden unterschiedlichen
       ; ' Elemente nach Maßgabe des Parameters SortOrder größer
       ; ' (1 bei aufsteigender Sortierung) oder kleiner (-1 bei
       ; ' aufsteigender Sortierung) als das zweite Element ist.
       ; ' Gleiche Elemente wurden bereits in CompareFunc ausge-
       ; ' schlossen; für sie wäre sonst 0 zurückzugeben.
       ; ' -----------------------------------------------------
       ; ' Return value depending on desired sorting:
       ReplaceString(sEntry1, ",", ".", #PB_String_InPlace, 1, 1) ; ersetze Dezimalkomma durch Punkt, damit ValF korrekt arbeitet
       ReplaceString(sEntry2, ",", ".", #PB_String_InPlace, 1, 1)
       If SortOrder=#AscSort
          ; Ascending order of two different numbers
          If ValF(sEntry1)<ValF(sEntry2)
             ProcedureReturn -1
          Else
             ProcedureReturn 1
          EndIf
       Else ; Descending sorting
          If ValF(sEntry1)>ValF(sEntry2)
             ProcedureReturn -1
          Else
             ProcedureReturn 1
          EndIf
       EndIf         
EndProcedure

Procedure.l CompareDate(sEntry1.s, sEntry2.s, SortOrder.b, sDateMask.s)
       ; ' -----------------------------------------------------
       ; ' Gibt zurück, ob das erste der beiden unterschiedlichen
       ; ' Elemente nach Maßgabe des Parameters SortOrder größer
       ; ' (1 bei aufsteigender Sortierung) oder kleiner (-1 bei
       ; ' aufsteigender Sortierung) als das zweite Element ist.
       ; ' Gleiche Elemente wurden bereits in CompareFunc ausge-
       ; ' schlossen; für sie wäre sonst 0 zurückzugeben.
       ; ' -----------------------------------------------------
       ; ' Rückgabewert je nach erwünschter Sortierung:
       If SortOrder=#AscSort
          ; Aufsteigende Sortierung zweier unterschiedlicher Zahlen
          If ParseDate(sDateMask, sEntry1)<ParseDate(sDateMask, sEntry2)
             ProcedureReturn -1
          Else
             ProcedureReturn 1
          EndIf
       Else ; Absteigende Sortierung
          If ParseDate(sDateMask, sEntry1)>ParseDate(sDateMask, sEntry2)
             ProcedureReturn -1
          Else
             ProcedureReturn 1
          EndIf
       EndIf         
EndProcedure

Procedure.s LvwGetText(*ListViewSort.LVWSORT, lParam.l)
       ; ' -----------------------------------------------------
       ; ' Ermittelt aus dem Fensterhandle des ListView-
       ; ' Steuerelements, der in ListViewSort.SortKey
       ; ' angegebenen (nullbasierten) Spalte im ListView
       ; ' und der an CompareFunc übergebenen Werte lParam1/2
       ; ' die davon repräsentierten Zelleninhalte.
       ; ' -----------------------------------------------------
       ; 20130623..nalor..Check if AllocateMemory succeeds
       ;                  freememory at the end (kudos to 'Little John')
       Protected udtFindInfo.LV_FINDINFO
       Protected udtLVItem.LV_ITEM
       Protected lngIndex.l
       Protected *baBuffer
       Protected lngLength.l
       Protected RetVal.s=""
       *baBuffer=AllocateMemory(512)
       If (*baBuffer)
          ; Auf Basis des Index den Text der Zelle auslesen:
          udtLVItem\mask=#LVIF_TEXT
          udtLVItem\iSubItem=*ListViewSort\SortKey
          udtLVItem\pszText=*baBuffer
          udtLVItem\cchTextMax=(512/SizeOf(Character))-1
          lngLength = SendMessage_(*ListViewSort\hWndListView, #LVM_GETITEMTEXT, lParam, @udtLVItem)
          ; Byte-Array in passender Länge als String-Rückgabewert kopieren:
          If lngLength > 0
             RetVal = PeekS(*baBuffer, lngLength)
          EndIf
          FreeMemory(*baBuffer)
       Else
          Debug "ERROR!! Allocating memory (LvwGetText)"
       EndIf
       ProcedureReturn RetVal
EndProcedure

Procedure.l CompareFunc(lParam1.l, lParam2.l, lParamSort.l)
       ; ' -----------------------------------------------------
       ; ' Vergleichsfunktion CompareFunc
       ; ' -----------------------------------------------------
       ; ' Verglichen werden jeweils zwei Elemente der zu
       ; ' sortierenden Spalte des ListView-Steuerelements,
       ; ' die über lParam1 und lParam2 angegeben werden.
       ; ' Hierbei wird über den Rückgabewert der Funktion
       ; ' bestimmt, welches der beiden Elemente als größer
       ; ' gelten soll (hier für Aufwärtssortierung):
       ; ' * Element 1 < Element 2: Rückgabewert < 0
       ; ' * Element 1 = Element 2: Rückgabewert = 0
       ; ' * Element 1 > Element 2: Rückgabewert > 0
       ; ' -----------------------------------------------------
       Protected *ListViewSort.LVWSORT
       Protected sEntry1.s
       Protected sEntry2.s
       Protected vCompare1.s ; As Variant
       Protected vCompare2.s ; As Variant
       ; In lParamSort von SortListView als Long-Pointer übergebene LVWSORT-Struktur abholen, um auf deren
       ; Werte zugreifen zu können:
       *ListViewSort=lParamSort
       ; Die Werte der zu vergleichenden Elemente werden mithilfe der privaten Funktion LvwGetText aus
       ; den Angaben lParam1 und lParam2 ermittelt:
       sEntry1 = LvwGetText(*ListViewSort, lParam1)
       sEntry2 = LvwGetText(*ListViewSort, lParam2)
       ; Sind die Elemente gleich, kann die Funktion sofort mit dem aktuellen Rückgabewert 0
       ; verlassen werden:
       If sEntry1 = sEntry2
          ProcedureReturn 0
       EndIf
       ; Für die Sortierung wird unterschieden zwischen Zahlen, Fließkommazahlen und allgemeinen Strings. Hierfür
       ; steht jeweils eine separate, private Vergleichsfunktion zur Verfügung.
       Select *ListViewSort\SortType
          Case #SortNumeric ; ' Spalteninhalte sind Zahlen
             ProcedureReturn CompareNumbers(sEntry1, sEntry2, *ListViewSort\SortOrder)
          Case #SortFloat ; ' Spalteninhalte sind Zahlen mit Nachkommastellen
             ProcedureReturn CompareFloat(sEntry1, sEntry2, *ListViewSort\SortOrder)
          Case #SortString;  ' Spalteninhalte sind Strings
             ProcedureReturn CompareStrings(@sEntry1, @sEntry2, *ListViewSort\SortOrder)
          Case #SortDate
             ProcedureReturn CompareDate(sEntry1, sEntry2, *ListViewSort\SortOrder, *ListViewSort\DateFormat)
       EndSelect
EndProcedure

Procedure.s GetDateFormat(Date.s)
       Debug "GetDateFormat >"+Date+"<"
       
       Protected Diff.i
       
       Diff=Len(Date)-CountString(Date, "0")-CountString(Date, "1")-CountString(Date, "2")-CountString(Date, "3")-CountString(Date, "4")-CountString(Date, "5")-CountString(Date, "6")-CountString(Date, "7")-CountString(Date, "8")-CountString(Date, "9")   
       
       Select Diff
          Case 2
             If Len(Date)=10 ; Date 'dd.mm.yyyy', 'mm.dd.yyyy' or 'yyyy.mm.dd'

                If (Not IsNumChar(@Date, 5) And Not IsNumChar(@Date, 8)) ; yyyy.mm.dd
                   ProcedureReturn "" ; faster to sort as string
                   
                ElseIf (Not IsNumChar(@Date, 3) And Not IsNumChar(@Date, 6)) ; dd.mm.yyyy or mm.dd.yyyy
                   If Val(Mid(Date, 4, 2))>12 ; is it mm.dd.yyyy?
                      ProcedureReturn "%mm"+Mid(Date, 3, 1)+"%dd"+Mid(Date, 6, 1)+"%yyyy"
                   Else ; default is dd.mm.yyyy
                      ProcedureReturn "%dd"+Mid(Date, 3, 1)+"%mm"+Mid(Date, 6, 1)+"%yyyy"
                   EndIf
                   
                Else
                   ProcedureReturn "" ; not a date - sort as string
                EndIf
             Else
                ProcedureReturn "" ; not a date - sort as string
             EndIf
             
          Case 4
             If Len(Date)=16 ;yyyy-mm-dd hh:mm, dd-mm-yyyy hh:mm or mm-dd-yyyy hh:mm
               
                If (Not IsNumChar(@Date, 5) And Not IsNumChar(@Date, 8)) ; yyyy.mm.dd xxxxx
                   ProcedureReturn "" ; faster to sort as string
                   
                ElseIf (Not IsNumChar(@Date, 3) And Not IsNumChar(@Date, 6)) ; dd.mm.yyyy hh:mm or mm.dd.yyyy hh:mm
                   If Val(Mid(Date, 4, 2))>12 ; is it mm.dd.yyyy?
                      ProcedureReturn "%mm"+Mid(Date, 3, 1)+"%dd"+Mid(Date, 6, 1)+"%yyyy"+Mid(Date, 11, 1)+"%hh"+Mid(Date, 14, 1)+"%ii"
                   Else ; default is dd.mm.yyyy
                      ProcedureReturn "%dd"+Mid(Date, 3, 1)+"%mm"+Mid(Date, 6, 1)+"%yyyy"+Mid(Date, 11, 1)+"%hh"+Mid(Date, 14, 1)+"%ii"
                   EndIf
                   
                Else
                   ProcedureReturn "" ; not a date - sort as string
                EndIf
             Else
                ProcedureReturn "" ; not a date - sort as string
             EndIf           
                   
          Case 5 ; 5 other chars, possibly DateTime?
             
             If Len(Date)=19 ;yyyy-mm-dd hh:mm, dd-mm-yyyy hh:mm or mm-dd-yyyy hh:mm
               
                If (Not IsNumChar(@Date, 5) And Not IsNumChar(@Date, 8)) ; yyyy.mm.dd xxxxx
                   ProcedureReturn "" ; faster to sort as string
                   
                ElseIf (Not IsNumChar(@Date, 3) And Not IsNumChar(@Date, 6)) ; dd.mm.yyyy hh:mm or mm.dd.yyyy hh:mm
                   If Val(Mid(Date, 4, 2))>12 ; is it mm.dd.yyyy?
                      ProcedureReturn "%mm"+Mid(Date, 3, 1)+"%dd"+Mid(Date, 6, 1)+"%yyyy"+Mid(Date, 11, 1)+"%hh"+Mid(Date, 14, 1)+"%ii"+Mid(Date, 17, 1)+"%ss"
                   Else ; default is dd.mm.yyyy
                      ProcedureReturn "%dd"+Mid(Date, 3, 1)+"%mm"+Mid(Date, 6, 1)+"%yyyy"+Mid(Date, 11, 1)+"%hh"+Mid(Date, 14, 1)+"%ii"+Mid(Date, 17, 1)+"%ss"
                   EndIf
                   
                Else
                   ProcedureReturn "" ; not a date - sort as string
                EndIf
             Else
                ProcedureReturn "" ; not a date - sort as string
             EndIf
             
          Default
             ProcedureReturn ""
       EndSelect
EndProcedure

Procedure SortListView(hWndListView.l, SortKey.l, SortType.b, SortOrder.b)
    ; ' -----------------------------------------------------
    ; ' Publicly Called Procedure SortListView
    ; ' for individual sorting of a ListView column
    ; ' -----------------------------------------------------
    ; ' hWndListView: Window handle of the ListView control
    ; ' SortKey:      Column (0-Based), that is sorted
    ; '               Should be (= Column Number - 1).
    ; ' SortType:     stString, to sort Strings (Default)
    ; '               stDate, to sort Dates
    ; '               stNumeric, to sort Numbers
    ; ' SortOrder:    lvwAscending, for Ascending sorting (Std.)
    ; '               lvwDescending, for Descending Sorting
    ; ' -----------------------------------------------------
       Protected udtLVWSORT.LVWSORT
       Protected sDateFormat.s, sTemp.s, GadId.i
       
       If SortType=#SortDate
          GadId=GetDlgCtrlID_(hWndListView)
          sDateFormat=GetDateFormat(GetGadgetItemText(GadId, 0, SortKey))
         
          If sDateFormat=""
             SortType=#SortString
          Else
             sTemp=GetDateFormat(GetGadgetItemText(GadId, CountGadgetItems(GadId)-1, SortKey))
             If sTemp=""
                SortType=#SortString
             Else
                If sTemp<>sDateFormat
                   If Left(sTemp, 3)="%mm" ; new format starts with %mm (.dd.yyyy) - if this US format is detected it has higher prio
                      sDateFormat=sTemp
                   EndIf
                EndIf
                sTemp=GetDateFormat(GetGadgetItemText(GadId, CountGadgetItems(GadId)/2, SortKey))
                If sTemp=""
                   SortType=#SortString
                Else
                   If sTemp<>sDateFormat
                      If Left(sTemp, 3)="%mm" ; new format starts with %mm (.dd.yyyy) - if this US format is detected it has higher prio
                         sDateFormat=sTemp
                      EndIf
                   EndIf
                EndIf   
             EndIf         
          EndIf
          udtLVWSORT\DateFormat=sDateFormat
          Debug "Final DateFormat >"+sDateFormat+"<"
       EndIf
       
       ; Übergebene Informationen in einer LVWSORT-Struktur zusammenfassen:
       udtLVWSORT\hWndListView=hWndListView
       udtLVWSORT\SortKey=SortKey
       udtLVWSORT\SortOrder=SortOrder
       udtLVWSORT\SortType=SortType   
       
       ; Eigene Sortierfunktionalität in der Funktion CompareFunc verwenden: Die Informationen der
       ; LVWSORT-Struktur wird mithilfe eines Zeigers auf die Variable udtLVWSORT beigegeben:
       SendMessage_(hWndListView, #LVM_SORTITEMSEX, @udtLVWSORT, @CompareFunc())
EndProcedure   

Procedure.b DetectOrderType(sText.s)
       Protected Diff.i
       
       Diff=Len(sText)-CountString(sText, "0")-CountString(sText, "1")-CountString(sText, "2")-CountString(sText, "3")-CountString(sText, "4")-CountString(sText, "5")-CountString(sText, "6")-CountString(sText, "7")-CountString(sText, "8")-CountString(sText, "9")   
       
       Select Diff
          Case 0 ; es sind nur Ziffern
             ProcedureReturn #SortNumeric
             
          Case 1 ; nur 1 anderes Zeichen
             If (CountString(sText, ",")>0 Or CountString(sText, ".")>0)
                ProcedureReturn #SortFloat
             ElseIf (Left(sText, 1)="$" Or Left(sText, 1)="%") ; es ist eine HEX oder Binär Zahl
                ProcedureReturn #SortNumeric
             Else
                ProcedureReturn #SortString
             EndIf
             
          Case 2 ; 2 andere Zeichen - evtl. Datum?
             
             If (Len(sText)=10 And
                 Not IsNumChar(@sText, 3) And Not IsNumChar(@sText, 6))
                ; dd-mm-yyyy or mm-dd-yyyy
                ProcedureReturn #SortDate
             Else
                ; yyyy-mm-dd
                ProcedureReturn #SortString
             EndIf
             
          Case 4 ; 4 other chars, possibly DateTime?
             
             If (Len(sText)=16 And
                 Not IsNumChar(@sText, 3) And Not IsNumChar(@sText, 6) And
                 Not IsNumChar(@sText, 11) And Not IsNumChar(@sText, 14))
                ;dd-mm-yyyy hh:mm or mm-dd-yyyy hh:mm
                ProcedureReturn #SortDate
             Else
                ProcedureReturn #SortString
             EndIf
             
          Case 5 ; 5 other chars, possibly DateTime?
             
             If (Len(sText)=19 And
                 Not IsNumChar(@sText, 3) And Not IsNumChar(@sText, 6) And
                 Not IsNumChar(@sText, 11) And Not IsNumChar(@sText, 14) And Not IsNumChar(@sText, 17))
                ;dd-mm-yyyy hh:mm:ss or mm-dd-yyyy hh:mm:ss
                ProcedureReturn #SortDate
             Else
                ProcedureReturn #SortString
             EndIf         
       
          Default
             ProcedureReturn #SortString
             
       EndSelect
EndProcedure

Procedure LIG_SortColumn(GadId.l, Column.l, OrderType.b=#SortAutoDetect)
       Protected ColCnt.i
       Protected Order.i
       Protected iStartT.i
       Protected iEndT.i
       Protected Temp.b
       
       Debug "LIG_SortColumn >"+Str(GadId)+"< Column >"+Str(Column)+"<"
       
       Select LIG_GetSortOrder(GadId, Column)
          Case #NoSort, #DescSort
             Order=#AscSort
          Case #AscSort
             Order=#DescSort
       EndSelect
       
       iStartT=ElapsedMilliseconds()
       
       If OrderType=#SortAutoDetect ; detect it automatically - check first, last and middle item of list
          OrderType=DetectOrderType(GetGadgetItemText(GadId, 0, Column))
          If (OrderType=DetectOrderType(GetGadgetItemText(GadId, CountGadgetItems(GadId)-1, Column)))
             If (OrderType<>DetectOrderType(GetGadgetItemText(GadId, CountGadgetItems(GadId)/2, Column)))
                Debug "Different OrderType - use SortString 2"
                OrderType=#SortString
             EndIf
          Else
             Debug "Different OrderType - use SortString"
             OrderType=#SortString
          EndIf
       EndIf   
       
       SortListView(GadgetID(GadId), Column, OrderType, Order)
       
       iEndT=ElapsedMilliseconds()
       
       Debug "Duration >"+StrF( (iEndT-iStartT)/1000, 2)+"<"
       
       LIG_SetSortIcon(GadId, Column, Order)
       
       If (GetGadgetState(GadId)>-1)
          LIG_EnsureVisible(GadId, GetGadgetState(GadId))
       EndIf
EndProcedure

Procedure ColumnClickCallback(hWnd, uMsg, wParam, lParam)
    Protected *msg.NM_LISTVIEW

    If uMsg=#WM_NOTIFY
       *msg=lParam
       If *msg\hdr\code=#LVN_COLUMNCLICK                     
          LIG_SortColumn(GetDlgCtrlID_(*msg\hdr\hwndfrom), *msg\iSubItem);, DetectOrderType(GetDlgCtrlID_(*msg\hdr\hwndfrom), *msg\iSubItem))
       EndIf
    EndIf
    ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

Procedure CountListiconColumn(gadget, maxcolumn, keyword.s)
If IsGadget(gadget)
  AddGadgetColumn(gadget, maxcolumn, keyword, 0)
    For i=0 To maxcolumn
      If GetGadgetItemText(gadget, -1, i)=keyword
        Break
      EndIf   
    Next
  RemoveGadgetColumn(gadget, i)
  ProcedureReturn i
EndIf
EndProcedure

Procedure FillListIcon(gadget, filename.s)
   If ReadFile(0,filename)
    SendMessage_(GadgetID(gadget),#WM_SETREDRAW, #False, 0)
     With nslist()
       While Eof(0)=0
         a$=ReadString(0,ReadStringFormat(0))
         p=FindString(a$,",")
        If a$<>","
         AddElement(nslist())
          \myhostname=Left(a$,p-1)
          \mydescription=Right(a$,(Len(a$)-(p)))
        EndIf
       Wend
     EndWith
   ForEach nslist()
     AddGadgetItem(gadget,-1,nslist()\myhostname+Chr(10)+nslist()\mydescription);<--Added extra Chr(10) at front
   Next
    ;ClearList(nslist())
    FreeList(nslist())
     CloseFile(0)
      SendMessage_(GadgetID(gadget),#WM_SETREDRAW, #True, 0)
   EndIf
EndProcedure

Procedure.S LIG_ColumnOrderGet(aListView.I)
  ; Convert the column order to a string representation.
  ; Maximum 26 columns.
  Protected.I lintCols, lintNumCols, hHeader
  Protected.S lstrOrder
  Protected Dim larrColOrder.I(1)
 
  If GadgetType(aListView) <> #PB_GadgetType_ListIcon
    ProcedureReturn #Empty$
  EndIf
 
  hHeader  = SendMessage_(GadgetID(aListView), #LVM_GETHEADER, 0, 0)
  lintNumCols = SendMessage_(hHeader,  #HDM_GETITEMCOUNT, 0, 0) - 1
 
  If lintNumCols > 25
    ProcedureReturn #Empty$
  EndIf
 
  ReDim larrColOrder(lintNumCols)
 
  SendMessage_(GadgetID(aListView), #LVM_GETCOLUMNORDERARRAY, lintNumCols + 1, larrColOrder())
 
  For lintCols = 0 To lintNumCols
    lstrOrder = lstrOrder + Chr(larrColOrder(lintCols) + 65)
  Next lintCols
 
  ProcedureReturn lstrOrder
EndProcedure

Procedure LIG_ColumnOrderSet(aListView.I, aOrder.S)
  ; Set the column order from a string representation.
  ; Maximum 26 columns.
  Protected.I lintCols, lintNumCols
  Protected.S lstrOrder
  Protected Dim larrColOrder.I(1)
 
  If GadgetType(aListView) <> #PB_GadgetType_ListIcon Or aOrder = #Empty$
    ProcedureReturn
  EndIf
 
  lintNumCols = Len(aOrder) - 1
 
  If lintNumCols > 25
    ProcedureReturn
  EndIf
 
  ReDim larrColOrder(lintNumCols)
  lstrOrder = UCase(aOrder)
 
  For lintCols = 0 To lintNumCols
    larrColOrder(lintCols) = Asc(Mid(aOrder, lintCols + 1, 1)) - 65
  Next lintCols
 
  SendMessage_(GadgetID(aListView), #LVM_SETCOLUMNORDERARRAY, lintNumCols + 1, larrColOrder()) 
EndProcedure

Procedure.i SearchListIcon(Gadget.i, Find$, *Result.Point, Column.i=#PB_Any)
 
  Protected.i Found, X, Y, i, j, MaxX, MaxY
 
  If IsGadget(Gadget)
    MaxY = CountGadgetItems(Gadget) - 1
   
    If Column = #PB_Any
      Repeat
        MaxX + 1
      Until GetGadgetItemAttribute(Gadget, -1, #PB_ListIcon_ColumnWidth, MaxX) = 0
      MaxX - 1
    EndIf
   
    For Y = 0 To MaxY
      If Column = #PB_Any
        For X = 0 To MaxX
          If FindString(GetGadgetItemText(Gadget, Y, X), Find$, #Null, #PB_String_NoCase)
            *Result\y = Y
            *Result\x = X
            Found = #True
            Break 2
          EndIf
        Next X
      Else
        If FindString(GetGadgetItemText(Gadget, Y, Column), Find$, #Null, #PB_String_NoCase)
          *Result\y = Y
          *Result\x = Column
          Found = #True
          Break 1
        EndIf
      EndIf
    Next Y
     
  EndIf

SetGadgetState(Gadget,y)

  ProcedureReturn Found

EndProcedure
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 4
; Folding = AAAw
; EnableXP
; Executable = C:\Temp\uVNCRemoteControl.exe
; DisableDebugger
; EnableUnicode