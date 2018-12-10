class ZCL_ABAK_SOURCE_XML_URL definition
  public
  final
  create public .

public section.

  interfaces ZIF_ABAK_SOURCE .

  methods CONSTRUCTOR
    importing
      !I_URL type STRING
    raising
      ZCX_ABAK .
protected section.
private section.

  data GO_SOURCE_XML type ref to ZIF_ABAK_SOURCE .
  data G_URL type STRING .

  methods FETCH_CONTENT_FROM_URL
    importing
      !I_URL type STRING
    returning
      value(R_CONTENT) type STRING
    raising
      ZCX_ABAK .
ENDCLASS.



CLASS ZCL_ABAK_SOURCE_XML_URL IMPLEMENTATION.


METHOD constructor.

  g_url = i_url.

  CREATE OBJECT go_source_xml TYPE zcl_abak_source_xml
    EXPORTING
      i_xml = fetch_content_from_url( g_url ).

ENDMETHOD.


method FETCH_CONTENT_FROM_URL.
  data: o_util type ref to zcl_abak_util.

  create object o_util.
  r_content = o_util->fetch_content_from_url( i_url ).

endmethod.


method ZIF_ABAK_SOURCE~GET_DATA.
  rt_data = go_source_xml->get_data( ).
endmethod.


method ZIF_ABAK_SOURCE~GET_NAME.
  r_name = |URL.{ go_source_xml->get_name( ) }|.
endmethod.


METHOD zif_abak_source~invalidate.
  CREATE OBJECT go_source_xml TYPE zcl_abak_source_xml
    EXPORTING
      i_xml = fetch_content_from_url( g_url ).
ENDMETHOD.
ENDCLASS.
