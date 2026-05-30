*&---------------------------------------------------------------------*
*&  Include           ZXV50BU06
*&---------------------------------------------------------------------*

** Implemented for the Object I109

DATA : LWA_EXTENSION1 TYPE  BAPIEXTC .

BREAK: SAGHULAM , TKRA .

LWA_EXTENSION1-FIELD1 = 'I109 TEST' .
APPEND LWA_EXTENSION1 TO ET_EXTENSION1 .
