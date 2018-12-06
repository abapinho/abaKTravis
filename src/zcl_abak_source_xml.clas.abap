CLASS zcl_abak_source_xml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

PUBLIC SECTION.

  interfaces ZIF_ABAK_SOURCE .

  methods CONSTRUCTOR
    importing
      !I_xml type string
    raising
      ZCX_ABAK .

  PROTECTED SECTION.
private section.

  data GT_DATA type ZABAK_DATA_T .

  methods CONVERT_TO_SOURCE_FORMAT
    importing
      !IT_XML type ZABAK_XML_CONSTANT_T
    returning
      value(RT_ITAB) type ZABAK_DATA_T .
ENDCLASS.



CLASS ZCL_ABAK_SOURCE_XML IMPLEMENTATION.


METHOD constructor.

  DATA: t_constant  TYPE zabak_xml_constant_t,
        o_exp       TYPE REF TO cx_st_error.

  TRY.
      CALL TRANSFORMATION zabak_source_xml
       SOURCE XML i_xml
       RESULT constants = t_constant.

       gt_data = convert_to_source_format( t_constant ).

    CATCH cx_st_error INTO o_exp.
      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          previous = o_exp.
  ENDTRY.

ENDMETHOD.


METHOD CONVERT_TO_SOURCE_FORMAT.

  DATA: s_itab LIKE LINE OF rt_itab.

  FIELD-SYMBOLS: <s_xml> LIKE LINE OF it_xml,
                 <s_value> like line of <s_xml>-t_value.

  LOOP AT it_xml ASSIGNING <s_xml>.
    s_itab-ricef = <s_xml>-ricef.
    s_itab-fieldname = <s_xml>-fieldname.
    s_itab-context = <s_xml>-context.
    s_itab-idx = 0.
    LOOP AT <s_xml>-t_value ASSIGNING <s_value>.
      ADD 1 TO s_itab.
      MOVE-CORRESPONDING <s_value> TO s_itab.
      INSERT s_itab INTO TABLE rt_itab.
    ENDLOOP.
  ENDLOOP.

ENDMETHOD.


METHOD zif_abak_source~get_data.

  LOG-POINT ID zabak SUBKEY 'source_xml.get_data'.

ENDMETHOD.


method ZIF_ABAK_SOURCE~GET_NAME.
  r_name = |XML|.
endmethod.


METHOD ZIF_ABAK_SOURCE~INVALIDATE.
  RETURN. " Nothing to invalidate in this case
ENDMETHOD.
ENDCLASS.
