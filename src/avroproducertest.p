USING OEKafka.* FROM PROPATH.
/* USING OpenEdge.Logging.ILogWriter. */
/* USING OpenEdge.Logging.LoggerBuilder. */

BLOCK-LEVEL ON ERROR UNDO, THROW.

/* DEFINE VARIABLE logger AS ILogWriter NO-UNDO. */
/* logger = LoggerBuilder:GetLogger("Default"). */

DEFINE VARIABLE librdkafkaWrapper AS LibrdkafkaWrapper NO-UNDO.

librdkafkaWrapper = NEW LibrdkafkaWrapper().

DEFINE VARIABLE brokers  AS CHARACTER NO-UNDO.
DEFINE VARIABLE consumer_group  AS CHARACTER NO-UNDO.
DEFINE VARIABLE topic  AS CHARACTER NO-UNDO.
DEFINE VARIABLE offset_reset  AS CHARACTER NO-UNDO.
DEFINE VARIABLE debug  AS CHARACTER NO-UNDO.
DEFINE VARIABLE timeout AS INTEGER NO-UNDO.

DEFINE VARIABLE lastError AS CHARACTER NO-UNDO.
DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

/*PAUSE 0 BEFORE-HIDE.*/

/*brokers = "host.docker.internal:9092".*/
consumer_group = "rdkafka-consumer-group-1".
topic = "test-topic-2".
offset_reset = "latest".
debug = "".
timeout = 10000.

RUN LogInfo(INPUT "Setting config options...").

DO ON STOP UNDO, LEAVE:
  IF (DEBUG <> "") THEN DO:
    librdkafkaWrapper:SetConfigOption("debug", debug).
  END.

  librdkafkaWrapper:SetConfigOption("bootstrap.servers", brokers).
  librdkafkaWrapper:SetConfigOption("group.id", consumer_group).
  librdkafkaWrapper:SetConfigOption("auto.offset.reset", offset_reset).
/*  librdkafkaWrapper:SetConfigOption("junk", "setting").*/

  CATCH ae AS Progress.Lang.AppError:
    RUN LogFatal(INPUT ae:GetMessage(1)).
    QUIT.
  END CATCH.

END.

RUN LogInfo(INPUT "Creating producer...").
callResult = librdkafkaWrapper:CreateProducer().
RUN LogInfo(INPUT "  Getting last error...").
lastError = librdkafkaWrapper:GetLastError().
IF callResult <> 0 THEN DO:
  RUN LogFatal(INPUT SUBSTITUTE("    Failed to create producer with error:  &1", lastError)).
  QUIT.
END.
IF lastError <> "" THEN DO:
  RUN LogWarn(INPUT SUBSTITUTE("    WARNING CREATE producer returned: &1", lastError)).
END.

/* create serdes instance*/
RUN LogInfo(INPUT "Creating serdes...").
RUN LogInfo(INPUT "  Getting last error...").
lastError = librdkafkaWrapper:GetLastError().
IF callResult <> 0 THEN DO:
  RUN LogFatal(INPUT SUBSTITUTE("    Failed to create serdes with error:  &1", lastError)).
  QUIT.
END.
IF lastError <> "" THEN DO:
  RUN LogWarn(INPUT SUBSTITUTE("    WARNING CREATE serdes returned: &1", lastError)).
END.
/*SetSerdesConfigOption("name", "value").*/

/* register schemas */
 
DEFINE VARIABLE keySchema-memptr AS MEMPTR NO-UNDO.
DEFINE VARIABLE keySchema AS CHARACTER NO-UNDO.
/* load file */
COPY-LOB FROM FILE "keySchema.json" TO keySchema-memptr.

keySchema = GET-STRING(keySchema-memptr,1).
SET-SIZE(keySchema-memptr) = 0.

RUN LogInfo(INPUT "Registering key schema...").
callResult = librdkafkaWrapper:RegisterSchema("Key", topic + "-key", keySchema).
RUN LogInfo(INPUT "  Getting last error...").
lastError = librdkafkaWrapper:GetLastError().
IF callResult <> 0 THEN DO:
  RUN LogFatal(INPUT SUBSTITUTE("    Failed to register key schema with error:  &1", lastError)).
  QUIT.
END.
IF lastError <> "" THEN DO:
  RUN LogWarn(INPUT SUBSTITUTE("    WARNING register key schema returned: &1", lastError)).
END.

DEFINE VARIABLE valueSchema-memptr AS MEMPTR NO-UNDO.
DEFINE VARIABLE valueSchema AS CHARACTER NO-UNDO.
/* load file */
COPY-LOB FROM FILE "messageSchema.json" TO valueSchema-memptr.

valueSchema = GET-STRING(valueSchema-memptr,1).
SET-SIZE(valueSchema-memptr) = 0.

