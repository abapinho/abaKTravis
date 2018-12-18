CLASS zcl_abak_shm_root DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  SHARED MEMORY ENABLED .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !i_format_type TYPE zabak_format_type
        !i_content_type TYPE zabak_content_type
        !i_content_param TYPE string
      RAISING
        zcx_abak .
    METHODS get_data
      RETURNING
        value(rt_k) TYPE zabak_k_t
      RAISING
        zcx_abak .
    METHODS get_name
      RETURNING
        value(r_name) TYPE string
      RAISING
        zcx_abak .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA g_format_type TYPE zabak_format_type .
    DATA g_content_type TYPE zabak_content_type .
    DATA g_content_param TYPE string .
    DATA gt_k TYPE zabak_k_t .
    DATA g_name TYPE string.
    DATA g_loaded TYPE flag .

    METHODS load_data
      RAISING
        zcx_abak .
ENDCLASS.



CLASS zcl_abak_shm_root IMPLEMENTATION.


  METHOD constructor.

    g_format_type = i_format_type.
    g_content_type = i_content_type.
    g_content_param = i_content_param.

    load_data( ).

  ENDMETHOD.


  METHOD get_data.

    LOG-POINT ID zabak SUBKEY 'format_shm.get_data' FIELDS g_format_type g_content_type g_content_param.

    load_data( ).

    rt_k = gt_k.

  ENDMETHOD.                                             "#EC CI_VALPAR


  METHOD get_name.
    load_data( ).
    r_name = g_name.
  ENDMETHOD.


  METHOD load_data.
    DATA o_data TYPE REF TO zif_abak_data.
    IF g_loaded IS INITIAL.
      o_data = zcl_abak_data_factory=>get_instance( i_format_type  = g_format_type
                                                    i_content_type  = g_content_type
                                                    i_content_param = g_content_param ).

      gt_k = o_data->get_data( ).
      g_name = o_data->get_name( ).
      g_loaded = abap_true.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
