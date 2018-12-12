*"* use this source file for your ABAP unit test classes
CLASS lcl_unittest DEFINITION DEFERRED.
CLASS zcl_abak_source_shm DEFINITION LOCAL FRIENDS lcl_unittest.

CLASS lcl_unittest DEFINITION FOR TESTING
  INHERITING FROM zcl_abak_unit_tests
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA:
      f_cut TYPE REF TO zcl_abak_source_shm,
      o_location TYPE REF TO zif_abak_location.

    METHODS: setup.
    METHODS: invalid_source FOR TESTING.
    METHODS: get_data FOR TESTING RAISING zcx_abak.
    METHODS: get_name FOR TESTING RAISING zcx_abak.
    METHODS: invalidate FOR TESTING RAISING cx_static_check.
ENDCLASS.       "lcl_Unittest


CLASS lcl_unittest IMPLEMENTATION.

  METHOD setup.
    generate_test_data( ).
  ENDMETHOD.

  METHOD invalid_source.
    DATA: param TYPE string.

    TRY.
        CREATE OBJECT f_cut
          EXPORTING
            i_source_type   = zcl_abak_source_factory=>gc_source_type-database
            i_location_type = zcl_abak_location_factory=>gc_location_type-inline
            i_param         = gc_tablename-invalid.

        cl_abap_unit_assert=>fail( msg = 'Table is invalid. An exception should have been raised' ).

      CATCH zcx_abak.
        RETURN.
    ENDTRY.

  ENDMETHOD.

  METHOD get_data.

    CREATE OBJECT f_cut
      EXPORTING
        i_source_type   = zcl_abak_source_factory=>gc_source_type-database
        i_location_type = zcl_abak_location_factory=>gc_location_type-inline
        i_param         = gc_tablename-valid.

    cl_abap_unit_assert=>assert_differs(
      exp = 0
      act = lines( f_cut->zif_abak_source~get_data( ) )
      msg = 'Resulting table should not have zero lines' ).

  ENDMETHOD.

  METHOD get_name.

    CREATE OBJECT f_cut
      EXPORTING
        i_source_type   = zcl_abak_source_factory=>gc_source_type-database
        i_location_type = zcl_abak_location_factory=>gc_location_type-inline
        i_param         = gc_tablename-valid.

    cl_abap_unit_assert=>assert_equals(
      exp = |SHM.DB.INLINE.{ gc_tablename-valid }|
      act = f_cut->zif_abak_source~get_name( )
      msg = 'Name different from what was expected' ).

  ENDMETHOD.

  METHOD invalidate.

    CREATE OBJECT f_cut
      EXPORTING
        i_source_type   = zcl_abak_source_factory=>gc_source_type-database
        i_location_type = zcl_abak_location_factory=>gc_location_type-inline
        i_param         = gc_tablename-valid.

    f_cut->zif_abak_source~get_data( ).

    zcl_abak_shm_area=>attach_for_read( f_cut->get_instance_name( ) ).

*  If we got here there is currently a shared memory instance as it should
*  Now let's invalidate it and check again

    f_cut->zif_abak_source~invalidate( ).

    TRY.
        zcl_abak_shm_area=>attach_for_read( f_cut->get_instance_name( ) ).
        cl_abap_unit_assert=>fail( msg = 'If we got here the instance was not invalidated' ).

      CATCH cx_root.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.       "lcl_Unittest