RUN LogInfo(INPUT "Registering value schema...").
callResult = librdkafkaWrapper:RegisterSchema("Value", topic + "-value", valueSchema).
RUN LogInfo(INPUT "  Getting last error...").
lastError = librdkafkaWrapper:GetLastError().
IF callResult <> 0 THEN DO:
  RUN LogFatal(INPUT SUBSTITUTE("    Failed to register value schema with error:  &1", lastError)).
  QUIT.
END.
IF lastError <> "" THEN DO:
  RUN LogWarn(INPUT SUBSTITUTE("    WARNING register value schema returned: &1", lastError)).
END.

DEFINE VARIABLE rkm AS INT64 NO-UNDO.

_GET_MESSAGES:
DO WHILE TRUE
  ON ENDKEY UNDO, LEAVE
  ON STOP UNDO, LEAVE:
  /*DEFINE VARIABLE key AS CHARACTER NO-UNDO.
  DEFINE VARIABLE payload AS CHARACTER NO-UNDO.
  key = "OEKEY".
  payload = "OEPAYLOAD".*/


  callResult = librdkafkaWrapper:CreateAvroMessage().
  lastError = librdkafkaWrapper:GetLastError().
  IF callResult <> 0 THEN DO:
    RUN LogError(INPUT SUBSTITUTE("    Failed to create avro message with error:  &1", lastError)).
  END.
  ELSE IF lastError <> "" THEN DO:
    RUN LogError(INPUT SUBSTITUTE("    Error creating avro message: &1", lastError)).
  END.


  callResult = librdkafkaWrapper:AddValueToMessageString("EventPayloadJson", "~{ 'json_value': 'the_value' ~}").
  lastError = librdkafkaWrapper:GetLastError().
  IF callResult <> 0 THEN DO:
    RUN LogError(INPUT SUBSTITUTE("    Failed to set EventPayloadJson value with error:  &1", lastError)).
  END.
  ELSE IF lastError <> "" THEN DO:
    RUN LogError(INPUT SUBSTITUTE("    Error setting EventPayloadJson value: &1", lastError)).
  END.

  callResult = librdkafkaWrapper:SerialiseAndSendMessage(topic, "KEY-1").
  lastError = librdkafkaWrapper:GetLastError().
  IF callResult <> 0 THEN DO:
    RUN LogError(INPUT SUBSTITUTE("    Failed to serialise and send message with error:  &1", lastError)).
  END.
  ELSE IF lastError <> "" THEN DO:
    RUN LogError(INPUT SUBSTITUTE("    Error serialising and sending message value: &1", lastError)).
  END.

  callResult = librdkafkaWrapper:DestroyAvroMessage().
  lastError = librdkafkaWrapper:GetLastError().
  IF callResult <> 0 THEN DO:
    RUN LogError(INPUT SUBSTITUTE("    Failed to destroy avro message with error:  &1", lastError)).
  END.
  ELSE IF lastError <> "" THEN DO:
    RUN LogError(INPUT SUBSTITUTE("    Error destroying avro message: &1", lastError)).
  END.

  /*RUN LogInfo(INPUT "Sending message...").
  callResult = librdkafkaWrapper:ProduceMessage(topic, key, payload).
  lastError = librdkafkaWrapper:GetLastError().
  IF callResult <> 0 THEN DO:
    RUN LogError(INPUT SUBSTITUTE("    Failed to produce message with error:  &1", lastError)).
  END.
  ELSE IF lastError <> "" THEN DO:
    RUN LogError(INPUT SUBSTITUTE("    Error producing message: &1", lastError)).
  END.*/

  /*PAUSE 0.01.*/
END.

RUN LogInfo(INPUT "Destroying producer...").
librdkafkaWrapper:DestroyProducer().

RUN LogInfo(INPUT "Completed!").

PROCEDURE LogInfo:
  DEFINE INPUT PARAMETER msg AS CHARACTER NO-UNDO.

  LOG-MANAGER:WRITE-MESSAGE(msg, "INFO").
END PROCEDURE.

PROCEDURE LogFatal:
  DEFINE INPUT PARAMETER msg AS CHARACTER NO-UNDO.

  LOG-MANAGER:WRITE-MESSAGE(msg, "FATAL").
END PROCEDURE.

PROCEDURE LogError:
  DEFINE INPUT PARAMETER msg AS CHARACTER NO-UNDO.

  LOG-MANAGER:WRITE-MESSAGE(msg, "ERROR").
END PROCEDURE.

PROCEDURE LogWarn:
  DEFINE INPUT PARAMETER msg AS CHARACTER NO-UNDO.

  LOG-MANAGER:WRITE-MESSAGE(msg, "WARN").
END PROCEDURE.
