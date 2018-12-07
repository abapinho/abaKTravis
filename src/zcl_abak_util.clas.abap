class ZCL_ABAK_UTIL definition
  public
  final
  create public
  shared memory enabled .

public section.

  methods CHECK_TABLE
    importing
      !I_TABLENAME type TABNAME
    raising
      ZCX_ABAK .
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


METHOD CHECK_TABLE.
  DATA: o_structdescr TYPE REF TO cl_abap_structdescr,
        t_component TYPE cl_abap_structdescr=>component_table.

  FIELD-SYMBOLS: <s_component> LIKE LINE OF t_component.

  o_structdescr ?= cl_abap_structdescr=>describe_by_name( i_tablename ).
  t_component = o_structdescr->get_components( ).

* Two components expected
  IF lines( t_component ) <> 2.
    RAISE EXCEPTION TYPE zcx_abak.
  ENDIF.

* Both components are includes
  LOOP AT t_component TRANSPORTING NO FIELDS WHERE as_include <> 'X'.
    RAISE EXCEPTION TYPE zcx_abak.
  ENDLOOP.

* 1st include is ZABAK_KEYS
  READ TABLE t_component ASSIGNING <s_component> INDEX 1.
  IF <s_component>-type->absolute_name <> '\TYPE=ZABAK_KEY'.
    RAISE EXCEPTION TYPE zcx_abak.
  ENDIF.

* 2nd include is ZABAK_FIELDS
  READ TABLE t_component ASSIGNING <s_component> INDEX 2.
  IF <s_component>-type->absolute_name <> '\TYPE=ZABAK_FIELDS'.
    RAISE EXCEPTION TYPE zcx_abak.
  ENDIF.

ENDMETHOD.


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
