

   MEMBER('BackUpUtility.clw')                             ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('BACKUPUTILITY005.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('BACKUPUTILITY003.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Browse the BackUpFiles file
!!! </summary>
BrowseBackUpFiles PROCEDURE 

CurrentTab           STRING(80)                            ! 
BRW1::View:Browse    VIEW(BackUpFiles)
                       PROJECT(Bac:PKBacGuid)
                       PROJECT(Bac:Description)
                       PROJECT(Bac:AppName)
                       PROJECT(Bac:InputPath)
                       PROJECT(Bac:OutputPath)
                       PROJECT(Bac:ZipTheFile)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
Bac:PKBacGuid          LIKE(Bac:PKBacGuid)            !List box control field - type derived from field
Bac:Description        LIKE(Bac:Description)          !List box control field - type derived from field
Bac:AppName            LIKE(Bac:AppName)              !List box control field - type derived from field
Bac:InputPath          LIKE(Bac:InputPath)            !List box control field - type derived from field
Bac:OutputPath         LIKE(Bac:OutputPath)           !List box control field - type derived from field
Bac:ZipTheFile         LIKE(Bac:ZipTheFile)           !List box control field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Browse the BackUpFiles file'),AT(,,358,198),FONT('Segoe UI',11,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,AUTO,CENTER,GRAY,IMM,HLP('BrowseBackUpFiles'),SYSTEM
                       LIST,AT(8,30,342,124),USE(?Browse:1),HVSCROLL,FORMAT('68L(2)|M~PKB ac Guid~L(2)@s16@80L' & |
  '(2)|M~Description~L(2)@s40@80L(2)|M~App Name~L(2)@s30@80L(2)|M~Input Path~L(2)@s255@' & |
  '80L(2)|M~Output Path~L(2)@s255@44R(2)|M~Zip Option~C(0)@n3@'),FROM(Queue:Browse:1),IMM, |
  MSG('Browsing the BackUpFiles file')
                       BUTTON('&View'),AT(142,158,49,14),USE(?View:2),LEFT,ICON('WAVIEW.ICO'),FLAT,MSG('View Record'), |
  TIP('View Record')
                       BUTTON('&Insert'),AT(195,158,49,14),USE(?Insert:3),LEFT,ICON('WAINSERT.ICO'),FLAT,MSG('Insert a Record'), |
  TIP('Insert a Record')
                       BUTTON('&Change'),AT(248,158,49,14),USE(?Change:3),LEFT,ICON('WACHANGE.ICO'),DEFAULT,FLAT, |
  MSG('Change the Record'),TIP('Change the Record')
                       BUTTON('&Delete'),AT(301,158,49,14),USE(?Delete:3),LEFT,ICON('WADELETE.ICO'),FLAT,MSG('Delete the Record'), |
  TIP('Delete the Record')
                       SHEET,AT(4,4,350,172),USE(?CurrentTab)
                         TAB('&1) PFBacGuidKey'),USE(?Tab:2)
                         END
                         TAB('&2) BacDescriptionKey'),USE(?Tab:3)
                         END
                         TAB('&3) BacAppNameKey'),USE(?Tab:4)
                         END
                       END
                       BUTTON('&Close'),AT(252,180,49,14),USE(?Close),LEFT,ICON('WACLOSE.ICO'),FLAT,MSG('Close Window'), |
  TIP('Close Window')
                       BUTTON('&Help'),AT(305,180,49,14),USE(?Help),LEFT,ICON('WAHELP.ICO'),FLAT,MSG('See Help Window'), |
  STD(STD:Help),TIP('See Help Window')
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
ResetSort              PROCEDURE(BYTE Force),BYTE,PROC,DERIVED
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
BRW1::Sort1:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 2
BRW1::Sort2:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 3
BRW1::Sort0:StepClass StepStringClass                      ! Default Step Manager
BRW1::Sort1:StepClass StepStringClass                      ! Conditional Step Manager - CHOICE(?CurrentTab) = 2
BRW1::Sort2:StepClass StepStringClass                      ! Conditional Step Manager - CHOICE(?CurrentTab) = 3
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
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

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('BrowseBackUpFiles')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Browse:1
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
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:BackUpFiles,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1::Sort1:StepClass.Init(+ScrollSort:AllowAlpha,ScrollBy:Runtime) ! Moveable thumb based upon Bac:Description for sort order 1
  BRW1.AddSortOrder(BRW1::Sort1:StepClass,Bac:BacDescriptionKey) ! Add the sort order for Bac:BacDescriptionKey for sort order 1
  BRW1.AddLocator(BRW1::Sort1:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort1:Locator.Init(,Bac:Description,1,BRW1)        ! Initialize the browse locator using  using key: Bac:BacDescriptionKey , Bac:Description
  BRW1::Sort2:StepClass.Init(+ScrollSort:AllowAlpha,ScrollBy:Runtime) ! Moveable thumb based upon Bac:AppName for sort order 2
  BRW1.AddSortOrder(BRW1::Sort2:StepClass,Bac:BacAppNameKey) ! Add the sort order for Bac:BacAppNameKey for sort order 2
  BRW1.AddLocator(BRW1::Sort2:Locator)                     ! Browse has a locator for sort order 2
  BRW1::Sort2:Locator.Init(,Bac:AppName,1,BRW1)            ! Initialize the browse locator using  using key: Bac:BacAppNameKey , Bac:AppName
  BRW1::Sort0:StepClass.Init(+ScrollSort:AllowAlpha,ScrollBy:Runtime) ! Moveable thumb based upon Bac:PKBacGuid for sort order 3
  BRW1.AddSortOrder(BRW1::Sort0:StepClass,Bac:PFBacGuidKey) ! Add the sort order for Bac:PFBacGuidKey for sort order 3
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 3
  BRW1::Sort0:Locator.Init(,Bac:PKBacGuid,1,BRW1)          ! Initialize the browse locator using  using key: Bac:PFBacGuidKey , Bac:PKBacGuid
  BRW1.AddField(Bac:PKBacGuid,BRW1.Q.Bac:PKBacGuid)        ! Field Bac:PKBacGuid is a hot field or requires assignment from browse
  BRW1.AddField(Bac:Description,BRW1.Q.Bac:Description)    ! Field Bac:Description is a hot field or requires assignment from browse
  BRW1.AddField(Bac:AppName,BRW1.Q.Bac:AppName)            ! Field Bac:AppName is a hot field or requires assignment from browse
  BRW1.AddField(Bac:InputPath,BRW1.Q.Bac:InputPath)        ! Field Bac:InputPath is a hot field or requires assignment from browse
  BRW1.AddField(Bac:OutputPath,BRW1.Q.Bac:OutputPath)      ! Field Bac:OutputPath is a hot field or requires assignment from browse
  BRW1.AddField(Bac:ZipTheFile,BRW1.Q.Bac:ZipTheFile)      ! Field Bac:ZipTheFile is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('BrowseBackUpFiles',QuickWindow)            ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                                    ! Will call: UpdateBackupFiles(Glo:DefaultOutputPath)
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
    INIMgr.Update('BrowseBackUpFiles',QuickWindow)         ! Save window data to non-volatile store
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
    UpdateBackupFiles(Glo:DefaultOutputPath)
    ReturnValue = GlobalResponse
  END
  RETURN ReturnValue


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert:3
    SELF.ChangeControl=?Change:3
    SELF.DeleteControl=?Delete:3
  END
  SELF.ViewControl = ?View:2                               ! Setup the control used to initiate view only mode


BRW1.ResetSort PROCEDURE(BYTE Force)

ReturnValue          BYTE,AUTO

  CODE
  IF CHOICE(?CurrentTab) = 2
    RETURN SELF.SetSort(1,Force)
  ELSIF CHOICE(?CurrentTab) = 3
    RETURN SELF.SetSort(2,Force)
  ELSE
    RETURN SELF.SetSort(3,Force)
  END
  ReturnValue = PARENT.ResetSort(Force)
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

