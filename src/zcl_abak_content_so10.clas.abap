CLASS ZCL_ABAK_CONTENT_SO10 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abak_content .

    METHODS constructor
      IMPORTING
        !i_name TYPE tdobname
        !i_id TYPE tdid DEFAULT 'ST'
        !i_spras TYPE spras DEFAULT sy-langu
      RAISING
        zcx_abak .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA g_name TYPE tdobname .
    DATA g_id TYPE tdid .
    DATA g_spras TYPE spras .
    DATA g_text TYPE string.

    METHODS fetch_standard_text
      RETURNING
        value(r_text) TYPE string
      RAISING
        zcx_abak .
ENDCLASS.



CLASS ZCL_ABAK_CONTENT_SO10 IMPLEMENTATION.


  METHOD constructor.

    g_name = i_name.

    g_id = i_id.
    IF g_id IS INITIAL.
      g_id = 'ST'.
    ENDIF.

    g_spras = i_spras.
    IF g_spras IS INITIAL.
      g_spras = sy-langu. " TODO convert LANGU to SPRAS?
    ENDIF.

    g_text = fetch_standard_text( ).

  ENDMETHOD.


  METHOD fetch_standard_text.

    DATA: t_line   TYPE tline_t.

    FIELD-SYMBOLS: <s_line> LIKE LINE OF t_line.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = g_id
        language                = g_spras
        name                    = g_name
        object                  = 'TEXT'
      TABLES
        lines                   = t_line
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          previous_from_syst = abap_true.
    ENDIF.

    LOOP AT t_line ASSIGNING <s_line>.
      IF sy-tabix = 1.
        r_text = <s_line>.
      ELSE.
        r_text = |{ r_text }\n{ <s_line>-tdline }|.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_abak_content~get.
    r_text = g_text.
  ENDMETHOD.


  METHOD zif_abak_content~get_type.
    r_type = zif_abak_consts=>content_type-standard_text.
  ENDMETHOD.


  METHOD zif_abak_content~invalidate.
    g_text = fetch_standard_text( ).
  ENDMETHOD.
ENDCLASS.
