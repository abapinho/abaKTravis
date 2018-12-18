class ZCL_ABAK_FORMAT_XML definition
  public
  final
  create public .

public section.

  interfaces ZIF_ABAK_FORMAT .
  PROTECTED SECTION.
private section.

  methods CONVERT_XML_K_2_K
    importing
      !IT_XML_K type ZABAK_XML_K_T
    returning
      value(RT_K) type ZABAK_K_T .
  methods LOAD_XML
    importing
      !I_XML type STRING
    exporting
      !ET_XML_K type ZABAK_XML_K_T
      !E_NAME type STRING
    raising
      ZCX_ABAK .
ENDCLASS.



CLASS ZCL_ABAK_FORMAT_XML IMPLEMENTATION.


  METHOD CONVERT_XML_K_2_K.

    DATA: s_k LIKE LINE OF rt_k,
          s_v LIKE LINE OF s_k-t_kv.

    FIELD-SYMBOLS: <s_xml_k> LIKE LINE OF it_xml_k.

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

  ENDMETHOD. "#EC CI_VALPAR


  METHOD load_xml.
    DATA: o_exp       TYPE REF TO cx_st_error.

    TRY.
        CALL TRANSFORMATION zabak_format_xml
         SOURCE XML i_xml
         RESULT constants = et_xml_k
                name = e_name.

      CATCH cx_st_error INTO o_exp.
        RAISE EXCEPTION TYPE zcx_abak
          EXPORTING
            previous = o_exp.
    ENDTRY.

  ENDMETHOD.


METHOD zif_abak_format~convert.
  DATA: t_xml_k TYPE zabak_xml_k_t.

  LOG-POINT ID zabak SUBKEY 'format_xml.convert' FIELDS i_data.

  load_xml( EXPORTING
              i_xml    = i_data
            IMPORTING
              et_xml_k = t_xml_k
              e_name   = e_name ).

  IF et_k IS REQUESTED.
    et_k = convert_xml_k_2_k( t_xml_k ).
  ENDIF.

ENDMETHOD.


METHOD zif_abak_format~get_type.
  r_format_type = zcl_abak_format_factory=>gc_format_type-xml.
ENDMETHOD.
ENDCLASS.
