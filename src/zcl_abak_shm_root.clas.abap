CLASS zcl_abak_shm_root DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  SHARED MEMORY ENABLED .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !i_format_type TYPE zabak_format_type
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

    DATA g_format_type TYPE zabak_format_type .
    DATA g_origin_type TYPE zabak_origin_type .
    DATA g_param TYPE string .
    DATA gt_k TYPE zabak_k_t .
    DATA g_loaded TYPE flag .

    METHODS get_format
      RETURNING
        value(ro_format) TYPE REF TO zif_abak_format
      RAISING
        zcx_abak .
    METHODS load_data
      RAISING
        zcx_abak .
ENDCLASS.



CLASS zcl_abak_shm_root IMPLEMENTATION.


  METHOD constructor.

    g_format_type = i_format_type.
    g_origin_type = i_origin_type.
    g_param = i_param.

    load_data( ).

  ENDMETHOD.


  METHOD get_data.

    LOG-POINT ID zabak SUBKEY 'format_shm.get_data' FIELDS g_format_type g_origin_type g_param.

    load_data( ).

    rt_k = gt_k.

  ENDMETHOD.                                             "#EC CI_VALPAR


  METHOD get_format.
    ro_format = zcl_abak_format_factory=>get_instance( i_format_type   = g_format_type
                                                       i_origin_type = g_origin_type
                                                       i_param         = g_param ).
  ENDMETHOD.


  METHOD load_data.

    IF g_loaded IS INITIAL.
      gt_k = get_format( )->get_data( ).
      g_loaded = abap_true.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
