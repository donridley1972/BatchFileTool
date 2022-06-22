

   MEMBER('BackUpUtility.clw')                             ! This is a MEMBER module


   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABUTIL.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('BACKUPUTILITY003.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Form BackUpFiles
!!! </summary>
UpdateBackupFiles PROCEDURE (string pDefaultOutputPath,<string pProjectGuid>)

CurrentTab           STRING(80)                            ! 
ActionMessage        CSTRING(40)                           ! 
History::Bac:Record  LIKE(Bac:RECORD),THREAD
QuickWindow          WINDOW('Form BackUpFiles'),AT(,,399,54),FONT('Segoe UI',11,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  AUTO,CENTER,ICON('appicon.ico'),GRAY,IMM,HLP('UpdateBackupFiles'),SYSTEM,WALLPAPER('gradient(1).png')
                       BUTTON('&OK'),AT(296,36,49,14),USE(?OK),FONT(,,00F8A865h,FONT:bold),LEFT,COLOR(00F8A865h), |
  ICON('check2.ico'),DEFAULT,FLAT,MSG('Accept data and close the window'),TIP('Accept dat' & |
  'a and close the window'),TRN
                       BUTTON('&Cancel'),AT(348,36,49,14),USE(?Cancel),FONT(,,00F8A865h,FONT:bold),LEFT,COLOR(00F8A865h), |
  ICON('cancel2.ico'),FLAT,MSG('Cancel operation'),TIP('Cancel operation'),TRN
                       PROMPT('Input File'),AT(6,6),USE(?Bac:InputPath:Prompt),FONT(,,006CF9FEh,FONT:bold),TRN
                       ENTRY(@s255),AT(60,6,322,10),USE(Bac:InputPath),LEFT(2)
                       PROMPT('Output Path'),AT(6,20),USE(?Bac:OutputPath:Prompt),FONT(,,006CF9FEh,FONT:bold),TRN
                       ENTRY(@s255),AT(60,20,322,10),USE(Bac:OutputPath),LEFT(2)
                       CHECK('Zip Option'),AT(6,36,70,8),USE(Bac:ZipTheFile),LEFT,HIDE,TRN,VALUE('1','0')
                       BUTTON,AT(385,5,12,11),USE(?LookupFile),COLOR(00F8A865h),ICON('search.ico')
                       BUTTON,AT(385,19,12,11),USE(?LookupFile:2),COLOR(00F8A865h),ICON('search.ico')
                     END

ThisWindow           CLASS(WindowManager)
Ask                    PROCEDURE(),DERIVED
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END

FileLookup7          SelectFileClass
FileLookup8          SelectFileClass
CurCtrlFeq          LONG
FieldColorQueue     QUEUE
Feq                   LONG
OldColor              LONG
                    END

  CODE
? DEBUGHOOK(BackUpFiles:Record)
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------

ThisWindow.Ask PROCEDURE

  CODE
  CASE SELF.Request                                        ! Configure the action message text
  OF ViewRecord
    ActionMessage = 'View Record'
  OF InsertRecord
    ActionMessage = 'Record Will Be Added'
  OF ChangeRecord
    ActionMessage = 'Record Will Be Changed'
  END
  QuickWindow{PROP:Text} = ActionMessage                   ! Display status message in title bar
  CASE SELF.Request
  OF ChangeRecord OROF DeleteRecord
    QuickWindow{PROP:Text} = QuickWindow{PROP:Text} & '  (' & Bac:AppName & ')' ! Append status message to window title text
  OF InsertRecord
    QuickWindow{PROP:Text} = QuickWindow{PROP:Text} & '  (New)'
  END
  PARENT.Ask


ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('UpdateBackupFiles')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?OK
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.AddItem(Toolbar)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(Bac:Record,History::Bac:Record)
  SELF.AddHistoryField(?Bac:InputPath,5)
  SELF.AddHistoryField(?Bac:OutputPath,6)
  SELF.AddHistoryField(?Bac:ZipTheFile,7)
  SELF.AddUpdateFile(Access:BackUpFiles)
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:BackUpFiles.SetOpenRelated()
  Relate:BackUpFiles.Open()                                ! File BackUpFiles used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:BackUpFiles
  IF SELF.Request = ViewRecord AND NOT SELF.BatchProcessing ! Setup actions for ViewOnly Mode
    SELF.InsertAction = Insert:None
    SELF.DeleteAction = Delete:None
    SELF.ChangeAction = Change:None
    SELF.CancelAction = Cancel:Cancel
    SELF.OkControl = 0
  ELSE
    SELF.ChangeAction = Change:Caller                      ! Changes allowed
    SELF.CancelAction = Cancel:Cancel+Cancel:Query         ! Confirm cancel
    SELF.OkControl = ?OK
    IF SELF.PrimeUpdate() THEN RETURN Level:Notify.
  END
  SELF.Open(QuickWindow)                                   ! Open window
    If Bac:PKBacGuid = '' Then Bac:PKBacGuid = Glo:st.MakeGuid() End  
    IF Bac:FKProjGuid = '' Then Bac:FKProjGuid = pProjectGuid End
    If pDefaultOutputPath and Bac:OutputPath = ''
        Bac:OutputPath = pDefaultOutputPath
    End
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                             ! Configure controls for View Only mode
    ?Bac:InputPath{PROP:ReadOnly} = True
    ?Bac:OutputPath{PROP:ReadOnly} = True
    DISABLE(?LookupFile)
    DISABLE(?LookupFile:2)
  END
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('UpdateBackupFiles',QuickWindow)            ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  FileLookup7.Init
  FileLookup7.ClearOnCancel = True
  FileLookup7.Flags=BOR(FileLookup7.Flags,FILE:LongName)   ! Allow long filenames
  FileLookup7.SetMask('All Files','*.*')                   ! Set the file mask
  FileLookup8.Init
  FileLookup8.ClearOnCancel = True
  FileLookup8.Flags=BOR(FileLookup8.Flags,FILE:LongName)   ! Allow long filenames
  FileLookup8.Flags=BOR(FileLookup8.Flags,FILE:Directory)  ! Allow Directory Dialog
  FileLookup8.SetMask('All Files','*.*')                   ! Set the file mask
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
    INIMgr.Update('UpdateBackupFiles',QuickWindow)         ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.Run PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Run()
  IF SELF.Request = ViewRecord                             ! In View Only mode always signal RequestCancelled
    ReturnValue = RequestCancelled
  END
  RETURN ReturnValue


ThisWindow.TakeAccepted PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
st      StringTheory
  CODE
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?OK
      ThisWindow.Update()
      IF SELF.Request = ViewRecord AND NOT SELF.BatchProcessing THEN
         POST(EVENT:CloseWindow)
      END
    OF ?LookupFile
      ThisWindow.Update()
      Bac:InputPath = FileLookup7.Ask(1)
      DISPLAY
      Bac:Description   = st.FileNameOnly(Bac:InputPath,0)
      Bac:AppName       = st.FileNameOnly(Bac:InputPath,1)
    OF ?LookupFile:2
      ThisWindow.Update()
      Bac:OutputPath = FileLookup8.Ask(1)
      DISPLAY
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

