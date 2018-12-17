*"* use this source file for your ABAP unit test classes
CLASS lcl_unittest DEFINITION DEFERRED.
CLASS ZCL_ABAK_FORMAT_XML DEFINITION LOCAL FRIENDS lcl_unittest.

CLASS lcl_unittest DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA:
      f_cut TYPE REF TO ZCL_ABAK_FORMAT_XML,
      o_location type ref to zcl_abak_origin_inline,
      t_k TYPE zabak_k_t.

    METHODS: get_inline_value FOR TESTING RAISING zcx_abak.
    METHODS: get_value FOR TESTING RAISING zcx_abak.
    METHODS: get_name FOR TESTING RAISING zcx_abak.
    METHODS: get_range_line FOR TESTING RAISING zcx_abak.
ENDCLASS.       "lcl_Unittest


CLASS lcl_unittest IMPLEMENTATION.

  METHOD get_inline_value.

    FIELD-SYMBOLS: <s_k> LIKE LINE OF t_k,
                   <s_kv> LIKE LINE OF <s_k>-t_kv.

    create object o_location
      EXPORTING
        i_text = |<abak name="test1"><k ricef="a" fieldname="bukrs" value="4321"/></abak>|.
    CREATE OBJECT f_cut
      EXPORTING
        io_origin = o_location.

    t_k = f_cut->zif_abak_format~get_data( ).
    READ TABLE t_k ASSIGNING <s_k> INDEX 1. "#EC CI_SUBRC
    READ TABLE <s_k>-t_kv ASSIGNING <s_kv> INDEX 1. "#EC CI_SUBRC

    cl_abap_unit_assert=>assert_equals( exp = '4321'
                                        act = <s_kv>-low ).

  ENDMETHOD.

  METHOD get_value.

    FIELD-SYMBOLS: <s_k> LIKE LINE OF t_k,
                   <s_kv> LIKE LINE OF <s_k>-t_kv.

    create object o_location
      EXPORTING
        i_text = |<abak name="test1"><k ricef="a" fieldname="bukrs"><v low="1234"/></k></abak>|.
    CREATE OBJECT f_cut
      EXPORTING
        io_origin = o_location.

    t_k = f_cut->zif_abak_format~get_data( ).
    READ TABLE t_k ASSIGNING <s_k> INDEX 1. "#EC CI_SUBRC
    READ TABLE <s_k>-t_kv ASSIGNING <s_kv> INDEX 1. "#EC CI_SUBRC

    cl_abap_unit_assert=>assert_equals( exp = '1234'
                                        act = <s_kv>-low ).

  ENDMETHOD.

  METHOD get_name.

    create object o_location
      EXPORTING
        i_text = |<abak name="test1"><k ricef="a" fieldname="bukrs"><v low="1234"/></k></abak>|.
    CREATE OBJECT f_cut
      EXPORTING
        io_origin = o_location.

    cl_abap_unit_assert=>assert_equals(
      exp = |XML.test1|
      act = f_cut->zif_abak_format~get_name( ) ).

  ENDMETHOD.

  METHOD get_range_line.

    FIELD-SYMBOLS: <s_k> LIKE LINE OF t_k,
                   <s_kv> LIKE LINE OF <s_k>-t_kv.

    create object o_location
      EXPORTING
        i_text = |<abak name="test1"><k ricef="a" fieldname="bukrs"><v sign="I" option="BT" low="1234" high="9999"/></k></abak>|.
    CREATE OBJECT f_cut
      EXPORTING
        io_origin = o_location.

    t_k = f_cut->zif_abak_format~get_data( ).
    READ TABLE t_k ASSIGNING <s_k> INDEX 1. "#EC CI_SUBRC
    READ TABLE <s_k>-t_kv ASSIGNING <s_kv> INDEX 1. "#EC CI_SUBRC

    cl_abap_unit_assert=>assert_equals( exp = '1234'
                                        act = <s_kv>-low ).
    cl_abap_unit_assert=>assert_equals( exp = '9999'
                                        act = <s_kv>-high ).
    cl_abap_unit_assert=>assert_equals( exp = 'I'
                                        act = <s_kv>-sign ).
    cl_abap_unit_assert=>assert_equals( exp = 'BT'
                                        act = <s_kv>-option ).

  ENDMETHOD.

ENDCLASS.       "lcl_Unittest
