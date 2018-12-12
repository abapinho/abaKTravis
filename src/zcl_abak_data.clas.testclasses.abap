*"* use this source file for your ABAP unit test classes
CLASS lcl_unittest DEFINITION DEFERRED.
CLASS zcl_abak_data DEFINITION LOCAL FRIENDS lcl_unittest.

CLASS lcl_unittest DEFINITION FOR TESTING
  INHERITING FROM zcl_abak_unit_tests
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA:
      f_cut TYPE REF TO zcl_abak_data,  "class under test
      f_source type ref to zcl_abak_source_db.

    METHODS: setup raising zcx_abak.
    METHODS: read_valid FOR TESTING RAISING zcx_abak.
    METHODS: get_name FOR TESTING RAISING zcx_abak.
    methods: invalidate for testing raising zcx_abak.
ENDCLASS.       "lcl_Unittest


CLASS lcl_unittest IMPLEMENTATION.

  METHOD setup.
    generate_test_data( ).

    create object f_source
      EXPORTING
        i_tablename = gc_tablename-valid.
  ENDMETHOD.

  METHOD read_valid.

    CREATE OBJECT f_cut
      EXPORTING
        io_source = f_source.

    cl_abap_unit_assert=>assert_differs(
      exp = 0
      act = lines( f_cut->zif_abak_data~read( i_ricef     = 'UTEST'
                                              i_fieldname = 'BUKRS'
                                              i_context   = space ) )
      msg = 'Resulting table should not be empty' ).

  ENDMETHOD.

  METHOD get_name.

    CREATE OBJECT f_cut
      EXPORTING
        io_source = f_source.

    cl_abap_unit_assert=>assert_equals(
      exp = f_source->zif_abak_source~get_name( )
      act = f_cut->zif_abak_data~get_name( )
      msg = 'Name different from what was expected' ).

  ENDMETHOD.

  METHOD invalidate.

    CREATE OBJECT f_cut
      EXPORTING
        io_source = f_source.

    f_cut->zif_abak_data~read( i_ricef     = 'UTEST'
                               i_fieldname = 'BUKRS'
                               i_context   = space ).

    cl_abap_unit_assert=>assert_differs(
      exp = 0
      act = lines( f_cut->gt_k )
      msg = 'Resulting table should have more than one line' ).

    f_cut->zif_abak_data~invalidate( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( f_cut->gt_k )
      msg = 'Resulting table should have ZERO lines' ).

  ENDMETHOD.

ENDCLASS.       "lcl_Unittest
