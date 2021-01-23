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

brokers = "host.docker.internal:9092".
topic = "test-topic-2".
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

  CATCH ae AS Progress.Lang.AppError:
    RUN LogFatal(INPUT ae:GetMessage(1)).
    QUIT.
  END CATCH.

END.

RUN LogInfo(INPUT "Creating consumer...").
callResult = librdkafkaWrapper:CreateConsumer().
RUN LogInfo(INPUT "Getting last error...").
lastError = librdkafkaWrapper:GetLastError().
IF callResult <> 0 THEN DO:
  RUN LogFatal(INPUT SUBSTITUTE("    Failed to create consumer with error:  &1", lastError)).
  QUIT.
END.
IF lastError <> "" THEN DO:
  RUN LogWarn(INPUT SUBSTITUTE("    WARNING CREATE consumer returned: &1", lastError)).
END.

/* subscribe to a topic */
RUN LogInfo(INPUT SUBSTITUTE("Subscribing to topic &1...", topic)).

callResult = librdkafkaWrapper:SubscribeToTopic(topic).
lastError = librdkafkaWrapper:GetLastError().
IF callResult <> 0 THEN DO:
  RUN LogInfo(INPUT SUBSTITUTE("    Failed to subscribe to topic with error:  &1", lastError)).
  QUIT.
END.
IF lastError <> "" THEN DO:
  RUN LogInfo(INPUT SUBSTITUTE("    WARNING subscribe to topic returned: &1", lastError)).
END.



/* create serdes conf*/
RUN LogInfo(INPUT "Creating serdes conf...").

callResult = librdkafkaWrapper:CreateSerdesConf("http://localhost:8081").
RUN LogInfo(INPUT "  Getting last error...").
lastError = librdkafkaWrapper:GetLastError().
IF callResult <> 0 THEN DO:
  RUN LogFatal(INPUT SUBSTITUTE("    Failed to create serdes conf with error:  &1", lastError)).
  QUIT.
END.
IF lastError <> "" THEN DO:
  RUN LogWarn(INPUT SUBSTITUTE("    WARNING CREATE serdes conf returned: &1", lastError)).
END.

/* set debug value */
librdkafkaWrapper:SetSerdesConfigOption("debug", "all").

/* create serdes conf*/
RUN LogInfo(INPUT "Creating serdes instance...").

callResult = librdkafkaWrapper:CreateSerdes().
RUN LogInfo(INPUT "  Getting last error...").
lastError = librdkafkaWrapper:GetLastError().
IF callResult <> 0 THEN DO:
  RUN LogFatal(INPUT SUBSTITUTE("    Failed to create serdes with error:  &1", lastError)).
  QUIT.
END.
IF lastError <> "" THEN DO:
  RUN LogWarn(INPUT SUBSTITUTE("    WARNING CREATE serdes returned: &1", lastError)).
END.


DEFINE VARIABLE rkm AS INT64 NO-UNDO.

_GET_MESSAGES:
DO WHILE TRUE
  ON ENDKEY UNDO, LEAVE
  ON STOP UNDO, LEAVE:

  RUN LogInfo(INPUT "Getting message...").
  rkm = librdkafkaWrapper:GetMessage(timeout).
  lastError = librdkafkaWrapper:GetLastError().
  IF (rkm = ? OR rkm = 0) THEN DO:
    RUN LogInfo(INPUT "    No messages.").
    IF lastError <> "" THEN DO:
      RUN LogError(INPUT SUBSTITUTE("    Error getting MESSAGE: &1", lastError)).
    END.

    NEXT _GET_MESSAGES.
  END.
  ELSE DO:
    RUN LogInfo(INPUT "    Got MESSAGE").

    DEFINE VARIABLE avroMessage AS AvroMessage NO-UNDO.
    avroMessage = NEW AvroMessage(librdkafkaWrapper, rkm).

    IF avroMessage:err = 1 THEN DO:
      RUN LogError(INPUT "    Got Error!").
      NEXT _GET_MESSAGES.
    END.

    RUN LogInfo(INPUT SUBSTITUTE("        Partition: &1: Offset: &2", avroMessage:partition, avroMessage:offset)).
    RUN LogInfo(INPUT SUBSTITUTE("        Key: &1", avroMessage:keyValue)).
    RUN LogInfo(INPUT SUBSTITUTE("        Payload: &1", avroMessage:payloadValue)).

    DELETE OBJECT avroMessage.

  END.

END.

RUN LogInfo(INPUT "Destroying serdes...").
librdkafkaWrapper:DestroySerdes().

RUN LogInfo(INPUT "Destroying consumer...").
librdkafkaWrapper:DestroyConsumer().

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
