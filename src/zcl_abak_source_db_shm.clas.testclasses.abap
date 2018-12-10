*"* use this source file for your ABAP unit test classes
CLASS lcl_unittest DEFINITION DEFERRED.
CLASS zcl_abak_source_db_shm DEFINITION LOCAL FRIENDS lcl_unittest.

CLASS lcl_unittest DEFINITION FOR TESTING
  INHERITING FROM zcl_abak_unit_tests
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA:
      f_cut TYPE REF TO zcl_abak_source_db_shm.  "class under test

    METHODS: setup.
    METHODS: check_table_valid FOR TESTING RAISING zcx_abak.
    METHODS: check_table_invalid FOR TESTING.
    METHODS: get_data FOR TESTING RAISING zcx_abak.
    METHODS: get_name FOR TESTING RAISING zcx_abak.
    METHODS: invalidate FOR TESTING RAISING zcx_abak.
ENDCLASS.       "lcl_Unittest


CLASS lcl_unittest IMPLEMENTATION.

  METHOD setup.
    generate_test_data( ).
  ENDMETHOD.

  METHOD check_table_valid.
    CREATE OBJECT f_cut
      EXPORTING
        i_tablename = gc_tablename-valid.
  ENDMETHOD.

  METHOD check_table_invalid.
    TRY.
        CREATE OBJECT f_cut
          EXPORTING
            i_tablename = gc_tablename-invalid.

        cl_abap_unit_assert=>fail( msg = 'Table is invalid so exception should have happened' ).

      CATCH zcx_abak.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD get_data.

    CREATE OBJECT f_cut
      EXPORTING
        i_tablename = gc_tablename-valid.

    cl_abap_unit_assert=>assert_differs(
      exp = 0
      act = lines( f_cut->zif_abak_source~get_data( ) )
      msg = 'Resulting table should not have zero lines' ).

  ENDMETHOD.

  METHOD get_name.

    CREATE OBJECT f_cut
      EXPORTING
        i_tablename = gc_tablename-valid.

    cl_abap_unit_assert=>assert_equals(
      exp = |SHM:{ gc_tablename-valid }|
      act = f_cut->zif_abak_source~get_name( )
      msg = 'Name different from what was expected' ).

  ENDMETHOD.

  METHOD invalidate.

    DATA: instance_name TYPE shm_inst_name.

    CREATE OBJECT f_cut
      EXPORTING
        i_tablename = gc_tablename-valid.

    f_cut->zif_abak_source~get_data( ).

    instance_name = gc_tablename-valid.

    zcl_abak_shm_area=>attach_for_read( instance_name ).

*  If we got here there is currently a shared memory instance as it should
*  Now let's invalidate it and check again

    f_cut->zif_abak_source~invalidate( ).

    TRY.
        zcl_abak_shm_area=>attach_for_read( instance_name ).
        cl_abap_unit_assert=>fail( msg = 'If we got here the instance was not invalidated' ).

      CATCH cx_root.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.       "lcl_Unittest
