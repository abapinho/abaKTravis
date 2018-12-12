CLASS zcl_abak_source_shm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abak_source .

    METHODS constructor
      IMPORTING
        !i_source_type TYPE zabak_source_type
        !i_origin_type TYPE zabak_origin_type
        !i_param TYPE string
      RAISING
        zcx_abak .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS: gc_max_instance_name TYPE i VALUE 80.

    DATA g_source_type TYPE zabak_source_type .
    DATA g_origin_type TYPE zabak_origin_type .
    DATA g_param TYPE string .

    METHODS read_shm
      RETURNING
        value(rt_k) TYPE zabak_k_t
      RAISING
        zcx_abak
        cx_shm_no_active_version
        cx_shm_inconsistent .
    METHODS write_shm
      RETURNING
        value(rt_k) TYPE zabak_k_t
      RAISING
        zcx_abak .
    METHODS get_instance_name
      RETURNING
        value(r_instance_name) TYPE shm_inst_name .
    METHODS hash
      IMPORTING
        !i_data TYPE string
      RETURNING
        value(r_hashed) TYPE string .
ENDCLASS.



CLASS zcl_abak_source_shm IMPLEMENTATION.


  METHOD constructor.

    g_source_type = i_source_type.
    g_origin_type = i_origin_type.
    g_param = i_param.

    zif_abak_source~get_data( ).

  ENDMETHOD.


  METHOD get_instance_name.
    DATA: instance_name TYPE string.

    instance_name = |{ g_source_type }.{ g_origin_type }.{ g_param }|.

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


  METHOD read_shm.

    DATA: o_broker      TYPE REF TO zcl_abak_shm_area,
          o_exp         TYPE REF TO cx_root.

    TRY.
        o_broker = zcl_abak_shm_area=>attach_for_read( get_instance_name( ) ).
        rt_k = o_broker->root->get_data( ).
        o_broker->detach( ).

      CATCH cx_shm_exclusive_lock_active
            cx_shm_change_lock_active
            cx_shm_read_lock_active INTO o_exp.

        RAISE EXCEPTION TYPE zcx_abak
          EXPORTING
            previous = o_exp.

    ENDTRY.

  ENDMETHOD.                                             "#EC CI_VALPAR


  METHOD write_shm.

    DATA: o_broker      TYPE REF TO zcl_abak_shm_area,
          o_root        TYPE REF TO zcl_abak_shm_root,
          o_exp         TYPE REF TO cx_root,
          o_abak_exp  TYPE REF TO zcx_abak.

    TRY.
        LOG-POINT ID zabak SUBKEY 'source_shm.write_shm' FIELDS me->zif_abak_source~get_name( ).

        o_broker = zcl_abak_shm_area=>attach_for_write( get_instance_name( ) ).

        TRY.
            CREATE OBJECT o_root AREA HANDLE o_broker
              EXPORTING
                i_source_type = g_source_type
                i_origin_type = g_origin_type
                i_param       = g_param.

            o_broker->set_root( o_root ).
            rt_k = o_root->get_data( ).
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

  ENDMETHOD.                                             "#EC CI_VALPAR


  METHOD zif_abak_source~get_data.

    DATA: o_exp TYPE REF TO cx_shm_parameter_error.

    LOG-POINT ID zabak SUBKEY 'source_shm.get_data' FIELDS zif_abak_source~get_name( ).

    TRY.
        rt_k = read_shm( ).

      CATCH cx_shm_no_active_version.
        rt_k = write_shm( ).

      CATCH cx_shm_inconsistent.
        TRY.
            zcl_abak_shm_area=>free_area( ).
            rt_k = write_shm( ).

          CATCH cx_shm_parameter_error INTO o_exp.
            LOG-POINT ID zabak SUBKEY 'source_shm.get_data' FIELDS o_exp->get_text( ).
        ENDTRY.

    ENDTRY.

  ENDMETHOD.


  METHOD zif_abak_source~get_name.
    r_name = |SHM.{ get_instance_name( ) }|.
  ENDMETHOD.


  METHOD zif_abak_source~invalidate.

    DATA: o_broker TYPE REF TO zcl_abak_shm_area.

    LOG-POINT ID zabak SUBKEY 'source_shm.invalidate' FIELDS me->zif_abak_source~get_name( ).

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
ENDCLASS.
