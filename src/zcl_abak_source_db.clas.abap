class ZCL_ABAK_SOURCE_DB definition
  public
  final
  create public
  shared memory enabled .

public section.

  interfaces ZIF_ABAK_SOURCE .

  methods CONSTRUCTOR
    importing
      !I_TABLENAME type TABNAME
    raising
      ZCX_ABAK .
protected section.
private section.

  data G_TABLENAME type TABNAME .

  methods CHECK_TABLE
    importing
      !I_TABLENAME type TABNAME
    raising
      ZCX_ABAK .
ENDCLASS.



CLASS ZCL_ABAK_SOURCE_DB IMPLEMENTATION.


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


METHOD constructor.

  check_table( i_tablename ).

  g_tablename = i_tablename.

ENDMETHOD.


METHOD zif_abak_source~get_data.

  LOG-POINT ID zabak SUBKEY 'source_db.get_data' FIELDS g_tablename.

  SELECT *
    FROM (g_tablename)
    INTO TABLE rt_data.

ENDMETHOD.


method ZIF_ABAK_SOURCE~GET_NAME.
  r_name = |DB.{ g_tablename }|.
endmethod.


METHOD ZIF_ABAK_SOURCE~INVALIDATE.
  RETURN. " Nothing to invalidate in this case
ENDMETHOD.
ENDCLASS.
