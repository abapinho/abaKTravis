*"* use this source file for your ABAP unit test classes
CLASS lcl_unittest DEFINITION DEFERRED.
CLASS zcl_abak_source_xml_url DEFINITION LOCAL FRIENDS lcl_unittest.

CLASS lcl_unittest DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA:
      f_cut TYPE REF TO zcl_abak_source_xml_url,
      t_data TYPE zabak_data_t.

    CONSTANTS: g_url TYPE string VALUE 'https://gist.githubusercontent.com/nununo/84d2f55c4a3f57baa08d80c54406ae06/raw/a1d926e0771ce431f02e2bb6bf7ef1ef1ac9a9ed/abak_sample.xml'.


    METHODS: get_value FOR TESTING RAISING zcx_abak.
    METHODS: get_name FOR TESTING RAISING zcx_abak.
ENDCLASS.       "lcl_Unittest


CLASS lcl_unittest IMPLEMENTATION.

  METHOD get_value.

    FIELD-SYMBOLS: <s_data> LIKE LINE OF t_data.

    CREATE OBJECT f_cut
      EXPORTING
        i_url = g_url.

    t_data = f_cut->zif_abak_source~get_data( ).
    READ TABLE t_data ASSIGNING <s_data> INDEX 1.

    cl_abap_unit_assert=>assert_equals( exp = '1111'
                                        act = <s_data>-ue_low ).

  ENDMETHOD.

  METHOD get_name.

    CREATE OBJECT f_cut
      EXPORTING
        i_url = g_url.

    cl_abap_unit_assert=>assert_equals(
      exp = |URLXML:simple values|
      act = f_cut->zif_abak_source~get_name( ) ).

  ENDMETHOD.

ENDCLASS.       "lcl_Unittest
