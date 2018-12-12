CLASS zcl_abak_source_xml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abak_source .

    METHODS constructor
      IMPORTING
        !io_location TYPE ref to zif_abak_location
      RAISING
        zcx_abak .
  PROTECTED SECTION.
  PRIVATE SECTION.

    data go_location type ref to zif_abak_location.
    DATA gt_k TYPE zabak_k_t .
    DATA g_name TYPE name1 .

    METHODS deep_table_2_source_format
      IMPORTING
        !it_xml_k TYPE zabak_xml_k_t
      RETURNING
        value(rt_k) TYPE zabak_k_t .
    METHODS load_xml
      IMPORTING
        !i_xml TYPE string
      RAISING
        zcx_abak .
ENDCLASS.



CLASS ZCL_ABAK_SOURCE_XML IMPLEMENTATION.


  METHOD constructor.
    if io_location is not bound.
      raise EXCEPTION type zcx_abak
        EXPORTING
          textid = zcx_abak=>invalid_parameters.
    endif.

    go_location = io_location.
    load_xml( io_location->get( ) ).
  ENDMETHOD.


  METHOD deep_table_2_source_format.

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


  METHOD zif_abak_source~invalidate.
    go_location->invalidate( ).
    load_xml( go_location->get( ) ).
  ENDMETHOD.
ENDCLASS.
