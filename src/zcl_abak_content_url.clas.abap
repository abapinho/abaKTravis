CLASS zcl_abak_content_url DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abak_content .

    METHODS constructor
      IMPORTING
        !i_url TYPE string
        !i_proxy_host TYPE string OPTIONAL
        !i_proxy_service TYPE string OPTIONAL
      RAISING
        zcx_abak .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA g_text TYPE string .
    DATA g_url TYPE string .
    DATA g_proxy_host TYPE string.
    DATA g_proxy_service TYPE string.

    METHODS fetch_from_url
      RETURNING
        value(r_content) TYPE string
      RAISING
        zcx_abak .
ENDCLASS.



CLASS zcl_abak_content_url IMPLEMENTATION.


  METHOD constructor.

    g_url = i_url.
    g_proxy_host = i_proxy_host.
    g_proxy_service = i_proxy_service.
    g_text = fetch_from_url( ).

  ENDMETHOD.


  METHOD fetch_from_url.

    DATA: o_http_client TYPE REF TO if_http_client.

    cl_http_client=>create_by_url(
      EXPORTING
        url                = g_url
        proxy_host         = g_proxy_host
        proxy_service      = g_proxy_service
      IMPORTING
        client             = o_http_client
      EXCEPTIONS
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        OTHERS             = 4 ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          previous_from_syst = abap_true.
    ENDIF.

    o_http_client->send(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        http_invalid_timeout       = 4
        OTHERS                     = 5 ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          previous_from_syst = abap_true.
    ENDIF.

    o_http_client->receive(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        OTHERS                     = 4 ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          previous_from_syst = abap_true.
    ENDIF.

    r_content = o_http_client->response->get_cdata( ).

    o_http_client->close(
      EXCEPTIONS
        http_invalid_state = 1
        OTHERS             = 2 ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_abak.
    ENDIF.

  ENDMETHOD.


  METHOD zif_abak_content~get.
    r_text = g_text.
  ENDMETHOD.


  METHOD zif_abak_content~invalidate.
    g_text = fetch_from_url( ).
  ENDMETHOD.

  METHOD zif_abak_content~get_type.
    r_type = zif_abak_consts=>content_type-url.
  ENDMETHOD.
ENDCLASS.
