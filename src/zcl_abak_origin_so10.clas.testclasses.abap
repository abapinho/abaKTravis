*"* use this source file for your ABAP unit test classes
CLASS lcl_unittest DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS gc_name TYPE tdobname VALUE 'ABAK_UTEST_XML'.
    DATA:
      f_cut TYPE REF TO zcl_abak_origin_so10.

    METHODS: setup RAISING zcx_abak.
    METHODS: invalid_text.
    METHODS: read_xml FOR TESTING RAISING zcx_abak.
ENDCLASS.       "lcl_Unittest


CLASS lcl_unittest IMPLEMENTATION.

  METHOD setup.
    DATA: s_header TYPE thead,
          t_line   TYPE tline_t,
          s_line   LIKE LINE OF t_line.

    s_header-tdobject = 'TEXT'.
    s_header-tdid = 'ST'.
    s_header-tdname = gc_name.
    s_header-tdspras = 'EN'.
    s_header-tdtitle = 'ABAK unit tests XML (title is ignored)'.

    s_line-tdline = |<abak name="ABAK SO10 XML Unit tests">|.
    INSERT s_line INTO TABLE t_line.
    s_line-tdline = |<k ricef="GLOBAL" fieldname="BUKRS" value="1234"/>|.
    INSERT s_line INTO TABLE t_line.
    s_line-tdline = |</abak>|.
    INSERT s_line INTO TABLE t_line.

    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        header   = s_header
      TABLES
        lines    = t_line
      EXCEPTIONS
        id       = 1
        language = 2
        name     = 3
        object   = 4
        OTHERS   = 5.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_abak.
    ENDIF.

  ENDMETHOD.

  METHOD invalid_text.

    TRY.
        CREATE OBJECT f_cut
          EXPORTING
            i_name = 'INVALID'.

        cl_abap_unit_assert=>fail( msg = 'Invalid text should have raised exception' ).

      CATCH zcx_abak.
        RETURN.
    ENDTRY.

  ENDMETHOD.

  METHOD read_xml.
    DATA: d TYPE string.

    CREATE OBJECT f_cut
      EXPORTING
        i_name = gc_name.

    d = f_cut->zif_abak_origin~get( ).
    SHIFT d LEFT DELETING LEADING space.

    cl_abap_unit_assert=>assert_equals( exp = |<abak name="ABAK SO10 XML Unit tests">\n<k ricef="GLOBAL" fieldname="BUKRS" value="1234"/>\n</abak>|
                                        act = d ).

  ENDMETHOD.

ENDCLASS.       "lcl_Unittest
