USING OEKafka.* FROM PROPATH.
USING Progress.Lang.* FROM PROPATH.

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

/*PROCEDURE wrapper_produce_message EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER topic AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER key AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER key_len AS INT64 NO-UNDO.
  DEFINE INPUT  PARAMETER payload AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER len AS INT64 NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.*/

PROCEDURE wrapper_produce_message EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER topic AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER key AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER key_len AS INT64 NO-UNDO.
  DEFINE INPUT  PARAMETER payload AS MEMPTR NO-UNDO.
  DEFINE INPUT  PARAMETER len AS INT64 NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.

PROCEDURE wrapper_get_message EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER timeout AS LONG NO-UNDO.
  DEFINE RETURN PARAMETER rkm AS INT64 NO-UNDO.
END.

PROCEDURE wrapper_get_last_message EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER topic AS CHARACTER NO-UNDO.
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
PROCEDURE wrapper_create_serdes_conf EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER registryurl AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_create_serdes EXTERNAL {&librdkafka-wrapper}:
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
PROCEDURE wrapper_create_avro_offset EXTERNAL {&librdkafka-wrapper}:
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_add_value_to_message_string EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER field_name AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER field_value AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_add_value_to_offset_string EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER field_name AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER field_value AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_get_value_from_message_string EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER field_name AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_get_value_from_offset_string EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER field_name AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_destroy_avro_message EXTERNAL {&librdkafka-wrapper}:
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_destroy_avro_offset EXTERNAL {&librdkafka-wrapper}:
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_destroy_serdes EXTERNAL {&librdkafka-wrapper}:
END.
PROCEDURE wrapper_serialise_and_send_message EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER topic AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER key AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.
PROCEDURE wrapper_serialise_and_send_offset EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER topic AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER key AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.

PROCEDURE wrapper_flush EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER timeout_ms AS LONG NO-UNDO.
  DEFINE RETURN PARAMETER queue_size AS LONG NO-UNDO.
END PROCEDURE.

PROCEDURE wrapper_deserialise_message_key EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER rkm AS INT64 NO-UNDO.
  DEFINE OUTPUT PARAMETER avro_value AS INT64 NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.

PROCEDURE wrapper_deserialise_message_value EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER rkm AS INT64 NO-UNDO.
  DEFINE OUTPUT PARAMETER avro_value AS INT64 NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.

PROCEDURE wrapper_destroy_avro_value EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER avro_value AS INT64 NO-UNDO.
END.

PROCEDURE wrapper_get_avro_string EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER avro_value AS INT64 NO-UNDO.
  DEFINE OUTPUT PARAMETER key_string AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER key_size AS LONG NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.

PROCEDURE wrapper_get_value_field EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER avro_source AS INT64 NO-UNDO.
  DEFINE OUTPUT PARAMETER avro_value AS INT64 NO-UNDO.
  DEFINE INPUT  PARAMETER field_name AS CHARACTER NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.

PROCEDURE wrapper_extract_key_and_value EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER rkm AS INT64 NO-UNDO.
  DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
END.

PROCEDURE wrapper_get_key EXTERNAL {&librdkafka-wrapper}:
  DEFINE OUTPUT PARAMETER key_value AS CHARACTER NO-UNDO.
END.

PROCEDURE wrapper_get_value_field_string EXTERNAL {&librdkafka-wrapper}:
  DEFINE INPUT  PARAMETER field_name AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER field_value AS CHARACTER NO-UNDO.
END.

PROCEDURE wrapper_clear_values EXTERNAL {&librdkafka-wrapper}:
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

METHOD INT64 GetLastMessage(topicName AS CHARACTER, timeout AS INTEGER):

  DEFINE VARIABLE rkm AS INT64 NO-UNDO.

  RUN wrapper_get_last_message
    (INPUT topicName,
     INPUT timeout,
     OUTPUT rkm).

  RETURN rkm.

END METHOD.

METHOD AvroMessage GetAvroLastMessage(topicName AS CHARACTER, timeout AS INTEGER, payloadField AS CHARACTER):

  DEFINE VARIABLE rkm AS INT64 NO-UNDO.

  RUN wrapper_get_last_message
    (INPUT topicName,
     INPUT timeout,
     OUTPUT rkm).
  IF (rkm = ? OR rkm = 0) THEN DO:
    LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("    Error getting MESSAGE rkm = ? or 0"), "INFO").
    /*Log:Information("    No messages.").
    IF lastError <> "" THEN DO:
      Log:Error(SUBSTITUTE("    Error getting MESSAGE: &1", lastError)).
    END.*/
    RETURN ?.
  END.
  ELSE DO:
    DEFINE VARIABLE avroMessage AS AvroMessage NO-UNDO.
    avroMessage = NEW AvroMessage(THIS-OBJECT, rkm, payloadField).
    IF avroMessage:err <> 0 THEN DO:
      LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("    Error getting MESSAGE avroMessage:err <> 0"), "INFO").
      RETURN ?.
    END.

    LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("        Partition: &1: Offset: &2", avroMessage:partition, avroMessage:offset), "INFO").
    LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("        Key: &1", avroMessage:keyValue), "INFO").
    LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("        Payload: &1", avroMessage:payloadValue), "INFO").

    RETURN avroMessage.
  END.

