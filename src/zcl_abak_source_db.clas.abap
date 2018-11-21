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
  data GT_DATA type ZABAK_DATA_T .

  methods LOAD_DATA .
ENDCLASS.



CLASS ZCL_ABAK_SOURCE_DB IMPLEMENTATION.


METHOD constructor.

  DATA: o_util TYPE REF TO zcl_abak_util.

  CREATE OBJECT o_util.
  o_util->check_table( i_tablename ).

  g_tablename = i_tablename.

ENDMETHOD.


method LOAD_DATA.

  if gt_data[] is not initial.
    return.
  endif.

  LOG-POINT ID zabak SUBKEY 'source_db.load_data' FIELDS g_tablename.

  SELECT *
    FROM (g_tablename)
    INTO TABLE gt_data.

endmethod.


METHOD ZIF_ABAK_SOURCE~GET_DATA.

  LOG-POINT ID zabak SUBKEY 'source_db.get_data' FIELDS g_tablename.

  load_data( ).

  rt_data = gt_data.

ENDMETHOD.


method ZIF_ABAK_SOURCE~GET_NAME.
  r_name = |DB:{ g_tablename }|.
endmethod.


METHOD ZIF_ABAK_SOURCE~INVALIDATE.
  CLEAR gt_data[].
ENDMETHOD.
ENDCLASS.
