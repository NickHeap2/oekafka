USING ABLContainer.Logging.* FROM PROPATH.
USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS Settings.ApplicationSettings INHERITS System.Object:

  DEFINE PUBLIC PROPERTY TestSetting AS CHARACTER NO-UNDO
  GET.
  SET.

  METHOD PUBLIC VOID LogCurrent(  ):

    Log:Information("Application Settings").
    Log:Information("  TestSetting: ~{TestSetting~}", BOX(THIS-OBJECT:TestSetting)).

  END METHOD.

END CLASS.