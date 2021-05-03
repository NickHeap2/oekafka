USING ABLContainer.Logging.* FROM PROPATH.
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
consumer_group = "rdkafka-consumer-group-1".
offset_reset = "latest".
debug = "".
timeout = 10000.

Log:Information( "Setting config options...").

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

Log:Information("Creating consumer...").
callResult = librdkafkaWrapper:CreateConsumer().
Log:Information("Getting last error...").
lastError = librdkafkaWrapper:GetLastError().
IF callResult <> 0 THEN DO:
  Log:Error(SUBSTITUTE("    Failed to create consumer with error:  &1", lastError)).
  QUIT.
END.
IF lastError <> "" THEN DO:
  Log:Warning(SUBSTITUTE("    WARNING CREATE consumer returned: &1", lastError)).
END.

/* subscribe to a topic */
Log:Information(SUBSTITUTE("Subscribing to topic &1...", topic)).

callResult = librdkafkaWrapper:SubscribeToTopic(topic).
lastError = librdkafkaWrapper:GetLastError().
IF callResult <> 0 THEN DO:
  Log:Error(SUBSTITUTE("    Failed to subscribe to topic with error:  &1", lastError)).
  QUIT.
END.
IF lastError <> "" THEN DO:
  Log:Warning(SUBSTITUTE("    WARNING subscribe to topic returned: &1", lastError)).
END.



/* create serdes conf*/
Log:Information("Creating serdes conf...").

callResult = librdkafkaWrapper:CreateSerdesConf("http://localhost:8081").
Log:Information("  Getting last error...").
lastError = librdkafkaWrapper:GetLastError().
IF callResult <> 0 THEN DO:
  Log:Error(SUBSTITUTE("    Failed to create serdes conf with error:  &1", lastError)).
  QUIT.
END.
IF lastError <> "" THEN DO:
  Log:Warning(SUBSTITUTE("    WARNING CREATE serdes conf returned: &1", lastError)).
END.

/* set debug value */
librdkafkaWrapper:SetSerdesConfigOption("debug", "all").

/* create serdes conf*/
Log:Information("Creating serdes instance...").

callResult = librdkafkaWrapper:CreateSerdes().
Log:Information("  Getting last error...").
lastError = librdkafkaWrapper:GetLastError().
IF callResult <> 0 THEN DO:
  Log:Error(SUBSTITUTE("    Failed to create serdes with error:  &1", lastError)).
  QUIT.
END.
IF lastError <> "" THEN DO:
  Log:Warning(SUBSTITUTE("    WARNING CREATE serdes returned: &1", lastError)).
END.


DEFINE VARIABLE rkm AS INT64 NO-UNDO.

DEFINE VARIABLE consumerNumMessage AS INTEGER NO-UNDO.

consumerNumMessage = 0.
_GET_MESSAGES:
DO WHILE consumerNumMessage < 100
  ON ENDKEY UNDO, LEAVE
  ON STOP UNDO, LEAVE:
  consumerNumMessage = consumerNumMessage + 1.

  Log:Information("Getting message...").
  rkm = librdkafkaWrapper:GetMessage(timeout).
  lastError = librdkafkaWrapper:GetLastError().
  IF (rkm = ? OR rkm = 0) THEN DO:
    Log:Information("    No messages.").
    IF lastError <> "" THEN DO:
      Log:Error(SUBSTITUTE("    Error getting MESSAGE: &1", lastError)).
    END.

    NEXT _GET_MESSAGES.
  END.
  ELSE DO:
    Log:Information("    Got MESSAGE").

    DEFINE VARIABLE avroMessage AS AvroMessage NO-UNDO.
    avroMessage = NEW AvroMessage(librdkafkaWrapper, rkm, "EventPayloadJson").

    IF avroMessage:err = 1 THEN DO:
      Log:Error("    Got Error!").
      NEXT _GET_MESSAGES.
    END.

    Log:Information(SUBSTITUTE("        Partition: &1: Offset: &2", avroMessage:partition, avroMessage:offset)).
    Log:Information(SUBSTITUTE("        Key: &1", avroMessage:keyValue)).
    Log:Information(SUBSTITUTE("        Payload: &1", avroMessage:payloadValue)).

    DELETE OBJECT avroMessage.

  END.

END.

Log:Information("Destroying serdes...").
librdkafkaWrapper:DestroySerdes().

Log:Information("Destroying consumer...").
librdkafkaWrapper:DestroyConsumer().

Log:Information("Completed!").
