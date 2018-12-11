class ZCL_ABAK_UTIL definition
  public
  final
  create public
  shared memory enabled .

public section.

  methods FETCH_CONTENT_FROM_URL
    importing
      !I_URL type STRING
    returning
      value(R_CONTENT) type STRING
    raising
      ZCX_ABAK .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ABAK_UTIL IMPLEMENTATION.


method FETCH_CONTENT_FROM_URL.

  DATA: o_http_client TYPE REF TO if_http_client.

  cl_http_client=>create_by_url(
    EXPORTING
      url                = i_url
    IMPORTING
      client             = o_http_client
    EXCEPTIONS
      argument_not_found = 1
      plugin_not_active  = 2
      internal_error     = 3
      OTHERS             = 4 ).
  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE ZCX_ABAK
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
    RAISE EXCEPTION TYPE ZCX_ABAK
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
    RAISE EXCEPTION TYPE ZCX_ABAK
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

endmethod.
ENDCLASS.