END METHOD.

METHOD AvroMessage GetAvroMessage(timeout AS INTEGER, payloadField AS CHARACTER):

  DEFINE VARIABLE rkm AS INT64 NO-UNDO.

  RUN wrapper_get_message
    (INPUT timeout,
     OUTPUT rkm).
  IF (rkm = ? OR rkm = 0) THEN DO:
    LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("    Error getting MESSAGE rkm = ? or 0"), "INFO").
    /*Log:Information("    No messages.").
    IF lastError <> "" THEN DO:
      Log:Error(SUBSTITUTE("    Error getting MESSAGE: &1", lastError)).
    END.*/
    RETURN ?.
  END.
  ELSE DO:
    DEFINE VARIABLE avroMessage AS AvroMessage NO-UNDO.
    avroMessage = NEW AvroMessage(THIS-OBJECT, rkm, payloadField).
    IF avroMessage:err = 1 THEN DO:
      LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("    Error getting MESSAGE avroMessage:err = 1"), "INFO").
      RETURN ?.
    END.

    LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("        Partition: &1: Offset: &2", avroMessage:partition, avroMessage:offset), "INFO").
    LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("        Key: &1", avroMessage:keyValue), "INFO").
    LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("        Payload: &1", avroMessage:payloadValue), "INFO").

    RETURN avroMessage.
  END.

END METHOD.

METHOD INTEGER ProduceMessage(topic AS CHARACTER, key AS CHARACTER, payload AS LONGCHAR):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  DEFINE VARIABLE memptrValue AS MEMPTR NO-UNDO.

  SET-SIZE(memptrValue) = LENGTH(payload).
  /*COPY-LOB FROM payload TO memptrValue.*/
  PUT-STRING(memptrValue, 1) = payload.

  RUN wrapper_produce_message
    (INPUT topic,
     key,
     LENGTH(key),
     memptrValue,
     GET-SIZE(memptrValue),
     OUTPUT callResult).

  SET-SIZE(memptrValue) = 0.

  RETURN callResult.

END METHOD.

METHOD INTEGER ProduceMessage(topic AS CHARACTER, key AS CHARACTER, payload AS CHARACTER):

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

METHOD INTEGER ProduceOffset(topic AS CHARACTER, key AS CHARACTER, offsetValue AS CHARACTER):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_produce_message
    (INPUT topic,
     key,
     LENGTH(key),
     offsetValue,
     LENGTH(offsetValue),
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
METHOD INTEGER CreateSerdesConf(schemaRegistryUrl AS CHARACTER):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_create_serdes_conf
    (INPUT schemaRegistryUrl,
     OUTPUT callResult).
  RETURN callResult.

END METHOD.

METHOD INTEGER CreateSerdes():

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_create_serdes
    (OUTPUT callResult).
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

METHOD INTEGER CreateAvroOffset():

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_create_avro_offset
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

METHOD INTEGER AddValueToOffsetString(fieldName AS CHARACTER, fieldValue AS CHARACTER):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_add_value_to_offset_string
    (INPUT fieldName,
     INPUT fieldValue,
     OUTPUT callResult).
  RETURN callResult.
END METHOD.

METHOD INTEGER AddValueToMessageString(fieldName AS CHARACTER, fieldValue AS LONGCHAR):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_add_value_to_message_string
    (INPUT fieldName,
     INPUT fieldValue,
     OUTPUT callResult).
  RETURN callResult.
END METHOD.

METHOD INTEGER AddValueToOffsetString(fieldName AS CHARACTER, fieldValue AS LONGCHAR):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_add_value_to_offset_string
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

METHOD INTEGER GetValueFromOffsetString(fieldName AS CHARACTER):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_get_value_from_offset_string
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

METHOD INTEGER DestroyAvroOffset():

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_destroy_avro_offset
    (OUTPUT callResult).
  RETURN callResult.
END METHOD.

METHOD INTEGER SerialiseAndSendMessage(topic AS CHARACTER, key AS CHARACTER):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_serialise_and_send_message
    (INPUT topic,
     INPUT key,
     OUTPUT callResult).
  RETURN callResult.
END METHOD.

METHOD INTEGER SerialiseAndSendOffset(topic AS CHARACTER, key AS CHARACTER):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_serialise_and_send_offset
    (INPUT topic,
     INPUT key,
     OUTPUT callResult).
  RETURN callResult.
END METHOD.

METHOD CHARACTER GetMessageKey(rkm AS INT64):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.
  DEFINE VARIABLE avro_key AS INT64 NO-UNDO.

  LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("        Calling wrapper_deserialise_message_key"), "INFO").
  RUN wrapper_deserialise_message_key
    (INPUT rkm,
     OUTPUT avro_key,
     OUTPUT callResult).
  IF callResult <> 0 THEN DO:
    RETURN ?.
  END.

  /*message avro_key.*/
  LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("        avro_key = [&1]", avro_key), "INFO").

  /*DEFINE VARIABLE key_memptr AS MEMPTR NO-UNDO.*/
  DEFINE VARIABLE avro_value AS INT64 NO-UNDO.
  DEFINE VARIABLE key_string AS CHARACTER NO-UNDO.
  DEFINE VARIABLE key_size AS INTEGER NO-UNDO.
  
  key_string = FILL(" ", 1000).

  /*SET-POINTER-VALUE(key_memptr) = key_string.*/

  LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("        Calling wrapper_get_avro_string"), "INFO").
  RUN wrapper_get_avro_string
    (INPUT avro_key,
     OUTPUT  key_string,
     OUTPUT  key_size,
     OUTPUT callResult).
  IF callResult <> 0 THEN DO:
    RETURN ?.
  END.

  LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("        Back from wrapper_get_avro_string"), "INFO").
  

  /*PROCEDURE wrapper_get_avro_string EXTERNAL {&librdkafka-wrapper}:
    DEFINE INPUT  PARAMETER avro_value AS INT64 NO-UNDO.
    DEFINE INPUT  PARAMETER key_string AS INT64 NO-UNDO.
    DEFINE INPUT  PARAMETER key_size AS INT64 NO-UNDO.
    DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
  END.
  
  PROCEDURE wrapper_get_value_field EXTERNAL {&librdkafka-wrapper}:
    DEFINE INPUT  PARAMETER avro_source AS INT64 NO-UNDO.
    DEFINE INPUT  PARAMETER avro_value AS INT64 NO-UNDO.
    DEFINE INPUT  PARAMETER field_name AS CHARACTER NO-UNDO.
    DEFINE RETURN PARAMETER callresult AS LONG NO-UNDO.
  END.*/


  /*RUN wrapper_serialise_and_send_message
  (INPUT topic,
   INPUT key,
   OUTPUT callResult).
RETURN callResult.*/
END METHOD.

