USING Progress.Lang.*.
// USING OpenEdge.Logging.ILogWriter.
// USING OpenEdge.Logging.LoggerBuilder.

BLOCK-LEVEL ON ERROR UNDO, THROW.


CLASS OEKafka.LibrdkafkaWrapper:

  // DEFINE VARIABLE logger AS ILogWriter NO-UNDO.

&SCOPED-DEFINE librdkafka-wrapper "liboekafka-wrapper.so.1" PERSISTENT CDECL
/*CDECL*/
/*
PROCEDURE SetDllDirectoryA EXTERNAL "kernel32":
    DEFINE INPUT  PARAMETER lpPathName AS INT64 NO-UNDO.
END PROCEDURE.
*/
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

PROCEDURE wrapper_create_producer EXTERNAL {&librdkafka-wrapper}:
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END PROCEDURE.

PROCEDURE wrapper_subscribe_to_topic EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER topic AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.

PROCEDURE wrapper_produce_message EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER topic AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER key AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER key_len AS INT64 NO-UNDO.
  DEFINE INPUT  PARAMETER payload AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER len AS INT64 NO-UNDO.
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

PROCEDURE wrapper_destroy_producer EXTERNAL {&librdkafka-wrapper}:
END PROCEDURE.

CONSTRUCTOR PUBLIC LibrdkafkaWrapper():
  // logger = LoggerBuilder:GetLogger("Default").

  /*MESSAGE "Checking processor architecture...".
  IF PROCESS-ARCHITECTURE = 64 THEN DO:
    MESSAGE "Setting dll directory for x64.".
    RUN SetDllDirectoryA(0).
  END.*/

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

METHOD INTEGER CreateProducer():

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_create_producer
    (OUTPUT callResult).
  RETURN callResult.

END METHOD.

METHOD VOID DestroyProducer():

  RUN wrapper_destroy_producer.

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

METHOD INTEGER ProduceMessage(topic AS CHARACTER, KEY AS CHARACTER, payload AS CHARACTER):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_produce_message
    (INPUT topic,
     key,
     LENGTH(key),
     payload,
     LENGTH(payload),
     OUTPUT callResult).

  RETURN callResult.

END METHOD.

METHOD INTEGER SetConfigOption(configName AS CHARACTER, configValue AS CHARACTER):

  DEFINE VARIABLE lastError AS CHARACTER NO-UNDO.

  DEFINE VARIABLE callresult AS INTEGER NO-UNDO.
  LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("    Setting config &1 to &2...", configName, configValue), "INFO").

  RUN wrapper_add_to_config
    (INPUT configname,
     INPUT configvalue,
     OUTPUT callresult).

  lastError = THIS-OBJECT:GetLastError().
  IF callresult <> 0 THEN DO:
    UNDO, THROW NEW AppError(SUBSTITUTE("        Failed to set config &1 to &2 with error: &3", configName, configValue, lastError), 1).
  END.
  IF lastError <> "" THEN DO:
    LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("        WARNING setting config &1 to &2 with message: &3", configName, configValue, lastError), "INFO").
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

