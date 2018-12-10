class ZCL_ABAK_SOURCE_XML definition
  public
  final
  create public .

public section.

  interfaces ZIF_ABAK_SOURCE .

  methods CONSTRUCTOR
    importing
      !I_XML type STRING
    raising
      ZCX_ABAK .
  PROTECTED SECTION.
private section.

  data GT_DATA type ZABAK_DATA_T .
  data G_NAME type NAME1 .

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
       RESULT constants = t_constant
              name = g_name.

      gt_data = convert_to_source_format( t_constant ).

    CATCH cx_st_error INTO o_exp.
      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          previous = o_exp.
  ENDTRY.

ENDMETHOD.


METHOD convert_to_source_format.

  DATA: s_itab LIKE LINE OF rt_itab.

  FIELD-SYMBOLS: <s_xml> LIKE LINE OF it_xml,
                 <s_value> LIKE LINE OF <s_xml>-t_value.

  LOOP AT it_xml ASSIGNING <s_xml>.
    s_itab-ricef = <s_xml>-ricef.
    TRANSLATE s_itab-ricef TO UPPER CASE.
    s_itab-fieldname = <s_xml>-fieldname.
    TRANSLATE s_itab-fieldname TO UPPER CASE.
    s_itab-context = <s_xml>-context.
    TRANSLATE s_itab-context TO UPPER CASE.

    s_itab-idx = 0.

    IF <s_xml>-value IS NOT INITIAL.
      ADD 1 TO s_itab-idx.
      s_itab-ue_option = 'EQ'.
      s_itab-ue_sign = 'I'.
      s_itab-ue_low = <s_xml>-value.
      INSERT s_itab INTO TABLE rt_itab.
    ENDIF.

    LOOP AT <s_xml>-t_value ASSIGNING <s_value>.
      ADD 1 TO s_itab-idx.
      MOVE-CORRESPONDING <s_value> TO s_itab.
      TRANSLATE s_itab-ue_sign TO UPPER CASE.
      TRANSLATE s_itab-ue_option TO UPPER CASE.
      INSERT s_itab INTO TABLE rt_itab.
    ENDLOOP.

  ENDLOOP.

ENDMETHOD.


METHOD zif_abak_source~get_data.

  LOG-POINT ID zabak SUBKEY 'source_xml.get_data'.

  rt_data = gt_data.

ENDMETHOD.


METHOD zif_abak_source~get_name.
  r_name = |XML|.
  IF g_name IS NOT INITIAL.
    r_name = |{ r_name }.{ g_name }|.
  ENDIF.
ENDMETHOD.


METHOD ZIF_ABAK_SOURCE~INVALIDATE.
  RETURN. " Nothing to invalidate in this case
ENDMETHOD.
ENDCLASS.
