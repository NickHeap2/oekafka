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
consumer_group = "rdkafka-consumer-group-1".
topic = "test-topic".
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

    DEFINE VARIABLE kafkaMessage AS KafkaMessage NO-UNDO.
    kafkaMessage = NEW KafkaMessage(rkm).
    librdkafkaWrapper:DestroyMessage(rkm).

    IF kafkaMessage:err = 1 THEN DO:
      RUN LogError(INPUT "    Got Error!").
      NEXT _GET_MESSAGES.
    END.

    RUN LogInfo(INPUT SUBSTITUTE("        Partition: &1: Offset: &2", kafkaMessage:partition, kafkaMessage:offset)).
    RUN LogInfo(INPUT SUBSTITUTE("        Key: &1", kafkaMessage:keyValue)).
    RUN LogInfo(INPUT SUBSTITUTE("        Payload: &1", kafkaMessage:payloadValue)).
  END.

END.

RUN LogInfo(INPUT "Destroying consumer...").
librdkafkaWrapper:DestroyConsumer().

RUN LogInfo(INPUT "Completed!").

procedure LogInfo:
  define input parameter msg as character no-undo.

  log-manager:write-message(msg, "INFO").
end procedure.

procedure LogFatal:
  define input parameter msg as character no-undo.

  log-manager:write-message(msg, "FATAL").
end procedure.

procedure LogError:
  define input parameter msg as character no-undo.

  log-manager:write-message(msg, "ERROR").
end procedure.

procedure LogWarn:
  define input parameter msg as character no-undo.

  log-manager:write-message(msg, "WARN").
end procedure.
