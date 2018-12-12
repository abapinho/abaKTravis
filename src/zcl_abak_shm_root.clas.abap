class ZCL_ABAK_SHM_ROOT definition
  public
  final
  create public
  shared memory enabled .

public section.

  methods CONSTRUCTOR
    importing
      !I_SOURCE_TYPE type ZABAK_SOURCE_TYPE
      !I_CONTENT type STRING
    raising
      ZCX_ABAK .
  methods GET_DATA
    returning
      value(RT_K) type ZABAK_K_T
    raising
      ZCX_ABAK .
protected section.
private section.

  data G_SOURCE_TYPE type ZABAK_SOURCE_TYPE .
  data G_CONTENT type STRING .
  data GT_K type ZABAK_K_T .
  data G_LOADED type FLAG .

  methods GET_SOURCE
    returning
      value(RO_SOURCE) type ref to ZIF_ABAK_SOURCE
    raising
      ZCX_ABAK .
  methods LOAD_DATA
    raising
      ZCX_ABAK .
ENDCLASS.



CLASS ZCL_ABAK_SHM_ROOT IMPLEMENTATION.


METHOD CONSTRUCTOR.

  g_source_type = i_source_type.
  g_content     = i_content.

  load_data( ).

ENDMETHOD.


METHOD GET_DATA.

  LOG-POINT ID zabak SUBKEY 'source_shm.get_data' FIELDS g_source_type g_content.

  load_data( ).

  rt_k = gt_k.

ENDMETHOD.


METHOD GET_SOURCE.
  ro_source = zcl_abak_source_factory=>get_instance( i_source_type = g_source_type
                                                     i_content     = g_content ).
ENDMETHOD.


METHOD LOAD_DATA.

  IF g_loaded IS INITIAL.
    gt_k = zcl_abak_source_factory=>get_instance( i_source_type = g_source_type
                                                  i_content     = g_content )->get_data( ).
    g_loaded = abap_true.
  ENDIF.

ENDMETHOD.
ENDCLASS.
