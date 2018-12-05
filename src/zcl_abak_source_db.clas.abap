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
ENDCLASS.



CLASS ZCL_ABAK_SOURCE_DB IMPLEMENTATION.


METHOD constructor.

  DATA: o_util TYPE REF TO zcl_abak_util.

  CREATE OBJECT o_util.
  o_util->check_table( i_tablename ).

  g_tablename = i_tablename.

ENDMETHOD.


METHOD zif_abak_source~get_data.

  LOG-POINT ID zabak SUBKEY 'source_db.get_data' FIELDS g_tablename.

  SELECT *
    FROM (g_tablename)
    INTO TABLE rt_data.

ENDMETHOD.


method ZIF_ABAK_SOURCE~GET_NAME.
  r_name = |DB:{ g_tablename }|.
endmethod.


METHOD ZIF_ABAK_SOURCE~INVALIDATE.
  RETURN. " Nothing to invalidate in this case
ENDMETHOD.
ENDCLASS.
