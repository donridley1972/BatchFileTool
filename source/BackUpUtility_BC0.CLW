  MEMBER('BackUpUtility.clw')

  INCLUDE('ABFILE.INC'),ONCE

  MAP
BackUpUtility_BC0:DctInit    PROCEDURE()
BackUpUtility_BC0:DctKill    PROCEDURE()
BackUpUtility_BC0:FilesInit  PROCEDURE()
  END

Hide:Access:BackUpFiles CLASS(FileManager),TYPE            ! FileManager for BackUpFiles
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
PrimeFields            PROCEDURE(),PROC,DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:BackUpFiles CLASS(RelationManager),TYPE        ! RelationManager for BackUpFiles
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:Projects CLASS(FileManager),TYPE               ! FileManager for Projects
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
PrimeFields            PROCEDURE(),PROC,DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:Projects CLASS(RelationManager),TYPE           ! RelationManager for Projects
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END


_Hide:Access:BackUpFiles &Hide:Access:BackUpFiles,AUTO,THREAD
_Hide:Relate:BackUpFiles &Hide:Relate:BackUpFiles,AUTO,THREAD
_Hide:Access:Projects &Hide:Access:Projects,AUTO,THREAD
_Hide:Relate:Projects &Hide:Relate:Projects,AUTO,THREAD


BackUpUtility_BC0:DctInit PROCEDURE()
  CODE
  _Hide:Access:BackUpFiles &= NEW(Hide:Access:BackUpFiles)
  _Hide:Relate:BackUpFiles &= NEW(Hide:Relate:BackUpFiles)
  _Hide:Access:Projects &= NEW(Hide:Access:Projects)
  _Hide:Relate:Projects &= NEW(Hide:Relate:Projects)
  Relate:BackUpFiles &= _Hide:Relate:BackUpFiles
  Relate:Projects &= _Hide:Relate:Projects


BackUpUtility_BC0:FilesInit PROCEDURE()
  CODE
  _Hide:Relate:BackUpFiles.Init
  _Hide:Relate:Projects.Init


BackUpUtility_BC0:DctKill PROCEDURE()
  CODE
  _Hide:Relate:BackUpFiles.Kill
  DISPOSE(_Hide:Relate:BackUpFiles)
  _Hide:Relate:Projects.Kill
  DISPOSE(_Hide:Relate:Projects)


Hide:Relate:BackUpFiles.Init PROCEDURE()
  CODE
  _Hide:Access:BackUpFiles.Init
  SELF.Init(Access:BackUpFiles,1)


Hide:Access:BackUpFiles.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= Bac:Record
  SELF.FileNameValue = 'BackUpFiles'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= BackUpFiles
  PARENT.Init
  Access:BackUpFiles &= SELF


Hide:Access:BackUpFiles.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:BackUpFiles &= NULL                               ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:BackUpFiles.PrimeFields PROCEDURE

  CODE
  Bac:PKBacGuid = glo:st.MakeGuid()                        ! Assign initial field value
  PARENT.PrimeFields


Hide:Access:BackUpFiles.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(BackUpFiles,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(Bac:PFBacGuidKey,'Bac:PFBacGuidKey',0)
    SELF.AddKey(Bac:FKProjGuidKey,'Bac:FKProjGuidKey',0)
    SELF.AddKey(Bac:BacDescriptionKey,'Bac:BacDescriptionKey',0)
    SELF.AddKey(Bac:BacAppNameKey,'Bac:BacAppNameKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:BackUpFiles.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:Projects)


Hide:Relate:BackUpFiles.Kill PROCEDURE

  CODE
  _Hide:Access:BackUpFiles.Kill                            ! Kill the file manager
  PARENT.Kill
  Relate:BackUpFiles &= NULL                               ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:BackUpFiles)                        ! destroy the file manager


Hide:Relate:Projects.Init PROCEDURE()
  CODE
  _Hide:Access:Projects.Init
  SELF.Init(Access:Projects,1)


Hide:Access:Projects.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= Pro:Record
  SELF.FileNameValue = 'Projects'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= Projects
  PARENT.Init
  Access:Projects &= SELF


Hide:Access:Projects.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:Projects &= NULL                                  ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:Projects.PrimeFields PROCEDURE

  CODE
  Pro:PKProjGuid = glo:st.MakeGuid()                       ! Assign initial field value
  PARENT.PrimeFields


Hide:Access:Projects.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(Projects,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(Pro:PKProjGuidKey,'Pro:PKProjGuidKey',0)
    SELF.AddKey(Pro:ProjDescriptionKey,'Pro:ProjDescriptionKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:Projects.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:BackUpFiles,RI:CASCADE,RI:None,Bac:FKProjGuidKey)
  SELF.AddRelationLink(Pro:PKProjGuid,Bac:FKProjGuid)


Hide:Relate:Projects.Kill PROCEDURE

  CODE
  _Hide:Access:Projects.Kill                               ! Kill the file manager
  PARENT.Kill
  Relate:Projects &= NULL                                  ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:Projects)                           ! destroy the file manager

