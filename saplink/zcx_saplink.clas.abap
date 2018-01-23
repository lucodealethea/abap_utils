class ZCX_SAPLINK definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  constants ERROR_MESSAGE type SOTR_CONC value '525400927CE21EE7BFFA34D9008BEFF5' ##NO_TEXT.
  constants EXISTING type SOTR_CONC value '525400927CE21EE7BFFA34D9008C0FF5' ##NO_TEXT.
  constants INCORRECT_FILE_FORMAT type SOTR_CONC value '525400927CE21EE7BFFA34D9008C2FF5' ##NO_TEXT.
  constants LOCKED type SOTR_CONC value '525400927CE21EE7BFFA34D9008C4FF5' ##NO_TEXT.
  data MSG type STRING value '44F7518323DB08BC02000000A7E42BB6' ##NO_TEXT.
  constants NOT_AUTHORIZED type SOTR_CONC value '525400927CE21EE7BFFA34D9008C6FF5' ##NO_TEXT.
  constants NOT_FOUND type SOTR_CONC value '525400927CE21EE7BFFA34D9008C8FF5' ##NO_TEXT.
  constants NO_PLUGIN type SOTR_CONC value '525400927CE21EE7BFFA34D9008CAFF5' ##NO_TEXT.
  constants SYSTEM_ERROR type SOTR_CONC value '525400927CE21EE7BFFA34D9008CCFF5' ##NO_TEXT.
  constants ZCX_SAPLINK type SOTR_CONC value '525400927CE21EE7BFFA34D9008CEFF5' ##NO_TEXT.
  data OBJECT type STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !MSG type STRING default '44F7518323DB08BC02000000A7E42BB6'
      !OBJECT type STRING optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_SAPLINK IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
 IF textid IS INITIAL.
   me->textid = ZCX_SAPLINK .
 ENDIF.
me->MSG = MSG .
me->OBJECT = OBJECT .
  endmethod.
ENDCLASS.
