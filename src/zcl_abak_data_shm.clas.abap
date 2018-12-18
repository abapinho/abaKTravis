class ZCL_ABAK_DATA_SHM definition
  public
  inheriting from ZCL_ABAK_DATA
  final
  create public

  global friends ZCL_ABAK_FACTORY .

public section.

  methods CONSTRUCTOR
    importing
      !I_FORMAT_TYPE type ZABAK_FORMAT_TYPE
      !I_ORIGIN_TYPE type ZABAK_ORIGIN_TYPE
      !I_PARAM type STRING
    raising
      ZCX_ABAK .
protected section.

  methods LOAD_DATA_AUX
    redefinition .
  methods INVALIDATE_AUX
    redefinition .
private section.

  constants GC_MAX_INSTANCE_NAME type I value 80. "#EC NOTEXT
  data G_FORMAT_TYPE type ZABAK_FORMAT_TYPE .
  data G_ORIGIN_TYPE type ZABAK_ORIGIN_TYPE .
  data G_PARAM type STRING .

  methods READ_SHM
    exporting
      value(ET_K) type ZABAK_K_T
      !E_NAME type STRING
    raising
      ZCX_ABAK
      CX_SHM_NO_ACTIVE_VERSION
      CX_SHM_INCONSISTENT .
  methods WRITE_SHM
    exporting
      value(ET_K) type ZABAK_K_T
      !E_NAME type STRING
    raising
      ZCX_ABAK .
  methods GET_INSTANCE_NAME
    returning
      value(R_INSTANCE_NAME) type SHM_INST_NAME .
  methods HASH
    importing
      !I_DATA type STRING
    returning
      value(R_HASHED) type STRING .
ENDCLASS.



CLASS ZCL_ABAK_DATA_SHM IMPLEMENTATION.


METHOD constructor.

  super->constructor( ).

  IF i_format_type IS INITIAL OR i_origin_type IS INITIAL OR i_param IS INITIAL.
    RAISE EXCEPTION TYPE zcx_abak
      EXPORTING
        textid = zcx_abak=>invalid_parameters.
  ENDIF.

  g_format_type = i_format_type.
  g_origin_type = i_origin_type.
  g_param = i_param.

ENDMETHOD.


METHOD get_instance_name.
  DATA: instance_name TYPE string.

  instance_name = |{ g_format_type }.{ g_origin_type }.{ g_param }|.

  IF strlen( instance_name ) <= gc_max_instance_name.
    r_instance_name = instance_name.
  ELSE.
*   If the instance name size is too big just hash it
    r_instance_name = hash( instance_name ).
  ENDIF.

ENDMETHOD.


METHOD hash.

  DATA: hashed TYPE hash160.

  CALL FUNCTION 'CALCULATE_HASH_FOR_CHAR'
    EXPORTING
      data           = i_data
    IMPORTING
      hash           = hashed
    EXCEPTIONS
      unknown_alg    = 1
      param_error    = 2
      internal_error = 3
      OTHERS         = 4.
  IF sy-subrc <> 0.
*   This will probably never happen so we'll just call it HASH_ERROR
    hashed = 'HASH_ERROR'.
  ENDIF.

  r_hashed = hashed.

ENDMETHOD.


METHOD invalidate_aux.
  DATA: o_broker TYPE REF TO zcl_abak_shm_area.

  LOG-POINT ID zabak SUBKEY 'format_shm.invalidate'. " TODO

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


METHOD load_data_aux.

  DATA: o_exp TYPE REF TO cx_shm_parameter_error.

  LOG-POINT ID zabak SUBKEY 'format_shm.get_data'. " TODO

  TRY.
      read_shm( IMPORTING et_k   = et_k
                          e_name = e_name ).

    CATCH cx_shm_no_active_version.
      write_shm( IMPORTING et_k   = et_k
                           e_name = e_name ).

    CATCH cx_shm_inconsistent.
      TRY.
          zcl_abak_shm_area=>free_instance( get_instance_name( ) ).
          write_shm( IMPORTING et_k   = et_k
                               e_name = e_name ).

        CATCH cx_shm_parameter_error INTO o_exp.
          LOG-POINT ID zabak SUBKEY 'format_shm.get_data' FIELDS o_exp->get_text( ).
      ENDTRY.

  ENDTRY.

ENDMETHOD.


METHOD read_shm.

  DATA: o_broker      TYPE REF TO zcl_abak_shm_area,
        o_exp         TYPE REF TO cx_root.

  TRY.
      o_broker = zcl_abak_shm_area=>attach_for_read( get_instance_name( ) ).
      et_k = o_broker->root->get_data( ).
      e_name = o_broker->root->get_name( ).
      o_broker->detach( ).

    CATCH cx_shm_exclusive_lock_active
          cx_shm_change_lock_active
          cx_shm_read_lock_active INTO o_exp.

      RAISE EXCEPTION TYPE zcx_abak
        EXPORTING
          previous = o_exp.

  ENDTRY.

ENDMETHOD.


METHOD write_shm.

  DATA: o_broker      TYPE REF TO zcl_abak_shm_area,
        o_root        TYPE REF TO zcl_abak_shm_root,
        o_exp         TYPE REF TO cx_root,
        o_abak_exp  TYPE REF TO zcx_abak.

  TRY.
      LOG-POINT ID zabak SUBKEY 'data_shm.write_shm'. " TODO

      o_broker = zcl_abak_shm_area=>attach_for_write( get_instance_name( ) ).

      TRY.
          CREATE OBJECT o_root AREA HANDLE o_broker
            EXPORTING
              i_format_type = g_format_type
              i_origin_type = g_origin_type
              i_param       = g_param.

          o_broker->set_root( o_root ).
          et_k = o_root->get_data( ).
          e_name = o_root->get_name( ).

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
ENDCLASS.
