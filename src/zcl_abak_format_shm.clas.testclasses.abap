*"* use this source file for your ABAP unit test classes
CLASS lcl_unittest DEFINITION DEFERRED.
CLASS ZCL_ABAK_FORMAT_SHM DEFINITION LOCAL FRIENDS lcl_unittest.

CLASS lcl_unittest DEFINITION FOR TESTING
  INHERITING FROM zcl_abak_unit_tests
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA:
      f_cut TYPE REF TO ZCL_ABAK_FORMAT_SHM.

    METHODS: setup.
    METHODS: invalid_format FOR TESTING.
    METHODS: get_data FOR TESTING RAISING zcx_abak.
    METHODS: get_name FOR TESTING RAISING zcx_abak.
    METHODS: invalidate FOR TESTING RAISING cx_static_check.
ENDCLASS.       "lcl_Unittest


CLASS lcl_unittest IMPLEMENTATION.

  METHOD setup.
    generate_test_data( ).
  ENDMETHOD.

  METHOD invalid_format.

    TRY.
        CREATE OBJECT f_cut
          EXPORTING
            i_format_type   = zcl_abak_format_factory=>gc_format_type-database
            i_origin_type = zcl_abak_origin_factory=>gc_origin_type-inline
            i_param         = gc_tablename-invalid.

        cl_abap_unit_assert=>fail( msg = 'Table is invalid. An exception should have been raised' ).

      CATCH zcx_abak.
        RETURN.
    ENDTRY.

  ENDMETHOD.

  METHOD get_data.

    CREATE OBJECT f_cut
      EXPORTING
        i_format_type   = zcl_abak_format_factory=>gc_format_type-database
        i_origin_type = zcl_abak_origin_factory=>gc_origin_type-inline
        i_param         = gc_tablename-valid.

    cl_abap_unit_assert=>assert_differs(
      exp = 0
      act = lines( f_cut->zif_abak_format~get_data( ) )
      msg = 'Resulting table should not have zero lines' ).

  ENDMETHOD.

  METHOD get_name.

    CREATE OBJECT f_cut
      EXPORTING
        i_format_type   = zcl_abak_format_factory=>gc_format_type-database
        i_origin_type = zcl_abak_origin_factory=>gc_origin_type-inline
        i_param         = gc_tablename-valid.

    cl_abap_unit_assert=>assert_equals(
      exp = |SHM.DB.INLINE.{ gc_tablename-valid }|
      act = f_cut->zif_abak_format~get_name( )
      msg = 'Name different from what was expected' ).

  ENDMETHOD.

  METHOD invalidate.

    CREATE OBJECT f_cut
      EXPORTING
        i_format_type   = zcl_abak_format_factory=>gc_format_type-database
        i_origin_type = zcl_abak_origin_factory=>gc_origin_type-inline
        i_param         = gc_tablename-valid.

    f_cut->zif_abak_format~get_data( ).

    zcl_abak_shm_area=>attach_for_read( f_cut->get_instance_name( ) ).

*  If we got here there is currently a shared memory instance as it should
*  Now let's invalidate it and check again

    f_cut->zif_abak_format~invalidate( ).

    TRY.
        zcl_abak_shm_area=>attach_for_read( f_cut->get_instance_name( ) ).
        cl_abap_unit_assert=>fail( msg = 'If we got here the instance was not invalidated' ).

      CATCH cx_shm_error cx_shm_general_error.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.       "lcl_Unittest
