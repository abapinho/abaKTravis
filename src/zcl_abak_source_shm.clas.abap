class ZCL_ABAK_SOURCE_SHM definition
  public
  final
  create public

  global friends ZCL_ZS_CONSTS .

public section.

  interfaces ZIF_ABAK_SOURCE .

  methods CONSTRUCTOR
    importing
      !I_TABLENAME type TABNAME
    raising
      ZCX_ABAK .
protected section.
private section.

  data GT_DATA type ZABAK_DATA_T .
  data G_DATA_LOADED type FLAG .
  data G_TABLENAME type TABNAME .

  methods READ_SHM
    raising
      ZCX_ABAK
      CX_SHM_NO_ACTIVE_VERSION .
  methods WRITE_SHM
    raising
      ZCX_ABAK .
  methods LOAD_DATA
    raising
      ZCX_ABAK .
  methods INVALIDATE_SHM .
ENDCLASS.



CLASS ZCL_ABAK_SOURCE_SHM IMPLEMENTATION.


METHOD constructor.

  DATA: o_util TYPE REF TO zcl_abak_util.

  CREATE OBJECT o_util.
  o_util->check_table( i_tablename ).

  g_tablename = i_tablename.

ENDMETHOD.


METHOD INVALIDATE_SHM.

  DATA: o_broker TYPE REF TO zcl_abak_shm_area.

  TRY.
      o_broker = zcl_abak_shm_area=>attach_for_read( ).

      o_broker->invalidate_area( ).

      o_broker->detach( ).

    CATCH cx_shm_attach_error
          cx_shm_parameter_error
          cx_sy_ref_is_initial
          cx_dynamic_check.
      "If the area does not exist, no need to invalidate it
      RETURN.

  ENDTRY.

ENDMETHOD.


METHOD LOAD_DATA.

  IF g_data_loaded = abap_true.
    RETURN.
  ENDIF.

  TRY.
      read_shm( ).

    CATCH cx_shm_no_active_version.

      write_shm( ).

  ENDTRY.

  g_data_loaded = abap_true.

ENDMETHOD.


METHOD READ_SHM.
* Code partially copied from book "ABAP to the Future"

  DATA: o_broker      TYPE REF TO zcl_abak_shm_area,
        o_exp         TYPE REF TO cx_root,
        instance_name TYPE shm_inst_name.

  TRY.
      instance_name = g_tablename.

      "We create an instance of the broker class which
      "contains within it a reference to the instance of
      "the root class which lives in shared memory
      "A (non exclusive) read lock is also set
      o_broker = zcl_abak_shm_area=>attach_for_read( instance_name ).

      "The root class contains our custom methods
      gt_data = o_broker->root->zif_abak_source~get_data( ).

      "Release read lock ; ending the transaction would
      "have the same result
      o_broker->detach( ).

    CATCH cx_shm_inconsistent "Root class is out of date
          cx_shm_exclusive_lock_active "Someone trying to change
          cx_shm_change_lock_active "Someone trying to change data
          cx_shm_read_lock_active INTO o_exp. "Amazingly, this can be an error

      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          previous = o_exp.

  ENDTRY.

ENDMETHOD.


METHOD write_shm.

  DATA: o_broker      TYPE REF TO zcl_abak_shm_area,
        o_root        TYPE REF TO zcl_abak_source_db,
        o_exp         TYPE REF TO cx_root,
        o_abak_exp  TYPE REF TO zcx_abak,
        instance_name TYPE shm_inst_name.

  TRY.

      LOG-POINT ID zabak SUBKEY 'source_shm.write_shm' FIELDS me->zif_abak_source~get_name( ).

      instance_name = g_tablename.

      "Open the shared memory area for write access
      o_broker = zcl_abak_shm_area=>attach_for_write( instance_name ).

      TRY.

          CREATE OBJECT o_root AREA HANDLE o_broker
            EXPORTING
              i_tablename = g_tablename.

          o_broker->set_root( o_root ).

          gt_data = o_root->zif_abak_source~get_data( ).

          o_broker->detach_commit( ).

        CATCH zcx_abak INTO o_abak_exp.

          o_broker->detach_rollback( ).

          RAISE EXCEPTION o_abak_exp.

      ENDTRY.

    CATCH cx_shm_error INTO o_exp.

      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          previous = o_exp.

  ENDTRY.

ENDMETHOD.


METHOD zif_abak_source~get_data.

  LOG-POINT ID zabak SUBKEY 'source_shm.get_data' FIELDS zif_abak_source~get_name( ).

  load_data( ).

  rt_data = gt_data.

ENDMETHOD.


method ZIF_ABAK_SOURCE~GET_NAME.
  r_name = |SHM:{ g_tablename }|.
endmethod.


METHOD zif_abak_source~invalidate.

  LOG-POINT ID zabak SUBKEY 'source_shm.invalidate' FIELDS me->zif_abak_source~get_name( ).

  CLEAR gt_data[].

  g_data_loaded = abap_false.

  invalidate_shm( ).

ENDMETHOD.
ENDCLASS.
