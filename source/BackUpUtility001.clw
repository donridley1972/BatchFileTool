

   MEMBER('BackUpUtility.clw')                             ! This is a MEMBER module


   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABUTIL.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('BACKUPUTILITY001.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Form Projects
!!! </summary>
UpdateProjects PROCEDURE 

CurrentTab           STRING(80)                            ! 
ActionMessage        CSTRING(40)                           ! 
History::Pro:Record  LIKE(Pro:RECORD),THREAD
QuickWindow          WINDOW('Form Projects'),AT(,,365,86),FONT('Segoe UI',11,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  CENTER,ICON('appicon.ico'),GRAY,HLP('UpdateProjects'),SYSTEM,WALLPAPER('gradient(1).png'),IMM
                       BUTTON('&OK'),AT(261,64,49,14),USE(?OK),FONT(,,00F8A865h,FONT:bold),LEFT,COLOR(00F8A865h), |
  ICON('check2.ico'),DEFAULT,FLAT,MSG('Accept data and close the window'),TIP('Accept dat' & |
  'a and close the window'),TRN
                       BUTTON('&Cancel'),AT(314,64,49,14),USE(?Cancel),FONT(,,00F8A865h,FONT:bold),LEFT,COLOR(00F8A865h), |
  ICON('cancel2.ico'),FLAT,MSG('Cancel operation'),TIP('Cancel operation'),TRN
                       ENTRY(@s30),AT(70,8,131,10),USE(Pro:ProjDescription),LEFT(2)
                       PROMPT('Description'),AT(5,8),USE(?Pro:ProjDescription:Prompt),FONT(,,006CF9FEh,FONT:bold), |
  TRN
                       PROMPT('Save Batch File To'),AT(5,22),USE(?Pro:SaveBatTo:Prompt),FONT(,,006CF9FEh,FONT:bold), |
  TRN
                       ENTRY(@s255),AT(70,21,276,10),USE(Pro:SaveBatTo),LEFT(2)
                       BUTTON,AT(351,20,12,11),USE(?LookupFile),COLOR(00F8A865h),ICON('search.ico')
                       PROMPT('Input Path'),AT(5,35),USE(?Pro:InputPath:Prompt),FONT(,,006CF9FEh,FONT:bold),TRN
                       ENTRY(@s255),AT(70,34,276,10),USE(Pro:InputPath),LEFT(2)
                       PROMPT('Output Path'),AT(5,48),USE(?Pro:OutputPath:Prompt),FONT(,,006CF9FEh,FONT:bold),TRN
                       ENTRY(@s255),AT(70,48,276,10),USE(Pro:OutputPath),LEFT(2)
                       BUTTON,AT(351,33,12,11),USE(?LookupFile:2),COLOR(00F8A865h),ICON('search.ico')
                       BUTTON,AT(351,47,12,11),USE(?LookupFile:3),COLOR(00F8A865h),ICON('search.ico')
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
FileLookup9          SelectFileClass
FileLookup11         SelectFileClass
CurCtrlFeq          LONG
FieldColorQueue     QUEUE
Feq                   LONG
OldColor              LONG
                    END

  CODE
? DEBUGHOOK(Projects:Record)
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
    QuickWindow{PROP:Text} = QuickWindow{PROP:Text} & '  (' & Pro:ProjDescription & ')' ! Append status message to window title text
  OF InsertRecord
    QuickWindow{PROP:Text} = QuickWindow{PROP:Text} & '  (New)'
  END
  PARENT.Ask


ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('UpdateProjects')
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
  SELF.AddHistoryFile(Pro:Record,History::Pro:Record)
  SELF.AddHistoryField(?Pro:ProjDescription,2)
  SELF.AddHistoryField(?Pro:SaveBatTo,3)
  SELF.AddHistoryField(?Pro:InputPath,4)
  SELF.AddHistoryField(?Pro:OutputPath,5)
  SELF.AddUpdateFile(Access:Projects)
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:Projects.SetOpenRelated()
  Relate:Projects.Open()                                   ! File Projects used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:Projects
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
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                             ! Configure controls for View Only mode
    ?Pro:ProjDescription{PROP:ReadOnly} = True
    ?Pro:SaveBatTo{PROP:ReadOnly} = True
    DISABLE(?LookupFile)
    ?Pro:InputPath{PROP:ReadOnly} = True
    ?Pro:OutputPath{PROP:ReadOnly} = True
    DISABLE(?LookupFile:2)
    DISABLE(?LookupFile:3)
  END
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('UpdateProjects',QuickWindow)               ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  FileLookup7.Init
  FileLookup7.ClearOnCancel = True
  FileLookup7.Flags=BOR(FileLookup7.Flags,FILE:LongName)   ! Allow long filenames
  FileLookup7.Flags=BOR(FileLookup7.Flags,FILE:Directory)  ! Allow Directory Dialog
  FileLookup7.SetMask('All Files','*.*')                   ! Set the file mask
  FileLookup9.Init
  FileLookup9.ClearOnCancel = True
  FileLookup9.Flags=BOR(FileLookup9.Flags,FILE:LongName)   ! Allow long filenames
  FileLookup9.Flags=BOR(FileLookup9.Flags,FILE:Directory)  ! Allow Directory Dialog
  FileLookup9.SetMask('All Files','*.*')                   ! Set the file mask
  FileLookup11.Init
  FileLookup11.ClearOnCancel = True
  FileLookup11.Flags=BOR(FileLookup11.Flags,FILE:LongName) ! Allow long filenames
  FileLookup11.Flags=BOR(FileLookup11.Flags,FILE:Directory) ! Allow Directory Dialog
  FileLookup11.SetMask('All Files','*.*')                  ! Set the file mask
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Projects.Close()
  END
  IF SELF.Opened
    INIMgr.Update('UpdateProjects',QuickWindow)            ! Save window data to non-volatile store
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
      Pro:SaveBatTo = FileLookup7.Ask(1)
      DISPLAY
    OF ?LookupFile:2
      ThisWindow.Update()
      Pro:InputPath = FileLookup9.Ask(1)
      DISPLAY
    OF ?LookupFile:3
      ThisWindow.Update()
      Pro:OutputPath = FileLookup11.Ask(1)
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

