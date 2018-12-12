*"* use this source file for your ABAP unit test classes
CLASS lcl_unittest DEFINITION DEFERRED.
CLASS zcl_abak_source_xml DEFINITION LOCAL FRIENDS lcl_unittest.

CLASS lcl_unittest DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA:
      f_cut TYPE REF TO zcl_abak_source_xml,
      o_location type ref to zcl_abak_location_inline,
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
        io_location = o_location.

    t_k = f_cut->zif_abak_source~get_data( ).
    READ TABLE t_k ASSIGNING <s_k> INDEX 1.
    READ TABLE <s_k>-t_kv ASSIGNING <s_kv> INDEX 1.

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
        io_location = o_location.

    t_k = f_cut->zif_abak_source~get_data( ).
    READ TABLE t_k ASSIGNING <s_k> INDEX 1.
    READ TABLE <s_k>-t_kv ASSIGNING <s_kv> INDEX 1.

    cl_abap_unit_assert=>assert_equals( exp = '1234'
                                        act = <s_kv>-low ).

  ENDMETHOD.

  METHOD get_name.

    create object o_location
      EXPORTING
        i_text = |<abak name="test1"><k ricef="a" fieldname="bukrs"><v low="1234"/></k></abak>|.
    CREATE OBJECT f_cut
      EXPORTING
        io_location = o_location.

    cl_abap_unit_assert=>assert_equals(
      exp = |XML.test1|
      act = f_cut->zif_abak_source~get_name( ) ).

  ENDMETHOD.

  METHOD get_range_line.

    FIELD-SYMBOLS: <s_k> LIKE LINE OF t_k,
                   <s_kv> LIKE LINE OF <s_k>-t_kv.

    create object o_location
      EXPORTING
        i_text = |<abak name="test1"><k ricef="a" fieldname="bukrs"><v sign="I" option="BT" low="1234" high="9999"/></k></abak>|.
    CREATE OBJECT f_cut
      EXPORTING
        io_location = o_location.

    t_k = f_cut->zif_abak_source~get_data( ).
    READ TABLE t_k ASSIGNING <s_k> INDEX 1.
    READ TABLE <s_k>-t_kv ASSIGNING <s_kv> INDEX 1.

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
