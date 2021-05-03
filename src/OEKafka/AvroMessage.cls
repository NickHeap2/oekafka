USING OEKafka.* FROM PROPATH.
USING Progress.Lang.* FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS OEKafka.AvroMessage:

  DEFINE PUBLIC PROPERTY rkm AS INT64 NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY err AS INT64 NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY rkt AS INT64 NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY partition AS INT64 NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY payload AS INT64 NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY len AS INT64 NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY key AS INT64 NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY key_len AS INT64 NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY offset AS INT64 NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY private AS INT64 NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY keyValue AS CHARACTER NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY payloadValue AS CHARACTER NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY errorMessage AS CHARACTER NO-UNDO
  GET.
  SET.

  DEFINE PUBLIC PROPERTY librdkafka AS LibrdkafkaWrapper NO-UNDO
  GET.
  SET.

CONSTRUCTOR PUBLIC AvroMessage (librdkafka AS LibrdkafkaWrapper, rkm AS INT64, payloadField AS CHARACTER):
  DEFINE VARIABLE ptr_rkm AS MEMPTR NO-UNDO.

  THIS-OBJECT:librdkafka = librdkafka.
  THIS-OBJECT:rkm = rkm.

  SET-POINTER-VALUE(ptr_rkm) = rkm.
  THIS-OBJECT:err = GET-BYTES(ptr_rkm, 1, 8).
  THIS-OBJECT:rkt = GET-BYTES(ptr_rkm, 9, 16).
  THIS-OBJECT:partition = GET-BYTES(ptr_rkm, 17, 24).
  THIS-OBJECT:payload = GET-BYTES(ptr_rkm, 25, 32).
  THIS-OBJECT:len = GET-BYTES(ptr_rkm, 33, 40).
  THIS-OBJECT:key = GET-BYTES(ptr_rkm, 41, 48).
  THIS-OBJECT:key_len = GET-BYTES(ptr_rkm, 49, 56).
  THIS-OBJECT:offset = GET-BYTES(ptr_rkm, 57, 64).
  THIS-OBJECT:private = GET-BYTES(ptr_rkm, 65, 72).

/*  THIS-OBJECT:keyValue = THIS-OBJECT:librdkafka:GetMessageKey(rkm).*/

  /* is this an error message? */
  IF THIS-OBJECT:err <> 0 THEN DO:
    errorMessage = THIS-OBJECT:librdkafka:GetLastError().
    RETURN.
  END.

  /*MESSAGE "keyValue:".
  MESSAGE keyValue.*/
  DEFINE VARIABLE callresult AS INTEGER NO-UNDO.
  DEFINE VARIABLE lastError   AS CHARACTER NO-UNDO.

  callresult = THIS-OBJECT:librdkafka:ExtractKeyAndValue(rkm).
  IF callresult <> 0 THEN DO:
    lastError = THIS-OBJECT:librdkafka:GetLastError().
    UNDO, THROW NEW AppError(SUBSTITUTE("Failed to extract key and value with result: &1 error message: &2", callresult, lastError)).
  END.

  THIS-OBJECT:keyValue = THIS-OBJECT:librdkafka:GetKey().

  THIS-OBJECT:payloadValue = THIS-OBJECT:librdkafka:GetValueFieldString(payloadField).

  THIS-OBJECT:librdkafka:ClearValues().

  /*
  DEFINE VARIABLE readableStart AS INTEGER NO-UNDO.
  DEFINE VARIABLE headerLength AS INTEGER NO-UNDO.

  IF THIS-OBJECT:key_len > 0 THEN DO:

    DEFINE VARIABLE ptr_key AS MEMPTR NO-UNDO.
    SET-POINTER-VALUE(ptr_key) = THIS-OBJECT:key.

    readableStart = 1.
    /* serdes? */
    IF GET-BYTE(ptr_key, 1) = 0 THEN DO:
      headerLength = GET-BYTE(ptr_key, 5).
      readableStart = 6 + headerLength.
      THIS-OBJECT:keyValue = GET-STRING(ptr_key, readableStart, THIS-OBJECT:key_len - readableStart).
    END.
    ELSE DO:
      THIS-OBJECT:keyValue = GET-STRING(ptr_key, 1, THIS-OBJECT:key_len).
    END.

    SET-POINTER-VALUE(ptr_key) = 0.
  END.

  IF THIS-OBJECT:len > 0 THEN DO:

    DEFINE VARIABLE ptr_payload AS MEMPTR NO-UNDO.
    SET-POINTER-VALUE(ptr_payload) = THIS-OBJECT:payload.

    readableStart = 1.
    /* serdes? */
    IF GET-BYTE(ptr_payload, 1) = 0 THEN DO:
      headerLength = GET-BYTE(ptr_payload, 5).
      readableStart = 6 + headerLength.
      THIS-OBJECT:payloadValue = GET-STRING(ptr_payload, readableStart, THIS-OBJECT:len - readableStart).
    END.
    ELSE DO:
      THIS-OBJECT:payloadValue = GET-STRING(ptr_payload, 1, THIS-OBJECT:len).
    END.

    SET-POINTER-VALUE(ptr_payload) = 0.
  END.

  SET-POINTER-VALUE(ptr_rkm) = 0.
*/
END CONSTRUCTOR.

DESTRUCTOR PUBLIC AvroMessage():

  THIS-OBJECT:librdkafka:DestroyMessage(THIS-OBJECT:rkm).

END DESTRUCTOR.

END CLASS.