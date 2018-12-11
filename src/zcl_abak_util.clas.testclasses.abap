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

ENDCLASS.       "lcl_Unittest


CLASS lcl_unittest IMPLEMENTATION.

ENDCLASS.       "lcl_Unittest
