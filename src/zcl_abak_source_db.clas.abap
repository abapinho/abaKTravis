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
  methods CONVERT
    importing
      !IT_DB type ZABAK_DB_T
    returning
      value(RT_K) type ZABAK_K_T
    raising
      ZCX_ABAK .
  methods SELECT
    importing
      !I_TABLENAME type TABNAME
    returning
      value(RT_DATA) type ZABAK_DB_T .
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

* 1st include is ZABAK_DB_KEYS
  READ TABLE t_component ASSIGNING <s_component> INDEX 1.
  IF <s_component>-type->absolute_name <> '\TYPE=ZABAK_DB_KEY'.
    RAISE EXCEPTION TYPE zcx_abak.
  ENDIF.

* 2nd include is ZABAK_DB_FIELDS
  READ TABLE t_component ASSIGNING <s_component> INDEX 2.
  IF <s_component>-type->absolute_name <> '\TYPE=ZABAK_DB_FIELDS'.
    RAISE EXCEPTION TYPE zcx_abak.
  ENDIF.

ENDMETHOD.


METHOD constructor.

  check_table( i_tablename ).

  g_tablename = i_tablename.

ENDMETHOD.


METHOD convert.

  DATA: s_k LIKE LINE OF rt_k,
        s_kv LIKE LINE OF s_k-t_kv.

  FIELD-SYMBOLS: <s_db> LIKE LINE OF it_db,
                 <s_k>  LIKE LINE OF rt_k.

  LOOP AT it_db ASSIGNING <s_db>.

    DO 2 TIMES.
*     Get K line
      READ TABLE rt_k ASSIGNING <s_k>
        WITH KEY ricef = <s_db>-ricef
                 fieldname = <s_db>-fieldname
                 context = <s_db>-context.
      IF sy-subrc = 0.
        EXIT.
      ELSE.
*       Not found: create it and the next DO iteration gets it
        s_k-ricef = <s_db>-ricef.
        s_k-fieldname = <s_db>-fieldname.
        s_k-context = <s_db>-context.
        INSERT s_k INTO TABLE rt_k.
      ENDIF.
    ENDDO.

    IF <s_k> IS NOT ASSIGNED.
      RAISE EXCEPTION TYPE zcx_abak. " This can't really happen but...
    ENDIF.

    s_kv-sign = <s_db>-ue_sign.
    s_kv-option = <s_db>-ue_option.
    s_kv-low = <s_db>-ue_low.
    s_kv-high = <s_db>-ue_high.
    INSERT s_kv INTO TABLE <s_k>-t_kv.

  ENDLOOP.

ENDMETHOD.


METHOD select.

  SELECT *
    FROM (i_tablename)
    INTO TABLE rt_data.

ENDMETHOD.


METHOD zif_abak_source~get_data.

  LOG-POINT ID zabak SUBKEY 'source_db.get_data' FIELDS g_tablename.

  rt_k = convert( select( g_tablename ) ).

ENDMETHOD.


method ZIF_ABAK_SOURCE~GET_NAME.
  r_name = |DB.{ g_tablename }|.
endmethod.


METHOD ZIF_ABAK_SOURCE~INVALIDATE.
  RETURN. " Nothing to invalidate in this case
ENDMETHOD.
ENDCLASS.
