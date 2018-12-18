*"* use this source file for your ABAP unit test classes
CLASS lcl_unittest DEFINITION FOR TESTING
  INHERITING FROM zcl_abak_unit_tests
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA:
      f_cut TYPE REF TO ZCL_ABAK_CONTENT_INLINE.

    METHODS: setup RAISING zcx_abak.
    METHODS: read FOR TESTING RAISING zcx_abak.

ENDCLASS.       "lcl_Unittest


CLASS lcl_unittest IMPLEMENTATION.

  METHOD setup.
    CREATE OBJECT f_cut
      EXPORTING
        i_text = 'Something'.
  ENDMETHOD.

  METHOD read.
    cl_abap_unit_assert=>assert_equals( exp = 'Something'
                                        act = f_cut->zif_abak_content~get( ) ).
  ENDMETHOD.

ENDCLASS.
