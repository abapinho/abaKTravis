CLASS ZCL_ABAK_LOCATION_SERVER DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abak_location .

    METHODS constructor
      IMPORTING
        !i_filepath TYPE string
      RAISING
        zcx_abak .
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



CLASS ZCL_ABAK_LOCATION_SERVER IMPLEMENTATION.


  METHOD constructor.
    g_filepath = i_filepath.
    g_text = load_from_server( i_filepath ).
  ENDMETHOD.


  METHOD zif_abak_location~get.
    r_text = g_text.
  ENDMETHOD.


  METHOD zif_abak_location~invalidate.
    g_text = load_from_server( g_filepath ).
  ENDMETHOD.

  method load_from_server.
    open dataset i_filepath for input in text mode ENCODING default.
    if sy-subrc <> 0.
      raise EXCEPTION type zcx_abak. " TODO
    endif.

    read dataset i_filepath into g_text.

    close dataset i_filepath.
  ENDMETHOD.


ENDCLASS.
