USING OEKafka.* FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE librdKafkaWrapper AS LibrdKafkaWrapper NO-UNDO.

librdKafkaWrapper = NEW LibrdKafkaWrapper().

DEFINE VARIABLE brokers  AS CHARACTER NO-UNDO.
DEFINE VARIABLE consumer_group  AS CHARACTER NO-UNDO.
DEFINE VARIABLE topic  AS CHARACTER NO-UNDO.
DEFINE VARIABLE offset_reset  AS CHARACTER NO-UNDO.
DEFINE VARIABLE debug  AS CHARACTER NO-UNDO.
DEFINE VARIABLE timeout AS INTEGER NO-UNDO.

DEFINE VARIABLE lastError AS CHARACTER NO-UNDO.
DEFINE VARIABLE callResult AS INTEGER NO-UNDO.

brokers = "localhost:9092".
consumer_group = "rdkafka-consumer-group-1".
topic = "_schemas".
offset_reset = "earliest".
debug = "".
timeout = 1000.


MESSAGE "Setting config options...".

DO ON STOP UNDO, LEAVE:
  IF (DEBUG <> "") THEN DO:
    librdKafkaWrapper:SetConfigOption("debug", debug).
  END.

  librdKafkaWrapper:SetConfigOption("bootstrap.servers", brokers).
  librdKafkaWrapper:SetConfigOption("group.id", consumer_group).
  librdKafkaWrapper:SetConfigOption("auto.offset.reset", offset_reset).
/*  librdKafkaWrapper:SetConfigOption("junk", "setting").*/

  CATCH ae AS Progress.Lang.AppError:
    MESSAGE ae:GetMessage(1).
    QUIT.
  END CATCH.

END.

MESSAGE "Creating consumer...".
callResult = librdKafkaWrapper:CreateConsumer().
lastError = librdKafkaWrapper:GetLastError().
IF callResult <> 0 THEN DO:
  MESSAGE SUBSTITUTE("Failed to create consumer with error:  &1", lastError).
  QUIT.
END.
IF lastError <> "" THEN DO:
  MESSAGE SUBSTITUTE("WARNING CREATE consumer returned: &1", lastError).
END.

/* subscribe to a topic */
MESSAGE SUBSTITUTE("Subscribing to topic &1...", topic).

callResult = librdKafkaWrapper:SubscribeToTopic(topic).
lastError = librdKafkaWrapper:GetLastError().
IF callResult <> 0 THEN DO:
  MESSAGE SUBSTITUTE("Failed to subscribe to topic with error:  &1", lastError).
  QUIT.
END.
IF lastError <> "" THEN DO:
  MESSAGE SUBSTITUTE("WARNING subscribe to topic returned: &1", lastError).
END.

DEFINE VARIABLE rkm AS INT64 NO-UNDO.

_GET_MESSAGES:
DO WHILE TRUE
  ON ENDKEY UNDO, LEAVE
  ON STOP UNDO, LEAVE:
  rkm = librdKafkaWrapper:GetMessage(timeout).
  lastError = librdKafkaWrapper:GetLastError().
  IF (rkm = ? OR rkm = 0) THEN DO:
    MESSAGE "NO MESSAGE".
    IF lastError <> "" THEN DO:
      MESSAGE SUBSTITUTE("Error getting MESSAGE: &1", lastError).
    END.

    NEXT _GET_MESSAGES.
  END.
  ELSE DO:
    MESSAGE "Got MESSAGE".

    DEFINE VARIABLE kafkaMessage AS KafkaMessage NO-UNDO.
    kafkaMessage = NEW KafkaMessage(rkm).
    librdKafkaWrapper:DestroyMessage(rkm).

    MESSAGE SUBSTITUTE("Partition: &1: Offset: &2", kafkaMessage:partition, kafkaMessage:offset).
    MESSAGE SUBSTITUTE("Key: &1", kafkaMessage:keyValue).
    MESSAGE SUBSTITUTE("Payload: &1", kafkaMessage:payloadValue).
  END.

END.

MESSAGE "Destroying consumer...".
librdKafkaWrapper:DestroyConsumer().

MESSAGE "Completed!".
