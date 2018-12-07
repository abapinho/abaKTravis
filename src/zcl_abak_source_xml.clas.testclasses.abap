*"* use this source file for your ABAP unit test classes
CLASS lcl_unittest DEFINITION DEFERRED.
CLASS zcl_abak_source_xml DEFINITION LOCAL FRIENDS lcl_unittest.

CLASS lcl_unittest DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA:
      f_cut TYPE REF TO zcl_abak_source_xml,
      t_data TYPE zabak_data_t.

    METHODS: get_inline_value FOR TESTING RAISING zcx_abak.
    METHODS: get_value FOR TESTING RAISING zcx_abak.
    METHODS: get_name FOR TESTING RAISING zcx_abak.
    methods: get_range_line for TESTING raising zcx_abak.
ENDCLASS.       "lcl_Unittest


CLASS lcl_unittest IMPLEMENTATION.

  METHOD get_inline_value.

    FIELD-SYMBOLS: <s_data> LIKE LINE OF t_data.

    CREATE OBJECT f_cut
      EXPORTING
        i_xml = |<abak name="test1"><k ricef="a" fieldname="bukrs" value="4321"/></abak>|.

    t_data = f_cut->zif_abak_source~get_data( ).
    READ TABLE t_data ASSIGNING <s_data> INDEX 1.

    cl_abap_unit_assert=>assert_equals( exp = '4321'
                                        act = <s_data>-ue_low ).

  ENDMETHOD.

  METHOD get_value.

    FIELD-SYMBOLS: <s_data> LIKE LINE OF t_data.

    CREATE OBJECT f_cut
      EXPORTING
        i_xml = |<abak name="test1"><k ricef="a" fieldname="bukrs"><v low="1234"/></k></abak>|.

    t_data = f_cut->zif_abak_source~get_data( ).
    READ TABLE t_data ASSIGNING <s_data> INDEX 1.

    cl_abap_unit_assert=>assert_equals( exp = '1234'
                                        act = <s_data>-ue_low ).

  ENDMETHOD.

  METHOD get_name.

    CREATE OBJECT f_cut
      EXPORTING
        i_xml = |<abak name="test1"><k ricef="a" fieldname="bukrs"><v low="1234"/></k></abak>|.

    cl_abap_unit_assert=>assert_equals(
      exp = |XML:test1|
      act = f_cut->zif_abak_source~get_name( ) ).

  ENDMETHOD.

  METHOD get_range_line.

    FIELD-SYMBOLS: <s_data> LIKE LINE OF t_data.

    CREATE OBJECT f_cut
      EXPORTING
        i_xml = |<abak name="test1"><k ricef="a" fieldname="bukrs"><v sign="I" option="BT" low="1234" high="9999"/></k></abak>|.

    t_data = f_cut->zif_abak_source~get_data( ).
    READ TABLE t_data ASSIGNING <s_data> INDEX 1.

    cl_abap_unit_assert=>assert_equals( exp = '1234'
                                        act = <s_data>-ue_low ).
    cl_abap_unit_assert=>assert_equals( exp = '9999'
                                        act = <s_data>-ue_high ).
    cl_abap_unit_assert=>assert_equals( exp = 'I'
                                        act = <s_data>-ue_sign ).
    cl_abap_unit_assert=>assert_equals( exp = 'BT'
                                        act = <s_data>-ue_option ).

  ENDMETHOD.

ENDCLASS.       "lcl_Unittest
