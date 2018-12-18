class ZCL_ABAK_CONTENT_FILE definition
  public
  final
  create public .

public section.

  interfaces zif_abak_content .

  methods CONSTRUCTOR
    importing
      !I_FILEPATH type STRING
    raising
      ZCX_ABAK .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA g_text TYPE string .
    data g_filepath type string.

    methods load_from_server
      IMPORTING
        !i_filepath type string
      returning
        VALUE(r_text) type string
      RAISING
        zcx_abak.

ENDCLASS.



CLASS ZCL_ABAK_CONTENT_FILE IMPLEMENTATION.


  METHOD constructor.
    g_filepath = i_filepath.
    g_text = load_from_server( i_filepath ).
  ENDMETHOD.


  method load_from_server.
    open dataset i_filepath for input in text mode ENCODING default.
    if sy-subrc <> 0.
      raise EXCEPTION type zcx_abak. " TODO
    endif.

    read dataset i_filepath into r_text.

    close dataset i_filepath.
  ENDMETHOD.


  METHOD zif_abak_content~get.
    r_text = g_text.
  ENDMETHOD.


  METHOD zif_abak_content~invalidate.
    g_text = load_from_server( g_filepath ).
  ENDMETHOD.

  METHOD zif_abak_content~get_type.
    r_type = zif_abak_consts=>content_type-file.
  ENDMETHOD.
ENDCLASS.
