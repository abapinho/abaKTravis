class ZCX_ABAK definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  data PREVIOUS_FROM_SYST type FLAG .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !PREVIOUS_FROM_SYST type FLAG optional .

  methods IF_MESSAGE~GET_LONGTEXT
    redefinition .
  methods IF_MESSAGE~GET_TEXT
    redefinition .
protected section.
private section.

  methods BUILD_FROM_SYST .
ENDCLASS.



CLASS ZCX_ABAK IMPLEMENTATION.


method BUILD_FROM_SYST.

  DATA: o_exp TYPE REF TO lcx_t100_syst.
  IF me->previous IS NOT BOUND AND me->previous_from_syst = abap_true.
    TRY .
        RAISE EXCEPTION TYPE lcx_t100_syst.
      CATCH lcx_t100_syst INTO o_exp.
        me->previous = o_exp.
    ENDTRY.
  ENDIF.

endmethod.


method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->PREVIOUS_FROM_SYST = PREVIOUS_FROM_SYST .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
endmethod.


method IF_MESSAGE~GET_LONGTEXT.
* The default behaviour returns the long text of this instance.
* We redefine it to recursively find the chained exceptions
* and fetch the long text from the last one

  IF me->previous IS BOUND.
    result = me->previous->get_longtext( preserve_newlines ).
  ELSE.
    result = super->if_message~get_longtext( preserve_newlines ).
  ENDIF.

endmethod.


method IF_MESSAGE~GET_TEXT.
* The default behaviour returns the text of this instance.
* We redefine it to recursively find the chained exceptions
* and fetch the text from the last one

  IF me->previous IS BOUND.
    result = me->previous->get_text( ).
  ELSE.
    result = super->if_message~get_text( ).
  ENDIF.

endmethod.
ENDCLASS.
