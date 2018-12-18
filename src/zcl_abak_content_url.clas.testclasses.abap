*"* use this source file for your ABAP unit test classes
CLASS lcl_unittest DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA:
      f_cut TYPE REF TO ZCL_ABAK_CONTENT_URL.

    METHODS: valid FOR TESTING RAISING zcx_abak.
    METHODS: invalid_url FOR TESTING.
    METHODS: valid_url_not_found FOR TESTING.
ENDCLASS.       "lcl_Unittest


CLASS lcl_unittest IMPLEMENTATION.

  METHOD valid.

    DATA: str TYPE char1024.

    CREATE OBJECT f_cut
      EXPORTING
        i_url = 'https://github.com/abapinho/abaK/blob/master/plantuml.txt'.

    str = f_cut->zif_abak_content~get( ).

    cl_abap_unit_assert=>assert_differs( exp = '@startuml'
                                         act = str(9) ).

  ENDMETHOD.

  METHOD invalid_url.

    TRY.
        CREATE OBJECT f_cut
          EXPORTING
            i_url = 'this is not an url'.

        cl_abap_unit_assert=>fail( msg = 'Invalid URL not detected' ).

      CATCH zcx_abak.
        RETURN.
    ENDTRY.

  ENDMETHOD.

  METHOD valid_url_not_found.

    TRY.
        CREATE OBJECT f_cut
          EXPORTING
            i_url = 'https://github.com/abapinho/abaK/blob/master/plantuml_this_does_not_exist.txt'.

        f_cut->zif_abak_content~get( ).

        cl_abap_unit_assert=>fail( msg = '401 file not found not detected' ).

      CATCH zcx_abak.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.       "lcl_Unittest
