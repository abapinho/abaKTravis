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

  data GT_K type ZABAK_K_T .
  data G_NAME type NAME1 .

  methods DEEP_TABLE_2_SOURCE_FORMAT
    importing
      !IT_XML_K type ZABAK_XML_K_T
    returning
      value(RT_K) type ZABAK_K_T .
  methods LOAD_XML
    importing
      !I_XML type STRING
    raising
      ZCX_ABAK .
ENDCLASS.



CLASS ZCL_ABAK_SOURCE_XML IMPLEMENTATION.


METHOD constructor.

  load_xml( i_xml ).

ENDMETHOD.


METHOD deep_table_2_source_format.

  DATA: s_k LIKE LINE OF rt_k,
        s_v LIKE LINE OF s_k-t_kv.

  FIELD-SYMBOLS: <s_xml_k> LIKE LINE OF it_xml_k,
                 <s_v> LIKE LINE OF <s_xml_k>-t_kv.

  LOOP AT it_xml_k ASSIGNING <s_xml_k>.

    MOVE-CORRESPONDING <s_xml_k> TO s_k.

    IF <s_xml_k>-value IS NOT INITIAL.
      CLEAR s_v.
      s_v-sign = 'I'.
      s_v-option = 'EQ'.
      s_v-low = <s_xml_k>-value.
      INSERT s_v INTO TABLE s_k-t_kv.
    ENDIF.

    INSERT LINES OF <s_xml_k>-t_kv INTO TABLE s_k-t_kv.

    INSERT s_k INTO TABLE rt_k.

  ENDLOOP.

ENDMETHOD.


METHOD load_xml.

  DATA: t_xml_k  TYPE zabak_xml_k_t,
        o_exp       TYPE REF TO cx_st_error.

  TRY.
      CALL TRANSFORMATION zabak_source_xml
       SOURCE XML i_xml
       RESULT constants = t_xml_k
              name = g_name.

      gt_k = deep_table_2_source_format( t_xml_k ).

    CATCH cx_st_error INTO o_exp.
      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          previous = o_exp.
  ENDTRY.

ENDMETHOD.


METHOD zif_abak_source~get_data.

  LOG-POINT ID zabak SUBKEY 'source_xml.get_data'.

  rt_k = gt_k.

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
