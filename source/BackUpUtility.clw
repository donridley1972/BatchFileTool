   PROGRAM


StringTheory:TemplateVersion equate('3.46')
FM3:Version           equate('5.59')       !Deprecated - but exists for backward compatibility
FM3:TemplateVersion   equate('5.59')
ResizeAndSplit:TemplateVersion equate('5.10')

   INCLUDE('ABERROR.INC'),ONCE
   INCLUDE('ABFILE.INC'),ONCE
   INCLUDE('ABUTIL.INC'),ONCE
   INCLUDE('ERRORS.CLW'),ONCE
   INCLUDE('KEYCODES.CLW'),ONCE
   INCLUDE('ABFUZZY.INC'),ONCE
  include('StringTheory.Inc'),ONCE
  include('ResizeAndSplit.Inc'),ONCE

   MAP
     MODULE('BACKUPUTILITY_BC.CLW')
DctInit     PROCEDURE                                      ! Initializes the dictionary definition module
DctKill     PROCEDURE                                      ! Kills the dictionary definition module
     END
!--- Application Global and Exported Procedure Definitions --------------------------------------------
     MODULE('BACKUPUTILITY002.CLW')
Main                   PROCEDURE   !
     END
     MODULE('BACKUPUTILITY004.CLW')
RuntimeFileManager     PROCEDURE   !
     END
       include('FM3map.clw')
   END

  include('StringTheory.Inc'),ONCE
Glo:st               StringTheory
Glo:CmdAppName       STRING(30)
Glo:DefaultOutputPath STRING(255)
SilentRunning        BYTE(0)                               ! Set true when application is running in 'silent mode'

!region File Declaration
BackUpFiles          FILE,DRIVER('TOPSPEED'),NAME('BackUpFiles.tps'),PRE(Bac),CREATE,BINDABLE,THREAD !                     
PFBacGuidKey             KEY(Bac:PKBacGuid),NOCASE,PRIMARY !                     
FKProjGuidKey            KEY(Bac:FKProjGuid),DUP,NOCASE    !                     
BacDescriptionKey        KEY(Bac:Description),DUP,NOCASE   !                     
BacAppNameKey            KEY(Bac:AppName),DUP,NOCASE       !                     
Record                   RECORD,PRE()
PKBacGuid                   STRING(16)                     !                     
FKProjGuid                  STRING(16)                     !                     
Description                 STRING(40)                     !                     
AppName                     STRING(30)                     ! Do not include file extension
InputPath                   STRING(150)                    !                     
OutputPath                  STRING(150)                    !                     
ZipTheFile                  BYTE                           !                     
                         END
                     END                       

Projects             FILE,DRIVER('TOPSPEED'),NAME('Projects.tps'),PRE(Pro),CREATE,BINDABLE,THREAD !                     
PKProjGuidKey            KEY(Pro:PKProjGuid),NOCASE,PRIMARY !                     
ProjDescriptionKey       KEY(Pro:ProjDescription),DUP,NOCASE !                     
Record                   RECORD,PRE()
PKProjGuid                  STRING(16)                     !                     
ProjDescription             STRING(30)                     !                     
SaveBatTo                   STRING(150)                    !                     
InputPath                   STRING(150)                    !                     
OutputPath                  STRING(150)                    !                     
                         END
                     END                       

!endregion

ds_VersionModifier  long
ds_FMInited byte
gTopSpeedFile File,driver('TopSpeed',''),pre(__gtps)
record         record
a                byte
               end
             end



  compile ('****', _VER_C60)
  include('cwsynchc.inc'),once
  ****
  include('fm3equ.clw')
ds_FMQueue  Queue,pre(_dsf),type
Prefix        String(10)
FileName      String(255)
FromVersion   Long
ToVersion     Long
Reserved      String(255)
            end

ds_FM_Upgrading  &byte,thread                ! File Manager 2/3 upgrading flag
Access:BackUpFiles   &FileManager,THREAD                   ! FileManager for BackUpFiles
Relate:BackUpFiles   &RelationManager,THREAD               ! RelationManager for BackUpFiles
Access:Projects      &FileManager,THREAD                   ! FileManager for Projects
Relate:Projects      &RelationManager,THREAD               ! RelationManager for Projects

FuzzyMatcher         FuzzyClass                            ! Global fuzzy matcher
GlobalErrorStatus    ErrorStatusClass,THREAD
GlobalErrors         ErrorClass                            ! Global error manager
INIMgr               INIClass                              ! Global non-volatile storage manager
GlobalRequest        BYTE(0),THREAD                        ! Set when a browse calls a form, to let it know action to perform
GlobalResponse       BYTE(0),THREAD                        ! Set to the response from the form
VCRRequest           LONG(0),THREAD                        ! Set to the request from the VCR buttons

Dictionary           CLASS,THREAD
Construct              PROCEDURE
Destruct               PROCEDURE
                     END


  CODE
  GlobalErrors.Init(GlobalErrorStatus)
  FuzzyMatcher.Init                                        ! Initilaize the browse 'fuzzy matcher'
  FuzzyMatcher.SetOption(MatchOption:NoCase, 1)            ! Configure case matching
  FuzzyMatcher.SetOption(MatchOption:WordOnly, 0)          ! Configure 'word only' matching
  INIMgr.Init('.\BackUpUtility.INI', NVD_INI)              ! Configure INIManager to use INI file
  DctInit()
  SYSTEM{PROP:Icon} = 'appicon.ico'
   ! Generated using Clarion Template version v11.0  Family = abc
    ds_FM_Upgrading &= ds_PassHandleForUpgrading()
    if ds_FMInited = 0
      ds_FMInited = 1
        ds_SetOption('inifilename','.\fm3.ini')
      ds_SetOption('BadFile',0)
      ds_AddDriver('Tps',gTopSpeedFile,__gtps:record)
  
  
      ds_IgnoreDriver('AllFiles',1)
      ds_SetOption('SPCreate',1)
      ds_SetOption('GUIDsCaseInsensitive',1)
    ds_UsingFileEx('BackUpFiles',BackUpFiles,4+ds_VersionModifier,'Bac')
    ds_UsingFileEx('Projects',Projects,4+ds_VersionModifier,'Pro')
              omit('***',FM2=1)
              !! Don't forget to add the FM2=>1 define to your project
              You did forget didn't you ?
              ! close this window - go to the app - click on project - click on properties -
              ! click on the defines tab - add FM2=>1 to the defines...
            !***
    End  !End of if ds_FMInited = 0
    ds_DoFullUpgrade(1)
    RuntimeFileManager()
  Main
  INIMgr.Update
  INIMgr.Kill                                              ! Destroy INI manager
  FuzzyMatcher.Kill                                        ! Destroy fuzzy matcher


Dictionary.Construct PROCEDURE

  CODE
  !System{PROP:DataPath} = 'C:\ACTIVE CLARION PROJECTS\Clarion 11\PDManager App Group\Backup Utility'
  IF THREAD()<>1
     DctInit()
  END


Dictionary.Destruct PROCEDURE

  CODE
  DctKill()

