USING OpenEdge.Core.Assert.
USING Progress.Json.ObjectModel.*.
USING Progress.Lang.*.
USING Settings.* FROM PROPATH.
USING ABLContainer.Configuration.ConfigurationBuilder FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS test_Settings: 
  DEFINE VARIABLE applicationSettings AS ApplicationSettings NO-UNDO.

  @Setup.
  METHOD PUBLIC VOID setUp(  ):

    DEFINE VARIABLE configurationBuilder AS ABLContainer.Configuration.ConfigurationBuilder NO-UNDO.
    configurationBuilder = NEW ConfigurationBuilder().
    ABLContainer.Configuration.Configuration:Current = configurationBuilder:Build().

    Assert:NotNull(ABLContainer.Configuration.Configuration:Current).

    applicationSettings = Settings:Application.

    Assert:NotNull(applicationSettings).
    Assert:IsType(applicationSettings, GET-CLASS("ApplicationSettings")).

  END METHOD.

  @Test.
  METHOD PUBLIC VOID canReturnProperty(  ):

    DEFINE VARIABLE cPropertyValue AS CHARACTER NO-UNDO.
    cPropertyValue = applicationSettings:TestSetting.

  END METHOD.
  
  @Test.
  METHOD PUBLIC VOID canLogCurrentSettings(  ):

    applicationSettings:LogCurrent().

  END METHOD.

  @TearDown.
  METHOD PUBLIC VOID tearDown(  ):

    IF VALID-OBJECT(applicationSettings) THEN DO:
      DELETE OBJECT applicationSettings.
    END.

  END METHOD.

END CLASS.