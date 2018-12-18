class ZCL_ABAK_DATA_NORMAL definition
  public
  inheriting from ZCL_ABAK_DATA
  final
  create public

  global friends ZCL_ABAK_FACTORY .

public section.

  methods CONSTRUCTOR
    importing
      !IO_FORMAT type ref to ZIF_ABAK_FORMAT
      !IO_ORIGIN type ref to ZIF_ABAK_ORIGIN
    raising
      ZCX_ABAK .
protected section.

  methods LOAD_DATA_AUX
    redefinition .
  methods INVALIDATE_AUX
    redefinition .
private section.

  data GO_FORMAT type ref to ZIF_ABAK_FORMAT .
  data GO_ORIGIN type ref to ZIF_ABAK_ORIGIN .
ENDCLASS.



CLASS ZCL_ABAK_DATA_NORMAL IMPLEMENTATION.


METHOD CONSTRUCTOR.

  super->constructor( ).

  IF io_format IS NOT BOUND OR io_format IS NOT BOUND.
    RAISE EXCEPTION TYPE zcx_abak
      EXPORTING
        textid = zcx_abak=>invalid_parameters.
  ENDIF.

  go_format = io_format.
  go_origin = io_origin.

ENDMETHOD.


METHOD invalidate_aux.
  go_origin->invalidate( ).
ENDMETHOD.


METHOD load_data_aux.
  go_format->convert(
    EXPORTING
      i_data = go_origin->get( )
    IMPORTING
      et_k   = et_k
      e_name = e_name ).
ENDMETHOD.
ENDCLASS.