METHOD INTEGER ExtractKeyAndValue(rkm AS INT64):

  DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

  RUN wrapper_extract_key_and_value
    (INPUT rkm,
     OUTPUT callResult).
  RETURN callResult.
END METHOD.

METHOD CHARACTER GetKey():
  
  DEFINE VARIABLE key_value AS CHARACTER NO-UNDO.
/*  DEFINE VARIABLE p_char AS INT64 NO-UNDO.*/
/*  DEFINE VARIABLE p_key_value AS MEMPTR NO-UNDO.*/

  key_value = FILL(" ", 1000).

  RUN wrapper_get_key
    (OUTPUT key_value).
/*  LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("        Back from wrapper_get_key with &1 ", key_value), "INFO").*/

/*  SET-SIZE(p_key_value) = 1000.          */
/*  RUN wrapper_get_key                    */
/*    (OUTPUT p_key_value).                */
/*  key_value = GET-STRING(p_key_value, 1).*/
/*  SET-SIZE(p_key_value) = 0.             */

/*  RUN wrapper_get_key                                                                                 */
/*    (OUTPUT p_char).                                                                                  */
/*  LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("        Back from wrapper_get_key with &1 ", p_char), "INFO").*/
/*                                                                                                      */
/*  SET-POINTER-VALUE(p_key_value) = p_char.                                                            */
/*  key_value = GET-STRING(p_key_value, 1).                                                             */
/*  SET-POINTER-VALUE(p_key_value) = 0.                                                                 */

  RETURN key_value.
END METHOD.

METHOD CHARACTER GetValueFieldString(fieldName AS CHARACTER):
  
  DEFINE VARIABLE field_value AS CHARACTER NO-UNDO.
/*  DEFINE VARIABLE p_char AS INT64 NO-UNDO.*/
/*  DEFINE VARIABLE p_field_value AS MEMPTR NO-UNDO.*/

  field_value = FILL(" ", 31991).

  RUN wrapper_get_value_field_string
    (INPUT fieldName,
     OUTPUT field_value).
/*  LOG-MANAGER:WRITE-MESSAGE(SUBSTITUTE("        Back from wrapper_get_key with &1 ", field_value), "INFO").*/

/*  RUN wrapper_get_key      */
/*    (INPUT fieldName,      */
/*     OUTPUT p_field_value).*/

/*  RUN wrapper_get_key                        */
/*    (INPUT fieldName,                        */
/*     OUTPUT p_char).                         */
/*  SET-POINTER-VALUE(p_field_value) = p_char. */
/*  field_value = GET-STRING(p_field_value, 1).*/
/*  SET-POINTER-VALUE(p_field_value) = 0.      */

  RETURN field_value.
END METHOD.

METHOD INTEGER Flush (timeoutMs AS INTEGER):
  DEFINE VARIABLE queueLength AS INTEGER NO-UNDO.

  RUN wrapper_flush
    (INPUT timeoutMs,
     OUTPUT queueLength).
  RETURN queueLength.

END METHOD.

METHOD INTEGER ClearValues():
  RUN wrapper_clear_values.
END METHOD.

END CLASS.
