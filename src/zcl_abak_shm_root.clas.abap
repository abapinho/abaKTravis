CLASS zcl_abak_shm_root DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  SHARED MEMORY ENABLED .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !i_source_type TYPE zabak_source_type
        !i_origin_type TYPE zabak_origin_type
        !i_param TYPE string
      RAISING
        zcx_abak .
    METHODS get_data
      RETURNING
        value(rt_k) TYPE zabak_k_t
      RAISING
        zcx_abak .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA g_source_type TYPE zabak_source_type .
    DATA g_origin_type TYPE zabak_origin_type .
    DATA g_param TYPE string .
    DATA gt_k TYPE zabak_k_t .
    DATA g_loaded TYPE flag .

    METHODS get_source
      RETURNING
        value(ro_source) TYPE REF TO zif_abak_source
      RAISING
        zcx_abak .
    METHODS load_data
      RAISING
        zcx_abak .
ENDCLASS.



CLASS zcl_abak_shm_root IMPLEMENTATION.


  METHOD constructor.

    g_source_type = i_source_type.
    g_origin_type = i_origin_type.
    g_param = i_param.

    load_data( ).

  ENDMETHOD.


  METHOD get_data.

    LOG-POINT ID zabak SUBKEY 'source_shm.get_data' FIELDS g_source_type g_origin_type g_param.

    load_data( ).

    rt_k = gt_k.

  ENDMETHOD.                                             "#EC CI_VALPAR


  METHOD get_source.
    ro_source = zcl_abak_source_factory=>get_instance( i_source_type   = g_source_type
                                                       i_origin_type = g_origin_type
                                                       i_param         = g_param ).
  ENDMETHOD.


  METHOD load_data.

    IF g_loaded IS INITIAL.
      gt_k = get_source( )->get_data( ).
      g_loaded = abap_true.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
