*"* use this source file for your ABAP unit test classes
CLASS lcl_unittest DEFINITION DEFERRED.
CLASS zcl_abak_util DEFINITION LOCAL FRIENDS lcl_unittest.

CLASS lcl_unittest DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS: BEGIN OF gc_tablename,
                 valid TYPE tabname VALUE 'ZABAK_UNITTESTS',
                 invalid TYPE tabname VALUE 'USR01',
               END OF gc_tablename.

    DATA:
      f_cut TYPE REF TO zcl_abak_util.  "class under test

    METHODS: check_table_valid FOR TESTING RAISING zcx_abak.
    METHODS: check_table_invalid FOR TESTING.
ENDCLASS.       "lcl_Unittest


CLASS lcl_unittest IMPLEMENTATION.

  METHOD check_table_valid.
    CREATE OBJECT f_cut.

    f_cut->check_table( gc_tablename-valid ).

  ENDMETHOD.

  METHOD check_table_invalid.
    TRY.
        CREATE OBJECT f_cut.

        f_cut->check_table( gc_tablename-invalid ).

        cl_abap_unit_assert=>fail( msg = 'Table is invalid so exception should have happened' ).

      CATCH zcx_abak.
        RETURN.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.       "lcl_Unittest
