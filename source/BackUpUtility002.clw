

   MEMBER('BackUpUtility.clw')                             ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABUTIL.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('BACKUPUTILITY002.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('BACKUPUTILITY001.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('BACKUPUTILITY003.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! </summary>
Main PROCEDURE 

StartPath            STRING(255)                           ! 
BatchLookupVar       STRING(150)                           ! 
FileQueue4           SelectFileQueue
FileQueueCount4      USHORT,AUTO
BRW2::View:Browse    VIEW(BackUpFiles)
                       PROJECT(Bac:AppName)
                       PROJECT(Bac:PKBacGuid)
                     END
Queue:Browse         QUEUE                            !Queue declaration for browse/combo box using ?List
Bac:AppName            LIKE(Bac:AppName)              !List box control field - type derived from field
Bac:PKBacGuid          LIKE(Bac:PKBacGuid)            !Primary key field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
BRW5::View:Browse    VIEW(Projects)
                       PROJECT(Pro:ProjDescription)
                       PROJECT(Pro:PKProjGuid)
                       PROJECT(Pro:SaveBatTo)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?List:2
Pro:ProjDescription    LIKE(Pro:ProjDescription)      !List box control field - type derived from field
Pro:PKProjGuid         LIKE(Pro:PKProjGuid)           !Browse hot field - type derived from field
Pro:SaveBatTo          LIKE(Pro:SaveBatTo)            !Browse hot field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
Window               WINDOW('Batch File Tool'),AT(,,393,224),FONT('Segoe UI',11),RESIZE,AUTO,ICON('appicon.ico'), |
  GRAY,SYSTEM,WALLPAPER('gradient(1).png'),IMM
                       BUTTON,AT(365,200,26),USE(?Close),COLOR(00F8A865h),ICON('exit.ico')
                       LIST,AT(90,43,300,137),USE(?List),LEFT(2),HVSCROLL,FORMAT('120L(2)M~Files~@s30@'),FROM(Queue:Browse), |
  IMM
                       BUTTON,AT(331,184,18,14),USE(?Insert),COLOR(00F8A865h),ICON('add.ico')
                       BUTTON,AT(352,184,18,14),USE(?Change),COLOR(00F8A865h),ICON('pencil.ico')
                       BUTTON,AT(373,184,18,14),USE(?Delete),COLOR(00F8A865h),ICON('trash.ico')
                       BUTTON('Create Batch File'),AT(90,184),USE(?CreateBatchFileBtn),FONT(,,00F8A865h,FONT:bold), |
  LEFT,COLOR(007C4922h),ICON('check2.ico'),FLAT,HIDE,TRN
                       LIST,AT(2,43,83,137),USE(?List:2),LEFT(2),FORMAT('120L(2)|M~Projects~@s30@'),FROM(Queue:Browse:1), |
  IMM
                       BUTTON,AT(2,184,18,14),USE(?Insert:2),COLOR(00F8A865h),ICON('add.ico')
                       BUTTON,AT(23,184,18,14),USE(?Change:2),COLOR(00F8A865h),ICON('pencil.ico')
                       BUTTON,AT(44,184,18,14),USE(?Delete:2),COLOR(00F8A865h),ICON('trash.ico')
                       IMAGE('batch-icon-26.png'),AT(2,1,52,39),USE(?IMAGE1)
                       IMAGE('Logo.png'),AT(57,10,192,23),USE(?IMAGE2)
                       BUTTON,AT(310,184,18,14),USE(?LookupFile),COLOR(00F8A865h),ICON('batchinsert1.ico')
                     END

st              StringTheory
local                       CLASS
BackUpFilesInsert           Procedure(string pFileName)
                            End
ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
TakeEvent              PROCEDURE(),BYTE,PROC,DERIVED
TakeNewSelection       PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
! ----- csResize --------------------------------------------------------------------------
csResize             Class(csResizeClass)
    ! derived method declarations
Fetch                  PROCEDURE (STRING Sect,STRING Ent,*? Val),VIRTUAL
Update                 PROCEDURE (STRING Sect,STRING Ent,STRING Val),VIRTUAL
Init                   PROCEDURE (),VIRTUAL
                     End  ! csResize
! ----- end csResize -----------------------------------------------------------------------
BRW2                 CLASS(BrowseClass)                    ! Browse using ?List
Q                      &Queue:Browse                  !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
                     END

BRW5                 CLASS(BrowseClass)                    ! Browse using ?List:2
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
                     END

FileLookup4          SelectFileClass

  CODE
? DEBUGHOOK(BackUpFiles:Record)
? DEBUGHOOK(Projects:Record)
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('Main')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Close
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Close,RequestCancelled)                 ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Close,RequestCompleted)                 ! Add the close control to the window manger
  END
  Relate:BackUpFiles.SetOpenRelated()
  Relate:BackUpFiles.Open()                                ! File BackUpFiles used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW2.Init(?List,Queue:Browse.ViewPosition,BRW2::View:Browse,Queue:Browse,Relate:BackUpFiles,SELF) ! Initialize the browse manager
  BRW5.Init(?List:2,Queue:Browse:1.ViewPosition,BRW5::View:Browse,Queue:Browse:1,Relate:Projects,SELF) ! Initialize the browse manager
  SELF.Open(Window)                                        ! Open window
    0{PROP:Buffer} = true  
  Do DefineListboxStyle
  BRW2.Q &= Queue:Browse
  BRW2.AddSortOrder(,)                                     ! Add the sort order for  for sort order 1
  BRW2.SetFilter('(Bac:FKProjGuid=Pro:PKProjGuid)')        ! Apply filter expression to browse
  BRW2.AddField(Bac:AppName,BRW2.Q.Bac:AppName)            ! Field Bac:AppName is a hot field or requires assignment from browse
  BRW2.AddField(Bac:PKBacGuid,BRW2.Q.Bac:PKBacGuid)        ! Field Bac:PKBacGuid is a hot field or requires assignment from browse
  BRW5.Q &= Queue:Browse:1
  BRW5.AddSortOrder(,)                                     ! Add the sort order for  for sort order 1
  BRW5.AddField(Pro:ProjDescription,BRW5.Q.Pro:ProjDescription) ! Field Pro:ProjDescription is a hot field or requires assignment from browse
  BRW5.AddField(Pro:PKProjGuid,BRW5.Q.Pro:PKProjGuid)      ! Field Pro:PKProjGuid is a hot field or requires assignment from browse
  BRW5.AddField(Pro:SaveBatTo,BRW5.Q.Pro:SaveBatTo)        ! Field Pro:SaveBatTo is a hot field or requires assignment from browse
  csResize.Init('Main',Window,1)
  INIMgr.Fetch('Main',Window)                              ! Restore window settings from non-volatile store
    Glo:DefaultOutputPath = GETINI('Settings','DefaultOutputPath',,'.\BackUpUtility.INI')  
  BRW2.AskProcedure = 1                                    ! Will call: UpdateBackupFiles(Pro:OutputPath,Pro:PKProjGuid)
  BRW5.AskProcedure = 2                                    ! Will call: UpdateProjects
  FileLookup4.Init
  FileLookup4.ClearOnCancel = True
  FileLookup4.Flags=BOR(FileLookup4.Flags,FILE:LongName)   ! Allow long filenames
  FileLookup4.SetMask('All Files','*.*')                   ! Set the file mask
  FileLookup4.WindowTitle='Select Files to Backup'
  BRW2.AddToolbarTarget(Toolbar)                           ! Browse accepts toolbar control
  BRW5.AddToolbarTarget(Toolbar)                           ! Browse accepts toolbar control
  csResize.Open()
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:BackUpFiles.Close()
  END
  IF SELF.Opened
    INIMgr.Update('Main',Window)                           ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.Run PROCEDURE(USHORT Number,BYTE Request)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Run(Number,Request)
  IF SELF.Request = ViewRecord
    ReturnValue = RequestCancelled                         ! Always return RequestCancelled if the form was opened in ViewRecord mode
  ELSE
    GlobalRequest = Request
    EXECUTE Number
      UpdateBackupFiles(Pro:OutputPath,Pro:PKProjGuid)
      UpdateProjects
    END
    ReturnValue = GlobalResponse
  END
  RETURN ReturnValue


