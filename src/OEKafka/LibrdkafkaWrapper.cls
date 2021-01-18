USING Progress.Lang.*.
/* USING OpenEdge.Logging.ILogWriter. */
/* USING OpenEdge.Logging.LoggerBuilder. */

BLOCK-LEVEL ON ERROR UNDO, THROW.


CLASS OEKafka.LibrdkafkaWrapper:

  /* DEFINE VARIABLE logger AS ILogWriter NO-UNDO. */

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

/* serdes */
PROCEDURE wrapper_create_serdes EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER registryurl AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_add_to_serdes_config EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER configname AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER configvalue AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_register_value_schema EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER value_schema_name AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER value_schema_definition AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_register_key_schema EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER key_schema_name AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER key_schema_definition AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_register_offset_schema EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER offset_schema_name AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER offset_schema_definition AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_create_avro_message EXTERNAL {&librdkafka-wrapper}:
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_add_value_to_message_string EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER field_name AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER field_value AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_get_value_from_message_string EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER field_name AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_destroy_avro_message EXTERNAL {&librdkafka-wrapper}:
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_destroy_serdes EXTERNAL {&librdkafka-wrapper}:
END.
PROCEDURE wrapper_serialiase_and_send_message EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER topic AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER key AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.

CONSTRUCTOR PUBLIC LibrdkafkaWrapper():
  /* logger = LoggerBuilder:GetLogger("Default"). */

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

/* serdes */
METHOD INTEGER CreateSerdes(schemaRegistryUrl AS CHARACTER):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_create_serdes
    (INPUT schemaRegistryUrl,
     OUTPUT callResult).
  RETURN callResult.

END METHOD.

METHOD VOID DestroySerdes():

  RUN wrapper_destroy_serdes.

END METHOD.

METHOD INTEGER SetSerdesConfigOption(configname AS CHARACTER, configvalue AS CHARACTER):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_add_to_serdes_config
    (INPUT configname,
     INPUT configvalue,
     OUTPUT callResult).
  RETURN callResult.
END METHOD.

METHOD INTEGER RegisterSchema(schemaType AS CHARACTER, schemaName AS CHARACTER, schemaDefinition AS CHARACTER):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  IF schemaType = "Key" THEN DO:
    RUN wrapper_register_key_schema
      (INPUT schemaName,
       INPUT schemaDefinition,
       OUTPUT callResult).
    RETURN callResult.
  END.
  IF schemaType = "Value" THEN DO:
    RUN wrapper_register_value_schema
      (INPUT schemaName,
       INPUT schemaDefinition,
       OUTPUT callResult).
    RETURN callResult.
  END.
  IF schemaType = "Offset" THEN DO:
    RUN wrapper_register_offset_schema
      (INPUT schemaName,
       INPUT schemaDefinition,
       OUTPUT callResult).
    RETURN callResult.
  END.

END METHOD.

METHOD INTEGER CreateAvroMessage():

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_create_avro_message
    (OUTPUT callResult).
  RETURN callResult.
END METHOD.

METHOD INTEGER AddValueToMessageString(fieldName AS CHARACTER, fieldValue AS CHARACTER):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_add_value_to_message_string
    (INPUT fieldName,
     INPUT fieldValue,
     OUTPUT callResult).
  RETURN callResult.
END METHOD.

METHOD INTEGER GetValueFromMessageString(fieldName AS CHARACTER):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_get_value_from_message_string
    (INPUT fieldName,
     OUTPUT callResult).
  RETURN callResult.
END METHOD.

METHOD INTEGER DestroyAvroMessage():

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_destroy_avro_message
    (OUTPUT callResult).
  RETURN callResult.
END METHOD.

METHOD INTEGER SerialiseAndSendMessage(topic AS CHARACTER, key AS CHARACTER):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_serialiase_and_send_message
    (INPUT topic,
     INPUT key,
     OUTPUT callResult).
  RETURN callResult.
END METHOD.


END CLASS.
