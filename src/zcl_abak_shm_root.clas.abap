class ZCL_ABAK_SHM_ROOT definition
  public
  final
  create public
  shared memory enabled .

public section.

  methods CONSTRUCTOR
    importing
      !I_FORMAT_TYPE type ZABAK_FORMAT_TYPE
      !I_ORIGIN_TYPE type ZABAK_ORIGIN_TYPE
      !I_PARAM type STRING
    raising
      ZCX_ABAK .
  methods GET_DATA
    returning
      value(RT_K) type ZABAK_K_T
    raising
      ZCX_ABAK .
  methods GET_NAME
    returning
      value(R_NAME) type STRING
    raising
      ZCX_ABAK .
  PROTECTED SECTION.
private section.

  data G_FORMAT_TYPE type ZABAK_FORMAT_TYPE .
  data G_ORIGIN_TYPE type ZABAK_ORIGIN_TYPE .
  data G_PARAM type STRING .
  data GT_K type ZABAK_K_T .
  data g_name type string.
  data G_LOADED type FLAG .

  methods LOAD_DATA
    raising
      ZCX_ABAK .
ENDCLASS.



CLASS ZCL_ABAK_SHM_ROOT IMPLEMENTATION.


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


method GET_NAME.
  load_data( ).
  r_name = g_name.
endmethod.


  METHOD load_data.
    DATA o_data TYPE REF TO zcl_abak_data_normal.
    IF g_loaded IS INITIAL.
      CREATE OBJECT o_data
        EXPORTING
          io_format = zcl_abak_format_factory=>get_instance( g_format_type )
          io_origin = zcl_abak_origin_factory=>get_instance( i_origin_type = g_origin_type
                                                             i_param       = g_param ).

      gt_k = o_data->zif_abak_data_get_data~get_data( ).
      g_name = o_data->zif_abak_data~get_name( ).
      g_loaded = abap_true.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
