USING ABLContainer.Logging.* FROM PROPATH.
USING Progress.Lang.*.
USING Settings.* FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS Settings.Settings INHERITS System.Object:

  DEFINE PRIVATE STATIC PROPERTY applicationSettings AS ApplicationSettings NO-UNDO
  PRIVATE GET.
  PRIVATE SET.

  DEFINE PUBLIC STATIC PROPERTY Application AS ApplicationSettings NO-UNDO
  GET:
    IF NOT VALID-OBJECT(applicationSettings) THEN DO:
      applicationSettings = NEW ApplicationSettings().

      IF VALID-OBJECT(ABLContainer.Configuration.Configuration:Current) THEN DO:
        ABLContainer.Configuration.Configuration:Current:GetSection("Application"):Bind(applicationSettings).
      END.
      applicationSettings:LogCurrent().
    END.

    RETURN applicationSettings.
  END GET.
  SET.

END CLASS.