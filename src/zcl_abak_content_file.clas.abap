CLASS zcl_abak_content_file DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abak_content .

    METHODS constructor
      IMPORTING
        !i_filepath TYPE string
      RAISING
        zcx_abak .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA g_text TYPE string .
    DATA g_filepath TYPE string.

    METHODS load_from_server
      IMPORTING
        !i_filepath TYPE string
      RETURNING
        value(r_text) TYPE string
      RAISING
        zcx_abak.

ENDCLASS.



CLASS ZCL_ABAK_CONTENT_FILE IMPLEMENTATION.


  METHOD constructor.
    g_filepath = i_filepath.
    g_text = load_from_server( i_filepath ).
  ENDMETHOD.


  METHOD load_from_server.
    DATA: o_exp TYPE REF TO cx_root.

    TRY.
        OPEN DATASET i_filepath FOR INPUT IN TEXT MODE ENCODING DEFAULT.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_abak_content_file
            EXPORTING
              textid   = zcx_abak_content_file=>error_opening_file
              filepath = i_filepath.
        ENDIF.

        READ DATASET i_filepath INTO r_text.

        CLOSE DATASET i_filepath.

      CATCH cx_sy_file_open
            cx_sy_codepage_converter_init
            cx_sy_conversion_codepage
            cx_sy_file_authority
            cx_sy_pipes_not_supported
            cx_sy_too_many_files INTO o_exp.
        RAISE EXCEPTION TYPE zcx_abak
          EXPORTING
            previous = o_exp.
    ENDTRY.
  ENDMETHOD.


  METHOD zif_abak_content~get.
    r_text = g_text.
  ENDMETHOD.


  METHOD zif_abak_content~get_type.
    r_type = zif_abak_consts=>content_type-file.
  ENDMETHOD.


  METHOD zif_abak_content~invalidate.
    g_text = load_from_server( g_filepath ).
  ENDMETHOD.
ENDCLASS.
