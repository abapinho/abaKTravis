*"* use this source file for your ABAP unit test classes
CLASS lcl_unittest DEFINITION DEFERRED.
CLASS zcl_abak_source_db DEFINITION LOCAL FRIENDS lcl_unittest.

CLASS lcl_unittest DEFINITION FOR TESTING
  INHERITING FROM zcl_abak_unit_tests
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA:
      f_cut TYPE REF TO zcl_abak_source_db,
      o_location_valid TYPE REF TO zcl_abak_origin_inline,
      o_location_invalid TYPE REF TO zcl_abak_origin_inline.

    METHODS: setup RAISING zcx_abak.
    METHODS: check_table_valid FOR TESTING RAISING zcx_abak.
    METHODS: check_table_invalid FOR TESTING.
    METHODS: get_data FOR TESTING RAISING zcx_abak.
    METHODS: get_name FOR TESTING RAISING zcx_abak.
ENDCLASS.       "lcl_Unittest


CLASS lcl_unittest IMPLEMENTATION.

  METHOD setup.
    CREATE OBJECT o_location_valid
      EXPORTING
        i_text = gc_tablename-valid.

    CREATE OBJECT o_location_invalid
      EXPORTING
        i_text = gc_tablename-invalid.

    generate_test_data( ).
  ENDMETHOD.

  METHOD check_table_valid.
    CREATE OBJECT f_cut
      EXPORTING
        io_origin = o_location_valid.
  ENDMETHOD.

  METHOD check_table_invalid.
    TRY.
        CREATE OBJECT f_cut
          EXPORTING
            io_origin = o_location_invalid.

        cl_abap_unit_assert=>fail( msg = 'Table is invalid so exception should have happened' ).

      CATCH zcx_abak.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD get_data.

    CREATE OBJECT f_cut
      EXPORTING
        io_origin = o_location_valid.

    cl_abap_unit_assert=>assert_differs(
      exp = 0
      act = lines( f_cut->zif_abak_source~get_data( ) )
      msg = 'Resulting table should not have zero lines' ).

  ENDMETHOD.

  METHOD get_name.

    CREATE OBJECT f_cut
      EXPORTING
        io_origin = o_location_valid.

    cl_abap_unit_assert=>assert_equals(
      exp = |DB.{ gc_tablename-valid }|
      act = f_cut->zif_abak_source~get_name( )
      msg = 'Name different from what was expected' ).

  ENDMETHOD.

ENDCLASS.       "lcl_Unittest
