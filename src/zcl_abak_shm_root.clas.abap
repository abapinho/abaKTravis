class ZCL_ABAK_SHM_ROOT definition
  public
  final
  create public
  shared memory enabled .

public section.

  methods CONSTRUCTOR
    importing
      !I_SOURCE_TYPE type ZABAK_SOURCE_TYPE
      !I_LOCATION_TYPE type ZABAK_LOCATION_TYPE
      !I_PARAM type STRING
    raising
      ZCX_ABAK .
  methods GET_DATA
    returning
      value(RT_K) type ZABAK_K_T
    raising
      ZCX_ABAK .
protected section.
PRIVATE SECTION.

  DATA g_source_type TYPE zabak_source_type .
  DATA g_location_type TYPE zabak_location_type .
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



CLASS ZCL_ABAK_SHM_ROOT IMPLEMENTATION.


METHOD CONSTRUCTOR.

  g_source_type = i_source_type.
  g_location_type = i_location_type.
  g_param = i_param.

  load_data( ).

ENDMETHOD.


METHOD GET_DATA.

  LOG-POINT ID zabak SUBKEY 'source_shm.get_data' FIELDS g_source_type g_location_type g_param.

  load_data( ).

  rt_k = gt_k.

ENDMETHOD. "#EC CI_VALPAR


METHOD GET_SOURCE.
  ro_source = zcl_abak_source_factory=>get_instance( i_source_type   = g_source_type
                                                     i_location_type = g_location_type
                                                     i_param         = g_param ).
ENDMETHOD.


METHOD LOAD_DATA.

  IF g_loaded IS INITIAL.
    gt_k = get_source( )->get_data( ).
    g_loaded = abap_true.
  ENDIF.

ENDMETHOD.
ENDCLASS.