ThisWindow.TakeAccepted PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
    CASE ACCEPTED()
    OF ?CreateBatchFileBtn
      st.SetValue('echo on<13,10>')
      st.Append('rem -- Copying Files -----------------------------------<13,10>')
      Set(BRW2::View:Browse)
      LOOP
        Next(BRW2::View:Browse)
        If Errorcode() Then Break END
        If Lower(st.ExtensionOnly(Bac:InputPath)) <> 'exe' and Lower(st.ExtensionOnly(Bac:InputPath)) <> 'dll'
            st.Append('copy /Y /V "'&clip(Bac:InputPath)&'" "'&clip(Bac:OutputPath)&'\'&st.FileNameOnly(Bac:InputPath,0)&'_'&Format(Today(),'@d12')&'_'&Format(Clock(),'@t5') & '.' & st.ExtensionOnly(Bac:InputPath) &'"<13,10>')
        ELSE
            st.Append('copy /Y /V "'&clip(Bac:InputPath)&'" "'&clip(Bac:OutputPath)&'\'&st.FileNameOnly(Bac:InputPath,1)&'"<13,10>')
        End
        !xcopy /C /Y /E "C:\Clarion11\accessory\libsrc\win\netweb\web\*.*" "web\*"
      End    
      st.SaveFile(Clip(Pro:SaveBatTo) & '\' & clip(Pro:ProjDescription) & '_BackUp.bat')
    OF ?List:2
      BRW2.ResetSort(1)      
    END
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?LookupFile
      ThisWindow.Update()
      FileLookup4.Ask(FileQueue4,1)                        ! Display lookup dialog
      LOOP FileQueueCount4=1 TO RECORDS(FileQueue4)        ! Perorm actions on each selected file
        GET(FileQueue4,FileQueueCount4)
        ASSERT(~ERRORCODE())
        BatchLookupVar=FileQueue4.Name
        DISPLAY
        local.BackUpFilesInsert(BatchLookupVar)
      END
      BRW2.ResetSort(1)      
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  csResize.TakeEvent()
  LOOP                                                     ! This method receives all events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
    Case Event()
    Of EVENT:NewSelection
        !message(Records(BRW2::View:Browse))
        If Records(Queue:Browse) > 0
            ?CreateBatchFileBtn{PROP:Hide} = FALSE
        ELSE
            ?CreateBatchFileBtn{PROP:Hide} = True
        End  
    End  
  ReturnValue = PARENT.TakeEvent()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeNewSelection PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all NewSelection events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  ReturnValue = PARENT.TakeNewSelection()
    CASE FIELD()
    OF ?List:2
      BRW2.ResetSort(1)      
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue

local.BackUpFilesInsert           Procedure(string pFileName)
    CODE
    Bac:PKBacGuid   = glo:st.MakeGuid()
    Bac:FKProjGuid = Pro:PKProjGuid
    !Bac:Description
    Bac:AppName     = glo:st.FileNameOnly(pFileName)
    Bac:InputPath   = pFileName
    Bac:OutputPath  = Pro:OutputPath  
    Access:BackUpFiles.Insert()
!----------------------------------------------------
csResize.Fetch   PROCEDURE (STRING Sect,STRING Ent,*? Val)
  CODE
  INIMgr.Fetch(Sect,Ent,Val)
  PARENT.Fetch (Sect,Ent,Val)
!----------------------------------------------------
csResize.Update   PROCEDURE (STRING Sect,STRING Ent,STRING Val)
  CODE
  INIMgr.Update(Sect,Ent,Val)
  PARENT.Update (Sect,Ent,Val)
!----------------------------------------------------
csResize.Init   PROCEDURE ()
  CODE
  PARENT.Init ()
  Self.CornerStyle = Ras:CornerDots
  SELF.GrabCornerLines() !
  SELF.SetStrategy(?Close,100,100,0,0)
  SELF.SetStrategy(?List,0,0,100,100)
  SELF.SetStrategy(?Insert,100,100,0,0)
  SELF.SetStrategy(?Change,100,100,0,0)
  SELF.SetStrategy(?Delete,100,100,0,0)
  SELF.SetStrategy(?CreateBatchFileBtn,,100,,0)
  SELF.SetStrategy(?List:2,,0,,100)
  SELF.SetStrategy(?Insert:2,,100,,0)
  SELF.SetStrategy(?Change:2,,100,,0)
  SELF.SetStrategy(?Delete:2,,100,,0)
  SELF.SetStrategy(?LookupFile,100,100,0,0)

BRW2.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert
    SELF.ChangeControl=?Change
    SELF.DeleteControl=?Delete
  END


BRW5.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert:2
    SELF.ChangeControl=?Change:2
    SELF.DeleteControl=?Delete:2
  END

