
 /*------------------------------------------------------------------------
    File        : LibrdkafkaWrapper
    Purpose     :
    Syntax      :
    Description :
    Author(s)   : Nick Heap
    Created     : Sat Feb 29 23:07:20 GMT 2020
    Notes       :
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS OEKafka.LibrdkafkaWrapper:

&SCOPED-DEFINE librdkafka-wrapper "librdkafka-wrapper" PERSISTENT

PROCEDURE SetDllDirectoryA EXTERNAL "kernel32":
    DEFINE INPUT  PARAMETER lpPathName AS INT64 NO-UNDO.
END PROCEDURE.

PROCEDURE wrapper_get_last_error EXTERNAL {&librdkafka-wrapper}:
  DEFINE RETURN PARAMETER last_error AS MEMPTR NO-UNDO.
END PROCEDURE.

PROCEDURE wrapper_add_to_config EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER configName AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER configValue AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.

PROCEDURE wrapper_create_consumer EXTERNAL {&librdkafka-wrapper}:
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END PROCEDURE.

PROCEDURE wrapper_subscribe_to_topic EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER topic AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.

PROCEDURE wrapper_get_message EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER timeout AS LONG NO-UNDO.
  DEFINE RETURN PARAMETER rkm AS INT64 NO-UNDO.
END.

PROCEDURE wrapper_destroy_message EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER rkm AS INT64 NO-UNDO.
END.

PROCEDURE wrapper_destroy_consumer EXTERNAL {&librdkafka-wrapper}:
END PROCEDURE.

CONSTRUCTOR PUBLIC LibrdkafkaWrapper():

  MESSAGE "Checking processor architecture...".
  IF PROCESS-ARCHITECTURE = 64 THEN DO:
    MESSAGE "Setting dll directory for x64.".
    RUN SetDllDirectoryA(0).
  END.

END CONSTRUCTOR.

METHOD INTEGER CreateConsumer():

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_create_consumer
    (OUTPUT callResult).
  RETURN callResult.

END METHOD.

METHOD VOID DestroyConsumer():

  RUN wrapper_destroy_consumer.

END METHOD.

METHOD VOID DestroyMessage(rkm AS INT64):

  RUN wrapper_destroy_message
    (INPUT rkm).

END METHOD.

METHOD CHARACTER GetLastError():

  DEFINE VARIABLE mplastError AS MEMPTR NO-UNDO.

  RUN wrapper_get_last_error
    (OUTPUT mplastError).
  RETURN GET-STRING(mplastError, 1).

END METHOD.

METHOD INT64 GetMessage(timeout AS INTEGER):

  DEFINE VARIABLE rkm AS INT64 NO-UNDO.

  RUN wrapper_get_message
    (INPUT timeout,
     OUTPUT rkm).

  RETURN rkm.

END METHOD.

METHOD INTEGER SetConfigOption(configName AS CHARACTER, configValue AS CHARACTER):

  DEFINE VARIABLE lastError AS CHARACTER NO-UNDO.

  DEFINE VARIABLE callresult AS INTEGER NO-UNDO.
  MESSAGE SUBSTITUTE("Setting config &1 to &2...", configName, configValue).

  RUN wrapper_add_to_config
    (INPUT configname,
     INPUT configvalue,
     OUTPUT callresult).

  lastError = THIS-OBJECT:GetLastError().
  IF callresult <> 0 THEN DO:
    UNDO, THROW NEW AppError(SUBSTITUTE("Failed to set config &1 to &2 with error: &3", configName, configValue, lastError), 1).
  END.
  IF lastError <> "" THEN DO:
    MESSAGE SUBSTITUTE("WARNING setting config &1 to &2 with message: &3", configName, configValue, lastError).
  END.

  RETURN callresult.

END METHOD.

METHOD INTEGER SubscribeToTopic(TOPIC AS CHARACTER):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_subscribe_to_topic
    (INPUT topic,
     OUTPUT callResult).

  RETURN callResult.

END METHOD.

END CLASS.