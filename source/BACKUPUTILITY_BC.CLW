  MEMBER('BackUpUtility.clw')

  PRAGMA('define(init_priority=>3)')

  MAP
    MODULE('BackUpUtility_BC0.CLW')
BackUpUtility_BC0:DctInit             PROCEDURE()
BackUpUtility_BC0:DctKill             PROCEDURE()
BackUpUtility_BC0:FilesInit           PROCEDURE()
    END
  END

DctInit PROCEDURE()
  CODE
  BackUpUtility_BC0:DctInit
  BackUpUtility_BC0:FilesInit


DctKill PROCEDURE()
  CODE
  BackUpUtility_BC0:DctKill

